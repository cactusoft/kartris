<%@ Page Language="VB" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="false"
    CodeFile="CustomerDetails.aspx.vb" Inherits="Customer_Details" %>

<%@ Register TagPrefix="user" TagName="AddressDetails" Src="~/UserControls/General/AddressDetails.ascx" %>
<%@ Register TagPrefix="user" TagName="AddressInput" Src="~/UserControls/General/CustomerAddress.ascx" %>
<%@ Register TagPrefix="user" TagName="AnimatedText" Src="~/UserControls/General/AnimatedText.ascx" %>
<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <h1>
        <asp:Literal ID="litContentTextChangeCustomerCode" runat="server" Text='<%$ Resources: Kartris, ContentText_ChangeCustomerCode %>' /></h1>
    <p><strong><asp:Literal ID="litUserEmail" runat="server"></asp:Literal></strong></p>
    <div>
        <asp:UpdatePanel ID="updAddresses" runat="server">
            <ContentTemplate>
                <asp:MultiView ID="mvwAddresses" runat="server" ActiveViewIndex="0">
                    <asp:View ID="viwDefaults" runat="server">
                        <div>
                            <p>
                                <asp:Literal ID="litChangePassword" runat="server" Text='<%$ Resources: SubTitle_ChangeCustomerCode %>' />
                            </p>
                            <div class="Kartris-DetailsView">
                                <div class="Kartris-DetailsView-Data">
                                    <ul>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblCurrentPassword" runat="server" Text="<%$ Resources: FormLabel_ExistingCustomerCode %>"
                                                AssociatedControlID="txtCurrentPassword" CssClass="requiredfield"></asp:Label></span><span
                                                    class="Kartris-DetailsView-Value">
                                                    <asp:TextBox ID="txtCurrentPassword" TextMode="Password" runat="server" /><asp:RequiredFieldValidator
                                                        Display="Dynamic" CssClass="error" ForeColor="" runat="server" ID="valCurrentPassword" ValidationGroup="Passwords"
                                                        ControlToValidate="txtCurrentPassword" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"></asp:RequiredFieldValidator>
                                                </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblNewPassword" runat="server" Text="<%$ Resources: FormLabel_NewCustomerCode %>"
                                                AssociatedControlID="txtNewPassword" CssClass="requiredfield"></asp:Label></span><span
                                                    class="Kartris-DetailsView-Value">
                                                    <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" /><asp:RequiredFieldValidator
                                                        runat="server" ID="valNewPassword" ControlToValidate="txtNewPassword" CssClass="error"
                                                        ForeColor="" Text="<%$ Resources: Kartris, ContentText_RequiredField %>" Display="Dynamic" ValidationGroup="Passwords"></asp:RequiredFieldValidator>
                                                    <ajaxToolkit:PasswordStrength runat="server" ID="psNewPassword" TargetControlID="txtNewPassword"
                                                        DisplayPosition="RightSide" MinimumSymbolCharacters="1" MinimumUpperCaseCharacters="1"
                                                        PreferredPasswordLength="8" CalculationWeightings="25;25;15;35" RequiresUpperAndLowerCaseCharacters="false"
                                                        StrengthIndicatorType="BarIndicator" StrengthStyles="barIndicator_poor;barIndicator_weak;barIndicator_good;barIndicator_strong;barIndicator_excellent"
                                                        PrefixText=" " BarBorderCssClass="barIndicatorBorder" Enabled="True">
                                                    </ajaxToolkit:PasswordStrength>
                                                </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblConfirmPassword" runat="server" Text="<%$ Resources: FormLabel_NewCustomerCodeRepeat %>"
                                                AssociatedControlID="txtConfirmPassword" CssClass="requiredfield"></asp:Label></span><span
                                                    class="Kartris-DetailsView-Value">
                                                    <asp:TextBox ID="txtConfirmPassword" runat="server" onpaste="return false" TextMode="Password" /><asp:RequiredFieldValidator
                                                        runat="server" ID="valConfirmPassword" ControlToValidate="txtConfirmPassword" ValidationGroup="Passwords"
                                                        CssClass="error" ForeColor="" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                                        Display="Dynamic"></asp:RequiredFieldValidator><br />
                                                    <asp:CompareValidator runat="server" ID="valPassword" ControlToValidate="txtNewPassword"
                                                        CssClass="error" ForeColor="" ControlToCompare="txtConfirmPassword" Operator="Equal"
                                                        Text="<%$ Resources: ContentText_CustomerCodesDifferent%> " EnableClientScript="False"
                                                        Display="Dynamic" ValidationGroup="Passwords" />
                                                    <asp:Literal runat="server" ID="litWrongPassword" EnableViewState="false"></asp:Literal></span>
                                        </li>
                                        <li>
                                            <asp:Button ID="btnSubmit" CssClass="button" runat="server" Text="<%$ Resources: Kartris, FormButton_Submit %>"
                                                ValidationGroup="Passwords" /></li>
                                    </ul>
                                    <!-- Length Validator will be placed here, wrong password literal needs to be styled -->
                                </div>
                            </div>
                        </div>
                        <asp:PlaceHolder runat="server" ID="phdDefaultAddresses">
                            <div class="section">
                                <p></p>
                                <div class="Kartris-DetailsView">
                                    <div class="Kartris-DetailsView-Data">
                                        <ul>
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Label ID="lblCustomerName" runat="server" Text="<%$ Resources: Kartris, ContentText_CustomerName %>"
                                                    AssociatedControlID="txtCustomerName" CssClass="requiredfield"></asp:Label></span><span
                                                        class="Kartris-DetailsView-Value">
                                                        <asp:TextBox ID="txtCustomerName" runat="server" /><asp:RequiredFieldValidator Display="Dynamic"
                                                            CssClass="error" ForeColor="" runat="server" ID="rfvCustomerName" ControlToValidate="txtCustomerName"
                                                            ValidationGroup="NameAndVAT" Text="<%$ Resources: Kartris, ContentText_RequiredField %>" />
                                                    </span></li>
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Label ID="lblEUVATNumber" runat="server" Text="<%$ Resources: Kartris, ContentText_EnterEUVat %>"
                                                    AssociatedControlID="txtEUVATNumber" CssClass="requiredfield"></asp:Label></span><span
                                                        class="Kartris-DetailsView-Value">
                                                        <asp:TextBox ID="txtEUVATNumber" runat="server" />
                                                    </span></li>
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Label ID="lblEORINumber" runat="server" Text="<%$ Resources: Kartris, ContentText_EORI %>"
                                                    AssociatedControlID="txtEORINumber" CssClass="requiredfield"></asp:Label></span><span
                                                        class="Kartris-DetailsView-Value">
                                                        <asp:TextBox ID="txtEORINumber" runat="server" />
                                                    </span></li>
                                            <li>
                                                <asp:Button ID="btnUpdate" CssClass="button" runat="server" Text="<%$ Resources: Kartris, FormButton_Submit %>"
                                                    ValidationGroup="NameAndVAT" /></li>
                                        </ul>
                                    </div>
                                </div>
                            </div>

                            <div class="section">
                                <div class="row collapse">
                                    <div class="small-12 medium-6 columns">

                                        <h2>
                                            <asp:Literal ID="litDefaultBilling" runat="server" Text='<%$ Resources: Address, ContentText_DefaultBillingAddress %>' />
                                        </h2>
                                        <div>
                                            <asp:Literal ID="litContentTextNoAddress" Visible="false" runat="server" Text='<%$ Resources: Address, ContentText_NoAddress %>' />
                                        </div>
                                        <user:AddressDetails runat="server" ID="UC_DefaultBilling" ShowButtons="false" />
                                        <br />
                                        <asp:LinkButton ID="lnkEditBilling" CssClass="link2" runat="server" Text='<%$ Resources: Address, ContentText_ManageAddresses %>'
                                            CausesValidation="false" /><br />
                                        <br />
                                    </div>
                                    <div class="small-12 medium-6 columns">
                                        <h2>
                                            <asp:Literal ID="litDefaultShipping" runat="server" Text='<%$ Resources: Address, ContentText_DefaultShippingAddress %>' />
                                        </h2>
                                        <div>
                                            <asp:Literal ID="litContentTextNoAddress2" Visible="false" runat="server" Text='<%$ Resources: Address, ContentText_NoAddress %>' />
                                        </div>
                                        <user:AddressDetails runat="server" ID="UC_DefaultShipping" ShowButtons="false" />
                                        <br />
                                        <asp:LinkButton ID="lnkEditShipping" CssClass="link2" runat="server" Text='<%$ Resources: Address, ContentText_ManageAddresses %>'
                                            CausesValidation="false" /><br />
                                        <br />
                                    </div>
                                </div>
                            </div>
                        </asp:PlaceHolder>
                    </asp:View>

                    <asp:View ID="viwBillingAddresses" runat="server">
                        <div class="section manageaddresses">
                            <h2>
                                <asp:Literal ID="litContentTextSavedAddresses" runat="server" Text='<%$ Resources: Address, ContentText_SavedAddresses %>' />:
                                <span class="h2_light_extra">
                                    <asp:Literal ID="litContentTextBillingAddress" runat="server" Text='<%$ Resources: Address, ContentText_BillingAddress %>' /></span></h2>
                            <asp:Panel ID="pnlBilling" runat="server">
                            </asp:Panel>
                            <div class="floatright">
                                <asp:LinkButton ID="lnkAddBilling" CssClass="link2" runat="server" CausesValidation="false"
                                    Text='<%$ Resources: Address, ContentText_AddEditAddress %>' />
                            </div>
                        </div>
                    </asp:View>

                    <asp:View ID="viwShippingAddresses" runat="server">
                        <div class="section manageaddresses">
                            <h2>
                                <asp:Literal ID="litContentTextSavedAddresses2" runat="server" Text='<%$ Resources: Address, ContentText_SavedAddresses %>' />:
                                <span class="h2_light_extra">
                                    <asp:Literal ID="litContentTextShippingAddress" runat="server" Text='<%$ Resources: Address, ContentText_ShippingAddress %>' /></span></h2>
                            <asp:Panel ID="pnlShipping" runat="server">
                            </asp:Panel>
                            <div class="floatright">
                                <asp:LinkButton ID="lnkAddShipping" CssClass="link2" runat="server" CausesValidation="false"
                                    Text='<%$ Resources: Address, ContentText_AddEditAddress %>' />
                            </div>
                        </div>
                    </asp:View>



                </asp:MultiView>
                <p>
                    <asp:LinkButton ID="btnBack" CssClass="link2" runat="server" Text='<%$ Resources: Kartris, ContentText_GoBack  %>'
                        CausesValidation="false" />
                </p>
                <asp:LinkButton ID="lnkDummy" runat="server" CausesValidation="false" />
                <asp:Panel ID="pnlNewAddress" runat="server" CssClass="popup" Style="display: none" DefaultButton="btnSaveNewAddress">
                    <h2>
                        <asp:Literal ID="litAddressTitle" runat="server" Text="<%$ Resources:Kartris, ContentText_Edit%>" /></h2>
                    <user:AddressInput ID="UC_NewEditAddress" DisplayType="Shipping" runat="server" ShowSaveAs="true"
                        AutoPostCountry="false" ValidationGroup="Shipping" />
                    <div class="spacer">
                    </div>
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <li><span class="Kartris-DetailsView-Name"></span><span class="Kartris-DetailsView-Value">
                                    <asp:CheckBox ID="chkAlso" runat="server" CssClass="checkbox" Text='<%$ Resources: Address, ContentText_CanAlsoBeUsedAsBillingAddress %>' /></span></li>
                                <li><span class="Kartris-DetailsView-Name"></span><span class="Kartris-DetailsView-Value">
                                    <asp:CheckBox ID="chkMakeDefault" runat="server" CssClass="checkbox" Text='<%$ Resources: Address, ContentText_SetAsDefault %>' /></span></li>
                            </ul>
                            <div class="submitbuttons">
                                <asp:Button CssClass="button" ID="btnSaveNewAddress" runat="server" Text='<%$ Resources: Kartris, FormButton_Submit %>'
                                    CausesValidation="true" />
                            </div>
                        </div>
                        <asp:LinkButton ID="btnAddressCancel" runat="server" Text="×" CssClass="closebutton linkbutton2" />
                    </div>
                </asp:Panel>
                <user:AnimatedText runat="server" ID="UC_Updated" />
                <ajaxToolkit:ModalPopupExtender ID="popExtender" runat="server" TargetControlID="lnkDummy"
                    CancelControlID="btnAddressCancel" PopupControlID="pnlNewAddress" BackgroundCssClass="popup_background" />
            </ContentTemplate>
        </asp:UpdatePanel>
        <asp:UpdateProgress ID="prgAddresses" runat="server" AssociatedUpdatePanelID="updAddresses">
            <ProgressTemplate>
                <div class="loadingimage">
                </div>
                <div class="updateprogress">
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
    </div>
</asp:Content>
