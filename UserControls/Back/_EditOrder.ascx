<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_EditOrder.ascx.vb" Inherits="UserControls_Back_EditOrder" %>
<%@ Register TagPrefix="_user" TagName="CustomerOrder" Src="~/UserControls/Front/CustomerOrder.ascx" %>
<%@ Register TagPrefix="_user" TagName="BasketView" Src="~/UserControls/Back/_BasketView.ascx" %>
<%@ Register TagPrefix="user" TagName="CustomerAddress" Src="~/UserControls/General/CustomerAddress.ascx" %>
<%@ Register TagPrefix="user" TagName="CheckoutAddress" Src="~/UserControls/Front/CheckoutAddressPopup.ascx" %>
<%@ Register TagPrefix="_user" TagName="AutoComplete" Src="~/UserControls/Back/_AutoCompleteInput.ascx" %>
<%@ Register TagPrefix="_user" TagName="OptionsPopup" Src="~/UserControls/Back/_OptionsPopup.ascx" %>
<asp:UpdatePanel ID="updEditOrder" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <ajaxToolkit:TabContainer ID="tabContainerProduct" runat="server" EnableTheming="False"
            CssClass=".tab" AutoPostBack="false">
            <%-- Main tab --%>
            <ajaxToolkit:TabPanel ID="tabMainInfo" runat="server">
                <HeaderTemplate>
                    <asp:Literal ID="litTabMainInfo" runat="server" Text="<%$ Resources: _Kartris, ContentText_Overview %>" />
                </HeaderTemplate>
                <ContentTemplate>
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblOrderID" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderID %>" /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litOrderID" runat="server"></asp:Literal></span> </li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblOrderCustomerID" runat="server" Text="<%$ Resources: _Customers, FormLabel_CustomerID %>" /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:Hyperlink ID="lnkOrderCustomerID" runat="server"></asp:Hyperlink>
                                    </span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblOrderCustomerEmail" runat="server" Text="<%$ Resources: _Kartris, ContentText_Email %>" /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtOrderCustomerEmail" runat="server"></asp:TextBox>
                                    </span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblOrderPONumber" runat="server" Text="<%$ Resources: _Orders, ContentText_PONumber %>" /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtOrderPONumber" runat="server"></asp:TextBox>
                                    </span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblLanguage" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Language %>" /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:DropDownList ID="ddlOrderLanguage" AutoPostBack="true" runat="server" />
                                    </span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblOrderPaymentGateway" runat="server" Text="<%$ Resources: _Orders, ContentText_PaymentGateWay %>" /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:DropDownList ID="ddlPaymentGateways" runat="server" />
                                        <asp:RequiredFieldValidator EnableClientScript="True" ID="valPaymentGateways" runat="server"
                                            ControlToValidate="ddlPaymentGateways" CssClass="error" ForeColor="" ValidationGroup="Checkout"
                                            Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"></asp:RequiredFieldValidator></span>
                                    <asp:HiddenField runat="server" ID="hidOrderCurrencyID" Value='<%#Eval("O_CurrencyID")%>' />
                                </li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblOrderStatus" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderStatus %>" /></span>
                                    <span class="Kartris-DetailsView-Value orderstatus"><span class="checkbox">
                                        <asp:CheckBox runat="server" ID="chkOrderSent" /></span>
                                        <asp:Label CssClass="checkbox_label" ID="lblOrderSent" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderStatusSent %>"
                                            AssociatedControlID="chkOrderSent" /><asp:HiddenField runat="server" ID="hidOrigOrderSent" />
                                        <br />
                                        <span class="checkbox">
                                            <asp:CheckBox runat="server" ID="chkOrderInvoiced" /></span>
                                        <asp:Label CssClass="checkbox_label" ID="lblOrderInvoiced" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderStatusInvoiced %>"
                                            AssociatedControlID="chkOrderInvoiced" />
                                        <br />
                                        <span class="checkbox">
                                            <asp:CheckBox runat="server" ID="chkOrderPaid" /></span>
                                        <asp:Label CssClass="checkbox_label" ID="lblOrderPaid" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderStatusPaid %>"
                                            AssociatedControlID="chkOrderPaid" />
                                        <br />
                                        <span class="checkbox">
                                            <asp:CheckBox runat="server" ID="chkOrderShipped" /></span>
                                        <asp:Label CssClass="checkbox_label" ID="lblOrderShipped" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderStatusShipped %>"
                                            AssociatedControlID="chkOrderShipped" />
                                    </span></li>
                                <asp:PlaceHolder runat="server" ID="phdSendEmailToCustomer" Visible="true">
                                    <li><span class="Kartris-DetailsView-Name"></span>
                                        <span class="Kartris-DetailsView-Value">
                                        <input type="hidden" name="C_EmailAddress" value="C_EmailAddress" />
                                        <span class="checkbox">
                                            <asp:CheckBox runat="server" ID="chkSendOrderUpdateEmail" /></span>
                                        <asp:Label ID="lblOrderSendEmailToCustomer" runat="server" Text="<%$ Resources: _Orders, ContentText_SendEmailToCustomer %>"
                                            AssociatedControlID="chkSendOrderUpdateEmail" CssClass="checkbox_label" />
                                    </span>
                                        <asp:HiddenField ID="hidSendOrderUpdateEmail" Value="true" runat="server" />
                                    </li>
                                </asp:PlaceHolder>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblComments" runat="server" Text="<%$ Resources: Checkout, SubTitle_Comments%>" /></span> <span class="Kartris-DetailsView-Value">
                                            <asp:Literal ID="litComments" runat="server"></asp:Literal></span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblOrderNotes" runat="server" Text="<%$ Resources: _Kartris, ContentText_Notes%>"
                                        AssociatedControlID="txtOrderNotes" /></span> <span class="Kartris-DetailsView-Value">
                                            <asp:TextBox runat="server" ID="txtOrderNotes" TextMode="MultiLine" /></span></li>
                            </ul>
                        </div>
                    </div>
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
            <%-- Order summary --%>
            <ajaxToolkit:TabPanel ID="tabOrderSummary" runat="server">
                <HeaderTemplate>
                    <asp:Literal ID="litPageTitleOrderDetails" runat="server" Text="<%$ Resources: _Orders, PageTitle_OrderDetails %>" />
                </HeaderTemplate>
                <ContentTemplate>
                    <div class="leftcolumn">
                        <!-- Addresses -->
                        <div id="section_addresses">
                            <asp:UpdatePanel runat="server" ID="updAddresses" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <div class="checkoutaddress">
                                        <user:CheckoutAddress runat="server" ID="UC_BillingAddress" Title="<%$ Resources: _Address, FormLabel_BillingAddress %>"
                                            ErrorMessagePrefix="Billing " ValidationGroup="Billing" EnableValidation="true" />
                                    </div>
                                    <!-- Shipping Address Selection/Input Control-->
                                    <asp:Panel ID="pnlShippingAddress" runat="server" Visible="true">
                                        <div class="checkoutaddress">
                                            <user:CheckoutAddress ID="UC_ShippingAddress" runat="server" ErrorMessagePrefix="Shipping "
                                                ValidationGroup="Shipping" Title="<%$ Resources: _Address, FormLabel_ShippingAddress %>" />
                                        </div>
                                    </asp:Panel>
                                    <div class="spacer">
                                    </div>
                                    <p>
                                        <span class="checkbox">
                                            <asp:CheckBox ID="chkSameShippingAsBilling" runat="server" Checked="false" AutoPostBack="true" />
                                            <asp:Label ID="lblchkSameShipping" Text="<%$ Resources: Checkout, ContentText_SameShippingAsBilling %>"
                                                runat="server" AssociatedControlID="chkSameShippingAsBilling" EnableViewState="false" /></span>
                                    </p>
                                    <!-- EU VAT Number -->
                                    <asp:PlaceHolder ID="phdEUVAT" runat="server" Visible="false">
                                        <div class="section">
                                            <h2>
                                                <asp:Literal ID="litEnterEUVAT" runat="server" Text="EUVAT" EnableViewState="false" /></h2>
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
                        <span class="floatright">
                            <asp:Button CssClass="button" runat="server" ID="lnkBtnResetAndCopy" Text="<%$ Resources:FormButton_CopyItemsToBasket%>"
                                ToolTip="" OnClick="lnkBtnResetAndCopy_Click" /></span><h2>
                                    <asp:Literal ID="litTabOrderSummary" runat="server" Text="<%$ Resources: _Kartris, ContentText_ItemSummary %>" /></h2>
                        <_user:AutoComplete runat="server" ID="_UC_AutoComplete_Item" MethodName="GetVersions" />
                        <asp:LinkButton CssClass="link2 icon_new" runat="server" ID="lnkBtnAddToBasket" OnClick="lnkBtnAddToBasket_Click"
                            Text="<%$ Resources:_Kartris, FormButton_Add%>" ToolTip="" />
                        <_user:BasketView ID="UC_BasketMain" runat="server" ViewType="CHECKOUT_BASKET" />
                    </div>
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
            <%-- Ordertext tab --%>
            <ajaxToolkit:TabPanel ID="tabOrderText" runat="server">
                <HeaderTemplate>
                    <asp:Literal ID="litTabOrderText" runat="server" Text="<%$ Resources: _Orders, ContentText_OriginalOrderText%>" />
                </HeaderTemplate>
                <ContentTemplate>
                    <div class="subtabsection">
                        <asp:Literal ID="litOrderText" runat="server"></asp:Literal></div>
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
        </ajaxToolkit:TabContainer>
        <div class="Kartris-DetailsView">
            <div class="Kartris-DetailsView-Data">
                <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                    <asp:LinkButton CausesValidation="True" CssClass="button savebutton" runat="server"
                        ID="lnkBtnSave" Text="<%$ Resources: _Kartris, FormButton_Save %>" ToolTip="<%$ Resources: _Kartris, FormButton_Save %>"
                        OnClientClick="Page_ClientValidate('Checkout');" OnClick="lnkBtnSave_Click" />
                    <asp:LinkButton CssClass="linkbutton icon_cancel cancelbutton" runat="server" ID="lnkBtnCancel"
                        Text="<%$ Resources: _Kartris, FormButton_Cancel %>" ToolTip="<%$ Resources: _Kartris, FormButton_Cancel %>"
                        OnClick="lnkBtnCancel_Click" />
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
