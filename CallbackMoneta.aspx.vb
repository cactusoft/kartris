Imports CkartrisBLL
Imports CkartrisDataManipulation
Imports KartSettingsManager

Partial Class CallbackMoneta
    'Inherits PageBaseClass
    Inherits System.Web.UI.Page
    'Private clsPlugin As Kartris.Interfaces.PaymentGateway

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim urlxMoneta As String = ""
        Dim params As New Dictionary(Of String, String)
        'Dim paymentid As String = Request("paymentid")
        'Dim result As String = Request("result")
        'string authorizationcode = Request["authorizationcode"];
        'string rrn = Request["rrn"];
        ' Dim merchantorderid As String = Request("merchantorderid")
        'string responsecode = Request["responsecode"];
        'string securitytoken = Request["securitytoken"];
        'string threedsecure = Request["threedsecure"];
        'string maskedpan = Request["maskedpan"];
        'string cardcountry = Request["cardcountry"];
        'string customfield = Request["customfield"];

        MLog("MCB in")
        If Not IsPostBack Then
            Dim strCallbackError As String = ""
            Dim strResult As String = ""
            Dim strBodyText As String = ""
            Dim blnFullDisplay As Boolean = False
            'If Request.QueryString("d") = "off" Then blnFullDisplay = False
            Dim strGatewayName As String = StrConv(Request.QueryString("g"), vbProperCase)
            'Dim clsPlugin As Kartris.Interfaces.PaymentGateway = Nothing

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

                'Loop through incoming fields if form post to this page
                For Each fldName In Request.Form
                    If Not String.IsNullOrEmpty(strResult) Then strResult += ":-:"
                    strResult += "FF_" & fldName & ":*:" & Request.Form(fldName)
                    params.Add(fldName, Request.Form(fldName))
                Next

                'Load in the payment gateway in question
                'This is why it is important that the name is
                'passed correctly when setting up the callback.aspx
                'clsPlugin = Payment.PPLoader(strGatewayName)


                'Process the callback and append to the result
                'MLog("MCB chiamo DLL")
                'strResult = clsPlugin.ProcessCallback(strResult, strReferrerURL)
                MLog("MCB fine chiamata DLL: " & strResult)
                MLog("###" & params.Item("result"))

                '-----------------------------------------------------
                'CALLBACK SUCCESSFUL
                'Lookup order to being processing it
                '-----------------------------------------------------
                'If clsPlugin.CallbackSuccessful Then
                If params.Item("result") = "APPROVED" Or params.Item("result") = "AUTHORISED" Then

                    Dim O_ID As Integer = params.Item("merchantorderid") 'clsPlugin.CallbackOrderID
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
                    MLog("err1= " & strCallbackError)
                    '-----------------------------------------------------
                    'NO ERRORS
                    'Proceed to process order and despatch confirmation
                    '-----------------------------------------------------
                    If String.IsNullOrEmpty(strCallbackError) Then

                        'If Math.Round(clsPlugin.CallbackOrderAmount, 2) = Math.Round(O_TotalPriceGateway, 2) OrElse
                        'NeutralizeCurrencyValue(Math.Round(clsPlugin.CallbackOrderAmount, 2).ToString) = NeutralizeCurrencyValue(Math.Round(O_TotalPriceGateway, 2).ToString) OrElse
                        'intCallbackStep = 2 Then
                        If Math.Round(CDbl(params.Item("customfield")), 2) = Math.Round(O_TotalPriceGateway, 2) OrElse
                        NeutralizeCurrencyValue(params.Item("customfield").ToString) = NeutralizeCurrencyValue(Math.Round(O_TotalPriceGateway, 2).ToString) OrElse
                        intCallbackStep = 2 Then
                            MLog("gli importi coincidono")
                            If intCallbackStep <> 2 Then
                                Dim blnCheckInvoicedOnPayment As Boolean = GetKartConfig("frontend.orders.checkinvoicedonpayment") = "y"
                                Dim blnCheckReceivedOnPayment As Boolean = GetKartConfig("frontend.orders.checkreceivedonpayment") = "y"

                                '-----------------------------------------------------
                                'UPDATE ORDER STATUS
                                'Set invoiced and received checkboxes, depending on
                                'config settings
                                '-----------------------------------------------------
                                'Dim intUpdateResult As Integer = OrdersBLL.CallbackUpdate(O_ID, clsPlugin.CallbackReferenceCode, CkartrisDisplayFunctions.NowOffset, True,
                                'blnCheckInvoicedOnPayment,
                                'blnCheckReceivedOnPayment,
                                'GetGlobalResourceObject("Email", "EmailText_OrderTime") & " " & CkartrisDisplayFunctions.NowOffset,
                                'O_CouponCode, O_WLID, O_CustomerID, O_CurrencyIDGateway, clsPlugin.GatewayName, O_TotalPriceGateway)
                                Dim intUpdateResult As Integer = OrdersBLL.CallbackUpdate(O_ID, params.Item("paymentid"), CkartrisDisplayFunctions.NowOffset, True,
                                                                                      blnCheckInvoicedOnPayment,
                                                                                      blnCheckReceivedOnPayment,
                                                                                      GetGlobalResourceObject("Email", "EmailText_OrderTime") & " " & CkartrisDisplayFunctions.NowOffset,
                                                                                      O_CouponCode, O_WLID, O_CustomerID, O_CurrencyIDGateway, strGatewayName, O_TotalPriceGateway)


                                MLog("aggiornato ordine")
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
                                    strCustomerEmailText = GetGlobalResourceObject("Email", "EmailText_OrderReceived") & vbCrLf & vbCrLf &
                                    GetGlobalResourceObject("Kartris", "ContentText_OrderNumber") & ": " & O_ID & vbCrLf & vbCrLf &
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
                                MLog("inviata mail al cliente")
                                '-----------------------------------------------------
                                'SEND CONFIRMATION EMAIL
                                'To store owner
                                '-----------------------------------------------------
                                If KartSettingsManager.GetKartConfig("frontend.orders.emailmerchant") <> "n" Then
                                    If Not blnUseHTMLOrderEmail Then
                                        strStoreEmailText = GetGlobalResourceObject("Email", "EmailText_StoreEmailHeader") & vbCrLf & vbCrLf &
                               GetGlobalResourceObject("Kartris", "ContentText_OrderNumber") & ": " & O_ID & vbCrLf & vbCrLf & strBodyText
                                    Else
                                        strStoreEmailText = strBodyText.Replace("[storeowneremailheader]", GetGlobalResourceObject("Email", "EmailText_StoreEmailHeader"))
                                    End If

                                    SendEmail(strFromEmail, LanguagesBLL.GetEmailTo(1), GetGlobalResourceObject("Email", "Config_Subjectline2") & " (#" & O_ID & ")", strStoreEmailText, , , , , blnUseHTMLOrderEmail)
                                End If
                                MLog("inviata mail ad admin")
                                'Send an order notification to Windows Store App if enabled
                                PushKartrisNotification("o")
                            Else
                                strBodyText = strBodyText.Replace("[orderid]", O_ID)
                                'we're in the callback page so obviously po_offline/bitcoin method is not being used
                                strBodyText = strBodyText.Replace("[poofflinepaymentdetails]", "")
                                strBodyText = strBodyText.Replace("[bitcoinpaymentdetails]", "")

                            End If

                            'Try
                            '    'This handles setting the order and customer ID
                            '    'for Google Analytics tracking
                            '    UC_EcommerceTracking.OrderID = O_ID
                            '    UC_EcommerceTracking.UserID = CurrentLoggedUser.ID
                            'Catch ex As Exception
                            '    'If that errors for some reason, turn off
                            '    'the ecommerce tracking
                            '    UC_EcommerceTracking.Visible = False
                            'End Try

                        Else
                            'The amount we recorded for the order, and the
                            'confirmation of the amount paid at the gateway
                            'do not match. This could indicate tampering, i.e.
                            'someone pays an order but has edited the amount
                            'down prior to going off to the gateway. Most
                            'gateways have some kind of defence against this,
                            'but it is a good check to make if we can get the
                            'amount back from the gateway.
                            strCallbackError = "Callback Failure: " & vbCrLf & "Order ID: " & O_ID & "- Order Amount doesn't match. " & vbCrLf &
                                    "Order Value in DB: " & Math.Round(O_TotalPriceGateway, 2) & vbCrLf &
                                    "  Order Value from Gateway: " & params.Item("customfield") & vbCrLf &
                                    "  Ref: " & params.Item("paymentid")
                            MLog("importi ordine non coincidono; err2" & strCallbackError)
                        End If
                    End If
                Else
                    'Record error
                    strCallbackError = "Callback Failure: " & strResult & vbCrLf '& clsPlugin.CallbackMessage &
                    strCallbackError &= vbCrLf & "FF: " & Request.Form.ToString & vbCrLf & "QS: " & Request.QueryString.ToString
                    'strCallbackError = "Callback Failure: " & strResult & vbCrLf & params.Item("errormessage") &
                    'vbCrLf & "FF: " & Request.Form.ToString & vbCrLf & "QS: " & Request.QueryString.ToString
                    MLog("err3" & strCallbackError)
                End If

            Else
                'No gateway name passed with callback, log error
                strCallbackError = "Callback Failure: Gateway name not specified. " &
                                        vbCrLf & "FF: " & Request.Form.ToString & vbCrLf & "QS: " & Request.QueryString.ToString
                MLog("err4" & strCallbackError)
            End If


            'If there was no error then...
            If String.IsNullOrEmpty(strCallbackError) Then
                MLog("CBM - rilevato nessun errore")
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
                    'CkartrisFormatErrors.LogError("Successful Callback Log (frontend.payment.debugmode.enabled=y): " & clsPlugin.CallbackMessage & vbCrLf & "FF: " &
                    'Request.Form.ToString & vbCrLf & "QS: " & Request.QueryString.ToString)
                    CkartrisFormatErrors.LogError("Successful Callback Log (frontend.payment.debugmode.enabled=y): " & vbCrLf & "FF: " &
                                                  Request.Form.ToString & vbCrLf & "QS: " & Request.QueryString.ToString)
                End If

                Dim BasketObject As BasketBLL = New BasketBLL
                BasketObject.DeleteBasket()
                Session("Basket") = Nothing

                urlxMoneta = WebShopURL() & "checkoutincomplete.aspx"

                params.Add("strWipeBasket", "yes")
            Else
                'Log the error
                CkartrisFormatErrors.LogError(strCallbackError)
                urlxMoneta = WebShopURL() & "checkoutincomplete.aspx"
                params.Add("strWipeBasket", "no")
            End If
            MLog("MCB - urlxMoneta: " & urlxMoneta)
            'clsPlugin = Nothing
        End If

        Dim urlfinale As String = urlxMoneta & "?strWipeBasket=" & params.Item("strWipeBasket") & "&result=" & params.Item("result")
        MLog("MCB scrivo " & urlfinale)

        Response.Write(urlfinale)
        Response.End()
    End Sub

    Function NeutralizeCurrencyValue(ByVal strInput As String) As String
        strInput = Replace(strInput, ",", "")
        strInput = Replace(strInput, ".", "")
        strInput = strInput.TrimStart(New [Char]() {"0"c})
        Return strInput
    End Function

    Public Shared Sub MLog(logMessage As String)
        Dim logpath As String = HttpRuntime.AppDomainAppPath & "Log.txt"
        Using w As StreamWriter = File.AppendText(logpath)
            w.Write(vbCrLf + "{0} {1}: {2}", DateTime.Now.ToString("dd/MM/yyyy"), DateTime.Now.ToLongTimeString(), logMessage)
            'w.WriteLine("  :{0}", logMessage)
            w.WriteLine("-------------------------------")
        End Using
    End Sub

End Class
