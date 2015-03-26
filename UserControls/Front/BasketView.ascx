<%@ Control Language="VB" AutoEventWireup="false" CodeFile="BasketView.ascx.vb" Inherits="Templates_BasketView" %>
<%@ Register TagPrefix="user" TagName="ShippingMethodsEstimate" Src="~/UserControls/General/ShippingMethodsEstimate.ascx" %>
<!--
===============================
CUSTOMIZE POPUP
===============================
-->
<asp:UpdatePanel ID="updPnlCustomText" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Panel ID="pnlCustomText" runat="server" Style="display: none" CssClass="popup popup_customization">
            <!-- Customization Window Title and Close Button -->
            <h2>
                <asp:Literal ID="litContentTextCustomization" runat="server" Text='<%$ Resources: Kartris, ContentText_Customization %>'
                    EnableViewState="false" /></h2>
            <asp:LinkButton ID="lnkClose" runat="server" Text="" CssClass="closebutton" />
            <asp:LinkButton ID="lnkDummy" runat="server" Text="X" CssClass="closebutton" />
            <div>
                <!-- Cancel Customization Link -->
                <asp:PlaceHolder ID="phdCustomizationCancel" runat="server" Visible="True">
                    <p>
                        <asp:LinkButton ID="btnCancelCustomText" runat="server" CssClass="link2" Text='<%$ Resources: Kartris, ContentText_CustomizeNoThanks %>' />
                    </p>
                </asp:PlaceHolder>
                <!-- Customization Explanation -->
                <p>
                    <asp:Literal ID="litContentTextCustomizationExplanation" runat="server" Text='<%$ Resources: Kartris, ContentText_CustomizationExplanation %>'
                        EnableViewState="false" />
                </p>
                <!-- Description Text -->
                <div>
                    <br />
                    <asp:Label ID="lblCustomDesc" runat="server" AssociatedControlID="txtCustomText"></asp:Label>
                    <br />
                    <!-- Customization Text Box & Validator -->
                    <asp:TextBox ID="txtCustomText" runat="server" TextMode="SingleLine" CssClass="longtext"></asp:TextBox>
                    <asp:RequiredFieldValidator EnableClientScript="True" ID="valCustomText" runat="server"
                        ControlToValidate="txtCustomText" ValidationGroup="CustomForm" CssClass="error"
                        ForeColor="" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                        Visible="False"></asp:RequiredFieldValidator>
                </div>
                <!-- Customization Price -->
                <asp:PlaceHolder ID="phdCustomizationPrice" runat="server" Visible="True">
                    <div>
                        <strong>
                            <asp:Literal ID="litContentTextPrice" runat="server" Text='<%$ Resources: Kartris, ContentText_Price %>'
                                EnableViewState="false" /></strong> &nbsp;<span class="price"><asp:Literal ID="litCustomCost"
                                    runat="server" /></span>
                    </div>
                </asp:PlaceHolder>
                <!-- Customization Submit Button -->
                <div class="submitbuttons">
                    <asp:Button ID="btnSaveCustomText" runat="server" CssClass="button" ValidationGroup="CustomForm"
                        Text='<%$ Resources: Kartris, FormLabel_Save %>' />
                </div>
            </div>
            <asp:HiddenField ID="hidCustomType" runat="server" />
            <asp:HiddenField ID="hidCustomVersionID" runat="server" />
            <asp:HiddenField ID="hidCustomQuantity" runat="server" />
            <asp:HiddenField ID="hidBasketID" runat="server" />
            <asp:HiddenField ID="hidOptions" runat="server" />
            <asp:HiddenField ID="hidOptionBasketID" runat="server" />
        </asp:Panel>
        <ajaxToolkit:ModalPopupExtender ID="popCustomText" runat="server" TargetControlID="lnkClose"
            PopupControlID="pnlCustomText" BackgroundCssClass="popup_background" OkControlID="lnkClose"
            CancelControlID="lnkClose" DropShadow="False">
        </ajaxToolkit:ModalPopupExtender>
    </ContentTemplate>
