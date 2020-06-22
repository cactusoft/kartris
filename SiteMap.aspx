<%@ Page Language="VB" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="false"
    CodeFile="SiteMap.aspx.vb" Inherits="SiteMap" %>

<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <div>
        <h2>
            <asp:Literal EnableViewState="False" ID="litContentTextProducts" runat="server" Text="<%$ Resources: Products, ContentText_Products %>" /></h2>
        <asp:PlaceHolder ID="phdCategoryMenu" runat="server"></asp:PlaceHolder>
    </div>
    <div>
        <user:NavigationMenu ID="UC_NavigationMenu" runat="server" EnableViewState="False" />
    </div>
</asp:Content>
