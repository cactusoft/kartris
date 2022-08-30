<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_OrderBreadcrumb.ascx.vb"
    Inherits="UserControls_Back_OrderBreadcrumb" %>
<asp:PlaceHolder runat="server" ID="phdOrderBreadcrumb">
    <div class="breadcrumbtrail">
        <span>
            <asp:Literal ID="litLinks" runat="server"></asp:Literal>
        </span>
    </div>
</asp:PlaceHolder>
