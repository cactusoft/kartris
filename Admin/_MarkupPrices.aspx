<%@ Page Title="" Language="VB" MasterPageFile="~/Skins/Admin/Template.master" AutoEventWireup="false"
    CodeFile="_MarkupPrices.aspx.vb" Inherits="Admin_MarkupPrices" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_markupprices">
        <h1>
            <asp:Literal ID="litPageTitle" runat="server" Text="<%$ Resources: _MarkupPrices, PageTitle_MarkupPrices %>" /></h1>
        <%--Markup Prices--%>
        <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:MultiView ID="mvwMain" runat="server" ActiveViewIndex="0">
                    <asp:View ID="viwStep1" runat="server">
                        <h2>
                            <asp:Literal ID="litContentTextVersionsToMarkUp" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_VersionsToMarkUp %>" /></h2>
                        <div class="Kartris-DetailsView">
                            <div class="Kartris-DetailsView-Data">
                                <ul>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litContentTextPriceRange" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_PriceRange %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litContentTextPriceRangeBetween" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_PriceRangeBetween %>" />
                                        <asp:Literal ID="litCurrencySymbol1" runat="server" />
                                        <asp:TextBox ID="txtFromPrice" runat="server" MaxLength="10" CssClass="shorttext" />
                                        <asp:RegularExpressionValidator ID="valRegexPriceFrom" runat="server" Display="Dynamic"
                                            SetFocusOnError="true" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
                                            CssClass="error" ForeColor="" ControlToValidate="txtFromPrice" ValidationGroup="ChangePrice"
                                            ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                        <asp:Literal ID="litContentTextPriceRangeAnd" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_PriceRangeAnd %>" />
                                        <asp:Literal ID="litCurrencySymbol2" runat="server" />
                                        <asp:TextBox ID="txtToPrice" runat="server" MaxLength="10" CssClass="shorttext" />
                                        <asp:RegularExpressionValidator ID="valRegexPriceTo" runat="server" Display="Dynamic"
                                            SetFocusOnError="true" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
                                            CssClass="error" ForeColor="" ControlToValidate="txtToPrice" ValidationGroup="ChangePrice"
                                            ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                        (<asp:Literal ID="litContentTextLeaveBlankPrices" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_LeaveBlankPrices %>" />)
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filPriceFrom" runat="server" TargetControlID="txtFromPrice"
                                            FilterType="Numbers,Custom" ValidChars=".," />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filPriceTo" runat="server" TargetControlID="txtToPrice"
                                            FilterType="Numbers,Custom" ValidChars=".," />
                                    </span></li>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litContentTextInCategory" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_InCategory %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:RadioButton ID="rdoAllCategories" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_AllCategories %>"
                                            CssClass="radio" AutoPostBack="true" Checked="true" GroupName="Categories" />
                                        <asp:RadioButton ID="rdoSelectedCategories" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_SelectedCategories %>"
                                            CssClass="radio" AutoPostBack="true" GroupName="Categories" />
                                    </span>
                                        <asp:UpdatePanel ID="updCategories" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:PlaceHolder ID="phdCategories" runat="server" Visible="false">
                                                    <div id="markup_categories">
                                                        <asp:CheckBoxList ID="chklistCategories" runat="server" RepeatDirection="Horizontal"
                                                            CssClass="checkbox" RepeatLayout="Flow">
                                                        </asp:CheckBoxList>
                                                    </div>
                                                </asp:PlaceHolder>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </li>


                                    <!-- Supplier (SupplierID) -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="litFormLabelSupplier" runat="server" Text="<%$ Resources: _Product, FormLabel_Supplier %>"
                                            AssociatedControlID="ddlSupplier"></asp:Label>
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:DropDownList ID="ddlSupplier" runat="server" AppendDataBoundItems="true">
                                            <asp:ListItem Text="<%$ Resources: _Kartris, ContentText_None %>" Value="0"></asp:ListItem>
                                        </asp:DropDownList>
                                    </span></li>

                                </ul>
                                <h2>
                                    <asp:Literal ID="litContentTextPriceModification" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_PriceModification %>" />
                                </h2>
                                <ul>
                                    <li>
                                        <asp:DropDownList ID="ddlMarkUpDown" runat="server" CssClass="midtext">
                                            <asp:ListItem Text="<%$ Resources: _MarkupPrices, ContentText_MarkUp %>" Value="up" />
                                            <asp:ListItem Text="<%$ Resources: _MarkupPrices, ContentText_MarkDown %>" Value="down" />
                                        </asp:DropDownList>
                                        <asp:DropDownList ID="ddlTargetField" runat="server" CssClass="midtext">
                                            <asp:ListItem Text="<%$ Resources: _Version, FormLabel_Price %>" Value="price" />
                                            <asp:ListItem Text="<%$ Resources: _Version, FormLabel_RRP %>" Value="rrp" />
                                            <asp:ListItem Text="<%$ Resources: _Version, FormLabel_TabQuantityDiscount %>" Value="qd" />
                                        </asp:DropDownList>
                                        <asp:Literal ID="litContentTextPriceMarkupBy" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_PriceMarkupBy %>" />
                                        <asp:TextBox ID="txtMarkValue" runat="server" MaxLength="10" CssClass="shorttext" />
                                        <asp:RequiredFieldValidator ID="valRequiredValue" runat="server" CssClass="error"
                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ControlToValidate="txtMarkValue" Display="Dynamic" SetFocusOnError="true" ValidationGroup="ChangePrice" />
                                        <asp:DropDownList ID="ddlMarkType" runat="server" CssClass="shorttext">
                                        </asp:DropDownList>
                                    </li>
                                    <li>
                                        <br />
                                        <asp:UpdatePanel ID="updSubmitStep1" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:Button ID="btnSubmitStep1" runat="server" Text="<%$ Resources: _Kartris, FormButton_Submit %>"
                                                    CssClass="button" ValidationGroup="ChangePrice" />
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </asp:View>
                    <asp:View ID="viwStep2" runat="server">
                        <asp:LinkButton ID="lnkBtnBack" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>'
                            CssClass="linkbutton icon_back floatright" CausesValidation="false"></asp:LinkButton><br />
                        <strong>
                            <asp:GridView ID="gvwVersions" runat="server" CssClass="kartristable" AllowPaging="false"
                                AllowSorting="false" AutoGenerateColumns="False">
                                <Columns>
                                    <asp:TemplateField>
                                        <HeaderTemplate>
                                            <asp:Literal ID="litContentTextProduct" runat="server" Text="<%$ Resources: _Kartris, ContentText_Product %>"></asp:Literal>
                                            (<asp:Literal ID="litContentTextVersion" runat="server" Text="<%$ Resources: _Kartris, ContentText_Version %>"></asp:Literal>)
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:Literal ID="litID" runat="server" Text='<%# Eval("V_ID") %>' Visible="false"></asp:Literal>
                                            <asp:Literal ID="P_Name" runat="server" Text='<%# Eval("P_Name") %>'></asp:Literal>
                                            (<asp:Literal ID="V_Name" runat="server" Text='<%# Eval("V_Name") %>'></asp:Literal>)
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="QD_Quantity" HeaderText="<%$ Resources: _Kartris, ContentText_Qty %>" />
                                    <asp:BoundField DataField="V_OldPrice" HeaderText="<%$ Resources: _Kartris, ContentText_Price %>" />
                                    <asp:BoundField DataField="V_NewPrice" HeaderText="<%$ Resources: _MarkupPrices, ContentText_NewPrice %>" />
                                    <asp:BoundField DataField="V_OldRRP" HeaderText="<%$ Resources: _Version, FormLabel_RRP %>" />
                                    <asp:BoundField DataField="V_NewRRP" HeaderText="<%$ Resources: _MarkupPrices, ContentText_NewRRP %>" />
                                    <asp:TemplateField>
                                        <HeaderTemplate>
                                            <asp:CheckBox ID="chkSelectAll" runat="server" Checked="true" CssClass="checkbox"
                                                OnCheckedChanged="SelectAllChanged" AutoPostBack="true" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:CheckBox ID="chkSave" runat="server" Checked="true" CssClass="checkbox" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                            <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                                <asp:LinkButton ID="btnSave" runat="server" Text="<%$ Resources: _Kartris, FormButton_Save %>"
                                    ToolTip="<%$ Resources: _Kartris, FormButton_Save %>" CssClass="button savebutton" /></div>
                    </asp:View>
                </asp:MultiView>
                <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
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
        <%--Import Price List Section--%>
        <div class="line">
        </div>
        <h2>
            <asp:Literal ID="litImportPriceTitle" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_ImportPriceList %>"></asp:Literal></h2>
            <asp:Literal ID="litImportListDescription" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_ImportPriceListInfo %>"></asp:Literal>
        <div class="Kartris-DetailsView">
            <div class="Kartris-DetailsView-Data">
                <ul>
                    <asp:UpdatePanel ID="updPriceList" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <li><span class="Kartris-DetailsView-Name">
                                <asp:Literal ID="litPriceListDetails" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_PriceListDetails %>"></asp:Literal>
                            </span><span class="Kartris-DetailsView-Value">
                                <asp:TextBox ID="txtPriceList" runat="server" TextMode="MultiLine"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="valPriceList" runat="server" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                    ControlToValidate="txtPriceList" SetFocusOnError="true" ValidationGroup="PriceList"
                                    Display="Dynamic">
                                </asp:RequiredFieldValidator>
                            </span></li>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litUploadFile" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_UploadFromFile %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:FileUpload ID="filUploader" runat="server" />
                        <asp:LinkButton ID="btnUploadPriceList" runat="server" Text="<%$ Resources: _Kartris, ContentText_Upload %>"
                            CssClass="linkbutton icon_upload icon_upload" />
                    </span></li>
                </ul>
            </div>
        </div>
        <br />
        <asp:UpdatePanel ID="updSubmitPriceList" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:Button ID="btnSubmitPriceList" runat="server" Text="<%$ Resources: _Kartris, FormButton_Submit %>"
                    CssClass="button" ValidationGroup="PriceList" />
            </ContentTemplate>
        </asp:UpdatePanel>

        <br />




        <%--Import Customer Group Prices--%>
        <div class="line">
        </div>
        <h2>
            <asp:Literal ID="litImportCustomerGroupPricesTitle" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_ImportCustomerGroupPrices %>"></asp:Literal>
        </h2>
        <asp:Literal ID="litImportCustomerGroupPricesDescription" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_ImportCustomerGroupPricesInfo %>"></asp:Literal>
        <div class="Kartris-DetailsView">
            <div class="Kartris-DetailsView-Data">
                <ul>
                    <asp:UpdatePanel ID="updCustomerGroupPriceList" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <li><span class="Kartris-DetailsView-Name">
                                <asp:Literal ID="litPriceListDetails2" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_PriceListDetails %>"></asp:Literal>
                            </span><span class="Kartris-DetailsView-Value">
                                <asp:TextBox ID="txtCustomerGroupPriceList" runat="server" TextMode="MultiLine"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="valCustomerGroupPriceList" runat="server" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                    ControlToValidate="txtCustomerGroupPriceList" SetFocusOnError="true" ValidationGroup="CustomerGroupPriceList"
                                    Display="Dynamic">
                                </asp:RequiredFieldValidator>
                            </span></li>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litUploadFile2" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_UploadFromFile %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:FileUpload ID="filUploader2" runat="server" />
                        <asp:LinkButton ID="btnUploadCustomerGroupPriceList" runat="server" Text="<%$ Resources: _Kartris, ContentText_Upload %>"
                            CssClass="linkbutton icon_upload icon_upload" />
                    </span></li>
                </ul>
            </div>
        </div>
        <br />
        <asp:UpdatePanel ID="updSubmitCustomerGroupPriceList" runat="server" UpdateMode="Conditional">
            
            <ContentTemplate>
                <asp:Button ID="btnSubmitCustomerGroupPriceList" runat="server" Text="<%$ Resources: _Kartris, FormButton_Submit %>"
                    CssClass="button" ValidationGroup="CustomerGroupPriceList" />
            </ContentTemplate>
        </asp:UpdatePanel>
        <br />




        <%--Import Quantity Discounts--%>
        <div class="line">
        </div>
        <h2>
            <asp:Literal ID="litImportQuantityDiscountsTitle" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_ImportQuantityDiscounts %>"></asp:Literal>
        </h2>
        <asp:Literal ID="litImportQuantityDiscountsDescription" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_ImportQuantityDiscountsInfo %>"></asp:Literal>
        <div class="Kartris-DetailsView">
            <div class="Kartris-DetailsView-Data">
                <ul>
                    <asp:UpdatePanel ID="updQuantityDiscounts" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <li><span class="Kartris-DetailsView-Name">
                                <asp:Literal ID="litPriceListDetails3" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_PriceListDetails %>"></asp:Literal>
                            </span><span class="Kartris-DetailsView-Value">
                                <asp:TextBox ID="txtQuantityDiscounts" runat="server" TextMode="MultiLine"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="valQuantityDiscounts" runat="server" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                    ControlToValidate="txtQuantityDiscounts" SetFocusOnError="true" ValidationGroup="QuantityDiscounts"
                                    Display="Dynamic">
                                </asp:RequiredFieldValidator>
                            </span></li>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litUploadFile3" runat="server" Text="<%$ Resources: _MarkupPrices, ContentText_UploadFromFile %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:FileUpload ID="filUploader3" runat="server" />
                        <asp:LinkButton ID="btnUploadQuantityDiscounts" runat="server" Text="<%$ Resources: _Kartris, ContentText_Upload %>"
                            CssClass="linkbutton icon_upload icon_upload" />
                    </span></li>
                </ul>
            </div>
        </div>
        <br />
        <asp:UpdatePanel ID="updSubmitQuantityDiscounts" runat="server" UpdateMode="Conditional">
            
            <ContentTemplate>
                <asp:Button ID="btnSubmitQuantityDiscounts" runat="server" Text="<%$ Resources: _Kartris, FormButton_Submit %>"
                    CssClass="button" ValidationGroup="QuantityDiscounts" />
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
</asp:Content>
