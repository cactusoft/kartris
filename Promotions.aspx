<%@ Page Language="VB" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="false"
    CodeFile="Promotions.aspx.vb" Inherits="Promotions" EnableSessionState="ReadOnly" %>

<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <asp:MultiView ID="mvwMain" runat="server" ActiveViewIndex="0">
        <asp:View ID="viwExist" runat="server">
            <user:BreadCrumbTrail ID="UC_BreadCrumbTrail" runat="server" EnableViewState="False" />
            <h1>
                <asp:Literal ID="litSubHeaderPromotions" runat="server" Text="<%$ Resources:Kartris, SubHeading_Promotions %>" /></h1>
            <user:ProductPromotions ID="UC_Promotions" runat="server" PageOwner="Promotions.aspx" />
        </asp:View>
        <asp:View ID="viwNotExist" runat="server">
            <p>
                <asp:Literal ID="litContentTextNotAvailable" runat="server" Text="<%$ Resources: Kartris, ContentText_ContentNotAvailable %>" /></p>
        </asp:View>
    </asp:MultiView>
</asp:Content>
