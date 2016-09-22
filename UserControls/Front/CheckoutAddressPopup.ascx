<%@ Control Language="VB" AutoEventWireup="false" CodeFile="CheckoutAddressPopup.ascx.vb"
    Inherits="UserControls_General_CheckoutAddress" %>
<%@ Register TagPrefix="user" TagName="CustomerAddress" Src="~/UserControls/General/CustomerAddress.ascx" %>
<div class="address">
            <h2>
                <asp:Literal ID="litAddressTitle" runat="server" /></h2>
        <asp:PlaceHolder ID="phdAddNewAddress" runat="server">

            <div class="inputform row collapse">
                <div class="small-9 large-10 columns">
                    <asp:DropDownList ID="ddlAddresses" runat="server" AutoPostBack="true" CssClass="fullwidth" />
                </div>
                <div class="small-3 large-2 columns">
                    &nbsp;<asp:LinkButton CssClass="link2 icon_new" ID="lnkNew" runat="server" Text='<%$ Resources: Kartris, ContentText_AddNew %>' />
                </div>
            </div>
            <div class="spacer"></div>
        </asp:PlaceHolder>
        <asp:PlaceHolder ID="phdAddressDetails" runat="server">
            <asp:HiddenField ID="hidAddressID" runat="server" />
            <asp:HiddenField ID="hidCountryID" runat="server" />
            <div>
                <asp:Literal ID="litAddressLabel" runat="server" />
            </div>
            <div>
                <asp:Literal ID="litName" runat="server" />
            </div>
            <asp:Panel ID="pnlCompany" runat="server">
                <asp:Literal ID="litCompany" runat="server" />
            </asp:Panel>
            <div>
                <asp:Literal ID="litAddress" runat="server" />
            </div>
            <div>
                <asp:Literal ID="litTownCity" runat="server" />,
                <asp:Literal ID="litCounty" runat="server" />&nbsp;
                <asp:Literal ID="litPostcode" runat="server" />
            </div>
            <div>
                <asp:Literal ID="litCountry" runat="server" />
                <asp:PlaceHolder ID="phdCountryNotAvailable" runat="server" Visible="false">
                    <span class="error">Country not available!</span></asp:PlaceHolder>
            </div>
            <div class="phone">
                <%-- <span class="label"><asp:Literal ID="litPhone" Text=" <%$ Resources:Address,FormText_PhoneNumber%>" runat="server" /></span>--%>
                <asp:Literal ID="litPhone" runat="server" />
            </div>
            <asp:Panel ID="pnlButtons" runat="server">
                <p>
                    <asp:LinkButton ID="btnEdit" CssClass="link2 icon_edit" runat="server" Text='<%$ Resources: Kartris, ContentText_Edit %>'
                        CausesValidation="false" />
                </p>
            </asp:Panel>
        </asp:PlaceHolder>
        <asp:PlaceHolder ID="phdNoAddress" runat="server" Visible="false">
            <div class="noaddress">
                <p>
                    <asp:Literal ID="litNoAddress" Text='<%$ Resources: Address, ContentText_NoAddress %>'
                        EnableViewState="false" runat="server" />
                </p>
                <p>
                    <asp:LinkButton CssClass="link2 icon_new" ID="lnkAdd" runat="server" Text='<%$ Resources: Address, ContentText_AddEditAddress %>' CausesValidation="false" />
                </p>
            </div>
        </asp:PlaceHolder>
        <asp:LinkButton ID="lnkDummy" runat="server" CausesValidation="false" />
        <asp:Panel ID="pnlNewAddress" runat="server" CssClass="popup" Style="display: none" DefaultButton="btnAccept">
            <asp:PlaceHolder runat="server" ID="phdAddressLookup" Visible="false">
                <div class="lookuppopup">
                    <div class="row collapse">
                        <div class="small-12 medium-8 columns" id="UKaddresscol">
                            <h2>UK address</h2>
                            <div class="row">
                                <asp:PlaceHolder runat="server" ID="phdEnterPostcode">
                                    <div class="small-9 medium-3 columns" id="UKcolpostcode">

                                        <asp:Label ID="lblPostcode" runat="server" Text="<%$ Resources: Address, FormLabel_PostCodeZip %>" EnableViewState="false"
                                            AssociatedControlID="txtZipCode" />
                                        <asp:TextBox runat="server" ID="txtZipCode" CssClass="postcode shorttext"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="valZipCodeRequired" ValidationGroup="Address" runat="server"
                                            ControlToValidate="txtZipCode" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                            CssClass="error" ForeColor="" EnableClientScript="true"></asp:RequiredFieldValidator>
                                        <asp:Literal ID="litNotValidError" runat="server"></asp:Literal>
                                    </div>
                                    <div class="small-3 medium-9 columns" id="UKcolpostcodelookup">
                                        <br />
                                        <asp:LinkButton ID="lnkLookup" runat="server" CssClass="link2 lookupbutton">Lookup</asp:LinkButton>

                                    </div>
                                </asp:PlaceHolder>
                                <asp:PlaceHolder runat="server" ID="phdChooseAddress" Visible="false">
                                    <div class="small-12 columns" id="chooseaddress">
                                        <asp:Label ID="lblChoose" runat="server" Text="Select address" EnableViewState="false"
                                            AssociatedControlID="lbxChooseAddress" />
                                        <asp:ListBox ID="lbxChooseAddress" runat="server" Rows="10" CssClass="addresslistbox" AutoPostBack="True"></asp:ListBox>
                                    </div>
                                </asp:PlaceHolder>
                            </div>
                        </div>

                        <div class="small-12 medium-4 columns" id="nonUKaddresscol">
                            <h2 id="nonUKaddressH2">Non-UK address</h2>


                            <asp:Label ID="lblCountry" runat="server" Text="<%$ Resources: Address, FormLabel_Country %>" EnableViewState="false"
                                AssociatedControlID="ddlCountry" CssClass="requiredfield" />
                                    <asp:ObjectDataSource ID="KartrisCountryList" runat="server" TypeName="KartrisClasses+Country"
                                        SelectMethod="GetAll" EnableCaching="false">
                                        <SelectParameters>
                                            <asp:SessionParameter SessionField="lang" DbType="Int16" Name="LanguageID" />
                                        </SelectParameters>
                                    </asp:ObjectDataSource>
                                    <asp:DropDownList AutoPostBack="true" runat="server" ID="ddlCountry" DataSourceID="KartrisCountryList"
                                        DataTextField="Name" DataValueField="CountryId" AppendDataBoundItems="true" EnableViewState="false">
                                        <asp:ListItem Text="<%$ Resources: Kartris, ContentText_DropdownSelectDefault %>" Value="0" />
                                    </asp:DropDownList>
                        </div>
                    </div>


                </div>
            </asp:PlaceHolder>
            <asp:PlaceHolder runat="server" ID="phdAddressEnterForm">
                <h2>
                    <asp:Literal ID="litContentTextAddEditAddress" Text='<%$ Resources: Address, ContentText_AddEditAddress %>'
                        runat="server" /></h2>
                <user:CustomerAddress ID="UC_CustomerAddress" runat="server" ValidationGroup="Billing"
                    AutoPostCountry="false" />

                <div class="spacer"></div>
                <div class="submitbuttons">
                    
                    <asp:Button ID="btnAccept" CssClass="button" runat="server" Text='<%$ Resources: Kartris, FormButton_Submit %>'
                        CausesValidation="true" />
                </div>
            </asp:PlaceHolder>

<asp:LinkButton ID="btnCancel" runat="server" Text="×" CssClass="closebutton linkbutton2" />
        </asp:Panel>
        <ajaxToolkit:ModalPopupExtender ID="popExtender" runat="server" TargetControlID="lnkDummy"
            CancelControlID="btnCancel" PopupControlID="pnlNewAddress" BackgroundCssClass="popup_background" />
    </div>

