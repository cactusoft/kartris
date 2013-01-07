<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_EditCategory.ascx.vb"
    Inherits="UserControls_Back_EditCategory" %>
<%@ Register TagPrefix="_user" TagName="LanguageContainer" Src="~/UserControls/Back/_LanguageContainer.ascx" %>
<%@ Register TagPrefix="_user" TagName="AutoComplete" Src="~/UserControls/Back/_AutoCompleteInput.ascx" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <%-- Languages --%>
        <div>
            <asp:UpdatePanel ID="updLanguageContainer" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:PlaceHolder ID="phdLangContainer" runat="server">
                        <_user:LanguageContainer ID="_UC_LangContainer" runat="server" />
                    </asp:PlaceHolder>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
        <div class="line">
        </div>
        <div class="Kartris-DetailsView">
            <div class="Kartris-DetailsView-Data">
                <ul>
                    <%-- Parent Category(ies) AutoCompleteInput --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litCategoryParent" runat="server" Text="<%$ Resources:_Category, ContentText_CategoryParent %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:PlaceHolder ID="phdCategories" runat="server">
                            <asp:UpdatePanel ID="updCategoryParent" runat="server" UpdateMode="Conditional" RenderMode="Inline">
                                <ContentTemplate>
                                    <asp:ListBox ID="lbxParentCategories" runat="server"></asp:ListBox>
                                    <asp:Literal ID="litParentCategories_Hidden" runat="server" Visible="false" />
                                    <asp:LinkButton ID="lnkBtnRemoveParentCategory" runat="server" Text='<%$ Resources:_Kartris, ContentText_RemoveSelected %>'
                                        CssClass="linkbutton icon_delete" /><br />
                                    <_user:AutoComplete ID="_UC_AutoComplete" runat="server" MethodName="GetCategories" />
                                    <asp:LinkButton ID="lnkBtnAddCategory" runat="server" Text='<%$ Resources:_Kartris, ContentText_AddNew %>'
                                        CssClass="linkbutton icon_new" />
                                </ContentTemplate>
                            </asp:UpdatePanel>
                            
                        </asp:PlaceHolder>
                    </span></li>
                    <%-- ShowOnSite (Live) --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litShowOnSite" runat="server" Text="<%$ Resources:_Category, FormLabel_ShowOnSite %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:CheckBox ID="chkLive" runat="server" CssClass="checkbox" Checked="True" />
                    </span></li>
                    <%-- LimitByGroup (CustomerGroupID) --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litLimitToCustomerGroup" runat="server" Text="<%$ Resources:_Category, ContentText_LimitToCustomerGroup %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:DropDownList ID="ddlCustomerGroup" runat="server" AppendDataBoundItems="true">
                            <asp:ListItem Text="<%$ Resources:_Category,ContentText_AvailableToAll %>" Value="0"></asp:ListItem>
                        </asp:DropDownList>
                    </span></li>
                    <%-- Product Display Type (ProductDisplayType) --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litProductDisplayType" runat="server" Text="<%$ Resources:_Category, FormLabel_ProductDisplayType %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:DropDownList ID="ddlProductDisplay" runat="server" CssClass="longtext">
                            <asp:ListItem Text="<%$ Resources:_Category, ContentText_DefaultProdDisplay %>" Value="d"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Category, ContentText_ExtendedProdDisplay %>"
                                Value="e"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Category, ContentText_NormalProdDisplay %>" Value="n"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Category, ContentText_ShortenedProdDisplay %>"
                                Value="s"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Category, ContentText_TabularProdDisplay %>" Value="t"></asp:ListItem>
                        </asp:DropDownList>
                    </span></li>
                    <%-- Sub-Cat Display Type (SubCatDisplayType) --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litSubCatDisplayType" runat="server" Text="<%$ Resources:_Category, FormLabel_SubCatDisplayType %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:DropDownList ID="ddlSubCategoryDisplay" runat="server" CssClass="longtext">
                            <asp:ListItem Text="<%$ Resources:_Category, ContentText_DefaultProdTypeDisplay %>"
                                Value="d"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Category, ContentText_NormalProdTypeDisplay %>"
                                Value="n"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Category, ContentText_ShortenedProdTypeDisplay %>"
                                Value="s"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Category, ContentText_LinkProdTypeDisplay %>"
                                Value="l"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Category, ContentText_TextProdTypeDisplay %>"
                                Value="t"></asp:ListItem>
                        </asp:DropDownList>
                    </span></li>
                    <%-- Sort Product By  --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litOrderProductsBy" runat="server" Text="<%$ Resources:_Category, FormLabel_OrderProductsBy %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:DropDownList ID="ddlSortProductBy" runat="server" CssClass="longtext">
                            <asp:ListItem Text="<%$ Resources:_Category, FormLabel_ConfigOrderByProducts %>"
                                Value="d"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Category, FormLabel_ConfigOrderByProductID %>"
                                Value="P_ID"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Category, FormLabel_ConfigOrderByProductName %>"
                                Value="P_Name"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Category, FormLabel_ConfigOrderByProductCreationDate %>"
                                Value="P_DateCreated"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Category, FormLabel_ConfigOrderByProductLastModificationDate %>"
                                Value="P_LastModified"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Category, FormLabel_ConfigOrderByProductCategoryLink %>"
                                Value="PCAT_OrderNo"></asp:ListItem>
                        </asp:DropDownList>
                    </span></li>
                    <%-- Sort Direction  --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litContentTextSortDirect" runat="server" Text="<%$ Resources:_Kartris, ContentText_SortDirection %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:DropDownList ID="ddlProductsSortDirection" runat="server" CssClass="longtext">
                            <asp:ListItem Text="<%$ Resources:_Kartris, ContentText_Ascending %>" Value="A"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Kartris, ContentText_Descending %>" Value="D"></asp:ListItem>
                        </asp:DropDownList>
                    </span></li>
                    <%-- Sort Subcat By  --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litOrderSubcatBy" runat="server" Text="<%$ Resources:_Category, FormLabel_OrderSubcatBy %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:DropDownList ID="ddlSortCategoryBy" runat="server" CssClass="longtext">
                            <asp:ListItem Text="<%$ Resources:_Category, FormLabel_ConfigOrderByCategories %>"
                                Value="d"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Category, FormLabel_ConfigOrderByCategoryID %>"
                                Value="CAT_ID"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Category, FormLabel_ConfigOrderByCategoryName %>"
                                Value="CAT_Name"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Category, FormLabel_ConfigOrderByCategoryParentSort %>"
                                Value="CH_OrderNo"></asp:ListItem>
                        </asp:DropDownList>
                    </span></li>
                    <%-- Sort Direction  --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="Literal2" runat="server" Text="<%$ Resources:_Kartris, ContentText_SortDirection %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:DropDownList ID="ddlCategoriesSortDirection" runat="server" CssClass="longtext">
                            <asp:ListItem Text="<%$ Resources:_Kartris, ContentText_Ascending %>" Value="A"></asp:ListItem>
                            <asp:ListItem Text="<%$ Resources:_Kartris, ContentText_Descending %>" Value="D"></asp:ListItem>
                        </asp:DropDownList>
                    </span></li>
                </ul>
            </div>
        </div>
        <%-- Save Button  --%>
        <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
            <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:LinkButton ID="lnkBtnSave" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                    ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' />
                    <asp:LinkButton ID="lnkBtnCancel" runat="server" CssClass="button cancelbutton" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                    ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                    <asp:HyperLink ID="lnkPreview" runat="server" CssClass="button previewbutton" Text='<%$ Resources: _Kartris, FormButton_Preview %>'
                    ToolTip='<%$ Resources: _Kartris, FormButton_Preview %>'
                        Target="_blank" Visible="false" /><span class="floatright">
                            <asp:LinkButton ID="lnkBtnDelete" CssClass="button deletebutton"
                                runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>' ToolTip='<%$ Resources: _Category, ContentText_DeleteOptionOneText %>' /></span>
                    <asp:ValidationSummary ID="valSummary" runat="server" ForeColor="" CssClass="valsummary"
                        DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
        <asp:ListBox ID="lbxResult" runat="server" Visible="False"></asp:ListBox>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgSaveChanges" runat="server" AssociatedUpdatePanelID="updMain">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
