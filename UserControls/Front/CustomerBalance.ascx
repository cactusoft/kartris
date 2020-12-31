<%@ Control Language="VB" AutoEventWireup="false" CodeFile="CustomerBalance.ascx.vb" Inherits="UserControls_Front_CustomerBalance" %>
<div id="customer-balance">
    <span class="label"><asp:Literal ID="litAccountBalance" runat="server" Text="<%$ Resources: Kartris, ContentText_AccountBalance %>"></asp:Literal></span>
    <span class="figure"><asp:Literal ID="litCustomerBalance" runat="server"></asp:Literal></span>
</div>