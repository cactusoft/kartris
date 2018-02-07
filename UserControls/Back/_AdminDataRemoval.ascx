<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_AdminDataRemoval.ascx.vb" Inherits="UserControls_Back_AdminDataRemoval" %>
<%@ Register TagPrefix="_user" TagName="LoginPopup" Src="~/UserControls/Back/_UserLoginPopup.ascx" %>

<div id="section_cleardata">
    <asp:UpdatePanel ID="updAdminDataRemoval" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div>
                <h2><asp:Literal ID="litContentText_ClearData" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_ClearData %>" />
                    <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=9804')">?</a>
                </h2>
                <asp:DropDownList ID="ddlDataToRemove" runat="server" CssClass="short">
                    <asp:ListItem Text="<%$ Resources: _Kartris, ContentText_None %>" Selected="True"
                        Value="N" />
                    <asp:ListItem Text="Products Related Data" Value="P" />
                    <asp:ListItem Text="Orders Related Data" Value="O" />
                    <asp:ListItem Text="Sessions Related Data" Value="S" />
                    <asp:ListItem Text="Content Related Data" Value="C" />
                </asp:DropDownList>
                <asp:Button ID="btnSubmit" runat="server" CssClass="button" Text="<%$ Resources: _Kartris, FormButton_Submit %>" />
                </div>
                <div>
                <asp:MultiView ID="mvwAdminRelatedTables" runat="server" ActiveViewIndex="0">
                    <asp:View ID="viwAdminRelatedTablesEmpty" runat="server">
                    </asp:View>
                    <asp:View ID="viwAdminRelatedTablesWarning" runat="server">
                    <br /><br />
                            <p><asp:Literal ID="litContentTextFollowTablesToDelete" runat="server"
                            Text="<%$ Resources: _DBAdmin, ContentText_FollowTablesToDelete %>" /></p>
                            <asp:BulletedList ID="bulTablesToBeRemoved" runat="server">
                            </asp:BulletedList><br />
                            <div class="errormessage">
                                <asp:Literal ID="litContentTextBackupSuggestion" runat="server"
                                Text="<%$ Resources: _DBAdmin, ContentText_BackupSuggestion %>" />
                                <asp:LinkButton ID="btnBackupNow" runat="server" Text="<%$ Resources: _Kartris, ContentText_DatabaseBackup %>" CssClass="linkbutton" />
                            </div>
                            <asp:Button ID="lnkBtnOpenLogin" CssClass="button" runat="server" Text="<%$ Resources: _Kartris, FormButton_Submit %>" />
                            <asp:Button ID="btnCancel" CssClass="button cancelbutton" runat="server" Text="<%$ Resources: _Kartris, FormButton_Cancel %>" />
                        
                    </asp:View>
                    <asp:View ID="viwAdminRelatedTablesSucceeded" runat="server">
                        <div class="updatemessage">
                            <asp:Literal ID="litOutput" runat="server" />
                        </div>
                    </asp:View>
                    <asp:View ID="viwAdminRelatedTablesFailed" runat="server">
                        <div class="errormessage">
                            <asp:Literal ID="litError" runat="server" />
                        </div>
                    </asp:View>
                </asp:MultiView>
                <_user:LoginPopup ID="_UC_LoginPopup" runat="server" />
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
<asp:UpdateProgress ID="prgAdminDataRemoval" runat="server" AssociatedUpdatePanelID="updAdminDataRemoval">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
