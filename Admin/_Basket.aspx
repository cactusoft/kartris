<%@ Page Title="" Language="VB" MasterPageFile="~/Skins/Admin/Template.master" AutoEventWireup="false" CodeFile="_Basket.aspx.vb" Inherits="admin_Basket" %>
<%@ Register TagPrefix="_user" TagName="BasketView" Src="~/UserControls/Back/_BasketView.ascx" %>
<asp:Content ID="Content1" ContentPlaceHolderID="phdHead" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="phdMain" Runat="Server">
    <h1>
        <asp:Literal ID="litTitle" runat="server" Text='<% $Resources: Basket, PageTitle_ShoppingBasket %>'></asp:Literal></h1>
    <_user:BasketView ID="UC_BasketMain" runat="server" ViewType="MAIN_BASKET" />
    <%--<div class="basket">
        <asp:PlaceHolder ID="phdSectionLinks" runat="server">
            <div class="links">
                <div>
                    <a href="Customer.aspx?action=savebasket" class="link2 icon_save">
                        <asp:Literal ID="litSaveRecoverBasketContents" runat="server" Text='<%$ Resources: Basket, PageTitle_SaveRecoverBasketContents %>'></asp:Literal></a>
                    <p>
                        <asp:Literal ID="litSaveRecoverBasket3" runat="server" Text='<%$ Resources: Basket, ContentText_SaveRecoverBasketDesc %>'></asp:Literal></p>
                </div>
                <div>
                    <a href="Customer.aspx?action=home" class="link2 icon_myaccount">
                        <asp:Literal ID="litMyAccountTitle" runat="server" Text='<%$ Resources: Kartris, PageTitle_MyAccount %>'></asp:Literal></a>
                    <p>
                        <asp:Literal ID="litMyAccount3" runat="server" Text='<%$ Resources: Basket, ContentText_MyAccountDesc %>'></asp:Literal></p>
                </div>
                <%If KartSettingsManager.GetKartConfig("frontend.users.wishlists.enabled") <> "n" Then%>
                <div>
                    <a href="Customer.aspx?action=wishlists" class="link2 icon_wishlist">
                        <asp:Literal ID="litSaveWishListTitle" runat="server" Text='<%$ Resources:Basket, ContentText_SaveWishList %>'></asp:Literal></a>
                    <p>
                        <asp:Literal ID="litSaveWishList3" runat="server" Text='<%$ Resources:Basket, ContentText_SaveWishListDesc %>'></asp:Literal></p>
                </div>
                <%End If%>
            </div>
        </asp:PlaceHolder>
    </div>--%>
    <user:PopupMessage ID="UC_PopUpErrors" runat="server" />
</asp:Content>

