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
Imports CkartrisEnumerations
Imports CkartrisDataManipulation

Partial Class UserControls_Back_ShippingRates
    Inherits System.Web.UI.UserControl

    Private blnShippingGatewaysEnabled As Boolean = False
    Public Event _UCEvent_DataUpdated()

    Public Sub GetShippingRates(ByVal numShippingMethodID As Byte, ByVal numShippingZoneID As Byte)

        Dim tblShippingRates As New DataTable
        tblShippingRates = ShippingBLL._GetRatesByMethodAndZone(numShippingMethodID, numShippingZoneID)

        If tblShippingRates.Rows.Count = 0 Then Return

        litShippingZoneID.Text = CStr(numShippingZoneID)
        litShippingZoneName.Text = ShippingBLL._GetShippingZoneNameByID(numShippingZoneID, Session("_LANG"))

        litShippingMethodID.Text = CStr(numShippingMethodID)

        If litShippingZoneName.Text = "" Then Return

        rptRates.DataSource = tblShippingRates
        rptRates.DataBind()

        updMain.Update()

    End Sub

    Protected Sub rptRates_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.RepeaterCommandEventArgs) Handles rptRates.ItemCommand
        litShippingIDToDelete.Text = ""
        Dim strGatewaysList As String = ""
        Select Case e.CommandName
            Case "DeleteRate"
                litShippingIDToDelete.Text = CType(e.Item.FindControl("litShippingID"), Literal).Text
                _UC_PopupMsg_Rate.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified"))

            Case "UpdateRate"

                Dim phdHigherOrdersGateways As PlaceHolder = CType(e.Item.FindControl("phdHigherOrderGateways"), PlaceHolder)
                For Each chkGateway As Control In phdHigherOrdersGateways.Controls
                    If InStr(chkGateway.ID, "chkHigherOrder") Then
                        If CType(chkGateway, CheckBox).Checked = True Then
                            If strGatewaysList <> "" Then strGatewaysList += ","
                            strGatewaysList += Mid(chkGateway.ID, 15)
                        End If
                    End If
                Next

                UpdateShippingRate(CByte(e.CommandArgument), _
                                   HandleDecimalValues(CType(e.Item.FindControl("txtHigherOrdersRate"), TextBox).Text), strGatewaysList)

            Case "NewRate"

                Dim phdAddNewGateways As PlaceHolder = CType(e.Item.FindControl("phdAddNewGateways"), PlaceHolder)
                For Each chkGateway As Control In phdAddNewGateways.Controls
                    If InStr(chkGateway.ID, "chkNewOrder") Then
                        If CType(chkGateway, CheckBox).Checked = True Then
                            If strGatewaysList <> "" Then strGatewaysList += ","
                            strGatewaysList += Mid(chkGateway.ID, 12)
                        End If
                    End If
                Next

                AddNewShippingRate(HandleDecimalValues(CType(e.Item.FindControl("txtNewBoundary"), TextBox).Text), _
                                   HandleDecimalValues(CType(e.Item.FindControl("txtNewRate"), TextBox).Text), strGatewaysList)

        End Select
    End Sub

    Private Sub UpdateShippingRate(ByVal numShippingRateID As Integer, ByVal numRate As Single, ByVal strShippingGateways As String)
        Dim strMessage As String = ""
        If Not ShippingBLL._UpdateShippingRate(numShippingRateID, numRate, strShippingGateways, strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            Return
        End If
        RaiseEvent _UCEvent_DataUpdated()
    End Sub

    Private Sub AddNewShippingRate(ByVal numBoundary As Single, ByVal numRate As Single, ByVal strShippingGateways As String)
        Dim strMessage As String = ""
        If Not ShippingBLL._AddNewShippingRate(GetShippingMethodID(), GetShippingZoneID(), numBoundary, numRate, strShippingGateways, strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            Return
        End If
        RaiseEvent _UCEvent_DataUpdated()
    End Sub

    Private Sub DeleteShippingRate(ByVal numShippingRateID As Integer)
        Dim strMessage As String = ""
        If Not ShippingBLL._DeleteShippingRate(numShippingRateID, strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            Return
        End If
        RaiseEvent _UCEvent_DataUpdated()
    End Sub

    Private Sub DeleteZoneRates()
        Dim strMessage As String = ""
        If Not ShippingBLL._DeleteShippingRateByMethodAndZone(CByte(litShippingMethodID.Text), _
                CByte(litShippingZoneID.Text), strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            Return
        End If
        RaiseEvent _UCEvent_DataUpdated()
    End Sub

    Protected Sub rptRates_ItemCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptRates.ItemCreated
        If e.Item.ItemType = ListItemType.AlternatingItem OrElse e.Item.ItemType = ListItemType.Item Then
            'dynamically create the shipping gateways checkboxes
            Dim strPaymentMethods As String = KartSettingsManager.GetKartConfig("frontend.payment.gatewayslist")

            Dim arrPaymentsMethods As String() = Split(strPaymentMethods, ",")
            Try
                For Each strGatewayEntry As String In arrPaymentsMethods
                    Dim arrGateway As String() = Split(strGatewayEntry, "::")
                    If UBound(arrGateway) = 3 Then
                        If arrGateway(3) = "s" And LCase(arrGateway(1)) <> "off" Then
                            Dim chkGateway As New CheckBox
                            chkGateway.ID = "chkHigherOrder" & arrGateway(0)
                            CType(e.Item.FindControl("phdHigherOrderGateways"), PlaceHolder).Controls.Add(chkGateway)
                            Dim chkNew As New CheckBox
                            chkNew.ID = "chkNewOrder" & arrGateway(0)
                            CType(e.Item.FindControl("phdAddNewGateways"), PlaceHolder).Controls.Add(chkNew)

                            Dim lblGateway As Label = New Label()
                            lblGateway.Text = arrGateway(0)
                            lblGateway.ID = "lbl" & arrGateway(0)
                            CType(e.Item.FindControl("phdHigherOrderGateways"), PlaceHolder).Controls.Add(lblGateway)
                            Dim lblNew As New Label
                            lblNew.ID = "lblNew" & arrGateway(0)
                            lblNew.Text = arrGateway(0)
                            CType(e.Item.FindControl("phdAddNewGateways"), PlaceHolder).Controls.Add(lblNew)
                            blnShippingGatewaysEnabled = True
                        End If
                    Else
                        Throw New Exception("Invalid gatewaylist config setting!")
                    End If
                Next
            Catch

            End Try
            If Not blnShippingGatewaysEnabled Then CType(rptRates.Controls(0).Controls(0).FindControl("litShippingGateway"), Literal).Text = ""

        End If
    End Sub

    Protected Sub rptRates_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptRates.ItemDataBound
        If e.Item.ItemType = ListItemType.AlternatingItem OrElse e.Item.ItemType = ListItemType.Item Then
            If CDbl(CType(e.Item.FindControl("litBoundary"), Literal).Text) >= 999999 Then
                CType(e.Item.FindControl("phdHighRates"), PlaceHolder).Visible = True
            Else
                CType(e.Item.FindControl("phdNormalRates"), PlaceHolder).Visible = True
            End If
            CType(e.Item.FindControl("litS_ShippingRate"), Literal).Text = _
                _HandleDecimalValues(CType(e.Item.FindControl("litS_ShippingRate"), Literal).Text)
            CType(e.Item.FindControl("txtHigherOrdersRate"), TextBox).Text = _
                _HandleDecimalValues(CType(e.Item.FindControl("txtHigherOrdersRate"), TextBox).Text)

            If Not blnShippingGatewaysEnabled Then CType(e.Item.FindControl("litS_ShippingGateways"), Literal).Text = ""

            'tick the shipping gateways checkboxes based on the S_ShippingGateways field
            Dim strShippingGateways As String = Trim(CType(e.Item.FindControl("litS_ShippingGateways"), Literal).Text)
            If Not String.IsNullOrEmpty(strShippingGateways) Then
                CType(e.Item.FindControl("litS_ShippingRate"), Literal).Text = "-"
                CType(e.Item.FindControl("litCUR_ISOCode3"), Literal).Text = "-"
                Dim phdHigherOrdersGateways As PlaceHolder = CType(e.Item.FindControl("phdHigherOrderGateways"), PlaceHolder)
                Dim arrGateways As String() = Split(strShippingGateways, ",")
                For x As Integer = 0 To arrGateways.Count - 1
                    For Each chkGateway As Control In phdHigherOrdersGateways.Controls
                        If chkGateway.ID = "chkHigherOrder" & arrGateways(x) Then
                            CType(chkGateway, CheckBox).Checked = True
                        End If
                    Next
                Next
            End If
        End If
    End Sub


    Protected Sub lnkBtnDeleteZone_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDeleteZone.Click
        _UC_PopupMsg_Zone.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified"))
    End Sub

    Protected Sub _UC_PopupMsg_Zone_Confirmed() Handles _UC_PopupMsg_Zone.Confirmed
        DeleteZoneRates()
    End Sub

    Protected Sub _UC_PopupMsg_Rate_Confirmed() Handles _UC_PopupMsg_Rate.Confirmed
        If litShippingIDToDelete.Text <> "" Then DeleteShippingRate(CInt(litShippingIDToDelete.Text))
    End Sub

    Private Function GetShippingMethodID() As Byte
        If Not litShippingMethodID.Text Is Nothing Then
            Return CByte(litShippingMethodID.Text)
        End If
        Return 0
    End Function

    Private Function GetShippingZoneID() As Byte
        If Not litShippingZoneID.Text Is Nothing Then
            Return CByte(litShippingZoneID.Text)
        End If
        Return 0
    End Function

    Private Sub ClearRates()
        litShippingMethodID.Text = Nothing
        litShippingZoneID.Text = Nothing
        litShippingZoneName.Text = Nothing
        litShippingIDToDelete.Text = Nothing

        rptRates.DataSource = Nothing
        rptRates.DataBind()
    End Sub

    'Nice way to handle alternate style for row without duplication
    'of using alternating template
    Public Function GetRowClass(ByVal numRowIndex As Integer) As String
        Dim rowAlt As Boolean = (numRowIndex / 2 = System.Math.Round(numRowIndex / 2, 0))

        If rowAlt Then
            Return ""
        Else
            Return "Kartris-GridView-Alternate"
        End If

    End Function

    'Convenient way to format currency (e.g. 0.00) 
    Function FormatAsCurrency(ByVal numValue As Double) As String
        Return CurrenciesBLL.FormatCurrencyPrice(HttpContext.Current.Session("CUR_ID"), numValue, False)
    End Function

End Class
