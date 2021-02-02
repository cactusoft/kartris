<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_OrdersList.aspx.vb" Inherits="Admin_OrdersList"
MasterPageFile="~/Skins/Admin/Template.master" %>
<%@ Register TagPrefix="_user" TagName="OrdersList" Src="~/UserControls/Back/_OrdersList.ascx" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
<asp:UpdatePanel runat="server" ID="updOrdersList" UpdateMode="Conditional"  >
    <ContentTemplate>
        <div id="page_orders">
            <h1>
                <asp:Literal ID="litOrderPageTitle" runat="server" Text="<%$Resources: PageTitle_Orders %>"></asp:Literal>:
                <span class="h1_light">
                    <asp:Literal ID="litOrderListMode" runat="server" Text="<%$Resources: PageTitle_OrdersRecent %>"></asp:Literal></span>
                <span class="h1_light_extra">
                    <asp:Literal ID="litModeDetails" runat="server" Text="<%$Resources: ContentText_OrdersRecentText%>"></asp:Literal></span>
                <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=9876')" />?</a>
            </h1>
            
            <div id="searchboxrow">
                <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                    <asp:PlaceHolder ID="phdGateway" runat="server" Visible="false">
                        <asp:Label ID="lblGateway" runat="server" Text="Gateway:"></asp:Label>
                        <asp:DropDownList ID="ddlGateways" runat="server" AppendDataBoundItems="true" DataSourceID="sqlDSGateways"
                            DataTextField="O_PaymentGateway" DataValueField="O_PaymentGateway" />
                        <asp:SqlDataSource ID="sqlDSGateways" runat="server" SelectCommand="_spKartrisOrders_GetGateways"
                            ConnectionString="<%$ ConnectionStrings:KartrisSQLConnection%>" SelectCommandType="StoredProcedure" />
                    </asp:PlaceHolder>
                    <asp:Label ID="lblFindOrder" runat="server" Text=""></asp:Label>
                    <div style="position:relative;">
                    <asp:ImageButton ID="btnCalendar" runat="server" AlternateText="" ImageUrl="~/Skins/Admin/Images/icon_calendar.gif"
                        Width="16" Height="16" CssClass="calendarbutton" />
                    <asp:TextBox ID="txtSearch" runat="server" ToolTip="<%$Resources: ContentText_FindAnOrder%>" /><ajaxToolkit:CalendarExtender
                        Format="yyyy/MM/dd" Animated="true" PopupButtonID="btnCalendar" TargetControlID="txtSearch"
                        runat="server" ID="calDateSearch" PopupPosition="BottomLeft" CssClass="calendar" />
                    <asp:Button ID="btnSearch" runat="server" Text="<%$ Resources:_Kartris, FormButton_Search %>"
                        CssClass="button" /></div>
                    <div class="spacer">
                        &nbsp;</div>
                    <p>
                        <asp:Literal ID="litEnterDate" runat="server" Text="<%$Resources: ContentText_EnterDate%>"></asp:Literal></p>
                </asp:Panel>
            </div>
            <div class="spacer">
                &nbsp;</div>
            <_user:OrdersList ID="_UC_OrdersList" runat="server" />
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

