<%@ Page Title="" Language="VB" MasterPageFile="~/Skins/Admin/Template.master" AutoEventWireup="false" CodeFile="_Linnworks.aspx.vb" Inherits="Admin_Linnworks" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="phdMain" runat="Server">
    <h1>
        <asp:Literal ID="litPageTitle" runat="server" Text='<%$ Resources:_Linnworks, PageTitle_LinnworksIntegration%>' /></h1>
    <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:Literal ID="litToken" runat="server" Visible="false"></asp:Literal>
            <asp:PlaceHolder ID="phdInvalidToken" runat="server">
                <div class="errormessage">
                    <asp:Literal ID="litTokenMessage" runat="server"></asp:Literal>
                </div>
                <div class="line">
                </div>
                <div class="Kartris-DetailsView">
                    <div class="Kartris-DetailsView-Data">
                        <ul>
                            <li><span class="Kartris-DetailsView-Name">
                                <asp:Literal ID="litLinnworksEmail" runat="server" Text="<%$ Resources: _Kartris, ContentText_Email %>"></asp:Literal>
                            </span><span class="Kartris-DetailsView-Value">
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="midtext"></asp:TextBox>
                            </span></li>
                            <li><span class="Kartris-DetailsView-Name">
                                <asp:Literal ID="litLinnworksPassword" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Password %>"></asp:Literal>
                            </span><span class="Kartris-DetailsView-Value">
                                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="midtext"></asp:TextBox>
                            </span></li>
                            <li>
                                <asp:Button ID="btnGenerate" runat="server" Text="<%$ Resources: _Kartris, ContentText_Generate %>" CssClass="button" /></li>
                        </ul>
                    </div>
                </div>
            </asp:PlaceHolder>
            <div class="spacer">
            </div>
            <asp:PlaceHolder ID="phdContents" runat="server">
                <ajaxToolkit:TabContainer ID="tabContainerLinnworks" runat="server" EnableTheming="False"
                    CssClass=".tab" AutoPostBack="false">
                    <ajaxToolkit:TabPanel ID="tabKartrisPendingOrders" runat="server">
                        <HeaderTemplate>
                            <asp:Literal ID="litTabKartrisPendingOrders" runat="server" Text="<%$ Resources:_Linnworks, ContentText_PendingOrders %>" />
                            <asp:Literal ID="litTotalPending" runat="server"></asp:Literal>
                        </HeaderTemplate>
                        <ContentTemplate>
                            <asp:UpdatePanel ID="updKartrisPendingOrders" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:MultiView ID="mvwPendingOrders" runat="server" ActiveViewIndex="0">
                                        <asp:View ID="viwPendingOrders" runat="server">
                                            <br />
                                            <asp:Literal ID="litPendingOrdersHidden" runat="server" Visible="False"></asp:Literal>
                                            <asp:Button ID="btnPendingSelectAll" runat="server" Text="Select All" CssClass="button"></asp:Button>
                                            <asp:Button ID="btnPendingSelectNone" runat="server" Text="Select None" CssClass="button"></asp:Button>
                                            <asp:Button ID="btnPendingSend" runat="server" Text="Send Selected" CssClass="button"></asp:Button>
                                            <asp:GridView CssClass="kartristable" ID="gvwPendingOrders" runat="server" AutoGenerateColumns="False"
                                                DataKeyNames="O_ID" GridLines="None" EnableViewState="true">
                                                <Columns>
                                                    <asp:TemplateField>
                                                        <ItemTemplate>
                                                            <asp:CheckBox ID="chkSelect" runat="server" CssClass="checkbox" />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText='<%$ Resources:_Kartris, ContentText_ID%>'>
                                                        <ItemTemplate>
                                                            <a class="linkbutton icon_edit" href="_ModifyOrderStatus.aspx?OrderID=<%#Eval("O_ID") %>">
                                                                <asp:Label ID="lblOrderID" runat="server" Text='<%# Eval("O_ID") %>'></asp:Label></a>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField ItemStyle-CssClass="datefield" HeaderText='<%$ Resources:_Kartris, ContentText_Date %>'>
                                                        <ItemTemplate>
                                                            <asp:Literal ID="litOrderDate" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("O_Date"), "t", Session("_LANG")) %>' />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField ItemStyle-CssClass="currencyfield" HeaderText='<%$ Resources:_Kartris, ContentText_Value %>'>
                                                        <ItemTemplate>
                                                            <asp:Literal ID="litOrderValue" runat="server" Text='<%# Eval("O_TotalPrice") %>'> </asp:Literal>
                                                            <asp:HiddenField runat="server" EnableViewState="false" ID="hidOrderCurrencyID" Value='<%#Eval("O_CurrencyID")%>' />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText='<%$ Resources:_Kartris, ContentText_CustomerName %>'>
                                                        <ItemTemplate>
                                                            <a class="linkbutton icon_user" href="_ModifyCustomerStatus.aspx?CustomerID=<%#Eval("O_CustomerID") %>">
                                                                <asp:Label ID="lblOrderBillingName" runat="server" Text='<%# Eval("O_BillingName") %>'></asp:Label></a>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField ItemStyle-CssClass="selectfield">
                                                        <ItemTemplate>
                                                            <asp:Button ID="btnSend" runat="server" Text="<%$ Resources: _Linnworks, ContentText_SendToLinnworks %>" CommandArgument='<%# Eval("O_ID")%>' CommandName="send" CssClass="button"></asp:Button>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </asp:View>
                                        <asp:View ID="viwNoPendingOrders" runat="server">
                                            <asp:Panel ID="pnlNoPendingItems" runat="server" CssClass="noresults">
                                                <asp:Literal ID="litNoPendingItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>">
                                                </asp:Literal>
                                            </asp:Panel>
                                        </asp:View>
                                    </asp:MultiView>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel ID="tabKartrisSentOrders" runat="server">
                        <HeaderTemplate>
                            <asp:Literal ID="litTabKartrisSentOrders" runat="server" Text="<%$ Resources: _Linnworks, ContentText_LinnworksOrders %>" />
                            <asp:Literal ID="litTotalSent" runat="server"></asp:Literal>
                        </HeaderTemplate>
                        <ContentTemplate>
                            <asp:UpdatePanel ID="updKartrisSentOrders" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:MultiView ID="mvwSentOrders" runat="server" ActiveViewIndex="0">
                                        <asp:View ID="viwSentOrders" runat="server">
                                            <asp:GridView CssClass="kartristable" ID="gvwSentOrders" runat="server" AutoGenerateColumns="False"
                                                DataKeyNames="O_ID" GridLines="None" EnableViewState="true">
                                                <Columns>
                                                    <asp:TemplateField HeaderText="Order ID">
                                                        <ItemTemplate>
                                                            <a class="linkbutton icon_edit" href="_ModifyOrderStatus.aspx?OrderID=<%#Eval("O_ID") %>">
                                                                <asp:Label ID="lblOrderID" runat="server" Text='<%# Eval("O_ID") %>'></asp:Label></a>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText='<%$ Resources:_Kartris, ContentText_CustomerName %>'>
                                                        <ItemTemplate>
                                                            <a class="linkbutton icon_user" href="_ModifyCustomerStatus.aspx?CustomerID=<%#Eval("O_CustomerID") %>">
                                                                <asp:Label ID="lblOrderBillingName" runat="server" Text='<%# Eval("O_BillingName") %>'></asp:Label></a><br />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField ItemStyle-CssClass="datefield" HeaderText="<%$ Resources: _Orders, ContentText_OrderDate %>">
                                                        <ItemTemplate>
                                                            <asp:Literal ID="litOrderDate" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("O_Date"), "t", Session("_LANG")) %>' />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField ItemStyle-CssClass="currencyfield" HeaderText='<%$ Resources:_Kartris, ContentText_Value %>'>
                                                        <ItemTemplate>
                                                            <asp:Literal ID="litOrderValue" runat="server" Text='<%# Eval("O_TotalPrice") %>'> </asp:Literal>
                                                            <asp:HiddenField runat="server" EnableViewState="false" ID="hidOrderCurrencyID" Value='<%#Eval("O_CurrencyID")%>' />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField ItemStyle-CssClass="datefield" HeaderText="<%$ Resources: _Kartris, ContentText_DateSent %>">
                                                        <ItemTemplate>
                                                            <asp:Literal ID="litOrderLinnworksDate" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("LWO_DataCreated"), "t", Session("_LANG")) %>' />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </asp:View>
                                        <asp:View ID="viwNoSentOrders" runat="server">
                                            <asp:Panel ID="pnlNoSentItems" runat="server" CssClass="noresults">
                                                <asp:Literal ID="litNoSentItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>">
                                                </asp:Literal>
                                            </asp:Panel>
                                        </asp:View>
                                    </asp:MultiView>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel ID="tabStockLevels" runat="server">
                        <HeaderTemplate>
                            <asp:Literal ID="litTabStockLevels" runat="server" Text="<%$ Resources: _Linnworks, ContentText_LinnworksStockLevel %>" />
                            <asp:Literal ID="litTotalStock" runat="server"></asp:Literal>
                        </HeaderTemplate>
                        <ContentTemplate>
                            <asp:UpdatePanel ID="updStockLevels" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:MultiView ID="mvwStock" runat="server" ActiveViewIndex="0">
                                        <asp:View ID="viwStock" runat="server">
                                            <br />
                                            <asp:PlaceHolder ID="phdEnableSync" runat="server">
                                                <asp:Button ID="btnStockSelectAll" runat="server" Text="<%$ Resources: _Kartris, ContentText_SelectAll %>" CssClass="button"></asp:Button>
                                                <asp:Button ID="btnStockSelectNone" runat="server" Text="<%$ Resources: _Kartris, ContentText_SelectNone %>" CssClass="button"></asp:Button>
                                                <asp:Button ID="btnStockSynchronize" runat="server" Text="<%$ Resources: _Linnworks, ContentText_SyncSelected %>" CssClass="button"></asp:Button>
                                            </asp:PlaceHolder>
                                            <asp:PlaceHolder ID="phdDisableSyn" runat="server" Visible="false">
                                                <div class="warnmessage">
                                                    <asp:Literal ID="litSyncIsDisabled" runat="server" Text="<%$ Resources: _Linnworks, ContentText_StockSyncDisabled %>"></asp:Literal>
                                                </div>
                                            </asp:PlaceHolder>
                                            <asp:GridView CssClass="kartristable" ID="gvwStock" runat="server" AutoGenerateColumns="False"
                                                DataKeyNames="SKU" GridLines="None" EnableViewState="true">
                                                <Columns>
                                                    <asp:TemplateField>
                                                        <HeaderTemplate>
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <asp:CheckBox ID="chkSelect" runat="server" CssClass="checkbox" />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:BoundField DataField="SKU" HeaderText='<%$ Resources:_Version, FormLabel_CodeNumer%>'></asp:BoundField>
                                                    <asp:BoundField DataField="Name" HeaderText='<%$ Resources:_Product, FormLabel_VersionName%>'></asp:BoundField>
                                                    <asp:BoundField DataField="Level" HeaderText="<%$ Resources: _Kartris, ContentText_Level %>"></asp:BoundField>
                                                    <asp:BoundField DataField="InOrderBook" HeaderText="<%$ Resources: _Linnworks, ContentText_InOrderBook %>"></asp:BoundField>
                                                    <asp:BoundField DataField="OnOrder" HeaderText="<%$ Resources: _Linnworks, ContentText_OnOrder %>"></asp:BoundField>
                                                    <asp:BoundField DataField="Available" HeaderText="<%$ Resources: _Kartris, ContentText_Available %>"></asp:BoundField>
                                                </Columns>
                                            </asp:GridView>
                                        </asp:View>
                                        <asp:View ID="viwNoStock" runat="server">
                                            <asp:Panel ID="pnlStockNoItems" runat="server" CssClass="noresults">
                                                <asp:Literal ID="litNoStockItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>">
                                                </asp:Literal>
                                            </asp:Panel>
                                        </asp:View>
                                    </asp:MultiView>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                </ajaxToolkit:TabContainer>
            </asp:PlaceHolder>
        </ContentTemplate>
    </asp:UpdatePanel>
    <asp:UpdateProgress ID="prgMain" runat="server" AssociatedUpdatePanelID="updMain">
        <ProgressTemplate>
            <div class="loadingimage">
            </div>
            <div class="updateprogress">
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>
    <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
</asp:Content>

