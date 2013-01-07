<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_PageHits.ascx.vb" Inherits="UserControls_Back_PageHits" %>
<%@ Register TagPrefix="_user" TagName="CategoryStats" Src="~/UserControls/Statistics/_CategoryStats.ascx" %>
<%@ Register TagPrefix="_user" TagName="ProductStats" Src="~/UserControls/Statistics/_ProductStats.ascx" %>
<%@ Register TagPrefix="_user" TagName="TopSearches" Src="~/UserControls/Statistics/_TopSearches.ascx" %>
<%@ Register TagPrefix="_user" TagName="OrderTurnoverSummary" Src="~/UserControls/Statistics/_OrderTurnoverSummary.ascx" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <ajaxToolkit:TabContainer ID="tabContainerStats" runat="server" CssClass=".tab">
            <ajaxToolkit:TabPanel ID="tabCategoryStats" runat="server">
                <HeaderTemplate>
                    <asp:Literal ID="litContentTextCategoryStatistics" runat="server" Text="<%$ Resources: _Statistics, ContentText_CategoryStatistics %>" />
                </HeaderTemplate>
                <ContentTemplate>
                    <_user:CategoryStats ID="_UC_CategoryStats" runat="server" />
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
            <ajaxToolkit:TabPanel ID="tabProductStats" runat="server">
                <HeaderTemplate>
                    <asp:Literal ID="litContentTextProductStatistics" runat="server" Text="<%$ Resources: _Statistics, ContentText_ProductStatistics %>" />
                </HeaderTemplate>
                <ContentTemplate>
                    <_user:ProductStats ID="_UC_ProductStats" runat="server" />
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
            <ajaxToolkit:TabPanel ID="tblOrderStats" runat="server">
                <HeaderTemplate>
                    <asp:Literal ID="litOrdersHeader" runat="server" Text="<%$ Resources: _Statistics, ContentText_Orders %>" />
                </HeaderTemplate>
                <ContentTemplate>
                    <h2>
                        <asp:Literal ID="litContentTextOrders" runat="server" Text="<%$ Resources: _Statistics, ContentText_Orders %>" /></h2>
                    <_user:OrderTurnoverSummary ID="_UC_OrderTurnover" runat="server" />
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
            <ajaxToolkit:TabPanel ID="tabSearchStats" runat="server">
                <HeaderTemplate>
                    <asp:Literal ID="litTopSearchTermsHeader" runat="server" Text="<%$ Resources: _Statistics, ContentText_TopSearchTerms %>" />
                </HeaderTemplate>
                <ContentTemplate>
                    <h2>
                        <asp:Literal ID="litTopSearchTerms" runat="server" Text="<%$ Resources: _Statistics, ContentText_TopSearchTerms %>" /></h2>
                    <_user:TopSearches ID="_UC_TopSearches" runat="server" />
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
        </ajaxToolkit:TabContainer>
    </ContentTemplate>
</asp:UpdatePanel>
