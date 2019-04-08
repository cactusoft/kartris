<%@ Control Language="VB" AutoEventWireup="false" EnableViewState="false" CodeFile="CategoryMenuSimple.ascx.vb"
    Inherits="UserControls_Skin_CategoryMenu" %>
<%@ OutputCache Duration="300" VaryByCustom="culture;user" VaryByParam="CategoryID" Shared="true" %>
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
<!-- CategoryMenu - dropdown -->

<div id="categorymenu">
    <h2>Products</h2>
    <nav data-topbar role="navigation">
        <section class="simplemenu">
            <ul>
                <asp:Repeater ID="rptTopCats" runat="server">
                    <ItemTemplate>
                        <li id='sm_<%# Eval("CAT_ID") %>' class="KartrisMenu-Leaf">
                            <asp:HyperLink CssClass="KartrisMenu-Link" ID="lnkTopLevel" runat="server" Text='<%# Server.HtmlEncode(Eval("CAT_Name")) %>' NavigateUrl='<%# Eval("CAT_ID") %>'></asp:HyperLink>
                        </li>
                    </ItemTemplate>
                </asp:Repeater>
            </ul>
        </section>
    </nav>
</div>
