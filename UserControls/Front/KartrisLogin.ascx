<%@ Control Language="VB" AutoEventWireup="true" EnableViewState="true" CodeFile="KartrisLogin.ascx.vb"
    Inherits="KartrisLogin" %>
<div id="login">
    <asp:UpdatePanel ID="updNewOrExisting" runat="server">
        <ContentTemplate>
            <ajaxToolkit:Accordion ID="accLoginRegister" runat="Server" SelectedIndex="0" HeaderCssClass="accordionHeader"
                HeaderSelectedCssClass="accordionHeaderSelected" ContentCssClass="accordionContent"
                AutoSize="None" FadeTransitions="true" TransitionDuration="250" FramesPerSecond="40"
                RequireOpenedPane="true" SuppressHeaderPostbacks="true">
                <Panes>
                    <ajaxToolkit:AccordionPane ID="acpMain" runat="server">
                        <Header>
                            <h2>
                                <asp:Literal ID="litContentTextCustomerAccount" runat="server" Text="<%$ Resources: ContentText_CustomerAccount %>" /></h2>
                        </Header>
                        <Content>
                            <asp:Panel ID="pnlEnterEmail" runat="server" DefaultButton="btnSignIn">
                            <div class="Kartris-DetailsView inputform" style="overflow:hidden;">
                                <div class="Kartris-DetailsView-Data">
                                    <ul>
                                        <li>
                                            <asp:RadioButtonList runat="server" ID="rblNeworOld" AutoPostBack="true" CssClass="radio">
                                                <asp:ListItem Text="<%$ Resources: Kartris, ContentText_NewCustomers %>" Value="New" />
                                                <asp:ListItem Text="<%$ Resources: Kartris, ContentText_AlreadyHaveAccount %>" Value="Existing" />
                                            </asp:RadioButtonList>
                                            <asp:Literal ID="litMessage" runat="server" />
                                            <br />
                                        </li>
                                        <asp:PlaceHolder ID="phdEmail" runat="server" Visible="false">
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Label ID="lblEmail" runat="server" Text="<%$ Resources: Kartris, FormLabel_EmailAddress %> "
                                                    AssociatedControlID="C_Email" CssClass="requiredfield" EnableViewState="false" /></span><span
                                                        class="Kartris-DetailsView-Value">
                                                        <asp:TextBox ID="C_Email" runat="server" AutoPostBack="false" type="email" /></span>
                                                        <asp:RequiredFieldValidator ID="valEmailAddress1" runat="server" ControlToValidate="C_Email"
                                                            ValidationGroup="Checkout" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                                            CssClass="error" ForeColor="" />
                                                        <asp:RegularExpressionValidator ID="valEmailAddress2" runat="server" ControlToValidate="C_Email"
                                                            ValidationGroup="Checkout" Display="Dynamic" ErrorMessage="<%$ Resources: Kartris, ContentText_BadEmail %>"
                                                            ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="error"
                                                            ForeColor="" /></li>
                                        </asp:PlaceHolder>
                                        <asp:PlaceHolder ID="phdPassword" runat="server" Visible="false">
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Label ID="lblUserPassword" runat="server" Text="<%$ Resources: Kartris, FormLabel_Password %> "
                                                    AssociatedControlID="txtUserPassword" CssClass="requiredfield" EnableViewState="false" /></span><span
                                                        class="Kartris-DetailsView-Value">
                                                        <asp:TextBox runat="server" ID="txtUserPassword" TextMode="Password" /></span>
                                                        <asp:RequiredFieldValidator
                                                            ID="valPassword" runat="server" ControlToValidate="txtUserPassword" ValidationGroup="Checkout"
                                                            Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                                            CssClass="error" ForeColor="" /></li>
                                        </asp:PlaceHolder>
                                        <asp:PlaceHolder ID="phdSubmitButtons" runat="server" Visible="false">
                                            <li><span class="Kartris-DetailsView-Value">
                                                <asp:Button runat="server" ID="btnSignIn" Text="<%$ Resources: Kartris, FormButton_Submit %>"
                                                    CssClass="button" />
                                                <asp:LinkButton ID="lnkbtnNew" runat="server" Text="" /></span></li>
                                        </asp:PlaceHolder>
                                    </ul>
                                </div>
                            </div>
                            </asp:Panel>
                            <ajaxToolkit:ModalPopupExtender ID="popLogin" runat="server" TargetControlID="lnkbtnNew"
                                CancelControlID="btnCancel" PopupControlID="pnlLogin" BackgroundCssClass="popup_background" />
                            <asp:Panel ID="pnlLogin" runat="server" CssClass="popup inputform" Style="display: none" DefaultButton="btnContinue">
                                <h2>
                                    <asp:Literal ID="litTitle" runat="server" Text="<%$ Resources: Kartris, PageTitle_LogInToSite %>"
                                        EnableViewState="false" /></h2>
                                <asp:MultiView ID="mvwLoginPopup" runat="server">
                                    <asp:View ID="viwNewUser" runat="server">
                                        <asp:UpdatePanel ID="updNewAccount" runat="server">
                                            <ContentTemplate>
                                                <div>
                                                    <asp:Literal ID="litSubTitleCreateCustomerAccount" runat="server" Text="<%$ Resources: SubTitle_CreateCustomerAccount %>"
                                                        EnableViewState="false" /></div>
                                                <div>
                                                    <asp:Literal ID="litFailureText" runat="server"></asp:Literal>
                                                </div>
                                                <div class="Kartris-DetailsView">
                                                    <div class="Kartris-DetailsView-Data">
                                                        <ul>
                                                            <li><span class="Kartris-DetailsView-Name">
                                                                <asp:Label ID="lblNewEmail" runat="server" Text="<%$ Resources: Kartris, FormLabel_EmailAddress %>"
                                                                    EnableViewState="false" AssociatedControlID="txtNewEmail" CssClass="requiredfield"></asp:Label></span><span
                                                                        class="Kartris-DetailsView-Value">
                                                                        <asp:TextBox ID="txtNewEmail" runat="server" Enabled="false" /></span></li>
                                                            <li><span class="Kartris-DetailsView-Name">
                                                                <asp:Label ID="lblConfirmEmail" runat="server" Text="<%$ Resources: FormLabel_ConfirmEmail %>"
                                                                    EnableViewState="false" AssociatedControlID="txtConfirmEmail" CssClass="requiredfield"></asp:Label></span><span
                                                                        class="Kartris-DetailsView-Value">
                                                                        <asp:TextBox ID="txtConfirmEmail" runat="server" /></span></li>
                                                            <asp:PlaceHolder ID="phdNewPassword" runat="server" >
                                                                    <li><span class="Kartris-DetailsView-Name">
                                                                <asp:Label ID="lblPassword" runat="server" Text="<%$ Resources: Kartris, FormLabel_Password %>"
                                                                    EnableViewState="false" AssociatedControlID="txtNewPassword" CssClass="requiredfield"></asp:Label>
                                                                        <asp:Label ID="lblPasswordOptional" runat="server" Text="<%$ Resources: Kartris, ContentText_PasswordOptional %>"
                                                                     AssociatedControlID="txtNewPassword" CssClass="requiredfield"></asp:Label>
                                                                        </span><span
                                                                        class="Kartris-DetailsView-Value">
                                                                        <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" EnableViewState="true" />
                                                                        <ajaxToolkit:PasswordStrength runat="server" ID="psNewPassword" TargetControlID="txtNewPassword"
                                                                            DisplayPosition="RightSide" MinimumSymbolCharacters="1" MinimumUpperCaseCharacters="1"
                                                                            PreferredPasswordLength="8" CalculationWeightings="25;25;15;35" RequiresUpperAndLowerCaseCharacters="false"
                                                                            StrengthIndicatorType="BarIndicator" StrengthStyles="barIndicator_poor;barIndicator_weak;barIndicator_good;barIndicator_strong;barIndicator_excellent"
                                                                            PrefixText=" " BarBorderCssClass="barIndicatorBorder" Enabled="True">
                                                                        </ajaxToolkit:PasswordStrength>
                                                                    </span></li>
                                                                <li><span class="Kartris-DetailsView-Name">
                                                                    <asp:Label ID="lblConfirmPassword" runat="server" Text="<%$ Resources: FormLabel_ConfirmPassword %>"
                                                                        EnableViewState="false" AssociatedControlID="txtConfirmPassword" CssClass="requiredfield"></asp:Label></span><span
                                                                            class="Kartris-DetailsView-Value">
                                                                            <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" /></span></li>
                                                            </asp:PlaceHolder>

                                                            <% 'GDPR opt in section %>
                                                            <asp:PlaceHolder ID="phdGDPROptIn" runat="server" Visible="false">
                                                                <div class="GDPR">
                                                                    <asp:CheckBox ID="chkGDPRConfirm" runat="server" class="checkbox" />
                                                                    <asp:Label ID="lblGDPRConfirmText" runat="server" Text="<%$ Resources: Kartris, FormLabel_GDPRConfirmText %>" AssociatedControlID="chkGDPRConfirm"></asp:Label>

                                                                </div>
                                                            </asp:PlaceHolder>


                                                            <li><span class="Kartris-DetailsView-Name"></span><span class="Kartris-DetailsView-Value">
                                                                <asp:Button ID="btnContinue" CssClass="button" runat="server" Text="<%$ Resources: Kartris, FormButton_Submit %>"
                                                                    CausesValidation="true" /></span></li>

                                                            
                                                        </ul>
                                                    </div>
                                                </div>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </asp:View>
                                    <asp:View ID="viwError" runat="server">
                                        <div>
                                            <asp:Literal ID="litErrorDetails" runat="server" Text="" /></div>
                                        <asp:Button CausesValidation="false" ID="btnOk" CssClass="button" runat="server"
                                            Text="<%$ Resources: Kartris, ContentText_Close %>" EnableViewState="false" />
                                        <br />
                                    </asp:View>
                                </asp:MultiView>
                                <asp:LinkButton ID="btnCancel" CssClass="closebutton linkbutton" runat="server" Text="×"
                                    CausesValidation="false" EnableViewState="false" />
                            </asp:Panel>
                        </Content>
                    </ajaxToolkit:AccordionPane>
                    <ajaxToolkit:AccordionPane ID="acpRecover" runat="server">
                        <Header>
                            <h2>
                                <asp:Literal ID="litPageTitleForgottenCustomerNumber" runat="server" Text="<%$ Resources:Login, PageTitle_ForgottenCustomerNumber%>"
                                    EnableViewState="false" /></h2>
                        </Header>
                        <Content>
                            <div>
                                <p>
                                    <asp:Literal ID="litContentTextForgottenCustomerNumberDesc" runat="server" Text="<%$ Resources:Login, ContentText_ForgottenCustomerNumberDesc%>" /></p>
                                <asp:PasswordRecovery ID="PasswordRecover" runat="server">
                                    <UserNameTemplate>
                                        <div class="Kartris-DetailsView inputform">
                                            <div class="Kartris-DetailsView-Data">
                                                <ul>
                                                    <li><span class="Kartris-DetailsView-Name">
                                                        <asp:Label ID="lblEmailAddress" runat="server" Text="<%$ Resources:Kartris, FormLabel_EmailAddress %>"
                                                            AssociatedControlID="UserName" CssClass="requiredfield"></asp:Label></span><span
                                                                class="Kartris-DetailsView-Value">
                                                                <asp:TextBox ID="UserName" runat="server" ValidationGroup="RecoverPassword"></asp:TextBox>
                                                                <asp:RegularExpressionValidator ID="valEmailAddress2" runat="server" ControlToValidate="UserName"
                                                                    ValidationGroup="RecoverPassword" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                                                    EnableClientScript="True" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_BadEmail %>"
                                                                    CssClass="error" ForeColor="" />
                                                                <asp:RequiredFieldValidator ID="valEmailAddress1" runat="server" ControlToValidate="UserName"
                                                                    EnableClientScript="True" ValidationGroup="RecoverPassword" Display="Dynamic"
                                                                    Text="<%$ Resources: Kartris, ContentText_RequiredField %>" CssClass="error"
                                                                    ForeColor="" />
                                                            </span></li>
                                                    <li>
                                                        <asp:Button ID="btnRecoverPassword" OnClick="btnRecover_Click" runat="server" CssClass="button"
                                                            ValidationGroup="RecoverPassword" Text="<%$ Resources:Kartris, FormLabel_Recover %>" /></li>
                                                </ul>
                                            </div>
                                        </div>
                                    </UserNameTemplate>
                                </asp:PasswordRecovery>
                            </div>
                            <ajaxToolkit:ModalPopupExtender ID="popRecovery" runat="server" TargetControlID="lnkRecoveryClose"
                                CancelControlID="lnkRecoveryClose" PopupControlID="pnlRecovery" BackgroundCssClass="popup_background" />
                            <asp:Panel ID="pnlRecovery" runat="server" CssClass="popup inputform" Style="display: none">
                                <h2>
                                    <asp:Literal ID="litRecoveryTitle" runat="server" Text="<%$ Resources:Kartris, FormLabel_Recover %>"
                                        EnableViewState="false" /></h2>
                                <div>
                                    <asp:Literal ID="litRecoveryMessage" runat="server" Text="" /></div>
                                <br />
                                <asp:Button CausesValidation="false" ID="btnRecoveryClose" CssClass="button" runat="server"
                                    Text="<%$ Resources: Kartris, ContentText_Close %>" />
                                <asp:LinkButton ID="lnkRecoveryClose" CssClass="closebutton linkbutton" runat="server"
                                    Text="×" CausesValidation="false" EnableViewState="false" />
                            </asp:Panel>
                        </Content>
                    </ajaxToolkit:AccordionPane>
                </Panes>
            </ajaxToolkit:Accordion>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
