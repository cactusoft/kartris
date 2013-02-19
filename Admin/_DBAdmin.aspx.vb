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

Partial Class Admin_DBAdmin
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Kartris", "BackMenu_DBAdmin") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Me.IsPostBack Then
            'Hide/disable some tabs if not in 'expertmode'
            If KartSettingsManager.GetKartConfig("backend.expertmode") <> "y" Then

                tabMain.Visible = False
                tabMain.HeaderText = ""

                tabDBRemoval.Visible = False
                tabDBRemoval.HeaderText = ""

                tabExecuteQuery.Visible = False
                tabExecuteQuery.HeaderText = ""

                tabDBTools.Visible = False
                tabDBTools.HeaderText = ""

                tabFTS.Visible = False
                tabFTS.HeaderText = ""

            End If

            '' Deleted Items
            CheckDeletedItems()
        End If

    End Sub

    Sub CheckDeletedItems()
        Dim tblDeletedItems As DataTable = KartrisDBBLL._GetDeletedItems()
        If tblDeletedItems.Rows.Count > 0 Then
            phdDeletedItems.Visible = True
        Else
            phdDeletedItems.Visible = False
        End If
        updDeletedItems.Update()
    End Sub

    Protected Sub _UC_AdminLog_AdminLogsUpdated() Handles _UC_AdminLog.AdminLogsUpdated
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub

    Protected Sub _UC_AdminDataRemoval_BackUpData() Handles _UC_AdminDataRemoval.BackUpData
        tabDBAdmin.ActiveTab = tabDBTools
        updMain.Update()
    End Sub

    Public Function SetExpertSetting() As Boolean
        If KartSettingsManager.GetKartConfig("backend.expertmode") <> "y" Then
            Return False
        Else
            Return True
        End If
    End Function

    Protected Sub _UC_AdminExportData_ExportSaved() Handles _UC_AdminExportData.ExportSaved
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub

    Protected Sub lnkBtnDeleteFiles_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDeleteFiles.Click
        KartrisDBBLL.DeleteNotNeededFiles()
        CheckDeletedItems()
    End Sub

    Protected Sub btnRestart_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnRestart.Click
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Kartris", "ContentText_ConfirmRestartKartris"))
    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        If CkartrisBLL.RestartKartrisApplication() Then
            CType(Me.Master, Skins_Admin_Template).DataUpdated()
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_ErrorCantRestartKartris"))
        End If

    End Sub

End Class
