'========================================================================
'Kartris - www.kartris.com
'Copyright 2014 CACTUSOFT INTERNATIONAL FZ LLC

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
Imports CkartrisBLL

Partial Class CustomerTickets
    Inherits PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If KartSettingsManager.GetKartConfig("frontend.supporttickets.enabled") = "y" Then
            Dim TIC_ID As Integer = 0
            If User.Identity.IsAuthenticated Then
                If Not Page.IsPostBack Then
                    Try
                        TIC_ID = Request.QueryString("TIC_ID")
                    Catch ex As Exception
                        TIC_ID = 0
                    End Try
                    If TIC_ID > 0 Then
                        UC_TicketDetails.ViewTicketDetails(TIC_ID)
                        mvwTickets.SetActiveView(viwTicketDetails)
                        updMain.Update()
                    Else
                        mvwTickets.ActiveViewIndex = 1
                        LoadUserTickets()
                    End If
                    If DirectCast(Page, PageBaseClass).CurrentLoggedUser.isSupportValid Then
                        Dim strMessage As String = GetGlobalResourceObject("Tickets", "ContentText_SupportExpiresMessage")
                        strMessage = strMessage.Replace("[date]", FormatDate(DirectCast(Page, PageBaseClass).CurrentLoggedUser.SupportEndDate, "d", Session("Lang")))
                        lblSupportExpirationMessage.Text = strMessage : lblSupportExpirationMessage.Visible = True
                        lblSupportExpirationMessage.CssClass = "expirywarning"
                    ElseIf DirectCast(Page, PageBaseClass).CurrentLoggedUser.SupportEndDate <> Nothing AndAlso _
                            DirectCast(Page, PageBaseClass).CurrentLoggedUser.SupportEndDate <> "#12:00:00 AM#" Then
                        Dim strMessage As String = GetGlobalResourceObject("Tickets", "ContentText_SupportExpiredMessage")
                        strMessage = strMessage.Replace("[date]", FormatDate(DirectCast(Page, PageBaseClass).CurrentLoggedUser.SupportEndDate, "d", Session("Lang")))
                        lblSupportExpirationMessage.Text = strMessage : lblSupportExpirationMessage.Visible = True
                        lblSupportExpirationMessage.CssClass = "expiredwarning"
                    Else
                        lblSupportExpirationMessage.Text = "" : lblSupportExpirationMessage.Visible = False
                    End If
                End If
            Else
                mvwTickets.ActiveViewIndex = 0
            End If
        Else
            mvwMain.SetActiveView(viwNotExist)
        End If
    End Sub

    Protected Sub UC_WriteTicket_WritingFinished() Handles UC_WriteTicket.WritingFinished
        LoadUserTickets()
        mvwTickets.SetActiveView(viwTickets)
        updMain.Update()
    End Sub

    Sub LoadUserTickets()
        Dim tblUserTickets As DataTable = TicketsBLL.GetSupportTicketsByUser(CurrentLoggedUser.ID)
        tblUserTickets.Columns.Add(New DataColumn("DateOpened", Type.GetType("System.String")))
        tblUserTickets.Columns.Add(New DataColumn("DateClosed", Type.GetType("System.String")))
        For Each drwTicket As DataRow In tblUserTickets.Rows
            If Not drwTicket("TIC_DateOpened") Is DBNull.Value Then
                drwTicket("DateOpened") = FormatDate(drwTicket("TIC_DateOpened"), "d", Session("LANG"))
            End If
            If Not drwTicket("TIC_DateClosed") Is DBNull.Value Then
                drwTicket("DateClosed") = FormatDate(drwTicket("TIC_DateClosed"), "d", Session("LANG"))
            Else
                drwTicket("DateClosed") = GetGlobalResourceObject("Tickets", "ContentText_TicketIsOpen")
            End If
            If CStr(FixNullFromDB(drwTicket("TIC_Subject"))).Length > 38 Then drwTicket("TIC_Subject") = Left(drwTicket("TIC_Subject"), 35) & "..."
        Next
        If tblUserTickets.Rows.Count > gvwTickets.PageSize Then
            gvwTickets.AllowPaging = True
        Else
            gvwTickets.AllowPaging = False
        End If
        Dim dvwTickets As DataView = tblUserTickets.DefaultView
        dvwTickets.Sort = "TIC_DateOpened DESC"
        gvwTickets.DataSource = dvwTickets.Table
        gvwTickets.DataBind()
    End Sub

    Protected Sub btnOpenTicket_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnOpenTicket.Click
        UC_WriteTicket.OpenNewTicket(CurrentLoggedUser.ID)
        mvwTickets.SetActiveView(viwWriteTicket)
        updMain.Update()
    End Sub
    Function FormatURL(ByVal TIC_ID As Integer) As String
        Return "CustomerTickets.aspx?TIC_ID=" & TIC_ID.ToString
    End Function

    Protected Sub gvwTickets_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwTickets.RowDataBound
        If e.Row.RowType = DataControlRowType.DataRow Then
            If CBool(CType(e.Row.Cells(4).FindControl("litAwaitingReply"), Literal).Text) Then
                If e.Row.RowState = DataControlRowState.Alternate Then
                    e.Row.CssClass = "sp_highlight_ticket"
                Else
                    e.Row.CssClass = "sp_highlight_ticket"
                End If
            End If
        End If
    End Sub
End Class