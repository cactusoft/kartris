// Jquery code to power the Suburban Griller Kartris skin

// Start foundation
$(document).ready(function () {
    $(document).foundation();
    $('.loadspinner').find('a').click(function () {
        $(".page-loading-container").fadeIn("20");
    });
});
$(document).foundation({
    offcanvas: {
        open_method: 'overlap_single'
    }
});

// Handle page height issues
$(window)
    .load(function () {
        SetOffCanvasHeight();
        $(".page-loading-container").fadeOut("500");
    })
    .resize(function () {
        SetOffCanvasHeight();
    });

function SetOffCanvasHeight() {
    var height = $(window).height();
    var footerheight = $("#footer").height();
    var contentHeight = $(".inner-wrap").height();
    //alert($(window).height() + ' - ' + $("#footer").height() + ' - ' + $(".inner-wrap").height())
    if (contentHeight < height) {
        $(".off-canvas-wrap").height(height);
        $(".inner-wrap").height(height - footerheight);
        $(".left-off-canvas-menu").height(height - footerheight);
    }
}

// Opening and closing the off-canvas seems to fire
// the updateprogress spinner on product pages. The
// code below hides the updateprogress.
function openOffCanvas() {
    $(".updateprogress").height(0);
    return true;
}
function closeOffCanvas() {
    $(".updateprogress").hide();
    $(".updateprogress").height('100%');
    return true;
}

// Reset canvas height when there are partial postbacks
// We need this because if a postback expands the page
// by unhiding a section, we don't want a secondary
// scrollbar down the side of the page
function pageLoad() { // this gets fired when the UpdatePanel completes
    SetOffCanvasHeight();
}

/// Show search box
function openSearchBox() {
    $("#searchbox_popup").fadeIn(200);
    return true;
}

/// Close search box
function closeSearchBox() {
    $("#searchbox_popup").fadeOut(200);
    return true;
}



