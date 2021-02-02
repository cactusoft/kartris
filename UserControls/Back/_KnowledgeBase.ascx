<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_KnowledgeBase.ascx.vb"
    Inherits="UserControls_Back_KnowledgeBase" %>
<%@ Register TagPrefix="_user" TagName="LanguageContainer" Src="~/UserControls/Back/_LanguageContainer.ascx" %>
<asp:UpdatePanel ID="updKBList" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <%  'The javascript routine is to dynamically change the link URL of
            'the top left 'front' button %>
        <script type="text/javascript">
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);

            function EndRequestHandler(sender, args) {
                document.getElementById("_UC_AdminBar_lnkFront").href = document.getElementById("phdMain__UC_KB_hidKBID").value;
            }
        </script>
        <asp:PlaceHolder ID="phdKBList" runat="server">
            <div class="section">
                <asp:LinkButton ID="lnkAddKB" runat="server" Text="<%$ Resources: _Kartris, FormButton_New %>"
                    CssClass="linkbutton icon_new floatright" /><br />
                <div class="searchboxrow">
                    <asp:Panel ID="pnlFind" runat="server" DefaultButton="btnFind">
                        <asp:TextBox runat="server" ID="txtSearchKBID" MaxLength="6" CssClass="midtext" />
                        <asp:Button ID="btnFind" runat="server" Text="<%$ Resources:_Kartris, FormButton_Search %>"
                            CssClass="button" />
                        <asp:Button ID="btnClear" runat="server" CssClass="button cancelbutton" Text='<%$ Resources:_Kartris, ContentText_Clear %>' />
                        <div class="spacer">
                            &nbsp;</div>
                        <p>
                            <asp:Literal ID="litEnterDate" runat="server" Text="<%$Resources:_Kartris, ContentText_EnterAnID %>"></asp:Literal></p>
                        <ajaxToolkit:FilteredTextBoxExtender ID="filSearch" runat="server" TargetControlID="txtSearchKBID"
                            FilterType="Numbers" />
                    </asp:Panel>
                    <br />
                </div>
                <asp:MultiView ID="mvwKBs" runat="server" ActiveViewIndex="0">
                    <asp:View ID="viwKBList" runat="server">
                        <asp:GridView CssClass="kartristable" ID="gvwKB" runat="server" AllowPaging="true"
                            AllowSorting="false" AutoGenerateColumns="False" DataKeyNames="KB_ID" AutoGenerateEditButton="False"
                            GridLines="None" SelectedIndex="-1" PageSize="15">
                            <Columns>
                                <asp:BoundField DataField="KB_ID" HeaderText="#" ItemStyle-CssClass="idfield" />
                                <asp:BoundField DataField="KB_Name" HeaderText="<%$ Resources:_Kartris, FormLabel_Name %>"
                                    ItemStyle-CssClass="column2" />
                                <asp:TemplateField ItemStyle-CssClass="column3">
                                    <HeaderTemplate>
                                        <asp:Literal ID="litContentTextLive" runat="server" Text="<%$ Resources:_Kartris, ContentText_Live %>" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="chkLive" runat="server" CssClass="checkbox" Enabled="false" Checked='<%# Eval("KB_Live") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField ItemStyle-CssClass="column4">
                                    <HeaderTemplate>
                                        <asp:Literal ID="litContentTextKBDateCreated" runat="server" Text="<%$ Resources:_Kartris, ContentText_DateCreated %>" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Literal ID="litDateCreated" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("KB_DateCreated"), "d", Session("_LANG")) %>' />
                                        <asp:Literal ID="litDateCreatedNumeric" runat="server" Text='<%# CkartrisDisplayFunctions.FormatBackwardsDate(Eval("KB_DateCreated")) %>'
                                            Visible="False" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField ItemStyle-CssClass="column5">
                                    <HeaderTemplate>
                                        <asp:Literal ID="litContentTextKBLastUpdated" runat="server" Text="<%$ Resources:_Kartris, ContentText_LastUpdated %>" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Literal ID="litLastUpdated" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("KB_LastUpdated"), "d", Session("_LANG")) %>' />
                                        <asp:Literal ID="litLastUpdatedNumeric" runat="server" Text='<%# CkartrisDisplayFunctions.FormatBackwardsDate(Eval("KB_LastUpdated")) %>'
                                            Visible="False" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField ItemStyle-CssClass="selectfield">
                                    <HeaderTemplate>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkBtnEdit" runat="server" CommandName="EditKB" CommandArgument='<%# Container.DataItemIndex %>'
                                            Text='<%$ Resources: _Kartris, FormButton_Edit %>' CssClass="linkbutton icon_edit" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </asp:View>
                    <asp:View ID="viwNoKB" runat="server">
                        <asp:Panel ID="pnlNoItems" runat="server" CssClass="noresults">
                            <asp:Literal ID="litNoItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>">
                            </asp:Literal>
                        </asp:Panel>
                    </asp:View>
                </asp:MultiView>
            </div>
        </asp:PlaceHolder>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgKBList" runat="server" AssociatedUpdatePanelID="updKBList">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
