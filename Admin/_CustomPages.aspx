<%@ Page Language="VB" MasterPageFile="~/Skins/Admin/Template.master" AutoEventWireup="false" CodeFile="_customPages.aspx.vb"
Inherits="Admin_CustomPages" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_custompages">
        <h1>
            <asp:Literal ID="litPageTitlePages" runat="server" Text="<%$ Resources: _Pages, PageTitle_Pages %>" />
            <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=9928')">?</a>

        </h1>
        <_user:CustomPages ID="_UC_CustomPages" runat="server" />
    </div>
</asp:Content>

