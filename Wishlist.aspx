<%@ Page Language="VB" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="false"
    CodeFile="Wishlist.aspx.vb" Inherits="Wishlist" %>

<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <div id="page_wishlist">
        <asp:UpdatePanel ID="updWishlist" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <user:PopupMessage ID="popMessage" runat="server" />
                <user:BreadCrumbTrail ID="UC_BreadCrumbTrail" runat="server" EnableViewState="False" />
                <h1>
                    <asp:Literal ID="litTitle" runat="server" Text='<%$ Resources: Kartris, PageTitle_WishListLogin %>' /></h1>
                <asp:Panel ID="pnlLogin" runat="server" DefaultButton="lnkWistListLogin">
                    <h2>
                        <asp:Literal ID="litContentTextSeeFriendsWishList" runat="server" Text='<%$ Resources: Kartris, ContentText_SeeFriendsWishList %>' /></h2>
                    <p>
                        <asp:Literal ID="litContentText_SeeFriendsWishList2" runat="server" Text='<%$ Resources: Kartris, ContentText_SeeFriendsWishList2 %>' /></p>
                    <div class="inputform">
                        <div class="Kartris-DetailsView">
                            <div class="Kartris-DetailsView-Data">
                                <ul>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblWishListEmail" runat="server" Text='<%$ Resources: Kartris, ContentText_WishListEmail %>'
                                            AssociatedControlID="txtWishListEmail" CssClass="requiredfield"></asp:Label></span>
                                        <span class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtWishListEmail" runat="server"></asp:TextBox>
                                            <asp:RequiredFieldValidator EnableClientScript="True" ID="valWishListEmail" runat="server"
                                                ControlToValidate="txtWishListEmail" ValidationGroup="Wishlist" CssClass="error"
                                                ForeColor="" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"></asp:RequiredFieldValidator></span></li>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblPassword" runat="server" Text='<%$ Resources: Kartris, ContentText_WishListPassword %>'
                                            AssociatedControlID="txtPassword" CssClass="requiredfield"></asp:Label></span>
                                        <span class="Kartris-DetailsView-Value">
                                            <asp:TextBox MaxLength="200" ID="txtPassword" runat="server"></asp:TextBox>
                                            <asp:RequiredFieldValidator EnableClientScript="True" ID="valPassword" runat="server"
                                                ControlToValidate="txtPassword" ValidationGroup="Wishlist" CssClass="error" ForeColor=""
                                                Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"></asp:RequiredFieldValidator></span></li>
                                </ul> 
                            </div>
                        </div>
                        <div class="submitbuttons">
                        <asp:Button OnCommand="WishListLogin_Click" ValidationGroup="Wishlist" CssClass="button"
                            ID="lnkWistListLogin" runat="server" Text='<%$ Resources: Kartris, FormButton_Submit %>' /></div>
                    </div>
                    <div class="spacer"></div>
                </asp:Panel>
                <asp:Panel ID="pnlWishlist" runat="server">
                    <h2>
                        <asp:Literal ID="litPageTitleWishListFor" runat="server" Text='<%$ Resources: Kartris, PageTitle_WishListFor %>' />&nbsp;
                        <asp:Literal ID="litOwnerName" runat="server" /></h2>
                    <p>
                        <asp:Literal ID="litMessage" runat="server" />
                    </p>
                    <p>
                        <asp:Literal ID="litContentTextWishListForDesc" runat="server" Text='<%$ Resources: Kartris, ContentText_WishListForDesc %>' />
                    </p>
                    <asp:Repeater ID="rptWishList" runat="server">
                        <HeaderTemplate>
                            <table class="baskettable">
                                <thead>
                                    <tr class="headrow">
                                        <th>
                                            <asp:Literal ID="litContentTextItem" runat="server" Text='<%$ Resources: Kartris, ContentText_Item %>' />
                                        </th>
                                        <th>
                                            <asp:Literal ID="litContentTextStatus" runat="server" Text='<%$ Resources: Kartris, ContentText_Status %>' />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <asp:HyperLink ID="lnkWishListItem" runat="server"></asp:HyperLink>
                                    <span class="versioncode"><asp:Literal ID="litVersionCode" runat="server" Text='<%# Server.HTMLEncode(Eval("VersionCode")) %>' /></span>
                                </td>
                                <td>
                                    <asp:Literal ID="litRequired" runat="server" />
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                            </tbody></table>
                        </FooterTemplate>
                    </asp:Repeater>
                    
                    <asp:PlaceHolder ID="phdLogout" runat="server">
                        <div class="section"><p>
                            <asp:LinkButton ID="lnkLogout" runat="server" Text='<%$ Resources: Kartris, ContentText_ToLogOutOfWishList %>'
                                OnClick="Logout_Click" CssClass="link2" />
                        </p></div>
                    </asp:PlaceHolder>
                </asp:Panel>
                <div class="spacer"></div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
</asp:Content>
