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

Partial Class Templates_WriteTicketTemplate
    Inherits System.Web.UI.UserControl

    Public Event WritingFinished()

    Private Function GetUserID() As Integer
        If Not String.IsNullOrEmpty(litUserID.Text) AndAlso IsNumeric(litUserID.Text) Then
            Return CInt(litUserID.Text)
        End If
        litUserID.Text = "0"
        Return 0
    End Function

    Public Sub OpenNewTicket(ByVal numUserID As Integer)
        litUserID.Text = numUserID
        txtSubject.Text = Nothing
        txtTicketMessage.Text = Nothing
        mvwWriting.SetActiveView(viwWritingForm)
        updMain.Update()
    End Sub

    Protected Sub btnAddTicket_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAddTicket.Click
        AddNewTicket()
    End Sub

    Sub AddNewTicket()
        If GetUserID() <> 0 Then
            Dim strSubject As String = txtSubject.Text
            Dim strTicketMessage As String = txtTicketMessage.Text
            Dim numTicketType As Integer = ddlTicketType.SelectedValue
            Dim strMsg As String = Nothing
            Dim intNewTicketID As Integer = TicketsBLL.AddSupportTicket(GetUserID, numTicketType, strSubject, strTicketMessage, strMsg)
            If intNewTicketID > 0 Then
                Dim tblTicketLogins As DataTable = LoginsBLL.GetSupportUsers()
                Dim strAdminEmail As String = ""
                Dim BccAddresses As System.Net.Mail.MailAddressCollection = Nothing

                'ticket is unassigned - send to all support admins
                For Each drwLogins As DataRow In tblTicketLogins.Rows
                    Dim strTempEmail As String = FixNullFromDB(drwLogins("LOGIN_EmailAddress"))
                    If Not String.IsNullOrEmpty(strTempEmail) Then
                        If String.IsNullOrEmpty(strAdminEmail) Then
                            strAdminEmail = strTempEmail
                        Else
                            BccAddresses = New System.Net.Mail.MailAddressCollection
                            BccAddresses.Add(New System.Net.Mail.MailAddress(strTempEmail))
                        End If
                    End If
                Next

                'insert ticket # to the email subject
                Dim strEmailSubject As String = Replace(GetGlobalResourceObject("Tickets", "Config_Subjectline6"), "[ticketno]", intNewTicketID)

                'append the backend ticket link to the ticket email text
                strTicketMessage = strSubject & vbCrLf & vbCrLf & strTicketMessage & vbCrLf & vbCrLf & _
                                    CkartrisBLL.WebShopURL & "Admin/_SupportTickets.aspx?tic_id=" & intNewTicketID

                SendEmail(LanguagesBLL.GetEmailFrom(CkartrisBLL.GetLanguageIDfromSession), strAdminEmail, strEmailSubject, strTicketMessage, , , , , , , BccAddresses)


                litResult.Text = GetGlobalResourceObject("Tickets", "ContentText_TicketSuccessfullySubmited")
            Else
                litResult.Text = GetGlobalResourceObject("Kartris", "ContentText_Error")
            End If
            mvwWriting.SetActiveView(viwWritingResult)
            updMain.Update()
        End If
    End Sub

    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancel.Click
        RaiseEvent WritingFinished()
    End Sub

    Protected Sub btnBack_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnBack.Click
        RaiseEvent WritingFinished()
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            If Page.User.Identity.IsAuthenticated Then FillLevels()
        End If
    End Sub

    Sub FillLevels()
        Dim tblTicketTypes As DataTable = TicketsBLL._GetTicketTypes()
        Dim dvwTicketTypes As DataView = tblTicketTypes.DefaultView
        If Not DirectCast(Page, PageBaseClass).CurrentLoggedUser.isSupportValid Then dvwTicketTypes.RowFilter = "STT_Level = 's'"
        ddlTicketType.DataTextField = "STT_Name"
        ddlTicketType.DataValueField = "STT_ID"
        ddlTicketType.DataSource = dvwTicketTypes
        ddlTicketType.DataBind()
    End Sub
End Class
