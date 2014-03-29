<%@ Control Language="VB" AutoEventWireup="false" CodeFile="CategoryProductsView.ascx.vb"
    Inherits="CategoryProductsView" %>
<%@ Register TagPrefix="user" TagName="ItemPager" Src="~/UserControls/Front/ItemPager.ascx" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <user:ItemPager ID="UC_ItemPager_Header" runat="server" Visible="False" />
        <div class="row">
            <asp:PlaceHolder ID="phdCategoryFilters" runat="server">
                <div class="small-12 large-3 columns filterbar">
                    <div id="filterbar_pad">
                        <asp:UpdatePanel ID="updCategoryFilters" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <h2>Refine products by</h2>
                                <asp:TextBox ID="txtSearch" runat="server" placeholder="Search..." Width="150" Style="display: inline-block;"></asp:TextBox>
                                <asp:PlaceHolder ID="phdPriceRange" runat="server">
                                    <asp:DropDownList ID="ddlPriceRange" runat="server" Width="150" AutoPostBack="true">
                                    </asp:DropDownList>
                                    <asp:PlaceHolder ID="phdCustomPrice" runat="server">
                                        <asp:Literal ID="litFromSymbol" runat="server"></asp:Literal>
                                        <asp:TextBox ID="txtFromPrice" runat="server" Text="0" Width="40" Style="display: inline-block;"></asp:TextBox>
                                        <asp:Literal ID="litTo" runat="server" Text=" To "></asp:Literal>
                                        <asp:Literal ID="litToSymbol" runat="server"></asp:Literal>
                                        <asp:TextBox ID="txtToPrice" runat="server" Width="40" Style="display: inline-block;"></asp:TextBox>
                                    </asp:PlaceHolder>
                                </asp:PlaceHolder>
                                <asp:DropDownList ID="ddlOrderBy" runat="server" Width="100">
                                    <asp:ListItem Text="Name ↑" Value=".sort=name.dir=a"></asp:ListItem>
                                    <asp:ListItem Text="Name ↓" Value=".sort=name.dir=d"></asp:ListItem>
                                    <asp:ListItem Text="Price ↑" Value=".sort=price.dir=a"></asp:ListItem>
                                    <asp:ListItem Text="Price ↓" Value=".sort=price.dir=d"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:Panel ID="pnlValues" runat="server">

                                        <asp:PlaceHolder ID="phdAttributes" runat="server">
                                            <div style="clear: both; margin-bottom: 30px; display: inline-block;">
                                                <asp:Repeater ID="rptAttributes" runat="server">
                                                    <ItemTemplate>
                                                        <div style="width: 200px; border: 1px solid #eee; float: left;">
                                                            <asp:Label ID="lblAttributeName" runat="server" Text='<%# Eval("AttributeName")%>' Font-Bold="true"></asp:Label>
                                                            <asp:CheckBoxList ID="chkList" runat="server" CssClass="checkbox" BackColor="White"></asp:CheckBoxList>
                                                        </div>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </div>
                                        </asp:PlaceHolder>

                                    </asp:Panel>
                                <asp:LinkButton ID="lnkBtnSearch" runat="server" CssClass="button" Text="GO"></asp:LinkButton>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                </div>
            </asp:PlaceHolder>
            <% If phdCategoryFilters.Visible = True Then%>
            <div class="small-12 large-9 columns">
                <%Else%>
                <div class="small-12 columns">
                    <% End If%>
                    <asp:MultiView ID="mvwCategoryProducts" runat="server" ActiveViewIndex="0">
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
                    </asp:MultiView>
                    <div class="spacer"></div>
            </div>
        </div>
        <user:ItemPager ID="UC_ItemPager_Footer" runat="server" Visible="False" />
    </ContentTemplate>
</asp:UpdatePanel>
