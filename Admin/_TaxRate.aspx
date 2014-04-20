<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_taxrate.aspx.vb" Inherits="Admin_Taxrate"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <h1>
        <asp:Literal ID="litPageTitleTaxRates" runat="server" Text="<%$ Resources: _Kartris, PageTitle_TaxRates %>" /></h1>
    <asp:MultiView ID="mvwTax" runat="server" ActiveViewIndex="0">
        <asp:View ID="viwTaxRates" runat="server">
            <asp:UpdatePanel ID="updTaxRates" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <table class="kartristable">
                        <thead>
                            <tr>
                                <th>
                                    <asp:Literal ID="litFormLabelTaxBand" runat="server" Text="<%$ Resources:_Version, FormLabel_TaxBand %>" />
                                </th>
                                <th>
                                    &nbsp;
                                </th>
                                <th>
                                    QuickBooks Tax RefCode
                                </th>
                            </tr>
                        </thead>
                        <asp:Repeater ID="rptTaxRate" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td class="idfield">
                                        <asp:Literal ID="litTaxRateID" runat="server" Text='<%# Eval("T_ID") %>' />
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtTaxRate" runat="server" Text='<%# Eval("T_Taxrate") %>' CssClass="shorttext"
                                            MaxLength="8" />
                                        <asp:Literal ID="litPercentSign" runat="server" Text="%" />
                                        <asp:RequiredFieldValidator ID="ReqValid" runat="server" CssClass="error" ForeColor=""
                                            ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ControlToValidate="txtTaxRate" />
                                        <asp:RegularExpressionValidator ID="valRegexTaxRate" runat="server" Display="Dynamic"
                                            SetFocusOnError="true" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
                                            CssClass="error" ForeColor="" ControlToValidate="txtTaxRate" ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filTaxRate" runat="server" TargetControlID="txtTaxRate"
                                            FilterType="Numbers, Custom" ValidChars=".," />
                                        
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtQBRefCode" runat="server" Text='<%# Eval("T_QBRefCode") %>' CssClass="mediumtext"
                                            MaxLength="50" />
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <AlternatingItemTemplate>
                                <tr class="Kartris-GridView-Alternate">
                                    <td class="idfield">
                                        <asp:Literal ID="litTaxRateID" runat="server" Text='<%# Eval("T_ID") %>' />
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtTaxRate" runat="server" Text='<%# Eval("T_Taxrate") %>' CssClass="shorttext"
                                            MaxLength="8" />
                                        <asp:Literal ID="litPercentSign" runat="server" Text="%" />
                                        <asp:RequiredFieldValidator ID="ReqValid" runat="server" CssClass="error" ForeColor=""
                                            ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ControlToValidate="txtTaxRate" />
                                        <asp:RegularExpressionValidator ID="valRegexTaxRate" runat="server" Display="Dynamic"
                                            SetFocusOnError="true" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
                                            CssClass="error" ForeColor="" ControlToValidate="txtTaxRate" ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filTaxRate" runat="server" TargetControlID="txtTaxRate"
                                            FilterType="Numbers, Custom" ValidChars=".," />
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtQBRefCode" runat="server" Text='<%# Eval("T_QBRefCode") %>' CssClass="mediumtext"
                                            MaxLength="50" />
                                    </td>
                                </tr>
                            </AlternatingItemTemplate>
                        </asp:Repeater>
                    </table>
                    <asp:UpdateProgress ID="prgTaxRates" runat="server" AssociatedUpdatePanelID="updTaxRates">
                        <ProgressTemplate>
                            <div class="loadingimage">
                            </div>
                            <div class="updateprogress">
                            </div>
                        </ProgressTemplate>
                    </asp:UpdateProgress>
                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                        <asp:LinkButton ID="btnUpdateTaxes" runat="server" CssClass="button savebutton" Text="<%$ Resources:_Kartris, FormButton_Save %>"
                            ToolTip="<%$ Resources:_Kartris, FormButton_Save %>" />
                        <asp:ValidationSummary ID="valSummary" runat="server" CssClass="valsummary" DisplayMode="BulletList"
                            ForeColor="" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </asp:View>
        <asp:View ID="viwMultistateTax" runat="server">
            <p><asp:Literal ID="litUSSimpleTax" runat="server" Text="<%$ Resources: _Kartris, ContentText_USmultistateTaxIsUsed %>" /></p>
        </asp:View>
    </asp:MultiView>
    <_user:PopupMessage runat="server" ID="_UC_PopupMsg" />
</asp:Content>
