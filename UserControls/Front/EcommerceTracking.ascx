<%@ Control Language="VB" AutoEventWireup="false" CodeFile="EcommerceTracking.ascx.vb" Inherits="UserControls_Front_EcommerceTracking" %>
<asp:PlaceHolder ID="phdEcommerceTracking" runat="server">
<!--
Kartris Google Analytics Ecommerce Tracking
See UserControls/Front/EcommerceTracking.ascx to make
changes to the javascript
-->
<asp:HiddenField ID="hidCurrencyID" runat="server" />
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<asp:Literal ID="litGoogleWebPropertyID" runat="server" />']);
  _gaq.push(['_trackPageview']);
  _gaq.push(['_addTrans',
    '<asp:Literal ID="litOrderID" runat="server" />',           // order ID - required
    '<asp:Literal ID="litWebShopName" runat="server" />',  // affiliation or store name
    '<asp:Literal ID="litTotal" runat="server" />',          // total - required
    '<asp:Literal ID="litTax" runat="server" />',           // tax
    '<asp:Literal ID="litShipping" runat="server" />'              // shipping
  ]);

   // add item might be called for every item in the shopping cart
   // where your ecommerce engine loops through each item in the cart and
   // prints out _addItem for each 

<asp:Repeater ID="rptOrderItems" runat="server">
<ItemTemplate>
   
  _gaq.push(['_addItem',
    '<asp:Literal ID="litOrderID" runat="server" />',           // order ID - required
    '<asp:Literal ID="litVersionCode" runat="server" />',           // SKU/code
    '<asp:Literal ID="litItemName" runat="server" />',        // product name
    '<asp:Literal ID="litItemOptions" runat="server" />',   // category or variation
    '<asp:Literal ID="litItemPrice" runat="server" />',          // unit price - required
    '<asp:Literal ID="litItemQuantity" runat="server" />'               // quantity - required
  ]);
  
</ItemTemplate>
</asp:Repeater>  

  _gaq.push(['_trackTrans']); //submits transaction to the Analytics servers

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(ga);
  })();

</script>
</asp:PlaceHolder>