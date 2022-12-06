<%@ Page Language="VB" AutoEventWireup="false" CodeFile="CheckoutProcess.aspx.vb" Inherits="checkout_process" %>

<!DOCTYPE html>
<html class="no-js" lang="en">
<head runat="server">
    <title>Payment</title>
    <meta name="referrer" content="no-referrer" />  
</head>
<body>
    <!-- STATIC PAGE GATEWAY TYPE -->
    <asp:Literal ID="litStaticPage" runat="server" Visible="false"></asp:Literal>

    <!-- REMOTE GATEWAY TYPE -->
    <form id="form1" runat="server">
    <div>
     <asp:Panel ID="MainPanel" runat="server"/>
        <p><strong><asp:Literal ID="litGatewayTestForwarding" runat="server" EnableViewState="false" Visible="false" /> </strong></p>
        <asp:Panel ID="GateWayPanel" runat="server" Visible="false">
        </asp:Panel>
    </div>
     <asp:button ID="btnSubmit" runat="server" Text="<%$ Resources: Kartris, FormButton_Submit %>" UseSubmitBehavior="true" Visible="true" EnableViewState="False" />
    </form>
</body>
</html>
