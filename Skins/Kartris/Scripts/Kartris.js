$(document).ready(function () {
    $(document).foundation();
});
$(document).foundation({
    offcanvas: {
        open_method: 'overlap_single'
    }
});
$(window)
    .load(function () {
        SetOffCanvasHeight();
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

// ==== MEGA MENU ================================================================


// Open categories menu
function menuCategories() {
    if ($("#menuCategories").is(':visible')) {
        $("#menuCategories").fadeOut(340);
        $("#menuBackOverlay").fadeOut(340);
        $("#menuCategoriesLink").removeClass("taller");
    }
    else {
        $("#menuBackOverlay").fadeIn(340); // back area to capture clicks away, so we can hide menu
        $("#menuCategories").fadeIn(340);
        $("#menuCategoriesLink").addClass("taller");
    }
}

// Close all menus
function menuBackOverlay() {
    $("#menuCategories").fadeOut(340);
    $("#menuCategoriesLink").removeClass("taller")
    $("#menuBackOverlay").fadeOut(340);
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


