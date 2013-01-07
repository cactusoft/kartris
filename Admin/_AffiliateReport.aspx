<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_AffiliateReport.aspx.vb"
    Inherits="_AffiliateReport" MasterPageFile="~/Skins/Admin/Template.master" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_affiliatestats">
        <h1>
            <asp:Literal ID="litPageTitleAffiliateStats" runat="server" Text='<%$ Resources: _Kartris, PageTitle_AffiliateStats %>' /></h1>
            <div class="spacer"></div>
        <!-- Hits -->
        <div class="halfwidth" id="rawhits">
            <h2>
                <asp:Literal ID="litPageTitleAffiliates" runat="server" Text='<%$ Resources: _Kartris, PageTitle_AffiliateHitsReport %>' /></h2>
            <asp:UpdatePanel ID="updHits" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <!-- Hits - 12 Months -->
                    <strong>
                        <asp:Literal ID="litContentTextLastTwelveMonths" runat="server" Text='<%$ Resources: _Stats, ContentText_LastTwelveMonths %>' />
                    </strong>
                    <asp:Repeater ID="rptAnnualHits" runat="server" EnableViewState="true">
                        <HeaderTemplate>
                            <table class="kartristable">
                                <tr>
                                    <th>
                                        <asp:Literal ID="litContentTextMonth" runat="server" Text='<%$ Resources: _Stats, ContentText_Month %>' />
                                    </th>
                                    <th class="amount">
                                        <asp:Literal ID="litContentTextRawDataHits" runat="server" Text='<%$ Resources: _Kartris, ContentText_RawDataHits %>' />
                                    </th>
                                </tr>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <asp:LinkButton ID="lnkHitsDate" runat="server" OnCommand="HitsDate_Click" />
                                </td>
                                <td class="amount">
                                    <asp:Literal ID="litHitsValue" runat="server" />
                                </td>
                            </tr>
                        </ItemTemplate>
                        <AlternatingItemTemplate>
                            <tr class="Kartris-GridView-Alternate">
                                <td>
                                    <asp:LinkButton ID="lnkHitsDate" runat="server" OnCommand="HitsDate_Click" />
                                </td>
                                <td class="amount">
                                    <asp:Literal ID="litHitsValue" runat="server" />
                                </td>
                            </tr>
                        </AlternatingItemTemplate>
                        <FooterTemplate>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                    <br />
                    <strong>
                        <asp:Literal ID="litHitsReportDate" runat="server" /></strong>
                    <div class="spaceholder">
                        <asp:Repeater ID="rptMonthlyHits" runat="server">
                            <HeaderTemplate>
                                <table class="kartristable">
                                    <tr>
                                        <th>
                                            <asp:Literal ID="litContentTextID" runat="server" Text='<%$ Resources: _Kartris, ContentText_ID %>' />
                                        </th>
                                        <th>
                                            <asp:Literal ID="litContentTextRawDataHits" runat="server" Text='<%$ Resources: _Kartris, ContentText_RawDataHits %>' />
                                        </th>
                                        <th>
                                            <asp:Literal ID="litContentTextAffiliateName" runat="server" Text='<%$ Resources: _Kartris, ContentText_AffiliateName %>' />
                                        </th>
                                    </tr>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td>
                                        <asp:Literal ID="litAffiliateID" runat="server" Text='<%#Eval("U_ID")%>' />
                                    </td>
                                    <td>
                                        <asp:Literal ID="litHitsValue" runat="server" Text='<%#Eval("Hits")%>' />
                                    </td>
                                    <td>
                                        <a href='_AffiliateOneRep.aspx?GivenMonth=<%=Report_Month%>&GivenYear=<%=Report_Year%>&CustomerID=<%#Eval("U_ID")%>'>
                                            <asp:Literal ID="litORD" runat="server" Text='<%#Eval("U_EmailAddress")%>'></asp:Literal></a>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <AlternatingItemTemplate>
                                <tr class="Kartris-GridView-Alternate">
                                    <td>
                                        <asp:Literal ID="litAffiliateID" runat="server" Text='<%#Eval("U_ID")%>' />
                                    </td>
                                    <td>
                                        <asp:Literal ID="litHitsValue" runat="server" Text='<%#Eval("Hits")%>' />
                                    </td>
                                    <td>
                                        <a href='_AffiliateOneRep.aspx?GivenMonth=<%=Report_Month%>&GivenYear=<%=Report_Year%>&CustomerID=<%#Eval("U_ID")%>'>
                                            <asp:Literal ID="litORD" runat="server" Text='<%#Eval("U_EmailAddress")%>'></asp:Literal></a>
                                    </td>
                                </tr>
                            </AlternatingItemTemplate>
                            <FooterTemplate>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>
                        <p>
                            <asp:Literal ID="litContentTextTotalHitsForAboveMonth" runat="server" Text='<%$ Resources: _Kartris, ContentText_TotalHitsForAboveMonth %>' />
                            <strong>
                                <asp:Literal ID="litTotalMonthlyHits" runat="server" /></strong></p>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
        <!-- Sales -->
        <div class="halfwidth col2" id="rawsales">
            <h2>
                <asp:Literal ID="litPageTitleAffiliateSalesReport" runat="server" Text='<%$ Resources: _Kartris, PageTitle_AffiliateSalesReport %>' /></h2>
            <asp:UpdatePanel ID="updSales" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <!-- Sales - 12 Months -->
                    <strong>
                        <asp:Literal ID="litContentTextLastTwelveMonths2" runat="server" Text='<%$ Resources: _Stats, ContentText_LastTwelveMonths %>' />
                    </strong>
                    <asp:Repeater ID="rptAnnualSales" runat="server" EnableViewState="true">
                        <HeaderTemplate>
                            <table class="kartristable">
                                <tr>
                                    <th>
                                        <asp:Literal ID="litContentTextMonth" runat="server" Text='<%$ Resources: _Stats, ContentText_Month %>' />
                                    </th>
                                    <th class="amount">
                                        <asp:Literal ID="litContentTextRawDataSales2" runat="server" Text='<%$ Resources: _Kartris, ContentText_RawDataSales %>' />
                                    </th>
                                </tr>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <asp:LinkButton ID="lnkSalesDate" runat="server" OnCommand="SalesDate_Click" />
                                </td>
                                <td class="amount">
                                    <asp:Literal ID="litSalesValue" runat="server" />
                                </td>
                            </tr>
                        </ItemTemplate>
                        <AlternatingItemTemplate>
                            <tr class="Kartris-GridView-Alternate">
                                <td>
                                    <asp:LinkButton ID="lnkSalesDate" runat="server" OnCommand="SalesDate_Click" />
                                </td>
                                <td class="amount">
                                    <asp:Literal ID="litSalesValue" runat="server" />
                                </td>
                            </tr>
                        </AlternatingItemTemplate>
                        <FooterTemplate>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                    <br />
                    <strong>
                        <asp:Literal ID="litSalesReportDate" runat="server" /></strong>
                    <div class="spaceholder">
                        <asp:Repeater ID="rptMonthlySales" runat="server">
                            <HeaderTemplate>
                                <table class="kartristable">
                                    <tr>
                                        <th>
                                            <asp:Literal ID="litContentTextID" runat="server" Text='<%$ Resources: _Kartris, ContentText_ID %>' />
                                        </th>
                                        <th>
                                            <asp:Literal ID="litContentTextRawDataSales" runat="server" Text='<%$ Resources: _Kartris, ContentText_RawDataSales %>' />
                                        </th>
                                        <th>
                                            <asp:Literal ID="litContentTextAffiliateName" runat="server" Text='<%$ Resources: _Kartris, ContentText_AffiliateName %>' />
                                        </th>
                                    </tr>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td>
                                        <asp:Literal ID="litAffiliateID" runat="server" Text='<%#Eval("U_AffiliateID")%>' />
                                    </td>
                                    <td>
                                        <asp:Literal ID="litHitsValue" runat="server" Text='<%#CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, Eval("OrderAmount"))%>' />
                                    </td>
                                    <td>
                                        <a href='_AffiliateOneRep.aspx?GivenMonth=<%=Report_Month%>&GivenYear=<%=Report_Year%>&CustomerID=<%#Eval("U_AffiliateID")%>'>
                                            <asp:Literal ID="litORD" runat="server" Text='<%#Eval("U_EmailAddress")%>'></asp:Literal></a>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <AlternatingItemTemplate>
                                <tr class="Kartris-GridView-Alternate">
                                    <td>
                                        <asp:Literal ID="litAffiliateID" runat="server" Text='<%#Eval("U_AffiliateID")%>' />
                                    </td>
                                    <td>
                                        <asp:Literal ID="litHitsValue" runat="server" Text='<%#CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, Eval("OrderAmount"))%>' />
                                    </td>
                                    <td>
                                        <a href='_AffiliateOneRep.aspx?GivenMonth=<%=Report_Month%>&GivenYear=<%=Report_Year%>&CustomerID=<%#Eval("U_AffiliateID")%>'>
                                            <asp:Literal ID="litORD" runat="server" Text='<%#Eval("U_EmailAddress")%>'></asp:Literal></a>
                                    </td>
                                </tr>
                            </AlternatingItemTemplate>
                            <FooterTemplate>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>
                        <p>
                            <asp:Literal ID="litContentTextTotalSalesForAboveMonth" runat="server" Text='<%$ Resources: _Kartris, ContentText_TotalSalesForAboveMonth %>' />
                            <strong>
                                <asp:Literal ID="litTotalMonthlySales" runat="server" /></strong></p>
                        <br />
                        <div class="infomessage">
                            <asp:Literal ID="litContentTextValuesShownExCoupons2" runat="server" Text='<%$ Resources: _Kartris, ContentText_ValuesShownExCoupons %>' /></div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
            <asp:UpdateProgress ID="prgHits" runat="server" AssociatedUpdatePanelID="updHits">
                <ProgressTemplate>
                    <div class="loadingimage">
                    </div>
                    <div class="updateprogress">
                    </div>
                </ProgressTemplate>
            </asp:UpdateProgress>
            <asp:UpdateProgress ID="prgSales" runat="server" AssociatedUpdatePanelID="updSales">
                <ProgressTemplate>
                    <div class="loadingimage">
                    </div>
                    <div class="updateprogress">
                    </div>
                </ProgressTemplate>
            </asp:UpdateProgress>
        </div>
    </div>
</asp:Content>
