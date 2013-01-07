'[[[NEW COPYRIGHT NOTICE]]]
Partial Class UserControls_AnimatedText
    Inherits System.Web.UI.UserControl
    Private _MessageText As String

    Public Property MessageText() As String
        Get
            Return _MessageText
        End Get
        Set(ByVal value As String)
            _MessageText = value
        End Set
    End Property
    Public Sub ShowAnimatedText()
        pHolderAnimation.Visible = True
        If _MessageText <> "" Then litMessage.Text = _MessageText
        MyPanel_Load(Me, New EventArgs)
    End Sub
    Public Sub reset()
        pHolderAnimation.Visible = False
    End Sub
    Protected Sub MyPanel_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyPanel.Load

    End Sub
End Class
