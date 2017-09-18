<%@ Page Language="VB" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="true"
    CodeFile="Basket.aspx.vb" Inherits="Basket" EnableSessionState="ReadOnly" %>

<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <user:BreadCrumbTrail ID="UC_BreadCrumbTrail" runat="server" EnableViewState="False" />
    <h1>
        <asp:Literal ID="litTitle" runat="server" Text='<% $Resources: Basket, PageTitle_ShoppingBasket %>'></asp:Literal></h1>
    <user:BasketView ID="UC_BasketMain" runat="server" ViewType="MAIN_BASKET" />
    <user:PopupMessage ID="UC_PopUpErrors" runat="server" />
</asp:Content>
