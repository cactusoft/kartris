<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_UserLoginPopup.ascx.vb" Inherits="UserControls_Back_UserLoginPopup" %>


<script type="text/javascript">
    function onRemove() {
        var postBack = new Sys.WebForms.PostBackAction();
        postBack.set_target('btnRemove');
        postBack.set_eventArgument('');
        postBack.performAction();
    }
</script>

<div id="section_editcoupon">
    <asp:UpdatePanel ID="updConfirmationMessage" runat="server">
        <ContentTemplate>
            <asp:Panel ID="pnlMessage" runat="server" Style="display: none" CssClass="popup" Width="250px" Height="150px">
                <h2>
                    <asp:Literal ID="litTitle" runat="server" Text="<%$ Resources: _Kartris, ContentText_Confirmation %>" /></h2>
                <asp:LinkButton ID="lnkExtenderCancel" runat="server" Text="" CssClass="closebutton linkbutton2" />
                <asp:LinkButton ID="lnkBtn" runat="server"></asp:LinkButton>
                <asp:Literal ID="litErrorMessage" runat="server" Visible="false" />
                <asp:PlaceHolder ID="phdContents" runat="server">
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label runat="server" ID="lblUserName" Text="<%$ Resources: _Kartris, FormLabel_Username %>"
                                        AssociatedControlID="txtUserName" /></span><span class="Kartris-DetailsView-Value"><asp:TextBox
                                            ID="txtUserName" runat="server" CssClass="midtext" />
                                            <asp:RequiredFieldValidator ID="valUser" runat="server" ErrorMessage="*"
                                                ValidationGroup="login" ControlToValidate="txtUserName" /></span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label runat="server" ID="lblPass" Text="<%$ Resources: _Kartris, FormLabel_Password %>"
                                        AssociatedControlID="txtPass" /></span><span class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtPass" runat="server" TextMode="Password" CssClass="midtext" />
                                            <asp:RequiredFieldValidator ID="valPass" runat="server" ErrorMessage="*"
                                                ValidationGroup="login" ControlToValidate="txtPass" /></span></li>
                                <li><span class="Kartris-DetailsView-Name"></span><span class="Kartris-DetailsView-Value">
                                    <asp:Button ID="btnSubmit" runat="server" Text="<%$ Resources: _Kartris, FormButton_Submit %>"
                                        CssClass="button" ValidationGroup="login" OnClick="btnSubmit_Click" />&nbsp;
                                    <asp:Button ID="btnCancel" runat="server" CssClass="button cancelbutton"
                                    Text='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                                </span></li>
                            </ul>
                        </div>
                    </div>
                    <asp:LinkButton ID="lnkExtenderOk" runat="server" Text="" CssClass="invisible" />
                </asp:PlaceHolder>
            </asp:Panel>
            <ajaxToolkit:ModalPopupExtender ID="popExtender" runat="server" TargetControlID="lnkBtn"
                PopupControlID="pnlMessage" OnOkScript="onRemove()" BackgroundCssClass="popup_background"
                OkControlID="lnkExtenderOk" CancelControlID="lnkExtenderCancel" DropShadow="False"
                RepositionMode="None">
            </ajaxToolkit:ModalPopupExtender>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
