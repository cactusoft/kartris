<%@ Control Language="VB" AutoEventWireup="false" CodeFile="MediaGallery.ascx.vb"
    Inherits="UserControls_Front_MediaGallery" %>
<asp:PlaceHolder runat="server" ID="phdMediaGallery">
<!-- Media Gallery -->
    <div class="spacer">
    </div>
    <div class="media_gallery">
        <div class="media_gallery_inner">
        <h2><span><span>
            <asp:Literal ID="litContentTextMediaGallery" runat="server" Text="<%$ Resources: Media, ContentText_MediaGallery %>"></asp:Literal></span></span></h2>
            <asp:Repeater ID="rptMediaLinks" runat="server">
                <ItemTemplate>
                    <div class="media_links">
                        <div class="mediaholder_horiz">
                            <asp:Literal ID="litMediaLink" runat="server"></asp:Literal>
                            <asp:PlaceHolder ID="phdInline" runat="server" />
                            <asp:HyperLink Visible="false" CssClass="media_downloadlink" ID="lnkDownload" runat="server"
                                ToolTip="<%$ Resources: Media, ContentText_Download %>" >
                            </asp:HyperLink>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>
</asp:PlaceHolder>
