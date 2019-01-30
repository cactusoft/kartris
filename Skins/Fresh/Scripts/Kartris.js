// Jquery code to power the Suburban Griller Kartris skin

// Start foundation
$(document).foundation({
    offcanvas: {
        open_method: 'overlap_single'
    }
});


// Opening and closing the off-canvas seems to fire
// the updateprogress spinner on product pages. The
// code below hides the updateprogress.
function openOffCanvas() {
    return true;
}
function closeOffCanvas() {
    return true;
}

/// Show search box
function openSearchBox() {
    $("#searchbox_popup").fadeIn(200);
    $('#searchbox').focus();
    return true;
}

/// Close search box
function closeSearchBox() {
    $("#searchbox_popup").fadeOut(200);
    return true;
}


// ==== MEGA MENU ================================================================

/// Open megamenu
function openMegaMenu(catID) {
    if (catID !== 22 && catID !== 21) {
        $("#mm_" + catID).fadeIn(40);
        $("#mml_" + catID).addClass("selectedmenulink");
    //alert("#mm_" + catID);
    } 

}

// handles closing megamenu when hover away
$(document).ready(function () {
    $("li.megamenu_linkholder, div.megamenu_tab").mouseleave(function () {
        
        $(".megamenu_tab").delay(120).fadeOut(120);
        $(".megamenu_linkholder").removeClass("selectedmenulink");
    });
});




