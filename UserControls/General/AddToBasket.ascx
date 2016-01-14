<%@ Control Language="VB" AutoEventWireup="false" CodeFile="AddToBasket.ascx.vb"
    Inherits="UserControls_General_AddToBasket" %>
<asp:Panel runat="server" ID="pnlAdd" DefaultButton="btnAdd">
<asp:UpdatePanel ID="updAddQuantity" runat="server" UpdateMode="Conditional" RenderMode="Inline">
    <ContentTemplate>
        <%
            'We will add the values dynamically in the codebehind
            'based on the config setting 'frontend.basket.addtobasketdropdown.max'
        %>
        <asp:DropDownList ID="ddlItemsQuantity" runat="server" CssClass="dropdown hide-for-small">
        </asp:DropDownList>
        <%
            'Default the text box value to 1 so can just hit button
            'in AddToBasket.ascx.vb we will change this to the
            'unitsize if required, e.g. 10, 12 etc.
        %>
        <asp:TextBox ID="txtItemsQuantity" runat="server" CssClass="textbox hide-for-small" text="1" MaxLength="6"></asp:TextBox>
        
        <asp:UpdatePanel ID="updAddButton" runat="server" UpdateMode="Conditional" RenderMode="Inline">
            <ContentTemplate>
                <asp:Button ID="btnAdd" runat="server" Text='<%$ Resources: Products, FormButton_Add %>' CssClass="button" />
            </ContentTemplate>
        </asp:UpdatePanel>

        <%
            'Need to validate the input and to allow only numbers (and "." in case of decimal qty - in code behind)
         %>
        <asp:CompareValidator ID="cvQuantity" runat="server" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
            ControlToValidate="txtItemsQuantity" Operator="DataTypeCheck" Type="Double" CssClass="error" ForeColor=""
            Enabled="true" Display="Dynamic" SetFocusOnError="true" />
        <ajaxToolkit:FilteredTextBoxExtender ID="filQuantity" runat="server" TargetControlID="txtItemsQuantity"
            FilterType="Numbers" Enabled="true" />
    </ContentTemplate>
</asp:UpdatePanel>
<asp:Literal ID="litVersionID" runat="server" Visible="False"></asp:Literal>
</asp:Panel>
