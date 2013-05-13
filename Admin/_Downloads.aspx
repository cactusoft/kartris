<%@ Page Title="" Language="VB" MasterPageFile="~/Skins/Admin/Template.master" AutoEventWireup="false"
    CodeFile="_Downloads.aspx.vb" Inherits="Admin_Downloads" %>

<%@ Register TagPrefix="_user" TagName="UploaderPopup" Src="~/UserControls/Back/_UploaderPopup.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_versiondownloads">
        <h1>
            <asp:Literal ID="litPageTitleVersionDownloads" runat="server" Text="<%$ Resources: _Versions, PageTitle_VersionDownloads %>" /></h1>
        <div>
            <asp:Literal ID="litContentTextVersionDownloadsPageText" runat="server" Text="<%$ Resources: _Versions, ContentText_VersionDownloadsPageText %>" />
            <br />
            <br />
        </div>
        <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <ajaxToolkit:TabContainer ID="tabContainerMain" runat="server" EnableTheming="False"
                    CssClass=".tab" AutoPostBack="false">
                    <%-- Category Main Info. Tab --%>
                    <ajaxToolkit:TabPanel ID="tabDownloads" runat="server">
                        <HeaderTemplate>
                            <asp:Literal ID="litContentTextDownloads" runat="server" Text="<%$ Resources: _Versions, ContentText_Downloads %>" /></HeaderTemplate>
                        <ContentTemplate>
                            <asp:MultiView ID="mvwDownloads" runat="server" ActiveViewIndex="0">
                                <asp:View ID="viwDownloadData" runat="server">
                                    <asp:GridView ID="gvwDownloads" CssClass="kartristable" runat="server" AllowSorting="true"
                                        AutoGenerateColumns="False" AutoGenerateEditButton="False" GridLines="None" SelectedIndex="0"
                                        DataKeyNames="V_ID" AllowPaging="true" PageSize="15">
                                        <Columns>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                </HeaderTemplate>
                                                <ItemStyle CssClass="recordnumberfield" />
                                                <ItemTemplate>
                                                    <asp:Literal ID="litDataItem" runat="server" Text='<%# Container.DataItemIndex + 1 %>' />
                                                    <asp:Literal ID="litVersionID" runat="server" Text='<%# Eval("V_ID") %>' Visible="false" />
                                                    <asp:Literal ID="litCodeNumber" runat="server" Text='<%# Eval("V_CodeNumber") %>'
                                                        Visible="false" />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litFormLabelVersionName" runat="server" Text="<%$ Resources: _Product, FormLabel_VersionName %>" />
                                                </HeaderTemplate>
                                                <ItemStyle CssClass="itemname" />
                                                <ItemTemplate>
                                                    <asp:HyperLink ID="lnkModifyProduct" runat="server" NavigateUrl='<%# "~/Admin/_ModifyProduct.aspx?ProductID=" & Eval("V_ProductID") %>'>
                                                        <asp:Literal ID="litVersionName" runat="server" Text='<%# Eval("V_Name") %>' /></asp:HyperLink>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litContentTextFileName" runat="server" Text="<%$ Resources: _Kartris, ContentText_Filename %>" />
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <asp:UpdatePanel ID="updFileName" runat="server" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:Literal ID="litFile" runat="server" Text='<%# Eval("V_DownLoadInfo") %>' Visible="false" />
                                                            <asp:LinkButton ID="lnkFile" runat="server" Text='<%# Eval("V_DownLoadInfo") %>'
                                                                CommandName="OpenFile" CommandArgument='<%# Eval("V_DownLoadInfo") %>' />
                                                        </ContentTemplate>
                                                        <Triggers>
                                                            <asp:PostBackTrigger ControlID="lnkFile" />
                                                        </Triggers>
                                                    </asp:UpdatePanel>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litContentTextFileSize" runat="server" Text="<%$ Resources: _Kartris, ContentText_FileSize %>" />
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <asp:Literal ID="litSize" runat="server" />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField ItemStyle-CssClass="selectfield">
                                                <ItemTemplate>
                                                    <asp:LinkButton visible="false" ID="lnkBtnRenameFile" runat="server" Text="<%$ Resources: _Kartris, ContentText_Rename %>"
                                                        CommandName="RenameFile" CommandArgument='<%# Container.DataItemIndex %>' CssClass="linkbutton icon_edit" />
                                                    <asp:LinkButton ID="lnkBtnChangeDownloadFile" runat="server" Text="<%$ Resources: _Kartris, FormButton_Change %>"
                                                        CommandName="ChangeFile" CommandArgument='<%# Container.DataItemIndex %>' CssClass="linkbutton icon_edit" />
                                                    <asp:LinkButton ID="lnkBtnUploadFile" runat="server" Text="<%$ Resources: _Kartris, ContentText_Upload %>"
                                                        CommandName="NewFile" CommandArgument='<%# Container.DataItemIndex %>' CssClass="linkbutton icon_edit"
                                                        Visible="false" />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </asp:View>
                                <asp:View ID="viwNoDownloads" runat="server">
                                    <asp:Panel ID="pnlNoItems" runat="server" CssClass="noresults">
                                        <asp:Literal ID="litNoDItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>">
                                        </asp:Literal>
                                    </asp:Panel>
                                </asp:View>
                            </asp:MultiView>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel ID="tabLinks" runat="server">
                        <HeaderTemplate>
                            <asp:Literal ID="litContentTextLinks" runat="server" Text="<%$ Resources: _Versions, ContentText_Links %>" /></HeaderTemplate>
                        <ContentTemplate>
                            <asp:MultiView ID="mvwLinks" runat="server" ActiveViewIndex="0">
                                <asp:View ID="viwLinksData" runat="server">
                                    <asp:GridView ID="gvwLinks" CssClass="kartristable" runat="server" AllowSorting="true"
                                        AutoGenerateColumns="False" AutoGenerateEditButton="False" GridLines="None" SelectedIndex="0"
                                        DataKeyNames="V_ID" AllowPaging="true" PageSize="15">
                                        <Columns>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                </HeaderTemplate>
                                                <ItemStyle CssClass="recordnumberfield" />
                                                <ItemTemplate>
                                                    <asp:Literal ID="litDataItem" runat="server" Text='<%# Container.DataItemIndex + 1 %>' />
                                                    <asp:Literal ID="litVersionID" runat="server" Text='<%# Eval("V_ID") %>' Visible="false" />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litFormLabelVersionName" runat="server" Text="<%$ Resources: _Product, FormLabel_VersionName %>" />
                                                </HeaderTemplate>
                                                <ItemStyle CssClass="itemname" />
                                                <ItemTemplate>
                                                    <asp:Literal ID="litProductID" runat="server" Text='<%# Eval("V_ProductID") %>'></asp:Literal>
                                                    <asp:HyperLink ID="hlinkVersion" runat="server" NavigateUrl='<%# "~/Admin/_ModifyProduct.aspx?ProductID=" & Eval("V_ProductID") %>'>
                                                        <asp:Literal ID="litVersionName" runat="server" Text='<%# Eval("V_Name") %>' /></asp:HyperLink>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litContentTextValue" runat="server" Text="<%$ Resources: _Kartris, ContentText_Value %>" />
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <asp:Literal ID="litLinkLocation" runat="server" Text='<%# Eval("V_DownLoadInfo") %>'
                                                        Visible="false" />
                                                    <asp:HyperLink ID="lnkLinkLocation" runat="server" NavigateUrl='<%# FormatFileURL(Eval("V_DownLoadInfo"))%>'
                                                        Text='<%# Eval("V_DownLoadInfo") %>' CssClass="normalweight" />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField ItemStyle-CssClass="selectfield">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="lnkBtnChangeLink" runat="server" CommandName="ChangeLink" CommandArgument='<%# Container.DataItemIndex %>'
                                                        Text="<%$ Resources: _Kartris, FormButton_Change %>" CssClass="linkbutton icon_edit" />
                                                </ItemTemplate>
                                                <FooterTemplate>
                                                </FooterTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </asp:View>
                                <asp:View ID="viwNoLinks" runat="server">
                                    <asp:Panel ID="pnlNoResults" runat="server" CssClass="noresults">
                                        <asp:Literal ID="litNoItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" />
                                    </asp:Panel>
                                </asp:View>
                            </asp:MultiView>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel ID="tabNonLinkedFiles" runat="server">
                        <HeaderTemplate>
                            <asp:Literal ID="litContentTextNonLinkedFiles" runat="server" Text="<%$ Resources: _Versions, ContentText_NonLinkedFiles %>" />&nbsp;(<asp:Literal
                                ID="litNonLinkedFiles" runat="server" />)</HeaderTemplate>
                        <ContentTemplate>
                            <div>
                                <h2>
                                    <asp:Literal ID="litContentTextUploadFolder" runat="server" Text="<%$ Resources: _Kartris, ContentText_UploadFolder %>" /></h2>
                                <div>
                                    <asp:Literal ID="litContentTextNonRelatedFiles" runat="server" Text="<%$ Resources: _Versions, ContentText_NonRelatedFiles %>" /></div>
                                <asp:MultiView ID="mvwNonLinked" runat="server" ActiveViewIndex="0">
                                    <asp:View ID="viwNonLinkedData" runat="server">
                                        <asp:ListBox ID="lstNonRelatedFiles" runat="server" Visible="false" />
                                        <asp:GridView ID="gvwNonLinkedFiles" CssClass="kartristable" runat="server" AllowSorting="true"
                                            AutoGenerateColumns="False" AutoGenerateEditButton="False" GridLines="None" SelectedIndex="0"
                                            AllowPaging="true" PageSize="15">
                                            <Columns>
                                                <asp:TemplateField>
                                                    <HeaderTemplate>
                                                    </HeaderTemplate>
                                                    <ItemStyle CssClass="recordnumberfield" />
                                                    <ItemTemplate>
                                                        <asp:Literal ID="litDataItem" runat="server" Text='<%# Container.DataItemIndex + 1 %>' />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField>
                                                    <HeaderTemplate>
                                                        <asp:Literal ID="litContentTextFileName" runat="server" Text="<%$ Resources: _Kartris, ContentText_Filename %>" />
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <asp:UpdatePanel ID="updNonRelatedFile" runat="server" UpdateMode="Conditional">
                                                            <ContentTemplate>
                                                                <asp:LinkButton ID="lnkNonRelatedFile" runat="server" CommandName="OpenFile" Text='<%# Eval("FileName") %>'
                                                                    CommandArgument='<%# Eval("FileName") %>' />
                                                            </ContentTemplate>
                                                            <Triggers>
                                                                <asp:PostBackTrigger ControlID="lnkNonRelatedFile" />
                                                            </Triggers>
                                                        </asp:UpdatePanel>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField>
                                                    <HeaderTemplate>
                                                        <asp:Literal ID="litContentTextFileSize" runat="server" Text="<%$ Resources: _Kartris, ContentText_FileSize %>" />
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <asp:Literal ID="litSize" runat="server" Text='<%# Eval("FileSize") %>' />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField ItemStyle-CssClass="selectfield">
                                                    <HeaderTemplate>
                                                        <asp:LinkButton ID="btnDeleteAll" runat="server" Text='<%$ Resources:_Kartris, ContentText_DeleteAll %>'
                                                            CommandName="DeleteAllFiles" CssClass="linkbutton icon_delete floatright" />
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <asp:LinkButton ID="lnkBtnDelete" CssClass="linkbutton icon_delete" runat="server"
                                                            Text='<%$ Resources: _Kartris, FormButton_Delete %>' CommandName="DeleteFile"
                                                            CommandArgument='<%# Eval("FileName") %>' /></span>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                    </asp:View>
                                    <asp:View ID="viwNoNonLinked" runat="server">
                                        <asp:Panel ID="pnlNoResults1" runat="server" CssClass="noresults">
                                            <asp:Literal ID="litContentTextNoItemsFound" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>">
                                            </asp:Literal>
                                        </asp:Panel>
                                    </asp:View>
                                </asp:MultiView>
                            </div>
                            <br />
                            <div>
                                <h2>
                                    <asp:Literal ID="litContentTextTempFolder" runat="server" Text="<%$ Resources: _Kartris, ContentText_TempFolder %>" /></h2>
                                <div>
                                    <asp:PlaceHolder ID="phdNoTempFiles" runat="server">
                                        <div class="noresults">
                                            <asp:Literal ID="litContentTextNoItemsFound2" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" />
                                        </div>
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder ID="phdTempFilesExist" runat="server" Visible="false">
                                        <p>
                                            <strong>
                                                <asp:Literal ID="litContentTextFiles" runat="server" Text="<%$ Resources: _Kartris, ContentText_Files %>" /></strong>:
                                            <asp:Literal ID="litTempFiles" runat="server" /></p>
                                        <p>
                                            <asp:LinkButton ID="lnkBtnDeleteTempFiles" CssClass="linkbutton icon_delete" runat="server" Text="<%$ Resources: _Kartris, ContentText_DeleteAll %>" /></p>
                                    </asp:PlaceHolder>
                                </div>
                            </div>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                </ajaxToolkit:TabContainer>
                <_user:UploaderPopup ID="_UC_UploaderPopup" runat="server" />
                <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
            </ContentTemplate>
        </asp:UpdatePanel>
        <asp:UpdateProgress ID="upgMain" runat="server" AssociatedUpdatePanelID="updMain">
            <ProgressTemplate>
                <div class="loadingimage">
                </div>
                <div class="updateprogress">
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>

        <script type="text/javascript">
            function onSave() {
                var postBack = new Sys.WebForms.PostBackAction();
                postBack.set_target('lnkSave');
                postBack.set_eventArgument('');
                postBack.performAction();
            }
        </script>

        <asp:UpdatePanel ID="updInputMessage" runat="server">
            <ContentTemplate>
                <asp:Panel ID="pnlMessage" runat="server" Style="display: none" CssClass="popup">
                    <h2>
                        <asp:Literal ID="litTitle" runat="server" Text="<%$ Resources: _Kartris, ContentText_FileRename %>" /></h2>
                    <asp:LinkButton ID="lnkExtenderCancel" runat="server" Text="" CssClass="closebutton linkbutton2" />
                    <asp:LinkButton ID="lnkBtn" runat="server"></asp:LinkButton>
                    <div>
                        <b>
                            <asp:Literal ID="litMessage" runat="server" /></b>
                        <div class="Kartris-DetailsView">
                            <div class="Kartris-DetailsView-Data">
                                <ul>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litFormLabelVersionName" runat="server" Text="<%$ Resources: _Product, FormLabel_VersionName %>" />
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litPopupVersionName" runat="server" />
                                    </span></li>
                                    <asp:Literal ID="litType" runat="server" Visible="false" />
                                    <asp:MultiView ID="mvwPopup" runat="server" ActiveViewIndex="0">
                                        <asp:View ID="viwPopupDownload" runat="server">
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Literal ID="litContentTextFilename" runat="server" Text="<%$ Resources: _Kartris, ContentText_Filename %>" />
                                            </span><span class="Kartris-DetailsView-Value">
                                                <asp:Literal ID="litPopupFileName" runat="server" Visible="false" />
                                                <asp:TextBox ID="txtPopupFileName" runat="server" MaxLength="70" />
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="*"
                                                ControlToValidate="txtPopupFileName" ValidationGroup="FileRename" />
                                            </span></li>
                                        </asp:View>
                                        <asp:View ID="viwPopupLink" runat="server">
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Literal ID="litContentTextValue2" runat="server" Text="<%$ Resources: _Kartris, ContentText_Value %>" />
                                            </span><span class="Kartris-DetailsView-Value">
                                                <asp:Literal ID="litPopupLinkLocation" runat="server" Visible="false" />
                                                <asp:TextBox ID="txtPopupLinkLocation" runat="server" MaxLength="70" />
                                            </span></li>
                                        </asp:View>
                                    </asp:MultiView>
                                </ul>
                            </div>
                        </div>
                        <asp:LinkButton ID="lnkExtenderOk" runat="server" Text="" CssClass="invisible" />
                        <p>
                            <asp:Button ID="lnkSave" OnClick="lnkSave_Click" runat="server" Text="<%$ Resources: _Kartris, FormButton_Save %>"
                                CssClass="button" />
                            &nbsp;<asp:Button ID="lnkCancel" runat="server" Text="<%$ Resources: _Kartris, FormButton_Cancel %>"
                                CssClass="button cancelbutton" /></p>
                    </div>
                </asp:Panel>
                <ajaxToolkit:ModalPopupExtender ID="popExtender" runat="server" TargetControlID="lnkBtn"
                    PopupControlID="pnlMessage" OnOkScript="onSave()" BackgroundCssClass="popup_background"
                    OkControlID="lnkExtenderOk" CancelControlID="lnkExtenderCancel" DropShadow="False"
                    RepositionMode="None">
                </ajaxToolkit:ModalPopupExtender>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
</asp:Content>
