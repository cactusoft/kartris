<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_HTMLEditor.ascx.vb" Inherits="UserControls_Back_HTMLEditor" %>
<script type="text/javascript">
    function onYes() {
        var postBack = new Sys.WebForms.PostBackAction();
            postBack.set_target('lnkYes');
            postBack.set_eventArgument('');
            postBack.performAction();
        }
</script>

<asp:UpdatePanel ID="updConfirmationMessage" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Panel ID="pnlMessage" runat="server" Style="display: none" CssClass="popup htmleditor">
            <h2>
                <asp:Literal ID="litTitle" runat="server" Text="<%$ Resources: _Kartris, ContentText_HTMLEditor %>" /></h2>
            <asp:LinkButton ID="lnkExtenderCancel" runat="server" Text="" CssClass="closebutton linkbutton2" />
            <asp:LinkButton ID="lnkBtn" runat="server"></asp:LinkButton>
            <asp:PlaceHolder ID="phdContents" runat="server">
                <div class="pad">
                         <asp:TextBox runat="server"
                            ID="txtHTMLEditor" 
                            TextMode="MultiLine" 
                            Rows="20" CssClass="htmltextbox" />
    
                        <ajaxToolkit:HtmlEditorExtender
                            ID="htmlEditorExtender1" 
                            TargetControlID="txtHTMLEditor"
                            DisplaySourceTab="true"
                            EnableSanitization="false"
                            runat="server" >
                        </ajaxToolkit:HtmlEditorExtender>
                        
                    <asp:LinkButton ID="lnkExtenderOk" runat="server" Text="" CssClass="invisible" />
              </div>
                <p>
                    <asp:Button ID="lnkYes" OnClick="lnkYes_Click" runat="server" Text="<%$ Resources: _Kartris, FormButton_Submit %>"
                        Visible="True" CssClass="button" />
                </p>
            </asp:PlaceHolder>
        </asp:Panel>
        <ajaxToolkit:ModalPopupExtender ID="popExtender" runat="server" TargetControlID="lnkBtn"
            PopupControlID="pnlMessage" OnOkScript="onYes()" BackgroundCssClass="popup_background"
            OkControlID="lnkExtenderOk" CancelControlID="lnkExtenderCancel" DropShadow="False"
            RepositionMode="None">
        </ajaxToolkit:ModalPopupExtender>
    </ContentTemplate>
</asp:UpdatePanel>
