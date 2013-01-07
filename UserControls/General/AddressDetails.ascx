<%@ Control Language="VB" AutoEventWireup="true" CodeFile="AddressDetails.ascx.vb" Inherits="UserControls_General_AddressDetails" %>
<div class="address">
<div>
    <asp:Literal ID="litAddressLabel" runat="server" /></div>
<div>
    <asp:Literal ID="litName" runat="server" /></div>
<asp:Panel ID="pnlCompany" runat="server">
    <asp:Literal ID="litCompany" runat="server" /></asp:Panel>
<div>
    <asp:Literal ID="litAddress" runat="server" /></div>
<div>
    <asp:Literal ID="litTownCity" runat="server" />,
    <asp:Literal ID="litCounty" runat="server" />
    <asp:Literal ID="litPostcode" runat="server" /></div>
<div>
    <asp:Literal ID="litCountry" runat="server" /></div>
<div class="phone">
    <asp:Literal ID="litPhone" runat="server" />
</div>
<asp:Panel ID="pnlButtons" runat="server">
    <asp:LinkButton ID="btnEdit" runat="server" Text='<%$ Resources: Kartris, ContentText_Edit %>'
        CausesValidation="false" class="link2" />
    &nbsp;
    <asp:LinkButton ID="btnDelete" runat="server" Text='<%$ Resources: Kartris, ContentText_Delete %>'
        CausesValidation="false" class="link2 icon_delete" />
</asp:Panel>
</div>