'[[[NEW COPYRIGHT NOTICE]]]
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

        ''We'll try to put a skin in place, if one exists
        'Try
        '    'Set the skin folder
        '    Dim strSkin As String = Server.MapPath("~/Skins/Admin/")

        '    'We will use this later
        '    Dim strFileName = ""

        '    'Find files in this folder
        '    If Directory.Exists(strSkin) Then

        '        For Each strCSSFile As String In Directory.GetFiles(strSkin, "*.css")
        '            Dim Include As New HtmlGenericControl("link")
        '            Include.Attributes.Add("type", "text/css")
        '            Include.Attributes.Add("rel", "stylesheet")
        '            Include.Attributes.Add("href", CkartrisBLL.WebShopURL & "Skins/Admin/" & Mid(strCSSFile, strCSSFile.LastIndexOf("\") + 2))
        '            phdNoMasterCSS.Controls.Add(Include)
        '        Next

        '    End If

        'Catch ex As Exception
        '    'Something went wrong, but popup should still
        '    'work although without CSS links
        'End Try

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
