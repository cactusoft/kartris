<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_EditPayment.ascx.vb"
    Inherits="UserControls_Back_EditPayment" %>
<%@ Register TagPrefix="_user" TagName="AnimatedText" Src="~/UserControls/Back/_AnimatedText.ascx" %>
<%@ Register TagPrefix="_user" TagName="AutoComplete" Src="~/UserControls/Back/_AutoCompleteInput.ascx" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <a class="linkbutton icon_back floatright" href='javascript:history.back()'>
                <asp:Literal ID="litContentTextBackLink" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>' /></a>
        <div id="paymentdetails">
            <div>
                <h2>
                    <asp:Literal ID="litPaymentDetails" runat="server" Text="<%$ Resources: _Payments, ContentText_PaymentDetails %>" /></h2>
                <asp:UpdatePanel ID="updPaymentDetails" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <div class="Kartris-DetailsView">
                            <div class="Kartris-DetailsView-Data">
                                <ul>
                                    <!-- Payment ID -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="lblPaymentID" runat="server" Text="<%$ Resources:_Kartris, ContentText_ID %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litPaymentID" runat="server" />
                                    </span></li>

                                    <!-- Payment Date -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litPaymentDate" runat="server" Text="<%$ Resources:_Kartris, ContentText_Date %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:ImageButton ID="btnCalendar" runat="server" AlternateText="" ImageUrl="~/Skins/Admin/Images/icon_calendar.gif"
                                        Width="16" Height="16" CssClass="calendarbutton" />
                                        <asp:TextBox ID="txtPaymentDate" runat="server" CssClass="midtext" MaxLength="11" />
                                        <asp:RequiredFieldValidator ID="valCreationDate" runat="server" ControlToValidate="txtPaymentDate"
                                            CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            Display="Dynamic" SetFocusOnError="true" />
                                        <ajaxToolkit:CalendarExtender Animated="true" ID="calDate" runat="server"
                                            TargetControlID="txtPaymentDate" PopupButtonID="btnCalendar"
                                            Format="d MMM yy" PopupPosition="BottomLeft" CssClass="calendar" />
                                    </span></li>


                                    <!-- Payment Order -->
                                     <li>   
                                        <span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="litContentTextCategoryParent" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderID %>"></asp:Label>
                                            (<asp:Label ID="lblOptional" runat="server" Text="<%$ Resources: _Options, FormLabel_IsOptional %>"></asp:Label>)
                                        </span><span class="Kartris-DetailsView-Value">
