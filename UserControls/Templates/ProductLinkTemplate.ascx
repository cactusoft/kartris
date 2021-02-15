<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductLinkTemplate.ascx.vb" Inherits="Templates_ProductLinkTemplate" %>
<!-- product link template start -->
<div class="box item loadspinner">
    <div class="pad">
        <asp:Literal ID="litProductID" runat="server" Visible="false" Text='<%# Eval("P_ID") %>'></asp:Literal>
        <div class="imageblock">
            <user:ImageViewer ID="UC_ImageView" runat="server" EnableViewState="False" />
        </div>
        <asp:HyperLink ID="lnkProductName" runat="server" NavigateUrl='<%# Eval("P_ID", "~/Product.aspx?ProductID={0}") %>' CssClass="details">
            <h2>
                <asp:Literal ID="litProductName" runat="server" Text='<%# DisplayProductName() %>'></asp:Literal></h2>
        </asp:HyperLink>
    </div>
</div>
<!-- product link template end -->
