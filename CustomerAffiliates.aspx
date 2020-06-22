<%@ Page Language="VB" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="false"
    CodeFile="CustomerAffiliates.aspx.vb" Inherits="CustomerAffiliates" %>

<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <div id="affiliates">
        <h1>
            <asp:Literal ID="litPageTitleAffiliates" runat="server" Text='<%$ Resources: Kartris, PageTitle_Affiliates %>' /></h1>
        <div class="affiliatestats">
            <asp:PlaceHolder ID="phdMonthly" runat="server">
                <h2>
                    <asp:Literal ID="litContentTextCommission" runat="server" Text='<%$ Resources: Kartris, ContentText_Commission %>' /></h2>
                <div class="affiliatestatstable affiliatesalesdetailtable">
                    <table class="filled">
                        <thead>
                            <tr>
                                <th colspan="2">
                                    <asp:Literal ID="litAffMonthly_Date" runat="server" />
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="stat">
                                    <asp:Literal ID="litContentTextTotalNumberOfHits" runat="server" Text='<%$ Resources: Kartris, ContentText_TotalNumberOfHits %>' />
                                </td>
                                <td class="value">
                                    <asp:Literal ID="litAffMonthly_TotalHits" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td class="stat">
                                    <asp:Literal ID="litContentTextTotalOrderValue" runat="server" Text='<%$ Resources: Kartris, ContentText_TotalOrderValue %>' />
                                </td>
                                <td class="value">
                                    <asp:Literal ID="litAffMonthly_TotalPrice" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td class="stat">
                                    <asp:Literal ID="litContentTextCommissionDueThisMonth" runat="server" Text='<%$ Resources: Kartris, ContentText_CommissionDueThisMonth %>' />
                                </td>
                                <td class="value">
                                    <asp:Literal ID="litAffMonthly_TotalCommission" runat="server" />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <h2>
                    <asp:Literal ID="litContentTextRawDataSales" runat="server" Text='<%$ Resources: Kartris, ContentText_RawDataSales %>' /></h2>
                <div class="affiliatestatstable affiliaterawdatatable">
                    <asp:Repeater ID="rptAffiliateSalesLink" runat="server">
                        <HeaderTemplate>
                            <table class="filled">
                                <thead>
                                    <tr class="header">
                                        <th class="count">
                                        </th>
                                        <th class="date">
                                            <asp:Literal ID="litContentTextDateTime" runat="server" Text='<%$ Resources: Kartris, ContentText_DateTime %>' />
                                        </th>
                                        <th class="value">
                                            <asp:Literal ID="litContentTextValue" runat="server" Text='<%$ Resources: Kartris, ContentText_Value %>' />
                                        </th>
                                        <th class="commission">
                                            <asp:Literal ID="litContentTextCommission" runat="server" Text='<%$ Resources: Kartris, ContentText_Commission %>' />
                                        </th>
                                        <th class="total">
                                            <asp:Literal ID="litContentTextTotal" runat="server" Text='<%$ Resources: Basket, ContentText_Total %>' />
                                        </th>
                                        <th class="paid">
                                            <asp:Literal ID="litContentTextPaid" runat="server" Text='<%$ Resources: Kartris, ContentText_Paid %>' />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td class="count">
                                    <asp:Literal ID="litSalesLinkCnt" runat="server" />
                                </td>
                                <td class="date">
                                    <asp:Literal ID="litSalesLinkDate" runat="server" />
                                </td>
                                <td class="value">
                                    <asp:Literal ID="litSalesLinkValue" runat="server" />
                                </td>
                                <td class="commission">
                                    <asp:Literal ID="litSalesLinkCommission" runat="server" />
                                </td>
                                <td class="total">
                                    <asp:Literal ID="litSalesLinkTotal" runat="server" />
                                </td>
                                <td class="paid">
                                    <asp:Image ID="imgSalesLinkPaid" runat="server" /><td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                            </tbody> </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
                <div>
                    <a href="javascript:history.back()" class="link2 icon_back">
                        <asp:Literal ID="litContentText_GoBack" runat="server" Text='<%$ Resources: Kartris, ContentText_GoBack %>' /></a></div>
            </asp:PlaceHolder>
            <asp:PlaceHolder ID="phdApply" runat="server">
                <p>
                    <asp:Literal ID="litContentTextAffiliateApplicationDetail" runat="server" Text='<%$ Resources: Kartris, ContentText_AffiliateApplicationDetail %>' />
                </p>
                <p>
                    <a href="CustomerAccount.aspx" class="link2 icon_back">
                        <asp:Literal ID="litContentTextGoBack" runat="server" Text='<%$ Resources: Kartris, ContentText_GoBack %>' />
                    </a>
                </p>
            </asp:PlaceHolder>
            <asp:PlaceHolder ID="phdBalance" runat="server">
                <h2>
                    <asp:Literal ID="litContentTextPaymentsMade" runat="server" Text='<%$ Resources: Kartris, ContentText_PaymentsMade %>' /></h2>
                <p>
                    <asp:Literal ID="litContentTextPaymentsMadeText" runat="server" Text='<%$ Resources: Kartris, ContentText_PaymentsMadeText %>' /></p>
                <div class="affiliatestatstable affiliatepaymentstable">
                    <asp:Repeater ID="rptAffPayments" runat="server">
                        <HeaderTemplate>
                            <table class="filled">
                                <thead>
                                    <tr class="header">
