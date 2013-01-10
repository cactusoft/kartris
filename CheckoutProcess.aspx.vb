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
Partial Class checkout_process
    Inherits System.Web.UI.Page
    Private clsPlugin As Kartris.Interfaces.PaymentGateway
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim strOutput As String = ""
        Dim strGatewayStatus As String = ""
        Dim strGatewayName As String = ""
        If Session("_CallBackMessage") IsNot Nothing And Session("_PostBackURL") IsNot Nothing Then
            strOutput = Session("_CallBackMessage")
            btnSubmit.PostBackUrl = Session("_PostBackURL")
        Else
            Dim BasketObject As BasketBLL = DirectCast(Session("BasketObject"), BasketBLL)
            strGatewayName = Session("GateWayName")
            Dim clsPlugin As Kartris.Interfaces.PaymentGateway
            clsPlugin = Payment.PPLoader(strGatewayName)
            Dim GatewayBasketBLL As New BasketBLL
            Dim BasketXML As String
            If clsPlugin.RequiresBasketItems Then
                Dim intGatewayCurrencyID As Integer = 0
                If Not (String.IsNullOrEmpty(clsPlugin.Currency) Or String.IsNullOrWhiteSpace(clsPlugin.Currency)) Then
                    intGatewayCurrencyID = CurrenciesBLL.CurrencyID(clsPlugin.Currency)
                End If
                If intGatewayCurrencyID > 0 AndAlso intGatewayCurrencyID <> CInt(Session("CUR_ID")) Then
                    With GatewayBasketBLL
                        'Retrieve Basket Items from Session
                        .CurrencyID = intGatewayCurrencyID
                        .LoadBasketItems()
                        .Validate(False)
                        .CalculateTotals()
                    End With
                Else
                    GatewayBasketBLL = BasketObject
                End If

                BasketXML = Payment.Serialize(GatewayBasketBLL)
            Else
                BasketXML = Nothing
            End If

            strOutput = clsPlugin.ProcessOrder(Session("objOrder"), BasketXML)
            btnSubmit.PostBackUrl = clsPlugin.PostbackURL
            strGatewayStatus = clsPlugin.Status
            clsPlugin = Nothing
        End If

        Select Case LCase(strGatewayStatus)
            Case "test"
                litGatewayTestForwarding.Text = GetLocalResourceObject("ContentText_GatewayTestForwarding")
                litGatewayTestForwarding.Visible = True
            Case "fake"
                litGatewayTestForwarding.Text = GetLocalResourceObject("ContentText_GatewayFake")
                litGatewayTestForwarding.Visible = True
            Case Else
                litGatewayTestForwarding.Visible = False
                Dim strScript As String = String.Format("document.getElementById('{0}').disabled = true;", btnSubmit.ClientID)
                Page.ClientScript.RegisterOnSubmitStatement(Page.GetType(), "disabledSubmitButton", strScript)
                Page.ClientScript.RegisterStartupScript(Page.GetType(), "Submit", String.Format("document.getElementById('{0}').click();", btnSubmit.ClientID), True)
                btnSubmit.Text = GetGlobalResourceObject("Basket", "ContentText_PleaseWait") '"Redirecting to payment gateway.*"
        End Select


        GateWayPanel.Visible = True
        'modify submit button's properties
        btnSubmit.UseSubmitBehavior = True
        MainPanel.Visible = False
        Page.Title = GetGlobalResourceObject("Basket", "FormButton_Checkout") & " | " & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))

        Session("objOrder") = Nothing
        Session("BasketObject") = Nothing

        If Not String.IsNullOrEmpty(strOutput) Then

            Dim arrOutput() As String = Split(strOutput, ":-:")
            Dim arrPair() As String

            If arrOutput IsNot Nothing AndAlso arrOutput.Count = 1 AndAlso InStr(arrOutput(0).ToString, ":*:") = 0 Then
                CkartrisFormatErrors.LogError("Can't process plugin output file - " & strGatewayName & " output:" & strOutput)
            End If

            For Each strPair In arrOutput
                arrPair = Split(strPair, ":*:")
                If UBound(arrPair) > 0 Then
                    If UCase(arrPair(0)) = "FORM_NAME" Then
                        Page.Form.Name = arrPair(1)
                    Else
                        If LCase(strGatewayStatus) = "fake" Then
                            With GateWayPanel.Controls
                                Dim litLineStart As New Literal
                                litLineStart.Text = "<li><span class=""Kartris-DetailsView-Name"">"
                                .Add(litLineStart)

                                Dim lblControl As Label = New Label
                                lblControl.Text = arrPair(0) & ": "
                                .Add(lblControl)

                                'Middle of line
                                Dim litLineMiddle As New Literal
                                litLineMiddle.Text = "</span><span class=""Kartris-DetailsView-Value"">"
                                .Add(litLineMiddle)

                                Dim txtControl As TextBox = New TextBox
                                txtControl.ID = arrPair(0)
                                txtControl.Text = arrPair(1)
                                .Add(txtControl)

                                'End of line
                                Dim litLineEnd As New Literal
                                litLineEnd.Text = "</span></li>"
                                .Add(litLineEnd)
                            End With
                        Else
                            Dim hfPair As HiddenField = New HiddenField
                            Kartris.Interfaces.Utils.SetHF(hfPair, arrPair(0), arrPair(1))
                            GateWayPanel.Controls.Add(hfPair)
                        End If
                    End If
                End If
            Next
        End If
    End Sub

End Class
