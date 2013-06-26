<%@ Control Language="VB" AutoEventWireup="false" CodeFile="CarryOnShopping.ascx.vb"
    Inherits="CarryOnShopping" %>
<%@ OutputCache Duration="300" Shared="true" VaryByCustom="culture;user" VaryByParam="*" %>
<div class="section carryonshopping">
    <div class="pad">
        <h4>
            <asp:Literal ID="litCarryOnShoppingHeader" runat="server"></asp:Literal></h4>
    </div>
    <div>
        <!-- Related products -->
        <asp:PlaceHolder ID="phdRelatedProducts" runat="server" Visible="false">
            <h3>
                <asp:Literal ID="litRelatedProducts" runat="server" Text="<%$ Resources:Products, ContentText_RelatedProducts %>"></asp:Literal></h3>
            <div class="products products_tabular">
                <asp:Repeater ID="rptRelatedProducts" runat="server">
                    <ItemTemplate>
                        <user:ProductLinkTemplate ID="UC_ProductLink" runat="server" />
                    </ItemTemplate>
                    <SeparatorTemplate>
                    </SeparatorTemplate>
                </asp:Repeater>
            </div>
            <div class="spacer">
            </div>
        </asp:PlaceHolder>
        <!-- People who bought this -->
        <asp:PlaceHolder ID="phdPeopleWhoBoughtThis" runat="server" Visible="false">
            <h3>
                <asp:Literal ID="litPeopleWhoBoughtThis" runat="server" Text="<%$ Resources:Products, ContentText_PeopleWhoBought %>"></asp:Literal></h3>
            <div class="products products_tabular">
                <asp:Repeater ID="rptPeopleWhoBoughtThis" runat="server">
                    <ItemTemplate>
                        <user:ProductLinkTemplate ID="UC_ProductLinkPeople" runat="server" />
                    </ItemTemplate>
                    <SeparatorTemplate>
                    </SeparatorTemplate>
                </asp:Repeater>
            </div>
            <div class="spacer">
            </div>
        </asp:PlaceHolder>
        <!-- Try these categegories -->
        <asp:PlaceHolder ID="phdLinkedCategories" runat="server" Visible="false">
            <h3>
                <asp:Literal ID="litTryTheseCategories" runat="server" Text="<%$ Resources:Products, ContentText_TryTheseCategories %>"></asp:Literal></h3>

            <asp:Repeater ID="rptLinkedCategories" runat="server">
                <ItemTemplate><asp:HyperLink ID="lnkParentCategories" runat="server" Text='<%# Server.HtmlEncode(Eval("CAT_Name")) %>' /></ItemTemplate>
                <SeparatorTemplate>, </SeparatorTemplate>
            </asp:Repeater>

            <div class="spacer">
            </div>
        </asp:PlaceHolder>
    </div>
</div>
