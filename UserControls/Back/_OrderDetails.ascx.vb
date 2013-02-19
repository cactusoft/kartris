'========================================================================
'Kartris - www.kartris.com
'Copyright 2013 CACTUSOFT INTERNATIONAL FZ LLC

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisBLL
Imports CkartrisEnumerations
Imports CkartrisDisplayFunctions
Imports CkartrisDataManipulation
Imports KartSettingsManager


Partial Class UserControls_Back_OrderDetails
    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' this runs when an update to data is made to trigger the animation
    ''' </summary>
    ''' <remarks></remarks>
    Public Event ShowMasterUpdate()

    ''' <summary>
    ''' this runs each time the page is called
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then

            ViewState("Referer") = Request.ServerVariables("HTTP_REFERER")

            Try
                'Get the Order ID QueryString - if it won't convert to integer then force return to Orders List page
                ViewState("numOrderID") = CType(Request.QueryString("OrderID"), Integer)
                fvwOrderDetails.DataSource = OrdersBLL.GetOrderByID(ViewState("numOrderID"))
                fvwOrderDetails.DataBind()
                UC_CustomerOrder.OrderID = ViewState("numOrderID")
                UC_CustomerOrder.ShowOrderSummary = False
                If Request.QueryString("cloned") = "y" Then RaiseEvent ShowMasterUpdate()
            Catch ex As Exception
                CkartrisFormatErrors.LogError(ex.Message)
                Response.Redirect("_OrdersList.aspx")
            End Try
        End If
    End Sub

    'Format back link
    Public Function FormatBackLink(ByVal strDate As String, ByVal strFromDate As String, ByVal strPage As String) As String
        Dim strURL As String = ""
        If strFromDate = "false" And (strPage = "" Or strPage = "1") Then
            'No page or date passed, format js back link
            strURL = "javascript:history.back()"
        Else
            'We have either a date, or page number, or both
            If strFromDate = "true" Then
                strURL &= "_OrdersList.aspx?strDate=" & strDate
            Else
                strURL &= "_OrdersList.aspx?strDate="
            End If
            If CInt(strPage) > 1 Then
                strURL &= "&Page=" & strPage
            End If
        End If

        Return strURL
    End Function


    ''' <summary>
    ''' when the order details are bound to the data
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub fvwOrderDetails_DataBound(ByVal sender As Object, ByVal e As System.EventArgs) Handles fvwOrderDetails.DataBound

        Dim hidOrderCoupon As HiddenField = DirectCast(fvwOrderDetails.FindControl("hidOrderCoupon"), HiddenField)
        Dim hidOrderText As HiddenField = DirectCast(fvwOrderDetails.FindControl("hidOrderText"), HiddenField)

        Dim phdViewCoupon As PlaceHolder = DirectCast(fvwOrderDetails.FindControl("phdViewCoupon"), PlaceHolder)
        Dim phdSendEmailToCustomer As PlaceHolder = DirectCast(fvwOrderDetails.FindControl("phdSendEmailToCustomer"), PlaceHolder)
        Dim hidSendOrderUpdateEmail As HiddenField = DirectCast(fvwOrderDetails.FindControl("hidSendOrderUpdateEmail"), HiddenField)

        Dim hidAffiliatePaymentID As HiddenField = DirectCast(fvwOrderDetails.FindControl("hidAffiliatePaymentID"), HiddenField)
        Dim hidOrderCurrencyID As HiddenField = DirectCast(fvwOrderDetails.FindControl("hidOrderCurrencyID"), HiddenField)
        Dim phdAffiliate As PlaceHolder = DirectCast(fvwOrderDetails.FindControl("phdAffiliate"), PlaceHolder)
        Dim litOrderTotalPrice As Literal = DirectCast(fvwOrderDetails.FindControl("litOrderTotalPrice"), Literal)
        Dim litOrderLanguage As Literal = DirectCast(fvwOrderDetails.FindControl("litOrderLanguage"), Literal)
        Dim txtOrderShippingAddress As TextBox = DirectCast(fvwOrderDetails.FindControl("txtOrderShippingAddress"), TextBox)
        Dim hidOrderData As HiddenField = DirectCast(fvwOrderDetails.FindControl("hidOrderData"), HiddenField)

        Dim dblOrderTotalPrice As Single = CSng(litOrderTotalPrice.Text)
        Dim srtOrderCurrencyID As Short = CShort(hidOrderCurrencyID.Value)


        'Hide edit button if order data is empty and if order is not flagged as replaced
        If Trim(hidOrderData.Value) <> "" And OrdersBLL._GetChildOrderID(ViewState("numOrderID")) = 0 Then
            DirectCast(fvwOrderDetails.FindControl("lnkBtnEdit"), LinkButton).Visible = True
            DirectCast(fvwOrderDetails.FindControl("btnOrderUpdate"), LinkButton).Visible = True
            DirectCast(fvwOrderDetails.FindControl("lnkBtnDelete"), LinkButton).Visible = True
        Else
            DirectCast(fvwOrderDetails.FindControl("lnkBtnEdit"), LinkButton).Visible = False
            DirectCast(fvwOrderDetails.FindControl("btnOrderUpdate"), LinkButton).Visible = False
            DirectCast(fvwOrderDetails.FindControl("lnkBtnDelete"), LinkButton).Visible = False

            'Show a clear message that this order was replaced
            DirectCast(fvwOrderDetails.FindControl("phdCancelledMessage"), PlaceHolder).Visible = True
        End If
        hidOrderData.Value = ""

        'Get the initial values of the checkboxes and store them in the variables
        ViewState("O_Sent") = DirectCast(fvwOrderDetails.FindControl("chkOrderSent"), CheckBox).Checked
        ViewState("O_Paid") = DirectCast(fvwOrderDetails.FindControl("chkOrderPaid"), CheckBox).Checked
        ViewState("O_Invoiced") = DirectCast(fvwOrderDetails.FindControl("chkOrderInvoiced"), CheckBox).Checked
        ViewState("O_Shipped") = DirectCast(fvwOrderDetails.FindControl("chkOrderShipped"), CheckBox).Checked
        ViewState("O_Notes") = DirectCast(fvwOrderDetails.FindControl("txtOrderNotes"), TextBox).Text
        ViewState("O_Cancelled") = DirectCast(fvwOrderDetails.FindControl("chkOrderCancelled"), CheckBox).Checked

        'Convert OrderLanguageID field to Front End Language Name
        litOrderLanguage.Text = LanguagesBLL.GetLanguageFrontName_s(CShort(litOrderLanguage.Text))


        'Format the Total Price base on the Currency
        Try
            litOrderTotalPrice.Text = CurrenciesBLL.FormatCurrencyPrice(srtOrderCurrencyID, dblOrderTotalPrice)
        Catch ex As Exception
            litOrderTotalPrice.Text = "? " & dblOrderTotalPrice
        End Try


        'Hide the Affiliate fields if there's no affiliate
        If hidAffiliatePaymentID.Value = "0" Then phdAffiliate.Visible = False

        'Hide the Coupon fields if there's no coupon used
        If hidOrderCoupon.Value = "" Then phdViewCoupon.Visible = False

        'Process the order text
        Dim strOrderText As String = hidOrderText.Value
        If InStr(Server.HtmlDecode(strOrderText).ToLower, "</html>") > 0 Then
            strOrderText = CkartrisBLL.ExtractHTMLBodyContents(Server.HtmlDecode(strOrderText))
            strOrderText = strOrderText.Replace("[orderid]", ViewState("numOrderID"))
        Else
            strOrderText = Replace(strOrderText, vbCrLf, "<br/>").Replace(vbLf, "<br/>")
        End If
        DirectCast(tabOrderText.FindControl("lblOrderText"), Label).Text = strOrderText
        ViewState("O_Details") = hidOrderText.Value
        hidOrderText.Value = ""


        If KartSettingsManager.GetKartConfig("backend.orders.emailupdates") = "n" Then
            phdSendEmailToCustomer.Visible = False
            hidSendOrderUpdateEmail.Value = False
        End If
    End Sub

    ''' <summary>
    ''' handles updating the order
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub fvwOrderDetails_ItemUpdating(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.FormViewUpdateEventArgs) Handles fvwOrderDetails.ItemUpdating
        Dim chkOrderSent As CheckBox = DirectCast(fvwOrderDetails.FindControl("chkOrderSent"), CheckBox)
        Dim chkOrderPaid As CheckBox = DirectCast(fvwOrderDetails.FindControl("chkOrderPaid"), CheckBox)
        Dim chkOrderInvoiced As CheckBox = DirectCast(fvwOrderDetails.FindControl("chkOrderInvoiced"), CheckBox)
        Dim chkOrderShipped As CheckBox = DirectCast(fvwOrderDetails.FindControl("chkOrderShipped"), CheckBox)
        Dim txtOrderStatus As TextBox = DirectCast(fvwOrderDetails.FindControl("txtOrderStatus"), TextBox)
        Dim txtOrderNotes As TextBox = DirectCast(fvwOrderDetails.FindControl("txtOrderNotes"), TextBox)
        Dim chkOrderCancelled As CheckBox = DirectCast(fvwOrderDetails.FindControl("chkOrderCancelled"), CheckBox)

        Dim hidSendOrderUpdateEmail As HiddenField = DirectCast(fvwOrderDetails.FindControl("hidSendOrderUpdateEmail"), HiddenField)

        'Email order update?
        If hidSendOrderUpdateEmail.Value = True Then

            Dim chkSendOrderUpdateEmail As CheckBox = DirectCast(fvwOrderDetails.FindControl("chkSendOrderUpdateEmail"), CheckBox)
            If chkSendOrderUpdateEmail.Checked Then
                Dim hidOrderLanguageID As HiddenField = DirectCast(fvwOrderDetails.FindControl("hidOrderLanguageID"), HiddenField)
                Dim litOrderID As Literal = DirectCast(fvwOrderDetails.FindControl("litOrderID"), Literal)
                Dim hidCustomerID As HiddenField = DirectCast(fvwOrderDetails.FindControl("hidCustomerID"), HiddenField)

                Dim strEmailFrom As String = LanguagesBLL.GetEmailFrom(CInt(hidOrderLanguageID.Value))
                Dim strEmailTo As String = UsersBLL.GetEmailByID(CInt(hidCustomerID.Value))
                Dim strEmailText As String
                Dim strSubjectLine As String = GetGlobalResourceObject("Email", "EmailText_OrderUpdateFrom") & " " & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))
                strEmailText = GetGlobalResourceObject("Email", "EmailText_OrderStatusUpdated") & vbCrLf & WebShopURL() & "CustomerViewOrder.aspx?O_ID=" & litOrderID.Text

                'Add in what was changed
                Dim strOrderStatus As String = ""
                If ViewState("O_Sent") <> chkOrderSent.Checked And chkOrderSent.Checked Then
                    strOrderStatus += vbCrLf & GetGlobalResourceObject("_Orders", "ContentText_OrderStatusSent")
                End If
                If ViewState("O_Invoiced") <> chkOrderInvoiced.Checked And chkOrderInvoiced.Checked Then
                    strOrderStatus += vbCrLf & GetGlobalResourceObject("_Orders", "ContentText_OrderStatusInvoiced")
                End If
                If ViewState("O_Paid") <> chkOrderPaid.Checked And chkOrderPaid.Checked Then
                    strOrderStatus += vbCrLf & GetGlobalResourceObject("_Orders", "ContentText_OrderStatusPaid")
                End If
                If ViewState("O_Shipped") <> chkOrderShipped.Checked And chkOrderShipped.Checked Then
                    strOrderStatus += vbCrLf & GetGlobalResourceObject("_Orders", "ContentText_OrderStatusShipped")
                End If
                If ViewState("O_Cancelled") <> chkOrderCancelled.Checked And chkOrderCancelled.Checked Then
                    strOrderStatus += vbCrLf & GetGlobalResourceObject("_Orders", "ContentText_OrderStatusCancelled")
                End If
                If strOrderStatus <> "" Then
                    strEmailText += vbCrLf & vbCrLf & GetGlobalResourceObject("_Orders", "ContentText_OrderStatus") & ":" & strOrderStatus
                End If

                Dim strOrderText As String = ViewState("O_Details")

                'Process the order text
                If InStr(Server.HtmlDecode(strOrderText).ToLower, "</html>") > 0 Then
                    strOrderText = CkartrisBLL.ExtractHTMLBodyContents(Server.HtmlDecode(strOrderText))
                    strOrderText = strOrderText.Replace("[orderid]", ViewState("numOrderID"))
                End If

                strEmailText += vbCrLf & vbCrLf & strOrderText.Replace("<br />", vbCrLf)

                If ViewState("O_Notes") <> txtOrderNotes.Text And Trim(txtOrderNotes.Text) <> "" Then
                    strEmailText += vbCrLf & GetGlobalResourceObject("_Kartris", "ContentText_Notes") & ":" & vbCrLf & txtOrderNotes.Text
                End If

                Dim blnHTMLEmail As Boolean = GetKartConfig("general.email.enableHTML") = "y"
                If blnHTMLEmail Then
                    Dim strHTMLEmailText As String = RetrieveHTMLEmailTemplate("OrderUpdate")
                    'build up the HTML email if template is found
                    If Not String.IsNullOrEmpty(strHTMLEmailText) Then
                        strHTMLEmailText = strHTMLEmailText.Replace("[webshopurl]", WebShopURL)
                        strHTMLEmailText = strHTMLEmailText.Replace("[orderid]", ViewState("numOrderID"))
                        strHTMLEmailText = strHTMLEmailText.Replace("[orderstatus]", strOrderStatus.Replace(vbCrLf, "<br />"))
                        strHTMLEmailText = strHTMLEmailText.Replace("[orderdetails]", strOrderText)
                        If ViewState("O_Notes") <> txtOrderNotes.Text And Trim(txtOrderNotes.Text) <> "" Then
                            strHTMLEmailText = strHTMLEmailText.Replace("[ordernotesline]", "<p>" & GetGlobalResourceObject("_Kartris", "ContentText_Notes") &
                                                                    ": <br />" & txtOrderNotes.Text & "</p>")
                        Else
                            strHTMLEmailText = strHTMLEmailText.Replace("[ordernotesline]", "")
                        End If
                        strEmailText = strHTMLEmailText
                    Else
                        blnHTMLEmail = False
                    End If
                    SendEmail(strEmailFrom, strEmailTo, strSubjectLine, strEmailText, , , , , blnHTMLEmail)
                End If
            End If
        End If

        'This line is actually the one that updates the order - not the built-in FormView update. Gives us more flexibility - needs to catch some thingies. =)
        If OrdersBLL._UpdateStatus(ViewState("numOrderID"), chkOrderSent.Checked, chkOrderPaid.Checked, chkOrderShipped.Checked,
                                chkOrderInvoiced.Checked, txtOrderStatus.Text, txtOrderNotes.Text, chkOrderCancelled.Checked) > 0 Then
            RaiseEvent ShowMasterUpdate()
        Else
            'error
        End If

    End Sub

    ''' <summary>
    ''' handles the delete linkbutton being clicked
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub lnkBtnDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified"))
    End Sub

    ''' <summary>
    ''' handles the 'view coupon' linkbutton being clicked
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub lnkBtnViewCoupon_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim hidOrderCoupon As HiddenField = DirectCast(fvwOrderDetails.FindControl("hidOrderCoupon"), HiddenField)
        _UC_ViewCouponPopup.LoadCouponInfo(CouponsBLL._GetByCouponCode(hidOrderCoupon.Value))
    End Sub

    ''' <summary>
    ''' if the delete is confirmed, "Yes" is chosen
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        Dim blnReturnStock As Boolean
        Dim blnOrigO_Sent As Boolean = CBool(DirectCast(fvwOrderDetails.FindControl("hidOrigOrderSent"), HiddenField).Value)
        If KartSettingsManager.GetKartConfig("backend.orders.returnstockondelete") <> "n" And blnOrigO_Sent Then blnReturnStock = True Else blnReturnStock = False
        OrdersBLL._Delete(ViewState("numOrderID"), blnReturnStock)
        RaiseEvent ShowMasterUpdate()
        Response.Redirect(ViewState("Referer"))
    End Sub

    ''' <summary>
    ''' If 'edit' clicked, redirects to order editing page
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub lnkBtnEdit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("_ModifyOrder.aspx?OrderID=" & ViewState("numOrderID"))
    End Sub

End Class
