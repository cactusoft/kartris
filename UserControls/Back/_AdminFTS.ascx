<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_AdminFTS.ascx.vb" Inherits="UserControls_Back_AdminFTS" %>
<h2>
    <asp:Literal ID="litSubHeadingFullTextSearch" runat="server" Text="<%$ Resources: _DBAdmin, SubHeading_FullTextSearch %>"></asp:Literal></h2>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:MultiView ID="mvwFTS" runat="server" ActiveViewIndex="0">
            <asp:View ID="viwEnabled" runat="server">
                <p>
                    <strong>
                        <asp:Literal ID="litContentTextStatus" runat="server" Text="<%$ Resources: _Kartris, ContentText_Status %>"></asp:Literal>:
                        <asp:Literal ID="litContentTextEnabled" runat="server" Text="<%$ Resources: _Kartris, ContentText_Enabled %>"></asp:Literal></strong></p>
                        
                <p>
                    <asp:Literal ID="litContentTextLanguages" runat="server" Text="<%$ Resources: _Kartris, ContentText_Languages %>"></asp:Literal>:</p>
                <p>
                    <asp:Literal ID="litFTSLanguages" runat="server"></asp:Literal></p>
                <h3>
                    <asp:Literal ID="litNeutralLanguages" runat="server" Visible="false">
                <b>* Afrikaans, Faeroese, Malay, Albanian, Farsi, Portugese, Arabic, Georgian, 
                    Russian, Basque, Greek, Serbian, Bulgarian, Hebrew, Swahili, Byelorussian, 
                    Hindi, Urdu, Catalan and Indonesian.</b>
                    </asp:Literal></h3>
                <br /><p>
                    <asp:LinkButton CssClass="linkbutton icon_delete" ID="lnkStopFTS" runat="server"
                        Text="<%$ Resources: _Kartris, FormButton_Delete %>" /></p>
            </asp:View>
            <asp:View ID="viwNotEnabled" runat="server">
                <p>
                    <asp:Literal ID="litContentTextFTSNotEnabled" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_FTSNotEnabled %>"></asp:Literal></p>
                    <br /><p><asp:LinkButton CssClass="linkbutton icon_new" ID="lnkSetupFTS" runat="server" Text="<%$ Resources: _Kartris, ContentText_ClickHere %>" /></p>
            </asp:View>
            <asp:View ID="viwNotSupported" runat="server">
                <p>
                    <asp:Literal ID="Literal1" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_FTSNotSupported %>"></asp:Literal></p>
            </asp:View>
        </asp:MultiView>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="upgMain" runat="server" AssociatedUpdatePanelID="updMain">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