<asp:UpdatePanel ID="updKBDetails" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:PlaceHolder ID="phdKBDetails" runat="server">
            <asp:Literal ID="litKBID" runat="server" Visible="false" />
            <asp:HiddenField runat="server" ID="hidKBID" Value=""></asp:HiddenField>
            <asp:MultiView ID="mvwKB" runat="server">
                <asp:View ID="viwKBEmpty" runat="server">
                </asp:View>
                <asp:View ID="viwKBInfo" runat="server">
                    <script type="text/javascript">
                        onload = function () {
                            document.getElementById("_UC_AdminBar_lnkFront").href = document.getElementById("phdMain__UC_KB_hidKBID").value;
                        }
                    </script>
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <%-- Live --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextLive" runat="server" Text="<%$ Resources:_Kartris, ContentText_Live %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:CheckBox ID="chkLive" runat="server" CssClass="checkbox" />
                                </span></li>
                                <%-- Creation Date --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litCreationDate" runat="server" Text="<%$ Resources: _Kartris , ContentText_DateCreated %>"></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value"><div style="position: relative;">
                                    <asp:ImageButton ID="btnCalendar" runat="server" AlternateText="" ImageUrl="~/Skins/Admin/Images/icon_calendar.gif"
                                        Width="16" Height="16" CssClass="calendarbutton" />
                                    <asp:TextBox ID="txtCreationDate" runat="server" CssClass="midtext" MaxLength="11" />
                                    <asp:RequiredFieldValidator ID="valCreationDate" runat="server" ControlToValidate="txtCreationDate"
                                        CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                        Display="Dynamic" SetFocusOnError="true" />
                                    <ajaxToolkit:CalendarExtender ID="calCreationDate" runat="server" TargetControlID="txtCreationDate"
                                        Animated="true" PopupButtonID="btnCalendar" Format="yyyy/MM/dd" PopupPosition="BottomLeft"
                                        CssClass="calendar" /></div>
                                </span></li>
                                <%-- Update Date --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litUpdateDate" runat="server" Text="<%$ Resources: _Kartris , ContentText_LastUpdated %>"></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value"><div style="position: relative;">
                                    <asp:ImageButton ID="btnCalendar2" runat="server" AlternateText="" ImageUrl="~/Skins/Admin/Images/icon_calendar.gif"
                                        Width="16" Height="16" CssClass="calendarbutton" />
                                    <asp:TextBox ID="txtUpdateDate" runat="server" CssClass="midtext" MaxLength="11" />
                                    <asp:RequiredFieldValidator ID="valUpdateDate" runat="server" ControlToValidate="txtUpdateDate"
                                        CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                        Display="Dynamic" SetFocusOnError="true" />
                                    <ajaxToolkit:CalendarExtender ID="calUpdateDate" runat="server" TargetControlID="txtUpdateDate"
                                        Animated="true" PopupButtonID="btnCalendar2" Format="yyyy/MM/dd" PopupPosition="BottomLeft"
                                        CssClass="calendar" /></div>
                                </span></li>
                            </ul>
                        </div>
                    </div>
                    <%-- Language Elements --%>
                    <div>
                        <asp:UpdatePanel ID="updLanguageContainer" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:PlaceHolder ID="phdLanguageContainer" runat="server">
                                    <_user:LanguageContainer ID="_UC_LangContainer" runat="server" />
                                </asp:PlaceHolder>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                    <%-- Save Button  --%>
                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                        <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:LinkButton ID="lnkBtnSaveKB" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                    ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' />
                                <asp:LinkButton ID="lnkBtnCancelKB" CausesValidation="false" runat="server" CssClass="button cancelbutton"
                                    Text='<%$ Resources: _Kartris, FormButton_Cancel %>' ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                                <asp:HyperLink ID="lnkPreview" runat="server" CssClass="button previewbutton"
                                    Text='<%$ Resources: _Kartris, FormButton_Preview %>' ToolTip='<%$ Resources: _Kartris, FormButton_Preview %>'
                                    Target="_blank" Visible="false" /><span class="floatright">
                                        <asp:LinkButton ID="lnkBtnDeleteKB" CssClass="button deletebutton"
                                            runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>' ToolTip='<%$ Resources: _Kartris, FormButton_Delete %>' /></span>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                        <asp:ValidationSummary CausesValidation="True" ID="valSummary" runat="server" ForeColor=""
                            CssClass="valsummary" DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                    </div>
                </asp:View>
            </asp:MultiView>
        </asp:PlaceHolder>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgKBDetails" runat="server" AssociatedUpdatePanelID="updKBDetails">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
