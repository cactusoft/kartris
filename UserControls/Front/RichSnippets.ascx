<%@ Control Language="VB" AutoEventWireup="false" CodeFile="RichSnippets.ascx.vb" Inherits="UserControls_Front_RichSnippets" %>
<%@ OutputCache Duration="3600" VaryByParam="*" VaryByCustom="culture" Shared="true" %>
<script type="application/ld+json">
{
  <asp:Literal ID="litProductMain" runat="server">"@context": "https://schema.org/",
  "@type": "Product",
  "name": "[product_name]",
  "description": "[product_desc]",
  "mpn": "[sku]",
  "sku": "[sku]",</asp:Literal><asp:Literal ID="litImage" runat="server">
  "image": [
	"[image_source]"
  ]</asp:Literal><asp:Literal ID="litReview" runat="server">,
  "aggregateRating": {
	"@type": "AggregateRating",
	"ratingValue": "[review_avg]",
	"reviewCount": "[review_total]"
  }</asp:Literal><asp:Literal ID="litOffer" runat="server">,
  "offers": {
	"@type": "Offer",
	"url": "[url]",
	"priceCurrency": "[currency]",
	"price": "[price]"
	}</asp:Literal>
  <asp:Literal ID="litOfferAggregate" runat="server">,
  "offers": {
	"@type": "AggregateOffer",
	"url": "[url]",
	"lowPrice": "[lowprice]",
	"highPrice": "[highprice]",
	"priceCurrency": "[currency]"
  }</asp:Literal>
}
</script>