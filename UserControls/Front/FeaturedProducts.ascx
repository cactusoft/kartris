<%@ Control Language="VB" AutoEventWireup="false" CodeFile="FeaturedProducts.ascx.vb"
    Inherits="UserControls_Skin_FeaturedProducts" %>
<%@ Register TagPrefix="user" TagName="ItemPager" Src="~/UserControls/Front/ItemPager.ascx" %>
<%@ Register TagPrefix="user" TagName="CarouselItem" Src="~/UserControls/Templates/ProductTemplateFeaturedCarousel.ascx" %>
<div id="featuredproducts">
    <h2 class="blockheader">
        <span><span>
            <asp:Literal ID="litContentTextFeaturedProducts" runat="server" Text='<%$ Resources: Kartris, ContentText_FeaturedProducts %>' /></span></span></h2>
    <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <user:ItemPager ID="UC_ItemPager_Header" runat="server" Visible="False" />
            <asp:MultiView ID="mvwFeaturedProducts" runat="server" ActiveViewIndex="0">
                <!-- products normal -->
                <asp:View ID="viwNormal" runat="server">
                    <div class="products products_normal">
                        <asp:Repeater ID="rptNormal" runat="server">
                            <ItemTemplate>
                                <user:ProductTemplateNormal ID="UC_ProductNormal" runat="server" />
                            </ItemTemplate>
                            <SeparatorTemplate>
                            </SeparatorTemplate>
                        </asp:Repeater>
                    </div>
                </asp:View>
                <!-- products extended -->
                <asp:View ID="viwExtended" runat="server">
                    <div class="products products_extended">
                        <asp:Repeater ID="rptExtended" runat="server">
                            <ItemTemplate>
                                <asp:UpdatePanel ID="updProductsExtended" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <user:ProductTemplateExtended ID="UC_ProductExtended" runat="server" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </ItemTemplate>
                            <SeparatorTemplate>
                            </SeparatorTemplate>
                        </asp:Repeater>
                    </div>
                </asp:View>
                <!-- products shortened -->
                <asp:View ID="viwShortened" runat="server">
                    <div class="products products_shortened">
                        <asp:Repeater ID="rptShortened" runat="server">
                            <ItemTemplate>
                                <user:ProductTemplateShortened ID="UC_ProductShortened" runat="server" />
                            </ItemTemplate>
                            <SeparatorTemplate>
                            </SeparatorTemplate>
                        </asp:Repeater>
                    </div>
                </asp:View>
                <!-- products tabular -->
                <asp:View ID="viwTabular" runat="server">
                    <div class="products products_tabular">
                        <asp:Repeater ID="rptTabular" runat="server">
                            <ItemTemplate>
                                <user:ProductTemplateTabular ID="UC_ProductTabular" runat="server" />
                            </ItemTemplate>
                            <SeparatorTemplate>
                            </SeparatorTemplate>
                        </asp:Repeater>
                    </div>
                </asp:View>
                <!-- carousel item -->
                <asp:View ID="viwCarousel" runat="server">
                    <asp:Repeater ID="rptCarousel" runat="server">
                        <ItemTemplate>
                            <div class="products_carousel">
                                <user:ProductTemplateShortened ID="UC_ProductShortened2" runat="server" />
                            </div>
                        </ItemTemplate>
                        <SeparatorTemplate>
                        </SeparatorTemplate>
                    </asp:Repeater>
                </asp:View>
            </asp:MultiView>
            <div class="spacer">
            </div>
            <user:ItemPager ID="UC_ItemPager_Footer" runat="server" Visible="False" />
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
<div class="spacer"></div>
