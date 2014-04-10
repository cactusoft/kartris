'========================================================================
'Kartris - www.kartris.com
'Copyright 2014 CACTUSOFT INTERNATIONAL FZ LLC

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class Customer_Account
    Inherits PageBaseClass

    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Me.Load

        'Don't show this page if user already logged in, go to the customer home page
        If Not Page.IsPostBack Then
            If LCase(KartSettingsManager.GetKartConfig("frontend.users.access")) = "yes" Then litMustBeLoggedIn.Visible = True
            If User.Identity.IsAuthenticated Then Response.Redirect("~/Customer.aspx?action=home")
        End If

    End Sub

End Class
