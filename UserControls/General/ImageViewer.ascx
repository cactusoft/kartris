<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ImageViewer.ascx.vb"
    Inherits="ImageViewer" %>
<div class="imageviewer_holder">
    <asp:UpdatePanel ID="updPopup" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:Panel runat="server" ID="pnlImageViewer" Visible="false">
                <div>
                    <!-- Main image -->
                    <div class="mainimage">
                        <a href="#" class="open-clearing" data-thumb-index="0">
                        <asp:Literal ID="litMainImage" runat="server"></asp:Literal>
                        </a>
                    </div>
                    <div class="spacer">
                    </div>
                    <!-- Large view link -->
                    <div class="largeview">
                        <asp:Literal ID="litLargeViewLink" runat="server"></asp:Literal>
                    </div>
                    <div class="spacer">
                    </div>
                    <!-- Image gallery -->
                    <div class="spacer"></div>

                    <ul class="clearing-thumbs" data-clearing>
                        <asp:Literal ID="litGalleryThumbs" runat="server"></asp:Literal>
                    </ul>
                    <div class="spacer">
                    </div>
                    <script>
                        $('.open-clearing').on('click', function (e) {
                            e.preventDefault();
                            $('[data-clearing] li img').eq($(this).data('thumb-index')).trigger('click');
                        });
                        $(document.body).on("open.fndtn.clearing", function (event) {
                            $(".updateprogress").show();
                        });
                        $(document.body).on("opened.fndtn.clearing", function (event) {
                            $(".updateprogress").hide();
                        });
                    </script>
                    <div class="updateprogress" style="display:none;">
                        <div class="loadingimage"></div>
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
