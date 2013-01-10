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
Partial Class UserControls_Back_HTMLEditor
    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' raised when the user click "ok" button
    ''' </summary>
    ''' <remarks></remarks>
    Public Event Saved()

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

        Return htmlEditorExtender1.Decode(txtHTMLEditor.Text)
    End Function

    
End Class
