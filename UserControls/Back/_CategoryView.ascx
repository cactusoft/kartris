<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_CategoryView.ascx.vb"
    Inherits="_CategoryView" %>
<%@ Register TagPrefix="_user" TagName="LanguageContainer" Src="~/UserControls/Back/_LanguageContainer.ascx" %>
<%@ Register TagPrefix="_user" TagName="ItemPager" Src="~/UserControls/Back/_ItemPager.ascx" %>
<%@ Import Namespace="CkartrisDataManipulation" %>

<div id="page_categories">
    <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:PlaceHolder ID="phdHeader" runat="server">
                <asp:UpdatePanel ID="updHeader" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:PlaceHolder ID="phdEditCategory" runat="server">
                            <div class="floatright rightpad">
                                <asp:LinkButton CssClass="linkbutton icon_edit" ID="lnkBtnModifyPage" runat="server"
                                    CommandName="ModifyPage" ToolTip="<%$ Resources:_Category, ContentText_ModifyThePage %>"
                                    Text='<%$ Resources: _Kartris, FormButton_Edit %>' />
                            </div>
                        </asp:PlaceHolder>
                        <h1>
                            <asp:Literal ID="litCatName" runat="server" Text="<%$ Resources:_Category, BackMenu_Categories %>"
                                EnableViewState="False" /></h1>
                        <asp:PlaceHolder ID="phdBreadCrumbTrail" runat="server">
                            <div class="breadcrumbtrail">
                                <asp:SiteMapPath ID="smpMain" PathSeparator="&nbsp;" SiteMapProvider="_CategorySiteMapProvider"
                                    runat="server" />
                            </div>
                        </asp:PlaceHolder>
                    </ContentTemplate>
                </asp:UpdatePanel>
                <div class="spacer"></div>
            </asp:PlaceHolder>
            <asp:UpdatePanel ID="updCategoryViews" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:MultiView ID="mvwCategory" runat="server" ActiveViewIndex="0">
                        <asp:View ID="viwCategoryHierarchy" runat="server">
                            <asp:UpdatePanel ID="updSubCategories" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <div class="section" id="section_categories">
                                        <asp:PlaceHolder ID="phdSubCategories" runat="server">
                                            <div class="floatright rightpad">
                                                <asp:LinkButton CssClass="linkbutton icon_new" ID="lnkBtnNewCategory" runat="server"
                                                    CommandName="NewCategory" ToolTip="<%$ Resources:_Category, ContentText_AddNewSubcategory %>"
                                                    Text='<%$ Resources:_Kartris, FormButton_New %>' />
                                            </div>
                                            <h2>
                                                <asp:Literal ID="litSubCategories" runat="server" Text="<%$ Resources:_Category, ContentText_SubCategories %>"
                                                    EnableViewState="False" /></h2>
                                            <_user:ItemPager ID="_UC_ItemPager_CAT_Header" runat="server" Visible="false" />
                                            <asp:Button Visible="false" Text="Update Preference" runat="server" ID="btnUpdatePreference" />
                                            <asp:HiddenField ID="currentPreference" Value='' runat="server" />
                                            <asp:DataList ID="dtlSubCategories" runat="server" CssClass="kartristable Kartris-DataView notableheader">
                                                <ItemStyle />
                                                <AlternatingItemStyle CssClass="Kartris-GridView-Alternate" />
                                                <ItemTemplate>
                                                    <div class="floatright">

                                                        <asp:HyperLink CssClass="linkbutton icon_edit" runat="server" ID="lnkButtonEditCategory"
                                                            ToolTip="<%$ Resources:_Category, ContentText_EditThisCategory %>" Text='<%$ Resources: _Kartris, FormButton_Edit %>'
                                                            NavigateUrl='<%# "~/Admin/_ModifyCategory.aspx?CategoryID=" & Eval("CAT_ID") & "&SiteID=" & _GetSiteID() & "&strParent=" & IIf(String.IsNullOrEmpty(_GetParentCategory), _GetCategoryID(), _GetParentCategory() & "," & _GetCategoryID())  %>' />
                                                    </div>

                                                    <asp:Literal ID="litCategoryID" runat="server" Text='<%# Eval("CAT_ID") %>' Visible="false"></asp:Literal>
                                                    <asp:TemplateField ItemStyle-Width="30">
                                                        <itemtemplate>
                                                            <input type="hidden" name="CAT_ID" value='<%# Eval("CAT_ID") %>' />
                                                        </itemtemplate>
                                                    </asp:TemplateField>
                                                    <asp:HyperLink runat="server" ID="lnkSelectPlus"
                                                        CssClass="imagebutton button_expand"
                                                        ToolTip='<%$ Resources:_Kartris, FormButton_Select %>' Text='+'
                                                        NavigateUrl='<%# FormatNavURL(_GetParentCategory, _GetCategoryID(), _GetSiteID())  %>' /><asp:PlaceHolder ID="phdCategoriesSort" runat="server" Visible='<%# Eval("SortByValue") %>'>
                                                            <div class="updownbuttons">
                                                                <asp:LinkButton ID="lnkBtnMoveUp" runat="server" CommandName="MoveUp" CommandArgument='<%# Eval("CAT_ID") %>'
                                                                    Text="+" CssClass="triggerswitch triggerswitch_on" />
                                                                <asp:LinkButton ID="lnkBtnMoveDown" runat="server" CommandName="MoveDown" CommandArgument='<%# Eval("CAT_ID") %>'
                                                                    Text="-" CssClass="triggerswitch triggerswitch_off" />
                                                            </div>
                                                        </asp:PlaceHolder>
                                                    <strong>
                                                        <asp:HyperLink runat="server" ID="lnkCategoryLink"
                                                            ToolTip='<%# Eval("CAT_Name") %>' Text='<%# Eval("CAT_Name") %>'
                                                            NavigateUrl='<%# FormatNavURL(_GetParentCategory, _GetCategoryID(), _GetSiteID())  %>' /></strong>
                                                </ItemTemplate>
                                                <FooterTemplate>
                                                    <asp:LinkButton ID="lnkBtnRefreshCat" runat="server" CommandName="Refresh" Text="refresh" CssClass="invisible btnRefreshCat" />
                                                </FooterTemplate>
                                            </asp:DataList>
                                        </asp:PlaceHolder>
                                        <asp:PlaceHolder ID="phdNoSubCategories" runat="server" Visible="false"><span class="noresults">
                                            <asp:Literal ID="litNoSubCategories" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>"
                                                EnableViewState="False"></asp:Literal></span></asp:PlaceHolder>
                                    </div>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                            <asp:UpdatePanel ID="updProducts" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <div class="section" id="section_products">
                                        <!-- Products Expanded (all versions showing) -->

                                        <asp:PlaceHolder ID="phdProductsExpanded" runat="server" Visible="false">
                                            <div id="products_expanded">
                                                <div class="floatright rightpad">
                                                    <a class="linkbutton icon_new" href="_ModifyProduct.aspx?ProductID=0&amp;CategoryID=<% =Request.QueryString("CategoryID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;strParent=<% =IIF(String.IsNullorEmpty(Request.Querystring("strParent")),0,Request.Querystring("strParent")) %>">
                                                        <asp:Literal ID="litFormatButtonNew" Text='<%$ Resources:_Kartris, FormButton_New %>'
                                                            runat="server"></asp:Literal></a>
                                                </div>
                                                <h2>
                                                    <asp:Literal ID="litContentTextProducts" runat="server" Text="<%$ Resources:_Product, ContentText_Products %>" />

                                                    <asp:LinkButton ID="lnkCollapseProducts" runat="server" CssClass="expandproductlink">[-]</asp:LinkButton>
                                                </h2>
                                                <asp:PlaceHolder ID="phdNoProducts2" runat="server"><span class="noresults">
                                                    <asp:Literal ID="litNoItemsFound2" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>"
                                                        EnableViewState="False"></asp:Literal></span> </asp:PlaceHolder>
                                                <asp:DataList ID="dtlProductsExpanded" runat="server" CssClass="kartristable notableheader">
                                                    <ItemStyle CssClass="product-row" />
                                                    <ItemTemplate>
                                                        <asp:Literal ID="litProductType" runat="server" Text='<%# Eval("P_Type") %>' Visible="false"
                                                            EnableViewState="False" />
                                                        <div class="floatright">
                                                            <a class="linkbutton icon_edit normalweight" href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;CategoryID=<% =Request.Querystring("CategoryID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;strParent=<% =IIF(String.IsNullorEmpty(Request.Querystring("strParent")),0,Request.Querystring("strParent")) %>&amp;strTab=attributes">
                                                                <asp:Literal ID="litAttributesLink" Text='<%$ Resources:_Kartris, ContentText_ProductAttributes %>'
                                                                    runat="server"></asp:Literal></a> <a class="linkbutton icon_edit normalweight" href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;CategoryID=<% =Request.Querystring("CategoryID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;strParent=<% =IIF(String.IsNullorEmpty(Request.Querystring("strParent")),0,Request.Querystring("strParent")) %>&amp;strTab=reviews">
                                                                        <asp:Literal ID="litReviewsLink" Text='<%$ Resources:_Product, ContentText_Reviews %>'
                                                                            runat="server"></asp:Literal></a> <a class="linkbutton icon_edit normalweight" href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;CategoryID=<% =Request.Querystring("CategoryID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;strParent=<% =IIF(String.IsNullorEmpty(Request.Querystring("strParent")),0,Request.Querystring("strParent")) %>&amp;strTab=relatedproducts">
                                                                                <asp:Literal ID="litRelatedProductsLink" Text='<%$ Resources:_Product, ContentText_RelatedProducts %>'
                                                                                    runat="server"></asp:Literal></a>

                                                            <a class="linkbutton icon_edit normalweight" href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;CategoryID=<% =Request.Querystring("CategoryID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;strParent=<% =IIF(String.IsNullorEmpty(Request.Querystring("strParent")),0,Request.Querystring("strParent")) %>&amp;strTab=versions">
                                                                <asp:Literal ID="litVersionsLink" Text='<%$ Resources:_Kartris, BackMenu_Versions %>'
                                                                    runat="server"></asp:Literal></a>
                                                            <asp:PlaceHolder ID="phdOptionsLink" runat="server" Visible="false"><a class="linkbutton icon_edit normalweight"
                                                                href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;strParent=<% =IIF(String.IsNullorEmpty(Request.Querystring("strParent")),0,Request.Querystring("strParent")) %>&amp;CategoryID=<% =Request.Querystring("CategoryID") %>&amp;strTab=options">
                                                                <asp:Literal ID="litOptionsLink" Text='<%$ Resources:_Kartris, ContentText_Options %>'
                                                                    runat="server"></asp:Literal></a></asp:PlaceHolder>
                                                            <a class="linkbutton icon_edit normalweight" href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;CategoryID=<% =Request.Querystring("CategoryID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;strParent=<% =IIF(String.IsNullorEmpty(Request.Querystring("strParent")),0,Request.Querystring("strParent")) %>&amp;strTab=config">
                                                                <asp:Literal ID="litObjectConfig" Text='<%$ Resources:_Kartris, ContentText_ObjectConfig %>'
                                                                    runat="server"></asp:Literal></a>

                                                            <asp:HyperLink ID="lnkProduct" runat="server" ToolTip="<%$ Resources:_Product, ImageLabel_EditThisProduct %>"
                                                                Text='<%$ Resources: _Kartris, FormButton_Edit %>' NavigateUrl='<%# "~/Admin/_ModifyProduct.aspx?ProductID=" & Eval("P_ID") & "&CategoryID=" & _GetCategoryID() & "&strParent=" & IIf(String.IsNullOrEmpty(Request.QueryString("strParent")), 0, Request.QueryString("strParent")) %>'
                                                                CssClass="linkbutton icon_edit" />
                                                        </div>
                                                        <div>
                                                            <asp:Literal ID="litProductID" runat="server" Text='<%# Eval("P_ID") %>' Visible="false"
                                                                EnableViewState="False"></asp:Literal>
                                                            <strong>
                                                                <asp:HyperLink ID="lnkEdit" runat="server" ToolTip="<%$ Resources:_Product, ImageLabel_EditThisProduct %>"
                                                                    Text='<%# Eval("P_Name") %>' NavigateUrl='<%# "~/Admin/_ModifyProduct.aspx?ProductID=" & Eval("P_ID") & "&amp;strParent=" & Request.QueryString("strParent") %>'
                                                                    CssClass="" /></strong>
                                                        </div>
                                                        <table class="kartristable nested section_versions">
                                                            <thead>
                                                                <tr>
                                                                    <th>
                                                                        <asp:Literal ID="litVersionName" runat="server" Text='<%$ Resources:_Product, FormLabel_VersionName %>'
                                                                            EnableViewState="False" />
                                                                    </th>
                                                                    <th>
                                                                        <asp:Literal ID="litCodeNumber" runat="server" Text='<%$ Resources:_Product, ContentText_CodeNumber %>'
                                                                            EnableViewState="False" />
                                                                    </th>
                                                                    <th class="alignright">
                                                                        <asp:Literal ID="litQuantity" runat="server" Text='<%$ Resources:_Version, FormLabel_StockQuantity %>'
                                                                            EnableViewState="False" />
                                                                    </th>
                                                                    <th class="alignright">
                                                                        <asp:Literal ID="litPrice" runat="server" Text='<%$ Resources:_Kartris, ContentText_Price %>'
                                                                            EnableViewState="False" />
                                                                    </th>
                                                                    <th class="alignright">
                                                                        <asp:Literal ID="litTaxRate" runat="server" Text='<%$ Resources:_Version, ContentText_Tax %>'
                                                                            EnableViewState="False" />
                                                                    </th>
                                                                    <th class="alignright selectfield">
                                                                        <asp:PlaceHolder ID="phdNewVersionLink" runat="server"><a class="linkbutton icon_new"
                                                                            href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;VersionID=0&amp;strParent=<% =IIF(String.IsNullorEmpty(Request.Querystring("strParent")),0,Request.Querystring("strParent")) %>&amp;strTab=versions">
                                                                            <asp:Literal ID="litNewVersionLink" Text='<%$ Resources:_Kartris, FormButton_New %>'
                                                                                runat="server"></asp:Literal></a> </asp:PlaceHolder>
                                                                    </th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <asp:Repeater ID="rptVersions" runat="server">
                                                                    <ItemTemplate>
                                                                        <tr class="<%# If(Container.ItemIndex Mod 2 = 0, "", "Kartris-GridView-Alternate") %>">
                                                                            <td class="itemname">
                                                                                <asp:Literal ID="litV_ID" runat="server" Text='<%# Eval("V_ID") %>' Visible="false"
                                                                                    EnableViewState="False" />
                                                                                <asp:Literal ID="litProductID" runat="server" Text='<%# Eval("V_ProductID") %>' Visible="false"
                                                                                    EnableViewState="False" />
                                                                                <asp:Literal ID="litV_Name" runat="server" Text='<%# Eval("V_Name") %>' EnableViewState="False"></asp:Literal>
                                                                            </td>
                                                                            <td>
                                                                                <asp:Literal ID="litV_CodeNumber" runat="server" Text='<%# Eval("V_CodeNumber") %>'
                                                                                    EnableViewState="False"></asp:Literal>
                                                                            </td>
                                                                            <td class="alignright">
                                                                                <asp:Literal ID="litV_Quantity" runat="server" Text='<%# Eval("V_Quantity") %>' EnableViewState="False"></asp:Literal>
                                                                            </td>
                                                                            <td class="alignright">
                                                                                <asp:Literal ID="litV_Price" runat="server" Text='<%# CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency(), Eval("V_Price")) %>' EnableViewState="False"></asp:Literal>
                                                                            </td>
                                                                            <td class="alignright">
                                                                                <% If TaxRegime.VTax_Type = "boolean" Then %>
                                                                                <span class="checkbox">
                                                                                    <asp:CheckBox ID="chkTax" runat="server" Checked='<%# Eval("T_TaxRate") <>0 %>' Enabled="False" EnableViewState="False"></asp:CheckBox></span>
                                                                                <% Else%>
                                                                                <asp:Literal ID="litT_TaxRate" runat="server" Text='<%# Eval("T_TaxRate") & "%" %>' EnableViewState="False"></asp:Literal>
                                                                                <% End If%>
                                                                            </td>
                                                                            <td class="alignright nowrap">
                                                                                <asp:PlaceHolder ID="phdCloneLink" Visible='<%# Eval("ShowClone") %>' runat="server">
                                                                                    <a class="linkbutton icon_new" href="_ModifyProduct.aspx?ProductID=<%# Eval("V_ProductID") %>&amp;CategoryID=<% =_GetCategoryID() %>&amp;VersionID=<%# Eval("V_ID") %>&amp;strParent=<% =IIF(String.IsNullorEmpty(Request.Querystring("strParent")),0,Request.Querystring("strParent")) %>&amp;strTab=versions&strClone=yes">
                                                                                        <asp:Literal ID="litFormButtonClone" Text='<%$ Resources:_Kartris, FormButton_Clone %>'
                                                                                            runat="server"></asp:Literal></a></asp:PlaceHolder>
                                                                                <a class="linkbutton icon_edit" href="_ModifyProduct.aspx?ProductID=<%# Eval("V_ProductID") %>&amp;CategoryID=<% =_GetCategoryID() %>&amp;VersionID=<%# Eval("V_ID") %>&amp;strParent=<% =IIF(String.IsNullorEmpty(Request.Querystring("strParent")),0,Request.Querystring("strParent")) %>&amp;strTab=versions">
                                                                                    <asp:Literal ID="litRelatedProductsLink" Text='<%$ Resources:_Kartris, FormButton_Edit %>'
                                                                                        runat="server"></asp:Literal></a>
                                                                            </td>
                                                                        </tr>
                                                                    </ItemTemplate>
                                                                </asp:Repeater>
                                                            </tbody>
                                                        </table>
                                                    </ItemTemplate>

                                                </asp:DataList>
                                                <_user:ItemPager ID="_UC_ItemPager_PROD_Header2" runat="server" Visible="true" />
                                            </div>
                                        </asp:PlaceHolder>
                                        <!-- Regular Products view -->
                                        <asp:PlaceHolder ID="phdProducts" runat="server">
                                            <div class="floatright rightpad">
                                                <asp:LinkButton ID="lnkTurnProductsOff" Text="<%$ Resources:_Product, ContentText_TurnAllProductsOff %>" runat="server" CssClass="linkbutton" Visible="False" />
                                                <asp:LinkButton ID="lnkTurnProductsOn" Text="<%$ Resources:_Product, ContentText_TurnAllProductsOn %>" runat="server" CssClass="linkbutton" Visible="False" />

                                                <a style="margin-left: 40px" class="linkbutton icon_new" href="_ModifyProduct.aspx?ProductID=0&amp;CategoryID=<% =_GetCategoryID() %>&amp;strParent=<% =_GetSiteID() %>::<% =_CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>">
                                                    <asp:Literal ID="litNewProductLink" Text='<%$ Resources:_Kartris, FormButton_New %>'
                                                        runat="server"></asp:Literal></a>
                                            </div>
                                            <h2>
                                                <asp:Literal ID="litProducts" runat="server" Text="<%$ Resources:_Product, ContentText_Products %>" />
                                                <asp:LinkButton ID="lnkExpandProducts" runat="server" CssClass="expandproductlink">[+]</asp:LinkButton>
                                            </h2>
                                            <asp:PlaceHolder ID="phdNoProducts" runat="server"><span class="noresults">
                                                <asp:Literal ID="litNoProducts" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>"
                                                    EnableViewState="False"></asp:Literal></span> </asp:PlaceHolder>
                                            <asp:Button Visible="false" Text="Update Preference" runat="server" ID="btnUpdatePreferenceProducts" />
                                            <asp:HiddenField ID="currentPreferenceProducts" Value='' runat="server" />
                                            <asp:DataList ID="dtlProducts" runat="server" CssClass="kartristable notableheader">
                                                <ItemStyle />
                                                <AlternatingItemStyle CssClass="Kartris-GridView-Alternate" />
                                                <SelectedItemStyle CssClass="Kartris-DataList-SelectedItem" />
                                                <ItemTemplate>
                                                    <asp:TemplateField ItemStyle-Width="30">
                                                        <itemtemplate>
                                                            <input type="hidden" name="P_ID" value='<%# Eval("P_ID") %>' />
                                                        </itemtemplate>
                                                    </asp:TemplateField>
                                                    <asp:Literal ID="litProductID" runat="server" Text='<%# Eval("P_ID") %>' Visible="false" />
                                                    <asp:Literal ID="litProductType" runat="server" Text='<%# Eval("P_Type") %>' Visible="false" />
                                                    <div class="floatright">



                                                        <a class="linkbutton icon_edit normalweight" href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;CategoryID=<% =_GetCategoryID() %>&amp;SiteID=<% =_GetSiteID() %>&amp;strParent=<% =_GetSiteID() %>::<% =_CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>&amp;strTab=attributes">
                                                            <asp:Literal ID="litAttributesLink" Text='<%$ Resources:_Kartris, ContentText_ProductAttributes %>'
                                                                runat="server"></asp:Literal></a> <a class="linkbutton icon_edit normalweight" href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;CategoryID=<% =_GetCategoryID() %>&amp;strParent=<% =_GetSiteID() %>::<% =_CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>&amp;strTab=reviews">
                                                                    <asp:Literal ID="litReviewsLink" Text='<%$ Resources:_Product, ContentText_Reviews %>'
                                                                        runat="server"></asp:Literal></a> <a class="linkbutton icon_edit normalweight" href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;CategoryID=<% =_GetCategoryID() %>&amp;strParent=<% =_GetSiteID() %>::<% =_CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>&amp;strTab=relatedproducts">
                                                                            <asp:Literal ID="litRelatedProductsLink" Text='<%$ Resources:_Product, ContentText_RelatedProducts %>'
                                                                                runat="server"></asp:Literal></a>
                                                        <a class="linkbutton icon_edit normalweight" href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;CategoryID=<% =Request.Querystring("CategoryID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;strParent=<% =_GetSiteID() %>::<% =_CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>&amp;strTab=versions">
                                                            <asp:Literal ID="litVersionsLink" Text='<%$ Resources:_Kartris, BackMenu_Versions %>'
                                                                runat="server"></asp:Literal></a>
                                                        <asp:PlaceHolder ID="phdOptionsLink" runat="server" Visible="false"><a class="linkbutton icon_edit normalweight"
                                                            href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;CategoryID=<% =_GetCategoryID() %>&amp;SiteID=<% =_GetSiteID() %>&amp;strParent=<% =_GetSiteID() %>::<% =_CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>&amp;strTab=options">
                                                            <asp:Literal ID="litOptionsLink" Text='<%$ Resources:_Kartris, ContentText_Options %>'
                                                                runat="server"></asp:Literal></a></asp:PlaceHolder>
                                                        <a class="linkbutton icon_edit normalweight" href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;CategoryID=<% =Request.Querystring("CategoryID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;strParent=<% =_GetSiteID() %>::<% =_CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>&amp;strTab=config">
                                                            <asp:Literal ID="litObjectConfig" Text='<%$ Resources:_Kartris, ContentText_ObjectConfig %>'
                                                                runat="server"></asp:Literal></a>

                                                        <asp:HyperLink ID="lnkBtnProduct" runat="server" ToolTip="<%$ Resources:_Product, ImageLabel_EditThisProduct %>"
                                                            Text='<%$ Resources: _Kartris, FormButton_Edit %>' NavigateUrl='<%# "~/Admin/_ModifyProduct.aspx?ProductID=" & Eval("P_ID") & "&CategoryID=" & _GetCategoryID() & "&SiteID="& _GetSiteID() & "&strParent=" & _GetSiteID() & "::" & _CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>'
                                                            CssClass="linkbutton icon_edit" />
                                                    </div>
                                                    <asp:LinkButton ID="lnkBtnSelect" runat="server" CommandName="select" Text="+" CssClass="imagebutton button_expand" /><asp:PlaceHolder ID="phdProductSort" runat="server" Visible='<%# Eval("SortByValue") %>'>
                                                        <div class="updownbuttons">
                                                            <asp:LinkButton ID="lnkBtnMoveUp" runat="server" CommandName="MoveUp" CommandArgument='<%# Eval("P_ID") %>' Text="+" CssClass="triggerswitch triggerswitch_on" />
                                                            <asp:LinkButton ID="lnkBtnMoveDown" runat="server" CommandName="MoveDown" CommandArgument='<%# Eval("P_ID") %>' Text="-" CssClass="triggerswitch triggerswitch_off" />
                                                        </div>
                                                    </asp:PlaceHolder>
                                                    <strong>
                                                        <asp:Literal ID="litProductNameStyle" runat="server" Visible='<%# Eval("P_Live")=false %>'><span class="hidden"></asp:Literal>
                                                        <asp:HyperLink ID="lnkEditThisProduct" runat="server" ToolTip="<%$ Resources:_Product, ImageLabel_EditThisProduct %>"
                                                            Text='<%# Eval("P_Name") %>' NavigateUrl='<%# "~/Admin/_ModifyProduct.aspx?ProductID=" & Eval("P_ID")& "&CategoryID=" & _GetCategoryID() & "&SiteID="& _GetSiteID() & "&strParent="  & _GetSiteID() & "::" & _CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>' /></strong>
                                                    <asp:Literal ID="litProductNameStyleClose" runat="server" Visible='<%# Eval("P_Live")=false %>'></span></asp:Literal>
                                                </ItemTemplate>
                                                <SelectedItemTemplate>
                                                    <asp:Literal ID="litProductType" runat="server" Text='<%# Eval("P_Type") %>' Visible="false"
                                                        EnableViewState="False" />
                                                    <div class="floatright">

                                                        <a class="linkbutton icon_edit normalweight" href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;CategoryID=<% =_GetCategoryID() %>&amp;SiteID=<% =_GetSiteID() %>&amp;strParent=<% =_GetSiteID() %>::<% =_CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>&amp;strTab=attributes">
                                                            <asp:Literal ID="litAttributesLink" Text='<%$ Resources:_Kartris, ContentText_ProductAttributes %>'
                                                                runat="server"></asp:Literal></a> <a class="linkbutton icon_edit normalweight" href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;CategoryID=<% =_GetCategoryID() %>&amp;strParent=<% =_GetSiteID() %>::<% =_CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>&amp;strTab=reviews">
                                                                    <asp:Literal ID="litReviewsLink" Text='<%$ Resources:_Product, ContentText_Reviews %>'
                                                                        runat="server"></asp:Literal></a> <a class="linkbutton icon_edit normalweight" href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;CategoryID=<% =_GetCategoryID() %>&amp;strParent=<% =_GetSiteID() %>::<% =_CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>&amp;strTab=relatedproducts">
                                                                            <asp:Literal ID="litRelatedProductsLink" Text='<%$ Resources:_Product, ContentText_RelatedProducts %>'
                                                                                runat="server"></asp:Literal></a>
                                                        <a class="linkbutton icon_edit normalweight" href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;CategoryID=<% =Request.Querystring("CategoryID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;strParent=<% =_GetSiteID() %>::<% =_CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>&amp;strTab=versions">
                                                            <asp:Literal ID="litVersionsLink" Text='<%$ Resources:_Kartris, BackMenu_Versions %>'
                                                                runat="server"></asp:Literal></a>
                                                        <asp:PlaceHolder ID="phdOptionsLink" runat="server" Visible="false"><a class="linkbutton icon_edit normalweight"
                                                            href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;strParent=<% =_CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>&amp;CategoryID=<% =_GetCategoryID() %>&amp;strTab=options">
                                                            <asp:Literal ID="litOptionsLink" Text='<%$ Resources:_Kartris, ContentText_Options %>'
                                                                runat="server"></asp:Literal></a></asp:PlaceHolder>
                                                        <a class="linkbutton icon_edit normalweight" href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;CategoryID=<% =Request.Querystring("CategoryID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;strParent=<% =_GetSiteID() %>::<% =_CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>&amp;strTab=config">
                                                            <asp:Literal ID="litObjectConfig" Text='<%$ Resources:_Kartris, ContentText_ObjectConfig %>'
                                                                runat="server"></asp:Literal></a>
                                                        <asp:HyperLink ID="lnkProduct" runat="server" ToolTip="<%$ Resources:_Product, ImageLabel_EditThisProduct %>"
                                                            Text='<%$ Resources: _Kartris, FormButton_Edit %>' NavigateUrl='<%# "~/Admin/_ModifyProduct.aspx?ProductID=" & Eval("P_ID") & "&CategoryID=" & _GetCategoryID() & "&SiteID="& _GetSiteID() & "&strParent=" & _CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>'
                                                            CssClass="linkbutton icon_edit" />
                                                    </div>
                                                    <div>
                                                        <asp:Literal ID="litProductID" runat="server" Text='<%# Eval("P_ID") %>' Visible="false"
                                                            EnableViewState="False"></asp:Literal>
                                                        <strong>
                                                            <asp:HyperLink ID="lnkEdit" runat="server" ToolTip="<%$ Resources:_Product, ImageLabel_EditThisProduct %>"
                                                                Text='<%# Eval("P_Name") %>' NavigateUrl='<%# "~/Admin/_ModifyProduct.aspx?ProductID=" & Eval("P_ID") & "&SiteID="& _GetSiteID() & "&amp;strParent=" & Request.Querystring("strParent") %>'
                                                                CssClass="" /></strong>
                                                    </div>
                                                    <table class="kartristable nested section_versions">
                                                        <thead>
                                                            <tr>
                                                                <th>
                                                                    <asp:Literal ID="litVersionName" runat="server" Text='<%$ Resources:_Product, FormLabel_VersionName %>'
                                                                        EnableViewState="False" />
                                                                </th>
                                                                <th>
                                                                    <asp:Literal ID="litCodeNumber" runat="server" Text='<%$ Resources:_Product, ContentText_CodeNumber %>'
                                                                        EnableViewState="False" />
                                                                </th>
                                                                <th class="alignright">
                                                                    <asp:Literal ID="litQuantity" runat="server" Text='<%$ Resources:_Version, FormLabel_StockQuantity %>'
                                                                        EnableViewState="False" />
                                                                </th>
                                                                <th class="alignright">
                                                                    <asp:Literal ID="litPrice" runat="server" Text='<%$ Resources:_Kartris, ContentText_Price %>'
                                                                        EnableViewState="False" />
                                                                </th>
                                                                <th class="alignright">
                                                                    <asp:Literal ID="litTaxRate" runat="server" Text='<%$ Resources:_Version, ContentText_Tax %>'
                                                                        EnableViewState="False" />
                                                                </th>
                                                                <th class="alignright selectfield">
                                                                    <asp:PlaceHolder ID="phdNewVersionLink" runat="server"><a class="linkbutton icon_new"
                                                                        href="_ModifyProduct.aspx?ProductID=<%# Eval("P_ID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;VersionID=0&amp;strParent=<% =_CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>&amp;strTab=versions">
                                                                        <asp:Literal ID="litNewVersionLink" Text='<%$ Resources:_Kartris, FormButton_New %>'
                                                                            runat="server"></asp:Literal></a> </asp:PlaceHolder>
                                                                </th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <asp:Repeater ID="rptVersions" runat="server">
                                                                <ItemTemplate>
                                                                    <tr class="<%# If(Container.ItemIndex Mod 2 = 0, "", "Kartris-GridView-Alternate") %>">
                                                                        <td class="itemname">
                                                                            <asp:Literal ID="litV_ID" runat="server" Text='<%# Eval("V_ID") %>' Visible="false"
                                                                                EnableViewState="False" />
                                                                            <asp:Literal ID="litProductID" runat="server" Text='<%# Eval("V_ProductID") %>' Visible="false"
                                                                                EnableViewState="False" />
                                                                            <asp:Literal ID="litV_Name" runat="server" Text='<%# Eval("V_Name") %>' EnableViewState="False"></asp:Literal>
                                                                        </td>
                                                                        <td>
                                                                            <asp:Literal ID="litV_CodeNumber" runat="server" Text='<%# Eval("V_CodeNumber") %>'
                                                                                EnableViewState="False"></asp:Literal>
                                                                        </td>
                                                                        <td class="alignright">
                                                                            <asp:Literal ID="litV_Quantity" runat="server" Text='<%# Eval("V_Quantity") %>' EnableViewState="False"></asp:Literal>
                                                                        </td>
                                                                        <td class="alignright">
                                                                            <asp:Literal ID="litV_Price" runat="server" Text='<%# CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency(), Eval("V_Price")) %>' EnableViewState="False"></asp:Literal>
                                                                        </td>
                                                                        <td class="alignright">
                                                                            <% If TaxRegime.VTax_Type = "boolean" Then %>
                                                                            <span class="checkbox">
                                                                                <asp:CheckBox ID="chkTax" runat="server" Checked='<%# Eval("T_TaxRate") <>0 %>' Enabled="False" EnableViewState="False"></asp:CheckBox></span>
                                                                            <% Else%>
                                                                            <asp:Literal ID="litT_TaxRate" runat="server" Text='<%# CkartrisDisplayFunctions.FixDecimal(Eval("T_TaxRate")) & "%" %>' EnableViewState="False"></asp:Literal>
                                                                            <% End If%>
                                                                        </td>
                                                                        <td class="alignright nowrap">
                                                                            <asp:PlaceHolder ID="phdCloneLink" Visible='<%# Eval("ShowClone") %>' runat="server">
                                                                                <a class="linkbutton icon_new" href="_ModifyProduct.aspx?ProductID=<%# Eval("V_ProductID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;CategoryID=<% =_GetCategoryID() %>&amp;VersionID=<%# Eval("V_ID") %>&amp;strParent=<% =_CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>&amp;strTab=versions&strClone=yes">
                                                                                    <asp:Literal ID="litFormButtonClone" Text='<%$ Resources:_Kartris, FormButton_Clone %>'
                                                                                        runat="server"></asp:Literal></a></asp:PlaceHolder>
                                                                            <a class="linkbutton icon_edit" href="_ModifyProduct.aspx?ProductID=<%# Eval("V_ProductID") %>&amp;SiteID=<% =_GetSiteID() %>&amp;CategoryID=<% =_GetCategoryID() %>&amp;VersionID=<%# Eval("V_ID") %>&amp;strParent=<% =_CategorySiteMapProvider.StripParents(Request.Querystring("strParent")) %>&amp;strTab=versions">
                                                                                <asp:Literal ID="litRelatedProductsLink" Text='<%$ Resources:_Kartris, FormButton_Edit %>'
                                                                                    runat="server"></asp:Literal></a>
                                                                        </td>
                                                                    </tr>
                                                                </ItemTemplate>
                                                            </asp:Repeater>
                                                        </tbody>
                                                    </table>
                                                </SelectedItemTemplate>
                                                <FooterTemplate>
                                                    <asp:LinkButton ID="lnkBtnRefreshProd" runat="server" CommandName="Refresh" Text="refresh" CssClass="invisible btnRefreshProd" />
                                                </FooterTemplate>
                                            </asp:DataList>
                                            <_user:ItemPager ID="_UC_ItemPager_PROD_Header" runat="server" Visible="true" />
                                        </asp:PlaceHolder>
                                    </div>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                            <%-- Preview Button  --%>
                            <div class="submitbuttons topsubmitbuttons">
                                <asp:HyperLink ID="lnkPreview" runat="server" CssClass="button previewbutton"
                                    Text='<%$ Resources: _Kartris, FormButton_Preview %>' ToolTip='<%$ Resources: _Kartris, FormButton_Preview %>'
                                    Target="_blank" />
                            </div>
                        </asp:View>
                        <asp:View ID="viwCategoryDetails" runat="server">
                            <asp:UpdatePanel ID="updLanguageContainer" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:PlaceHolder ID="phdLangContainer" runat="server">
                                        <_user:LanguageContainer ID="_UC_LangContainer" runat="server" />
                                    </asp:PlaceHolder>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                            <%-- Save Button  --%>
                            <div class="submitbuttons ">
                                <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:Button ID="lnkBtnSave" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                            ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' />
                                        <asp:Button ID="lnkBtnCancel" runat="server" CssClass="button cancelbutton" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                            ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                        </asp:View>
                    </asp:MultiView>
                </ContentTemplate>
            </asp:UpdatePanel>
            <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
        </ContentTemplate>
    </asp:UpdatePanel>

    <script type="text/javascript">
        function dndEvents() {
            $("[id*=dtlSubCategories]").sortable({
                items: 'tr',
                cursor: 'pointer',
                axis: 'y',
                dropOnEmpty: false,
                start: function (e, ui) {
                    ui.item.addClass("selected");
                    $(ui.item).find(".floatright").hide();
                },
                stop: function (e, ui) {
                    ui.item.removeClass("selected");
                    var catIds = document.forms[0].elements["CAT_ID"];
                    var catIdsStr = "";
                    for (var i = 0; i < catIds.length; i++) {
                        if (catIdsStr == "") {
                            catIdsStr = catIds[i].value;
                        } else {
                            catIdsStr = catIdsStr + "," + catIds[i].value;
                        }

                    }
                    $(ui.item).find(".floatright").show();
                    if (catIdsStr != $("#phdMain__UC_CategoryView_currentPreference").val()) {
                        $(".btnRefreshCat")[0].click();
                    }
                },
                receive: function (e, ui) {
                    $(this).find("tbody").append(ui.item);
                }
            });

    <% If sortByValueBool Then %>
            $("[id*=dtlProducts]").sortable({
                items: 'tr',
                cursor: 'pointer',
                axis: 'y',
                dropOnEmpty: false,
                start: function (e, ui) {
                    ui.item.addClass("selected");
                    $(ui.item).find(".floatright").hide();
                },
                stop: function (e, ui) {
                    ui.item.removeClass("selected");
                    var pIds = document.forms[0].elements["P_ID"];
                    var pIdsStr = "";
                    for (var i = 0; i < pIds.length; i++) {
                        if (pIdsStr == "") {
                            pIdsStr = pIds[i].value;
                        } else {
                            pIdsStr = pIdsStr + "," + pIds[i].value;
                        }

                    }
                    $(ui.item).find(".floatright").show();
                    if (pIdsStr != $("#phdMain__UC_CategoryView_currentPreferenceProducts").val()) {
                        $(".btnRefreshProd")[0].click();
                    }
                },
                receive: function (e, ui) {
                    $(this).find("tbody").append(ui.item);
                }
            });
    <%End If %>

            var isDragging = false;
            $("tr")
                .mousedown(function () {
                    isDragging = true;
                })
                .mousemove(function (e) {
                    if (isDragging) {
                        var y = $("#divPageContent").scrollTop();  //your current y position on the page
                        if ((screen.availHeight - e.screenY) < 100) {
                            $("#divPageContent").scrollTop(y + 10);
                        }
                        else if ((e.screenY) < (400)) {
                            $("#divPageContent").scrollTop(y - 10);
                        }
                    }

                })
                .mouseup(function () {
                    var wasDragging = isDragging;
                    isDragging = false;
                });
        }

        var prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_endRequest(function (s, e) {
            dndEvents();
        });

        $(function () {
            dndEvents();
        });

    </script>
</div>
<asp:UpdateProgress ID="prgMain" runat="server" AssociatedUpdatePanelID="updMain">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
