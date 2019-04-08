<%@ Page Language="VB" Trace="false" AutoEventWireup="true" MasterPageFile="~/Skins/Kartris/Template.master"
    CodeFile="checkout.aspx.vb" Inherits="_Checkout" Title="Checkout" MaintainScrollPositionOnPostback="True" %>

<%@ Register TagPrefix="user" TagName="CheckoutAddress" Src="~/UserControls/Front/CheckoutAddressPopup.ascx" %>
<%@ Register TagPrefix="user" TagName="AddressDetails" Src="~/UserControls/General/AddressDetails.ascx" %>
<%@ Register TagPrefix="user" TagName="KartrisLogin" Src="~/UserControls/Front/KartrisLogin.ascx" %>
<%@ Register TagPrefix="user" TagName="CreditCardInput" Src="~/UserControls/Front/CreditCardInput.ascx" %>
<%@ Register TagPrefix="user" Namespace="Kartris" Assembly="KartrisCheckboxValidator" %>
<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">



    <div id="checkout">

        <user:BreadCrumbTrail ID="UC_BreadCrumbTrail" runat="server" EnableViewState="False" />
        <h1>
            <asp:Literal ID="litCheckoutTitle" runat="server" Text="<%$ Resources: PageTitle_CheckOut%>"
                EnableViewState="false" /></h1>
        <!--
        ===============================
        CUSTOMER LOGIN / CREATE USER
        ===============================
        -->
        <asp:MultiView ID="mvwCheckout" runat="server" ActiveViewIndex="0">
            <asp:View ID="viwEmailInput" runat="server">
                <div>
                    <user:KartrisLogin runat="server" ID="UC_KartrisLogin" ForSection="checkout" />
                </div>
            </asp:View>
            <asp:View ID="viwCheckoutInput" runat="server">

                <!--
                ===============================
                PAYMENT METHODS
                Dropdown if multiple choices
                available, hidden if only one
                choice.
                ===============================
                -->
                <asp:UpdatePanel runat="server" ID="updPaymentMethods" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:PlaceHolder ID="phdPaymentMethods" runat="server">
                            <div class="section">
                                <h2>
                                    <asp:Literal ID="litCheckoutPaymentMethod" runat="server" Text="<%$ Resources: FormLabel_SelectPayment %>"
                                        EnableViewState="false" /></h2>

                                <asp:DropDownList CssClass="" ID="ddlPaymentGateways" runat="server" AutoPostBack="true" />
                                <asp:Literal ID="litPaymentGatewayHidden" runat="server" Visible="false"></asp:Literal>
                                <asp:RequiredFieldValidator EnableClientScript="True" ID="valPaymentGateways" runat="server"
                                    ControlToValidate="ddlPaymentGateways" CssClass="error" InitialValue="::False" ForeColor="" ValidationGroup="Checkout"
                                    Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"></asp:RequiredFieldValidator>

                            </div>
                        </asp:PlaceHolder>
                        <asp:PlaceHolder ID="phdCustomerChoicesInfo" runat="server" Visible="false">
                            Some info
                        </asp:PlaceHolder>
                    </ContentTemplate>
                </asp:UpdatePanel>

                <div>
                    <asp:LinkButton ID="lnkbtnDummy" runat="server" Text="" />
                    <!--
                    ===============================
                    POPUP FOR ERRORS
                    Ones with no client-side
                    validation...
                    ===============================
                    -->
                    <ajaxToolkit:ModalPopupExtender ID="popExtender" runat="server" TargetControlID="lnkbtnDummy"
                        CancelControlID="btnCancel" PopupControlID="pnlErrorPopup" BackgroundCssClass="popup_background" />
                    <asp:Panel ID="pnlErrorPopup" runat="server" CssClass="popup" Style="display: none">
                        <h2>
                            <asp:Literal ID="litTitle" runat="server" Text="<%$ Resources: Kartris, ContentText_CorrectErrors %>"
                                EnableViewState="false" /></h2>
                        <asp:Literal runat="server" ID="litOtherErrors" Text="" EnableViewState="false"></asp:Literal>
                        <div>
                            <br />
                            <asp:Button CausesValidation="false" ID="btnOk" CssClass="button" runat="server"
                                Text="<%$ Resources: Kartris, ContentText_OK %>" />
                        </div>
                        <asp:LinkButton ID="btnCancel" CssClass="closebutton linkbutton" runat="server" Text="×"
                            CausesValidation="false" />
                    </asp:Panel>
                    <!--
                    ===============================
                    STREET ADDRESSES
                    Billing / Shipping
                    ===============================
                    -->
                    <asp:UpdatePanel runat="server" ID="updAddresses" UpdateMode="Conditional">
                        <ContentTemplate>
                            <div class="row collapse">
                                <!--
                                -------------------------------
                                BILLING ADDRESS
                                -------------------------------
                                -->
                                <div class="checkoutaddress small-12 large-6 columns">
                                    <user:CheckoutAddress runat="server" ID="UC_BillingAddress" Title="<%$ Resources: Address, FormLabel_BillingAddress %>"
                                        ErrorMessagePrefix="Billing " ValidationGroup="Billing" EnableValidation="true" />
                                </div>
                                <!--
                                -------------------------------
                                SHIPPING ADDRESS
                                -------------------------------
                                -->
                                <!-- Shipping Address Selection/Input Control-->
                                <asp:Panel ID="pnlShippingAddress" runat="server" Visible="false" CssClass="checkoutaddress small-12 large-6 columns">

                                    <user:CheckoutAddress ID="UC_ShippingAddress" runat="server" ErrorMessagePrefix="Shipping "
                                        ValidationGroup="Shipping" Title="<%$ Resources: Address, FormLabel_ShippingAddress %>" />
                                </asp:Panel>

                            </div>
                            <div class="spacer">
                            </div>
                            <!--
                            -------------------------------
                            SAME SHIPPING/BILLING CHECKBOX
                            -------------------------------
                            -->
                            <p>
                                <span class="checkbox">
                                    <asp:CheckBox ID="chkSameShippingAsBilling" runat="server" Checked="true" AutoPostBack="true" />
                                    <asp:Label ID="lblchkSameShipping" Text="<%$ Resources: Checkout, ContentText_SameShippingAsBilling %>"
                                        runat="server" AssociatedControlID="chkSameShippingAsBilling" EnableViewState="true" /></span>
                            </p>
                            <!--
                    ===============================
                    EU VAT NUMBER
                    This section only displays if
                    required (i.e. the setting:
                    general.tax.euvatcountry is
                    not blank, and the user who is
                    checking out is in another EU
                    country).
                    ===============================
                    -->
                            <asp:PlaceHolder ID="phdEUVAT" runat="server" Visible="false">
                                <div class="section" id="euvatsection">
                                    <h2>
                                        <asp:Literal ID="litEnterEUVAT" runat="server" Text="<%$ Resources: ContentText_EnterEUVat %>"
                                            EnableViewState="false" /></h2>
                                    <div class="row">
                                        <div class="small-1 large-1 columns">
                                            <strong>
                                                <asp:Literal ID="litMSCode" runat="server" EnableViewState="true" /></strong>
                                        </div>
                                        <div class="small-10 large-3 columns">
                                            <asp:TextBox ID="txtEUVAT" runat="server" EnableViewState="true" AutoPostBack="true"></asp:TextBox>
                                        </div>
                                        <div class="small-1 large-8 columns">&nbsp;<asp:Literal ID="litValidationOfVATNumber" runat="server"></asp:Literal></div>
                                    </div>
                                </div>
                            </asp:PlaceHolder>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    <div class="spacer">
                    </div>
                </div>

                <!--
                -------------------------------
                PURCHASE ORDER NUMBER
                This field appears dynamically
                if 'PO' (offline payment) is
                selected.
                -------------------------------
                -->
                <asp:UpdatePanel ID="updMain" runat="server">
                    <ContentTemplate>
                        <asp:PlaceHolder ID="phdPONumber" runat="server" Visible="false">
                            <div class="section">
                                <h2>
                                    <asp:Literal ID="litPONumber" runat="server" Text="<%$ Resources: Invoice, ContentText_PONumber %>"
                                        EnableViewState="false" /></h2>
                                <div class="row">
                                    <div class="small-12 large-4 columns">
                                        <asp:TextBox ID="txtPurchaseOrderNo" runat="server" />
                                    </div>
                                </div>
                            </div>
                        </asp:PlaceHolder>
                    </ContentTemplate>
                </asp:UpdatePanel>
                <!--
                ===============================
                BASKET
                ===============================
                -->
                <div id="checkoutbasket">
                    <asp:UpdatePanel ID="updBasket" runat="server" UpdateMode="Conditional">
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="chkSameShippingAsBilling" />
                        </Triggers>
                        <ContentTemplate>
                            <div>
                                <user:BasketView ID="UC_BasketView" runat="server" ViewType="CHECKOUT_BASKET" />
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
                <!--
                ===============================
                CUSTOMER COMMENTS BOX
                frontend.checkout.comments.enabled
                ===============================
                -->
                <asp:PlaceHolder ID="phdCustomerComments" runat="server">
                    <h2><asp:Literal ID="litComments" runat="server" Text="<%$ Resources: Checkout, SubTitle_Comments %>"
                            EnableViewState="false" /></h2>
                    <div id="comments" style="margin-top: 10px;">
                        <asp:TextBox ID="txtComments" runat="server" TextMode="MultiLine"></asp:TextBox>
                    </div>
                </asp:PlaceHolder>
                <!--
                ===============================
                ORDER EMAILS OPT-IN
                backend.orders.emailupdates
                ===============================
                -->
                <asp:PlaceHolder ID="phdOrderEmails" runat="server">
                    <div class="section">
                        <h2>
                            <asp:Literal ID="litOrderEmails" runat="server" Text="<%$ Resources:Checkout,ContentText_OrderEmails%>"
                                EnableViewState="false" /></h2>
                        <p>
                            <asp:Literal ID="litOrderEmailsText" runat="server" Text="<%$ Resources:Checkout,ContentText_OrderEmailsText%>"
                                EnableViewState="false" />
                        </p>
                        <div class="inputform">
                            <span class="checkbox">
                                <asp:CheckBox ID="chkOrderEmails" runat="server" Checked="true" />
                                <asp:Label ID="litOrderEmailsYes" Text="<%$ Resources: Checkout, ContentText_OrderEmailsYes %>"
                                    AssociatedControlID="chkOrderEmails" runat="server" EnableViewState="true" />
                            </span>
                        </div>
                        <div class="spacer">
                        </div>
                    </div>
                </asp:PlaceHolder>
                <!--
                ===============================
                MAILING LIST OPT-IN
                frontend.users.mailinglist.enabled
                ===============================
                -->
                <asp:PlaceHolder ID="phdMailingList" runat="server">
                    <div class="section">
                        <h2>
                            <asp:Literal ID="litMailingList" runat="server" Text="<%$ Resources: Kartris, PageTitle_MailingList%>" EnableViewState="false" /></h2>
                        <p>
                            <asp:Literal ID="litMailingListText" runat="server" Text="<%$ Resources: Checkout, ContentText_WantToMailingList%>"
                                EnableViewState="false" />
                        </p>
                        <div class="inputform">
                            <div>
                                <span class="checkbox">
                                    <asp:CheckBox ID="chkMailingList" runat="server" Checked="false" />
                                    <asp:Label ID="lblYesAddMe" Text="<%$ Resources: Checkout, ContentText_YesAddMe %>"
                                        runat="server" AssociatedControlID="chkMailingList" EnableViewState="true" /></span>
                            </div>
                        </div>
                        <div class="spacer">
                        </div>
                    </div>
                </asp:PlaceHolder>
                <!--
                ===============================
                SAVE BASKET
                frontend.checkout.savebasket
                ===============================
                -->
                <asp:PlaceHolder ID="phdSaveBasket" runat="server">
                    <div class="section">
                        <h2>
                            <asp:Literal ID="litSaveBasket" runat="server" Text="<%$ Resources: Basket, ContentText_SaveBasket %>"
                                EnableViewState="false" /></h2>
                        <p>
                            <asp:Literal ID="litSaveBasketText" runat="server" Text="<%$ Resources: Checkout, ContentText_SaveBasketOnCheckout %>"
                                EnableViewState="false" />
                        </p>
                        <div class="inputform">
                            <span class="checkbox">
                                <asp:CheckBox ID="chkSaveBasket" runat="server" Checked="false" />
                                <asp:Label ID="lblSaveBasket" Text="<%$ Resources: Checkout, ContentText_SaveBasketYes %>"
                                    runat="server" AssociatedControlID="chkSaveBasket" EnableViewState="true" /></span>
                        </div>
                        <div class="spacer">
                        </div>
                    </div>
                </asp:PlaceHolder>
                <!--
                ===============================
                TERMS AND CONDITIONS AGREEMENT
                frontend.checkout.termsandconditions
                ===============================
                -->
                <script type="text/javascript">
                <!--
                function toggle_visibility(id) {
                    var e = document.getElementById(id);
                    if (e.style.display == 'block')
                        e.style.display = 'none';
                    else
                        e.style.display = 'block';
                }
                //-->
                </script>
                <asp:PlaceHolder ID="phdTermsAndConditions" runat="server">
                    <div class="section">
                        <h2>
                            <asp:Literal ID="litContentTextTermsAndConditionsHeader" runat="server" Text="<%$ Resources: Checkout, ContentText_TermsAndConditionsHeader %>"
                                EnableViewState="false" /></h2>
                        <a href="javascript:toggle_visibility('terms');" class="link2 icon_new">
                            <asp:Literal ID="litContentTextTermsAndConditionsPopup" runat="server" Text="<%$ Resources: Checkout, ContentText_TermsAndConditionsPopup %>"
                                EnableViewState="false" /></a>
                        <div id="terms" style="display: none; margin-top: 10px;">
                            <div class="pad">
                                <asp:Literal ID="litContentTextTermsAndConditions" runat="server" Text="<%$ Resources: Checkout, ContentText_TermsAndConditions %>"
                                    EnableViewState="false" />
                            </div>
                        </div>
                        <div class="spacer">
                        </div>
                        <div class="inputform">
                            <span class="checkbox">
                                <asp:CheckBox ID="chkTermsAndConditions" runat="server" />
                                <asp:Label ID="lblTermsAndConditions" Text="<%$ Resources: Checkout, ContentText_TermsAndConditionsCheck%>"
                                    AssociatedControlID="chkTermsAndConditions" runat="server" EnableViewState="true" />
                                <!-- Just remove the AssociatedControlID property if we don't want to disable the proceed button if the Terms checkbox is unchecked -->
                                <user:CheckBoxValidator runat="server" ID="valTermsAndConditions" ControlToValidate="chkTermsAndConditions"
                                    EnableClientScript="true" CssClass="error" ForeColor="" ValidationGroup="Checkout"
                                    Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>" />
                            </span>
                        </div>
                        <div class="spacer">
                        </div>
                    </div>
                </asp:PlaceHolder>
            </asp:View>
            <!--
            ===============================
            ORDER CONFIRMATION PAGE
            ===============================
            -->
            <asp:View ID="viwCheckoutConfirm" runat="server">
                <div id="confirmation">
                    <p>
                        <strong>
                            <asp:Literal ID="litReviewOrder" runat="server" Text="<%$ Resources: PageTitle_ReviewYourOrder %>"
                                EnableViewState="false" /></strong>
                    </p>
                    <!--
                    -------------------------------
                    BILLING ADDRESS
                    -------------------------------
                    -->
                    <div class="checkoutaddress small-12 large-6 columns">
                        <h2>
                            <asp:Literal ID="litBillingDetails" runat="server" Text="<%$ Resources: Address, ContentText_BillingAddress %>" EnableViewState="true" /></h2>
                        <user:AddressDetails ID="UC_Billing" runat="server" ShowLabel="false" ShowButtons="false" />
                    </div>
                    <!--
                    -------------------------------
                    SHIPPING ADDRESS
                    -------------------------------
                    -->
                    <div class="checkoutaddress small-12 large-6 columns">
                        <h2>
                            <asp:Literal ID="litShippingDetails" runat="server" Text="<%$ Resources: Address, ContentText_Shipping %>"
                                EnableViewState="true" /></h2>
                        <user:AddressDetails ID="UC_Shipping" runat="server" ShowLabel="false" ShowButtons="false" />
                    </div>
                    <div class="spacer">
                    </div>
                    <!--
                    -------------------------------
                    BASKET
                    -------------------------------
                    -->
                    <user:BasketView ID="UC_BasketSummary" runat="server" ViewType="CHECKOUT_BASKET"
                        ViewOnly="true" />
                    <!--
                    -------------------------------
                    ACTUAL AMOUNT
                    Converted to the process
                    currency of the payment gateway
                    if set
                    -------------------------------
                    -->
                    <asp:Panel ID="pnlProcessCurrency" runat="server" CssClass="section">
                        <h2>
                            <asp:Literal ID="litProcessCurrencyText" runat="server" Text="<%$ Resources: Email, EmailText_ProcessCurrencyExp1 %>"
                                EnableViewState="false" />
                            <asp:Label ID="lblProcessCurrency" runat="server"></asp:Label>
                        </h2>
                    </asp:Panel>
                    <!--
                    -------------------------------
                    COMMENTS
                    -------------------------------
                    -->
                    <asp:Panel ID="pnlComments" runat="server" CssClass="section">
                        <h2>
                            <asp:Literal ID="litComments2" runat="server" Text="<%$ Resources: Checkout, SubTitle_Comments %>"
                                EnableViewState="false" /></h2>
                        <asp:Label ID="lblComments" runat="server"></asp:Label>
                    </asp:Panel>
                    <!--
                    -------------------------------
                    CHECKED OPTIONS SUMMARY
                    -------------------------------
                    -->
                    <p>
                        <asp:Literal ID="litFormLabelSelectPayment" runat="server" Text="<%$ Resources: FormLabel_SelectPayment %>"
                            EnableViewState="false" />: <strong>
                                <asp:Literal ID="litPaymentMethod" runat="server" EnableViewState="true" /></strong>
                    </p>
                    <asp:Literal ID="litPONumberText" runat="server"></asp:Literal>
                    <div class="tick">
                        <asp:Literal ID="litOrderEmailsYes2" Text="<%$ Resources: Checkout, ContentText_OrderEmailsYes %>"
                            runat="server" EnableViewState="true" />
                    </div>
                    <div class="tick">
                        <asp:Literal ID="litMailingListYes" Text="<%$ Resources: Checkout, ContentText_YesAddMe %>"
                            runat="server" EnableViewState="true" />
                    </div>
                    <div class="tick">
                        <asp:Literal ID="litSaveBasketYes" Text="<%$ Resources: Checkout, ContentText_SaveBasketYes %>"
                            runat="server" EnableViewState="true" />
                    </div>
                    <asp:PlaceHolder ID="phdCreditCardInput" runat="server">
                        <div class="section">
                            <user:CreditCardInput runat="server" ID="UC_CreditCardInput" />
                        </div>
                    </asp:PlaceHolder>
                    
                    <!--
                    -------------------------------
                    BrainTree Module Section
                    This field appears dynamically
                    if 'BrainTree' is
                    selected.
                    -------------------------------
                    -->

                    <asp:UpdatePanel ID="upBrainTree" runat="server" >
                        <ContentTemplate>
                            <asp:PlaceHolder ID="phdBrainTree" runat="server" Visible="false">
                                    <div class="section">
                                        <asp:HiddenField ID="tbClientToken" runat="server" ClientIDMode="Static"/>
                                        <asp:HiddenField ID="tbPaymentMethodNonce" runat="server" ClientIDMode="Static"/>
                                        <asp:HiddenField ID="tbAmount" runat="server" ClientIDMode="Static"/>
                                        <div class="bt-drop-in-wrapper">
                                            <div id="bt-dropin"></div>
                                        </div>
                                    </div>
                            </asp:PlaceHolder>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    <script type="text/javascript" src="https://js.braintreegateway.com/js/braintree-2.28.0.min.js"></script>
                    <script type="text/javascript">
                        var checkoutBT;
                        var active = false;

                        $(document).ready(function () {
                            $("#checkout .submitbuttons").on("click", "input[name*='btnBack']", function () {
                                console.log("btnback");
                                runTearDown();
                                __doPostBack('ctl00$cntMain$btnBack', 'OnClick');
                            });
                        });
                        
                        function clientTokenChanged() {
                            var client_token = $("input[name*='tbClientToken']")[0].value;
                            braintree.setup(client_token, "dropin", {
                                container: "bt-dropin",
                                form: "frmMain",
                                onReady: function(integration){
                                    checkoutBT = integration;
                                },
                                onError: function (payload) {
                                    console.log(payload);
                                },
                                paymentMethodNonceReceived: function (event, nonce) {
                                    console.log(event);
                                    $("input[name*='tbPaymentMethodNonce']")[0].value = nonce;
                                },
                                onPaymentMethodReceived: function (obj) {
                                    //$("input[name*='tbClientToken']")[0].value = "Card finishing with: ";
                                    __doPostBack('ctl00$cntMain$btnProceed', 'OnClick');

                                }
                            });
                        }

                        function runTearDown() {
                            if (typeof checkoutBT != 'undefined') {
                                if (checkoutBT !== null) {
                                    // When you are ready to tear down your integration
                                    checkoutBT.teardown(function () {
                                        checkoutBT = null;
                                        // braintree.setup can safely be run again!
                                    });
                                }
                            }
                        }
                    
                    </script>
                </div>
            </asp:View>
        </asp:MultiView>
        <!--
        ===============================
        SUBMIT / BACK BUTTONS
        Also validation summary
        ===============================
        -->
        <div class="submitbuttons">
            <p>
                <strong>
                    <asp:Literal ID="litFakeOrTest" runat="server" Text="<%$ Resources: Checkout, ContentText_FakeOrTestStatus %>"
                        EnableViewState="false" Visible="false" />
                </strong>
            </p>
            <asp:Button ID="btnBack" CssClass="button" runat="server" Text="<%$ Resources: Checkout, FormButton_Back %>"
                Visible="false" EnableViewState="true" />
            <asp:Button ID="btnProceed" ValidationGroup="Checkout" CssClass="button" runat="server" Text="<%$ Resources: Checkout, ContentText_Proceed %>"
                Visible="true" EnableViewState="true" CausesValidation="true" OnClientClick="Page_ClientValidate('Checkout');" />
            <asp:ValidationSummary ID="valSummary" ValidationGroup="Checkout" runat="server"
                CssClass="valsummary" DisplayMode="BulletList" ForeColor="" HeaderText="<%$ Resources: Kartris, ContentText_Errors %>" />
        </div>
        <!--
        -------------------------------
        POPUP ERRORS
        General errors
        -------------------------------
        -->
        <user:PopupMessage ID="UC_PopUpErrors" runat="server" />

        <%
'This function below disables the scrolling function so
'when the page is submitted, we should see any errors in
'Validators
        %>
        <script type="text/javascript">
            window.scrollTo = function () { }
        </script>
    </div>

</asp:Content>
