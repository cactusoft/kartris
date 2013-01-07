<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_ItemIndicator.ascx.vb"
    Inherits="UserControls_Back_ItemIndicator" %>
<asp:UpdatePanel ID="updIndicator" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Panel ID="pnlMessage" CssClass="warnmessage section_itemindicator" runat="server" Visible="False">
            <div class="leftcolumn">
                <asp:Literal ID="litContentTextProductNotVisible" runat="server" Text="<%$ Resources:_Kartris, ContentText_ProductNotVisible %>"></asp:Literal></div>
            <div class="rightcolumn">
                <asp:BulletedList ID="bulList" runat="server" Visible="True">
                </asp:BulletedList>
            </div>
            <div class="spacer">
            </div>
        </asp:Panel>
    </ContentTemplate>
</asp:UpdatePanel>
