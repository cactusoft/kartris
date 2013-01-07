<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_OptionsPopup.ascx.vb" Inherits="UserControls_Back_OptionsPopup" %>
<%@ Register TagPrefix="_user" TagName="OptionsContainer" Src="~/UserControls/Back/_OptionsContainer.ascx" %>
<asp:UpdatePanel ID="updPnlOptions" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Panel ID="pnlOptions" runat="server" Style="display: none" CssClass="popup">
            <!-- Customization Window Title and Close Button -->
            <h2>
                <asp:Literal ID="litContentTextTitle" runat="server" Text='<%$ Resources: _Kartris, ContentText_Options %>'
                    EnableViewState="false" /></h2>
            <asp:LinkButton ID="lnkClose" runat="server" Text="" CssClass="closebutton" />
            <div>
                <!-- Description Text -->
                <div>
                    <strong><asp:Literal ID="litProductName" runat="server" /></strong>
                    <asp:Literal ID="litVersionCode" runat="server"></asp:Literal>
                    <br />
                    <asp:UpdatePanel ID="updOptionsContainer" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <_user:OptionsContainer ID="UC_OptionsContainer" runat="server" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
                <!-- Options Submit Button -->
                <div class="submitbuttons">
                    <asp:Button ID="btnSaveOptions" runat="server" CssClass="button" ValidationGroup="SaveOptions"
                        Text='<%$ Resources: Kartris, FormLabel_Save %>' />
                </div>
            </div>
        </asp:Panel>
        <ajaxToolkit:ModalPopupExtender ID="popOptions" runat="server" TargetControlID="lnkClose"
            PopupControlID="pnlOptions" BackgroundCssClass="popup_background" OkControlID="lnkClose"
            CancelControlID="lnkClose" DropShadow="False">
        </ajaxToolkit:ModalPopupExtender>
        <asp:Literal ID="litVersionID" runat="server" Visible="false" />
        <asp:Literal ID="litProductID" runat="server" Visible="false" />
    </ContentTemplate>
</asp:UpdatePanel>


