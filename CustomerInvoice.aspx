<%@ Page Language="VB" MasterPageFile="~/Skins/Admin/Invoice.master" AutoEventWireup="false"
    CodeFile="CustomerInvoice.aspx.vb" Inherits="Customer_Invoice" %>

<%@ Register TagPrefix="user" TagName="Invoice" Src="~/UserControls/General/Invoice.ascx" %>
<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <user:Invoice ID="UC_Invoice" runat="server" />
</asp:Content>
