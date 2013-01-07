<%@ Page Title="" Language="VB" MasterPageFile="~/Skins/Admin/Template.master" AutoEventWireup="false"
    CodeFile="_SupportTickets.aspx.vb" Inherits="Admin_SupportTickets" %>

<%@ Register TagPrefix="_user" TagName="EditTicket" Src="~/UserControls/Back/_EditTicket.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_supporttickets">
        <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
            <contenttemplate>
                <h1>
                    <asp:Literal ID="litPageTitleSupportTickets" runat="server" Text="<%$ Resources: _Tickets, PageTitle_SupportTickets %>" /></h1>
                    <asp:PlaceHolder ID="phdFeatureDisabled" runat="server" Visible="false">
            <div class="warnmessage">
                <asp:Literal ID="litFeatureDisabled" runat="server" />
                <asp:HyperLink ID="lnkEnableFeature" runat="server" Text="<%$ Resources: _Kartris, ContentText_ConfigChange2 %>"
                    NavigateUrl="~/Admin/_Config.aspx?name=frontend.supporttickets.enabled" CssClass="linkbutton icon_edit" />
            </div>
        </asp:PlaceHolder>
                <asp:MultiView ID="mvwTickets" runat="server" ActiveViewIndex="0">
                    <asp:View ID="viwTickets" runat="server">
                        <div class="searchboxrow">
                            <asp:Panel ID="pnlFind" runat="server" DefaultButton="btnFind">
                                <div class="floatright">
                                    <asp:HyperLink ID="lnkAwaitingResponse" runat="server" CssClass="linkbutton icon_edit" NavigateUrl="~/Admin/_SupportTickets.aspx?s=w">
                                        <asp:Literal ID="litContentTextWaiting" runat="server" Text="<%$ Resources: _Tickets, ContentText_AwaitingResponse %>" />
                                        <asp:Literal ID="litAwaitingResponse" runat="server" /></asp:HyperLink>
                                </div>
                                <asp:TextBox runat="server" ID="txtSearchStarting" MaxLength="100" />
                                <asp:DropDownList CssClass="short" ID="ddlLanguages" runat="server" AutoPostBack="true"
                                        DataTextField="LANG_BackName" DataValueField="LANG_ID" />
                                <asp:Button ID="btnFind" runat="server" Text="<%$ Resources:_Kartris, FormButton_Search %>"
                                    CssClass="button" />
                                <asp:Button ID="btnClear" runat="server" CssClass="button cancelbutton" Text='<%$ Resources:_Kartris, ContentText_Clear %>' />
                                <div>
                                    <br />
                                    <!-- Assigned To -->
                                    <asp:Label ID="litAssigedTo" CssClass="nolabelwidth" runat="server" Text="<%$ Resources:_Tickets, ContentText_AssignedTo %>"
                                        AssociatedControlID="ddlAssignedLogin" />
                                    <asp:DropDownList ID="ddlAssignedLogin" runat="server" CssClass="midtext" AutoPostBack="true">
                                    </asp:DropDownList>
                                    <!-- My Back End UserID -->
                                    <% 'We have had some problems using Session("_UserID")
                                        'in controls after a postback has occurred; the 
                                        'value seems to be lost. To make sure we know the
                                        'ID of the present admin, we store it in a hidden
                                        'field here. We reference this instead. %>
                                    <asp:HiddenField ID="hidPresentAdminUserID" runat="server" />
                                    <!-- Type -->
                                    <asp:Label ID="litType" CssClass="nolabelwidth" runat="server" Text="<%$ Resources:_Kartris, ContentText_Type %>"
                                        AssociatedControlID="ddlTicketType" />
                                    <asp:DropDownList ID="ddlTicketType" runat="server" CssClass="midtext" AutoPostBack="true">
                                    </asp:DropDownList>
                                    <!-- Status -->
                                    <asp:Label ID="lblStatus" CssClass="nolabelwidth" runat="server" Text="<%$ Resources:_Kartris, ContentText_Status %>"
                                        AssociatedControlID="ddlTicketStatus" />
                                    <asp:DropDownList ID="ddlTicketStatus" runat="server" CssClass="midtext" AutoPostBack="true">
                                        <asp:ListItem Text="<%$ Resources: _Kartris, BackMenu_SearchAll %>" Value="a" />
                                        <asp:ListItem Text="<%$ Resources: _Tickets, ContentText_OpenStatus %>" Value="o" />
                                        <asp:ListItem Text="<%$ Resources: _Tickets, ContentText_ClosedStatus %>" Value="c" />
                                        <asp:ListItem Text="<%$ Resources: _Tickets, ContentText_AwaitingResponse %>" Value="w" />
                                        <asp:ListItem Text="<%$ Resources: _Tickets, ContentText_UnresolvedStatus %>" Value="u" />
                                        <asp:ListItem Text="<%$ Resources: _Tickets, ContentText_NotSureStatus %>" Value="n" />
                                    </asp:DropDownList>
                                    <!-- Customer -->
                                    <asp:Label ID="litUser" CssClass="nolabelwidth" runat="server" Text='<%$ Resources:_Kartris, ContentText_Customer %>'
                                        AssociatedControlID="txtUser" />
                                    <asp:TextBox ID="txtUser" runat="server" MaxLength="100" CssClass="midtext" AutoPostBack="true" />
                                </div>
                            </asp:Panel>
                            <br />
                        </div>
                        <asp:UpdatePanel ID="updTickets" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:Literal ID="litListingType" runat="server" Visible="false" />
                                <asp:GridView CssClass="kartristable" ID="gvwTickets" runat="server" AllowPaging="True"
                                    AutoGenerateColumns="False" DataKeyNames="TIC_ID" AutoGenerateEditButton="False"
                                    GridLines="None" PagerSettings-PageButtonCount="10" PageSize="15">
                                    <Columns>
                                        <asp:BoundField DataField="TIC_ID" HeaderText="<%$ Resources: _Kartris, ContentText_ID %>"
                                            ItemStyle-CssClass="idfield">
                                            <HeaderStyle />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="DateOpened" HeaderText="<%$ Resources: _Tickets, ContentText_DateOpened %>"
                                            Visible="False">
                                            <HeaderStyle />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="LastMessage" HeaderText="<%$ Resources: _Tickets, ContentText_ReplyToTicket %>"
                                            ItemStyle-CssClass="datefield">
                                            <HeaderStyle />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="TIC_Subject" HeaderText="<%$ Resources: _Tickets, ContentText_TicketSubject %>"
                                            ItemStyle-CssClass="bold">
                                            <HeaderStyle />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="LOGIN_UserName" HeaderText="<%$ Resources: _Tickets, ContentText_AssignedTo %>"
                                            ItemStyle-CssClass="bold">
                                            <HeaderStyle />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="U_EmailAddress" HeaderText="User" ItemStyle-CssClass="valuefield">
                                            <HeaderStyle />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="STT_Name" HeaderText="<%$ Resources: _Kartris, ContentText_Type %>"
                                            Visible="False">
                                            <HeaderStyle />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="LOGIN_Username" HeaderText="Admin" Visible="False">
                                            <HeaderStyle />
                                        </asp:BoundField>
                                        <asp:TemplateField ItemStyle-CssClass="selectfield">
                                            <ItemTemplate>
                                                <asp:Literal ID="litTicketStatus" runat="server" Visible="false" Text='<%# Eval("TIC_Status") %>' />
                                                <asp:Literal ID="litAwaitingResponse" runat="server" Visible="false" Text='<%# Eval("TIC_AwaitingResponse") %>' />
                                                <asp:Literal ID="litLoginID" runat="server" Visible="false" Text='<%# Eval("TIC_LoginID") %>' />
                                                <asp:LinkButton ID="selectbutton" runat="server" CommandName="edit_ticket" CommandArgument='<%# Eval("TIC_ID") %>'
                                                    CssClass="linkbutton icon_edit" Text='<%$ Resources: _Kartris, FormButton_Edit %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                    <EmptyDataTemplate>
                                        <div class="noresults">
                                            <asp:Literal ID="litNoTickets" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" /></div>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                                <br />
                                <asp:Panel ID="pnlNoTickets" runat="server" CssClass="noresults" Visible="false">
                                    <asp:Literal ID="litNoTickets" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" /></asp:Panel>
                                <asp:Panel ID="pnlTicketColors" runat="server" CssClass="infomessage">
                                    <asp:Literal ID="litTicketColors" runat="server" Text="<%$ Resources: _Tickets, ContentText_TicketColors %>" />
                                </asp:Panel>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </asp:View>
                    <asp:View ID="viwEditTicket" runat="server">
                        <asp:UpdatePanel ID="updBack" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:LinkButton ID="lnkBtnShowTicketsList" runat="server" CssClass="linkbutton icon_back floatright"
                                    Text='<%$ Resources: _Kartris, ContentText_BackLink %>' />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                        <div class="spacer">
                        </div>
                        <_user:EditTicket ID="_UC_EditTicket" runat="server" />
                    </asp:View>
                </asp:MultiView>
            </contenttemplate>
        </asp:UpdatePanel>
        <asp:UpdateProgress ID="prgTickets" runat="server" AssociatedUpdatePanelID="updTickets">
            <progresstemplate>
                <div class="loadingimage">
                </div>
                <div class="updateprogress">
                </div>
            </progresstemplate>
        </asp:UpdateProgress>
        <asp:UpdateProgress ID="prgBack" runat="server" AssociatedUpdatePanelID="updBack">
            <progresstemplate>
                <div class="loadingimage">
                </div>
                <div class="updateprogress">
                </div>
            </progresstemplate>
        </asp:UpdateProgress>
    </div>
</asp:Content>
