<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductTemplateShortened.ascx.vb"
    Inherits="ProductTemplateShortened" %>
<!-- template start -->
<div class="item">
    <div class="box">
        <div class="pad">
            <asp:Literal EnableViewState="false" ID="litProductID" runat="server" Visible="false" Text='<%# Eval("P_ID") %>'></asp:Literal>
            <user:ImageViewer ID="UC_ImageView" runat="server" EnableViewState="False" />
            <h2>
                <asp:HyperLink EnableViewState="false" ID="lnkProductName" runat="server" NavigateUrl='<%# Eval("P_ID", "~/Product.aspx?ProductID={0}") %>'
                    Text='<%# DisplayProductName() %>'></asp:HyperLink></h2>
            <%--            <% If Len(litStrapLine.Text) > 0 Then %>
                <em class="strapline">
                    <asp:Literal ID="litStrapLine" runat="server" Text='<%#Eval("P_StrapLine")%>'></asp:Literal>
                </em>
            <% End if %>--%>
            <div class="minprice" EnableViewState="false" id="divPrice" runat="server" visible='<%# Iif( ObjectConfigBLL.GetValue("K:product.callforprice", Eval("P_ID")) = 1 OrElse Not String.IsNullOrEmpty(ObjectConfigBLL.GetValue("K:product.customcontrolname", Eval("P_ID"))), False, True) %>'>
                <asp:Literal EnableViewState="false" ID="litPriceFrom" runat="server" Text="<%$ Resources:Products,ContentText_ProductPriceFrom %>"></asp:Literal>
                <asp:Literal EnableViewState="false" ID="litPriceHidden" runat="server" Text='<%# Eval("MinPrice") %>' Visible="false" />
                <asp:Literal EnableViewState="false" ID="litPriceView" runat="server" />
            </div>
        </div>
    </div>
</div>
<!-- template end -->
