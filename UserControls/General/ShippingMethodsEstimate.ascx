<%@ Control Language="VB" AutoEventWireup="true" CodeFile="ShippingMethodsEstimate.ascx.vb" Inherits="UserControls_ShippingMethodsEstimate" %>
<%@ Import namespace="Kartris.Payment" %>
<div id="shippingestimate">
<asp:UpdatePanel ID="updShippingMethods" runat="server">
    <ContentTemplate>
    <h2><asp:Literal ID="litContentTextEstimatedShipping" runat="server" Text='<%$ Resources: Basket, ContentText_EstimateShipping %>'
                                                    EnableViewState="false" Visible="true"></asp:Literal></h2>
        <div class="row">
            <div class="small-12 large-4 columns">
            <asp:ObjectDataSource ID="KartrisCountryList" runat="server" TypeName="KartrisClasses+Country"
                SelectMethod="GetAll" EnableCaching="false" CacheDuration="30">
                <SelectParameters>
                    <asp:SessionParameter SessionField="lang" DbType="Int16" Name="LanguageID" />
                </SelectParameters>
            </asp:ObjectDataSource>
            <asp:DropDownList AutoPostBack="true" runat="server" ID="ddlCountry" DataSourceID="KartrisCountryList"
                DataTextField="Name" DataValueField="CountryId" AppendDataBoundItems="true" EnableViewState="false">
                <asp:ListItem Text="<%$ Resources: Kartris, ContentText_DropdownSelectDefault %>"
                    Value="0" />
            </asp:DropDownList>
            </div>
        </div>
        <asp:Label ID="lblError" runat="server" Text="Opps .. There is a problem in estimating the shipping cost in your address, please make sure your shipping address details are correct, then try again." Visible="false" ForeColor="Red"></asp:Label>
        <asp:Gridview ID="gvwShippingMethods" runat="server" AutoGenerateColumns="false" >
        <Columns>
             <asp:TemplateField ItemStyle-CssClass="name" HeaderText='<%$ Resources: Checkout, ContentText_ShipMethod %>'>
                <ItemTemplate>
                    <asp:Literal ID="litShippingMethodName" runat="server" Text='<%# Eval("Name") %>'> </asp:Literal>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-CssClass="datafield hide-for-small" HeaderText='<%$ Resources: _Kartris, ContentText_Description %>'>
                <ItemTemplate>
                    <asp:Literal ID="litShippingMethodDescription" runat="server" Text='<%# Eval("Description") %>'> </asp:Literal>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-CssClass="currencyfield extax" HeaderText='<%$ Resources: Kartris, ContentText_ExTax %>'>
                <ItemTemplate>
                    <asp:Literal ID="litShippingMethodNameExTax" runat="server" Text='<%# Eval("EXTAX") %>'> </asp:Literal>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-CssClass="currencyfield inctax" HeaderText='<%$ Resources: Kartris, ContentText_IncTax %>'>
                <ItemTemplate>
                    <asp:Literal ID="litShippingMethodNameIncTax" runat="server" Text='<%# Eval("INCTAX") %>'> </asp:Literal>
                </ItemTemplate>
            </asp:TemplateField>
            </Columns>
        </asp:Gridview>
        <asp:UpdateProgress ID="prgShippingMethods" runat="server" AssociatedUpdatePanelID="updShippingMethods" DynamicLayout="False">
            <ProgressTemplate>
                <div class="smallupdateprogress">
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
    </ContentTemplate>
</asp:UpdatePanel>
</div>