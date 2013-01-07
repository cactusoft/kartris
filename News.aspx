<%@ Page Language="VB" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="false"
    CodeFile="News.aspx.vb" Inherits="News" %>

<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <user:BreadCrumbTrail ID="UC_BreadCrumbTrail" runat="server" EnableViewState="False" />
    <div id="news">
        <asp:Repeater ID="rptSiteNews" runat="server" EnableViewState="False">
            <ItemTemplate>
                <h1>
                    <asp:Literal ID="N_Name" runat="server" Text='<%# Server.HtmlEncode(Eval("N_Name")) %>'
                        EnableViewState="False" /></h1>
                <div class="news_strapline">
                    <asp:Literal ID="N_StrapLine" runat="server" Text='<%# Eval("N_StrapLine") %>' EnableViewState="False" />
                </div>
                <div class="news_datecreated">
                    <asp:Literal ID="N_DateCreated" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("N_DateCreated"), "d", Session("LANG")) %>'
                        EnableViewState="False" /></div>
                <div class="news_text">
                    <asp:Literal ID="N_Text" runat="server" Text='<%# Eval("N_Text") %>' EnableViewState="False" />
                </div>
            </ItemTemplate>
        </asp:Repeater>
        <user:SiteNews ID="UC_SiteNews" runat="server" TitleTagType="h2" EnableViewState="False" />
    </div>
</asp:Content>
