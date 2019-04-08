<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_ModifyCategory.aspx.vb"
    Inherits="Admin_ModifyCategory" MasterPageFile="~/Skins/Admin/Template.master" %>

<%@ Register TagPrefix="_user" TagName="ObjectConfig" Src="~/UserControls/Back/_ObjectConfig.ascx" %>
<%@ Register TagPrefix="_user" TagName="CategoryFilter" Src="~/UserControls/Back/_CategoryFilters.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <asp:Literal ID="activeTab" runat="server" />
    <a class="linkbutton icon_back floatright" href="javascript:history.back()">
        <asp:Literal ID="litContentTextBackLink" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>' /></a><h1>
            <asp:Literal ID="litBackMenuCategories" runat="server" Text="<%$ Resources: _Category, BackMenu_Categories %>"></asp:Literal>:
        <span class="h1_light">
            <asp:Literal ID="litCategoryName" runat="server"></asp:Literal></span></h1>

    <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <_user:ItemIndicator ID="_UC_CategoryIndicator" runat="server" />
            <asp:Literal ID="litCategoryID" runat="server" Visible="false"></asp:Literal>
            <asp:Literal ID="litSiteID" runat="server" Visible="false"></asp:Literal>
            <ajaxToolkit:TabContainer ID="tabContainerProduct" runat="server" EnableTheming="False"
                CssClass=".tab" AutoPostBack="false">
                <%-- Category Main Info. Tab --%>
                <ajaxToolkit:TabPanel ID="tabMainInfo" runat="server">
                    <HeaderTemplate>
                        <asp:Literal ID="litTabCategoryInfo" runat="server" Text="<%$ Resources:_Category, FormLabel_TabCategoryInformation %>" />
                    </HeaderTemplate>
                    <ContentTemplate>
                        <asp:UpdatePanel ID="updModifyCategory" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <_user:EditCategory ID="_UC_EditCategory" runat="server" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <%-- Category Images Tab (Uploader) --%>
                <ajaxToolkit:TabPanel ID="tabImages" runat="server">
                    <HeaderTemplate>
                        <asp:Literal ID="litTabCategoryImages" runat="server" Text="<%$ Resources:_Category, FormLabel_TabCategoryImages %>" />
                    </HeaderTemplate>
                    <ContentTemplate>
                        <div class="subtabsection">
                            <_user:FileUploader ID="_UC_Uploader" runat="server" />
                        </div>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <%-- Category's Related Data Tab --%>
                <ajaxToolkit:TabPanel ID="tabRelatedData" runat="server">
                    <HeaderTemplate>
                        <asp:Literal ID="litContentTextSubCatsProducts" runat="server" Text="<%$ Resources: _Kartris, ContentText_SubCatsProducts %>" />
                    </HeaderTemplate>
                    <ContentTemplate>
                        <asp:UpdatePanel ID="updRelatedData" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <_user:CategoryView ID="_UC_CategoryView" runat="server" ShowHeader="False" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <%-- Object Config Tab --%>
                <ajaxToolkit:TabPanel ID="tblObjectConfig" runat="server">
                    <HeaderTemplate>
                        <asp:Literal ID="litObjectConfig" runat="server" Text="<%$ Resources: _Kartris, ContentText_ObjectConfig %>" />
                    </HeaderTemplate>
                    <ContentTemplate>
                        <div class="subtabsection">
                            <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=9996')" style="margin-bottom: 20px;">?</a>
                            <_user:ObjectConfig ID="_UC_ObjectConfig" runat="server" ItemType="Category" />
                        </div>

                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <%-- Category's Xml Filters Tab --%>
                <ajaxToolkit:TabPanel ID="tabXmlFilters" runat="server">
                    <HeaderTemplate>
                        <asp:Literal ID="litContentTextCategoryFilters" runat="server" Text="Category Filters" />
                    </HeaderTemplate>
                    <ContentTemplate>
                        <asp:UpdatePanel ID="updCategoryFilters" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <_user:CategoryFilter ID="_UC_CategoryFilter" runat="server" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
            </ajaxToolkit:TabContainer>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
