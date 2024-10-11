'========================================================================
'Kartris - www.kartris.com
'Copyright 2024 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class UserControls_Back_HTMLEditor

    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' raised when the user click "ok" button
    ''' </summary>
    ''' <remarks></remarks>
    Public Event Saved()

    Dim strFilesFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "General/"

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '' The following line is important for the confirmation msg box
        ''  => it will allow the event of the server side button to be fired
        Page.ClientScript.GetPostBackEventReference(Me, String.Empty)
    End Sub

    ''' <summary>
    ''' calls the popup control to show in the screen
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub OpenEditor()
        popExtender.Show()
    End Sub

    Protected Sub lnkYes_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkYes.Click
        RaiseEvent Saved()
    End Sub

    Public Sub SetText(ByVal strText As String)

        txtHTMLEditor.Text = strText
    End Sub

    Public Function GetText() As String
        Return Server.HtmlDecode(txtHTMLEditor.Text)
    End Function

    'Protected Sub ajaxFileUpload_OnUploadComplete(sender As Object, e As AjaxControlToolkit.AjaxFileUploadEventArgs)
    '    htmlEditorExtender1.AjaxFileUpload.SaveAs(strFilesFolder + e.FileName)
    '    e.PostedUrl = Page.ResolveUrl(strFilesFolder + e.FileName)
    'End Sub

    Protected Sub ajaxFileUpload_OnUploadComplete(sender As Object, e As AjaxControlToolkit.AjaxFileUploadEventArgs)
        Dim strFullPath As String = strFilesFolder & e.FileName
        htmlEditorExtender1.AjaxFileUpload.SaveAs(Server.MapPath(strFullPath))
        e.PostedUrl = KartSettingsManager.GetKartConfig("general.webshopurl") + strFullPath.Replace("~/", "")
    End Sub

    Protected Sub SaveFile(sender As Object, e As AjaxControlToolkit.AjaxFileUploadEventArgs)

        Dim strFullPath As String = strFilesFolder & e.FileName
        ' Save your File
        htmlEditorExtender1.AjaxFileUpload.SaveAs(Server.MapPath(strFullPath))

        ' Tells the HtmlEditorExtender where the file is otherwise it will render as: <img src="" />
        e.PostedUrl = strFullPath
    End Sub

End Class
