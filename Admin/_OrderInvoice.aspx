<%@ Page Language="VB" MasterPageFile="~/Skins/Admin/Invoice.master" AutoEventWireup="false"
    CodeFile="_OrderInvoice.aspx.vb" Inherits="Order_Invoice" %>

<%@ Register TagPrefix="user" TagName="Invoice" Src="~/UserControls/General/Invoice.ascx" %>
<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <%-- We are using the front end control,
since the output is for the customer --%>
    <user:Invoice ID="UC_Invoice" runat="server" />
</asp:Content>
