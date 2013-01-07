<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductReviews.ascx.vb"
    Inherits="ProductReviews" %>
<%@ Register TagPrefix="user" TagName="WriteReview" Src="~/UserControls/Templates/WriteReviewTemplate.ascx" %>
<div class="reviews">
    <ajaxToolkit:TabContainer CssClass=".tab" ID="tbcMain" runat="server" EnableTheming="False">
        <ajaxToolkit:TabPanel ID="tabReadReview" runat="server">
            <HeaderTemplate>
                <asp:Literal ID="litReviewsHeader" runat="server" />
            </HeaderTemplate>
            <ContentTemplate>
                <div class="reviews_list">
                    <asp:MultiView ID="mvwReview" runat="server" ActiveViewIndex="0">
                        <asp:View ID="viwReview" runat="server">
                            <asp:Repeater ID="rptReviews" runat="server">
                                <SeparatorTemplate>
                                </SeparatorTemplate>
                                <ItemTemplate>
                                    <user:ReviewTemplate ID="UC_ReviewTemplate" runat="server" />
                                </ItemTemplate>
                            </asp:Repeater>
                        </asp:View>
                        <asp:View ID="viwNoReview" runat="server">
                            <asp:Literal ID="litNoReview" runat="server" Text="<%$ Resources:Reviews, ContentText_NoReviews %>"></asp:Literal>
                        </asp:View>
                    </asp:MultiView></div>
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
        <ajaxToolkit:TabPanel runat="server" ID="tabWriteReview">
            <HeaderTemplate>
                <asp:Literal ID="litWriteReviewText" runat="server" Text="" />
            </HeaderTemplate>
            <ContentTemplate>
                <user:WriteReview ID="UC_WriteReview" runat="server" />
                <br />
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
    </ajaxToolkit:TabContainer>
</div>
