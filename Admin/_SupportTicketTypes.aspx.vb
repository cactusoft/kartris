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
Imports CkartrisDataManipulation
Imports CkartrisDisplayFunctions
Imports CkartrisEnumerations
Imports KartSettingsManager

Partial Class Admin_SupportTicketTypes

    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Tickets", "PageTitle_SupportTicketTypes") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Page.IsPostBack Then
            'Set number of records per page
            Dim intRowsPerPage As Integer = 25
            Try
                intRowsPerPage = CType(KartSettingsManager.GetKartConfig("backend.display.pagesize"), Double)
            Catch ex As Exception
                'Stays at 25
            End Try
            gvwTicketTypes.PageSize = intRowsPerPage

            If KartSettingsManager.GetKartConfig("frontend.supporttickets.enabled") <> "y" Then
                litFeatureDisabled.Text = Replace( _
                    GetGlobalResourceObject("_Kartris", "ContentText_DisabledInFrontEnd"), "[name]", _
                    GetGlobalResourceObject("_Tickets", "PageTitle_SupportTickets"))
                phdFeatureDisabled.Visible = True
            Else
                phdFeatureDisabled.Visible = False
            End If

            LoadSupportTicketTypes()
        End If
    End Sub

    Sub LoadSupportTicketTypes()
        Dim tblSupportTicketTypes As DataTable = TicketsBLL._GetTicketTypes()

        If tblSupportTicketTypes.Rows.Count = 0 Then
            gvwTicketTypes.DataSource = Nothing
            gvwTicketTypes.DataBind()
            gvwTicketTypes.Visible = False
            pnlNoTypes.Visible = True
            updTypes.Update()
            Return
        Else
            pnlNoTypes.Visible = False
        End If

        gvwTicketTypes.Visible = True
        gvwTicketTypes.DataSource = tblSupportTicketTypes
        gvwTicketTypes.DataBind()

        mvwTypes.SetActiveView(viwTypes)
        updMain.Update()
    End Sub

    Protected Sub gvwTicketTypes_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwTicketTypes.PageIndexChanging
        gvwTicketTypes.PageIndex = e.NewPageIndex
        LoadSupportTicketTypes()
    End Sub

    Protected Sub gvwTicketTypes_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwTicketTypes.RowCommand
        If e.CommandName = "edit_type" Then
            PrepareExistingSupportType(e.CommandArgument)

        End If
    End Sub

    Protected Sub gvwTicketTypes_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwTicketTypes.RowDataBound
        If e.Row.RowType = DataControlRowType.DataRow Then
            If CType(e.Row.Cells(1).FindControl("litSupportLevel"), Literal).Text = "p" Then
                If e.Row.RowState = DataControlRowState.Alternate Then
                    e.Row.CssClass = "Kartris-GridView-Alternate-Red"
                Else
                    e.Row.CssClass = "Kartris-GridView-Red"
                End If
            End If
        End If
    End Sub

    Protected Sub lnkBtnShowTypesList_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnShowTypesList.Click
        mvwTypes.SetActiveView(viwTypes)
        updMain.Update()
    End Sub

    Protected Sub lnkBtnNewType_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnNewType.Click
        PrepareNewSupportType()
    End Sub

    Sub PrepareNewSupportType()
        litTypeID.Text = "0"
        txtSupportType.Text = Nothing
        litSupportType.Text = Nothing
        ddlSupportLevel.SelectedIndex = 0
        phdDelete.Visible = False
        mvwTypes.SetActiveView(viwEditType)
        updMain.Update()
    End Sub

    Sub PrepareExistingSupportType(ByVal numTypeID As Integer)
        Dim tblTypes As DataTable = TicketsBLL._GetTicketTypes()
        Dim drwSupportType() As DataRow = tblTypes.Select("STT_ID=" & numTypeID)
        If drwSupportType.Length <> 1 Then Exit Sub
        litTypeID.Text = numTypeID
        txtSupportType.Text = FixNullFromDB(drwSupportType(0)("STT_Name"))
        litSupportType.Text = FixNullFromDB(drwSupportType(0)("STT_Name"))

        'If tickets from before types have changed, this might fail,
        'so put in a try/catch loop for safety
        Try
            ddlSupportLevel.SelectedValue = FixNullFromDB(drwSupportType(0)("STT_Level"))
        Catch ex As Exception

        End Try

        Dim dvwTypes As DataView = tblTypes.DefaultView
        dvwTypes.RowFilter = "STT_ID <> " & numTypeID
        ddlTicketType.DataTextField = "STT_Name"
        ddlTicketType.DataValueField = "STT_ID"
        ddlTicketType.DataSource = dvwTypes
        ddlTicketType.DataBind()
        phdDelete.Visible = True
        mvwTypes.SetActiveView(viwEditType)
        updMain.Update()
    End Sub

    Function GetTypeID() As Integer
        If litTypeID.Text <> "" Then
            Return CLng(litTypeID.Text)
        End If
        Return 0
    End Function

    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.Click
        If SaveChanges() Then
            LoadSupportTicketTypes()
            CType(Me.Master, Skins_Admin_Template).DataUpdated()
        End If
    End Sub

    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancel.Click
        mvwTypes.SetActiveView(viwTypes)
        updMain.Update()
    End Sub

    Protected Sub lnkBtnDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDelete.Click
        Dim strMessage As String = Replace(GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItem"), "[itemname]", _
                                        litSupportType.Text)
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, strMessage)
    End Sub

    Public Function SaveChanges() As Boolean

        If (GetTypeID() = 0) Then
            If Not SaveType(DML_OPERATION.INSERT) Then Return False
        Else
            If Not SaveType(DML_OPERATION.UPDATE) Then Return False
        End If

        Return True

    End Function

    Private Function SaveType(ByVal enumOperation As DML_OPERATION) As Boolean

        Dim strTypeName As String = txtSupportType.Text
        Dim chrTypeLevel As Char = ddlSupportLevel.SelectedValue
        Dim strMessage As String = ""
        Dim numTypeID As Long = GetTypeID()
        Select Case enumOperation
            Case DML_OPERATION.UPDATE
                If Not TicketsBLL._UpdateTicketType(numTypeID, strTypeName, chrTypeLevel, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
            Case DML_OPERATION.INSERT
                If Not TicketsBLL._AddTicketType(strTypeName, chrTypeLevel, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
        End Select

        Return True

    End Function

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        Dim strMessage As String = ""
        If TicketsBLL._DeleteTicketType(GetTypeID(), ddlTicketType.SelectedValue, strMessage) Then
            LoadSupportTicketTypes()
            CType(Me.Master, Skins_Admin_Template).DataUpdated()
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        End If
    End Sub

End Class
