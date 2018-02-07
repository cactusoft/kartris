<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_destinations.aspx.vb" Inherits="Admin_Destinations"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <h1>
        <asp:Literal ID="litPageTitleShippingDestinationCountries" runat="server" Text="<%$ Resources: _Shipping, PageTitle_ShippingDestinationCountries %>" />
        <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=9798')">?</a>
    </h1>
    <asp:UpdatePanel ID="updDefaultCountry" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <p>
                <asp:Literal ID="litDefaultDesc" runat="server"></asp:Literal></p>
            <div id="section_destination_default">
                <span class="Kartris-DetailsView-Name">
                    <asp:Label ID="lblCountry" runat="server" Text="frontend.checkout.defaultcountry"
                        EnableViewState="false" AssociatedControlID="ddlCountry" CssClass="requiredfield" />
                </span><span class="Kartris-DetailsView-Value">
                    <asp:ObjectDataSource ID="KartrisCountryList" runat="server" TypeName="KartrisClasses+Country"
                        SelectMethod="GetAll" EnableCaching="false">
                        <SelectParameters>
                            <asp:SessionParameter SessionField="_lang" DbType="Int16" Name="LanguageID" />
                        </SelectParameters>
                    </asp:ObjectDataSource>
                    <asp:DropDownList runat="server" ID="ddlCountry" DataSourceID="KartrisCountryList"
                        DataTextField="Name" DataValueField="CountryId" AppendDataBoundItems="true" EnableViewState="true">
                        <asp:ListItem Text="<%$ Resources: Kartris, ContentText_DropdownSelectDefault %>"
                            Value="0" />
                    </asp:DropDownList>
                    <asp:Button CssClass="button" runat="server" ID="btnUpdate" Text="<%$ Resources: _Kartris, FormButton_Update %>">
                    </asp:Button>
                </span>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    <_user:ZoneDestinations ID="_UC_ZoneDestinations" runat="server" />
</asp:Content>
