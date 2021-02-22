<%@ Control Language="VB" AutoEventWireup="false" CodeFile="LoginStatus.ascx.vb"
    Inherits="UserControls_Skin_LoginStatus" %>
<div id="loginstatus" class="hovermenu_holder">
    <% '----------Logged in--------- %>
    <asp:PlaceHolder ID="phdLoggedIn" runat="server" Visible="False">
        <asp:HyperLink NavigateUrl="~/Customer.aspx?action=home" ID="lnkMyAccount" runat="server" CssClass="loginbutton loggedin">
            <i class="fas fa-user-check"></i>
        </asp:HyperLink>
        <span id="username"><strong>
            <asp:LoginName ID="KartrisLoginName" FormatString="{0}" runat="server" />
        </strong></span>
        <div id="account_menu" class="hide hovermenu">
            <div class="box">
                <ul>
                    <li>
                        <asp:HyperLink NavigateUrl="~/Customer.aspx?action=home" ID="lnkMyAccountMenuLink" runat="server" CssClass="button" Text="<%$ Resources: Kartris, PageTitle_MyAccount %>"></asp:HyperLink></li>
                    <li>
                        <asp:HyperLink NavigateUrl="~/Customer.aspx?action=details" ID="lnkChangeDetails" runat="server" CssClass="button" Text="<%$ Resources: Kartris, ContentText_ChangeCustomerCode %>"></asp:HyperLink></li>
                    <li>
                        <asp:HyperLink NavigateUrl="~/Customer.aspx?action=addresses" ID="lnkManageAddresses" runat="server" CssClass="button" Text="<%$ Resources: Address, ContentText_ManageAddresses %>"></asp:HyperLink></li>
                    <li>
                        <asp:HyperLink NavigateUrl="~/Customer.aspx?action=password" ID="lnkChangePassword" runat="server" CssClass="button" Text="<%$ Resources: Kartris, ContentText_CustomerCode %>"></asp:HyperLink></li>
                    <li>
                        <asp:HyperLink NavigateUrl="~/CustomerTickets.aspx" ID="lnkSupportTickets" runat="server" CssClass="button" Text="<%$ Resources: Tickets, PageTitle_SupportTickets %>"></asp:HyperLink></li>
                    <li>
                        <asp:LoginStatus ID="KartrisLoginStatus2" runat="server" CssClass="button"
                            LoginText="" LogoutText='<%$ Resources: Kartris, ContentText_LogMeOut %>' LogoutAction="Redirect"
                            LogoutPageUrl="~/CustomerAccount.aspx" />
                    </li>
                </ul>
            </div>
        </div>
    </asp:PlaceHolder>
    <% '---------Not logged in--------- %>
    <asp:PlaceHolder ID="phdLoggedOut" runat="server" Visible="False">
        <asp:HyperLink ID="lnkLogin" runat="server" NavigateUrl="~/CustomerAccount.aspx" CssClass="loginbutton loggedout">
            <i class="fas fa-user"></i>
            <span class="icontext">
                <asp:Literal ID="litContentTextLogin" runat="server" Text='<%$ Resources: Kartris, PageTitle_LogInToSite %>' />
            </span>
        </asp:HyperLink>
        <span id="statuslabel">
            <asp:Literal ID="litContentTextNotLoggedIn" runat="server" Text="<%$ Resources: Kartris, ContentText_NotLoggedIn %>"></asp:Literal>
        </span>
    </asp:PlaceHolder>

</div>
