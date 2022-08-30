<%@ Control Language="VB" AutoEventWireup="false" CodeFile="CustomerOrder.ascx.vb" Inherits="UserControls_Front_CustomerOrder" %>
<asp:PlaceHolder ID="phdViewOrder" runat="server" Visible="false">
    <div class="vieworder">
        <h2>
            <asp:Literal ID="litContentTextOrderDetails" runat="server" Text='<%$ Resources: Kartris, ContentText_OrderDetails %>' /></h2>
        <div class="Kartris-DetailsView">
            <div class="Kartris-DetailsView-Data">
                <ul>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litContentTextOrderNumber" runat="server" Text='<%$ Resources: Kartris, ContentText_OrderNumber %>' /></span><span
                            class="Kartris-DetailsView-Value"><asp:Literal ID="litOrderID" runat="server" Text='' /></span></li>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litContentText_OrderDate" runat="server" Text='<%$ Resources: Kartris, ContentText_OrderDate %>' /></span><span
                            class="Kartris-DetailsView-Value"><asp:Literal ID="litOrderDate" runat="server" Text='' /></span></li>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litContentTextTotal" runat="server" Text='<%$ Resources: Basket, ContentText_Total %>' /></span><span
                            class="Kartris-DetailsView-Value"><asp:Literal ID="litTotalPrice" runat="server"
                                Text='' /></span></li>
                    <asp:PlaceHolder ID="phOrderTracking" runat="server">
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Literal ID="litContentTextLastUpdate" runat="server" Text='<%$ Resources: Kartris, ContentText_LastUpdate %>' /></span><span
                                class="Kartris-DetailsView-Value"><asp:Literal ID="litLastModified" runat="server"
                                    Text='' /></span> </li>
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Literal ID="litContentTextOrderStatus" runat="server" Text='<%$ Resources: Kartris, ContentText_OrderStatus %>' /></span><span
                                class="Kartris-DetailsView-Value"><asp:Image ID="imgSent" runat="server" AlternateText="" /><asp:Literal
                                    ID="litContentTextOrderStatusSent" runat="server" Text='<%$ Resources: Kartris, ContentText_OrderStatusSent %>' /><br />
                                <asp:Image ID="imgInvoiced" runat="server" AlternateText="" /><asp:Literal ID="litContentTextOrderStatusInvoiced"
                                    runat="server" Text='<%$ Resources: Kartris, ContentText_OrderStatusInvoiced %>' />
                                <br />
                                <asp:Image ID="imgPaid" runat="server" AlternateText="" /><asp:Literal ID="litContentTextOrderStatusPaid"
                                    runat="server" Text='<%$ Resources: Kartris, ContentText_OrderStatusPaid %>' />
                                <br />
                                <asp:Image ID="imgShipped" runat="server" AlternateText="" /><asp:Literal ID="litContentTextOrderStatusShipped"
                                    runat="server" Text='<%$ Resources: Kartris, ContentText_OrderStatusShipped %>' />
                                <br />
                                 <asp:Image ID="imgCancelled" runat="server" AlternateText="" /><asp:Literal ID="litContentTextOrderStatusCancelled"
                                    runat="server" Text='<%$ Resources: Kartris, ContentText_OrderStatusCancelled %>' />
                            </span></li>
                    </asp:PlaceHolder>
                </ul>
            </div>
        </div>
        <asp:PlaceHolder ID="phdStatus" runat="server" Visible="false">
            <h2>
                <asp:Literal ID="litContentTextOrderProgress" runat="server" Text='<%$ Resources: Kartris, ContentText_OrderProgress %>' /></h2>
            <p>
                <asp:Literal ID="litOrderStatus" runat="server" Text='' /></p>
        </asp:PlaceHolder>
    </div>
