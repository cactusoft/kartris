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
Imports KartSettingsManager

''' <summary>
''' IframeCSS creates links to the skin's CSS files for
''' pages that don't use the skin's master page. In
''' particular, the Large Image popup iframe, and the
''' Media Gallery iframe. Simple put this control in
''' the head section, and it automatically finds all
''' .css files in the current skin folder and links
''' to them.
''' </summary>
''' <remarks>By Paul</remarks>
Partial Class _NoMasterCSS
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Dim Include As New HtmlGenericControl("link")
        Include.Attributes.Add("type", "text/css")
        Include.Attributes.Add("rel", "stylesheet")
        Include.Attributes.Add("href", CkartrisBLL.WebShopURL & "Skins/Admin/general.css")
        phdNoMasterCSS.Controls.Add(Include)

        Dim Include2 As New HtmlGenericControl("link")
        Include2.Attributes.Add("type", "text/css")
        Include2.Attributes.Add("rel", "stylesheet")
        Include2.Attributes.Add("href", CkartrisBLL.WebShopURL & "Skins/Admin/sections.css")
        phdNoMasterCSS.Controls.Add(Include2)
    End Sub

End Class
