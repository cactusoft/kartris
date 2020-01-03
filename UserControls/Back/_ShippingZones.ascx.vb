'========================================================================
'Kartris - www.kartris.com
'Copyright 2020 CACTUSOFT

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
Partial Class UserControls_Back_ShippingZones
    Inherits System.Web.UI.UserControl

    Public Event UpdateSaved()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        valRequiredOrderBy.ValidationGroup = LANG_ELEM_TABLE_TYPE.ShippingZones
        valCompareOrderBy.ValidationGroup = LANG_ELEM_TABLE_TYPE.ShippingZones
        valSummary.ValidationGroup = LANG_ELEM_TABLE_TYPE.ShippingZones
        lnkBtnSaveShippingZone.ValidationGroup = LANG_ELEM_TABLE_TYPE.ShippingZones

        If Not Page.IsPostBack Then
            LoadShippingZones()
        End If

        If GetShippingZoneID() = 0 Then
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.ShippingZones, True)
        Else
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.ShippingZones, False, GetShippingZoneID())
        End If

    End Sub

    Private Sub LoadShippingZones()

        Dim tblShippingZones As New DataTable
        tblShippingZones = ShippingBLL._GetShippingZonesByLanguage(Session("_LANG"))

        gvwShippingZones.DataSource = tblShippingZones
        gvwShippingZones.DataBind()

        updShippingZonesList.Update()

    End Sub

    Private Sub LoadShippingZoneInformation()

        _UC_LangContainer.CreateLanguageStrings( _
                LANG_ELEM_TABLE_TYPE.ShippingZones, False, GetShippingZoneID())
        '' The following line .. read the value of "litOrderBy" which holds the value of the 
        ''      'SZ_OrderByValue' field .. to reduce the db calls
        txtOrderBy.Text = CType(gvwShippingZones.SelectedRow.Cells(0).FindControl("litOrderBy"), Literal).Text
        chkShippingZoneLive.Checked = CType(gvwShippingZones.SelectedRow.Cells(1).FindControl("chkLive"), CheckBox).Checked

        litShippingZoneNameInfo.Text = ShippingBLL._GetShippingZoneNameByID(GetShippingZoneID(), Session("_LANG"))

        lnkBtnDeleteShippingZone.Visible = True
        ddlAssignedZone.Items.Clear()
        '' Assign Zone
        If ShippingBLL._GetTotalDestinationsByZone(GetShippingZoneID()) > 0 Then
            Dim tblShippingZones As New DataTable
            tblShippingZones = ShippingBLL._GetShippingZonesByLanguage(Session("_LANG"))
            Dim dvwShippingZones As DataView = tblShippingZones.DefaultView
            dvwShippingZones.RowFilter = "SZ_ID <> " & GetShippingZoneID()
            ddlAssignedZone.DataSource = dvwShippingZones
            ddlAssignedZone.DataBind()
            phdAssignToZone.Visible = True
            phdList.Visible = False
        Else
            phdAssignToZone.Visible = False
        End If


    End Sub

    Private Function GetShippingZoneID() As Byte
        If IsNumeric(litShippingZoneID.Text) Then
            Return CByte(litShippingZoneID.Text)
        End If
        litShippingZoneID.Text = "0"
        Return 0
    End Function

    Protected Sub gvwShippingZones_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwShippingZones.RowCommand
        Try
            gvwShippingZones.SelectedIndex = CInt(e.CommandArgument)
        Catch ex As Exception
            Return
        End Try
        Select Case e.CommandName
            Case "EditShippingZone"
                mvwShippingZones.SetActiveView(viwShippingZoneInfo)
                litShippingZoneID.Text = gvwShippingZones.SelectedValue()
                LoadShippingZoneInformation()
                updShippingZoneDetails.Update()
                phdList.Visible = False
            Case "ShowDestinations"
                mvwShippingZones.SetActiveView(viwShippingZoneDestinations)
                litShippingZoneID.Text = gvwShippingZones.SelectedValue()
                litShippingZoneNameDestinations.Text = ShippingBLL._GetShippingZoneNameByID(GetShippingZoneID(), Session("_LANG"))
                LoadZoneDestinations()
                updShippingZoneDetails.Update()
                phdList.Visible = False
            Case ""

        End Select
    End Sub

    Private Sub LoadZoneDestinations()
        _UC_ZoneDestinations.GetZoneDestinations(GetShippingZoneID())
        phdList.Visible = False
    End Sub

    Private Sub PrepareNewShippingZone()
        litShippingZoneID.Text = "0"
        litShippingZoneNameInfo.Text = GetGlobalResourceObject("_Shipping", "ContentText_NewShippingZone")
        _UC_LangContainer.CreateLanguageStrings( _
                LANG_ELEM_TABLE_TYPE.ShippingZones, True)
        txtOrderBy.Text = "0"
        chkShippingZoneLive.Checked = False

        lnkBtnDeleteShippingZone.Visible = False
        phdAssignToZone.Visible = False
        phdList.Visible = False

        mvwShippingZones.SetActiveView(viwShippingZoneInfo)
        updShippingZoneDetails.Update()
    End Sub

    Protected Sub lnkAddNewShippingZone_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkAddNewShippingZone.Click
        PrepareNewShippingZone()
    End Sub

    Private Sub BackToShippingZoneList()
        litShippingZoneID.Text = ""
        mvwShippingZones.SetActiveView(viwShippingZoneEmpty)
        phdList.Visible = True
        updShippingZonesList.Update()
        updShippingZoneDetails.Update()
    End Sub

    Private Sub DataChanged()
        LoadShippingZones()
        BackToShippingZoneList()
        RaiseEvent UpdateSaved()
    End Sub

    Protected Sub _UC_ZoneDestinations__UCEvent_DataUpdated() Handles _UC_ZoneDestinations._UCEvent_DataUpdated
        LoadShippingZones()
        RaiseEvent UpdateSaved()
    End Sub

    Protected Sub lnkBack_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBack.Click
        BackToShippingZoneList()
    End Sub

    Protected Sub lnkBack2_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBack2.Click
        BackToShippingZoneList()
    End Sub

    Private Function SaveChanges() As Boolean
        If GetShippingZoneID() = 0 Then
            '' if new => INSERT
            If Not SaveShippingZone(DML_OPERATION.INSERT) Then Return False
        Else
            '' if update => UPDATE
            If Not SaveShippingZone(DML_OPERATION.UPDATE) Then Return False
        End If

        Return True
    End Function

    Private Function SaveShippingZone(ByVal enumOperation As DML_OPERATION) As Boolean
        Dim tblLanguageContetns As New DataTable
        tblLanguageContetns = _UC_LangContainer.ReadContent()

        Dim blnLive As Boolean = chkShippingZoneLive.Checked
        Dim numOrderBy As Byte = CByte(txtOrderBy.Text)

        Dim strMessage As String = ""
        Select Case enumOperation
            Case DML_OPERATION.INSERT
                If Not ShippingBLL._AddNewShippingZone(tblLanguageContetns, blnLive, numOrderBy, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
            Case DML_OPERATION.UPDATE
                If Not ShippingBLL._UpdateShippingZone(tblLanguageContetns, GetShippingZoneID(), blnLive, numOrderBy, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
        End Select

        Return True
    End Function

    Protected Sub lnkBtnCancelShippingZone_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancelShippingZone.Click
        BackToShippingZoneList()
    End Sub

    Protected Sub lnkBtnSaveShippingZone_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSaveShippingZone.Click
        If SaveChanges() Then
            DataChanged()
        End If
    End Sub

    Protected Sub lnkBtnDeleteShippingZone_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDeleteShippingZone.Click
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified"))
    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        Dim strMessage As String = ""
        Dim numAssigenedZone As Byte = 0

        If ddlAssignedZone.Items.Count > 0 Then numAssigenedZone = CByte(ddlAssignedZone.SelectedValue())

        If ShippingBLL._DeleteShippingZone(GetShippingZoneID(), numAssigenedZone, strMessage) Then
            DataChanged()
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        End If


    End Sub

End Class
