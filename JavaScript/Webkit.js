/*
Google Chrome / Safari / WebKit hack

There appears to be a bug in ASP.net that does not
recognize Google Chrome and so serves up 'fixed' code
designed for Safari.
*/

//Google chrome I think
Sys.Browser.WebKit = {}; //Safari 3 is considered WebKit

if (navigator.userAgent.indexOf('WebKit/') > -1) {

    Sys.Browser.agent = Sys.Browser.WebKit;

    Sys.Browser.version = parseFloat(navigator.userAgent.match(/WebKit\/(\d+(\.\d+)?)/)[1]);

    Sys.Browser.name = 'WebKit';

}
