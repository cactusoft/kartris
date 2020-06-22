<%@ Control Language="VB" AutoEventWireup="false" CodeFile="SearchBox.ascx.vb" Inherits="UserControls_Skin_SearchBox" %>
<div id="section_searchbox">
    <div id="searchboxes" class="row collapse">
        <asp:Panel ID="pnlSearchBox" runat="server">
            <span class="small-10 columns"><input type="search" size="40" class="textbox" id="searchbox" onkeypress="javascript:presssearchkey(event);" /></span>
            <span class="small-2 columns"><i onclick="javascript: submitsearchbox()" class="fas fa-search"></i></span>
            <div class="spacer">
            </div>
            <script type="text/javascript">
                function submitsearchbox() {
                    window.location.href = document.getElementById('baseTag').href + 'Search.aspx?strSearchText=' + document.getElementById('searchbox').value.replace(/ /gi, "+");
                }
                function presssearchkey(e) {
                    if (typeof e == 'undefined' && window.event) { e = window.event; }
                    if (e.keyCode == 13) {
                        window.location.href = document.getElementById('baseTag').href + 'Search.aspx?strSearchText=' + document.getElementById('searchbox').value.replace(/ /gi, "+");
                    }
                }
            </script>
        </asp:Panel>
    </div>
</div>