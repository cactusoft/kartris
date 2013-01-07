<%@ Page Language="VB" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="false"
    CodeFile="Page.aspx.vb" Inherits="Page" %>

<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <user:BreadCrumbTrail ID="UC_BreadCrumbTrail" runat="server" EnableViewState="False" />
    <user:Page ID="UC_Page" runat="server" EnableViewState="False" />
</asp:Content>
