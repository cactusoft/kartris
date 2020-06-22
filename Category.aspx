<%@ Page Language="VB" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="true"
    CodeFile="Category.aspx.vb" Inherits="Category" %>

<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <div class="page_category">
        <asp:MultiView ID="mvwCategory" runat="server" ActiveViewIndex="0">
            <asp:View ID="viwCategoryDetails" runat="server">

                <user:CategoryView ID="UC_CategoryView" runat="server" />
                <div class="spacer"></div>

                <ajaxToolkit:TabContainer ID="tabContainer" runat="server" EnableTheming="False"
                    CssClass="tab">
                    <ajaxToolkit:TabPanel ID="tabSubCats" runat="server">
                        <HeaderTemplate>
                            <asp:Literal ID="litSubCatHeader" runat="server" Text="<%$ Resources:Categories,ContentText_SubCategories %>" />
                        </HeaderTemplate>
                        <ContentTemplate>
                            <user:SubCategoryView ID="UC_SubCategoryView" runat="server" />
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel runat="server" ID="tabProducts">
                        <HeaderTemplate>
                            <asp:Literal ID="litProductsHeader" runat="server" Text="<%$ Resources:Products, ContentText_Products %>" />
                        </HeaderTemplate>
                        <ContentTemplate>
                            <user:CategoryProductsView ID="UC_CategoryProductsView" runat="server" />
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                </ajaxToolkit:TabContainer>
            </asp:View>
            <asp:View ID="viwCategoryNotExist" runat="server">
                <p>
                    <asp:Literal ID="litContentTextContentNotAvailable" runat="server" Text="<%$ Resources: Kartris, ContentText_ContentNotAvailable %>" /></p>
            </asp:View>
        </asp:MultiView>
    </div>
</asp:Content>
