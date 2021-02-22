<%@ Control Language="VB" AutoEventWireup="false" CodeFile="AnimatedText.ascx.vb"
    Inherits="UserControls_AnimatedText" %>


<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:PlaceHolder ID="pHolderAnimation" runat="server" Visible="false">
            <ajaxToolkit:AnimationExtender ID="MyExtender" runat="server" TargetControlID="MyPanel">
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
            <asp:Panel ID="MyPanel" runat="server">
                <div class="updatemessage">
                    <asp:Literal ID="litMessage" runat="server" Text='<%$ Resources:_Kartris, ContentText_UpdateSaved %>'></asp:Literal>
                </div>
            </asp:Panel>
        </asp:PlaceHolder>
    </ContentTemplate>
</asp:UpdatePanel>
