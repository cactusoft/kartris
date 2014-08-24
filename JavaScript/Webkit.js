/*
Previously we had this file because there were issues with Chrome being identified as Safari
on early versions of the AjaxToolkit. But Chrome broke things with release 36, and we found a
fix was to effectively tell things to treat Chrome as Firefox. More info here.

http://www.kartris.com/Knowledgebase/Chrome-AJAX-postback-issues-July-2014__k-56.aspx

*/
Sys.Browser.WebKit = {}; //Safari 3 is considered WebKit

if (navigator.userAgent.indexOf('WebKit/') > -1) {

    Sys.Browser.agent = Sys.Browser.Firefox;

    Sys.Browser.version = parseFloat(navigator.userAgent.match(/WebKit\/(\d+(\.\d+)?)/)[1]);

    Sys.Browser.name = 'Firefox';

}
