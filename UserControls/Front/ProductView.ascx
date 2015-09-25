<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductView.ascx.vb"
    Inherits="ProductView" %>
<%@ Register TagPrefix="user" TagName="BreadCrumbTrail" Src="~/UserControls/Front/BreadCrumbTrail.ascx" %>
<%@ Register TagPrefix="user" TagName="CarryOnShopping" Src="~/UserControls/Front/CarryOnShopping.ascx" %>
<%@ Register TagPrefix="user" TagName="ProductAttributes" Src="~/UserControls/Front/ProductAttributes.ascx" %>
<%@ Register TagPrefix="user" TagName="ProductPromotions" Src="~/UserControls/Front/ProductPromotions.ascx" %>
<%@ Register TagPrefix="user" TagName="ProductQuantityDiscounts" Src="~/UserControls/Front/ProductQuantityDiscounts.ascx" %>
<%@ Register TagPrefix="user" TagName="ProductReviews" Src="~/UserControls/Front/ProductReviews.ascx" %>
<%@ Register TagPrefix="user" TagName="RichSnippets" Src="~/UserControls/Front/RichSnippets.ascx" %>
<%@ Register TagPrefix="user" TagName="ProductVersions" Src="~/UserControls/Other/ProductVersions.ascx" %>
<script type="text/javascript" language="javascript">
    //<![CDATA[

    //Function to set URL for iframe of media popup, size it, and show it
    function ShowMediaPopup(ML_ID, MT_Extension, intParentID, strParentType, intWidth, intHeight) {
        //Set some variables we use later
        var objFrame = $find('cntMain_UC_ProductView_tbcProduct_tabMain_UC_PopUpMedia_popMessage');

        var objMediaIframeBaseUrl = document.getElementById('media_iframe_base_url').value;
        var objPopupWindow = document.getElementById('cntMain_UC_ProductView_tbcProduct_tabMain_UC_PopUpMedia_pnlMessage');
        var objMediaIframe = document.getElementById('media_iframe');
        //Set media ID
        objMediaIframe.src = objMediaIframeBaseUrl + "?ML_ID=" + ML_ID;
        //Set parent ID
        objMediaIframe.src = objMediaIframe.src + "&intParentID=" + intParentID;
        //Set parent type
        objMediaIframe.src = objMediaIframe.src + "&strParentType=" + strParentType;
        //Set file type
        objMediaIframe.src = objMediaIframe.src + "&MT_Extension=" + MT_Extension;
        //Size popup dynamically based on file type
        //If 999 width, we make full screen
        if (intWidth == '999')
        {
            objPopupWindow.style.width = "100%";
            objPopupWindow.style.height = "100%";
            objPopupWindow.className += ' popup_media';
        }
        else
        {
        objPopupWindow.style.width = (intWidth * 1 + 20) + "px";
        objPopupWindow.style.height = (intHeight * 1 + 15) + "px";
        objPopupWindow.className = 'popup';
        }
        //Show the popup
        objFrame.show();
    }

    //Function to set URL for iframe of media popup, size it, and show it
    function ShowURLPopup(ML_EmbedSource, intWidth, intHeight) {
        //Set some variables we use later
        var objFrame = $find('cntMain_UC_ProductView_tbcProduct_tabMain_UC_PopUpMedia_popMessage');

        var objMediaIframeBaseUrl = ML_EmbedSource;
        var objPopupWindow = document.getElementById('cntMain_UC_ProductView_tbcProduct_tabMain_UC_PopUpMedia_pnlMessage');
        var objMediaIframe = document.getElementById('media_iframe');

        //Set target URL
        objMediaIframe.src = objMediaIframeBaseUrl;

        //Size popup dynamically based on file type
        objPopupWindow.style.width = (intWidth * 1 + 20) + "px";
        objPopupWindow.style.height = (intHeight * 1 + 15) + "px";
        //Show the popup
        objFrame.show();
    }
    //]]>
</script>

