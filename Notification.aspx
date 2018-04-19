<%@ Page Language="VB" Buffer="true" ValidateRequest="false" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="false" CodeFile="Notification.aspx.vb" Inherits="Notification" %>

<asp:Content id="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <user:EcommerceTracking runat="server" ID="UC_EcommerceTracking" />
    <h2><asp:Label ID="lblOrderResult" Text="" runat="server"/></h2>
    <p><asp:Literal ID="litOrderDetails" runat="server" /></p>
</asp:Content>