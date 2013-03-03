<%@ Control Language="VB" AutoEventWireup="false" CodeFile="OptionsContainer.ascx.vb"
    Inherits="OptionsContainer" ClientIDMode="AutoID" %>
<%@ Register TagPrefix="user" TagName="Options" Src="~/UserControls/General/Options.ascx" %>
<div class="options">
    <div class="pad">
        <asp:Label ID="lblErrorDefaults" runat="server" ForeColor="Red" Text="Error: No Selected Product, Language and/or Currency."
            Visible="False"></asp:Label>
        <user:Options ID="UC_HiddenOption" runat="server" Visible="false" OnOption_IndexChanged="UCEvent_Options_IndexChaged" />
        <asp:UpdatePanel ID="updOptions2" runat="server">
            <ContentTemplate>
                <asp:PlaceHolder ID="phdOptions" runat="server"></asp:PlaceHolder>
            </ContentTemplate>
        </asp:UpdatePanel>
        <div class="spacer">
        </div>
    </div>
</div>
