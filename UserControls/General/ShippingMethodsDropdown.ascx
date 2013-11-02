<%@ Control Language="VB" AutoEventWireup="true" CodeFile="ShippingMethodsDropdown.ascx.vb" Inherits="UserControls_ShippingMethodsDropdown" %>
<%@ Import namespace="Kartris.Payment" %>
<asp:UpdatePanel ID="updShippingMethods" runat="server">
    <ContentTemplate>
        <asp:DropDownList ID="ddlShippingMethods" runat="server" AutoPostBack="true" />
        <asp:UpdateProgress ID="prgShippingMethods" runat="server" AssociatedUpdatePanelID="updShippingMethods" DynamicLayout="True">
            <ProgressTemplate>
                <div class="smallupdateprogress">
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>        
        
        <asp:RequiredFieldValidator ID="valShippingMethods" runat="server" ControlToValidate="ddlShippingMethods"
                                     Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                     CssClass="error" ForeColor="" ValidationGroup="Checkout"></asp:RequiredFieldValidator>
        <asp:Literal ID="litContentTextShippingAvailableAfterAddress" runat="server"
         Text="<%$ Resources: ContentText_ShippingAvailableAfterAddress %>" Visible="False"></asp:Literal>

    </ContentTemplate>
</asp:UpdatePanel>
