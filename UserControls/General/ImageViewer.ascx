<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ImageViewer.ascx.vb"
    Inherits="ImageViewer" %>
<div class="imageviewer_holder">
    <asp:UpdatePanel ID="updPopup" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:Panel runat="server" ID="pnlImageViewer" Visible="false">
                <div class="imageviewer">
                    <!-- JS function -->
                    <asp:Literal ID="litJSFunction" runat="server"></asp:Literal>
                    <!-- Main image -->
                    <div class="mainimage">
                        <asp:Literal ID="litMainImage" runat="server"></asp:Literal>
                    </div>
                    <div class="spacer">
                    </div>
                    <!-- Large view link -->
                    <div class="largeview hide-for-small">
                        <asp:Literal ID="litLargeViewLink" runat="server"></asp:Literal></div>
                    <div class="spacer">
                    </div>
                    <!-- Image gallery -->
                    <div class="spacer"></div>
                    <div class="gallery">
                        <div class="scrollarea">
                            <asp:Literal ID="litGalleryThumbs" runat="server"></asp:Literal>
                            <div class="spacer">
                            </div>
                        </div>
                    </div>
                </div>
            </asp:Panel>
            <asp:Panel runat="server" ID="pnlSingleImage" Visible="false">
                <asp:Literal ID="litSingleImage" runat="server"></asp:Literal>
                <div class="spacer">
                </div>
                <!-- Large view link -->
                <div class="largeview">
                    <asp:Literal ID="litLargeViewLink2" runat="server"></asp:Literal></div>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
