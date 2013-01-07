
//------------------------------------------------------------------------------
// The functions below are used to hide ASP.NET modal popups
// for large images, media when the background is clicked
//------------------------------------------------------------------------------

function pageLoad() {
    var backgroundElementLargeImage = $get('ctl00_cntMain_UC_ProductView_tbcProduct_tabMain_fvwProduct_UC_PopUpLargeView_popMessage_backgroundElement');
    var backgroundElementMedia = $get('ctl00_cntMain_UC_ProductView_tbcProduct_tabMain_fvwProduct_UC_PopUpMedia_popMessage_backgroundElement');
    var backgroundElementEmptyBasket = $get('ctl00_cntMain_UC_BasketMain_popEmptyBasket_backgroundElement');

    if (backgroundElementLargeImage)
        $addHandler(backgroundElementLargeImage, 'click', hideModalPopupViaClientLargeImage);

    if (backgroundElementMedia)
        $addHandler(backgroundElementMedia, 'click', hideModalPopupViaClientMedia);

    if (backgroundElementEmptyBasket)
        $addHandler(backgroundElementEmptyBasket, 'click', hideModalPopupViaClientEmptyBasket);
}

function hideModalPopupViaClientLargeImage(e) {
    var modalPopupBehaviorLargeImage = $find('ctl00_cntMain_UC_ProductView_tbcProduct_tabMain_fvwProduct_UC_PopUpLargeView_popMessage');
    if (modalPopupBehaviorLargeImage) modalPopupBehaviorLargeImage.hide();
}

function hideModalPopupViaClientMedia(e) {
    var modalPopupBehaviorMedia = $find('ctl00_cntMain_UC_ProductView_tbcProduct_tabMain_fvwProduct_UC_PopUpMedia_popMessage');
    if (modalPopupBehaviorMedia) modalPopupBehaviorMedia.hide();
}

function hideModalPopupViaClientEmptyBasket(e) {
    var modalPopupBehaviorEmptyBasket = $find('ctl00_cntMain_UC_BasketMain_popEmptyBasket');
    if (modalPopupBehaviorEmptyBasket) modalPopupBehaviorEmptyBasket.hide();
}




