<%@ Page Language="VB" AutoEventWireup="true" CodeFile="Default.aspx.vb" Inherits="Main"
    MasterPageFile="~/Skins/Kartris/Template.master" %>

<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <div id="homepage">
        <user:PopupMessage ID="UC_PopUpConfirmMail" runat="server" />
        <% '--------Home page main feature---------- %>
        <user:Page ID="UC_Page" runat="server" PageName="default" EnableViewState="False" />
        <div class="spacer">
        </div>
        <% '--------Various highlighted products and info---------- %>
        <div class="chunks row">
            <div class="chunk small-12 columns">
                <user:FeaturedProducts ID="UC_FeaturedProducts" runat="server" />
            </div>
            <div class="chunk small-12 columns">
                <user:NewestItems ID="UC_NewestItems" runat="server" EnableViewState="False" />
            </div>
            <div class="chunk small-12 columns">
                <user:TopListProducts ID="UC_TopListProducts" runat="server" EnableViewState="False" />
            </div>
            <div class="chunk small-12 columns">
                <user:SiteNews ID="UC_SiteNews" runat="server" TitleTagType="h2" EnableViewState="False" />
            </div>
            <div class="spacer">
            </div>
        </div>
    </div>
</asp:Content>
