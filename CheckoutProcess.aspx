<%@ Page Language="VB" AutoEventWireup="false" CodeFile="CheckoutProcess.aspx.vb" Inherits="checkout_process" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server"/>
<body>
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
