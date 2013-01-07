<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_CustomersList.aspx.vb"
    Inherits="Admin_CustomersList" MasterPageFile="~/Skins/Admin/Template.master" %>

<%@ Register TagPrefix="_user" TagName="CustomersList" Src="~/UserControls/Back/_CustomersList.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <asp:UpdatePanel runat="server" ID="updCustomersList" UpdateMode="Conditional">
        <ContentTemplate>
            <div id="page_customers">
                <h1>
                    <asp:Literal ID="litCustomersListTitle" runat="server" Text="<%$Resources: PageTitle_Customers %>"></asp:Literal></h1>
                <div id="searchboxrow">
                    <asp:Label ID="lblFindCustomer" runat="server" Text="<%$Resources: ContentText_FindACustomer%>"
                        Visible="False"></asp:Label>
                    <div>
                        <asp:TextBox ID="txtSearch" runat="server" />
                        <asp:Button ID="btnSearch" runat="server" Text="<%$ Resources:_Kartris, FormButton_Search %>"
                            CssClass="button" />
                    </div>
                    <br />
                    <p>
                        <asp:Literal ID="litDetails" runat="server" Text="<%$Resources: ContentText_EnterEmailAddress%>"></asp:Literal></p>
                </div>
                <br />
                <_user:CustomersList ID="_UC_CustomersList" runat="server" />
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    <asp:UpdateProgress ID="prgCustomers" runat="server" AssociatedUpdatePanelID="updCustomersList">
        <ProgressTemplate>
            <div class="loadingimage">
            </div>
            <div class="updateprogress">
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>
</asp:Content>
