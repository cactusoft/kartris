<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_CategoryStats.ascx.vb"
    Inherits="UserControls_Statistics_CategoryStats" %>
<%@ Register TagPrefix="_user" TagName="KartrisChart" Src="~/UserControls/Statistics/_KartrisChart.ascx" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <contenttemplate>
        <h2>
            <asp:Literal ID="litTitle" runat="server" /></h2>
        <asp:PlaceHolder ID="phdOptions" runat="server">
            <div class="Kartris-DetailsView">
                <div class="Kartris-DetailsView-Data">
                    <ul>
                        <li>
                            <table>
                                <tr>
                                    <td>
                                        <asp:Literal ID="litContentTextDisplayType" runat="server" Text="<%$ Resources: _Statistics, ContentText_DisplayType %>"></asp:Literal>
                                    </td>
                                    <td>
                                        <asp:Literal ID="litContentTextDisplayPeriod" runat="server" Text="<%$ Resources: _Statistics, ContentText_DisplayPeriod %>" />
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
                                            <asp:ListItem Text="6" Value="6" />
                                            <asp:ListItem Text="12" Value="12" Selected="True" />
                                            <asp:ListItem Text="24" Value="24" />
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                            </table>
                        </li>
                    </ul>
                </div>
            </div>
        </asp:PlaceHolder>
        <asp:MultiView ID="mvwDisplayType" runat="server" ActiveViewIndex="0">
            <asp:View ID="viwDisplayChart" runat="server">
                <asp:UpdatePanel ID="updCategoryChart" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:MultiView ID="mvwYearSummaryChart" runat="server" ActiveViewIndex="0" >
                    <asp:View ID="viwYearSummaryListChart" runat="server">
                        <div class="section_stats">
                            <asp:UpdatePanel ID="updCategorySummaryChart" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <_user:KartrisChart ID="_UC_KartChartCategoryYearSummary" runat="server" />
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                    </asp:View>
                    <asp:View ID="viwCategoryListChart" runat="server">
                        <div class="section_stats">
                            <asp:LinkButton ID="lnkBackChart" runat="server" CssClass="linkbutton icon_back floatright"
                                Text='<%$ Resources: _Kartris, ContentText_BackLink %>' />
                            <asp:UpdatePanel ID="updCategoryDetailsChart" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <_user:KartrisChart ID="_UC_KartChartCategoryMonthDetails" runat="server" />
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                    </asp:View>
                </asp:MultiView>
            </ContentTemplate>
        </asp:UpdatePanel>
            </asp:View>
            <asp:View ID="viwDisplayTable" runat="server">
                <!-- Year Summary -->
                <asp:UpdatePanel ID="updCategoryTable" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:MultiView ID="mvwYearSummaryTable" runat="server" ActiveViewIndex="0">
                            <asp:View ID="viwYearSummaryListTable" runat="server">
                                <div class="section_stats">
                                    <asp:GridView CssClass="kartristable" ID="gvwYearSummary" runat="server" AllowPaging="False"
                                        AutoGenerateColumns="False" DataKeyNames="MonthYear" AutoGenerateEditButton="False"
                                        GridLines="None" ShowFooter="False">
                                        <Columns>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litContentTextMonth" runat="server" Text="<%$ Resources: _Stats, ContentText_Month %>"
                                                        EnableViewState="False" />
                                                </HeaderTemplate>
                                                <ItemStyle CssClass="itemname" />
                                                <ItemTemplate>
                                                    <!-- Month -->
                                                    <asp:LinkButton ID="lnkMonth" runat="server" Text='<%# Eval("TheDate") %>' CommandName="DateSelected"
                                                        CommandArgument='<%# Container.DataItemIndex %>' />
                                                </ItemTemplate>
                                                <FooterTemplate>
                                                </FooterTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litContentTextShareOfHits" runat="server" Text="<%$ Resources: _Stats, ContentText_ShareOfHits %>"
                                                        EnableViewState="False" />
                                                </HeaderTemplate>
                                                <ItemStyle CssClass="graph" />
                                                <ItemTemplate>
                                                    <!-- Graph -->
                                                    <%# CkartrisGraphs.StatGraph(Eval("TopHits"), Eval("NoOfHits"))%>
                                                </ItemTemplate>
                                                <FooterTemplate>
                                                    <asp:Literal ID="litContentTextTotal" runat="server" Text="<%$ Resources: _Kartris, ContentText_Total %>"
                                                        EnableViewState="False" />
                                                </FooterTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litContentTextNoOfHits" runat="server" Text="<%$ Resources: _Stats, ContentText_SwitchToHits %>"
                                                        EnableViewState="False" />
                                                </HeaderTemplate>
                                                <ItemStyle CssClass="hitcount" />
                                                <ItemTemplate>
                                                    <!-- Number of Hits -->
                                                    <asp:Literal ID="litNoOfHits" runat="server" Text='<%# Eval("NoOfHits") %>' EnableViewState="False" />
                                                </ItemTemplate>
                                                <FooterTemplate>
                                                    <strong>
                                                        <asp:Literal ID="litTotal" runat="server" EnableViewState="False" /></strong></FooterTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <ItemStyle CssClass="selectfield" />
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="lnkSelect" runat="server" Text='<%$ Resources: _Kartris, FormButton_Select %>'
                                                        CommandName="DateSelected" CssClass="linkbutton icon_edit" CommandArgument='<%# Container.DataItemIndex %>' />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </div>
                            </asp:View>
                            <asp:View ID="viwCategoryListTable" runat="server">
                                <div class="section_stats">
                                    <asp:LinkButton ID="lnkBackTable" runat="server" CssClass="linkbutton icon_back floatright"
                                        Text='<%$ Resources: _Kartris, ContentText_BackLink %>' />
                                        <asp:GridView CssClass="kartristable" ID="gvwCategoryList" runat="server" AllowPaging="True"
                                        PageSize="15" AutoGenerateColumns="False" DataKeyNames="CategoryID" AutoGenerateEditButton="False"
                                        GridLines="None">
                                        <Columns>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litFormLabelCategoryName" runat="server" Text="<%$ Resources: _Stats, FormLabel_CategoryName %>"
                                                        EnableViewState="False" />
                                                </HeaderTemplate>
                                                <ItemStyle CssClass="itemname" />
                                                <ItemTemplate>
                                                    <!-- Category Name -->
                                                    <asp:LinkButton ID="lnkCategory" runat="server" Text='<%# Eval("CategoryName") %>'
                                                        PostBackUrl='<%# "~/Admin/_ModifyCategory.aspx?CategoryID=" & Eval("CategoryID")  %>' />
                                                </ItemTemplate>
                                                <FooterTemplate>
                                                </FooterTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litContentTextShareOfHits" runat="server" Text="<%$ Resources: _Stats, ContentText_ShareOfHits %>"
                                                        EnableViewState="False" />
                                                </HeaderTemplate>
                                                <ItemStyle CssClass="graph" />
                                                <ItemTemplate>
                                                    <!-- Graph -->
                                                    <%# CkartrisGraphs.StatGraph(Eval("TopHits"), Eval("NoOfHits"))%>
                                                </ItemTemplate>
                                                <FooterTemplate>
                                                    <strong>
                                                        <asp:Literal ID="litContentTextTotal" runat="server" Text="<%$ Resources: _Kartris, ContentText_Total %>"
                                                            EnableViewState="False" /></strong>
                                                </FooterTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litContentTextNoOfHits" runat="server" Text="<%$ Resources: _Stats, ContentText_SwitchToHits %>"
                                                        EnableViewState="False" />
                                                </HeaderTemplate>
                                                <ItemStyle CssClass="hitcount" />
                                                <ItemTemplate>
                                                    <!-- Number of Hits -->
                                                    <asp:Literal ID="litNoOfHits" runat="server" Text='<%# Eval("NoOfHits") %>' EnableViewState="False" />
                                                </ItemTemplate>
                                                <FooterTemplate>
                                                    <strong>
                                                        <asp:Literal ID="litTotal" runat="server" /></strong></FooterTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                    <asp:PlaceHolder runat="server" ID="phdNoResults" Visible="false">
                                        <div id="noresults">
                                            <asp:Literal ID="litNoCategories" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" /></div>
                                    </asp:PlaceHolder>
                                </div>
                            </asp:View>
                        </asp:MultiView>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </asp:View>
        </asp:MultiView>
    </contenttemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgMain" runat="server" AssociatedUpdatePanelID="updMain">
    <progresstemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </progresstemplate>
</asp:UpdateProgress>
