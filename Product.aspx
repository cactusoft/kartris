<%@ Page Language="VB" AutoEventWireup="true" MasterPageFile="~/Skins/Kartris/Template.master"
    CodeFile="Product.aspx.vb" Inherits="Product" EnableSessionState="ReadOnly" %>

<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <user:ProductView ID="UC_ProductView" runat="server" />
</asp:Content>