<div class="product">
    <user:BreadCrumbTrail ID="UC_BreadCrumbTrail" runat="server" EnableViewState="False" SiteMapProvider="CategorySiteMapProvider" />
    <h1>
        <asp:Literal ID="litProductName" runat="server"></asp:Literal></h1>
    <asp:UpdatePanel ID="updProduct" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <ajaxToolkit:TabContainer CssClass=".tab" ID="tbcProduct" runat="server" OnDemand="false" OnClientActiveTabChanged="" AutoPostBack="false" EnableTheming="False">
                <%--
                =====================================
                TAB 1 - Main product details
                =====================================
                --%>
                <ajaxToolkit:TabPanel ID="tabMain" runat="server" OnDemandMode="Once">
                    <HeaderTemplate>
                        <asp:Literal ID="litContentTextHome" runat="server" Text="<%$ Resources: Kartris, ContentText_Home %>" EnableViewState="false"></asp:Literal>
                    </HeaderTemplate>
                    <ContentTemplate>
                        <div class="row">
                                        <%--
                    IMAGE COLUMN
                                        --%>
                            <div class="imagecolumn small-12 large-4 columns">
                                <asp:UpdatePanel ID="updImages" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <user:ImageViewer ID="UC_ImageView2" runat="server" LargeViewClickable="false" EnableViewState="false" />
                                        <asp:PlaceHolder ID="phdImageColumn" runat="server">
                                            <user:ImageViewer ID="UC_ImageView" runat="server" LargeViewClickable="true" EnableViewState="false" />
                                        </asp:PlaceHolder>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                                <asp:UpdatePanel ID="updMedia" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <%--
                    MEDIA GALLERY
                                        --%>
                                        <user:PopupMessage ID="UC_PopUpMedia" runat="server" EnableViewState="false" />
                                        <user:MediaGallery ID="UC_MediaGallery" ParentType="p" runat="server" EnableViewState="false" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                                        <%--
                    TEXT COLUMN
                                        --%>
                            <div class="textcolumn small-12 large-8 columns">
                                <asp:FormView ID="fvwProduct" runat="server">
                                    <HeaderTemplate>
                                        <asp:Literal ID="litProductID" runat="server" Visible="false" Text='<%# Eval("P_ID") %>'></asp:Literal>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <div id="strapline">
                                            <asp:Literal ID="litProductStrapLine" runat="server" Text='<%# Eval("P_StrapLine") %>' EnableViewState="false"></asp:Literal>
                                        </div>
                                        <div id="description" itemscope itemtype="http://data-vocabulary.org/Product">
                                            <span itemprop="name" style="display: none;"><%# Eval("P_Name") %></span>
                                            <user:RichSnippets ID="UC_RichSnippets" runat="server" ProductID='<%# Eval("P_ID") %>' />
                                            <span itemprop="description">
                                                <asp:Literal EnableViewState="False" ID="litProductDescription" runat="server" Text='<%# ShowLineBreaks(Eval("P_Desc")) %>'></asp:Literal>
                                            </span>
                                        </div>
                                        <%--
                                        COMPARE LINK
                                        --%>
                                        <asp:PlaceHolder ID="phdCompareLink" runat="server">
                                            <div id="comparelink">
                                                <asp:HyperLink CssClass="link2" ID="lnkCompare" runat="server" Text="<%$ Resources:Products,ContentText_ViewCompareLink %>" EnableViewState="false" />
                                            </div>
                                        </asp:PlaceHolder>

                                    </ItemTemplate>
                                </asp:FormView>
                                <user:ProductVersions ID="UC_ProductVersions"
                                    runat="server" EnableViewState="true" />

                            </div>
                        </div>
                        <div class="spacer"></div>
                        <%--
                        VERSIONS/OPTIONS
                        --%>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <%--
                =====================================
                TAB 2 - Attributes
                =====================================
                --%>
                <ajaxToolkit:TabPanel runat="server" ID="tabAttributes" OnDemandMode="Once">
                    <HeaderTemplate>
                        <asp:Literal ID="litContentTextAttributes" runat="server" Text="<%$ Resources:Attributes, ContentText_Attributes %>" EnableViewState="false"></asp:Literal>
                    </HeaderTemplate>
                    <ContentTemplate>
                        <user:ProductAttributes ID="UC_ProductAttributes" runat="server" EnableViewState="false" />
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <%--
                =====================================
                TAB 3 - Quantity Discounts
                =====================================
                --%>
                <ajaxToolkit:TabPanel runat="server" ID="tabQuantityDiscounts" OnDemandMode="Once">
                    <HeaderTemplate>
                        <asp:Literal ID="litContentTextViewQuantityDiscount" runat="server" Text="<%$ Resources: Versions, ContentText_ViewQuantityDiscount %>" EnableViewState="false"></asp:Literal>
                    </HeaderTemplate>
                    <ContentTemplate>
                        <user:ProductQuantityDiscounts ID="UC_QuantityDiscounts" runat="server" EnableViewState="false" />
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <%--
                =====================================
                TAB 4 - Reviews
                =====================================
                --%>
                <ajaxToolkit:TabPanel runat="server" ID="tabReviews" OnDemandMode="Once">
                    <HeaderTemplate>
                        <asp:Literal ID="litContentTextCustomerReviews" runat="server" Text="<%$ Resources:Reviews, ContentText_CustomerReviews %>" EnableViewState="false"></asp:Literal>
                    </HeaderTemplate>
                    <ContentTemplate>
                        <asp:UpdatePanel ID="updReviews" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <user:ProductReviews ID="UC_Reviews" runat="server" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
            </ajaxToolkit:TabContainer>
            <div class="spacer">
            </div>
            <%--
                =====================================
                PROMOTIONS
                =====================================
            --%>
            <user:ProductPromotions ID="UC_Promotions" runat="server" PageOwner="Product.aspx" EnableViewState="false" />
            <div class="spacer">
            </div>
            <%--
                =====================================
                CARRY ON SHOPPING
                =====================================
            --%>
            <user:CarryOnShopping ID="UC_CarryOnShopping" runat="server" EnableViewState="false" />
            <asp:Image ID="imgProductHidden" runat="server" Visible="false" />
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
