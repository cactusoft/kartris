
//------------------------------------------------------------------------------
// The functions below are used to hide ASP.NET modal popups
// for large images, media when the background is clicked
//------------------------------------------------------------------------------

function pageLoad() {
    var backgroundElementLargeImage = $get('cntMain_UC_ProductView_tbcProduct_tabMain_UC_PopUpLargeView_popMessage_backgroundElement');
    var backgroundElementMedia = $get('cntMain_UC_ProductView_tbcProduct_tabMain_UC_PopUpMedia_popMessage_backgroundElement');
    var backgroundElementEmptyBasket = $get('cntMain_UC_BasketMain_popEmptyBasket_backgroundElement');

    if (backgroundElementLargeImage)
        $addHandler(backgroundElementLargeImage, 'click', hideModalPopupViaClientLargeImage);

    if (backgroundElementMedia)
        $addHandler(backgroundElementMedia, 'click', hideModalPopupViaClientMedia);

    if (backgroundElementEmptyBasket)
        $addHandler(backgroundElementEmptyBasket, 'click', hideModalPopupViaClientEmptyBasket);
}

function hideModalPopupViaClientLargeImage(e) {
    var modalPopupBehaviorLargeImage = $find('cntMain_UC_ProductView_tbcProduct_tabMain_UC_PopUpLargeView_popMessage');
    if (modalPopupBehaviorLargeImage) modalPopupBehaviorLargeImage.hide();
}

function hideModalPopupViaClientMedia(e) {
    var modalPopupBehaviorMedia = $find('cntMain_UC_ProductView_tbcProduct_tabMain_UC_PopUpMedia_popMessage');
    if (modalPopupBehaviorMedia) modalPopupBehaviorMedia.hide();
}

function hideModalPopupViaClientEmptyBasket(e) {
    var modalPopupBehaviorEmptyBasket = $find('cntMain_UC_BasketMain_popEmptyBasket');
    if (modalPopupBehaviorEmptyBasket) modalPopupBehaviorEmptyBasket.hide();
}



