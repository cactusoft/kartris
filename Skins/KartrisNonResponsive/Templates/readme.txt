This folder is designed to hold templates for the following features

------------------------------------------
ORDER CONFIRMATON PAGE
------------------------------------------
Some payment systems will relay HTML returned to them in the Callback.aspx page on to the user.
Returning the standard Kartris page is problematic; some gateways will strip script and other
required tags from it to protect against XSS. Furthermore local links to CSS and other files
won't work, so pages will appear without any styling.

To overcome this, Kartris can use HTML templates for particular payment systems. If present, 
these will be read, the order details inserted where a placeholder is, and the output sent
to the payment system to relay to end users.

If using CSS, it is best to put this within the HTML file, as local links to CSS will fail. 
Some payment systems support uploading of images to their secure servers; in this case you
can reference these from your HTML (with full https:// URL). Do not reference anything without
SSL (such as images on your own site if it doesn't have SSL). Doing so will result in security
warnings to users that 'some items in this page are not secure'.

Templates should be named as follows:

Callback-[GatewayName].html

The Gateway name should match the folder name of the plugin exactly, for example:

Callback-Realex.html
Callback-RBSWorldPay.html

The template should include a tag as follows, which will act as a placeholder for the order
details:

[orderdetails]