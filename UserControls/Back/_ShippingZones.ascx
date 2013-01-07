<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_ShippingZones.ascx.vb"
    Inherits="UserControls_Back_ShippingZones" %>
<%@ Register TagPrefix="_user" TagName="LanguageContainer" Src="~/UserControls/Back/_LanguageContainer.ascx" %>
<%@ Register TagPrefix="_user" TagName="ZoneDestinations" Src="~/UserControls/Back/_ZoneDestinations.ascx" %>
<asp:UpdatePanel ID="updShippingZonesList" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <div id="section_shippingzones">
            <asp:PlaceHolder ID="phdList" runat="server">
                <asp:LinkButton ID="lnkAddNewShippingZone" runat="server" Text="<%$ Resources: _Kartris, FormButton_New %>"
                    CssClass="linkbutton icon_new floatright" />
                <asp:GridView CssClass="kartristable" ID="gvwShippingZones" runat="server" AllowPaging="false"
                    AllowSorting="true" AutoGenerateColumns="False" DataKeyNames="SZ_ID" AutoGenerateEditButton="False"
                    GridLines="None" SelectedIndex="-1">
                    <Columns>
                        <asp:TemplateField ItemStyle-CssClass="itemname">
                            <HeaderTemplate>
                                <asp:Literal ID="litContentTextShippingZone" runat="server" Text='<%$ Resources:_Shipping, ContentText_ShippingZone %>' />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkEditSZ" runat="server" Text='<%# Eval("SZ_Name") %>' CommandName="EditShippingZone"
                                    CommandArgument='<%# Container.DataItemIndex %>' />
                                <%-- litOrderBy used to hold the value of 'SZ_OrderByValue' field .. to reduce the db calls --%>
                                <asp:Literal ID="litOrderBy" runat="server" Text='<%# Eval("SZ_OrderByValue") %>'
                                    Visible="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <HeaderTemplate>
                                <asp:Literal ID="litContentTextLive" runat="server" Text="<%$ Resources: _Kartris, ContentText_Live %>"></asp:Literal>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="chkLive" runat="server" Checked='<%# Eval("SZ_Live") %>' CssClass="checkbox"
                                    Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-CssClass="selectfield">
                            <HeaderTemplate>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkBtnDestinations" runat="server" CommandName="ShowDestinations"
                                    CommandArgument='<%# Container.DataItemIndex %>' Text='<%$ Resources: _Shipping, ContentText_ShippingDestinations %>'
                                    CssClass="linkbutton icon_edit normalweight" />
                                <asp:LinkButton ID="lnkBtnEdit" runat="server" CommandName="EditShippingZone" CommandArgument='<%# Container.DataItemIndex %>'
                                    Text='<%$ Resources: _Kartris, FormButton_Edit %>' CssClass="linkbutton icon_edit" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </asp:PlaceHolder>
        </div>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgShippingZonesList" runat="server" AssociatedUpdatePanelID="updShippingZonesList">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
<asp:UpdatePanel ID="updShippingZoneDetails" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:PlaceHolder ID="phdZoneDetails" runat="server">
            <asp:Literal ID="litShippingZoneID" runat="server" Visible="false" />
            <asp:MultiView ID="mvwShippingZones" runat="server">
                <asp:View ID="viwShippingZoneEmpty" runat="server">
                </asp:View>
                <asp:View ID="viwShippingZoneInfo" runat="server">
                    <asp:LinkButton ID="lnkBack2" CssClass="linkbutton icon_back floatright" runat="server"
                        Text="<%$ Resources: _Kartris, ContentText_BackLink %>"></asp:LinkButton><h2>
                            <asp:Literal ID="litShippingZoneNameInfo" runat="server" /></h2>
                    <%-- Language Elements --%>
                    <div>
                        <asp:UpdatePanel ID="updLanguageContainer" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:PlaceHolder ID="phdLanguageContainer" runat="server">
                                    <_user:LanguageContainer ID="_UC_LangContainer" runat="server" />
                                </asp:PlaceHolder>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                    <div class="line">
                    </div>
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <%-- Live --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelLive" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Live %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:CheckBox ID="chkShippingZoneLive" runat="server" CssClass="checkbox" />
                                </span></li>
                                <%-- Sort By --%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextSorByValue" runat="server" Text="<%$ Resources:_Kartris, ContentText_SorByValue %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtOrderBy" runat="server" CssClass="shorttext" MaxLength="3" />
                                    <asp:RequiredFieldValidator ID="valRequiredOrderBy" runat="server" CssClass="error"
                                        ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                        ControlToValidate="txtOrderBy" Display="Dynamic" SetFocusOnError="true" />
                                    <asp:CompareValidator ID="valCompareOrderBy" runat="server" ControlToValidate="txtOrderBy"
                                        Display="Dynamic" CssClass="error" ForeColor="" ErrorMessage="0-255!" Operator="LessThanEqual"
                                        ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoByte %>" ValueToCompare="255"
                                        Type="Integer" SetFocusOnError="true" />
                                    <ajaxToolkit:FilteredTextBoxExtender ID="filOrderBy" runat="server" FilterType="Numbers"
                                        TargetControlID="txtOrderBy" />
                                </span></li>
                            </ul>
                        </div>
                    </div>
                    <%-- Save Button  --%>
                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                        <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:LinkButton ID="lnkBtnSaveShippingZone" runat="server" CssClass="button savebutton"
                                    Text='<%$ Resources: _Kartris, FormButton_Save %>' />
                                <asp:LinkButton ID="lnkBtnCancelShippingZone" runat="server" CssClass="button cancelbutton"
                                    Text='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                                <asp:ValidationSummary ID="valSummary" runat="server" CssClass="valsummary" DisplayMode="BulletList"
                                    ForeColor="" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                                <span class="floatright">
                                    <asp:PlaceHolder ID="phdAssignToZone" runat="server"><span class="reassign">
                                        <asp:Literal ID="litContentTextAssignToZone" runat="server" Text="<%$ Resources: _Shipping, ContentText_AssignedToZone %>" />
                                        <asp:DropDownList ID="ddlAssignedZone" runat="server" DataTextField="SZ_Name" DataValueField="SZ_ID">
                                        </asp:DropDownList>
                                    </span></asp:PlaceHolder>
                                    <asp:LinkButton ID="lnkBtnDeleteShippingZone" CssClass="button deletebutton"
                                        runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>' /></span>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                </asp:View>
                <asp:View ID="viwShippingZoneDestinations" runat="server">
                    <asp:LinkButton ID="lnkBack" CssClass="linkbutton icon_back floatright" runat="server"
                        Text="<%$ Resources: _Kartris, ContentText_BackLink %>"></asp:LinkButton><h2>
                            <asp:Literal ID="litPageTitleShippingDestinationCountries" runat="server" Text="<%$ Resources: _Shipping, PageTitle_ShippingDestinationCountries %>" />:
                            <span class="h1_light">
                                <asp:Literal ID="litShippingZoneNameDestinations" runat="server" /></span>
                        </h2>
                    <_user:ZoneDestinations ID="_UC_ZoneDestinations" runat="server" ShowGroupLinks="False" />
                </asp:View>
            </asp:MultiView>
        </asp:PlaceHolder>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="upgShippingZoneDetails" runat="server" AssociatedUpdatePanelID="updShippingZoneDetails">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>

