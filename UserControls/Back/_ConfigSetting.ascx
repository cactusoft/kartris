<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_ConfigSetting.ascx.vb"
    Inherits="_ConfigSetting" %>
<div id="page_config">
    <h1>
        <asp:Literal ID="litPageTitle" runat="server" Text='<%$ Resources:_Kartris, BackMenu_ConfigSettings %>'></asp:Literal></h1>
    <asp:UpdatePanel ID="updPanel" runat="server">
        <ContentTemplate>
            <div class="dropdownmenu2" id="configmenu">
                <asp:Menu ID="menConfig" runat="server" Orientation="Vertical">
                </asp:Menu>
            </div>
            <div>
                <asp:Literal ID="litConfigName" runat="server" Text=""></asp:Literal>
                <asp:RadioButtonList ID="lstRadioButtons" runat="server" AutoPostBack="True"
                    RepeatDirection="Horizontal">
                    <asp:ListItem Value="frontend." Text='<%$ Resources:_Kartris, ContentText_FrontEnd %>' />
                    <asp:ListItem Value="backend." Text='<%$ Resources:_Kartris, PageTitle_BackEnd %>' />
                    <asp:ListItem Value="general." Text='<%$ Resources:_Kartris, BackMenu_SearchAll %>' />
                    <asp:ListItem Value="" Selected="True">-</asp:ListItem>
                </asp:RadioButtonList>
                <asp:Panel ID="pnlFind" runat="server" DefaultButton="btnFind">
                    <div class="searchboxline">
                        <asp:LinkButton ID="btnNew" runat="server" Text='<%$ Resources:_Kartris, FormButton_New %>'
                            CssClass="linkbutton icon_new floatright" />
                        <asp:TextBox CssClass="longishtext" runat="server" ID="txtSearchStarting" MaxLength="100" />
                        <asp:DropDownList ID="ddlConfigFilter" runat="server">
                            <asp:ListItem Text="<%$ Resources:_Kartris, BackMenu_SearchAll %>" Value="a" Selected="True" />
                            <asp:ListItem Text="<%$ Resources:_Config, ContentText_ConfigImportant %>" Value="i" />
                        </asp:DropDownList>
                        <asp:Button ID="btnFind" runat="server" Text='<%$ Resources:_Kartris, FormButton_Search %>'
                            CssClass="button" />
                        <asp:Button ID="btnClear" runat="server" CssClass="button cancelbutton" Text='<%$ Resources:_Kartris, ContentText_Clear %>' />
                        </div>
                </asp:Panel>
                <asp:Panel ID="pnlNewSearch" runat="server" Visible="false">
                    <asp:LinkButton ID="btnNewSearch" runat="server" CssClass="linkbutton icon_edit"
                        Text='<%$ Resources:_Search, ContentText_NewSearch %>' />
                </asp:Panel>
            </div>
            <br />
            <div class="spacer">
            </div>
            <%--Update Error Message--%>
            <asp:PlaceHolder ID="phdMessageError" runat="server" Visible="false">
                <div class="errormessage">
                    <asp:Literal ID="litMessageError" runat="server" Text='<%$ Resources:_Kartris, ContentText_Error %>'></asp:Literal>
                </div>
            </asp:PlaceHolder>
            <asp:MultiView ID="mvwConfig" runat="server" ActiveViewIndex="0">
                <asp:View ID="viwMenu" runat="server">

                </asp:View>
                <asp:View ID="viwNoResult" runat="server">
                    <div id="noresults">
                        <asp:Literal ID="litNoResults" runat="server" Text='<%$ Resources:_Kartris, ContentText_NoResults %>'></asp:Literal>
                    </div>
                </asp:View>
                <asp:View ID="viwResult" runat="server">
                    <asp:GridView CssClass="kartristable" ID="gvwConfig" runat="server" AllowPaging="True"
                        AutoGenerateColumns="False" DataKeyNames="CFG_Name" AutoGenerateEditButton="False"
                        GridLines="None" PagerSettings-PageButtonCount="10" PageSize="10">
                        <Columns>
                            <asp:BoundField DataField="CFG_Name" HeaderText='<%$ Resources:_Kartris, ContentText_Name %>'
                                ItemStyle-CssClass="itemname">
                                <HeaderStyle />
                            </asp:BoundField>
                            <asp:TemplateField HeaderText='<%$ Resources:_Kartris, ContentText_Value %>' ItemStyle-CssClass="valuefield">
                                <HeaderStyle />
                                <ItemTemplate>
                                    <asp:Literal ID="litCFG_Value" runat="server" Text='<%# CkartrisDisplayFunctions.TruncateDescriptionBack(Eval("CFG_Value"), 50) %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField ItemStyle-CssClass="selectfield">
                                <ItemTemplate>
                                    <asp:LinkButton ID="selectbutton" runat="server" CommandName="select" CssClass="linkbutton icon_edit"
                                        Text='<%$ Resources:_Kartris, FormButton_Edit %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </asp:View>
                <asp:View ID="viwEdit" runat="server">
                    <%-- Back Link --%>
                    <asp:PlaceHolder runat="server" ID="phdBackLink">
                        <asp:LinkButton ID="lnkBtnBack" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>'
                            CssClass="linkbutton icon_back floatright" Style='margin-top: 20px;' CausesValidation="false"></asp:LinkButton>
                    </asp:PlaceHolder>
                    <div class="Kartris-DetailsView section_languagestrings">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <%--CFG_Name--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litHName" runat="server" Text='<%$ Resources:_Kartris, ContentText_Name %>'></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtCFG_Name" runat="server" MaxLength="100" />
                                    <asp:Literal ID="litCFG_Name" runat="server"></asp:Literal>
                                    <asp:RequiredFieldValidator ID="valRequiredName" runat="server" CssClass="error"
                                        ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                        ControlToValidate="txtCFG_Name" SetFocusOnError="True" ValidationGroup="CFG">
                                    </asp:RequiredFieldValidator>
                                    <asp:PlaceHolder ID="phdCheckChange" runat="server">
                                        <asp:LinkButton ID="lnkBtnCFG_CheckName" runat="server" CausesValidation="false"
                                            Text='<%$ Resources:_Kartris, FormButton_Check %>' />
                                        <asp:LinkButton ID="lnkBtnCFG_ChangeName" runat="server" CausesValidation="false"
                                            Visible="false" Text='<%$ Resources:_Kartris, FormButton_Change %>' />
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder ID="phdNameAlreadyExist" Visible="false" runat="server">
                                        <asp:Literal ID="litNewNameMsg" runat="server" Text='<%$ Resources:_Kartris, ContentText_AlreadyInUse %>' />
                                        <asp:LinkButton ID="lnkBtnViewConfigName" runat="server" Text='<%$ Resources:_Kartris, ContentText_ClickHere %>' />
                                    </asp:PlaceHolder>
                                    <asp:Literal ID="litPleaseEnterValue" runat="server" Visible="false" Text='<%$ Resources:_Kartris, ContentText_PleaseEnterValue %>' />
                                </span></li>
                                <%--CFG_Value--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litHValue" runat="server" Text='<%$ Resources:_Kartris, ContentText_Value %>'></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtCFG_Value" runat="server" Text='<%# Eval("CFG_Value") %>' MaxLength="255" />
                                    <%-- <asp:RequiredFieldValidator ID="valRequiredValue" runat="server" CssClass="error"
                                        ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                        ControlToValidate="txtCFG_Value" SetFocusOnError="True" ValidationGroup="CFG">
                                    </asp:RequiredFieldValidator>--%>
                                </span></li>
                                <%--CFG_DataType--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelDataType" runat="server" Text='<%$ Resources: _Config, FormLabel_DataType %>'></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:DropDownList ID="ddlCFG_DataType" runat="server">
                                    </asp:DropDownList>
                                    <asp:CompareValidator ID="valCompareDataType" runat="server" CssClass="error" ForeColor=""
                                        ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ControlToValidate="ddlCFG_DataType"
                                        SetFocusOnError="True" ValueToCompare="-" Operator="NotEqual" ValidationGroup="CFG" ></asp:CompareValidator>
                                </span></li>
                                <%--CFG_DisplayType--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelDisplayType" runat="server" Text='<%$ Resources: _Config, FormLabel_DisplayType %>'></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:DropDownList ID="ddlCFG_DisplayType" runat="server">
                                    </asp:DropDownList>
                                    <asp:CompareValidator ID="valCompareDisplayType" runat="server" CssClass="error"
                                        ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                        ControlToValidate="ddlCFG_DisplayType" SetFocusOnError="True" ValueToCompare="-"
                                        Operator="NotEqual" ValidationGroup="CFG" ></asp:CompareValidator>
                                </span></li>
                                <%--CFG_DisplayInfo--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelDisplayInfo" runat="server" Text='<%$ Resources: _Config, FormLabel_DisplayInfo %>'></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtCFG_DisplayInfo" runat="server" MaxLength="255" />
                                </span></li>
                                <%--CFG_DefaultValue--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litHDefaultValue" runat="server" Text='<%$ Resources: _Kartris, ContentText_DefaultValue %>'></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtCFG_DefaultValue" runat="server" MaxLength="255" />
                                </span></li>
                                <%--CFG_Description--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litHDesc" runat="server" Text='<%$ Resources: _Kartris, ContentText_Description %>'></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtCFG_Desc" runat="server" TextMode="MultiLine" Wrap="true" MaxLength="255" />
                                </span></li>
                                <%--CFG_VersionAdded--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litHVersionAdded" runat="server" Text='<%$ Resources: _Kartris, ContentText_VersionAdded %>'></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtCFG_VersionAdded" runat="server" MaxLength="8" />
                                    <asp:RegularExpressionValidator ID="valRegexVersionAdded" runat="server" Display="Dynamic"
                                        SetFocusOnError="true" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
                                        CssClass="error" ForeColor="" ControlToValidate="txtCFG_VersionAdded" ValidationGroup="CFG"
                                        ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                    <ajaxToolkit:FilteredTextBoxExtender ID="filVersionAdded" runat="server" TargetControlID="txtCFG_VersionAdded"
                                        FilterType="Numbers,Custom" ValidChars="." />
                                </span></li>
                                <%--CFG_Important--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextConfigImportant" runat="server" Text="<%$ Resources: _Config, ContentText_ConfigImportant %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:CheckBox ID="chkCFG_Important" runat="server" CssClass="checkbox" />
                                </span></li>
                            </ul>
                        </div>
                    </div>
                    <div class="spacer">
                    </div>
                    <%-- Save Button  --%>
                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                        <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:LinkButton ID="btnSave" runat="server" CausesValidation="True" ValidationGroup="CFG"
                                    Text='<%$ Resources: _Kartris, FormButton_Save %>' ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' CssClass="button savebutton"></asp:LinkButton>
                                <asp:LinkButton ID="btnCancel" runat="server" CausesValidation="False" CommandName="Cancel"
                                    ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                    Text='<%$ Resources: _Kartris, FormButton_Cancel %>' CssClass="button cancelbutton">
                                </asp:LinkButton>
                                <asp:ValidationSummary ID="valSummary" ValidationGroup="CFG"
                                            runat="server" forecolor="" CssClass="valsummary" DisplayMode="BulletList"
                                            HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                </asp:View>
                <asp:View ID="viwKartrisLimitation" runat="server">
                    <asp:Literal ID="litMessage" runat="server" />
                </asp:View>
            </asp:MultiView>
            
            <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
        </ContentTemplate>
    </asp:UpdatePanel>
    <asp:UpdateProgress ID="prgConfig" runat="server" AssociatedUpdatePanelID="updPanel">
        <ProgressTemplate>
            <div class="loadingimage">
            </div>
            <div class="updateprogress">
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>
</div>