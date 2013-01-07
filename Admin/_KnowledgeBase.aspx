<%@ Page Title="" Language="VB" MasterPageFile="~/Skins/Admin/Template.master" AutoEventWireup="false"
    CodeFile="_KnowledgeBase.aspx.vb" Inherits="Admin_KnowledgeBase" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_knowledgebase">
        <h1>
            <asp:Literal ID="litTitle" runat="server" Text="<%$ Resources: _Knowledgebase, PageTitle_KnowledgeBase %>" /></h1>
        <asp:PlaceHolder ID="phdFeatureDisabled" runat="server" Visible="false">
            <div class="warnmessage">
                <asp:Literal ID="litFeatureDisabled" runat="server" />
                <asp:HyperLink ID="lnkEnableFeature" runat="server" Text="<%$ Resources: _Kartris, ContentText_ConfigChange2 %>"
                    NavigateUrl="~/Admin/_Config.aspx?name=frontend.knowledgebase.enabled" CssClass="linkbutton icon_edit" />
            </div>
        </asp:PlaceHolder>
        <_user:KnowledgeBase ID="_UC_KB" runat="server" />
    </div>
</asp:Content>
