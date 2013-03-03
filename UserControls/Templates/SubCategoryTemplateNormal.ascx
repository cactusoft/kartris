<%@ Control Language="VB" AutoEventWireup="false" CodeFile="SubCategoryTemplateNormal.ascx.vb"
    Inherits="SubCategoryTemplateNormal" %>
<!-- subcat normal template start -->
<div class="item">
    <div class="box">
        <div class="pad">
            <div class="imageblock">
                <user:ImageViewer ID="UC_ImageView" runat="server" EnableViewState="False" />
            </div>
            <div class="details">
                <asp:Literal EnableViewState="true" ID="litCategoryID" runat="server" Visible="false"
                    Text='<%# Eval("CAT_ID") %>'></asp:Literal>
                <h2>
                    <asp:HyperLink EnableViewState="false" ID="lnkCategoryName" runat="server" Text='<%# Server.HtmlEncode(Eval("CAT_Name")) %>'></asp:HyperLink></h2>
                <asp:Literal EnableViewState="false" ID="litCategoryDescHidden" runat="server" Text='<%# Eval("CAT_Desc") %>'
                    Visible="false"></asp:Literal>
                <p class="description">
                    <asp:Literal EnableViewState="false" ID="litCategoryDesc" runat="server"></asp:Literal>
                </p>
                <p>
                    <asp:HyperLink EnableViewState="false" ID="lnkMore" runat="server" CssClass="link2"
                        NavigateUrl='<%# Eval("CAT_ID", "~/category.aspx?CategoryID={0}") %>' Text="<%$ Resources: Products, ContentText_ViewProductMoreDetail %>" /></p>
            </div>
        </div>
    </div>
</div>
<!-- subcat normal template end -->
