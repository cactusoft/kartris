<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductCompareValues.ascx.vb" Inherits="ProductCompareValues" %>
<asp:Literal ID="litPriceHidden" runat="server" Text='<%# Eval("P_Price") %>' Visible="false"></asp:Literal>

<p class="minprice"><asp:Literal ID="litMinPrice" runat="server"></asp:Literal></p>
<asp:Repeater ID="rptProductAttributes" runat="server">
    <HeaderTemplate>
        <table>
    </HeaderTemplate>
    <ItemTemplate>
        <tr>
            <td>
                <asp:Literal ID="litAttIDHidden" runat="server" Text='<%# Eval("ATTRIB_ID") %>' Visible="false"></asp:Literal>
                <asp:Literal ID="litAttName" runat="server" Text='<%# Eval("ATTRIB_Name") %>'></asp:Literal>
            </td>
            <td>
                <asp:Literal ID="litAttValue" runat="server" Text='<%# Eval("ATTRIB_Value") %>' Mode="Encode"></asp:Literal>
            </td>
        </tr>
    </ItemTemplate>
    <FooterTemplate>
        </table>
    </FooterTemplate>
</asp:Repeater>
