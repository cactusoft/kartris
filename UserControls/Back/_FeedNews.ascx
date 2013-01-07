<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_FeedNews.ascx.vb" Inherits="UserControls_Back_FeedNews" %>
<asp:UpdatePanel ID="updNews" runat="server">
    <ContentTemplate>
        <div class="section_newsfeed">
            <asp:PlaceHolder ID="phdNewsFeed" runat="server">
                <asp:LinkButton ID="lnkForward" runat="server" class="links linknext">&#187;</asp:LinkButton><asp:LinkButton
                    ID="lnkBack" runat="server" class="links linkback" Visible="false">&#171;</asp:LinkButton>
            <h2><asp:Literal ID="litContentTextKartrisNews" Text="<%$ Resources: _Kartris, ContentText_KartrisNews %>"
                runat="server" /></h2>
                <asp:Literal ID="litXMLData" runat="server"></asp:Literal><asp:HiddenField ID="hidItem"
                    Value="0" runat="server" />
            </asp:PlaceHolder>
            <asp:PlaceHolder ID="phdNewsFeedNotAccessible" runat="server" Visible="false">
                <asp:Literal ID="litContentTextFeedNotAccessible" runat="server" Text="<%$ Resources: _Kartris, ContentText_FeedNotAccessible %>" />
            </asp:PlaceHolder>
        </div>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgNews" runat="server" AssociatedUpdatePanelID="updNews">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
