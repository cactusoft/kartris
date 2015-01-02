<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_OrdersList.ascx.vb"
    Inherits="UserControls_Back_OrdersList" %>
<%@ Register TagPrefix="_user" TagName="ItemPager" Src="~/UserControls/Back/_ItemPagerAjax.ascx" %>
<%@ Register TagPrefix="_user" TagName="DispatchLabels" Src="~/UserControls/Back/_DispatchLabels.ascx" %>
<div>
    <asp:PlaceHolder runat="server" ID="phdDateNavigation">
        <div class="breadcrumbtrail">
            <span><span>
                <asp:LinkButton runat="server" ID="btnYesterday" /></span></span> <span><span class="middle">
                    <asp:Literal ID="litToday" runat="server" Text=''></asp:Literal></span></span>
            <span><span>
                <asp:LinkButton runat="server" ID="btnTomorrow" /></span></span>
            <asp:Literal ID="litSelectedLongDate" runat="server" Text='' Visible="false"></asp:Literal></div>
        <div>
            <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                <asp:ImageButton ID="btnCalendar" runat="server" AlternateText="" ImageUrl="~/Skins/Admin/Images/icon_calendar.gif"
                    Width="16" Height="16" CssClass="calendarbutton" />
                <asp:TextBox ID="txtFilterDate" runat="server" CssClass="midtext" /><ajaxToolkit:CalendarExtender
                    Format="dd MMM yy" Animated="true" PopupButtonID="btnCalendar" TargetControlID="txtFilterDate"
                    runat="server" ID="calDateSearch" PopupPosition="BottomLeft" CssClass="calendar" />
                <asp:Button ID="btnSearch" runat="server" Text="<%$ Resources:_Kartris, FormButton_Search %>"
                    CssClass="button" />
            </asp:Panel>
        </div>
    </asp:PlaceHolder>
    <div>
        <_user:DispatchLabels ID="DispatchLabels" runat="server" Visible="false" />
    </div>
    <asp:GridView CssClass="kartristable" ID="gvwOrders" runat="server" AutoGenerateColumns="False"
        DataKeyNames="O_ID" GridLines="None" EnableViewState="true">
        <Columns>
            <asp:BoundField DataField="O_ID" HeaderText='<%$ Resources:_Kartris, ContentText_ID%>'
                ItemStyle-CssClass="idfield"></asp:BoundField>
            <asp:TemplateField ItemStyle-CssClass="datefield" HeaderText='<%$ Resources:_Kartris, ContentText_Date %>'>
                <ItemTemplate>
                    <asp:Literal ID="litOrderDate" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("O_Date"), "t", Session("_LANG")) %>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-CssClass="currencyfield" HeaderText='<%$ Resources:_Kartris, ContentText_Value %>'>
                <ItemTemplate>
                    <asp:Literal ID="litOrderValue" runat="server" Text='<%# Eval("O_TotalPrice") %>'> </asp:Literal>
                    <asp:HiddenField runat="server" EnableViewState="false" ID="hidOrderCurrencyID" Value='<%#Eval("O_CurrencyID")%>' />
                    <asp:HiddenField runat="server" EnableViewState="false" ID="hidOrderChildID" Value='<%# CkartrisDataManipulation.FixNullFromDB(Eval("CO_OrderID"))%>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText='<%$ Resources:_Kartris, ContentText_CustomerName %>'>
                <ItemTemplate>
                    <a class="linkbutton icon_user" href="_ModifyCustomerStatus.aspx?CustomerID=<%#Eval("O_CustomerID") %>">
                        <asp:Label ID="lblOrderBillingName" runat="server" Text='<%# Eval("O_BillingName") %>'></asp:Label></a>
                        
                    <asp:PlaceHolder ID="phdBatchProcess" Visible="false" runat="server">
                        <br />
                        <asp:CheckBox runat="server" ID="chkBatchProcess" Visible="false" Checked='<%#Eval("O_Sent") %>' />
                        <asp:HiddenField runat="server" ID="hidOrderID" Value='<%#Eval("O_ID")%>' />
                        <asp:HiddenField runat="server" ID="hidOrderStatus" Value='<%#Eval("O_Status")%>' />
                        <asp:HiddenField runat="server" ID="hidOrderLanguageID" Value='<%#Eval("O_LanguageID")%>' />
                        <asp:HiddenField runat="server" ID="hidOrderCustomerID" Value='<%#Eval("O_CustomerID")%>' />
                        <div>
                            <a class="linkbutton icon_orders" target="_blank" href="_OrderInvoice.aspx?OrderID=<%#Eval("O_ID") %>&CustomerID=<%#Eval("O_CustomerID") %>">
                                <asp:Literal ID="litClickOrderInvoice" runat="server" Text="<%$Resources: _Orders, ContentText_IssueInvoice%>"></asp:Literal></a>
                        </div>
                        <span class="checkbox">
                            <div>
                                <asp:CheckBox runat="server" ID="chkOrderInvoiced" Checked='<%#Bind("O_Invoiced")%>' />
                                <asp:Label ID="lblOrderInvoiced" runat="server" Text="<%$Resources: _Orders, ContentText_OrderStatusInvoiced%>"
                                    AssociatedControlID="chkOrderInvoiced" />
                            </div>
                            <div>
                                <asp:CheckBox runat="server" ID="chkOrderPaid" Checked='<%#Bind("O_Paid")%>' />
                                <asp:Label ID="lblOrderPaid" runat="server" Text="<%$Resources: _Orders, ContentText_OrderStatusPaid%>"
                                    AssociatedControlID="chkOrderPaid" />
                            </div>
                            <div>
                                <asp:CheckBox runat="server" ID="chkOrderShipped" Checked='<%#Bind("O_Shipped")%>' />
                                <asp:Label ID="lblOrderShipped" runat="server" Text="<%$Resources: _Orders, ContentText_OrderStatusShipped%>"
                                    AssociatedControlID="chkOrderShipped" />
                            </div>
                            <div>
                                <asp:CheckBox runat="server" ID="chkOrderCancelled" Checked='<%#Bind("O_Cancelled")%>' />
                                <asp:Label ID="lblOrderCancelled" runat="server" Text="<%$Resources: _Orders, ContentText_OrderStatusCancelled%>"
                                    AssociatedControlID="chkOrderCancelled" />
                            </div>
                        </span>
                    </asp:PlaceHolder>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-CssClass="selectfield">
                <ItemTemplate>
                    <a class="linkbutton icon_edit" href="_ModifyOrderStatus.aspx?OrderID=<%#Eval("O_ID") %>&amp;FromDate=<%# TagIfReturnToDate() %>&amp;Page=<%# CurrentPageNumber() %>">
                        <asp:Literal ID="litOLIndicates" runat="server" EnableViewState="false" Text="<%$ Resources:_Kartris, FormButton_Select %>"></asp:Literal></a>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    <asp:PlaceHolder ID="phdBatchProcessButtons" Visible="false" runat="server">
        <br />
        <br />
        <span class="checkbox">
            <asp:CheckBox runat="server" ID="chkInformCustomers" /><asp:Label ID="lblInformCustomers"
                runat="server" Text="<%$Resources: ContentText_InformCustomers%>" AssociatedControlID="chkInformCustomers" />
        </span>
        <div class="submitbuttons">
            <asp:Button ID="btnUpdate" runat="server" Text="<%$ Resources:_Kartris, FormButton_Update %>"
                CssClass="button" />
        </div>
    </asp:PlaceHolder>
    <asp:PlaceHolder ID="phdPurgeOrder" Visible="false" runat="server">
        <p class="floatright alignright">
            <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
            <asp:LinkButton ID="btnPurgeOrders" runat="server" Text="<%$ Resources: ContentText_PurgeUnfinishedOrders%>"
                CssClass="linkbutton icon_delete floatright" />
        </p>
    </asp:PlaceHolder>
    <div class="spacer">
    </div>
    <asp:PlaceHolder ID="phdIndicates" runat="server">
        <div class="infomessage">
            <asp:Literal ID="litOLIndicates" runat="server" Text=""></asp:Literal>
            <asp:Literal ID="litOLIndicatesComplete" runat="server" Text=""></asp:Literal>
        </div>
    </asp:PlaceHolder>
    <_user:ItemPager runat="server" ID="_UC_ItemPager" />
</div>
