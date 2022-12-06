<?xml version="1.0"?>
<rss version="2.0">
  <channel>
	<title>Kartris Change Log</title>
	<link>http://www.kartris.com/feed/revisions/</link>
	<description>Kartris ASP.NET Ecommerce</description>
	<language>en-gb</language>
	<docs>http://www.kartris.com/feed/revisions/</docs>
	<generator>Kartris Web Site</generator>

	<item>
	  <majorVersion>3</majorVersion>
	  <minorVersion>3.3001</minorVersion>
	  <beta>False</beta>
	  <releaseDate></releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
	* Fixed issue with savedbaskets table clearing after new one saved
	  </bugFixes>
	  <improvements>
	* Stripe payment gateway support added, minor changes to CheckoutComplete and Callback to accommodate this, plus Stripe.net DLL
	* Support for newer GA-4, Google Analytics support (older version will be deprecated in Jun 2023)
	* Netbanx upgraded for 3ds-v2 (needs to pass some extra JSON info within form)
	  </improvements>
	</item>	

	<item>
	  <majorVersion>3</majorVersion>
	  <minorVersion>3.3000</minorVersion>
	  <beta>True</beta>
	  <releaseDate>Thu, 09 Jun 2022 14:25:00 GMT</releaseDate>
	 <type>Beta</type>
	  <bugFixes>
	* Fixed issue where new Worldpay DLL still reported itself as RBSWorldpay
	  </bugFixes>
	  <improvements>
	* New tblKartrisProductSearchIndex table used to store the min/max values of products. This makes for significantly better performance in searches or filtering by product price.
	* New triggers and sprocs that ensure this new index is maintained, with version, option or qty discount changes all triggering a recalculation.
	* Full clean up and rebuild of indexes of all tables, PKs using clustered indexes, consistent naming for all indexes, removed duplicate indexes, added some indexing to additional fields in places.
	  </improvements>
	</item>	
	
	<item>
	  <majorVersion>3</majorVersion>
	  <minorVersion>3.2002</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Tue, 05 Apr 2022 15:02:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
	* Changed callback so it checks O_Paid rather than O_Sent, allowing sent orders that are unpaid potentially to be paid and called back later
	* Getorders SQL updated to include the O_Invoiced status and excluded cancelled orders
	* Fixed status count
	* Add unique index to CO_ParentOrderID so cannot create two cloned orders from a single one (i.e. if open in two tabs at same time)
	* U_CustomerBalance changed to decimal(18,6), balance calculations and order payments list updated to exclude cancelled orders
	* Fixed issue where orders with O_Date of NULL were included in total count, even if they had been manually tagged as SENT
	* Fixed checkout shipping issue where did not show shipping until the "same shipping and billing" checkbox was cycled on/off
	* Suppressed new account mail for guest users at checkout
	  </bugFixes>
	  <improvements>
	* BLL threading improvements rolled out to Users, Categories and Versions
	* Various code to try to pre-select addresses when cloning an order, also improved email sent when an order is cloned to new and old order numbers clearly included and explained
	* Stock tracking handles cloned orders better, stock from cancelled released and then stock from new order reserved
	* Stock notification request now gives feedback that the request was recorded so users don't create multiple requests for same item, thinking nothing was recorded
	* Removed unused web service references, updated DLLs from Nuget
	* Added new sproc and code to clear the AUTOSAVE basket for a user when an order is placed, so that basket cannot be recovered automatically on next visit
	* Sagepay payment DLL upgraded and renamed to "Opayo"
	* RBSWorldpay payment DLL upgraded and renamed to "Worldpay"
	* Quickpay payment DLL added
	  </improvements>
	</item>	

	<item>
	  <majorVersion>3</majorVersion>
	  <minorVersion>3.2001</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Mon, 15 Nov 2021 13:39:00 GMT</releaseDate>
	 <type>Minor</type>
	  <bugFixes>
	* Internal release
	  </bugFixes>
	  <improvements>
	* Internal release
	  </improvements>
	</item>	

	<item>
	  <majorVersion>3</majorVersion>
	  <minorVersion>3.2000</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Tue, 13 Jul 2021 09:19:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
  * Cleaned up some minor issues in SQL creation script with language string changes for Login page
	  </bugFixes>
	  <improvements>
  * Reworked many BLL functions and their usage throughout for high volume items to improve reliability and scale up capacity, especially on busy sites
	  </improvements>
	</item>	

	<item>
	  <majorVersion>3</majorVersion>
	  <minorVersion>3.1002</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Tue, 04 May 2021 12:39:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
  * Fixed password reset problem
	  </bugFixes>
	  <improvements>
  * Cleaned up stats indexes
	  </improvements>
	</item>	
	
	<item>
	  <majorVersion>3</majorVersion>
	  <minorVersion>3.1001</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Wed, 21 Apr 2021 15:39:00 GMT</releaseDate>
	 <type>Minor</type>
	  <bugFixes>
	* Internal release
	  </bugFixes>
	  <improvements>
	* Internal release
	  </improvements>
	</item>	
	
	<item>
	  <majorVersion>3</majorVersion>
	  <minorVersion>3.1000</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Thu, 25 Feb 2021 15:39:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
  * Fixed issue where cannot dismiss popup for product customization, if customization is a required field
	  </bugFixes>
	  <improvements>
  * New default skin
  * Reorganization of "My Account" section, with tabbed interface
  * Added account balance to "My Account" section
  * Reworked tax/regional setup wizard, can now change tax regime from here
  * Customers/users now has object config tab, can easily add new values to be required for customers
  * Brexit/UK changes - EORI field added (using customers/users object config setting)
  * Brexit/UK changes - commodity code object config setting at product level
  * Brexit/UK changes - can now configure to keep EU VAT field option at checkout for EU customers, as it helps with shipping/customs
  * Brexit/UK changes - general.orders.extendedinvoiceinfo - turns on commodity code, weight per row, discounted price per row, EORI, EU VAT number on invoices, can help with filling in shipping documentation
  * Brexit/UK changes - email address added to invoice, can help with shipping documentation
  * Removed support for Flash/Shockwave in media uploads, reworked front end audio plugin to use HTML5 rather than Flash
  * Numerous performance improvements and minor bug fixes
	  </improvements>
	</item>	

	<item>
	  <majorVersion>3</majorVersion>
	  <minorVersion>3.0000</minorVersion>
	  <beta>True</beta>
	  <releaseDate>Tue, 15 Oct 2019 15:15:00 GMT</releaseDate>
	 <type>Beta</type>
	  <bugFixes>
  * Stock tracking on combinations products fixed
  * Fixed issue in basket where setting the shipping estimate config setting off causes blank basket page
	  </bugFixes>
	  <improvements>
  * Added support for 'sub sites' in back end. This lets you define separate sites, and map them to a category to use as their root. We hope to add front end support in the coming months, but wanted to let the back end work out into the wild for testing.
  * New default skin with mega-menu type layout and more animation
  * New VAT regime option, similar to the EU VAT code but supports a simpler structure with a single country member (e.g. New Zealand, or likely the UK if Brexit happens).
  * Updated the mail sending to use MailKit (thanks to Matteo for this)
  * Improvements to allow cloning multiple copies of a product in one go.
  * Lite products view improved and extended front and back, improves performance significantly on databases with large numbers of products
  * Improved the 404 page with built-in search box.
  * Hide order progress on front end if we detect the XML order content still in the progress field
  * Pre-select 'PO' as payment method when creating orders on the back end  
  * Improved generate feed exports
  * Improved install experience
  * More tomehost help links added
  * Improved database indexing and performance
	  </improvements>
	</item>
	
  <item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.9014</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Fri, 07 Sep 2018 11:11:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
  * Fix in site news that prevented uploading of images within the HTML editor
  * Updated _spKartrisProducts_DeleteByCategory so can handle large product IDs and deleting large numbers of products from a category
  * Made the feed generation more robust, try/catch to try to skip single line errors
  * Mailchimp, remove deleted carts on PO orders
	  </bugFixes>
	  <improvements>
  * Drag and drop sorting for products and categories
  * Language element retrieval now far more robust, virtually eliminates any Oops errors if one fails (it first waits 10ms then tries again, if still errors, returns blank)
  * Removed redirect to Default.aspx in global asax, so root of domain stays in URL bar and faster
  * Added a logout button to the my-account section, some older skins won't see the link on the login menu
  * Cancelled orders now visible in orders list
  * Fixed some problems with category sort, defaults to 1 so CactuShop imported data ready for sorting
  * Made carry on shopping more robust, try/catch if something fails or times out
  * Improved rich snippets code, thanks to Michael @ pyramid imaging
  * Various Mailchimp updates and improvements
  * Added a bookmark to top of powerpack filters, when page refreshes, can jump back to filters instead of top of page and needing to scroll down each time
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.9013</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Fri, 13 Apr 2018 10:27:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
  * Fix in OrdersBLL.vb to new account creation in new orders, needs IP address for GDPR modified sproc
	  </bugFixes>
	  <improvements>
  * Rewrote the orders listing sproc (back end) to improve performance significantly, especially on sites with huge numbers of orders in the database
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.9012</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Fri, 16 Mar 2018 14:21:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
  * Minor CSS fixes in Kartris skin
  * Fixed issue where versions displayed in dropdown format could not be added to basket
	  </bugFixes>
	  <improvements>
  * Upgraded to .NET 4.6 by default for TLS 1.2 support (see https://kartris.tome.host/tc/10112)
  * Added tomehost help to the back end
  * GDPR: new confirmation check box on new account dialog
  * GDPR: export data from customer edit page; easy way to fulfill data requests which will be free after May 2018
  * New 'suburban griller' skin
	  </improvements>
	</item>

	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.9011</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Tue, 28 Nov 2017 14:01:00 GMT</releaseDate>
	 <type>Minor</type>
	  <bugFixes>
  * Fixed popup/lightbox and display of multiple version images
	  </bugFixes>
	  <improvements>
  * Cleaned up sample data script to remove stats records
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.9010</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Sat, 25 Nov 2017 15:07:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
  * Fixed issue where out of stock items not removed from basket if they should be
  * Fixed various promotion issues
	  </bugFixes>
	  <improvements>
  * MailChimp support
  * Autosave basket when user is logged in
  * BrainTree payment plugin
  * Session creation optimizations, improved db stability, especially on large/busy sites
  * Turn all products in a category on/off
  * Attribute options (finite selections for attribute values as well as existing free text)
  * Images on basket items in order emails
  * Basket images - use version image if available, otherwise fallback to product image
  * Multiple version images with gallery
  * Image code improved, aspx replaced with ashx, which has lower overhead (does not run full page cycle - thanks to Craig at Deadline Automation)
  * Breadcrumbtrail tweak, if you change tab from default products to subcats, click through, breadcrump on product page now uses history.back on parent category link, so clicking remembers which tab you had selected
  * WriteToCSV improvements, encoding handled better so non-ASCII chars exported correctly
  * Improved image uploading/sorting control in back end, so improved renaming to ensure sort order respected
  * New object config to exclude some products from customer discount
 
	  </improvements>
	</item>
 
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.9009</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Wed, 3 May 2017 18:30:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
  * Fixed automated build process to copy in default config files for payment and other plugins
  * Fixed Write Review validation, now only validations the ReviewForm group, otherwise validation on other tabs can stop submission
	  </bugFixes>
	  <improvements>
  * Replaced old RDFa Rich Snippets markup with JSON-LD, Google's recommended approach now. The control is now self-contained, and also the MaxPrice function has been fixed to better handle option prices when calculating the max price of an item.
	  </improvements>
	</item>
 
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.9008</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Tue, 4 Apr 2017 16:55:00 GMT</releaseDate>
	 <type>Minor</type>
	  <bugFixes>
  * Remove idxSESS index, duplicate, and unique causes issues sometimes 
	  </bugFixes>
	  <improvements>
  * Added support for external SSL such as Cloudflare.com
  * Added web.config section to set cache headers for static files like CSS and JS
	  </improvements>
	</item>
 
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.9007</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Fri, 10 Mar 2017 16:55:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
  * Fixed setup SQL script; needs extra line at end otherwise installation can fail when the GO statements are parsed and each section of code is run against the db
  * Fixed bitcoin price feed, was hardcoded to GBP, now respects default currency
  * For CactuShop URLs, need to accept either PT_ID or CAT_ID for different versions
  * Fixed exporttoCSV issue, added zero-length string to value to force as string
  * More tax US/simple fixes to shipping and order handling charges
  * Fixed issue with shipping tax on US and simple tax orders if customer in same tax jurisdiction
  * Sitemap index code now working, if more than 50k URLs, it will create multiple sitemap files, and an index document detailing their URLs, and will show path to the index file in back end rather than the sitemap.xml, so it can be submitted to google
  * Make address popup more robust if country of existing address not found
  * Docdata rewritten; uses .mdb file now to hold pending orders and receive updates to them and make appropriate API checks with Docdata to get status
  * Added more detection of index out of bounds, this time to FormatCurrencyPrice, to attempt to recycle app pool
  * Improved logged error message if no db connection
  * Fixed issue with promotions, strip them from order before gateway otherwise get serialization error
  * Try loop more forgiving if one or more countries doesn't have foreign language translation
  * Updated kartris interfaces to remove promotions from XML, causes problems with sage and potentially other gateways that try to read the basket XML and deserialize it
	  </bugFixes>
	  <improvements>
  * New KartrisDark2 skin added, this is updated to work with latest version of Kartris
  * Kartris interfaces DLL updated, now if firstname (before last space in name) is longer than 20 chars, we instead take value up to first space. Also Sagepay.dll upgraded to .NET 4.5.2 and recompiled 
  * Improved feed for sitemap, no adaptor so easier to set timeout to long time
  * Sitemap feed updated to include multiple languages, new sproc to support this
	  </improvements>
	</item>
 
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.9006</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Thu, 6 Oct 2016 17:53:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
   * Option group issues with null values (if data imported via data tool)
   * Fixed issue where Default.aspx appended to CactuShop URL format support
   * Fixed AddDelimiter to escape double quotes in saved exports
   * Tweaks to 404 functionality to stop mangled error pages where a 404 is logged and then fires another error
   * Fixed issue where cannot edit a saved export that doesn't begin with SELECT (which ones using sprocs to execute will not)
   * Speeded up the tasklist query, this was using the full version view instead of the language-free one which is faster for doing counts where the language parts are not required
   * Introduced code to try to recycle the app pool programmatically if it crashes (such as when SQL is temporarily unavailable)
   * Fixed issue where extax total shows on simple tax method
   * Fixed issue where shipping dropdown broke if there were colons in the shipping name or description; now use multiple pipes as separator
   * Removed amount check on callback, seems to misfire on a few gateways
   * Fixed issue with powerpack filters not being URL encoded
   * fnKartrisBasket_GetItemWeight updated to add base version weight to options modifiers weights; previously if there were option weight modifiers, the total item weight was only from these and didn't include the base version weight.
	  </bugFixes>
	  <improvements>
   * Updated data tool export sproc in saved exports to match formatting required for re-import to data tool
   * Set SQL command and connection timeout for custom export as it can run for fair time on a big db
   * Added mime type header to Image.aspx, so image can be viewed directly in browser without appearing as corrupted text rather than an image
	  </improvements>
	</item>
	   
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.9005</minorVersion>
	  <beta>True</beta>
	  <releaseDate>Wed, 8 Jun 2016 12:12:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
   * Fixed issue with fixed value promotions not being triggered both ex tax pricing (spend £X, get xxxx).
   * Various currency values still using single or double found and changed to decimal.
	  </bugFixes>
	  <improvements>
   * Stock notifications
   * Added some experimental code to try to catch some conditions that can be fixed by an app-pool recycle, and recycle the app pool programmatically. There is a new DLL Microsoft.Web.Administration.dll in the Bin folder which provides the capability for this.
   * FORCE ORDER added to counts in the spKartrisDBGetTaskList sproc for tasklist, makes it run much faster in certain circumstances. Thanks to TiggyWiggler for the SQL for this.
   * Fixed couple of formatting issues for currency, now fixnull to db function for decimal doesn't set 0 to null.
   * Added content type to Image.aspx; right click and view image on Kartris thumbs show if viewed directly in a browser now, previously only showed in a page, but were garbled text data if viewed directly.
   * Serialization issue with promotions fixed (thanks to Craig, Deadline-Automation.com), workarounds (clearing promotions from basket before serialization) now removed
	  </improvements>
	</item>

	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.9004</minorVersion>
	  <beta>True</beta>
	  <releaseDate>Thu, 5 May 2016 09:52:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
   * Fixed issue with orders with promotions not saving properly due to XML serialization issue
   * Fixed Paypal plugin issue where currency values were submitted with comma rather than point as decimal separator (Paypal always requires point)
   * Issue where save button disappears after removing all featured products so cannot save changes fixed
   * Tax and regional wizard made more robust for setting EU countries, upgrade progress spinner added, Monaco added for EU purposes to taxregime.config
   * Fixed issue where language not picked up right so SEO fields don't get pulled in correctly
   * Fixed annoying issue where basket menu appears under orbit slider controls so disappears sometimes when being used on the home page
   * Fixed collation issues on temp tables, these will now be created with fields having same collation as database default, rather than the SQL instance default
   * Fixed Ts and Cs section not opening, restored jscript function
	  </bugFixes>
	  <improvements>
   * Clone single and multiple version products (not just individual versions)
   * Print multiple invoices simultaneously
   * Alt tags on product and category images
   * Live currency rate feed now using bitpay bitcoin rate feed
   * Easypay payment system (Portugal) added, includes credit card and multibanco support
   * Changed many real/float types to decimal for better handling of currency values and exchange rates, includes SQL table changes, sprocs updated, DAL, BLL and various functions in the code updated.
   * When not displaying tax on basket, but items are extax, show totals without tax
   * ID numbers added to country listing, makes it easier when setting the defaultcountry config setting
   * Do permanent rather than temp redirect (301) from http to https if ssl mode is 'a' (always on)
   * Just return first 160 chars of descriptions for meta description
   * Tweaked search routines so even if not 'exact' match, will try to fill up data with an exact match before a general match
   * Added RRP to single version product display (if there is an RRP set)
   * Added styling for tabular results produced from the execute query function
	  </improvements>
	</item>
	 
	  <item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.9003</minorVersion>
	  <beta>True</beta>
	  <releaseDate>Tue, 16 Feb 2016 11:10:00 GMT</releaseDate>
	 <type>Minor</type>
	  <bugFixes>
   * Improved redirection of /Admin folder to back end home
   * frontend.crossselling.trythesecategories now correctly sets number of categories displayed in cross selling links
   * Fixed sitemap language issue
   * Fixed some minor options issues, option products can now be stock tracked again
   * Fixed annoying issue where logs recorded data conversion error on product pages when enter key is used to submit search. Added panels with default buttons and turned add-to-bsket button and save customer text button in basketview to be buttons but changing usesubmitbehaviour.
   * Some other minor bug fixes
	  </bugFixes>
	  <improvements>
   * ModernCentre skin added
   * Default skin improved, new off-canvas menu, login and basket icons for better space use while in mobile mode, price display improved
   * In US tax mode, can now specify whether shipping has tax on per-method basis
   * Paypal plugin updated to support TLS 1.2
   * Docdata plugin updated to support TLS 1.2
   * Shipping selection hidden if only one choice
   * Markup prices now has CSV updates for group prices, quantity discounts and RRP added to main version update
   * Added a hint to logging of errors that suggest a problem with the db connection or permissions (language strings not found)
   * frontend.navigationmenu.cssids added, when on, puts unique IDs into main menus so can custom style particular links
	  </improvements>
	</item>
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.9002</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Mon, 4 Jan 2016 16:59:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
   * Disabled back end event validation, fixes annoying problem where expanded treeview fails if on a page that has posted back
   * Improvements to Postcodes4u support
   * 'Add' (to basket) button label using back end instead of front end for options
   * Hide back end graphs properly when turned off from config
   * Updated format currencies function so in 'partial' access mode it only obscures prices on the front end, not the back
   * Fixed rounding issue in customerorder control, fixed min order value currency issue in checkout.aspx.vb
   * Fixed rounding issue on row tax amount, was hardcoded to 4 decimal places instead of using the currency decimals value
   * Fixed issue where price list imports had lines truncated at 20 chars
   * Fixed layout for largeimageoverride in productview
   * Support full screen video popup, including back end updates
	  </bugFixes>
	  <improvements>
   * Major refactoring and rewrite of BasketBLL (thanks to Craig at http://www.deadline-automation.com for his excellent work on this)
   * Replaced large image popups with Foundation 'Clearing' lightbox for bigger images and cleaned up imageviewer code a lot as a result
   * Improved the media gallery support, now can name files/links, better layout and icons - support for zip and URL types added
   * Postcodes4u support added; address lookup functionality at checkout based on postcode
   * New Paypal DLL (1.1.0.0), this separates shipping/handling costs and order value components so they show separately at Paypal
   * Paypal settings in Kartris now include URLSandbox, in addition to URL - this lets you hold both the live and sandbox processing URLs, the Paypal component will use the sandbox one for TEST mode, and the live one for orders when ON
   * GP Webpay payment gateway added
   * Pay4Later payment gateway added
   * Netbanx payment gateway added
   * Back end payment gateway list now shows the DLL version number in listing, this will help clarify which DLL is installed for support and upgrading purposes
   * Minor change to chkOrderEmails, set to n when frontend.checkout.ordertracking is set off so no ordertracking option shown to customer
   * Support for siterooturl tag in callback templates, added 2co template that calls back and redirects back to Kartris checkout complete page.
   * Redirect back to page after login if private web site hit on a product or other URL
   * Updated UPS DLL, uses known path to XML lookup instead of reflection, this way the names of UPS shipping types show instead of codes
   * Fedex shipping plugin added (thanks to Justin Cosgrove, http://www.ctgsoftware.com/
   * Added product.asp, page.asp handles forwarding CactuShop URLs to Kartris to preserve SE behaviour on upgraded sites
   * 404 handler updated to handle redirecting cactushop product and category URLs to the new Kartris ones. Page.asp added to do same for custom pages
   * Added .axd http handlers to robot.txt, these seem to get hit and generate a lot of pointless errors in logs
   * Show an error message if the estimate shipping had an issue with the address
   * Improved 'call for price' display and handling
   * Added property to simple catmenu control to specify number of levels
   * Item sorter - change how items are renamed to allow for files that were not originally added via Kartris back end
   * Made back end custom pages control more resilient to imported data with date formatting function. Also introduced new category menu simple control to use on off-canvas menu in skin.
   * Added some further indexes to tblKartrisOrders, vastly improves performance of searching for and paging orders in the back end on stores with tens of thousands of orders
	  </improvements>
	</item>
	
	  <item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.9001</minorVersion>
	  <beta>True</beta>
	  <releaseDate>Fri, 25 Sep 2015 11:17:00 GMT</releaseDate>
	 <type>Minor</type>
	  <bugFixes>
	* Internal release
	  </bugFixes>
	  <improvements>
	* Internal release
	  </improvements>
	</item>
	  <item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.9000</minorVersion>
	  <beta>True</beta>
	  <releaseDate>Fri, 18 Sep 2015 18:21:00 GMT</releaseDate>
	 <type>Major</type>
	  <bugFixes>
	* Internal release
	  </bugFixes>
	  <improvements>
	* Internal release
	  </improvements>
	</item> 
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.8004</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Fri, 10 Apr 2015 11:17:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
   * Handle occasional reviews that can be imported with null ratings, without crashing product page
   * Fixed issue where reviews that were 'enabled (no versions)' did not show the reviews tab and hence reviews
   * Default address type to u in db, so addresses in imported data from CactuShop show on customer address tab in back end
	  </bugFixes>
	  <improvements>
   * Added search box filtering to attributes admin
   * Added search box filtering to options admin
   * Optimizations to attributes product tab for sites with more than 25 attributes
   * Optimizations to options product tab for sites with more than 25 option groups
   * Show kartris root path, uses server.mappath - useful for setting backup location and potentially path to other files where necessary
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.8003</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Sat, 21 Mar 2015 17:10:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
	  </bugFixes>
	  <improvements>
   * Changed attribute ID and associated fields to Int; previously tinyint only supported up to 255 attributes
   * New HugoFox skin, this is for use only for users with business sites on the HugoFox system
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.8002</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Fri, 13 Feb 2015 22:00:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
   * Fixed issue with version sort constraint when creating products in fresh installs
	  </bugFixes>
	  <improvements>
   * Upgraded WorldPay DLL, passes extra fields for VISA (with blank values, but required)
   * Global.asax code that maps friendly URLs for callback pages to parametrized version improved to replace subsequent ? characters with &amp; for gateways that send some querystring parameters to the callback page
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.8001</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Wed, 28 Jan 2015 22:34:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
   * General testing, debugging and fixing of various unitsize and stock issues with all the different product types.
   * Add a 'unique' index to U_EmailAddress. This should stop a potential issue where it's possible for a customer creating a new account to double click and create two records with the same email address. This code in the upgrade script may fail if there are duplicate records already, those would need to be removed first.
	  </bugFixes>
	  <improvements>
   * Can now have up to 9,999,999 of an item in stock
   * Error popups if you try to enter qty that conflicts with unitsize setting for a product
   * When adjusting down qty in basket because limited stock, we will reduce down to a size compatible with the unitsize for that product
   * Editing quantities in the basket will flag an error and return the amount to a valid number (i.e. compatible with stock limitations and unitsize)
   * When adjusting down qty in basket because limited stock, we will reduce down to a size compatible with the unitsize for that product
   * No longer defaults to textbox if unitsize is not 1. You can have dropdowns or no qty selector.
   * Textboxes will default to the unitsize, e.g. 10, rather than 1
   * New function - SafeModulus. This addresses problems with the built-in Mod function when handling double types 
   * Redefined the 'showtax' config setting; now has three settings - 'n'= don't show tax, 'y'= always show tax, 'c' = just show at checkout
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.8000</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Mon, 5 Jan 2015 11:17:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
   * Fixed callback issue on stores where regional settings use a comma as decimal separator. With gateways such as Paypal passing the order value back with a point, the comparison could cause callbacks to fail due to order value not matching.
   * Fixed issue where customer groups could not be edited; this was due to a validator which was hidden but still active on a field that is no longer used.
   * Fixed issue with 'Spend X get $Y off' promotion which was using extax basket total instead of inctax when required.
	  </bugFixes>
	  <improvements>
	* Print shipping labels; from the 'awaiting dispatch' page, the label format can be selected to create a PDF of addresses to print to standard labels. Thanks to Deadline Automation Ltd. for this code addition.
	* Added default sort direction setting for versions.
	  </improvements>
	</item>

	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.7001</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Sun, 31 Aug 2014 15:36:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
	* Various minor bugs fixed
	  </bugFixes>
	  <improvements>
	* Upgraded to ASP.NET 4.5
	* Upload multiple product images in one go
	* Error and admin logs moved to 'Reports' menu so both available with single click
	* Error log page improved: defaults to today's date (if there are errors), and will scroll errors field to bottom when loading or after refresh so latest error quicker to find
	* Restart button now on back end home page rather than hidden in DB admin
	* Clear orphan images and files now moved to 'Clear Data' tab in DB admin
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.7000</minorVersion>
	  <beta>True</beta>
	  <releaseDate>Mon, 25 Aug 2014 23:12:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
	* Chrome 36 back end issue fixed
	  </bugFixes>
	  <improvements>
	* Support for 'always on' SSL
	* Improved performance with new optimized 'no language' version view
	* Improved web API code including new serialization of data tables (thanks to Polychrome)
	* Removed various obsolete code including experimental Linnworks support
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.6004</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Sun, 22 Jun 2014 23:47:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
	* Moved price range label inside placeholder for filters, so gets hidden if no price range
	* Fixed some add-to-basket / stock / out of stock issues
	* Various options fixes
	* Fixed free shipping for combinations products
	  </bugFixes>
	  <improvements>
	* Updates to Search sprocs to handle nvarchar values internally (N'value' syntax), otherwise search can fail to find non-western strings
	* Show number of promotion applied in email text of order (e.g. 3 x Promotion)
	* Improvement to qty discounts when customer group pricing is lower - hide rows instead of setting price to customer group price
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.6003</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Wed, 4 Jun 2014 22:19:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
	* Fixed issue where category could not be saved if parent categories not altered - https://kartris.codeplex.com/SourceControl/changeset/34664
	* Updated split string function to 500 chars otherwise problems with attribute filtering in PowerPack
	  </bugFixes>
	  <improvements>
	* If a user has group pricing below that available through qty discounts, that will show in place of the qty discount  
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.6002</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Sun, 25 May 2014 09:52:00 GMT</releaseDate>
	 <type>Minor</type>
	  <bugFixes>
	* Double check that Logins_GetList sproc is present, sometimes seems to get missed earlier if upgrading which can give error when viewing logins page
	* Fixed some minor combination and options issues to improve interface back and front
	* Turn bitcoin and some other gateways off by default
	* Minor CSS changes
	* Fixed currency update for JPY and other currencies with no decimals
	* Fixed issue where cannot set stock levels in warnings to negative or zero
	  </bugFixes>
	  <improvements>
	* Zero value order now passes as PO as long as that is active (can set to authorized only).
	* Improved EU VAT number check, ignores country code if added to box (as already handled outside the box)
	* Added CSV and TXT export option; this is not Google Products compatible, but can give a good base for creating a file for some other systems such as Amazon    
	  </improvements>
	</item>

	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.6001</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Sat, 3 May 2014 13:13:59 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
	* Fixed some rounding issues in US tax regime
	* Fixed stock level fields on stock warning and edit version to allow negative values
	* Tasklist fixed so items with negative stock counted in out of stock total
	* Foundation minor update to fix Orbit slideshow issue on IE
	  </bugFixes>
	  <improvements>
	* Back end config improved, now formats dropdown of values for settings with finite list of options
	* Language string and config setting edit pages improved and simplified, some fields hidden until click to open up area, helps avoids accidentally editing wrong fields
	* Config search improved so after editing a config setting, the search filters are not changed, and you go back to search results
	* Various deprecated config settings that are handled elsewhere removed, - shipping tax set per method, USmultistatetax now handled by TaxRegime web config setting, shipping system now set at band level
	* Mailing list sign up option added to last stage of install routine
	* Checkout and basket totals display improved, extax, tax and total on separate lines rather than columns, which implied they're a total of the values above in same column
	* Some language strings whose descriptions refer to PDF manual changed to link to userguide
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.6000</minorVersion>
	  <beta>True</beta>
	  <releaseDate>Mon, 21 Apr 2014 00:09:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
	* Fixed support for SIMPLE tax regime
	* Removed continuing use of deprecated 'usmultistatetax' config setting
	* Fixed issues with out-of-stock items unavailable even when out-of-stock purchasing enabled
	* Fixed issue with versions imported with Data Tool not holding manual sort positions
	* Added constraint to prevent possibility of payments being logged twice
	  </bugFixes>
	  <improvements>
	* Responsive interface upgraded to support Foundation 5.2 while retaining legacy support for Kartris v2.5 skins (Foundation 4)
	* Create orders from back end
	* Redesign of order editing
	* Interface code for upcoming Kartris PowerPack incorporated
	* Tasklist improvement - arrears and refunds links now filter results
	  </improvements>
	</item>

	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.5009</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Fri, 7 Mar 2014 11:34:00 GMT</releaseDate>
	 <type>Minor</type>
	  <bugFixes>
	* Promotions and wishlist auto remove from navigation menu if turned off in the config settings
	* Removed code that tries to disable new product and new category links, which are no longer in the back end, which was leading to page errors if you logged in as a user without product permissions
	* Updated taxregime settings config file to include RO and BG and remove monaco from EU - SQL also updated
	* Coupon tax fix, basket layout improvements
	* Turned off paging for support tickets on customer side
	* Added indexes for support ticket tables, improved performance
	* Bugfix to 'Edit Order' Issue in the backend
	* Basket view control updated so tax at checkout in US mode does not show at 100 before destination is selected
	  </bugFixes>
	  <improvements>
	* Added Buckaroo payment system
	* Made front page featured/new/top/news controls self-contained, so no code behind needed on Default page each control can hide itself if turned off
	* Hide push notifications area if feature turned off from config settings
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.5008</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Mon, 25 Nov 2013 12:12:00 GMT</releaseDate>
	 <type>Minor</type>
	  <bugFixes>
	* Fixed maindata object config creation issue (duplicate IDs)
	* Fixes for non-English culture issues
	  </bugFixes>
	  <improvements>
	* Minor CSS tweaks
	  </improvements>
	</item>

	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.5007</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Thu, 14 Nov 2013 19:59:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
	* Categories with enough products to force the page links into sections with ... (for next section) could produce too many links in last section.
	* Various issues with stock level export and import CSV format fixed, so numeric SKUs are treated as strings rather than reverting to numbers and potentially losing trailing zeroes
	* _spKartrisLogins_GetList CREATE added to the upgrade SQL scripts as was missing
	* Fixed issues with Linnworks paging support
	* Fix for combination shipping issues; items set to ship free at version level would not seem their combinations inherit this
	* Fixed fnKartrisProduct_IsReadyToLive so belongs to dbo in upgrade and maindata SQL scripts
	* Fixed accordion / slideshow bug, where the Foundation slide show did not work if using the accordion type menu
	* Removed insert coupons lines from the sample data, as these clash with new constraints code
	* Updated Google Analytics code for Checkout and Callback page. 
	* Fixed issue where 'call for price' items show price in other currency
	  </bugFixes>
	  <improvements>
	* Some layout and CSS improvements for small screens, iphone in particular as very small by most mobile standards these days
	* Improvements to how the Web API handles method parameters. Added support to 'char' parameter types.
	* Better handling at checkout of cases where no valid shipping available, clearer error message
	* Improved invoice display to better show tax calculations
	* New view vKartrisVersionsStock created and GetTaskList Updated; this avoids using the main version view for the task list on every page, which is much slower
	  </improvements>
	</item>

	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.5006</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Wed, 6 Nov 2013 16:08:00 GMT</releaseDate>
	 <type>Minor</type>
	  <bugFixes>
	* Internal release
	  </bugFixes>
	  <improvements>
	* Internal release
	  </improvements>
	</item>

	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.5005</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Tue, 17 Sep 2013 22:58:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
	* Browser files updated to better handle IE10+ on some servers which don't seem to have up-to-date definitions
	  </bugFixes>
	  <improvements>
	* Web services API - full access to the BLL functions via remote http interface
	* Linnworks integration
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.5004</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Sun, 25 Aug 2013 12:30:00 GMT</releaseDate>
	 <type>Recommended</type>
	  <bugFixes>
	* PageBaseClass.vb - Browser sniffing for IE now identifies IE8 and below, rather than IE9 and below (IE9 can run foundation, it should get the responsive skin)
	* Global.asax - we now lookup the default currency rather than assuming it is ID=1, as the new functionality to switch default currencies means ID is irrelevant
	* Some minor CSS changes in the skins to hide the disabled scrollbar in large image popups
	* Fixed a VAT calculation error in orders from outside the EU on stores where prices include tax.
	* Updated SQL update script from v2.0 to v2.5 to update sprocs that add or update logins, as these have changed to accomodate the push notifications info
	* 2checkout - bug fixes and minor improvements
	  </bugFixes>
	  <improvements>
	* First beta of web service API included
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.5003</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Wed, 24 Jul 2013 15:00:00 GMT</releaseDate>
	 <type>Minor</type>
	  <bugFixes>
	* Removed redirect to OldIE page; search engines seem to see this for some reason. Now if no NonResponsive skin for old IE versions, we just serve the main skin.
	  </bugFixes>
	  <improvements>
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.5002</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Mon, 22 Jul 2013 11:01:00 GMT</releaseDate>
	  <type>Recommended</type>
	  <bugFixes>
	* SSL/webshopURL redirection issue sorted
	* Fixed issues with stock tracking counting/showing versions multiple times if product in multiple categories
	* Increased placeholder numbers used for 'all higher orders' otherwise max limit of about a tonne for stores using grams as weight measure
	* Customer group pricing was not considered in 'from' pricing
	* Products now hidden from home page if they are only available to a customer group that the logged in user is not a member of
	* Menus cached now varied by customer group ID and language, so users don't see items that are not available to them, or don't see items that are
	  </bugFixes>
	  <improvements>
	* Responsive interface (mobile and tablet support)
	* Bitcoin integration - fully native using Bitcoin client, no third party services required
	* Currency improvements; easy switching of default currency, common currencies pre-configured
	* Currency now set during install/setup routine; configures more easily for US, EU, Canada or other stores
	* Improved support for push notifications to Windows apps (Phone and Win 8) and Android app
	* Croatian VAT number handling added to EU VAT check function (welcome to the EU!)
	* Can now list customers by customer group
	* Title added to custom pages, no longer uses the ID field in bread crumbs
	  </improvements>
	</item>

	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.5001</minorVersion>
	  <beta>True</beta>
	  <releaseDate>Wed, 17 Jul 2013 18:02:00 GMT</releaseDate>
	 <type>Minor</type>
	  <bugFixes>
	* Internal release
	  </bugFixes>
	  <improvements>
	* Internal release
	  </improvements>
	</item>
  
	  <item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.5000</minorVersion>
	  <beta>True</beta>
	  <releaseDate>Sun, 9 Jun 2013 13:58:00 GMT</releaseDate>
	 <type>Minor</type>
	  <bugFixes>
	* Internal release
	  </bugFixes>
	  <improvements>
	* Internal release
	  </improvements>
	</item>
	  
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.0002</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Wed, 1 May 2013 16:57:00 GMT</releaseDate>
	  <type>Minor</type>
	  <bugFixes>
	* Fixed problem with Ajaxtoolkit which causes tabs not to show in IE8 and earlier
	* Fixed caching of category menu when categories mapped to customer groups
	* Fixed downloadable product links, and removed extraneous div which stopped accordions after the downloads one from expanding in my-account
	* HTMLeditor issue partially sorted; image upload still not working (doesn't like modal popups) but no longer HTML encodes HTML links added manually such as images or tables
		</bugFixes>
	  <improvements>
	* Ogone and PaymentSense payment systems added
	  </improvements>
	</item>

	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.0001</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Tue, 26 Mar 2013 15:11:00 GMT</releaseDate>
	  <type>Minor</type>
	  <bugFixes>
	* Fixed problem creating new categories on some installs
	* Problem with popup for deleting customers fixed
	* Removed constraint for customer on orders table as was blocking bulk deletion of orders-related data (including with new data tool)
	  </bugFixes>
	  <improvements>
	* Added a general files uploader and manager to the Miscellaneous menu; useful for custom mods, changing images on front page jquery slideshow and so on
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>2</majorVersion>
	  <minorVersion>2.0000</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Sun, 24 Mar 2013 10:33:00 GMT</releaseDate>
	  <type>Recommended</type>
	  <bugFixes>
	* Fixed currency issue in main product search
	* Fixed white-space issue when saving payment gateway details
	* addtobasket config setting effect on multiple version products in dropdown view had no effect
	* Numeric ISO codes beginning with zero lose leading zero (due to being treated as number)
	* Fixed issue with CVV (security code) losing leading zero on some local payment gateways
	* Various other bug fixes
	  </bugFixes>
	  <improvements>
	* Fully open-source code
	* All triggers removed for improved performance and compatibility with the Microsoft Web App Gallery
	* HTML templates for emails (order confirmations, password reset, etc.)
	* New 'cancelled' order status, returns any items in order to stock
	* Added anti-spam bot test to contact form
	* Can view customer addresses from new 'addresses' tab when viewing a customer record
	* Improved password hashing for user and login accounts
	* New order/payment history tab with total balance for better snapshot of customer account and any overdue balance or refund.
	* Support ticket improvements, fixed various bugs and added 'tagging' system to aid keyword searching
	* Now using the ASP.NET AJAX HTML editor for simpler interface
	* Live currency rate lookup now uses feed from ECB (European Central Bank) feed, which includes all common European and non-European currencies
	* Object config system extended to versions (previously only available for products)
	* Back end image and media upload and handling improvements, back end images previews now properly thumbnailed
	* Error handling now more efficient, error pages self-contained to avoid possibility of 404 cascades
	* Front end search improved, now passes querystrings to Search.aspx page so can be invoked from external search box
	* Windows 8 live tile for order and support ticket notifications on Windows 8, Windows RT and Windows 8 Phone devices
	* Upgraded to latest AJAX toolkit
	  </improvements>
	</item>

	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.4004</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Sun, 28 Oct 2012 12:40:00 GMT</releaseDate>
	  <type>Minor</type>
	  <bugFixes>
	* Fixed VAT/tax error for overseas countries
	* Tax band menu not populated when creating new shipping method
	* Currency conversion didn't work properly on quantity discount prices
	  </bugFixes>
	  <improvements>
	* Now include Kartris version number (from DLL) in error logs
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.4003</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Sun, 8 Jul 2012 20:32:00 GMT</releaseDate>
	  <type>Minor</type>
	  <bugFixes>
	* Changed promotion string for % off category promotion (% off item in category)
	* Fixed problem with Buy 1 of items from category XXX, get 10% off from category YYY
	* Fixed problem deleting media files and associated db records
	* Checkout sending blank customer account email fixed
	* Basket shipping estimate errors if detects browser country not in active country list
	* Amount box doesn't show when editing coupons with % or fixed price discount
	* Admin 'edit this page' links now work on custom pages and kb pages with parametrized URLs
	* Decimal quantities of an item in the basket get broken if another item which doesn't support decimal quantities is added
	* Minor fixes to upgrade SQL scripts 
	  </bugFixes>
	  <improvements>
	* HTML editor updated to latest version, better Chrome compatibility
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.4002</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Sun, 3 Jun 2012 18:02:00 GMT</releaseDate>
	 <type>Minor</type>
	  <bugFixes>
	* Internal release
	  </bugFixes>
	  <improvements>
	* Internal release
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.4001</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Sun, 20 May 2012 13:44:00 GMT</releaseDate>
	  <type>Recommended</type>
	  <bugFixes>
	* No longer caches 'bad license' results caused if site is hit through alternative domain that also resolves to site
	* Gateways that require basket item info to be passed now works fine with user-default currency
	* Stock and quantity handling improvements
	* Various promotions fixes
	* Fixed order history back-two-steps error after clicking on product shortened view
	  </bugFixes>
	  <improvements>
	* ASP.NET 4.0 
	* Back end graphing
	* Object config system - framework for extended configuration of products
	* Can now set qty selector, unit-size and $POA at product level, rather than globally
	* Canada tax support (beta)
	* Tax/regional setup wizard in back end, simplifies setup for various tax regimes
	* Markup prices improved; can now mark up RRP and qty discounts
	* Support for setting specific option combination prices (rather than derive prices from selected options)
	* Support for completely custom product controls, configurators for items whose price depends on height/width, algorithms, web-services, spreadsheet lookups, etc.
	* Show support name in order summary
	* Shipping price estimate in basket (optional)
	* Option description shows under labels for each option
	* Logging option for callback page
	* Delete option groups and attributes
	* Support for HTML templates for payment gateways that support injecting HTML to success page (Worldpay, etc.)
	* Can now link a promotion and coupon together, where the coupon code triggers the promotion
	  </improvements>
	</item>

	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.4000</minorVersion>
	  <beta>True</beta>
	  <releaseDate>Tue, 3 Jan 2012 11:01:00 GMT</releaseDate>
	  <type>Minor</type>
	  <bugFixes>
	* Internal release
	  </bugFixes>
	  <improvements>
	* Internal release
	  </improvements>
	</item>
	   
	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.3008</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Tue, 21 Feb 2012 16:51:00 GMT</releaseDate>
	  <type>Minor</type>
	  <bugFixes>
	* Removed javascript links from short format items as browsers don't record history properly so 'back' button jumps back two pages
	* Other minor bug fixes
	  </bugFixes>
	  <improvements>
	* Minor stability improvements
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.3007</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Tue, 10 Jan 2012 13:57:00 GMT</releaseDate>
	  <type>Minor</type>
	  <bugFixes>
	* SQL files updated to include some missing items that caused options products not to add to basket
	* 1.3006-1.3007 update file to upgrade the SQL db of any affected 1.3006 site
	  </bugFixes>
	  <improvements>
	* Minor stability improvements
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.3006</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Fri, 2 Dec 2011 14:37:00 GMT</releaseDate>
	  <type>Minor</type>
	  <bugFixes>
	* _EditCategory.aspx.vb user control fix to category sorting caused some categories to fail to save when updating
	  </bugFixes>
	  <improvements>
	* 'frontend.products.display.fromprice' now has three options y/p/n (From X.XX, X.XX, no display)
	  </improvements>
	</item>

	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.3005</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Sun, 27 Nov 2011 11:26:00 GMT</releaseDate>
	  <type>Recommended</type>
	  <bugFixes>
	* Fixed feed and sitemap link bug
	* SagePay plugin was passing billing postcode to delivery field
	* Searching in 'all' mode didn't work with attribute values more than 10 chars
	* Back end linked to style sheets with http, even when running under https, triggering alert
	* Wrong version sometimes added to basket for combination products
	* Admin user level check fixed in some back end pages that were wrongly classified as to which admins could see them
	* Pressing 'enter' in popups goes to search page
	* Fixed featured products error
	* FTS enable/disable improved to detect if FTS not enabled
	* Clearing order all data (to remove test data before going live) removed product images
	* Checkout error if no payment system selected; added validator group back on to proceed button
	* Some promotion fixes and improvements
	* 'frontend.products.display.fromprice' didn't remove 'from' price
	* Dot (.) at end of category or product name in URL leads to ./ which causes 404
	* Fixed problem with assigning attributes with ID > 10
	* Fixed some US tax setup issues
	* HTML error (DIV in wrong place) causes problems if basket links are hidden (frontend.minibasket.hidelinks); adding options products doesn't work, adding subsequent products from multiple versions product fails
	  </bugFixes>
	  <improvements>
	* Can use Invoice.master optionally within a skin folder to style invoice
	* Version weight can be displayed in multiple version products
	* Delete for option groups and options
	* USPS shipping system upgraded to latest API
	* New type of attribute for Google Product feed (due to their recent changes), updated feed to pull these values
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.3004</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Tue, 9 Aug 2011 11:14:00 GMT</releaseDate>
	  <type>Recommended</type>
	  <bugFixes>
	* Various US tax issues
	* Various promotion fixes (some kinds of promotions were limited to one only)
	* Fixed newsletter confirmation mail at checkout issue
	* Confirmation stage at checkout said you'd opted in, even if you hadn't
	* Single quotes within support ticket text doubled
	* Subsequent version from one page added to basket goes in as quantity 1, regardless of selection
	  </bugFixes>
	  <improvements>
	* RRP now shown on single version products
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.3003</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Fri, 27 May 2011 14:52:00 GMT</releaseDate>
	  <type>Minor</type>
	  <bugFixes>
	  </bugFixes>
	  <improvements>
	* Minor changes requested by Microsoft; encryption key randomized, PO payment system turned on by default
	  </improvements>
	</item>

	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.3002</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Sun, 22 May 2011 17:11:00 GMT</releaseDate>
	  <type>Minor</type>
	  <bugFixes>
	* SagePay isssue fixed (updated SagePay DLL)
	  </bugFixes>
	  <improvements>
	* Minor performance improvements and minor fixes
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.3001</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Sun, 15 May 2011 17:37:00 GMT</releaseDate>
	  <type>Recommended</type>
	  <bugFixes>
	* Front end search paging fixed
	* Fixed checkout issue where if PO (offline payment) was only type it would not display PO number box
	* If frontend.users.mailinglist.enabled is off, checkbox to sign user up is disabled
	* Fixed date issue with KB articles in back end erroring on editing in some cases if back end language is not English
	  </bugFixes>
	  <improvements>
	* Refresh button for back end error log
	* Product images using ProductLinkTemplate for top sellers and newest items
	* Google feed now includes version code (SKU) from versions, and special use product attributes can be used to set other required Google Product Search values
	  </improvements>
	</item>

	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.3000</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Mon, 2 May 2011 13:21:00 GMT</releaseDate>
	  <type>Recommended</type>
	  <bugFixes>
	* Many minor bug fixes
	  </bugFixes>
	  <improvements>
	* Only lightweight core compiled; most source code now completely open
	* Category navigation menu can now be set to be CSS-fold-out, accordion or dropdown/select
	* Introduced beta functionality to edit orders and track over/underpayments that result
	* Improved skin structure - masterpages and theme combined
	* New Skin.config file allows custom skins per page, product, category, customer or customer group
	* Several new and improved skins
	* Numerous other minor improvements
	  </improvements>
	</item>

	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.2001</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Wed, 19 Jan 2011 10:45:00 GMT</releaseDate>
	  <type>Recommended</type>
	  <bugFixes>
	* Fixed issue where existing customers could not set different billing and shipping addresses
	* Fixed issue where shipping miscalculates as weight/cost setting is ignored
	* Fixed issues with the Googlebase/Froogle XML/RSS feed
	* Fixed some issues with promotions that use fixed amount values
	  </bugFixes>
	  <improvements>
	* Close/open site button now up on top left and visible while in front or back end when logged in as admin
	* Added image_link to Googlebase/Froogle feed
	  </improvements>
	</item>
	
	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.2000</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Wed, 3 Nov 2010 12:05:00 GMT</releaseDate>
	  <type>Recommended</type>
	  <bugFixes>
	* Fixed lots of minor performance issues
	  </bugFixes>
	  <improvements>
	* Added support for video, audio and multimedia download galleries for products and versions
	* Introduced real-time shipping support for UPS and USPS, with plugin framework to support further modules later
	* Shipping can be profiled so you can mix real-time shipping with banded shipping for different zones and weight ranges
	* Back-end usability re-design; full width, treeview navigation, movable splitter bar, submit/update buttons fixed above forms
	* Performance of image popups improved as launched by client-side javascript without postback
	* Improvements for multiple languages, especially RtL (right-to-left) ones such as Arabic and Hebrew
	  </improvements>
	</item>

	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.1009</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Thu, 12 Aug 2010 13:30:00 GMT</releaseDate>
	  <type>Minor</type>
	  <bugFixes>
	* Removed additional languages, which are incomplete
	* Fixed an issue updating some products resulting in timeout
	  </bugFixes>
	  <improvements>
	* Minor speed and stability improvements
	  </improvements>
	</item>

	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.1008</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Tue, 10 Aug 2010 13:57:00 GMT</releaseDate>
	  <type>Minor</type>
	  <bugFixes>
	* Some language session and switching issues
	* Few SSL related fixes
	* Search overflow issue fixed
	  </bugFixes>
	  <improvements>
	* Added 'notes' field to orders and customers
	* Can now set flag icons for language selection
	  </improvements>
	</item>

	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.1007</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Wed, 28 Jul 2010 10:27:00 GMT</releaseDate>
	  <type>Minor</type>
	  <bugFixes>
	* Fixed issue with long friendly URLs giving 'bad request' on some servers
	* Minor bug fixes
	  </bugFixes>
	  <improvements>
	* Added recently viewed product functionality
	* Added optional images for basket items
	* Themes and master pages selection in back end now puts available options in dropdowns
	  </improvements>
	</item>

	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.1006</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Mon, 19 Jul 2010 10:03:00 GMT</releaseDate>
	  <type>Minor</type>
	  <bugFixes>
	* Fixed issue creating new users in back end - support date expiry field was missing
	* Top 5 sproc now pulls 50, with config setting used to trim down to lower number
	* Fixed Greece to 'EL' (not ISO GR) in EU VAT web service
	* Fixed minor CSS issue with calendar control in IE8
	  </bugFixes>
	  <improvements>
	* O_Details field increased in DAL to 100,000 chars (from 50,000)
	  </improvements>
	</item>

	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.1005</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Mon, 28 Jun 2010 10:40:00 GMT</releaseDate>
	  <type>Recommended</type>
	  <bugFixes>
	  </bugFixes>
	  <improvements>
	* Support for installation using the Microsoft Web Platform Installer
	* Much improved setup/install routine
	* Friendly URLs changed to append .aspx; no longer need to set custom 404s manually for SEO friendly URLs as can be done from web.config
	  </improvements>
	</item>

	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.1004</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Thu, 24 Jun 2010 15:12:00 GMT</releaseDate>
	  <type>Minor</type>
	  <bugFixes>
	* Various minor fixes
	  </bugFixes>
	  <improvements>
	  </improvements>
	</item>

	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.1003</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Mon, 21 Jun 2010 09:42:00 GMT</releaseDate>
	  <type>Minor</type>
	  <bugFixes>
	* Various minor fixes
	  </bugFixes>
	  <improvements>
	  </improvements>
	</item>

	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.1002</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Thu, 17 Jun 2010 11:55:00 GMT</releaseDate>
	  <type>Minor</type>
	  <bugFixes>
	* Various minor fixes
	  </bugFixes>
	  <improvements>
	  </improvements>
	</item>

	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.1001</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Thu, 10 Jun 2010 15:15:00 GMT</releaseDate>
	  <type>Recommended</type>
	  <bugFixes>
	* Hide mailinglist at checkout if turned off in config settings
	* Fixed some more SSL issues
	* Order history would record % tax to nearest whole number in item summary
	* Fixed error editing promotion parts
	* Other minor fixes
	  </bugFixes>
	  <improvements>
	* Text customizations and options all now show in confirmation mails and back end order summary
	* 'From' price now takes lowest available price for this customer, including customer pricing and quantity discounts
	  </improvements>
	</item>

	<item>
	  <majorVersion>1</majorVersion>
	  <minorVersion>1.1000</minorVersion>
	  <beta>False</beta>
	  <releaseDate>Thu, 27 May 2010 13:05:00 GMT</releaseDate>
	  <type>Recommended</type>
	  <bugFixes>
	* Fixed various SSL related issues
	* Can now add same item to basket with different customizations without aggregating them
	* Customer group price now shows on the item
	* IsValidUserAgent routine improved so can handle spiders that don't provide it
	  </bugFixes>
	  <improvements>
	* Some field renaming in DB for consistency
	* Can now display minibasket in super-compact one line form
	* 'Powered by' link now XHTML compliant (inline CSS)
	* Text customizations can now be required or optional (set per item)
	* Support tickets system now supports expiry for 'premium' ticket types (for example, technical support)
	  </improvements>
	</item>
 
  </channel>
</rss>
