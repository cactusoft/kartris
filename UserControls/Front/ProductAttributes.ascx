<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductAttributes.ascx.vb"
    Inherits="ProductAttributes" %>
<asp:PlaceHolder ID="phdDetails" runat="server">
    <div class="attributes">
        <table class="filled">
            <thead>
                <tr class="headrow">
                    <th>
                        <asp:Literal ID="litContentTextAttributeName" runat="server" Text='<%$ Resources:Attributes, ContentText_AttributeName %>' />
                    </th>
                    <th>
                        <asp:Literal ID="litContentTextAttributeValue" runat="server" Text='<%$ Resources:Attributes, ContentText_AttributeValue %>' />
                    </th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptAttributes" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td class="itemname">
                                <asp:Literal ID="litAttributeName" runat="server" Text='<%#Eval("ATTRIB_Name") %>'
                                    Mode="Encode" />
                            </td>
                            <td>
                                <asp:Literal ID="litAttributeValue" runat="server" Text='<%#Eval("ATTRIBV_Value") %>'
                                    Mode="Encode" />
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>
</asp:PlaceHolder>
