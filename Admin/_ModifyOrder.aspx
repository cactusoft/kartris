<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_ModifyOrder.aspx.vb" Inherits="Admin_ModifyOrder"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<%@ Register TagPrefix="_user" TagName="EditOrder" Src="~/UserControls/Back/_EditOrder.ascx" %>
<%@ Register TagPrefix="_user" TagName="OrderBreadcrumb" Src="~/UserControls/Back/_OrderBreadcrumb.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_modifyorder">
        <_user:OrderBreadcrumb runat="server" ID="_UC_OrderBreadcrumb" />
        <h1>
            <asp:Literal ID="litOrderPageTitle" runat="server" Text="<%$Resources: PageTitle_EditOrder %>"></asp:Literal></h1>
        <_user:EditOrder runat="server" ID="_UC_EditOrder" />
    </div>
</asp:Content>
