<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_SubSitesList.aspx.vb" Inherits="Admin_SubSitesList"
MasterPageFile="~/Skins/Admin/Template.master" %>
<%@ Register TagPrefix="_user" TagName="SubSitesList" Src="~/UserControls/Back/_SubSitesList.ascx" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
<asp:UpdatePanel runat="server" ID="updOrdersList" UpdateMode="Conditional"  >
    <ContentTemplate>
        <div id="page_subsites">
            <h1>
                <asp:Literal ID="litOrderPageTitle" runat="server" Text="Sub Sites"></asp:Literal>:
                <%--<span class="h1_light">
                    <asp:Literal ID="litOrderListMode" runat="server" Text="<%$Resources: PageTitle_OrdersRecent %>"></asp:Literal></span>--%>
                <%--<span class="h1_light_extra">
                    <asp:Literal ID="litModeDetails" runat="server" Text="<%$Resources: ContentText_OrdersRecentText%>"></asp:Literal></span>--%>
                <%--<a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=9876')" />?</a>--%>
            </h1>
            
            <div class="spacer">
                &nbsp;</div>
            <_user:SubSitesList ID="_UC_SubSitesList" runat="server" />
        </div>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgOrders" runat="server" AssociatedUpdatePanelID="updOrdersList">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
</asp:Content>

