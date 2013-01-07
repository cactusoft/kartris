<%@ Control Language="VB" AutoEventWireup="true" CodeFile="_AddressesDetails.ascx.vb" Inherits="UserControls_General_AddressesDetails" %>
<asp:HiddenField ID="hidDisplayAddressType" runat="server" Value="" />
<asp:Repeater ID="rptrUserAddresses" runat="server">
    <ItemTemplate>
        </br>
        <div class="address">
            <div>
                <asp:HiddenField ID="hidAddressType" runat="server" value = '<%# Eval("ADR_Type")%>' />
                <%--<h3><asp:Literal ID="litAddressLabel" runat="server" Text='<%# Eval("ADR_Label")%>' /></h3>--%></div>
            <div>
                <asp:Literal ID="litName" runat="server" Text='<%# Eval("ADR_Name")%>'/></div>
            <asp:Panel ID="pnlCompany" runat="server">
                <asp:Literal ID="litCompany" runat="server" Text='<%# Eval("ADR_Company")%>'/></asp:Panel>
            <div>
                <asp:Literal ID="litAddress" runat="server" Text='<%# Eval("ADR_StreetAddress")%>'/></div>
            <div>
                <asp:Literal ID="litTownCity" runat="server" Text='<%# Eval("ADR_TownCity")%>'/>,
                <asp:Literal ID="litCounty" runat="server" Text='<%# Eval("ADR_County")%>'/>
                <asp:Literal ID="litPostcode" runat="server" Text='<%# Eval("ADR_PostCode")%>'/></div>
            <div>
                <asp:Literal ID="litCountry" runat="server" Text='<%# Eval("ADR_Country")%>'/></div>
            <div class="phone">
                <asp:Literal ID="litPhone" runat="server" Text='<%# Eval("ADR_Telephone")%>'/>
            </div>
        </div>
    </ItemTemplate>
</asp:Repeater>