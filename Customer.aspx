<%@ Page Language="VB" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="false"
    CodeFile="Customer.aspx.vb" Inherits="Customer" %>

<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <div id="customer">
        <user:PopupMessage ID="UC_PopUpInfo" runat="server" />
        <user:BreadCrumbTrail ID="UC_BreadCrumbTrail" runat="server" EnableViewState="False" />
        <asp:UpdatePanel ID="updPanelCustomer" runat="server">
            <ContentTemplate>
                <!-- start of save basket -->
                <asp:UpdatePanel ID="updSaveBasket" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:Panel ID="pnlSaveBasket" runat="server" DefaultButton="lnkBtnSaveBasket">
                            <asp:PlaceHolder ID="phdSaveBasket" runat="server" Visible="false">
                                <h1>
                                    <asp:Literal ID="litPageTitleSaveCurrentBasketContents" runat="server" Text='<%$ Resources: Kartris, PageTitle_SaveCurrentBasketContents %>'
                                        EnableViewState="false"></asp:Literal></h1>
                                <p>
                                    <asp:Literal ID="litSaveBasketError" runat="server"></asp:Literal></p>
                                <p>
                                    <asp:Literal ID="litContentTextSaveRecoverBasketContentsDesc" runat="server" Text='<%$ Resources: Kartris, ContentText_SaveRecoverBasketContentsDesc %>'
                                        EnableViewState="false"></asp:Literal></p>
                                <p>
                                    <asp:Literal ID="litContentTextChooseNamePassword" runat="server" Text='<%$ Resources: Kartris, ContentText_ChooseNamePassword %>'
                                        EnableViewState="false"></asp:Literal></p>
                                <div class="inputform">
                                    <div class="Kartris-DetailsView">
                                        <div class="Kartris-DetailsView-Data">
                                            <ul>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Label ID="lblContentTextBasketNamePassword" runat="server" AssociatedControlID="txtBasketName"
                                                        Text='<%$ Resources: Basket, ContentText_BasketNamePassword %>' CssClass="requiredfield"></asp:Label>
                                                </span><span class="Kartris-DetailsView-Value">
                                                    <asp:TextBox MaxLength="50" ID="txtBasketName" runat="server"></asp:TextBox><asp:Button
                                                        OnCommand="SaveBasket_Click" ValidationGroup="SavedBasket" CssClass="button"
                                                        ID="lnkBtnSaveBasket" runat="server" Text='<%$ Resources: Kartris, FormLabel_Save %>' /><asp:RequiredFieldValidator
                                                            EnableClientScript="True" ID="valBasketName" runat="server" ControlToValidate="txtBasketName"
                                                            ValidationGroup="SavedBasket" CssClass="error" ForeColor="" Display="Dynamic"
                                                            Text="<%$ Resources: Kartris, ContentText_RequiredField %>"></asp:RequiredFieldValidator></span></li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </asp:PlaceHolder>
                        </asp:Panel>
                    </ContentTemplate>
                </asp:UpdatePanel>
                <!-- end of save basket-->
                <!-- start of home/my account -->
                <asp:UpdatePanel ID="updHome" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:PlaceHolder ID="phdHome" runat="server" Visible="false">
                            <h1>
                                <asp:Literal ID="litPageTitleMyAccount" runat="server" Text='<%$ Resources: Kartris, PageTitle_MyAccount %>'></asp:Literal></h1>

                                <div class="changecustomercode section">
                                    <h2>
                                        <asp:Literal ID="litContentTextChangeCustomerCode" runat="server" Text='<%$ Resources: Kartris, ContentText_ChangeCustomerCode %>'></asp:Literal></h2>
                                    <p>
                                        <a href="CustomerDetails.aspx" class="link2">
                                            <asp:Literal ID="litContentTextToChangeCustomerCode" runat="server" Text='<%$ Resources: Kartris, ContentText_ToChangeCustomerCode %>' /></a>
                                    </p>
                                </div>
                                <% If KartSettingsManager.GetKartConfig("frontend.supporttickets.enabled") = "y" Then%>
                                <div class="supporttickets section">
                                    <h2>
                                        <asp:Literal ID="litPageTitleSupportTickets" runat="server" Text='<%$ Resources: Tickets, PageTitle_SupportTickets %>'></asp:Literal></h2>
                                    <p>
                                        <a href="CustomerTickets.aspx" class="link2">
                                            <asp:Literal ID="litContentTextView" runat="server" Text='<%$ Resources: Kartris, ContentText_View %>' /></a>
                                    </p>
                                </div>
                                <% End If%>
                                <% If numCustomerDiscount > 0 Then%>
                                <div class="customerdiscount section">
                                    <h2>
                                        <asp:Literal ID="litContentTextCustomerDiscount" runat="server" Text='<%$ Resources: Kartris, ContentText_CustomerDiscount %>'></asp:Literal></h2>
                                    <asp:Literal ID="litContentTextCustomerDiscountText1" runat="server" Text='<%$ Resources: Kartris, ContentText_CustomerDiscountText1 %>'></asp:Literal>
                                    <strong>
                                        <%=(numCustomerDiscount)%>%</strong>
                                    <asp:Literal ID="litContentTextCustomerDiscountText2" runat="server" Text='<%$ Resources: Kartris, ContentText_CustomerDiscountText2 %>'></asp:Literal>
                                </div>
                                <% End If%>
                                <ajaxToolkit:Accordion ID="accMyAccount" runat="Server" SelectedIndex="0" HeaderCssClass="accordionHeader"
                                    HeaderSelectedCssClass="accordionHeaderSelected" ContentCssClass="accordionContent"
                                    AutoSize="None" FadeTransitions="true" TransitionDuration="250" FramesPerSecond="40"
                                    RequireOpenedPane="false" SuppressHeaderPostbacks="true">
                                    <Panes>
                                        <%-- Tab: Order History --%>
                                        <ajaxToolkit:AccordionPane ID="acpOrderHistory" runat="server" HeaderCssClass="accordionHeader"
                                            HeaderSelectedCssClass="accordionHeaderSelected" ContentCssClass="accordionContent">
                                            <Header>
                                                <h2>
                                                    <asp:Literal runat="server" ID="litSubHeadingOrderHistory2" Text="<%$ Resources: Kartris, SubHeading_OrderHistory %>" /></h2>
                                            </Header>
                                            <Content>
                                                <asp:UpdatePanel runat="server" ID="updOrder" UpdateMode="Conditional">
                                                    <ContentTemplate>
                                                        <div id="orderhistory">
                                                            <% If rptOrder.Items.Count <> 0 Then%>
                                                            <p>
                                                                <asp:Literal ID="litContentTextOrdersBelowRecent" runat="server" Text='<%$ Resources: Kartris, ContentText_OrdersBelowRecent %>'></asp:Literal>
                                                            </p>
                                                            <asp:Repeater ID="rptOrder" runat="server">
                                                                <HeaderTemplate>
                                                                    <table class="filled">
                                                                        <thead>
                                                                            <tr class="header">
                                                                                <th class="number">
                                                                                    <asp:Literal ID="litContentTextSmallNumber" runat="server" Text='<%$ Resources: Kartris, ContentText_SmallNumber %>' />
                                                                                </th>
                                                                                <th class="orderdate">
                                                                                    <asp:Literal ID="litContentTextOrderDate" runat="server" Text='<%$ Resources: Kartris, ContentText_OrderDate %>' />
                                                                                </th>
                                                                                <th class="lastupdate">
                                                                                    <asp:Literal ID="litContentTextLastUpdate" runat="server" Text='<%$ Resources: Kartris, ContentText_LastUpdate %>' />
                                                                                </th>
                                                                                <th class="amount">
                                                                                    <asp:Literal ID="litContentTextAmount" runat="server" Text='<%$ Resources: Kartris, ContentText_Amount %>' />
                                                                                </th>
                                                                                <th class="select">
                                                                                    <asp:UpdateProgress ID="prgOrder" runat="server" AssociatedUpdatePanelID="updOrder"
                                                                                        DynamicLayout="true">
                                                                                        <ProgressTemplate>
                                                                                            <div class="loadingimage">
                                                                                            </div>
                                                                                            <div class="updateprogress">
                                                                                            </div>
                                                                                        </ProgressTemplate>
                                                                                    </asp:UpdateProgress>
                                                                                </th>
                                                                            </tr>
                                                                        </thead>
                                                                        <tbody>
                                                                </HeaderTemplate>
                                                                <ItemTemplate>
                                                                    <tr>
                                                                        <td class="name">
                                                                            <%#Eval("O_ID")%>
                                                                        </td>
                                                                        <td class="orderdate">
                                                                            <%#CkartrisDisplayFunctions.FormatDate(Eval("O_Date"), "t", Session("LANG"))%>
                                                                        </td>
                                                                        <td class="lastupdate">
                                                                            <%#CkartrisDisplayFunctions.FormatDate(Eval("O_LastModified"), "d", Session("LANG"))%>
                                                                        </td>
                                                                        <td class="amount">
                                                                            <asp:Literal runat="server" ID="litOrdersTotal" Text="" />
                                                                        </td>
                                                                        <td class="select">
                                                                            <asp:LinkButton ID="lnkBtnOrderInvoice" CssClass="link2 normalweight" runat="server"
                                                                                Text='<%$ Resources: Kartris, ContentText_SalesReceipt %>'></asp:LinkButton>
                                                                            <asp:LinkButton ID="lnkBtnOrderView" CssClass="link2" runat="server" Text='<%$ Resources: Kartris, ContentText_View %>'></asp:LinkButton>
                                                                        </td>
                                                                    </tr>
                                                                </ItemTemplate>
                                                                <FooterTemplate>
                                                                    </tbody></table>
                                                                </FooterTemplate>
                                                            </asp:Repeater>
                                                            <div class="itempager">
                                                                <asp:LinkButton ID="lnkBtnOrderPrev" Text="&#171;" OnCommand="PageNavigate_Click"
                                                                    CommandName="Order" runat="server" />
                                                                <asp:LinkButton ID="lnkBtnOrderNext" Text="&#187;" OnCommand="PageNavigate_Click"
                                                                    CommandName="Order" runat="server" />
                                                            </div>
                                                            <% Else%>
                                                            <p>
                                                                <asp:Literal ID="litContentTextOrderNotFound" runat="server" Text='<%$ Resources: Kartris, ContentText_OrderNotFound %>'></asp:Literal>
                                                            </p>
                                                            <br />
                                                            <% End If%>
                                                        </div>
                                                    </ContentTemplate>
                                                </asp:UpdatePanel>
                                            </Content>
                                        </ajaxToolkit:AccordionPane>
                                        <%-- Tab: Downloadable Products --%>
                                        <ajaxToolkit:AccordionPane ID="acpDownloadableProducts" runat="server" HeaderCssClass="accordionHeader"
                                            HeaderSelectedCssClass="accordionHeaderSelected" ContentCssClass="accordionContent">
                                            <Header>
                                                <h2>
                                                    <asp:Literal runat="server" ID="litSubHeadingProductsOrdered" Text="<%$ Resources: SubHeading_ProductsOrdered %>" /></h2>
                                            </Header>
                                            <Content>
                                                <asp:PlaceHolder ID="phdDownloadableProducts" runat="server">
                                                    <div class="downloadableproducts">
                                                        <p>
                                                            <asp:Literal ID="litDownloadExplanation" runat="server" Text='<%$ Resources: ContentText_DownloadExplanation %>'
                                                                EnableViewState="false" /></p>
                                                        <asp:Repeater ID="rptDownloadableProducts" runat="server">
                                                            <HeaderTemplate>
                                                                <table class="filled">
                                                                    <thead>
                                                                        <tr class="header">
                                                                            <th class="itemname">
                                                                            </th>
                                                                            <th class="codenumber">
                                                                                <asp:Literal ID="litContentTextCodeNumberSmall" runat="server" Text='<%$ Resources: ContentText_CodeNumberSmall %>' />
                                                                            </th>
                                                                            <th class="orderdate">
                                                                                <asp:Literal ID="litContentTextOrderDate" runat="server" Text='<%$ Resources: Kartris, ContentText_OrderDate %>' />
                                                                            </th>
                                                                            <th class="select">
                                                                            </th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody>
                                                            </HeaderTemplate>
                                                            <ItemTemplate>
                                                                <tr>
                                                                    <td class="itemname">
                                                                        <asp:Literal ID="litVersionName" runat="server" Text='<%#Eval("IR_VersionName") %>' />
                                                                    </td>
                                                                    <td class="codenumber">
                                                                        <asp:Literal ID="litVersionCodeNumber" runat="server" Text='<%#Eval("IR_VersionCode") %>' />
                                                                    </td>
                                                                    <td class="orderdate">
                                                                        <%#CkartrisDisplayFunctions.FormatDate(Eval("O_Date"), "t", Session("LANG"))%>
                                                                    </td>
                                                                    <td class="select">
                                                                        <asp:UpdatePanel ID="updDownloadLinks" runat="server" UpdateMode="Conditional">
                                                                            <ContentTemplate>
                                                                                
                                                                                <asp:LinkButton OnCommand="lnkDownload_Click" CommandArgument='<%#Eval("V_DownloadInfo")%>'
                                                                                    ID="lnkDownload" runat="server" Text='<%$ Resources: ContentText_Download%>'
                                                                                    CssClass="link2" />
                                                                                <asp:HyperLink ID="hlnkDownload" runat="server" NavigateUrl='<%#Eval("V_DownloadInfo")%>'
                                                                                    Text='<%$ Resources: ContentText_Download%>' CssClass="link2" />
                                                                            </ContentTemplate>
                                                                            <Triggers>
                                                                                <asp:PostBackTrigger ControlID="lnkDownload" />
                                                                            </Triggers>
                                                                        </asp:UpdatePanel>
                                                                    </td>
                                                                </tr>
                                                            </ItemTemplate>
                                                            <FooterTemplate>
                                                                </tbody></table>
                                                            </FooterTemplate>
                                                        </asp:Repeater>
                                                    </div>
                                                </asp:PlaceHolder>
                                            </Content>
                                        </ajaxToolkit:AccordionPane>
                                        <%-- Tab: Saved Baskets --%>
                                        <ajaxToolkit:AccordionPane ID="acpSavedBaskets" runat="server" HeaderCssClass="accordionHeader"
                                            HeaderSelectedCssClass="accordionHeaderSelected" ContentCssClass="accordionContent">
                                            <Header>
                                                <h2>
                                                    <asp:Literal ID="litSubHeadingStoredBaskets" runat="server" Text='<%$ Resources: Kartris, SubHeading_StoredBaskets %>'
                                                        EnableViewState="false"></asp:Literal></h2>
                                            </Header>
                                            <Content>
                                                <asp:UpdatePanel ID="updSavedBaskets" runat="server" UpdateMode="Conditional">
                                                    <ContentTemplate>
                                                        <div class="savebaskets">
                                                            <% If rptSavedBasket.Items.Count <> 0 Then%>
                                                            <p>
                                                                <asp:Literal ID="litContentTextStoreBasketsDescRecent" runat="server" Text='<%$ Resources: Kartris, ContentText_StoreBasketsDescRecent %>'
                                                                    EnableViewState="false"></asp:Literal>
                                                            </p>
                                                            <asp:Repeater ID="rptSavedBasket" runat="server">
                                                                <HeaderTemplate>
                                                                    <div class="savebasketstable">
                                                                        <table class="filled">
                                                                            <thead>
                                                                                <tr class="headrow">
                                                                                    <th class="itemname">
                                                                                        <asp:Literal ID="litContentTextBasketName" runat="server" Text='<%$ Resources: Basket, ContentText_BasketName%>'
                                                                                            EnableViewState="false"></asp:Literal>
                                                                                    </th>
                                                                                    <th class="date">
                                                                                        <asp:Literal ID="litContentTextDateSaved" runat="server" Text='<%$ Resources: Kartris, ContentText_DateSaved%>'
                                                                                            EnableViewState="false"></asp:Literal>
                                                                                    </th>
                                                                                    <th class="select">
                                                                                        <asp:UpdateProgress ID="prgSavedBaskets" runat="server" AssociatedUpdatePanelID="updSavedBaskets"
                                                                                            DynamicLayout="true">
                                                                                            <ProgressTemplate>
                                                                                                <div class="loadingimage">
                                                                                                </div>
                                                                                                <div class="updateprogress">
                                                                                                </div>
                                                                                            </ProgressTemplate>
                                                                                        </asp:UpdateProgress>
                                                                                    </th>
                                                                                </tr>
                                                                            </thead>
                                                                            <tbody>
                                                                </HeaderTemplate>
                                                                <ItemTemplate>
                                                                    <tr>
                                                                        <td class="itemname">
                                                                            <div id="divBasketName" runat="server">
                                                                                <%#Eval("SBSKT_Name")%></div>
                                                                        </td>
                                                                        <td class="date">
                                                                            <%#CkartrisDisplayFunctions.FormatDate(Eval("SBSKT_DateTimeAdded"), "t", Session("LANG"))%>
                                                                        </td>
                                                                        <td class="select">
                                                                            <asp:LinkButton OnCommand="RemoveSavedBasket_Click" CommandName="RemoveSavedBasket"
                                                                                CommandArgument='<%#Eval("SBSKT_ID")%>' ID="lnkBtnDeleteSaveBasket" runat="server"
                                                                                Text='<%$ Resources: Kartris, ContentText_Delete%>' CssClass="link2 icon_delete normalweight"></asp:LinkButton>
                                                                            <asp:LinkButton OnCommand="LoadSavedBasket_Click" CommandName="LoadSavedBasket" CommandArgument='<%#Eval("SBSKT_ID")%>'
                                                                                ID="lnkBtnLoadSaveBasket" runat="server" Text='<%$ Resources: Kartris, ContentText_Load%>'
                                                                                CssClass="link2"></asp:LinkButton>
                                                                        </td>
                                                                    </tr>
                                                                </ItemTemplate>
                                                                <FooterTemplate>
                                                                    </tbody></table></div>
                                                                </FooterTemplate>
                                                            </asp:Repeater>
                                                            <div class="itempager">
                                                                <asp:LinkButton ID="lnkBtnBasketPrev" Text="&#171;" OnCommand="PageNavigate_Click"
                                                                    CommandName="Basket" runat="server" /><asp:LinkButton ID="lnkBtnBasketNext" Text="&#187;"
                                                                        OnCommand="PageNavigate_Click" CommandName="Basket" runat="server" />
                                                            </div>
                                                            <% Else%>
                                                            <p>
                                                                <asp:Literal ID="litContentTextNoSavedBaskets" runat="server" Text='<%$ Resources: Kartris, ContentText_NoSavedBaskets %>'></asp:Literal>
                                                            </p>
                                                            <br />
                                                            <% End If%>
                                                            <%If blnNoBasketItem <> True Then%>
                                                            <div>
                                                                <p>
                                                                    <a href="Customer.aspx?action=savebasket" class="link2 icon_save">
                                                                        <asp:Literal ID="litPageTitleSaveRecoverBasketContents" runat="server" Text='<%$ Resources: Basket, PageTitle_SaveRecoverBasketContents %>'></asp:Literal></a></p>
                                                                <p>
                                                                    <asp:Literal ID="litContentTextSaveRecoverBasketDesc" runat="server" Text='<%$Resources:Basket,ContentText_SaveRecoverBasketDesc %>'></asp:Literal></p>
                                                            </div>
                                                            <%End If%>
                                                        </div>
                                                    </ContentTemplate>
                                                </asp:UpdatePanel>
                                            </Content>
                                        </ajaxToolkit:AccordionPane>
                                        <%-- Tab: WishLists --%>
                                        <ajaxToolkit:AccordionPane ID="acpWishLists" runat="server" HeaderCssClass="accordionHeader"
                                            HeaderSelectedCssClass="accordionHeaderSelected" ContentCssClass="accordionContent">
                                            <Header>
                                                <h2>
                                                    <asp:Literal ID="litSubHeadingWishLists" runat="server" Text='<%$ Resources: Kartris, SubHeading_WishLists %>'></asp:Literal></h2>
                                            </Header>
                                            <Content>
                                                <asp:UpdatePanel ID="updWishlists" runat="server" UpdateMode="Conditional">
                                                    <ContentTemplate>
                                                        <div class="wishlists">
                                                            <% If rptWishLists.Items.Count <> 0 Then%>
                                                            <p>
                                                                <asp:Literal ID="litContentTextRecoverExistingWishList" runat="server" Text='<%$ Resources: Kartris, ContentText_RecoverExistingWishList %>'></asp:Literal></p>
                                                            <asp:Repeater ID="rptWishLists" runat="server">
                                                                <HeaderTemplate>
                                                                    <table class="filled">
                                                                        <thead>
                                                                            <tr class="headrow">
                                                                                <th class="itemname">
                                                                                    <asp:Literal ID="litContentTextWishListName" runat="server" Text='<%$ Resources: Kartris, ContentText_WishListName%>'></asp:Literal>
                                                                                </th>
                                                                                <th class="date">
                                                                                    <asp:Literal ID="litContentTextDateSaved" runat="server" Text='<%$ Resources: Kartris, ContentText_DateSaved%>'></asp:Literal>
                                                                                </th>
                                                                                <th class="select">
                                                                                    <asp:UpdateProgress ID="prgSavedBaskets" runat="server" AssociatedUpdatePanelID="updWishlists"
                                                                                        DynamicLayout="true">
                                                                                        <ProgressTemplate>
                                                                                            <div class="loadingimage">
                                                                                            </div>
                                                                                            <div class="updateprogress">
                                                                                            </div>
                                                                                        </ProgressTemplate>
                                                                                    </asp:UpdateProgress>
                                                                                </th>
                                                                            </tr>
                                                                        </thead>
                                                                        <tbody>
                                                                </HeaderTemplate>
                                                                <ItemTemplate>
                                                                    <tr>
                                                                        <td class="itemname">
                                                                            <a href='Wishlist.aspx?WishlistID=<%#Eval("WL_ID")%>' style="color: Black">
                                                                                <span id="spnWishListName" runat="server">
                                                                                </span>
                                                                            </a>
                                                                        </td>
                                                                        <td class="date">
                                                                            <%#CkartrisDisplayFunctions.FormatDate(Eval("WL_DateTimeAdded"), "t", Session("LANG"))%>
                                                                        </td>
                                                                        <td class="select">
                                                                            <asp:LinkButton CssClass="link2 icon_delete normalweight" OnCommand="RemoveWishLists_Click"
                                                                                CommandName="RemoveWishLists" CommandArgument='<%#Eval("WL_ID")%>' ID="lnkBtnDeleteWishLists"
                                                                                runat="server">
                                                                                <asp:Literal ID="litContentText_Delete" runat="server" Text='<%$ Resources: Kartris, ContentText_Delete %>'></asp:Literal></asp:LinkButton>
                                                                            <asp:LinkButton CssClass="link2 normalweight" OnCommand="EditWishLists_Click" CommandName="EditWishLists"
                                                                                CommandArgument='<%#Eval("WL_ID")%>' ID="lnkBtnEditWishLists" runat="server">
                                                                                <asp:Literal ID="litContentTextEdit" runat="server" Text='<%$ Resources: Kartris, ContentText_Edit %>'></asp:Literal></asp:LinkButton>
                                                                            <asp:LinkButton CssClass="link2" OnCommand="LoadWishLists_Click" CommandName="LoadWishLists"
                                                                                CommandArgument='<%#Eval("WL_ID")%>' ID="lnkBtnLoadWishListst" runat="server">
                                                                                <asp:Literal ID="litContentTextLoad" runat="server" Text='<%$ Resources: Kartris, ContentText_Load %>'></asp:Literal></asp:LinkButton>
                                                                        </td>
                                                                    </tr>
                                                                </ItemTemplate>
                                                                <FooterTemplate>
                                                                    </tbody></table>
                                                                </FooterTemplate>
                                                            </asp:Repeater>
                                                            <div class="itempager">
                                                                <asp:LinkButton ID="lnkBtnWishlistPrev" Text="&#171;" OnCommand="PageNavigate_Click"
                                                                    CommandName="Wishlist" runat="server" />
                                                                <asp:LinkButton ID="lnkBtnWishlistNext" Text="&#187;" OnCommand="PageNavigate_Click"
                                                                    CommandName="Wishlist" runat="server" />
                                                            </div>
                                                            <% Else%>
                                                            <p>
                                                                <asp:Literal ID="litContentTextNoWishLists" runat="server" Text='<%$ Resources: Kartris, ContentText_NoWishLists %>'></asp:Literal>
                                                            </p>
                                                            <br />
                                                            <% End If%>
                                                            <%If blnNoBasketItem <> True Then%>
                                                            <div>
                                                                <p>
                                                                    <a href="Customer.aspx?action=wishlists" class="link2 icon_wishlist">
                                                                        <asp:Literal ID="litContentTextSaveWishList" runat="server" Text='<%$ Resources: Basket, ContentText_SaveWishList %>'></asp:Literal></a></p>
                                                                <p>
                                                                    <asp:Literal ID="litContentTextSaveWishListDesc" runat="server" Text='<%$ Resources: Basket, ContentText_SaveWishListDesc %>'></asp:Literal></p>
                                                            </div>
                                                            <% End If%>
                                                            <div class="spacer">
                                                            </div>
                                                        </div>
                                                    </ContentTemplate>
                                                </asp:UpdatePanel>
                                            </Content>
                                        </ajaxToolkit:AccordionPane>
                                        <%-- Tab: Affiliates --%>
                                        <ajaxToolkit:AccordionPane ID="acpAffiliates" runat="server" HeaderCssClass="accordionHeader"
                                            HeaderSelectedCssClass="accordionHeaderSelected" ContentCssClass="accordionContent">
                                            <Header>
                                                <h2>
                                                    <asp:Literal ID="litContentTextAffiliateReferrals" runat="server" Text='<%$ Resources: Kartris, ContentText_AffiliateReferrals %>' /></h2>
                                            </Header>
                                            <Content>
                                                <asp:UpdatePanel ID="updAffiliates" runat="server" UpdateMode="Conditional">
                                                    <ContentTemplate>
                                                        <user:PopupMessage ID="UC_PopUpAffiliates" runat="server" />
                                                        <div class="affiliates">
                                                            <% If AFF_IsAffiliate Then%>
                                                            <% If AFF_AffiliateCommission > 0 Then%>
                                                            <div>
                                                                <p>
                                                                    <asp:Literal ID="litContentTextAffiliateLink" runat="server" Text='<%$ Resources: Kartris, ContentText_AffiliateLinkText %>' /></p>
                                                                <p>
                                                                    <strong>
                                                                        <%=CkartrisBLL.WebShopURL & "?af=" & CurrentLoggedUser.ID%></strong></p>
                                                            </div>
                                                            <br />
                                                            <div>
                                                                <p>
                                                                    <a href="CustomerAffiliates.aspx" class="link2">
                                                                        <asp:Literal ID="litContentTextToViewAffiliateActivity" runat="server" Text='<%$ Resources: Kartris, ContentText_ToViewAffiliateActivity %>' /></a></p>
                                                                <p>
                                                                    <a href="CustomerAffiliates.aspx?activity=balance" class="link2">
                                                                        <asp:Literal ID="litContentTextViewAccountBalance" runat="server" Text='<%$ Resources: Kartris, ContentText_ViewAccountBalance %>' /></a><p>
                                                            </div>
                                                            <% Else%>
                                                            <p>
                                                                <asp:Literal ID="litContentTextAffiliateApplicationPending" runat="server" Text='<%$ Resources: Kartris, ContentText_AffiliateApplicationPending %>' />
                                                            </p>
                                                            <% End If%>
                                                            <% Else%>
                                                            <p>
                                                                <asp:Literal ID="litContentTextNotAffiliateYet" runat="server" Text='<%$ Resources: Kartris, ContentText_NotAffiliateYet %>' />
                                                                <asp:LinkButton OnCommand="Affiliate_Click" CommandName="Apply" ID="lnkCustomerCodeClickHere"
                                                                    runat="server" Text='<%$ Resources: Kartris, ContentText_CustomerCodeClickHere %>' />
                                                            </p>
                                                            <% End If%>
                                                        </div>
                                                    </ContentTemplate>
                                                </asp:UpdatePanel>
                                            </Content>
                                        </ajaxToolkit:AccordionPane>
                                        <%-- Tab: Mailing List --%>
                                        <ajaxToolkit:AccordionPane ID="acpMailingList" runat="server" HeaderCssClass="accordionHeader"
                                            HeaderSelectedCssClass="accordionHeaderSelected" ContentCssClass="accordionContent">
                                            <Header>
                                                <h2>
                                                    <asp:Literal ID="litPageTitleMailingList" runat="server" Text='<%$ Resources: Kartris, PageTitle_MailingList %>'></asp:Literal></h2>
                                            </Header>
                                            <Content>
                                                <asp:UpdatePanel ID="updMailingList" runat="server" UpdateMode="Conditional">
                                                    <ContentTemplate>
                                                        <div class="mailinglistpreference">
                                                            <user:PopupMessage ID="UC_PopUpMessage" runat="server" />
                                                            <% 	If ML_ConfirmationDateTime > New Date(1900, 1, 1) Then%>
                                                            <p>
                                                                <asp:Literal ID="litContentTextEmailNotVerified" runat="server" Text='<%$ Resources: Kartris, ContentText_EmailVerified %>' />
                                                            </p>
                                                            <div>
                                                                <asp:DropDownList ID="ddlMailingList" runat="server">
                                                                </asp:DropDownList>
                                                                <asp:Button CssClass="button" OnCommand="MailingList_Click" CommandName="MailVerified"
                                                                    ID="btnMailVerified" runat="server" Text='<%$ Resources: Kartris, ContentText_Change %>' />
                                                            </div>
                                                            <% 	ElseIf ML_SignupDateTime > New Date(1900, 1, 1) Then%>
                                                            <p>
                                                                <asp:Literal ID="litContentTextEmailNotVerified2" runat="server" Text='<%$ Resources: Kartris, ContentText_EmailNotVerified %>' />
                                                            </p>
                                                            <div>
                                                                <asp:LinkButton OnCommand="MailingList_Click" CommandName="MailNotVerified" ID="lnkBtnMailNotVerified"
                                                                    CssClass="link2" runat="server" Text='<%$ Resources: Kartris, ContentText_SendVerificationMail %>' />
                                                            </div>
                                                            <% Else%>
                                                            <p>
                                                                <asp:Literal ID="litContentTextEmailNotSignedUp" runat="server" Text='<%$ Resources: Kartris, ContentText_EmailNotSignedUp %>' />
                                                            </p>
                                                            <div>
                                                                <asp:LinkButton OnCommand="MailingList_Click" CommandName="MailNotSigned" ID="lnkBtnMailNotSigned"
                                                                    CssClass="link2" runat="server" Text='<%$ Resources: Kartris, ContentText_SendVerificationMail %>' />
                                                            </div>
                                                            <% End If%>
                                                        </div>
                                                        <br />
                                                    </ContentTemplate>
                                                </asp:UpdatePanel>
                                            </Content>
                                        </ajaxToolkit:AccordionPane>
                                    </Panes>
                                </ajaxToolkit:Accordion>
                        </asp:PlaceHolder>
                    </ContentTemplate>
                </asp:UpdatePanel>
                <!-- end of home -->
                <!-- start of save wishlists -->
                <%If KartSettingsManager.GetKartConfig("frontend.users.wishlists.enabled") <> "n" And KartSettingsManager.GetKartConfig("frontend.users.myaccount.wishlists.enabled") <> "n" Then%>
                <asp:UpdatePanel ID="updSaveWishLists" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:Panel ID="pnlSaveWishLists" runat="server" DefaultButton="lnkbtnSubmit">
                            <asp:PlaceHolder ID="phdSaveWishLists" runat="server" Visible="false">
                                <h1>
                                    <asp:Literal ID="litContentTextSaveWishList2" runat="server" Text='<%$ Resources: Basket, ContentText_SaveWishList %>'></asp:Literal></h1>
                                <asp:Literal ID="litSaveWishlistsError" runat="server"></asp:Literal>
                                <div class="wishlist Kartris-DetailsView">
                                    <div class="Kartris-DetailsView-Data">
                                        <ul>
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Label ID="lblName" runat="server" Text='<%$ Resources: Kartris, ContentText_WishListName %>'
                                                    AssociatedControlID="txtWL_Name" CssClass="requiredfield"></asp:Label></span><span
                                                        class="Kartris-DetailsView-Value">
                                                        <asp:TextBox MaxLength="200" ID="txtWL_Name" runat="server"></asp:TextBox><asp:RequiredFieldValidator
                                                            EnableClientScript="True" ID="valWL_Name" runat="server" ControlToValidate="txtWL_Name"
                                                            ValidationGroup="SaveWishlist" CssClass="error" ForeColor="" Display="Dynamic"
                                                            Text="<%$ Resources: Kartris, ContentText_RequiredField %>"></asp:RequiredFieldValidator></span></li>
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Label ID="lblPublicPassword" runat="server" Text='<%$ Resources: Kartris, ContentText_WishListPublicPassword %>'
                                                    AssociatedControlID="txtWL_PublicPassword" CssClass="requiredfield"></asp:Label></span><span
                                                        class="Kartris-DetailsView-Value">
                                                        <asp:TextBox MaxLength="10" ID="txtWL_PublicPassword" runat="server"></asp:TextBox><asp:RequiredFieldValidator
                                                            EnableClientScript="True" ID="valWL_PublicPassword" runat="server" ControlToValidate="txtWL_PublicPassword"
                                                            ValidationGroup="SaveWishlist" CssClass="error" ForeColor="" Display="Dynamic"
                                                            Text="<%$ Resources: Kartris, ContentText_RequiredField %>"></asp:RequiredFieldValidator></span></li>
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Label ID="lblPersonalMessage" runat="server" Text='<%$ Resources: Kartris, ContentText_WishListPersonalMessage %>'
                                                    AssociatedControlID="txtWL_Message"></asp:Label></span><span class="Kartris-DetailsView-Value">
                                                        <asp:TextBox Rows="12" TextMode="MultiLine" Wrap="true" ID="txtWL_Message" runat="server"
                                                            MaxLength="1000"></asp:TextBox>
                                                        <asp:Literal ID="litExplanation" runat="server"></asp:Literal></span></li>
                                        </ul>
                                        <div class="submitbuttons">
                                            <asp:Button OnCommand="SaveWishLists_Click" ID="lnkbtnSubmit" runat="server" CssClass="button"
                                                Text='<%$ Resources: Kartris,FormLabel_Save %>' ValidationGroup="SaveWishlist" />
                                            <asp:ValidationSummary ValidationGroup="SaveWishlist" ID="valSummary" runat="server"
                                                CssClass="valsummary" DisplayMode="BulletList" ForeColor="" HeaderText="<%$ Resources: Kartris, ContentText_Errors %>" />
                                            <asp:Button ID="btnCancel" runat="server" CssClass="button cancel" Text="<%$ Resources:Kartris, FormButton_Cancel %>" />
                                        </div>
                                    </div>
                                </div>
                            </asp:PlaceHolder>
                        </asp:Panel>
                    </ContentTemplate>
                </asp:UpdatePanel>
                <% End If%>
                <!-- end of save wishlists -->
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
</asp:Content>
