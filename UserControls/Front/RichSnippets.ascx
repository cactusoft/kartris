<%@ Control Language="VB" AutoEventWireup="false" CodeFile="RichSnippets.ascx.vb" Inherits="UserControls_Front_RichSnippets" %>

<script type="application/ld+json">
{
  <asp:Literal ID="litProductMain" runat="server">"@context": "http://schema.org/",
  "@type": "Product",
  "name": "[product_name]",
  "description": "[product_desc]",
  "mpn": "[sku]",</asp:Literal>
  <asp:Literal ID="litImage" runat="server">"image": "[image_source]",</asp:Literal>
  <asp:Literal ID="litReview" runat="server">"aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "[review_avg]",
    "reviewCount": "[review_total]"
  },</asp:Literal>
  "offers": {
  <asp:Literal ID="litOffer" runat="server">"@type": "Offer",
    "priceCurrency": "[currency]",
    "price": "[price]"
    </asp:Literal><asp:Literal ID="litOfferAggregate" runat="server">"@type": "AggregateOffer",
    "lowPrice": "[lowprice]",
    "highPrice": "[highprice]",
    "priceCurrency": "[currency]"
  </asp:Literal>}
}
</script>
