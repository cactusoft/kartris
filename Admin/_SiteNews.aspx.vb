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
Partial Class Admin_SiteNews
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_News", "PageTitle_FrontNewsItems") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Page.IsPostBack Then
            If KartSettingsManager.GetKartConfig("frontend.navigationmenu.sitenews") <> "y" Then
                litFeatureDisabled.Text = Replace( _
                    GetGlobalResourceObject("_Kartris", "ContentText_DisabledInFrontEnd"), "[name]", _
                    GetGlobalResourceObject("_News", "PageTitle_FrontNewsItems"))
                phdFeatureDisabled.Visible = True
            Else
                phdFeatureDisabled.Visible = False
            End If
        End If
    End Sub
End Class
