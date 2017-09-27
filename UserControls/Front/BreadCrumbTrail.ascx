<%@ Control Language="VB" AutoEventWireup="false" CodeFile="BreadCrumbTrail.ascx.vb" Inherits="BreadCrumbTrail" %>
<div class="breadcrumbtrail">
    <asp:SiteMapPath ID="smpTrail" PathSeparator="<% $Resources: Kartris, ContentText_BreadcrumbSeparator %>"
        runat="server" SiteMapProvider="BreadCrumbSiteMap" />

</div>
<script>
    $('div.breadcrumbtrail span span:nth-last-child(4) a[href*="__c-p-"]').attr('href', 'javascript:window.location=document.referrer;')
</script>
