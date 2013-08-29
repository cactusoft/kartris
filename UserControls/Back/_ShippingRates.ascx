<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_ShippingRates.ascx.vb"
    Inherits="UserControls_Back_ShippingRates" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Literal ID="litShippingZoneID" runat="server" Visible="false" />
        <asp:Literal ID="litShippingMethodID" runat="server" Visible="false" />
        <asp:UpdatePanel ID="updShipping" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <span class="zonename">
                    <asp:Literal ID="litShippingZoneName" runat="server" /></span>
                <asp:LinkButton ID="lnkBtnDeleteZone" runat="server" Text="<%$ Resources: _Kartris, FormButton_Delete %>"
                    CssClass="linkbutton icon_delete" />
            </ContentTemplate>
        </asp:UpdatePanel>
        <table class="kartristable">
            <asp:Repeater ID="rptRates" runat="server">
                <HeaderTemplate>
                    <tr>
                        <th>
                            <% '------------------------------------------------------- %>
                            <% 'Need to display bands as either WEIGHT or ORDER VALUE %>
                            <% '------------------------------------------------------- %>
                            <% If KartSettingsManager.GetKartConfig("frontend.checkout.shipping.calcbyweight") = "y" Then%>
                            <asp:Literal ID="litContentTextWeight" runat="server" Text="<%$ Resources: _Shipping, ContentText_OrderWeight  %>" />
                            <% Else%>
                            <asp:Literal ID="litContentTextValue" runat="server" Text="<%$ Resources: _Orders, ContentText_OrderValue %>" />
                            <% End If%>
                        </th>
                        <th>
                            <asp:Literal ID="litContentTextPrice" runat="server" Text="<%$ Resources: _Kartris, ContentText_Price %>" />
                        </th>
                        <th>
                            <asp:Literal ID="litShippingGateway" runat="server" Text="Shipping Gateway" />
                        </th>
                        <th>&nbsp;</th>
                    </tr>
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:Literal ID="litShippingID" runat="server" Text='<%# Eval("S_ID") %>' Visible="false" />
                    <asp:Literal ID="litBoundary" runat="server" Text='<%# Eval("S_Boundary") %>' Visible="false" />
                    <asp:Literal ID="litISOCode" runat="server" Text='<%# Eval("CUR_Symbol") %>' Visible="false" />
                    <asp:PlaceHolder ID="phdNormalRates" runat="server" Visible="false">
                        <tr class='<%# GetRowClass(Container.ItemIndex) %>'>
                            <td>
                                <asp:Literal ID="litContentTextUpTo" runat="server" Text="<%$ Resources: _Shipping, ContentText_Upto %>" />
                                <% '------------------------------------------------------- %>
                                <% 'Need to display bands as either WEIGHT or ORDER VALUE %>
                                <% '------------------------------------------------------- %>
                                <% If KartSettingsManager.GetKartConfig("frontend.checkout.shipping.calcbyweight") = "y" Then%>&nbsp;<asp:Literal
                                    ID="litS_Boundary" runat="server" Text='<%# Eval("S_Boundary") %>' />&nbsp;<%= KartSettingsManager.GetKartConfig("general.weightunit") %>
                                <% Else%>&nbsp;<asp:Literal ID="litCUR_ISOCode2" runat="server" Text='<%# Eval("CUR_Symbol") %>' />
                                <asp:Literal ID="litS_Boundary1" runat="server" Text='<%# FormatAsCurrency(Eval("S_Boundary")) %>' />
                                <% End If%>
                            </td>
                            <td>
                                <asp:Literal ID="litCUR_ISOCode3" runat="server" Text='<%# Eval("CUR_Symbol") %>' />
                                <asp:Literal ID="litS_ShippingRate" runat="server" Text='<%# FormatAsCurrency(Eval("S_ShippingRate")) %>' />
                            </td>
                            <td>
                                <asp:Literal ID="litS_ShippingGateways" runat="server" Text='<%# Eval("S_ShippingGateways") %>' />
                                </td>
                            <td>
                                <asp:UpdatePanel ID="updDelete" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:LinkButton ID="lnkBtnDelete" runat="server" Text="<%$ Resources: _Kartris, FormButton_Delete %>"
                                            CommandName="DeleteRate" CommandArgument='<%# Eval("S_ID") %>' CssClass="linkbutton icon_delete floatright" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                    </asp:PlaceHolder>
                    <asp:PlaceHolder ID="phdHighRates" runat="server" Visible="false">
                        <tr class='<%# GetRowClass(Container.ItemIndex) %>'>
                            <td>
                                <asp:Literal ID="litAllHigherOrders" runat="server" Text="<%$ Resources: _Shipping, ContentText_AllHigherOrders %>" />
                            </td>
                            <td>
                                <asp:Literal ID="litCUR_ISOCode4" runat="server" Text='<%# Eval("CUR_Symbol") %>' />
                                <asp:TextBox ID="txtHigherOrdersRate" runat="server" Text='<%# FormatAsCurrency(Eval("S_ShippingRate")) %>'
                                    ValidationGroup='<%# "HighOrders" & Eval("S_ID") %>' CssClass="midtext" MaxLength="8" />
                                <asp:RequiredFieldValidator ID="reqValidHigherOrdersRate" runat="server" SetFocusOnError="true"
                                    CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                    ControlToValidate="txtHigherOrdersRate" Display="Dynamic" ValidationGroup='<%# "HighOrders" & Eval("S_ID") %>' />
                                <asp:RegularExpressionValidator ID="valRegexHigherOrdersRate" runat="server" ControlToValidate="txtHigherOrdersRate"
                                    CssClass="error" Display="Dynamic" ErrorMessage="*" ForeColor="" SetFocusOnError="true"
                                    ValidationGroup='<%# "HighOrders" & Eval("S_ID") %>' ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                <ajaxToolkit:FilteredTextBoxExtender ID="filHigherOrdersRate" runat="server" TargetControlID="txtHigherOrdersRate"
                                    FilterType="Numbers,Custom" FilterMode="ValidChars" ValidChars=".," />
                            </td>
                            <td>
                                <span class="checkbox">
                                    <asp:PlaceHolder ID="phdHigherOrderGateways" runat="server"></asp:PlaceHolder>
                                </span>
                            </td>
                            <td>
                                <asp:UpdatePanel ID="updUpdateButton" runat="server" UpdateMode="Conditional" RenderMode="Inline">
                                    <ContentTemplate>
                                        <asp:LinkButton ID="lnkBtnUpdate" runat="server" Text="<%$ Resources: _Kartris, FormButton_Update %>"
                                            CommandName="UpdateRate" CommandArgument='<%# Eval("S_ID") %>' ValidationGroup='<%# "HighOrders" & Eval("S_ID") %>'
                                            CssClass="linkbutton icon_edit" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                                <asp:UpdatePanel ID="updDeleteAllHigher" runat="server" UpdateMode="Conditional" RenderMode="Inline">
                                    <ContentTemplate>
                                        <asp:LinkButton ID="lnkBtnDeleteAllHigher" runat="server" Text="<%$ Resources: _Kartris, FormButton_Delete %>"
                                            CommandName="DeleteRate" CommandArgument='<%# Eval("S_ID") %>' CssClass="linkbutton icon_delete floatright" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                    </asp:PlaceHolder>
                </ItemTemplate>
                <FooterTemplate>
                        <tr class="add_new">
                            <td>
                                <% '------------------------------------------------------- %>
                                <% 'Need to display bands as either WEIGHT or ORDER VALUE %>
                                <% '------------------------------------------------------- %>
                                <asp:Literal ID="litContentTextUpTo2" runat="server" Text="<%$ Resources: _Shipping, ContentText_Upto %>" />&nbsp;<asp:TextBox ID="txtNewBoundary" runat="server" CssClass="midtext" ValidationGroup='<%# "NewRate" & Eval("S_ID") %>'
                                    MaxLength="8" />
                                <asp:RegularExpressionValidator ID="valRegexNewBoundary" runat="server" ControlToValidate="txtNewBoundary"
                                    CssClass="error" Display="Dynamic" ErrorMessage="*" ForeColor="" SetFocusOnError="true"
                                    ValidationGroup='<%# "NewRate" & Eval("S_ID") %>' ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                <ajaxToolkit:FilteredTextBoxExtender ID="filNewBoundary" runat="server" TargetControlID="txtNewBoundary"
                                    FilterType="Numbers,Custom" FilterMode="ValidChars" ValidChars=".," />
                            </td>
                            <td>
                                <asp:Literal ID="litCUR_ISOCode6" runat="server" Text='<%# Eval("CUR_Symbol") %>' />
                                <asp:TextBox ID="txtNewRate" runat="server" CssClass="midtext" ValidationGroup='<%# "NewRate" & Eval("S_ID") %>'
                                    MaxLength="8" />
                                <asp:RegularExpressionValidator ID="valRegexNewRate" runat="server" ControlToValidate="txtNewRate"
                                    CssClass="error" Display="Dynamic" ErrorMessage="*" ForeColor="" SetFocusOnError="true"
                                    ValidationGroup='<%# "NewRate" & Eval("S_ID") %>' ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                            </td>
                            <td>
                                <span class="checkbox">
                                    <asp:PlaceHolder ID="phdAddNewGateways" runat="server" />
                                </span>
                                </td>
                            <td>
                                <asp:UpdatePanel ID="updAddButton" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:LinkButton ID="lnkBtnAdd" runat="server" Text="<%$ Resources: _Kartris, FormButton_Add %>"
                                            CommandName="NewRate" ValidationGroup='<%# "NewRate" & Eval("S_ID") %>' CssClass="linkbutton icon_new floatright" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                </FooterTemplate>
            </asp:Repeater>
        </table>
        <asp:Literal ID="litShippingIDToDelete" runat="server" Visible="false" />
        <_user:PopupMessage ID="_UC_PopupMsg_Zone" runat="server" />
        <_user:PopupMessage ID="_UC_PopupMsg_Rate" runat="server" />
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
