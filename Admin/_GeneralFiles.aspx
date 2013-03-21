<%@ Page Title="" Language="VB" MasterPageFile="~/Skins/Admin/Template.master" AutoEventWireup="false" CodeFile="_GeneralFiles.aspx.vb" Inherits="Admin_GeneralFiles" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="phdMain" runat="Server">
    <h1>
        <asp:Literal ID="litPageTitleGeneralFiles" runat="server" Text="<%$ Resources: _Kartris, PageTitle_GeneralFiles %>" /></h1>
    <asp:MultiView ID="mvwGeneralFiles" runat="server" ActiveViewIndex="0">
        <asp:View ID="viwFiles" runat="server">
            <asp:UpdatePanel ID="updFiles" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:GridView CssClass="kartristable" ID="gvwFiles" runat="server" AllowPaging="true"
                        AllowSorting="false" AutoGenerateColumns="False" DataKeyNames="F_Name" AutoGenerateEditButton="False"
                        GridLines="None" SelectedIndex="0" PageSize="15">
                        <Columns>
                            <asp:TemplateField>
                                <ItemStyle CssClass="column1" />
                                <ItemTemplate>
                                    <asp:Literal ID="litNumber" runat="server" Text='<%# Container.DataItemIndex + 1 %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="F_Name" HeaderText="<%$ Resources:_Kartris, ContentText_Filename %>"
                                ItemStyle-CssClass="column2" />
                            <asp:BoundField DataField="F_Type" HeaderText="<%$ Resources:_Kartris, ContentText_FileType %>"
                                ItemStyle-CssClass="column2" />
                            <asp:BoundField DataField="F_Size" HeaderText="<%$ Resources:_Kartris, ContentText_FileSize %>"
                                ItemStyle-CssClass="column2" />
                            <asp:BoundField DataField="F_LastUpdated" HeaderText="<%$ Resources:_Kartris, ContentText_LastUpdated %>"
                                ItemStyle-CssClass="column2" />
                            <asp:TemplateField ItemStyle-CssClass="selectfield">
                                <HeaderTemplate>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkBtnDelete" runat="server" CommandName="DeleteFile" CommandArgument='<%# Eval("F_Name") %>'
                                        Text='<%$ Resources: _Kartris, FormButton_Delete %>' CssClass="linkbutton icon_delete" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                    <asp:HiddenField ID="hidFileNameToDelete" runat="server"></asp:HiddenField>
                    <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
                    <asp:UpdateProgress ID="prgFiles" runat="server" AssociatedUpdatePanelID="updFiles">
                        <ProgressTemplate>
                            <div class="loadingimage">
                            </div>
                            <div class="updateprogress">
                            </div>
                        </ProgressTemplate>
                    </asp:UpdateProgress>

                </ContentTemplate>
            </asp:UpdatePanel>
        </asp:View>
        <asp:View ID="viwNoFiles" runat="server">
            <asp:Panel ID="pnlNoItems" runat="server" CssClass="noresults">
                <asp:Literal ID="litNoItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>">
                </asp:Literal>
            </asp:Panel>
        </asp:View>
    </asp:MultiView>
    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
        <asp:LinkButton ID="btnAdd" runat="server" CssClass="button addbutton" Text="<%$ Resources:_Kartris, FormButton_Add %>"
            ToolTip="<%$ Resources:_Kartris, FormButton_Add %>" />
    </div>
    <asp:Panel ID="pnlMessage" runat="server" Style="display: none" CssClass="popup">
        <asp:LinkButton ID="lnkExtenderCancel" runat="server" Text="" CssClass="closebutton" />
        <asp:LinkButton ID="lnkBtn" runat="server" CssClass="invisible"></asp:LinkButton>

        <script type="text/javascript">
            function onUpload() {
                var postBack = new Sys.WebForms.PostBackAction();
                postBack.set_target('lnkUpload');
                postBack.set_eventArgument('');
                postBack.performAction();
            }
        </script>

        <asp:LinkButton ID="lnkExtenderOk" runat="server" Text="" CssClass="invisible" />
        <h2>
            <asp:Literal ID="litContentTextUpload" runat="server" Text="<%$ Resources: _Kartris, ContentText_FileUpload %>"></asp:Literal></h2>
        <asp:UpdatePanel ID="updUploader" runat="server">
            <Triggers>
                <asp:PostBackTrigger ControlID="lnkUpload" />
            </Triggers>
            <ContentTemplate>
                <asp:LinkButton ID="lnkUpload" runat="server" OnClick="lnkUpload_Click" Text="<%$ Resources: _Kartris, ContentText_Upload %>"
                    CssClass="linkbutton icon_upload" />
                <asp:FileUpload ID="filUploader" runat="server" />
            </ContentTemplate>
        </asp:UpdatePanel>
    </asp:Panel>
    <asp:UpdatePanel ID="updConfirmationMessage" runat="server">
        <ContentTemplate>
            <asp:Panel ID="pnlMessage2" runat="server" Style="display: none" CssClass="popup">
                <asp:LinkButton ID="lnkExtenderCancel2" runat="server" Text="" CssClass="closebutton" />
                <h2>
                    <asp:Literal ID="litTitle2" runat="server" Text="<%$ Resources:Kartris, ContentText_Error %>" /></h2>
                <p>
                    <asp:Literal ID="litStatus2" runat="server"></asp:Literal>
                </p>
                <asp:LinkButton ID="lnkBtn2" runat="server" CssClass="invisible"></asp:LinkButton>
                <asp:LinkButton ID="lnkExtenderOk2" runat="server" Text="" CssClass="invisible" />
            </asp:Panel>
            <ajaxToolkit:ModalPopupExtender ID="popExtender2" runat="server" TargetControlID="lnkBtn2"
                PopupControlID="pnlMessage2" OnOkScript="onYes()" BackgroundCssClass="popup_background"
                OkControlID="lnkExtenderOk2" CancelControlID="lnkExtenderCancel2" DropShadow="False"
                RepositionMode="None">
            </ajaxToolkit:ModalPopupExtender>
        </ContentTemplate>
    </asp:UpdatePanel>
    <ajaxToolkit:ModalPopupExtender ID="popExtender" runat="server" TargetControlID="lnkBtn"
        PopupControlID="pnlMessage" OnOkScript="onUpload" BackgroundCssClass="popup_background"
        OkControlID="lnkExtenderOk" CancelControlID="lnkExtenderCancel" DropShadow="False"
        RepositionMode="None">
    </ajaxToolkit:ModalPopupExtender>
</asp:Content>

