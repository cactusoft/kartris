<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ReviewTemplate.ascx.vb"
    Inherits="UserControls_Templates_New_ReviewTemplate" ClientIDMode="Static" %>
<div class="review">
    <div class="box">
        <div class="pad">
            <div class="date">
                <asp:Literal EnableViewState="false" ID="litReviewDateCreated" runat="server" Text='<%# Eval("REV_DateCreated") %>'></asp:Literal>
            </div>
            <asp:Literal EnableViewState="false" ID="litReviewIDHidden" runat="server" Text='<%# Eval("REV_ID") %>' Visible="false" />
            <asp:Literal EnableViewState="false" ID="litReviewRatingHidden" runat="server" Text='<%# Eval("REV_Rating") %>'
                Visible="false" />
            <div>
                <asp:PlaceHolder ID="phdStars" runat="server"></asp:PlaceHolder>
                <strong>
                    <asp:Literal EnableViewState="false" ID="litReviewTitle" Mode="Encode" runat="server" Text='<%# Eval("REV_Title") %>'></asp:Literal>
                </strong>
                <div class="reviewer">
                    <asp:Literal EnableViewState="false" ID="litReviewedBy" runat="server" Text='<%$ Resources:Reviews, ContentText_ReviewedBy%>'></asp:Literal>
                    <asp:Literal EnableViewState="false" ID="litReviewName" Mode="Encode" runat="server" Text='<%# Eval("REV_Name") %>'></asp:Literal>
                    -
                    <asp:Literal EnableViewState="false" ID="litReviewLocation" Mode="Encode" runat="server" Text='<%# Eval("REV_Location") %>'></asp:Literal>
                    <asp:Literal ID="litReviewCustomerIDHidden" runat="server" Text='<%# Eval("REV_CustomerID") %>'
                        Visible="false" /></div>
            </div>
            <div>
                <asp:Literal ID="litReviewText" EnableViewState="false" Mode="Encode" runat="server" Text='<%# Eval("REV_Text") %>'></asp:Literal>
            </div>
        </div>
    </div>
</div>
