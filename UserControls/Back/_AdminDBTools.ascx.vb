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
Imports CkartrisEnumerations
Imports KartSettingsManager

Partial Class UserControls_Back_AdminDBTools

    Inherits System.Web.UI.UserControl

    Protected Sub btnCreateBackup_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCreateBackup.Click
        If Not File.Exists(litBackupName.Text) Then CreateBackup() : Return
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_DBAdmin", "ContentText_BackupAlreadyExists"))
    End Sub

    Protected Sub Back_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnBackFailed.Click, lnkBtnBackSucceeded.Click
        mvwBackup.SetActiveView(viwCreateBackup)
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            litConfigBackupFolder.Text = GetKartConfig("general.backupfolder")
            GetDBInformation()
            CreateBackupName()
            litRootPath.Text = Server.MapPath("../")
        End If
    End Sub

    Private Sub GetDBInformation()
        Dim strMessage As String = String.Empty
        Dim tblDBInfo As New DataTable
        KartrisDBBLL._GetDBInformation(tblDBInfo, strMessage)
        If tblDBInfo.Rows.Count = 0 Then Return
        For Each row As DataRow In tblDBInfo.Rows
            litDBName.Text = row("DatabaseName")
            If CStr(row("FileName")).EndsWith("_log") Then row("FileType") = "LOG FILE" : Continue For
            row("FileType") = "DATA FILE"
        Next
        gvwDBInfo.DataSource = tblDBInfo
        gvwDBInfo.DataBind()
    End Sub

    Private Sub CreateBackupName()
        litBackupName.Text = GetKartConfig("general.backupfolder") & CStr(Now.Year) & "." & CStr(Now.Month) & "." & CStr(Now.Day) & ".bak"
    End Sub

    Private Sub CreateBackup()
        Dim strMessage As String = String.Empty
        If Not KartrisDBBLL._CreateDBBackup(litBackupName.Text, txtBackupDescription.Text, strMessage) Then
            mvwBackup.SetActiveView(viwBackupFailed)
            litBackupFailed.Text = Replace(GetGlobalResourceObject("_DBAdmin", "ContentText_BackupUnsuccessful"), "[filename]", "<span>" & litBackupName.Text & "</span>")
        Else
            If File.Exists(litBackupName.Text) Then
                mvwBackup.SetActiveView(viwBackupSucceeded)
                litBackupSucceeded.Text = Replace(GetGlobalResourceObject("_DBAdmin", "ContentText_BackupSuccessful"), "[filename]", "<span>" & litBackupName.Text & "</span>")
                txtBackupDescription.Text = String.Empty
            Else
                mvwBackup.SetActiveView(viwBackupFailed)
                litBackupFailed.Text = Replace(GetGlobalResourceObject("_DBAdmin", "ContentText_BackupUnsuccessful"), "[filename]", "<span>" & litBackupName.Text & "</span>")
            End If
        End If
        updAdminTools.Update()
    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        CreateBackup()
    End Sub
End Class
