<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_EditVersion.ascx.vb"
    Inherits="_EditVersion" %>
<%@ Register TagPrefix="_user" TagName="LanguageContainer" Src="~/UserControls/Back/_LanguageContainer.ascx" %>
<%@ Register TagPrefix="_user" TagName="FileUploader" Src="~/UserControls/Back/_FileUploader.ascx" %>
<%@ Register TagPrefix="_user" TagName="UploaderPopup" Src="~/UserControls/Back/_UploaderPopup.ascx" %>
<%@ Import Namespace="CkartrisEnumerations" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Literal ID="litVersionID" runat="server" Visible="false" Text="0"></asp:Literal>
        <asp:UpdatePanel ID="updClone" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:CheckBox ID="chkClone" runat="server" CssClass="checkbox" Visible="false" />
            </ContentTemplate>
        </asp:UpdatePanel>
        <%-- LanguageStrings --%>
        <div>
            <asp:UpdatePanel ID="updLanguageContainer" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:PlaceHolder ID="phdLanguages" runat="server">
                        <_user:LanguageContainer ID="_UC_LangContainer" runat="server" />
                    </asp:PlaceHolder>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
        <%-- ------LINE------- --%>
        <div class="line">
        </div>
        <div class="Kartris-DetailsView">
            <div class="Kartris-DetailsView-Data">
                <ul>
                    <%-- ShowOnSite (Live) --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litFormLabelShowOnSite" runat="server" Text="<%$ Resources: _Category, FormLabel_ShowOnSite %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:CheckBox ID="chkLive" runat="server" CssClass="checkbox" />
                    </span></li>
                    <%-- Version Type  --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litFormLabelVersionType" runat="server" Text="<%$ Resources: _Version, FormLabel_VersionType %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:DropDownList ID="ddlVersionType" runat="server" Enabled="false">
                            <asp:ListItem Text="Normal Version" Value="v" Selected="True" />
                            <%--<asp:ListItem Text="Option Version" Value="o" />--%>
                            <asp:ListItem Text="Base Version" Value="b" />
                            <asp:ListItem Text="Combination Version" Value="c" />
                        </asp:DropDownList>
                    </span></li>
                    <%-- Code Number (CodeNumber) --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litFormLabelCodeNumber" runat="server" Text="<%$ Resources: _Version, FormLabel_CodeNumer %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:TextBox ID="txtCodeNumber" runat="server" MaxLength="25" />
                        <asp:RequiredFieldValidator ID="valRequiredCodeNumber" runat="server" CssClass="error"
                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                            ControlToValidate="txtCodeNumber" Display="Dynamic" SetFocusOnError="true" />
                    </span></li>
                    <%-- Price IncTax / ExTax (depends on pricesinctax config setting) --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <% If KartSettingsManager.GetKartConfig("general.tax.pricesinctax") = "y" Then%>
                        <asp:Literal ID="litFormLabelPriceIncTax" runat="server" Text="<%$ Resources: _Version, FormLabel_PriceIncTax %>"></asp:Literal>
                        <% Else%>
                        <asp:Literal ID="litFormLabelPriceExTax" runat="server" Text="<%$ Resources: _Version, FormLabel_PriceExTax %>"></asp:Literal>
                        <% End If%>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:TextBox ID="txtPriceIncTax" runat="server" CssClass="midtext" MaxLength="8" />
                        <asp:RequiredFieldValidator ID="valRequiredPrice" runat="server" CssClass="error"
                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                            ControlToValidate="txtPriceIncTax" SetFocusOnError="true" Display="Dynamic" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Versions %>" />
                        <asp:RegularExpressionValidator ID="valRegexPrice" runat="server" Display="Dynamic"
                            SetFocusOnError="true" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
                            CssClass="error" ForeColor="" ControlToValidate="txtPriceIncTax" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Versions %>"
                            ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                        <ajaxToolkit:FilteredTextBoxExtender ID="filPriceIncTax" runat="server" TargetControlID="txtPriceIncTax"
                            FilterType="Numbers,Custom" ValidChars=".," />
                    </span></li>
                    <%-- Tax Band --%>
                    <% If TaxRegime.VTax_Type = "rate" Then%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litFormLabelTaxBand" runat="server" Text="<%$ Resources: _Version, FormLabel_TaxBand %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:DropDownList ID="ddlTaxBand" runat="server" AppendDataBoundItems="true" CssClass="midtext">
                            <asp:ListItem Text='<%$ Resources: _Kartris, ContentText_DropDownSelect %>' Value="0" />
                        </asp:DropDownList>
                        <asp:CompareValidator ID="valCompareTaxBand" runat="server" CssClass="error" ForeColor=""
                            ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ControlToValidate="ddlTaxBand"
                            Operator="NotEqual" ValueToCompare="0" Display="Dynamic" SetFocusOnError="true"
                            ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Versions %>" />
                    </span></li>
                    <% ElseIf TaxRegime.VTax_Type = "boolean" Then%>
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Literal ID="litCheckBoxLabelTaxBand" runat="server" Text="<%$ Resources: _Kartris, ContentText_ChargeTax %>"></asp:Literal>
                        </span><span class="Kartris-DetailsView-Value">
                           <asp:CheckBox ID="chkTaxBand" runat="server" CssClass="checkbox" />
                        </span></li>
                    <% End If%>
                    <%-- Tax Band 2--%>
                    <% If TaxRegime.VTax_Type2 = "rate" Then%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litFormLabelTaxBand2" runat="server" Text="<%$ Resources: _Version, FormLabel_TaxBand %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:DropDownList ID="ddlTaxBand2" runat="server" AppendDataBoundItems="true" CssClass="midtext">
                            <asp:ListItem Text='<%$ Resources: _Kartris, ContentText_DropDownSelect %>' Value="0" />
                        </asp:DropDownList>
                        <asp:CompareValidator ID="valCompareTaxBand2" runat="server" CssClass="error" ForeColor=""
                            ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ControlToValidate="ddlTaxBand2"
                            Operator="NotEqual" ValueToCompare="0" Display="Dynamic" SetFocusOnError="true"
                            ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Versions %>" />
                    </span></li>
                     <% ElseIf TaxRegime.VTax_Type2 = "boolean" Then%>
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Literal ID="litCheckBoxLabelTaxBand2" runat="server" Text="<%$ Resources: _Kartris, ContentText_ChargeTax %>"></asp:Literal>
                        </span><span class="Kartris-DetailsView-Value">
                           <asp:CheckBox ID="chkTaxBand2" runat="server" CssClass="checkbox" />
                        </span></li>
                    <% End If%>
                    <%-- Weight  --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litFormLabelVersionWeight" runat="server" Text="<%$ Resources: _Version, FormLabel_VersionWeight %>"></asp:Literal>
                        (<% =KartSettingsManager.GetKartConfig("general.weightunit") %>)
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:TextBox ID="txtWeight" runat="server" CssClass="shorttext" MaxLength="8" />
                        <asp:RequiredFieldValidator ID="valRequiredWeight" runat="server" CssClass="error"
                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                            ControlToValidate="txtWeight" Display="Dynamic" SetFocusOnError="true" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Versions %>" />
                        <asp:RegularExpressionValidator ID="valRegexWeight" runat="server" ControlToValidate="txtWeight"
                            CssClass="error" Display="Dynamic" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
                            ForeColor="" SetFocusOnError="true" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Versions %>"
                            ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                        <ajaxToolkit:FilteredTextBoxExtender ID="filWeight" runat="server" TargetControlID="txtWeight"
                            FilterType="Numbers,Custom" ValidChars=".," />
                    </span></li>
                    <%-- RRP  --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litFormLabelRRP" runat="server" Text="<%$ Resources: _Version, FormLabel_RRP %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:TextBox ID="txtRRP" runat="server" CssClass="shorttext" MaxLength="8" />
                        <asp:RequiredFieldValidator ID="valRequiredRRP" runat="server" CssClass="error" ForeColor=""
                            ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ControlToValidate="txtRRP"
                            Display="Dynamic" SetFocusOnError="true" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Versions %>" />
                        <asp:RegularExpressionValidator ID="valRegexRRP" runat="server" ControlToValidate="txtRRP"
                            CssClass="error" Display="Dynamic" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
                            ForeColor="" SetFocusOnError="true" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Versions %>"
                            ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                        <ajaxToolkit:FilteredTextBoxExtender ID="filRRP" runat="server" TargetControlID="txtRRP"
                            FilterType="Numbers,Custom" ValidChars=".," />
                    </span></li>
                    <%-- Delivery Time  --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litFormLabelDeliveryTime" runat="server" Text="<%$ Resources: _Version, FormLabel_DeliveryTime %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:TextBox ID="txtDeliveryTime" runat="server" CssClass="shorttext" MaxLength="3" />
                        <asp:RequiredFieldValidator ID="valRequiredDelivery" runat="server" CssClass="error"
                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                            ControlToValidate="txtDeliveryTime" Display="Dynamic" SetFocusOnError="true"
                            ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Versions %>" />
                        <asp:CompareValidator ID="valCompareDelivery" runat="server" ControlToValidate="txtDeliveryTime"
                            CssClass="error" ForeColor="" Display="Dynamic" ErrorMessage="0-255!" Operator="LessThanEqual"
                            ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoByte %>" ValueToCompare="255"
                            Type="Integer" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Versions %>" />
                        <ajaxToolkit:FilteredTextBoxExtender ID="filDeliveryTime" runat="server" TargetControlID="txtDeliveryTime"
                            FilterType="Numbers" />
                    </span></li>
                    <%-- Stock Tracking  --%>
                    <asp:PlaceHolder ID="phdStockTracking" runat="server">
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Literal ID="litFormLabelStockTracking" runat="server" Text="<%$ Resources: _Version, FormLabel_StockTracking %>"></asp:Literal>
                        </span><span class="Kartris-DetailsView-Value">
                            <asp:CheckBox ID="chkStockTracking" runat="server" CssClass="checkbox" AutoPostBack="true" />
                            <asp:PlaceHolder ID="phdStockTrackingInputs" runat="server">
                                <asp:Literal ID="litFormLabelStockTrackingText" runat="server" Text="<%$ Resources: _Version, ContentText_StockTrackingText %>"></asp:Literal><br />
                                <asp:Literal ID="litFormLabelStockQuantity" runat="server" Text="<%$ Resources: _Version, FormLabel_StockQuantity %>" />&nbsp;
                                <asp:TextBox ID="txtStockQuantity" runat="server" CssClass="shorttext" MaxLength="5" />
                                <asp:CompareValidator ID="valCompareStockQuantity" runat="server" ControlToValidate="txtStockQuantity"
                                    Display="Dynamic" CssClass="error" ForeColor="" ErrorMessage="0-32767!" Operator="LessThanEqual"
                                    ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoShort %>" ValueToCompare="32767"
                                    Type="Double" SetFocusOnError="true" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Versions %>" />
                                <asp:RequiredFieldValidator ID="valRequiredStockQty" runat="server" CssClass="error"
                                    ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                    ControlToValidate="txtStockQuantity" Display="Dynamic" SetFocusOnError="true"
                                    ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Versions %>" />&nbsp;
                                <asp:Literal ID="litFormLabelWarningLevel" runat="server" Text="<%$ Resources: _Version, FormLabel_WarningLevel %>" />&nbsp;
                                <asp:TextBox ID="txtWarningLevel" runat="server" CssClass="shorttext" MaxLength="5" />
                                <asp:CompareValidator ID="valCompareWarningLevel" runat="server" ControlToValidate="txtWarningLevel"
                                    Display="Dynamic" CssClass="error" ForeColor="" ErrorMessage="0-32767!" Operator="LessThanEqual"
                                    ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoShort %>" ValueToCompare="32767"
                                    Type="Double" SetFocusOnError="true" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Versions %>" />
                                <asp:RequiredFieldValidator ID="valRequiredWarnLevel" runat="server" CssClass="error"
                                    ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                    ControlToValidate="txtWarningLevel" Display="Dynamic" SetFocusOnError="true"
                                    ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Versions %>" />
                                <ajaxToolkit:FilteredTextBoxExtender ID="filStockQuantity" runat="server" TargetControlID="txtStockQuantity"
                                    FilterType="Numbers,Custom" ValidChars=".," />
                                <ajaxToolkit:FilteredTextBoxExtender ID="filWarningLevel" runat="server" TargetControlID="txtWarningLevel"
                                    FilterType="Numbers,Custom" ValidChars=".," />
                            </asp:PlaceHolder>
                        </span></li>
                    </asp:PlaceHolder>
                    <%-- LimitByGroup (CustomerGroupID) --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litFormLabelLimitToCustomerGroup" runat="server" Text="<%$ Resources: _Category, ContentText_LimitToCustomerGroup %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:DropDownList ID="ddlCustomerGroup" runat="server" AppendDataBoundItems="true">
                            <asp:ListItem Text="<%$ Resources: _Category, ContentText_AvailableToAll %>" Value="0"></asp:ListItem>
                        </asp:DropDownList>
                    </span></li>
                    <%-- User Customization --%>
                    <li>
                        <asp:UpdatePanel ID="updCustomizationType" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextCustomizationType" runat="server" Text="<%$ Resources: _Versions, ContentText_CustomizationType %>"></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:DropDownList ID="ddlCustomizationType" runat="server" AutoPostBack="true">
                                        <asp:ListItem Text="<%$ Resources: _Kartris, ContentText_None %>" Value="n" Selected="True"></asp:ListItem>
                                        <asp:ListItem Text="<%$ Resources: _Kartris, ContentText_PlainText %>" Value="t"></asp:ListItem>
                                        <asp:ListItem Text='<%$ Resources: _Version, ContentText_RequiredPlainText %>' Value="r"></asp:ListItem>
                                    </asp:DropDownList>
                                    <br />
                                    <asp:PlaceHolder ID="phdCustomization" runat="server" Visible="false">
                                        <asp:Literal ID="litContentTextCustomizationDetails" runat="server" Text="<%$ Resources: _Versions, ContentText_CustomizationDetails %>"></asp:Literal>&nbsp;
                                        <asp:TextBox ID="txtCustomizationDesc" runat="server" MaxLength="255" CssClass="text" />&nbsp;
                                        <asp:Literal ID="litContentTextPrice" runat="server" Text="<%$ Resources: _Kartris, ContentText_Price %>" />&nbsp;
                                        <asp:TextBox ID="txtCustomizationCost" runat="server" CssClass="shorttext" MaxLength="8"
                                            Text="0" />
                                        <asp:RequiredFieldValidator ID="valRequiredCustomizationCost" runat="server" CssClass="error"
                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ControlToValidate="txtCustomizationCost" Display="Dynamic" SetFocusOnError="true"
                                            ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Versions %>" />
                                        <asp:RegularExpressionValidator ID="valRegexCustomizationCost" runat="server" ControlToValidate="txtCustomizationCost"
                                            CssClass="error" Display="Dynamic" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
                                            ForeColor="" SetFocusOnError="true" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Versions %>"
                                            ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filCustomizationCost" runat="server" TargetControlID="txtCustomizationCost"
                                            FilterType="Numbers,Custom" ValidChars=".," />
                                    </asp:PlaceHolder>
                                </span>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </li>
                    <%-- Free Shipping  --%>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litContentTextDeliveryType" runat="server" Text="<%$ Resources: _Version, ContentText_DeliveryType %>"></asp:Literal>
                    </span><span class="Kartris-DetailsView-Value">
                        <asp:UpdatePanel ID="updFreeShipping" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:DropDownList ID="ddlDownloadType" runat="server" AutoPostBack="true">
                                    <asp:ListItem Text="<%$ Resources: _Version, ContentText_NormalDelivery %>" Value="n"
                                        Selected="True" />
                                    <asp:ListItem Text="<%$ Resources: _Version, FormLabel_DownLoadURL %>" Value="l" />
                                    <asp:ListItem Text="<%$ Resources: _Version, ContentText_DownloadableFile %>" Value="u" />
                                    <asp:ListItem Text="<%$ Resources: _Version,FormLabel_FreeShipping %>" Value="f" />
                                </asp:DropDownList>
                                <asp:PlaceHolder ID="phdLink" runat="server" Visible="false">
                                    <br />
                                    <asp:Literal ID="litURL" runat="server" Text="<%$ Resources: _Version, FormLabel_DownLoadURL %>" />
                                    &nbsp;http://<asp:TextBox ID="txtURL" runat="server" />
                                </asp:PlaceHolder>
                                <asp:PlaceHolder ID="phdUpload" runat="server" Visible="false">
                                    <asp:UpdatePanel ID="updUpload" runat="server" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <asp:PlaceHolder ID="phdDownloadFileInfo" runat="server" Visible="false">
                                                <asp:Literal ID="litContentTextFile" runat="server" Text="<%$ Resources: _Version, ContentText_DownloadableFile %>" />
                                                &nbsp; <b>
                                                    <asp:Literal ID="litFileName" runat="server" Text="<%$ Resources: _Kartris, ContentText_None %>" /></b>&nbsp;
                                                <asp:LinkButton ID="lnkBtnChangeDownloadFile" runat="server" Text="<%$ Resources: _Kartris, FormButton_Change %>" />&nbsp;
                                            </asp:PlaceHolder>
                                            <_user:UploaderPopup ID="_UC_UploaderPopup" runat="server" />
                                            <asp:Literal ID="litFilePath" runat="server" Visible="false" />
                                            <asp:Literal ID="litOldFileName" runat="server" Visible="false" />
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </asp:PlaceHolder>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </span></li>
                </ul>
                    </div>
            
        </div>

        <asp:Literal ID="litVersionType" runat="server" Visible="false" />
        <asp:ListBox ID="lbxResult" runat="server" Visible="False"></asp:ListBox>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
<div class="submitbuttons topsubmitbuttons">
            <asp:ValidationSummary ID="valSummary" runat="server" ForeColor="" CssClass="valsummary"
                DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
        </div>