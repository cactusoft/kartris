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


'========================================================================
'See https://github.com/brandonseydel/MailChimp.Net
'
'Rather than reinvent the wheel, we're using Brandon Seydel's excellent
'MailChimp v3 API NuGet package.
'
'========================================================================
Public Class MailChimpBLL
    'Dim listId As String = "07891e3377"
    Dim listId As String = "5d5ad03475"     ' Kartris Store List
    Dim apiKey As String
    Dim apiUrl As String
    Dim manager As IMailChimpManager
    Dim currentLoggedUser As KartrisMemberShipUser
    Dim mcStore As Store
    Dim kartrisBasket As Basket
    Dim kartrisCurrencyCode As String

    Sub New()
        apiKey = KartSettingsManager.GetKartConfig("general.mailchimp.apikey")
        apiUrl = KartSettingsManager.GetKartConfig("general.mailchimp.apiurl")
        manager = New MailChimpManager(apiKey)
        CurrentLoggedUser = Nothing
        mcStore = New Store()
        kartrisBasket = New Basket()
    End Sub

    Sub New(ByVal user As KartrisMemberShipUser, ByVal basket As Basket, ByVal currencyCode As String)
        apiKey = KartSettingsManager.GetKartConfig("general.mailchimp.apikey")
        apiUrl = KartSettingsManager.GetKartConfig("general.mailchimp.apiurl")
        manager = New MailChimpManager(apiKey)
        CurrentLoggedUser = user
        mcStore = New Store()
        kartrisBasket = basket
        Me.kartrisCurrencyCode = currencyCode
    End Sub

    'Dim FILE_NAME As String = "C:\test2.txt"
    'Dim objWriter As New System.IO.StreamWriter(FILE_NAME)
    'objWriter.WriteLine("begin")
    'objWriter.Close()

    Public Async Function MailChimpStuff() As Task(Of Boolean)

        'Dim storeName As String = "kartrisstore"
        Dim storeName As String = "kartrisstoreNew"
        Try
            mcStore = Await manager.ECommerceStores.GetAsync(storeName).ConfigureAwait(False)
        Catch ex As Exception
            If ex.Message.Contains("Unable to find the resource at") Then
                mcStore = Nothing
            End If
            Debug.Print(ex.Message)
        End Try

        Try
            If (mcStore Is Nothing) Then
                mcStore = Await Me.AddStore(storeName).ConfigureAwait(False)
            End If

            Dim customer As Customer
            Try
                customer = Await manager.ECommerceStores.Customers(mcStore.Id).GetAsync(CurrentLoggedUser.ID)
            Catch ex As Exception
                customer = Nothing
            End Try
            If customer Is Nothing Then
                customer = Await Me.AddCustomer().ConfigureAwait(False)
            End If

            If customer IsNot Nothing Then
                Dim cart As Cart = Await AddCart(customer).ConfigureAwait(False)
                'Dim order As Order = Await AddOrder(customer).ConfigureAwait(False)
            End If
        Catch ex As Exception
            Debug.Print(ex.Message)
        End Try
        Return True
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

    Public Async Function AddCustomer() As Task(Of Customer)
        Try
            Dim userFullName As String = ""
            userFullName = UsersBLL.GetNameandEUVAT(CurrentLoggedUser.ID).Split("|||")(0)
            Dim userNamesArray() As String = userFullName.Split(" ")
            'Use the Status property if updating an existing member
            Dim customer As Customer = New Customer With {.Id = CurrentLoggedUser.ID,
                                                            .EmailAddress = CurrentLoggedUser.Email,
                                                            .OptInStatus = True
                                                        }
            customer.FirstName = userNamesArray(0)
            If (userNamesArray.Length > 1) Then
                customer.LastName = userNamesArray(1)
            End If

            Dim taskResult As Customer = Await manager.ECommerceStores.Customers(mcStore.Id).AddAsync(customer).ConfigureAwait(False)
            Return taskResult
        Catch ex As Exception
            Debug.Print(ex.Message)
        End Try
    End Function

    Public Async Function AddProduct(ByVal basketItem As BasketItem) As Task(Of Product)
        Try
            Dim product As Product
            Dim productVariant As [Variant]
            Dim listVariants As List(Of [Variant]) = New List(Of [Variant])
            Try
                product = Await manager.ECommerceStores.Products(mcStore.Id).GetAsync(basketItem.ID).ConfigureAwait(False)
            Catch ex As Exception
                If ex.Message.Contains("A product with the provided ID already") Then
                    product = Nothing
                End If
            End Try

            If product Is Nothing Then
                productVariant = New [Variant] With {.Id = basketItem.ID,
                                                 .Title = basketItem.Name
            }
                listVariants.Add(productVariant)
                product = New Product With {.Id = basketItem.ID,
                                            .Title = basketItem.Name,
                                            .Variants = listVariants
                                            }

                Dim taskResult As Product = Await manager.ECommerceStores.Products(mcStore.Id).AddAsync(product).ConfigureAwait(False)
                Return taskResult
            End If
            Return Nothing
        Catch ex As Exception
                Debug.Print(ex.Message)
        End Try
    End Function

    Public Async Function AddCart(ByVal customer As Customer) As Task(Of Cart)
        Try
            Dim timestamp = CLng(DateTime.UtcNow.Subtract(New DateTime(1970, 1, 1)).TotalMilliseconds)

            Dim cart As Cart = New Cart With {.Id = customer.Id & "_" & timestamp,
                                            .Customer = New Customer With {.Id = customer.Id, .OptInStatus = True},
                                            .CurrencyCode = CurrencyCode.GBP,
                                          .OrderTotal = kartrisBasket.TotalIncTax,
                                          .CheckoutUrl = "http://localhost:54147/Checkout.aspx",
                                          .Lines = New Collection(Of Line)
                                        }
            Dim product As Product
            For counter As Integer = 0 To kartrisBasket.BasketItems.Count - 1
                product = Await AddProduct(kartrisBasket.BasketItems(counter))

                cart.Lines.Add(New Line With {.Id = customer.Id & "_" & timestamp & "_" & counter,
                                            .ProductId = kartrisBasket.BasketItems(counter).ID,
                                            .ProductTitle = kartrisBasket.BasketItems(counter).Name,
                                            .ProductVariantId = kartrisBasket.BasketItems(counter).ID,
                                            .ProductVariantTitle = kartrisBasket.BasketItems(counter).Name,
                                            .Quantity = kartrisBasket.BasketItems(counter).Quantity,
                                            .Price = kartrisBasket.BasketItems(counter).Price
                })
            Next
            Dim taskResult As Cart = Await manager.ECommerceStores.Carts(mcStore.Id).AddAsync(cart).ConfigureAwait(False)


            Return taskResult
        Catch ex As Exception
            Debug.Print(ex.Message)
        End Try
    End Function

    Public Async Function AddOrder(ByVal customer As Customer) As Task(Of Order)
        Try
            Dim timestamp = CLng(DateTime.UtcNow.Subtract(New DateTime(1970, 1, 1)).TotalMilliseconds)

            Dim order As Order = New Order With {.Id = customer.Id & "_" & timestamp,
                                            .Customer = New Customer With {.Id = customer.Id},
                                          .CurrencyCode = CurrencyCode.GBP,
                                          .OrderTotal = kartrisBasket.TotalIncTax,
                                          .Lines = New Collection(Of Line)
                                        }
            Dim product As Product
            For counter As Integer = 0 To kartrisBasket.BasketItems.Count - 1
                product = Await AddProduct(kartrisBasket.BasketItems(counter))

                order.Lines.Add(New Line With {.Id = customer.Id & "_" & timestamp & "_" & counter,
                                            .ProductId = kartrisBasket.BasketItems(counter).ID,
                                            .ProductTitle = kartrisBasket.BasketItems(counter).Name,
                                            .ProductVariantId = kartrisBasket.BasketItems(counter).ID,
                                            .ProductVariantTitle = kartrisBasket.BasketItems(counter).Name,
                                            .Quantity = kartrisBasket.BasketItems(counter).Quantity,
                                            .Price = kartrisBasket.BasketItems(counter).Price
                })
            Next
            Dim taskResult As Order = Await manager.ECommerceStores.Orders(mcStore.Id).AddAsync(order).ConfigureAwait(False)

            If taskResult IsNot Nothing Then
                customer.OrdersCount = customer.OrdersCount + 1
                customer.OptInStatus = True
                Dim updateCustomer As Customer = Await manager.ECommerceStores.Customers(mcStore.Id).UpdateAsync(customer.Id, customer).ConfigureAwait(False)
            End If

            Return taskResult
        Catch ex As Exception
            Debug.Print(ex.Message)
        End Try
    End Function

    Public Async Function AddStore(ByVal storeName As String) As Task(Of Store)
        Try
            Dim currencyCodeEnum As CurrencyCode = DirectCast(System.[Enum].Parse(GetType(CurrencyCode), Me.kartrisCurrencyCode), CurrencyCode)

            Dim storeObj = New Store With {.Id = storeName,
                                        .ListId = listId,
                                        .Name = "Kartris Store",
                                        .Domain = "www.kartris.com",
                                        .EmailAddress = "joni@cactusoft.com",
                                        .CurrencyCode = currencyCodeEnum}
            Dim taskResult As Store = Await manager.ECommerceStores.AddAsync(storeObj).ConfigureAwait(False)

            Return taskResult
        Catch ex As Exception
            Debug.Print(ex.Message)
        End Try
    End Function

End Class
