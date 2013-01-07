<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_LoginConsole.ascx.vb"
    Inherits="UserControls_Back_LoginConsole" %>
<div id="loginstatus">
    <asp:Panel ID="pnlConsole" runat="server">
        <span class="username">
            <strong>
                <asp:Literal ID="litMessage" runat="server" Text=''></asp:Literal></strong></span>
        <span class="ticks">
            <asp:Image ID="imgConfig" ImageUrl="~/Skins/Admin/Images/tick.gif" runat="server"
                ToolTip="<%$ Resources: _Logins, ImageLabel_PermConfig %>" AlternateText="<%$ Resources: _Logins, ImageLabel_PermConfig %>" /><asp:Image
                    ToolTip="<%$ Resources: _Logins, ImageLabel_PermProducts %>" AlternateText="<%$ Resources: _Logins, ImageLabel_PermProducts %>"
                    ID="imgProducts" ImageUrl="~/Skins/Admin/Images/tick.gif" runat="server" /><asp:Image
                        ToolTip="<%$ Resources: _Logins, ImageLabel_PermOrders %>" AlternateText="<%$ Resources: _Logins, ImageLabel_PermOrders %>"
                        ID="imgOrders" ImageUrl="~/Skins/Admin/Images/tick.gif" runat="server" /><asp:Image
                            ToolTip="<%$ Resources: _Logins, ImageLabel_PermSupport %>" AlternateText="<%$ Resources: _Logins, ImageLabel_PermSupport %>"
                            ID="imgSupport" ImageUrl="~/Skins/Admin/Images/tick.gif" runat="server" /></span>
        <span class="logout">
            <asp:Button ID="btnLogOut" runat="server" Text=""
                ToolTip="<%$ Resources: _Kartris, FormButton_Logout %>" CssClass="button" /></span>
    </asp:Panel>
</div>
