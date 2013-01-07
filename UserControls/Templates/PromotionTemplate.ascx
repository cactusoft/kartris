<%@ Control Language="VB" AutoEventWireup="false" CodeFile="PromotionTemplate.ascx.vb"
    Inherits="Templates_PromotionTemplate" %>
<!-- promotion template start -->
<div class="promotion">
    <div class="box">
        <div class="pad">
            <asp:Literal ID="litPromotionIDHidden" runat="server" Visible="false" ></asp:Literal>
            <div class="imageblock">
                <user:ImageViewer ID="UC_ImageView" runat="server" />
            </div>
				<strong><asp:Literal EnableViewState="false" ID="litPromotionName" runat="server" Mode="Encode" ></asp:Literal></strong>
            <p>
            <asp:Literal EnableViewState="false" ID="litPromotionText" runat="server" ></asp:Literal></p>

        </div>
    </div>
</div>
<!-- promotion template end -->
