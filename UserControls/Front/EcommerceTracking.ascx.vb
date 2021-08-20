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
        If KartSettingsManager.GetKartConfig("general.google.analytics.webpropertyid") <> "" Then
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
                phdEcommerceTracking.Visible = True

                Dim numShippingTotal As Single = tblOrder.Rows(0).Item("O_ShippingPrice") + tblOrder.Rows(0).Item("O_OrderHandlingCharge")
                Dim numTotalItems As Single = tblOrder.Rows(0).Item("O_AffiliateTotalPrice")
                Dim numTax As Single = tblOrder.Rows(0).Item("O_TotalPrice") - numTotalItems - numShippingTotal

                'Set currency ID, need to use this
                'elsewhere
                hidCurrencyID.Value = tblOrder.Rows(0).Item("O_CurrencyID")

                litHeader.Text = vbCrLf & vbCrLf & "<script type=""text/javascript"">" & vbCrLf
                litHeader.Text &= "gtag('event', 'purchase', {" & vbCrLf

                'Fill out the items in the javascript
                litOrderID.Text = ("""transaction_id"": """ & _OrderID & """")
                litWebShopName.Text = ("""affiliation"": """ & GetGlobalResourceObject("Kartris", "Config_Webshopname") & """")
                litTotal.Text = ("""value"": " & CkartrisDataManipulation.HandleDecimalValuesString(CurrenciesBLL.FormatCurrencyPrice(hidCurrencyID.Value, numTotalItems, False)))
                litCurrencyIsoCode.Text = ("""currency"": """ & CurrenciesBLL.CurrencyCode(hidCurrencyID.Value) & """")
                litTax.Text = ("""tax"": " & CkartrisDataManipulation.HandleDecimalValuesString(CurrenciesBLL.FormatCurrencyPrice(hidCurrencyID.Value, numTax, False)))
                litShipping.Text = ("""shipping"": " & CkartrisDataManipulation.HandleDecimalValuesString(CurrenciesBLL.FormatCurrencyPrice(hidCurrencyID.Value, numShippingTotal, False)))

                'Clear order details
                tblOrder.Dispose()

                'Fill order with details of customer invoice,
                'so we can loop through individual item
                'records
                tblOrder = objBasketBLL.GetCustomerInvoice(_OrderID, _UserID, 1)

                'Bind data to repeater control
                rptOrderItems.DataSource = tblOrder
                rptOrderItems.DataBind()

                litFooter.Text = "});" & vbCrLf
                litFooter.Text &= "</script>"
            Else
                'Order not found - hide code
                phdEcommerceTracking.Visible = False
                litHiddenBecause.Text = "<!-- GOOGLE ANALYTICS: _OrderID " & _OrderID & " was not found in db -->"
            End If
        Else
            'Ecommerce tracking not enabled
            phdEcommerceTracking.Visible = False
            litHiddenBecause.Text = "<!-- GOOGLE ANALYTICS: general.google.analytics.webpropertyid is not set -->"
        End If

    End Sub

    ''' <summary>
    ''' Repeater gets data bound
    ''' </summary>
    ''' <remarks>By Paul</remarks>
    Protected Sub rptOrderItems_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptOrderItems.ItemDataBound

        Try
            'Declare variables
            Dim strVersionCode, strItemName, strItemOptions As String
            Dim numItemPrice, numItemQuantity As Single

            'Set variable values from data in
            'invoice row records of this order
            strVersionCode = e.Item.DataItem("IR_VersionCode")
            strItemName = e.Item.DataItem("IR_VersionName")
            strItemOptions = e.Item.DataItem("IR_OptionsText")
            numItemPrice = CurrenciesBLL.FormatCurrencyPrice(hidCurrencyID.Value, e.Item.DataItem("IR_PricePerItem"), False)
            numItemQuantity = e.Item.DataItem("IR_Quantity")

            'Find the controls within the repeater
            'and set their values
            CType(e.Item.FindControl("litVersionCode"), Literal).Text = ("""id"": """ & strVersionCode & """")
            CType(e.Item.FindControl("litItemName"), Literal).Text = ("""name"": """ & strItemName & """")
            CType(e.Item.FindControl("litItemOptions"), Literal).Text = ("""variant"": """ & Replace(strItemOptions, "<br />", "/") & """")
            CType(e.Item.FindControl("litItemQuantity"), Literal).Text = ("""quantity"": " & numItemQuantity)
            CType(e.Item.FindControl("litItemPrice"), Literal).Text = ("""price"": " & CkartrisDataManipulation.HandleDecimalValuesString(numItemPrice.ToString))
        Catch ex As Exception
            'Catch the error
        End Try


    End Sub


End Class
