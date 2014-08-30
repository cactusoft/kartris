<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_AdminLog.ascx.vb" Inherits="UserControls_Back_AdminLog" %>
<div id="section_adminlog">
    <asp:UpdatePanel ID="updAdminLog" runat="server">
        <ContentTemplate>
            <asp:Panel ID="pnlFind" runat="server" DefaultButton="btnSearchAdminLog">
                <div id="searchboxrow">
                    <asp:TextBox runat="server" ID="txtAdminLogSearchText" MaxLength="100" />
                    <asp:DropDownList CssClass="short" ID="ddlAdminLogSearchBy" runat="server">
                        <asp:ListItem Text="All" Value="" />
                        <asp:ListItem Text="Config" Value="Config" />
                        <asp:ListItem Text="Currency" Value="Currency" />
                        <asp:ListItem Text="Languages" Value="Languages" />
                        <asp:ListItem Text="Site Text" Value="SiteText" />
                        <asp:ListItem Text="Logins" Value="Logins" />
                        <asp:ListItem Text="Data Records" Value="DataRecords" />
                        <asp:ListItem Text="Query Execution" Value="ExecuteQuery" />
                    </asp:DropDownList>
                    <asp:Button ID="btnSearchAdminLog" runat="server" Text="<%$ Resources:_Kartris, FormButton_Search %>"
                        CssClass="button" ValidationGroup="AdminLog" />
                </div>
                <br />
                <asp:Label ID="litFormLabelStartDate" runat="server" Text='<%$ Resources: _Kartris, FormLabel_StartDate %>'
                    AssociatedControlID="txtStartDate" />
                <asp:ImageButton ID="imgBtnStart" runat="server" ImageUrl="~/Skins/Admin/Images/icon_calendar.gif"
                    Width="16" Height="16" CssClass="calendarbutton" /><asp:TextBox ID="txtStartDate"
                        runat="server" MaxLength="20" CssClass="midtext" />
                <asp:RequiredFieldValidator ID="valRequiredStartDate" runat="server" CssClass="error"
                    ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                    ControlToValidate="txtStartDate" ValidationGroup="AdminLog" />
                <ajaxToolkit:CalendarExtender ID="calExtStartDate" runat="server" TargetControlID="txtStartDate"
                    PopupButtonID="imgBtnStart" Format="yyyy/MM/dd" CssClass="calendar" />
                <ajaxToolkit:FilteredTextBoxExtender ID="filStartDate" runat="server" TargetControlID="txtStartDate"
                    FilterType="Numbers, Custom" ValidChars="/" />
                <asp:Label ID="litFormLabelEndDate" runat="server" Text='<%$ Resources: _Kartris, FormLabel_EndDate %>'
                    AssociatedControlID="txtEndDate" />
                <asp:ImageButton ID="imgBtnEnd" runat="server" ImageUrl="~/Skins/Admin/Images/icon_calendar.gif"
                    Width="16" Height="16" CssClass="calendarbutton" /><asp:TextBox ID="txtEndDate" runat="server"
                        MaxLength="20" CssClass="midtext" />
                <asp:RequiredFieldValidator ID="valRequiredEndDate" runat="server" CssClass="error"
                    ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                    ControlToValidate="txtEndDate" ValidationGroup="AdminLog" Display="Dynamic" />
                <ajaxToolkit:CalendarExtender ID="calExtEndDate" runat="server" TargetControlID="txtEndDate"
                    PopupButtonID="imgBtnEnd" Format="yyyy/MM/dd" CssClass="calendar" />
                <ajaxToolkit:FilteredTextBoxExtender ID="filEndDate" runat="server" TargetControlID="txtEndDate"
                    FilterType="Numbers, Custom" ValidChars="/" />
                <asp:CompareValidator ID="valCompareCheckPeriod" runat="server" ErrorMessage='<%$ Resources: _Promotions, ContentText_EndBeforeStartDate %>'
                    ControlToValidate="txtEndDate" ControlToCompare="txtStartDate" Operator="GreaterThanEqual"
                    Type="Date" SetFocusOnError="true" CultureInvariantValues="true" Display="Dynamic"
                    ValidationGroup="validGrpNewCoupon" CssClass="error"
                    ForeColor="" />
                <div class="spacer">
                    &nbsp;</div>
            </asp:Panel>
            <div>
                <asp:MultiView ID="mvwAdminLog" runat="server">
                    <asp:View ID="viwAdminLogEmpty" runat="server">
                        <asp:Panel ID="pnlNoAdminLogs" runat="server" CssClass="noresults">
                            <asp:Literal ID="litNoAdminLogs" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" /></asp:Panel>
                    </asp:View>
                    <asp:View ID="viwAdminLogList" runat="server">
                        <asp:UpdatePanel ID="updAdminLogList" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:GridView CssClass="kartristable" ID="gvwAdminLog" runat="server" AllowPaging="True"
                                    AllowSorting="true" AutoGenerateColumns="False" DataKeyNames="AL_ID" AutoGenerateEditButton="False"
                                    GridLines="None" PagerSettings-PageButtonCount="10" PageSize="10" SelectedIndex="0">
                                    <Columns>
                                        <asp:TemplateField ItemStyle-CssClass="datefield">
                                            <HeaderTemplate>
                                                <asp:Literal ID="litContentTextDateTime" runat="server" Text='<%$ Resources: _Kartris, ContentText_DateTime %>'
                                                    EnableViewState="False" />
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <asp:Literal ID="AL_DateStamp" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("AL_DateStamp"), "t", Session("_LANG")) %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField ItemStyle-CssClass="column2">
                                            <HeaderTemplate>
                                                <asp:Literal ID="litContentTextType" runat="server" Text="<%$ Resources: _Kartris, ContentText_Type %>"
                                                    EnableViewState="False" />
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <asp:Literal ID="AL_Type" runat="server" Text='<%# Eval("AL_Type") %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField ItemStyle-CssClass="column3">
                                            <HeaderTemplate>
                                                <asp:Literal ID="litContentTextLogQuery" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_LogQuery %>"
                                                    EnableViewState="False" />
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <asp:Literal ID="ShortQuery" runat="server" Text='<%# Eval("ShortQuery") %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField HeaderText="User" DataField="AL_LoginName" />
                                        <asp:TemplateField ItemStyle-CssClass="selectfield">
                                            <HeaderTemplate>
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <asp:LinkButton ID="lnkBtnDetails" runat="server" CommandName="cmdDetails" CommandArgument='<%# Eval("AL_ID") %>'
                                                    CssClass="linkbutton icon_edit" Text='<%$ Resources: _Kartris, ContentText_Details %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </asp:View>
                    <asp:View ID="viwAdminLogDetails" runat="server">
                        <div class="line">
                        </div>
                        <asp:LinkButton ID="lnkBtnBack" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>'
                            CssClass="linkbutton icon_back floatright" />
                        <asp:Literal ID="litLogID" runat="server" Visible="false" />
                        <div class="Kartris-DetailsView">
                            <div class="Kartris-DetailsView-Data">
                                <ul>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litContentTextDateTime" runat="server" Text='<%$ Resources: _Kartris, ContentText_DateTime %>'
                                            EnableViewState="False" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litLogDateTime" runat="server" />
                                    </span></li>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litFormLabelUsername" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Username %>"
                                            EnableViewState="False" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litLogUser" runat="server" />
                                    </span></li>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litContentTextType" runat="server" Text="<%$ Resources: _Kartris, ContentText_Type %>"
                                            EnableViewState="False" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litLogType" runat="server" />
                                    </span></li>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litContentTextLogQuery" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_LogQuery %>"
                                            EnableViewState="False" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litLogQuery" runat="server" />
                                    </span></li>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litContentTextDescription" runat="server" Text="<%$ Resources: _Kartris, ContentText_Description %>"
                                            EnableViewState="False" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litLogDescription" runat="server" />
                                    </span></li>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litContentTextLogRelatedRecord" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_LogRelatedRecord %>"
                                            EnableViewState="False" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litLogRelatedID" runat="server" />
                                    </span></li>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litContentTextIP" runat="server" Text="<%$ Resources: _Kartris, ContentText_IP %>"
                                            EnableViewState="False" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litLogIP" runat="server" />
                                    </span></li>
                                </ul>
                            </div>
                        </div>
                    </asp:View>
                </asp:MultiView>
            </div>
            <br /><br /><br />
            <h2>
                <asp:Literal ID="litPageTitlePurgeOldAdminLogs" runat="server" Text="<%$ Resources: _DBAdmin, PageTitle_PurgeOldAdminLogs %>" /></h2>
            <p>
                <asp:Literal ID="litContentTextAdminLogsPurge1" runat="server" Text="<%$ Resources:_DBAdmin, ContentText_AdminLogsPurge1 %>" /></p>
                <br /><br />
                <p><asp:Button ID="btnPurgeOldLogs" runat="server" Text='<%$ Resources:_DBAdmin, ContentText_PurgeAdminLogs %>'
                    CssClass="button" /></p>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
<_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
<asp:UpdateProgress ID="prgAdminLog" runat="server" AssociatedUpdatePanelID="updAdminLog">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
