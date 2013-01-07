<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_TopSearches.ascx.vb" Inherits="UserControls_Statistics_TopSearches" %>
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
                        <asp:Literal ID="litContentTextPeriod" runat="server" Text="<%$ Resources: _Statistics, ContentText_DisplayPeriod %>" />
                    </td>
                    <td>
                        <asp:Literal ID="litContentTextRecordsReturned" runat="server" Text="<%$ Resources: _Statistics, ContentText_DisplayRecords %>" />
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
                    <td>
                        <asp:DropDownList ID="ddlTerms" runat="server" AutoPostBack="true" CssClass="midtext">
                            <asp:ListItem Text="5" Value="5" />
                            <asp:ListItem Text="10" Value="10" Selected="True" />
                            <asp:ListItem Text="15" Value="15" />
                            <asp:ListItem Text="20" Value="20" />
                        </asp:DropDownList>
                    </td>
                </tr>
            </table>
        </asp:PlaceHolder>
        <asp:UpdatePanel ID="updSearch" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:MultiView ID="mvwSearchStats" runat="server" ActiveViewIndex="0">
                    <asp:View ID="viwSearchChart" runat="server">
                        <asp:UpdatePanel ID="updSearchChart" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <_user:KartrisChart ID="_UC_KartChartSearch" runat="server" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </asp:View>
                    <asp:View ID="viwSearchTable" runat="server">
                        <asp:GridView CssClass="kartristable" ID="gvwSearch" runat="server" AutoGenerateColumns="False"
                            GridLines="None" EnableViewState="true" AllowPaging="false">
                            <Columns>
                                <asp:BoundField DataField="SS_Keyword" HeaderText="<%$ Resources: _Kartris, ContentText_Value %>" />
                                <asp:BoundField DataField="TotalSearches" HeaderText="<%$ Resources: _Kartris, ContentText_Total %>" ItemStyle-CssClass="currencyfield" />
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