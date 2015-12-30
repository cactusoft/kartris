<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_BasketView.ascx.vb"
    Inherits="Back_BasketView" %>
<%@ Register TagPrefix="_user" TagName="ShippingMethodsDropDown" Src="~/UserControls/Back/_ShippingMethodsDropdown.ascx" %>
<!-- customize popup -->
<asp:UpdatePanel ID="updPnlCustomText" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Panel ID="pnlCustomText" runat="server" Style="display: none" CssClass="popup popup_customization">
            <!-- Customization Window Title and Close Button -->
            <h2>
                <asp:Literal ID="litContentTextCustomization" runat="server" Text='<%$ Resources: Kartris, ContentText_Customization %>'
                    EnableViewState="false" /></h2>
            <asp:LinkButton ID="lnkClose" runat="server" Text="" CssClass="closebutton" />
            <div>
                <!-- Cancel Customization Link -->
                <asp:PlaceHolder ID="phdCustomizationCancel" runat="server" Visible="True">
                    <p>
                        <asp:LinkButton ID="btnCancelCustomText" runat="server" CssClass="linkbutton icon_delete"
                            Text='<%$ Resources: Kartris, ContentText_CustomizeNoThanks %>' /></p>
                </asp:PlaceHolder>
                <!-- Customization Explanation -->
                <p>
                    <asp:Literal ID="litContentTextCustomizationExplanation" runat="server" Text='<%$ Resources: Kartris, ContentText_CustomizationExplanation %>'
                        EnableViewState="false" /></p>
                <!-- Description Text -->
                <div>
                    <br />
                    <asp:Label ID="lblCustomDesc" runat="server" AssociatedControlID="txtCustomText"
                        CssClass="nolabelwidth"></asp:Label>
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
<!-- main basket -->
<asp:UpdatePanel ID="updPnlMainBasket" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:PlaceHolder ID="phdMainBasket" runat="server" Visible="false">
            <div class="basket">
                <asp:Literal ID="litSpeedError" runat="server"></asp:Literal>
                <asp:Literal ID="litCouponError" runat="server"></asp:Literal>
                <div class='errors'>
                    <strong>
                        <asp:Literal ID="litBasketEmpty" runat="server"></asp:Literal></strong></div>
                <asp:Literal ID="litError" runat="server"></asp:Literal>
                <user:PopupMessage ID="popMessage" runat="server" />
                <asp:Panel ID="pnlEmptyBasket" runat="server" Style="display: none; width: 450px"
                    CssClass="popup">
                    <h2>
                        <asp:Literal ID="litPageTitleShoppingBasket" EnableViewState="false" runat="server"
                            Text='<%$ Resources: Basket, PageTitle_ShoppingBasket %>' /></h2>
                    <p>
                        <asp:Literal ID="litContentTextEmptyShoppingBasketConfirm" EnableViewState="false"
                            runat="server" Text='<%$ Resources: Basket, ContentText_EmptyShoppingBasketConfirm %>' /></p>
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
                                            <th class="name" colspan="2">
                                                <asp:Literal ID="litContentTextNameDetails" runat="server" Text='<%$ Resources: Kartris, ContentText_NameDetails %>'
                                                    EnableViewState="false"></asp:Literal>
                                            </th>
                                            <% If APP_PricesIncTax Then%>
                                            <% If APP_ShowTaxDisplay Or ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then%>
                                            <th class="extax">
                                                <asp:Literal ID="litContentTextExTax1" runat="server" Text='<%$ Resources: Kartris, ContentText_ExTax %>'
                                                    EnableViewState="false"></asp:Literal>
                                            </th>
                                            <th class="inctax">
                                                <asp:Literal ID="litIContentTextncTax1" runat="server" Text='<%$ Resources: Kartris, ContentText_IncTax %>'
                                                    EnableViewState="false"></asp:Literal>
                                            </th>
                                            <% Else%>
                                            <th class="price" colspan="2">
                                                <asp:Literal ID="litContentTextPrice1" runat="server" Text='<%$ Resources: Kartris, ContentText_Price %>'
                                                    EnableViewState="false"></asp:Literal>
                                            </th>
                                            <% End If%>
                                            <% Else 'Ex Tax %>
                                            <% If APP_ShowTaxDisplay Or (ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET And APP_USMultiStateTax = False) Then%>
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
                                            <% If ViewType = BasketBLL.VIEW_TYPE.MAIN_BASKET Then%>
                                            <th class="remove">
                                            </th>
                                            <% Else%>
                                            <th class="total">
                                                <asp:Literal ID="litContentTextTotal1" runat="server" Text='<%$ Resources: Basket, ContentText_Total %>'></asp:Literal>
                                            </th>
                                            <% End If%>
                                            <th>&nbsp;</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr class="product_row">
                                    <td colspan="2">
                                        <div class="name" style="cursor: pointer;">
                                            <strong>
                                                <asp:LinkButton ID="lnkBtnProductName" runat="server" Text='<%# Server.HtmlEncode(Eval("ProductName")) %>'
                                                    OnCommand="ProductName_Click" CommandArgument='<%#Eval("ID") & ";" & eval("VersionID") & ";" & eval("Quantity") & ";" & eval("ProductType") %> ' /></strong>
                                            <asp:LinkButton ID="lnkCustomize" CssClass="link2 icon_new" runat="server" CommandName="Customize"
                                                CommandArgument='<%#Eval("ID")%>' OnCommand="CustomText_Click" Text="<%$ Resources: Basket, ContentText_Customize %>" /></div>
                                        <div class="spacer">
                                        </div>
                                        <div class="details">
                                            <% If KartSettingsManager.GetKartConfig("backend.basket.showimages") = "y" Then%>
                                            <user:ProductTemplateImageOnly ID="ProductTemplateImageOnly1" runat="server" />
                                            <% End If%>
                                            <div class="info">
                                                <asp:PlaceHolder ID="phdProductType1" runat="server" Visible="false">
                                                    <asp:Literal ID="litCodeNumber" runat="server" Text='<%# Server.HtmlEncode(Eval("CodeNumber")) %>' />
                                                </asp:PlaceHolder>
                                                <asp:PlaceHolder ID="phdProductType2" runat="server" Visible="false">
                                                    <asp:PlaceHolder ID="phdItemHasCombinations" runat="server" Visible="false">
                                                        <%#Eval("OptionText")%>
                                                    </asp:PlaceHolder>
                                                    <asp:PlaceHolder ID="phdItemHasNoCombinations" runat="server" Visible="false">
                                                        <asp:Literal ID="litVersionName" runat="server" Text='<%# Server.HtmlEncode(Eval("VersionName")) %>' />
                                                    </asp:PlaceHolder>
                                                    (<asp:Literal ID="litCodeNumber2" runat="server" Text='<%# Server.HtmlEncode(Eval("CodeNumber")) %>' />)
                                                </asp:PlaceHolder>
                                            </div>
                                        </div>
                                        <div class="spacer">
                                        </div>
                                    </td>
                                    <% If APP_PricesIncTax Then%>
                                    <% If APP_ShowTaxDisplay Or ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then%>
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
                                    <% If APP_ShowTaxDisplay Or (ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET And APP_USMultiStateTax = False) Then%>
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
                                        <%	If ViewOnly Then%>
                                        <%#Eval("Quantity")%>
                                        <%	Else%>
                                        <asp:UpdatePanel runat="server" ID="updItemQuantity">
                                            <ContentTemplate>
                                                <asp:Literal ID="litProductID_H" runat="server" Text='<%# Eval("ProductID") %>' Visible="false" />
                                                    <% If ObjectConfigBLL.GetValue("K:product.decimalquantity", CLng(litProductID_H.Text)) = 1 Then%>
                                                <ajaxToolkit:FilteredTextBoxExtender ID="filDecimalQuantity" runat="server" TargetControlID="txtQuantity"
                                                    FilterType="Numbers,Custom" ValidChars=".">
                                                </ajaxToolkit:FilteredTextBoxExtender>
                                                <% Else%>
                                                <ajaxToolkit:FilteredTextBoxExtender ID="filQuantity" runat="server" TargetControlID="txtQuantity"
                                                    FilterType="Numbers">
                                                </ajaxToolkit:FilteredTextBoxExtender>
                                                <% End If%>
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
                                        <%	End If%>
                                    </td>
                                    <td class="total">
                                        <% If APP_USMultiStateTax Then%>
                                        <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Eval("RowExTax"))%>
                                        <% Else%>
                                        <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Eval("RowIncTax"))%>
                                        <% End If%>
                                    </td>
                                    <td class="remove">
                                        <asp:LinkButton CssClass="link2 icon_delete" ID="lnkBtnRemoveItem" OnCommand="RemoveItem_Click"
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
                                    <tr class="promotiondiscountrow">
                                        <td colspan="2">
                                            <div class="name">
                                                <strong>
                                                    <asp:Literal ID="litPromotionDiscount" runat="server" Text='<%$ Resources: Basket, ContentText_Promotion %>'
                                                        EnableViewState="false"></asp:Literal></strong></div>
                                            <div class="details">
                                                <%#Server.HtmlEncode(Eval("Name"))%></div>
                                        </td>
                                        <% If APP_PricesIncTax Then%>
                                        <% If APP_ShowTaxDisplay Or ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then%>
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
                                        <%	If APP_ShowTaxDisplay Or (ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET And APP_USMultiStateTax = False) Then%>
                                        <td class="extax">
                                            <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, CDbl(Eval("ExTax")))%>
                                        </td>
                                        <td class="tax">
                                            <%# CDbl(Eval("ComputedTaxRate") * 100)%>%
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
                                        <td class="total">
                                            <% If APP_USMultiStateTax Then%>
                                            <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, CDbl(Eval("TotalExTax")))%>
                                            <% Else%>
                                            <%#CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, CDbl(Eval("TotalIncTax")))%>
                                            <% End If%>
                                        </td>
                                        <td>
                                            &nbsp;
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </asp:PlaceHolder>
                        <%=""%>
                        <!-- Coupon Row -->
                        <% If Basket.CouponDiscount.IncTax < 0 Then%>
                        <tr class="couponrow">
                            <td colspan="2">
                                <div class="name">
                                    <strong>
                                        <asp:Literal ID="litCouponDiscount" runat="server" Text='<%$Resources:Kartris,ContentText_CouponDiscount%>'
                                            EnableViewState="false"></asp:Literal></strong>
                                </div>
                                <div class="details">
                                    <div class="info">
                                        <%=Basket.CouponName%></div>
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
                            <%	If APP_ShowTaxDisplay Or (ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET And APP_USMultiStateTax = False) Then%>
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
                            <td class="quantity">
                                1
                            </td>
                            <td class="total">
                                <% If APP_USMultiStateTax Then%>
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CouponDiscount.ExTax)%>
                                <% Else%>
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CouponDiscount.IncTax)%>
                                <% End If%>
                            </td>
                            <td class="remove">
                                <asp:LinkButton ID="lnkBtnRemoveCoupon" OnCommand="RemoveCoupon_Click" CommandName="RemoveCoupon"
                                    CommandArgument="" CssClass="link2 icon_delete" runat="server" ToolTip='<%$ Resources: Basket, FormButton_Remove %>'
                                    Text=""></asp:LinkButton>
                            </td>
                        </tr>
                        <% End If%>
                        <!-- Customer Discount Row -->
                        <% If BSKT_CustomerDiscount > 0 Then%>
                        <tr class="customerdiscountrow">
                            <td colspan="2">
                                <div class="name">
                                    <strong>
                                        <asp:Literal ID="litContentTextDiscount" runat="server" Text='<%$ Resources: Basket, ContentText_Discount %>'
                                            EnableViewState="false"></asp:Literal></strong>
                                </div>
                                <div class="details">
                                    <div class="info">
                                        <%=BSKT_CustomerDiscount%>%</div>
                                </div>
                            </td>
                            <%'Inc Tax%>
                            <% If APP_PricesIncTax Then%>
                            <% If APP_ShowTaxDisplay Or ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then%>
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
                            <% If APP_ShowTaxDisplay Or (ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET And APP_USMultiStateTax = False) Then%>
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
                            <td class="quantity">
                                1
                            </td>
                            <td class="total">
                                <% If APP_USMultiStateTax Then%>
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CustomerDiscount.ExTax)%>
                                <% Else%>
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.CustomerDiscount.IncTax)%>
                                <% End If%>
                            </td>
                            <td>
                                &nbsp;
                            </td>
                        </tr>
                        <% End If%>
                        <!-- Shipping Method Row -->
                        <asp:PlaceHolder ID="phdShipping" runat="server" Visible="false">
                            <tr class="shippingrow">
                                <td colspan="2">
                                    <div class="name">
                                        <strong>
                                            <asp:Literal ID="litContentTextShipping" runat="server" Text='<%$ Resources: Address, ContentText_Shipping %>'
                                                EnableViewState="false"></asp:Literal></strong>
                                    </div>
                                    <div class="details">
                                        <div class="info">
                                            <asp:PlaceHolder ID="phdShippingSelection" runat="server" Visible="false">
                                                <_user:ShippingMethodsDropDown ID="UC_ShippingMethodsDropdown" runat="server" />
                                                <br />
                                            </asp:PlaceHolder>
                                            <%=""%>
                                            <%	If ViewOnly Then%>
                                            <strong>
                                                <%=Basket.ShippingName%></strong> -
                                            <% End If%><%=Basket.ShippingDescription%></div>
                                    </div>
                                </td>
                                <asp:PlaceHolder ID="phdShippingTaxHide" runat="server" Visible="false">
                                    <td colspan="5">
                                    </td>
                                </asp:PlaceHolder>
                                <asp:PlaceHolder ID="phdShippingTax" runat="server" Visible="false">
                                    <%=""%>
                                    <% If APP_PricesIncTax Then%>
                                    <% If APP_ShowTaxDisplay Or ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then%>
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
                                    <% If APP_ShowTaxDisplay Or (ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET And APP_USMultiStateTax = False) Then%>
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
                                    <td class="quantity">
                                        1
                                    </td>
                                    <td class="total">
                                        <% If APP_USMultiStateTax Then%>
                                        <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.ShippingPrice.ExTax)%>
                                        <% Else%>
                                        <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.ShippingPrice.IncTax)%>
                                        <% End If%>
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                </asp:PlaceHolder>
                            </tr>
                        </asp:PlaceHolder>
                        <!-- Order Handling Charge Row -->
                        <asp:PlaceHolder ID="phdOrderHandling" runat="server">
                            <tr class="orderhandlingrow">
                                <td colspan="2">
                                    <div class="name">
                                        <strong>
                                            <asp:Literal ID="litOrderHandlingCharge" runat="server" Text='<%$ Resources: Kartris, ContentText_OrderHandlingCharge %>'
                                                EnableViewState="false"></asp:Literal></strong>
                                    </div>
                                </td>
                                <%=""%>
                                <% If APP_PricesIncTax Then%>
                                <% If APP_ShowTaxDisplay Or ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then%>
                                <td class="extax">
                                    <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.OrderHandlingPrice.ExTax)%>
                                </td>
                                <td class="inctax">
                                    <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.OrderHandlingPrice.IncTax)%>
                                </td>
                                <%	Else%>
                                <td class="price" colspan="2">
                                    <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.OrderHandlingPrice.IncTax)%>
                                </td>
                                <% End If%>
                                <%	Else%>
                                <% If APP_ShowTaxDisplay Or (ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET And APP_USMultiStateTax = False) Then%>
                                <td class="extax">
                                    <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.OrderHandlingPrice.ExTax)%>
                                </td>
                                <td class="tax">
                                    <%=(Basket.OrderHandlingPrice.TaxRate * 100)%>%
                                </td>
                                <%	Else%>
                                <td class="price" colspan="2">
                                    <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.OrderHandlingPrice.ExTax)%>
                                </td>
                                <% End If%>
                                <% End If%>
                                <td class="quantity">
                                    1
                                </td>
                                <td class="total">
                                    <% If APP_USMultiStateTax Then%>
                                    <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.OrderHandlingPrice.ExTax)%>
                                    <% Else%>
                                    <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, Basket.OrderHandlingPrice.IncTax)%>
                                    <% End If%>
                                </td>
                                <td>
                                    &nbsp;
                                </td>
                            </tr>
                        </asp:PlaceHolder>
                        <!-- Coupon Entry Row -->
                        <%	If KartSettingsManager.GetKartConfig("frontend.orders.allowcoupons") <> "n" And Not (ViewOnly) Then%>
                        <%	If Basket.CouponName = "" Then%>
                        <tr class="applycoupon">
                            <td colspan="7">
                                <asp:UpdatePanel ID="updCoupons" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:Panel ID="pnlCoupons" runat="server" DefaultButton="btnApplyCoupon">
                                            <div class="name">
                                                <asp:Label ID="lblCouponCode" runat="server" Text='<%$ Resources: Basket, ContentText_ApplyCouponCode %>'
                                                    EnableViewState="false" AssociatedControlID="txtCouponCode"></asp:Label></div>
                                            <div class="details">
                                                <asp:TextBox MaxLength="25" ID="txtCouponCode" runat="server" Text="" AutoPostBack="false"
                                                    CssClass="couponbox"></asp:TextBox>
                                                <asp:LinkButton ID="btnApplyCoupon" CssClass="link2 icon_new" OnCommand="ApplyCoupon_Click"
                                                    CommandName="ApplyCoupon" CommandArgument="" runat="server" Text='<%$ Resources: Basket, ContentText_EnterCouponLink %>' /></div>
                                        </asp:Panel>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                        <%	End If%>
                        <%	End If%>
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
                                vFinalPriceTaxRate = Math.Round(Basket.D_Tax * 100, 2)
                            End If

                        %>
                        <!-- Show Total Tax Row if USmultistatetax is on -->
                        <%If APP_USMultiStateTax And ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then%>
                        <tr class="totals">
                            <td colspan="3" id="totaltaxrow">
                                <asp:Literal ID="litTax" runat="server" Text='<%$ Resources: Kartris, ContentText_Tax %>'
                                    EnableViewState="false" />
                            </td>
                            <td class="tax" colspan="2">
                                <%=vFinalPriceTaxRate%>%
                            </td>
                            <td class="total">
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, vFinalPriceTaxAmount)%>
                            </td>
                            <td>
                                &nbsp;
                            </td>
                        </tr>
                        <%End If%>
                        <!-- Grand Totals Rows -->
                        <tr class="footerrow">
                            <td colspan="2" id="totallabel" class="grandtotal">
                                <div class="name">
                                    <strong>
                                        <asp:Literal ID="litTotal2" runat="server" Text='<%$ Resources: Basket, ContentText_Total %>'
                                            EnableViewState="false"></asp:Literal></strong></div>
                            </td>
                            <% If APP_PricesIncTax Then%>
                            <% If APP_ShowTaxDisplay Or (ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET) Then%>
                            <td class="grandtotal extax">
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, vFinalPriceExTax)%>
                            </td>
                            <td class="grandtotal inctax">
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, vFinalPriceIncTax)%>
                            </td>
                            <%	Else%>
                            <td class="grandtotal price" colspan="2">
                            </td>
                            <% End If%>
                            <%	Else%>
                            <% If APP_ShowTaxDisplay Or (ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET And APP_USMultiStateTax = False) Then%>
                            <td class="grandtotal extax">
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, vFinalPriceExTax)%>
                            </td>
                            <td class="grandtotal tax">
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, vFinalPriceTaxAmount)%>
                            </td>
                            <% Else%>
                            <td class="grandtotal extax" colspan="2">
                                <%If Not (APP_USMultiStateTax And ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET) Then%>
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, vFinalPriceExTax)%>
                                <%End If%>
                            </td>
                            <% End If%>
                            <% End If%>
                            <td class="grandtotal total" colspan="2">
                                <%=CurrenciesBLL.FormatCurrencyPrice(SESS_CurrencyID, vFinalPriceIncTax)%>
                            </td>
                            <td class="grandtotal">
                                &nbsp;
                            </td>
                        </tr>
                        </tbody></table>
                    </div>
                    <div>
                        <asp:Literal ID="litShippingTotal" runat="server"></asp:Literal>
                        <asp:PlaceHolder ID="phdControls" runat="server" Visible="false"></asp:PlaceHolder>
                    </div>
                    <asp:PlaceHolder ID="phdBasketButtons" runat="server" Visible="true">
                        <div class="controls">
                            <div>
                                <%-- this is a dummy button, for people who haven't realized that it
                            autoposts qty updates so just need to click off qty box --%>
                                <asp:Button Text='<%$ Resources: Basket, FormButton_Recalculate %>' CssClass="button"
                                    ID="btnRecalculate" runat="server" />
                                <asp:Button Text='<%$ Resources: Basket, FormButton_EmptyBasket %>' CssClass="button"
                                    ID="btnEmptyBasket" runat="server" />
                            </div>
                        </div>
                    </asp:PlaceHolder>
                    <!-- end of form -->
                </asp:PlaceHolder>
                <% If Basket.BasketItems.Count > 0 Then%>
                <asp:PlaceHolder ID="phdPromotions" runat="server" Visible="false">
                    <div class="promotions">
                        <div class="pad">
                            <h2 class="boxheader">
                                <asp:Literal ID="litSubHeaderPromotions" runat="server" Text="<%$ Resources:Kartris, SubHeading_Promotions %>"
                                    EnableViewState="false"></asp:Literal></h2>
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

