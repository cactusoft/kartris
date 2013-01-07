<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_EditTicket.ascx.vb"
    Inherits="UserControls_Back_EditTicket" %>
<%@ Register TagPrefix="_user" TagName="AnimatedText" Src="~/UserControls/Back/_AnimatedText.ascx" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <div id="supporttickets">
            <div class="halfwidth">
                <h2>
                    <asp:Literal ID="litTicketDetails" runat="server" Text="<%$ Resources: _Tickets, ContentText_TicketDetails %>" /></h2>
                <asp:UpdatePanel ID="updTicketDetails" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                         <% 'We have had some problems using Session("_UserID")
                             'in controls after a postback has occurred; the 
                             'value seems to be lost. To make sure we know the
                             'ID of the admin that a ticket belongs to, and the
                             'present logged in admin, we store them here as
                             'hidden fields when the page first loads. %>
                        <asp:HiddenField ID="hidTicketOwnerID" runat="server" Visible="false" />
                        <asp:HiddenField ID="hidPresentAdminUserID" runat="server" />
                        <div class="Kartris-DetailsView">
                            <div class="Kartris-DetailsView-Data">
                                <ul>
                                    <!-- Ticket No -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litTicket" runat="server" Text="<%$ Resources:_Tickets, ContentText_TicketNumber %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litTicketNumber" runat="server" />
                                    </span></li>
                                    <!-- Ticket Subject -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litSubject" runat="server" Text="<%$ Resources:_Tickets, ContentText_TicketSubject %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litTicketSubject" runat="server" />
                                    </span></li>
                                    <!-- Date Opened -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litOpened" runat="server" Text="<%$ Resources:_Tickets, ContentText_DateOpened %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litDateOpened" runat="server"></asp:Literal>
                                    </span></li>
                                    <!-- Assigned To -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litAssigedTo" runat="server" Text="<%$ Resources:_Tickets, ContentText_AssignedTo %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:DropDownList ID="ddlAssignedLogin" runat="server" CssClass="midtext">
                                        </asp:DropDownList>
                                        <asp:LinkButton class="linkbutton icon_edit" ID="lnkAssignToMe" Text="<%$ Resources: _Kartris, ContentText_Me %>"
                                            runat="server"></asp:LinkButton>
                                    </span>
                                    </li>
                                    <!-- Type -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litType" runat="server" Text="<%$ Resources:_Kartris, ContentText_Type %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:DropDownList ID="ddlTicketType" runat="server" CssClass="midtext">
                                        </asp:DropDownList>
                                    </span></li>
                                    <!-- Status -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="lblStatus" runat="server" Text="<%$ Resources:_Kartris, ContentText_Status %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:DropDownList ID="ddlTicketStatus" runat="server" CssClass="midtext">
                                            <asp:ListItem Text="<%$ Resources: _Tickets, ContentText_OpenStatus %>" Value="o" />
                                            <asp:ListItem Text="<%$ Resources: _Tickets, ContentText_ClosedStatus %>" Value="c" />
                                            <asp:ListItem Text="<%$ Resources: _Tickets, ContentText_UnresolvedStatus %>" Value="u" />
                                            <asp:ListItem Text="<%$ Resources: _Tickets, ContentText_NotSureStatus %>" Value="n" />
                                        </asp:DropDownList>
                                    </span></li>
                                    <!-- Time Spent -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litTime" runat="server" Text="<%$ Resources:_Tickets, ContentText_TotalTimeSpent %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtTotalTimeSpent" runat="server" MaxLength="4" CssClass="shorttext" />
                                        <asp:Literal ID="litMinutes" runat="server" Text="<%$ Resources:_Kartris, ContentText_Minutes %>" />
                                        <asp:RequiredFieldValidator EnableClientScript="False" ID="valTime" runat="server"
                                            ControlToValidate="txtTotalTimeSpent" ValidationGroup="TicketForm" CssClass="error" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filTotalTimeSpent" runat="server" TargetControlID="txtTotalTimeSpent"
                                            FilterType="Numbers" />
                                    </span></li>
                                    <!-- Date Closed -->
                                    <asp:PlaceHolder ID="phdDateClosed" runat="server">
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="lblClosed" runat="server" Text="<%$ Resources:_Tickets, ContentText_DateClosed %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litDateClosed" runat="server" />
                                    </span></li></asp:PlaceHolder>
                                </ul>
                            </div>
                            <div class="spacer">
                                    <!-- Search Tags -->
                                    <span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litTags" runat="server" Text="<%$ Resources:_Tickets, ContentText_SearchTags %>" />
                                    </span>
                                    <asp:TextBox ID="txtTags" runat="server" MaxLength="200" TextMode="MultiLine" CssClass="tags" />
                            </div>
                            <br /><br />
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
            <div class="halfwidth">
                <h2>
                    <asp:Literal ID="litCustomerTitle" runat="server" Text="<%$ Resources: _Kartris, ContentText_Customer %>" /></h2>
                <asp:UpdatePanel ID="updCustomerDetails" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <div class="Kartris-DetailsView">
                            <div class="Kartris-DetailsView-Data">
                                <ul>
                                    <!-- UserID -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litFormLabelCustomerID" runat="server" Text="<%$ Resources: _Customers, FormLabel_CustomerID %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:HyperLink ID="lnkCustomer" runat="server" CssClass="linkbutton icon_user">
                                        <asp:Literal ID="litUserID" runat="server" /></asp:HyperLink>
                                    </span></li>
                                    <!-- UserEmail -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litContentTextCustomerEmail" runat="server" Text="<%$ Resources: _Reviews, ContentText_CustomerEmail %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litUserEmail" runat="server" />
                                    </span></li>
                                    <!-- TotalTickets -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litContentTextTotalTickets" runat="server" Text="<%$ Resources: _Tickets, ContentText_TotalTickets %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litTotalTickets" runat="server" />
                                    </span></li>
                                    <!-- TotalMessages -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litContentTextTotalMessages" runat="server" Text="<%$ Resources: _Tickets, ContentText_TotalMessages %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litTotalMessages" runat="server" />
                                    </span></li>
                                    <!-- TotalTime -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litContentTextTotalTime" runat="server" Text="<%$ Resources: _Tickets, ContentText_TotalTime %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litTotalTime" runat="server" />
                                    </span></li>
                                    <li>
                                    <br /><asp:HyperLink ID="hlnkCustomersTickets" CssClass="linkbutton icon_support" runat="server" Text="<%$ Resources: _Tickets, ContentText_ThisCustomerTickets %>" ></asp:HyperLink>
                                    </li>
                            </div>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
            <div class="spacer">
            </div>
            <%-- Save Button  --%>
            <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:LinkButton ID="btnSave" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                            ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' ValidationGroup="TicketForm" />
                        <span class="floatright">
                            <asp:LinkButton ID="lnkBtnDelete" CssClass="button icon_delete deletebutton" runat="server"
                                Text='<%$ Resources: _Kartris, FormButton_Delete %>' ToolTip='<%$ Resources: _Kartris, FormButton_Delete %>'
                                ValidationGroup="TicketForm" /></span>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
            <h2>
                <asp:Literal ID="litContentTextTicketMessages" runat="server" Text="<%$ Resources:_Tickets, ContentText_TicketMessages %>" /></h2>
            <asp:UpdatePanel ID="updMessages" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:Repeater ID="rptTicket" runat="server">
                        <ItemTemplate>
                            <asp:Panel ID="pnlMessage" runat="server" CssClass='<%# Eval("CssStyle") %>'>
                            <!--
                            IMPORTANT - ensure no space or line breaks between the P tag and Literals below, otherwise the PRE
                            CSS formatting on this section will show it as white-space.
                            --> 
                                <p class="details"><asp:Literal ID="litMessageFooter" runat="server" Text='<%# Eval("MessageFooter") %>' /></p>
                                <p class="message"><asp:Literal Mode="Encode" ID="litMessageContents" runat="server" Text='<%# Eval("STM_Text") %>' /></p>
                            </asp:Panel>
                        </ItemTemplate>
                    </asp:Repeater>
                </ContentTemplate>
            </asp:UpdatePanel>
            <h2>
                <asp:Literal ID="litReply" runat="server" Text="<%$ Resources: _Tickets, ContentText_ReplyToTicket %>" /></h2>
            <asp:Literal ID="litReplyComment" runat="server" Text="<%$ Resources: _Tickets, ContentText_MustAssignBeforeReply %>"
                Visible="False" />
            <asp:PlaceHolder ID="phdReply" runat="server">
                <asp:UpdatePanel ID="updReply" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:TextBox ID="txtTicketMessage" runat="server" TextMode="MultiLine" MaxLength="4000" />
                        <asp:RequiredFieldValidator Display="Dynamic" Text="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                            ID="valTicketMessage" runat="server" ControlToValidate="txtTicketMessage" ValidationGroup="TicketReply"
                            CssClass="error" ForeColor=""></asp:RequiredFieldValidator>
                    </ContentTemplate>
                </asp:UpdatePanel>
                <div class="Kartris-DetailsView">
                    <div class="Kartris-DetailsView-Data">
                        <ul>
                            <li><span class="Kartris-DetailsView-Name">
                                <asp:Label ID="lblTimeSpentString" runat="server" Text="<%$ Resources: _Tickets, ContentText_TimeSpent %>" />
                            </span><span class="Kartris-DetailsView-Value">
                                <asp:UpdatePanel ID="updTimer" runat="server">
                                    <ContentTemplate>
                                        <asp:Label ID="lblTime" runat="server" />
                                        <asp:Timer ID="timMinutes" runat="server" Enabled="false" Interval="60000" />
                                        <asp:Label ID="lblTimeSpent_Hidden" runat="server" Text="0" Visible="false" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </span></li>
                            <li><span class="Kartris-DetailsView-Name">
                                <asp:Literal ID="litContentTextEstimateTimeSpent" runat="server" Text="<%$ Resources: _Tickets, ContentText_EstimateTimeSpent %>" />
                            </span><span class="Kartris-DetailsView-Value">
                                <asp:UpdatePanel ID="updReplyTime" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:TextBox ID="txtTimeSpent" runat="server" MaxLength="3" CssClass="shorttext" />
                                        <asp:Literal ID="litMinutesString" runat="server" Text="<%$ Resources: _Kartris, ContentText_Minutes %>" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filTimeSpent" runat="server" TargetControlID="txtTimeSpent"
                                            FilterType="Numbers" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </span></li>
                        </ul>
                    </div>
                </div>
                <div class="submitbuttons">
                    <asp:UpdatePanel ID="updAddReply" runat="server" UpdateMode="Conditional" RenderMode="Inline">
                        <ContentTemplate>

                            <asp:Button ID="btnAddReply" runat="server" ValidationGroup="TicketReply" CssClass="button"
                                Text="<%$ Resources: _Tickets, ContentText_ReplyToTicket %>" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </asp:PlaceHolder>
        </div>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgSave" runat="server" AssociatedUpdatePanelID="updSaveChanges">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
<asp:UpdateProgress ID="prgAddReply" runat="server" AssociatedUpdatePanelID="updAddReply">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
