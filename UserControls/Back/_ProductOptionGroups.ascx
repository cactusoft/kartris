<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_ProductOptionGroups.ascx.vb"
    Inherits="_ProductOptionGroups" %>
<%@ Register TagPrefix="_user" TagName="_ProductOptions" Src="~/UserControls/Back/_ProductOptions.ascx" %>
<%@ Register TagPrefix="_user" TagName="ItemSelection" Src="~/UserControls/Back/_ItemSelection.ascx" %>
<%@ Register TagPrefix="_user" TagName="LanguageContent" Src="~/UserControls/Back/_LanguageContent.ascx" %>
<%@ Register TagPrefix="_user" TagName="LanguageContainer" Src="~/UserControls/Back/_LanguageContainer.ascx" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Literal ID="litProductID" runat="server" Visible="false" />
        <ajaxToolkit:TabContainer ID="tabContainerMain" runat="server" CssClass=".tab" EnableTheming="False">
            <ajaxToolkit:TabPanel ID="tabBasicInformation" runat="server">
                <HeaderTemplate>
                    <asp:Literal ID="litContentTextOptionInformation" runat="server" Text="<%$ Resources: _Options, ContentText_OptionInformation %>" />
                </HeaderTemplate>
                <ContentTemplate>
                    <asp:PlaceHolder ID="phdBasicVersion" runat="server" Visible="false"></asp:PlaceHolder>
                    <asp:UpdatePanel ID="updBasicInformation" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:Literal ID="litBasicVersionID" runat="server" Visible="false"></asp:Literal>
                            <asp:Literal ID="litBasicVersionType" runat="server" Visible="false"></asp:Literal>
                            <div id="section_options" class="Kartris-DetailsView-Data">
                                <ul>
                                    <%-- Code Number (CodeNumber) --%>
                                    <li>
                                        <asp:Label ID="lblFormLabelCodeNumber" runat="server" Text="<%$ Resources: _Version, FormLabel_CodeNumer %>"
                                            AssociatedControlID="txtBasicCodeNumber"></asp:Label>
                                        <asp:TextBox ID="txtBasicCodeNumber" runat="server" MaxLength="25" />
                                        <asp:RequiredFieldValidator ID="valRequiredBasicCodeNumber" runat="server" ControlToValidate="txtBasicCodeNumber"
                                            CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ValidationGroup="BasicVersion" />
                                    </li>
                                    <%-- Stock Tracking --%>
                                    <li>
                                        <asp:CheckBox ID="chkBasicStockTracking" runat="server" AutoPostBack="true" Checked="true"
                                            CssClass="checkbox" Text="<%$ Resources:_Version,ContentText_StockTrackingText %>" />
                                    </li>
                                    <asp:PlaceHolder ID="PlaceHolder2" runat="server" Visible="false">
                                        <li>
                                            <asp:Label ID="lblFormLabelStockQuantity" runat="server" Text="<%$ Resources:_Version,FormLabel_StockQuantity %>"
                                                AssociatedControlID="txtBasicStockQuantity"></asp:Label>
                                            <asp:TextBox ID="txtBasicStockQuantity" CssClass="mediumfield" runat="server" Text="0"
                                                MaxLength="5" />
                                            <asp:RequiredFieldValidator ID="valRequiredBasicStockQuantity" runat="server" CssClass="error"
                                                ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                ControlToValidate="txtBasicStockQuantity" Display="Dynamic" SetFocusOnError="true"
                                                ValidationGroup="BasicVersion" />
                                            <asp:CompareValidator ID="compareValidatorBasicStockQuantity" runat="server" ControlToValidate="txtBasicStockQuantity"
                                                Display="Dynamic" CssClass="error" ForeColor="" ErrorMessage="0-32767!" Operator="LessThanEqual"
                                                ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoShort %>" ValueToCompare="32767"
                                                Type="Integer" SetFocusOnError="true" ValidationGroup="BasicVersion" />
                                            <ajaxToolkit:FilteredTextBoxExtender ID="filBasicStockQuantity" runat="server" FilterType="Numbers"
                                                TargetControlID="txtBasicStockQuantity" />
                                        </li>
                                        <li>
                                            <asp:Label ID="lblFormLabelWarningLevel" runat="server" Text="<%$ Resources:_Version,FormLabel_WarningLevel %>"
                                                AssociatedControlID="txtBasicWarningLevel"></asp:Label>
                                            <asp:TextBox ID="txtBasicWarningLevel" CssClass="mediumfield" runat="server" Text="0"
                                                MaxLength="5" />
                                            <asp:RequiredFieldValidator ID="valRequiredBasicWarnLevel" runat="server" CssClass="error"
                                                ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                ControlToValidate="txtBasicWarningLevel" Display="Dynamic" SetFocusOnError="true"
                                                ValidationGroup="BasicVersion" />
                                            <asp:CompareValidator ID="valCompareBasicWarningLevel" runat="server" ControlToValidate="txtBasicWarningLevel"
                                                Display="Dynamic" CssClass="error" ForeColor="" ErrorMessage="0-32767!" Operator="LessThanEqual"
                                                ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoShort %>" ValueToCompare="32767"
                                                Type="Integer" SetFocusOnError="true" ValidationGroup="BasicVersion" />
                                            <ajaxToolkit:FilteredTextBoxExtender ID="filBasicWarningLevel" runat="server" FilterType="Numbers"
                                                TargetControlID="txtBasicWarningLevel" />
                                        </li>
                                    </asp:PlaceHolder>
                                    <%-- Price IncTax --%>
                                    <li>
                                        <asp:Label ID="lblFormLabelPriceIncTax" runat="server" Text="<%$ Resources:_Version,FormLabel_PriceIncTax %>"
                                            AssociatedControlID="txtBasicIncTax"></asp:Label>
                                        <asp:TextBox CssClass="mediumfield" ID="txtBasicIncTax" runat="server" MaxLength="8" />
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="txtBasicIncTax"
                                            CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ValidationGroup="BasicVersion" Display="Dynamic" SetFocusOnError="true" />
                                        <asp:RegularExpressionValidator ID="valRegexPrice" runat="server" ControlToValidate="txtBasicIncTax"
                                            CssClass="error" Display="Dynamic" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
                                            ForeColor="" SetFocusOnError="true" ValidationGroup="BasicVersion" ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filBasicVersion" runat="server" FilterType="Numbers,Custom"
                                            ValidChars=".," TargetControlID="txtBasicIncTax" />
                                    </li>
                                    <%-- Tax Band --%>
                                    <% If TaxRegime.VTax_Type = "rate" Then%>
                                    <li>
                                        <asp:Label ID="lblFormLabelTaxBand" runat="server" Text="<%$ Resources:_Version,FormLabel_TaxBand %>"
                                            AssociatedControlID="ddlBasicTaxBand"></asp:Label>
                                        <asp:DropDownList ID="ddlBasicTaxBand" runat="server" AppendDataBoundItems="true"
                                            CssClass="mediumfield">
                                            <asp:ListItem Text='<%$ Resources: _Kartris, ContentText_DropDownSelect %>' Value="0" />
                                        </asp:DropDownList>
                                        <asp:CompareValidator ID="compValidatorTaxBand" runat="server" CssClass="error" ForeColor=""
                                            ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ControlToValidate="ddlBasicTaxBand"
                                            Operator="NotEqual" ValueToCompare="0" ValidationGroup="BasicVersion" Display="Dynamic"
                                            SetFocusOnError="true" />
                                    </li>
                                     <% ElseIf TaxRegime.VTax_Type = "boolean" Then%>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Literal ID="litCheckBoxLabelTaxBand" runat="server" Text="<%$ Resources: _Version, FormLabel_TaxBand %>"></asp:Literal>
                                        </span><span class="Kartris-DetailsView-Value">
                                           <asp:CheckBox ID="chkTaxBand" runat="server" CssClass="checkbox" />
                                        </span></li>
                                    <% End If%>
                                    <%-- Tax Band2 --%>
                                    <% If TaxRegime.VTax_Type2 = "rate" Then%>
                                    <li>
                                        <asp:Label ID="lblFormLabelTaxBand2" runat="server" Text="<%$ Resources:_Version,FormLabel_TaxBand %>"
                                            AssociatedControlID="ddlBasicTaxBand2"></asp:Label>
                                        <asp:DropDownList ID="ddlBasicTaxBand2" runat="server" AppendDataBoundItems="true"
                                            CssClass="mediumfield">
                                            <asp:ListItem Text='<%$ Resources: _Kartris, ContentText_DropDownSelect %>' Value="0" />
                                        </asp:DropDownList>
                                        <asp:CompareValidator ID="compValidatorTaxBand2" runat="server" CssClass="error" ForeColor=""
                                            ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ControlToValidate="ddlBasicTaxBand2"
                                            Operator="NotEqual" ValueToCompare="0" ValidationGroup="BasicVersion" Display="Dynamic"
                                            SetFocusOnError="true" />
                                    </li>
                                     <% ElseIf TaxRegime.VTax_Type2 = "boolean" Then%>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Literal ID="litCheckBoxLabelTaxBand2" runat="server" Text="<%$ Resources: _Version, FormLabel_TaxBand %>"></asp:Literal>
                                        </span><span class="Kartris-DetailsView-Value">
                                           <asp:CheckBox ID="chkTaxBand2" runat="server" CssClass="checkbox" />
                                        </span></li>
                                    <% End If%>
                                    <%-- RRP --%>
                                    <li>
                                        <asp:Label ID="lblFormLabelRRP" runat="server" Text="<%$ Resources: _Version, FormLabel_RRP %>"
                                            AssociatedControlID="txtBasicRRP"></asp:Label>
                                        <asp:TextBox ID="txtBasicRRP" runat="server" CssClass="mediumfield" MaxLength="8" />
                                        <asp:RequiredFieldValidator ID="valRequiredRRP" runat="server" ControlToValidate="txtBasicRRP"
                                            CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ValidationGroup="BasicVersion" Display="Dynamic" SetFocusOnError="true" />
                                        <asp:RegularExpressionValidator ID="valRegexRRP" runat="server" ControlToValidate="txtBasicRRP"
                                            CssClass="error" Display="Dynamic" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
                                            ForeColor="" SetFocusOnError="true" ValidationGroup="BasicVersion" ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filBasicRRP" runat="server" FilterType="Numbers,Custom"
                                            ValidChars="." TargetControlID="txtBasicRRP" />
                                    </li>
                                    <%-- Weight --%>
                                    <li>
                                        <asp:Label ID="lblFormLabelVersionWeight" runat="server"
                                            AssociatedControlID="txtBasicWeight">
                                            <asp:Literal ID="litFormLabelVersionWeight" runat="server" Text="<%$ Resources: _Version, FormLabel_VersionWeight %>"></asp:Literal>
                                            (<% =KartSettingsManager.GetKartConfig("general.weightunit") %>)</asp:Label>
                                        <asp:TextBox ID="txtBasicWeight" runat="server" CssClass="mediumfield" MaxLength="8" />
                                        <asp:RequiredFieldValidator ID="valRequiredRRP2" runat="server" ControlToValidate="txtBasicWeight"
                                            CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ValidationGroup="BasicVersion" Display="Dynamic" SetFocusOnError="true" />
                                        <asp:RegularExpressionValidator ID="valRegexWeight" runat="server" ControlToValidate="txtBasicWeight"
                                            CssClass="error" Display="Dynamic" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
                                            ForeColor="" SetFocusOnError="true" ValidationGroup="BasicVersion" ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filBasicWeight" runat="server" FilterType="Numbers,Custom"
                                            ValidChars="." TargetControlID="txtBasicWeight" />
                                    </li>
                                </ul>
                                <%-- Save Button --%>
                                <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                                    <asp:LinkButton ID="lnkBtnSaveBasicVersion" runat="server" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                        ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' CssClass="button savebutton"
                                        ValidationGroup="BasicVersion" />
                                </div>
                                <%-- Message To User --%>
                                <asp:Literal ID="litBasicInfoMsg" runat="server" />
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
            <ajaxToolkit:TabPanel ID="tabProductOptions" runat="server">
                <HeaderTemplate>
                    <asp:Literal ID="litProductOptions" runat="server" Text="<%$ Resources: _Options, ContentText_ProductOptions %>" />
                </HeaderTemplate>
                <ContentTemplate>
                    <asp:UpdatePanel ID="updProductOptions" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <div id="section_options">
                                <asp:UpdatePanel ID="updOptionGroups" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <table class="kartristable">
                                            <thead>
                                                <tr>
                                                    <th>
                                                    </th>
                                                    <th class="optionsfield">
                                                        <div class="optionsfield">
                                                            <asp:Literal ID="litFormLabelIsOptional" runat="server" Text="<%$ Resources: _Options, FormLabel_IsOptional %>" /></div>
                                                        <div class="optionsfield">
                                                            <asp:Literal ID="litFormLabelOrderByValue" runat="server" Text="<%$ Resources: _Kartris, FormLabel_OrderByValue %>" /></div>
                                                        <div class="optionsfield">
                                                            <asp:Literal ID="litFormLabelWeightChange" runat="server" Text="<%$ Resources: _Options, FormLabel_WeightChange %>" /></div>
                                                        <div class="optionsfield">
                                                            <asp:Literal ID="litFormLabelPriceChange" runat="server" Text="<%$ Resources: _Options, FormLabel_PriceChange %>" /></div>
                                                        <div class="optionsfield">
                                                            <asp:Literal ID="litFormLabelIsDefault" runat="server" Text="<%$ Resources: _Options, FormLabel_IsDefault %>" /></div>
                                                    </th>
                                                </tr>
                                            </thead>
                                            <asp:Repeater ID="rptProductOptions" runat="server">
                                                <ItemTemplate>
                                                    <tr>
                                                        <td>
                                                            <asp:Literal ID="litOptionGrpID" runat="server" Text='<%# Eval("OPTG_ID") %>' Visible="false" />
                                                            <%--<asp:CheckBox ID="chkGrpBackName" runat="server" Checked='<%# Eval("ExistInTheProduct") %>'
                                                            OnCheckedChanged="CheckBoxChanged" AutoPostBack="true" CssClass="checkbox" Enabled="true" Visible="false" />--%>
                                                            <_user:ItemSelection ID="_UC_ItemSelection" Checked='<%# Eval("ExistInTheProduct") %>'
                                                                ItemNo='<%# Container.ItemIndex %>' runat="server" OnItemSelectionChanged="ItemSelectionChanged" />
                                                            <asp:LinkButton ID="lnkGrpName" runat="server" Text='<%# Eval("OPTG_BackendName") %>'
                                                                CommandName="select" CommandArgument='<%# Eval("OPTG_ID") %>' />
                                                        </td>
                                                        <td class="optionsfield">
                                                            <asp:Panel ID="pnlOptions" runat="server" Enabled='<%# Eval("ExistInTheProduct") %>'>
                                                                <div class="optionsfield">
                                                                    <asp:CheckBox ID="chkMustSelect" runat="server" Checked='<%# Eval("MustSelected") %>'
                                                                        CssClass="checkbox" />
                                                                </div>
                                                                <div class="optionsfield">
                                                                    <asp:TextBox ID="txtOrderByValue" runat="server" Text='<%# iif(CkartrisDataManipulation.FixNullFromDB(Eval("OPTG_DefOrderByValue")) IsNot Nothing, Eval("OPTG_DefOrderByValue"), "0") %>'
                                                                        MaxLength="3" />
                                                                    <asp:CompareValidator ID="valCompareOrderByValue" runat="server" ControlToValidate="txtOrderByValue"
                                                                        Display="Dynamic" CssClass="error" ForeColor="" ErrorMessage="0-255!" Operator="LessThanEqual"
                                                                        ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoByte %>" ValueToCompare="255"
                                                                        Type="Integer" SetFocusOnError="true" ValidationGroup="ProductOptions" />
                                                                    <asp:RequiredFieldValidator ID="valRequiredOrderByValue" runat="server" ControlToValidate="txtOrderByValue"
                                                                        CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                                        ValidationGroup="ProductOptions" Display="Dynamic" />
                                                                    <ajaxToolkit:FilteredTextBoxExtender ID="filOrderByValue" runat="server" TargetControlID="txtOrderByValue"
                                                                        FilterType="Numbers" />
                                                                </div>
                                                                <div class="optionsfield">
                                                                </div>
                                                                <div class="optionsfield">
                                                                </div>
                                                                <div class="optionsfield">
                                                                </div>
                                                            </asp:Panel>
                                                        </td>
                                                    </tr>
                                                    <asp:PlaceHolder ID="phdOptions" runat="server" Visible="false">
                                                        <_user:_ProductOptions ID="_UC_ProductOptions" runat="server" />
                                                    </asp:PlaceHolder>
                                                </ItemTemplate>
                                                <FooterTemplate>
                                                    </table>
                                                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                                                        <asp:UpdatePanel ID="updDeleteAllCombinations" runat="server" UpdateMode="Conditional">
                                                            <ContentTemplate>
                                                                <asp:LinkButton ID="lnkDeleteAllOptions" runat="server" Text="<%$ Resources: _Options, ContentText_DeleteCombinationsLink %>"
                                                                    ToolTip="<%$ Resources: _Options, ContentText_DeleteCombinationsText %>" CssClass="linkbutton icon_delete" />
                                                            </ContentTemplate>
                                                        </asp:UpdatePanel>
                                                        <asp:PlaceHolder ID="phdButtons" runat="server">
                                                            <asp:LinkButton ID="lnkBtnSaveProductOption" runat="server" CssClass="button savebutton"
                                                                CommandName="save" Text='<%$ Resources: _Kartris, FormButton_Save %>' ToolTip='<%$ Resources: _Kartris, FormButton_Save %>'
                                                                ValidationGroup="ProductOptions" />
                                                            <asp:LinkButton ID="lnkBtnResetSavedOptions" runat="server" CssClass="button cancelbutton"
                                                                CommandName="reset" Text='<%$ Resources: _Kartris, FormButton_Cancel %>' ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                                                            <asp:ValidationSummary ID="valSummary" runat="server" CssClass="valsummary" DisplayMode="BulletList"
                                                                ForeColor="" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" ValidationGroup="ProductOptions" />
                                                        </asp:PlaceHolder>
                                                    </div>
                                                </FooterTemplate>
                                            </asp:Repeater>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
            <ajaxToolkit:TabPanel ID="tabOptionCombinations" runat="server">
                <HeaderTemplate>
                    <asp:Literal ID="litContentTextOptionCombinations" runat="server" Text="<%$ Resources: _Options, ContentText_OptionCombinations %>" />
                </HeaderTemplate>
                <ContentTemplate>
                    <asp:UpdatePanel ID="updCreateCombination" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:Panel ID="pnlCreateCombination" DefaultButton="btnSubmitCombination" runat="server"
                                Visible="false" CssClass="subtabsection">
                                <p>
                                    <asp:Literal ID="litContentTextCreateCombinationsText" runat="server" Text="<%$ Resources: _Options, ContentText_CreateCombinationsText %>" /></p>
                                <div class="submitbuttons">
                                    <asp:LinkButton ID="btnSubmitCombination" runat="server" Text="<%$ Resources: _Options, ContentText_CreateCombinations %>"
                                        CssClass="linkbutton icon_new" Visible="True" /></div>
                            </asp:Panel>
                            <asp:Panel ID="pnlCannotCreateCombinations" runat="server">
                                <p>
                                    <asp:Literal ID="litContentTextCannotCreateCombinations" runat="server" Text="<%$ Resources: _Options, ContentText_CannotCreateCombinationsText %>" /></p>
                            </asp:Panel>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    <asp:UpdatePanel ID="updCombinations" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:PlaceHolder ID="phdCombinationList" runat="server" Visible="false">
                                <ajaxToolkit:TabContainer ID="tabCombinations" runat="server" CssClass=".tab" EnableTheming="false">
                                    <ajaxToolkit:TabPanel ID="tabCurrentCombinations" runat="server">
                                        <HeaderTemplate>
                                            <asp:Literal ID="litCurrentCombinationsHeader" runat="server" />
                                        </HeaderTemplate>
                                        <ContentTemplate>
                                            <asp:UpdatePanel ID="updCombinationsList" runat="server" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <div id="section_combinations">
                                                        <table class="kartristable">
                                                            <asp:Repeater ID="rptCurrentCombinations" runat="server">
                                                                <HeaderTemplate>
                                                                    <thead>
                                                                        <tr>
                                                                            <th>
                                                                                &nbsp;
                                                                            </th>
                                                                            <th>
                                                                                <asp:Literal ID="litFormLabelVersionName" runat="server" Text="<%$ Resources: _Product, FormLabel_VersionName  %>" />
                                                                            </th>
                                                                            <th>
                                                                                <asp:Literal ID="litFormLabelCodeNumber" runat="server" Text="<%$ Resources: _Version, FormLabel_CodeNumer %>" />
                                                                            </th>
                                                                            <asp:PlaceHolder ID="phdHeaderPrice" runat="server">
                                                                                <th>
                                                                                    <% If KartSettingsManager.GetKartConfig("general.tax.pricesinctax") = "y" Then%>
                                                                                    <asp:Literal ID="litFormLabelPriceIncTax" runat="server" Text="<%$ Resources: _Version, FormLabel_PriceIncTax %>"></asp:Literal>
                                                                                    <% Else%>
                                                                                    <asp:Literal ID="litFormLabelPriceExTax" runat="server" Text="<%$ Resources: _Version, FormLabel_PriceExTax %>"></asp:Literal>
                                                                                    <% End If%>
                                                                                </th>
                                                                            </asp:PlaceHolder>
                                                                            <asp:PlaceHolder ID="phdHeaderStock" runat="server">
                                                                                <th>
                                                                                    <asp:Literal ID="litFormLabelStockQuantity" runat="server" Text="<%$ Resources: _Version, FormLabel_StockQuantity %>" />
                                                                                </th>
                                                                                <th>
                                                                                    <asp:Literal ID="litFormLabelWarningLevel" runat="server" Text="<%$ Resources: _Version, FormLabel_WarningLevel %>" />
                                                                                </th>
                                                                            </asp:PlaceHolder>
                                                                            <th>
                                                                                <asp:Literal ID="litFormLabelLive" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Live %>" />
                                                                            </th>
                                                                        </tr>
                                                                    </thead>
                                                                </HeaderTemplate>
                                                                <ItemTemplate>
                                                                    <tr class='<%# GetRowClass(Container.ItemIndex) %>'>
                                                                        <td class="recordnumberfield">
                                                                            <asp:Literal ID="litItemIndex" runat="server" Text='<%# Container.ItemIndex + 1 %>' />
                                                                        </td>
                                                                        <!-- Name -->
                                                                        <td>
                                                                            <asp:Literal ID="litVersionID" runat="server" Text='<%# Eval("V_ID") %>' Visible="false" />
                                                                            <asp:TextBox ID="txtCombinationOptionName" CssClass="itemname" runat="server" Text='<%# Eval("V_Name") %>'
                                                                                MaxLength="4000" />
                                                                            <asp:RequiredFieldValidator ID="valRequiredCombinationOptionName" runat="server"
                                                                                ControlToValidate="txtCombinationOptionName" CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                                                ValidationGroup="CurrentCombinationsGrp" Display="Dynamic" />
                                                                        </td>
                                                                        <!-- Code Number -->
                                                                        <td>
                                                                            <asp:TextBox ID="txtCombinationCodeNumber" CssClass="codenumber" runat="server" Text='<%# Eval("V_CodeNumber") %>'
                                                                                MaxLength="25" />
                                                                            <asp:RequiredFieldValidator ID="valRequiredCombinationCodeNumber" runat="server"
                                                                                ControlToValidate="txtCombinationCodeNumber" CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                                                ValidationGroup="CurrentCombinationsGrp" Display="Dynamic" />
                                                                        </td>
                                                                        <asp:PlaceHolder ID="phdPrice" runat="server" Visible='<%# Eval("UseCombinationPrices") %>'>
                                                                            <!-- Price -->
                                                                            <td>
                                                                                <asp:TextBox ID="txtCombinationPrice" CssClass="midtext" MaxLength="8" runat="server" Text='<%# Eval("V_Price") %>' />
                                                                                <asp:RequiredFieldValidator ID="valRequiredCombinationPrice" runat="server" ControlToValidate="txtCombinationPrice"
                                                                                    CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                                                    ValidationGroup="CurrentCombinationsGrp" Display="Dynamic" Enabled='<%# Eval("UseCombinationPrices") %>' />
                                                                            </td>
                                                                        </asp:PlaceHolder>
                                                                        <asp:PlaceHolder ID="phdStock" runat="server" Visible='<%# Eval("IsStockTracking") %>'>
                                                                            <!-- Stock Quantity -->
                                                                            <td>
                                                                                <asp:TextBox ID="txtCombinationStockQuantity" CssClass="shorttext" runat="server"
                                                                                    Text='<%# Eval("V_Quantity") %>' MaxLength="5" />
                                                                                <asp:RequiredFieldValidator ID="valRequiredCombinationStockQuantity" runat="server"
                                                                                    ControlToValidate="txtCombinationStockQuantity" CssClass="error" ForeColor=""
                                                                                    ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ValidationGroup="CurrentCombinationsGrp"
                                                                                    Display="Dynamic" Enabled='<%# Eval("IsStockTracking") %>' />
                                                                                <asp:CompareValidator ID="valCompareCombinationStockQuantity" runat="server" ControlToValidate="txtCombinationStockQuantity"
                                                                                    Display="Dynamic" CssClass="error" ForeColor="" ErrorMessage="0-32767!" Operator="LessThanEqual"
                                                                                    ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoShort %>" ValueToCompare="32767"
                                                                                    Type="Integer" SetFocusOnError="true" ValidationGroup="CurrentCombinationsGrp"
                                                                                    Enabled='<%# Eval("IsStockTracking") %>' />
                                                                                <ajaxToolkit:FilteredTextBoxExtender ID="filCombinationStockQuantity" runat="server"
                                                                                    TargetControlID="txtCombinationStockQuantity" FilterType="Numbers" />
                                                                            </td>
                                                                            <!-- Warn Level -->
                                                                            <td>
                                                                                <asp:TextBox ID="txtCombinationWarningLevel" CssClass="shorttext" runat="server"
                                                                                    Text='<%# Eval("V_QuantityWarnLevel") %>' MaxLength="5" />
                                                                                <asp:RequiredFieldValidator ID="valRequiredCombinationWarningLevel" runat="server"
                                                                                    ControlToValidate="txtCombinationWarningLevel" CssClass="error" ForeColor=""
                                                                                    ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ValidationGroup="CurrentCombinationsGrp"
                                                                                    Display="Dynamic" Enabled='<%# Eval("IsStockTracking") %>' />
                                                                                <asp:CompareValidator ID="valCompareCombinationWarningLevel" runat="server" ControlToValidate="txtCombinationWarningLevel"
                                                                                    Display="Dynamic" CssClass="error" ForeColor="" ErrorMessage="0-32767!" Operator="LessThanEqual"
                                                                                    ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoShort %>" ValueToCompare="32767"
                                                                                    Type="Integer" SetFocusOnError="true" ValidationGroup="CurrentCombinationsGrp"
                                                                                    Enabled='<%# Eval("IsStockTracking") %>' />
                                                                                <ajaxToolkit:FilteredTextBoxExtender ID="filCombinationWarningLevel" runat="server"
                                                                                    TargetControlID="txtCombinationWarningLevel" FilterType="Numbers" />
                                                                            </td>
                                                                        </asp:PlaceHolder>
                                                                        <!-- Live -->
                                                                        <td>
                                                                            <asp:CheckBox ID="chkCombinationLive" runat="server" Checked='<%# Eval("V_Live") %>'
                                                                                CssClass="checkbox" />
                                                                        </td>
                                                                    </tr>
                                                                </ItemTemplate>
                                                                <FooterTemplate>
                                                                    </table><div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                                                                        <asp:Literal ID="litSaveMessage" runat="server"></asp:Literal>
                                                                        <asp:LinkButton ID="lnkBtnSaveCombination" runat="server" CssClass="button savebutton"
                                                                            Text="<%$ Resources: _Kartris, FormButton_Save %>" ToolTip="<%$ Resources: _Kartris, FormButton_Save %>"
                                                                            CommandName="update" ValidationGroup="CurrentCombinationsGrp" /><span class="floatright">
                                                                                <asp:LinkButton ID="lnkBtnDeleteExistingCombinations" CssClass="button deletebutton"
                                                                                    runat="server" Text='<%$ Resources: _Options, FormButton_DeleteCombinations %>'
                                                                                    CommandName="deletecombinations" /></span><asp:ValidationSummary ID="valSummary"
                                                                                        runat="server" ForeColor="" CssClass="valsummary" DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>"
                                                                                        ValidationGroup="CurrentCombinationsGrp" />
                                                                    </div>
                                                                </FooterTemplate>
                                                            </asp:Repeater>
                                                        </table>
                                                    </div>
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </ContentTemplate>
                                    </ajaxToolkit:TabPanel>
                                    <ajaxToolkit:TabPanel ID="tabNewCombinations" runat="server" Enabled="false">
                                        <HeaderTemplate>
                                            <asp:Literal ID="litNewCombinationsHeader" runat="server" />
                                        </HeaderTemplate>
                                        <ContentTemplate>
                                            <asp:UpdatePanel ID="updNewCombinationsList" runat="server" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <div id="section_combinations">
                                                        <table class="kartristable">
                                                            <asp:Repeater ID="rptNewCombinations" runat="server">
                                                                <HeaderTemplate>
                                                                    <thead>
                                                                        <tr>
                                                                            <th>
                                                                                &nbsp;
                                                                            </th>
                                                                            <th>
                                                                                <asp:Literal ID="litFormLabelVersionName" runat="server" Text="<%$ Resources: _Product, FormLabel_VersionName  %>" />
                                                                            </th>
                                                                            <th>
                                                                                <asp:Literal ID="litFormLabelCodeNumber" runat="server" Text="<%$ Resources: _Version, FormLabel_CodeNumer %>" />
                                                                            </th>
                                                                            <asp:PlaceHolder ID="phdHeaderPrice" runat="server">
                                                                                <th>
                                                                                    <% If KartSettingsManager.GetKartConfig("general.tax.pricesinctax") = "y" Then%>
                                                                                    <asp:Literal ID="litFormLabelPriceIncTax" runat="server" Text="<%$ Resources: _Version, FormLabel_PriceIncTax %>"></asp:Literal>
                                                                                    <% Else%>
                                                                                    <asp:Literal ID="litFormLabelPriceExTax" runat="server" Text="<%$ Resources: _Version, FormLabel_PriceExTax %>"></asp:Literal>
                                                                                    <% End If%>
                                                                                </th>
                                                                            </asp:PlaceHolder>
                                                                            <asp:PlaceHolder ID="phdHeaderStock" runat="server">
                                                                                <th>
                                                                                    <asp:Literal ID="litFormLabelStockQuantity" runat="server" Text="<%$ Resources: _Version, FormLabel_StockQuantity %>" />
                                                                                </th>
                                                                                <th>
                                                                                    <asp:Literal ID="litFormLabelWarningLevel" runat="server" Text="<%$ Resources: _Version, FormLabel_WarningLevel %>" />
                                                                                </th>
                                                                            </asp:PlaceHolder>
                                                                            <th>
                                                                                <asp:Literal ID="litFormLabelLive" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Live %>" />
                                                                            </th>
                                                                        </tr>
                                                                    </thead>
                                                                </HeaderTemplate>
                                                                <ItemTemplate>
                                                                    <tr class='<%# GetRowClass(Container.ItemIndex) %>'>
                                                                        <td class="recordnumberfield">
                                                                            <asp:Literal ID="litItemIndex" runat="server" Text='<%# Container.ItemIndex + 1 %>' />
                                                                        </td>
                                                                        <!-- Name -->
                                                                        <td>
                                                                            <asp:Literal ID="litIDList" runat="server" Text='<%# Eval("ID_List") %>' Visible="false" />
                                                                            <asp:TextBox ID="txtCombinationOptionName" CssClass="itemname" runat="server" Text='<%# Eval("OPT_Name") %>'
                                                                                MaxLength="4000" />
                                                                            <asp:RequiredFieldValidator ID="valRequiredCombinationOptionName" runat="server"
                                                                                ControlToValidate="txtCombinationOptionName" CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                                                ValidationGroup="NewCombinationsGrp" Display="Dynamic" />
                                                                        </td>
                                                                        <!-- Code Number -->
                                                                        <td>
                                                                            <asp:TextBox ID="txtCombinationCodeNumber" CssClass="codenumber" runat="server" Text='<%# Eval("CodeNumber") %>'
                                                                                MaxLength="25" />
                                                                            <asp:RequiredFieldValidator ID="valRequiredCombinationCodeNumber" runat="server"
                                                                                ControlToValidate="txtCombinationCodeNumber" CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                                                ValidationGroup="NewCombinationsGrp" Display="Static" />
                                                                        </td>
                                                                        <asp:PlaceHolder ID="phdPrice" runat="server" Visible='<%# Eval("UseCombinationPrices") %>'>
                                                                            <!-- Price -->
                                                                            <td>
                                                                                <asp:TextBox ID="txtCombinationPrice" CssClass="midtext" MaxLength="8" runat="server" Text='<%# Eval("Price") %>' />
                                                                                <asp:RequiredFieldValidator ID="valRequiredCombinationPrice" runat="server" ControlToValidate="txtCombinationPrice"
                                                                                    CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                                                    ValidationGroup="CurrentCombinationsGrp" Display="Dynamic" Enabled='<%# Eval("UseCombinationPrices") %>' />
                                                                            </td>
                                                                        </asp:PlaceHolder>
                                                                        <asp:PlaceHolder ID="PlaceHolder3" runat="server" Visible='<%# Eval("IsStockTracking") %>'>
                                                                            <!-- Stock Quantity -->
                                                                            <td>
                                                                                <asp:TextBox ID="txtCombinationStockQuantity" runat="server" Text='<%# Eval("Quantity") %>'
                                                                                    CssClass="shorttext" MaxLength="5" />
                                                                                <asp:CompareValidator ID="valCompareCombinationStockQuantity" runat="server" ControlToValidate="txtCombinationStockQuantity"
                                                                                    Display="Dynamic" CssClass="error" ForeColor="" ErrorMessage="0-32767!" Operator="LessThanEqual"
                                                                                    ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoShort %>" ValueToCompare="32767"
                                                                                    Type="Integer" SetFocusOnError="true" ValidationGroup="NewCombinationsGrp" Enabled='<%# Eval("IsStockTracking") %>' />
                                                                                <ajaxToolkit:FilteredTextBoxExtender ID="filCombinationStockQuantity" runat="server"
                                                                                    TargetControlID="txtCombinationStockQuantity" FilterType="Numbers" />
                                                                            </td>
                                                                            <!-- Warn Level -->
                                                                            <td>
                                                                                <asp:TextBox ID="txtCombinationWarningLevel" runat="server" Text='<%# Eval("QuantityWarnLevel") %>'
                                                                                    CssClass="shorttext" MaxLength="5" />
                                                                                <asp:CompareValidator ID="valCompareCombinationWarningLevel" runat="server" ControlToValidate="txtCombinationWarningLevel"
                                                                                    Display="Dynamic" CssClass="error" ForeColor="" ErrorMessage="0-32767" Operator="LessThanEqual"
                                                                                    ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoShort %>" ValueToCompare="32767"
                                                                                    Type="Integer" SetFocusOnError="true" ValidationGroup="NewCombinationsGrp" Enabled='<%# Eval("IsStockTracking") %>' />
                                                                                <ajaxToolkit:FilteredTextBoxExtender ID="filCombinationWarningLevel" runat="server"
                                                                                    TargetControlID="txtCombinationWarningLevel" FilterType="Numbers" />
                                                                            </td>
                                                                        </asp:PlaceHolder>
                                                                        <!-- Live -->
                                                                        <td>
                                                                            <asp:CheckBox ID="chkCombinationLive" runat="server" Checked="true" CssClass="checkbox" />
                                                                        </td>
                                                                    </tr>
                                                                </ItemTemplate>
                                                                <FooterTemplate>
                                                                    </table>
                                                                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                                                                        <asp:LinkButton ID="lnkBtnSaveCombination" runat="server" Text="<%$ Resources: _Kartris, FormButton_Save %>"
                                                                            ToolTip="<%$ Resources: _Kartris, FormButton_Save %>" CommandName="save" ValidationGroup="NewCombinationsGrp"
                                                                            CssClass="button savebutton" Visible="True" /><asp:ValidationSummary ID="valSummary"
                                                                                runat="server" ForeColor="" CssClass="valsummary" DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>"
                                                                                ValidationGroup="NewCombinationsGrp" />
                                                                    </div>
                                                                    <asp:Literal ID="litSaveMessage" runat="server"></asp:Literal>
                                                                </FooterTemplate>
                                                            </asp:Repeater>
                                                        </table>
                                                    </div>
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </ContentTemplate>
                                    </ajaxToolkit:TabPanel>
                                </ajaxToolkit:TabContainer>
                            </asp:PlaceHolder>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
        </ajaxToolkit:TabContainer>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdatePanel ID="updPopups" runat="server">
    <ContentTemplate>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
        <_user:PopupMessage ID="_UC_PopupMsg_DeleteCombinations" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
