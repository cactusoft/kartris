<%@ Control Language="VB" AutoEventWireup="false" EnableViewState="false" CodeFile="MegaMenuCatSub.ascx.vb"
    Inherits="MegaMenuCatSub" %>
<%@ OutputCache Duration="1" VaryByCustom="culture;user" VaryByParam="*" Shared="true" %>
<%
'-----------------------------------
'We cache this control for 300 secs,
'this improves performance but delay
'in any changes going live is kept
'to minimum (=5 mins)

'Note that we vary cache by culture
'and user. This way, when a user
'is logged in, they get a personal
'cached version. This is necessary
'because some categories may be
'available only to some customer
'groups, so we cannot serve same
'menu to each user.
'-----------------------------------
%>
<div id="categorymenu">
    <nav role="navigation">
        <section class="custommegamenu">
            <asp:Repeater ID="rptTopCats" runat="server">
                <ItemTemplate>
                    <div id='mml_<%# Eval("CAT_ID") %>' class="custom-submenu">
                        <h2>
                            <asp:HyperLink CssClass="mm_toplevel" ID="lnkTopLevel" runat="server" Text='<%# Server.HtmlEncode(Eval("CAT_Name")) %>' NavigateUrl='<%# Eval("CAT_ID") %>'></asp:HyperLink></h2>
                        <ul>
                            <asp:Repeater ID="rptMegaMenu" runat="server">
                                <ItemTemplate>
                                    <li>
                                        <asp:HiddenField ID="hidParentID" runat="server" Value='<%# Eval("ParentID") %>' />

                                        <asp:HyperLink ID="lnkSubCat" runat="server" NavigateUrl='<%# Eval("CAT_ID") %>' CssClass="mm_sublevel">
                                            <span class="mm_text">
                                                <asp:Literal runat="server" Text='<%# Server.HtmlEncode(Eval("CAT_Name")) %>'></asp:Literal></span>

                                        </asp:HyperLink>
                                    </li>
                                </ItemTemplate>
                            </asp:Repeater>
                        </ul>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </section>
    </nav>
    <div class="spacer"></div>
</div>

