<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_OrderBreadcrumb.ascx.vb"
    Inherits="UserControls_Back_OrderBreadcrumb" %>
<asp:PlaceHolder runat="server" ID="phdOrderBreadcrumb">
    <div class="breadcrumbtrail">
        <span>
            <span>
                <asp:HyperLink ID="lnkParent" runat="server"></asp:HyperLink>
            </span>
            <span>&#160;</span>
            <span>
                <asp:HyperLink ID="lnkChild" runat="server"></asp:HyperLink>
            </span>
        </span>
    </div>
</asp:PlaceHolder>
