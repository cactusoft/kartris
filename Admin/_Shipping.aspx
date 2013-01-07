<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_shipping.aspx.vb" Inherits="Admin_Shipping"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_shipping">
        <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <h1>
                    <asp:Literal ID="litPageTitleShipping" runat="server" Text="<%$ Resources: _Shipping, PageTitle_Shipping %>" /></h1>
                <ajaxToolkit:TabContainer ID="tabContainerShipping" runat="server" CssClass=".tab"
                    EnableTheming="false">
                    <ajaxToolkit:TabPanel ID="tabPnlConfig" runat="server">
                        <HeaderTemplate>
                            <asp:Literal ID="litBackMenuConfigSettings" runat="server" Text="<%$ Resources: _Kartris, BackMenu_ConfigSettings %>" />
                        </HeaderTemplate>
                        <ContentTemplate>
                            <div class="subtabsection">
                                <asp:UpdatePanel ID="updCollapsiblePanel" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                       <%-- <ajaxToolkit:CollapsiblePanelExtender ID="CollapsiblePanelShippingSystem" runat="server"
                                            CollapseControlID="pnlShippingSystem" ExpandControlID="pnlShippingSystem" TargetControlID="pnlModifyShippingSystem"
                                            TextLabelID="lblExpandCollapseShippingSystem" ExpandedText="" CollapsedText=""
                                            SuppressPostBack="false" Collapsed="true" />
                                        <asp:Panel ID="pnlShippingSystem" runat="server">
                                            <p>
                                                <asp:Label ID="lblExpandCollapseShippingSystem" runat="server" Text="" />
                                                <asp:Literal ID="litContentTextShippingSystem" runat="server" Text="<%$ Resources: _Shipping, ContentText_ShippingSystem %>" />:
                                                <strong>
                                                    <asp:Literal ID="litShippingSystem" runat="server" /></strong>
                                                <asp:LinkButton ID="lnkBtnChangeShippingSystem" CssClass="linkbutton icon_edit" runat="server"
                                                    Text="<%$ Resources: _Kartris, ContentText_ConfigChange2 %>" />
                                                <asp:LinkButton ID="lnkBtnCancelShippingSystem" CssClass="linkbutton icon_delete"
                                                    runat="server" Text="<%$ Resources: _Kartris, FormButton_Cancel %>" Visible="false" /></p>
                                        </asp:Panel>
                                        <asp:Panel ID="pnlModifyShippingSystem" runat="server">
                                            <div class="configsettingbox">
                                                <strong>
                                                    <asp:Literal ID="litTextConfigSettingSystem" runat="server" Text="frontend.checkout.shipping.system" /></strong>
                                                <div class="floatright">
                                                    <asp:DropDownList ID="ddlShippingSystem" runat="server">
                                                        <asp:ListItem Text="<%$ Resources: _Shipping, ContentText_IntegratedShipping %>"
                                                            Value="c" />
                                                        <asp:ListItem Text="<%$ Resources: _Shipping, ContentText_UPS %>" Value="u" />
                                                        <asp:ListItem Text="<%$ Resources: _Kartris, ContentText_None %>" Value="n" />
                                                    </asp:DropDownList>
                                                    <asp:Button ID="lnkBtnSaveShippingSystem" runat="server" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                                        CssClass="button" /></div>
                                                <p>
                                                    <asp:Literal ID="litShippingSystemDescription" runat="server" /></p>
                                            </div>
                                            <br />
                                            <br />
                                        </asp:Panel>--%>
                                        <asp:PlaceHolder ID="phdCalculation" runat="server">
                                            <ajaxToolkit:CollapsiblePanelExtender ID="CollapsiblePanelShippingCalculation" runat="server"
                                                CollapseControlID="pnlShippingCalculation" ExpandControlID="pnlShippingCalculation"
                                                TargetControlID="pnlModifyShippingCalculation" TextLabelID="lblExpandCollapseShippingCalculation"
                                                ExpandedText="" CollapsedText="" SuppressPostBack="false" Collapsed="true" />
                                            <asp:Panel ID="pnlShippingCalculation" runat="server">
                                                <p>
                                                    <asp:Label ID="lblExpandCollapseShippingCalculation" runat="server" Text="" />
                                                    <asp:Literal ID="litContentTextShippingCalculate" runat="server" Text="<%$ Resources: _Shipping, ContentText_ShippingCalculate %>" />:
                                                    <strong>
                                                        <asp:Literal ID="litShippingCalculated" runat="server" /></strong>
                                                    <asp:LinkButton ID="lnkBtnChangeShippingCalculation" CssClass="linkbutton icon_edit"
                                                        runat="server" Text="<%$ Resources: _Kartris, ContentText_ConfigChange2 %>" />
                                                    <asp:LinkButton CssClass="linkbutton icon_delete" ID="lnkBtnCancelShippingCalculation"
                                                        runat="server" Text="<%$ Resources: _Kartris, FormButton_Cancel %>" Visible="false" /></p>
                                            </asp:Panel>
                                            <asp:Panel ID="pnlModifyShippingCalculation" runat="server">
                                                <div class="configsettingbox">
                                                    <strong>
                                                        <asp:Literal ID="litConfigSettingCalcByWeight" runat="server" Text="frontend.checkout.shipping.calcbyweight" /></strong>
                                                    <div class="floatright">
                                                        <asp:CheckBox ID="chkCalcByWeight" runat="server" CssClass="checkbox" />
                                                        <asp:Button ID="lnkBtnSaveShippingCalculation" runat="server" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                                            CssClass="button" /></div>
                                                    <p>
                                                        <asp:Literal ID="litShippingCalculationDescription" runat="server" /></p>
                                                </div>
                                                <br />
                                                <br />
                                            </asp:Panel>
                                        </asp:PlaceHolder>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                                 <div class="spacer">
                                &nbsp;</div>
                                <asp:LinkButton ID="lnkGateways" CssClass="linkbutton icon_edit"
                                                        runat="server" Text="<%$ Resources: _Kartris, ContentText_PaymentShippingGateways %>" PostBackUrl="~/Admin/_PaymentGateways.aspx" />
                                
                            </div>
                            <asp:UpdateProgress ID="upgCollapsiblePanel" runat="server" AssociatedUpdatePanelID="updCollapsiblePanel">
                                <ProgressTemplate>
                                    <div class="loadingimage">
                                    </div>
                                    <div class="updateprogress">
                                    </div>
                                </ProgressTemplate>
                            </asp:UpdateProgress>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel ID="tabPnlShippingMethods" runat="server" Visible="False">
                        <HeaderTemplate>
                            <asp:Literal ID="litContentTextShippingMethods" Visible="False" runat="server" Text="<%$ Resources: _Shipping, ContentText_ShippingMethods %>" />
                        </HeaderTemplate>
                        <ContentTemplate>
                            <div class="subtabsection">
                                <_user:ShippingMethods ID="_UC_ShippingMethods" runat="server" />
                            </div>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel ID="tabPnlShippingZones" runat="server" Visible="False">
                        <HeaderTemplate>
                            <asp:Literal ID="litContentTextShippingZones" Visible="False" runat="server" Text="<%$ Resources: _Shipping, ContentText_ShippingZones %>" />
                        </HeaderTemplate>
                        <ContentTemplate>
                            <div class="subtabsection">
                                <_user:ShippingZones ID="_UC_ShippingZones" runat="server" />
                            </div>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                </ajaxToolkit:TabContainer>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
    <div class="spacer">
        &nbsp;</div>
</asp:Content>
