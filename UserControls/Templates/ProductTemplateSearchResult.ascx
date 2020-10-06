<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductTemplateSearchResult.ascx.vb"
    Inherits="Templates_ProductTemplateSearchResult" %>
<div class="products_classicsearch">

    <asp:Repeater ID="rptSearchResult" runat="server">
        <ItemTemplate>
            <!-- product search results template start -->
            <div class="item loadspinner">
                <div class="box">
                    <div class="pad">
                        <asp:Literal ID="litProductID" runat="server" Visible="false" Text='<%# Eval("P_ID") %>'></asp:Literal>
                        <div class="imageblock">
                            <user:ImageViewer ID="UC_ImageView" runat="server" EnableViewState="False" />
                        </div>
                        <div class="details">
                            <h2>
                                <asp:HyperLink ID="lnkProductName" runat="server" NavigateUrl='<%# Eval("P_ID", "~/Product.aspx?ProductID={0}") %>'
                                    Text='<%# DisplayProductName() %>' />
                            </h2>
                            <asp:Literal ID="litProductDesc" runat="server" Text='<%# Eval("P_Desc") %>'></asp:Literal>
                            <div class="minprice">
                                <asp:Literal ID="litPriceFrom" runat="server" Text="<%$ Resources:Products,ContentText_ProductPriceFrom %>"></asp:Literal>
                                <asp:Literal ID="litPriceHidden" runat="server" Text='<%# Eval("MinPrice") %>' Visible="false" />
                                <asp:Literal ID="litPriceView" runat="server" />
                            </div>
                        </div>
                        <div class="spacer"></div>
                    </div>
                </div>
            </div>
            <!-- product search results template end -->
        </ItemTemplate>
    </asp:Repeater>

</div>

