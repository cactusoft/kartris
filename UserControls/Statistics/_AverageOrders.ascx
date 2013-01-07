<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_AverageOrders.ascx.vb"
    Inherits="UserControls_Statistics_AverageOrders" %>
<%@ Register TagPrefix="_user" TagName="KartrisChart" Src="~/UserControls/Statistics/_KartrisChart.ascx" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:PlaceHolder ID="phdOptions" runat="server" visible="False">
            <table>
                <tr>
                    <td>
                        <asp:Literal ID="litContentTextDisplayType" runat="server" Text="<%$ Resources: _Statistics, ContentText_DisplayType %>"></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:DropDownList ID="ddlDisplayType" runat="server" AutoPostBack="true" CssClass="midtext">
                            <asp:ListItem Text="<%$ Resources: _Statistics, ContentText_Chart %>" Value="chart" Selected="True" />
                            <asp:ListItem Text="<%$ Resources: _Statistics, ContentText_Table %>" Value="table" />
                        </asp:DropDownList>
                    </td>
                </tr>
            </table>
        </asp:PlaceHolder>
        <asp:UpdatePanel ID="updAverageOrders" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:MultiView ID="mvwOrders" runat="server" ActiveViewIndex="0">
                    <asp:View ID="viwAverageOrdersChart" runat="server">
                        <asp:UpdatePanel ID="updAverageOrdersChart" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <_user:KartrisChart ID="_UC_KartChartAverageOrders" runat="server" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </asp:View>
                    <asp:View ID="viwAverageOrdersTable" runat="server">
                        <asp:GridView CssClass="kartristable" ID="gvwAverageOrders" runat="server" AutoGenerateColumns="False"
                            GridLines="None" EnableViewState="true" AllowPaging="false">
                            <Columns>
                                <asp:BoundField DataField="Period" HeaderText="<%$ Resources: _Kartris, ContentText_Period %>" />
                                <asp:BoundField DataField="Orders" HeaderText="<%$ Resources: _Statistics, ContentText_Orders %>" />
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Literal ID="litContentTextAverageDailyTotal" runat="server" Text="<%$ Resources: _Statistics, ContentText_AverageDailyTotal %>" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Literal ID="litTunover" runat="server" Text='<%# Eval("Turnover") %>'></asp:Literal>
                                    </ItemTemplate>
                                    <ItemStyle CssClass="currencyfield" />
                                </asp:TemplateField>
                                <%--<asp:BoundField DataField="Turnover"  ItemStyle-CssClass="currencyfield" />--%>
                            </Columns>
                        </asp:GridView>
                    </asp:View>
                    <asp:View ID="viwNoData" runat="server">
                        <asp:Panel ID="pnlNoItems" runat="server" CssClass="noresults">
                            <asp:Literal ID="litNoItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>">
                            </asp:Literal>
                        </asp:Panel>
                    </asp:View>
                </asp:MultiView>
            </ContentTemplate>
        </asp:UpdatePanel>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="upgMain" runat="server" AssociatedUpdatePanelID="updMain">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
