<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_EditProduct.ascx.vb"
    Inherits="_EditProduct" %>
<%@ Register TagPrefix="_user" TagName="LanguageContainer" Src="~/UserControls/Back/_LanguageContainer.ascx" %>
<%@ Register TagPrefix="_user" TagName="AutoComplete" Src="~/UserControls/Back/_AutoCompleteInput.ascx" %>

<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Literal ID="litProductID" runat="server" Visible="false" />
        <asp:PlaceHolder ID="phdNoCategories" runat="server" Visible="false">
            <asp:Literal ID="litContentTextNoCategoriesInThisSite" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoCategoriesInTheSite %>" />
        </asp:PlaceHolder>
        <asp:PlaceHolder ID="phdEditProduct" runat="server">
            <!-- Language Elements -->
            <div>
                <asp:UpdatePanel ID="updLanguageContainer" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:PlaceHolder ID="phdLanguageContainer" runat="server">
                            <_user:LanguageContainer ID="_UC_LangContainer" runat="server" />
                        </asp:PlaceHolder>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
            <!-- Line -->
            <div class="line">
            </div>
            <div class="Kartris-DetailsView">
                <div class="Kartris-DetailsView-Data">
                    <ul>
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Label ID="litContentTextCategoryParent" runat="server" Text="<%$ Resources: _Category, ContentText_CategoryParent %>"></asp:Label>
                        </span><span class="Kartris-DetailsView-Value">
                            <asp:UpdatePanel ID="updProductCategories" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:ListBox ID="lbxProductCategories" runat="server"></asp:ListBox>
                                    <asp:LinkButton ID="lnkBtnRemoveProductCategory" Cssclass="linkbutton icon_delete" runat="server"
                                        Text='<%$ Resources:_Kartris, ContentText_RemoveSelected %>' /><br />
                                    <_user:AutoComplete ID="_UC_AutoComplete" runat="server" MethodName="GetCategories" />
                                    <asp:LinkButton ID="lnkBtnAddCategory" Cssclass="linkbutton icon_new" runat="server"
                                        Text='<%$ Resources:_Kartris, FormButton_Add %>' /><br />
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </span>
                        </li>
                        <% If litProductID.Text <> 0 Then%>
                        <li>
                            <!-- Date Created (P_DateCreated) -->
                            <span class="Kartris-DetailsView-Name">
                                <asp:Literal ID="litFormLabelDateCreated" runat="server" Text="<%$ Resources: _Kartris, ContentText_DateCreated%>"></asp:Literal>
                            </span><span class="Kartris-DetailsView-Value">
                                <asp:Literal ID="litDateCreated" runat="server"></asp:Literal>
                            </span></li>
                        <!-- Last Modified (P_LastModified) -->
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Literal ID="litFormLabelLastModified" runat="server" Text="<%$ Resources: _Kartris, ContentText_LastUpdated %>"></asp:Literal>
                        </span><span class="Kartris-DetailsView-Value">
                            <asp:Literal ID="litLastModified" runat="server"></asp:Literal>
                        </span></li>
                        <% End If%>
                        <!-- ShowOnSite (Live) -->
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Label ID="litFormLabelShowOnSite" runat="server" Text="<%$ Resources: _Category, FormLabel_ShowOnSite %>"
                                AssociatedControlID="chkLive"></asp:Label>
                        </span><span class="Kartris-DetailsView-Value">
                            <asp:CheckBox ID="chkLive" runat="server" CssClass="checkbox" /><span><asp:Literal ID="Literal2"
                                runat="server" Text="<%$ Resources: _Product, ContentText_ProductWillBeHidden %>" /></span>
                        </span></li>
                        <!-- LimitByGroup (CustomerGroupID) -->
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Label ID="litContentText_LimitToCustomerGroup" runat="server" Text="<%$ Resources: _Category, ContentText_LimitToCustomerGroup %>"
                                AssociatedControlID="ddlCustomerGroup"></asp:Label>
                        </span><span class="Kartris-DetailsView-Value">
                            <asp:DropDownList ID="ddlCustomerGroup" runat="server" AppendDataBoundItems="true" AutoPostBack="true">
                                <asp:ListItem Text="<%$ Resources: _Category, ContentText_AvailableToAll %>" Value="0"></asp:ListItem>
                            </asp:DropDownList>
                        </span></li>
                        <!-- Supplier (SupplierID) -->
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Label ID="litFormLabelSupplier" runat="server" Text="<%$ Resources: _Product, FormLabel_Supplier %>"
                                AssociatedControlID="ddlSupplier"></asp:Label>
                        </span><span class="Kartris-DetailsView-Value">
                            <asp:DropDownList ID="ddlSupplier" runat="server" AppendDataBoundItems="true">
                                <asp:ListItem Text="<%$ Resources: _Kartris, ContentText_None %>" Value="0"></asp:ListItem>
                            </asp:DropDownList>
                        </span></li>
                        <!-- Product Featured (P_Featured) -->
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Label ID="litFormLabelFeatured" runat="server" Text="<%$ Resources: _Product, FormLabel_Featured %>"
                                AssociatedControlID="txtFeaturedLevel"></asp:Label>
                        </span><span class="Kartris-DetailsView-Value">
                            <asp:TextBox ID="txtFeaturedLevel" runat="server" CssClass="shorttext" MaxLength="3" Text="0" />
                            <ajaxToolkit:FilteredTextBoxExtender ID="filPriority" runat="server" TargetControlID="txtFeaturedLevel"
                                FilterType="Numbers" />
                            <asp:Literal ID="litNoFeaturedInCaseOfCustomerGroups" runat="server" Visible="false" Text="<%$ Resources: _Kartris, ContentText_ProductLimitedToCustomerGroupAsFeatured %>" />
                        </span></li>
                        <!-- ProductType -->
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Label ID="litContentTextProductType" runat="server" Text="<%$ Resources: _Product, ContentText_ProductType %>"
                                AssociatedControlID="ddlProductType"></asp:Label>
                        </span><span class="Kartris-DetailsView-Value">
                        <asp:UpdatePanel ID="updProductType" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                            <asp:DropDownList ID="ddlProductType" runat="server" AutoPostBack="True">
                                <asp:ListItem Text="<%$ Resources: _Product, ContentText_ProductTypeSingleVersionDisplay %>"
                                    Value="s"></asp:ListItem>
                                <asp:ListItem Text="<%$ Resources: _Product, ContentText_ProductTypeMultipleVersionDisplay %>"
                                    Value="m"></asp:ListItem>
                                <asp:ListItem Text="<%$ Resources: _Product, ContentText_ProductTypeOptionVersionDisplay %>"
                                    Value="o"></asp:ListItem>
                            </asp:DropDownList></ContentTemplate>
                            </asp:UpdatePanel>
                        </span></li>
                        <!-- Version Display Type (VersionDisplayType) -->
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Label ID="litFormLabelVersionDisplayType" runat="server" Text="<%$ Resources: _Product, FormLabel_VersionDisplayType %>"
                                AssociatedControlID="ddlVersionDisplay"></asp:Label>
                        </span><span class="Kartris-DetailsView-Value">
                            <asp:UpdatePanel ID="updVersionDisplayType" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                            
                            
                            <asp:DropDownList ID="ddlVersionDisplay" runat="server" CssClass="longtext">
                                <asp:ListItem Text="<%$ Resources:_Product,ContentText_DefaultVerDisplayType %>"
                                    Value="d"></asp:ListItem>
                                <asp:ListItem Text="<%$ Resources:_Product,ContentText_OptionPriceVerDisplayType %>"
                                    Value="p"></asp:ListItem>
                                <asp:ListItem Text="<%$ Resources:_Product,ContentText_RowsVerDisplayType %>" Value="r"></asp:ListItem>
                                <asp:ListItem Text="<%$ Resources:_Product,ContentText_OptionsVerDisplayType %>"
                                    Value="o"></asp:ListItem>
                                <asp:ListItem Text="<%$ Resources:_Product,ContentText_NoneVerDisplayType %>" Value="l"></asp:ListItem>
                            </asp:DropDownList></ContentTemplate>
                            </asp:UpdatePanel>
                        </span></li>
                        <!-- Sort Versions By  -->
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Label ID="litFormLabelOrderVersionsBy" runat="server" Text="<%$ Resources: _Product, FormLabel_OrderVersionsBy %>"
                                AssociatedControlID="ddlOrderVersionsBy"></asp:Label>
                        </span><span class="Kartris-DetailsView-Value">
                            <asp:UpdatePanel ID="updSortVersions" runat="server" UpdateMode="Conditional">
                            <ContentTemplate><asp:DropDownList ID="ddlOrderVersionsBy" runat="server" CssClass="longtext">
                                <asp:ListItem Text="-"
                                    Value="d"></asp:ListItem>
                                <asp:ListItem Text="<%$ Resources: _Product, FormLabel_NameOrderByVersions %>" Value="V_Name"></asp:ListItem>
                                <asp:ListItem Text="<%$ Resources: _Product, FormLabel_PriceOrderByVersions %>" Value="V_Price"></asp:ListItem>
                                <asp:ListItem Text="<%$ Resources: _Product, FormLabel_ValueOrderByVersions %>" Value="V_OrderByValue"></asp:ListItem>
                                <asp:ListItem Text="<%$ Resources: _Version, FormLabel_StockQuantity %>" Value="V_Quantity"></asp:ListItem>
                            </asp:DropDownList></ContentTemplate>
                            </asp:UpdatePanel>
                        </span></li>
                        <!-- Sort Direction  -->
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Literal ID="litContentTextSort" runat="server" Text="<%$ Resources:_Kartris, ContentText_SortDirection %>"></asp:Literal>
                        </span><span class="Kartris-DetailsView-Value">
                            <asp:UpdatePanel ID="updSortDirection" runat="server" UpdateMode="Conditional">
                            <ContentTemplate><asp:DropDownList ID="ddlVersionsSortDirection" runat="server" CssClass="longtext">
                                <asp:ListItem Text="-" Value="-"></asp:ListItem>
                                <asp:ListItem Text="<%$ Resources:_Kartris, ContentText_Ascending %>" Value="A"></asp:ListItem>
                                <asp:ListItem Text="<%$ Resources:_Kartris, ContentText_Descending %>" Value="D"></asp:ListItem>
                            </asp:DropDownList></ContentTemplate>
                            </asp:UpdatePanel>
                        </span></li>
                        <!-- Customer Reviews  -->
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Label ID="litCustomerReviews" runat="server" Text="<%$ Resources: _Product, FormLabel_CustomerReviews %>"
                                AssociatedControlID="ddlCustomerReviews"></asp:Label>
                        </span><span class="Kartris-DetailsView-Value">
                            <asp:DropDownList ID="ddlCustomerReviews" runat="server">
                                <asp:ListItem Text="<%$ Resources: _Product, FormLabel_CustomerReviewsYes %>" Value="y"></asp:ListItem>
                                <asp:ListItem Text="<%$ Resources: _Product, FormLabel_CustomerReviewsNoVersions %>"
                                    Value="v"></asp:ListItem>
                                <asp:ListItem Text="<%$ Resources: _Product, FormLabel_CustomerReviewsNo %>" Value="n"></asp:ListItem>
                            </asp:DropDownList>
                        </span></li>
                    </ul>
                </div>
            </div>
            <!-- Save Button  -->
            <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:LinkButton ID="btnSave" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                            ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' />
                        <asp:LinkButton ID="btnCloneProduct" runat="server" CssClass="button clonebutton" Text='<%$ Resources: _Kartris, FormButton_Clone %>'
                            ToolTip='<%$ Resources: _Kartris, FormButton_Clone %>' />
                        <asp:TextBox ID="txtCloneQty" runat="server" CssClass="submitareatext" value="1" ToolTip='<%$ Resources: _Kartris, ContentText_PleaseEnterValue %>'></asp:TextBox>
                        <asp:LinkButton ID="btnCancel" runat="server" CssClass="button cancelbutton" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                            ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                        <asp:HyperLink ID="hlinkPreview" runat="server" CssClass="button previewbutton"
                            Text='<%$ Resources: _Kartris, FormButton_Preview %>' Target="_blank" Visible="false"
                            ToolTip='<%$ Resources: _Kartris, FormButton_Preview %>' />
                        <span class="floatright">
                            <asp:LinkButton ID="lnkBtnDelete" CssClass="button deletebutton"
                                runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>' ToolTip='<%$ Resources: _Product, ContentText_DeleteThisProduct %>' /></span>
                        <asp:ValidationSummary ID="valSummary" runat="server" CssClass="valsummary" DisplayMode="BulletList"
                            ForeColor="" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
            <asp:ListBox ID="lbxResult" runat="server" Visible="False"></asp:ListBox>
            <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
            <_user:PopupMessage ID="_UC_PopupMsg_Clone" runat="server" />
        </asp:PlaceHolder>
    </ContentTemplate>
</asp:UpdatePanel>
