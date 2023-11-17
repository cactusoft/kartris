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
Partial Class UserControls_Skin_LoginStatus
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'Hide support tickets if not activated from config
        If KartSettingsManager.GetKartConfig("frontend.supporttickets.enabled") <> "y" Then
            lnkSupportTickets.Visible = False
        End If

        'Show main login and status links
        If Page.User.Identity.IsAuthenticated Then
            phdLoggedIn.Visible = True
            lnkMyAccount.ToolTip = Page.User.Identity.Name
        Else
            phdLoggedOut.Visible = True
        End If

    End Sub
End Class
