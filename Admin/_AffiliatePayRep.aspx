<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_AffiliatePayRep.aspx.vb"
    Inherits="_affiliate_payrep" MasterPageFile="~/Skins/Admin/Template.master" %>

<%@ Register TagPrefix="_user" TagName="ItemPager" Src="~/UserControls/Back/_ItemPagerAjax.ascx" %>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <asp:UpdatePanel runat="server" ID="updPnlAffPayRep" UpdateMode="Conditional">
        <ContentTemplate>
            <div id="page_affiliatecommission">
                <asp:HyperLink ID="lnkBack" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>'
                    NavigateUrl="javascript:history.back()" CssClass="floatright linkbutton icon_back" />
                <h1>
                    <asp:Literal ID="litAffPayRepTitle" runat="server" Text="<%$ Resources: _Kartris, PageTitle_AffiliateReportFor %>" />:
                    <span class="h1_light">
                        <asp:Literal ID="litEmail" runat="server" /></span>
                </h1>
                <p>
                    <a class="linkbutton icon_user" href="_ModifyCustomerStatus.aspx?CustomerID=<% =request.querystring("CustomerID") %>">
                        <asp:Literal ID="litContentTextAffiliateDetails" runat="server" Text='<%$ Resources: _Customers, ContentText_AffiliateDetails %>' /></a></p>
                <table class="kartristable">
                    <tr>
                        <th>
                        </th>
                        <th>
                        </th>
                    </tr>
                    <tr>
                        <td>
                            <asp:Literal ID="litContentTextPaidCommission" runat="server" Text="<%$ Resources: _Kartris, ContentText_PaidCommission %>" />
                        </td>
                        <td class="selectfield amount">
                            <asp:Literal ID="litPaidCommission" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Literal ID="litContentTextUnpaidCommission" runat="server" Text="<%$ Resources: _Kartris, ContentText_UnpaidCommission %>" />
                        </td>
                        <td class="selectfield amount">
                            <asp:Literal ID="litUnpaidCommission" runat="server" />
                        </td>
                    </tr>
                </table>
                <div class="spacer">
                </div>
                <br />
                <h2>
                    <asp:Literal ID="litContentTextUnpaidCommission2" runat="server" Text="<%$ Resources: _Kartris, ContentText_UnpaidCommission %>"></asp:Literal>
                </h2>
                <p>
                    <asp:Literal ID="litContentTextUnPaidCommissionText" runat="server" Text="<%$ Resources: _Kartris, ContentText_UnPaidCommissionText %>"></asp:Literal></p>
                <br />
                <asp:GridView ID="gvwUnpaid" CssClass="kartristable" runat="server" AutoGenerateColumns="False" GridLines="None"
                    EnableViewState="true">
                    <Columns>
                        <asp:TemplateField>
                            <HeaderTemplate>
                                <asp:CheckBox EnableViewState="False" Checked="false" ID="chkHeader" CssClass="checkbox"
                                    runat="server" ToolTip="<%$ Resources: _Kartris, ContentText_SelectAll %>" OnCheckedChanged="CheckAll_Click"
                                    AutoPostBack="true" />
                                <%--                                    <asp:LinkButton runat="server" ID="lnkAll" ToolTip='<%$ Resources: _Kartris, ContentText_SelectAll %>' OnClientClick="CheckAll_Click">x</asp:LinkButton>--%>
                            </HeaderTemplate>
                            <HeaderStyle CssClass="checkboxfield" />
                            <ItemTemplate>
                                <asp:HiddenField ID="hidOrderID" runat="server" Value='<%# Eval("O_ID") %>' />
                                <asp:CheckBox ID="chkPaid" runat="server" CssClass="checkbox" OnCheckedChanged="CheckPaid_Click"
                                    AutoPostBack="false" />
                            </ItemTemplate>
                            <ItemStyle CssClass="checkboxfield" />
                        </asp:TemplateField>
                        <%--                        <asp:TemplateField>
                            <ItemTemplate>
                                <strong>
                                    <asp:Literal ID="litCounter" runat="server" Text='<%#Eval("RowNum")%>' /></strong>
                            </ItemTemplate>
                        </asp:TemplateField>--%>
                        <asp:TemplateField HeaderText="<%$ Resources: _Kartris, ContentText_DateTime %>">
                            <ItemTemplate>
                                <asp:Literal ID="litOrderDate" runat="server" Text='<%# GetDateTime(eval("O_Date")) %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:Literal ID="litCommission" runat="server" Text='<%# GetCommission(eval("Commission"),eval("O_AffiliatePercentage"))%>' />
                            </ItemTemplate>
                            <ItemStyle CssClass="amount" />
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-CssClass="selectfield">
                            <ItemTemplate>
                                <a class="linkbutton icon_orders normalweight" href='_ModifyOrderStatus.aspx?OrderID=<%# Eval("O_ID") %>'>
                                    <asp:Literal ID="litORD" runat="server" Text='<%$ Resources: _Kartris, ContentText_ShowOrder %>'></asp:Literal></a>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-CssClass="selectfield">
                            <ItemTemplate>
                                <a class="linkbutton icon_edit" href='_ModifyCustomerStatus.aspx?CustomerID=<%# Eval("U_ID") %>'>
                                    <asp:Literal ID="litSelect" runat="server" Text='<%$ Resources: _Kartris, FormButton_Select %>'></asp:Literal></a>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                <div id="divNoUnpaidRec" runat="server" class="noresults">
                    <asp:Literal ID="litNoUnpaidRec" runat="server" Text=""></asp:Literal>
                </div>
                <_user:ItemPager runat="server" ID="_UC_UnpaidPager" />
                <div>
                    <asp:Button CausesValidation="True" CssClass="button" runat="server" ID="btnSetAsPaid"
                        Text="<%$ Resources: _Kartris, FormButton_SetAsPaid %>" />
                </div>
                <br />
                <br />
                <h2>
                    <asp:Literal ID="litContentTextPayments" runat="server" Text="<%$ Resources: _Kartris, ContentText_Payments %>"></asp:Literal>
                </h2>
                <asp:GridView CssClass="kartristable" ID="gvwPaid" runat="server" AutoGenerateColumns="False" GridLines="None"
                    EnableViewState="true">
                    <Columns>
                        <%--                        <asp:TemplateField>
                            <ItemTemplate>
                                <strong>
                                    <asp:Literal ID="litCounter" runat="server" Text='<%# Eval("RowNum") %>' /></strong>
                            </ItemTemplate>
                        </asp:TemplateField>--%>
                        <asp:TemplateField HeaderText="<%$ Resources:_Kartris, ContentText_DateTime %>">
                            <ItemTemplate>
                                <asp:Literal ID="litAffDate" runat="server" Text='<%# GetDateTime(eval("AFP_DateTime")) %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$ Resources: _Kartris, ContentText_CommissionOrders %>">
                            <ItemTemplate>
                                <asp:Literal ID="litTotalOrders" runat="server" Text='<%# Eval("TotalOrders") %>' />
                            </ItemTemplate>
                            <ItemStyle CssClass="alignright" />
                            <HeaderStyle CssClass="alignright" />
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:Literal ID="litTotalPayment" runat="server" Text='<%# GetTotalPayment(Eval("TotalPayment")) %>' />
                            </ItemTemplate>
                            <ItemStyle CssClass="amount" />
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-CssClass="selectfield">
                            <ItemTemplate>
                                <a class="linkbutton icon_orders normalweight" href="_OrdersList.aspx?callmode=affpayment">
                                    <asp:Literal ID="litORD" runat="server" Text='<%$ Resources: _Customers, ContentText_ListOrders %>'></asp:Literal></a>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-CssClass="selectfield">
                            <ItemTemplate>
                                <asp:LinkButton CssClass="linkbutton icon_delete" ID="lnkMarkUnpaid" runat="server"
                                    Text='<%$ Resources:_Kartris, ImageLabel_MarkUnpaid %>' CommandArgument='<%# Eval("AFP_ID") %>'
                                    OnCommand="MarkUnpaid_Click" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                <div id="divNoPaidRec" runat="server" class="noresults">
                    <asp:Literal ID="litNoPaidRec" runat="server" Text=""></asp:Literal>
                </div>
                <_user:ItemPager runat="server" ID="_UC_PaidPager" />
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    <asp:UpdateProgress ID="prgAffPayRep" runat="server" AssociatedUpdatePanelID="updPnlAffPayRep">
        <ProgressTemplate>
            <div class="loadingimage">
            </div>
            <div class="updateprogress">
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>
</asp:Content>
