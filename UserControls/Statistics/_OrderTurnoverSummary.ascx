<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_OrderTurnoverSummary.ascx.vb"
    Inherits="UserControls_Back_OrderTurnoverSummary" %>
<%@ Register TagPrefix="_user" TagName="KartrisChart" Src="~/UserControls/Statistics/_KartrisChart.ascx" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:PlaceHolder ID="phdOptions" runat="server">
            <table>
                <tr>
                    <td>
                        <asp:Literal ID="litContentTextDisplayType" runat="server" Text="<%$ Resources: _Statistics, ContentText_DisplayType %>"></asp:Literal>
                    </td>
                    <td>
                        <asp:Literal ID="litContentTextDisplayPeriod" runat="server" Text="<%$ Resources: _Statistics, ContentText_DisplayPeriod %>" /></span>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:DropDownList ID="ddlDisplayType" runat="server" AutoPostBack="true" CssClass="midtext">
                            <asp:ListItem Text="<%$ Resources: _Statistics, ContentText_Chart %>" Value="chart" Selected="True" />
                            <asp:ListItem Text="<%$ Resources: _Statistics, ContentText_Table %>" Value="table" />
                        </asp:DropDownList>
                    </td>
                    <td>
                        <asp:DropDownList ID="ddlDuration" runat="server" AutoPostBack="true" CssClass="midtext">
                            <asp:ListItem Text="7" Value="-7" />
                            <asp:ListItem Text="14" Value="-14" />
                            <asp:ListItem Text="30" Value="-30" Selected="True" />
                            <asp:ListItem Text="60" Value="-60" />
                        </asp:DropDownList>
                    </td>
                </tr>
            </table>
        </asp:PlaceHolder>
        <asp:UpdatePanel ID="updTurnover" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:MultiView ID="mvwOrderStats" runat="server" ActiveViewIndex="0">
                    <asp:View ID="viwTurnoverChart" runat="server">
                        <asp:UpdatePanel ID="updTurnoverChart" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <_user:KartrisChart ID="_UC_KartChartOrderTurnover" runat="server" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </asp:View>
                    <asp:View ID="viwTurnoverTable" runat="server">
                        <asp:GridView CssClass="kartristable" ID="gvwOrdersTurnover" runat="server" AutoGenerateColumns="False"
                            GridLines="None" EnableViewState="true" AllowPaging="false">
                            <Columns>
                                <asp:TemplateField ItemStyle-CssClass="datefield" HeaderText='<%$ Resources:_Kartris, ContentText_Date %>'>
                                    <ItemTemplate>
                                        <asp:Literal ID="litTurnoverDate" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("Date"), "d", Session("_LANG")) %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Orders" HeaderText="<%$ Resources: _Statistics, ContentText_Orders %>" />
                                <asp:TemplateField ItemStyle-CssClass="currencyfield" HeaderText="<%$ Resources: _Kartris, ContentText_Total %>">
                                    <ItemTemplate>
                                        <asp:Literal ID="litOrderValue" runat="server" Text='<%# Eval("Turnover") %>'> </asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
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
