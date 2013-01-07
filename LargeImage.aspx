<%@ Page Language="VB" AutoEventWireup="false" CodeFile="LargeImage.aspx.vb" Inherits="LargeImage" %>

<%@ Register TagPrefix="user" TagName="NoMasterCSS" Src="~/UserControls/Front/NoMasterCSS.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" style="border: none;">
<head runat="server">
    <user:NoMasterCSS ID="UC_NoMasterCSS" runat="server" />
    <title></title>
</head>
<body style="border: none; text-align: center;">
    <div>
        <form id="frmLargeImage" runat="server">
        <asp:ScriptManager ID="scrManager" runat="server">
        </asp:ScriptManager>
        <user:ImageViewer ID="UC_ImageView" runat="server" LargeViewClickable="False" />
        </form>
    </div>
</body>
</html>
