<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductTemplateExtended.ascx.vb"
    Inherits="ProductTemplateExtended" %>
<!-- product extended template start -->
<div class="item">
    <div class="box">
        <div class="pad row">
            <asp:Literal ID="litProductID" runat="server" Visible="false" Text='<%# Eval("P_ID") %>'></asp:Literal>
            <div class="imageblock small-12 medium-4 large-3 columns">
                <user:ImageViewer ID="UC_ImageView" runat="server" EnableViewState="False" />
            </div>
            <div class="details small-12 medium-8 large-9 columns">
                <h2>
                    <asp:HyperLink ID="lnkProductName" runat="server" NavigateUrl='<%# Eval("P_ID", "~/Product.aspx?ProductID={0}") %>'
                        Text='<%# Server.HtmlEncode(Eval("P_Name")) %>'></asp:HyperLink></h2>
                <em class="strapline">
                    <asp:Literal ID="litStrapLine" runat="server" Text='<%#Eval("P_StrapLine")%>'></asp:Literal></em>
                <p class="description">
                    <asp:Literal ID="litProductDesc" runat="server" Text='<%# CkartrisDisplayFunctions.TruncateDescription(Eval("P_Desc"), KartSettingsManager.GetKartConfig("frontend.products.display.truncatedescription")) %>'></asp:Literal>
                </p>
                <asp:HyperLink ID="lnknMore" runat="server" NavigateUrl='<%# Eval("P_ID", "~/Product.aspx?ProductID={0}") %>'
                    Text="<%$ Resources:Products,ContentText_ViewProductMoreDetail %>" CssClass="link2"></asp:HyperLink>


                <asp:PlaceHolder ID="phdMinPrice" runat="server" Visible="false">
                    <div class="minprice" id="divPrice" runat="server" visible='<%# Iif( ObjectConfigBLL.GetValue("K:product.callforprice", Eval("P_ID")) = 1 OrElse Not String.IsNullOrEmpty(ObjectConfigBLL.GetValue("K:product.customcontrolname", Eval("P_ID"))), False, True) %>'>
                        <asp:Literal ID="litPrice" runat="server" Text='<%# Eval("MinPrice") %>' Visible="false" />
                        <asp:Literal ID="litTaxRateHidden" runat="server" Text='<%# Eval("MinTaxRate") %>'
                            Visible="false" />
                    </div>
                </asp:PlaceHolder>
                <asp:Literal ID="litVersionsViewType" runat="server" Text='<%# Eval("P_VersionDisplayType") %>'
                    Visible="false"></asp:Literal>
                <asp:UpdatePanel ID="updProductVersions" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <user:ProductVersions ID="UC_ProductVersions" runat="server" ShowMediaGallery="False" />
                    </ContentTemplate>
                </asp:UpdatePanel>

            </div>

        </div>
    </div>
</div>
<!-- product extended template end -->

