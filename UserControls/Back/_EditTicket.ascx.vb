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

Partial Class UserControls_Back_EditTicket

    Inherits System.Web.UI.UserControl

    Public Event TicketChanged()
    Public Event TicketDeleted()
    Public Event ShowMasterUpdate()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        'store admin user ID in hidden field, otherwise it
        'seems to be unavailable in ajax postbacks after
        'a postback has already occurred
        If Not Page.IsPostBack Then
            hidPresentAdminUserID.Value = Session("_UserID")
        End If
    End Sub

    Function GetTicketID() As Long
        If Not String.IsNullOrEmpty(litTicketNumber.Text) AndAlso IsNumeric(litTicketNumber.Text) Then
            Return CLng(litTicketNumber.Text)
        End If
        litTicketNumber.Text = "0"
        Return 0
    End Function

    Public Sub GetTicket(ByVal numTicketID As Long)
        GetTicketDetails(numTicketID)
        GetUserTicketsDetails(CInt(hidTicketOwnerID.Value))
        GetTicketMessages(numTicketID)
        DisplayReplyBox()
        StartTimer()
    End Sub

    Sub GetTicketTypes()
        If ddlTicketType.Items.Count = 0 Then
            ddlTicketType.Items.Clear()
            Dim tblTicketTypes As DataTable = TicketsBLL._GetTicketTypes()
            ddlTicketType.DataTextField = "STT_Name"
            ddlTicketType.DataValueField = "STT_ID"
            ddlTicketType.DataSource = tblTicketTypes
            ddlTicketType.DataBind()
        End If
    End Sub

    Sub GetTicketLogins()
        If ddlAssignedLogin.Items.Count = 0 Then
            ddlAssignedLogin.Items.Clear()
            Dim tblTicketLogins As DataTable = LoginsBLL._GetSupportUsers()
            ddlAssignedLogin.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_Unassigned"), 0))
            ddlAssignedLogin.AppendDataBoundItems = True
            ddlAssignedLogin.DataTextField = "LOGIN_Username"
            ddlAssignedLogin.DataValueField = "LOGIN_ID"
            ddlAssignedLogin.DataSource = tblTicketLogins
            ddlAssignedLogin.DataBind()
        End If
    End Sub

    Sub StartTimer()
        lblTime.Text = "00 " & GetGlobalResourceObject("_Kartris", "ContentText_Minutes")
        lblTimeSpent_Hidden.Text = "0"
        timMinutes.Enabled = True
    End Sub

    Sub GetTicketDetails(ByVal numTicketID As Long)

        GetTicketTypes()
        GetTicketLogins()

        Dim tblTicketDetails As DataTable = TicketsBLL._GetTicketDetails(numTicketID)
        If tblTicketDetails.Rows.Count = 0 Then Response.Redirect("~/Admin/_SupportTickets.aspx?")
        Dim drwDetails As DataRow = tblTicketDetails.Rows(0)
        litTicketNumber.Text = drwDetails("TIC_ID")
        litTicketSubject.Text = RemoveXSS(FixNullFromDB(drwDetails("TIC_Subject")))
        litDateOpened.Text = FormatDate(drwDetails("TIC_DateOpened"), "t", Session("_LANG"))
        ddlAssignedLogin.SelectedValue = FixNullFromDB(drwDetails("TIC_LoginID"))
        ddlTicketType.SelectedValue = FixNullFromDB(drwDetails("TIC_SupportTicketTypeID"))
        ddlTicketStatus.SelectedValue = FixNullFromDB(drwDetails("TIC_Status"))
        txtTotalTimeSpent.Text = FixNullFromDB(drwDetails("TIC_TimeSpent"))
        If FixNullFromDB(drwDetails("TIC_Status")) = "c" Then
            phdDateClosed.Visible = True
            litDateClosed.Text = FormatDate(drwDetails("TIC_DateClosed"), "t", Session("_LANG"))
        Else
            phdDateClosed.Visible = False
            litDateClosed.Text = "-"
        End If
        txtTags.Text = FixNullFromDB(drwDetails("TIC_Tags"))
        hidTicketOwnerID.Value = FixNullFromDB(drwDetails("TIC_UserID"))

        updTicketDetails.Update()

    End Sub

    Sub GetUserTicketsDetails(ByVal numUserID As Integer)
        Dim drwDetails As DataRow = UsersBLL._GetTicketDetailsByUser(numUserID).Rows(0)
        litUserID.Text = numUserID
        lnkCustomer.NavigateUrl = "~/Admin/_ModifyCustomerStatus.aspx?CustomerID=" & numUserID
        litUserEmail.Text = FixNullFromDB(drwDetails("U_EmailAddress"))
        ViewState("CustomerEmail") = litUserEmail.Text
        litTotalTickets.Text = FixNullFromDB(drwDetails("UserTickets")) & _
            " (" & GetPercentage(drwDetails("UserTickets"), drwDetails("TotalTickets")) & ")"
        litTotalMessages.Text = FixNullFromDB(drwDetails("UserMessages")) & _
            " (" & GetPercentage(drwDetails("UserMessages"), drwDetails("TotalMessages")) & ")"
        litTotalTime.Text = FixNullFromDB(drwDetails("UserTime")) & " " & GetGlobalResourceObject("_Kartris", "ContentText_Minutes") & _
            " (" & GetPercentage(drwDetails("UserTime"), drwDetails("TotalTime")) & ")"
        hlnkCustomersTickets.NavigateURL = "~/Admin/_SupportTickets.aspx?c=" & numUserID
        updCustomerDetails.Update()
    End Sub

    Function GetPercentage(ByVal numValue As Integer, ByVal numTotal As Integer) As String
        Return Format(CDbl(numValue / numTotal) * 100, "###.#") & "%"
    End Function

    Sub GetTicketMessages(ByVal numTicketID As Integer)
        Dim tblTicket As DataTable = TicketsBLL._GetTicketMessages(numTicketID)
        tblTicket.Columns.Add(New DataColumn("CssStyle", Type.GetType("System.String")))
        tblTicket.Columns.Add(New DataColumn("MessageFooter", Type.GetType("System.String")))

        '' Format the message headers
        Dim strMessageHeader As String = GetGlobalResourceObject("Tickets", "ContentText_TicketMessageHeader")
        For Each drwTickets As DataRow In tblTicket.Rows
            If CInt(FixNullFromDB(drwTickets("AssignedID"))) = 0 Then
                '' Written by user
                drwTickets("CssStyle") = "userreply" '' The css class name used to style the user reply
                drwTickets("MessageFooter") = strMessageHeader.Replace("[user]", GetGlobalResourceObject("_Kartris", "ContentText_Customer"))
                drwTickets("MessageFooter") = drwTickets("MessageFooter").Replace("[date]", FormatDate(drwTickets("STM_DateCreated"), "t", Session("_LANG")))
            Else
                '' Written by the owner
                drwTickets("CssStyle") = "ownerreply" '' The css class name used to style the owner reply
                drwTickets("MessageFooter") = strMessageHeader.Replace("[user]", FixNullFromDB(drwTickets("AssignedName")))
                drwTickets("MessageFooter") = drwTickets("MessageFooter").Replace("[date]", FormatDate(drwTickets("STM_DateCreated"), "t", Session("_LANG")))
            End If
        Next
        Dim dvwTicket As DataView = tblTicket.DefaultView
        dvwTicket.Sort = "STM_DateCreated ASC"
        rptTicket.DataSource = dvwTicket.Table
        rptTicket.DataBind()
        updMessages.Update()
    End Sub

    Protected Sub btnAddReply_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAddReply.Click
        timMinutes.Enabled = False
        Dim strTicketMessage As String = txtTicketMessage.Text
        Dim numTimeSpent As Integer = lblTimeSpent_Hidden.Text
        If Not String.IsNullOrEmpty(txtTimeSpent.Text) Then
            numTimeSpent = CInt(txtTimeSpent.Text)
        Else
            If numTimeSpent = 0 Then numTimeSpent = 1
        End If
        Dim strMsg As String = Nothing
        Dim intTicketID As Long = GetTicketID()
        Dim num_UserID As Integer = ddlAssignedLogin.SelectedValue()
        Dim tblCustLastMess As DataTable = TicketsBLL._GetLastByCustomer(intTicketID)

        If TicketsBLL._AddOwnerReply(intTicketID, num_UserID, strTicketMessage, numTimeSpent, strMsg) Then
            '-----------------------------------------------------
            'ADD OWNER REPLY
            '-----------------------------------------------------
            Dim strCustomerEmail As String = ViewState("CustomerEmail")

            'insert ticket # to the email subject
            Dim strEmailSubject As String = Replace(GetGlobalResourceObject("Tickets", "Config_Subjectline7"), "[ticketno]", intTicketID)
            Dim strTicketLink As String = CkartrisBLL.WebShopURL & "CustomerTickets.aspx?tic_id=" & intTicketID

            'retrieve the last message from the customer and include it in the message
            Dim strCustomerLastMessage As String = ""
            If tblCustLastMess.Rows.Count = 1 Then
                strCustomerLastMessage = GetGlobalResourceObject("Tickets", "EmailText_ReplyToMessageOn") & _
                            tblCustLastMess.Rows(0)("STM_DateCreated") & ":" & vbCrLf & vbCrLf & tblCustLastMess.Rows(0)("STM_Text")
            End If

            Dim blnHTMLEmail As Boolean = KartSettingsManager.GetKartConfig("general.email.enableHTML") = "y"
            If blnHTMLEmail Then
                Dim strHTMLEmailText As String = RetrieveHTMLEmailTemplate("SupportTicket")
                'build up the HTML email if template is found
                If Not String.IsNullOrEmpty(strHTMLEmailText) Then
                    strHTMLEmailText = strHTMLEmailText.Replace("[supporttickettitle]", strEmailSubject)
                    strHTMLEmailText = strHTMLEmailText.Replace("[customermessage]", strTicketMessage)
                    strHTMLEmailText = strHTMLEmailText.Replace("[supportticketlink]", strTicketLink)
                    If Not String.IsNullOrEmpty(strCustomerLastMessage) Then
                        strHTMLEmailText = strHTMLEmailText.Replace("[lastmessageblock]", strCustomerLastMessage.Replace(vbCrLf, "<br />"))
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
                strTicketMessage += vbCrLf & vbCrLf & strCustomerLastMessage
            End If
            SendEmail(LanguagesBLL.GetEmailFrom(CkartrisBLL.GetLanguageIDfromSession), strCustomerEmail, strEmailSubject, strTicketMessage, , , , , blnHTMLEmail)

            tblCustLastMess = Nothing
            txtTicketMessage.Text = Nothing
            txtTimeSpent.Text = Nothing
            updReply.Update()
            updReplyTime.Update()
            RaiseEvent TicketChanged()
            RaiseEvent ShowMasterUpdate()
            GetTicketDetails(intTicketID)
            GetTicketMessages(intTicketID)
            StartTimer()
        Else
            '-----------------------------------------------------
            'ERROR
            'The reply could not be added to db for some reason
            '-----------------------------------------------------
            timMinutes.Enabled = True
            _UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.ErrorMessage, strMsg)

            CkartrisFormatErrors.LogError(strMsg & vbCrLf & "intTicketID = " & intTicketID & vbCrLf & "numLoginID = " & num_UserID & vbCrLf & "numTimeSpent = " & numTimeSpent)
        End If
    End Sub

    Protected Sub timMinutes_Tick(ByVal sender As Object, ByVal e As System.EventArgs) Handles timMinutes.Tick
        Dim numTotalMinutes As Integer = CInt(lblTimeSpent_Hidden.Text) + timMinutes.Interval / 60000
        lblTimeSpent_Hidden.Text = numTotalMinutes
        lblTime.Text = Format(numTotalMinutes, "0#") & " " & litMinutesString.Text
    End Sub

    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.Click
        UpdateTicket()
        DisplayReplyBox()
        updMain.Update()
    End Sub

    Protected Sub lnkAssignToMe_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkAssignToMe.Click
        ddlAssignedLogin.SelectedValue = CInt(hidPresentAdminUserID.Value)
        UpdateTicket()
        DisplayReplyBox()
        updMain.Update()
    End Sub

    Sub UpdateTicket()
        Dim numAssignedID As Integer = ddlAssignedLogin.SelectedValue
        Dim numTicketTypeID As Integer = ddlTicketType.SelectedValue
        Dim chrStatus As Char = ddlTicketStatus.SelectedValue
        Dim numTimeSpent As Integer = CInt(txtTotalTimeSpent.Text)
        Dim strMsg As String = Nothing
        If Not TicketsBLL._UpdateTicket(GetTicketID, numAssignedID, chrStatus, numTimeSpent, txtTags.Text, numTicketTypeID, strMsg) Then
            _UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.ErrorMessage, strMsg)
        Else
            RaiseEvent TicketChanged()
            GetTicketDetails(GetTicketID)

            RaiseEvent ShowMasterUpdate()
        End If

    End Sub

    Protected Sub lnkBtnDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDelete.Click
        _UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified"))
    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        DeleteTicket()
        RaiseEvent ShowMasterUpdate()
    End Sub

    Private Sub DisplayReplyBox()
        Try
            Dim numCurrentUser As Integer = 0
            If Not String.IsNullOrEmpty(hidPresentAdminUserID.Value) AndAlso IsNumeric(hidPresentAdminUserID.Value) AndAlso hidPresentAdminUserID.Value > 0 Then
                numCurrentUser = CInt(hidPresentAdminUserID.Value)
            ElseIf IsNumeric(Session("_UserID")) AndAlso Session("_UserID") > 0 Then
                numCurrentUser = CInt(Session("_UserID"))
            End If
            If ddlAssignedLogin.SelectedValue = numCurrentUser Then
                phdReply.Visible = True
                litReplyComment.Visible = False
            Else
                phdReply.Visible = False
                litReplyComment.Visible = True
            End If
        Catch ex As Exception
            phdReply.Visible = False
            litReplyComment.Visible = True
            'Log error
            CkartrisFormatErrors.LogError("hidPresentAdminUserID.Value = " & hidPresentAdminUserID.Value)
        End Try
    End Sub

    Sub DeleteTicket()
        Dim strMessage As String = Nothing
        If TicketsBLL._DeleteTicket(GetTicketID, strMessage) Then
            RaiseEvent TicketDeleted()
            RaiseEvent ShowMasterUpdate()
        Else
            _UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.ErrorMessage, strMessage)
        End If
    End Sub
End Class
