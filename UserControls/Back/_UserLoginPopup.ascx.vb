'[[[NEW COPYRIGHT NOTICE]]]
Imports System.Data

Partial Class UserControls_Back_UserLoginPopup
    Inherits System.Web.UI.UserControl

    Public Event SubmitClicked(ByVal strUserName As String, ByVal strPassword As String)

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '' The following line is important for the confirmation msg box
        ''  => it will allow the event of the server side button to be fired
        Page.ClientScript.GetPostBackEventReference(Me, String.Empty)
    End Sub

    Public Sub ShowLogin()
        txtUserName.Text = ""
        txtPass.Text = ""
        popExtender.Show()
    End Sub

    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSubmit.Click
        RaiseEvent SubmitClicked(txtUserName.Text, txtPass.Text)
    End Sub
End Class
