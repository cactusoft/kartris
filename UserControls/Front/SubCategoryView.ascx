<%@ Control Language="VB" AutoEventWireup="false" CodeFile="SubCategoryView.ascx.vb" Inherits="UserControls_Front_New_SubCategoryView" %>
<%@ Register TagPrefix="user" TagName="ItemPager" Src="~/UserControls/Front/ItemPager.ascx"  %>
<asp:UpdatePanel ID="updMain" runat="server">
    <ContentTemplate>
<%--        <h5>
            <asp:Literal ID="litGroupName" runat="server" Visible="False"
            Text="<%$ Resources:Categories,ContentText_SubCategories %>" />
        </h5>--%>
        <user:ItemPager ID="UC_ItemPager_Header" runat="server" Visible="False" />
        <asp:MultiView ID="multiSubCategories" runat="server" ActiveViewIndex="0">
            <!-- subcategories normal -->
            <asp:View ID="viewNormal" runat="server">
                <div class="subcategories subcategories_normal">
                    <asp:Repeater ID="rptNormal" runat="server">
                        <ItemTemplate>
                            <user:SubcategoryTemplateNormal ID="UC_TemplateNormal" runat="server" Type='<%# SubCategoryDisplayType %>'>
                            </user:SubcategoryTemplateNormal>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:View>
            <!-- subcategories shortened -->
            <asp:View ID="viewShortened" runat="server">
                <div class="subcategories subcategories_shortened">
                    <asp:Repeater ID="rptShortened" runat="server">
                        <ItemTemplate>
                            <user:SubcategoryTemplateShortened ID="UC_TemplateShortened" runat="server" />
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:View>
            <!-- subcategories link -->
            <asp:View ID="viewLink" runat="server">
                <div class="subcategories subcategories_link">
                    <asp:Repeater ID="rptLink" runat="server">
                        <ItemTemplate>
                            <user:SubcategoryTemplateLink ID="UC_TemplateLink" runat="server" />
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:View>
            <!-- subcategories text -->
            <asp:View ID="viewText" runat="server">
                <div class="subcategories subcategories_text">
                    <asp:Repeater ID="rptText" runat="server">
                        <ItemTemplate>
                            <user:SubcategoryTemplateText ID="UC_TemplateText" runat="server" />
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:View>
            <asp:View ID="viewError" runat="server">
                Display Type Not Defined...
            </asp:View>
        </asp:MultiView>
        <div class="spacer"></div>
        <user:ItemPager ID="UC_ItemPager_Footer" runat="server" Visible="False" />
    </ContentTemplate>
</asp:UpdatePanel>