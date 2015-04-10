<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_ProductOptions.ascx.vb" Inherits="_ProductOptions" %>
<%@ Register TagPrefix="_user" TagName="ItemSelection" Src="~/UserControls/Back/_ItemSelection.ascx"  %>

<asp:Literal ID="litProductID" runat="server" Visible="false" />
<asp:Literal ID="litOptGrpID" runat="server" Visible="false" />
<table class="kartristable nested" id="tab_<asp:Literal ID='litOptGrpID2' runat='server' />">
<asp:Repeater ID="rptOptions" runat="server">
    <ItemTemplate>
        <tr class="Kartris-GridView-Alternate">
            <td class="indent" >
                <asp:Literal ID="litOptionID" runat="server" Text='<%# Eval("OPT_ID") %>' Visible="false" />
                <asp:Literal ID="litOptionGroupDisplayType" runat="server" Text='<%# Eval("OPTG_OptionDisplayType") %>'
                    Visible="false"></asp:Literal>
                <_user:ItemSelection ID="_UC_ItemSelection" Checked='<%# Eval("ExistInTheProduct") %>'
                    ItemNo='<%# Container.ItemIndex %>' runat="server" AutoPostBack="False" />
                <%--OnItemSelectionChanged="ItemSelectionChanged"--%>
                <asp:LinkButton ID="lnkOptionName" runat="server" Text='<%# Eval("OPT_Name") %>'
                    CommandName="select" CommandArgument='<%# Eval("OPT_ID") %>' />
            </td>
            <td class="optionsfield">
                <asp:Panel ID="pnlOptions" runat="server" Enabled='<%# Eval("ExistInTheProduct") %>'>
                    <div class="optionsfield">
                        &nbsp;</div>
                    <!-- Order By -->
                    <div class="optionsfield">
                        <asp:TextBox ID="txtOptOrderBy" runat="server" Text='<%# iif(CkartrisDataManipulation.FixNullFromDB(Eval("OPT_DefOrderByValue")) IsNot Nothing, Eval("OPT_DefOrderByValue"), "0") %>'
                            Enabled="true" MaxLength="5" />
                        <asp:RequiredFieldValidator ID="valRequiredOptOrderBy" runat="server" ControlToValidate="txtOptOrderBy"
                            CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                            ValidationGroup="ProductOptions" SetFocusOnError="true" Display="Dynamic" />
                        <asp:CompareValidator ID="compareValidatorOptOrderBy" runat="server" ControlToValidate="txtOptOrderBy"
                            CssClass="error" ForeColor="" Display="Dynamic" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
                            Operator="LessThanEqual" SetFocusOnError="true" ValidationGroup="ProductOptions"
                            ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoShort %>" ValueToCompare="32767"
                            Type="Integer" />
                        <ajaxToolkit:FilteredTextBoxExtender ID="FilteredtxtOptOrderBy" runat="server" TargetControlID="txtOptOrderBy"
                            FilterType="Numbers" />
                    </div>
                    <!-- Weight Change -->
                    <div class="optionsfield">
                        <asp:TextBox ID="txtOptWeightChange" runat="server" Text='<%# iif(CkartrisDataManipulation.FixNullFromDB(Eval("OPT_DefWeightChange")) IsNot Nothing, Eval("OPT_DefWeightChange"), "0") %>'
                            Enabled="true" MaxLength="8" />
                        <asp:RequiredFieldValidator ID="valRequiredOptWeightChange" runat="server" ControlToValidate="txtOptWeightChange"
                            CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                            ValidationGroup="ProductOptions" Display="Dynamic" />
                        <asp:RegularExpressionValidator ID="valRegexWeightChange" runat="server" ControlToValidate="txtOptWeightChange"
                            CssClass="error" Display="Dynamic" ErrorMessage="*" ForeColor="" SetFocusOnError="true"
                            ValidationGroup="ProductOptions" ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                        <ajaxToolkit:FilteredTextBoxExtender ID="FilteredtxtOptWeightChange" runat="server"
                            TargetControlID="txtOptWeightChange" FilterType="Numbers,Custom" ValidChars=".,-" />
                    </div>
                    <!-- Price Change -->
                    <div class="optionsfield">
                        <asp:TextBox ID="txtOptPriceChange" runat="server" Text='<%# iif(CkartrisDataManipulation.FixNullFromDB(Eval("OPT_DefPriceChange")) IsNot Nothing, Eval("OPT_DefPriceChange"), "0") %>'
                            Enabled="true" MaxLength="8" />
                        <asp:RequiredFieldValidator ID="valRequiredOptPriceChange" runat="server" ControlToValidate="txtOptPriceChange"
                            CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                            ValidationGroup="ProductOptions" Display="Dynamic" />
                        <asp:RegularExpressionValidator ID="valRegexPriceChange" runat="server" ControlToValidate="txtOptPriceChange"
                            CssClass="error" Display="Dynamic" ErrorMessage="*" ForeColor="" SetFocusOnError="true"
                            ValidationGroup="ProductOptions" ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                        <ajaxToolkit:FilteredTextBoxExtender ID="FilteredtxtOptPriceChange" runat="server"
                            TargetControlID="txtOptPriceChange" FilterType="Numbers,Custom" ValidChars=".,-" />
                    </div>
                    <!-- Option Selected -->
                    <div class="optionsfield">
                        <asp:RadioButton ID="btnOptSelected" runat="server" Checked='<%# Eval("OPT_CheckBoxValue") %>'
                            AutoPostBack="true" OnCheckedChanged="RadioChanged" Enabled="true" CssClass="checkbox" />
                        <asp:CheckBox ID="chkOptSelected" runat="server" Checked='<%# Eval("OPT_CheckBoxValue") %>'
                            Enabled="true" Visible="false" CssClass="checkbox" />
                    </div>
                </asp:Panel>
            </td>
        </tr>
    </ItemTemplate>
</asp:Repeater>
</table>