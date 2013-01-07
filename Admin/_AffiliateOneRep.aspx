<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_AffiliateOneRep.aspx.vb"
    Inherits="_AffiliateOneRep" MasterPageFile="~/Skins/Admin/Template.master" %>

<%@ Register TagPrefix="_user" TagName="ItemPager" Src="~/UserControls/Back/_ItemPagerAjax.ascx" %>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_affiliatestats">
        <asp:HyperLink ID="lnkBack" runat="server"
        Text='<%$ Resources: _Kartris, ContentText_BackLink %>'
        NavigateUrl="javascript:history.back()" CssClass="floatright linkbutton icon_back" />
        <h1>
            <asp:Literal ID="litPageTitleAffiliates" runat="server" Text='<%$ Resources: _Kartris, PageTitle_AffiliateStats %>' />:
            <span class="h1_light">
                <asp:Literal ID="litAffiliateName" runat="server" /></span>
        </h1>
        <p><asp:HyperLink ID="lnkAffPayReport" runat="server"
        Text='<%$ Resources: _Kartris, PageTitle_AffiliateReportFor %>'
        CssClass="linkbutton icon_orders" /></p><br />
        <p><strong>
            <asp:Literal ID="litHitsReportDate" runat="server" /></strong></p>
        <table class="kartristable">
        <tr>
        <th colspan="2"></th></tr>
            <tr>
                <td>
                    <asp:Literal ID="litContentTextTotalOrderValue" runat="server" Text='<%$ Resources: _Kartris, ContentText_TotalOrderValue %>' />
                </td>
                <td class="amount">
                    <asp:Literal ID="litTotalOrder" runat="server" />
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Literal ID="litContentTextCommissionDueThisMonth" runat="server" Text='<%$ Resources: _Kartris, ContentText_CommissionDueThisMonth %>' />
                </td>
                <td class="amount">
                    <asp:Literal ID="litCommissionMonth" runat="server" />
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Literal ID="litContentTextTotalNumberOfHits" runat="server" Text='<%$ Resources: _Kartris, ContentText_TotalNumberOfHits %>' />
                </td>
                <td class="amount">
                    <asp:Literal ID="litTotalHits" runat="server" />
                </td>
            </tr>
        </table>
        <div class="infomessage">
            <asp:Literal ID="litContentTextValuesShownExCoupons" runat="server" Text='<%$ Resources: _Kartris, ContentText_ValuesShownExCoupons %>' /></div>
        <strong>
            <asp:Literal ID="litContentTextRawDataHits" runat="server" Text='<%$ Resources: _Kartris, ContentText_RawDataHits %>' /></strong>
        <div class="spacer">
            &nbsp;</div>
        <asp:UpdatePanel ID="pnlRawDataHits" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:GridView ID="gvwRawDataHits" runat="server" CssClass="kartristable" AutoGenerateColumns="False" GridLines="None">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:Literal ID="litCounter" runat="server" Text='<%#Eval("RowNum")%>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$Resources:_Kartris, ContentText_DateTime %>">
                            <ItemTemplate>
                                <asp:Literal ID="AFLG_DateTime" runat="server" Text='<%# GetDateTime(Eval("AFLG_DateTime"))%>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$Resources:_Kartris, ContentText_IP %>">
                            <ItemTemplate>
                                <asp:Literal ID="AFLG_IP" runat="server" Text='<%#Eval("AFLG_IP")%>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$Resources:_Kartris, ContentText_Referrer %>">
                            <ItemTemplate>
                                <asp:Literal ID="AFLG_Referer" runat="server" Text='<%#Eval("AFLG_Referer")%>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                <asp:PlaceHolder ID="phdNoResults" runat="server">
                <div id="noresults">
                    <asp:Literal ID="litNoRawDataHitsRec" runat="server" Text='<%$ Resources: _Kartris, ContentText_NoItemsFound %>'></asp:Literal>
                </div></asp:PlaceHolder>
                <_user:ItemPager runat="server" ID="_UC_RawDataHitsPager" />
            </ContentTemplate>
        </asp:UpdatePanel>
        <br />
        <p><strong>
            <asp:Literal ID="litContentTextRawDataSales2" runat="server" Text='<%$ Resources: _Kartris, ContentText_RawDataSales %>' /></strong></p>

        <asp:UpdatePanel ID="updRawDataSales" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:GridView ID="gvwRawDataSales" runat="server" CssClass="kartristable" AutoGenerateColumns="False" GridLines="None">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:Literal ID="litCounter" runat="server" Text='<%# Eval("RowNum") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$ Resources: _Kartris, ContentText_DateTime %>">
                            <ItemTemplate>
                                <asp:Literal ID="O_Date" runat="server" Text='<%# GetDateTime(Eval("O_Date")) %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$ Resources: _Kartris, ContentText_Value %>">
                            <ItemTemplate>
                                <asp:Literal ID="OrderTotal"
                                    runat="server" Text='<% #CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, Eval("OrderTotal")) %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$ Resources: _Kartris, ContentText_Commission %>">
                            <ItemTemplate>
                                <asp:Literal ID="Commission"
                                    runat="server" Text='<%# CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, Eval("Commission")) %>' />&nbsp;(<%#Eval("O_AffiliatePercentage")%>%)
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <a class="linkbutton icon_orders normalweight" href='_ModifyOrderStatus.aspx?OrderID=<%#Eval("O_ID")%>'>
                                    <asp:Literal ID="litORD" runat="server" Text='<%$ Resources: _Kartris, ContentText_ShowOrder %>'></asp:Literal></a>&nbsp;
                                <a class="linkbutton icon_user" href='_ModifyCustomerStatus.aspx?CustomerID=<%#Eval("U_ID")%>'>
                                    <asp:Literal ID="litSelect" runat="server" Text='<%$ Resources: _Kartris, ImageLabel_ViewThisCustomer %>'></asp:Literal></a>
                            </ItemTemplate>
                            <ItemStyle CssClass="selectfield" />
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                <asp:PlaceHolder ID="phdNoResults2" runat="server">
                <div id="noresults">
                    <asp:Literal ID="litNoRawDataSalesRec" runat="server" Text='<%$ Resources: _Kartris, ContentText_NoItemsFound %>'></asp:Literal>
                </div></asp:PlaceHolder>
                <_user:ItemPager runat="server" ID="_UC_RawDataSalesPager" />
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
</asp:Content>
