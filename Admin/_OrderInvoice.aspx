<%@ Page Language="VB" MasterPageFile="~/Skins/Admin/Invoice.master" AutoEventWireup="false"
    CodeFile="_OrderInvoice.aspx.vb" Inherits="Order_Invoice" %>

<%@ Register TagPrefix="user" TagName="Invoice" Src="~/UserControls/General/Invoice.ascx" %>
<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <%-- We are using the front end control,
since the output is for the customer --%>
    <asp:Repeater ID="rptCompleteInvoice" runat="server">
        <ItemTemplate>
            <%-- Header --%>
            <asp:Literal ID="litInvoiceHeader" runat="server" Text='<%$ Resources: Invoice, ContentText_InvoiceHeader %>' />
            <user:Invoice ID="UC_Invoice" runat="server" />
            <%-- Footer --%>
            <asp:Literal ID="litInvoiceFooter" runat="server" Text='<%$ Resources: Invoice, ContentText_InvoiceFooter %>' />
            <div class="pagebreak"></div>
        </ItemTemplate>
    </asp:Repeater>
</asp:Content>
