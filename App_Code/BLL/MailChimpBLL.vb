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
Imports System.Xml.Serialization


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
            customer = manager.ECommerceStores.Customers(mcStoreId).GetAsync(kartrisUserId).Result
        Catch ex As Exception
            CkartrisFormatErrors.LogError("MailchimpBLL GetCustomer ")
            CkartrisFormatErrors.LogError("MailchimpBLL GetCustomer ex:" & ex.Message)
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
        Try
            mcStore = manager.ECommerceStores.GetAsync(mcStoreId).Result
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
                mcStore = Await Me.AddStore(mcStoreId).ConfigureAwait(False)
            End If

            Dim customer As Customer
            Try
                customer = manager.ECommerceStores.Customers(mcStore.Id).GetAsync(currentLoggedUser.ID).Result
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
            CkartrisFormatErrors.LogError("MailchimpBLL AddCartToCustomerToStore(1): ")
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
                CkartrisFormatErrors.LogError("MailchimpBLL Product trycatch 1 ")

                product = manager.ECommerceStores.Products(mcStoreId).GetAsync(basketItem.ProductID).Result
            Catch ex As Exception
                CkartrisFormatErrors.LogError("MailchimpBLL Product trycatch ")
                CkartrisFormatErrors.LogError("MailchimpBLL Product trycatch :" & ex.Message)
                If ex.Message.Contains("A product with the provided ID already") Then
                    product = Nothing
                End If
            End Try

            CkartrisFormatErrors.LogError("MailchimpBLL Product after get")
            Dim itemprice As Double
            If basketItem.PricesIncTax = True Then
                itemprice = basketItem.IR_PricePerItem
            Else
                itemprice = Math.Round((basketItem.IR_PricePerItem * (1 + basketItem.IR_TaxPerItem)), 2)
            End If

            CkartrisFormatErrors.LogError("MailchimpBLL Product after itemprice")

            Dim imageUrl As String = CkartrisBLL.WebShopURL & "Image.aspx?strItemType=p&numMaxHeight=100&numMaxWidth=100&numItem=" & basketItem.ProductID
            CkartrisFormatErrors.LogError("MailchimpBLL Product after imageurl")
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
                CkartrisFormatErrors.LogError("MailchimpBLL Product before add")
                Dim taskResult As Product = manager.ECommerceStores.Products(mcStoreId).AddAsync(product).Result
                CkartrisFormatErrors.LogError("MailchimpBLL Product after add")
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

                CkartrisFormatErrors.LogError("MailchimpBLL Product before modified if")
                If modified Then
                    Dim taskResult As Product = Nothing
                    CkartrisFormatErrors.LogError("MailchimpBLL Product before modified")
                    Try
                        taskResult = manager.ECommerceStores.Products(mcStoreId).UpdateAsync(basketItem.ProductID, product).Result
                    Catch ex As Exception
                        CkartrisFormatErrors.LogError("MailchimpBLL Product try catch modified")
                    End Try
                    CkartrisFormatErrors.LogError("MailchimpBLL Product after modified")
                    Return taskResult
                Else
                    Return product
                End If
                CkartrisFormatErrors.LogError("MailchimpBLL Product after modified if")
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

            Dim taskResult As Cart = manager.ECommerceStores.Carts(mcStoreId).AddAsync(cart).Result


            Return taskResult
        Catch ex As Exception
            'Debug.Print(ex.Message)
            'Log the error
            Dim trace = New System.Diagnostics.StackTrace(ex, True)
            CkartrisFormatErrors.LogError("MailchimpBLL AddCart stacktrace: " & ex.StackTrace & vbCrLf & "Error in AddCart - Line number:" & trace.GetFrame(0).GetFileLineNumber().ToString)
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

            ' Deleting XML Files
            Dim xmlPath As String = Path.Combine(HttpRuntime.AppDomainAppPath, "XmlStoring")
            Dim orderId As Integer = 0
            If cartId.Contains("cart") Then
                Dim cartIdSplit As String() = cartId.Split(New String() {"cart_"}, StringSplitOptions.None)
                orderId = Integer.Parse(cartIdSplit(1))
            Else
                orderId = Integer.Parse(cartId)
            End If
            Dim xmlFilePath As String = xmlPath & "\" & orderId.ToString() & "_basket.xml"
            Dim orderXmlFilePath As String = xmlPath & "\" & orderId.ToString() & "_order.xml"

            If File.Exists(xmlFilePath) Then
                File.Delete(xmlFilePath)
            End If
            If File.Exists(orderXmlFilePath) Then
                File.Delete(orderXmlFilePath)
            End If

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
            Dim timestamp As String = ""
            If (IsDBNull(CkartrisDisplayFunctions.NowOffset())) Then
                CkartrisFormatErrors.LogError("MailchimpBLL AddOrder offset: " + CkartrisDisplayFunctions.NowOffset().ToString())
                timestamp = CkartrisDisplayFunctions.NowOffset().ToString("yyyy-MM-dd HH:mm")
            Else
                CkartrisFormatErrors.LogError("MailchimpBLL AddOrder offset: was null ")
                timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm")
            End If

            If kartrisBasket Is Nothing Then
                CkartrisFormatErrors.LogError("MailchimpBLL Basket is null")
                Dim orderId As Integer = 0
                If cartId.Contains("cart") Then
                    Dim cartIdSplit As String() = cartId.Split(New String() {"cart_"},
                                        StringSplitOptions.None)
                    orderId = Integer.Parse(cartIdSplit(1))
                Else
                    orderId = Integer.Parse(cartId)
                End If

                Dim xmlPath As String = Path.Combine(System.Web.HttpContext.Current.Request.PhysicalApplicationPath, "XmlStoring")
                Dim xmlFilePath As String = xmlPath & "\" & orderId.ToString() & "_basket.xml"

                ' Open the file to read from.
                Dim readText As String = File.ReadAllText(xmlFilePath)

                Dim objBasket As Kartris.Basket = Payment.Deserialize(readText, GetType(Kartris.Basket))
                kartrisBasket = objBasket
                CkartrisFormatErrors.LogError("MailchimpBLL Basket after file being processed")
                CkartrisFormatErrors.LogError("MailchimpBLL Basket kartrisBasket.FinalPriceIncTax: " & kartrisBasket.FinalPriceIncTax.ToString())
            End If


            CkartrisFormatErrors.LogError("MailchimpBLL kartrisCurrencyCode")
            CkartrisFormatErrors.LogError("MailchimpBLL kartrisCurrencyCode: " & Me.kartrisCurrencyCode)
            Dim currencyCodeEnum As CurrencyCode = DirectCast(System.[Enum].Parse(GetType(CurrencyCode), Me.kartrisCurrencyCode), CurrencyCode)
            CkartrisFormatErrors.LogError("MailchimpBLL cartId: " & cartId)
            CkartrisFormatErrors.LogError("MailchimpBLL customer")
            Dim customerJson As String = New JavaScriptSerializer().Serialize(customer)
            CkartrisFormatErrors.LogError("MailchimpBLL Product before basketItem JSON: " & customerJson)
            CkartrisFormatErrors.LogError("MailchimpBLL currencyCodeEnum: " & currencyCodeEnum)
            CkartrisFormatErrors.LogError("MailchimpBLL timestamp: " & timestamp)
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

            CkartrisFormatErrors.LogError("MailchimpBLL AddOrder basketItems 1 : " & kartrisBasket.ToString())
            CkartrisFormatErrors.LogError("MailchimpBLL AddOrder basketItems 2 : " & kartrisBasket.BasketItems.Count.ToString())

            For counter As Integer = 0 To kartrisBasket.BasketItems.Count - 1
                CkartrisFormatErrors.LogError("MailchimpBLL AddOrder inside For")
                CkartrisFormatErrors.LogError("MailchimpBLL AddOrder inside For: " & kartrisBasket.BasketItems(counter).ToString())
                product = Await AddProduct(kartrisBasket.BasketItems(counter))
                CkartrisFormatErrors.LogError("MailchimpBLL AddOrder after add product ")
                If kartrisBasket.BasketItems(counter).PricesIncTax = True Then
                    itemprice = (kartrisBasket.BasketItems(counter).IR_PricePerItem)
                Else
                    itemprice = Math.Round((kartrisBasket.BasketItems(counter).IR_PricePerItem * (1 + kartrisBasket.BasketItems(counter).IR_TaxPerItem)), 2)
                End If
                CkartrisFormatErrors.LogError("MailchimpBLL AddOrder after item price ")
                order.Lines.Add(New Line With {.Id = "order_" & cartId & "_l" & counter,
                                            .ProductId = kartrisBasket.BasketItems(counter).ProductID,
                                            .ProductTitle = kartrisBasket.BasketItems(counter).Name,
                                            .ProductVariantId = kartrisBasket.BasketItems(counter).ProductID,
                                            .ProductVariantTitle = kartrisBasket.BasketItems(counter).Name,
                                            .Quantity = kartrisBasket.BasketItems(counter).Quantity,
                                            .Price = itemprice
                })
                CkartrisFormatErrors.LogError("MailchimpBLL AddOrder added line to order")
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
            Dim trace = New System.Diagnostics.StackTrace(ex, True)
            CkartrisFormatErrors.LogError("MailchimpBLL AddOrder stacktrace: " & ex.StackTrace & vbCrLf & "Error in AddOrder - Line number:" & trace.GetFrame(0).GetFileLineNumber().ToString)
        End Try
    End Function


    ''' <summary>
    ''' Add order
    ''' </summary>
    Public Async Function AddOrderByCustomerId(ByVal customerId As Integer, ByVal cartId As String) As Task(Of Order)
        Try
            Dim O_TotalPriceGateway As Double = 0
            Dim orderId As Integer = 0
            Dim timestamp As String = ""
            If (IsDBNull(CkartrisDisplayFunctions.NowOffset())) Then
                CkartrisFormatErrors.LogError("MailchimpBLL AddOrder offset: " + CkartrisDisplayFunctions.NowOffset().ToString())
                timestamp = CkartrisDisplayFunctions.NowOffset().ToString("yyyy-MM-dd HH:mm")
            Else
                CkartrisFormatErrors.LogError("MailchimpBLL AddOrder offset: was null ")
                timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm")
            End If

            If kartrisBasket Is Nothing Then
                CkartrisFormatErrors.LogError("MailchimpBLL Basket is null")

                If cartId.Contains("cart") Then
                    Dim cartIdSplit As String() = cartId.Split(New String() {"cart_"},
                                        StringSplitOptions.None)
                    orderId = Integer.Parse(cartIdSplit(1))
                Else
                    orderId = Integer.Parse(cartId)
                End If

                Dim xmlPath As String = Path.Combine(System.Web.HttpContext.Current.Request.PhysicalApplicationPath, "XmlStoring")
                Dim xmlFilePath As String = xmlPath & "\" & orderId.ToString() & "_basket.xml"

                Dim orderXmlFilePath As String = xmlPath & "\" & orderId.ToString() & "_order.xml"

                ' Open the file to read from.
                Dim readText As String = File.ReadAllText(xmlFilePath)
                Dim orderReadText As String = File.ReadAllText(orderXmlFilePath)
                Try
                    Dim objBasket As Kartris.Basket = Payment.Deserialize(readText, GetType(Kartris.Basket))
                    kartrisBasket = objBasket

                    Dim xmlElem = XElement.Parse(orderReadText)

                    xmlElem = xmlElem.Element("Amount")
                    O_TotalPriceGateway = Double.Parse(xmlElem.Value)

                Catch ex As Exception
                    CkartrisFormatErrors.LogError("MailchimpBLL XML catch")
                    CkartrisFormatErrors.LogError("MailchimpBLL XML catch: " & ex.Message)
                End Try


            End If


            Dim currencyCodeEnum As CurrencyCode = DirectCast(System.[Enum].Parse(GetType(CurrencyCode), Me.kartrisCurrencyCode), CurrencyCode)
            CkartrisFormatErrors.LogError("MailchimpBLL cartId: " & cartId)
            CkartrisFormatErrors.LogError("MailchimpBLL customer")

            Dim order As Order = New Order With {.Id = "order_" & cartId,
                                            .Customer = New Customer With {.Id = customerId},
                                          .CurrencyCode = currencyCodeEnum,
                                          .OrderTotal = O_TotalPriceGateway,
                                          .ProcessedAtForeign = timestamp,
                                          .UpdatedAtForeign = timestamp,
                                          .Lines = New Collection(Of Line)
                                        }
            Dim product As Product
            Dim itemprice As Double

            CkartrisFormatErrors.LogError("MailchimpBLL AddOrder basketItems 1 : " & kartrisBasket.ToString())
            CkartrisFormatErrors.LogError("MailchimpBLL AddOrder basketItems 2 : " & kartrisBasket.BasketItems.Count.ToString())

            For counter As Integer = 0 To kartrisBasket.BasketItems.Count - 1
                CkartrisFormatErrors.LogError("MailchimpBLL AddOrderByCustomerId inside For")
                Try
                    CkartrisFormatErrors.LogError("MailchimpBLL AddOrderByCustomerId inside For: " & kartrisBasket.BasketItems(counter).ToString())
                    Dim itemJson As String = New JavaScriptSerializer().Serialize(kartrisBasket)
                    CkartrisFormatErrors.LogError("MailchimpBLL AddOrderByCustomerId basketItem JSON: " & itemJson)
                    CkartrisFormatErrors.LogError("MailchimpBLL AddOrderByCustomerId before addproduct")
                    product = Await AddProduct(kartrisBasket.BasketItems(counter))
                    CkartrisFormatErrors.LogError("MailchimpBLL AddOrderByCustomerId after addproduct")
                Catch ex As Exception
                    CkartrisFormatErrors.LogError("MailchimpBLL AddOrderByCustomerId addproduct")
                End Try

                Try
                    CkartrisFormatErrors.LogError("MailchimpBLL AddOrderByCustomerId after add product ")
                    If kartrisBasket.BasketItems(counter).PricesIncTax = True Then
                        itemprice = (kartrisBasket.BasketItems(counter).IR_PricePerItem)
                    Else
                        itemprice = Math.Round((kartrisBasket.BasketItems(counter).IR_PricePerItem * (1 + kartrisBasket.BasketItems(counter).IR_TaxPerItem)), 2)
                    End If

                    If itemprice > 0 Then
                        CkartrisFormatErrors.LogError("MailchimpBLL AddOrderByCustomerId after item price ")
                        order.Lines.Add(New Line With {.Id = "order_" & cartId & "_l" & counter,
                                            .ProductId = kartrisBasket.BasketItems(counter).ProductID,
                                            .ProductTitle = kartrisBasket.BasketItems(counter).Name,
                                            .ProductVariantId = kartrisBasket.BasketItems(counter).ProductID,
                                            .ProductVariantTitle = kartrisBasket.BasketItems(counter).Name,
                                            .Quantity = kartrisBasket.BasketItems(counter).Quantity,
                                            .Price = itemprice
                    })
                    End If
                    CkartrisFormatErrors.LogError("MailchimpBLL AddOrderByCustomerId added line to order")
                Catch ex As Exception
                    CkartrisFormatErrors.LogError("MailchimpBLL AddOrderByCustomerId orderline add : " & ex.Message)
                    Dim trace = New System.Diagnostics.StackTrace(ex, True)
                    CkartrisFormatErrors.LogError("MailchimpBLL AddOrderByCustomerId  orderline addstacktrace: " & ex.StackTrace & vbCrLf & "Error in AddOrder - Line number:" & trace.GetFrame(0).GetFileLineNumber().ToString)
                End Try
            Next
            Dim taskResult As Order = manager.ECommerceStores.Orders(mcStoreId).AddAsync(order).Result

            Dim mcCustomer As Customer = manager.ECommerceStores.Customers(mcStoreId).GetAsync(customerId).Result


            If taskResult IsNot Nothing Then
                mcCustomer.OrdersCount = mcCustomer.OrdersCount + 1
                mcCustomer.OptInStatus = True
                Dim updateCustomer As Customer = Await manager.ECommerceStores.Customers(mcStoreId).UpdateAsync(customerId, mcCustomer).ConfigureAwait(False)
            End If

            Return taskResult
        Catch ex As Exception
            'Debug.Print(ex.Message)
            'Log the error
            CkartrisFormatErrors.LogError("MailchimpBLL AddOrderByCustomerId: " & ex.Message)
            Dim trace = New System.Diagnostics.StackTrace(ex, True)
            CkartrisFormatErrors.LogError("MailchimpBLL AddOrderByCustomerId stacktrace: " & ex.StackTrace & vbCrLf & "Error in AddOrder - Line number:" & trace.GetFrame(0).GetFileLineNumber().ToString)
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
