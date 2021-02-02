<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_EditCouponPopup.ascx.vb"
    Inherits="UserControls_Back_EditCouponPopup" %>

<script type="text/javascript">
    function onSave() {
        var postBack = new Sys.WebForms.PostBackAction();
        postBack.set_target('lnkBtnSaveCoupon');
        postBack.set_eventArgument('');
        postBack.performAction();
    }
</script>

<div id="section_editcoupon">
    <asp:UpdatePanel ID="updConfirmationMessage" runat="server">
        <ContentTemplate>
            <asp:Panel ID="pnlMessage" runat="server" Style="display: none" CssClass="popup">
                <h2>
                    <asp:Literal ID="litTitle" runat="server" Text="<%$ Resources: _Coupons ,PageTitle_Coupons %>" /></h2>
                <asp:LinkButton ID="lnkExtenderCancel" runat="server" Text="" CssClass="closebutton linkbutton2" />
                <asp:LinkButton ID="lnkBtn" runat="server"></asp:LinkButton>
                <p>
                    <asp:Literal ID="litMessage" runat="server" Text="<%$ Resources: _Coupons, ContentText_CouponNotFound %>"
                        Visible="false" /></p>
                <asp:Literal ID="litErrorMessage" runat="server" Visible="false" />
                <asp:PlaceHolder ID="phdContents" runat="server">
                    <asp:Literal ID="litCouponID" runat="server" Visible="false" />
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
                                            CssClass="error" Display="Dynamic" ValidationGroup="grpNewCoupon" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
                                            ForeColor="" SetFocusOnError="true" ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
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
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelStartDate" runat="server" Text='<%$ Resources: _Kartris, FormLabel_StartDate %>' /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:UpdatePanel ID="updDates" runat="server" UpdateMode="Conditional" RenderMode="Inline">
                                            <ContentTemplate><div style="position: relative;">
                                                <asp:ImageButton CssClass="calendarbutton" ID="imgBtnStart" runat="server" ImageUrl="~/Skins/Admin/Images/icon_calendar.gif"
                                                    Width="16" Height="16" />
                                                <asp:TextBox ID="txtStartDate" runat="server" MaxLength="20" CssClass="midtext" />
                                                <ajaxToolkit:CalendarExtender ID="calStartDate" runat="server" TargetControlID="txtStartDate"
                                                    PopupButtonID="imgBtnStart" Format="yyyy/MM/dd" CssClass="calendar" />
                                                <asp:RequiredFieldValidator ID="valRequiredStartDate" runat="server" CssClass="error"
                                                    ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                    ControlToValidate="txtStartDate" ValidationGroup="grpNewCoupon" SetFocusOnError="true" Display="Dynamic" />
                                                <ajaxToolkit:FilteredTextBoxExtender ID="filStartDate" runat="server" TargetControlID="txtStartDate"
                                                    FilterType="Numbers, Custom" ValidChars="/" />
                                                <asp:CompareValidator ID="valCompareCheckStartIsDate" runat="server" ErrorMessage='<%$ Resources: _Kartris, ContentText_NotValidDate %>'
                                                    CssClass="error" ForeColor="" ControlToValidate="txtStartDate" Type="Date" Operator="DataTypeCheck"
                                                    SetFocusOnError="true" CultureInvariantValues="true" Display="Dynamic" ValidationGroup="grpNewCoupon" /></div>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelEndDate" runat="server" Text='<%$ Resources: _Kartris, FormLabel_EndDate %>' /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:UpdatePanel ID="updDates2" runat="server" UpdateMode="Conditional" RenderMode="Inline">
                                            <ContentTemplate><div style="position: relative;">
                                                <asp:ImageButton CssClass="calendarbutton" ID="imgBtnEnd" runat="server" ImageUrl="~/Skins/Admin/Images/icon_calendar.gif"
                                                    Width="16" Height="16" /><asp:TextBox ID="txtEndDate" runat="server" MaxLength="20"
                                                        CssClass="midtext" />
                                                <ajaxToolkit:CalendarExtender ID="calEndDate" runat="server" TargetControlID="txtEndDate"
                                                    PopupButtonID="imgBtnEnd" Format="yyyy/MM/dd" CssClass="calendar" />
                                                <asp:RequiredFieldValidator ID="valRequiredEndDate" runat="server" CssClass="error"
                                                    ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                    ControlToValidate="txtEndDate" SetFocusOnError="true" ValidationGroup="grpNewCoupon" Display="Dynamic" />
                                                <ajaxToolkit:FilteredTextBoxExtender ID="filEndDate" runat="server" TargetControlID="txtEndDate"
                                                    FilterType="Numbers, Custom" ValidChars="/" />
                                                <asp:CompareValidator ID="valCompareCheckPeriod" runat="server" ErrorMessage='<%$ Resources: _Promotions, ContentText_EndBeforeStartDate %>'
                                                    CssClass="error" ForeColor="" ControlToValidate="txtEndDate" ControlToCompare="txtStartDate"
                                                    Operator="GreaterThanEqual" Type="Date" SetFocusOnError="true" CultureInvariantValues="true"
                                                    Display="Dynamic" ValidationGroup="grpNewCoupon" /></div>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </span></li>
                            </ul>
                        </div>
                    </div>
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <%-- Coupon Code --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextCouponCode" runat="server" Text="<%$ Resources: _Coupons, ContentText_CouponCode %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtCouponCode" runat="server" CssClass="midtext" MaxLength="8" Visible="True"
                                        ReadOnly="true" />
                                </span></li>
                                <%-- Reusable --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelReusable" runat="server" Text="<%$ Resources: _Coupons, FormLabel_Reusable %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:CheckBox ID="chkReusable" runat="server" CssClass="checkbox" />
                                </span></li>
                                <%-- Live --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelLive" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Live %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:CheckBox ID="chkLive" runat="server" CssClass="checkbox" />
                                </span></li>
                            </ul>
                        </div>
                    </div>
                    <%-- Save Button  --%>
                    <div class="submitbuttons">
                        <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:Button ID="lnkBtnSaveCoupon" runat="server" CssClass="button" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                    ValidationGroup="grpNewCoupon" OnClick="lnkBtnSaveCoupon_Click" />
                                <asp:Button ID="lnkBtnCancelCoupon" runat="server" CssClass="button cancelbutton"
                                    Text='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                                <asp:ValidationSummary ID="valSummary" runat="server" CssClass="valsummary" DisplayMode="BulletList"
                                    ForeColor="" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" ValidationGroup="grpNewCoupon" />    
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                    <asp:LinkButton ID="lnkExtenderOk" runat="server" Text="" CssClass="invisible" />
                </asp:PlaceHolder>
            </asp:Panel>
            <ajaxToolkit:ModalPopupExtender ID="popExtender" runat="server" TargetControlID="lnkBtn"
                PopupControlID="pnlMessage" OnOkScript="onSave()" BackgroundCssClass="popup_background"
                OkControlID="lnkExtenderOk" CancelControlID="lnkExtenderCancel" DropShadow="False"
                RepositionMode="None">
            </ajaxToolkit:ModalPopupExtender>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
