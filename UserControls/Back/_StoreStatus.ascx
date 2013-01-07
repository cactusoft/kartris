<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_StoreStatus.ascx.vb"
    Inherits="UserControls_Back_StoreStatus" %>
    
<script type="text/javascript" language="javascript">
    //<![CDATA[

    //Function to set URL for iframe of media popup, size it, and show it
    function CloseStore() {
        var objLink = document.getElementById('ctl00__UC_StoreStatus_btnCloseStore');
        objLink.className = "closedstore";
    }

    function OpenStore() {
        var objLink = document.getElementById('ctl00__UC_StoreStatus_btnOpenStore');
        objLink.className = "openedstore";
    }
    //]]>
</script>
    
<asp:UpdatePanel ID="updStoreStatus" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:MultiView ID="mvwStoreStatus" runat="server" ActiveViewIndex="0">
            <asp:View ID="viwEmpty" runat="server">
            </asp:View>
            <asp:View ID="viwOpen" runat="server">
                <asp:LinkButton ID="btnCloseStore" runat="server" Text=" "
                    CssClass="openedstore" OnClientClick="CloseStore()" />
            </asp:View>
            <asp:View ID="viwClosed" runat="server">
                <asp:LinkButton ID="btnOpenStore" runat="server" Text=" "
                    CssClass="closedstore" OnClientClick="OpenStore()" />
            </asp:View>
        </asp:MultiView>
    </ContentTemplate>
</asp:UpdatePanel>


