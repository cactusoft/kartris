<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_languagestrings.aspx.vb"
    Inherits="Admin_LanguageStrings" MasterPageFile="~/Skins/Admin/Template.master" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_languagestrings">
        <h1>
            <asp:Literal ID="litBackMenuLanguageStrings" runat="server" Text='<%$ Resources:_Kartris, BackMenu_LanguageStrings %>'></asp:Literal></h1>
        <ajaxToolkit:TabContainer ID="conTabs" runat="server" CssClass=".tab" EnableTheming="false">
            <ajaxToolkit:TabPanel ID="tabLanguageStrings" runat="server">
                <HeaderTemplate>
                    <asp:Literal ID="litPageTitle1" runat="server" Text='<%$ Resources: _Kartris, BackMenu_LanguageStrings %>'></asp:Literal>
                </HeaderTemplate>
                <ContentTemplate>
                    <div class="subtabsection">
                        <_user:LanguageStrings ID="_UC_LanguageStrings" runat="server" />
                    </div>
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
            <ajaxToolkit:TabPanel ID="tabStringsTranslation" runat="server">
                <HeaderTemplate>
                    <asp:Literal ID="litPageTitle" runat="server" Text='<%$ Resources: _Kartris, BackMenu_StringsTranslation %>'></asp:Literal></HeaderTemplate>
                <ContentTemplate>
                    <div class="subtabsection">
                        <_user:LanguageStringsTranslation ID="_UC_LSTranslation" runat="server" />
                    </div>
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
        </ajaxToolkit:TabContainer>
    </div>
</asp:Content>
