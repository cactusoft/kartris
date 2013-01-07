<%@ Control Language="VB" AutoEventWireup="false" CodeFile="Page.ascx.vb" Inherits="UserControls_Front_Page" %>
<div id="custompagetext">
    <asp:Repeater ID="rptPage" runat="server">
        <ItemTemplate>
            <asp:Literal ID="litText" runat="server" Text='<%# Eval("PAGE_Text") %>'></asp:Literal>
        </ItemTemplate>
    </asp:Repeater>
    <asp:Literal ID="litContentTextContentNotAvailable"
    runat="server" Text='<%$ Resources: Kartris, ContentText_ContentNotAvailable %>'
    visible="false"></asp:Literal>
</div>