</asp:UpdatePanel>
<!--
===============================
MAIN BASKET
===============================
-->
<asp:UpdatePanel ID="updPnlMainBasket" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:PlaceHolder ID="phdMainBasket" runat="server" Visible="false">
            <div class="basket">
                <asp:Literal ID="litSpeedError" runat="server"></asp:Literal>
                <asp:Literal ID="litCouponError" runat="server"></asp:Literal>
                <div class='errors'>
                    <strong>
                        <asp:Literal ID="litBasketEmpty" runat="server"></asp:Literal></strong>
                </div>
                <asp:Literal ID="litError" runat="server"></asp:Literal>
                <user:PopupMessage ID="popMessage" runat="server" />
                <asp:Panel ID="pnlEmptyBasket" runat="server" Style="display: none; width: 450px"
                    CssClass="popup">
                    <h2>
                        <asp:Literal ID="litPageTitleShoppingBasket" EnableViewState="false" runat="server"
                            Text='<%$ Resources: Basket, PageTitle_ShoppingBasket %>' /></h2>
                    <p>
                        <asp:Literal ID="litContentTextEmptyShoppingBasketConfirm" EnableViewState="false"
                            runat="server" Text='<%$ Resources: Basket, ContentText_EmptyShoppingBasketConfirm %>' />
                    </p>
                    <br />
                    <div>
                        <asp:Button ID="btnEmptyBasketYes" runat="server" CssClass="button" Text="<%$ Resources: Kartris, ContentText_Yes %>"
                            OnCommand="EmptyBasket_Click" CommandName="EmptyBasket" />
                        <asp:Button ID="btnEmptyBasketExtenderCancel" runat="server" CssClass="button" Text="<%$ Resources: Kartris, ContentText_No %>" />
                        <asp:Button ID="btnEmptyBasketExtenderOK" runat="server" Text="" CssClass="invisible" />
                    </div>
                </asp:Panel>
                <ajaxToolkit:ModalPopupExtender ID="popEmptyBasket" runat="server" TargetControlID="btnEmptyBasket"
                    PopupControlID="pnlEmptyBasket" BackgroundCssClass="popup_background" OkControlID="btnEmptyBasketExtenderOK"
                    CancelControlID="btnEmptyBasketExtenderCancel" DropShadow="False" OnOkScript="EmptyBasketOK">
                </ajaxToolkit:ModalPopupExtender>
                <asp:PlaceHolder ID="phdBasket" runat="server" Visible="false">
                    <div class="inputform">
                        <asp:PlaceHolder ID="phdOutOfStockElectronic" runat="server" Visible="false">
                            <!-- Out of stock / electronic warning -->
                            <div class="basketwarning">
                                <asp:Literal ID="litOutofStockElectronic" runat="server" Text='<%$Resources:Basket,ContentText_OutOfStockElectronic%>'
                                    EnableViewState="false"></asp:Literal>
                            </div>
                            <div class="spacer">
                            </div>
                            <br />
                        </asp:PlaceHolder>
                        <asp:PlaceHolder ID="phdOutOfStock" runat="server" Visible="false">
                            <!-- Out of stock -->
                            <div class="basketwarning">
                                <asp:Literal ID="litOutofStockx" runat="server" Text='<%$Resources:Basket,ContentText_OutOfStock%>'
                                    EnableViewState="false"></asp:Literal>
                            </div>
                            <div class="spacer">
                            </div>
                            <br />
                        </asp:PlaceHolder>
                        <!-- Basket Items Rows -->
                        <asp:Repeater ID="rptBasket" runat="server">
                            <HeaderTemplate>
                                <table class="baskettable">
                                    <thead>
                                        <tr class="headrow">
                                            <% If KartSettingsManager.GetKartConfig("frontend.basket.showimages") = "y" Then%>
                                            <th class="hide-for-small"></th>
                                            <th class="name">
                                                <% Else%>
                                            <th colspan="2" class="name">
                                                <% End If%>
                                                <asp:Literal ID="litContentTextNameDetails" runat="server" Text='<%$ Resources: Kartris, ContentText_NameDetails %>'
                                                    EnableViewState="false"></asp:Literal>
                                            </th>
                                            <% If APP_PricesIncTax Then%>
                                            <% If APP_ShowTaxDisplay Then%>
                                            <th class="extax">
                                                <asp:Literal ID="litContentTextExTax1" runat="server" Text='<%$ Resources: Kartris, ContentText_ExTax %>'
                                                    EnableViewState="false"></asp:Literal>
                                            </th>
                                            <th class="inctax">
                                                <asp:Literal ID="litContentTextIncTax1" runat="server" Text='<%$ Resources: Kartris, ContentText_IncTax %>'
                                                    EnableViewState="false"></asp:Literal>
                                            </th>
                                            <% Else%>
                                            <th class="price" colspan="2">
                                                <asp:Literal ID="litContentTextPrice1" runat="server" Text='<%$ Resources: Kartris, ContentText_Price %>'
                                                    EnableViewState="false"></asp:Literal>
                                            </th>
                                            <% End If%>
                                            <% Else 'Ex Tax %>
                                            <% If APP_ShowTaxDisplay Then%>
                                            <th class="price">
                                                <asp:Literal ID="litContentTextExTax2" runat="server" Text='<%$ Resources: Kartris, ContentText_Price %>'
                                                    EnableViewState="false"></asp:Literal>
                                            </th>
                                            <th class="tax">
                                                <asp:Literal ID="litContentTextTax2" runat="server" Text='<%$ Resources: Kartris, ContentText_Tax %>'
                                                    EnableViewState="false"></asp:Literal>
                                            </th>
                                            <% Else%>
                                            <th class="price" colspan="2">
                                                <asp:Literal ID="litContentTextPrice2" runat="server" Text='<%$ Resources: Kartris, ContentText_Price %>'
                                                    EnableViewState="false"></asp:Literal>
                                            </th>
                                            <% End If%>
                                            <% End If%>
                                            <th class="quantity">
                                                <asp:Literal ID="litContentTextQty" runat="server" Text='<%$ Resources: Basket, ContentText_Qty %>'
                                                    EnableViewState="false"></asp:Literal>
                                            </th>
                                            <th class="total hide-for-small">
                                                <asp:Literal ID="litContentTextTotal1" runat="server" Text='<%$ Resources: Basket, ContentText_Total %>'></asp:Literal>
                                            </th>
                                            <th class="remove"></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr class="product_row">
                                    <% If KartSettingsManager.GetKartConfig("frontend.basket.showimages") = "y" Then%>
                                    <td class="image_cell hide-for-small">
                                        <user:ProductTemplateImageOnly ID="UC_ProductTemplateImageOnly" runat="server" />
                                    </td>
                                    <td>
                                        <% Else%>
                                    <td colspan="2">
                                        <% End If%>
                                        <div class="name" style="cursor: pointer;">
                                            <strong>
                                                <asp:HyperLink ID="lnkProduct" runat="server" Text='<%# Server.HTMLEncode(Eval("Quantity") & " x " &  Eval("ProductName")) %>'></asp:HyperLink></strong>
                                            <asp:UpdatePanel ID="updCustomize" runat="server" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:LinkButton ID="lnkCustomize" CssClass="link2 icon_new" runat="server" CommandName="Customize"
                                                        CommandArgument='<%#Eval("ID")%>' OnCommand="CustomText_Click" Text="<%$ Resources: Basket, ContentText_Customize %>" /></div>
                                                </ContentTemplate>
                                                <Triggers>
                                                    <asp:AsyncPostBackTrigger ControlID="lnkCustomize" EventName="Click" />
                                                </Triggers>
                                            </asp:UpdatePanel>
                                            <div class="spacer">
                                            </div>
                                            <div class="details">
                                                <div class="info">
                                                    <asp:PlaceHolder ID="phdProductType1" runat="server" Visible="false">
                                                        <asp:Literal ID="litCodeNumber" runat="server" Text='<%# Server.HtmlEncode(Eval("CodeNumber")) %>' />
                                                    </asp:PlaceHolder>
                                                    <asp:PlaceHolder ID="phdProductType2" runat="server" Visible="false">
                                                        <asp:PlaceHolder ID="phdItemHasCombinations" runat="server" Visible="false">
                                                            <%#Eval("OptionText")%>
                                                        </asp:PlaceHolder>
                                                        <asp:PlaceHolder ID="phdItemHasNoCombinations" runat="server" Visible="false">
                                                            <asp:Literal ID="litVersionName" runat="server" Text='<%# Server.HtmlEncode(Eval("VersionName")) %>' Visible="false" />
                                                            <%#Eval("OptionText")%>
                                                        </asp:PlaceHolder>
                                                        (<asp:Literal ID="litCodeNumber2" runat="server" Text='<%# Server.HtmlEncode(Eval("CodeNumber")) %>' />)
                                                    </asp:PlaceHolder>
                                                </div>
                                            </div>
                                            <div class="spacer">
                                            </div>
                                    </td>
                                    <% If APP_PricesIncTax Then%>
                                    <% If APP_ShowTaxDisplay Then%>
                                    <td class="extax">
                                        <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Eval("ExTax"))%>
                                    </td>
                                    <td class="inctax">
                                        <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Eval("IncTax"))%>
                                    </td>
                                    <% Else%>
                                    <td class="price" colspan="2">
                                        <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Eval("IncTax"))%>
                                    </td>
                                    <% End If%>
                                    <% Else%>
                                    <% If APP_ShowTaxDisplay Then%>
                                    <td class="extax">
                                        <asp:Literal ID="litExTax1" runat="server" />
                                        <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Eval("ExTax"))%>
                                    </td>
                                    <td class="tax">
                                        <%# Eval("ComputedTaxRate") * 100%>%
                                    </td>
                                    <% Else%>
                                    <td class="price" colspan="2">
                                        <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Eval("ExTax"))%>
                                    </td>
                                    <% End If%>
                                    <% End If%>
                                    <td class="quantity">
                                        <% If ViewOnly Then%>
                                        <%#Eval("Quantity")%>
                                        <% Else%>
                                        <asp:UpdatePanel runat="server" ID="updItemQuantity">
                                            <ContentTemplate>
                                                <asp:Literal ID="litProductID_H" runat="server" Text='<%# Eval("ProductID") %>' Visible="false" />
                                                <ajaxToolkit:FilteredTextBoxExtender ID="filDecimalQuantity" runat="server" TargetControlID="txtQuantity"
                                                    FilterType="Numbers,Custom" ValidChars=".">
                                                </ajaxToolkit:FilteredTextBoxExtender>
                                                <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="txtQuantity"
                                                    Operator="DataTypeCheck" Type="Double" Display="Dynamic" CssClass="error" ForeColor=""
                                                    ErrorMessage='<%$ Resources: Kartris, ContentText_InvalidValue %>'></asp:CompareValidator>
                                                <asp:TextBox MaxLength="25" ID='txtQuantity' EnableViewState="true" AutoPostBack="true"
                                                    OnTextChanged='QuantityChanged' runat="server" Text='<%#Eval("Quantity")%>' CausesValidation="False">
                                                </asp:TextBox>
                                                <asp:HiddenField ID="hdfBasketID" runat="server" Value='<%#Eval("ID")%>' />
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                        <asp:UpdateProgress ID="prgItemQuantity" runat="server" AssociatedUpdatePanelID="updItemQuantity"
                                            DynamicLayout="true" DisplayAfter="10">
                                            <ProgressTemplate>
                                                <div class="smallupdateprogress">
                                                </div>
                                            </ProgressTemplate>
                                        </asp:UpdateProgress>
                                        <% End If%>
                                    </td>
                                    <td class="total hide-for-small">
                                        <% If APP_USMultiStateTax Then%>
                                        <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Eval("RowExTax"))%>
                                        <% Else%>
                                        <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Eval("RowIncTax"))%>
                                        <% End If%>
                                    </td>
                                    <td class="remove">
                                        <asp:LinkButton CssClass="basket_delete_button" ID="lnkBtnRemoveItem" OnCommand="RemoveItem_Click"
                                            CommandName="RemoveItem" CommandArgument='<%#Eval("ID") & ";" & Eval("VersionID")%>'
                                            runat="server" ToolTip='<%$Resources:Basket,FormButton_Remove%>' Text=""></asp:LinkButton>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                        <!-- Promotion Discount Rows -->
                        <asp:PlaceHolder ID="phdPromotionDiscountHeader" runat="server" Visible="true">
                            <asp:Repeater ID="rptPromotionDiscount" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <% If KartSettingsManager.GetKartConfig("frontend.basket.showimages") = "y" Then%>
                                        <td class="image_cell hide-for-small"></td>
                                        <td>
                                            <% Else%>
                                        <td colspan="2">
                                            <% End If%>
                                            <div class="name">
                                                <strong>
                                                    <%#Eval("Quantity")%> x
                                                    <asp:Literal ID="litPromotionDiscount" runat="server" Text='<%$ Resources: Basket, ContentText_Promotion %>'
                                                        EnableViewState="false"></asp:Literal></strong>
                                            </div>
                                            <div class="details">
                                                <%#Server.HtmlEncode(Eval("Name"))%>
                                            </div>
                                        </td>
                                        <% If APP_PricesIncTax Then%>
                                        <% If APP_ShowTaxDisplay Then%>
                                        <td class="extax">
                                            <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, CDbl(Eval("ExTax")))%>
                                        </td>
                                        <td class="inctax">
                                            <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, CDbl(Eval("IncTax")))%>
                                        </td>
                                        <% Else%>
                                        <td class="price" colspan="2">
                                            <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, CDbl(Eval("IncTax")))%>
                                        </td>
                                        <% End If%>
                                        <!-- Ex Tax -->
                                        <% Else%>
                                        <% If APP_ShowTaxDisplay Then%>
                                        <td class="extax">
                                            <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, CDbl(Eval("ExTax")))%>
                                        </td>
                                        <td class="tax">
                                            <%#CDbl(Eval("ComputedTaxRate") * 100)%>%
                                        </td>
                                        <% Else%>
                                        <td class="price" colspan="2">
                                            <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, CDbl(Eval("ExTax")))%>
                                        </td>
                                        <% End If%>
                                        <% End If%>
                                        <td class="quantity">
                                            <%#Eval("Quantity")%>
                                        </td>
                                        <td class="total hide-for-small">
                                            <% If APP_USMultiStateTax Then%>
                                            <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, CDbl(Eval("TotalExTax")))%>
                                            <% Else%>
                                            <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, CDbl(Eval("TotalIncTax")))%>
                                            <% End If%>
                                        </td>
                                        <td>&nbsp;
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </asp:PlaceHolder>
                        <%=""%>
                        <!-- Coupon Row -->
                        <% If Not String.IsNullOrEmpty(Basket.CouponCode) Then 'We have a coupon
                        %>
                        <tr>
                            <% If KartSettingsManager.GetKartConfig("frontend.basket.showimages") = "y" Then%>
                            <td class="image_cell hide-for-small"></td>
                            <td>
                                <% Else%>
                            <td colspan="2">
                                <% End If%>
                                <div class="name">
                                    <strong>
                                        <asp:Literal ID="litCouponDiscount" runat="server" Text='<%$Resources:Kartris,ContentText_CouponDiscount%>'
                                            EnableViewState="false"></asp:Literal></strong>
                                </div>
                                <div class="details">
                                    <div class="info">
                                        <%=Basket.CouponName%>
                                    </div>
                                </div>
                            </td>
                            <% '' inc tax %>
                            <% If APP_PricesIncTax Then%>
                            <% If APP_ShowTaxDisplay = True Then%>
                            <td class="extax">
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CouponDiscount.ExTax)%>
                            </td>
                            <td class="inctax">
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CouponDiscount.IncTax)%>
                            </td>
                            <% Else%>
                            <td class="price" colspan="2">
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CouponDiscount.IncTax)%>
                            </td>
                            <% End If%>
                            <%'' Ex Tax %>
                            <% Else%>
                            <% If APP_ShowTaxDisplay Then%>
                            <td class="extax">
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CouponDiscount.ExTax)%>
                            </td>
                            <td class="tax">
                                <%=(Basket.CouponDiscount.TaxRate * 100)%>%
                            </td>
                            <% Else%>
                            <td class="price" colspan="2">
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CouponDiscount.ExTax)%>
                            </td>
                            <% End If%>
                            <% End If%>
                            <td class="quantity">1
                            </td>
                            <td class="total hide-for-small">
                                <% If Basket.CouponDiscount.IncTax > 0 Then%>
                                <% If APP_USMultiStateTax Then%>
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CouponDiscount.ExTax)%>
                                <% Else%>
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CouponDiscount.IncTax)%>
                                <% End If%>
                                <% Else%>
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CouponDiscount.IncTax)%>
                                <% End If%>
                            </td>
                            <td class="remove">
                                <asp:LinkButton ID="lnkBtnRemoveCoupon" OnCommand="RemoveCoupon_Click" CommandName="RemoveCoupon"
                                    CommandArgument="" CssClass="basket_delete_button" runat="server" ToolTip='<%$ Resources: Basket, FormButton_Remove %>'
                                    Text=""></asp:LinkButton>
                            </td>
                        </tr>
                        <% End If%>
                        <!-- Customer Discount Row -->
                        <% If BSKT_CustomerDiscount > 0 Then%>
                        <tr>
                            <% If KartSettingsManager.GetKartConfig("frontend.basket.showimages") = "y" Then%>
                            <td class="image_cell hide-for-small"></td>
                            <td>
                                <% Else%>
                            <td colspan="2">
                                <% End If%>
                                <div class="name">
                                    <strong>
                                        <asp:Literal ID="litContentTextDiscount" runat="server" Text='<%$ Resources: Basket, ContentText_Discount %>'
                                            EnableViewState="false"></asp:Literal></strong>
                                </div>
                                <div class="details">
                                    <div class="info">
                                        <%=BSKT_CustomerDiscount%>%
                                    </div>
                                </div>
                            </td>
                            <%'Inc Tax%>
                            <% If APP_PricesIncTax Then%>
                            <% If APP_ShowTaxDisplay Then%>
                            <td class="extax">
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CustomerDiscount.ExTax)%>
                            </td>
                            <td class="inctax">
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CustomerDiscount.IncTax)%>
                            </td>
                            <% Else%>
                            <td class="price" colspan="2">
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CustomerDiscount.IncTax)%>
                            </td>
                            <% End If%>
                            <%'Ex Tax%>
                            <% Else%>
                            <% If APP_ShowTaxDisplay Then%>
                            <td class="extax">
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CustomerDiscount.ExTax)%>
                            </td>
                            <td class="tax">
                                <%=(Basket.CustomerDiscount.TaxRate * 100)%>%
                            </td>
                            <% Else%>
                            <td class="price" colspan="2">
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CustomerDiscount.ExTax)%>
                            </td>
                            <% End If%>
                            <% End If%>
                            <td class="quantity">1
                            </td>
                            <td class="total hide-for-small">
                                <% If APP_USMultiStateTax Then%>
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CustomerDiscount.ExTax)%>
                                <% Else%>
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CustomerDiscount.IncTax)%>
                                <% End If%>
                            </td>
                            <td>&nbsp;
                            </td>
                        </tr>
                        <% End If%>
                        <!-- Shipping Method Row -->
                        <asp:PlaceHolder ID="phdShipping" runat="server" Visible="false">
                            <tr class="shippingrow">
                                <% If KartSettingsManager.GetKartConfig("frontend.basket.showimages") = "y" Then%>
                                <td class="image_cell hide-for-small"></td>
                                <td>
                                    <% Else%>
                                <td colspan="2">
                                    <% End If%>
                                    <div class="name">
                                        <strong>
                                            <asp:Literal ID="litContentTextShipping" runat="server" Text='<%$ Resources: Address, ContentText_Shipping %>'
                                                EnableViewState="false"></asp:Literal></strong>
                                    </div>
                                    <div class="details">
                                        <div class="info">
                                            <asp:PlaceHolder ID="phdShippingSelection" runat="server" Visible="false">
                                                <user:ShippingMethods ID="UC_ShippingMethodsDropdown" runat="server" />
                                                <br />
                                            </asp:PlaceHolder>
                                            <% If ViewOnly Then%>
                                            <strong>
                                                <%=Basket.ShippingName%></strong> -
                                                <% End If%><%=Basket.ShippingDescription%>
                                        </div>
                                    </div>
                                </td>
                                <asp:PlaceHolder ID="phdShippingTaxHide" runat="server" Visible="false">
                                    <td colspan="4"></td>
                                </asp:PlaceHolder>
                                <asp:PlaceHolder ID="phdShippingTax" runat="server" Visible="false">
                                    <%=""%>
                                    <% If APP_PricesIncTax Then%>
                                    <% If APP_ShowTaxDisplay Then%>
                                    <td class="extax">
                                        <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.ShippingPrice.ExTax)%>
                                    </td>
                                    <td class="inctax">
                                        <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.ShippingPrice.IncTax)%>
                                    </td>
                                    <% Else%>
                                    <td class="price" colspan="2">
                                        <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.ShippingPrice.IncTax)%>
                                    </td>
                                    <% End If%>
                                    <% Else%>
                                    <% If APP_ShowTaxDisplay Then%>
                                    <td class="extax">
                                        <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.ShippingPrice.ExTax)%>
                                    </td>
                                    <td class="tax">
                                        <%=(Basket.ShippingPrice.TaxRate * 100)%>%
                                    </td>
                                    <% Else%>
                                    <td class="price" colspan="2">
                                        <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.ShippingPrice.ExTax)%>
                                    </td>
                                    <% End If%>
                                    <% End If%>
                                    <td class="quantity">1
                                    </td>
                                    <td class="total hide-for-small">
                                        <% If APP_USMultiStateTax Then%>
                                        <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.ShippingPrice.ExTax)%>
                                        <% Else%>
                                        <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.ShippingPrice.IncTax)%>
                                        <% End If%>
                                    </td>
                                    <td>&nbsp;
                                    </td>
                                </asp:PlaceHolder>
                            </tr>
                        </asp:PlaceHolder>
                        <!-- Order Handling Charge Row -->
                        <asp:PlaceHolder ID="phdOrderHandling" runat="server">
                            <tr>
                                <% If KartSettingsManager.GetKartConfig("frontend.basket.showimages") = "y" Then%>
                                <td class="image_cell hide-for-small"></td>
                                <td>
                                    <% Else%>
                                <td colspan="2">
                                    <% End If%>
                                    <div class="name">
                                        <strong>
                                            <asp:Literal ID="litOrderHandlingCharge" runat="server" Text='<%$ Resources: Kartris, ContentText_OrderHandlingCharge %>'
                                                EnableViewState="false"></asp:Literal></strong>
                                    </div>
                                </td>
                                <%=""%>
                                <% If APP_PricesIncTax Then%>
                                <% If APP_ShowTaxDisplay Then%>
                                <td class="extax">
                                    <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.OrderHandlingPrice.ExTax)%>
                                </td>
                                <td class="inctax">
                                    <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.OrderHandlingPrice.IncTax)%>
                                </td>
                                <% Else%>
                                <td class="price" colspan="2">
                                    <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.OrderHandlingPrice.IncTax)%>
                                </td>
                                <% End If%>
                                <% Else%>
                                <% If APP_ShowTaxDisplay Then%>
                                <td class="extax">
                                    <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.OrderHandlingPrice.ExTax)%>
                                </td>
                                <td class="tax">
                                    <%=(Basket.OrderHandlingPrice.TaxRate * 100)%>%
                                </td>
                                <% Else%>
                                <td class="price" colspan="2">
                                    <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.OrderHandlingPrice.ExTax)%>
                                </td>
                                <% End If%>
                                <% End If%>
                                <td class="quantity">1
                                </td>
                                <td class="total hide-for-small">
                                    <% If APP_USMultiStateTax Then%>
                                    <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.OrderHandlingPrice.ExTax)%>
                                    <% Else%>
                                    <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.OrderHandlingPrice.IncTax)%>
                                    <% End If%>
                                </td>
                                <td>&nbsp;
                                </td>
                            </tr>
                        </asp:PlaceHolder>
                        <!-- Coupon Entry Row -->
                        <% If KartSettingsManager.GetKartConfig("frontend.orders.allowcoupons") <> "n" And Not (ViewOnly) Then%>
                        <% If Basket.CouponName = "" Then%>
                        <tr class="applycoupon">
                            <% If KartSettingsManager.GetKartConfig("frontend.basket.showimages") = "y" Then%>
                            <td class="image_cell hide-for-small"></td>
                            <td colspan="5">
                                <% Else%>
                            <td colspan="6">
                                <% End If%>
                                <asp:Panel ID="pnlCoupons" runat="server" DefaultButton="btnApplyCoupon">

                                    <asp:Label ID="lblCouponCode" runat="server" Text='<%$ Resources: Basket, ContentText_ApplyCouponCode %>'
                                        EnableViewState="false" AssociatedControlID="txtCouponCode"></asp:Label><asp:TextBox MaxLength="25" ID="txtCouponCode" runat="server" Text="" AutoPostBack="false"
                                            CssClass="couponbox"></asp:TextBox>
                                    <asp:LinkButton ID="btnApplyCoupon" CssClass="link2 icon_new" OnCommand="ApplyCoupon_Click"
                                        CommandName="ApplyCoupon" CommandArgument="" runat="server" Text='<%$ Resources: Basket, ContentText_EnterCouponLink %>' />
                    </div>

                    </asp:Panel>

                            </td>
                            <td class="hide-for-small">&nbsp;</td>
                    </tr>
                        <% End If%>
                    <% End If%>
                    <!-- Grand totals -->
                    <%
                        Dim vFinalPriceExTax, vFinalPriceTaxAmount, vFinalPriceIncTax, vFinalPriceTaxRate As Double
     	
                        If ViewType <> BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then
                            vFinalPriceExTax = Basket.FinalPriceExTax - Basket.ShippingPrice.ExTax - Basket.OrderHandlingPrice.ExTax
                            vFinalPriceTaxAmount = Basket.FinalPriceTaxAmount - Basket.ShippingPrice.TaxAmount - Basket.OrderHandlingPrice.TaxAmount
                            vFinalPriceIncTax = Basket.FinalPriceIncTax - Basket.ShippingPrice.IncTax - Basket.OrderHandlingPrice.IncTax
                        Else
                            vFinalPriceExTax = Basket.FinalPriceExTax
                            vFinalPriceTaxAmount = Basket.FinalPriceTaxAmount
                            vFinalPriceIncTax = Basket.FinalPriceIncTax
                            vFinalPriceTaxRate = Math.Round(Basket.D_Tax * 100, 3)
                        End If

                    %>

                    <!-- Grand Totals Rows -->

                    <!-- ex tax -->
                    <% If APP_ShowTaxDisplay Then%>
                    <tr class="totals">
                        <% If KartSettingsManager.GetKartConfig("frontend.basket.showimages") = "y" Then%>
                        <td class="image_cell hide-for-small"></td>
                        <td colspan="5" class="extax">
                            <% Else%>
                        <td colspan="6" class="extax">
                            <% End If%>
                            <span class="labeltext">
                                <asp:Literal ID="litContentTextExTax2" runat="server" Text='<%$ Resources: Kartris, ContentText_ExTax %>'
                                    EnableViewState="false"></asp:Literal></span>
                            <span class="value"><%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, vFinalPriceExTax)%></span></td>
                        <td class="hide-for-small">&nbsp;</td>
                    </tr>
                    <% End If%>
                    <%If APP_USMultiStateTax Then%>
                    <!-- Show just tax amount for EU, non US -->
                    <tr class="totals">
                        <% If KartSettingsManager.GetKartConfig("frontend.basket.showimages") = "y" Then%>
                        <td class="image_cell hide-for-small"></td>
                        <td colspan="5" class="tax">
                            <% Else%>
                        <td colspan="6" class="tax">
                            <% End If%>
                            <span class="labeltext">
                                <asp:Literal ID="litContentTextTax2" runat="server" Text='<%$ Resources: Kartris, ContentText_Tax %>'
                                    EnableViewState="false"></asp:Literal></span>
                            <!-- show tax rate% for US -->

                            <span class="taxrate"><%=vFinalPriceTaxRate%>%</span>

                            <span class="value"><%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, vFinalPriceTaxAmount)%></span></td>
                        <td class="hide-for-small">&nbsp;</td>
                    </tr>
                    <% End If%>


                    <!-- total inc tax -->
                    <tr class="totals">
                        <% If KartSettingsManager.GetKartConfig("frontend.basket.showimages") = "y" Then%>
                        <td class="image_cell hide-for-small"></td>
                        <td colspan="5" class="total">
                            <% Else%>
                        <td colspan="6" class="total">
                            <% End If%>
                            <span class="labeltext">
                                <asp:Literal ID="litTotal2" runat="server" Text='<%$ Resources: Basket, ContentText_Total %>'
                                    EnableViewState="false"></asp:Literal></span>
                            <span class="value"><%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, vFinalPriceIncTax)%></span></td>
                        <td class="hide-for-small">&nbsp;</td>
                    </tr>
                </tbody></table>
            </div>
            <div>
                <asp:Literal ID="litShippingTotal" runat="server"></asp:Literal>
                <asp:PlaceHolder ID="phdControls" runat="server" Visible="false"></asp:PlaceHolder>
            </div>
            <asp:PlaceHolder ID="phdBasketButtons" runat="server" Visible="false">
                <div class="controls">
                    <div>
                        <%-- this is a dummy button, for people who haven't realized that it
                            autoposts qty updates so just need to click off qty box --%>
                        <asp:Button Text='<%$ Resources: Basket, FormButton_Recalculate %>' CssClass="button"
                            ID="btnRecalculate" runat="server" UseSubmitBehavior="True" CausesValidation="True" />
                        <asp:Button Text='<%$ Resources: Basket, FormButton_EmptyBasket %>' CssClass="button"
                            ID="btnEmptyBasket" runat="server" />
                        <asp:Button Text='<%$ Resources: Basket, FormButton_MakeEnquiry %>' CssClass="button"
                            ID="btnEnquire" runat="server" PostBackUrl="~/Contact.aspx" />
                        <asp:Button Text='<%$ Resources: Basket, FormButton_Checkout %>' CssClass="button highpriority"
                            ID="btnCheckout" runat="server" PostBackUrl="~/Checkout.aspx" />
                    </div>
                </div>
            </asp:PlaceHolder>
            <!-- end of form -->
        </asp:PlaceHolder>
        <% If ViewType = BasketBLL.VIEW_TYPE.MAIN_BASKET Then%>
        <!-- shipping estimate -->
        <user:ShippingMethodsEstimate ID="UC_ShippingMethodsEstimate" runat="server" />
        <!-- basket links -->
        <div class="basket">
            <asp:PlaceHolder ID="phdSectionLinks" runat="server">
                <div class="links">
                    <div>
                        <a href="Customer.aspx?action=savebasket" class="link2 icon_save">
                            <asp:Literal ID="litSaveRecoverBasketContents" runat="server" Text='<%$ Resources: Basket, PageTitle_SaveRecoverBasketContents %>'></asp:Literal></a>
                        <p>
                            <asp:Literal ID="litSaveRecoverBasket3" runat="server" Text='<%$ Resources: Basket, ContentText_SaveRecoverBasketDesc %>'></asp:Literal>
                        </p>
                    </div>
                    <div>
                        <a href="Customer.aspx?action=home" class="link2 icon_myaccount">
                            <asp:Literal ID="litMyAccountTitle" runat="server" Text='<%$ Resources: Kartris, PageTitle_MyAccount %>'></asp:Literal></a>
                        <p>
                            <asp:Literal ID="litMyAccount3" runat="server" Text='<%$ Resources: Basket, ContentText_MyAccountDesc %>'></asp:Literal>
                        </p>
                    </div>
                    <%If KartSettingsManager.GetKartConfig("frontend.users.wishlists.enabled") <> "n" Then%>
                    <div>
                        <a href="Customer.aspx?action=wishlists" class="link2 icon_wishlist">
                            <asp:Literal ID="litSaveWishListTitle" runat="server" Text='<%$ Resources:Basket, ContentText_SaveWishList %>'></asp:Literal></a>
                        <p>
                            <asp:Literal ID="litSaveWishList3" runat="server" Text='<%$ Resources:Basket, ContentText_SaveWishListDesc %>'></asp:Literal>
                        </p>
                    </div>
                    <%End If%>
                    <div class="spacer">
                    </div>
                </div>
            </asp:PlaceHolder>
        </div>
        <div class="spacer">
        </div>
        <!-- end basket links -->
        <% End If%>
        <% If Basket.BasketItems.Count > 0 Then%>
        <asp:PlaceHolder ID="phdPromotions" runat="server" Visible="false">
            <div class="section section_promotions">
                <div class="pad">
                    <h4>
                        <asp:Literal ID="litSubHeaderPromotions" runat="server" Text="<%$ Resources:Kartris, SubHeading_Promotions %>"
                            EnableViewState="false"></asp:Literal></h4>
                    <asp:Repeater ID="rptPromotions" runat="server">
                        <ItemTemplate>
                            <div class="promotion">
                                <div class="box">
                                    <div class="pad">
                                        <asp:Literal ID="litPromotionText" runat="server" Text='<%# Eval("PromoText") %>'
                                            EnableViewState="false"></asp:Literal>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                        <FooterTemplate>
                            <a href='<%= CkartrisBLL.WebShopURL %>Promotions.aspx'>
                                <asp:Literal ID="litSubHeaderPromotions" runat="server" Text="<%$ Resources:Basket, ContentText_MorePromotionsLink %>"
                                    EnableViewState="false"></asp:Literal></a>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </asp:PlaceHolder>
        <% End If%>
            </div>
        </asp:PlaceHolder>
    </ContentTemplate>
