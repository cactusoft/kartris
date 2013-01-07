<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_Currency.aspx.vb" Inherits="Admin_Currency"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <_user:CurrencyRates ID="_UC_Currency" runat="server" />
</asp:Content>
