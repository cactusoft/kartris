<%@ Control Language="VB" AutoEventWireup="false" CodeFile="Invoice.ascx.vb" Inherits="UserControls_General_Invoice" %>
<div id="invoice">
    <h1>
        <asp:Literal ID="litPageTitleInvoice" runat="server" Text='<%$ Resources: Invoice, PageTitle_Invoice %>' /></h1>
    <div id="topinfo">
        <div class="box">
            <div class="pad">
                <strong>
                    <asp:Literal ID="litBillingAddress" runat="server" Text='<%$ Resources: Address, FormLabel_BillingAddress %>' /></strong>
                <asp:Literal ID="litBilling" runat="server" Text="" />
            </div>
        </div>
        <div class="box">
            <div class="pad">
                <strong><asp:Literal ID="litShippingAddress" runat="server" Text='<%$ Resources: Address, FormLabel_ShippingAddress %>' /></strong>
                <asp:Literal ID="litShipping" runat="server" Text="" />
            </div>
        </div>
        <div class="box">
            <div class="pad">
                <strong>
                    <asp:Literal ID="litInvoiceDetails" runat="server" Text='<%$ Resources: Invoice, ContentText_InvoiceDetails %>' /></strong>
                <div class="label">
                    <asp:Literal ID="lblOrderID" runat="server" Text='<%$ Resources: _Orders, ContentText_OrderID %>' /></div>
                <div class="value">
                    <asp:Literal ID="litOrderID" runat="server" Text="" />&nbsp;</div>
                <div class="label">
                    <asp:Literal ID="litContentText_PONumber" runat="server" Text='<%$ Resources: Invoice, ContentText_PONumber %>' /></div>
                <div class="value">
                    <asp:Literal ID="litPONumber" runat="server" Text="" />&nbsp;</div>
                <div class="label">
                    <asp:Literal ID="lblCustomerID" runat="server" Text='<%$ Resources: _Customers, FormLabel_CustomerID %>' /></div>
                <div class="value">
                    <asp:Literal ID="litCustomerID" runat="server" Text="" />&nbsp;</div>
                <div class="label">
                    <asp:Literal ID="lblInvoiceDate" runat="server" Text='<%$ Resources: FormLabel_InvoiceDate %>' /></div>
                <div class="value">
                    <asp:Literal ID="litInvoiceDate" runat="server" Text="" />&nbsp;</div>
                <div class="label">
                    <asp:Literal ID="litEUVATNumber" runat="server" Text='<%$ Resources: Invoice, FormLabel_CardholderEUVatNum %>' /></div>
                <div class="value">
                    <asp:Literal ID="litVatNumber" runat="server" Text="" />&nbsp;</div>
            </div>
        </div>
        <asp:PlaceHolder ID="phdOrderComments" runat="server" Visible="false">
            <div class="box" id="customercomments">
                <div class="pad">
                    <strong>
                        <asp:Literal ID="litOrderCommentsLabel" runat="server" Text='<%$ Resources: Checkout, SubTitle_Comments %>' /></strong>
                    <asp:Literal ID="litOrderComments" runat="server" Text="" />
                </div>
            </div>
        </asp:PlaceHolder>
    </div>
    <div id="midinfo">
        <asp:Repeater ID="rptInvoice" runat="server">
            <HeaderTemplate>
                <table id="invoiceitems">
                <thead>
                    <tr>
                        <th></th>
                        <% If APP_ShowTaxDisplay Then%>
                        <th>
                            <asp:Literal ID="litContentTextExTax" runat="server" Text='<%$ Resources: Kartris, ContentText_ExTax %>' />&nbsp;
                        </th>
                        <th>
                            <asp:Literal ID="litContentTextTaxPerItem" runat="server" Text='<%$ Resources: Kartris, ContentText_Tax %>' />&nbsp;
                        </th>
                        <% Else%>
                        <th>
                            <asp:Literal ID="litContentTextPrice" runat="server" Text='<%$ Resources: Kartris, ContentText_Price %>' />&nbsp;
                        </th>
                        <% End If%>
                        <th>
                            <asp:Literal ID="litContentTextQty" runat="server" Text='<%$ Resources: Basket, ContentText_Qty %>' />
                        </th>
                        <% If APP_ShowTaxDisplay Then%>
                        <th>
                            <asp:Literal ID="litContentTextTotal1" runat="server" Text='<%$ Resources: Basket, ContentText_Total %>' />
                        </th>
                        <th>
                            <asp:Literal ID="litContentTextTax" runat="server" Text='<%$ Resources: Kartris, ContentText_Tax %>' />&nbsp;
                        </th>
                        <% End If%>
                        <th>
                            <asp:Literal ID="litContentTextTotal2" runat="server" Text='<%$ Resources: Basket, ContentText_Total %>' />
                        </th>
                    </tr>
                    </thead>
                    <tbody>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td colspan='<% =numColumns%>' class="fullline">
                        <asp:Literal ID="litVersionName" runat="server" Text='' />
                    </td>
                </tr>
                <tr>
                    <td class="col1">
                        <asp:Literal ID="litVersionCode" runat="server" Text='' />

                        <div>
                            <asp:Literal ID="litCustomizationOptionText" runat="server" Text='' /></div>
                    </td>
                    <% If APP_ShowTaxDisplay Then%>
                    <td>
                        <asp:Literal ID="litItemPriceExTax" runat="server" Text='' />
                    </td>
                    <td>
                        <asp:Literal ID="litTaxPerItem" runat="server" Text='' />
                    </td>
                    <% Else%>
                    <td>
                        <asp:Literal ID="litItemPrice" runat="server" Text='' />&nbsp;
                    </td>
                    <% End If%>

                    <td>
                        <asp:Literal ID="litQuantity" runat="server" Text='' />
                    </td>
                    <% If APP_ShowTaxDisplay Then%>
                    <td>
                        <asp:Literal ID="litRowPriceExTax" runat="server" Text='' />
                    </td>
                    <td>
                        <asp:Literal ID="litTaxAmount" runat="server" Text='' />
                    </td>
                    <% End If%>
                    <td class="bold">
                        <asp:Literal ID="litRowPriceIncTax" runat="server" Text='' />
                    </td>
                </tr>
            </ItemTemplate>
            <FooterTemplate>
                <asp:PlaceHolder ID="phdPromotionDiscount" runat="server" Visible="false">
                    <tr>
                        <td colspan='<% =numColumns%>' class="fullline section">
                            <asp:Literal ID="litContentTextPromotionDiscount" runat="server" Text='<%$ Resources: Kartris, ContentText_PromotionDiscount %>' />
                        </td>
                    </tr>
                    <tr>
                        <td class="col1">
                            <asp:Literal ID="litPromoDesc" runat="server" Text='' />
                        </td>
                        <% If APP_ShowTaxDisplay Then%>
                        <td>
                            <asp:Literal ID="litPromoDiscountExTax" runat="server" Text='' />
                        </td>
                        <td>
                            <asp:Literal ID="litPromoTaxPerItem" runat="server" Text='' />
                        </td>
                        <% Else%>
                        <td>
                            <asp:Literal ID="litPromoItemPrice" runat="server" Text='' />
                        </td>
                        <% End If%>
                        <td>1
                        </td>
                        <% If APP_ShowTaxDisplay Then%>
                        <td>
                            <asp:Literal ID="litPromoDiscountTotal1" runat="server" Text='' />
                        </td>
                        <td>
                            <asp:Literal ID="litPromoDiscountTaxAmount" runat="server" Text='' />
                        </td>
                        <% End If%>
                        <td class="bold">
                            <asp:Literal ID="litPromoDiscountTotal2" runat="server" Text='' />
                        </td>
                    </tr>
                </asp:PlaceHolder>
                <asp:PlaceHolder ID="phdCouponDiscount" runat="server" Visible="false">
                    <tr>
                        <td colspan='<% =numColumns%>' class="fullline section">
                            <asp:Literal ID="litContentTextCouponDiscount" runat="server" Text='<%$ Resources: Kartris, ContentText_CouponDiscount %>' />
                        </td>
                    </tr>
                    <tr>
                        <td class="col1">
                            <asp:Literal ID="litCouponCode" runat="server" Text='' />
                        </td>
                        <% If APP_ShowTaxDisplay Then%>
                        <td>
                            <asp:Literal ID="litCouponDiscountExTax" runat="server" Text='' />
                        </td>
                        <td>
                            <asp:Literal ID="litCouponDiscountTaxPerItem" runat="server" Text='' />
                        </td>
                        <% Else%>
                        <td>
                            <asp:Literal ID="litCouponDiscountPrice" runat="server" Text='' />
                        </td>
                        <% End If%>
                        <td>
                            1
                        </td>
                        <% If APP_ShowTaxDisplay Then%>
                        <td>
                            <asp:Literal ID="litCouponDiscountTotal1" runat="server" Text='' />
                        </td>
                        <td>
                            <asp:Literal ID="litCouponDiscountTaxAmount" runat="server" Text='' />
                        </td>
                        <% End If%>
                        <td class="bold">
                            <asp:Literal ID="litCouponDiscountTotal2" runat="server" Text='' />
                        </td>
                    </tr>
                </asp:PlaceHolder>
                <asp:PlaceHolder ID="phdCustomerDiscount" runat="server" Visible="false">
                    <tr>
                        <td colspan='<% =numColumns%>' class="fullline section">
                            <asp:Literal ID="litContentTextDiscount" runat="server" Text='<%$ Resources: Basket, ContentText_Discount %>' />
                            <asp:Literal ID="litContentTextExcludedItems" runat="server"></asp:Literal>
                        </td>
                    </tr>
                    <tr>
                        <td class="col1">
                            <asp:Literal ID="litDiscountPercentage" runat="server" Text='' />
                        </td>
                        <% If APP_ShowTaxDisplay Then%>
                        <td>
                            <asp:Literal ID="litCustomerDiscountExTax" runat="server" Text='' />
                        </td>
                        <td>
                            <asp:Literal ID="litCustomerDiscountTaxPerItem" runat="server" Text='' />
                        </td>
                        <% Else%>
                        <td>
                            <asp:Literal ID="litCustomerDiscountPrice" runat="server" Text='' />
                        </td>
                        <% End If%>
                        <td>
                            1
                        </td>
                        <% If APP_ShowTaxDisplay Then%>
                        <td>
                            <asp:Literal ID="litCustomerDiscountTotal1" runat="server" Text='' />
                        </td>
                        <td>
                            <asp:Literal ID="litCustomerDiscountTaxAmount" runat="server" Text='' />
                        </td>
                        <% End If%>
                        <td class="bold">
                            <asp:Literal ID="litCustomerDiscountTotal2" runat="server" Text='' />
                        </td>
                    </tr>
                </asp:PlaceHolder>
                <asp:PlaceHolder ID="phdShippingCost" runat="server" Visible="false">
                    <tr>
                        <td colspan='<% =numColumns%>' class="fullline section">
                            <asp:Literal ID="litContentTextShipping" runat="server" Text='<%$ Resources: Address, ContentText_Shipping %>' />
                        </td>
                    </tr>
                    <tr>
                        <td class="col1">
                            <asp:Literal ID="litShippingMethod" runat="server" Text='' />
                        </td>
                        <% If APP_ShowTaxDisplay Then%>
                        <td>
                            <asp:Literal ID="litShippingPriceExTax" runat="server" Text='' />
                        </td>
                        <td>
                            <asp:Literal ID="litShippingTaxPerItem" runat="server" Text='' />
                        </td>
                        <% Else%>
                        <td>
                            <asp:Literal ID="litShippingPrice" runat="server" Text='' />
                        </td>
                        <% End If%>
                        <td>
                            1
                        </td>
                        <% If APP_ShowTaxDisplay Then%>
                        <td>
                            <asp:Literal ID="litShippingPriceTotal1" runat="server" Text='' />
                        </td>
                        <td>
                            <asp:Literal ID="litShippingTaxAmount" runat="server" Text='' />
                        </td>
                        <% End If%>
                        <td class="bold">
                            <asp:Literal ID="litShippingPriceTotal2" runat="server" Text='' />
                        </td>
                    </tr>
                </asp:PlaceHolder>
                <asp:PlaceHolder ID="phdOrderHandlingCharge" runat="server" Visible="false">
                    <tr>
                        <td colspan='<% =numColumns%>' class="fullline section">
                            <asp:Literal ID="litContentTextOrderHandlingCharge" runat="server" Text='<%$ Resources: Kartris, ContentText_OrderHandlingCharge %>' />
                        </td>
                    </tr>
                    <tr>
                        <td class="col1">
                        </td>
                        <% If APP_ShowTaxDisplay Then%>
                        <td>
                            <asp:Literal ID="litOrderHandlingPriceExTax" runat="server" Text='' />
                        </td>
                        <td>
                            <asp:Literal ID="litOrderHandlingTaxPerItem" runat="server" Text='' />
                        </td>
                        <% Else%>
                        <td>
                            <asp:Literal ID="litOrderHandlingPrice" runat="server" Text='' />
                        </td>
                        <% End If%>
                        <td>
                            1
                        </td>
                        <% If APP_ShowTaxDisplay Then%>
                        <td>
                            <asp:Literal ID="litOrderHandlingPriceTotal1" runat="server" Text='' />
                        </td>
                        <td>
                            <asp:Literal ID="litOrderHandlingPriceTaxTotal" runat="server" Text='' />
                        </td>
                        <% End If%>
                        <td class="bold">
                            <asp:Literal ID="litOrderHandlingPriceTotal2" runat="server" Text='' />
                        </td>
                    </tr>
                </asp:PlaceHolder>
                <tr id="total">
                    <td class="col1">
                        <asp:Literal ID="litContentTextTotal" runat="server" Text='<%$ Resources: Basket, ContentText_Total %>' />
                    </td>
                    <% If APP_ShowTaxDisplay Then%>
                    <td></td>
                    <td></td>
                    <% Else%>
                    <td></td>
                    <% End If%>
                    <td></td>
                    <% If APP_ShowTaxDisplay Then%>
                    <td>
                        <asp:Literal ID="litTotalExTax" runat="server" Text='' />
                    </td>
                    <td>
                        <asp:Literal ID="litTotalTaxAmount" runat="server" Text='' />
                    </td>
                    <% End If%>
                    <td>
                        <asp:Literal ID="litTotal" runat="server" Text='' />
                    </td>
                </tr>
                <tr id="currency">
                    <td colspan='<% =numColumns%>'>
                        <asp:Literal ID="litCurrencyDescription" runat="server"  />
                    </td>
                </tr>
                <!-- total paid at gateway -->
                <asp:PlaceHolder ID="phdTotalGateway" runat="server" Visible="false">
                    <tr class="footerrow">
                        <td class="total" colspan='<% =numColumns%>'>
                            <span class="totallabel">
                                <asp:Literal ID="litEmailTextProcessCurrencyExp1" runat="server" Text='<%$ Resources: Email, EmailText_ProcessCurrencyExp1 %>' /></span>
                            <asp:Literal ID="litTotalGateway" runat="server" Text='' />
                        </td>
                    </tr>
                </asp:PlaceHolder>
                <tbody></table>
            </FooterTemplate>
        </asp:Repeater>
    </div>
</div>
