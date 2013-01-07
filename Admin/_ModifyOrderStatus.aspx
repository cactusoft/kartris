<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_ModifyOrderStatus.aspx.vb"
    Inherits="Admin_ModifyOrderStatus" MasterPageFile="~/Skins/Admin/Template.master" %>

<%@ Register TagPrefix="_user" TagName="OrderDetails" Src="~/UserControls/Back/_OrderDetails.ascx" %>
<%@ Register TagPrefix="_user" TagName="OrderBreadcrumb" Src="~/UserControls/Back/_OrderBreadcrumb.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_order">
        <h1>
            <asp:Literal ID="litOrderPageTitle" runat="server" Text="<%$Resources: _Orders, PageTitle_OrderDetails %>"></asp:Literal></h1>
        <_user:OrderBreadcrumb runat="server" ID="_UC_OrderBreadcrumb" />
        <_user:OrderDetails runat="server" ID="_UC_OrderDetails" />
    </div>
</asp:Content>
