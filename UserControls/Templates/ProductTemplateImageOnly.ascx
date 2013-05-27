<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductTemplateImageOnly.ascx.vb"
    Inherits="ProductTemplateImageOnly" %>
<!-- product image only -->
<div class="item">
    <div class="box" title='<%# Server.HtmlEncode(Eval("P_Name")) %>' style='height: <% =KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.height") %>px;
    width: <%=KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.width") %>px;'>
        <asp:Literal EnableViewState="false" ID="litProductID" runat="server" Visible="false" Text='<%# Eval("P_ID") %>'></asp:Literal>
        <asp:Literal EnableViewState="false" ID="litP_Name" runat="server" Visible="false" Text='<%# Server.HtmlEncode(Eval("P_Name")) %>'></asp:Literal>
        <asp:Literal EnableViewState="false" ID="litImage" runat="server" Text='<%# CreateImageTag %>'></asp:Literal>
    </div>
</div>
<!-- product image only -->
