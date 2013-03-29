<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductLinkTemplate.ascx.vb" Inherits="Templates_ProductLinkTemplate" %>
<!-- product link template start -->
<div class="item">
    <div class="box">
        <div class="pad">
            <asp:Literal EnableViewState="false" ID="litProductID" runat="server" Visible="false" Text='<%# Eval("P_ID") %>'></asp:Literal>
            <div class="imageblock">
                <user:ImageViewer ID="UC_ImageView" runat="server" EnableViewState="False" />
            </div>
            <div class="details">
                <h2>
                    <asp:HyperLink EnableViewState="false" ID="lnkProductName" runat="server" NavigateUrl='<%# Eval("P_ID", "~/Product.aspx?ProductID={0}") %>'
                        Text='<%# DisplayProductName() %>'></asp:HyperLink></h2>
            </div>
        </div>
    </div>
</div>
<!-- product link template end -->