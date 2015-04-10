<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_OptionGroups.ascx.vb"
    Inherits="_OptionGroups" %>
<%@ Register TagPrefix="_user" TagName="LanguageContent" Src="~/UserControls/Back/_LanguageContent.ascx" %>
<%@ Register TagPrefix="_user" TagName="LanguageContainer" Src="~/UserControls/Back/_LanguageContainer.ascx" %>
<%@ Import Namespace="CkartrisEnumerations" %>

<%-- Option Group Part --%>
<asp:UpdatePanel ID="updOptionGrpList" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:PlaceHolder ID="phdOptionGroups" runat="server">
                    <a class="linkbutton icon_back floatright" href="javascript:history.back()">
            <asp:Literal ID="litContentTextBackLink" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>' /></a><h1>
                <asp:Literal ID="litContentTextOptions" runat="server" Text='<%$ Resources: _Kartris, ContentText_Options %>' />:
                <span class="h1_light">
                    <asp:Literal ID="litPageTitleOptionGroups" runat="server" Text='<%$ Resources: _Options, PageTitle_OptionGroups %>' /></span></h1>

            <div id="searchboxrow">
                <div>
                    <asp:TextBox ID="txtSearch" runat="server" /><asp:Button ID="btnSearch" runat="server" Text="<%$ Resources:_Kartris, FormButton_Search %>"
                        CssClass="button" /><asp:Button ID="btnClear" runat="server" Text="<%$ Resources:_Kartris, ContentText_Clear %>"
                            CssClass="button cancelbutton" />
                </div>
            </div>
            <br />

            <asp:DataList CssClass="kartristable" ID="dtlOptionGroups" runat="server" DataKeyField="OPTG_ID">
                <AlternatingItemStyle CssClass="Kartris-GridView-Alternate" />
                <SelectedItemStyle CssClass="Kartris-DataList-SelectedItem" />
                <HeaderStyle CssClass="header" />
                <HeaderTemplate>
                    <%-- Group Pager --%>
                    <%-- Column Names --%>
                    <div class="floatright">
                        <asp:LinkButton ID="lnkNewOptionGroup" CssClass="linkbutton icon_new" runat="server"
                            Text="<%$ Resources: _Kartris, FormButton_New %>" CommandName="new" />
                    </div>
                    <div class="column_optionname">
                        <asp:Literal ID="litContentTextName" runat="server" Text='<%$ Resources: _Kartris, ContentText_Name %>'></asp:Literal></div>
                    <div class="column_displaytype">
                        <asp:Literal ID="litFormLabelOptionDisplayType" runat="server" Text='<%$ Resources: _Kartris, FormLabel_OptionDisplayType %>'></asp:Literal></div>
                </HeaderTemplate>
                <%-- Item --%>
                <ItemTemplate>
                    <div class="column_optionname">
                        <asp:Literal ID="litOptionGrpID" runat="server" Text='<%# Eval("OPTG_ID") %>' Visible="false"></asp:Literal>
                        <asp:LinkButton ID="lnkBtnGrpName" runat="server" Text='<%# Eval("OPTG_BackendName") %>'
                            CommandArgument='<%# Eval("OPTG_ID") %>' CommandName="edit" /></div>
                    <div class="column_displaytype">
                        <asp:Literal ID="litDisplay" runat="server" Text='<%# Eval("Display") %>' />
                        <asp:Literal ID="litDisplayType" runat="server" Text='<%# Eval("OPTG_OptionDisplayType") %>'
                            Visible="false" /></div>
                    <div class="floatright">
                        <asp:LinkButton ID="lnkBtnOptionValues" CssClass="linkbutton icon_edit normalweight"
                            runat="server" Text='<%$ Resources: _Options, ContentText_OptionValues %>' CommandArgument='<%# Eval("OPTG_ID") %>'
                            CommandName="optionvalues" />
                        <asp:LinkButton ID="lnkBtnGrpNameEdit" CssClass="linkbutton icon_edit" runat="server"
                            Text='<%$ Resources: _Kartris, FormButton_Edit %>' CommandArgument='<%# Eval("OPTG_ID") %>'
                            CommandName="edit" />
                    </div>
                </ItemTemplate>
                <%-- Selected Item --%>
                <SelectedItemTemplate>
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextName2" runat="server" Text='<%$ Resources: _Kartris, ContentText_Name %>'></asp:Literal></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litOptionGrpID" runat="server" Text='<%# Eval("OPTG_ID") %>' Visible="false"></asp:Literal>
                                        <asp:TextBox ID="txtBackEndName" runat="server" Text='<%# Eval("OPTG_BackendName") %>'
                                            MaxLength="50" />
                                        <asp:Literal ID="litBackEndName_Hidden" runat="server" Text='<%# Eval("OPTG_BackendName") %>' Visible="false"></asp:Literal>
                                        <asp:RequiredFieldValidator ID="validBackEndName" runat="server" SetFocusOnError="true"
                                            CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ControlToValidate="txtBackEndName" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.OptionGroups %>" /></span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelOptionDisplayType2" runat="server" Text='<%$ Resources: _Kartris, FormLabel_OptionDisplayType %>'></asp:Literal></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litDisplayType" runat="server" Text='<%# Eval("OPTG_OptionDisplayType") %>'
                                            Visible="false" />
                                        <asp:DropDownList ID="ddlDisplayType" runat="server">
                                            <asp:ListItem Text="DropDown" Value="d" />
                                            <asp:ListItem Text="List" Value="l" />
                                        </asp:DropDownList>
                                    </span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelOrderByValue2" runat="server" Text='<%$ Resources: _Kartris, FormLabel_OrderByValue %>'></asp:Literal></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtOrderByValue" runat="server" CssClass="shorttext" Text='<%# Eval("OPTG_DefOrderByValue") %>'
                                            MaxLength="5" />
                                        <asp:RequiredFieldValidator ID="valRequiredOrderByValue" runat="server" SetFocusOnError="true"
                                            Display="Dynamic" CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ControlToValidate="txtOrderByValue" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.OptionGroups %>" />
                                        <asp:CompareValidator ID="valCompareOrderByValue" runat="server" ControlToValidate="txtOrderByValue"
                                            Display="Dynamic" CssClass="error" ForeColor="" ErrorMessage="0-32767!" Operator="LessThanEqual"
                                            ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoByte %>" ValueToCompare="32767"
                                            Type="Integer" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.OptionGroups %>" SetFocusOnError="true" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filOrderByValue" runat="server" TargetControlID="txtOrderByValue"
                                            FilterType="Numbers" />
                                    </span></li>
                            </ul>
                        </div>
                    </div>
                    <div class="spacer">
                    </div>
                    <asp:UpdatePanel ID="updSelectGroup" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <_user:LanguageContainer ID="_UC_LangContainer_SelectedGrp" runat="server" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    <asp:UpdatePanel ID="updSaveOptGrp" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <div class="submitbuttons">
                                <asp:Button ID="lnkDeleteOptionGrp" runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>'
                                    CommandName="delete" CssClass="button floatright" />
                                <asp:Button ID="lnkSaveOptionGrp" runat="server" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                    CommandName="update" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.OptionGroups %>"
                                    CssClass="button" />
                                <asp:Button ID="lnkCancelOptionGrp" runat="server" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                    CommandName="cancel" CssClass="button cancelbutton" />
                                <asp:ValidationSummary ID="valSummary4" runat="server" ForeColor="" CssClass="valsummary" DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>"
                                        ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.OptionGroups %>" />
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </SelectedItemTemplate>
                <%-- Footer --%>
                <FooterStyle CssClass="Kartris-DataList-SelectedItem" />
                <FooterTemplate>
                    <asp:UpdatePanel ID="updFooterItem" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:Literal ID="litStatus" runat="server"></asp:Literal>
                            <asp:PlaceHolder ID="phdNewGrpItem" runat="server" Visible="false">
                                <div class="Kartris-DetailsView">
                                    <div class="Kartris-DetailsView-Data">
                                        <ul>
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Literal ID="litContentTextName2" runat="server" Text='<%$ Resources: _Kartris, ContentText_Name %>'></asp:Literal></span>
                                                <span class="Kartris-DetailsView-Value">
                                                    <asp:UpdatePanel ID="updBackEndName" runat="server" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:TextBox ID="txtBackEndName" runat="server" MaxLength="50" />
                                                            <asp:RequiredFieldValidator ID="valBackEndName" runat="server" SetFocusOnError="true"
                                                                CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                                ControlToValidate="txtBackEndName" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.OptionGroups %>" />
                                                        </ContentTemplate>
                                                    </asp:UpdatePanel>
                                                </span></li>
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Literal ID="litFormLabelOptionDisplayType2" runat="server" Text='<%$ Resources: _Kartris, FormLabel_OptionDisplayType %>'></asp:Literal></span>
                                                <span class="Kartris-DetailsView-Value">
                                                    <asp:UpdatePanel ID="updDisplayType" runat="server" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:DropDownList ID="ddlDisplayType" runat="server">
                                                                <asp:ListItem Text='<%$ Resources: _Kartris, ContentText_DropDownSelect %>' Value="0" />
                                                                <asp:ListItem Text="DropDown" Value="d" />
                                                                <asp:ListItem Text="List" Value="l" />
                                                            </asp:DropDownList>
                                                            <asp:CompareValidator ID="valCompareDisplayType" runat="server" CssClass="error"
                                                                ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                                ControlToValidate="ddlDisplayType" SetFocusOnError="True" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.OptionGroups %>"
                                                                ValueToCompare="0" Operator="NotEqual" />
                                                        </ContentTemplate>
                                                    </asp:UpdatePanel>
                                                </span></li>
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Literal ID="litFormLabelOrderByValue2" runat="server" Text='<%$ Resources: _Kartris, FormLabel_OrderByValue %>'></asp:Literal></span>
                                                <span class="Kartris-DetailsView-Value">
                                                    <asp:UpdatePanel ID="updOrderByValue" runat="server" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:TextBox ID="txtOrderByValue" runat="server" CssClass="shorttext" Text="0" MaxLength="5" />
                                                            <asp:RequiredFieldValidator ID="valOrderByValue" runat="server" SetFocusOnError="true"
                                                                CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                                ControlToValidate="txtOrderByValue" Display="Dynamic" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.OptionGroups %>" />
                                                            <asp:CompareValidator ID="valCompareOrderByValue" runat="server" ControlToValidate="txtOrderByValue"
                                                                Display="Dynamic" CssClass="error" ForeColor="" ErrorMessage="0-32767!" Operator="LessThanEqual"
                                                                ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoByte %>" ValueToCompare="32767"
                                                                Type="Integer" SetFocusOnError="true" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.OptionGroups %>" />
                                                            <ajaxToolkit:FilteredTextBoxExtender ID="filOrderByValue" runat="server" TargetControlID="txtOrderByValue"
                                                                FilterType="Numbers" />
                                                        </ContentTemplate>
                                                    </asp:UpdatePanel>
                                                </span></li>
                                        </ul>
                                    </div>
                                </div>
                                <div class="spacer">
                                </div>
                                <asp:UpdatePanel ID="updSelectGroup" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <_user:LanguageContainer ID="_UC_LangContainer_NewGrp" runat="server" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                                <asp:UpdatePanel ID="updSaveOptGrp" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <div class="submitbuttons">
                                            <asp:Button ID="lnkSaveNewOptGrp" runat="server" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                                CommandName="save" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.OptionGroups %>"
                                                CssClass="button" />
                                            <asp:Button ID="lnkCancelNewOptGrp" runat="server" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                                CommandName="cancel" CssClass="button cancelbutton" /><asp:ValidationSummary ID="valSummary"
                                                    runat="server" ForeColor="" CssClass="valsummary" DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>"
                                                    ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.OptionGroups %>" />
                                        </div>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="lnkSaveNewOptGrp" EventName="Click" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </asp:PlaceHolder>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    <asp:PlaceHolder ID="phdCreateNewOptionGrp" runat="server">
                        <asp:PlaceHolder ID="phdNoOptionGroups" runat="server" Visible="false">
                            <asp:Panel ID="pnlNoItems" runat="server" CssClass="noresults">
                                <asp:Literal ID="litNoItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>">
                                </asp:Literal>
                            </asp:Panel>
                        </asp:PlaceHolder>
                    </asp:PlaceHolder>
                </FooterTemplate>
            </asp:DataList>
        </asp:PlaceHolder>
        <asp:Literal ID="litGroupDisplayType" runat="server" Visible="false" />
    </ContentTemplate>