</asp:PlaceHolder>
<div class="basket">
    <asp:Repeater ID="rptBasket" runat="server">
        <HeaderTemplate>
            <table class="baskettable">
                <thead>
                    <tr class="header">
                        <% If HttpSecureCookie.IsBackendAuthenticated Then%>
                        <th class="name">
                        </th>
                        <th class="supplier">
                            <asp:Literal ID="litSupplierNameText" runat="server" Text='<%$ Resources: _Product, FormLabel_Supplier %>' />
                        </th>
                        <%else%>
                        <th class="name" colspan="2">
                        </th>
                        <%End If%>
                        <%If APP_PricesIncTax Then%>
                        <%If APP_ShowTaxDisplay Then%>
                        <th class="extax">
                            <asp:Literal ID="litContentTextExTax" runat="server" Text='<%$ Resources: Kartris, ContentText_ExTax %>' />
                        </th>
                        <th class="inctax">
                            <asp:Literal ID="litContentTextIncTax" runat="server" Text='<%$ Resources:Kartris, ContentText_IncTax %>' />
                        </th>
                        <%Else%>
                        <th class="price" colspan="2">
                            <asp:Literal ID="litContentTextPrice" runat="server" Text='<%$ Resources: Kartris, ContentText_Price %>' />
                        </th>
                        <%End If%>
                        <%Else 'Ex Tax %>
                        <%If APP_ShowTaxDisplay Then%>
                        <th class="price">
                            <asp:Literal ID="litContentTextPrice2" runat="server" Text='<%$ Resources: Kartris, ContentText_Price %>' />
                        </th>
                        <th class="tax">
                            <asp:Literal ID="litContentTextTax" runat="server" Text='<%$ Resources: Kartris, ContentText_Tax %>' />
                        </th>
                        <% Else%>
                        <th class="price" colspan="2">
                            <asp:Literal ID="litContentTextPrice3" runat="server" Text='<%$ Resources: Kartris, ContentText_Price %>' />
                        </th>
                        <%End If%>
                        <%End If%>
                        <th class="quantity">
                            <asp:Literal ID="litContentTextQty" runat="server" Text='<%$ Resources: Basket, ContentText_Qty %>' />
                        </th>
                        <th class="total">
                            <asp:Literal ID="litContentTextTotal" runat="server" Text='<%$ Resources: Basket, ContentText_Total %>' />
                        </th>
                    </tr>
                </thead>
                <tbody>
        </HeaderTemplate>
        <ItemTemplate>
            <tr class="invoicerow">
                <td class="name" <% If HttpSecureCookie.IsBackendAuthenticated Then%>colspan="1"<%else %>colspan="2"<%end if %>>
                    <strong>
                        <asp:Literal ID="litVersionName" runat="server" Text='<%#Eval("IR_VersionName")%>' />
                        <asp:Literal ID="litMarkItemsExcludedFromCustomerDiscount" runat="server" visible='<%#Eval("IR_ExcludeFromCustomerDiscount")%>' Text=" **"/>
                    </strong><br />
                    <asp:Literal ID="litVersionCode" runat="server" Text='' />
                    <br /><div class="optionstext" style="padding-left: 10px; padding-top: 3px;">
                        <asp:Literal ID="litOptionsText" runat="server" Text='<%#Eval("IR_OptionsText")%>' />
                    </div>
                </td>
                <% If HttpSecureCookie.IsBackendAuthenticated Then%>
                <td class="supplier">
                    <asp:Literal ID="litSupplierName" runat="server" Text='<%#Eval("SupplierName")%>'></asp:Literal>
                </td>
                <%End If%>
                <asp:PlaceHolder ID="phdIncTax" runat="server" Visible="false">
                    <asp:PlaceHolder ID="phdIncTaxDisplay" runat="server" Visible="false">
                        <td class="extax">
                            <asp:Literal ID="litIncTaxPrice1" runat="server" Text='' />
                        </td>
                        <td class="inctax">
                            <asp:Literal ID="litIncTaxPrice2" runat="server" Text='' />
                        </td>
                    </asp:PlaceHolder>
                    <asp:PlaceHolder ID="phdIncTaxHide" runat="server" Visible="false">
                        <td class="price" colspan="2">
                            <asp:Literal ID="litIncTaxPrice" runat="server" Text='' />
                        </td>
                    </asp:PlaceHolder>
                    <td class="quantity">
                        <asp:Literal ID="litIncTaxQty" runat="server" Text='' />
                    </td>
                    <td class="total">
                        <asp:Literal ID="litIncTaxTotal" runat="server" Text='' />
                    </td>
                </asp:PlaceHolder>
                <asp:PlaceHolder ID="phdExTax" runat="server" Visible="false">
                    <asp:PlaceHolder ID="phdExTaxDisplay" runat="server" Visible="false">
                    <td class="price">
                        <asp:Literal ID="litExTaxPrice1" runat="server" Text='' />
                    </td>
                    <td class="tax">
                        <asp:Literal ID="litExTaxPrice2" runat="server" Text='' />
                    </td>
                        </asp:PlaceHolder>
                    <asp:PlaceHolder ID="phdExTaxHide" runat="server" Visible="false">
                        <td class="price" colspan="2">
                            <asp:Literal ID="litExTaxPrice" runat="server" Text='' />
                        </td>
                    </asp:PlaceHolder>
                    <td class="quantity">
                        <asp:Literal ID="litExTaxQty" runat="server" Text='' />
                    </td>
                    <td class="total">
                        <asp:Literal ID="litExTaxTotal" runat="server" Text='' />
                    </td>
                </asp:PlaceHolder>
            </tr>
        </ItemTemplate>
        <FooterTemplate>
            <!-- total order value -->
            <tr class="footerrow">
                <td colspan="6" class="subtotal">
                    <span class="totallabel">
                        <asp:Literal ID="litContentTextTotalOrderValue" runat="server" Text='<%$ Resources: Kartris, ContentText_TotalOrderValue %>' /></span>
                    <asp:Literal ID="litTotOrderValue" runat="server" Text='' />
                </td>
            </tr>
            <tr class="footerrow">
                <td colspan="6">
                    &nbsp;
                </td>
            </tr>
            <!-- promotion discount -->
            <asp:PlaceHolder ID="phdPromotion" runat="server" Visible="false">
                <tr class="footerrow">
                    <td colspan="6">
                        <span class="totallabel">
                            <asp:Literal ID="litContentTextPromotionDiscount" runat="server" Text='<%$ Resources: Kartris, ContentText_PromotionDiscount %>' /></span>
                        <span class="total"><asp:Literal ID="litPromotionDiscount" runat="server" Text='' /></span>
                    </td>
                </tr>
            </asp:PlaceHolder>
            <!-- coupon discount -->
            <asp:PlaceHolder ID="phdCoupon" runat="server" Visible="false">
                <tr class="footerrow">
                    <td colspan="6">
                        <span class="totallabel">
                            <asp:Literal ID="litContentTextCouponDiscount" runat="server" Text='<%$ Resources: Kartris, ContentText_CouponDiscount %>' />
                        </span>
                        <span class="total"><asp:Literal ID="litCouponDiscount" runat="server" Text='' /></span>
                    </td>
                </tr>
            </asp:PlaceHolder>
            <!-- customer discount -->
            <asp:PlaceHolder ID="phdCustomer" runat="server" Visible="false">
                <tr class="footerrow">
                    <td colspan="6">
                        <span class="totallabel">
                            <asp:Literal ID="litContentTextDiscount" runat="server" Text='<%$ Resources: Basket, ContentText_Discount %>' />
                            <asp:PlaceHolder ID="phdSomeItemsExcluded" runat="server" Visible="false">
                                (<asp:Literal ID="litContentTextSomeItemsExcluded" runat="server"
                                    Text='<%$ Resources: Basket, ContentText_SomeItemsExcludedFromDiscount %>'
                                    EnableViewState="false"></asp:Literal>)
                            </asp:PlaceHolder>
                        </span>

                        <span class="total">
                            <asp:Literal ID="litCustomerDiscount" runat="server" Text='' /></span>
                </tr>
            </asp:PlaceHolder>
            <!-- shipping -->
            <tr class="footerrow">
                <td colspan="6">
                    <span class="totallabel">
                        <asp:Literal ID="litContentTextShipping" runat="server" Text='<%$ Resources: Address, ContentText_Shipping %>' />
                        <span class="unbold"><asp:Literal ID="litShippingDesc" runat="server" /></span>
                    </span>
                    <span class="total"><asp:Literal ID="litShipping" runat="server" Text='' /></span>
                </td>
            </tr>
            <!-- order handling charge -->
            <tr class="footerrow">
                <td colspan="6">
                    <span class="totallabel">
                        <asp:Literal ID="litContentTextOrderHandlingCharge" runat="server" Text='<%$ Resources: Kartris, ContentText_OrderHandlingCharge %>' /></span>
                    <span class="total"><asp:Literal ID="litOrderHandlingCharge" runat="server" Text='' /></span>
                </td>
            </tr>
            <!-- grand total -->
            <tr class="footerrow">
                <td class="grandtotal" colspan="6">
                    <span class="totallabel">
                        <asp:Literal ID="litContentTextTotal" runat="server" Text='<%$ Resources: Basket, ContentText_Total %>' /></span>
                    <span class="total"><asp:Literal ID="litTotal" runat="server" Text='' /></span>
                </td>
            </tr>
            <!-- total paid at gateway -->
            <asp:PlaceHolder ID="phdTotalGateway" runat="server" Visible="false">
                <tr class="footerrow">
                    <td class="grandtotalgateway" colspan="6">
                        <span class="totallabel">
                            <asp:Literal ID="litEmailTextProcessCurrencyExp1" runat="server" Text='<%$ Resources: Email, EmailText_ProcessCurrencyExp1 %>' /></span>
                        <span class="total"><asp:Literal ID="litTotalGateway" runat="server" Text='' /></span>
                    </td>
                </tr>
            </asp:PlaceHolder>
            </tbody> </table>
        </FooterTemplate>
    </asp:Repeater>
</div>
