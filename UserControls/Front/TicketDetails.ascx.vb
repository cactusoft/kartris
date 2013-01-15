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
Imports CkartrisDataManipulation
Imports CkartrisDisplayFunctions

Partial Class UserControls_Front_TicketDetails
    Inherits System.Web.UI.UserControl

    Function GetTicketID() As Long
        If Not String.IsNullOrEmpty(litTicketID.Text) AndAlso IsNumeric(litTicketID.Text) Then
            Return CLng(litTicketID.Text)
        End If
        litTicketID.Text = "0"
        Return 0
    End Function

    Public Sub ViewTicketDetails(ByVal numTicketID As Long)

        litTicketID.Text = numTicketID
        Dim tblTicketDetails As DataTable = TicketsBLL.GetTicketDetailsByID(numTicketID, DirectCast(Page, PageBaseClass).CurrentLoggedUser.ID)
        tblTicketDetails.Columns.Add(New DataColumn("CssStyle", Type.GetType("System.String")))
        tblTicketDetails.Columns.Add(New DataColumn("MessageHeader", Type.GetType("System.String")))

        Try
            '' Show the ticket's subject/date opened date
            Dim drwTicketDetails As DataRow = tblTicketDetails.Rows(0)
            litTicketSubject.Text = FixNullFromDB(drwTicketDetails("TIC_Subject"))
            ViewState("AssignedID") = FixNullFromDB(drwTicketDetails("AssignedID"))
            litOpened.Text = FormatDate(drwTicketDetails("TIC_DateOpened"), "t", Session("LANG"))

            '' Check to ticket's status
            Dim chrStatus As Char = FixNullFromDB(drwTicketDetails("TIC_Status"))
            If chrStatus = "c" Then
                '' Closed (show the closed date)
                litClosed.Text = GetGlobalResourceObject("Tickets", "ContentText_TicketClosed") & " " & _
                    FormatDate(drwTicketDetails("TIC_DateClosed"), "t", Session("LANG"))
                mvwStatus.SetActiveView(viwClosed)
            Else
                '' Not closed (show the reply form)
                mvwStatus.SetActiveView(viwNotClosed)
            End If

            '' Format the message headers
            Dim strMessageHeader As String = GetGlobalResourceObject("Tickets", "ContentText_TicketMessageHeader")
            For Each drwTicket As DataRow In tblTicketDetails.Rows
                If CInt(FixNullFromDB(drwTicket("STM_LoginID"))) = 0 Then
                    '' Written by user
                    drwTicket("CssStyle") = "userreply" '' The css class name used to style the user reply
                    drwTicket("MessageHeader") = strMessageHeader.Replace("[user]", Server.HtmlEncode(Page.User.Identity.Name))
                    drwTicket("MessageHeader") = drwTicket("MessageHeader").Replace("[date]", FormatDate(drwTicket("STM_DateCreated"), "t", Session("LANG")))
                Else
                    '' Written by the owner
                    drwTicket("CssStyle") = "ownerreply" '' The css class name used to style the owner reply
                    drwTicket("MessageHeader") = strMessageHeader.Replace("[user]", GetGlobalResourceObject("Kartris", "Config_Webshopname"))
                    drwTicket("MessageHeader") = drwTicket("MessageHeader").Replace("[date]", FormatDate(drwTicket("STM_DateCreated"), "t", Session("LANG")))
                End If
            Next
            Dim dvwTickets As DataView = tblTicketDetails.DefaultView
            dvwTickets.Sort = "STM_DateCreated ASC"
            rptTicket.DataSource = dvwTickets.Table
            rptTicket.DataBind()
            updMain.Update()
        Catch ex As Exception
            Response.Redirect("~/CustomerTickets.aspx")
        End Try
        
    End Sub

    Protected Sub btnAddReply_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAddReply.Click
        Dim strTicketMessage As String = txtTicketMessage.Text
        Dim strMsg As String = Nothing
        Dim intTicketID As Long = GetTicketID()

        Dim tblAdminLastMess As DataTable = TicketsBLL.GetLastByOwner(intTicketID)
        If TicketsBLL.AddCustomerReply(intTicketID, strTicketMessage, strMsg) Then
            Dim tblTicketLogins As DataTable = LoginsBLL.GetSupportUsers()
            Dim strAdminEmail As String = ""
            Dim BccAddresses As System.Net.Mail.MailAddressCollection = Nothing
            Dim intAssignedID As Integer = CInt(ViewState("AssignedID"))
            If intAssignedID > 0 Then
                For Each dt As DataRow In tblTicketLogins.Select("LOGIN_ID=" & intAssignedID)
                    strAdminEmail = FixNullFromDB(dt("LOGIN_EmailAddress"))
                    Exit For
                Next
            Else
                'ticket is unassigned - send to all support admins
                For Each dt As DataRow In tblTicketLogins.Rows
                    Dim strTempEmail As String = FixNullFromDB(dt("LOGIN_EmailAddress"))
                    If Not String.IsNullOrEmpty(strTempEmail) Then
                        If String.IsNullOrEmpty(strAdminEmail) Then
                            strAdminEmail = strTempEmail
                        Else
                            If BccAddresses Is Nothing Then BccAddresses = New System.Net.Mail.MailAddressCollection
                            BccAddresses.Add(New System.Net.Mail.MailAddress(strTempEmail))
                        End If
                    End If
                Next
            End If

            'insert ticket # to the email subject
            Dim strEmailSubject As String = Replace(GetGlobalResourceObject("Tickets", "Config_Subjectline7"), "[ticketno]", intTicketID)
            Dim strTicketLink As String = CkartrisBLL.WebShopURL & "Admin/_SupportTickets.aspx?tic_id=" & intTicketID



            'retrieve the last message from the admin and include it in the message
            Dim strAdminLastMessage As String = ""
            If tblAdminLastMess.Rows.Count = 1 Then
                strAdminLastMessage = GetGlobalResourceObject("Tickets", "EmailText_ReplyToMessageOn") & _
                            tblAdminLastMess.Rows(0)("STM_DateCreated") & ":" & vbCrLf & vbCrLf & tblAdminLastMess.Rows(0)("STM_Text")
            End If


            Dim blnHTMLEmail As Boolean = KartSettingsManager.GetKartConfig("general.email.enableHTML") = "y"
            If blnHTMLEmail Then
                Dim strHTMLEmailText As String = RetrieveHTMLEmailTemplate("SupportTicket")
                'build up the HTML email if template is found
                If Not String.IsNullOrEmpty(strHTMLEmailText) Then
                    strHTMLEmailText = strHTMLEmailText.Replace("[supporttickettitle]", strEmailSubject)
                    strHTMLEmailText = strHTMLEmailText.Replace("[customermessage]", strTicketMessage)
                    strHTMLEmailText = strHTMLEmailText.Replace("[supportticketlink]", strTicketLink)
                    If Not String.IsNullOrEmpty(strAdminLastMessage) Then
                        strHTMLEmailText = strHTMLEmailText.Replace("[lastmessageblock]", strAdminLastMessage.Replace(vbCrLf, "<br />"))
                    Else
                        strHTMLEmailText = strHTMLEmailText.Replace("[lastmessageblock]", "")
                    End If
                    strTicketMessage = strHTMLEmailText
                Else
                    blnHTMLEmail = False
                End If
            End If

            If Not blnHTMLEmail Then
                'append the backend ticket link to the ticket email text
                strTicketMessage += vbCrLf & vbCrLf & strTicketLink
                strTicketMessage += vbCrLf & vbCrLf & strAdminLastMessage
            End If

            SendEmail(LanguagesBLL.GetEmailFrom(CkartrisBLL.GetLanguageIDfromSession), strAdminEmail, strEmailSubject, strTicketMessage, , , , , blnHTMLEmail, , BccAddresses)

            'Send a support notification request to Windows Store App if enabled
            If intAssignedID = 0 Then CkartrisBLL.PushKartrisNotification("s")

            UC_Updated.ShowAnimatedText()

            txtTicketMessage.Text = Nothing
            ViewTicketDetails(GetTicketID)
            updMain.Update()
        Else
            updAddTicket.Update()
        End If

    End Sub
End Class
