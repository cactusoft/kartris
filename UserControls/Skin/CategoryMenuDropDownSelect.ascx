<%@ Control Language="VB" AutoEventWireup="false" EnableViewState="false" CodeFile="CategoryMenuDropDownSelect.ascx.vb"
    Inherits="UserControls_Skin_CategoryMenuDropDownSelect" %>
<%@ OutputCache Duration="300" VaryByCustom="culture" VaryByParam="none" Shared="true" %>
<%
    '-----------------------------------
    'We cache this control for 300 secs,
    'this improves performance but delay
    'in any changes going live is kept
    'to minimum (=5 mins)
    '-----------------------------------
%>
<!-- CategoryMenu - dropdown/select -->
<div id="categorymenu">
    <div class="box">
        <div class="dropdownselect">

            <script language="javascript" type="text/javascript">
    function <%=ddlCategories.ClientID %>_CategorySelected() {

        var menuList = document.getElementById("<%=ddlCategories.ClientID %>");
        var catURL = menuList.options[menuList.selectedIndex].value;
        if (catURL != "-")
        { window.location = catURL; }
    }
            </script>

            <asp:DropDownList ID="ddlCategories" runat="Server" DataSourceID="srcSiteMap" DataTextField="Title"
                DataValueField="Url" AppendDataBoundItems="true">
                <asp:ListItem Text="-" Value="-"></asp:ListItem>
            </asp:DropDownList>
        </div>
    </div>
</div>
<%  'DataSource %>
<asp:SiteMapDataSource ID="srcSiteMap" SiteMapProvider="CategorySiteMapProvider"
    ShowStartingNode="false" runat="server" />
