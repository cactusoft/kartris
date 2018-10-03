<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_ModifySubSiteStatus.aspx.vb" Inherits="Admin_ModifySubSiteStatus" 
MasterPageFile="~/Skins/Admin/Template.master" %>
<%@ Register TagPrefix="_user" TagName="SubSiteDetails" Src="~/UserControls/Back/_SubSiteDetails.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_order">
        <h1>
            <asp:Literal ID="litOrderPageTitle" runat="server" Text="SubSite Details"></asp:Literal></h1>
        <_user:SubSiteDetails runat="server" ID="_UC_SubSiteDetails" />
    </div>
</asp:Content>
