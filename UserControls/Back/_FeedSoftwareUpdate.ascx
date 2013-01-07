<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_FeedSoftwareUpdate.ascx.vb"
    Inherits="UserControls_Back_FeedSoftwareUpdate" %>
<asp:UpdatePanel ID="updSoftwareUpdate" runat="server">
    <ContentTemplate>
        <div class="section_softwareupdate<asp:Literal ID='litExtraClass' runat='server'/>">
        <h2><asp:Literal ID="litSoftwareUpdateTitle" runat="server" Text="<%$ Resources: _SoftwareUpdate, PageTitle_SoftwareUpdate %>" /></h2>
            <asp:PlaceHolder ID="phdSoftwareUpdate" runat="server">
                <asp:Literal ID="litXMLData" runat="server"></asp:Literal>
            </asp:PlaceHolder>
            <asp:PlaceHolder ID="phdSoftwareUpdateNotAccessible" runat="server" Visible="false">
                <div class="softwareupdate_Critical">
                    <asp:Literal ID="litContentText_SoftwareUpdateNotAccessible" runat="server" Text="<%$ Resources: _Kartris, ContentText_SoftwareUpdateNotAccessible %>" />
                </div>
            </asp:PlaceHolder>
        </div>
    </ContentTemplate>
</asp:UpdatePanel>
