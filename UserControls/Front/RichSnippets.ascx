<%@ Control Language="VB" AutoEventWireup="false" CodeFile="RichSnippets.ascx.vb" Inherits="UserControls_Front_RichSnippets" %>

<div  style="display: none;">
    
    <asp:Literal ID="litProductMain" runat="server">
        <span itemprop="identifier" content="sku:[sku]">[sku]</span>
        <span itemprop="category" content="[category]"></span>
    </asp:Literal>

    <asp:Literal ID="litImage" runat="server">
        <img itemprop="image" src="[image_source]" alt="" />
    </asp:Literal>

    <asp:Literal ID="litReview" runat="server">
        <span itemprop="review" itemscope itemtype="http://data-vocabulary.org/Review-aggregate">
            <span itemprop="rating">[review_avg]</span><span itemprop="count">[review_total]
            </span>
        </span>
    </asp:Literal>

    <asp:Literal ID="litOffer" runat="server">
        <span itemprop="offerDetails" itemscope itemtype="http://data-vocabulary.org/Offer">
            <meta itemprop="currency" content="[currency]" />
            <span itemprop="price">[price]</span>
        </span>
    </asp:Literal>

    <asp:Literal ID="litOfferAggregate" runat="server">
        <span itemprop="offerDetails" itemscope itemtype="http://data-vocabulary.org/Offer-aggregate">
            <meta itemprop="currency" content="[currency]" />
            <span itemprop="lowPrice">[lowprice]</span>
            <span itemprop="highPrice">[highprice]</span>
        </span>
    </asp:Literal>


</div>
