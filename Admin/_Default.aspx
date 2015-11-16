<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_Default.aspx.vb" Inherits="Admin_Home"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<%@ Register TagPrefix="_user" TagName="OrderTurnoverSummary" Src="~/UserControls/Statistics/_OrderTurnoverSummary.ascx" %>
<%@ Register TagPrefix="_user" TagName="AverageHits" Src="~/UserControls/Statistics/_AverageHits.ascx" %>
<%@ Register TagPrefix="_user" TagName="AverageOrders" Src="~/UserControls/Statistics/_AverageOrders.ascx" %>
<%@ Register TagPrefix="_user" TagName="TopSearches" Src="~/UserControls/Statistics/_TopSearches.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_default">

        <asp:UpdatePanel ID="updControlBar" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <div id="backendcontrolbar" class="submitbuttons topsubmitbuttons">
                    <asp:LinkButton ID="btnRestart" runat="server" Text='<%$ Resources: _Kartris, ContentText_RestartKartris %>'
                        CssClass="button restartbutton" />
                </div>
                <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />

            </ContentTemplate>
        </asp:UpdatePanel>

        <_user:FeedSoftwareUpdate ID="_UC_FeedSoftwareUpdate" runat="server" />

        <_user:FeedNews ID="_UC_FeedNews" runat="server" />
        <asp:UpdatePanel ID="updStatistics" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:PlaceHolder ID="phdOrderStats" runat="server" Visible="true">
                    <div class="halfwidth">

                        <!-- ORDERS TURNOVER -->
                        <h2>
                            <asp:Literal ID="litBackMenuOrders" Text="<%$ Resources: _Statistics, ContentText_Orders %>"
                                runat="server" />
                        </h2>
                        <asp:HyperLink ID="lnkStats1" runat="server" NavigateUrl="~/Admin/_Stats.aspx">
                            <_user:OrderTurnoverSummary ID="_UC_OrderTurnover" runat="server" IsMiniDisplay="true" />
                        </asp:HyperLink>
                    </div>

                    <div class="halfwidth">
                        <!-- AVERAGE ORDERS TURNOVER -->
                        <h2>
                            <asp:Literal ID="litContentTextOrderValue" Text="<%$ Resources: _Orders, ContentText_OrderValue %>"
                                runat="server" />
                            <span class="h2_small">
                                <asp:Literal ID="litContentTextAverageDailyTotal" runat="server" Text="<%$ Resources: _Statistics, ContentText_AverageDailyTotal %>" /></span>
                        </h2>
                        <asp:HyperLink ID="lnkStats2" runat="server" NavigateUrl="~/Admin/_Stats.aspx">
                            <_user:AverageOrders ID="_UC_AverageOrders" runat="server" />
                        </asp:HyperLink>

                    </div>

                    <div class="halfwidth">
                        <!-- TOP SEARCH TERMS -->
                        <h2>
                            <asp:Literal ID="litTopSearchTermsHeader" runat="server" Text="<%$ Resources: _Statistics, ContentText_TopSearchTerms %>" />
                            <span class="h2_small">
                                <asp:Literal ID="litContentTextLast7Days" runat="server" Text="<%$ Resources: _Kartris, ContentText_Last7Days %>" /></span>
                        </h2>
                        <asp:HyperLink ID="lnkStats3" runat="server" NavigateUrl="~/Admin/_Stats.aspx">
                            <_user:TopSearches ID="_UC_TopSearches" runat="server" IsMiniDisplay="true" />
                        </asp:HyperLink>
                    </div>

                    <div class="halfwidth">
                        <!-- SHOP HITS -->
                        <h2>
                            <asp:Literal ID="litContentTextStoreHits" runat="server" Text="<%$ Resources: _Statistics, ContentText_StoreHits %>" />
                            <span class="h2_small">
                                <asp:Literal ID="litContentTextAverageDailyTotal2" runat="server" Text="<%$ Resources: _Statistics, ContentText_AverageDailyTotal %>" /></span>
                        </h2>
                        <asp:HyperLink ID="lnkStats4" runat="server" NavigateUrl="~/Admin/_Stats.aspx">
                            <_user:AverageHits ID="_UC_AverageHits" runat="server" />
                        </asp:HyperLink>
                    </div>
                </asp:PlaceHolder>
                <div class="spacer">
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
</asp:Content>
