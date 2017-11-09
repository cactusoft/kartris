<%@ Control Language="VB" AutoEventWireup="false" CodeFile="BreadCrumbTrail.ascx.vb" Inherits="BreadCrumbTrail" %>
<div class="breadcrumbtrail">
    <asp:SiteMapPath ID="smpTrail" PathSeparator="<% $Resources: Kartris, ContentText_BreadcrumbSeparator %>"
        runat="server" SiteMapProvider="BreadCrumbSiteMap" />

</div>
<% If Request.Url.ToString.ToLower.Contains("product.aspx") Then %>
<script>
    $('div.breadcrumbtrail span span:nth-last-child(4) a[href*="__c-p-"]').attr('href', 'javascript:window.location=document.referrer;')
</script>
<% End if %>
