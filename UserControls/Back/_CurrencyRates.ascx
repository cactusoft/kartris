<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_CurrencyRates.ascx.vb"
    Inherits="UserControls_Back_CurrencyRates" %>
<%@ Register TagPrefix="_user" TagName="LanguageContainer" Src="~/UserControls/Back/_LanguageContainer.ascx" %>
<asp:UpdatePanel ID="updCurrencyRates" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <div class="floatright">
            <asp:HyperLink ID="lnkLiveCurrencies" CssClass="linkbutton icon_edit" runat="server"
                NavigateUrl="~/Admin/_LiveCurrencies.aspx" Text="<%$ Resources:_Currency, PageTitle_LiveCurrencyRateUpdate %>"></asp:HyperLink>
        </div>
        <h1>
            <asp:Literal ID="litPageTitleCurrencies" runat="server" Text="<%$ Resources:_Currency, PageTitle_Currencies %>" /></h1>
        <asp:UpdatePanel ID="updCurrencyList" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:PlaceHolder ID="phdList" runat="server">
                    <asp:GridView CssClass="kartristable" ID="gvwCurrencies" runat="server" AllowSorting="true" AutoGenerateColumns="False"
                        AutoGenerateEditButton="False" GridLines="None" SelectedIndex="0" DataKeyNames="CUR_ID">
                        <FooterStyle />
                        <RowStyle />
                        <Columns>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                </HeaderTemplate>
                                <ItemStyle CssClass="recordnumberfield" />
                                <ItemTemplate>
                                    <asp:Literal ID="litDataItem" runat="server" Text='<%# Container.DataItemIndex + 1 %>' />
                                    <asp:Literal ID="litCUR_ID" runat="server" Text='<%# Eval("CUR_ID") %>' Visible="false" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <asp:Literal ID="litContentTextISOCode" runat="server" Text='<%$ Resources:_Currency, ContentText_ISOCode %>' />
                                </HeaderTemplate>
                                <ItemStyle CssClass="itemname" />
                                <ItemTemplate>
                                    <asp:Literal ID="litCUR_ISOCode" runat="server" Text='<%# Eval("CUR_ISOCode") %>' /><asp:Literal
                                        ID="litShowBaseCurrency" runat="server" Text='<%# ShowBaseCurrency(Eval("CUR_ID")) %>' />
                                </ItemTemplate>
                                <FooterTemplate>
                                </FooterTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <asp:Literal ID="litContentTextSymbol" runat="server" Text='<%$ Resources:_Currency, ContentText_Symbol %>' />
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:Literal ID="litCUR_Symbol" runat="server" Text='<%# Eval("CUR_Symbol") %>' />
                                </ItemTemplate>
                                <FooterTemplate>
                                </FooterTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <HeaderStyle />
                                <HeaderTemplate>
                                    <asp:Literal ID="litExchangeRate" runat="server" Text='<%$ Resources:_Currency, ContentText_ExchangeRate %>' />
                                </HeaderTemplate>
                                <ItemStyle />
                                <ItemTemplate>
                                    <asp:Literal ID="litCUR_ExchangeRate" runat="server" Text='<%# Eval("CUR_ExchangeRate") %>' />
                                </ItemTemplate>
                                <FooterTemplate>
                                </FooterTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <asp:Literal ID="litContentTextLive" runat="server" Text='<%$ Resources:_Kartris, ContentText_Live %>' />
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkLive" runat="server" Checked='<%# Eval("CUR_Live") %>' Enabled="false"
                                        CssClass="checkbox" />
                                </ItemTemplate>
                                <FooterTemplate>
                                </FooterTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField ItemStyle-CssClass="selectfield">
                                <HeaderTemplate>
                                    <asp:LinkButton ID="btnNew" runat="server" Text='<%$ Resources:_Kartris, FormButton_New %>'
                                        CommandName="CreateNewCurrency" CssClass="linkbutton icon_new floatright" />
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkBtnEditCurrency" runat="server" CommandName="select" CommandArgument='<%# Container.DataItemIndex %>'
                                        Text="<%$ Resources: _Kartris, FormButton_Edit %>" CssClass="linkbutton icon_edit" />
                                </ItemTemplate>
                                <FooterTemplate>
                                </FooterTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                    <asp:Literal ID="litBaseCurrency" runat="server" Text="<%$ Resources:_Currency, ContentText_BaseCurrencyExpl %>" />
                </asp:PlaceHolder>
            </ContentTemplate>
        </asp:UpdatePanel>
        <asp:UpdatePanel ID="updCurrency" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:Literal ID="litCurrencyID" runat="server" Visible="false" />
                <asp:PlaceHolder ID="phdCurrencyDetails" runat="server" Visible="false">
                    <!-- Language elements -->
                    <asp:UpdatePanel ID="updLanguageContainer" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:PlaceHolder ID="phdLanguages" runat="server">
                                <_user:LanguageContainer ID="_UC_LangContainer" runat="server" />
                            </asp:PlaceHolder>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    <div class="line">
                    </div>
                    <!-- Symbol, IsoCode, IsoNumeric and ExchangeRate -->
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextSymbol" runat="server" Text='<%$ Resources:_Currency, ContentText_Symbol %>' /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtSymbol" runat="server" CssClass="midtext" MaxLength="5" />
                                        <asp:RequiredFieldValidator ID="valRequiredSymbol" runat="server" CssClass="error"
                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ControlToValidate="txtSymbol" Display="Dynamic" /></span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextISOCode" runat="server" Text='<%$ Resources:_Currency, ContentText_ISOCode %>' /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtISOCode" runat="server" CssClass="shorttext" MaxLength="3" />
                                        <asp:RequiredFieldValidator ID="valRequiredCurrency" runat="server" CssClass="error"
                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ControlToValidate="txtISOCode" Display="Dynamic" /></span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextISOCodeNumeric" runat="server" Text='<%$ Resources:_Shipping, ContentText_ISOCodeNumeric %>' /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtIsoCodeNumeric" runat="server" CssClass="shorttext" MaxLength="3" />
                                        <asp:RequiredFieldValidator ID="valRequiredIsoNumeric" runat="server" CssClass="error"
                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ControlToValidate="txtIsoCodeNumeric" Display="Dynamic" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filIsoCodeNumeric" runat="server"
                                            TargetControlID="txtIsoCodeNumeric" FilterType="Numbers" />
                                    </span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextExchangeRate" runat="server" Text='<%$ Resources:_Currency, ContentText_ExchangeRate %>' /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtExchangeRate" runat="server" CssClass="midtext" MaxLength="10" />
                                        <asp:RequiredFieldValidator ID="valRequiredExchangeRate" runat="server" CssClass="error"
                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ControlToValidate="txtExchangeRate" Display="Dynamic" />
                                        <%-- <asp:CompareValidator ID="valCompareExchangeNotOne" runat="server" ErrorMessage="value can't be 1"
                                            ControlToValidate="txtExchangeRate" ValueToCompare="1" Operator="NotEqual" />--%></span></li>
                                <!-- Use Decimal Point -->
                                <li>
                                    <asp:UpdatePanel ID="updUseDecimal" runat="server" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <asp:CheckBox ID="chkUseDecimal" runat="server" Text="<%$ Resources:_Currency,ContentText_CurrencyDecimalFractions %>"
                                                CssClass="checkbox" AutoPostBack="true" />
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </li>
                                <!-- Live -->
                                <li>
                                    <asp:CheckBox ID="chkLive" runat="server" Text="<%$ Resources:_Kartris,ContentText_Live %>"
                                        CssClass="checkbox" /></li>
                                <!-- Format -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormat" runat="server" Text="<%$ Resources:_Currency,ContentText_CurrencyFormat %>" /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtFormat" runat="server" value="[symbol] [value]" MaxLength="20" />
                                        <asp:RequiredFieldValidator ID="valRequiredFormat" runat="server" CssClass="error"
                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ControlToValidate="txtFormat" Display="Dynamic" />
                                    </span></li>
                                <!-- ISO Format -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litIsoFormat" runat="server" Text="<%$ Resources:_Currency,ContentText_IsoCurrencyFormat %>" /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtIsoFormat" runat="server" value="[iso] [value]" MaxLength="20" />
                                        <asp:RequiredFieldValidator ID="valRequiredIsoFormat" runat="server" CssClass="error"
                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ControlToValidate="txtIsoFormat" Display="Dynamic" /></span></li>
                                <!-- Decimal Point -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litDecimalPoint" runat="server" Text="<%$ Resources:_Currency,ContentText_DecimalPoint %>" /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtDecimalPoint" runat="server" CssClass="shorttext" MaxLength="1"
                                            value="." />
                                        <asp:RequiredFieldValidator ID="valRequiredDecimalPoint" runat="server" CssClass="error"
                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ControlToValidate="txtDecimalPoint" Display="Dynamic" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filDecimalPoint" runat="server" TargetControlID="txtDecimalPoint"
                                            FilterType="LowercaseLetters,UppercaseLetters,Numbers" FilterMode="InvalidChars" />
                                    </span></li>
                                <!-- Round Numbers -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextRoundNumber" runat="server" Text="<%$ Resources:_Currency,ContentText_RoundNumber %>" /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtRoundNumbers" runat="server" CssClass="shorttext" MaxLength="1"
                                            value="2" />
                                        <asp:RequiredFieldValidator ID="valRequiredRoundNumbers" runat="server" CssClass="error"
                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            ControlToValidate="txtRoundNumbers" Display="Dynamic" />
                                        <!-- No Need to check if the value is byte, coz the max length is 1 -->
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filRoundNumbers" runat="server" TargetControlID="txtRoundNumbers"
                                            FilterType="Numbers" />
                                    </span></li>
                            </ul>
                        </div>
                    </div>
                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                        <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:LinkButton ID="lnkBtnSave" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                    ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' />
                                <asp:LinkButton ID="lnkBtnCancel" runat="server" CssClass="button cancelbutton" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                    ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                                <span class="floatright">
                                    <asp:LinkButton ID="lnkBtnDelete" CssClass="button deletebutton"
                                        runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>' ToolTip='<%$ Resources: _Kartris, FormButton_Delete %>' /></span><asp:ValidationSummary
                                            ID="valSummary" runat="server" ForeColor="" CssClass="valsummary" DisplayMode="BulletList"
                                            HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                </asp:PlaceHolder>
            </ContentTemplate>
        </asp:UpdatePanel>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgCurrencyRates" runat="server" AssociatedUpdatePanelID="updCurrencyRates">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
<_user:PopupMessage ID="_UC_PopupMsg" runat="server" />

