<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_StockWarning.ascx.vb"
    Inherits="UserControls_Back_StockWarning" %>
<div id="page_stockwarning">
    <h1>
        <asp:Literal ID="litPageTitleStockLevelWarnings" runat="server" Text="<%$ Resources: _StockLevel, PageTitle_StockLevelWarnings %>" /></h1>
    <div class="section">
        <p>
            <asp:Literal ID="litContentTextStockLevelPagetext" runat="server" Text="<%$ Resources: _StockLevel, ContentText_StockLevelPagetext %>" /></p>
    </div>
    <div class="section">
        <asp:UpdatePanel ID="updStockHeader" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:Label ID="litFormLabelSupplier" runat="server" Text="<%$ Resources: _Product, FormLabel_Supplier %>"
                    AssociatedControlID="ddlSupplier" />
                <asp:DropDownList ID="ddlSupplier" runat="server" AppendDataBoundItems="true" CssClass="midtext">
                    <asp:ListItem Text="<%$ Resources: _Category, ContentText_AvailableToAll %>" Value="0"></asp:ListItem>
                </asp:DropDownList>
                <asp:Button ID="btnSubmitSupplier" runat="server" Text="<%$ Resources: _Kartris, FormButton_Submit %>"
                    CssClass="button" />
                <asp:Button ID="btnExportCSV" runat="server" Text="<%$ Resources: _StockLevel, FormSupport_ExportStockWarnings %>"
                    CssClass="button"/>
            </ContentTemplate>
            <Triggers>
                <asp:PostBackTrigger ControlID="btnExportCSV" />
            </Triggers>
        </asp:UpdatePanel>
        <asp:UpdateProgress ID="prgSaveChanges" runat="server" AssociatedUpdatePanelID="updStockHeader">
            <ProgressTemplate>
                <div class="loadingimage">
                </div>
                <div class="updateprogress">
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
    </div>
    <asp:UpdatePanel ID="updStockLevelList" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:MultiView ID="mvwStockWarning" runat="server" ActiveViewIndex="0">
                <asp:View ID="viwStockData" runat="server">
                    <div id="section_reviews">
                        <asp:GridView CssClass="kartristable" ID="gvwStockLevel" runat="server" AllowSorting="true" AutoGenerateColumns="False"
                            DataKeyNames="V_ID" AutoGenerateEditButton="False" GridLines="None" PagerSettings-PageButtonCount="10"
                            SelectedIndex="0" AllowPaging="true" PageSize="10">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Literal ID="litFormLabelCodeNumber" runat="server" Text="<%$ Resources:_Version, FormLabel_CodeNumer %>" />
                                    </HeaderTemplate>
                                    <HeaderStyle CssClass="itemname" />
                                    <ItemTemplate>
                                        <asp:Literal runat="server" ID="litVersionID" Text='<%# Eval("V_ID") %>' Visible="false" />
                                        <asp:Literal runat="server" ID="litVersionCode" Text='<%# Eval("V_CodeNumber") %>' />
                                    </ItemTemplate>
                                    <ItemStyle CssClass="itemname" />
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Literal ID="litFormLabelName" runat="server" Text="<%$ Resources:_Kartris, ContentText_Name %>" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Literal ID="litVersionName" runat="server" Text='<%# Eval("V_Name") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Literal ID="litFormLabelStockQuantity" runat="server" Text="<%$ Resources:_Version, FormLabel_StockQuantity %>" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtStockQty" runat="server" CssClass="shorttext" MaxLength="5" Text='<%# Eval("V_Quantity") %>' />
                                        (<asp:Literal ID="litOldQuantity" runat="server" Text='<%# Eval("V_Quantity") %>'></asp:Literal>)
                                        <asp:CompareValidator ID="valCompareStockQuantity" runat="server" ControlToValidate="txtStockQty"
                                            Display="Dynamic" ErrorMessage="*" Operator="DataTypeCheck" ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoShort %>"
                                            Type="Double" SetFocusOnError="true" ValidationGroup="StockLevel" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filStockQuantity" runat="server" TargetControlID="txtStockQty"
                                            FilterType="Numbers,Custom" ValidChars=".," />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Literal ID="litFormLabelWarnLevel" runat="server" Text="<%$ Resources:_Version, FormLabel_WarningLevel %>" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtWarnLevel" runat="server" CssClass="shorttext" MaxLength="5"
                                            Text='<%# Eval("V_QuantityWarnLevel") %>' />
                                        (<asp:Literal ID="litOldWarnLevel" runat="server" Text='<%# Eval("V_QuantityWarnLevel") %>'></asp:Literal>)
                                        <asp:CompareValidator ID="valCompareWarningLevel" runat="server" ControlToValidate="txtWarnLevel"
                                            Display="Dynamic" ErrorMessage="*" Operator="DataTypeCheck" ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoShort %>"
                                            Type="Double" SetFocusOnError="true" ValidationGroup="NewCombinationsGrp" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filWarningLevel" runat="server" TargetControlID="txtWarnLevel"
                                            FilterType="Numbers,Custom" ValidChars=".," />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:Hyperlink ID="lnkEditVersion" CssClass="linkbutton icon_edit" Text='<%$ Resources:_Kartris, FormButton_Edit %>'
                                            runat="server" NavigateUrl='<%# "~/Admin/_ModifyProduct.aspx?ProductID=" & Eval("P_ID") & "&strTab=versions&VersionID=" & Eval("V_ID")  %>' />
                                    </ItemTemplate>
                                    <ItemStyle CssClass="selectfield" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                        <asp:LinkButton ID="btnSave" runat="server" Text="<%$ Resources: _Kartris, FormButton_Save %>"
                        ToolTip="<%$ Resources: _Kartris, FormButton_Save %>"
                            CssClass="button savebutton" />
                    </div>
                </asp:View>
                <asp:View ID="viwNoItems" runat="server">
                    <asp:Panel ID="pnlNoItems" runat="server" CssClass="noresults">
                        <asp:Literal ID="litNoItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>">
                        </asp:Literal>
                    </asp:Panel>
                </asp:View>
            </asp:MultiView>
            <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
        </ContentTemplate>
    </asp:UpdatePanel>
    <asp:UpdateProgress ID="upgStockLevelList" runat="server" AssociatedUpdatePanelID="updStockLevelList">
        <ProgressTemplate>
            <div class="loadingimage">
            </div>
            <div class="updateprogress">
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>
</div>
