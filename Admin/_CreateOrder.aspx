<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_CreateOrder.aspx.vb" Inherits="Admin_CreateOrder"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<%@ Register TagPrefix="_user" TagName="CreateOrder" Src="~/UserControls/Back/_CreateOrder.ascx" %>
<%@ Register TagPrefix="_user" TagName="OrderBreadcrumb" Src="~/UserControls/Back/_OrderBreadcrumb.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_createorder">
        <_user:OrderBreadcrumb runat="server" ID="_UC_OrderBreadcrumb" />
        <h1><asp:Literal ID="litOrderPageTitle" runat="server" Text="<%$Resources: _Orders, PageTitle_CreateNewOrder %>"></asp:Literal></h1>
        <_user:CreateOrder runat="server" ID="_UC_CreateOrder" />
    </div>
</asp:Content>