</asp:UpdatePanel>
<%-- Options Part --%>
<asp:UpdatePanel ID="updOptions" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:PlaceHolder ID="phdOptions" runat="server" Visible="false">
            <h1>
                <asp:Literal ID="litContentTextOptions2" runat="server" Text='<%$ Resources: _Kartris, ContentText_Options %>' />:
                <span class="h1_light">
                    <asp:Literal ID="litPageTitleOptionValues" runat="server" Text='<%$ Resources: _Options, ContentText_OptionValues %>' /></span></h1>
            <asp:Literal ID="litOptGrpID" runat="server" Visible="false" />
            <table>
                <asp:DataList CssClass="kartristable" ID="dtlOptions" runat="server" DataKeyField="OPT_ID">
                    <AlternatingItemStyle CssClass="Kartris-GridView-Alternate" />
                    <SelectedItemStyle CssClass="Kartris-DataList-SelectedItem" />
                    <HeaderStyle CssClass="header" />
                    <%-- Header --%>
                    <HeaderTemplate>
                        <div class="floatright">
                            <asp:LinkButton ID="lnkNewOption" CssClass="linkbutton icon_new" runat="server" Text="<%$ Resources: _Kartris, FormButton_New %>"
                                CommandName="new" />
                        </div>
                        <div class="column_optionname">
                            <asp:Literal ID="litContentTextName" runat="server" Text='<%$ Resources: _Kartris, ContentText_Name %>' /></div>
                        <div class="column_misc">
                            <asp:Literal ID="litContentTextLive" runat="server" Text='<%$ Resources: _Options, FormLabel_Selected %>' /></div>
                        <div class="column_misc">
                            <asp:Literal ID="litFormLabelPriceChange" runat="server" Text='<%$ Resources: _Options, FormLabel_PriceChange %>' /></div>
                        <div class="column_misc">
                            <asp:Literal ID="litFormLabelWeightChange" runat="server" Text='<%$ Resources: _Options, FormLabel_WeightChange %>' /></div>
                        <div class="column_misc">
                            <asp:Literal ID="litFormLabelOrderByValue" runat="server" Text='<%$ Resources: _Kartris, FormLabel_OrderByValue %>' /></div>
                    </HeaderTemplate>
                    <%-- Item --%>
                    <ItemTemplate>
                        <div class="floatright">
                            <asp:LinkButton ID="lnkBtnOptionValueEdit" CssClass="linkbutton icon_edit" runat="server"
                                Text='<%$ Resources: _Kartris, FormButton_Edit %>' CommandArgument='<%# Eval("OPT_ID") %>'
                                CommandName="edit" />
                        </div>
                        <div class="column_optionname">
                            <asp:Literal ID="litOptionID" runat="server" Text='<%# Eval("OPT_ID") %>' Visible="false" />
                            <asp:LinkButton ID="lnkOptionName" runat="server" Text='<%# Eval("OPT_Name") %>'
                                CommandName="edit" CommandArgument='<%# Eval("OPT_ID") %>' /></div>
                        <div class="column_misc">
                            <asp:Literal ID="litOPT_CheckBoxValue" runat="server" Text='<%# Eval("OPT_CheckBoxValue") %>' /></div>
                        <div class="column_misc">
                            <asp:Literal ID="litOPT_DefPriceChange" runat="server" Text='<%# Eval("OPT_DefPriceChange") %>' /></div>
                        <div class="column_misc">
                            <asp:Literal ID="litOPT_DefWeightChange" runat="server" Text='<%# Eval("OPT_DefWeightChange") %>' /></div>
                        <div class="column_misc">
                            <asp:Literal ID="litOPT_DefOrderByValue" runat="server" Text='<%# Eval("OPT_DefOrderByValue") %>' /></div>
                    </ItemTemplate>
                    <%-- Selected Item --%>
                    <SelectedItemTemplate>
                        <div class="Kartris-DetailsView">
                            <div class="Kartris-DetailsView-Data">
                                <ul>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litContentTextName" runat="server" Text='<%$ Resources: _Kartris, ContentText_Name %>' /></span>
                                        <span class="Kartris-DetailsView-Value">
                                            <asp:Literal ID="litOptionID" runat="server" Text='<%# Eval("OPT_ID") %>' Visible="false" /><asp:Literal
                                                ID="litOptionName" runat="server" Text='<%# Eval("OPT_Name") %>' /></span></li>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litContentTextLive" runat="server" Text='<%$ Resources: _Options, FormLabel_Selected %>' /></span>
                                        <span class="Kartris-DetailsView-Value">
                                            <asp:CheckBox ID="chkSelected" runat="server" Checked='<%# Eval("OPT_CheckBoxValue") %>'
                                                CssClass="checkbox" /></span></li>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litFormLabelPriceChange" runat="server" Text='<%$ Resources: _Options, FormLabel_PriceChange %>' /></span>
                                        <span class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtPriceChange" runat="server" Text='<%# Eval("OPT_DefPriceChange") %>'
                                                CssClass="shorttext" MaxLength="8" />
                                            <asp:Label ID="litNotNumericPrice" runat="server" Text="*" CssClass="error" Visible="false" />
                                            <asp:RequiredFieldValidator ID="valRequiredPriceChange" runat="server" CssClass="error"
                                                ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                Display="Dynamic" ControlToValidate="txtPriceChange" SetFocusOnError="true" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Options %>" />
                                            <asp:RegularExpressionValidator ID="valRegexPriceChange" runat="server" ControlToValidate="txtPriceChange"
                                                CssClass="error" Display="Dynamic" ErrorMessage="*" ForeColor="" SetFocusOnError="true"
                                                ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Options %>" ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                            <ajaxToolkit:FilteredTextBoxExtender ID="filPriceChange" runat="server" TargetControlID="txtPriceChange"
                                                FilterType="Numbers,Custom" ValidChars=".,-" />
                                        </span></li>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litFormLabelWeightChange" runat="server" Text='<%$ Resources: _Options, FormLabel_WeightChange %>' /></span>
                                        <span class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtWeightChange" runat="server" Text='<%# Eval("OPT_DefWeightChange") %>'
                                                CssClass="shorttext" MaxLength="8" />
                                            <asp:Label ID="litNotNumericWeight" runat="server" Text="*" CssClass="error" Visible="false" />
                                            <asp:RequiredFieldValidator ID="valRequiredWeightChange" runat="server" CssClass="error"
                                                ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                Display="Dynamic" ControlToValidate="txtWeightChange" SetFocusOnError="true"
                                                ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Options %>" />
                                            <asp:RegularExpressionValidator ID="valRegexWeight" runat="server" ControlToValidate="txtWeightChange"
                                                CssClass="error" Display="Dynamic" ErrorMessage="*" ForeColor="" SetFocusOnError="true"
                                                ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Options %>" ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                            <ajaxToolkit:FilteredTextBoxExtender ID="filWeightChange" runat="server" TargetControlID="txtWeightChange"
                                                FilterType="Numbers,Custom" ValidChars=".,-" />
                                        </span></li>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litFormLabelOrderByValue" runat="server" Text='<%$ Resources: _Kartris, FormLabel_OrderByValue %>' /></span>
                                        <span class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtOrderByValue" runat="server" Text='<%# Eval("OPT_DefOrderByValue") %>'
                                                CssClass="shorttext" MaxLength="5" />
                                            <asp:RequiredFieldValidator ID="valRequiredOrderByValue" runat="server" CssClass="error"
                                                ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                Display="Dynamic" ControlToValidate="txtOrderByValue" SetFocusOnError="true"
                                                ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Options %>" />
                                            <asp:CompareValidator ID="valCompareOrderByValue" runat="server" ControlToValidate="txtOrderByValue"
                                                Display="Dynamic" ErrorMessage="0-32767!" CssClass="error" ForeColor="" Operator="LessThanEqual"
                                                SetFocusOnError="true" ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoShort %>"
                                                ValueToCompare="32767" Type="Integer" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Options %>" />
                                            <ajaxToolkit:FilteredTextBoxExtender ID="filOrderByValue" runat="server" TargetControlID="txtOrderByValue"
                                                FilterType="Numbers" />
                                        </span></li>
                                </ul>
                            </div>
                        </div>
                        <div class="spacer">
                        </div>
                        <div>
                            <asp:UpdatePanel ID="updLanguageElements" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <_user:LanguageContainer ID="_UC_LangContainer_SelectedOption" runat="server" />
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                        <div class="spacer">
                        </div>
                        <div class="submitbuttons">
                            <asp:UpdatePanel ID="updSaveOptions" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:Button ID="lnkDeleteOption" runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>'
                                    CommandName="delete" CssClass="button floatright" />
                                    <asp:Button ID="lnkSave" runat="server" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                        CommandName="update" CommandArgument='<%# Eval("OPT_ID") %>' ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Options %>"
                                        CssClass="button" />
                                    <asp:Button ID="lnkCancel" runat="server" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                        CommandName="cancel" CssClass="button cancelbutton" /><asp:ValidationSummary ID="valSummary2"
                                            runat="server" ForeColor="" CssClass="valsummary" DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>"
                                            ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Options %>" />
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                    </SelectedItemTemplate>
                    <%-- Footer --%>
                    <FooterStyle CssClass="Kartris-DataList-SelectedItem" />
                    <FooterTemplate>
                        <asp:PlaceHolder ID="phdNewItem" runat="server" Visible="false">
                            <div class="Kartris-DetailsView">
                                <div class="Kartris-DetailsView-Data">
                                    <ul>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Literal ID="litContentTextName" runat="server" Text='<%$ Resources: _Kartris, ContentText_Name %>' /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:Literal ID="litNewOption" runat="server" Text="NewOption"></asp:Literal></span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Literal ID="litContentTextLive" runat="server" Text='<%$ Resources: _Options, FormLabel_Selected %>' /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:CheckBox ID="chkSelected" runat="server" CssClass="checkbox" /></span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Literal ID="litFormLabelPriceChange" runat="server" Text='<%$ Resources: _Options, FormLabel_PriceChange %>' /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:TextBox ID="txtPriceChange" runat="server" Text="0.0" CssClass="shorttext" MaxLength="8" />
                                                <asp:RequiredFieldValidator ID="valRequiredPriceChange" runat="server" CssClass="error"
                                                    ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                    Display="Dynamic" ControlToValidate="txtPriceChange" SetFocusOnError="true" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Options %>" />
                                                <asp:RegularExpressionValidator ID="valRegexPriceChange" runat="server" ControlToValidate="txtPriceChange"
                                                    CssClass="error" Display="Dynamic" ErrorMessage="*" ForeColor="" SetFocusOnError="true"
                                                    ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Options %>" ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                                <ajaxToolkit:FilteredTextBoxExtender ID="filPriceChange" runat="server" TargetControlID="txtPriceChange"
                                                    FilterType="Numbers,Custom" ValidChars=".,-" />
                                            </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Literal ID="litFormLabelWeightChange" runat="server" Text='<%$ Resources: _Options, FormLabel_WeightChange %>' /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:TextBox ID="txtWeightChange" runat="server" Text="0.0" CssClass="shorttext"
                                                    MaxLength="8" />
                                                <asp:RequiredFieldValidator ID="valRequiredWeightChange" runat="server" CssClass="error"
                                                    ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                    Display="Dynamic" ControlToValidate="txtWeightChange" SetFocusOnError="true"
                                                    ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Options %>" />
                                                <asp:RegularExpressionValidator ID="valRegexWeight" runat="server" ControlToValidate="txtWeightChange"
                                                    CssClass="error" Display="Dynamic" ErrorMessage="*" ForeColor="" SetFocusOnError="true"
                                                    ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Options %>" ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                                <ajaxToolkit:FilteredTextBoxExtender ID="filWeightChange" runat="server" TargetControlID="txtWeightChange"
                                                    FilterType="Numbers,Custom" ValidChars=".,-" />
                                            </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Literal ID="litFormLabelOrderByValue" runat="server" Text='<%$ Resources: _Kartris, FormLabel_OrderByValue %>' /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:TextBox ID="txtOrderByValue" runat="server" Text="0" CssClass="shorttext" MaxLength="5" />
                                                <asp:RequiredFieldValidator ID="valRequiredOrderByValue" runat="server" CssClass="error"
                                                    ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                    Display="Dynamic" ControlToValidate="txtOrderByValue" SetFocusOnError="true"
                                                    ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Options %>" />
                                                <asp:CompareValidator ID="valCompareOrderByValue" runat="server" ControlToValidate="txtOrderByValue"
                                                    Display="Dynamic" ErrorMessage="0-32767!" CssClass="error" ForeColor="" Operator="LessThanEqual"
                                                    SetFocusOnError="true" ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoShort %>"
                                                    ValueToCompare="32767" Type="Integer" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Options %>" />
                                                <ajaxToolkit:FilteredTextBoxExtender ID="filOrderByValue" runat="server" TargetControlID="txtOrderByValue"
                                                    FilterType="Numbers" />
                                            </span></li>
                                    </ul>
                                </div>
                            </div>
                            <div class="spacer">
                            </div>
                            <div>
                                <asp:UpdatePanel ID="updLanguagesNew" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <_user:LanguageContainer ID="_UC_LangContainer_NewOption" runat="server" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                            <div class="spacer">
                            </div>
                            <div class="submitbuttons">
                                <asp:UpdatePanel ID="updSaveOptions" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:Button ID="lnkSaveNew" runat="server" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                            CommandName="save" CommandArgument='<%# Eval("OPT_ID") %>' ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Options %>"
                                            CssClass="button" />
                                        <asp:Button ID="lnkCancelNew" runat="server" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                            CommandName="cancel" CssClass="button cancelbutton" /><asp:ValidationSummary ID="valSummary3"
                                                runat="server" ForeColor="" CssClass="valsummary" DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>"
                                                ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Options %>" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                        </asp:PlaceHolder>
                        <asp:PlaceHolder ID="phdNoOption" runat="server" Visible="false">
                            <div id="noresults">
                                <asp:Literal ID="litContentTextNoItemsFound" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" />
                            </div>
                        </asp:PlaceHolder>
                    </FooterTemplate>
                </asp:DataList>
            </table>
            <asp:HyperLink ID="lnkBack" CssClass="linkbutton icon_back" runat="server" NavigateUrl="~/Admin/_OptionGroups.aspx"
                Text='<%$ Resources: _Kartris, FormButton_Back %>'></asp:HyperLink>
            
        </asp:PlaceHolder>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdatePanel ID="updOperationResult" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Literal ID="litResult" runat="server"></asp:Literal>
    </ContentTemplate>
</asp:UpdatePanel>
<_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
<asp:Literal ID="litToDelete_Hidden" runat="server" Visible="false"></asp:Literal>