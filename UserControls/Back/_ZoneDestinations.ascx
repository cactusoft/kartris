<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_ZoneDestinations.ascx.vb"
    Inherits="UserControls_Back_ZoneDestinations" %>
<%@ Register TagPrefix="_user" TagName="LanguageContainer" Src="~/UserControls/Back/_LanguageContainer.ascx" %>
<%@ Import Namespace="CkartrisEnumerations" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:UpdateProgress ID="prgMain" runat="server" AssociatedUpdatePanelID="updMain">
            <ProgressTemplate>
                <div class="loadingimage">
                </div>
                <div class="updateprogress">
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
        <div id="section_shippingdestinations">
            <asp:Literal ID="litShippingZoneID" runat="server" Visible="false" />
            <asp:PlaceHolder ID="phdFiltersUC" runat="server">
                <asp:PlaceHolder ID="phdFilters" runat="server">
                    <asp:UpdatePanel ID="updFilters" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:Literal ID="litSelectedFilterType" runat="server" Visible="false" />
                            <asp:Literal ID="litSelectedFilterValue" runat="server" Visible="false" />
                            <asp:PlaceHolder ID="phdDestinationsFilter" runat="server">
                                <div class="Kartris-DetailsView">
                                    <div class="Kartris-DetailsView-Data toplinks">
                                        <ul>
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Literal ID="litDestFilterAlphabetical" runat="server" Text="<%$ Resources: _Destinations, ContentText_DestFilterAlphabetical %>" /></span><span
                                                    class="Kartris-DetailsView-Value"><asp:PlaceHolder ID="phdFilterByAlpha" runat="server">
                                                    </asp:PlaceHolder>
                                                </span></li>
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Literal ID="litContentTextDestFilterISO" runat="server" Text="<%$ Resources: _Destinations, ContentText_DestFilterISO %>" /></span><span
                                                    class="Kartris-DetailsView-Value">
                                                    <asp:PlaceHolder ID="phdFilterByISO" runat="server"></asp:PlaceHolder>
                                                </span></li>
                                            <asp:PlaceHolder ID="phdFilterZoneArea" runat="server">
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Literal ID="litContentTextDestFilterZones" runat="server" Text="<%$ Resources: _Destinations, ContentText_DestFilterZones %>" /></span><span
                                                        class="Kartris-DetailsView-Value">
                                                        <asp:PlaceHolder ID="phdFilterByZones" runat="server"></asp:PlaceHolder>
                                                    </span></li>
                                            </asp:PlaceHolder>
                                        </ul>
                                    </div>
                                </div>
                            </asp:PlaceHolder>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </asp:PlaceHolder>
            </asp:PlaceHolder>
            <asp:PlaceHolder ID="phdNoDestinations" runat="server" Visible="false">
                <p>
                    <asp:Literal ID="litContentTextNoItemsFound" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" /></p>
            </asp:PlaceHolder>
            <asp:DataList ID="dtlDestinations" CssClass="kartristable" runat="server">
                <AlternatingItemStyle CssClass="Kartris-GridView-Alternate" />
                <SelectedItemStyle CssClass="Kartris-DataList-SelectedItem" />
                <HeaderStyle CssClass="header" />
                <HeaderTemplate>
                    <div class="column0">
                        <asp:Literal ID="litID" runat="server" Text="ID" /></div>
                    <div class="column1">
                        <asp:Literal ID="litContentTextCountry" runat="server" Text="<%$ Resources: _Shipping, ContentText_Country %>" /></div>
                    <div class="column2">
                        <asp:Literal ID="litContentTextISOCode2Letters" runat="server" Text="<%$ Resources: _Shipping, ContentText_ISOCode2Letters %>" /></div>
                    <div class="column3">
                        <asp:Literal ID="litContentTextISOCode3Letters" runat="server" Text="<%$ Resources: _Shipping, ContentText_ISOCode3Letters %>" /></div>
                    <div class="column4">
                        <asp:Literal ID="litContentTextISOCodeNumeric" runat="server" Text="<%$ Resources: _Shipping, ContentText_ISOCodeNumeric %>" /></div>
                    <div class="column5">
                        <asp:Literal ID="litContentTextRegion" runat="server" Text="<%$ Resources: _Shipping, ContentText_Region %>" /></div>
                    <div class="column6">
                        <asp:Literal ID="litContentTextTax" runat="server" Text="<%$ Resources: _Version, ContentText_Tax %>" /></div>
                    <% If TaxRegime.DTax_Type2 <> "" Then%>
                        <div class="column7">
                            <asp:Literal ID="litContentTextTax2" runat="server" Text="<%$ Resources: _Version, ContentText_Tax %>" /></div>
                    <% End If%>
                    <div class="column8">
                        <asp:Literal ID="litContentTextLive" runat="server" Text="<%$ Resources: _Kartris, ContentText_Live %>" /></div>
                </HeaderTemplate>
                <ItemTemplate>
                    <div class="floatright">
                        <asp:UpdatePanel ID="updEditDestination2" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:LinkButton ID="lnkEdit" runat="server" Text='<%$ Resources: _Kartris, FormButton_Edit %>'
                                    CssClass="linkbutton icon_edit" CommandName="EditDestination" CommandArgument='<%# Eval("D_ID") %>' />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                    <div class="column0"><asp:Literal ID="litID" runat="server" Text='<%# Eval("D_ID") %>' Visible="true" /></div>
                    <div class="column1">
                        <asp:UpdatePanel ID="updEditDestination" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:LinkButton ID="lnkButtonDestinationName" runat="server" Text='<%# Eval("D_Name") %>'
                                    CssClass="linkButton" CommandName="EditDestination" CommandArgument='<%# Eval("D_ID") %>' />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                    <div class="column2">
                        <asp:Literal ID="litIsoCode" runat="server" Text='<%# Eval("D_IsoCode") %>' /></div>
                    <div class="column3">
                        <asp:Literal ID="litISOCode3Letter" runat="server" Text='<%# Eval("D_ISOCode3Letter") %>' /></div>
                    <div class="column4">
                        <asp:Literal ID="litISOCodeNumeric" runat="server" Text='<%# Eval("D_ISOCodeNumeric") %>' /></div>
                    <div class="column5">
                        <asp:Literal ID="litRegion" runat="server" Text='<%# Eval("D_Region") %>' />&nbsp;</div>
                    <div class="column6">
                        <% If TaxRegime.DTax_Type = "rate" Then%>
                        <asp:Literal ID="litTax" runat="server" Text='<%# Math.Round(Eval("D_Tax"),5) %>' />
                        <% Else%>
                        <asp:CheckBox ID="chkTax" runat="server" Checked='<%# Eval("D_Tax") = 1 %>' CssClass="checkbox"
                            Enabled="false" />
                        <% End If%>
                    </div>
                    <% If TaxRegime.DTax_Type2 <> "" Then%>
                        <div class="column7">
                            <% If TaxRegime.DTax_Type2 = "rate" Then%>
                            <asp:Literal ID="litTax2" runat="server" Text='<%#  IIF(CkartrisDataManipulation.FixNullFromDB(Eval("D_Tax2")) is nothing, "-", CkartrisDataManipulation.FixNullFromDB(Eval("D_Tax2"))) %>' />
                            <% Else%>
                            <asp:CheckBox ID="chkTax2" runat="server" Checked='<%# IIF(CkartrisDataManipulation.FixNullFromDB(Eval("D_Tax2")) is nothing, 0, CkartrisDataManipulation.FixNullFromDB(Eval("D_Tax2"))) = 1 %>' CssClass="checkbox"
                                Enabled="false" />
                            <% End If%>
                        </div>
                    <% End If%>
                    <div class="column8">
                        <asp:CheckBox ID="chkLive" runat="server" Checked='<%# Eval("D_Live") %>' CssClass="checkbox"
                            Enabled="false" /></div>
                </ItemTemplate>
                <SelectedItemTemplate>
                    <%-- Language Elements --%>
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
                                <!-- Destination ID, Shipping Zone -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextZone" runat="server" Text="<%$ Resources: _Shipping, ContentText_Zone %>" /></span><span
                                        class="Kartris-DetailsView-Value"><asp:Literal ID="litDestinationID" runat="server"
                                            Text='<%# Eval("D_ID") %>' Visible="false" />
                                        <asp:Literal ID="litDestinationZoneID" runat="server" Text='<%# Eval("D_ShippingZoneID") %>'
                                            Visible="false" />
                                        <asp:DropDownList ID="ddlShippingZone" runat="server" DataTextField="SZ_Name" DataValueField="SZ_ID">
                                        </asp:DropDownList>
                                    </span></li>
                                <!-- ISO Code -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextISOCode2Letters" runat="server" Text="<%$ Resources: _Shipping, ContentText_ISOCode2Letters %>" /></span><span
                                        class="Kartris-DetailsView-Value"><asp:TextBox ID="txtISOCode2Letters" runat="server"
                                            Text='<%# Eval("D_IsoCode") %>' CssClass="shorttext" MaxLength="2" />
                                        <asp:RequiredFieldValidator ID="valRequiredISO2Letters" runat="server" CssClass="error"
                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ControlToValidate="txtISOCode2Letters" Display="Dynamic" SetFocusOnError="true"
                                            ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Destination %>" />
                                    </span></li>
                                <!-- ISO Code 3 Letters -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextISOCode3Letters" runat="server" Text="<%$ Resources: _Shipping, ContentText_ISOCode3Letters %>" /></span><span
                                        class="Kartris-DetailsView-Value"><asp:TextBox ID="txtISOCode3Letters" runat="server"
                                            Text='<%# Eval("D_ISOCode3Letter") %>' CssClass="shorttext" MaxLength="3" />
                                        <asp:RequiredFieldValidator ID="valRequiredISO3Letters" runat="server" CssClass="error"
                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ControlToValidate="txtISOCode3Letters" Display="Dynamic" SetFocusOnError="true"
                                            ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Destination %>" />
                                    </span></li>
                                <!-- ISO Code Numeric -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextISOCodeNumeric" runat="server" Text="<%$ Resources: _Shipping, ContentText_ISOCodeNumeric %>" /></span><span
                                        class="Kartris-DetailsView-Value"><asp:TextBox ID="txtISONumeric" runat="server"
                                            Text='<%# Eval("D_ISOCodeNumeric") %>' CssClass="shorttext" MaxLength="3" />
                                        <asp:RequiredFieldValidator ID="valRequiredISONumeric" runat="server" CssClass="error"
                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ControlToValidate="txtISONumeric" Display="Dynamic" SetFocusOnError="true" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Destination %>" />
                                        <asp:CompareValidator ID="valCompareIsoNumeric" runat="server" ControlToValidate="txtISONumeric"
                                            Display="Dynamic" ErrorMessage="*" Operator="LessThanEqual" ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoShort %>"
                                            ValueToCompare="32767" Type="Integer" SetFocusOnError="true" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Destination %>" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filISONumeric" runat="server" TargetControlID="txtISONumeric"
                                            FilterMode="ValidChars" FilterType="Numbers" />
                                    </span></li>
                                <!-- Region -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextRegion" runat="server" Text="<%$ Resources: _Shipping, ContentText_Region %>" /></span><span
                                        class="Kartris-DetailsView-Value"><asp:TextBox ID="txtRegion" runat="server" Text='<%# Eval("D_Region") %>'
                                            CssClass="midtext" MaxLength="30" />
                                    </span></li>
                                <!-- Tax -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextTax" runat="server" Text="<%$ Resources: _Version, ContentText_Tax %>" /></span><span
                                        class="Kartris-DetailsView-Value">
                                        <% If TaxRegime.DTax_Type = "rate" Then%>
                                        <asp:TextBox ID="txtTax" runat="server" Text='<%# Math.Round(Eval("D_Tax"),5) %>' CssClass="shorttext"
                                            MaxLength="8" />
                                            <asp:Literal ID="litPercent" runat="server" Text="%" />
                                        <asp:RequiredFieldValidator ID="valRequiredTax" runat="server" CssClass="error" ForeColor=""
                                            ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ControlToValidate="txtTax"
                                            Display="Dynamic" SetFocusOnError="true" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Destination %>" />
