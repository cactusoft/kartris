'========================================================================
'Kartris - www.kartris.com
'Copyright 2018 CACTUSOFT

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

    'Declare parameters
    Public _OrderID As Long
    Public _UserID As Long
    Private objBasket As New kartris.Basket

    'Order ID
    Public Property OrderID() As Long
        Get
            Return _OrderID
        End Get
        Set(ByVal value As Long)
            _OrderID = value
        End Set
    End Property

    'User ID - security measure
    Public Property UserID() As Long
        Get
            Return _UserID
        End Get
        Set(ByVal value As Long)
            _UserID = value
        End Set
    End Property

    ''' <summary>
    ''' Page Load
    ''' </summary>
    ''' <remarks>By Paul</remarks>
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Page.User.Identity.IsAuthenticated Then

            'Only need ecommerce tracking if there is a 
            'webproperty ID (site identifier) set in 
            'the config settings of Kartris
            If KartSettingsManager.GetKartConfig("general.googleanalytics.webpropertyid") <> "" Then
                'Declare variables
                Dim tblOrder As System.Data.DataTable

                'Fill datatable width basket items
                tblOrder = BasketBLL.GetCustomerOrderDetails(_OrderID)

                'Examine data of order, if exists
                If tblOrder.Rows.Count > 0 Then

                    If tblOrder.Rows(0).Item("O_CustomerID") = _UserID Then

                        '================================
                        'ORDER FOUND AND OK
                        'Order exists, and belongs to the
                        'logged in user, and tracking is
                        'enabled.
                        '================================
                        phdEcommerceTracking.Visible = True

                        'Fill out the items in the javascript
                        litOrderID.Text = _OrderID
                        litGoogleWebPropertyID.Text = KartSettingsManager.GetKartConfig("general.googleanalytics.webpropertyid")
                        litWebShopName.Text = GetGlobalResourceObject("Kartris", "Config_Webshopname")

                        Dim numShippingTotal As Single = tblOrder.Rows(0).Item("O_ShippingPrice") + tblOrder.Rows(0).Item("O_OrderHandlingCharge")
                        Dim numTotalItems As Single = tblOrder.Rows(0).Item("O_AffiliateTotalPrice")
                        Dim numTax As Single = tblOrder.Rows(0).Item("O_TotalPrice") - numTotalItems - numShippingTotal

                        'Set currency ID, need to use this
                        'elsewhere
                        hidCurrencyID.Value = tblOrder.Rows(0).Item("O_CurrencyID")

                        'Order detail amounts
                        litShipping.Text = CkartrisDataManipulation.HandleDecimalValuesString(CurrenciesBLL.FormatCurrencyPrice(hidCurrencyID.Value, numShippingTotal, False))
                        litTotal.Text = CkartrisDataManipulation.HandleDecimalValuesString(CurrenciesBLL.FormatCurrencyPrice(hidCurrencyID.Value, numTotalItems, False))
                        litTax.Text = CkartrisDataManipulation.HandleDecimalValuesString(CurrenciesBLL.FormatCurrencyPrice(hidCurrencyID.Value, numTax, False))

                        'Clear order details
                        tblOrder.Dispose()

                        'Fill order with details of customer invoice,
                        'so we can loop through individual item
                        'records
                        tblOrder = BasketBLL.GetCustomerInvoice(_OrderID, _UserID, 1)

                        'Bind data to repeater control
                        rptOrderItems.DataSource = tblOrder
                        rptOrderItems.DataBind()


                    Else
                        'Trying to call an order that does
                        'not belong to this user. Fail!
                        'Or if no analytics web site ID set
                        'up - fail!
                        phdEcommerceTracking.Visible = False

                    End If

                Else
                    'Order not found - hide code
                    phdEcommerceTracking.Visible = False
                End If
            Else
                'Ecommerce tracking not enabled
                phdEcommerceTracking.Visible = False
            End If

        Else
            'If user is not authenticated, then
            'we assume this control is on a page
            'being called by a remote server, so
            'no point adding all this client side
            'javascript code
            phdEcommerceTracking.Visible = False

        End If
    End Sub

    ''' <summary>
    ''' Repeater gets data bound
    ''' </summary>
    ''' <remarks>By Paul</remarks>
    Protected Sub rptOrderItems_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptOrderItems.ItemDataBound

        'Declare variables
        Dim strVersionCode, strItemName, strItemOptions As String
        Dim numOrderID As Long
        Dim numItemPrice, numItemQuantity As Single

        'Set variable values from data in
        'invoice row records of this order
        numOrderID = e.Item.DataItem("IR_OrderNumberID")
        strVersionCode = e.Item.DataItem("IR_VersionCode")
        strItemName = e.Item.DataItem("IR_VersionName")
        strItemOptions = e.Item.DataItem("IR_OptionsText")
        numItemPrice = CurrenciesBLL.FormatCurrencyPrice(hidCurrencyID.Value, e.Item.DataItem("IR_PricePerItem"), False)
        numItemQuantity = e.Item.DataItem("IR_Quantity")

        'Find the controls within the repeater
        'and set their values
        CType(e.Item.FindControl("litOrderID"), Literal).Text = numOrderID
        CType(e.Item.FindControl("litVersionCode"), Literal).Text = strVersionCode
        CType(e.Item.FindControl("litItemName"), Literal).Text = strItemName
        CType(e.Item.FindControl("litItemOptions"), Literal).Text = Replace(strItemOptions, "<br />", "/")
        CType(e.Item.FindControl("litItemPrice"), Literal).Text = CkartrisDataManipulation.HandleDecimalValuesString(numItemPrice.ToString)
        CType(e.Item.FindControl("litItemQuantity"), Literal).Text = numItemQuantity
    End Sub


End Class
