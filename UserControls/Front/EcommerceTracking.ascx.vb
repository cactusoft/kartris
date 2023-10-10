'========================================================================
'Kartris - www.kartris.com
'Copyright 2019 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports KartSettingsManager
Imports CkartrisBLL
Imports CkartrisDataManipulation
Imports Org.BouncyCastle.Utilities

''' <summary>
''' Ecommerce Tracking control
''' This is designed primarily for Google Analytics, but the javascript
''' on the .ascx is accessible and can be modified by any user if
''' required to support alternative tracking systems
''' </summary>
''' <remarks>By Paul</remarks>
Partial Class UserControls_Front_EcommerceTracking
    Inherits System.Web.UI.UserControl

    Private objBasket As New Kartris.Basket

    ''' <summary>
    ''' Page Load
    ''' </summary>
    ''' <remarks>By Paul</remarks>
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Dim _OrderID As Integer = CInt(Session("OrderID"))

        Dim _UserID As Integer = 0

        'Only need ecommerce tracking if there is a 
        'webproperty ID (site identifier) set in 
        'the config settings of Kartris
        If KartSettingsManager.GetKartConfig("general.google.ga4.measurementid") <> "" Then
            'Declare variables
            Dim tblOrder As System.Data.DataTable

            Dim objBasketBLL As New BasketBLL

            'Fill datatable width basket items
            tblOrder = objBasketBLL.GetCustomerOrderDetails(_OrderID)


            'Examine data of order, if exists
            If tblOrder.Rows.Count > 0 Then

                _UserID = tblOrder.Rows(0).Item("O_CustomerID")


                '================================
                'ORDER FOUND AND OK
                'Order exists, and belongs to the
                'logged in user, and tracking is
                'enabled.
                '================================
                phdGoogleGA4.Visible = True

                Dim numShippingTotal As Single = tblOrder.Rows(0).Item("O_ShippingPrice") + tblOrder.Rows(0).Item("O_OrderHandlingCharge")
                Dim numTotalItems As Single = tblOrder.Rows(0).Item("O_AffiliateTotalPrice")
                Dim numTax As Single = tblOrder.Rows(0).Item("O_TotalPrice") - numTotalItems - numShippingTotal


                Dim transactionId As String = _OrderID
                Dim transactionValue As String = CkartrisDataManipulation.HandleDecimalValuesString(CurrenciesBLL.FormatCurrencyPrice(hidCurrencyID.Value, numTotalItems, False))
                Dim transactionTax As String = CkartrisDataManipulation.HandleDecimalValuesString(CurrenciesBLL.FormatCurrencyPrice(hidCurrencyID.Value, numTax, False))
                Dim transactionShipping As String = CkartrisDataManipulation.HandleDecimalValuesString(CurrenciesBLL.FormatCurrencyPrice(hidCurrencyID.Value, numShippingTotal, False))
                Dim transactionCurrency As String = CurrenciesBLL.CurrencyCode(hidCurrencyID.Value)

                tblOrder.Dispose()

                'Fill order with details of customer invoice,
                'so we can loop through individual item
                'records
                tblOrder = objBasketBLL.GetCustomerInvoice(_OrderID, _UserID, 1)

                Dim items As New List(Of String)()

                For Each row As DataRow In tblOrder.Rows
                    'Declare variables
                    Dim strVersionCode, strItemName, strItemOptions As String
                    Dim numItemPrice, numItemQuantity As Single

                    strVersionCode = row("IR_VersionCode")
                    strItemName = row("IR_VersionName")
                    strItemOptions = row("IR_OptionsText")
                    numItemPrice = CurrenciesBLL.FormatCurrencyPrice(hidCurrencyID.Value, row("IR_PricePerItem"), False)
                    numItemQuantity = row("IR_Quantity")

                    Dim itemString As String = $"{{ item_id: ""{strVersionCode}"", 
                                    item_name: ""{strItemName}"", 
                                    item_variant: ""{strItemOptions}"", 
                                    price: {numItemPrice}, 
                                    quantity: {numItemQuantity} }}"
                    items.Add(itemString)
                Next

                'affiliation: ""{affiliation}"", 
                'coupon: ""{coupon}"", 
                'discount: {discount}, 
                'index: {Index}, 
                'item_brand: ""{itemBrand}"", 
                'item_category: ""{itemCategory}"", 
                'item_category2: ""{itemCategory2}"", 
                'item_category3: ""{itemCategory3}"", 
                'item_category4: ""{itemCategory4}"", 
                'item_category5: ""{itemCategory5}"", 
                'item_list_id: ""{itemListId}"", 
                'item_list_name: ""{itemListName}"", 
                'item_variant: ""{itemVariant}"", 
                'location_id: ""{locationId}"", 

                Dim itemsString As String = String.Join(",", items)

                Dim trackingCode As String = $"dataLayer.push({{ ecommerce: null }});
                dataLayer.push({{
                  event: ""purchase"",
                  ecommerce: {{
                      transaction_id: ""{transactionId}"",
                      value: {transactionValue},
                      tax: {transactionTax},
                      shipping: {transactionShipping},
                      currency: ""{transactionCurrency}"",
                      items: [{itemsString}]
                  }}
                }});"

                litTrackingCode.Text = "<script>" & vbCrLf & trackingCode & vbCrLf & "<script>"

            Else
                'Order not found - hide code
                phdGoogleGA4.Visible = False
                litHiddenBecause.Text = "<!-- GOOGLE ANALYTICS: _OrderID " & _OrderID & " was not found in db -->"
            End If
        Else
            'Ecommerce tracking not enabled
            phdGoogleGA4.Visible = False
            litHiddenBecause.Text = "<!-- GOOGLE ANALYTICS: general.google.analytics.webpropertyid is not set -->"
        End If

    End Sub


End Class
