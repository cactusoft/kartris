<%@ Control Language="VB" AutoEventWireup="false" EnableViewState="false" CodeFile="MegaMenu.ascx.vb"
    Inherits="MegaMenu" %>
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
        <section class="megamenu">
            <ul>
                <asp:Repeater ID="rptTopCats" runat="server">
                    <ItemTemplate>
                        <li id='mml_<%# Eval("CAT_ID") %>' onmouseover="funcDelay=setTimeout('openMegaMenu(<%# Eval("CAT_ID") %>)', 100)" onmouseout="clearTimeout(funcDelay)" class="megamenu_linkholder">
                            <asp:HyperLink CssClass="mm_toplevel" ID="lnkTopLevel" runat="server" Text='<%# Server.HtmlEncode(Eval("CAT_Name")) %>' NavigateUrl='<%# Eval("CAT_ID") %>'></asp:HyperLink>
                            <asp:PlaceHolder ID="phdMegaMenu" runat="server" Visible="false">
                            <div class="megamenu_tab" id='mm_<%# Eval("CAT_ID") %>' style="display: none;">
                                <asp:Repeater ID="rptMegaMenu" runat="server">
                                    <ItemTemplate>
                                            <asp:HiddenField ID="hidParentID" runat="server" value='<%# Eval("ParentID") %>' />
                                            <asp:HyperLink ID="lnkSubCat" runat="server" NavigateUrl='<%# Eval("CAT_ID") %>' CssClass="mm_sublevel">
                                                <asp:Image ID="imgSubCat" runat="server" CssClass="mm_image" />
                                              
                                                <span class="mm_text"><asp:Literal runat="server" Text='<%# Server.HtmlEncode(Eval("CAT_Name")) %>'></asp:Literal></span>
                                                
                                            </asp:HyperLink>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                                </asp:PlaceHolder>
                        </li>
                    </ItemTemplate>
                </asp:Repeater>
            </ul>
        </section>
    </nav>
</div>

