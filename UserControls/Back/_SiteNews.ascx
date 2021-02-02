<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_SiteNews.ascx.vb" Inherits="UserControls_Back_SiteNews" %>
<%@ Register TagPrefix="_user" TagName="LanguageContainer" Src="~/UserControls/Back/_LanguageContainer.ascx" %>
<asp:UpdatePanel ID="updNewsList" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <%  'The javascript routine is to dynamically change the link URL of
'the top left 'front' button %>
        <script type="text/javascript">
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);

            function EndRequestHandler(sender, args) {
                document.getElementById("_UC_AdminBar_lnkFront").href = document.getElementById("phdMain__UC_SiteNews_hidNewsID").value;

            }
        </script>
        <asp:Literal ID="litNewsID" runat="server" Visible="False" />
        <asp:HiddenField runat="server" ID="hidNewsID" Value=""></asp:HiddenField>
        <asp:MultiView ID="mvwNewsList" runat="server" ActiveViewIndex="0">
            <asp:View ID="viwList" runat="server">
                <div class="section">
                    <asp:HyperLink ID="lnkNew" runat="server" Text="<%$ Resources: _Kartris, FormButton_New %>"
                        CssClass="linkbutton icon_new floatright" NavigateUrl="~/Admin/_SiteNews.aspx?NewsID=0" />
                    <br />
                    <asp:MultiView ID="mvwSiteNews" runat="server">
                        <asp:View ID="viwNewsData" runat="server">
                            <asp:GridView CssClass="kartristable" ID="gvwNews" runat="server" AllowPaging="true"
                                AllowSorting="false" AutoGenerateColumns="False" DataKeyNames="N_ID" AutoGenerateEditButton="False"
                                GridLines="None" SelectedIndex="0" PageSize="50">
                                <Columns>
                                    <asp:TemplateField>
                                        <ItemStyle CssClass="column1" />
                                        <ItemTemplate>
                                            <asp:Literal ID="litNumber" runat="server" Text='<%# Container.DataItemIndex + 1 %>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="N_Name" HeaderText="<%$ Resources:_News, ContentText_NewsHeadLine %>"
                                        ItemStyle-CssClass="column2" />
                                    <asp:TemplateField>
                                        <ItemStyle CssClass="column3" />
                                        <HeaderTemplate>
                                            <asp:Literal ID="litContentTextNewsDateCreated" runat="server" Text="<%$ Resources:_Kartris, ContentText_DateCreated %>" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:Literal ID="N_DateCreated" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("N_DateCreated"), "t", Session("_LANG")) %>' />
                                            <asp:HiddenField ID="hidDateCreated" runat="server" Value='<%# Eval("N_DateCreated") %>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField>
                                        <ItemStyle CssClass="column4" />
                                        <HeaderTemplate>
                                            <asp:Literal ID="litContentTextNewsLastUpdated" runat="server" Text="<%$ Resources:_Kartris, ContentText_LastUpdated %>" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:Literal ID="N_LastUpdated" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("N_LastUpdated"), "t", Session("_LANG")) %>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField ItemStyle-CssClass="selectfield">
                                        <HeaderTemplate>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:HyperLink ID="lnkEdit" runat="server"
                                                Text='<%$ Resources: _Kartris, FormButton_Edit %>' CssClass="linkbutton icon_edit" NavigateUrl='<%# FormatEditLink(Eval("N_ID")) %>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </asp:View>
                        <asp:View ID="viwNoNews" runat="server">
                            <asp:Panel ID="pnlNoItems" runat="server" CssClass="noresults">
                                <asp:Literal ID="litNoItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>">
                                </asp:Literal>
                            </asp:Panel>
                        </asp:View>
                    </asp:MultiView>
                </div>
            </asp:View>
            <asp:View ID="viwNewsInfo" runat="server">
                <script type="text/javascript">
                    onload = function () {
                        document.getElementById("_UC_AdminBar_lnkFront").href = document.getElementById("phdMain__UC_SiteNews_hidNewsID").value;
                    }
                </script>
                <div>
                    <%-- Back Link --%>
                    <asp:PlaceHolder runat="server" ID="phdBackLink">

                        <asp:HyperLink ID="lnkBack" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>'
                            CssClass="linkbutton icon_back floatright" NavigateUrl="~/Admin/_SiteNews.aspx"></asp:HyperLink>

                    </asp:PlaceHolder>
                    <asp:UpdatePanel ID="updLanguageContainer" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:PlaceHolder ID="phdLanguageContainer" runat="server">
                                <_user:LanguageContainer ID="_UC_LangContainer" runat="server" />
                            </asp:PlaceHolder>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    <asp:UpdatePanel ID="updCreationDate" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <div class="line">
                            </div>
                            <div class="Kartris-DetailsView">
                                <div class="Kartris-DetailsView-Data">
                                    <ul>
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
                                            <ajaxToolkit:CalendarExtender Animated="true" ID="calDate" runat="server" TargetControlID="txtCreationDate"
                                                PopupButtonID="btnCalendar" Format="yyyy/MM/dd" PopupPosition="BottomLeft" CssClass="calendar" /></div>
                                        </span></li>
                                    </ul>
                                </div>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
                <%-- Save Button  --%>
                <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                    <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:LinkButton ID="lnkBtnSaveNews" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' />
                            <asp:LinkButton ID="lnkBtnCancelNews" runat="server" CssClass="button cancelbutton"
                                Text='<%$ Resources: _Kartris, FormButton_Cancel %>' ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                            <asp:HyperLink ID="lnkPreview" runat="server" CssClass="button previewbutton"
                                Text='<%$ Resources: _Kartris, FormButton_Preview %>' ToolTip='<%$ Resources: _Kartris, FormButton_Preview %>'
                                Target="_blank" Visible="false" /><span class="floatright">
                                    <asp:LinkButton ID="lnkBtnDeleteNews" CssClass="button deletebutton"
                                        runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>' ToolTip='<%$ Resources: _Kartris, FormButton_Delete %>' /></span>
                            <asp:ValidationSummary ID="valSummary" runat="server" CssClass="valsummary" DisplayMode="BulletList"
                                ForeColor="" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </asp:View>
        </asp:MultiView>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgNewsList" runat="server" AssociatedUpdatePanelID="updNewsList">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
