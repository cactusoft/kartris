<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_ModifyProduct.aspx.vb"
    Inherits="Admin_ModifyProduct" MasterPageFile="~/Skins/Admin/Template.master" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <asp:HyperLink ID="lnkBack" runat="server" Text="<%$ Resources:_Kartris, ContentText_BackLink %>"
        CssClass="floatright linkbutton icon_back" NavigateUrl="javascript:history.back()"></asp:HyperLink>
    <h1>
        <asp:Literal ID="litBackMenuProducts" runat="server" Text="<%$ Resources: _Kartris, BackMenu_Products %>"></asp:Literal>:
        <span class="h1_light">
            <asp:Literal ID="litProductName" runat="server"></asp:Literal></span></h1>

    <asp:PlaceHolder ID="phdBreadCrumbTrail" runat="server">
        <div class="breadcrumbtrail">
            <asp:SiteMapPath ID="smpMain" PathSeparator="&nbsp;" SiteMapProvider="_CategorySiteMapProvider"
                runat="server" />
        </div>
    </asp:PlaceHolder>

    <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <_user:ItemIndicator ID="_UC_ProductIndicator" runat="server" />
            <asp:Literal ID="litProductID" runat="server" Visible="false"></asp:Literal>
            <%-- We could use an AJAX tab control, but we found that very slow
            as the resulting page ends up huge. So better to break things up
            with a multiview instead --%>
            <%----%>
            <asp:Panel class="mvw__tab_default" runat="server" ID="pnlTabStrip">

                <asp:HyperLink ID="lnkMainInfo" runat="server" Text="<%$ Resources:_Product, FormLabel_TabProductInformation %>" /><asp:HyperLink
                    ID="lnkImages" runat="server" Text="<%$ Resources:_Product, FormLabel_TabProductImages %>" /><asp:HyperLink
                        ID="lnkMedia" runat="server" Text="<%$ Resources:_Product, FormLabel_TabProductMedia %>" /><asp:HyperLink
                            ID="lnkAttributes" runat="server" Text="<%$ Resources:_Product, FormLabel_TabProductAttributes %>" /><asp:HyperLink
                                ID="lnkReviews" runat="server" Text="<%$ Resources:_Product, FormLabel_TabProductReviews %>" /><asp:HyperLink
                                    ID="lnkRelatedProducts" runat="server" Text="<%$ Resources:_Product, FormLabel_TabProductRelatedProducts %>" /><asp:HyperLink
                                        ID="lnkProductVersions" runat="server" Text="<%$ Resources:_Product, FormLabel_TabProductVersions %>" /><asp:HyperLink
                                            ID="lnkOptions" runat="server" Text="<%$ Resources:_Product, FormLabel_TabProductOptions %>" /><asp:HyperLink
                                                ID="lnkObjectConfig" runat="server" Text="<%$ Resources:_Kartris, ContentText_ObjectConfig %>" />
            </asp:Panel>
            <%----%>
            <asp:MultiView ID="mvwEditProduct" runat="server" ActiveViewIndex="0">
                <%-- Product Main Info. Tab --%>
                <asp:View runat="server" ID="tabMainInfo">
                    <_user:EditProduct ID="_UC_EditProduct" runat="server" />
                </asp:View>
                <%-- Product Images Tab (Uploader) --%>
                <asp:View runat="server" ID="tabImages">
                    <div class="subtabsection">
                        <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=9837')" style="margin-bottom: 20px;">?</a>
                        <_user:FileUploader ID="_UC_Uploader" AllowMultiple="true" runat="server" />
                    </div>
                </asp:View>
                <asp:View runat="server" ID="tabMedia">
                    <div class="subtabsection">
                        <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=9838')" style="margin-bottom: 20px;">?</a>
                        <_user:EditMedia ID="_UC_EditMedia" runat="server" />
                    </div>
                </asp:View>
                <%-- Product Attributes Tab --%>
                <asp:View runat="server" ID="tabAttributes">
                    <div class="subtabsection">
                        <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=9842')" style="margin-bottom: 20px;">?</a>
                        <_user:ProductAttributes ID="_UC_ProductAttributes" runat="server" />
                    </div>
                </asp:View>
                <%-- Product Customer Reviews Tab --%>
                <asp:View runat="server" ID="tabReviews">
                    <div class="subtabsection">
                        <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=10154')" style="margin-bottom: 20px;">?</a>
                        <_user:ProductReviews ID="_UC_ProductReview" runat="server" />
                    </div>
                </asp:View>
                <%-- Related Products Tab --%>
                <asp:View runat="server" ID="tabRelatedProducts">
                    <div class="subtabsection">
                        <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=9843')" style="margin-bottom: 20px;">?</a>
                        <_user:RelatedProducts ID="_UC_RelatedProducts" runat="server" />
                    </div>
                </asp:View>
                <%-- Product Versions --%>
                <asp:View runat="server" ID="tabProductVersions">
                    <_user:VersionView ID="_UC_VersionView" runat="server" />
                </asp:View>
                <%-- Product Options Tab --%>
                <asp:View runat="server" ID="tabOptions">
                    <div class="section_options">
                        <_user:ProductOptionGroups ID="_UC_ProductOptionGroups" runat="server" />
                    </div>
                </asp:View>
                <%-- Object Config Tab --%>
                <asp:View runat="server" ID="tabObjectConfig">
                    <div class="subtabsection">
                        <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=9996')" style="margin-bottom: 20px;">?</a>
                        <_user:ObjectConfig ID="_UC_ObjectConfig" runat="server" ItemType="Product" />
                    </div>
                </asp:View>
            </asp:MultiView>
        </ContentTemplate>
    </asp:UpdatePanel>
    <asp:UpdateProgress ID="prgMain" runat="server" AssociatedUpdatePanelID="updMain">
        <ProgressTemplate>
            <div class="loadingimage">
            </div>
            <div class="updateprogress">
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>
</asp:Content>
