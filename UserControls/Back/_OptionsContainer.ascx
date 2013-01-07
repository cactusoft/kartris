<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_OptionsContainer.ascx.vb"
    Inherits="_OptionsContainer" %>
<%@ Register TagPrefix="_user" TagName="Options" Src="~/UserControls/Back/_Options.ascx" %>
<div class="options">
    <div class="pad">
        <asp:Label ID="lblErrorDefaults" runat="server" ForeColor="Red" Text="Error: No Selected Product, Language and/or Currency."
            Visible="False"></asp:Label>
        <_user:Options ID="UC_HiddenOption" runat="server" Visible="false" />
        <asp:UpdatePanel ID="updOptions2" runat="server">
            <ContentTemplate>
                <asp:PlaceHolder ID="phdOptions" runat="server"></asp:PlaceHolder>
            </ContentTemplate>
        </asp:UpdatePanel>
        <div class="spacer">
        </div>
    </div>
</div>
