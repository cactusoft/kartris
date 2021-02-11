<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductCompare.ascx.vb" Inherits="ProductCompare" %>
<%@ Register TagPrefix="user" TagName="ProductCompareValues" Src="~/UserControls/Front/ProductCompareValues.ascx" %>

<asp:UpdatePanel ID="updComparison" runat="server">
    <ContentTemplate>
        <asp:Repeater ID="rptCompareProducts" runat="server">
            <ItemTemplate>
                <div class="item small-12 large-6 columns loadspinner">
                    <div class="pad">
                        <asp:Literal ID="litP_ID" runat="server" Text='<%# Eval("P_ID") %>' Visible="false" />
                        <div class="imageblock">
                            <user:ImageViewer ID="UC_ImageViewer" runat="server" />
                        </div>
                        <h2>
                            <asp:HyperLink ID="lnkProductName" runat="server" NavigateUrl='<%# Eval("P_ID", "~/product.aspx?ProductID={0}") %>'
                                Text='<%# Server.HtmlEncode(Eval("P_Name")) %>'></asp:HyperLink></h2>
                        <div class="spacer">
                        </div>
                        <user:ProductCompareValues ID="UC_ProductCompareValues" runat="server" />
                        <div class="removelink">
                            <asp:HyperLink ID="lnkRemove" runat="server" Text="<%$ Resources:Products, ContentText_CompareRemove %>"
                                CssClass="link2 icon_delete" NavigateUrl='<%# Eval("P_ID", "~/product.aspx?action=del&id={0}") %>' />
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </ContentTemplate>
</asp:UpdatePanel>
