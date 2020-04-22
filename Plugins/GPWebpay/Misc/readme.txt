This script acts as a proxy. Add it to the root of your site, and then
set the URL (full URL including https://) to be the FixedUrlForCallback
setting of your subsites. This way, they will all send the URL for this
proxy script as the callback URL.

You then need to configure each site to have the tblKartrisOrders table
O_ID field seed value to be different for each site. So for example

1000000000
2000000000
3000000000

This way, each site will allocate order IDs in different ranges. This
is important as the single GP Webpay account needs unique order IDs.

It is also how our proxy script decides which site to relay the callback
to. You will need to edit the ReceiveCallback.aspx.vb script to map
incoming callbacks to the right callback URLs.

