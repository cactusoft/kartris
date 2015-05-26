<%@ Control Language="VB" AutoEventWireup="false" CodeFile="CategoryTemplate.ascx.vb"
    Inherits="CategoryTemplate" %>
<h1>
    <asp:Literal ID="litCategoryName" runat="server" Text="<%$ Resources:Kartris, ContentText_Categories %>"></asp:Literal></h1>
<div class="spacer"></div>
<asp:PlaceHolder ID="phdCategoryDetails" runat="server" Visible="false">
    <div class="category">
        <div class="main">
            <div class="description">
                <asp:PlaceHolder ID="phdCategoryImage" runat="server">
                      <user:ImageViewer ID="UC_ImageView" runat="server" EnableViewState="True" />
                </asp:PlaceHolder>
                <asp:Literal ID="litCategoryDesc" runat="server"></asp:Literal>
            </div>
        </div>
    </div>
</asp:PlaceHolder>

