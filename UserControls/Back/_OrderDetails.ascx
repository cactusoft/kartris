<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_OrderDetails.ascx.vb"
    Inherits="UserControls_Back_OrderDetails" %>
<%@ Register TagPrefix="_user" TagName="CustomerOrder" Src="~/UserControls/Front/CustomerOrder.ascx" %>
<%@ Register TagPrefix="_user" TagName="EditCouponPopup" Src="~/UserControls/Back/_EditCouponPopup.ascx" %>
<%@ Register TagPrefix="_user" TagName="BasketView" Src="~/UserControls/Back/_BasketView.ascx" %>
<asp:UpdatePanel ID="updTabs" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <ajaxToolkit:TabContainer ID="tabContainerProduct" runat="server" EnableTheming="False"
            CssClass=".tab" AutoPostBack="false">
            <%-- Main tab --%>
            <ajaxToolkit:TabPanel ID="tabMainInfo" runat="server">
                <HeaderTemplate>
                    <asp:Literal ID="litTabMainInfo" runat="server" Text="<%$ Resources: _Kartris, ContentText_Overview %>" />
                </HeaderTemplate>
                <ContentTemplate>
                    <asp:UpdatePanel ID="updMainInfo" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:FormView ID="fvwOrderDetails" runat="server" DefaultMode="Edit">
                                <EditItemTemplate>
                                    <asp:PlaceHolder runat="server" ID="phdDateLink">
                                        <a class="linkbutton icon_back floatright" href='<%# FormatBackLink(CkartrisDisplayFunctions.FormatBackwardsDate(Eval("O_Date")), Request.Querystring("FromDate"), Request.Querystring("Page")) %>'>
                                            <asp:Literal ID="litContentTextBackLink" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>' /></a>
                                    </asp:PlaceHolder>
                                    <div class="buttonbar">
                                        <asp:PlaceHolder runat="server" ID="phdAffiliate">
                                            <div class="floatright">
                                                <a class="linkbutton icon_user" href="_ModifyCustomerStatus.aspx?CustomerID=<%#Eval("O_AffiliatePaymentID") %>">
                                                    <asp:Literal ID="litOrderAffiliateDetails" runat="server" Text="<%$ Resources: _Customers, ContentText_AffiliateDetails %>"></asp:Literal></a>
                                                <asp:HiddenField runat="server" ID="hidAffiliatePaymentID" Value='<%#Eval("O_AffiliatePaymentID")%>' />
                                            </div>
                                        </asp:PlaceHolder>
                                        <a class="linkbutton icon_user" href="_ModifyCustomerstatus.aspx?CustomerID=<%#Eval("O_CustomerID") %>">
                                            <asp:Literal ID="litOrderCustomerDetails" runat="server" Text="<%$ Resources: _Customers, ContentText_CustomerDetails %>"></asp:Literal></a>
                                        <asp:HiddenField runat="server" ID="hidCustomerID" Value='<%#Eval("O_CustomerID")%>' />
                                        <a class="linkbutton icon_orders" href="_OrderInvoice.aspx?OrderID=<%#Eval("O_ID") %>&amp;CustomerID=<%#Eval("O_CustomerID") %>">
                                            <asp:Label ID="lblContentTextIssueInvoice" runat="server" Text="<%$ Resources: _Orders, ContentText_IssueInvoice%>" /></a>
                                        <a class="linkbutton icon_orders" href="_ModifyPayment.aspx?OrderID=<%#Eval("O_ID") %>&amp;CustomerID=<%#Eval("O_CustomerID") %>">
                                            <asp:Label ID="lblContentTextNewPayment" runat="server" Text="<%$ Resources: _Payments, ContentText_AddPayment%>" /></a>
                                    </div>
                                    <div class="Kartris-DetailsView">
                                        <div class="Kartris-DetailsView-Data">
                                            <ul>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Label ID="lblOrderID" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderID %>" /></span>
                                                    <span class="Kartris-DetailsView-Value">
                                                        <asp:Literal ID="litOrderID" runat="server" Text='<%#Eval("O_ID") %>'></asp:Literal></span>
                                                </li>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Label ID="lblOrderPONumber" runat="server" Text="<%$ Resources: _Orders, ContentText_PONumber %>" /></span>
                                                    <span class="Kartris-DetailsView-Value">
                                                        <asp:Literal ID="litOrderPONumber" runat="server" Text='<%#Eval("O_PurchaseOrderNo")%>'></asp:Literal></span>
                                                </li>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Label ID="lblOrderDate" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderDate %>" /></span>
                                                    <span class="Kartris-DetailsView-Value">
                                                        <asp:Literal ID="litOrderDate" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("O_Date"), "t", Session("_LANG")) %>'></asp:Literal></span></li>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Label ID="lblOrderLastUpdate" runat="server" Text="<%$ Resources: _Orders, ContentText_LastUpdate %>" /></span>
                                                    <span class="Kartris-DetailsView-Value">
                                                        <asp:Literal ID="litOrderLastModified" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("O_LastModified"), "t", Session("_LANG")) %>'></asp:Literal></span></li>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Label ID="lblOrderValue" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderValue %>" /></span>
                                                    <span class="Kartris-DetailsView-Value">
                                                        <asp:Literal ID="litOrderTotalPrice" runat="server" Text='<%#Eval("O_TotalPrice")%>'></asp:Literal></span></li>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Label ID="lblOrderPaymentGateway" runat="server" Text="<%$ Resources: _Orders, ContentText_PaymentGateWay %>" /></span>
                                                    <span class="Kartris-DetailsView-Value">
                                                        <asp:Literal ID="litOrderPaymentGateway" runat="server" Text='<%#Eval("O_PaymentGateway")%>'></asp:Literal></span>
                                                    <asp:HiddenField runat="server" ID="hidOrderCurrencyID" Value='<%#Eval("O_CurrencyID")%>' />
                                                </li>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Label ID="lblOrderReferenceCode" runat="server" Text="<%$ Resources: _Orders, ContentText_ReferenceCode %>" /></span>
                                                    <span class="Kartris-DetailsView-Value">
                                                        <asp:Literal ID="litOrderReferenceCode" runat="server" Text='<%#Eval("O_ReferenceCode")%>'></asp:Literal></span></li>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Label ID="lblOrderLanguage" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Language %>" /></span>
                                                    <span class="Kartris-DetailsView-Value">
                                                        <asp:Literal ID="litOrderLanguage" runat="server" Text='<%#Eval("O_LanguageID")%>'></asp:Literal>
                                                        <asp:HiddenField runat="server" ID="hidOrderLanguageID" Value='<%#Eval("O_LanguageID")%>' />
                                                    </span></li>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Label ID="lblOrderAffiliateCommission" runat="server" Text="<%$ Resources: _Customers, FormLabel_Commission %>" /></span>
                                                    <span class="Kartris-DetailsView-Value">
                                                        <asp:Literal ID="litOrderAffiliateCommission" runat="server" Text=''></asp:Literal></span></li>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Label ID="lblOrderBillingAddress" runat="server" Text="<%$ Resources: _Address, FormLabel_BillingAddress %>"
                                                        AssociatedControlID="txtOrderBillingAddress" /></span> <span class="Kartris-DetailsView-Value">
                                                            <asp:TextBox ReadOnly="true" runat="server" ID="txtOrderBillingAddress" TextMode="MultiLine"
                                                                Text='<%#Eval("O_BillingAddress")%>' /></span></li>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Label ID="lblOrderShippingAddress" runat="server" Text="<%$ Resources: _Address, FormLabel_ShippingAddress %>"
                                                        AssociatedControlID="txtOrderShippingAddress" /></span> <span class="Kartris-DetailsView-Value">
                                                            <asp:TextBox ReadOnly="true" runat="server" ID="txtOrderShippingAddress" TextMode="MultiLine"
                                                                Text='<%#Eval("O_ShippingAddress")%>' /></span></li>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Label ID="lblOrderStatus" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderStatus %>" /></span>
                                                
                                                    <span class="Kartris-DetailsView-Value"><span class="checkbox">
                                                        <asp:CheckBox runat="server" ID="chkOrderSent" Checked='<%#Bind("O_Sent")%>' /></span>
                                                        <asp:Label CssClass="checkbox_label" ID="lblOrderSent" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderStatusSent %>"
                                                            AssociatedControlID="chkOrderSent" /><asp:HiddenField runat="server" ID="hidOrigOrderSent"
                                                                Value='<%#Eval("O_Sent")%>' />
                                                        <br />
                                                        <span class="checkbox">
                                                            <asp:CheckBox runat="server" ID="chkOrderInvoiced" Checked='<%#Bind("O_Invoiced")%>' /></span>
                                                        <asp:Label CssClass="checkbox_label" ID="lblOrderInvoiced" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderStatusInvoiced %>"
                                                            AssociatedControlID="chkOrderInvoiced" />
                                                        <br />
                                                        <span class="checkbox">
                                                            <asp:CheckBox runat="server" ID="chkOrderPaid" Checked='<%#Bind("O_Paid")%>' /></span>
                                                        <asp:Label CssClass="checkbox_label" ID="lblOrderPaid" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderStatusPaid %>"
                                                            AssociatedControlID="chkOrderPaid" />
                                                        <br />
                                                        <span class="checkbox">
                                                            <asp:CheckBox runat="server" ID="chkOrderShipped" Checked='<%#Bind("O_Shipped") %>' /></span>
                                                        <asp:Label CssClass="checkbox_label" ID="lblOrderShipped" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderStatusShipped %>"
                                                            AssociatedControlID="chkOrderShipped" />
                                                             <br />
                                                        <span class="checkbox">
                                                            <asp:CheckBox runat="server" ID="chkOrderCancelled" Checked='<%#Bind("O_Cancelled") %>' /></span>
                                                        <asp:Label CssClass="checkbox_label" ID="lblOrderCancelled" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderStatusCancelled %>"
                                                            AssociatedControlID="chkOrderCancelled" />
                                                    </span></li>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:HiddenField runat="server" ID="hidOrderText" Value='<%# Server.HtmlEncode(Eval("O_Details")) %>' />
                                                    <asp:HiddenField runat="server" ID="hidOrderData" Value='<%# Server.HtmlEncode(CkartrisDataManipulation.FixNullFromDB(Eval("O_Data"))) %>' />
                                                    <asp:Label ID="lblOrderProgress" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderProgress %>"
                                                        AssociatedControlID="txtOrderStatus" /></span> <span class="Kartris-DetailsView-Value">
                                                            <asp:TextBox runat="server" ID="txtOrderStatus" TextMode="MultiLine" Text='<%#Bind("O_Status") %>' /></span></li>
                                                <asp:PlaceHolder runat="server" ID="phdSendEmailToCustomer" Visible="true">
                                                    <li><span class="Kartris-DetailsView-Name"></span><span class="Kartris-DetailsView-Value">
                                                        <input type="hidden" name="C_EmailAddress" value="C_EmailAddress" />
                                                        <span class="checkbox">
                                                            <asp:CheckBox runat="server" ID="chkSendOrderUpdateEmail" Checked='<%#Eval("O_SendOrderUpdateEmail") %>' /></span>
                                                        <asp:Label ID="lblOrderSendEmailToCustomer" runat="server" Text="<%$ Resources: _Orders, ContentText_SendEmailToCustomer %>"
                                                            AssociatedControlID="chkSendOrderUpdateEmail" CssClass="checkbox_label" />
                                                    </span>
                                                        <asp:HiddenField ID="hidSendOrderUpdateEmail" Value="true" runat="server" />
                                                    </li>
                                                </asp:PlaceHolder>
                                                <asp:PlaceHolder runat="server" ID="phdViewCoupon">
                                                    <li><span class="Kartris-DetailsView-Name">
                                                        <asp:HiddenField runat="server" ID="hidOrderCoupon" Value='<%#Eval("O_CouponCode")%>' />
                                                        <asp:Label ID="lblOrderViewCoupon" runat="server" Text="<%$ Resources: _Orders, ContentText_ViewCouponUsed %>" /></span>
                                                        <span class="Kartris-DetailsView-Value">
                                                            <asp:LinkButton CssClass="linkbutton icon_edit" runat="server" ID="lnkBtnViewCoupon"
                                                                Text="<%$ Resources: _Kartris, ContentText_ClickHere %>" OnClick="lnkBtnViewCoupon_Click" />
                                                        </span></li>
                                                </asp:PlaceHolder>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Label ID="lblComments" runat="server" Text="<%$ Resources: Checkout, SubTitle_Comments%>" /></span> <span class="Kartris-DetailsView-Value">
                                                        <asp:Literal ID="litComments" runat="server" Text='<%#Eval("O_Comments") %>'></asp:Literal></span></li>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Label ID="lblOrderNotes" runat="server" Text="<%$ Resources: _Kartris, ContentText_Notes%>"
                                                    AssociatedControlID="txtOrderNotes" /></span> <span class="Kartris-DetailsView-Value">
                                                        <asp:TextBox runat="server" ID="txtOrderNotes" TextMode="MultiLine" Text='<%#Bind("O_Notes") %>' /></span></li>
                                            </ul>
                                                <asp:PlaceHolder runat="server" ID="phdCancelledMessage" Visible="false">
                                                    <div class="warnmessage"><asp:Literal ID="litCancelledMessage" runat="server"
                                                    Text="<%$ Resources: _Orders, ContentText_OrderStatusCancelled %>" /></div>
                                                </asp:PlaceHolder>
                                            <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">

                                            
                                                <asp:LinkButton CausesValidation="True" CommandName="Update" CssClass="button savebutton"
                                                    runat="server" ID="btnOrderUpdate" Text="<%$ Resources: _Kartris, FormButton_Save %>"
                                                    ToolTip="<%$ Resources: _Kartris, FormButton_Save %>" /><asp:LinkButton CausesValidation="True"
                                                        CssClass="button editbutton" runat="server" ID="lnkBtnEdit" Text="<%$ Resources: _Kartris, FormButton_Edit %>"
                                                        ToolTip="<%$ Resources: _Kartris, FormButton_Edit %>" OnClick="lnkBtnEdit_Click" />
                                                <span class="floatright">
                                                    <asp:LinkButton CssClass="button deletebutton" runat="server" ID="lnkBtnDelete"
                                                        Text="<%$ Resources: _Kartris, FormButton_Delete %>" ToolTip="<%$ Resources: _Kartris, FormButton_Delete %>"
                                                        OnClick="lnkBtnDelete_Click" /></span>
                                            </div>
                                        </div>
                                    </div>
                                </EditItemTemplate>
                            </asp:FormView>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
            <%-- Order summary --%>
            <ajaxToolkit:TabPanel ID="tabOrderSummary" runat="server">
                <HeaderTemplate>
                    <asp:Literal ID="litTabOrderSummary" runat="server" Text="<%$ Resources: _Kartris, ContentText_ItemSummary %>" />
                </HeaderTemplate>
                <ContentTemplate>
                    <div class="subtabsection">
                        <_user:CustomerOrder runat="server" ID="UC_CustomerOrder" />
                    </div>
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
            <%-- Ordertext tab --%>
            <ajaxToolkit:TabPanel ID="tabOrderText" runat="server">
                <HeaderTemplate>
                    <asp:Literal ID="litTabOrderText" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderText%>" />
                </HeaderTemplate>
                <ContentTemplate>
                    <div class="subtabsection">
                        <asp:Literal ID="litOrderText" runat="server" Text=""></asp:Literal></div>
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
        </ajaxToolkit:TabContainer>
        <_user:EditCouponPopup ID="_UC_ViewCouponPopup" runat="server" />
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
