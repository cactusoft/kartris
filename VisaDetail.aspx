<%@ Page Language="VB" Buffer="true" ValidateRequest="false" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="false" CodeFile="VisaDetail.aspx.vb" Inherits="Callback" %>

<asp:Content id="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <h2>
        <asp:Literal ID="lblEntity" runat="server" Text="Entity"
                                EnableViewState="false" />
    </h2>
    <asp:Literal ID="valEntity" runat="server" Text=""
                                EnableViewState="false" />
    <br />
    <h2>
        <asp:Literal ID="lblRef" runat="server" Text="Reference"
                                EnableViewState="false" />
    </h2>
    <asp:Literal ID="valRef" runat="server" Text=""
                                EnableViewState="false" />
    <br />
    <h2>
        <asp:Literal ID="lblAmount" runat="server" Text="Amount"
                                EnableViewState="false" />
    </h2>
    <asp:Literal ID="valAmount" runat="server" Text=""
                                EnableViewState="false" />
    <br />
</asp:Content>