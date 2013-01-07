<%@ Control Language="VB" AutoEventWireup="false" CodeFile="CheckoutAddressPopup.ascx.vb"
    Inherits="UserControls_General_CheckoutAddress" %>
<%@ Register TagPrefix="user" TagName="CustomerAddress" Src="~/UserControls/General/CustomerAddress.ascx" %>
<div class="address">
    <h2>
        <asp:Literal ID="litAddressTitle" runat="server" /></h2>
    <div>
        <asp:PlaceHolder ID="phdAddNewAddress" runat="server">
            <div class="inputform">
                <asp:DropDownList ID="ddlAddresses" runat="server" AutoPostBack="true" />
                <asp:LinkButton CssClass="link2 icon_new" ID="lnkNew" runat="server" Text='<%$ Resources: Kartris, ContentText_AddNew %>' />
            </div>
        </asp:PlaceHolder>
        <asp:PlaceHolder ID="phdAddressDetails" runat="server">
            <asp:HiddenField ID="hidAddressID" runat="server" />
            <asp:HiddenField ID="hidCountryID" runat="server" />
            <div>
                <asp:Literal ID="litAddressLabel" runat="server" /></div>
            <div>
                <asp:Literal ID="litName" runat="server" /></div>
            <asp:Panel ID="pnlCompany" runat="server">
                <asp:Literal ID="litCompany" runat="server" /></asp:Panel>
            <div>
                <asp:Literal ID="litAddress" runat="server" /></div>
            <div>
                <asp:Literal ID="litTownCity" runat="server" />,
                <asp:Literal ID="litCounty" runat="server" />&nbsp;
                <asp:Literal ID="litPostcode" runat="server" /></div>
            <div>
                <asp:Literal ID="litCountry" runat="server" />
                <asp:PlaceHolder ID="phdCountryNotAvailable" runat="server" Visible="false">
                <span class="error">Country not available!</span></asp:PlaceHolder></div>
            <div class="phone">
                <%-- <span class="label"><asp:Literal ID="litPhone" Text=" <%$ Resources:Address,FormText_PhoneNumber%>" runat="server" /></span>--%>
                <asp:Literal ID="litPhone" runat="server" />
            </div>
            <asp:Panel ID="pnlButtons" runat="server">
                <p>
                    <asp:LinkButton ID="btnEdit" CssClass="link2 icon_edit" runat="server" Text='<%$ Resources: Kartris, ContentText_Edit %>'
                        CausesValidation="false" /></p>
            </asp:Panel>
        </asp:PlaceHolder>
        <asp:PlaceHolder ID="phdNoAddress" runat="server" Visible="false">
            <div class="noaddress">
                <p>
                    <asp:Literal ID="litNoAddress" Text='<%$ Resources: Address, ContentText_NoAddress %>'
                        EnableViewState="false" runat="server" /></p>
                <p>
                    <asp:LinkButton CssClass="link2 icon_new" ID="lnkAdd" runat="server" Text='<%$ Resources: Address, ContentText_AddEditAddress %>' CausesValidation="false"/></p>
            </div>
        </asp:PlaceHolder>
        <asp:LinkButton ID="lnkDummy" runat="server" CausesValidation="false" />
        <asp:Panel ID="pnlNewAddress" runat="server" CssClass="popup" Style="display: none" DefaultButton="btnAccept">
            <h2>
                <asp:Literal ID="litContentTextAddEditAddress" Text='<%$ Resources: Address, ContentText_AddEditAddress %>'
                    runat="server" /></h2>
            <user:CustomerAddress ID="UC_CustomerAddress" runat="server" ValidationGroup="Billing"
                AutoPostCountry="false" />
            <div class="spacer">
            </div>
            <div class="submitbuttons">
                <asp:LinkButton ID="btnCancel" runat="server" Text="X" CssClass="closebutton linkbutton2" />
                <asp:Button ID="btnAccept" CssClass="button" runat="server" Text='<%$ Resources: Kartris, FormButton_Submit %>'
                    CausesValidation="true"  />
                <%--            <asp:Button ID="btnCancel" CssClass="button" runat="server" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                CausesValidation="false" />--%>
            </div>
        </asp:Panel>
        <ajaxToolkit:ModalPopupExtender ID="popExtender" runat="server" TargetControlID="lnkDummy"
            CancelControlID="btnCancel" PopupControlID="pnlNewAddress" BackgroundCssClass="popup_background" />
    </div>
</div>
