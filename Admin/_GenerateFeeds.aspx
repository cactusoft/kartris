<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_GenerateFeeds.aspx.vb"
    Inherits="Admin_GenerateFeeds" MasterPageFile="~/Skins/Admin/Template.master" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_generatesitemap">
        <h1>
            <asp:Literal ID="litPageTitle" runat="server" Text='<%$ Resources: _Feeds, PageTitle_GenerateFeeds %>'
                EnableViewState="False"></asp:Literal>
        </h1>
        <p>
            <asp:Literal ID="litDescription" runat="server" Text='<%$ Resources: _Feeds, ContentText_GenerateFeedsDesc %>'
                EnableViewState="False" />
        </p>
        <asp:UpdatePanel runat="server" ID="updSitemap" UpdateMode="Conditional">
            <ContentTemplate>
                <!-- GOOGLE SITEMAP -->
                <h2>
                    <asp:Literal ID="litSitemap" runat="server" Text='<%$ Resources: _Feeds, ContentText_SitemapFile %>'
                        EnableViewState="False"></asp:Literal>
                </h2>
                <div class="Kartris-DetailsView">
                    <div class="Kartris-DetailsView-Data">
                        <ul>
                            <li><span class="Kartris-DetailsView-Name">
                                <asp:Label ID="lblChangeFrequency" runat="server" Text="<%$ Resources: _Feeds, FormLabel_ChangeFrequency %>" /></span><span
                                    class="Kartris-DetailsView-Value">
                                    <asp:DropDownList ID="ddlChangeFrequency" runat="server">
                                        <asp:ListItem Text="always" />
                                        <asp:ListItem Text="hourly" />
                                        <asp:ListItem Text="daily" />
                                        <asp:ListItem Text="weekly" Selected="True" />
                                        <asp:ListItem Text="monthly" />
                                        <asp:ListItem Text="yearly" />
                                        <asp:ListItem Text="never" />
                                        <asp:ListItem Text="none" />
                                    </asp:DropDownList>
                                </span></li>
                            <li><span class="Kartris-DetailsView-Name"></span><span class="Kartris-DetailsView-Value">
                                <asp:Button CssClass="button" ID="btnSitemap" runat="server" Text="<%$ Resources: _Kartris, ContentText_Generate %>" /></span></li>
                        </ul>
                    </div>
                </div>
                <!-- GOOGLEBASE FEED -->
                <h2>
                    <asp:Literal ID="litGoogleBase" runat="server" Text='<%$ Resources: _Feeds, ContentText_GoogleFile %>'
                        EnableViewState="False"></asp:Literal>
                </h2>
                <div class="Kartris-DetailsView">
                    <div class="Kartris-DetailsView-Data">
                        <ul>
                            <li><span class="Kartris-DetailsView-Name">
                                <asp:Label ID="lblCondition" runat="server" Text="<%$ Resources: _Feeds, FormLabel_Condition %>" /></span><span
                                    class="Kartris-DetailsView-Value">
                                    <asp:DropDownList ID="ddlCondition" runat="server">
                                        <asp:ListItem Text="new" Selected="True" />
                                        <asp:ListItem Text="used" />
                                        <asp:ListItem Text="refurbished" />
                                    </asp:DropDownList>
                                </span></li>
                            <li><span class="Kartris-DetailsView-Name">
                                <asp:Label ID="lblFeedType" runat="server" Text="<%$ Resources: _Feeds, FormLabel_FeedType %>" /></span><span
                                    class="Kartris-DetailsView-Value">
                                    <asp:DropDownList ID="ddlXMLorTXT" runat="server">
                                        <asp:ListItem Text="RSS 2.0 (.XML)" Value="xml" />
                                        <asp:ListItem Text="Tab Delimited Text File (.txt)" Value="txt" />
                                    </asp:DropDownList>
                                </span></li>
                            <li><span class="Kartris-DetailsView-Name"></span><span class="Kartris-DetailsView-Value">
                                <asp:Button CssClass="button" ID="btnFroogle" runat="server" Text="<%$ Resources: _Kartris, ContentText_Generate %>" /></span></li>
                        </ul>
                    </div>
                </div>
                <p>
                    <asp:HyperLink ID="lnkGenerated" runat="server" Text="<%$ Resources: _Feeds, ContentText_ViewFile %>"
                        Target="_blank" Visible="false" CssClass="linkbutton icon_edit" /><br />
                    <div>
                        <asp:Literal ID="litFilePath" runat="server" Visible="false"></asp:Literal></div>
                </p>
            </ContentTemplate>
        </asp:UpdatePanel>
        <asp:UpdateProgress ID="prgGenerate" runat="server" AssociatedUpdatePanelID="updSitemap">
            <ProgressTemplate>
                <div class="loadingimage">
                </div>
                <div class="updateprogress">
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
    </div>
</asp:Content>
