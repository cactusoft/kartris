<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_TaskList.ascx.vb" Inherits="UserControls_Back_TaskList" %>
<div id="section_tasklist">

        <h2><asp:Literal ID="litContentTextToDoList" Text="<%$ Resources: _TaskList, ContentText_ToDoList  %>"
                runat="server" /></h2>

    <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <%--Customer Orders--%>
            <asp:PlaceHolder ID="phdCustomerOrders" runat="server">
                <!-- Orders -->
                <asp:PlaceHolder ID="phdOrders" runat="server" Visible="true">
                    <div class="task_section">
                        <div class="level_1">
                            <a href="_OrdersList.aspx">
                                <asp:Literal ID="litContentTextToDoListOrders1" runat="server" Text="<%$ Resources: _TaskList, ContentText_ToDoListOrders1 %>" />
                            </a>
                        </div>
                        <div class="level_2">
                            <asp:PlaceHolder ID="phdToInvoice" runat="server">
                                <div>
                                    <a href="_OrdersList.aspx?callmode=invoice">
                                        <asp:Literal ID="litContentTextToDoListOrders2" runat="server" Text="<%$ Resources: _TaskList, ContentText_ToDoListOrders2 %>" />&nbsp;<asp:Literal
                                            ID="litToInvoice" runat="server" /></a></div>
                            </asp:PlaceHolder>
                            <asp:PlaceHolder ID="phdNeedPayment" runat="server">
                                <div>
                                    <a href="_OrdersList.aspx?callmode=payment">
                                        <asp:Literal ID="litContentTextToDoListOrders3" runat="server" Text="<%$ Resources: _TaskList, ContentText_ToDoListOrders3 %>" />&nbsp;<asp:Literal
                                            ID="litNeedPayment" runat="server" /></a></div>
                            </asp:PlaceHolder>
                            <asp:PlaceHolder ID="phdToDispatch" runat="server">
                                <div>
                                    <a href="_OrdersList.aspx?callmode=dispatch">
                                        <asp:Literal ID="litContentTextToDoListOrders4" runat="server" Text="<%$ Resources: _TaskList, ContentText_ToDoListOrders4 %>" />&nbsp;<asp:Literal
                                            ID="litToDispatch" runat="server" /></a></div>
                            </asp:PlaceHolder>
                        </div>
                    </div>
                </asp:PlaceHolder>
                <%--Customer --%>
                <asp:PlaceHolder ID="phdCustomers" runat="server" Visible="true">
                    <div class="task_section">
                        <div class="level_1">
                            <a href="_CustomersList.aspx">
                                <asp:Literal ID="litCustomers" runat="server" Text="<%$ Resources: _Search, ContentText_AdminSearchCustomers %>" />
                            </a>
                        </div>
                        <div class="level_2">
                            <asp:PlaceHolder ID="phdCustomersAwaitingRefunds" runat="server">
                                <div>
                                    <a href="_CustomersList.aspx?callmode=refunds">
                                        <asp:Literal ID="litCustomersAwaitingRefunds" runat="server" Text="<%$ Resources: _TaskList, ContentText_CustomersAwaitingRefunds %>" />&nbsp;<asp:Literal
                                            ID="litCustomersAwaitingRefundsCount" runat="server" /></a></div>
                            </asp:PlaceHolder>
                            <asp:PlaceHolder ID="phdCustomersInArrears" runat="server">
                                <div>
                                    <a href="_CustomersList.aspx?callmode=arrears">
                                        <asp:Literal ID="litCustomersInArrears" runat="server" Text="<%$ Resources: _TaskList, ContentText_CustomersInArrears %>" />&nbsp;<asp:Literal
                                            ID="litCustomersInArrearsCount" runat="server" /></a></div>
                            </asp:PlaceHolder>
                            <asp:PlaceHolder ID="phdCustomersToAnonymize" runat="server" Visible="false">
                                <div>
                                    <a href="_AnonymizeList.aspx">
                                        <asp:Literal ID="litCustomersToAnonymize" runat="server" Text="To Anonymize" />&nbsp;<asp:Literal ID="litCustomersToAnonymizeCount" runat="server" /></a></div>
                            </asp:PlaceHolder>
                        </div>
                    </div>
                </asp:PlaceHolder>
                <!-- Stock -->
                <asp:PlaceHolder ID="phdStock" runat="server" Visible="true">
                    <div class="task_section">
                        <div class="level_1">
                            <a href="_StockWarning.aspx">
                                <asp:Literal ID="litContentTextToDoListStock1" runat="server" Text="<%$ Resources: _TaskList, ContentText_ToDoListStock1 %>" />
                            </a>
                        </div>
                        <div class="level_2">
                            <asp:PlaceHolder ID="phdStockWarning" runat="server"><a href="_StockWarning.aspx">
                                <asp:Literal ID="litContentTextToDoListStock3" runat="server" Text="<%$ Resources: _TaskList, ContentText_ToDoListStock3 %>" />&nbsp;<asp:Literal
                                    ID="litStockWarning" runat="server" /></a></asp:PlaceHolder>
                            <asp:PlaceHolder ID="phdOutOfStock" runat="server"><a href="_StockWarning.aspx">
                                <asp:Literal ID="litContentTextToDoListStock4" runat="server" Text="<%$ Resources: _TaskList, ContentText_ToDoListStock4 %>" />&nbsp;<asp:Literal
                                    ID="litOutOfStock" runat="server" /></a></asp:PlaceHolder>
                        </div>
                    </div>
                </asp:PlaceHolder>


                <!-- Stock Notifications -->
                <asp:PlaceHolder ID="phdStockNotifications" runat="server" Visible="false">
                    <div class="task_section">
                        <div class="level_1">
                            <a href="_StockNotifications.aspx">
                                <asp:Literal ID="litStockNotifications" runat="server" Text="<%$ Resources: _StockNotification, ContentText_StockNotifications %>" />
                                </a>
                        </div>
                        <div class="level_2">
                            <div><asp:Literal ID="litVersionsAwaitingCheck" runat="server" Text="<%$ Resources: _StockNotification, ContentText_VersionsAwaitingCheck %>" />&nbsp;<asp:Literal
                                    ID="litVersionsAwaitingCheckQty" runat="server" /></div>
                        </div>
                    </div>
                </asp:PlaceHolder>



                <!-- Affiliates -->
                <asp:PlaceHolder ID="phdAffiliates" runat="server" Visible="true">
                    <div class="task_section">
                        <div class="level_1">
                            <a href="_CustomersList.aspx?mode=af">
                                <asp:Literal ID="litContentTextToDoListAffiliates1" runat="server" Text="<%$ Resources: _TaskList, ContentText_ToDoListAffiliates1 %>" />
                            </a>
                        </div>
                        <div class="level_2">
                            <a href="_CustomersList.aspx?mode=af&amp;approve=y">
                                <asp:Literal ID="litContentTextToDoListAffiliates3" runat="server" Text="<%$ Resources: _TaskList, ContentText_ToDoListAffiliates3 %>" />&nbsp;<asp:Literal
                                    ID="litWaitingAffiliates" runat="server" /></a>
                        </div>
                    </div>
                </asp:PlaceHolder>
                <!-- Reviews -->
                <asp:PlaceHolder ID="phdReviews" runat="server" Visible="true">
                    <div class="task_section">
                        <div class="level_1">
                            <a href="_Reviews.aspx?strModerate=y">
                                <asp:Literal ID="litContentTextToDoListReviews1" runat="server" Text="<%$ Resources: _TaskList, ContentText_ToDoListReviews1 %>" />
                            </a>
                        </div>
                        <div class="level_2">
                            <a href="_Reviews.aspx?strModerate=y">
                                <asp:Literal ID="litContentTextToDoListReviews3" runat="server" Text="<%$ Resources: _TaskList, ContentText_ToDoListReviews3 %>" />&nbsp;<asp:Literal
                                    ID="litWaitingReviews" runat="server" /></a>
                        </div>
                    </div>
                </asp:PlaceHolder>
                <!-- No Items -->
                <asp:PlaceHolder ID="phdNoItems" runat="server" Visible="false">
                    <div class="noresults">
                        <asp:Literal ID="litContentTextNoItemsFound" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" /></div>
                </asp:PlaceHolder>
            </asp:PlaceHolder>
            <!-- Support Tickets -->
            <asp:PlaceHolder ID="phdSupportTickets" runat="server" Visible="false">
                <div class="task_section">
                    <div class="level_1">
                        <asp:HyperLink ID="lnkMyTickets" runat="server">
                            <asp:Literal ID="litBackMenuSupportTickets" runat="server" Text="<%$ Resources: _Kartris, BackMenu_SupportTickets %>" />
                        </asp:HyperLink>
                    </div>
                    <div class="level_2">
                        <div>
                            <asp:HyperLink ID="lnkAwaitingResponse" runat="server">
                                <asp:Literal ID="litContentTextWaiting" runat="server" Text="<%$ Resources: _Tickets, ContentText_Waiting %>" />&nbsp;<asp:Literal
                                    ID="litAwaitingResponse" runat="server" /></asp:HyperLink></div>
                        <div>
                            <asp:HyperLink ID="lnkUnAssignedTickets" runat="server" NavigateUrl="~/Admin/_SupportTickets.aspx?u=0">
                                <asp:Literal ID="litContentTextUnassignedTickets" runat="server" Text="<%$ Resources: _Tickets, ContentText_UnassignedTickets %>" />&nbsp;<asp:Literal
                                    ID="litUnassigned" runat="server" />
                            </asp:HyperLink>
                        </div>
                    </div>
                </div>
            </asp:PlaceHolder>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
