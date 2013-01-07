<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_ConfigSettingPopup.ascx.vb" Inherits="UserControls_Back_ConfigSettingPopup" %>
<asp:UpdatePanel ID="updPopup" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Panel ID="pnlConfig" runat="server" Style="display: none" CssClass="popup" >
            <h2><asp:Literal ID="litConfigName" runat="server" /></h2>
                <asp:PlaceHolder ID="phdSettings" runat="server" EnableViewState="true" />
                <asp:Literal ID="litConfigDesc" runat="server" />
                
            <asp:LinkButton ID="btnExtenderCancel" runat="server" Text="" CssClass="closebutton" />
            <asp:LinkButton ID="lnkDummy" runat="server" CausesValidation="false" />
            <div class="submitbuttons">
                <asp:Button ID="btnAccept" CssClass="button" runat="server" Text='<%$ Resources: _Kartris, FormButton_Update %>'
                    CausesValidation="true"  />
            </div>
        </asp:Panel>
        <ajaxToolkit:ModalPopupExtender ID="popConfigSetting" runat="server" TargetControlID="lnkDummy"
            PopupControlID="pnlConfig" BackgroundCssClass="popup_background" CancelControlID="btnExtenderCancel" DropShadow="False">
        </ajaxToolkit:ModalPopupExtender>
    </ContentTemplate>
</asp:UpdatePanel>
