<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_PopupMessage.ascx.vb" Inherits="UserControls_Back_PopupMessage" %>


<script type="text/javascript">
    function onYes() {
        var postBack = new Sys.WebForms.PostBackAction();
            postBack.set_target('lnkYes');
            postBack.set_eventArgument('');
            postBack.performAction();
    }
</script>

<asp:UpdatePanel ID="updConfirmationMessage" runat="server">
    <ContentTemplate>
        <asp:Panel ID="pnlMessage" runat="server" Style="display: none" CssClass="popup">

            <h2><asp:Literal ID="litTitle" runat="server" Text="<%$ Resources: _Kartris, ContentText_Confirmation %>"/></h2>

            <asp:LinkButton ID="lnkExtenderCancel" runat="server" Text="" CssClass="closebutton" />
            <asp:LinkButton ID="lnkBtn" runat="server"></asp:LinkButton>
            <asp:PlaceHolder ID="phdContents" runat="server">
                <div>
                    <asp:PlaceHolder ID="phdImage" runat="server" Visible="false">
                        <div class="imageholder">
                            <asp:Image ID="imgToRemove" runat="server" Width="120px" Height="120px" />
                            <p>
                                <strong><asp:Literal ID="litImageNameToRemove" runat="server"></asp:Literal></strong>
                            </p>
                        </div>
                    </asp:PlaceHolder>
                    <p><asp:Literal ID="litMessage" runat="server" /></p>
                    
                    <asp:LinkButton ID="lnkExtenderOk" runat="server" Text="" CssClass="invisible" />
                    <p>
                    <asp:Button ID="lnkYes" OnClick="lnkYes_Click" runat="server" Text="<%$ Resources: _Kartris, ContentText_Yes %>" Visible="false" CssClass="button" />
                    &nbsp;<asp:Button ID="lnkNo" OnClick="lnkNo_Click" runat="server" Text="<%$ Resources: _Kartris, ContentText_No %>"
                    Visible="false" CssClass="button cancelbutton" /></p>
                </div>
            </asp:PlaceHolder>
        </asp:Panel>
        <ajaxToolkit:ModalPopupExtender ID="popExtender" runat="server" TargetControlID="lnkBtn"
            PopupControlID="pnlMessage" OnOkScript="onYes()" BackgroundCssClass="popup_background"
            OkControlID="lnkExtenderOk" CancelControlID="lnkExtenderCancel" DropShadow="False"
            RepositionMode="None">
        </ajaxToolkit:ModalPopupExtender>
    </ContentTemplate>
</asp:UpdatePanel>