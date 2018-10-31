<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_UserDetails.ascx.vb"
    Inherits="UserControls_Back_UserDetails" %>
<%@ Register TagPrefix="user" TagName="AddressesDetails" Src="~/UserControls/General/_AddressesDetails.ascx" %>
<asp:UpdatePanel runat="server" ID="updUser" UpdateMode="Conditional">
    <ContentTemplate>
        <_user:PopupMessage runat="server" ID="_UC_PopupMsg" />
        <asp:HyperLink ID="lnkBack" runat="server" CssClass="linkbutton icon_back floatright"
            Text="<%$ Resources: _Kartris, ContentText_BackLink %>"></asp:HyperLink>

        <asp:FormView ID="fvwUser" runat="server" DefaultMode="Edit">
            <EditItemTemplate>
                <ajaxToolkit:TabContainer ID="tabContainerUser" runat="server" EnableTheming="False"
                    CssClass=".tab" AutoPostBack="false">
                    <%-- Main tab --%>
                    <ajaxToolkit:TabPanel ID="tabMainInfo" runat="server">
                        <HeaderTemplate>
                            <asp:Literal ID="litTabMainInfo" runat="server" Text="<%$Resources: ContentText_ContactAndMiscDetails %>" />
                        </HeaderTemplate>
                        <ContentTemplate>
                            <div class="buttonbar">
                                <a class="linkbutton icon_orders" href="_OrdersList.aspx?CustomerID=<%# Eval("U_ID") %>&callmode=customer">
                                    <asp:Literal ID="litListOrders" runat="server" Text="<%$ Resources: _Customers, ContentText_ListOrders %>"></asp:Literal></a>
                                <a class="linkbutton icon_orders" href="_ModifyPayment.aspx?CustomerID=<%# Eval("U_ID") %>">
                                    <asp:Literal ID="litAddPayment" runat="server" Text="<%$ Resources: _Payments, ContentText_AddPayment %>"></asp:Literal></a>
                                <a class="linkbutton icon_support" href="_SupportTickets.aspx?c=<%# Eval("U_ID") %>">
                                    <asp:Literal ID="litPageTitleSupportTickets" runat="server" Text="<%$ Resources: _Tickets, PageTitle_SupportTickets %>" /></a>
                            </div>
                            <div class="Kartris-DetailsView">
                                <div class="Kartris-DetailsView-Data">
                                    <asp:HiddenField runat="server" ID="hidIsGuest" Value='<%# Eval("U_GDPR_IsGuest") %>' />
                                    <ul>
                                        <asp:PlaceHolder runat="server" ID="phdGuestTag" Visible='<%# Eval("U_GDPR_IsGuest") %>'>
                                            <li>
                                                <span class="guestcheckouttag"><asp:Literal ID="litIsGuest" runat="server" Text="<%$ Resources: _GDPR, ContentText_GuestCheckout %>" /></span></li>
                                        </asp:PlaceHolder>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserID" runat="server" Text="<%$ Resources: _Customers, FormLabel_CustomerID %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:Literal ID="litUserID" runat="server" Text='<%#Eval("U_ID") %>'></asp:Literal></span>
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="litContentTextCustomerName" runat="server" Text="<%$ Resources: _Kartris, ContentText_CustomerName %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:TextBox ID="txtAccountHolderName" runat="server" Text='<%# Eval("U_AccountHolderName")%>'></asp:TextBox></span>
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserEmail" runat="server" Text="<%$ Resources: _Kartris, ContentText_Email %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:TextBox ID="txtUserEmail" runat="server" Text='<%# UsersBLL.CleanGuestEmailUsername(Eval("U_EmailAddress"))%>'></asp:TextBox>
                                                <asp:RequiredFieldValidator ID="valEmailAddress1" runat="server" ControlToValidate="txtUserEmail"
                                                    CssClass="error" ForeColor="" Display="Dynamic" Text="<%$ Resources: _Kartris, ContentText_RequiredField %>" />
                                                <asp:RegularExpressionValidator ID="valEmailAddress2" runat="server" ControlToValidate="txtUserEmail"
                                                    CssClass="error" ForeColor="" Display="Dynamic" ErrorMessage="<%$ Resources: _Kartris, ContentText_BadEmail %>"
                                                    ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" />
                                            </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserPassword" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Password %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:Label ID="lblPassword" runat="server" Text="{encrypted}" />
                                                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" Visible="false" />
                                                <asp:LinkButton ID="btnChangePassword" OnClick="btnChangePassword_Click" Text="<%$ Resources: _Kartris, ContentText_ConfigChange2 %>"
                                                    runat="server" CausesValidation="false" />
                                                <asp:RequiredFieldValidator ID="valRequiredUserPassword" runat="server" ControlToValidate="txtPassword"
                                                    Enabled="false" CssClass="error" ForeColor="" Display="Dynamic" Text="<%$ Resources: _Kartris, ContentText_RequiredField %>" />
                                            </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserDiscount" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Discount %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:TextBox ID="txtUserDiscount" runat="server" Text='<%# Eval("U_CustomerDiscount")%>'
                                                    CssClass="shorttext"></asp:TextBox>
                                                <asp:RegularExpressionValidator ID="valRegExUserDiscount" runat="server" ControlToValidate="txtUserDiscount"
                                                    CssClass="error" ForeColor="" ErrorMessage="0-100!" Display="Dynamic" EnableClientScript="true"
                                                    ValidationExpression="<%$ AppSettings:PercentageRegex %>" />
                                            </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserGroup" runat="server" Text="<%$ Resources: _Customers, FormLabel_CustomerGroup %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:DropDownList ID="ddlUserGroups" runat="server" DataSourceID="objUserGroups"
                                                    DataTextField="CG_Name" DataValueField="CG_ID" />
                                                <asp:ObjectDataSource ID="objUserGroups" runat="server" OldValuesParameterFormatString="original_{0}"
                                                    SelectMethod="_GetCustomerGroups" TypeName="UsersBLL">
                                                    <SelectParameters>
                                                        <asp:SessionParameter Name="numLanguageID" SessionField="_LANG" Type="Byte" DefaultValue="1" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <asp:HiddenField ID="hidUserGroup" runat="server" Value='<%# Eval("U_CustomerGroupID")%>'></asp:HiddenField>
                                            </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserApproved" runat="server" Text="<%$ Resources: _Customers, FormLabel_Approved %>" /></span>
                                            <span class="Kartris-DetailsView-Value"><span class="checkbox">
                                                <asp:CheckBox ID="chkUserApproved" runat="server" Checked='<%# Bind("U_Approved") %>' />
                                            </span></span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserLanguage" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Language %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:DropDownList ID="ddlLanguages" runat="server" DataSourceID="objLanguages" DataTextField="Lang_FrontName"
                                                    DataValueField="Lang_ID" />
                                                <asp:ObjectDataSource ID="objLanguages" runat="server" OldValuesParameterFormatString="original_{0}"
                                                    SelectMethod="GetData" TypeName="kartrisLanguageDataTableAdapters.LanguagesTblAdptr" />
                                                <asp:HiddenField ID="hidUserLanguage" runat="server" Value='<%# Eval("U_LanguageID") %>' />
                                            </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserSupportEndDate" runat="server" Text="<%$ Resources: _Customers, FormLabel_SupportEndDate %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:TextBox ID="txtUserSupportEndDate" runat="server" Text='<%# Cdate(CkartrisDataManipulation.FixNullFromDB(Eval("U_SupportEndDate"))).ToString("yyyy/MM/dd") %>'></asp:TextBox>
                                                <asp:ImageButton ID="btnCalendar" runat="server" AlternateText="" ImageUrl="~/Skins/Admin/Images/icon_calendar.gif"
                                                    Width="16" Height="16" CssClass="calendarbutton" />
                                                <ajaxToolkit:CalendarExtender
                                                    Format="yyyy/MM/dd" Animated="true" PopupButtonID="btnCalendar" TargetControlID="txtUserSupportEndDate"
                                                    runat="server" ID="calDate" PopupPosition="BottomLeft" CssClass="calendar" />
                                            </span>
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserNotes" runat="server" Text="<%$ Resources: _Kartris, ContentText_Notes%>"
                                                AssociatedControlID="txtUserNotes" /></span> <span class="Kartris-DetailsView-Value">
                                                    <asp:TextBox runat="server" ID="txtUserNotes" TextMode="MultiLine" Text='<%#Bind("U_Notes") %>' /></span></li>
                                    </ul>
                                </div>
                            </div>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <%-- Addresses tab --%>
                    <ajaxToolkit:TabPanel ID="tabAddresses" runat="server">
                        <HeaderTemplate>
                            <asp:Literal ID="litTabAddresses" runat="server" Text="<%$ Resources: _Customers, ContentText_Addresses %>" />
                        </HeaderTemplate>
                        <ContentTemplate>
                            <div class="halfwidth" id="billingaddress">
                                <h2>
                                    <asp:Literal ID="litBillingAddress" runat="server" Text="<%$ Resources: _Address, FormLabel_BillingAddress %>" /></h2>
                                <user:AddressesDetails ID="_UC_Billing" runat="server" AddressType="b" />
                            </div>
                            <div class="halfwidth" id="shippingaddress">
                                <h2>
                                    <asp:Literal ID="litShippingAddress" runat="server" Text="<%$ Resources: _Address, FormLabel_ShippingAddress %>" /></h2>
                                <user:AddressesDetails ID="_UC_Shipping" runat="server" AddressType="s" />
                            </div>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <%-- Order/Payment History tab --%>
                    <ajaxToolkit:TabPanel ID="tabPaymentHistory" runat="server">
                        <HeaderTemplate>
                            <asp:Literal ID="litTabPaymentHistory" runat="server" Text='<%$ Resources: _Payments ,ContentText_OrderPaymentHistory %>' />
                        </HeaderTemplate>
                        <ContentTemplate>
                            <!-- Customer Orders -->
                            <div class="halfwidth" id="customerorders">
                                <h2>
                                    <asp:Literal ID="litCustomerOrders" runat="server" Text='<%$ Resources: _Statistics, ContentText_Orders %>' /></h2>
                                <asp:GridView ID="gvwCustomerOrders" CssClass="kartristable" runat="server" AutoGenerateColumns="False" GridLines="None"
                                    AllowPaging="False" DataKeyNames="O_ID">
                                    <Columns>
                                        <asp:TemplateField ItemStyle-CssClass="itemname" SortExpression="O_ID" HeaderText="<%$ Resources: _Orders, ContentText_OrderID %>">
                                            <ItemTemplate>
                                                <a href="_ModifyOrderStatus.aspx?OrderID=<%# Eval("O_ID") %>&FromDate=false&Page=1">
                                                    <asp:Literal ID="litOrderID" runat="server" Text='<%# Eval("O_ID") %>' /></a>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField SortExpression="O_Date" HeaderText="<%$ Resources: _Orders, ContentText_OrderDate %>">
                                            <ItemTemplate>
                                                <asp:Literal ID="litOrderDate" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("O_Date"), "d", Session("_LANG")) %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField SortExpression="O_TotalPrice" HeaderText="<%$ Resources: _Orders, ContentText_OrderValue %>" ItemStyle-CssClass="amount" HeaderStyle-CssClass="amount">
                                            <ItemTemplate>
                                                <asp:Literal ID="litOrderValue" runat="server" Text='<%# CurrenciesBLL.FormatCurrencyPrice(Eval("O_CurrencyID"), Eval("O_TotalPrice"))%>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                                <p>
                                    <span class="totallabel">
                                        <asp:Literal ID="litOrdersTotal" runat="server" Text='<%$ Resources: _Kartris, ContentText_Total %>' /></span>
                                    <strong><span class="total">
                                        <asp:Literal ID="litOrdersTotalValue" runat="server" Text='0' /></span></strong>
                                </p>
                            </div>
                            <!-- Customer Payments -->
                            <div class="halfwidth col2" id="customerpayments">
                                <a class="linkbutton icon_orders floatright" href="_ModifyPayment.aspx?CustomerID=<%# Eval("U_ID") %>">
                                    <asp:Literal ID="litAddPayment2" runat="server" Text="<%$ Resources: _Payments, ContentText_AddPayment %>"></asp:Literal></a><h2>
                                        <asp:Literal ID="litCustomerPayments" runat="server" Text='<%$ Resources: _Kartris, ContentText_Payments %>' /></h2>

                                <asp:GridView ID="gvwCustomerPayments" CssClass="kartristable" runat="server" AutoGenerateColumns="False" GridLines="None"
                                    AllowPaging="False" DataKeyNames="Payment_ID">
                                    <Columns>
                                        <asp:BoundField DataField="Payment_ID" SortExpression="Payment_ID" ItemStyle-CssClass="itemname" HeaderText="<%$ Resources: _Payments, ContentText_PaymentID %>" />
                                        <asp:TemplateField SortExpression="O_Date" HeaderText="<%$ Resources: _Payments, ContentText_PaymentDate %>">
                                            <ItemTemplate>
                                                <asp:Literal ID="litPaymentDate" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("Payment_Date"), "d", Session("_LANG")) %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField SortExpression="Payment_Amount" HeaderText="<%$ Resources: _Kartris, ContentText_Value %>" HeaderStyle-CssClass="amount" ItemStyle-CssClass="amount">
                                            <ItemTemplate>
                                                <asp:Literal ID="litPaymentAmount" runat="server" Text='<%# CurrenciesBLL.FormatCurrencyPrice(Eval("Payment_CurrencyID"),Eval("Payment_Amount")) %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                                <p>
                                    <span class="totallabel">
                                        <asp:Literal ID="litPaymentsTotal" runat="server" Text='<%$ Resources: _Kartris, ContentText_Total %>' /></span>
                                    <strong><span class="total">
                                        <asp:Literal ID="litPaymentsTotalValue" runat="server" Text='0' /></span></strong>
                                </p>
                            </div>
                            <br />
                            <br />
                            <div class="spacer line"></div>

                            <h2 style='<%# FormatTotalColour(CkartrisDataManipulation.FixNullFromDB(Eval("U_CustomerBalance")))%>'>
                                <span class="totallabel">
                                    <asp:Label ID="litUserBalanceLabel" runat="server" Text="<%$ Resources: _Users, ContentText_CustomerBalance %>" /></span>
                                <span class="total">
                                    <asp:Literal ID="litUserBalance" runat="server" Text='<%#CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, CkartrisDataManipulation.FixNullFromDB(Eval("U_CustomerBalance")))%>'></asp:Literal></span>
                            </h2>

                        </ContentTemplate>

                    </ajaxToolkit:TabPanel>
                    <%-- Affiliate tab --%>
                    <ajaxToolkit:TabPanel ID="tabAffiliateInfo" runat="server">
                        <HeaderTemplate>
                            <asp:Literal ID="litTabAffiliateInfo" runat="server" Text="<%$ Resources: _Customers, ContentText_AffiliateDetails %>" />
                        </HeaderTemplate>
                        <ContentTemplate>
                            <div class="buttonbar">
                                <a class="linkbutton icon_orders" href="_AffiliatePayRep.aspx?CustomerID=<%# Eval("U_ID") %>">
                                    <asp:Literal ID="litPageTitleAffiliateReportFor" runat="server" Text='<%$ Resources: _Kartris, PageTitle_AffiliateReportFor %>' /></a>
                            </div>
                            <div class="Kartris-DetailsView">
                                <div class="Kartris-DetailsView-Data">
                                    <ul>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblOrderStatus" runat="server" Text="<%$ Resources: _Customers, FormLabel_IsAffiliate %>" /></span>
                                            <span class="Kartris-DetailsView-Value"><span class="checkbox">
                                                <asp:CheckBox runat="server" ID="chkUserisAffialite" Checked='<%# Bind("U_IsAffiliate")%>' /></span></span>
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblOrderLanguage" runat="server" Text="<%$ Resources: _Customers, FormLabel_Commission %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:TextBox ID="txtAffiliateCommission" runat="server" Text='<%# Eval("U_AffiliateCommission") %>'
                                                    CssClass="shorttext"></asp:TextBox>
                                                <asp:RegularExpressionValidator ID="valRegExAffiliateCommission" runat="server" ControlToValidate="txtAffiliateCommission"
                                                    ErrorMessage="0-100!" Display="Dynamic" CssClass="error" ForeColor="" EnableClientScript="true"
                                                    ValidationExpression="<%$ AppSettings:PercentageRegex %>" />
                                            </span></li>
                                    </ul>
                                </div>
                            </div>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <%-- Mailinglist tab --%>
                    <ajaxToolkit:TabPanel ID="tabMailingListInfo" runat="server">
                        <HeaderTemplate>
                            <asp:Literal ID="litTabMailingListInfo" runat="server" Text="<%$ Resources: _Customers, PageTitle_MailingList %>" />
                        </HeaderTemplate>
                        <ContentTemplate>
                            <div class="Kartris-DetailsView">
                                <div class="Kartris-DetailsView-Data">
                                    <ul>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblMLSignupDate" runat="server" Text="<%$ Resources: ContentText_MLSignupDateTime %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:Literal ID="litSignupDate" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("U_ML_SignupDateTime"), "t", Session("_LANG")) %>'></asp:Literal></span>
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblMLConfirmDateTime" runat="server" Text="<%$ Resources: ContentText_MLConfirmationDateTime %>">
                                            </asp:Label></span> <span class="Kartris-DetailsView-Value">
                                                <asp:Literal ID="litMLConfirmDateTime" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("U_ML_ConfirmationDateTime"), "t", Session("_LANG")) %>'></asp:Literal></span>
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblMLSignupIP" runat="server" Text="<%$ Resources: ContentText_MLSignupIP %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:Literal ID="litMLSignupIP" runat="server" Text='<%# Eval("U_ML_SignupIP") %>'></asp:Literal></span>
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblMLConfirmIP" runat="server" Text="<%$ Resources: ContentText_MLConfirmationIP %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:Literal ID="litMLConfirmIP" runat="server" Text='<%# Eval("U_ML_ConfirmationIP") %>'></asp:Literal></span>
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblMLFormat" runat="server" Text="<%$Resources: ContentText_MLFormat %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:Literal ID="litMLFormat" runat="server" Text='<%#Eval("U_ML_Format") %>'></asp:Literal></span>
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblMLSendMail" runat="server" Text="<%$Resources: ContentText_MLSendMail %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:Literal ID="litMLSendMail" runat="server" Text='<%#Eval("U_ML_SendMail") %>'></asp:Literal></span>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>

                </ajaxToolkit:TabContainer>
                <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                    <asp:LinkButton CausesValidation="True" CssClass="button savebutton" runat="server" OnClick="btnCustomerUpdate_Click"
                        ID="btnCustomerUpdate" Text="<%$ Resources: _Kartris, FormButton_Save %>" ToolTip="<%$ Resources: _Kartris, FormButton_Save %>" />
                    <asp:HyperLink CausesValidation="False" CssClass="button exportbutton" runat="server"
                        ID="btnGDPRExport" Text="<%$ Resources: _GDPR, ContentText_GDPRExport %>" ToolTip="<%$ Resources: _GDPR, ContentText_GDPRExport %>"
                        NavigateUrl="<%# FormatExportURL(Request.RawUrl) %>" />

                    <asp:LinkButton CssClass="button deletebutton" runat="server" ID="btnCustomerDelete"
                        OnClick="btnCustomerDelete_Click" Text="<%$ Resources: ContentText_DeleteThisCustomer %>"
                        ToolTip="<%$ Resources: ContentText_DeleteThisCustomer %>" />

                    <asp:ValidationSummary CausesValidation="True" ID="valSummary" runat="server" ForeColor=""
                        CssClass="valsummary" DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />

                </div>
            </EditItemTemplate>
            <InsertItemTemplate>
                <ajaxToolkit:TabContainer ID="tabContainerProduct2" runat="server" EnableTheming="False"
                    CssClass=".tab" AutoPostBack="false">
                    <%-- Main tab --%>
                    <ajaxToolkit:TabPanel ID="tabMainInfo2" runat="server">
                        <HeaderTemplate>
                            <asp:Literal ID="litTabMainInfo2" runat="server" Text="<%$ Resources: ContentText_ContactAndMiscDetails %>" />
                        </HeaderTemplate>
                        <ContentTemplate>
                            <div class="Kartris-DetailsView">
                                <div class="Kartris-DetailsView-Data">
                                    <ul>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserID2" runat="server" Text="<%$ Resources: _Customers, FormLabel_CustomerID %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:Literal ID="litUserID2" runat="server" Text='New'></asp:Literal></span>
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="litContentTextCustomerName2" runat="server" Text="<%$ Resources: _Kartris, ContentText_CustomerName %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:TextBox ID="txtAccountHolderName2" runat="server" Text=''></asp:TextBox></span>
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserEmail2" runat="server" Text="<%$ Resources: _Kartris, ContentText_Email %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:TextBox ID="txtUserEmail2" runat="server" Text=''></asp:TextBox>
                                                <asp:RequiredFieldValidator ID="valEmailAddress3" runat="server" ControlToValidate="txtUserEmail2"
                                                    CssClass="error" ForeColor="" Display="Dynamic" Text="<%$ Resources: _Kartris, ContentText_RequiredField %>" />
                                                <asp:RegularExpressionValidator ID="valEmailAddress4" runat="server" ControlToValidate="txtUserEmail2"
                                                    Display="Dynamic" ErrorMessage="<%$ Resources: _Kartris, ContentText_BadEmail %>"
                                                    CssClass="error" ForeColor="" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" />
                                            </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserPassword2" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Password %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:TextBox ID="txtUserPassword2" runat="server" Text=''></asp:TextBox>
                                                <asp:RequiredFieldValidator ID="valRequiredUserPassword2" runat="server" ControlToValidate="txtUserPassword2"
                                                    CssClass="error" ForeColor="" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>" />
                                            </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserDiscount2" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Discount %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:TextBox ID="txtUserDiscount2" runat="server" Text='0'></asp:TextBox>
                                                <asp:RegularExpressionValidator ID="valRegExUserDiscount2" runat="server" ControlToValidate="txtUserDiscount2"
                                                    CssClass="error" ForeColor="" ErrorMessage="0-100!" Display="Dynamic" EnableClientScript="true"
                                                    ValidationExpression="<%$ AppSettings:PercentageRegex %>" />
                                            </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserGroup2" runat="server" Text="<%$ Resources: _Customers, FormLabel_CustomerGroup %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:DropDownList ID="ddlUserGroups2" runat="server" DataSourceID="objUserGroups2"
                                                    DataTextField="CG_Name" DataValueField="CG_ID" />
                                                <asp:ObjectDataSource ID="objUserGroups2" runat="server" OldValuesParameterFormatString="original_{0}"
                                                    SelectMethod="_GetCustomerGroups" TypeName="UsersBLL">
                                                    <SelectParameters>
                                                        <asp:SessionParameter Name="numLanguageID" SessionField="_Lang" Type="Byte" DefaultValue="1" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <asp:HiddenField ID="hidUserGroup2" runat="server" Value=''></asp:HiddenField>
                                            </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserApproved2" runat="server" Text="<%$ Resources: _Customers, FormLabel_Approved %>" /></span>
                                            <span class="Kartris-DetailsView-Value"><span class="checkbox">
                                                <asp:CheckBox ID="chkUserApproved2" runat="server" Checked='false' />
                                            </span></span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserLanguage2" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Language %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:DropDownList ID="ddlLanguages2" runat="server" DataSourceID="objLanguages2"
                                                    DataTextField="Lang_FrontName" DataValueField="Lang_ID" />
                                                <asp:ObjectDataSource ID="objLanguages2" runat="server" OldValuesParameterFormatString="original_{0}"
                                                    SelectMethod="GetData" TypeName="kartrisLanguageDataTableAdapters.LanguagesTblAdptr" />
                                                <asp:HiddenField ID="hidUserLanguage2" runat="server" Value='' />
                                            </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserSupportEndDate2" runat="server" Text="<%$ Resources: _Customers, FormLabel_SupportEndDate %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:TextBox ID="txtUserSupportEndDate2" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(CkartrisDataManipulation.FixNullFromDB(Eval("U_SupportEndDate")), "d", Session("_LANG")) %>'></asp:TextBox>
                                                <asp:ImageButton ID="btnCalendar2" runat="server" AlternateText="" ImageUrl="~/Skins/Admin/Images/icon_calendar.gif"
                                                    Width="16" Height="16" CssClass="calendarbutton" />
                                                <ajaxToolkit:CalendarExtender Format="dd MMM yy" Animated="true" PopupButtonID="btnCalendar2"
                                                    TargetControlID="txtUserSupportEndDate2" runat="server" ID="calDateSearch2" PopupPosition="BottomLeft"
                                                    CssClass="calendar" />
                                            </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblUserNotes2" runat="server" Text="<%$ Resources: _Kartris, ContentText_Notes%>"
                                                AssociatedControlID="txtUserNotes2" /></span> <span class="Kartris-DetailsView-Value">
                                                    <asp:TextBox runat="server" ID="txtUserNotes2" TextMode="MultiLine" Text='' /></span></li>
                                    </ul>
                                </div>
                            </div>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <%-- Affiliate tab --%>
                    <ajaxToolkit:TabPanel ID="tabAffiliateInfo2" runat="server">
                        <HeaderTemplate>
                            <asp:Literal ID="litTabAffiliateInfo2" runat="server" Text="<%$ Resources: _Customers, ContentText_AffiliateDetails %>" />
                        </HeaderTemplate>
                        <ContentTemplate>
                            <div class="Kartris-DetailsView">
                                <div class="Kartris-DetailsView-Data">
                                    <ul>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblOrderStatus2" runat="server" Text="<%$ Resources: _Customers, FormLabel_IsAffiliate %>" /></span>
                                            <span class="Kartris-DetailsView-Value"><span class="checkbox">
                                                <asp:CheckBox runat="server" ID="chkUserisAffialite2" Checked='false' /></span></span>
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblOrderLanguage2" runat="server" Text="<%$ Resources: _Customers, FormLabel_Commission %>" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:TextBox ID="txtAffiliateCommission2" runat="server" Text='0'></asp:TextBox>
                                                <asp:RegularExpressionValidator ID="valRegExAffiliateCommission2" runat="server"
                                                    ControlToValidate="txtAffiliateCommission2" ErrorMessage="0-100!" Display="Dynamic"
                                                    CssClass="error" ForeColor="" EnableClientScript="true" ValidationExpression="<%$ AppSettings:PercentageRegex %>" />
                                            </span></li>
                                    </ul>
                                </div>
                            </div>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                </ajaxToolkit:TabContainer>
                <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                    <asp:LinkButton CausesValidation="True" CssClass="button savebutton" runat="server" OnClick="btnCustomerAdd_Click"
                        ID="btnCustomerAdd" Text="<%$ Resources: _Kartris, FormButton_Save %>" ToolTip="<%$ Resources: _Kartris, FormButton_Save %>" />
                    <asp:ValidationSummary CausesValidation="True" ID="valSummary" runat="server" ForeColor=""
                        CssClass="valsummary" DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                </div>
            </InsertItemTemplate>
        </asp:FormView>
    </ContentTemplate>
</asp:UpdatePanel>
