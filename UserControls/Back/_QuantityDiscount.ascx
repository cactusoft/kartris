<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_QuantityDiscount.ascx.vb"
    Inherits="UserControls_Back_QuantityDiscount" %>
<asp:UpdatePanel ID="updQtyDiscount" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        
        <div class="subtabsection"><p>
            <asp:Literal ID="litContentTextQuantityDiscountsExplanation" runat="server" Text="<%$ Resources:_Version, ContentText_QuantityDiscountsExp %>" /></p>
            <asp:Literal ID="litVersionID" runat="server" Visible="false" />
            <asp:ListBox ID="lbxQty" runat="server" Visible="false" />
            <asp:ListBox ID="lbxPrice" runat="server" Visible="false" />
            <asp:UpdatePanel ID="updAddNew" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <%-- Quantity --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelQty" runat="server" Text='<%$ Resources:_Version, FormLabel_Qty %>' />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtQty" runat="server" CssClass="shorttext" MaxLength="10" />
                                    <asp:RequiredFieldValidator ID="valRequiredQty" runat="server" CssClass="error" ForeColor=""
                                        ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ControlToValidate="txtQty"
                                        ValidationGroup="addNewQtyDiscount" Display="Dynamic" />
                                    <asp:CompareValidator ID="valCompareQty" runat="server" ErrorMessage="*" CssClass="error"
                                        ForeColor="" ControlToValidate="txtQty" Type="Double" Operator="DataTypeCheck"
                                        SetFocusOnError="true" ValidationGroup="addNewQtyDiscount" Display="Dynamic" />
                                    <ajaxToolkit:FilteredTextBoxExtender ID="filQty" runat="server" TargetControlID="txtQty"
                                        FilterType="Numbers,Custom" ValidChars=".," />
                                </span></li>
                                <%-- Price --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelPrice" runat="server" Text='<%$ Resources: _Version, FormLabel_Price %>' />
                                    (<asp:Literal ID="litContentTextPerItem" runat="server" Text='<%$ Resources: _Version, ContentText_PerItem %>' />)
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtPrice" runat="server" CssClass="shorttext" MaxLength="8" />
                                    <asp:RequiredFieldValidator ID="valRequiredPrice" runat="server" CssClass="error"
                                        ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                        ControlToValidate="txtPrice" ValidationGroup="addNewQtyDiscount" Display="Dynamic" />
                                    <asp:RegularExpressionValidator ID="valRegexPrice" runat="server" ControlToValidate="txtPrice"
                                        CssClass="error" Display="Dynamic" ErrorMessage="*" ForeColor="" SetFocusOnError="true"
                                        ValidationGroup="addNewQtyDiscount" ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                    <%--<asp:CompareValidator ID="valComparePrice" runat="server" ErrorMessage="*" CssClass="error"
                                        ForeColor="" ControlToValidate="txtPrice" Type="Double" Operator="DataTypeCheck"
                                        SetFocusOnError="true" ValidationGroup="addNewQtyDiscount" Display="Dynamic" />--%>
                                    <ajaxToolkit:FilteredTextBoxExtender ID="filPrice" runat="server" TargetControlID="txtPrice"
                                        FilterMode="ValidChars" FilterType="Numbers,Custom" ValidChars=".," />
                                </span></li>
                            </ul>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
            <asp:UpdatePanel ID="updAddButton" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:Button ID="btnAdd" runat="server" Text="<%$ Resources: _Kartris, ContentText_AddNew %>"
                        CssClass="button" ValidationGroup="addNewQtyDiscount" />
                </ContentTemplate>
            </asp:UpdatePanel>
            <br />
            <br />
            <asp:GridView CssClass="kartristable" ID="gvwQtyDiscount" runat="server" AllowSorting="false" AutoGenerateColumns="False"
                AutoGenerateEditButton="False" GridLines="None" SelectedIndex="0">
                <Columns>
                    <asp:TemplateField>
                        <HeaderTemplate>
                            <asp:Literal ID="litFormLabelQty" runat="server" Text='<%$ Resources:_Version, FormLabel_Qty %>' />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:Literal ID="litQuantity" runat="server" Text='<%# Eval("QD_Quantity") %>' />
                        </ItemTemplate>
                        <FooterTemplate>
                        </FooterTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-CssClass="alignright">
                        <HeaderTemplate>
                            <asp:Literal ID="litFormLabelPrice" runat="server" Text='<%$ Resources:_Version, FormLabel_Price %>' />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:Literal ID="litPrice" runat="server" Text='<%# Eval("QD_Price") %>' />
                        </ItemTemplate>
                        <FooterTemplate>
                        </FooterTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-CssClass="selectfield">
                        <HeaderTemplate>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:LinkButton ID="lnkBtnRemoveQtyDiscount" runat="server" CommandName="remove"
                                CommandArgument='<%# Container.DataItemIndex %>' Text="<%$ Resources: _Kartris, FormButton_Delete %>"
                                CssClass="linkbutton icon_delete" ToolTip="<%$ Resources:_Version, ImageLabel_RemoveDiscount %>" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:LinkButton ID="btnSave" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                        ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' />
                        <asp:LinkButton ID="btnCancel" runat="server" CssClass="button cancelbutton" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                        ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
        </div>
    </ContentTemplate>
</asp:UpdatePanel>
<_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
