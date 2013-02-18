<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_Coupons.ascx.vb" Inherits="UserControls_Back_KartrisCoupons" %>
<%@ Register TagPrefix="_user" TagName="EditCouponPopup" Src="~/UserControls/Back/_EditCouponPopup.ascx" %>
<div id="page_coupons">
    <h1>
        <asp:Literal ID="litPageTitleCoupons" runat="server" Text="<%$ Resources: _Coupons, PageTitle_Coupons %>" />
    </h1>
    <asp:UpdatePanel ID="updCouponsList" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:MultiView ID="mvwCoupons" runat="server">
                <asp:View ID="viwCouponGroups" runat="server">
                    <asp:LinkButton ID="lnkAddCouponGroup" runat="server" Text="<%$ Resources: _Kartris, FormButton_New %>"
                                        CssClass="linkbutton icon_new floatright" /><br />
                    <asp:MultiView ID="mvwCouponGroups" runat="server" ActiveViewIndex="0">
                        <asp:View ID="viwCouponGroupsData" runat="server">
                            <div id="searchboxrow">
                                <asp:Panel ID="pnlFind" runat="server" DefaultButton="btnSearchCoupon">
                                    <asp:TextBox ID="txtSearchCouponCode" runat="server" MaxLength="10" />
                                    <asp:Button ID="btnSearchCoupon" runat="server" Text="<%$ Resources: _Kartris, FormButton_Search %>"
                                        CssClass="button" />
                                    <asp:Button ID="btnClear" runat="server" CssClass="button cancelbutton" Text='<%$ Resources:_Kartris, ContentText_Clear %>' />
                                    <br />
                                    <br />
                                    <asp:Literal ID="litContentTextEnterCouponCode" runat="server" Text="<%$ Resources: _Coupons, ContentText_EnterCouponCode %>" />
                                    <br />
                                    <br />
                                </asp:Panel>
                            </div>
                            <asp:GridView CssClass="kartristable stats" ID="gvwCouponGroups" runat="server" AllowPaging="True" PageSize="10"
                                AutoGenerateColumns="False" AutoGenerateEditButton="False" DataKeyNames="CreatedTime"
                                GridLines="None" >
                                <Columns>
                                    <asp:TemplateField>
                                        <HeaderTemplate>
                                            <asp:Literal ID="litContentTextDateTimeCreated" runat="server" Text="<%$ Resources: _Kartris, ContentText_DateCreated %>" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:Literal ID="litCreatedTime" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("CreatedTime"), "d", Session("_LANG")) %>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField HeaderText="<%$ Resources: _Kartris, ContentText_Qty %>" DataField="Qty" />
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:LinkButton ID="lnkBtnSelectGroup" runat="server" CommandArgument='<%# Container.DataItemIndex %>'
                                                CommandName="selectCoupon" Text="<%$ Resources: _Kartris, FormButton_Select %>"
                                                CssClass="linkbutton icon_edit floatright" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </asp:View>
                        <asp:View ID="viwNoItems" runat="server">
                            <asp:Panel ID="pnlNoItems" runat="server" CssClass="noresults">
                                <asp:Literal ID="litNoItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>">
                                </asp:Literal>
                            </asp:Panel>
                        </asp:View>
                    </asp:MultiView>
                </asp:View>
                <asp:View ID="viwCoupons" runat="server">
                    <asp:GridView CssClass="kartristable" ID="gvwCoupons" runat="server" AllowPaging="True" DataKeyNames="CP_ID"
                        AutoGenerateColumns="False" AutoGenerateEditButton="False" GridLines="None" PageSize="15">
                        <Columns>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <asp:Literal ID="litContentTextCouponCode" runat="server" Text="<%$ Resources: _Coupons, ContentText_CouponCode %>" /></HeaderTemplate>
                                <ItemStyle CssClass="column1" />
                                <ItemTemplate>
                                    <asp:Literal ID="CP_CouponCode" runat="server" Text='<%# Eval("CP_CouponCode") %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <asp:Literal ID="litFormLabelCouponValue" runat="server" Text="<%$ Resources: _Coupons, ContentText_CouponValue %>" /></HeaderTemplate>
                                <ItemStyle CssClass="column2" />
                                <ItemTemplate>
                                    <asp:Literal ID="litCouponValue" runat="server" Text='<%# Eval("CouponValue") %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <asp:Literal ID="litFormLabelStartDate" runat="server" Text="<%$ Resources: _Kartris, FormLabel_StartDate %>" /></HeaderTemplate>
                                <ItemStyle CssClass="column3" />
                                <ItemTemplate>
                                    <asp:Literal ID="litStartDate" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("StartDate"), "d", Session("_LANG")) %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <asp:Literal ID="litFormLabelEndDate" runat="server" Text="<%$ Resources: _Kartris, FormLabel_EndDate %>" /></HeaderTemplate>
                                <ItemStyle CssClass="column4" />
                                <ItemTemplate>
                                    <asp:Literal ID="litEndDate" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("EndDate"), "d", Session("_LANG")) %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <asp:Literal ID="litFormLabelReusable" runat="server" Text="<%$ Resources: _Coupons, FormLabel_Reusable %>" /></HeaderTemplate>
                                <ItemStyle CssClass="column5" />
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkReusable" runat="server" CssClass="checkbox" Checked='<%# Eval("CP_Reusable") %>'
                                        Enabled="false" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <asp:Literal ID="litFormLabelUsed" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Used %>" /></HeaderTemplate>
                                <ItemStyle CssClass="column6" />
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkUsed" runat="server" CssClass="checkbox" Checked='<%# Eval("CP_Used") %>'
                                        Enabled="false" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <asp:Literal ID="litFormLabelLive" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Live %>" /></HeaderTemplate>
                                <ItemStyle CssClass="column7" />
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkLive" runat="server" CssClass="checkbox" Checked='<%# Eval("CP_Enabled") %>'
                                        Enabled="false" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <ItemStyle CssClass="column8" />
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkBtnDelete" runat="server" CommandArgument='<%# Container.DataItemIndex %>'
                                        CommandName="DeleteCoupon" Text="<%$ Resources: _Kartris, FormButton_Delete %>"
                                        CssClass="linkbutton icon_delete floatright normalweight" Visible='<%# NOT Eval("CP_Used") %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <asp:LinkButton ID="lnkBtnBack" runat="server" CommandName="BackToGroup" Text="<%$ Resources: _Kartris, FormButton_Back %>"
                                        CssClass="linkbutton icon_back floatright" />
                                </HeaderTemplate>
                                <ItemStyle CssClass="selectfield" />
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkBtnEdit" runat="server" CommandArgument='<%# Container.DataItemIndex %>'
                                        CommandName="EditCoupon" Text="<%$ Resources: _Kartris, FormButton_Edit %>" CssClass="linkbutton icon_edit normalweight"
                                        Visible='<%# NOT Eval("CP_Used") %>' />
                                    <asp:LinkButton ID="lnkBtnEnable" runat="server" CommandArgument='<%# Container.DataItemIndex %>'
                                        CommandName="EnableCoupon" Text="<%$ Resources: _Coupons, ContentText_EnableThisCoupon %>"
                                        CssClass="linkbutton icon_edit" Visible='<%# NOT Eval("CP_Enabled") %>' />
                                    <asp:LinkButton ID="lnkBtnDisable" runat="server" CommandArgument='<%# Container.DataItemIndex %>'
                                        CommandName="DisableCoupon" Text="<%$ Resources: _Coupons, ContentText_DisableThisCoupon %>"
                                        CssClass="linkbutton icon_edit" Visible='<%# Eval("CP_Enabled") %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                    <_user:EditCouponPopup ID="_UC_EditCoupon" runat="server" />
                </asp:View>
                <asp:View ID="viwNewCoupon" runat="server">
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <%-- Coupon Value --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextCouponValue" runat="server" Text="<%$ Resources: _Coupons, ContentText_CouponValue %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:PlaceHolder ID="phdNonPromotionType" runat="server">
                                        <asp:TextBox ID="txtDiscountValue" runat="server" CssClass="shorttext" MaxLength="8" />
                                        <asp:RequiredFieldValidator ID="valRequiredCouponValue" runat="server" CssClass="error"
                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                            Display="Dynamic" ControlToValidate="txtDiscountValue" ValidationGroup="grpNewCoupon" />
                                        <asp:RegularExpressionValidator ID="valRegexCouponValue" runat="server" ControlToValidate="txtDiscountValue"
                                            CssClass="error" Display="Dynamic" ValidationGroup="grpNewCoupon" ErrorMessage="*" ForeColor="" 
                                            SetFocusOnError="true" ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filDiscountValue" runat="server" TargetControlID="txtDiscountValue"
                                                    FilterType="Numbers, Custom" ValidChars=".," />
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder ID="phdPromotionType" runat="server" Visible="false">
                                        <asp:DropDownList ID="ddlPromotions" runat="server" CssClass="midtext">
                                        </asp:DropDownList>
                                        <asp:CompareValidator ID="valComparePromotion" runat="server" CssClass="error" ForeColor=""
                                            ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ControlToValidate="ddlPromotions"
                                            Operator="NotEqual" ValueToCompare="0" Display="Dynamic" SetFocusOnError="true"
                                            ValidationGroup="grpNewCoupon" Enabled="false" />
                                    </asp:PlaceHolder>            
                                    <asp:DropDownList ID="ddlDiscountType" runat="server" CssClass="midtext" AutoPostBack="true">
                                    </asp:DropDownList>
                                    
                                </span></li>
                            </ul>
                        </div>
                    </div>
                    <div class="line">
                    </div>
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelStartDate" runat="server" Text='<%$ Resources: _Kartris, FormLabel_StartDate %>' /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:UpdatePanel ID="updDates" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:ImageButton CssClass="calendarbutton" ID="imgBtnStart" runat="server" ImageUrl="~/Skins/Admin/Images/icon_calendar.gif"
                                                    Width="16" Height="16" /><asp:TextBox ID="txtStartDate" runat="server" MaxLength="20"
                                                        CssClass="midtext" />
                                                <ajaxToolkit:CalendarExtender ID="calExtStartDate" runat="server" TargetControlID="txtStartDate"
                                                    PopupButtonID="imgBtnStart" Format="yyyy/MM/dd" CssClass="calendar" />
                                                <asp:RequiredFieldValidator ID="valRequiredStartDate" runat="server" CssClass="error"
                                                    ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                    ControlToValidate="txtStartDate" ValidationGroup="grpNewCoupon" SetFocusOnError="true" Display="Dynamic" />
                                                <ajaxToolkit:FilteredTextBoxExtender ID="filStartDate" runat="server" TargetControlID="txtStartDate"
                                                    FilterType="Numbers, Custom" ValidChars="/" />
                                                <asp:CompareValidator ID="valCompareCheckStartIsDate" runat="server" ErrorMessage='<%$ Resources: _Kartris, ContentText_NotValidDate %>'
                                                    ForeColor="" ControlToValidate="txtStartDate" Type="Date" Operator="DataTypeCheck" SetFocusOnError="true"
                                                    CultureInvariantValues="true" Display="Dynamic" ValidationGroup="grpNewCoupon" CssClass="error" />
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelEndDate" runat="server" Text='<%$ Resources: _Kartris, FormLabel_EndDate %>' /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:UpdatePanel ID="updDates2" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:ImageButton CssClass="calendarbutton" ID="imgBtnEnd" runat="server" ImageUrl="~/Skins/Admin/Images/icon_calendar.gif"
                                                    Width="16" Height="16" /><asp:TextBox ID="txtEndDate" runat="server" MaxLength="20"
                                                        CssClass="midtext" />
                                                <ajaxToolkit:CalendarExtender ID="calExtEndDate" runat="server" TargetControlID="txtEndDate"
                                                    PopupButtonID="imgBtnEnd" Format="yyyy/MM/dd" CssClass="calendar" />
                                                <asp:RequiredFieldValidator ID="valRequiredEndDate" runat="server" CssClass="error"
                                                    ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                    ControlToValidate="txtEndDate" SetFocusOnError="true" ValidationGroup="grpNewCoupon" Display="Dynamic" />
                                                <ajaxToolkit:FilteredTextBoxExtender ID="filEndDate" runat="server" TargetControlID="txtEndDate"
                                                    FilterType="Numbers, Custom" ValidChars="/" />
                                                <asp:CompareValidator ID="valCompareCheckPeriod" runat="server" ErrorMessage='<%$ Resources: _Promotions, ContentText_EndBeforeStartDate %>'
                                                    ForeColor="" ControlToValidate="txtEndDate" ControlToCompare="txtStartDate" Operator="GreaterThanEqual"
                                                    Type="Date" SetFocusOnError="true" CultureInvariantValues="true" Display="Dynamic"
                                                    ValidationGroup="grpNewCoupon" CssClass="error" />
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </span></li>
                            </ul>
                        </div>
                    </div>
                    <div class="line">
                    </div>
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <%-- Coupon Code --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextCouponCode" runat="server" Text="<%$ Resources: _Coupons, ContentText_CouponCode %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:CheckBox ID="chkFixedCouponCode" runat="server" CssClass="checkbox" AutoPostBack="true" />
                                    <asp:TextBox ID="txtCouponCode" runat="server" CssClass="midtext" MaxLength="15" Visible="false" />
                                    <asp:RequiredFieldValidator ID="valRequiredCouponCode" runat="server" CssClass="error"
                                        ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                        Display="Dynamic" ControlToValidate="txtCouponCode" ValidationGroup="grpNewCoupon"
                                        Enabled="false" />
                                </span></li>
                                <%-- Quantity of Coupons --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelCouponQuantity" runat="server" Text="<%$ Resources: _Coupons, FormLabel_CouponQuantity %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtQty" runat="server" CssClass="shorttext" MaxLength="5" />
                                    <asp:RequiredFieldValidator ID="valRequiredValidatorQty" runat="server" CssClass="error"
                                        ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                        Display="Dynamic" ControlToValidate="txtQty" ValidationGroup="grpNewCoupon" />
                                    <asp:CompareValidator ID="valCompareQty" runat="server" ErrorMessage="*" CssClass="error"
                                        ForeColor="" Display="Dynamic" ControlToValidate="txtQty" Type="Integer" ValidationGroup="grpNewCoupon"
                                        Operator="DataTypeCheck" />
                                </span></li>
                                <%-- Reusable --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelReusable" runat="server" Text="<%$ Resources: _Coupons, FormLabel_Reusable %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:CheckBox ID="chkReusable" runat="server" CssClass="checkbox" />
                                </span></li>
                            </ul>
                        </div>
                    </div>
                    <%-- Save Button  --%>
                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                        <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:LinkButton ID="lnkBtnSaveCoupon" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                    ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' ValidationGroup="grpNewCoupon" />
                                <asp:LinkButton ID="lnkBtnCancelCoupon" runat="server" CssClass="button cancelbutton"
                                    Text='<%$ Resources: _Kartris, FormButton_Cancel %>' ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' /><asp:ValidationSummary
                                        ID="valSummary" runat="server" ForeColor="" CssClass="valsummary" DisplayMode="BulletList"
                                        HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" ValidationGroup="grpNewCoupon" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                </asp:View>
                <asp:View ID="viwNoResult" runat="server">
                    <asp:LinkButton ID="lnkBtnBack" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>'
                        CssClass="linkbutton floatright" />
                    <asp:Panel ID="pnlNoResult" runat="server" CssClass="noresults">
                        <asp:Literal ID="litNoResult" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" /></asp:Panel>
                </asp:View>
            </asp:MultiView>
            <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
<asp:UpdateProgress ID="prgCouponsList" runat="server" AssociatedUpdatePanelID="updCouponsList">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
