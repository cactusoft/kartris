<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_ErrorLogs.aspx.vb" Inherits="Admin_ErrorLogs"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<%@ Register TagPrefix="_user" TagName="AdminErrorLogs" Src="~/UserControls/Back/_AdminErrorLogs.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <h1>
        <asp:Literal ID="litErrorLogsHeader" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_ErrorLogs %>" /></h1>
    <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <_user:AdminErrorLogs ID="_UC_AdminErrorLogs" runat="server" />

        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
