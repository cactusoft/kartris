<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_PaymentGateways.aspx.vb"
    Inherits="Admin_PaymentGateways" MasterPageFile="~/Skins/Admin/Template.master" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <h1>
        <asp:Literal ID="litContentTextPaymentShippingGateways" runat="server" Text='<%$ Resources: _Kartris, ContentText_PaymentShippingGateways %>'
            EnableViewState="False"></asp:Literal>
    </h1>
    <p><asp:Literal ID="litDetails" runat="server" Text="<%$ Resources: ContentText_PaymentShippingGatewaysText %>"></asp:Literal></p>
    <div class="spacer">
        &nbsp;</div>
    <table class="kartristable">
        <thead>
            <tr>
                <th scope="col" class="itemname">
                    <asp:Literal ID="litFormLabelName" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Name %>" />
                </th>
                <th scope="col" >
                    <asp:Literal ID="litContentTextType" runat="server" Text="<%$ Resources: _Kartris, ContentText_Type %>" />
                </th>
                <th scope="col">
                    <asp:Literal ID="litContentTextStatus" runat="server" Text="<%$ Resources: _Kartris, ContentText_Status %>" />
                </th>
                <th class="selectfield" scope="col">
                    &nbsp;
                </th>
            </tr>
        </thead>
        <tbody>
            <asp:Repeater ID="rptGateways" runat="server">
                <ItemTemplate>
                    <tr class="<%# If(Container.ItemIndex Mod 2 = 0, "", "Kartris-GridView-Alternate") %>">
                        <td class="itemname">
                            <asp:Literal ID="litName" runat="server" Text='<%# DataBinder.Eval(Container.DataItem, "Name") %>'></asp:Literal>
                        </td>
                        <td>
                            <asp:Literal ID="litGatewayType" runat="server" Text='<%# DataBinder.Eval(Container.DataItem, "Type") %>'></asp:Literal>
                        </td>
                        <td>
                            <asp:Literal ID="litStatus" runat="server" Text='<%# ShowBlank(DataBinder.Eval(Container.DataItem, "Status")) %>'></asp:Literal>
                        </td>
                        <td class="selectfield">
                            <a class="linkbutton icon_edit" href='_GatewaySettings.aspx?g=<%# DataBinder.Eval(Container.DataItem, "Name") %>'>
                                <asp:Literal ID="litFormButtonEdit" runat="server" Text="<%$ Resources: _Kartris, FormButton_Edit %>" /></a>
                        </td>
                    </tr>
                </ItemTemplate>
            </asp:Repeater>
        </tbody>
    </table>
    <div id="updatebuttonbar" class="squarebuttons topsubmitbuttons">
    <asp:LinkButton CssClass="refreshbutton" runat="server" ID="btnRefresh" Text="<%$ Resources: _Kartris, ContentText_Refresh %>"
    ToolTip="<%$ Resources: _Kartris, ContentText_Refresh %>"></asp:LinkButton>
    </div>
</asp:Content>
