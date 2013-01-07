<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_ModifyPayment.aspx.vb" Inherits="Admin_ModifyPayment"
    MasterPageFile="~/Skins/Admin/Template.master" %>
<%@ Register TagPrefix="_user" TagName="EditPayment" Src="~/UserControls/Back/_EditPayment.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_modifypayment">
        <h1>
            <asp:Literal ID="litPaymentPageTitle" runat="server" Text="<%$ Resources:_Payments, PageTitle_EditPayment %>"></asp:Literal></h1>
            <_user:EditPayment runat="server" ID="_UC_EditPayment" />
    </div>
</asp:Content>
