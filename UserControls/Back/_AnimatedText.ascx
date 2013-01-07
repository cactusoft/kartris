<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_AnimatedText.ascx.vb"
    Inherits="UserControls_Back_AnimatedText" %>
<asp:PlaceHolder ID="phdAnimation" runat="server" Visible="false">
    <ajaxToolkit:AnimationExtender ID="aneMain" runat="server" TargetControlID="pnlMessage">
        <Animations>
                        <OnLoad>
                            <Sequence>
                                <EnableAction Enabled="false" />
                                <FadeOut Duration="2" Fps="25" />
                                <Parallel >
                                <Resize Height="0" Width="0" Unit="px" />
                                </Parallel>
                                <HideAction />
                            </Sequence>
                        </OnLoad>                
        </Animations>
    </ajaxToolkit:AnimationExtender>
    <asp:Panel ID="pnlMessage" runat="server">
        <div class="updatemessage">
            <asp:Literal ID="litMessage" runat="server" Text='<%$ Resources:_Kartris, ContentText_UpdateSaved %>'></asp:Literal>
        </div>
    </asp:Panel>
</asp:PlaceHolder>
