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
Partial Class UserControls_Back_AnimatedText
    Inherits System.Web.UI.UserControl

    Private strMessageText As String

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        phdAnimation.Visible = False
    End Sub

    Public Property MessageText() As String
        Get
            Return strMessageText
        End Get
        Set(ByVal value As String)
            strMessageText = value
        End Set
    End Property

    Public Sub Reset()
        phdAnimation.Visible = False
    End Sub

    Public Sub ShowAnimatedText()
        phdAnimation.Visible = True
        If strMessageText <> "" Then litMessage.Text = strMessageText
        pnlMessage_Load(Me, New EventArgs)
    End Sub

    Protected Sub pnlMessage_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles pnlMessage.Load

    End Sub

End Class
