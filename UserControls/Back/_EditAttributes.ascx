<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_EditAttributes.ascx.vb"
    Inherits="UserControls_Back_EditAttributes" %>
<%@ Register TagPrefix="_user" TagName="LanguageContainer" Src="~/UserControls/Back/_LanguageContainer.ascx" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Literal ID="litAttributeID" runat="server" Text="0" Visible="false" />
        <!-- Language String -->
        <asp:UpdatePanel ID="updLanguageContainer" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:PlaceHolder ID="phdLanguageContainer" runat="server">
                    <_user:LanguageContainer ID="_UC_LangContainer" runat="server" />
                </asp:PlaceHolder>
            </ContentTemplate>
        </asp:UpdatePanel>
        <div class="line">
        </div>
        <div class="Kartris-DetailsView">
            <div class="Kartris-DetailsView-Data">
                <ul>
                    <!-- Live -->
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litFormLabelLive" runat="server" Text='<%$ Resources: _Kartris, FormLabel_Live %>' /></span><span
                            class="Kartris-DetailsView-Value">
                            <asp:CheckBox ID="chkLive" runat="server" CssClass="checkbox" /></span></li>
                    <!-- Attribute type -->
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litFormLabelAttributeType" runat="server" Text='<%$ Resources: _Attributes, FormLabel_AttributeType %>' /></span><span
                            class="Kartris-DetailsView-Value">
                            <asp:DropDownList ID="ddlAttributeType" runat="server" Enabled="true">
                                <asp:ListItem Text='<%$ Resources: _Kartris, ContentText_DropDownSelect %>' Value="0" />
                                <asp:ListItem Text='<%$ Resources: _Attributes, FormLabel_AttributeTypeText %>' Value="t" Selected="True" />
                                <asp:ListItem Text='<%$ Resources: _Attributes, FormLabel_AttributeTypeDropdown %>' Value="d" Enabled="false" />
                                <asp:ListItem Text='<%$ Resources: _Attributes, FormLabel_AttributeTypeCheckbox %>' Value="c" />
                            </asp:DropDownList>
                            <asp:CompareValidator ID="valCompareAttributeType" runat="server" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                CssClass="error" ForeColor="" ControlToValidate="ddlAttributeType" Operator="NotEqual"
                                ValueToCompare="0" /></span></li>
                    <!-- Google Feed Special -->
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litSpecialUse" runat="server" Text='<%$ Resources: _Attributes, FormLabel_SpecialUse %>' /></span><span
                            class="Kartris-DetailsView-Value">
                            <asp:CheckBox ID="chkGoogleSpecial" runat="server" CssClass="checkbox" AutoPostBack="true" /></span></li>
                    <asp:UpdatePanel ID="updOptions" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:MultiView ID="mvwOptions" runat="server" ActiveViewIndex="0">
                                <asp:View ID="viwNotGoogleSpecial" runat="server">
                                    <!-- Show in product page -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litFormLabelShowFrontEnd" runat="server" Text='<%$ Resources: _Attributes, FormLabel_ShowFrontend %>' /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:CheckBox ID="chkShowInProductPage" runat="server" CssClass="checkbox" /></span></li>
                                    <!-- Show on search -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litFormLabelShowSearch" runat="server" Text='<%$ Resources: _Attributes, FormLabel_ShowSearch %>' /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:CheckBox ID="chkShowOnSearch" runat="server" CssClass="checkbox" /></span></li>
                                    <!-- Show on comparison table -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litFormLabelCompare" runat="server" Text='<%$ Resources: _Attributes, FormLabel_Compare %>' /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:DropDownList ID="ddlCompare" runat="server">
                                                <asp:ListItem Text='<%$ Resources: _Kartris, ContentText_DropDownSelect %>' Value="0" />
                                                <asp:ListItem Text='<%$ Resources: _Attributes, FormLabel_CompareAlways %>' Value="a" />
                                                <asp:ListItem Text='<%$ Resources: _Attributes, FormLabel_CompareEvery %>' Value="e" />
                                                <asp:ListItem Text='<%$ Resources: _Attributes, FormLabel_CompareOne %>' Value="o" />
                                                <asp:ListItem Text='<%$ Resources: _Attributes, FormLabel_CompareNever %>' Value="n" />
                                            </asp:DropDownList>
                                            <asp:CompareValidator ID="valCompareAttributeType2" runat="server" CssClass="error"
                                                ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                ControlToValidate="ddlCompare" Operator="NotEqual" ValueToCompare="0" /></span></li>
                                    <!-- Sort by value -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litFormLabelOrderByValue" runat="server" Text='<%$ Resources: _Kartris, FormLabel_OrderByValue %>' /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtSortByValue" runat="server" Text="0" CssClass="shorttext" MaxLength="3" />
                                            <asp:RequiredFieldValidator ID="valRequiredOrderByValue" runat="server" CssClass="error"
                                                ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                ControlToValidate="txtSortByValue" Display="Dynamic" />
                                            <asp:CompareValidator ID="valCompareSort" runat="server" ErrorMessage="0-255!" CssClass="error"
                                                ForeColor="" ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoByte %> " ControlToValidate="txtSortByValue"
                                                Operator="LessThanEqual" ValueToCompare="255" Type="Integer" Display="Dynamic" />
                                            <ajaxToolkit:FilteredTextBoxExtender ID="filSortByValue" runat="server" TargetControlID="txtSortByValue"
                                                FilterType="Numbers" />
                                        </span></li>
                                </asp:View>
                                <asp:View ID="viwGoogleSpecial" runat="server">
                                    <div class="infomessage">
                                        <asp:Literal ID="Literal2" runat="server" Text="<%$ Resources: _Attributes, ContentText_SpecialUseNote %>" />
                                    </div>
                                </asp:View>
                            </asp:MultiView>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </ul>
            </div>
        </div>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>