<%--                                        <asp:RegularExpressionValidator ID="valRegexTax" runat="server" ControlToValidate="txtTax"
                                            CssClass="error" Display="Dynamic" ErrorMessage="*" ForeColor="" SetFocusOnError="true"
                                            ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Destination %>" ValidationExpression="<%$ AppSettings:PercentageRegex %>" />--%>
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filCompareTax" runat="server" TargetControlID="txtTax"
                                            FilterMode="ValidChars" FilterType="Numbers,Custom" ValidChars=".," />
                                        <% Else%>
                                        <asp:CheckBox ID="chkTax" runat="server" Checked='<%# Eval("D_Tax") = 1 %>' CssClass="checkbox" />
                                        <% End If%>
                                    </span></li>
                                    <% If TaxRegime.DTax_Type2 <> "" Then%>
                                        <!-- Tax2 -->
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Literal ID="litContentTextTax2" runat="server" Text="<%$ Resources: _Version, ContentText_Tax %>" /></span><span
                                                class="Kartris-DetailsView-Value">
                                                <% If TaxRegime.DTax_Type2 = "rate" Then%>
                                                <asp:TextBox ID="txtTax2" runat="server" Text='<%# IIF(CkartrisDataManipulation.FixNullFromDB(Eval("D_Tax2")) is nothing, 0, CkartrisDataManipulation.FixNullFromDB(Eval("D_Tax2"))) %>' CssClass="shorttext"
                                                    MaxLength="8" />
                                                <asp:RequiredFieldValidator ID="valRequiredTax2" runat="server" CssClass="error" ForeColor=""
                                                    ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ControlToValidate="txtTax2"
                                                    Display="Dynamic" SetFocusOnError="true" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Destination %>" />
                                                <asp:RegularExpressionValidator ID="valRegexTax2" runat="server" ControlToValidate="txtTax2"
                                                    CssClass="error" Display="Dynamic" ErrorMessage="*" ForeColor="" SetFocusOnError="true"
                                                    ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Destination %>" ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                                <ajaxToolkit:FilteredTextBoxExtender ID="filCompareTax2" runat="server" TargetControlID="txtTax2"
                                                    FilterMode="ValidChars" FilterType="Numbers,Custom" ValidChars=".," />
                                                <% Else%>
                                                <asp:CheckBox ID="chkTax2" runat="server" Checked='<%# IIF(CkartrisDataManipulation.FixNullFromDB(Eval("D_Tax2")) is nothing, 0, CkartrisDataManipulation.FixNullFromDB(Eval("D_Tax2"))) = 1 %>' CssClass="checkbox" />
                                                <% End If%>
                                            </span></li>
                                    <% End If%>
                                <!-- Live -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextLive" runat="server" Text="<%$ Resources: _Kartris, ContentText_Live %>" /></span><span
                                        class="Kartris-DetailsView-Value"><asp:CheckBox ID="chkLive" runat="server" Checked='<%# Eval("D_Live") %>'
                                            CssClass="checkbox" /></span></li>
                            </ul>
                        </div>
                    </div>
                    <%-- Save Button  --%>
                    <div class="submitbuttons">
                        <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:Button ID="lnkBtnSaveDestination" runat="server" CssClass="button" CommandName="SaveDestination"
                                    CommandArgument='<%# Eval("D_ID") %>' Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                    ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Destination %>" />
                                <asp:Button ID="lnkBtnCancelDestination" runat="server" CssClass="button cancelbutton"
                                    CommandName="CancelDestination" Text='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                                <asp:ValidationSummary ID="valSummary" ValidationGroup="<%# LANG_ELEM_TABLE_TYPE.Destination %>"
                                    runat="server" ForeColor="" CssClass="valsummary" DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                </SelectedItemTemplate>
            </asp:DataList>
        </div>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
