<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_LiveCurrencies.aspx.vb"
    Inherits="Admin_LiveCurrencies" MasterPageFile="~/Skins/Admin/Template.master" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="section_currencies">
    <asp:Literal ID="litMessage" runat="server" Visible="false" />
    
    <asp:PlaceHolder ID="phdMainContent" runat="server">
        <div class="floatright">
            <asp:HyperLink ID="lnkCurrencies" CssClass="linkbutton icon_edit" runat="server"
                NavigateUrl="~/Admin/_Currency.aspx" Text="<%$ Resources:_Currency, PageTitle_Currencies %>"></asp:HyperLink>
        </div>
        <h1>
            <asp:Literal ID="litPageTitleCurrencies" runat="server" Text="<%$ Resources:_Currency, PageTitle_Currencies %>" />:
            <span class="h1_light">
                <asp:Literal ID="litPageTitleLiveCurrencyRateUpdate" runat="server" Text="<%$ Resources: _Currency, PageTitle_LiveCurrencyRateUpdate %>" /></span>
        </h1>
        <p>
            <asp:Literal ID="litContentTextLiveCurrencyRateText" runat="server" Text="<%$ Resources: _Currency, ContentText_LiveCurrencyRateText %>" /></p>
        <br />
        <br />
        <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:PlaceHolder ID="phdCurrencies" runat="server" Visible="true">
                    <table class="kartristable">
                        <thead>
                            <tr>
                                <th>
                                    <asp:Literal ID="litContentTextCurrency" runat="server" Text="<%$ Resources: _Currency, ContentText_Currency %>" />
                                </th>
                                <th>
                                    <asp:Literal ID="litContentTextISOCode" runat="server" Text="<%$ Resources: _Currency, ContentText_ISOCode %>" />
                                </th>
                                <th>
                                    <asp:Literal ID="litContentTextCurrencyRate" runat="server" Text="<%$ Resources: _Currency, ContentText_CurrentRate %>" />
                                </th>
                                <th>
                                    <asp:Literal ID="litContentTextNewRate" runat="server" Text="<%$ Resources: _Currency, ContentText_NewRate %>" />
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptCurrencies" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td class="bold">
                                            <asp:Literal ID="litCurrencyID" runat="server" Text='<%# Eval("CurrencyID") %>' Visible="false" />
                                            <asp:CheckBox ID="chkIsDefault" runat="server" Checked='<%# Eval("IsDefault")%>' Visible="false" />
                                            <asp:Literal ID="litCurrencyName" runat="server" Text='<%# Eval("CurrencyName") %>' />
                                        </td>
                                        <td>
                                            <asp:Literal ID="litISOCode" runat="server" Text='<%# Eval("ISOCode") %>' />
                                        </td>
                                        <td>
                                            <asp:Literal ID="litCurrentRate" runat="server" Text='<%# Eval("CurrentRate") %>' />
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtNewRate" runat="server" Text='<%# Eval("NewRate") %>' CssClass="midtext" />
                                            <asp:RegularExpressionValidator ID="valRegexNewOld" runat="server" Display="Dynamic" SetFocusOnError="true"
                                                ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>" CssClass="error" ForeColor="" ControlToValidate="txtNewRate" 
                                                ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                            <ajaxToolkit:FilteredTextBoxExtender ID="filNewRate" runat="server" TargetControlID="txtNewRate"
                                                FilterType="Numbers, Custom" ValidChars=".," />
                                        </td>
                                    </tr>
                                </ItemTemplate>
                                <AlternatingItemTemplate>
                                    <tr class="Kartris-GridView-Alternate">
                                        <td class="itemname">
                                            <asp:Literal ID="litCurrencyID" runat="server" Text='<%# Eval("CurrencyID") %>' Visible="false" />
                                            <asp:CheckBox ID="chkIsDefault" runat="server" Checked='<%# Eval("IsDefault")%>' Visible="false" />
                                            <asp:Literal ID="litCurrencyName" runat="server" Text='<%# Eval("CurrencyName") %>' />
                                        </td>
                                        <td>
                                            <asp:Literal ID="litISOCode" runat="server" Text='<%# Eval("ISOCode") %>' />
                                        </td>
                                        <td>
                                            <asp:Literal ID="litCurrentRate" runat="server" Text='<%# Eval("CurrentRate") %>' />
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtNewRate" runat="server" Text='<%# Eval("NewRate") %>' CssClass="midtext" />
                                            <asp:RegularExpressionValidator ID="valRegexNewOld" runat="server" Display="Dynamic" SetFocusOnError="true"
                                                ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>" CssClass="error" ForeColor="" ControlToValidate="txtNewRate"
                                                ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                            <ajaxToolkit:FilteredTextBoxExtender ID="filNewRate" runat="server" TargetControlID="txtNewRate"
                                                FilterType="Numbers, Custom" ValidChars=".," />
                                        </td>
                                    </tr>
                                </AlternatingItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                        <asp:LinkButton ID="lnkUpdateCurrencies" runat="server" Text="<%$ Resources:_Kartris, FormButton_Save %>"
                            ToolTip="<%$ Resources: _Kartris, FormButton_Save %>" CssClass="button savebutton" />
                        
                    </div>
                    <div class="infomessage">
                        <p><asp:Literal ID="litContentTextLiveCurrencyRateNote2" runat="server" 
                            Text="International exchange rate information obtained from the <strong>European Central Bank</strong> - <a href='http://www.ecb.int'>www.ecb.int</a>"></asp:Literal></p>

                        <p><asp:Literal ID="litContentTextLiveCurrencyRateNote3" runat="server" 
                            Text="Bitcoin price from <strong>Bitpay</strong> - <a href='http://www.bitpay.com'>www.bitpay.com</a>"></asp:Literal></p>

                        <p>
                        <asp:Literal ID="litContentTextCurrencyHash" runat="server" Text="<%$ Resources: _Currency, ContentText_CurrencyHash %>" /></p>
                    </div>
                </asp:PlaceHolder>
                <asp:PlaceHolder ID="phdCurrenciesNotAccessible" runat="server">
                    <div class="errortext">
                        <asp:Literal ID="litContentTextLiveCurrenciesNotAccessible" runat="server" Text="<%$ Resources: _Kartris, ContentText_LiveCurrenciesNotAccessible %>" /></div>
                </asp:PlaceHolder>
            </ContentTemplate>
        </asp:UpdatePanel>
        <asp:UpdateProgress ID="prgMain" runat="server" AssociatedUpdatePanelID="updMain">
            <ProgressTemplate>
                <div class="loadingimage">
                </div>
                <div class="updateprogress">
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </asp:PlaceHolder>
    </div>
</asp:Content>
