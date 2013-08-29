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
                UpdateShippingRate(CInt(e.CommandArgument), _
                                   HandleDecimalValues(CType(e.Item.FindControl("txtHigherOrdersRate"), TextBox).Text), _
                                   CType(e.Item.FindControl("txtGatewaysMain"), TextBox).Text)

            Case "NewRate"
                AddNewShippingRate(HandleDecimalValues(CType(rptRates.Controls(rptRates.Controls.Count - 1).Controls(0).FindControl("txtNewBoundary"), TextBox).Text), _
                                   HandleDecimalValues(CType(rptRates.Controls(rptRates.Controls.Count - 1).Controls(0).FindControl("txtNewRate"), TextBox).Text), _
                                   CType(rptRates.Controls(rptRates.Controls.Count - 1).Controls(0).FindControl("txtGatewaysAdd"), TextBox).Text)

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
        If e.Item.ItemType = ListItemType.AlternatingItem OrElse e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.Footer Then
            'Nothing here at moment...
        End If
    End Sub

    Protected Sub rptRates_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptRates.ItemDataBound
        If e.Item.ItemType = ListItemType.AlternatingItem OrElse e.Item.ItemType = ListItemType.Item Then
            If CDbl(CType(e.Item.FindControl("litBoundary"), Literal).Text) >= 99999 Then
                CType(e.Item.FindControl("phdHighRates"), PlaceHolder).Visible = True
            Else
                CType(e.Item.FindControl("phdNormalRates"), PlaceHolder).Visible = True
            End If
            CType(e.Item.FindControl("litS_ShippingRate"), Literal).Text = _
                _HandleDecimalValues(CType(e.Item.FindControl("litS_ShippingRate"), Literal).Text)
            CType(e.Item.FindControl("txtHigherOrdersRate"), TextBox).Text = _
                _HandleDecimalValues(CType(e.Item.FindControl("txtHigherOrdersRate"), TextBox).Text)

            'tick the shipping gateways checkboxes based on the S_ShippingGateways field
            Dim strShippingGateways As String = Trim(CType(e.Item.FindControl("litS_ShippingGateways"), Literal).Text)

            If Not String.IsNullOrEmpty(strShippingGateways) Then
                CType(e.Item.FindControl("litS_ShippingRate"), Literal).Text = "-"
                CType(e.Item.FindControl("litCUR_ISOCode3"), Literal).Text = "-"
            End If
        ElseIf e.Item.ItemType = ListItemType.Footer Then
            'If we ever needed to do something just to footer rows,
            'it would go here
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

    'Function to make it simple to check
    'if site is using shipping gateways
    Function UseShippingGateways() As Boolean
        Dim strPaymentMethods As String = KartSettingsManager.GetKartConfig("frontend.payment.gatewayslist")
        Dim arrPaymentsMethods As String() = Split(strPaymentMethods, ",")
        Dim blnUseShippingGateways As Boolean = False

        For Each strGatewayEntry As String In arrPaymentsMethods
            Dim arrGateway As String() = Split(strGatewayEntry, "::")
            If UBound(arrGateway) = 4 Then
                If arrGateway(4) = "s" And LCase(arrGateway(1)) = "on" Then
                    blnUseShippingGateways = True
                End If
            End If
        Next
        Return blnUseShippingGateways
    End Function

End Class
