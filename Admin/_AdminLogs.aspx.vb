'========================================================================
'Kartris - www.kartris.com
'Copyright 2017 CACTUSOFT

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

Partial Class Admin_AdminLogs
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_DBAdmin", "ContentText_AdminLogs") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

    End Sub

    Protected Sub _UC_AdminLog_AdminLogsUpdated() Handles _UC_AdminLog.AdminLogsUpdated
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub
End Class
