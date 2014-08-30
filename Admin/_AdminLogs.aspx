<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_AdminLogs.aspx.vb" Inherits="Admin_AdminLogs"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<%@ Register TagPrefix="_user" TagName="AdminLog" Src="~/UserControls/Back/_AdminLog.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <h1>
        <asp:Literal ID="litAdminLogsHeader" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_AdminLogs %>" /></h1>
    <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <_user:AdminLog ID="_UC_AdminLog" runat="server" />
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
