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
                <asp:PlaceHolder ID="phdCurrentNotifications" runat="server">
                    <div>
                        <asp:Button ID="btnCheckAndSend" CssClass="button" runat="server" Text="<%$ Resources: _StockNotification, ContentText_RunNotificationsCheck %>" />

                    </div>
                    <asp:GridView ID="gvwDetails" runat="server" CssClass="kartristable" AllowPaging="true"
                        GridLines="None" AutoGenerateColumns="False">
                        <Columns>
                            <asp:TemplateField ItemStyle-CssClass="column1">
                                <HeaderTemplate>
                                    <asp:Literal ID="litContentTextID" runat="server" Text="<%$ Resources:_Kartris, ContentText_ID %>" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:Literal ID="litID" runat="server" Text='<%# Eval("SNR_ID")%>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-CssClass="column2">
                            <HeaderTemplate>
                                <asp:Literal ID="litEmailHeader" runat="server" Text="<%$ Resources:_Kartris, ContentText_Email %>" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:Literal ID="litUserEmail" runat="server" Text='<%# Eval("SNR_UserEmail")%>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-CssClass="column3">
                            <HeaderTemplate>
                                <asp:Literal ID="litProductNameHeader" runat="server" Text="<%$ Resources:_Kartris, FormLabel_Title %>" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:Literal ID="litProductName" runat="server" Text='<%# Eval("SNR_ProductName")%>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-CssClass="column4">
                            <HeaderTemplate>
                                <asp:Literal ID="litDateCreatedHeader" runat="server" Text="<%$ Resources:_Kartris, ContentText_DateCreated %>" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:Literal ID="litDateCreatedName" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(CkartrisDataManipulation.FixNullFromDB(Eval("SNR_DateCreated")), "t", Session("_LANG"))%>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-CssClass="column5">
                            <HeaderTemplate>
                                <asp:Literal ID="litDateSettledHeader" runat="server" Text="<%$ Resources:_Tickets, ContentText_DateClosed %>" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:Literal ID="litDateSettled" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(CkartrisDataManipulation.FixNullFromDB(Eval("SNR_DateSettled")), "t", Session("_LANG")) %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                <br /><br />
                </asp:PlaceHolder>
                <h2><asp:Literal ID="litClosed" runat="server" Text="<%$ Resources:_Tickets, ContentText_ClosedStatus %>"></asp:Literal></h2>
                <asp:GridView ID="gvwDetailsClosed" runat="server" CssClass="kartristable" AllowPaging="true"
                    GridLines="None" AutoGenerateColumns="False">
                    <Columns>
                        <asp:TemplateField ItemStyle-CssClass="column1">
                            <HeaderTemplate>
                                <asp:Literal ID="litContentTextID" runat="server" Text="<%$ Resources:_Kartris, ContentText_ID %>" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:Literal ID="litID" runat="server" Text='<%# Eval("SNR_ID")%>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-CssClass="column2">
                            <HeaderTemplate>
                                <asp:Literal ID="litEmailHeader" runat="server" Text="<%$ Resources:_Kartris, ContentText_Email %>" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:Literal ID="litUserEmail" runat="server" Text='<%# Eval("SNR_UserEmail")%>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-CssClass="column3">
                            <HeaderTemplate>
                                <asp:Literal ID="litProductNameHeader" runat="server" Text="<%$ Resources:_Kartris, FormLabel_Title %>" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:Literal ID="litProductName" runat="server" Text='<%# Eval("SNR_ProductName")%>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-CssClass="column4">
                            <HeaderTemplate>
                                <asp:Literal ID="litDateCreatedHeader" runat="server" Text="<%$ Resources:_Kartris, ContentText_DateCreated %>" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:Literal ID="litDateCreatedName" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(CkartrisDataManipulation.FixNullFromDB(Eval("SNR_DateCreated")), "t", Session("_LANG"))%>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-CssClass="column5">
                            <HeaderTemplate>
                                <asp:Literal ID="litDateSettledHeader" runat="server" Text="<%$ Resources:_Tickets, ContentText_DateClosed %>" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:Literal ID="litDateSettled" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(CkartrisDataManipulation.FixNullFromDB(Eval("SNR_DateSettled")), "t", Session("_LANG")) %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
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

