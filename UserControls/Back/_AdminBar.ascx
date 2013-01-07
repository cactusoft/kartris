<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_AdminBar.ascx.vb" Inherits="UserControls_Back_AdminBar" %>

<asp:UpdatePanel ID="updAdminBar" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <span id="adminbar" class="squarebuttons bluebuttons">
            <asp:HyperLink ID="lnkFront" runat="server" ToolTip="<%$ Resources: _Kartris, BackMenu_Front %>"
                NavigateUrl="~/Default.aspx" CssClass="adminbutton"></asp:HyperLink>
        </span>
    </ContentTemplate>
</asp:UpdatePanel>

