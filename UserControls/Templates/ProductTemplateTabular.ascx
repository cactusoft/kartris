<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductTemplateTabular.ascx.vb" Inherits="ProductTemplateTabular" %>
<!-- product tabular template start -->
<div class="item">
    <div class="box">
        <div class="pad">
            <asp:Literal ID="litProductID" runat="server" Visible="false" Text='<%# Eval("P_ID") %>'></asp:Literal>
            <div class="imageblock">
                <user:ImageViewer ID="UC_ImageView" runat="server" EnableViewState="False" />
            </div>
            <div class="details">
                <h2>
                    <asp:HyperLink ID="lnkProductName" runat="server" NavigateUrl='<%# Eval("P_ID", "~/Product.aspx?ProductID={0}") %>'
                        Text='<%# DisplayProductName() %>'></asp:HyperLink></h2>
                <div class="minprice" EnableViewState="true" id="divPrice" runat="server" visible='<%# Iif( ObjectConfigBLL.GetValue("K:product.callforprice", Eval("P_ID")) = 1 OrElse Not String.IsNullOrEmpty(ObjectConfigBLL.GetValue("K:product.customcontrolname", Eval("P_ID"))), False, True) %>'>
                    <asp:Literal ID="litPriceFrom" runat="server" Text="<%$ Resources:Products,ContentText_ProductPriceFrom %>"></asp:Literal>
                    <asp:Literal ID="litPriceHidden" runat="server" Text='<%# Eval("MinPrice") %>' Visible="false" />
                    <asp:Literal ID="litPriceView" runat="server" />
                </div>
            </div>
        </div>
    </div>
</div>
<!-- product tabular template end -->