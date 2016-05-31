<%@ Page Title="" Language="VB" MasterPageFile="~/Skins/Admin/Template.master" AutoEventWireup="false"
    CodeFile="_StockNotifications.aspx.vb" Inherits="Admin_StockNotifications" %>
 
<%@ Register TagPrefix="_user" TagName="AutoComplete" Src="~/UserControls/Back/_AutoCompleteInput.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <h1>
        <asp:Literal ID="litPageTitleStockNotifications" runat="server" Text="<%$ Resources: _StockNotification, ContentText_StockNotifications %>" /></h1>
    <div id="section_stocknotifications">
        <asp:UpdatePanel ID="updStockNotifications" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
    <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    <asp:UpdateProgress ID="prgMain" runat="server" AssociatedUpdatePanelID="updStockNotifications">
        <ProgressTemplate>
            <div class="loadingimage">
            </div>
            <div class="updateprogress">
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>
</asp:Content>

