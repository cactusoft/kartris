<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_AdminSearch.ascx.vb"
    Inherits="UserControls_Back_AdminSearch" %>
<div id="section_searchbox">
<h2>
                <asp:Literal ID="litAdminSearchTitle" runat="server" Text="<%$ Resources: _Kartris, FormButton_Search %>"></asp:Literal></h2>
    <asp:UpdatePanel ID="updSearch" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div id="searchboxes">
                <asp:TextBox ID="txtSearch" runat="server" MaxLength="80" CssClass="searchtextbox" />
                <asp:Button ID="btnSearch" runat="server" Text="<%$ Resources: _Kartris, FormButton_Search %>"
                    ToolTip="<%$ Resources: _Kartris, FormButton_Search %>" CssClass="searchbutton button" /><br />
                <asp:DropDownList ID="ddlFilter" runat="server" Visible="false">
                    <asp:ListItem Text="<%$ Resources: _Kartris, BackMenu_SearchAll %>" Value="0" />
                    <asp:ListItem Text="<%$ Resources: _Search, ContentText_AdminSearchCategories  %>"
                        Value="categories" />
                    <asp:ListItem Text="<%$ Resources: _Search, ContentText_AdminSearchProducts %>" Value="products" />
                    <asp:ListItem Text="<%$ Resources: _Search, ContentText_AdminSearchVersions %>" Value="versions" />
                    <asp:ListItem Text="<%$ Resources: _Search, ContentText_AdminSearchCustomers %>"
                        Value="customers" />
                    <asp:ListItem Text="<%$ Resources: _Search, ContentText_AdminSearchOrders %>" Value="orders" />
                    <asp:ListItem Text="<%$ Resources: _Search, ContentText_AdminSearchSiteText %>" Value="site" />
                    <asp:ListItem Text="<%$ Resources: _Search, ContentText_AdminSearchConfig %>" Value="config" />
                    <asp:ListItem Text="<%$ Resources: _Kartris, BackMenu_CustomPages %>" Value="pages" />
                </asp:DropDownList>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
<asp:UpdateProgress ID="prgSearch" runat="server" AssociatedUpdatePanelID="updSearch">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
