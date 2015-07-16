'========================================================================
'Kartris - www.kartris.com
'Copyright 2015 CACTUSOFT

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
Imports CkartrisDataManipulation
Imports KartSettingsManager

Partial Class Callback
    Inherits PageBaseClass

    Private clsPlugin As Kartris.Interfaces.PaymentGateway

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Dim strCallbackError As String = ""
            Dim strResult As String = ""
            Dim strBodyText As String = ""
            Dim blnFullDisplay As Boolean = True
            If Request.QueryString("d") = "off" Then blnFullDisplay = False
            Dim strGatewayName As String = StrConv(Request.QueryString("g"), vbProperCase)
            Dim clsPlugin As Kartris.Interfaces.PaymentGateway = Nothing

            'Callback Step 0 - normal callback
            'Callback Step 1 - update order but don't display full HTML if d=off QS is passed, write gateway dll output to screen
            'Callback Step 2 - don't update order, just display result as usual
            Dim intCallbackStep As Integer
            Try
                intCallbackStep = CInt(Request.QueryString("step"))
            Catch ex As Exception
                intCallbackStep = 0
            End Try

            '-----------------------------------------------------
            'CALLBACK
            'We need to know which gateway to process. This can
            'be done in two ways. The Callback.aspx page can be
            'sent a querystring value named 'g', for example:

            'Callback.aspx?g=Paypal

            '(the value of 'g' should match the name of the
            'payment system's plugin folder)

            'Some payment systems won't pass this querystring
            'value and form values at the same time. So instead,
            'the following format can be used:

            'Callback-Paypal.aspx

            'Kartris will recognize this and map it to the
            'querystring version above.
            '-----------------------------------------------------
            If Not String.IsNullOrEmpty(strGatewayName) Then
                'Let's turn some comment gateway names which
                'might be sent in any case format to the correct
                'mixed case format so they look nice.
                If LCase(strGatewayName) = "sagepaydirect" Then strGatewayName = "SagePayDirect"
                If LCase(strGatewayName) = "sagepay" Then strGatewayName = "SagePay"
                If LCase(strGatewayName) = "cp" Then strGatewayName = "Cactuspay"

                'Loop through incoming fields if form post to this page
                For Each fldName In Request.Form
                    If Not String.IsNullOrEmpty(strResult) Then strResult += ":-:"
                    strResult += "FF_" & fldName & ":*:" & Request.Form(fldName)
                Next

                'Loop through incoming fields if URL with 
                For Each fldName In Request.QueryString
                    If Not String.IsNullOrEmpty(strResult) Then strResult += ":-:"
                    strResult += "QS_" & fldName & ":*:" & Request.QueryString(fldName)
                Next

                'Load in the payment gateway in question
                'This is why it is important that the name is
                'passed correctly when setting up the callback.aspx
                clsPlugin = Payment.PPLoader(strGatewayName)

                'According to the dictionary, 'referrer' is the
                'correct spelling and whoever decided on 'referer'
                'is the one who is wrong :)
                Dim strReferrerURL As String
                Try
                    strReferrerURL = Request.UrlReferrer.ToString()
                Catch ex As Exception
                    strReferrerURL = Request.ServerVariables("HTTP_REFERER")
                End Try

                'Process the callback and append to the result
                strResult = clsPlugin.ProcessCallback(strResult, strReferrerURL)

                '-----------------------------------------------------
                'CALLBACK SUCCESSFUL
                'Lookup order to being processing it
                '-----------------------------------------------------
                If clsPlugin.CallbackSuccessful Then
                    Dim O_ID As Integer = clsPlugin.CallbackOrderID
                    Dim tblOrder As DataTable = OrdersBLL.GetOrderByID(O_ID)

                    Dim O_CouponCode As String = ""
                    Dim O_TotalPriceGateway As Double = 0
                    Dim O_WLID As Integer = 0
                    Dim O_CustomerID As Integer = 0
                    Dim O_LanguageID As Integer = 0
                    Dim O_CurrencyIDGateway As Integer = 0
                    Dim strBasketBLL As String = ""
                    If tblOrder.Rows.Count > 0 Then
                        If tblOrder.Rows(0)("O_Sent") = 0 OrElse intCallbackStep = 2 Then
                            'Store the order details
                            O_CouponCode = CStr(FixNullFromDB(tblOrder.Rows(0)("O_CouponCode")))
                            O_TotalPriceGateway = CDbl(tblOrder.Rows(0)("O_TotalPriceGateway"))
                            O_WLID = CInt(tblOrder.Rows(0)("O_WishListID"))
                            O_CustomerID = CInt(tblOrder.Rows(0)("O_CustomerID"))
                            O_LanguageID = CInt(tblOrder.Rows(0)("O_LanguageID"))
                            strBasketBLL = CStr(tblOrder.Rows(0)("O_Status"))
                            strBodyText = CStr(tblOrder.Rows(0)("O_Details"))
                            O_CurrencyIDGateway = CInt(tblOrder.Rows(0)("O_CurrencyIDGateway"))
                        Else
                            strCallbackError = "Callback Failure: " & vbCrLf & "Order already submitted (ID: " & O_ID & ", Order sent: 'yes')"
                        End If
                    Else
                        'The order ID we looked up was not
                        'found in our database
                        strCallbackError = "Callback Failure: " & vbCrLf & "Order id not found (" & O_ID & ")"
                    End If

                    '-----------------------------------------------------
                    'NO ERRORS
                    'Proceed to process order and despatch confirmation
                    '-----------------------------------------------------
                    If String.IsNullOrEmpty(strCallbackError) Then

                        If Math.Round(clsPlugin.CallbackOrderAmount, 2) = Math.Round(O_TotalPriceGateway, 2) OrElse _
                            NeutralizeCurrencyValue(Math.Round(clsPlugin.CallbackOrderAmount, 2).ToString) = NeutralizeCurrencyValue(Math.Round(O_TotalPriceGateway, 2).ToString) OrElse
                            intCallbackStep = 2 Then

                            If intCallbackStep <> 2 Then
                                Dim blnCheckInvoicedOnPayment As Boolean = GetKartConfig("frontend.orders.checkinvoicedonpayment") = "y"
                                Dim blnCheckReceivedOnPayment As Boolean = GetKartConfig("frontend.orders.checkreceivedonpayment") = "y"

                                '-----------------------------------------------------
                                'UPDATE ORDER STATUS
                                'Set invoiced and received checkboxes, depending on
                                'config settings
                                '-----------------------------------------------------
                                Dim intUpdateResult As Integer = OrdersBLL.CallbackUpdate(O_ID, clsPlugin.CallbackReferenceCode, CkartrisDisplayFunctions.NowOffset, True, _
                                                                                          blnCheckInvoicedOnPayment, _
                                                                                          blnCheckReceivedOnPayment, _
                                                                                          GetGlobalResourceObject("Email", "EmailText_OrderTime") & " " & CkartrisDisplayFunctions.NowOffset, _
                                                                                          O_CouponCode, O_WLID, O_CustomerID, O_CurrencyIDGateway, clsPlugin.GatewayName, O_TotalPriceGateway)

                                '-----------------------------------------------------
                                'FORMAT CONFIRMATION EMAIL
                                '-----------------------------------------------------
                                'Set some values for use later
                                Dim blnUseHTMLOrderEmail As Boolean = (GetKartConfig("general.email.enableHTML") = "y")
                                Dim strCustomerEmailText As String = ""
                                Dim strStoreEmailText As String = ""
                                strBodyText = strBodyText.Replace("[orderid]", O_ID)
                                'we're in the callback page so obviously po_offlinedetails/bitcoin method is not being used
                                strBodyText = strBodyText.Replace("[poofflinepaymentdetails]", "")
                                strBodyText = strBodyText.Replace("[bitcoinpaymentdetails]", "")

                                If KartSettingsManager.GetKartConfig("frontend.checkout.ordertracking") <> "n" Then
                                    If Not blnUseHTMLOrderEmail Then
                                        'Add order tracking information at the top
                                        strCustomerEmailText = GetGlobalResourceObject("Email", "EmailText_OrderLookup") & vbCrLf & vbCrLf & WebShopURL() & "Customer.aspx" & vbCrLf & vbCrLf
                                    End If
                                End If
                                strCustomerEmailText += strBodyText

                                If Not blnUseHTMLOrderEmail Then
                                    'Add in email header above that
                                    strCustomerEmailText = GetGlobalResourceObject("Email", "EmailText_OrderReceived") & vbCrLf & vbCrLf & _
                                        GetGlobalResourceObject("Kartris", "ContentText_OrderNumber") & ": " & O_ID & vbCrLf & vbCrLf & _
                                        strCustomerEmailText
                                Else
                                    strCustomerEmailText = strCustomerEmailText.Replace("[storeowneremailheader]", "")
                                End If


                                Dim strFromEmail As String = LanguagesBLL.GetEmailFrom(O_LanguageID)

                                '-----------------------------------------------------
                                'SEND CONFIRMATION EMAIL
                                'To customer
                                '-----------------------------------------------------
                                If KartSettingsManager.GetKartConfig("frontend.orders.emailcustomer") <> "n" Then
                                    SendEmail(strFromEmail, UsersBLL.GetEmailByID(O_CustomerID), GetGlobalResourceObject("Email", "Config_Subjectline") & " (#" & O_ID & ")", strCustomerEmailText, , , , , blnUseHTMLOrderEmail)
                                End If

                                '-----------------------------------------------------
                                'SEND CONFIRMATION EMAIL
                                'To store owner
                                '-----------------------------------------------------
                                If KartSettingsManager.GetKartConfig("frontend.orders.emailmerchant") <> "n" Then
                                    If Not blnUseHTMLOrderEmail Then
                                        strStoreEmailText = GetGlobalResourceObject("Email", "EmailText_StoreEmailHeader") & vbCrLf & vbCrLf & _
                                   GetGlobalResourceObject("Kartris", "ContentText_OrderNumber") & ": " & O_ID & vbCrLf & vbCrLf & strBodyText
                                    Else
                                        strStoreEmailText = strBodyText.Replace("[storeowneremailheader]", GetGlobalResourceObject("Email", "EmailText_StoreEmailHeader"))
                                    End If

                                    SendEmail(strFromEmail, LanguagesBLL.GetEmailTo(1), GetGlobalResourceObject("Email", "Config_Subjectline2") & " (#" & O_ID & ")", strStoreEmailText, , , , , blnUseHTMLOrderEmail)
                                End If

                                'Send an order notification to Windows Store App if enabled
                                PushKartrisNotification("o")
                            Else
                                strBodyText = strBodyText.Replace("[orderid]", O_ID)
                                'we're in the callback page so obviously po_offline/bitcoin method is not being used
                                strBodyText = strBodyText.Replace("[poofflinepaymentdetails]", "")
                                strBodyText = strBodyText.Replace("[bitcoinpaymentdetails]", "")
                            End If

                            Try
                                'This handles setting the order and customer ID
                                'for Google Analytics tracking
                                UC_EcommerceTracking.OrderID = O_ID
                                UC_EcommerceTracking.UserID = CurrentLoggedUser.ID
                            Catch ex As Exception
                                'If that errors for some reason, turn off
                                'the ecommerce tracking
                                UC_EcommerceTracking.Visible = False
                            End Try

                        Else
                            'The amount we recorded for the order, and the
                            'confirmation of the amount paid at the gateway
                            'do not match. This could indicate tampering, i.e.
                            'someone pays an order but has edited the amount
                            'down prior to going off to the gateway. Most
                            'gateways have some kind of defence against this,
                            'but it is a good check to make if we can get the
                            'amount back from the gateway.
                            strCallbackError = "Callback Failure: " & vbCrLf & "Order ID: " & O_ID & "- Order Amount doesn't match. " & vbCrLf & _
                                        "Order Value in DB: " & Math.Round(O_TotalPriceGateway, 2) & vbCrLf & _
                                        "  Order Value from Gateway: " & Math.Round(clsPlugin.CallbackOrderAmount, 2) & vbCrLf & _
                                        "  Ref: " & clsPlugin.CallbackReferenceCode
                        End If
                    End If
                Else
                    'Record error
                    strCallbackError = "Callback Failure: " & strResult & vbCrLf & clsPlugin.CallbackMessage & _
                                        vbCrLf & "FF: " & Request.Form.ToString & vbCrLf & "QS: " & Request.QueryString.ToString
                End If
            Else
                'No gateway name passed with callback, log error
                strCallbackError = "Callback Failure: Gateway name not specified. " & _
                                        vbCrLf & "FF: " & Request.Form.ToString & vbCrLf & "QS: " & Request.QueryString.ToString
            End If


            'If there was no error then...
            If String.IsNullOrEmpty(strCallbackError) Then
                If GetKartConfig("frontend.payment.debugmode.enabled") = "y" Then
                    '-----------------------------------------------------
                    'LOG THE CALLBACK
                    'We log it to the error logs to avoid having to
                    'create a completely separate log system for this.
                    'Logging callbacks is useful for debugging cases
                    'where you think the callback is setup, but orders
                    'don't seem to be processed and moved to the 
                    '"completed" list. The log will show you firstly that
                    'the callback is occurring, and secondly will show
                    'you the values passed through both form fields and
                    'the querystring so you can figure out why these
                    'are not triggering the completion procedure.
                    '-----------------------------------------------------
                    CkartrisFormatErrors.LogError("Successful Callback Log (frontend.payment.debugmode.enabled=y): " & clsPlugin.CallbackMessage & vbCrLf & "FF: " & _
                                                  Request.Form.ToString & vbCrLf & "QS: " & Request.QueryString.ToString)
                End If

                'Dim BasketObject As kartris.Basket = new OldBasketBLL
                BasketBLL.DeleteBasket()
                Session("Basket") = Nothing

                '-----------------------------------------------------
                'DISPLAY OUTPUT TO CLIENT
                'Some remote type payment systems allow the callback
                'to return HTML to the payment system's server;
                'we have a setting to return 'full display', which is
                'a fully-formed Kartris page with the order result in
                'it. This works fine if returned directly to a user's
                'browser because the Callback.aspx is called directly
                'in a user's browser (e.g. SagePay VSP Form). But if
                'this full content is returned to a payment system
                'like RBSWorldPay or Realex that will relay it to the
                'client, it will result in a badly formatted page and
                'potentially SSL security warnings. This is because
                'some elements like SCRIPT tags will be stripped for
                'security reasons, local links to CSS files won't
                'find their targets, and images referenced with local
                'or http links will either be missing or trigger
                'browser security warnings.

                'The solution is to use a special HTML template to
                'format the response we send to the payment system.
                'This is optional; if you place the appropriate
                'template in the skin, Kartris should find and use
                'it.

                'The template should be put in a folder within your
                'skin called 'Templates'. It should be named as 
                'follows:

                'Callback(-[GatewayName].html)

                'The Gateway name should match the folder name of the
                'plugin exactly, for example:

                'Callback-Realex.html
                'Callback-RBSWorldPay.html

                'Kartris will find this template, replace the place-
                'holder [orderdetails] with the order details, and
                'serve back the HTML to the client. Pay attention to
                'links to external files, links to not https files
                'and banned tags (such as <script>) that payment gateways
                'might enforce. For more details, see the documentation
                'from the particular gateway to determine what is and is
                'not allowed in the HTML they relay to end users.
                '-----------------------------------------------------

                '-----------------------------------------------------
                'CALLBACK TEMPLATE CHECKS
                '-----------------------------------------------------
                'Figure out where to look for this template
                Dim strPathToCallbackTemplate As String = ""
                strPathToCallbackTemplate = "~/Skins/" & CkartrisBLL.Skin(Session("LANG")) & "/Templates/Callback_" & strGatewayName & ".html"

                'Create variable to hold the HTML content of the template,
                'if we find one and can read it
                Dim strCallbackTemplateHTML As String = ""

                'Check if template exists
                Dim arrCallbackTemplateHTML(2) As String
                If File.Exists(Server.MapPath(strPathToCallbackTemplate)) Then
                    strCallbackTemplateHTML = File.ReadAllText(Server.MapPath(strPathToCallbackTemplate))
                    If Not strCallbackTemplateHTML.Contains("[orderdetails]") Then
                        'Template does not contain the [orderdetails] tag;
                        'in this case, set the template string to "" so we
                        'can treat as if no template.
                        strCallbackTemplateHTML = ""

                        'Log an error to explain to user the problem if
                        'the required [orderdetails] tag was not found
                        CkartrisFormatErrors.LogError("Callback template " & strPathToCallbackTemplate & " does not contain required [orderdetails] tag.")
                    Else
                        arrCallbackTemplateHTML = Split(strCallbackTemplateHTML, "[orderdetails]", -1)
                    End If
                End If


                'Show full Kartris page if gateway is set to use
                'full display (normal page output) and there is no
                'template in use for this gateway.
                If blnFullDisplay And strCallbackTemplateHTML = "" Then
                    lblOrderResult.Text = GetLocalResourceObject("ContentText_TransactionSuccess")
                    If GetKartConfig("general.email.enableHTML") = "y" Then
                        litOrderDetails.Text = ExtractHTMLBodyContents(strBodyText)
                    Else
                        litOrderDetails.Text = Replace(strBodyText, vbCrLf, "<br/>")
                    End If
                Else
                    Response.Clear()
                    If intCallbackStep = 1 Then
                        Response.Write(strResult)
                    Else
                        'First part of HTML template
                        Try
                            Response.Write(arrCallbackTemplateHTML(0))
                        Catch ex As Exception
                            'No HTML template or [orderdetails] tag missing
                            'just ignore
                        End Try
                        Response.Write(GetLocalResourceObject("ContentText_TransactionSuccess"))
                        Response.Write("<br/><br/>")
                        'Response.Write(Replace(strBodyText, vbCrLf, "<br/>"))
                        Response.Write("<p><a href='" & WebShopURL() & "?strWipeBasket=yes'>" & GetGlobalResourceObject("Kartris", "ContentText_ReturnToHomepage") & "</a></p>")

                        'Closing part of HTML template
                        Try
                            Response.Write(arrCallbackTemplateHTML(1)) 'Closing part of HTML template
                        Catch ex As Exception
                            'No HTML template or [orderdetails] tag missing
                            'just ignore
                        End Try
                    End If
                    Response.End()
                End If
            Else
                'Log the error
                CkartrisFormatErrors.LogError(strCallbackError)
                If blnFullDisplay Then
                    lblOrderResult.Text = GetLocalResourceObject("ContentText_TransactionFailure")
                    litOrderDetails.Text = strResult
                Else
                    Response.Clear()
                    Response.Write(GetLocalResourceObject("ContentText_TransactionFailure"))
                    Response.Write("<br/><br/>")
                    Response.Write(strResult)
                    Response.Write("<p><a href='" & WebShopURL() & "?strWipeBasket=yes'>" & GetGlobalResourceObject("Kartris", "ContentText_ReturnToHomepage") & "</a></p>")
                    Response.End()
                End If

            End If

            clsPlugin = Nothing
        End If
    End Sub

    Function NeutralizeCurrencyValue(ByVal strInput As String) As String
        strInput = Replace(strInput, ",", "")
        strInput = Replace(strInput, ".", "")
        Return strInput
    End Function
End Class
