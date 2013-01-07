<%@ Page Language="VB"  AutoEventWireup="false" CodeFile="_reviews.aspx.vb" Inherits="Admin_Reviews" 
MasterPageFile="~/Skins/Admin/Template.master"  %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_reviews">
        <h1>
            <asp:Literal ID="litPageTitleReviews" runat="server" Text="<%$ Resources: _Reviews, PageTitle_Reviews %>" /></h1>
        <_user:ProductReviews ID="_UC_ProductReviews" runat="server" />
    </div>
</asp:Content>