<asp:UpdatePanel ID="updPaymentOrders" runat="server" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:TextBox ID="txtOrderID" runat="server" />
                                                    <asp:LinkButton ID="lnkBtnAddOrder" class="linkbutton icon_new" runat="server"
                                                        Text='<%$ Resources:_Kartris, FormButton_Add %>' CausesValidation="false" /><br />
                                                    <asp:ListBox ID="lbxOrders" runat="server"></asp:ListBox>
                                                    <asp:LinkButton ID="lnkBtnRemoveOrder" class="linkbutton icon_delete" runat="server"
                                                        Text='<%$ Resources:_Kartris, ContentText_RemoveSelected %>' CausesValidation="false" /><br />
                                                        
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </span>
                                    </li>
                                    <!-- Payment Customer ID -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="lblPaymentCustomerEmail" runat="server" Text="<%$ Resources:_Reviews, ContentText_CustomerEmail %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtPaymentCustomerEmail" runat="server"  AutoPostBack="true" />
                                        <asp:RequiredFieldValidator ID="valCustomerEmail" runat="server" ControlToValidate="txtPaymentCustomerEmail"
                                            CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            Display="Dynamic" SetFocusOnError="true" />
                                         <asp:RegularExpressionValidator ID="valCustomerEmail2" runat="server" ControlToValidate="txtPaymentCustomerEmail"
                                                            Display="Dynamic" ErrorMessage="<%$ Resources: Kartris, ContentText_BadEmail %>"
                                                            ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="error"
                                                            ForeColor="" />
                                    </span>
                                    
                                    
                                    <div>
                                        <asp:UpdatePanel ID="updCustomerDetails" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <div class="Kartris-DetailsView">
                                                    <div class="Kartris-DetailsView-Data">
                                                        <ul>
                                                            <!-- CustomerID -->
                                                            <li><span class="Kartris-DetailsView-Name">
                                                                <asp:Literal ID="lblPaymentCustomerID" runat="server" Text="<%$ Resources: _Customers, FormLabel_CustomerID %>" />
                                                            </span><span class="Kartris-DetailsView-Value">
                                                                <asp:Literal ID="litPaymentCustomerID" runat="server" />
                                                            </span></li>
                                                            <!-- CustomerName -->
                                                            <li><span class="Kartris-DetailsView-Name">
                                                                <asp:Literal ID="lblPaymentCustomerName" runat="server" Text="<%$ Resources: _Kartris, ContentText_CustomerName %>" />
                                                            </span><span class="Kartris-DetailsView-Value">
                                                                <asp:Literal ID="litPaymentCustomerName" runat="server" />
                                                            </span></li>
                                                    </div>
                                                </div>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </div>


                                    </li>

                                    <!-- Payment Gateway -->
                                   <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblPaymentGateway" runat="server"
                                            Text="<%$ Resources: _Orders, ContentText_PaymentGateWay %>" /></span><span class="Kartris-DetailsView-Value">
                                            <asp:Literal ID="litInactivePaymentGateway" runat="server" />
                                            <asp:DropDownList ID="ddlPaymentGateways" runat="server" />
                                            <asp:RequiredFieldValidator ID="valPaymentGateways" runat="server"
                                                ControlToValidate="ddlPaymentGateways" CssClass="error" ForeColor="" SetFocusOnError="true"
                                                Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>">
                                                </asp:RequiredFieldValidator></span>
                                    </li>


                                     <!-- Payment Gateway Reference Code-->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litPaymentReferenceCode" runat="server" Text="<%$ Resources:_Orders, ContentText_ReferenceCode %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtPaymentReferenceCode" runat="server" />
                                        <asp:RequiredFieldValidator ID="valReferenceCode" runat="server" ControlToValidate="txtPaymentReferenceCode"
                                            CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            Display="Dynamic" SetFocusOnError="true" />
                                    </span></li>
                                   <!-- Currency ID -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litPaymentCurrency" runat="server" Text="<%$ Resources:_Currency, ContentText_Currency %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                                <asp:DropDownList ID="ddlPaymentCurrency" runat="server" AutoPostBack="True" />
                                    </span></li>
                                    <!-- GateWay Currency Rate -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litPaymentExchangeRate" runat="server" Text="<%$ Resources:_Currency, ContentText_ExchangeRate %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtPaymentCurrencyRate" runat="server" />
                                    </span></li>
                                    <!-- Payment Amount -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litPaymentAmount" runat="server" Text="<%$ Resources:Kartris, ContentText_Amount %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtPaymentAmount" runat="server" />
                                        <asp:RequiredFieldValidator ID="valPaymentAmount" runat="server" ControlToValidate="txtPaymentAmount"
                                            CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            Display="Dynamic" SetFocusOnError="true" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filPaymentAmount" runat="server" TargetControlID="txtPaymentAmount"
                                            FilterType="Custom,Numbers" ValidChars="-,."/>
                                    </span></li>
                                </ul>
                            </div>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
            <div class="spacer">
            </div>
            <%-- Save Button  --%>
            <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:LinkButton ID="btnSave" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                            ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' CausesValidation="true" />
                        <span class="floatright">
                            <asp:LinkButton ID="lnkBtnDelete" CssClass="button icon_delete deletebutton" runat="server" CausesValidation="false"
                                Text='<%$ Resources: _Kartris, FormButton_Delete %>' ToolTip='<%$ Resources: _Kartris, FormButton_Delete %>'
                                OnClick="lnkBtnDelete_Click" /></span>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgSave" runat="server" AssociatedUpdatePanelID="updSaveChanges">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
