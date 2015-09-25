<%@ Control Language="VB" AutoEventWireup="false" CodeFile="PopupMessage.ascx.vb" ClientIDMode="Predictable" Inherits="UserControls_General_PopupMessage" %>
<asp:UpdatePanel ID="updPopup" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Panel ID="pnlMessage" runat="server" Style="display: none" CssClass="popup">
            <h2>
                <asp:Literal ID="litTitle" runat="server" /></h2>
            <asp:LinkButton ID="lnkBtn" runat="server"></asp:LinkButton>
            <asp:LinkButton ID="btnExtenderCancel" runat="server" Text="×" CssClass="closebutton" />
            <asp:MultiView ID="mvwDisplay" runat="server" ActiveViewIndex="0">
                <asp:View ID="viwEmpty" runat="server">
                </asp:View>
                <asp:View ID="viwText" runat="server">
                    <p>
                        <asp:Literal ID="litMessage" runat="server" /></p>
                    <br />
                </asp:View>
                <asp:View ID="viwMedia" runat="server">
                    <asp:Literal ID="litIframeMedia" runat="server"></asp:Literal>
                </asp:View>
            </asp:MultiView>
            <asp:Button ID="btnExtenderOk" runat="server" Text="" CssClass="invisible" />
        </asp:Panel>
        <ajaxToolkit:ModalPopupExtender ID="popMessage" runat="server" TargetControlID="lnkBtn"
            PopupControlID="pnlMessage" BackgroundCssClass="popup_background" OkControlID="btnExtenderOk"
            CancelControlID="btnExtenderCancel" DropShadow="False">
          
        </ajaxToolkit:ModalPopupExtender>

    </ContentTemplate>
</asp:UpdatePanel>


