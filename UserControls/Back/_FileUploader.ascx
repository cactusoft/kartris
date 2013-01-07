<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_FileUploader.ascx.vb"
    Inherits="_FileUploader" %>
<%@ Register TagPrefix="_user" TagName="ItemSorter" Src="~/UserControls/Back/_ItemSorter.ascx" %>
<%@ Register TagPrefix="_user" TagName="UploaderPopup" Src="~/UserControls/Back/_UploaderPopup.ascx" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:UpdatePanel ID="updUploaderArea" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <div id="fileuploader">
                    <_user:UploaderPopup ID="_UC_UploaderPopup" runat="server" />
                    <asp:Button ID="btnAddFile" runat="server" Text="<%$ Resources: _Kartris, ContentText_AddNew %>"
                        CssClass="button" />
                    <asp:Literal ID="litInfo" runat="server" Visible="false" />
                    <asp:CheckBox ID="chkOneItemOnly" runat="server" CssClass="checkbox" Visible="false" />
                </div>
                <div>
                    <_user:ItemSorter ID="_UC_ItemSorter" runat="server" />
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdatePanel ID="updConfirmationMessage" runat="server">
    <ContentTemplate>
        <asp:Panel ID="pnlMessage" runat="server" Style="display: none" CssClass="popup">
            <asp:LinkButton ID="lnkExtenderCancel" runat="server" Text="" CssClass="closebutton" />
            <h2>
                <asp:Literal ID="litTitle" runat="server" Text="<%$ Resources:Kartris, ContentText_Error %>" /></h2>
            <p>
                <asp:Literal ID="litStatus" runat="server"></asp:Literal></p>
            <asp:LinkButton ID="lnkBtn" runat="server" CssClass="invisible"></asp:LinkButton>
            <asp:LinkButton ID="lnkExtenderOk" runat="server" Text="" CssClass="invisible" />
        </asp:Panel>
        <ajaxToolkit:ModalPopupExtender ID="popExtender" runat="server" TargetControlID="lnkBtn"
            PopupControlID="pnlMessage" OnOkScript="onYes()" BackgroundCssClass="popup_background"
            OkControlID="lnkExtenderOk" CancelControlID="lnkExtenderCancel" DropShadow="False"
            RepositionMode="None">
        </ajaxToolkit:ModalPopupExtender>
    </ContentTemplate>
</asp:UpdatePanel>
