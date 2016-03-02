<%@ Page Language="VB" MasterPageFile="~/Skins/Admin/Invoice.master" AutoEventWireup="false"
    CodeFile="CustomerInvoice.aspx.vb" Inherits="Customer_Invoice" %>

<%@ Register TagPrefix="user" TagName="Invoice" Src="~/UserControls/General/Invoice.ascx" %>
<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
            <%-- Header --%>
            <asp:Literal ID="litInvoiceHeader" runat="server" Text='<%$ Resources: Invoice, ContentText_InvoiceHeader %>' />
            <user:Invoice ID="UC_Invoice" runat="server" />
            <%-- Footer --%>
            <asp:Literal ID="litInvoiceFooter" runat="server" Text='<%$ Resources: Invoice, ContentText_InvoiceFooter %>' />
            <div class="pagebreak"></div>
</asp:Content>
