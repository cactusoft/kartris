'========================================================================
'Kartris - www.kartris.com
'Copyright 2020 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Public Class Skins_Admin_Template

    Inherits System.Web.UI.MasterPage

    Public Event ShowMasterUpdate As EventHandler

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Not Page.IsPostBack Then

            Try
                'Let's try to set the width of the menu bar from cookie
                Dim strLeftPanelWidth As String = Request.Cookies("kartris_admin_cookie_menuwidth").Value
                Dim numLeftPanelWidth As Integer = CInt(Replace(strLeftPanelWidth, "px", ""))
                pnlLeftSide.Width = numLeftPanelWidth
            Catch ex As Exception
                'Oh well, let's just default it then
                pnlLeftSide.Width = 270
            End Try

            'This message shows if 
            litHiddenCatMenu.Text = "<div style=""padding: 10px;"">Your account lacks the permissions to view this content.</div>"
        End If

    End Sub

    'This sub can be called by various pages for the parent
    'which is this master page
    Public Sub DataUpdated()
        _UC_AnimatedText.ShowAnimatedText()
        updAnimation.Update()
    End Sub

    Public Sub LoadTaskList()
        _UC_TaskList.LoadTaskList()
        updTaskList.Update()
    End Sub

    Public Sub LoadCategoryMenu()
        _UC_CategoryMenu.LoadCategoryMenu()
    End Sub

    'User controls within this master page can call this with
    'a 'ShowMsterUpdate' event
    Protected Sub ShowMasterUpdateMessage() Handles _UC_CategoryMenu.ShowMasterUpdate
        _UC_AnimatedText.ShowAnimatedText()
        updAnimation.Update()
    End Sub

End Class

