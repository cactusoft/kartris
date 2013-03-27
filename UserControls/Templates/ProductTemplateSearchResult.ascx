<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductTemplateSearchResult.ascx.vb"
    Inherits="Templates_ProductTemplateSearchResult" %>
<div class="products_classicsearch">
    <asp:UpdatePanel ID="updSearch" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:Repeater ID="rptSearchResult" runat="server">
                <ItemTemplate>
                    <!-- product search results template start -->
                    <div class="item">
                        <div class="box">
                            <div class="pad">
                                <asp:Literal EnableViewState="false" ID="litProductID" runat="server" Visible="false" Text='<%# Eval("P_ID") %>'></asp:Literal>
                                <div class="imageblock">
                                    <user:ImageViewer ID="UC_ImageView" runat="server" EnableViewState="False" />
                                </div>
                                <div class="details">
                                    <h2>
                                        <asp:HyperLink EnableViewState="false" ID="lnkProductName" runat="server" NavigateUrl='<%# Eval("P_ID", "~/Product.aspx?ProductID={0}") %>'
                                            Text='<% DisplayProductName() %>' />
                                    </h2>
                                    <%--<em class="strapline">
                                            <asp:Literal ID="litStrapLine" runat="server" Text='<%# Eval("P_StrapLine") %>'></asp:Literal></em>--%>
                                    <asp:Literal EnableViewState="false" ID="litProductDesc" runat="server" Text='<%# Eval("P_Desc") %>'></asp:Literal>
                                    <div class="minprice">
                                        <asp:Literal EnableViewState="false" ID="litPriceFrom" runat="server" Text="<%$ Resources:Products,ContentText_ProductPriceFrom %>"></asp:Literal>
                                        <asp:Literal EnableViewState="false" ID="litPriceHidden" runat="server" Text='<%# Eval("MinPrice") %>' Visible="false" />
                                        <asp:Literal EnableViewState="false" ID="litPriceView" runat="server" />
                                    </div>
                                </div>
                                <div class="spacer"></div>
                            </div>
                        </div>
                    </div>
                    <!-- product search results template end -->
                </ItemTemplate>
            </asp:Repeater>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>

