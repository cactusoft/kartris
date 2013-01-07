<%@ Page Title="" Language="VB" MasterPageFile="~/Skins/Kartris/Template.master"
    AutoEventWireup="false" CodeFile="CustomerTickets.aspx.vb" Inherits="CustomerTickets"
    ValidateRequest="false" %>

<%@ Register TagPrefix="user" TagName="KartrisLogin" Src="~/UserControls/Front/KartrisLogin.ascx" %>
<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <div id="supporttickets">
        <asp:MultiView ID="mvwMain" runat="server" ActiveViewIndex="0">
            <asp:View ID="viwExist" runat="server">
                <user:BreadCrumbTrail ID="UC_BreadCrumbTrail" runat="server" EnableViewState="False" />
                <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <h1>
                            <asp:Literal ID="litPageTitleSupportTickets" runat="server" Text="<%$ Resources:Tickets, PageTitle_SupportTickets %>" /></h1>
                        <asp:Label ID="lblSupportExpirationMessage" runat="server" Text="" Visible="false"
                            CssClass="expirywarning" />
                        <asp:MultiView ID="mvwTickets" runat="server" ActiveViewIndex="0">
                            <asp:View ID="viwLogin" runat="server">
                                <div>
                                    <user:KartrisLogin runat="server" ID="UC_KartrisLogin" ForSection="support" />
                                </div>
                            </asp:View>
                            <asp:View ID="viwTickets" runat="server">
                                <p>
                                    <asp:Literal ID="litContentTextSupportTicketExplanation" runat="server" Text="<%$ Resources:Tickets, ContentText_SupportTicketExplanation %>" /></p>
                                <asp:LinkButton ID="btnOpenTicket" runat="server" CssClass="linkbutton link2 floatright"
                                    Text="<%$ Resources: Kartris, ContentText_AddNew %>" />
                                <asp:GridView CssClass="filled" ID="gvwTickets" runat="server" AllowPaging="True"
                                    AutoGenerateColumns="False" DataKeyNames="TIC_ID" AutoGenerateEditButton="False"
                                    GridLines="None" PagerSettings-PageButtonCount="10" PageSize="15">
                                    <Columns>
                                        <asp:BoundField DataField="TIC_ID" HeaderText="<%$ Resources: Kartris, ContentText_SmallNumber %>"
                                            ItemStyle-CssClass="idfield">
                                            <HeaderStyle />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="TIC_Subject" HeaderText="<%$ Resources:Tickets, ContentText_TicketSubject %>"
                                            ItemStyle-CssClass="subject">
                                            <HeaderStyle />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="DateOpened" HeaderText="<%$ Resources:Tickets, ContentText_TicketOpened %>"
                                            ItemStyle-CssClass="opened">
                                            <HeaderStyle />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="DateClosed" HeaderText="<%$ Resources:Tickets, ContentText_TicketClosed %>"
                                            ItemStyle-CssClass="closed">
                                            <HeaderStyle />
                                        </asp:BoundField>
                                        <asp:TemplateField ItemStyle-CssClass="selectfield">
                                            <ItemTemplate>
                                                <%--<asp:LinkButton ID="selectbutton" runat="server" CommandName="view" CommandArgument='<%# Eval("TIC_ID") %>'
                                            CssClass="link2" Text='<%$ Resources:Kartris, ContentText_View %>' />--%>
                                                <asp:Literal ID="litAwaitingReply" runat="server" Visible="false" Text='<%# Eval("TIC_AwaitingReplay") %>' />
                                                <asp:HyperLink runat="server" ID="lnkView" NavigateUrl='<%# FormatURL(Eval("TIC_ID")) %>'
                                                    Text='<%$ Resources:Kartris, ContentText_View %>' CssClass="link2"></asp:HyperLink>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                    <EmptyDataTemplate>
                                        <p>
                                            -</p>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </asp:View>
                            <asp:View ID="viwTicketDetails" runat="server">
                                <asp:HyperLink ID="lnkBack" Visible="true" CssClass="link2 floatright" NavigateUrl="CustomerTickets.aspx"
                                    runat="server" Text="<%$ Resources:Kartris, ContentText_GoBack  %>" />
                                <div class="spacer">
                                </div>
                                <user:TicketDetails ID="UC_TicketDetails" runat="server" />
                            </asp:View>
                            <asp:View ID="viwWriteTicket" runat="server">
                                <user:WriteTicketTemplate ID="UC_WriteTicket" runat="server" />
                            </asp:View>
                        </asp:MultiView>
                    </ContentTemplate>
                </asp:UpdatePanel>
                <asp:UpdateProgress ID="prgMain" runat="server" AssociatedUpdatePanelID="updMain"
                    DynamicLayout="true" DisplayAfter="10">
                    <ProgressTemplate>
                        <div class="loadingimage">
                        </div>
                        <div class="updateprogress">
                        </div>
                    </ProgressTemplate>
                </asp:UpdateProgress>
            </asp:View>
            <asp:View ID="viwNotExist" runat="server">
                <p>
                    <asp:Literal ID="litContentTextNotAvailable" runat="server" Text="<%$ Resources: Kartris, ContentText_ContentNotAvailable %>" /></p>
            </asp:View>
        </asp:MultiView>
    </div>
</asp:Content>
