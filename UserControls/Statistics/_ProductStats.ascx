<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_ProductStats.ascx.vb"
    Inherits="UserControls_Statistics_ProductStats" %>
<%@ Register TagPrefix="_user" TagName="KartrisChart" Src="~/UserControls/Statistics/_KartrisChart.ascx" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
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
                <asp:UpdatePanel ID="updProductChart" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:MultiView ID="mvwYearSummaryChart" runat="server" ActiveViewIndex="0">
                            <asp:View ID="viwYearSummaryListChart" runat="server">
                                <div class="section_stats">
                                    <asp:UpdatePanel ID="updProductSummaryChart" runat="server" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <_user:KartrisChart ID="_UC_KartChartProductYearSummary" runat="server" />
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>
                            </asp:View>
                            <asp:View ID="viwProductListChart" runat="server">
                                <div class="section_stats">
                                    <asp:LinkButton ID="lnkBackChart" runat="server" CssClass="linkbutton icon_back floatright"
                                        Text='<%$ Resources: _Kartris, ContentText_BackLink %>' />
                                    <asp:UpdatePanel ID="updCategoryDetailsChart" runat="server" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <_user:KartrisChart ID="_UC_KartChartProductMonthDetails" runat="server" />
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
                <asp:UpdatePanel ID="updProductTable" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:MultiView ID="mvwYearSummaryTable" runat="server" ActiveViewIndex="0">
                            <asp:View ID="viwYearSummaryListTable" runat="server">
                                <div class="section_stats">
                                    <asp:GridView CssClass="kartristable" ID="gvwYearSummary" runat="server" AllowPaging="False"
                                        AutoGenerateColumns="False" DataKeyNames="MonthYear" AutoGenerateEditButton="False"
                                        GridLines="None">
                                        <Columns>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litContentTextMonth" runat="server" Text="<%$ Resources: _Stats, ContentText_Month %>" />
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
                                                    <asp:Literal ID="litContentTextShareOfHits" runat="server" Text="<%$ Resources: _Stats, ContentText_ShareOfHits %>" />
                                                </HeaderTemplate>
                                                <ItemStyle CssClass="graph" />
                                                <ItemTemplate>
                                                    <!-- Graph -->
                                                    <%# CkartrisGraphs.StatGraph(Eval("TopHits"), Eval("NoOfHits"))%>
                                                </ItemTemplate>
                                                <FooterTemplate>
                                                    <strong>
                                                        <asp:Literal ID="litContentTextTotal" runat="server" Text="<%$ Resources: _Kartris, ContentText_Total %>" /></strong>
                                                </FooterTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litContentTextNoOfHits" runat="server" Text="<%$ Resources: _Stats, ContentText_SwitchToHits %>" />
                                                </HeaderTemplate>
                                                <ItemStyle CssClass="hitcount" />
                                                <ItemTemplate>
                                                    <!-- Number of Hits -->
                                                    <asp:Literal ID="litNoOfHits" runat="server" Text='<%# Eval("NoOfHits") %>' />
                                                </ItemTemplate>
                                                <FooterTemplate>
                                                    <strong>
                                                        <asp:Literal ID="litTotal" runat="server" /></strong></FooterTemplate>
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
                            <asp:View ID="viwProductListTable" runat="server">
                                <div class="section_stats">
                                    <asp:LinkButton ID="lnkBackTable" runat="server" CssClass="linkbutton icon_back floatright"
                                        Text='<%$ Resources: _Kartris, ContentText_BackLink %>' />
                                        <asp:GridView CssClass="kartristable stats" ID="gvwProductList" runat="server" AllowPaging="True"
                                        PageSize="15" AutoGenerateColumns="False" DataKeyNames="ProductID" AutoGenerateEditButton="False"
                                        GridLines="None">
                                        <Columns>
                                            <%-- For some reason, it fails when these two empty columns are removed --%>
                                            <asp:TemplateField Visible="False">
                                                <ItemTemplate>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField Visible="False">
                                                <ItemTemplate>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <%-- Weirdness ends --%>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                    <div class="itemname">
                                                        <asp:Literal ID="litContentTextProduct" runat="server" Text="<%$ Resources: _Kartris, ContentText_Product %>" /></div>
                                                    <div class="graph">
                                                        <asp:Literal ID="litContentTextShareOfHits" runat="server" Text="<%$ Resources: _Stats, ContentText_ShareOfHits %>" /></div>
                                                    <div class="hitcount">
                                                        <asp:Literal ID="litContentTextNoOfHits" runat="server" Text="<%$ Resources: _Stats, ContentText_SwitchToHits %>" />
                                                    </div>
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <div class="selectfield floatright">
                                                        <asp:LinkButton ID="lnkDetails" runat="server" Text="<%$ Resources: _Kartris, FormButton_Select %>"
                                                            CommandName="DetailsSelected" CommandArgument='<%# Container.DataItemIndex  %>'
                                                            CssClass="linkbutton icon_edit" /></div>
                                                    <div class="itemname">
                                                        <asp:LinkButton ID="lnkProduct" runat="server" Text='<%# Eval("ProductName") %>'
                                                            PostBackUrl='<%# "~/Admin/_ModifyProduct.aspx?ProductID=" & Eval("ProductID")  %>' /></div>
                                                    <div class="graph">
                                                        <!-- Graph -->
                                                        <%# CkartrisGraphs.StatGraph(Eval("TopHits"), Eval("NoOfHits"))%></div>
                                                    <div class="hitcount">
                                                        <!-- Number of Hits -->
                                                        <asp:Literal ID="litNoOfHits" runat="server" Text='<%# Eval("NoOfHits") %>' />
                                                        <asp:Literal ID="litProductID" runat="server" Text='<%# Eval("ProductID") %>' Visible="false" /></div>
                                                    <div class="spacer">
                                                    </div>
                                                    <asp:Panel ID="pnlProductDetails" runat="server" Visible="false" CssClass="foldout">
                                                        <div class="selectfield">
                                                            <asp:LinkButton ID="lnkHideDetails" runat="server" CssClass="linkbutton icon_back floatright"
                                                                Text='<%$ Resources: _Kartris, ContentText_HideLink %>' CommandArgument='<%# Container.DataItemIndex  %>'
                                                                CommandName="HideDetails" /></div>
                                                        <asp:GridView ID="grdStatsDetails" runat="server" AllowPaging="False" AutoGenerateColumns="False"
                                                            AutoGenerateEditButton="False" GridLines="None">
                                                            <Columns>
                                                                <asp:TemplateField>
                                                                    <HeaderTemplate>
                                                                        <asp:Literal ID="litFormLabelCategoryName" runat="server" Text="<%$ Resources: _Stats, FormLabel_CategoryName %>" /></HeaderTemplate>
                                                                    <ItemStyle CssClass="itemname" />
                                                                    <ItemTemplate>
                                                                        <asp:LinkButton ID="lnkCategory" runat="server" Text='<%# Eval("CategoryName") %>'
                                                                            PostBackUrl='<%# "~/Admin/_ModifyCategory.aspx?CategoryID=" & Eval("CategoryID")  %>' />
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField>
                                                                    <HeaderTemplate>
                                                                        <asp:Literal ID="litContentTextShareOfHits" runat="server" Text="<%$ Resources: _Stats, ContentText_ShareOfHits %>" /></HeaderTemplate>
                                                                    <ItemStyle CssClass="graph" />
                                                                    <ItemTemplate>
                                                                        <!-- Graph -->
                                                                        <%# CkartrisGraphs.StatGraph(Eval("TopHits"), Eval("NoOfHits"))%>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField>
                                                                    <HeaderTemplate>
                                                                        <asp:Literal ID="litContentTextSwitchToHits" runat="server" Text="<%$ Resources: _Stats, ContentText_SwitchToHits %>" /></HeaderTemplate>
                                                                    <ItemTemplate>
                                                                        <asp:Literal ID="litNoOfHits" runat="server" Text='<%# Eval("NoOfHits") %>' />
                                                                    </ItemTemplate>
                                                                    <ItemStyle CssClass="hitcount" />
                                                                </asp:TemplateField>
                                                                <asp:TemplateField>
                                                                    <HeaderTemplate>
                                                                    </HeaderTemplate>
                                                                    <ItemTemplate>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                            </Columns>
                                                        </asp:GridView>
                                                    </asp:Panel>
                                                </ItemTemplate>
                                                <FooterTemplate>
                                                    <div>
                                                    </div>
                                                    <div>
                                                        <strong>
                                                            <asp:Literal ID="litContentTextTotal" runat="server" Text="<%$ Resources: _Kartris, ContentText_Total %>" /></strong></div>
                                                    <div>
                                                        <strong>
                                                            <asp:Literal ID="litTotal" runat="server" /></strong></div>
                                                    <div>
                                                    </div>
                                                </FooterTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                    <asp:PlaceHolder runat="server" ID="phdNoResults" Visible="false">
                                        <div id="noresults">
                                            <asp:Literal ID="litNoProducts" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" /></div>
                                    </asp:PlaceHolder>
                                    
                                </div>
                            </asp:View>
                            
                        </asp:MultiView>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </asp:View>
        </asp:MultiView>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgMain" runat="server" AssociatedUpdatePanelID="updMain">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
