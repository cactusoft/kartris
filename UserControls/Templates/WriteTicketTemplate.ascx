<%@ Control Language="VB" AutoEventWireup="false" CodeFile="WriteTicketTemplate.ascx.vb" Inherits="Templates_WriteTicketTemplate" %>

<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        
        <asp:MultiView ID="mvwWriting" runat="server" ActiveViewIndex="0">
            <asp:View ID="viwWritingForm" runat="server"> 
                <p><asp:Literal ID="litContentTextSupportTicketExplanation2" Text="<%$ Resources:Tickets, ContentText_SupportTicketExplanation2 %>" runat="server"></asp:Literal></p>
                <div class="inputform">
                    <asp:UpdatePanel ID="updWritingForm" runat="server">
                        <ContentTemplate>
                            <asp:Literal ID="litUserID" runat="server" Visible="false"></asp:Literal>
                            <asp:Panel ID="pnlWriteReview" runat="server" DefaultButton="btnAddTicket">
                                <div class="Kartris-DetailsView">
                                    <div class="Kartris-DetailsView-Data">
                                        <ul>
                                            <!-- Level -->
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Label ID="lblTicketType" runat="server" Text="<%$ Resources:Tickets, ContentText_TicketType %>" AssociatedControlID="ddlTicketType"
                                                    CssClass="requiredfield"></asp:Label></span><span class="Kartris-DetailsView-Value">
                                                        <asp:DropDownList ID="ddlTicketType" runat="server" CssClass="midtext" AppendDataBoundItems="true">
                                                            <asp:ListItem Text='<%$ Resources: Kartris, ContentText_DropdownSelectDefault %>' Value="0" />
                                                        </asp:DropDownList></span>
                                                        <asp:CompareValidator ID="valCompareTicketType" runat="server" CssClass="error" ForeColor=""
                                                            ErrorMessage="<%$ Resources: Kartris, ContentText_RequiredField %>" ControlToValidate="ddlTicketType"
                                                            Operator="NotEqual" ValueToCompare="0" Display="Dynamic" SetFocusOnError="true"
                                                            ValidationGroup="TicketForm" /></li>
                                            
                                            <!-- Subject -->
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Label ID="lblSubject" runat="server" Text="<%$ Resources:Tickets, ContentText_TicketSubject %>" AssociatedControlID="txtSubject"
                                                    CssClass="requiredfield"></asp:Label></span><span class="Kartris-DetailsView-Value">
                                                        <asp:TextBox ID="txtSubject" runat="server" MaxLength="100" /></span>
                                                        <asp:RequiredFieldValidator EnableClientScript="True" ID="valTitle" runat="server"
                                                            ControlToValidate="txtSubject" ValidationGroup="TicketForm" CssClass="error"
                                                            ForeColor="" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"></asp:RequiredFieldValidator></li>
                                            <!-- Text -->
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Label ID="lblTicketMessage" runat="server" Text="<%$ Resources:ContactUs, ContentText_YourMessageComments %>" AssociatedControlID="txtTicketMessage"
                                                    CssClass="requiredfield"></asp:Label></span><span class="Kartris-DetailsView-Value">
                                                        <asp:TextBox ID="txtTicketMessage" runat="server" TextMode="MultiLine" MaxLength="4000" /></span>
                                                        <asp:RequiredFieldValidator Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                                            ID="valTicketMessage" runat="server" ControlToValidate="txtTicketMessage" ValidationGroup="TicketForm"
                                                            CssClass="error" ForeColor=""></asp:RequiredFieldValidator></li>
                                        </ul>
                                    </div>
                                    <div class="submitbuttons">
                                        <asp:UpdatePanel ID="updAddTicket" runat="server" UpdateMode="Conditional" RenderMode="Inline">
                                            <ContentTemplate>
                                                <asp:Button ID="btnAddTicket" runat="server" ValidationGroup="TicketForm" CssClass="button"
                                                    Text="<%$ Resources:Kartris, FormButton_Submit %>" />
                                                <asp:ValidationSummary ValidationGroup="TicketForm" ID="valSummary" runat="server"
                                                    CssClass="valsummary" DisplayMode="BulletList" ForeColor="" HeaderText="<%$ Resources: Kartris, ContentText_Errors %>" />
                                                <asp:Button ID="btnCancel" runat="server" CssClass="button cancel" Text="<%$ Resources:Kartris, FormButton_Cancel %>" />
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </div>
                                </div>
                            </asp:Panel>
                            <user:PopupMessage ID="popErrors" runat="server" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </asp:View>
            <asp:View ID="viwWritingResult" runat="server">
                <div class="addreview inputform">
                    <asp:Literal ID="litResult" runat="server"></asp:Literal>
                    <br /><br />
                    <asp:LinkButton ID="btnBack" Visible="true" CssClass="link2 floatright" classID="BtnBack" runat="server" Text="<%$ Resources:Kartris, ContentText_GoBack  %>" />
                </div>
            </asp:View>
        </asp:MultiView>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgMain" runat="server" AssociatedUpdatePanelID="updMain">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>