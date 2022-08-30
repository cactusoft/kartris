<%@ Control Language="VB" AutoEventWireup="true" CodeFile="_AddressesDetails.ascx.vb" Inherits="UserControls_General_AddressesDetails" %>
<%@ Register TagPrefix="_user" TagName="AddressInput" Src="~/UserControls/General/CustomerAddress.ascx" %>
<%@ Register TagPrefix="_user" TagName="PopupMessage" Src="~/UserControls/General/_PopupMessage.ascx" %>

<asp:HiddenField ID="hidDisplayAddressType" runat="server" Value="" />
<asp:HiddenField ID="hidAddressToDeleteID" runat="server" Value="" />
<asp:HiddenField ID="hidUserID" runat="server" Value="" />
<_user:PopupMessage runat="server" ID="_UC_PopupMsg" />

<asp:LinkButton ID="lnkAddBilling" CssClass="linkbutton icon_new" runat="server" CausesValidation="false"
                                                Text='<%$ Resources: _Kartris, ContentText_AddNew %>' />

<asp:Repeater ID="rptrUserAddresses" runat="server">
    <ItemTemplate>
        </br>
        <div class="address">
            <div>
                <asp:HiddenField ID="hidAddressType" runat="server" Value='<%# Eval("ADR_Type")%>' />
            </div>
            <div>
                <asp:Literal ID="litName" runat="server" Text='<%# Eval("ADR_Name")%>' />
            </div>
            <asp:Panel ID="pnlCompany" runat="server">
                <asp:Literal ID="litCompany" runat="server" Text='<%# Eval("ADR_Company")%>' />
            </asp:Panel>
            <div>
                <asp:Literal ID="litAddress" runat="server" Text='<%# Eval("ADR_StreetAddress")%>' />
            </div>
            <div>
                <asp:Literal ID="litTownCity" runat="server" Text='<%# Eval("ADR_TownCity")%>' />,
                <asp:Literal ID="litCounty" runat="server" Text='<%# Eval("ADR_County")%>' />
                <asp:Literal ID="litPostcode" runat="server" Text='<%# Eval("ADR_PostCode")%>' />
            </div>
            <div>
                <asp:Literal ID="litCountry" runat="server" Text='<%# Eval("ADR_Country")%>' />
            </div>
            <div class="phone">
                <asp:Literal ID="litPhone" runat="server" Text='<%# Eval("ADR_Telephone")%>' />
            </div>
            <asp:Panel ID="pnlButtons" runat="server">
                <asp:LinkButton ID="btnEdit" runat="server" Text='<%$ Resources: _Kartris, FormButton_Edit %>'
                    CausesValidation="false" class="linkbutton icon_edit" CommandName="Edit"
                    CommandArgument='<%# Eval("ADR_ID")%>'
                    OnCommand="LinkButton_Command" />
                &nbsp;
    <asp:LinkButton ID="btnDelete" runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>'
        CausesValidation="false" class="linkbutton icon_delete" CommandName="Delete"
        CommandArgument='<%# Eval("ADR_ID")%>'
        OnCommand="LinkButton_Command" />
            </asp:Panel>
        </div>
    </ItemTemplate>
</asp:Repeater>

<asp:LinkButton ID="lnkDummy" runat="server" CausesValidation="false" />

<asp:Panel ID="pnlNewAddress" runat="server" CssClass="popup customeraddress" DefaultButton="btnSaveNewAddress" Style="display: none;">
    <h2>
        <asp:Literal ID="litAddressTitle" runat="server" Text="<%$ Resources:Kartris, ContentText_Edit%>" /></h2>
    <_user:AddressInput ID="UC_NewEditAddress" DisplayType="Shipping" runat="server" ShowSaveAs="true"
        AutoPostCountry="false" ValidationGroup="Shipping" />
    <div class="spacer">
    </div>

    <div class="submitbuttons">
        <asp:Button CssClass="button" ID="btnSaveNewAddress" runat="server" Text='<%$ Resources: Kartris, FormButton_Submit %>'
            CausesValidation="true" />
    </div>

    <asp:LinkButton ID="btnAddressCancel" runat="server" Text="×" CssClass="closebutton linkbutton2" />

</asp:Panel>

<ajaxToolkit:ModalPopupExtender ID="popExtender" runat="server" TargetControlID="lnkDummy"
    CancelControlID="btnAddressCancel" PopupControlID="pnlNewAddress" BackgroundCssClass="popup_background" />


