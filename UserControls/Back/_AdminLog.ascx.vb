'========================================================================
'Kartris - www.kartris.com
'Copyright 2021 CACTUSOFT

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
Imports System.Data

Partial Class UserControls_Back_AdminLog
    Inherits System.Web.UI.UserControl

    Public Event AdminLogsUpdated()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then

            txtStartDate.Text = NowOffset.AddDays(-7).Year & "/" & NowOffset.AddDays(-7).Month & "/" & NowOffset.AddDays(-7).Day
            txtEndDate.Text = NowOffset.Year & "/" & NowOffset.Month & "/" & NowOffset.Day

            LoadAdminLogRecords()

            litContentTextAdminLogsPurge1.Text = Replace(GetGlobalResourceObject("_DBAdmin", "ContentText_AdminLogsPurge1"), "[date]", _
                "<strong>" & FormatDate(NowOffset.AddDays(1 - CInt(GetKartConfig("backend.adminlog.purgedays"))), "d", Session("_LANG")) & "</strong>")

        End If
    End Sub

    Private Sub LoadAdminLogRecords()
        Dim tblAdminLog As New DataTable
        tblAdminLog = KartrisDBBLL._SearchAdminLog(txtAdminLogSearchText.Text, ddlAdminLogSearchBy.SelectedValue, _
                                                      CDate(txtStartDate.Text), _
                                                      CDate(txtEndDate.Text))

        If tblAdminLog.Rows.Count = 0 Then mvwAdminLog.SetActiveView(viwAdminLogEmpty) : Return

        gvwAdminLog.DataSource = tblAdminLog
        gvwAdminLog.DataBind()
        mvwAdminLog.SetActiveView(viwAdminLogList)
    End Sub

    Protected Sub btnSearchAdminLog_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSearchAdminLog.Click
        LoadAdminLogRecords()
        txtAdminLogSearchText.Text = "" 'blank search box
    End Sub

    Protected Sub gvwAdminLog_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwAdminLog.PageIndexChanging
        gvwAdminLog.PageIndex = e.NewPageIndex
        LoadAdminLogRecords()
    End Sub

    Protected Sub gvwAdminLog_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwAdminLog.RowCommand
        If e.CommandName = "cmdDetails" Then
            Dim drLogDetails As DataRow = KartrisDBBLL._GetLogByID(CInt(e.CommandArgument))
            If Not drLogDetails Is Nothing Then
                LoadLogDetails(drLogDetails)
            End If
        End If
    End Sub

    Sub LoadLogDetails(ByVal drDetails As DataRow)
        litLogID.Text = FixNullFromDB(drDetails("AL_ID"))
        litLogDateTime.Text = FixNullFromDB(drDetails("AL_DateStamp"))
        litLogUser.Text = FixNullFromDB(drDetails("AL_LoginName"))
        litLogType.Text = FixNullFromDB(drDetails("AL_Type"))
        litLogQuery.Text = Replace(FixNullFromDB(drDetails("AL_Query")), "##", "<br/>&nbsp;&nbsp;&nbsp;&nbsp;")
        litLogDescription.Text = FixNullFromDB(drDetails("AL_Description"))
        litLogRelatedID.Text = FixNullFromDB(drDetails("AL_RelatedID"))
        litLogIP.Text = FixNullFromDB(drDetails("AL_IP"))

        mvwAdminLog.SetActiveView(viwAdminLogDetails)
    End Sub

    Protected Sub lnkBtnBack_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnBack.Click
        mvwAdminLog.SetActiveView(viwAdminLogList)
    End Sub

    Protected Sub btnPurgeOldLogs_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnPurgeOldLogs.Click
        Dim strMessage As String = ""
        If Not KartrisDBBLL._PurgeOldLogs(strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            Return
        End If
        LoadAdminLogRecords()
        RaiseEvent AdminLogsUpdated()
    End Sub
End Class
