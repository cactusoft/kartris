<%@ Page Language="VB" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="false"
    CodeFile="CheckoutComplete.aspx.vb" Inherits="CheckoutComplete" %>

<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <div>

        <h1>
            <asp:Literal ID="litTitle" runat="server" Text="<%$ Resources: Callback, PageTitle_OnlineCreditCardPayment %>" /></h1>
        <h2>
            <asp:Label ID="lblResult" Text="<%$ Resources: Callback, ContentText_TransactionSuccess %>"
                runat="server" /></h2>
        <p>
            <asp:Literal ID="litOrderDetails" runat="server" />
        </p>
        <p>
            <asp:Literal ID="litContentTextConfirmEmail" Text="<%$ Resources: Checkout, ContentText_ConfirmEmail %>"
                runat="server" />
        </p>
    </div>
    <user:EcommerceTracking runat="server" ID="UC_EcommerceTracking" />
</asp:Content>
