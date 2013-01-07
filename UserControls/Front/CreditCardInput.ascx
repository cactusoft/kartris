<%@ Control Language="VB" AutoEventWireup="false" CodeFile="CreditCardInput.ascx.vb"
    Inherits="UserControls_Front_CreditCardInput" %>
<div class="creditcardinput">

    <div class="Kartris-DetailsView">
        <div class="Kartris-DetailsView-Data">
            <h2><asp:Literal ID="litCreditCardDesc" runat="server" Text="<%$ Resources: Checkout, ContentText_CreditCardDetails %>" /></h2>
            <ul>
                <li><span class="Kartris-DetailsView-Name">
                    <asp:Label CssClass="requiredfield" ID="lblCardType" runat="server" Text="<%$ Resources: ContentText_CardType %>"
                        AssociatedControlID="ddlCardType" EnableViewState="false" /></span> <span class="Kartris-DetailsView-Value">
                            <!-- populated programmatically -->
                            <asp:DropDownList runat="server" ID="ddlCardType" />
                            <asp:RequiredFieldValidator ID="valRequiredCardType" runat="server" ControlToValidate="ddlCardType"
                                ErrorMessage="<%$ Resources: Kartris, ContentText_RequiredField %>" EnableClientScript="true"
                                Display="Dynamic" ValidationGroup="CreditCard" CssClass="error" ForeColor="" />
                        </span></li>
                <li><span class="Kartris-DetailsView-Name">
                    <asp:Label CssClass="requiredfield" ID="lblCardNumber" runat="server" Text="<%$ Resources: ContentText_CardNumber %>"
                        AssociatedControlID="txtCardNumber" EnableViewState="false" /></span> <span class="Kartris-DetailsView-Value">
                            <asp:TextBox ID="txtCardNumber" runat="server" Text="4929000000006" />
                            <asp:RegularExpressionValidator ID="valRegExCardNumber" runat="server" ControlToValidate="txtCardNumber"
                                ErrorMessage="<%$ Resources: Error, ContentText_IsNotNumeric %>" EnableClientScript="true"
                                Display="Dynamic" ValidationGroup="CreditCard" ValidationExpression="[0-9]*"
                                CssClass="error" ForeColor="" />
                            <asp:RequiredFieldValidator ID="valRequiredCardNumber" runat="server" ControlToValidate="txtCardNumber"
                                ErrorMessage="<%$ Resources: Kartris, ContentText_RequiredField %>" EnableClientScript="true"
                                Display="Dynamic" ValidationGroup="CreditCard" CssClass="error" ForeColor="" />
                        </span></li>
                <li><span class="Kartris-DetailsView-Name">
                    <asp:Label ID="lblCardIssueNumber" runat="server" Text="<%$ Resources: ContentText_CardIssueNumber %>"
                        AssociatedControlID="txtCardIssueNumber" EnableViewState="false" /></span> <span
                            class="Kartris-DetailsView-Value">
                            <asp:TextBox ID="txtCardIssueNumber" runat="server" />
                            <asp:RegularExpressionValidator ID="valRegExCardIssueNumber" runat="server" ControlToValidate="txtCardIssueNumber"
                                Display="Dynamic" ErrorMessage="<%$ Resources: Error, ContentText_IsNotNumeric %>"
                                EnableClientScript="true" ValidationGroup="CreditCard" ValidationExpression="[0-9]*"
                                CssClass="error" ForeColor="" />
                        </span></li>
                <li><span class="Kartris-DetailsView-Name">
                    <asp:Label CssClass="requiredfield" ID="lblCardSecurityNumber" runat="server" Text="<%$ Resources: ContentText_SecurityNumber %>"
                        AssociatedControlID="txtCardSecurityNumber" EnableViewState="false" /></span>
                    <span class="Kartris-DetailsView-Value">
                        <asp:TextBox ID="txtCardSecurityNumber" runat="server" MaxLength="4" Text="123" />
                        <asp:RequiredFieldValidator ID="valRequiredCardSecurityNumber" runat="server" ControlToValidate="txtCardSecurityNumber"
                            ErrorMessage="<%$ Resources: Kartris, ContentText_RequiredField %>" EnableClientScript="true"
                            ValidationGroup="CreditCard" Display="Dynamic" CssClass="error" ForeColor="" />
                        <asp:RegularExpressionValidator ID="valRegExCardSecurityNumber" runat="server" ControlToValidate="txtCardSecurityNumber"
                            Display="Dynamic" ErrorMessage="<%$ Resources: Error, ContentText_IsNotNumeric %>"
                            EnableClientScript="true" ValidationGroup="CreditCard" ValidationExpression="[0-9]*"
                            CssClass="error" ForeColor="" />
                    </span></li>
                <li><span class="Kartris-DetailsView-Name">
                    <asp:Label ID="lblCardStartDate" runat="server" Text="<%$ Resources: ContentText_StartDate %>"
                        AssociatedControlID="ddlCardStartMonth" EnableViewState="false" /></span> <span class="Kartris-DetailsView-Value">
                            <asp:DropDownList runat="server" ID="ddlCardStartMonth">
                                <asp:ListItem Text="01" />
                                <asp:ListItem Text="02" />
                                <asp:ListItem Text="03" />
                                <asp:ListItem Text="04" />
                                <asp:ListItem Text="05" />
                                <asp:ListItem Text="06" />
                                <asp:ListItem Text="07" />
                                <asp:ListItem Text="08" />
                                <asp:ListItem Text="09" />
                                <asp:ListItem Text="10" />
                                <asp:ListItem Text="11" />
                                <asp:ListItem Text="12" />
                            </asp:DropDownList>
                            <asp:Literal ID="litSlash" runat="server" Text="/" EnableViewState="false" />
                            <!-- populated programmatically -->
                            <asp:DropDownList runat="server" ID="ddlCardStartYear" />
                        </span></li>
                <li><span class="Kartris-DetailsView-Name">
                    <asp:Label CssClass="requiredfield" ID="lblCardExpiry" runat="server" Text="<%$ Resources: ContentText_CardExpiry %>"
                        AssociatedControlID="ddlCardExpiryMonth" EnableViewState="false" /></span> <span
                            class="Kartris-DetailsView-Value">
                            <asp:DropDownList runat="server" ID="ddlCardExpiryMonth">
                                <asp:ListItem Text="01" />
                                <asp:ListItem Text="02" />
                                <asp:ListItem Text="03" />
                                <asp:ListItem Text="04" />
                                <asp:ListItem Text="05" />
                                <asp:ListItem Text="06" />
                                <asp:ListItem Text="07" />
                                <asp:ListItem Text="08" />
                                <asp:ListItem Text="09" />
                                <asp:ListItem Text="10" />
                                <asp:ListItem Text="11" />
                                <asp:ListItem Text="12" />
                            </asp:DropDownList>
                            <asp:Literal ID="litSlash2" runat="server" Text="/" EnableViewState="false" />
                            <!-- populated programmatically -->
                            <asp:DropDownList runat="server" ID="ddlCardExpiryYear" />
                        </span></li>
            </ul>
        </div>
    </div>
</div>
