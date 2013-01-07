<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_revisions.aspx.vb" Inherits="Admin_Revisions"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_revisions">
        <h1>
            <asp:Literal ID="litPageTitleRevisions" Text="<%$ Resources: _Kartris, BackMenu_Revisions %>"
                runat="server" /></h1>
        <asp:PlaceHolder ID="phdFeed" runat="server" Visible="True">
            <div class="section_revisions">
                <asp:Literal ID="litXMLData" runat="server"></asp:Literal>
            </div>
            <p>
                *<asp:Literal ID="litContentTextInstalledExplanation" Text="<%$ Resources: _SoftwareUpdate, ContentText_InstalledExplanation %>"
                    runat="server" /></p>
        </asp:PlaceHolder>
        <asp:PlaceHolder ID="phdFeedNotAccessible" runat="server" Visible="false">
            <p>
                <asp:Literal ID="litContentTextFeedNotAccessible" runat="server" Text="<%$ Resources: _Kartris, ContentText_FeedNotAccessible %>" /></p>
        </asp:PlaceHolder>
    </div>
</asp:Content>
