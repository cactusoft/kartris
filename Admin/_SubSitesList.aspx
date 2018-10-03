<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_SubSitesList.aspx.vb" Inherits="Admin_SubSitesList"
MasterPageFile="~/Skins/Admin/Template.master" %>
<%@ Register TagPrefix="_user" TagName="SubSitesList" Src="~/UserControls/Back/_SubSitesList.ascx" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <_user:SubSitesList ID="_UC_SubSitesList" runat="server" />
</asp:Content>

