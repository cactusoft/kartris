<%@ Control Language="VB" AutoEventWireup="false" CodeFile="SubCategoryTemplateShortened.ascx.vb" Inherits="SubCategoryTemplateShortened" %>
<!-- subcat shortened template start -->
<div class="item loadspinner">
    <div class="box">
        <div class="pad">
            <asp:Literal ID="litCategoryID" runat="server" Visible="false" Text='<%# Eval("CAT_ID") %>'></asp:Literal>
            <user:ImageViewer ID="UC_ImageView" runat="server" EnableViewState="False" />      
            <h2><asp:HyperLink ID="lnkCategoryName" runat="server" Text='<%# Server.HtmlEncode(Eval("CAT_Name")) %>'></asp:HyperLink></h2>

            <asp:Literal ID="litCategoryDescHidden" runat="server" Text='<%# Eval("CAT_Desc") %>' Visible="false"></asp:Literal>
<%--            <% If Len(litCategoryDesc.Text) > 0 Then%>
                <div class="description">
                <asp:Literal ID="litCategoryDesc" runat="server"></asp:Literal>
                </div>
            <% End if %>--%>
        </div>
    </div>
</div>
<!-- subcat shortened template end -->