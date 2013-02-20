<%@ Page Title="" Language="VB" MasterPageFile="~/Skins/Admin/Template.master" AutoEventWireup="false" CodeFile="_Basket.aspx.vb" Inherits="admin_Basket" %>
<%@ Register TagPrefix="_user" TagName="BasketView" Src="~/UserControls/Back/_BasketView.ascx" %>
<asp:Content ID="Content1" ContentPlaceHolderID="phdHead" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="phdMain" Runat="Server">
    <h1>
        <asp:Literal ID="litTitle" runat="server" Text='<% $Resources: Basket, PageTitle_ShoppingBasket %>'></asp:Literal></h1>
    <_user:BasketView ID="UC_BasketMain" runat="server" ViewType="MAIN_BASKET" />
    <user:PopupMessage ID="UC_PopUpErrors" runat="server" />
</asp:Content>

