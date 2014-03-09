<%@ Control Language="VB" AutoEventWireup="true" CodeFile="_ShippingMethodsDropdown.ascx.vb" Inherits="_ShippingMethodsDropdown" %>
<%@ Import namespace="Kartris.Payment" %>
<asp:UpdatePanel ID="updShippingMethods" runat="server">
    <ContentTemplate>
        <asp:DropDownList ID="ddlShippingMethods" runat="server" AutoPostBack="true" />
        <asp:RequiredFieldValidator ID="valShippingMethods" runat="server" ControlToValidate="ddlShippingMethods"
                                     Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                     CssClass="error" ForeColor="" ValidationGroup="Checkout"></asp:RequiredFieldValidator>
        <asp:UpdateProgress ID="prgShippingMethods" runat="server" AssociatedUpdatePanelID="updShippingMethods" DynamicLayout="False">
            <ProgressTemplate>
                <div class="smallupdateprogress">
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
        <asp:Literal ID="litContentTextShippingAvailableAfterAddress" runat="server"
         Text="-" Visible="False"></asp:Literal>
        
    </ContentTemplate>
</asp:UpdatePanel>
