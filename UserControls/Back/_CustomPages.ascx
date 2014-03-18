<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_CustomPages.ascx.vb"
    Inherits="UserControls_Back_CustomPages" %>
<%@ Register TagPrefix="_user" TagName="LanguageContainer" Src="~/UserControls/Back/_LanguageContainer.ascx" %>
<div style="display:none">
    <_user:LanguageContainer ID="ghost_UC_LangContainer" runat="server" />
</div>
<asp:UpdatePanel ID="updPagesList" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <%  'The javascript routine is to dynamically change the link URL of
            'the top left 'front' button %>
        <script type="text/javascript">
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);

            function EndRequestHandler(sender, args) {
                document.getElementById("_UC_AdminBar_lnkFront").href = document.getElementById("phdMain__UC_CustomPages_hidPageID").value;
            }
        </script>
        <asp:PlaceHolder ID="phdPagesList" runat="server">
            <div class="section">
                <asp:LinkButton ID="lnkAddPage" runat="server" Text="<%$ Resources: _Kartris, FormButton_New %>"
                    CssClass="linkbutton icon_new floatright" /><br />
                <asp:MultiView ID="mvwCustomPages" runat="server" ActiveViewIndex="0">
                    <asp:View ID="viwPagesData" runat="server">
                        <asp:GridView CssClass="kartristable" ID="gvwPages" runat="server" AllowPaging="true"
                            AllowSorting="false" AutoGenerateColumns="False" DataKeyNames="Page_ID" AutoGenerateEditButton="False"
                            GridLines="None" SelectedIndex="-1">
                            <Columns>
                                <asp:TemplateField ItemStyle-CssClass="column1">
                                    <ItemTemplate>
                                        <asp:Literal ID="litID" runat="server" Text='<%# Container.DataItemIndex + 1 %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField ItemStyle-CssClass="column2">
                                    <HeaderTemplate>
                                        <asp:Literal ID="litContentTextID" runat="server" Text="<%$ Resources:_Kartris, ContentText_ID %>" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Literal ID="litPageName" runat="server" Text='<%# Eval("Page_Name")%>' />
                                        <asp:Literal ID="litPageParentID" runat="server" Text='<%# Eval("Page_ParentID")%>'
                                            Visible="false" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField ItemStyle-CssClass="column3">
                                    <HeaderTemplate>
                                        <asp:Literal ID="litContentTextLive" runat="server" Text="<%$ Resources:_Kartris, ContentText_Live %>" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="chkLive" runat="server" CssClass="checkbox" Enabled="false" Checked='<%# Eval("Page_Live") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField ItemStyle-CssClass="column4">
                                    <HeaderTemplate>
                                        <asp:Literal ID="litContentTextNewsDateCreated" runat="server" Text="<%$ Resources:_Kartris, ContentText_DateCreated %>" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Literal ID="litDateCreated" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("Page_DateCreated"), "t", Session("_LANG")) %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField ItemStyle-CssClass="column5">
                                    <HeaderTemplate>
                                        <asp:Literal ID="litContentTextNewsLastUpdated" runat="server" Text="<%$ Resources:_Kartris, ContentText_LastUpdated %>" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Literal ID="litLastUpdated" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("Page_LastUpdated"), "t", Session("_LANG")) %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField ItemStyle-CssClass="selectfield">
                                    <HeaderTemplate>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkBtnEdit" runat="server" CommandName="EditPage" CommandArgument='<%# Container.DataItemIndex %>'
                                            Text='<%$ Resources: _Kartris, FormButton_Edit %>' CssClass="linkbutton icon_edit" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </asp:View>
                    <asp:View ID="viwNoPages" runat="server">
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
<asp:UpdateProgress ID="prgPagesList" runat="server" AssociatedUpdatePanelID="updPagesList">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
<asp:UpdatePanel ID="updPageDetails" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:PlaceHolder ID="phdPageDetails" runat="server">
            <asp:Literal ID="litPageID" runat="server" Visible="false" />
            <asp:HiddenField runat="server" ID="hidPageID"></asp:HiddenField>
            <asp:MultiView ID="mvwPage" runat="server">
                <asp:View ID="viwPageEmpty" runat="server">
                </asp:View>
                <asp:View ID="viwPageInfo" runat="server">
                    <script type="text/javascript">
                        onload = function () {
                            document.getElementById("_UC_AdminBar_lnkFront").href = document.getElementById("phdMain__UC_CustomPages_hidPageID").value;
                        }
                    </script>
                    <%-- Back Link --%>
                    <asp:PlaceHolder runat="server" ID="phdBackLink">
                        <asp:LinkButton ID="lnkBtnBack" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>'
                            CssClass="linkbutton icon_back floatright"></asp:LinkButton>
                    </asp:PlaceHolder>
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <%-- Live --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextLive" runat="server" Text="<%$ Resources:_Kartris, ContentText_Live %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:CheckBox ID="chkLive" runat="server" CssClass="checkbox" />
                                </span></li>
                                <%-- Page Name --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextID" runat="server" Text="<%$ Resources: _Kartris, ContentText_ID %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtPageName" runat="server" MaxLength="50" />
                                    <asp:RequiredFieldValidator ID="valRequiredPageName" runat="server" CssClass="error"
                                        ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                        ControlToValidate="txtPageName" />
                                    <asp:RegularExpressionValidator ID="valAlphaNumeric" runat="server" CssClass="error"
                                        ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
                                        ControlToValidate="txtPageName" ValidationExpression="^([0-9a-zA-Z]+((-)[0-9a-zA-Z]+)*)+$" /><br />
                                    <asp:Literal ID="litContentTextPageIDMustBeUnique" runat="server" Text="<%$ Resources: _Pages, ContentText_PageIDMustBeUnique %>" />
                                </span></li>
                                <%-- Parent Page --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litParentPage" runat="server" Text="<%$ Resources:_Pages, ContentText_ParentPage %>"></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:DropDownList ID="ddlParentPage" runat="server" AppendDataBoundItems="true">
                                    </asp:DropDownList>
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
                                <asp:LinkButton ID="lnkBtnSavePage" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                    ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' />
                                <asp:LinkButton ID="lnkBtnCancelPage" CausesValidation="false" runat="server" CssClass="button cancelbutton"
                                    Text='<%$ Resources: _Kartris, FormButton_Cancel %>' ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                                <asp:HyperLink ID="lnkPreview" runat="server" CssClass="button previewbutton"
                                    Text='<%$ Resources: _Kartris, FormButton_Preview %>' ToolTip='<%$ Resources: _Kartris, FormButton_Preview %>'
                                    Target="_blank" Visible="false" />
                                <span class="floatright">
                                    <asp:LinkButton ID="lnkBtnDeletePage" CssClass="button deletebutton"
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
<asp:UpdateProgress ID="prgPagesDetails" runat="server" AssociatedUpdatePanelID="updPageDetails">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
