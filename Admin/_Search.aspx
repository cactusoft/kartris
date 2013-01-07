<%@ Page Language="VB" MasterPageFile="~/Skins/Admin/Template.master" AutoEventWireup="false"
    CodeFile="_Search.aspx.vb" Inherits="Admin_Search" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_searchresults">
        <asp:UpdatePanel ID="updResults" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <h1>
                    <asp:Literal ID="litPageTitleSearchResults" runat="server" Text="<%$ Resources: _Search, PageTitle_SearchResults %>" /></h1>
                
                <asp:Panel ID="pnlNoResults" runat="server" Visible="false" CssClass="noresults">
                    <asp:Literal ID="litContentTextBackSearchNoResults" runat="server" Text="<%$ Resources: _Kartris, ContentText_BackSearchNoResults %>" />
                </asp:Panel>
                <!-- Categories -->
                <asp:Panel ID="pnlCategories" runat="server" Visible="false">
                    <div class="sidebar">
                        <h2>
                            <asp:Literal ID="litBackMenuCategories" runat="server" Text="<%$ Resources: _Category, BackMenu_Categories %>" />
                            <em>(<asp:Literal ID="litCategories" runat="server" />)</em></h2>
                    </div>
                    <asp:GridView ID="gvwCategories" CssClass="kartristable" runat="server" AllowPaging="True" AutoGenerateColumns="False"
                        DataKeyNames="ItemID" AutoGenerateEditButton="False" GridLines="None" PageSize="15"
                        OnPageIndexChanging="gridView_PageIndexChanging">
                        <Columns>
                            <asp:BoundField DataField="ItemValue" HeaderText='<%$ Resources:_Kartris, ContentText_Name %>'
                                ItemStyle-CssClass="itemname">
                                <HeaderStyle />
                            </asp:BoundField>
                            <asp:TemplateField ItemStyle-CssClass="selectfield">
                                <ItemTemplate>
                                    <asp:HyperLink ID="lnkCategoryEdit" Text='<%$ Resources:_Kartris, FormButton_Edit %>' runat="server"
                                     NavigateUrl='<%# "~/Admin/_ModifyCategory.aspx?CategoryID=" & Eval("ItemID") %>'
                                     CssClass="linkbutton icon_edit" />

                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView><div class="spacer"></div>
                </asp:Panel>
                <!-- Products -->
                <asp:Panel ID="pnlProducts" runat="server" Visible="false">
                    <div class="sidebar">
                        <h2>
                            <asp:Literal ID="litBackMenuProducts" runat="server" Text="<%$ Resources: _Kartris, BackMenu_Products %>" />
                            <em>(<asp:Literal ID="litProducts" runat="server" />)</em></h2>
                    </div>
                    <asp:GridView CssClass="kartristable" ID="gvwProducts" runat="server" AllowPaging="True" AutoGenerateColumns="False"
                        DataKeyNames="ItemID" AutoGenerateEditButton="False" GridLines="None" PageSize="15"
                        OnPageIndexChanging="gridView_PageIndexChanging">
                        <Columns>
                            <asp:BoundField DataField="ItemValue" HeaderText='<%$ Resources:_Kartris, ContentText_Name %>'
                                ItemStyle-CssClass="itemname">
                                <HeaderStyle />
                            </asp:BoundField>
                            <asp:TemplateField ItemStyle-CssClass="selectfield">
                                <ItemTemplate>
                                <asp:HyperLink ID="lnkProductEdit" Text='<%$ Resources:_Kartris, FormButton_Edit %>' runat="server"
                                     NavigateUrl='<%# "~/Admin/_ModifyProduct.aspx?ProductID=" & Eval("ItemID") %>'
                                     CssClass="linkbutton icon_edit" />

                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView><div class="spacer"></div>
                </asp:Panel>
                <!-- Versions -->
                <asp:Panel ID="pnlVersions" runat="server" Visible="false">
                    <div class="sidebar">
                        <h2>
                            <asp:Literal ID="litBackMenuVersions" runat="server" Text="<%$ Resources: _Kartris, BackMenu_Versions %>" />
                            <em>(<asp:Literal ID="litVersions" runat="server" />)</em></h2>
                    </div>
                    <asp:GridView CssClass="kartristable" ID="gvwVersions" runat="server" AllowPaging="True" AutoGenerateColumns="False"
                        DataKeyNames="VersionID" AutoGenerateEditButton="False" GridLines="None" PageSize="15"
                        OnPageIndexChanging="gridView_PageIndexChanging">
                        <Columns>
                            <asp:BoundField DataField="VersionCode" HeaderText='<%$ Resources:_Product, ContentText_CodeNumber %>'
                                ItemStyle-CssClass="itemname">
                                <HeaderStyle />
                            </asp:BoundField>
                            <asp:BoundField DataField="VersionName" HeaderText='<%$ Resources:_Kartris, ContentText_Name %>'>
                                <HeaderStyle />
                            </asp:BoundField>
                            <asp:TemplateField ItemStyle-CssClass="selectfield">
                                <ItemTemplate>
                                    <asp:HyperLink ID="lnkVersionEdit" Text='<%$ Resources:_Kartris, FormButton_Edit %>' runat="server"
                                     NavigateUrl='<%# "~/Admin/_ModifyProduct.aspx?ProductID=" & Eval("ProductID") & "&VersionID=" & Eval("VersionID") & "&strTab=versions" %>'
                                     CssClass="linkbutton icon_edit" />

                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView><div class="spacer"></div>
                </asp:Panel>
                <!-- Customers/Users -->
                <asp:Panel ID="pnlCustomers" runat="server" Visible="false">
                    <div class="sidebar">
                        <h2>
                            <asp:Literal ID="litBackMenuCustomers" runat="server" Text="<%$ Resources: _Kartris, BackMenu_Customers %>" />
                            <em>(<asp:Literal ID="litCustomers" runat="server" />)</em></h2>
                    </div>
                    <asp:GridView CssClass="kartristable" ID="gvwCustomers" runat="server" AllowPaging="True" AutoGenerateColumns="False"
                        DataKeyNames="CustomerID" AutoGenerateEditButton="False" GridLines="None" PageSize="15"
                        OnPageIndexChanging="gridView_PageIndexChanging">
                        <Columns>
                            <asp:BoundField DataField="CustomerName" HeaderText='<%$ Resources:_Kartris, ContentText_Name %>'>
                                <HeaderStyle />
                            </asp:BoundField>
                            <asp:BoundField DataField="CustomerEmail" ItemStyle-CssClass="itemname">
                                <HeaderStyle />
                            </asp:BoundField>
                            <asp:TemplateField ItemStyle-CssClass="selectfield">
                                <ItemTemplate>
                                
                                    <asp:HyperLink ID="lnkOrderList" Text='<%$ Resources:_Customers, ContentText_ListOrders %>' runat="server"
                                     NavigateUrl='<%# "~/Admin/_OrdersList.aspx?CustomerID=" & Eval("CustomerID") & "&callmode=customer" %>'
                                     CssClass="linkbutton icon_edit normalweight" />                          
                                     <asp:HyperLink ID="lnkCustomerEdit" Text='<%$ Resources:_Kartris, FormButton_Edit %>' runat="server"
                                     NavigateUrl='<%# "~/Admin/_ModifyCustomerStatus.aspx?CustomerID=" & Eval("CustomerID") %>'
                                     CssClass="linkbutton icon_edit" />                                 
                                
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView><div class="spacer"></div>
                </asp:Panel>
                <!-- Orders -->
                <asp:Panel ID="pnlOrders" runat="server" Visible="false">
                    <div class="sidebar">
                        <h2>
                            <asp:Literal ID="litBackMenuOrders" runat="server" Text="<%$ Resources: _Kartris, BackMenu_Orders %>" />
                            <em>(<asp:Literal ID="litOrders" runat="server" />)</em></h2>
                    </div>
                    <asp:GridView CssClass="kartristable" ID="gvwOrders" runat="server" AllowPaging="True" AutoGenerateColumns="False"
                        DataKeyNames="OrderID" AutoGenerateEditButton="False" GridLines="None" PageSize="15"
                        OnPageIndexChanging="gridView_PageIndexChanging">
                        <Columns>
                            <asp:BoundField DataField="OrderID" HeaderText='<%$ Resources:_Orders, ContentText_OrderNumber %>'
                                ItemStyle-CssClass="itemname">
                                <HeaderStyle />
                            </asp:BoundField>
                            <asp:BoundField DataField="PurchaseOrderNumber" HeaderText='<%$ Resources:_Orders, ContentText_PONumber %>'
                                ItemStyle-CssClass="itemname">
                                <HeaderStyle />
                            </asp:BoundField>
                            <asp:TemplateField ItemStyle-CssClass="selectfield">
                                <ItemTemplate>
                                     <asp:HyperLink ID="lnkOrderEdit" Text='<%$ Resources:_Kartris, FormButton_Edit %>' runat="server"
                                     NavigateUrl='<%# "~/Admin/_ModifyOrderStatus.aspx?OrderID=" & Eval("OrderID") %>'
                                     CssClass="linkbutton icon_edit" />    
                                     
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView><div class="spacer"></div>
                </asp:Panel>
                <!-- Config -->
                <asp:Panel ID="pnlConfig" runat="server" Visible="false">
                    <div class="sidebar">
                        <h2>
                            <asp:Literal ID="litBackMenuConfigSettings" runat="server" Text="<%$ Resources: _Kartris, BackMenu_ConfigSettings %>" />
                            <em>(<asp:Literal ID="litConfig" runat="server" />)</em></h2>
                        <p>
                            <asp:HyperLink NavigateUrl="~/Admin/_Config.aspx" ID="lnkNewSearch" runat="server"
                                CssClass="linkbutton icon_edit" Text='<%$ Resources:_Search, ContentText_NewSearch %>' /></p>
                    </div>
                    <asp:GridView CssClass="kartristable" ID="gvwConfig" runat="server" AllowPaging="True" AutoGenerateColumns="False"
                        DataKeyNames="ConfigName" AutoGenerateEditButton="False" GridLines="None" PageSize="15"
                        OnPageIndexChanging="gridView_PageIndexChanging">
                        <Columns>
                            <asp:BoundField DataField="ConfigName" HeaderText='<%$ Resources:_Kartris, ContentText_Name %>'
                                ItemStyle-CssClass="itemname">
                                <HeaderStyle />
                            </asp:BoundField>
                            <asp:TemplateField ItemStyle-CssClass="selectfield">
                                <ItemTemplate>
                                     <asp:HyperLink ID="lnkConfigSearch" Text='<%$ Resources:_Kartris, FormButton_Edit %>' runat="server"
                                     NavigateUrl='<%# "~/Admin/_Config.aspx?name=" & Eval("ConfigName") %>'
                                     CssClass="linkbutton icon_edit" />  

                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView><div class="spacer"></div>
                </asp:Panel>
                <!-- Site Text (LanguageStrings) -->
                <asp:Panel ID="pnlSiteText" runat="server" Visible="false">
                    <div class="sidebar">
                        <h2>
                            <asp:Literal ID="litBackMenuLanguageStrings" runat="server" Text="<%$ Resources: _Kartris, BackMenu_LanguageStrings %>" />
                            <em>(<asp:Literal ID="litSiteText" runat="server" />)</em></h2>
                        <p>
                            <asp:HyperLink NavigateUrl="~/Admin/_LanguageStrings.aspx" ID="lnkNewSearch2" runat="server"
                                CssClass="linkbutton icon_edit" Text='<%$ Resources:_Search, ContentText_NewSearch %>' /></p>
                    </div>
                    <asp:GridView CssClass="kartristable" ID="gvwSite" runat="server" AllowPaging="True" AutoGenerateColumns="False"
                        DataKeyNames="LSFB,LSLang,LSName" AutoGenerateEditButton="False" GridLines="None"
                        PageSize="25" OnPageIndexChanging="gridView_PageIndexChanging">
                        <Columns>
                            <asp:BoundField DataField="LSFB">
                                <HeaderStyle />
                            </asp:BoundField>
                            <asp:BoundField DataField="LSName" HeaderText='<%$ Resources:_Kartris, ContentText_ClassName %>'
                                ItemStyle-CssClass="itemname">
                                <HeaderStyle />
                            </asp:BoundField>
                            <asp:TemplateField ItemStyle-CssClass="selectfield">
                                <ItemTemplate>
                                     <asp:HyperLink ID="lnkLSFind" Text='<%$ Resources:_Kartris, FormButton_Edit %>' runat="server"
                                     NavigateUrl='<%# "~/Admin/_LanguageStrings.aspx?fb=" & Eval("LSFB") & "&lang=" & Eval("LSLang") & "&name=" & Eval("LSName") %>'
                                     CssClass="linkbutton icon_edit" /> 
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView><div class="spacer"></div>
                </asp:Panel>
                <!-- Pages (CMS) -->
                <asp:Panel ID="pnlPages" runat="server" Visible="false">
                    <div class="sidebar">
                        <h2>
                            <asp:Literal ID="Literal1" runat="server" Text="<%$ Resources: _Kartris, BackMenu_CustomPages %>" />
                            <em>(<asp:Literal ID="litPages" runat="server" />)</em></h2>
                    </div>
                    <asp:GridView CssClass="kartristable" ID="gvwPages" runat="server" AllowPaging="True" AutoGenerateColumns="False"
                        DataKeyNames="PageID" AutoGenerateEditButton="False" GridLines="None"
                        PageSize="25" OnPageIndexChanging="gridView_PageIndexChanging">
                        <Columns>
                            <asp:BoundField DataField="PageName" HeaderText='<%$ Resources:_Kartris, ContentText_ID %>'
                                ItemStyle-CssClass="itemname">
                                <HeaderStyle />
                            </asp:BoundField>
                            <asp:TemplateField ItemStyle-CssClass="selectfield">
                                <ItemTemplate>
                                     <asp:HyperLink ID="lnkCustomPageFind" Text='<%$ Resources:_Kartris, FormButton_Edit %>' runat="server"
                                     NavigateUrl='<%# "~/Admin/_CustomPages.aspx?id=" & Eval("PageID") %>'
                                     CssClass="linkbutton icon_edit" /> 
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                    <div class="spacer"></div>
                </asp:Panel>
            </ContentTemplate>
        </asp:UpdatePanel>
        <asp:UpdateProgress ID="prgSearch" runat="server" AssociatedUpdatePanelID="updResults">
            <ProgressTemplate>
                <div class="loadingimage">
                </div>
                <div class="updateprogress">
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
    </div>
</asp:Content>
