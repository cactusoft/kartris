<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductPromotions.ascx.vb"
    Inherits="ProductPromotions" %>
<asp:Panel ID="pnlPromotions" runat="server">
    <div class="section_promotions">
        <asp:PlaceHolder ID="phdSubHeading" runat="server">
            <h4>
                <asp:Literal ID="litSubHeaderPromotions" runat="server" Text="<%$ Resources: Kartris, SubHeading_Promotions %>" /></h4>
        </asp:PlaceHolder>
        <asp:Repeater ID="rptProductPromotion" runat="server">
            <ItemTemplate>
                <user:PromotionTemplate ID="UC_PromotionTemplate" runat="server" PromotionID='<%#Eval("PROM_ID")%>'
                    PromotionName='<%# Server.HtmlEncode(Eval("PROM_Name")) %>' PromotionText='<%#eval("PROM_Text")%>' />
            </ItemTemplate>
        </asp:Repeater>
        <asp:PlaceHolder ID="phdNoResults" runat="server">
            <asp:Literal ID="litNoPromotions" Text="<%$ Resources: Promotions, ContentText_NoPromotions %>"
                runat="server"></asp:Literal>
        </asp:PlaceHolder>
    </div>
</asp:Panel>
