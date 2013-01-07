<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_stats.aspx.vb" Inherits="Admin_Stats" 
MasterPageFile="~/Skins/Admin/Template.master" %>
<%@ Register TagPrefix="_user" TagName="PageHits" Src="~/UserControls/Back/_PageHits.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_stats">
        <h1>
            <asp:Literal ID="litPageTitle" runat="server" Text='<%$ Resources:_Kartris, BackMenu_Statistics %>'></asp:Literal></h1>
        <_user:PageHits ID="_UC_PageHits" runat="server" />
    </div>
</asp:Content>
