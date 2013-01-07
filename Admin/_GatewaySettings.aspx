<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_GatewaySettings.aspx.vb" Inherits="Admin_GatewaySettings"
MasterPageFile="~/Skins/Admin/Template.master" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_gatewaysettings">
        <asp:UpdatePanel runat="server" ID="upGatewaySettings">
            <ContentTemplate>
                <asp:Panel ID="pnlDetails" runat="server">
                    <h1>
                        <asp:Literal ID="litPageTitle" runat="server" Text='<%$ Resources: _Kartris, ContentText_PaymentShippingGateways %>' EnableViewState="False"></asp:Literal>:
                        <span class="h1_light">
                            <asp:Literal ID="lblGatewayName" runat="server" /></span>
                    </h1>
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <asp:PlaceHolder ID="phdSettings" runat="server" />
                            </ul>
                        </div>
                    </div>
                    <div class="spacer">
                    </div>
                    <asp:UpdatePanel ID="upUpdate" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <div class="Kartris-DetailsView">
                                <div class="Kartris-DetailsView-Data">
                                    <ul>
                                        <li>
                                            <asp:CheckBox CssClass="checkbox" ID="chkEncrypt" runat="server" Text="<%$ Resources: _Gateways, ContentText_EncryptSettings %>"
                                                Visible="false" /></li>
                                    </ul>
                                </div>
                            </div>
                            <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                                <asp:LinkButton CssClass="button savebutton" ID="btnUpdate" runat="server" Text="<%$ Resources: _Kartris, FormButton_Save %>"
                                ToolTip="<%$ Resources: _Kartris, FormButton_Save %>"
                                    Visible="false" CausesValidation="true" />
                                <asp:LinkButton CssClass="button cancelbutton" ID="btnCancel" runat="server" Text="<%$ Resources: _Kartris, FormButton_Cancel %>"
                                ToolTip="<%$ Resources: _Kartris, FormButton_Cancel %>"
                                    PostBackUrl="~/Admin/_PaymentGateways.aspx" CausesValidation="false" />
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </asp:Panel>
            </ContentTemplate>
        </asp:UpdatePanel>
        <asp:LinkButton ID="btnBack" CausesValidation="false" runat="server" CssClass="linkbutton icon_back"
            Text='<%$ Resources: _Kartris, ContentText_BackLink %>' PostBackUrl="~/Admin/_PaymentGateways.aspx" />
  <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />          
    </div>
</asp:Content>
