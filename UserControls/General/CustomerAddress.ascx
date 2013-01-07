<%@ Control Language="VB" AutoEventWireup="false" CodeFile="CustomerAddress.ascx.vb"
    Inherits="UserControls_Front_CustomerAddress" %>

<%@ Import Namespace="Kartris.Payment" %>
<div class="inputform">
    <asp:HiddenField ID="hidAddressID" runat="server" Value="0" />
    <asp:HiddenField ID="hidAddressType" runat="server" Value="" />
    <asp:HiddenField ID="hidDisplayType" runat="server" Value="" />
    <div class="Kartris-DetailsView">
        <div class="Kartris-DetailsView-Data">
            <ul>
                <asp:PlaceHolder ID="phdName" runat="server">
                    <asp:PlaceHolder ID="phdSaveAs" runat="server" Visible="false">
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Label ID="lblAddressLabel" runat="server" EnableViewState="false" Text="<%$ Resources: Kartris, ContentText_ItemLabel %>" AssociatedControlID="txtSaveAs" /></span><span
                                class="Kartris-DetailsView-Value">
                                <asp:TextBox runat="server" ID="txtSaveAs"></asp:TextBox></span></li>
                    </asp:PlaceHolder>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Label ID="lblName" runat="server" Text="<%$ Resources: Kartris, ContentText_CustomerName %>" EnableViewState="false"
                            AssociatedControlID="txtLastName" CssClass="requiredfield" /></span><span class="Kartris-DetailsView-Value">
                                <asp:TextBox ID="txtLastName" runat="server"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="valLastNameRequired" runat="server" ControlToValidate="txtLastName"
                                     Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>" ValidationGroup="Address"
                                     CssClass="error" ForeColor="" EnableClientScript="true"></asp:RequiredFieldValidator></span></li>
                    <li><span class="Kartris-DetailsView-Name">
                        <asp:Label ID="lblCompany" runat="server" Text="<%$ Resources: Address, FormLabel_CardHolderCompany %>" EnableViewState="false"
                            AssociatedControlID="txtCompanyName" /></span><span class="Kartris-DetailsView-Value">
                                <asp:TextBox runat="server" ID="txtCompanyName"></asp:TextBox></span></li>
                </asp:PlaceHolder>
                <li><span class="Kartris-DetailsView-Name">
                    <asp:Label ID="lblStreetAddress" runat="server" Text="<%$ Resources: Address, FormLabel_StreetAddress %>" EnableViewState="false"
                        AssociatedControlID="txtAddress" CssClass="requiredfield" /></span><span class="Kartris-DetailsView-Value">
                            <asp:TextBox runat="server" ID="txtAddress"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="valAddressRequired" ValidationGroup="Address" runat="server"
                                ControlToValidate="txtAddress" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                CssClass="error" ForeColor="" EnableClientScript="true"></asp:RequiredFieldValidator></span></li>
                <li><span class="Kartris-DetailsView-Name"></span><span class="Kartris-DetailsView-Value">
                </span></li>
                <li><span class="Kartris-DetailsView-Name">
                    <asp:Label ID="lblTownCity" runat="server" Text="<%$ Resources: Address, FormLabel_TownCity %>" EnableViewState="false"
                        AssociatedControlID="txtCity" CssClass="requiredfield" /></span><span class="Kartris-DetailsView-Value">
                            <asp:TextBox runat="server" ID="txtCity"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="valCityRequired" ValidationGroup="Address" runat="server"
                                ControlToValidate="txtCity" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                CssClass="error" ForeColor="" EnableClientScript="true"></asp:RequiredFieldValidator></span></li>
                <li><span class="Kartris-DetailsView-Name">
                    <asp:Label ID="lblCountyState" runat="server" Text="<%$ Resources: Address, FormLabel_CountyState %>" EnableViewState="false"
                        AssociatedControlID="txtState" CssClass="requiredfield" /></span><span class="Kartris-DetailsView-Value">
                            <asp:TextBox runat="server" ID="txtState"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="valStateRequired" ValidationGroup="Address" runat="server"
                                ControlToValidate="txtState" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                CssClass="error" ForeColor=""></asp:RequiredFieldValidator></span></li>
                <li><span class="Kartris-DetailsView-Name">
                    <asp:Label ID="lblPostcode" runat="server" Text="<%$ Resources: Address, FormLabel_PostCodeZip %>" EnableViewState="false"
                        AssociatedControlID="txtZipCode" /></span><span class="Kartris-DetailsView-Value">
                            <asp:TextBox runat="server" ID="txtZipCode" CssClass="postcode"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="valZipCodeRequired" ValidationGroup="Address" runat="server"
                                ControlToValidate="txtZipCode" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                CssClass="error" ForeColor="" EnableClientScript="true"></asp:RequiredFieldValidator></span></li>
                <li><span class="Kartris-DetailsView-Name">
                    <asp:Label ID="lblPhone" runat="server" Text="<%$ Resources: Address, FormText_PhoneNumber %>" EnableViewState="false"
                        AssociatedControlID="txtPhone" CssClass="requiredfield" /></span><span class="Kartris-DetailsView-Value">
                            <asp:TextBox runat="server" ID="txtPhone" CssClass="phone"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="valTelePhoneRequired" ValidationGroup="Address" runat="server"
                                ControlToValidate="txtPhone" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                CssClass="error" ForeColor="" EnableClientScript="true"></asp:RequiredFieldValidator></span></li>
                <li><span class="Kartris-DetailsView-Name">
                    <asp:Label ID="lblCountry" runat="server" Text="<%$ Resources: Address, FormLabel_Country %>" EnableViewState="false"
                        AssociatedControlID="ddlCountry" CssClass="requiredfield" /></span><span class="Kartris-DetailsView-Value">
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
                            <asp:RequiredFieldValidator ID="valCountry" ValidationGroup="Address" runat="server"
                                InitialValue="0" ControlToValidate="ddlCountry" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                CssClass="error" ForeColor="" EnableClientScript="true"></asp:RequiredFieldValidator></span></li>
            </ul>
        </div>
        <asp:PlaceHolder ID="phdPhoneNotice" runat="server" Visible="false">(<label id="lblPhoneNotice"
            runat="server"></label>)</asp:PlaceHolder>
    </div>
</div>
