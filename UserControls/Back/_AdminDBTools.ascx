<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_AdminDBTools.ascx.vb"
    Inherits="UserControls_Back_AdminDBTools" %>
<asp:UpdatePanel ID="updAdminTools" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <h2>
            <asp:Literal ID="litPageTitleDatabaseInformation" runat="server" Text="<%$ Resources: _Kartris, PageTitle_DatabaseInformation %>" /></h2>
        <div class="Kartris-DetailsView">
            <div class="Kartris-DetailsView-Data">
                <strong>
                    <asp:Literal ID="litContentTextDatabaseName" runat="server" Text="<%$ Resources: _Kartris, ContentText_DatabaseName %>" /></strong>:
                <asp:Literal ID="litDBName" runat="server" />
            </div>
        </div>
        <asp:GridView CssClass="kartristable" ID="gvwDBInfo" runat="server" AutoGenerateColumns="False"
            AutoGenerateEditButton="False" GridLines="None" SelectedIndex="0">
            <Columns>
                <asp:TemplateField ItemStyle-CssClass="datefield">
                    <HeaderTemplate>
                        <asp:Literal ID="litContentTextFileType" runat="server" Text="<%$ Resources: _Kartris, ContentText_FileType %>" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:Literal ID="litFileType" runat="server" Text='<%# Eval("FileType") %>' />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField ItemStyle-CssClass="aligncentre" HeaderStyle-CssClass="aligncentre">
                    <HeaderTemplate>
                        <asp:Literal ID="litContentTextFileSize" runat="server" Text="<%$ Resources: _Kartris, ContentText_FileSize %>" />
                        (MB)
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:Literal ID="litFileSize" runat="server" Text='<%# Eval("FileSize") %>' />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField ItemStyle-CssClass="column3">
                    <HeaderTemplate>
                        <asp:Literal ID="litContentTextFilePath" runat="server" Text="<%$ Resources: _Kartris, ContentText_FilePath %>" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:Literal ID="litFileLocation" runat="server" Text='<%# Eval("FileLocation") %>' />
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
        <h2>
            <asp:Literal ID="litContentTextDatabaseBackup" runat="server" Text="<%$ Resources: _Kartris, ContentText_DatabaseBackup %>"></asp:Literal></h2>
        <asp:Literal ID="litContentTextFolder" Text="<%$ Resources: _Kartris, ContentText_Folder %>"
            runat="server" />: <strong>
                <asp:Literal ID="litConfigBackupFolder" runat="server" /></strong>
        <asp:HyperLink ID="lnkContentTextConfigChange2" runat="server" CssClass="linkbutton icon_edit"
            runat="server" Text="<%$ Resources: _Kartris, ContentText_ConfigChange2 %>" NavigateUrl="~/Admin/_Config.aspx?name=general.backupfolder" /><br />
        <asp:MultiView ID="mvwBackup" runat="server" ActiveViewIndex="0">
            <asp:View ID="viwCreateBackup" runat="server">
                <div class="Kartris-DetailsView">
                    <div class="Kartris-DetailsView-Data">
                        <ul>
                            <li><span class="Kartris-DetailsView-Name">
                                <asp:Literal ID="litContentTextFilePath2" runat="server" Text="<%$ Resources: _Kartris, ContentText_FilePath %>" /></span><span
                                    class="Kartris-DetailsView-Value">
                                    <asp:Literal ID="litBackupName" runat="server" /></span></li>
                            <li><span class="Kartris-DetailsView-Name">
                                <asp:Literal ID="litContentTextDescription" runat="server" Text="<%$ Resources: _Kartris, ContentText_Description %>" /></span><span
                                    class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtBackupDescription" runat="server" TextMode="MultiLine" MaxLength="4000" />
                                </span></li>
                            <li><span class="Kartris-DetailsView-Name">Kartris Root</span><span
                                    class="Kartris-DetailsView-Value">
                                    <asp:Literal ID="litRootPath" runat="server" />
                                </span></li>
                        </ul>
                    </div>
                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                        <asp:LinkButton ID="btnCreateBackup" runat="server" Text="<%$ Resources: _Kartris, FormButton_Save %>"
                            ToolTip="<%$ Resources: _Kartris, FormButton_Save %>" CssClass="button savebutton" /></div>
                </div>
            </asp:View>
            <asp:View ID="viwBackupSucceeded" runat="server">
                <asp:LinkButton ID="lnkBtnBackSucceeded" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>'
                    CssClass="linkbutton icon_back floatright" />
                <br />
                <br />
                <div class="updatemessage">
                    <asp:Literal ID="litBackupSucceeded" runat="server" />
                </div>
            </asp:View>
            <asp:View ID="viwBackupFailed" runat="server">
                <asp:LinkButton ID="lnkBtnBackFailed" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>'
                    CssClass="linkbutton icon_back floatright" />
                <br />
                <br />
                <div class="errormessage">
                    <asp:Literal ID="litBackupFailed" runat="server" /></strong></p>
                </div>
            </asp:View>
        </asp:MultiView>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgAdminTools" runat="server" AssociatedUpdatePanelID="updAdminTools">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
