<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_UploaderPopup.ascx.vb" Inherits="UserControls_Back_UploaderPopup" %>
<%--<%@ Register TagPrefix="Master" TagName="MasterPage" Src="~/MasterPages/Admin.master" %>--%>
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
    <h2><asp:Literal ID="litContentTextUpload" runat="server" Text="<%$ Resources: _Kartris, ContentText_FileUpload %>"></asp:Literal></h2>
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
                <asp:Literal ID="litStatus2" runat="server"></asp:Literal></p>
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
