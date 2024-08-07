<%@ Page Language="VB" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="false"
    CodeFile="PasswordReset.aspx.vb" Inherits="PasswordReset" %>

<%@ Register TagPrefix="user" TagName="AnimatedText" Src="~/UserControls/General/AnimatedText.ascx" %>
<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <h1>
        <asp:Literal ID="litContentTextChangeCustomerCode" runat="server" Text='<%$ Resources: Kartris, ContentText_ChangeCustomerCode %>' /></h1>
    <div>
        <asp:UpdatePanel ID="updAddresses" runat="server">
            <ContentTemplate>

                <div>
                    <p>
                        <asp:Literal ID="litChangePassword" runat="server" Text='<%$ Resources: Login, SubTitle_ChangeCustomerCode %>' />
                    </p>
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblCurrentPassword" runat="server" Text="<%$ Resources: Login, FormLabel_ExistingCustomerCode %>"
                                        AssociatedControlID="txtCurrentPassword" CssClass="requiredfield"></asp:Label></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtCurrentPassword" TextMode="Password" runat="server" /><asp:RequiredFieldValidator
                                                Display="Dynamic" CssClass="error" ForeColor="" runat="server" ID="valCurrentPassword" ValidationGroup="Passwords"
                                                ControlToValidate="txtCurrentPassword" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"></asp:RequiredFieldValidator>
                                        </span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblNewPassword" runat="server" Text="<%$ Resources: Login, FormLabel_NewCustomerCode %>"
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
                                    <asp:Label ID="lblConfirmPassword" runat="server" Text="<%$ Resources: Login, FormLabel_NewCustomerCodeRepeat %>"
                                        AssociatedControlID="txtConfirmPassword" CssClass="requiredfield"></asp:Label></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtConfirmPassword" runat="server" onpaste="return false" TextMode="Password" /><asp:RequiredFieldValidator
                                                runat="server" ID="valConfirmPassword" ControlToValidate="txtConfirmPassword" ValidationGroup="Passwords"
                                                CssClass="error" ForeColor="" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                                Display="Dynamic"></asp:RequiredFieldValidator><br />
                                            <asp:CompareValidator runat="server" ID="valPassword" ControlToValidate="txtNewPassword"
                                                CssClass="error" ForeColor="" ControlToCompare="txtConfirmPassword" Operator="Equal"
                                                Text="<%$ Resources: Login, ContentText_CustomerCodesDifferent%> " EnableClientScript="False"
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



                <user:AnimatedText runat="server" ID="UC_Updated" />

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
