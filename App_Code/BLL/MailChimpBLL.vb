'========================================================================
'Kartris - www.kartris.com
'Copyright 2017 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports System
Imports MailChimp
Imports MailChimp.Net
Imports MailChimp.Net.Core
Imports System.Threading.Tasks
Imports Microsoft.VisualBasic
Imports MailChimp.Net.Interfaces
Imports MailChimp.Net.Models
Imports Newtonsoft.Json.Linq
Imports System.Collections.ObjectModel
Imports System.Web.Script.Serialization


'========================================================================
'See https://github.com/brandonseydel/MailChimp.Net
'
'Rather than reinvent the wheel, we're using Brandon Seydel's excellent
'MailChimp v3 API NuGet package.
'
'========================================================================
Public Class MailChimpBLL
    Dim listId As String = KartSettingsManager.GetKartConfig("general.mailchimp.listid")
    Dim apiKey As String = KartSettingsManager.GetKartConfig("general.mailchimp.apikey")
    Dim apiUrl As String = KartSettingsManager.GetKartConfig("general.mailchimp.apiurl")
    Dim mcStoreId As String = KartSettingsManager.GetKartConfig("general.mailchimp.storeid")
    Public manager As IMailChimpManager
    Dim currentLoggedUser As KartrisMemberShipUser
    Dim kartrisBasket As Basket
    Dim kartrisCurrencyCode As String

    ''' <summary>
    ''' Create a new action
    ''' if user not logged in
    ''' </summary>
    Sub New()
        apiKey = KartSettingsManager.GetKartConfig("general.mailchimp.apikey")
        apiUrl = KartSettingsManager.GetKartConfig("general.mailchimp.apiurl")
        manager = New MailChimpManager(apiKey)
        kartrisCurrencyCode = CurrenciesBLL.CurrencyCode(CurrenciesBLL.GetDefaultCurrency())
        currentLoggedUser = Nothing
        kartrisBasket = New Basket()
    End Sub

    ''' <summary>
    ''' Create a new action
    ''' for logged in user
    ''' </summary>
    Sub New(ByVal user As KartrisMemberShipUser, ByVal currencyCode As String)
        apiKey = KartSettingsManager.GetKartConfig("general.mailchimp.apikey")
        apiUrl = KartSettingsManager.GetKartConfig("general.mailchimp.apiurl")
        manager = New MailChimpManager(apiKey)
        currentLoggedUser = user
        Me.kartrisCurrencyCode = currencyCode
    End Sub

    ''' <summary>
    ''' Create a new action
    ''' logged in user with basket
    ''' </summary>
    Sub New(ByRef user As KartrisMemberShipUser, ByRef basket As Basket, ByRef currencyCode As String)
        manager = New MailChimpManager(apiKey)
        currentLoggedUser = user
        kartrisBasket = basket
        Me.kartrisCurrencyCode = currencyCode
    End Sub

    ''' <summary>
    ''' Get customer using Kartris customer ID
    ''' from mailchimp account
    ''' </summary>
    Public Async Function GetCustomer(ByVal kartrisUserId As Integer) As Task(Of Customer)
        Dim customer As Customer = Nothing
        Try
            customer = Await manager.ECommerceStores.Customers(mcStoreId).GetAsync(kartrisUserId)
        Catch ex As Exception
            Debug.Print(ex.Message)
        End Try
        Return customer
    End Function

    ''' <summary>
    ''' Add cart to mailchimp and tagged for
    ''' right customer
    ''' </summary>
    Public Async Function AddCartToCustomerToStore(Optional ByVal orderId As Integer = 0) As Task(Of String)
        Dim mcStore As Store = New Store()
        Dim toReturn As String = ""
        Dim storeName As String = KartSettingsManager.GetKartConfig("general.mailchimp.storeid")
        Try
            mcStore = Await manager.ECommerceStores.GetAsync(KartSettingsManager.GetKartConfig("general.mailchimp.storeid")).ConfigureAwait(False)
        Catch ex As Exception
            If ex.Message.Contains("Unable to find the resource at") Then
                mcStore = Nothing
            End If
            'Debug.Print(ex.Message)
            'Log the error
            'CkartrisFormatErrors.LogError("MailchimpBLL AddCartToCustomerToStore(1): " & ex.Message)
        End Try

        Try
            If (mcStore Is Nothing) Then
                mcStore = Await Me.AddStore(storeName).ConfigureAwait(False)
            End If

            Dim customer As Customer
            Try
                customer = Await manager.ECommerceStores.Customers(mcStore.Id).GetAsync(currentLoggedUser.ID)
            Catch ex As Exception
                customer = Nothing
            End Try
            If customer Is Nothing Then
                customer = Await Me.AddCustomer().ConfigureAwait(False)
            End If

            If customer IsNot Nothing Then
                Dim cart As Cart = Await AddCart(customer, orderId).ConfigureAwait(False)
                If cart IsNot Nothing Then
                    toReturn = cart.Id
                End If
                'Dim order As Order = Await AddOrder(customer).ConfigureAwait(False)
            End If
        Catch ex As Exception
            'Debug.Print(ex.Message)
            'Log the error
            CkartrisFormatErrors.LogError("MailchimpBLL AddCartToCustomerToStore(2): " & ex.Message)
        End Try
        Return toReturn
    End Function

    'Public Async Function AddUpdateMember() As Task(Of Member)
    '    Try
    '        Dim userFullName As String = ""
    '        userFullName = UsersBLL.GetNameandEUVAT(currentLoggedUser.ID).Split("|||")(0)
    '        Dim userNamesArray() As String = userFullName.Split(" ")
    '        'Use the Status property if updating an existing member
    '        Dim member As Member = New Member With {.Id = currentLoggedUser.ID,
    '                                            .EmailAddress = currentLoggedUser.Email,
    '                                            .StatusIfNew = Status.Subscribed}
    '        member.MergeFields.Add("FNAME", userNamesArray(0))
    '        If (userNamesArray.Length > 1) Then
    '            member.MergeFields.Add("LNAME", userNamesArray(1))
    '        End If

    '        Dim taskResult As Member = Await manager.Members.AddOrUpdateAsync(listId, member).ConfigureAwait(False)
    '        Return taskResult
    '    Catch ex As Exception
    '        Debug.Print(ex.Message)
    '    End Try
    'End Function

    ''' <summary>
    ''' Add customer record to mailchimp
    ''' </summary>
    Public Async Function AddCustomer() As Task(Of Customer)
        Try
            Dim userFullName As String = ""
            userFullName = UsersBLL.GetNameandEUVAT(currentLoggedUser.ID).Split("|||")(0)
            Dim userNamesArray() As String = userFullName.Split(" ")
            'Use the Status property if updating an existing member
            Dim customer As Customer = New Customer With {.Id = currentLoggedUser.ID,
                                                            .EmailAddress = currentLoggedUser.Email,
                                                            .OptInStatus = True
                                                        }
            customer.FirstName = userNamesArray(0)
            If (userNamesArray.Length > 1) Then
                customer.LastName = userNamesArray(1)
            End If

            Dim taskResult As Customer = Await manager.ECommerceStores.Customers(mcStoreId).AddAsync(customer).ConfigureAwait(False)
            Return taskResult
        Catch ex As Exception
            'Debug.Print(ex.Message)
            'Log the error
            CkartrisFormatErrors.LogError("MailchimpBLL AddCustomer: " & ex.Message)
        End Try
    End Function

    ''' <summary>
    ''' Add product to mailchimp
    ''' </summary>
    Public Async Function AddProduct(ByVal basketItem As BasketItem) As Task(Of Product)
        Try
            Dim product As Product
            Dim productVariant As [Variant]
            Dim listVariants As List(Of [Variant]) = New List(Of [Variant])
            Try
                product = Await manager.ECommerceStores.Products(mcStoreId).GetAsync(basketItem.ProductID).ConfigureAwait(False)
            Catch ex As Exception
                If ex.Message.Contains("A product with the provided ID already") Then
                    product = Nothing
                End If
            End Try

            Dim itemprice As Double
            If basketItem.PricesIncTax = True Then
                itemprice = basketItem.IR_PricePerItem
            Else
                itemprice = Math.Round((basketItem.IR_PricePerItem * (1 + basketItem.IR_TaxPerItem)), 2)
            End If

            Dim imageUrl As String = CkartrisBLL.WebShopURL & "Image.aspx?strItemType=p&numMaxHeight=100&numMaxWidth=100&numItem=" & basketItem.ProductID
            If product Is Nothing Then
                productVariant = New [Variant] With {.Id = basketItem.ProductID,
                                                 .Title = basketItem.Name,
                                                 .Price = itemprice,
                                                 .ImageUrl = imageUrl
                                                }

                listVariants.Add(productVariant)
                product = New Product With {.Id = basketItem.ProductID,
                                            .Title = basketItem.Name,
                                            .Variants = listVariants,
                                            .ImageUrl = imageUrl
                                            }

                Dim taskResult As Product = Await manager.ECommerceStores.Products(mcStoreId).AddAsync(product).ConfigureAwait(False)
                Return taskResult
            Else
                Dim modified As Boolean = False
                If product.Title <> basketItem.Name Then
                    product.Title = basketItem.Name
                    product.Variants.First().Title = basketItem.Name
                    modified = True
                End If
                If product.ImageUrl <> imageUrl Then
                    product.ImageUrl = imageUrl
                    product.Variants.First().ImageUrl = imageUrl
                    modified = True
                End If
                If basketItem.PricesIncTax = True Then
                    If product.Variants.First().Price <> basketItem.IR_PricePerItem Then
                        product.Variants.First().Price = basketItem.IR_PricePerItem
                        modified = True
                    End If
                Else
                    itemprice = Math.Round((basketItem.IR_PricePerItem * (1 + basketItem.IR_TaxPerItem)), 2)
                    If product.Variants.First().Price <> itemprice Then
                        product.Variants.First().Price = itemprice
                        modified = True
                    End If
                End If

                If modified Then
                    Dim taskResult As Product = Await manager.ECommerceStores.Products(mcStoreId).UpdateAsync(basketItem.ProductID, product).ConfigureAwait(False)
                    Return taskResult
                End If
            End If
            Return Nothing
        Catch ex As Exception
            'Debug.Print(ex.Message)
            'Log the error
            CkartrisFormatErrors.LogError("MailchimpBLL AddProduct: " & ex.Message)
        End Try
    End Function

    ''' <summary>
    ''' Add cart to mailchimp
    ''' </summary>
    Public Async Function AddCart(ByVal customer As Customer, ByVal orderId As Integer) As Task(Of Cart)
        Try
            Dim idSufix As String = orderId
            If orderId = 0 Then
                Dim timestamp = CLng(DateTime.UtcNow.Subtract(New DateTime(1970, 1, 1)).TotalMilliseconds)
                idSufix = customer.Id & "_" & timestamp
            End If

            Dim currencyCodeEnum As CurrencyCode = DirectCast(System.[Enum].Parse(GetType(CurrencyCode), Me.kartrisCurrencyCode), CurrencyCode)
            Dim cart As Cart = New Cart With {.Id = "cart_" & idSufix,
                                            .Customer = New Customer With {.Id = customer.Id, .OptInStatus = True},
                                            .CurrencyCode = currencyCodeEnum,
                                          .OrderTotal = kartrisBasket.FinalPriceIncTax,
                                          .CheckoutUrl = CkartrisBLL.WebShopURL.ToLower & "Checkout.aspx",
                                          .Lines = New Collection(Of Line)
                                        }
            Dim product As Product
            Dim itemprice As Double
            For counter As Integer = 0 To kartrisBasket.BasketItems.Count - 1
                product = Await AddProduct(kartrisBasket.BasketItems(counter))

                If kartrisBasket.BasketItems(counter).PricesIncTax = True Then
                    itemprice = (kartrisBasket.BasketItems(counter).IR_PricePerItem)
                Else
                    itemprice = Math.Round((kartrisBasket.BasketItems(counter).IR_PricePerItem * (1 + kartrisBasket.BasketItems(counter).IR_TaxPerItem)), 2)
                End If

                cart.Lines.Add(New Line With {.Id = "cart_" & idSufix & "_l" & counter,
                                            .ProductId = kartrisBasket.BasketItems(counter).ProductID,
                                            .ProductTitle = kartrisBasket.BasketItems(counter).Name,
                                            .ProductVariantId = kartrisBasket.BasketItems(counter).ProductID,
                                            .ProductVariantTitle = kartrisBasket.BasketItems(counter).Name,
                                            .Quantity = kartrisBasket.BasketItems(counter).Quantity,
                                            .Price = itemprice
                               })
            Next

            Dim taskResult As Cart = Await manager.ECommerceStores.Carts(mcStoreId).AddAsync(cart).ConfigureAwait(False)


            Return taskResult
        Catch ex As Exception
            'Debug.Print(ex.Message)
            'Log the error
            CkartrisFormatErrors.LogError("MailchimpBLL AddCart: " & ex.Message)
        End Try
    End Function

    ''' <summary>
    ''' Delete cart
    ''' </summary>
    Public Async Function DeleteCart(ByVal cartId As String) As Task(Of Boolean)
        Dim result As Boolean = False
        Try
            Await manager.ECommerceStores.Carts(mcStoreId).DeleteAsync(cartId).ConfigureAwait(False)
            result = True
        Catch ex As Exception
            If ex.Message.Contains("Unable to find") Then
                result = True
            Else
                result = False
            End If
            'Debug.Print(ex.Message)
            'Log the error
            CkartrisFormatErrors.LogError("MailchimpBLL DeleteCart: " & ex.Message)
        End Try
        Return result
    End Function

    ''' <summary>
    ''' Delete order
    ''' </summary>
    Public Async Function DeleteOrder(ByVal orderId As String) As Task(Of Boolean)
        Dim result As Boolean = False
        Try
            Await manager.ECommerceStores.Orders(mcStoreId).DeleteAsync(orderId).ConfigureAwait(False)
            result = True
        Catch ex As Exception
            If ex.Message.Contains("Unable to find") Then
                result = True
            Else
                result = False
            End If
            'Debug.Print(ex.Message)
            'Log the error
            CkartrisFormatErrors.LogError("MailchimpBLL DeleteOrder: " & ex.Message)
        End Try
        Return result
    End Function

    ''' <summary>
    ''' Add order
    ''' </summary>
    Public Async Function AddOrder(ByVal customer As Customer, ByVal cartId As String) As Task(Of Order)
        Try
            Dim timestamp As String = CkartrisDisplayFunctions.NowOffset().ToString("yyyy-MM-dd HH:mm")

            Dim currencyCodeEnum As CurrencyCode = DirectCast(System.[Enum].Parse(GetType(CurrencyCode), Me.kartrisCurrencyCode), CurrencyCode)
            Dim order As Order = New Order With {.Id = "order_" & cartId,
                                            .Customer = New Customer With {.Id = customer.Id},
                                          .CurrencyCode = currencyCodeEnum,
                                          .OrderTotal = kartrisBasket.FinalPriceIncTax,
                                          .ProcessedAtForeign = timestamp,
                                          .UpdatedAtForeign = timestamp,
                                          .Lines = New Collection(Of Line)
                                        }
            Dim product As Product
            Dim itemprice As Double
            For counter As Integer = 0 To kartrisBasket.BasketItems.Count - 1
                product = Await AddProduct(kartrisBasket.BasketItems(counter))

                If kartrisBasket.BasketItems(counter).PricesIncTax = True Then
                    itemprice = (kartrisBasket.BasketItems(counter).IR_PricePerItem)
                Else
                    itemprice = Math.Round((kartrisBasket.BasketItems(counter).IR_PricePerItem * (1 + kartrisBasket.BasketItems(counter).IR_TaxPerItem)), 2)
                End If

                order.Lines.Add(New Line With {.Id = "order_" & cartId & "_l" & counter,
                                            .ProductId = kartrisBasket.BasketItems(counter).ProductID,
                                            .ProductTitle = kartrisBasket.BasketItems(counter).Name,
                                            .ProductVariantId = kartrisBasket.BasketItems(counter).ProductID,
                                            .ProductVariantTitle = kartrisBasket.BasketItems(counter).Name,
                                            .Quantity = kartrisBasket.BasketItems(counter).Quantity,
                                            .Price = itemprice
                })
            Next
            Dim taskResult As Order = Await manager.ECommerceStores.Orders(mcStoreId).AddAsync(order).ConfigureAwait(False)

            If taskResult IsNot Nothing Then
                customer.OrdersCount = customer.OrdersCount + 1
                customer.OptInStatus = True
                Dim updateCustomer As Customer = Await manager.ECommerceStores.Customers(mcStoreId).UpdateAsync(customer.Id, customer).ConfigureAwait(False)
            End If

            Return taskResult
        Catch ex As Exception
            'Debug.Print(ex.Message)
            'Log the error
            CkartrisFormatErrors.LogError("MailchimpBLL AddOrder: " & ex.Message)
        End Try
    End Function

    ''' <summary>
    ''' Add store
    ''' </summary>
    Public Async Function AddStore(ByVal storeId As String, Optional ByVal storeName As String = "Kartris Store", Optional ByVal storeDomain As String = "www.kartris.com", Optional ByVal EmailAddress As String = "someemail@cactusoft.com") As Task(Of Store)
        Try
            Dim currencyCodeEnum As CurrencyCode = DirectCast(System.[Enum].Parse(GetType(CurrencyCode), Me.kartrisCurrencyCode), CurrencyCode)
            Dim storeObj = New Store With {.Id = storeId,
                                        .ListId = listId,
                                        .Name = storeName,
                                        .Domain = storeDomain,
                                        .EmailAddress = EmailAddress,
                                        .CurrencyCode = currencyCodeEnum}
            Dim taskResult As Store = Await manager.ECommerceStores.AddAsync(storeObj).ConfigureAwait(False)

            Return taskResult
        Catch ex As Exception
            'Debug.Print(ex.Message)
            'Log the error
            CkartrisFormatErrors.LogError("MailchimpBLL AddStore: " & ex.Message)
            Throw ex
        End Try
    End Function

    ''' <summary>
    ''' Add mailinglist signup to mailchimp
    ''' </summary>
    Public Async Function AddListSubscriber(ByVal strEmail As String) As Task(Of Member)
        Try
            Dim member As Member = New Member With {.EmailAddress = strEmail,
                .Status = Status.Subscribed
                }
            Dim strListID As String = KartSettingsManager.GetKartConfig("general.mailchimp.mailinglistid")
            Dim taskResult As Member = Await manager.Members.AddOrUpdateAsync(strListID, member).ConfigureAwait(False)
            Return taskResult
        Catch ex As Exception
            'Debug.Print(ex.Message)
            'Log the error
            CkartrisFormatErrors.LogError("MailchimpBLL AddListSubscriber: " & ex.Message)
            Throw ex
        End Try
    End Function

End Class
