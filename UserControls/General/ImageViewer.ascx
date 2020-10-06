<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ImageViewer.ascx.vb"
    Inherits="ImageViewer" %>


<asp:Panel runat="server" ID="pnlImageViewer" Visible="false">
    <div class="imageviewer_holder">
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
        <div class="updateprogress" style="display: none;">
            <div class="loadingimage"></div>
        </div>
    </div>
    <script>
        function openClearingEventListeners() {
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
        }

        $(function () {
            openClearingEventListeners();
        });

        var prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_endRequest(function (s, e) {

            // Refreshing foundation after postback
            // after getting images (solves the problem of images appearing big)
            if ($('[data-clearing] li img').closest("ul").hasClass("clearing-thumbs")) {
                $(document).foundation();
            }

            openClearingEventListeners();

        });

    </script>
</asp:Panel>
<asp:Panel runat="server" ID="pnlSingleImage" Visible="false">
    <div class="imageviewer_holder">
        <asp:Literal ID="litSingleImage" runat="server"></asp:Literal>
        <div class="spacer">
        </div>
        <!-- Large view link -->
        <div class="largeview">
            <asp:Literal ID="litLargeViewLink2" runat="server"></asp:Literal>
        </div>
    </div>
</asp:Panel>



