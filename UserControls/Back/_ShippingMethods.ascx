<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_ShippingMethods.ascx.vb"
    Inherits="UserControls_Back_ShippingMethods" %>
<%@ Register TagPrefix="_user" TagName="LanguageContainer" Src="~/UserControls/Back/_LanguageContainer.ascx" %>
<%@ Register TagPrefix="_user" TagName="ShippingRates" Src="~/UserControls/Back/_ShippingRates.ascx" %>
<%@ Import Namespace="CkartrisEnumerations" %>
<%@ Import Namespace="CkartrisDataManipulation" %>
<asp:UpdatePanel ID="updShippingMethodsList" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:PlaceHolder ID="phdMethodsList" runat="server">
            <div id="section_shippingmethods">
                <asp:LinkButton ID="lnkAddNewShippingMethod" runat="server" Text="<%$ Resources: _Kartris, FormButton_New %>"
                    CssClass="linkbutton icon_new floatright" />
                <asp:GridView CssClass="kartristable" ID="gvwShippingMethods" runat="server" AllowPaging="false" AllowSorting="true"
                    AutoGenerateColumns="False" DataKeyNames="SM_ID" AutoGenerateEditButton="False"
                    GridLines="None" PagerSettings-PageButtonCount="10" PageSize="10" SelectedIndex="-1">
                    <Columns>
                        <asp:TemplateField>
                            <HeaderTemplate>
                                <asp:Literal ID="litContentTextShippingMethod" runat="server" Text='<%$ Resources:_Shipping, ContentText_ShippingMethod %>' />
                            </HeaderTemplate>
                            <ItemStyle CssClass="itemname" />
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkEditSM" runat="server" Text='<%# Eval("SM_Name") %>' CommandName="EditShippingMethod"
                                    CommandArgument='<%# Container.DataItemIndex %>' />
                                <%-- litOrderBy used to hold the value of 'SM_OrderByValue' field .. to reduce the db calls --%>
                                <asp:Literal ID="litOrderBy" runat="server" Text='<%# Eval("SM_OrderByValue") %>'
                                    Visible="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <%-- Tax Band --%>
                        <asp:TemplateField>
                            <HeaderTemplate>
                                <asp:Literal ID="litContentTextTaxBand" runat="server" Text="<%$ Resources: _Version, FormLabel_TaxBand %>"></asp:Literal>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:HiddenField ID="hidTaxBand" runat="server" value='<%# Eval("SM_Tax") %>' />
                                <asp:Literal ID="litTaxBand" runat="server" Text='<%# TaxBLL.GetTaxRate(FixNullFromDB(Eval("SM_Tax"))) & "%" %>'></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <%-- Tax Band2 --%>
                        <asp:TemplateField>
                            <HeaderTemplate>
                                <asp:Literal ID="litContentTextTaxBand2" runat="server" Text="<%$ Resources: _Version, FormLabel_TaxBand %>"></asp:Literal>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:HiddenField ID="hidTaxBand2" runat="server" value='<%# Eval("SM_Tax2") %>' />
                                <asp:Literal ID="litTaxBand2" runat="server" Text='<%# TaxBLL.GetTaxRate(FixNullFromDB(Eval("SM_Tax2"))) & "%" %>'></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <HeaderTemplate>
                                <asp:Literal ID="litContentTextLive" runat="server" Text="<%$ Resources: _Kartris, ContentText_Live %>"></asp:Literal>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="chkLive" runat="server" Checked='<%# Eval("SM_Live") %>' CssClass="checkbox"
                                    Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-CssClass="selectfield">
                            <HeaderTemplate>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkBtnRates" runat="server" CommandName="ShowRates" CommandArgument='<%# Container.DataItemIndex %>'
                                    Text='<%$ Resources: _Shipping, ContentText_ShippingRates %>' CssClass="linkbutton icon_edit normalweight" />
                                <asp:LinkButton ID="lnkBtnEdit" runat="server" CommandName="EditShippingMethod" CommandArgument='<%# Container.DataItemIndex %>'
                                    Text='<%$ Resources: _Kartris, FormButton_Edit %>' CssClass="linkbutton icon_edit" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </asp:PlaceHolder>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdatePanel ID="updShippingMethodDetails" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:PlaceHolder ID="phdMethodDetails" runat="server">
            <asp:Literal ID="litShippingMethodID" runat="server" Visible="false" />
            <asp:MultiView ID="mvwShippingMethods" runat="server">
                <asp:View ID="viwShippingMethodEmpty" runat="server">
                </asp:View>
                <asp:View ID="viwShippingMethodInfo" runat="server">
                    <h2>
                        <asp:Literal ID="litShippingMethodNameInfo" runat="server" />
                    </h2>
                    <%-- Language Elements --%>
                    <div>
                        <asp:UpdatePanel ID="updLanguageContainer" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:PlaceHolder ID="phdLanguageContainer" runat="server">
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
                                <%-- Tax Band --%>
                                <% If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" Then%>
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
                                <% End If%>
                                <%-- Live --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelLive" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Live %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:CheckBox ID="chkShippingMethodLive" runat="server" CssClass="checkbox" />
                                </span></li>
                                <%-- Sort By --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelOrderByValue" runat="server" Text="<%$ Resources:_Kartris, FormLabel_OrderByValue %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtOrderBy" runat="server" CssClass="shorttext" MaxLength="3" />
                                    <asp:RequiredFieldValidator ID="valRequiredOrderBy" runat="server" CssClass="error"
                                        ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                        ControlToValidate="txtOrderBy" SetFocusOnError="true" Display="Dynamic" />
                                    <asp:CompareValidator ID="valCompareOrderBy" runat="server" ControlToValidate="txtOrderBy"
                                        Display="Dynamic" CssClass="error" ForeColor="" ErrorMessage="0-255!" Operator="LessThanEqual"
                                        ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoByte %>" ValueToCompare="255"
                                        Type="Integer" SetFocusOnError="true" />
                                    <ajaxToolkit:FilteredTextBoxExtender ID="filOrderBy" runat="server" FilterType="Numbers"
                                        TargetControlID="txtOrderBy" />
                                </span></li>
                            </ul>
                        </div>
                    </div>
                    <%-- Save Button  --%>
                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                        <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:LinkButton ID="lnkBtnSaveShippingMethod" runat="server" CssClass="button savebutton"
                                    Text='<%$ Resources: _Kartris, FormButton_Save %>' ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' />
                                <asp:LinkButton ID="lnkBtnCancelShippingMethod" runat="server" CssClass="button cancelbutton"
                                    Text='<%$ Resources: _Kartris, FormButton_Cancel %>' ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                                <span class="floatright">
                                    <asp:LinkButton ID="lnkBtnDeleteShippingMethod" CssClass="button deletebutton"
                                        runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>' ToolTip='<%$ Resources: _Kartris, FormButton_Delete %>' /></span>
                                <asp:ValidationSummary ID="valSummary" runat="server" CssClass="valsummary" DisplayMode="BulletList"
                                    ForeColor="" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                                <asp:PlaceHolder ID="phdDeleteButton" runat="server"></asp:PlaceHolder>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                </asp:View>
                <asp:View ID="viwShippingMethodRates" runat="server">
                    <asp:LinkButton ID="lnkBack" CssClass="linkbutton icon_back floatright" runat="server"
                        Text="<%$ Resources: _Kartris, ContentText_BackLink %>"></asp:LinkButton><h2>
                            <asp:Literal ID="litPageTitleShippingRates" runat="server" Text="<%$ Resources: _Shipping, PageTitle_ShippingRates %>" />:
                            <span class="h1_light">
                                <asp:Literal ID="litShippingMethodNameRates" runat="server" /></span>
                        </h2>
                    <asp:Repeater ID="rptShippingRateZones" runat="server">
                        <ItemTemplate>
                            <asp:Literal ID="litShippingZoneID" runat="server" Text='<%# Eval("S_ShippingZoneID") %>'
                                Visible="false" />
                            <_user:ShippingRates ID="_UC_ShippingRates" runat="server" On_UCEvent_DataUpdated="ShippingRatesUpdated" />
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Panel ID="pnlAddZone" runat="server">
                        <h2>
                            <asp:Literal ID="litContentText" runat="server" Text="<%$ Resources: _Shipping, ContentText_AddShippingZoneToMethod %>" /></h2>
                        <p>
                            <asp:Literal ID="litContentTextAddShippingZone1" runat="server" Text="<%$ Resources: _Shipping, ContentText_AddShippingZone1 %>" /><asp:Literal
                                ID="litContentTextAddShippingZone2" runat="server" Text="<%$ Resources: _Shipping, ContentText_AddShippingZone2 %>" /></p>
                        <div class="Kartris-DetailsView">
                            <div class="Kartris-DetailsView-Data">
                                <ul>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litContentTextZoneToAdd" runat="server" Text="<%$ Resources: _Shipping, ContentText_ZoneToAdd %>" /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:DropDownList ID="ddlShippingZonesToAdd" runat="server">
                                            </asp:DropDownList>
                                        </span></li>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litContentTextZoneToCopy" runat="server" Text="<%$ Resources: _Shipping, ContentText_ZoneToCopy %>" /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:DropDownList ID="ddlShippingZonesToCopy" runat="server">
                                            </asp:DropDownList>
                                        </span></li>
                                </ul>
                                <asp:UpdatePanel ID="updSaveZones" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:Button ID="btnAddZone" runat="server" CssClass="button" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                        ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                        </div>
                    </asp:Panel>
                </asp:View>
            </asp:MultiView>
        </asp:PlaceHolder>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </contenttemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="upgMain" runat="server" AssociatedUpdatePanelID="updMain">
    <progresstemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
