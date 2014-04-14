<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductVersions.ascx.vb"
    Inherits="ProductVersions" %>

<div class="versions">
    <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:MultiView ID="mvwVersion" runat="server" ActiveViewIndex="0">
                <asp:View ID="viwEmpty" runat="server">
                </asp:View>
                <asp:View ID="viwSelect" runat="server">
                 <!-- select display -->
                    <asp:FormView ID="fvwPrice" runat="server">
                        <ItemTemplate>
                            <%-- weight --%>
                            <asp:Panel EnableViewState="false" ID="pnlWeight" runat="server" Visible='<%# KartSettingsManager.GetKartConfig("frontend.versions.showweight") = "y" %>'>
                                <span class="weight">
                                    <asp:Literal EnableViewState="false" ID="litLS_Weight" runat="server" Text="<%$ Resources: _Version, FormLabel_VersionWeight %>" />
                                    <span class="figure">
                                        <asp:Literal ID="litWeight_Rows" runat="server" Text='<%# Eval("V_Weight") %>' EnableViewState="false" />
                                        <%= KartSettingsManager.GetKartConfig("general.weightunit") %></span></span>
                            </asp:Panel>
                            <div id="divTax" EnableViewState="false" runat="server" visible='<%# Iif( ObjectConfigBLL.GetValue("K:product.callforprice", ProductID) = 1, False, True) %>'>
                                <!-- ex tax / inc tax prices -->
                                <asp:Panel EnableViewState="false" ID="pnlExIncTax" runat="server" Visible="false">
                                <div class="prices">
                                    <span class="extax">
                                        <asp:Literal ID="litLS_ExTax" runat="server" Text="<%$ Resources: Kartris, ContentText_ExTax %>" EnableViewState="false" />
                                        <span class="figure">
                                            <asp:Literal ID="litCalculatedTax_Rows" runat="server" Text='<%# Eval("CalculatedTax") %>'
                                                Visible="false" EnableViewState="false" />
                                            <asp:Literal ID="litResultedCalculatedTax_Rows" runat="server" EnableViewState="false" /></span></span>
                                    <% If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" Then%>
                                    <span class="inctax">
                                        <asp:Literal ID="litLS_IncTax" runat="server" Text="<%$ Resources: Kartris, ContentText_IncTax %>" EnableViewState="false" />
                                        <span class="figure">
                                            <asp:Literal ID="litIncTax_Rows" runat="server" Text='<%# Eval("V_Price") %>' Visible="false" EnableViewState="false" />
                                            <asp:Literal ID="litResultedIncTax_Rows" runat="server" EnableViewState="false" /></span>
                                        <% End If%>
                                </div>
                            </asp:Panel>
                                <!-- ex tax / tax % prices -->
                                <asp:Panel ID="pnlExTaxTax" runat="server" Visible="false" EnableViewState="false">
                                <div class="prices">
                                    <span class="extax">
                                        <asp:Literal ID="litLS_ExTax2" runat="server" Text="<%$ Resources: Kartris, ContentText_ExTax %>" EnableViewState="false" />
                                        <asp:Literal ID="litExTax_Rows" runat="server" Text='<%# Eval("V_Price") %>' Visible="false" EnableViewState="false" />
                                        <span class="figure">
                                            <asp:Literal ID="litResultedExTax_Rows" runat="server" EnableViewState="false" /></span></span>
                                    <span class="tax">
                                        <asp:Literal ID="litLS_Tax" runat="server" Text="<%$ Resources: Kartris, ContentText_Tax %>" EnableViewState="false" />
                                        <span class="figure">
                                            <asp:Literal ID="litTaxRate_Rows" runat="server" Text='<%# Eval("T_TaxRate") %>'
                                                Visible="false" EnableViewState="false" />
                                            <asp:Literal ID="litResultedTaxRate_Rows" runat="server" EnableViewState="false" /></span></span>
                                </div>
                            </asp:Panel>
                            </div>
                            <!-- single price -->
                            <div class="boxinset line">
                                <div class="addtobasket">
                                    <asp:Panel ID="pnlPrice" runat="server" Visible="false" EnableViewState="false">
                                        <div class="prices">
                                            <span class="price">
                                                <asp:Literal EnableViewState="false" ID="litLS_Price" runat="server" Text="<%$ Resources: Kartris, ContentText_Price %>" />
                                                <span class="figure">
                                                    <asp:Literal ID="litPrice_Rows" runat="server" Text='<%# Eval("V_Price") %>' Visible="false" EnableViewState="false" />
                                                    <asp:Literal ID="litResultedPrice_Rows" runat="server" EnableViewState="false" /></span></span>
                                        </div>
                                    </asp:Panel>
                                    <asp:UpdatePanel ID="updVersionQty1" runat="server" UpdateMode="Conditional" RenderMode="Block">
                                        <ContentTemplate>
                                            <%  'Hide 'add' button and selector if in cataloguemode or for partial access
                                                '(hidden prices unless user logged in)
                                                If KartSettingsManager.GetKartConfig("frontend.cataloguemode") <> "y" And Not CheckHideAddButton() Then%>
                                                <% 'the div below is hidden if it is a 'call for prices' version %>
                                            <div class="selector" runat="server">
                                                <asp:PlaceHolder ID="phdNotOutOfStock1" runat="server" Visible='<%# Iif((Eval("V_Quantity") < 1 And Eval("V_QuantityWarnLevel") > 0) AND (KartSettingsManager.GetKartConfig("frontend.orders.allowpurchaseoutofstock") <> "y"), False, True) %>'>
                                                    <asp:PlaceHolder EnableViewState="false" ID="phdCustomizable" runat="server" Visible='<%# Eval("V_CustomizationType") <> "n" %>'>
                                                        <div class="cancustomizetag" title="<asp:Literal ID='litContentTextCanCustomize1' Text='<%$ Resources: Products, ContentText_CanCustomize %>' runat='server'></asp:Literal>">
                                                        </div> 
                                                    </asp:PlaceHolder>
                                                    <user:AddPane ID="UC_AddToBasketQty1" runat="server" HasAddButton="True" CanCustomize='<%# Eval("V_CustomizationType") <> "n" %>' OnWrongQuantity="AddWrongQuantity"
                                                        VersionID='<%# Eval("V_ID") %>' visible='<%# Iif( ObjectConfigBLL.GetValue("K:product.callforprice", ProductID) = 1, False, True) %>' />
                                                </asp:PlaceHolder>
                                                <asp:PlaceHolder EnableViewState="false" ID="phdOutOfStock1" runat="server" Visible='<%# Iif((Eval("V_Quantity") < 1 And Eval("V_QuantityWarnLevel") > 0) AND (KartSettingsManager.GetKartConfig("frontend.orders.allowpurchaseoutofstock") <> "y"), True, False) %>'>
                                                    <div class="outofstock">
                                                        <asp:Literal ID="litOutOfStockMessage1" runat="server" Text="<%$ Resources: Versions, ContentText_AltOutOfStock %>" /></div>
                                                </asp:PlaceHolder>
                                                <asp:PlaceHolder EnableViewState="false" ID="phdCallForPrice1" runat="server" Visible='<%# Iif( NOT((Eval("V_Quantity") < 1 And Eval("V_QuantityWarnLevel") > 0) AND (KartSettingsManager.GetKartConfig("frontend.orders.allowpurchaseoutofstock") <> "y")) AND ObjectConfigBLL.GetValue("K:product.callforprice", ProductID) = 1, True, False) %>'>
                                                    <asp:Literal ID="litContentTextCallForPrice" runat="server" Text="<%$ Resources: Versions, ContentText_CallForPrice %>" />
                                                </asp:PlaceHolder>
                                            </div>
                                            <% End If%>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:FormView>
                </asp:View>
                <asp:View ID="viwError" runat="server">
                    <span class="error">
                        <asp:Literal ID="litError" runat="server" Text="<%$ Resources: Kartris, ContentText_ContentNotAvailable %>"></asp:Literal></span>
                </asp:View>
                <!-- multi-version rows -->
                <asp:View ID="viwVersionRows" runat="server">
                        <asp:UpdatePanel ID="updVersions" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:DropDownList ID="ddlVersionImages" runat="server" Visible="true" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                        <asp:UpdatePanel ID="updVersionsTabular" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <table>
                                    <colgroup class="col_name" />
                                    <%--Weight--%>
                                    <%
                                        If KartSettingsManager.GetKartConfig("frontend.versions.showweight") = "y" Then
                                    %>
                                    <colgroup class="col_weight" />
                                    <% End If%>
                                    <!-- RRP -->
                                    <%
                                        If KartSettingsManager.GetKartConfig("frontend.versions.display.showrrp") = "y" Then
                                    %>
                                    <colgroup class="col_rrp hide-for-small" />
                                    <% End If%>
                                    <!-- Stock level -->
                                    <%
                                        If KartSettingsManager.GetKartConfig("frontend.versions.display.showstock") = "y" Then
                                    %>
                                    <colgroup class="col_stock" />
                                    <% End If%>
                                    <colgroup class="col_price" />
                                    <colgroup class="col_addtobasket" />
                                    <thead>
                                        <tr class="headrow">
                                            <th class="info">
                                            </th>
                                            <%--Weight--%>
                                            <%If KartSettingsManager.GetKartConfig("frontend.versions.showweight") = "y" Then%>
                                            <th class="weight">
                                                <asp:Literal ID="litLS_Weight" runat="server" Text="<%$ Resources: _Version, FormLabel_VersionWeight %>" EnableViewState="false" />
                                            </th>
                                            <% End If%>
                                            <!-- RRP -->
                                            <%
                                                If KartSettingsManager.GetKartConfig("frontend.versions.display.showrrp") = "y" andalso _
                                                    ObjectConfigBLL.GetValue("K:product.callforprice", ProductID) <> 1 Then
                                            %>
                                            <th class="rrp hide-for-small">
                                                <asp:Literal ID="litLS_RRP" runat="server" Text="<%$ Resources: Versions, ContentText_RRP %>" EnableViewState="false" />
                                            </th>
                                            <% End If%>
                                            <!-- Stock level -->
                                            <%
                                                If KartSettingsManager.GetKartConfig("frontend.versions.display.showstock") = "y" Then
                                            %>
                                            <th>
                                                <asp:Literal ID="litLS_Stock" runat="server" Text="<%$ Resources: Versions, ContentText_Stock %>" EnableViewState="false" />
                                            </th>
                                            <% End If%>
                                            <%  If ObjectConfigBLL.GetValue("K:product.callforprice", ProductID) <> 1 Then ' 'Call For Price' check
                                                    'Tax Columns
                                                    If KartSettingsManager.GetKartConfig("frontend.display.showtax") = "y" Then%>
                                            <th class="price extax">
                                                <asp:Literal ID="litLS_ExTax" runat="server" Text="<%$ Resources: Kartris, ContentText_ExTax %>" EnableViewState="false" />
                                            </th>
                                            <% If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" Then%>
                                            <% If KartSettingsManager.GetKartConfig("general.tax.pricesinctax") = "y" Then%>
                                            <th class="price inctax">
                                                <asp:Literal ID="litLS_IncTax" runat="server" Text="<%$ Resources: Kartris, ContentText_IncTax %>" EnableViewState="false" />
                                            </th>
                                            <% Else%>
                                            <th class="price tax">
                                                <asp:Literal ID="litLS_Tax" runat="server" Text="<%$ Resources: Kartris, ContentText_Tax %>" EnableViewState="false" />
                                            </th>
                                            <%  End If%>
                                            <% End If%>
                                            <%Else%>
                                            <th class="price">
                                                <asp:Literal ID="litLS_Price" runat="server" Text="<%$ Resources: Kartris, ContentText_Price %>" EnableViewState="false" />
                                            </th>
                                            <%  End If 'Tax Columns %>
                                            <%Else ' call for price%>
                                            <th class="price">
                                                <asp:Literal ID="litCallForPriceHeader" runat="server" EnableViewState="false" Text="<%$ Resources: Kartris, ContentText_Price %>" />
                                            </th>
                                            <%End If ' call for price%>
                                            <%
                                                'Hide 'add' button and selector if in cataloguemode or for partial access
                                                '(hidden prices unless user logged in)
                                                If KartSettingsManager.GetKartConfig("frontend.cataloguemode") <> "y" And Not CheckHideAddButton() Then%>
                                            <th class="addtobasket">
                                            </th>
                                            <%  End If%>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <asp:Repeater ID="rptRows" runat="server">
                                            <ItemTemplate>
                                                <tr>
                                                    <%
                                                        'COUNT TOTAL COLUMNS
                                                        'Unfortunately, IE6 does not accept
                                                        'the 'colspan=0' syntax so we
                                                        'cannot stretch the version desc
                                                        'cell across all rows simply because
                                                        'the number of columns displayed can
                                                        'vary depending on config settings.
                                                        'So we need to keep a running total
                                                        'and set the colspan accordingly.
                                                        Dim intColSpan As Integer = 3
                                                    %>
                                                    <td class="info">
                                                        <%--
                                                        =====================================
                                                        VERSION IMAGE (if any)
                                                        =====================================
                                                        --%>
                                                        <asp:PlaceHolder ID="phdVersionImage" runat="server">
                                                            <user:ImageViewer ID="UC_ImageViewer_Rows" runat="server" />
                                                        </asp:PlaceHolder>

                                                        <%--
                                                        =====================================
                                                        VERSION NAME, CODE & DESCRIPTION
                                                        =====================================
                                                        --%>
                                                        <asp:Label ID="lblVID_Rows" runat="server" Text='<%# Eval("V_ID") %>' Visible="False" EnableViewState="false"></asp:Label>
                                                        <asp:Label ID="lblName_Rows" runat="server" Text='<%# Eval("V_Name") %>' EnableViewState="false" CssClass="name"></asp:Label>
                                                        <asp:Label ID="lblCode_Rows" runat="server" Text='<%# Eval("V_CodeNumber") %>' EnableViewState="false" CssClass="codenumber"></asp:Label>
                                                        <% If KartSettingsManager.GetKartConfig("frontend.versions.display.showextrasku") = "y" Then%>
                                                        <asp:Label ID="lblExtraCode_Rows" runat="server" Text='<%# Eval("V_ExtraCodeNumber") %>' EnableViewState="false" CssClass="codenumber"></asp:Label>
                                                        <% End If %>
                                                        <asp:Label ID="lblDesc_Rows" runat="server" Text='<%# Eval("V_Desc") %>' Visible='<%# CkartrisDataManipulation.FixNullFromDB(Eval("V_Desc")) IsNot Nothing AndAlso Len(Eval("V_Desc"))> 0 %>' EnableViewState="false" CssClass="description"></asp:Label>

                                                        <%--
                                                        =====================================
                                                        MEDIA GALLERY
                                                        =====================================
                                                        --%>
                                                        <asp:PlaceHolder ID="phdMediaGallery" runat="server">
                                                            <user:MediaGallery ID="UC_VersionMediaGallery" ParentID='<%# Eval("V_ID") %>' ParentType="v"
                                                                    runat="server" />
                                                        </asp:PlaceHolder>   
                                                    </td>
                                                    <%
                                                        ' Weight
                                                        If KartSettingsManager.GetKartConfig("frontend.versions.showweight") = "y" Then
                                                            intColSpan += 1
                                                    %>
                                                    <td class="weight">
                                                        <asp:Literal ID="litWeight_Rows" runat="server" Text='<%# Eval("V_Weight") %>' EnableViewState="false" />
                                                        <%= KartSettingsManager.GetKartConfig("general.weightunit") %>
                                                    </td>
                                                    <% End If%>
                                                    <%
                                                        'SHOW RRP
                                                        If KartSettingsManager.GetKartConfig("frontend.versions.display.showrrp") = "y" AndAlso _
                                                            ObjectConfigBLL.GetValue("K:product.callforprice", ProductID) <> 1 Then
                                                            intColSpan += 1
                                                    %>
                                                    <td class="rrp hide-for-small">
                                                        <asp:Literal ID="litRRP_Rows" runat="server" Text='<%# Eval("V_RRP") %>' Visible='<%# Eval("V_RRP") > 0 %>' EnableViewState="false" />
                                                    </td>
                                                    <% End If%>
                                                    <%
                                                        'SHOW STOCK LEVEL
                                                        If KartSettingsManager.GetKartConfig("frontend.versions.display.showstock") = "y" Then
                                                            intColSpan += 1
                                                    %>
                                                    <td class="stock">
                                                        <asp:Label ID="lblStock_Rows" runat="server" Text='<%# Eval("V_Quantity") %>' EnableViewState="false"></asp:Label>
                                                    </td>
                                                    <% End If%>
                                                    <%  If ObjectConfigBLL.GetValue("K:product.callforprice", ProductID) <> 1 Then ' 'Call For Price' check
                                                            ' Tax Columns ..---------------------
                                                            If KartSettingsManager.GetKartConfig("frontend.display.showtax") = "y" Then
                                                                If KartSettingsManager.GetKartConfig("general.tax.pricesinctax") = "y" Then%>
                                                    <td class="price extax">
                                                        <asp:Literal ID="litCalculatedTax_Rows" runat="server" Text='<%# Eval("CalculatedTax") %>'
                                                            Visible="false" EnableViewState="false" />
                                                        <asp:Literal ID="litResultedCalculatedTax_Rows" runat="server" EnableViewState="false" />
                                                    </td>
                                                                    <% If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" Then%>
                                                    <td class="price inctax">
                                                        <asp:Literal ID="litIncTax_Rows" runat="server" Text='<%# Eval("V_Price") %>' Visible="false" EnableViewState="false" />
                                                        <asp:Literal ID="litResultedIncTax_Rows" runat="server" EnableViewState="false" />
                                                    </td>
                                                                    <%End If%>
                                                                <%Else%>
                                                    <td class="price extax">
                                                        <asp:Literal ID="litExTax_Rows" runat="server" Text='<%# Eval("V_Price") %>' Visible="false" EnableViewState="false" />
                                                        <asp:Literal ID="litResultedExTax_Rows" runat="server" EnableViewState="false" />
                                                    </td>
                                                                    <% If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" Then%>
                                                    <td class="price tax">
                                                        <asp:Literal ID="litTaxRate_Rows" runat="server" Text='<%# Eval("T_TaxRate") %>'
                                                            Visible="false" EnableViewState="false" />
                                                        <asp:Literal ID="litResultedTaxRate_Rows" runat="server" EnableViewState="false" />
                                                    </td>
                                                                    <%End If%>
                                                                <%End If%>
                                                            <%  Else%>
                                                    <td class="price">
                                                        <asp:Literal ID="litPrice_Rows" runat="server" Text='<%# Eval("V_Price") %>' Visible="false" EnableViewState="false" />
                                                        <asp:Literal ID="litResultedPrice_Rows" runat="server" EnableViewState="false" />
                                                    </td>
                                                            <%  End If ' Tax Columns ..---------------------
                                                        Else %>
                                                    <td class="price">
                                                        <asp:Literal ID="litCallForPrice" runat="server" EnableViewState="false" Text="<%$ Resources: Versions, ContentText_CallForPrice %>" />
                                                    </td>
                                                    <%End If ' callfor price %>
                                                    <%  'Hide 'add' button and selector if in cataloguemode or for partial access
                                                        '(hidden prices unless user logged in)
                                                        If KartSettingsManager.GetKartConfig("frontend.cataloguemode") <> "y" And Not CheckHideAddButton() Then
                                                    %>
                                                    <td class="addtobasket">
                                                        <asp:PlaceHolder ID="phdCustomizable" runat="server" Visible='<%# Eval("V_CustomizationType") <> "n" %>'>
                                                            <div class="cancustomizetag" title="<asp:Literal ID='litContentTextCanCustomize2' Text='<%$ Resources: Products, ContentText_CanCustomize %>' runat='server'></asp:Literal>">
                                                            </div>
                                                        </asp:PlaceHolder>
                                                        <asp:PlaceHolder ID="phdNotOutOfStock2" runat="server" Visible='<%# Iif((Eval("V_Quantity") < 1 And Eval("V_QuantityWarnLevel") > 0) AND (KartSettingsManager.GetKartConfig("frontend.orders.allowpurchaseoutofstock") <> "y"), False, True) %>'>
                                                            <asp:UpdatePanel ID="updVersionQty2" runat="server" UpdateMode="Conditional" RenderMode="Inline">
                                                                <ContentTemplate>
                                                                    <user:AddPane ID="UC_AddToBasketQty2" runat="server" HasAddButton="True" CanCustomize='<%# Eval("V_CustomizationType") <> "n" %>'
                                                                        VersionID='<%# Eval("V_ID") %>' visible='<%# Iif( ObjectConfigBLL.GetValue("K:product.callforprice", ProductID) = 1, False, True) %>'
                                                                        OnWrongQuantity="AddWrongQuantity" />
                                                                </ContentTemplate>
                                                            </asp:UpdatePanel>
                                                        </asp:PlaceHolder>
                                                        <asp:PlaceHolder ID="phdOutOfStock2" runat="server" Visible='<%# Iif((Eval("V_Quantity") < 1 And Eval("V_QuantityWarnLevel") > 0) AND (KartSettingsManager.GetKartConfig("frontend.orders.allowpurchaseoutofstock") <> "y"), True, False) %>'>
                                                            <div class="outofstock">
                                                                <asp:Literal ID="litOutOfStockMessage2" runat="server" Text="<%$ Resources: Versions, ContentText_AltOutOfStock %>" /></div>
                                                        </asp:PlaceHolder>
                                                    </td>
                                                    <% End If%>
                                                </tr>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </tbody>
                                </table>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                </asp:View>
                <asp:View ID="viwVersionDropDown" runat="server">
                 <!-- multi-version dropdown -->
                    <div class="boxinset line multipleversiondropdown">
                        <div class="addtobasket row" runat="server">
                            <asp:UpdatePanel ID="updVersionDropdown" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <div class="small-12 large-9 columns">
                                        <asp:DropDownList ID="ddlName_DropDown" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlName_DropDown_SelectedIndexChanged">
                                        </asp:DropDownList><asp:TextBox runat="server" ID="txtOutOfStockItems" Visible="false">
                                        </asp:TextBox>
                                    </div>

                                    <%  'Hide 'add' button and selector if in cataloguemode or for partial access
                                        '(hidden prices unless user logged in)
                                        If KartSettingsManager.GetKartConfig("frontend.cataloguemode") <> "y" And Not CheckHideAddButton() Then%>
                                    <div class="selector small-12 large-3 columns">
                                        <asp:UpdatePanel ID="updVersionQty3" runat="server" UpdateMode="Conditional" RenderMode="Block">
                                            <ContentTemplate>
                                                <asp:Literal runat="server" ID="litShow"></asp:Literal>
                                                <asp:PlaceHolder ID="phdNotOutOfStock3" runat="server">
                                                    <asp:PlaceHolder ID="phdDropdownCustomizable" runat="server">
                                                        <div class="cancustomizetag" title="<asp:Literal ID='litContentTextCanCustomize3' Text='<%$ Resources: Products, ContentText_CanCustomize %>' runat='server'></asp:Literal>">
                                                        </div>
                                                    </asp:PlaceHolder>
                                                    <user:AddPane ID="UC_AddToBasketQty3" runat="server" HasAddButton="False" />
                                                    <asp:UpdatePanel ID="updAddVersions3" runat="server" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:Button ID="btnAddVersions3" runat="server" CssClass="button" Text="<%$ Resources: Products, FormButton_Add %>" />
                                                        </ContentTemplate>
                                                    </asp:UpdatePanel>
                                                </asp:PlaceHolder>
                                                <asp:PlaceHolder ID="phdOutOfStock3" runat="server" Visible="false">
                                                    <div class="outofstock">
                                                        <asp:Literal ID="litOutOfStockMessage3" runat="server" Text="<%$ Resources: Versions, ContentText_AltOutOfStock %>" />
                                                    </div>
                                                </asp:PlaceHolder>
                                                <asp:PlaceHolder ID="phdCalForPrice3" runat="server" Visible="false">
                                                    <asp:Literal ID="litCallForPrice3" runat="server" Text="<%$ Resources: Versions, ContentText_CallForPrice %>" />
                                                </asp:PlaceHolder>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </div>
                                    <% End If%>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                        <div class="spacer">
                        </div>
                    </div>
                </asp:View>
                <asp:View ID="viwVersionOptions" runat="server">
                 <!-- options -->
                    <asp:Label ID="lblVID_Options" runat="server" Visible="False"></asp:Label>
                    <asp:UpdatePanel ID="updOptionsContainer" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <user:OptionsContainer ID="UC_OptionsContainer" runat="server" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    <div class="boxinset line">
                        <div class="addtobasket">
                            <div class="prices">
                                <asp:UpdatePanel ID="updPricePanel" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <%
                                            'Store base item price and tax rate
                                        %>
                                        <asp:Literal ID="litPriceHidden" runat="server" Visible="false" />
                                        <asp:Literal ID="litTaxRateHidden" runat="server" Visible="false" />
                                        <%
                                            'ex tax
                                        %>
                                        <asp:PlaceHolder ID="phdExTax" runat="server" Visible="false"><span class="extax">
                                            <asp:Literal ID="litExTaxLabel" runat="server" Text="<%$ Resources: Kartris, ContentText_ExTax %>" />
                                            <span class="figure">
                                                <asp:Literal ID="litExTax" runat="server" /></span></span> </asp:PlaceHolder>
                                        <%
                                            'inc tax
                                            If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" Then%>
                                        <asp:PlaceHolder ID="phdIncTax" runat="server" Visible="false"><span class="inctax">
                                            <asp:Literal ID="litIncTaxLabel" runat="server" Text="<%$ Resources: Kartris, ContentText_IncTax %>" />
                                            <span class="figure">
                                                <asp:Literal ID="litIncTax" runat="server" /></span></span> </asp:PlaceHolder>
                                        <%  End If%>
                                        <%
                                            'tax
                                        %>
                                        <asp:PlaceHolder ID="phdTax" runat="server" Visible="false"><span class="inctax">
                                            <asp:Literal ID="litTaxRateLabel" runat="server" Text="<%$ Resources: Kartris, ContentText_Tax %>" />
                                            <span class="figure">
                                                <asp:Literal ID="litTaxRate" runat="server" /></span></span></asp:PlaceHolder>
                                        <%
                                            'price
                                        %>
                                        <asp:PlaceHolder ID="phdPrice" runat="server" Visible="false"><span class="price">
                                            <asp:Literal ID="litPriceLabel" runat="server" Text="<%$ Resources: Kartris, ContentText_Price %>" />
                                            <span class="figure">
                                                <asp:Literal ID="litPriceView" runat="server" /></span></span></asp:PlaceHolder>

                                                <asp:PlaceHolder ID="phdNoValidCombinations" runat="server" Visible="false">
                                                <span class="novalidcombinations">
                                                <asp:Literal ID="litContentTextNoValidCombinations" runat="server" Text="<%$ Resources: Options, ContentText_NoValidCombinations %>" />
                                                </span></asp:PlaceHolder>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                            <div class="selector">
                                <asp:UpdatePanel ID="updOptions" runat="server" UpdateMode="Conditional" RenderMode="Block">
                                    <ContentTemplate>
                                        <%  'Hide 'add' button and selector if in cataloguemode or for partial access
                                            '(hidden prices unless user logged in)
                                            If KartSettingsManager.GetKartConfig("frontend.cataloguemode") <> "y" And Not CheckHideAddButton() Then%>
                                        <asp:PlaceHolder ID="phdOptionsCustomizable" runat="server">
                                            <div class="cancustomizetag" title="<asp:Literal ID='litContentTextCanCustomize4' Text='<%$ Resources: Products, ContentText_CanCustomize %>' runat='server'></asp:Literal>">
                                            </div>
                                        </asp:PlaceHolder>
                                        <user:AddPane ID="UC_AddToBasketQty4" runat="server" HasAddButton="False" />
                                        <asp:PlaceHolder ID="phdNotOutOfStock4" runat="server">
                                            <asp:UpdatePanel ID="updAddOptions" runat="server" UpdateMode="Conditional" RenderMode="Inline">
                                                <ContentTemplate>
                                                    <asp:Button ID="btnAdd_Options" runat="server" CssClass="button" Text="<%$ Resources: Products, FormButton_Add %>" />
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </asp:PlaceHolder>
                                        <asp:PlaceHolder ID="phdOutOfStock4" runat="server" Visible="false">
                                            <div class="outofstock">
                                                <asp:Literal ID="litContentText_AltOutOfStock" runat="server" Text="<%$ Resources: Versions, ContentText_AltOutOfStock %>" /></div>
                                        </asp:PlaceHolder>
                                        <% End If%>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                        </div>
                    </div>
                    <div class="spacer">
                    </div>
                </asp:View>
                <!-- Custom Product View -->
                <asp:View ID="viwCustomVersion" runat="server">
                    <asp:PlaceHolder ID="phdCustomControl" runat="server"/>
                    <asp:Literal ID="litHiddenV_ID" runat="server" Visible="false" />
                    <div class="boxinset line">
                        <div class="addtobasket">
                            <asp:DropDownList ID="ddlCustomVersionQuantity" runat="server" CssClass="dropdown"/>
                            <asp:Button ID="btnAddCustomVersion" runat="server" CssClass="button" Text="<%$ Resources: Products, FormButton_Add %>" />
                        </div>
                    </div>
                </asp:View>
            </asp:MultiView>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
<user:PopupMessage ID="UC_PopupMessage" runat="server" />
