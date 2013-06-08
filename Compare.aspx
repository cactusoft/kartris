<%@ Page Language="VB" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="false"
    CodeFile="compare.aspx.vb" Inherits="Compare" %>

<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <asp:MultiView ID="mvwMain" runat="server" ActiveViewIndex="0">
        <asp:View ID="viwExist" runat="server">
            <user:BreadCrumbTrail ID="UC_BreadCrumbTrail" runat="server" EnableViewState="False" />
            <div class="comparison">
                <h1>
                    <asp:Literal ID="litProductComparisonHeader" runat="server" Text="<%$ Resources:Products, PageTitle_ProductComparision  %>"></asp:Literal></h1>
                <p>
                    <asp:Literal ID="litProductComparisonText" runat="server" Text="<%$ Resources:Products, ContentText_ProductComparison %>"></asp:Literal>
                </p>
                <p>
                    <asp:Button ID="btnClearSession" CssClass="button" runat="server" Text="<%$ Resources:Comparison, ContentText_ClearAll %>">
                    </asp:Button>
                </p>
                <% If Session("ProductsToCompare") <> "" Then%>
                <div class="items row">
                    <user:ProductCompare ID="UC_ProductComparison" runat="server" />
                </div>
                <% End If%>
                <div class="spacer">
                </div>
            </div>
        </asp:View>
        <asp:View ID="viwNotExist" runat="server">
            <p>
                <asp:Literal ID="litContentTextNotAvailable" runat="server" Text="<%$ Resources: Kartris, ContentText_ContentNotAvailable %>" /></p>
        </asp:View>
    </asp:MultiView>
</asp:Content>