<%--                                        <th class="count">
                                        </th>--%>
                                        <th class="date">
                                            <asp:Literal ID="litContentTextDateTime" runat="server" Text='<%$ Resources: Kartris, ContentText_DateTime %>' />
                                        </th>
                                        <th class="value">
                                            <asp:Literal ID="litContentTextPayment" runat="server" Text='<%$ Resources: Kartris, ContentText_Payment %>' />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
<%--                                <td class="count">
                                    <asp:Literal ID="litPaymentCnt" runat="server" />
                                </td>--%>
                                <td class="date">
                                    <asp:Literal ID="litPaymentDate" runat="server" />
                                </td>
                                <td class="value">
                                    <asp:Literal ID="litPaymentPayment" runat="server" />
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                            <tr class="totalsrow">
                                <td colspan="1">
                                </td>
                                <td class="total">
                                    <asp:Literal ID="litPaymentTotal" runat="server" />
                                </td>
                            </tr>
                            </tbody> </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
                <h2>
                    <asp:Literal ID="litContentTextUnpaidSales" runat="server" Text='<%$ Resources: Kartris, ContentText_UnpaidSales %>' /></h2>
                <p>
                    <asp:Literal ID="litContentTextUnpaidSalesText" runat="server" Text='<%$ Resources: Kartris, ContentText_UnpaidSalesText %>' /></p>
                <div class="affiliatestatstable affiliateunpaidtable">
                    <asp:Repeater ID="rptAffiliateUnpaid" runat="server">
                        <HeaderTemplate>
                            <table class="filled">
                                <thead>
                                    <tr class="header">
<%--                                        <th class="count">
                                        </th>--%>
                                        <th class="date">
                                            <asp:Literal ID="litContentTextDateTime" runat="server" Text='<%$ Resources: Kartris, ContentText_DateTime %>' />
                                        </th>
                                        <th class="value">
                                            <asp:Literal ID="litContentTextCommission" runat="server" Text='%' />
                                        </th>
                                        <th class="value">
                                            <asp:Literal ID="litContentTextCommission2" runat="server" Text='<%$ Resources: Kartris, ContentText_Commission %>' />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
