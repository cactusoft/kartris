
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
    // page loading spinner
        $(".page-loading-container").fadeOut("500");
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
        $("#menuCategories").fadeOut(140);
        menuBackOverlay();
        $("#menuCategoriesLink").removeClass("taller");
    }
    else {
        closeAllMenus();
        $("#menuBackOverlay").fadeIn(140); // back area to capture clicks away, so we can hide menu
        $("#menuCategories").fadeIn(140);
        $("#menuCategoriesLink").addClass("taller");
    }
}

// Open further menu 1
function menuFurther1() {
    if ($("#menuFurther1").is(':visible')) {
        $("#menuFurther1").fadeOut(140);
        menuBackOverlay();
        $("#menuFurtherLink1").removeClass("taller");
    }
    else {
        closeAllMenus();
        $("#menuBackOverlay").fadeIn(140); // back area to capture clicks away, so we can hide menu
        $("#menuFurther1").fadeIn(140);
        $("#menuFurtherLink1").addClass("taller");
    }
}

// Open further menu 2
function menuFurther2() {
    if ($("#menuFurther2").is(':visible')) {
        $("#menuFurther2").fadeOut(140);
        menuBackOverlay();
        $("#menuFurtherLink2").removeClass("taller");
    }
    else {
        closeAllMenus();
        $("#menuBackOverlay").fadeIn(140); // back area to capture clicks away, so we can hide menu
        $("#menuFurther2").fadeIn(140);
        $("#menuFurtherLink2").addClass("taller");
    }
}

// Open further menu 3
function menuFurther3() {
    if ($("#menuFurther3").is(':visible')) {
        $("#menuFurther3").fadeOut(140);
        menuBackOverlay();
        $("#menuFurtherLink3").removeClass("taller");
    }
    else {
        closeAllMenus();
        $("#menuBackOverlay").fadeIn(140); // back area to capture clicks away, so we can hide menu
        $("#menuFurther3").fadeIn(140);
        $("#menuFurtherLink3").addClass("taller");
    }
}

// Open search menu
function menuSearch() {
    if ($("#menuSearch").is(':visible')) {
        $("#menuSearch").fadeOut(140);
        menuBackOverlay();
        $("#menuSearchLink").removeClass("taller");
    }
    else {
        closeAllMenus();
        $("#menuBackOverlay").fadeIn(140); // back area to capture clicks away, so we can hide menu
        $("#menuSearch").fadeIn(140);
        $("#menuSearchLink").addClass("taller");
        // put cursor focus in searchbox
        $("#searchbox").focus();
        $("#searchbox").attr('placeholder', 'Search...');
    }
}

// Close all menus
function menuBackOverlay() {
    $(".menuSpecial").fadeOut(140);
    $(".menuSpecial").removeClass("taller");
    $("#menuBackOverlay").fadeOut(140);
}
function closeAllMenus() {
    $(".menuSpecial").fadeOut(140);
    $(".menuSpecial").removeClass("taller");
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

// add 'header--fixed' class to header when we scroll 
// away from top
$(document).ready(function () {
    $(window).bind("scroll",
        function () {
            var e = 90;
            $(window).scrollTop() > e
                ? $("div#header").addClass("header--fixed")
                : $("div#header").removeClass("header--fixed");
        });

});

// Home page featured products carousel
// Make sure your template references
// JavaScript/k30001/filmroll.jquery.min.js
$(function () {
    fr = new FilmRoll({
        container: '#cntMain_UC_FeaturedProducts_updMain',
        height: 540,
        pager: false
    });
});


