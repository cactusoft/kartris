<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_CreateOrder.ascx.vb" Inherits="UserControls_Back_CreateOrder" %>
<%@ Register TagPrefix="_user" TagName="CustomerOrder" Src="~/UserControls/Front/CustomerOrder.ascx" %>
<%@ Register TagPrefix="_user" TagName="BasketView" Src="~/UserControls/Back/_BasketView.ascx" %>
<%@ Register TagPrefix="_user" TagName="CustomerAddress" Src="~/UserControls/General/CustomerAddress.ascx" %>
<%@ Register TagPrefix="_user" TagName="CheckoutAddressPopup" Src="~/UserControls/Front/CheckoutAddressPopup.ascx" %>
<%@ Register TagPrefix="_user" TagName="AutoComplete" Src="~/UserControls/Back/_AutoCompleteInput.ascx" %>
<%@ Register TagPrefix="_user" TagName="OptionsPopup" Src="~/UserControls/Back/_OptionsPopup.ascx" %>
<asp:UpdatePanel ID="updEditOrder" runat="server" UpdateMode="Conditional">
    <ContentTemplate>

        <div class="leftcolumn">
            <div class="Kartris-DetailsView">
                <div class="Kartris-DetailsView-Data">
                    <ul>
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Label ID="lblOrderCustomerEmail" runat="server" Text="<%$ Resources: _Kartris, ContentText_Email %>" /></span>
                            <span class="Kartris-DetailsView-Value">
                                <asp:TextBox ID="txtOrderCustomerEmail" runat="server" AutoPostBack="true"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="valEmailAddress1" runat="server" ControlToValidate="txtOrderCustomerEmail"
                                    Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                    CssClass="error" ForeColor="" />
                                <asp:RegularExpressionValidator ID="valEmailAddress2" runat="server" ControlToValidate="txtOrderCustomerEmail"
                                    Display="Dynamic" ErrorMessage="<%$ Resources: Kartris, ContentText_BadEmail %>"
                                    ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="error"
                                    ForeColor="" />
                            </span></li>
                        <asp:PlaceHolder runat="server" ID="phdExistingCustomer" Visible="false">
                            <li><span class="Kartris-DetailsView-Name">
                                <asp:Label ID="lblOrderCustomerID" runat="server" Text="<%$ Resources: _Customers, FormLabel_CustomerID %>" /></span>
                                <span class="Kartris-DetailsView-Value">
                                    <asp:Literal ID="litOrderCustomerID" runat="server"></asp:Literal>
                                </span></li>
                        </asp:PlaceHolder>
                        <asp:PlaceHolder ID="phdNewPassword" runat="server" Visible="true">
                            <li><span class="Kartris-DetailsView-Name">
                                <asp:Label ID="lblPassword" runat="server" Text="<%$ Resources: Kartris, FormLabel_Password %>"
                                    EnableViewState="false" AssociatedControlID="txtNewPassword" CssClass="requiredfield"></asp:Label>
                            </span>
                                <span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" EnableViewState="true" />
                                    <asp:RequiredFieldValidator ID="valNewPassword" runat="server" ControlToValidate="txtNewPassword"
                                        Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                        CssClass="error" ForeColor="" />
                                    <ajaxToolkit:PasswordStrength runat="server" ID="psNewPassword" TargetControlID="txtNewPassword"
                                        DisplayPosition="RightSide" MinimumSymbolCharacters="1" MinimumUpperCaseCharacters="1"
                                        PreferredPasswordLength="8" CalculationWeightings="25;25;15;35" RequiresUpperAndLowerCaseCharacters="false"
                                        StrengthIndicatorType="BarIndicator" StrengthStyles="barIndicator_poor;barIndicator_weak;barIndicator_good;barIndicator_strong;barIndicator_excellent"
                                        PrefixText=" " BarBorderCssClass="barIndicatorBorder" Enabled="True">
                                    </ajaxToolkit:PasswordStrength>
                                </span></li>
                            <li><span class="Kartris-DetailsView-Name">
                                <asp:Label ID="lblConfirmPassword" runat="server" Text="Confirm Password"
                                    EnableViewState="false" AssociatedControlID="txtConfirmPassword" CssClass="requiredfield"></asp:Label></span>
                                <span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" EnableViewState="true" />
                                    <asp:RequiredFieldValidator ID="valConfirmPassword" runat="server" ControlToValidate="txtConfirmPassword"
                                        Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                        CssClass="error" ForeColor="" />
                                </span></li>
                        </asp:PlaceHolder>
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Label ID="lblOrderLanguage" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Language %>" /></span>
                            <span class="Kartris-DetailsView-Value">
                                <asp:DropDownList ID="ddlOrderLanguage" AutoPostBack="true" runat="server" />
                            </span></li>
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Label ID="lblOrderCurrency" runat="server" Text="<%$ Resources: _Currency, ContentText_Currency %>" /></span>
                            <span class="Kartris-DetailsView-Value">
                                <asp:DropDownList ID="ddlOrderCurrency" AutoPostBack="true" runat="server" />
                            </span></li>
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Label ID="lblOrderPaymentGateway" runat="server" Text="<%$ Resources: _Orders, ContentText_PaymentGateWay %>" /></span>
                            <span class="Kartris-DetailsView-Value">
                                <asp:DropDownList ID="ddlPaymentGateways" runat="server" />
                                <asp:RequiredFieldValidator EnableClientScript="True" ID="valPaymentGateways" runat="server"
                                    ControlToValidate="ddlPaymentGateways" CssClass="error" ForeColor=""
                                    Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"></asp:RequiredFieldValidator></span>
                            <asp:HiddenField runat="server" ID="hidOrderCurrencyID" Value='<%#Eval("O_CurrencyID")%>' />
                        </li>
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Label ID="lblOrderPONumber" runat="server" Text="<%$ Resources: _Orders, ContentText_PONumber %>" /></span>
                            <span class="Kartris-DetailsView-Value">
                                <asp:TextBox ID="txtOrderPONumber" runat="server"></asp:TextBox>
                            </span></li>
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Label ID="lblOrderNotes" runat="server" Text="<%$ Resources: Checkout, SubTitle_Comments%>"
                                AssociatedControlID="txtOrderNotes" /></span> <span class="Kartris-DetailsView-Value">
                                    <asp:TextBox runat="server" ID="txtOrderNotes" TextMode="MultiLine" /></span></li>

                        <asp:PlaceHolder runat="server" ID="phdSendEmailToCustomer" Visible="true">
                            <li>
                                <input type="hidden" name="C_EmailAddress" value="C_EmailAddress" />
                                <span class="checkbox">
                                    <asp:CheckBox runat="server" ID="chkSendOrderUpdateEmail" Checked="true" /></span>
                                <asp:Label ID="lblOrderSendEmailToCustomer" runat="server" Text="<%$ Resources: _Orders, ContentText_SendEmailToCustomer %>"
                                    AssociatedControlID="chkSendOrderUpdateEmail" CssClass="checkbox_label" />

                                <asp:HiddenField ID="hidSendOrderUpdateEmail" Value="true" runat="server" />
                            </li>
                        </asp:PlaceHolder>

                    </ul>
                </div>
            </div>

            <!-- Addresses -->
            <div id="section_addresses">
                <asp:UpdatePanel runat="server" ID="updAddresses" UpdateMode="Conditional">
                    <ContentTemplate>
                        <div class="checkoutaddress">
                            <_user:CheckoutAddressPopup runat="server" ID="_UC_BillingAddress" Title="<%$ Resources: _Address, FormLabel_BillingAddress %>"
                                ErrorMessagePrefix="Billing " EnableValidation="true" />
                        </div>
                        <!-- Shipping Address Selection/Input Control-->
                        <asp:Panel ID="pnlShippingAddress" runat="server" Visible="false">
                            <div class="checkoutaddress">
                                <_user:CheckoutAddressPopup ID="_UC_ShippingAddress" runat="server" ErrorMessagePrefix="Shipping "
                                    Title="<%$ Resources: _Address, FormLabel_ShippingAddress %>" />
                            </div>
                        </asp:Panel>
                        <div class="spacer">
                        </div>

                        <span class="checkbox">
                            <asp:CheckBox ID="chkSameShippingAsBilling" runat="server" Checked="true" AutoPostBack="true" />
                            <asp:Label ID="lblchkSameShipping" Text="<%$ Resources: Checkout, ContentText_SameShippingAsBilling %>"
                                runat="server" AssociatedControlID="chkSameShippingAsBilling" EnableViewState="false" /></span>
                        <!-- EU VAT Number -->
                        <asp:PlaceHolder ID="phdEUVAT" runat="server" Visible="false">
                            <div class="section">
                                <h2>
                                    <asp:Literal ID="litEnterEUVAT" runat="server" Text="<%$ Resources: _Orders, FormLabel_CardholderEUVatNum %>" EnableViewState="false" /></h2>
                                <strong>
                                    <asp:Literal ID="litMSCode" runat="server" EnableViewState="true" /></strong>&nbsp;
                                        <asp:TextBox ID="txtEUVAT" runat="server" EnableViewState="true" AutoPostBack="true"></asp:TextBox>
                            </div>
                        </asp:PlaceHolder>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>

        <div class="rightcolumn">
            <h2>
                <asp:Literal ID="litTabOrderSummary" runat="server" Text="<%$ Resources: _Kartris, ContentText_ItemSummary %>" /></h2>

            <_user:AutoComplete runat="server" ID="_UC_AutoComplete_Item" MethodName="GetVersionsExcludeBaseCombinations" />
            <asp:LinkButton CssClass="link2 icon_new" runat="server" ID="lnkBtnAddToBasket" OnClick="lnkBtnAddToBasket_Click"
                Text="<%$ Resources:_Kartris, FormButton_Add%>" ToolTip="" />
            <_user:BasketView ID="_UC_BasketMain" runat="server" ViewType="CHECKOUT_BASKET" />
        </div>

        <div class="spacer">
        </div>
        <div class="Kartris-DetailsView">
            <div class="Kartris-DetailsView-Data">
                <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                    <asp:LinkButton CausesValidation="True" CssClass="button savebutton" runat="server"
                        ID="lnkBtnSave" Text="<%$ Resources: _Kartris, FormButton_Save %>" ToolTip="<%$ Resources: _Kartris, FormButton_Save %>"
                        OnClientClick="Page_ClientValidate('Checkout');" OnClick="lnkBtnSave_Click" />
                    <asp:LinkButton CssClass="linkbutton icon_cancel cancelbutton" runat="server" ID="lnkBtnCancel"
                        Text="<%$ Resources: _Kartris, FormButton_Cancel %>" ToolTip="<%$ Resources: _Kartris, FormButton_Cancel %>"
                        OnClick="lnkBtnCancel_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
        <_user:OptionsPopup ID="_UC_OptionsPopup" runat="server" />
        <asp:Literal ID="litOptionsVersion" runat="server" Text="" Visible="false" />
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgEditOrder" runat="server" AssociatedUpdatePanelID="updEditOrder">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