</asp:UpdatePanel>
<!--
===============================
MINI BASKET
===============================
-->
<asp:UpdatePanel ID="updPnlMiniBasket" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:PlaceHolder ID="phdMiniBasket" runat="server" Visible="false">
            <user:PopupMessage ID="popMessage2" runat="server" />
            <script type="text/javascript" language="javascript">
                //<![CDATA[
                function ShowAddToBasketPopup(strDelayValue) {
                    if (isNaN(strDelayValue)) {
                        //test//
                    }
                    else {
                        $find('UC_MiniBasket_popAddToBasket').show();
                        setTimeout("HideAddToBasketPopup()", strDelayValue);
                    }
                }

                function HideAddToBasketPopup() {
                    $find('UC_MiniBasket_popAddToBasket').hide();
                }

                function ShowCustomizePopup() {
                    $find('UC_MiniBasket_popCustomText').show();
                }
                //]]>
            </script>

            <%
                '------------------------------------------
                'MINIBASKET
                'We have two types of minibasket display.
                'The 'compactversion' is a one-line summary
                'that has the basket link, number of items
                'and total price. The full version contains
                'basket title, lines for each item in the
                'basket, any discounts or price modifiers,
                'full total, and (depending on other
                'settings) extra related links.
    
                'See these config settings:
    
                'frontend.minibasket.hidelinks
                'frontend.minibasket.hiderows
                'frontend.minibasket.compactversion
                'frontend.minibasket.countversions
                '------------------------------------------
            %>
            <%  If KartSettingsManager.GetKartConfig("frontend.minibasket.compactversion") = "y" Then%>
            <div class="compactminibasket">
                <asp:Literal ID="litCompactShoppingBasket" runat="server" EnableViewState="false" />
            </div>
            <%  Else 'not compactversion %>

            <div class="compactminibasket show-for-touch" style="display: none;">
                <asp:Literal ID="litCompactShoppingBasket2" runat="server" EnableViewState="false" />
            </div>

            <div id="minibasket" class="infoblock hide-for-touch">
                <div id="minibasket_header">
                    <h4>
                        <asp:Literal ID="litShoppingBasketTitle" runat="server"
                            EnableViewState="false" />
                    </h4>
                </div>
                <div id="minibasket_main">
                    <div id="contents" class="hide-for-touch">
                        <div class="box">
                            <asp:PlaceHolder ID="phdOrderInProgress" runat="server" Visible="false">
                                <div id="orderinprogress">
                                    <asp:Literal ID="litOrderInProgress" runat="server" Text="<%$Resources:Kartris, ContentText_MinibasketHidden%>"
                                        EnableViewState="false" />
                                </div>
                            </asp:PlaceHolder>
                            <asp:PlaceHolder ID="phdMiniBasketContent" runat="server" Visible="false">
                                <ul>
                                    <% If KartSettingsManager.GetKartConfig("frontend.minibasket.hiderows") <> "y" Then%>
                                    <asp:Repeater ID="rptMiniBasket" runat="server">
                                        <ItemTemplate>
                                            <li class="minibasket_item">
                                                <asp:HyperLink ID="lnkMiniBasketProduct" runat="server" Text='<%# Server.HTMLEncode(Eval("Quantity") & " x " &  Eval("ProductName")) %>'></asp:HyperLink>
                                            </li>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    <asp:PlaceHolder ID="phdMiniBasketPromotions" runat="server">
                                        <li id="minibasket_promotions">
                                            <asp:HyperLink ID="lnkMiniBasketPromotions" runat="server">
                                                <asp:Literal ID="litPromotions" runat="server" Text='<%$Resources:Kartris,SubHeading_Promotions%>'
                                                    EnableViewState="false"></asp:Literal>
                                            </asp:HyperLink>
                                        </li>
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder ID="phdMiniBasketCouponDiscount" runat="server">
                                        <li id="minibasket_coupondiscount">
                                            <asp:HyperLink ID="lnkMiniBasketCouponDiscount" runat="server">
                                                <asp:Literal ID="litCouponDiscount2" runat="server" Text='<%$Resources:Kartris,ContentText_CouponDiscount%>'
                                                    EnableViewState="false"></asp:Literal>
                                            </asp:HyperLink>
                                        </li>
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder ID="phdMiniBasketCustomerDiscount" runat="server">
                                        <li id="minibasket_customerdiscount">
                                            <asp:HyperLink ID="lnkMiniBasketCustomerDiscount" runat="server">
                                                <asp:Literal ID="litCustomerDiscount" runat="server" Text='<%$Resources:Kartris,ContentText_CustomerDiscount%>'></asp:Literal>
                                            </asp:HyperLink>
                                        </li>
                                    </asp:PlaceHolder>
                                    <% End If%>
                                    <li id="totals">
                                        <asp:PlaceHolder ID="phdMiniBasketTax" runat="server">
                                            <div id="minibasket_total_1">
                                                <asp:Literal ID="litMiniBasketTax1" runat="server" />
                                            </div>
                                            <div id="minibasket_total_2">
                                                <asp:Literal ID="litMiniBasketTax2" runat="server" />
                                            </div>
                                            <div id="minibasket_whereapplicable">
                                                <asp:Literal ID="litMiniBasketApplicable" runat="server" Text='<%$Resources:Kartris,ContentText_MiniBasket_WhereApplicable%>'
                                                    EnableViewState="false" />
                                            </div>
                                        </asp:PlaceHolder>
                                        <asp:PlaceHolder ID="phdMiniBasketTotal" runat="server">
                                            <asp:Literal ID="litMiniBasketTotal" runat="server" />
                                        </asp:PlaceHolder>
                                    </li>
                                </ul>
                            </asp:PlaceHolder>
                            <asp:PlaceHolder ID="phdMiniBasketEmpty" runat="server" Visible="false">
                                <div id="basketisempty">
                                    <asp:Literal ID="litMiniBasketIsEmpty" runat="server" Text="<%$Resources:Kartris, ContentText_MinibasketIsEmpty%>"
                                        EnableViewState="false" />
                                </div>
                            </asp:PlaceHolder>
                        </div>
                    </div>
                    <% If KartSettingsManager.GetKartConfig("frontend.minibasket.hidelinks") <> "y" Then%>
                    <asp:PlaceHolder ID="phdMiniBasketLinks" runat="server" Visible="true">
                        <div id="links" class="hide-for-touch">
                            <ul id="basketlinks">
                                <li><a class="button" href="<%=CkartrisBLL.WebShopURL%>Basket.aspx" id="basket_button">
                                    <asp:Literal ID="litViewBasket" runat="server" Text="<%$ Resources:Kartris, ContentText_MinibasketViewBasket  %>"
                                        EnableViewState="false"></asp:Literal>
                                </a></li>
                                <% If BasketItems.Count > 0 Then%>
                                <li><a class="button" href="<%=CkartrisBLL.WebShopURL%>Checkout.aspx" id="checkout_button">
                                    <asp:Literal ID="litCheckout" runat="server" Text="<%$ Resources:Kartris, ContentText_MinibasketCheckout  %>"
                                        EnableViewState="false"></asp:Literal>
                                </a></li>
                                <%End If%>
                                <li><a class="button" href="<%=CkartrisBLL.WebShopURL%>Contact.aspx" id="enquiry_button">
                                    <asp:Literal ID="litEnquiry" runat="server" Text="<%$ Resources:Kartris, ContentText_MinibasketMakeEnquiry  %>"
                                        EnableViewState="false"></asp:Literal>
                                </a></li>
                                <% If BasketItems.Count > 0 Then%>
                                <li><a class="button" href="<%=CkartrisBLL.WebShopURL%>Customer.aspx?action=savebasket" id="saverecoverbasket_button">
                                    <asp:Literal ID="litSaveRecoverBasket" runat="server" Text="<%$ Resources:Kartris, ContentText_MinibasketSaveBasket  %>"
                                        EnableViewState="false"></asp:Literal>
                                </a></li>
                                <%If KartSettingsManager.GetKartConfig("frontend.users.wishlists.enabled") <> "n" Then%>
                                <li><a class="button" href="<%=CkartrisBLL.WebShopURL%>Customer.aspx?action=wishlists" id="wishlist_button">
                                    <asp:Literal ID="litWishlist" runat="server" Text="<%$ Resources:Kartris, ContentText_MinibasketWishList  %>"
                                        EnableViewState="false"></asp:Literal>
                                </a></li>
                                <% End If%>
                                <%End If%>
                            </ul>
                        </div>
                    </asp:PlaceHolder>
                    <% End If 'hidelinks %>
                </div>
            </div>
            <% End If 'compactversion%>
        </asp:PlaceHolder>
    </ContentTemplate>
