<%@ Page Language="VB" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="true"
    CodeFile="CustomerAccount.aspx.vb" Inherits="Customer_Account" %>

<%@ Register TagPrefix="user" TagName="KartrisLogin" Src="~/UserControls/Front/KartrisLogin.ascx" %>
<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <h1>
        <asp:Literal ID="litTitle" runat="server" Text="<%$ Resources:Kartris, PageTitle_MyAccount %>" /></h1>
    <p>
        <asp:Literal ID="litMustBeLoggedIn" runat="server" Visible="false" Text="<%$ Resources: ContentText_LogInToSite %>" /></p>
    <asp:UpdatePanel runat="server" ID="updMain">
        <ContentTemplate>
            <div>
                <user:KartrisLogin runat="server" ID="UC_KartrisLogin" ForSection="myaccount" />
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
