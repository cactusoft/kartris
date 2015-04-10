<%@ Control Language="VB" AutoEventWireup="False" CodeFile="_LanguageStringsTranslation.ascx.vb"
    Inherits="UserControls_Back_LanguageStringsTranslation" %>

<script type="text/javascript">
    function onSave() {
        var postBack = new Sys.WebForms.PostBackAction();
        postBack.set_target('lnkSave');
        postBack.set_eventArgument('');
        postBack.performAction();
    }
</script>

<div class="section_languagestringstranslation">
    <asp:UpdatePanel ID="updSearch" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div class="searchboxrow">
                <asp:Panel ID="pnlTranslate" runat="server" DefaultButton="btnFind">
                    <asp:TextBox runat="server" ID="txtSearch" MaxLength="100" /><asp:Button ID="btnFind" runat="server" Text="<%$ Resources:_Kartris, FormButton_Search %>"
                        CssClass="button" />
                </asp:Panel>
            </div>
            <div class="searchboxrow">
                <asp:Label ID="lblContentTextField" CssClass="nolabelwidth" runat="server" AssociatedControlID="ddlSearchBy"
                    Text='<%$ Resources:_Kartris, ContentText_Field %>' />
                <asp:DropDownList CssClass="short" ID="ddlSearchBy" runat="server">
                    <asp:ListItem Text='<%$ Resources:_Kartris, ContentText_Name %>' Value="Name" />
                    <asp:ListItem Text='<%$ Resources:_Kartris, ContentText_Value %>' Value="Value" />
                    <asp:ListItem Text='<%$ Resources:_Kartris, ContentText_ClassName %>' Value="ClassName" />
                    <asp:ListItem Text='<%$ Resources:_Kartris, BackMenu_SearchAll %>' Value="" Selected="Selected" />
                </asp:DropDownList>
                <span class="checkbox nolabelwidth">
                    <asp:CheckBox ID="chkFront" runat="server" Text='<%$ Resources:_Kartris, ContentText_FrontEnd %>' />
                    <asp:CheckBox ID="chkBack" runat="server" Text='<%$ Resources:_Kartris, PageTitle_BackEnd %>' />
                </span>
            </div>
            <div class="searchboxrow">
                <asp:Label ID="lblFormLabelLanguage" CssClass="nolabelwidth" runat="server" AssociatedControlID="ddlFromLanguage"
                    Text='<%$ Resources:_Kartris, FormLabel_Language %>' />
                <asp:DropDownList CssClass="short" ID="ddlFromLanguage" runat="server" AppendDataBoundItems="true"
                    AutoPostBack="true" DataTextField="LANG_BackName" DataValueField="LANG_ID">
                </asp:DropDownList>
                &nbsp;&#187;&nbsp;
                <asp:DropDownList CssClass="short" ID="ddlToLanguage" runat="server" AppendDataBoundItems="true">
                </asp:DropDownList>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    <asp:UpdateProgress ID="upgSearch" runat="server" AssociatedUpdatePanelID="updSearch">
        <ProgressTemplate>
            <div class="loadingimage">
            </div>
            <div class="updateprogress">
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>
    <asp:Literal ID="litLanguageID" runat="server" Visible="false" />
    <asp:UpdatePanel ID="updTranslation" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:GridView CssClass="kartristable" ID="gvwTranslation" runat="server" AllowPaging="True"
                AutoGenerateColumns="False" DataKeyNames="LS_LANGID,LS_FrontBack,LS_Name" GridLines="None"
                AutoGenerateEditButton="False" PageSize="20" Visible="false">
                <Columns>
                    <asp:TemplateField ItemStyle-CssClass="hidecolumn" HeaderStyle-CssClass="hidecolumn">
                        <ItemTemplate>
                            <asp:Literal ID="litLanguageID" runat="server" Text='<%# Eval("LS_LangID") %>' Visible="false" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="LS_FrontBack" HeaderText='' ItemStyle-CssClass="column1">
                        <HeaderStyle />
                    </asp:BoundField>
                    <asp:BoundField ItemStyle-CssClass="itemname column2" DataField="LS_Name" HeaderText='<%$ Resources:_Kartris, ContentText_Name %>'
                        HeaderStyle-CssClass="column2">
                        <HeaderStyle />
                    </asp:BoundField>
                    <asp:TemplateField>
                        <HeaderTemplate>
                            <asp:Literal ID="litContentTextFrom" runat="server" Text='<%# GetLanguage("From") %>'></asp:Literal>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:Literal ID="litFromValue" runat="server" Text='<%# Eval("LS_Value") %>'></asp:Literal>
                            <asp:Literal ID="litFromDesc" runat="server" Text='<%# Eval("LS_Description") %>'
                                Visible="false"></asp:Literal>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField>
                        <HeaderTemplate>
                            <asp:Literal ID="litContentTextTo" runat="server" Text='<%# GetLanguage("To") %>'></asp:Literal>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:Literal ID="litToValue" runat="server" Text='<%# Eval("Value") %>'></asp:Literal>
                            <asp:Literal ID="litToDesc" runat="server" Text='<%# Eval("Desc") %>' Visible="false"></asp:Literal>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-CssClass="selectfield">
                        <ItemTemplate>
                            <asp:LinkButton ID="selectbutton" runat="server" CommandName="select" CssClass="linkbutton icon_edit"
                                Text='<%$ Resources:_Kartris, FormButton_Edit %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </ContentTemplate>
    </asp:UpdatePanel>
    <asp:UpdateProgress ID="upgTranslation" runat="server" AssociatedUpdatePanelID="updTranslation">
        <ProgressTemplate>
            <div class="loadingimage">
            </div>
            <div class="updateprogress">
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>
    <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    <asp:UpdatePanel ID="updEditBox" runat="server">
        <ContentTemplate>
            <asp:Panel ID="pnlEditBox" runat="server" Style="display: none" CssClass="popup">
                <h2>
                    <asp:Literal ID="litTitle" runat="server" Text="<%$ Resources: _Kartris, BackMenu_StringsTranslation %>" /></h2>
                <asp:LinkButton ID="lnkExtCancel" runat="server" Text="" CssClass="closebutton linkbutton2" />
                <asp:LinkButton ID="lnkBtnDummy" runat="server"></asp:LinkButton>
                <asp:PlaceHolder ID="phdEditContents" runat="server">
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFrontBack" runat="server" Text="<%$ Resources:_Kartris, ContentText_FrontOrBack %>" /></span><span
                                        class="Kartris-DetailsView-Value"><asp:Literal ID="litLS_FrontBack" runat="server" /></span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextName" runat="server" Text="<%$ Resources:_Kartris, ContentText_Name %>" /></span><span
                                        class="Kartris-DetailsView-Value"><asp:Literal ID="litLS_Name" runat="server" /></span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextValue" runat="server" Text="<%$ Resources:_Kartris, ContentText_Value %>" />
                                    (<asp:Literal ID="litFromLanguageName2" runat="server" />)</span><span class="Kartris-DetailsView-Value"><asp:Literal
                                        ID="litLS_Value" runat="server" />
                                    </span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextValue2" runat="server" Text="<%$ Resources:_Kartris, ContentText_Value %>" />
                                    (<asp:Literal ID="litToLanguageName2" runat="server" />)</span><span class="Kartris-DetailsView-Value"><asp:TextBox
                                        ID="txtValue" runat="server" TextMode="MultiLine" /></span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelDescription" runat="server" Text="<%$ Resources:_Kartris, FormLabel_Description %>" />
                                    (<asp:Literal ID="litFromLanguageName3" runat="server" />)</span><span class="Kartris-DetailsView-Value"><asp:Literal
                                        ID="litLS_Description" runat="server" />
                                    </span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelDescription2" runat="server" Text="<%$ Resources:_Kartris, FormLabel_Description %>" />
                                    (<asp:Literal ID="litToLanguageName3" runat="server" />)</span><span class="Kartris-DetailsView-Value"><asp:TextBox
                                        ID="txtDesc" runat="server" TextMode="MultiLine" /></span></li>
                            </ul>
                        </div>
                        <div class="submitbuttons">
                            <asp:LinkButton ID="lnkExtOk" runat="server" Text="" CssClass="invisible" />
                            <asp:Button ID="lnkSave" OnClick="lnkSave_Click" runat="server" Text="<%$ Resources: _Kartris, FormButton_Save %>"
                                CssClass="button" />
                        </div>
                    </div>
                </asp:PlaceHolder>
            </asp:Panel>
            <ajaxToolkit:ModalPopupExtender ID="popExtender" runat="server" TargetControlID="lnkBtnDummy"
                PopupControlID="pnlEditBox" OnOkScript="onSave()" BackgroundCssClass="popup_background"
                OkControlID="lnkExtOk" CancelControlID="lnkExtCancel" DropShadow="False" RepositionMode="None">
            </ajaxToolkit:ModalPopupExtender>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
