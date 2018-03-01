<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductTemplateImageOnly.ascx.vb"
    Inherits="ProductTemplateImageOnly" %>
<!-- product image only -->
<div class="item loadspinner">
    <div class="box" title='<%# Server.HtmlEncode(Eval("P_Name")) %>' style='height: <% =KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.height") %>px;
    width: <%=KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.width") %>px; max-width: 100%; max-height: 100%;'>
        <asp:Literal ID="litProductID" runat="server" Visible="false" Text='<%# Eval("P_ID") %>'></asp:Literal>
        <asp:Literal ID="litVersionID" runat="server" Visible="false" Text='<%# Eval("VersionID") %>'></asp:Literal>
        <asp:Literal ID="litP_Name" runat="server" Visible="false" Text='<%# Server.HtmlEncode(Eval("P_Name")) %>'></asp:Literal>
        <asp:Literal ID="litImage" runat="server" Text='<%# CreateImageTag %>'></asp:Literal>
    </div>
</div>
<!-- product image only -->
