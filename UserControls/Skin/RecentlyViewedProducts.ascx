<%@ Control Language="VB" AutoEventWireup="false" CodeFile="RecentlyViewedProducts.ascx.vb"
    Inherits="UserControls_Skin_RecentlyViewedProducts" %>
<div id="recentlyviewed">
    <h4>
        <asp:Literal ID="litContentTextRecentlyViewedProducts" runat="server" Text="<%$ Resources: Kartris, ContentText_RecentlyViewedProducts %>" /></h4>
    <%  If KartSettingsManager.GetKartConfig("frontend.display.recentproducts.display") = "t" Then%>
    <ul>
        <% Else%><div class="infoblock_pad">
            <div class="products_imageonly">
                <% End If%>
                <asp:Repeater ID="rptRecentViewedProducts" runat="server">
                    <ItemTemplate>
                        <% If KartSettingsManager.GetKartConfig("frontend.display.recentproducts.display") = "t" Then%>
                        <li>
                            <asp:HyperLink ID="lnkRecentlyViewed" runat="server" Text='<%# Eval("P_Name") %>'></asp:HyperLink></li>
                        <% Else%>
                        <user:ProductTemplateImageOnly ID="UC_ProductTemplateImageOnly" runat="server" />
                        <% End If%>
                    </ItemTemplate>
                </asp:Repeater>
                <% If KartSettingsManager.GetKartConfig("frontend.display.recentproducts.display") = "t" Then%>
    </ul>
    <%  Else%>
</div>
</div>
<%  End If%>
<div class="spacer">
</div>
</div>
<!--
this space below is needed for IE7!
It misses out the h4 tag above otherwise!(!)
-->
&nbsp; 