<%--                                <td class="count">
                                    <asp:Literal ID="litUnpaidCnt" runat="server" />
                                </td>--%>
                                <td class="date">
                                    <asp:Literal ID="litUnpaidDate" runat="server" />
                                </td>
                                <td class="value_percent">
                                    <asp:Literal ID="litUnpaidPaymentPercent" runat="server" />
                                </td>
                                <td class="value">
                                    <asp:Literal ID="litUnpaidPayment" runat="server" />
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                            <tr class="totalsrow">
                                <td colspan="2">
                                </td>
                                <td class="total">
                                    <asp:Literal ID="litUnpaidTotal" runat="server" />
                                </td>
                            </tr>
                            </tbody> </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
                <p>
                    <a href="javascript:history.back()" class="link2 icon_back">
                        <asp:Literal ID="litContentTextGoBack1" runat="server" Text='<%$ Resources: Kartris, ContentText_GoBack %>' /></a></p>
            </asp:PlaceHolder>
            <asp:PlaceHolder ID="phdActivity" runat="server">
                <div class="halfwidth" id="rawhits">
                    <h2>
                        <asp:Literal ID="litContentTextRawDataHits" runat="server" Text='<%$ Resources: Kartris, ContentText_RawDataHits %>' /></h2>
                    <asp:Repeater ID="rptAffiliateActivityHits" runat="server">
                        <HeaderTemplate>
                            <table class="filled">
                                <thead>
                                    <tr class="header">
                                        <%--                                        <th class="graph">
                                            <asp:Literal ID="litContentTextShareOfHits" runat="server" Text='<%$ Resources: Kartris, ContentText_ShareOfHits %>' />
                                        </th>--%>
                                        <th class="month">
                                            <asp:Literal ID="litContentTextMonth" runat="server" Text='<%$ Resources: Kartris, ContentText_Month %>' />
                                        </th>
                                        <th class="total">
                                            <asp:Literal ID="litContentTextTotal" runat="server" Text='<%$ Resources: Basket, ContentText_Total %>' />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <%--                                <td class="graph">
                                    <div class="affiliategraph">
                                        <div class="bar" style='width: <%# Eval("GraphValue") %>%' runat="server" id="divAffHitsBar">
                                        </div>
                                    </div>
                                </td>--%>
                                <td class="month">
                                    <asp:HyperLink ID="hypLnkMonth" runat="server"></asp:HyperLink>
                                </td>
                                <td class="total">
                                    <asp:Literal ID="litHitsShare" runat="server" />
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                            </tbody>
                            <tr class="totalsrow">
                                <%--                                <td class="graph">
                                </td>--%>
                                <td class="month">
                                </td>
                                <td class="total">
                                    <asp:Literal ID="litHitsTotal" runat="server" />
                                </td>
                            </tr>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
                <div class="halfwidth" id="rawsales">
                    <h2>
                        <asp:Literal ID="litContentText_RawDataSales" runat="server" Text='<%$ Resources: Kartris, ContentText_RawDataSales %>' /></h2>
                    <asp:Repeater ID="rptAffiliateActivitySales" runat="server">
                        <HeaderTemplate>
                            <table class="filled">
                                <thead>
                                    <tr class="header">
                                        <%--                                        <th class="graph">
                                            <asp:Literal ID="litContentTextShareOfSales" runat="server" Text='<%$ Resources: Kartris, ContentText_ShareOfSales %>' />
                                        </th>--%>
                                        <th class="month">
                                            <asp:Literal ID="litContentTextMonth" runat="server" Text='<%$ Resources: Kartris, ContentText_Month %>' />
                                        </th>
                                        <th class="total">
                                            <asp:Literal ID="litContentTextTotal" runat="server" Text='<%$ Resources: Basket, ContentText_Total %>' />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <%--                                <td class="graph">
                                    <div class="affiliategraph">
                                        <div class="bar" style='width: <% =Eval("GraphValue")%>%' runat="server" id="divAffHitsBar">
                                        </div>
                                    </div>
                                </td>--%>
                                <td class="month">
                                    <asp:HyperLink ID="hypLnkMonth" runat="server" CssClass="link2"></asp:HyperLink>
                                </td>
                                <td class="total">
                                    <asp:Literal ID="litSalesShare" runat="server" />
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                            </tbody>
                            <tr class="totalsrow">
                                <%--                                <td class="graph">
                                </td>--%>
                                <td class="month">
                                </td>
                                <td class="total">
                                    <asp:Literal ID="litSalesTotal" runat="server" />
                                </td>
                            </tr>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
                <div class="spacer">
                </div>
                <p>
                    <a href="javascript:history.back()" class="link2 icon_back">
                        <asp:Literal ID="litContentTextGoBack2" runat="server" Text='<%$ Resources: Kartris, ContentText_GoBack %>' /></a></p>
            </asp:PlaceHolder>
        </div>
    </div>
</asp:Content>
