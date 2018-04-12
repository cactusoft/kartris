<%@ Control Language="VB" AutoEventWireup="false" CodeFile="SiteLinksSearch.ascx.vb" Inherits="UserControls_Front_SiteLinksSearch" %>
<script type="application/ld+json">
{
  "@context": "http://schema.org",
  "@type": "WebSite",
  "url": "<% =CkartrisBLL.WebShopURL.ToLower %>",
  "potentialAction": {
    "@type": "SearchAction",
    "target": "<% =CkartrisBLL.WebShopURL.ToLower %>Search.aspx?strSearchText={search_term_string}",
    "query-input": "required name=search_term_string"
  }
}
</script>
