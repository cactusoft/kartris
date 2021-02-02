<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_EditPromotion.ascx.vb"
    Inherits="UserControls_Back_EditPromotion" %>
<%@ Register TagPrefix="_user" TagName="LanguageContainer" Src="~/UserControls/Back/_LanguageContainer.ascx" %>
<%@ Register TagPrefix="_user" TagName="PromotionStringBuilder" Src="~/UserControls/Back/_PromotionStringBuilder.ascx" %>
<%@ Register TagPrefix="_user" TagName="FileUploader" Src="~/UserControls/Back/_FileUploader.ascx" %>
<%@ Register TagPrefix="_user" TagName="UploaderPopup" Src="~/UserControls/Back/_UploaderPopup.ascx" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Literal ID="litPromotionID" runat="server" Text="0" Visible="false" />
        <!-- Language String -->
        <asp:UpdatePanel ID="updLanguageContainer" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:PlaceHolder ID="phdLanguageContainer" runat="server">
                    <_user:LanguageContainer ID="_UC_LanguageContainer" runat="server" />
                </asp:PlaceHolder>
            </ContentTemplate>
        </asp:UpdatePanel>
        <div class="line">
        </div>
        <div class="Kartris-DetailsView">
            <div class="Kartris-DetailsView-Data">
                <ul>
                    <!-- Live -->
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litFormLabelPromotionsLive" runat="server" Text='<%$ Resources: _Kartris, ContentText_Active %>' /></span>
                        <span class="Kartris-DetailsView-Value">
                            <asp:CheckBox ID="chkLive" runat="server" CssClass="checkbox" />
                            <asp:TextBox ID="txtToday" runat="server" Visible="true" CssClass="invisible" />
                        </span></li>
                    <!-- Start/End Date -->
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litFormLabelStartDate" runat="server" Text='<%$ Resources: _Kartris, FormLabel_StartDate %>' /></span>
                        <span class="Kartris-DetailsView-Value">
                            <asp:UpdatePanel ID="updDates" runat="server" UpdateMode="Conditional">
                                <ContentTemplate><div style="position: relative;">
                                    <asp:ImageButton ID="imgBtnStart" runat="server" ImageUrl="~/Skins/Admin/Images/icon_calendar.gif"
                                        Width="16" Height="16" CssClass="calendarbutton" /><asp:TextBox ID="txtStartDate"
                                            runat="server" MaxLength="20" CssClass="midtext" />
                                    <ajaxToolkit:CalendarExtender ID="calenderExtStartDate" runat="server" TargetControlID="txtStartDate"
                                        PopupButtonID="imgBtnStart" Format="yyyy/MM/dd" CssClass="calendar" />
                                    <asp:RequiredFieldValidator ID="valRequiredStartDate" runat="server" CssClass="error"
                                        ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                        ControlToValidate="txtStartDate" ValidationGroup="EditPromotion" SetFocusOnError="true" />
                                    <ajaxToolkit:FilteredTextBoxExtender ID="filStartDate" runat="server" TargetControlID="txtStartDate"
                                        FilterType="Numbers, Custom" ValidChars="/" />
                                    <asp:CompareValidator ID="valCompareCheckStartIsDate" runat="server" ErrorMessage='<%$ Resources: _Kartris, ContentText_NotValidDate %>'
                                        CssClass="error" ForeColor="" ControlToValidate="txtStartDate" Type="Date" Operator="DataTypeCheck"
                                        SetFocusOnError="true" CultureInvariantValues="true" Display="Dynamic" /></div>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </span></li>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litFormLabelEndDate" runat="server" Text='<%$ Resources: _Kartris, FormLabel_EndDate %>' /></span>
                        <span class="Kartris-DetailsView-Value">
                            <asp:UpdatePanel ID="updDates2" runat="server" UpdateMode="Conditional">
                                <ContentTemplate><div style="position: relative;">
                                    <asp:ImageButton ID="imgBtnEnd" runat="server" ImageUrl="~/Skins/Admin/Images/icon_calendar.gif"
                                        Width="16" Height="16" CssClass="calendarbutton" /><asp:TextBox ID="txtEndDate" runat="server"
                                            MaxLength="20" CssClass="midtext" />
                                    <ajaxToolkit:CalendarExtender ID="calenderExtEndDate" runat="server" TargetControlID="txtEndDate"
                                        PopupButtonID="imgBtnEnd" Format="yyyy/MM/dd" CssClass="calendar" />
                                    <asp:RequiredFieldValidator ID="valRequiredEndDate" runat="server" CssClass="error"
                                        ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                        ControlToValidate="txtEndDate" SetFocusOnError="true" />
                                    <ajaxToolkit:FilteredTextBoxExtender ID="filEndDate" runat="server" TargetControlID="txtEndDate"
                                        FilterType="Numbers, Custom" ValidChars="/" />
                                    <asp:CompareValidator ID="valCompareCheckPeriod" runat="server" ErrorMessage='<%$ Resources: _Promotions, ContentText_EndBeforeStartDate %>'
                                        CssClass="error" ForeColor="" ControlToValidate="txtEndDate" ControlToCompare="txtStartDate"
                                        Operator="GreaterThanEqual" Type="Date" SetFocusOnError="true" CultureInvariantValues="true"
                                        Display="Dynamic" /></div>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </span></li>
                    <!-- Max Qty -->
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litFormLabelPromotionMaxQty" runat="server" Text='<%$ Resources:_Promotions, FormLabel_PromotionMaxQty %>' /></span>
                        <span class="Kartris-DetailsView-Value">
                            <asp:TextBox ID="txtMaxQuantity" runat="server" CssClass="shorttext" Text="0" MaxLength="3" />
                            <asp:RequiredFieldValidator ID="valRequiredMaxQuantity" runat="server" CssClass="error"
                                ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                ControlToValidate="txtMaxQuantity" SetFocusOnError="true" Display="Dynamic" />
                            <asp:CompareValidator ID="valCompareCheckMaxQuantity" runat="server" ControlToValidate="txtMaxQuantity"
                                Display="Dynamic" CssClass="error" ForeColor="" ErrorMessage="0-255!" Operator="LessThanEqual"
                                ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoByte %>" ValueToCompare="255"
                                Type="Integer" SetFocusOnError="true" />
                            <ajaxToolkit:FilteredTextBoxExtender ID="filMaxQuantity" runat="server" FilterType="Numbers"
                                TargetControlID="txtMaxQuantity" />
                        </span></li>
                    <!-- Sort Value -->
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Literal ID="litFormLabelSortValue" runat="server" Text='<%$ Resources:_Kartris, FormLabel_OrderByValue %>' /></span>
                        <span class="Kartris-DetailsView-Value">
                            <asp:TextBox ID="txtOrderNo" runat="server" CssClass="shorttext" Text="0" MaxLength="5" />
                            <asp:RequiredFieldValidator ID="valRequiredOrderNo" runat="server" CssClass="error"
                                ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                ControlToValidate="txtOrderNo" Display="Dynamic" SetFocusOnError="true" />
                            <asp:CompareValidator ID="valCompareCheckOrderBy" runat="server" ControlToValidate="txtOrderNo"
                                Display="Dynamic" CssClass="error" ForeColor="" ErrorMessage="0-32767!" Operator="LessThanEqual"
                                SetFocusOnError="true" ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoShort %>"
                                ValueToCompare="32767" Type="Integer" />
                            <ajaxToolkit:FilteredTextBoxExtender ID="filOrderNo" runat="server" FilterType="Numbers"
                                TargetControlID="txtOrderNo" />
                        </span></li>
                    <!-- Promotions Parts -->
                    <li>
                        <div id="promotion_part_A">
                            <asp:UpdatePanel ID="updPromotionA" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <_user:PromotionStringBuilder ID="_UC_PromotionStringBuilder_PartA" runat="server" />
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                        <div id="promotion_part_B">
                            <asp:UpdatePanel ID="updPromotionB" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <_user:PromotionStringBuilder ID="_UC_PromotionStringBuilder_PartB" runat="server" />
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                        <div class="spacer">
                        </div>
                    </li>
                </ul>
            </div>
        </div>
        <!-- Promotion Image -->
        <h2>
            <asp:Literal ID="litContentTextImages" runat="server" Text='<%$ Resources:_Kartris, ContentText_NormalImage %>' /></h2>
        <asp:Literal ID="litPromotionFileName" runat="server" Visible="false" />
        <asp:UpdatePanel ID="updUploadFile" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:Image ID="imgPromotionImage" runat="server" Height="100" Width="100" />
                <asp:LinkButton ID="lnkUploadFile" runat="server" CssClass="linkbutton icon_upload"
                    Text="<%$ Resources:_Kartris, ContentText_Upload %>" />
                <asp:LinkButton ID="lnkRemoveFile" runat="server" CssClass="linkbutton icon_delete"
                    Text="<%$ Resources:_Kartris, FormButton_Remove %>" />
                <asp:Literal ID="litOriginalFileName" runat="server" Visible="false" />
                <asp:Literal ID="litTempFileName" runat="server" Visible="false" />
                <_user:UploaderPopup ID="_UC_FileUploaderPopup" runat="server" />
            </ContentTemplate>
        </asp:UpdatePanel>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
