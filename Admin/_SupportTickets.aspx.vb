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
Imports CkartrisDataManipulation
Imports CkartrisDisplayFunctions
Imports CkartrisEnumerations
Imports KartSettingsManager

Partial Class Admin_SupportTickets
    Inherits _PageBaseClass

    Protected Sub ShowMasterUpdateMessage() Handles _UC_EditTicket.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Tickets", "PageTitle_SupportTickets") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Page.IsPostBack Then

            'Store ID of admin in hidden field, so we don't lose
            'session in postbacks
            hidPresentAdminUserID.Value = Session("_UserID")

            'Set number of records per page
            Dim intRowsPerPage As Integer = 25
            Try
                intRowsPerPage = CType(KartSettingsManager.GetKartConfig("backend.display.pagesize"), Double)
            Catch ex As Exception
                'Stays at 25
            End Try
            gvwTickets.PageSize = intRowsPerPage

            If KartSettingsManager.GetKartConfig("frontend.supporttickets.enabled") <> "y" Then
                litFeatureDisabled.Text = Replace( _
                    GetGlobalResourceObject("_Kartris", "ContentText_DisabledInFrontEnd"), "[name]", _
                    GetGlobalResourceObject("_Tickets", "PageTitle_SupportTickets"))
                phdFeatureDisabled.Visible = True
            Else
                phdFeatureDisabled.Visible = False
            End If

            If TicketQS() <> 0 Then
                _UC_EditTicket.GetTicket(TicketQS)
                mvwTickets.SetActiveView(viwEditTicket)
                updMain.Update()
            Else
                ddlLanguages.Items.Clear()
                ddlLanguages.DataSource = GetLanguagesFromCache()
                ddlLanguages.DataBind()
                GetTicketTypes()
                GetTicketLogins()

                If Not String.IsNullOrEmpty(Request.QueryString("u")) OrElse _
                    Not String.IsNullOrEmpty(Request.QueryString("s")) OrElse _
                        Not String.IsNullOrEmpty(Request.QueryString("c")) Then

                    If Not String.IsNullOrEmpty(Request.QueryString("u")) Then
                        ddlAssignedLogin.SelectedValue = Request.QueryString("u")
                    End If
                    If Not String.IsNullOrEmpty(Request.QueryString("s")) Then
                        ddlTicketStatus.SelectedValue = Request.QueryString("s")
                    End If
                    If Not String.IsNullOrEmpty(Request.QueryString("c")) Then
                        txtUser.Text = Request.QueryString("c")
                    End If
                    FindTickets()
                Else
                    LoadSupportTickets()
                End If
            End If
        End If
    End Sub

    Sub LoadSupportTickets()
        litListingType.Text = "NoSearch"
        Dim tblSupportTickets As DataTable = TicketsBLL._GetTickets()

        If tblSupportTickets.Rows.Count = 0 Then
            gvwTickets.DataSource = Nothing
            gvwTickets.DataBind()
            gvwTickets.Visible = False
            pnlNoTickets.Visible = True
            pnlTicketColors.Visible = False
            updTickets.Update()
            Return
        Else
            pnlNoTickets.Visible = False
        End If

        tblSupportTickets.Columns.Add(New DataColumn("DateOpened", Type.GetType("System.String")))
        tblSupportTickets.Columns.Add(New DataColumn("LastMessage", Type.GetType("System.String")))

        For Each drwSupportTicket As DataRow In tblSupportTickets.Rows
            drwSupportTicket("DateOpened") = FormatDate(drwSupportTicket("TIC_DateOpened"), "d", Session("_LANG"))
            drwSupportTicket("LastMessage") = FormatDate(drwSupportTicket("LastMessageDate"), "t", Session("_LANG"))
            If CStr(FixNullFromDB(drwSupportTicket("TIC_Subject"))).Length > 30 Then drwSupportTicket("TIC_Subject") = Left(drwSupportTicket("TIC_Subject"), 27) & "..."
        Next

        gvwTickets.Visible = True
        Dim dvwTickets As DataView = tblSupportTickets.DefaultView
        dvwTickets.Sort = "TIC_DateOpened DESC"
        gvwTickets.DataSource = dvwTickets.Table
        gvwTickets.DataBind()
    End Sub

    Protected Sub gvwTickets_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwTickets.PageIndexChanging
        gvwTickets.PageIndex = e.NewPageIndex
        If litListingType.Text = "Search" Then FindTickets() Else LoadSupportTickets()
    End Sub

    Protected Sub gvwTickets_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwTickets.RowCommand
        If e.CommandName = "edit_ticket" Then
            _UC_EditTicket.GetTicket(e.CommandArgument)
            mvwTickets.SetActiveView(viwEditTicket)
            updMain.Update()
        End If
    End Sub

    Protected Sub gvwTickets_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwTickets.RowDataBound
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim numLoginID As Integer = 0
            If Not String.IsNullOrEmpty(CType(e.Row.Cells(7).FindControl("litLoginID"), Literal).Text) Then
                numLoginID = CInt(CType(e.Row.Cells(7).FindControl("litLoginID"), Literal).Text)
            End If
            Select Case CType(e.Row.Cells(7).FindControl("litTicketStatus"), Literal).Text
                Case "o"
                    If numLoginID = 0 OrElse numLoginID = hidPresentAdminUserID.Value Then
                        'Check TIC_AwaitingResponse
                        If CType(e.Row.Cells(7).FindControl("litAwaitingResponse"), Literal).Text = True Then
                            If e.Row.RowState = DataControlRowState.Alternate Then
                                e.Row.CssClass = "Kartris-GridView-Alternate-Yellow"
                            Else
                                e.Row.CssClass = "Kartris-GridView-Yellow"
                            End If
                        End If
                    Else
                        If e.Row.RowState = DataControlRowState.Alternate Then
                            e.Row.CssClass = "Kartris-GridView-Alternate-Green"
                        Else
                            e.Row.CssClass = "Kartris-GridView-Green"
                        End If
                    End If
                Case "u", "n"
                    If e.Row.RowState = DataControlRowState.Alternate Then
                        e.Row.CssClass = "Kartris-GridView-Alternate-Red"
                    Else
                        e.Row.CssClass = "Kartris-GridView-Red"
                    End If
                Case "c"
                    If e.Row.RowState = DataControlRowState.Alternate Then
                        e.Row.CssClass = "Kartris-GridView-Alternate-Done"
                    Else
                        e.Row.CssClass = "Kartris-GridView-Done"
                    End If
            End Select
        End If
    End Sub

    Protected Sub lnkBtnShowTicketsList_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnShowTicketsList.Click
        If TicketQS() <> 0 Then Response.Redirect("_SupportTickets.aspx")
        mvwTickets.SetActiveView(viwTickets)
        updMain.Update()
    End Sub

    Protected Sub _UC_EditTicket_TicketChanged() Handles _UC_EditTicket.TicketChanged
        LoadSupportTickets()
        updTickets.Update()
        CType(Me.Master, Skins_Admin_Template).LoadTaskList()
    End Sub

    Protected Sub _UC_EditTicket_TicketDeleted() Handles _UC_EditTicket.TicketDeleted
        If TicketQS() <> 0 Then Response.Redirect("_SupportTickets.aspx")
        LoadSupportTickets()
        mvwTickets.SetActiveView(viwTickets)
        updMain.Update()
        CType(Me.Master, Skins_Admin_Template).LoadTaskList()
    End Sub

    Sub GetTicketTypes()
        If ddlTicketType.Items.Count = 0 Then
            ddlTicketType.Items.Clear()
            ddlTicketType.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "BackMenu_SearchAll"), "-1"))
            ddlTicketType.AppendDataBoundItems = True
            ddlTicketType.DataTextField = "STT_Name"
            ddlTicketType.DataValueField = "STT_ID"
            Dim tblTicketTypes As DataTable = TicketsBLL._GetTicketTypes()
            ddlTicketType.DataSource = tblTicketTypes
            ddlTicketType.DataBind()
        End If
    End Sub

    Sub GetTicketLogins()
        If ddlAssignedLogin.Items.Count = 0 Then
            ddlAssignedLogin.Items.Clear()
            ddlAssignedLogin.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "BackMenu_SearchAll"), "-1"))
            ddlAssignedLogin.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_Unassigned"), "0"))
            ddlAssignedLogin.AppendDataBoundItems = True
            ddlAssignedLogin.DataTextField = "LOGIN_Username"
            ddlAssignedLogin.DataValueField = "LOGIN_ID"
            Dim tblTicketLogins As DataTable = LoginsBLL._GetSupportUsers()
            ddlAssignedLogin.DataSource = tblTicketLogins
            ddlAssignedLogin.DataBind()
        End If
    End Sub

    Function TicketQS() As Long
        If Not String.IsNullOrEmpty(Request.QueryString("TIC_ID")) AndAlso _
                Request.QueryString("TIC_ID") <> 0 AndAlso IsNumeric(Request.QueryString("TIC_ID")) Then
            Return CLng(Request.QueryString("TIC_ID"))
        End If
        Return 0
    End Function
    Protected Sub ddlAssignedLogin_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlAssignedLogin.SelectedIndexChanged
        FindTickets()
    End Sub

    Protected Sub ddlLanguages_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlLanguages.SelectedIndexChanged
        FindTickets()
    End Sub

    Protected Sub ddlTicketStatus_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlTicketStatus.SelectedIndexChanged
        FindTickets()
    End Sub

    Protected Sub ddlTicketType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlTicketType.SelectedIndexChanged
        FindTickets()
    End Sub

    Protected Sub txtUser_TextChanged(sender As Object, e As System.EventArgs) Handles txtUser.TextChanged
        FindTickets()
    End Sub

    Protected Sub btnFind_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnFind.Click
        FindTickets()
    End Sub

    Protected Sub btnClear_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnClear.Click
        txtSearchStarting.Text = ""
        txtUser.Text = ""
        ddlLanguages.SelectedValue = LanguagesBLL.GetDefaultLanguageID()
        ddlAssignedLogin.SelectedIndex = 0
        ddlTicketType.SelectedIndex = 0
        ddlTicketStatus.SelectedIndex = 0
        LoadSupportTickets()
    End Sub

    Sub FindTickets()
        Dim strKeyword As String = txtSearchStarting.Text
        Dim numLanguageID As Short = ddlLanguages.SelectedValue()
        Dim numAssignedID As Short = ddlAssignedLogin.SelectedValue()
        Dim numTypeID As Short = ddlTicketType.SelectedValue()
        Dim chrStatus As Char = ddlTicketStatus.SelectedValue()

        Dim numUserID As Integer = -1
        Dim strUserEmail As String = ""

        If Not String.IsNullOrEmpty(txtUser.Text) Then
            If IsNumeric(txtUser.Text) Then
                numUserID = CInt(txtUser.Text)
            Else
                strUserEmail = txtUser.Text
            End If
        End If
        litListingType.Text = "Search"

        Dim tblResult As DataTable = TicketsBLL._SearchTickets(strKeyword, numLanguageID, numAssignedID, numTypeID, numUserID, strUserEmail, chrStatus)

        If tblResult.Rows.Count = 0 Then
            gvwTickets.DataSource = Nothing
            gvwTickets.DataBind()
            gvwTickets.Visible = False
            pnlNoTickets.Visible = True
            pnlTicketColors.Visible = False
            updTickets.Update()
            Return
        Else
            pnlNoTickets.Visible = False
        End If


        tblResult.Columns.Add(New DataColumn("DateOpened", Type.GetType("System.String")))
        tblResult.Columns.Add(New DataColumn("LastMessage", Type.GetType("System.String")))

        For Each drwResult As DataRow In tblResult.Rows
            drwResult("DateOpened") = FormatDate(drwResult("TIC_DateOpened"), "d", Session("_LANG"))
            drwResult("LastMessage") = FormatDate(drwResult("LastMessageDate"), "t", Session("_LANG"))
            If CStr(FixNullFromDB(drwResult("TIC_Subject"))).Length > 30 Then drwResult("TIC_Subject") = Left(drwResult("TIC_Subject"), 27) & "..."
        Next
        gvwTickets.Visible = True
        Dim dvwResults As DataView = tblResult.DefaultView
        dvwResults.Sort = "TIC_DateOpened DESC"
        gvwTickets.DataSource = dvwResults.Table
        gvwTickets.DataBind()
    End Sub

    
End Class
