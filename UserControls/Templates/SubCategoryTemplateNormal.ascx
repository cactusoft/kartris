<%@ Control Language="VB" AutoEventWireup="false" CodeFile="SubCategoryTemplateNormal.ascx.vb"
    Inherits="SubCategoryTemplateNormal" %>
<!-- subcat normal template start -->
<div class="item">
    <div class="box">
        <div class="pad row">
            <div class="imageblock small-12 medium-4 large-3 columns">
                <user:ImageViewer ID="UC_ImageView" runat="server" EnableViewState="False" />
            </div>
            <div class="details small-12 medium-8 large-9 columns">
                <asp:Literal ID="litCategoryID" runat="server" Visible="false"
                    Text='<%# Eval("CAT_ID") %>'></asp:Literal>
                <h2>
                    <asp:HyperLink ID="lnkCategoryName" runat="server" Text='<%# Server.HtmlEncode(Eval("CAT_Name")) %>'></asp:HyperLink></h2>
                <asp:Literal ID="litCategoryDescHidden" runat="server" Text='<%# Eval("CAT_Desc") %>'
                    Visible="false"></asp:Literal>
                <p class="description">
                    <asp:Literal ID="litCategoryDesc" runat="server"></asp:Literal>
                </p>
                <p>
                    <asp:HyperLink ID="lnkMore" runat="server" CssClass="link2"
                        NavigateUrl='<%# Eval("CAT_ID", "~/category.aspx?CategoryID={0}") %>' Text="<%$ Resources: Products, ContentText_ViewProductMoreDetail %>" /></p>
            </div>
        </div>
    </div>
</div>
<!-- subcat normal template end -->