</asp:UpdatePanel>
<!--
===============================
ADD TO BASKET POPUP
===============================
-->
<asp:UpdatePanel ID="updPnlAddToBasket" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Timer ID="tmrAddToBasket" runat="server">
        </asp:Timer>
        <asp:Panel ID="pnlAddToBasket" runat="server" Style="display: none" CssClass="popup popup_addtobasket">
            <h2>
                <asp:Literal ID="litSubHeadingInformation" runat="server" Text='<%$ Resources: Kartris, SubHeading_Information %>'
                    EnableViewState="false" /></h2>
            <p>
                <asp:Literal ID="litContentTextItemsAdded" runat="server" Text='<%$ Resources: Basket, ContentText_ItemsAdded %>'
                    EnableViewState="false" />
            </p>
            <asp:Button ID="btnDummy" runat="server" Text="dummy" CssClass="invisible" />
            <asp:LinkButton ID="btnCancel" runat="server" Text="X" CssClass="closebutton" />
        </asp:Panel>
        <ajaxToolkit:ModalPopupExtender ID="popAddToBasket" runat="server" TargetControlID="btnDummy"
            PopupControlID="pnlAddToBasket" BackgroundCssClass="popup_background" OkControlID="btnDummy"
            CancelControlID="btnCancel" DropShadow="False">
        </ajaxToolkit:ModalPopupExtender>
    </ContentTemplate>
</asp:UpdatePanel>
