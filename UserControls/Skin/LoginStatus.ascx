<%@ Control Language="VB" AutoEventWireup="false" CodeFile="LoginStatus.ascx.vb"
    Inherits="UserControls_Skin_LoginStatus" %>
<div id="loginstatus">
    <% '----------Logged in--------- %>
    <asp:PlaceHolder ID="phdLoggedIn" runat="server" Visible="False"><span id="statuslabel"
        runat="server">
        <asp:Literal ID="litContentTextLoginStatus" runat="server" Text="<%$ Resources: Kartris, ContentText_LoginStatus %>"></asp:Literal>
    </span><span id="username"><strong>
        <asp:LoginName ID="KartrisLoginName" FormatString="{0}" runat="server" />
    </strong></span><span class="logout">
        <asp:LoginStatus ID="KartrisLoginStatus" runat="server" CssClass="link2 icon_logout"
            LoginText="" LogoutText='<%$ Resources: Kartris, ContentText_LogMeOut %>' LogoutAction="Redirect"
            LogoutPageUrl="~/Default.aspx" />
    </span></asp:PlaceHolder>
    <% '---------Not logged in--------- %>
    <asp:PlaceHolder ID="phdLoggedOut" runat="server" Visible="False"><span id="statuslabel">
        <asp:Literal ID="litContentTextNotLoggedIn" runat="server" Text="<%$ Resources: Kartris, ContentText_NotLoggedIn %>"></asp:Literal>
    </span><span class="link2">
        <asp:HyperLink ID="lnkLogin" runat="server" NavigateUrl="~/CustomerAccount.aspx">
            <asp:Literal ID="litContentTextLogin" runat="server" Text='<%$ Resources: Kartris, PageTitle_LogInToSite %>' /></asp:HyperLink>
    </span></asp:PlaceHolder>

</div>
