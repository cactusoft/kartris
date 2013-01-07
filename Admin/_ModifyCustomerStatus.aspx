<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_ModifyCustomerStatus.aspx.vb" Inherits="Admin_ModifyCustomerStatus"
MasterPageFile="~/Skins/Admin/Template.master" %>
<%@ Register TagPrefix="_user" TagName="UserDetails" Src="~/UserControls/Back/_UserDetails.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_user">
        <h1>
            <asp:Literal ID="litOrderPageTitle" runat="server" Text="<%$Resources: PageTitle_CustomerDetails %>"></asp:Literal>
        </h1>
       <_user:UserDetails runat="server" id="_UC_UserDetails" />
    </div>
</asp:Content>
