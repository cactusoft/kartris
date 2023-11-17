'========================================================================
'Kartris - www.kartris.com
'Copyright 2023 CACTUSOFT

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

Partial Class Admin_Home
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim arrAuth As String() = HttpSecureCookie.Decrypt(Session("Back_Auth"))

        'Show stats graphs
        phdOrderStats.Visible = (CBool(arrAuth(3)) Or CBool(arrAuth(1))) And KartSettingsManager.GetKartConfig("backend.homepage.graphs") <> "OFF"

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
