<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductQuantityDiscounts.ascx.vb"
    Inherits="ProductQuantityDiscounts" %>
<div id="section_quantitydiscounts">
    <asp:UpdatePanel ID="updQD" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:Repeater ID="rptQuantityDiscount" runat="server">
                <ItemTemplate>
                    <table class="filled">
                        <thead>
                            <tr>
                                <th class="name">
                                    <asp:Literal ID="litVersionName" runat="server" Text='<%# Eval("VersionName") %>' />
                                    <asp:HiddenField ID="hidVersionID" runat="server" Value='<%# Eval("VersionID") %>' />
                                </th>
                                <th class="quantity">
                                    <asp:Literal ID="litContentTextQuantity" runat="server" Text="<%$ Resources: Kartris, ContentText_Quantity %>" />
                                </th>
                                <th class="price">
                                    <asp:Literal ID="liContentTextPrice" runat="server" Text="<%$ Resources: Kartris, ContentText_Price %>" />
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptVersionsDiscount" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td>
                                            &nbsp;
                                        </td>
                                        <td class="quantity">
                                            <asp:Literal ID="litQuantity" runat="server" Text='<%# Eval("Quantity") %>' />
                                        </td>
                                        <td class="price">
                                            <asp:Literal ID="litPrice" runat="server" Text='<%# Eval("Price") %>' />
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                    <asp:Literal ID="litVersionCode_Hidden" runat="server" Text='<%# Eval("VersionCode") %>'
                        Visible="false" />
                </ItemTemplate>
            </asp:Repeater>
            <p>
                <asp:Literal ID="litContentTextDiscountsAvailable" runat="server" Text="<%$ Resources: Versions, ContentText_DiscountsAvailable %>" /></p>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
