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
Partial Class IframeCSS
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'We'll try to put a skin in place, if one exists
        Try
            'Set the skin folder
            Dim strSkin As String = Server.MapPath("~/Skins/" & CkartrisBLL.Skin(Session("LANG")))

            'We will use this later
            Dim strFileName = ""

            'Find files in this folder
            If Directory.Exists(strSkin) Then

                For Each strCSSFile As String In Directory.GetFiles(strSkin, "*.css")
                    Dim Include As New HtmlGenericControl("link")
                    Include.Attributes.Add("type", "text/css")
                    Include.Attributes.Add("rel", "stylesheet")
                    Include.Attributes.Add("href", CkartrisBLL.WebShopURL & "Skins/" & CkartrisBLL.Skin(Session("LANG")) & "/" & Mid(strCSSFile, strCSSFile.LastIndexOf("\") + 2))
                    phdIframeCSS.Controls.Add(Include)
                Next

            End If

        Catch ex As Exception
            'Something went wrong, but popup should still
            'work although without CSS links
        End Try

    End Sub

End Class
