<%@ Control Language="VB" AutoEventWireup="false" CodeFile="TicketDetails.ascx.vb"
    Inherits="UserControls_Front_TicketDetails" %>
<%@ Register TagPrefix="user" TagName="AnimatedText" Src="~/UserControls/General/AnimatedText.ascx" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <!-- ticket overview -->
        <div class="Kartris-DetailsView">
            <div class="Kartris-DetailsView-Data">
                <ul>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litContentTextTicket" runat="server" Text="<%$ Resources:Tickets, ContentText_Ticket %>" /></span><span
                            class="Kartris-DetailsView-Value">#<asp:Literal ID="litTicketID" runat="server" /></span></li>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litContentTextTicketSubject" runat="server" Text="<%$ Resources:Tickets, ContentText_TicketSubject %>" />
                    </span><span class="Kartris-DetailsView-Value"><strong>
                        <asp:Literal Mode="Encode" ID="litTicketSubject" runat="server"></asp:Literal></strong></span></li>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litContentTextOpened" runat="server" Text="<%$ Resources:Tickets, ContentText_TicketOpened %>" />
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:Literal ID="litOpened" runat="server"></asp:Literal></span></li>
                </ul>
            </div>
        </div>
        <!-- ticket responses -->
        <div class="section">
            <asp:Repeater ID="rptTicket" runat="server">
                <ItemTemplate>
                    <asp:Panel ID="pnlMessage" runat="server" CssClass='<%# Eval("CssStyle") %>'>
                        <!--
                        IMPORTANT - ensure no space or line breaks between the P tag and Literals below, otherwise the PRE
                        CSS formatting on this section will show it as white-space.
                        --> 
                        <p class="details"><asp:Literal ID="litMessageFrom" runat="server" Text='<%# Eval("MessageHeader") %>' /></p>
                        <p class="message"><asp:Literal ID="litMessageContents" runat="server" Text='<%# Eval("STM_Text") %>' Mode="Encode" /></p>
                    </asp:Panel>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <!-- add response -->
        <asp:MultiView ID="mvwStatus" runat="server" ActiveViewIndex="0">
            <asp:View ID="viwNotClosed" runat="server">
                <div class="Kartris-DetailsView">
                    <div class="Kartris-DetailsView-Data">
                        <ul>
                            <li><span class="Kartris-DetailsView-Name">
                                <asp:Label ID="lblTicketMessage" runat="server" Text="<%$ Resources:ContactUs, ContentText_YourMessageComments %>"
                                    AssociatedControlID="txtTicketMessage" CssClass="requiredfield"></asp:Label><asp:RequiredFieldValidator Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                    ID="valTicketMessage" runat="server" ControlToValidate="txtTicketMessage" ValidationGroup="TicketForm"
                                    CssClass="error" ForeColor=""></asp:RequiredFieldValidator></span>
                                <asp:TextBox ID="txtTicketMessage" runat="server" TextMode="MultiLine" MaxLength="8000" />
                                </li>
                            <li>
                                <asp:UpdatePanel ID="updAddTicket" runat="server" UpdateMode="Conditional" RenderMode="Inline">
                                    <ContentTemplate>
                                        <asp:Button ID="btnAddReply" runat="server" ValidationGroup="TicketForm" CssClass="button"
                                            Text="<%$ Resources:Kartris, FormButton_Submit %>" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </li>
                        </ul>
                    </div>
                </div>
                <user:AnimatedText runat="server" ID="UC_Updated" />
            </asp:View>
            <!-- ticket closed -->
            <asp:View ID="viwClosed" runat="server">
                <strong>
                    <asp:Literal ID="litClosed" runat="server"></asp:Literal></strong>
            </asp:View>
        </asp:MultiView>
    </ContentTemplate>
</asp:UpdatePanel>
