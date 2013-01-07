<%@ Control Language="VB" AutoEventWireup="false" CodeFile="SiteNews.ascx.vb" Inherits="UserControls_Front_SiteNews" %>
<asp:PlaceHolder ID="phdNews" runat="server">
<div class="news">
    <asp:PlaceHolder ID="phdH1Tag" runat="server">
        <h1>
            <asp:Literal ID="litPageTitleSiteNews" runat="server" Text="<%$ Resources: News, PageTitle_SiteNews %>" /></h1>
    </asp:PlaceHolder>
    <asp:PlaceHolder ID="phdH2Tag" runat="server">
            <h2 class="blockheader">
        <span><span>
            <asp:Literal ID="litPageTitleSiteNews2" runat="server" Text="<%$ Resources: News, PageTitle_SiteNews %>" /></span></span></h2>
    </asp:PlaceHolder>
    <div id="summary">
        <ul>
            <asp:Repeater ID="rptSiteNews" runat="server">
                <ItemTemplate>
                    <li>
                        <div class="news_lastupdated">
                            <asp:Literal ID="N_DateCreated" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("N_DateCreated"), "d", Session("LANG")) %>' /></div>
                        <div class="news_link">
                            <asp:HyperLink ID="lnkNews" runat="server" Text='<%# Server.HTMLEncode(Eval("N_Name")) %>'></asp:HyperLink>
                        </div>
                        <div class="spacer">
                        </div>
                        <% 'We have used N_Strapline below, but you can use N_Text instead by changing the code below, 
                            'or you could add a new line/section with N_Text in if you want strapline and text %>
                        <div class="news_text">
                            <asp:Literal ID="N_Text" runat="server" Text='<%# CkartrisDisplayFunctions.TruncateDescription(Eval("N_Strapline"), KartSettingsManager.GetKartConfig("frontend.news.display.truncatestory")) %>' Mode="Encode" /></div>
                    </li>
                </ItemTemplate>
            </asp:Repeater>
        </ul>
        <asp:PlaceHolder ID="phdNoResults" runat="server">
            <asp:Literal ID="litNoItems" Text="<%$ Resources: Kartris, ContentText_NoItems %>"
                runat="server"></asp:Literal>
        </asp:PlaceHolder>
    </div>
</div>
</asp:PlaceHolder>
<asp:Literal ID="litDisabledCommentMessage" runat="server" />