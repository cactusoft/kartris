<%@ Control Language="VB" AutoEventWireup="false" CodeFile="SubCategoryTemplateText.ascx.vb" Inherits="SubCategoryTemplateText" %>
<!-- subcat text template start -->
<asp:UpdatePanel ID="updMain" runat="server">
    <ContentTemplate>
        <div class="item">
            <div class="box">
                <div class="pad">
                    <asp:Literal ID="litCategoryID" runat="server" Visible="false" Text='<%# Eval("CAT_ID") %>'></asp:Literal>
                    <h2>
                        <asp:HyperLink ID="lnkCategoryName" runat="server" Text='<%# Server.HtmlEncode(Eval("CAT_Name")) %>'></asp:HyperLink></h2>
                    <asp:Literal ID="litCategoryDescHidden" runat="server" Text='<%# Eval("CAT_Desc") %>'
                        Visible="false"></asp:Literal>
                    <p>
                        <asp:Literal ID="litCategoryDesc" runat="server"></asp:Literal>
                    </p>
                </div>
            </div>
        </div>
    </ContentTemplate>
</asp:UpdatePanel>
<!-- subcat text template end -->
