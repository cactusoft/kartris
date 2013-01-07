<%@ Page Language="VB" AutoEventWireup="false" CodeFile="MultiMedia.aspx.vb" Inherits="MultiMedia" %>

<%@ Register TagPrefix="user" TagName="NoMasterCSS" Src="~/UserControls/Front/NoMasterCSS.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" style="border: none;">
<head runat="server">
    <user:NoMasterCSS ID="UC_NoMasterCSS" runat="server" />
    <title></title>
</head>
<body style="border: none; text-align: center;">
    <div>
        <form id="frmMediaPopup" runat="server">
        <asp:ScriptManager ID="scrManager" runat="server">
        </asp:ScriptManager>
        <asp:Repeater ID="rptMediaLinks" runat="server">
            <ItemTemplate>
                <div class="media_links">
                    <asp:Literal ID="litMediaLink" runat="server"></asp:Literal>
                    <asp:HyperLink Visible="false" CssClass="media_downloadlink" ID="lnkDownload" runat="server"
                        ToolTip="<%$ Resources:Media, ContentText_Download %>">
                    </asp:HyperLink>
                </div>
            </ItemTemplate>
        </asp:Repeater>
        <asp:PlaceHolder ID="phdInline" runat="server"></asp:PlaceHolder>
        </form>
    </div>
</body>
</html>
