<%@ Page Language="VB" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="false"
    CodeFile="CustomerViewOrder.aspx.vb" Inherits="Customer_ViewOrder" %>

<%@ Register TagPrefix="user" TagName="CustomerOrder" Src="~/UserControls/Front/CustomerOrder.ascx" %>
<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <user:PopupMessage ID="UC_PopUp" runat="server" />
    <asp:PlaceHolder ID="phdOrderStatus" runat="server">
        <div id="customer">
            <user:BreadCrumbTrail ID="UC_BreadCrumbTrail" runat="server" EnableViewState="False" />
            <h1>
                <asp:Literal ID="litPageTitleOrderStatus" runat="server" Text='<%$ Resources: Kartris, PageTitle_OrderStatus %>' /></h1>
            <user:CustomerOrder ID="UC_CustomerOrder" runat="server" CustomerID="0" OrderID="0" />
            <p>
                <asp:HyperLink ID="lnkBack" runat="server" NavigateUrl="~/Customer.aspx" Text='<%$ Resources: Kartris, ContentText_GoBack %>'
                    CssClass="link2 icon_back"></asp:HyperLink></p>
        </div>
    </asp:PlaceHolder>
</asp:Content>


