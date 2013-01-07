<%@ Page Language="VB" MasterPageFile="~/Skins/Admin/Template.master" AutoEventWireup="false"
    CodeFile="_SiteNews.aspx.vb" Inherits="Admin_SiteNews" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_sitenews">
        <h1>
            <asp:Literal ID="litPageTitleFrontNewsItems" runat="server" Text="<%$ Resources: _News, PageTitle_FrontNewsItems %>" /></h1>
        <asp:PlaceHolder ID="phdFeatureDisabled" runat="server" Visible="false">
            <div class="warnmessage">
                <asp:Literal ID="litFeatureDisabled" runat="server" />
                <asp:HyperLink ID="lnkEnableFeature" runat="server" Text="<%$ Resources: _Kartris, ContentText_ConfigChange2 %>"
                    NavigateUrl="~/Admin/_Config.aspx?name=frontend.navigationmenu.sitenews" CssClass="linkbutton icon_edit" />
            </div>
        </asp:PlaceHolder>
        <_user:SiteNews ID="_UC_SiteNews" runat="server" />
    </div>
</asp:Content>
