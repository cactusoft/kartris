<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_Options.ascx.vb" Inherits="_Options"  %>
<asp:UpdatePanel ID="updOptions" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <div class="boxinset">
            <div class="option">
                <label class="optiontitle">
                    <asp:TextBox ID="txtDummy" runat="server" Visible="false" />
                    <asp:Label ID="lblOptionGroupName" runat="server"></asp:Label>
                    <asp:RequiredFieldValidator ID="valRequiredField" runat="server" CssClass="error" ControlToValidate="txtDummy"
                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                            Display="Dynamic" SetFocusOnError="true" Enabled="false" ValidationGroup="SaveOptions" />
                </label>
                <div>
                    <asp:UpdatePanel ID="updOption" runat="server">
                        <ContentTemplate>
                            <asp:PlaceHolder ID="phdOption" runat="server"></asp:PlaceHolder>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </div>
            <asp:Label ID="lblCurrencyID" runat="server" Visible="False"></asp:Label>
            <asp:Label ID="lblOptionDescription" runat="server" Visible = "false"></asp:Label>
        </div>
    </ContentTemplate>
</asp:UpdatePanel>
