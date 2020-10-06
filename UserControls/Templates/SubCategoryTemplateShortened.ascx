<%@ Control Language="VB" AutoEventWireup="false" CodeFile="SubCategoryTemplateShortened.ascx.vb" Inherits="SubCategoryTemplateShortened" %>
<!-- subcat shortened template start -->
<div class="box item loadspinner">
    <div class="pad">
        <asp:Literal ID="litCategoryID" runat="server" Visible="false" Text='<%# Eval("CAT_ID") %>'></asp:Literal>
        
        <div class="imageblock"><user:ImageViewer ID="UC_ImageView" runat="server" EnableViewState="False" /></div>
        <asp:HyperLink ID="lnkCategoryName" runat="server" Text='<%# "<h2>" & Server.HtmlEncode(Eval("CAT_Name")) & "</h2>" %>' CssClass="details"></asp:HyperLink>

        <asp:Literal ID="litCategoryDescHidden" runat="server" Text='<%# Eval("CAT_Desc") %>' Visible="false"></asp:Literal>
    </div>
</div>
<!-- subcat shortened template end -->
