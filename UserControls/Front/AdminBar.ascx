<%@ Control Language="VB" AutoEventWireup="false" CodeFile="AdminBar.ascx.vb" Inherits="UserControls_Front_AdminBar" %>

<style type="text/css">
#adminbarmenu                           { position: fixed; top: 0; left: 0; display: block; min-height: 40px; }
#adminbarmenu ul                        { position: relative; padding: 0; border: 0; margin: 0; width: 200px; }
#adminbarmenu ul li                     { width: 100%; position: relative; list-style: none; float: left; margin: 0; }
#adminbarmenu ul li a.KartrisMenu-Link  { position: fixed; display: block; top: 4px; left: 4px; background-image: url(Skins/Admin/Images/button_frontback.png); background-position: center center; background-repeat: no-repeat; width: 32px; height: 32px; overflow: hidden; color: transparent; padding: 0; line-height: 0px; font-size: 0px; float: left; margin-right: 2px; cursor: pointer; background-color: #666; border: solid 1px #333; z-index: 1000; }
#adminbarmenu ul li a.KartrisMenu-Link:hover
										{ background-color: #888 }						
#adminbarmenu ul ul                     { font-family: "Segoe UI", Verdana, Arial, Helvetica; font-size: 13px; font-weight: normal; left: 4px; top: 37px; width: 180px; color: #333; position: absolute; visibility: hidden; z-index: 1001; border: solid 2px #333; }
#adminbarmenu ul ul li:hover            { border-top: none }
#adminbarmenu ul li:hover ul,
#adminbarmenu ul li li:hover ul,
#adminbarmenu ul li li li:hover ul      { visibility: visible }
#adminbarmenu ul li:hover ul li:hover a { color: #000; background-color: #eee; font-weight: bold; }
#adminbarmenu ul li:hover ul li a       { display: block; width: auto; text-decoration: none; font-weight: normal; color: #000; padding: 2px 11px 3px 10px; background-color: #fff; }
#adminbarmenu a:hover                   { cursor: pointer }
#adminbarmenu ul li a                   { display: block; text-decoration: none; padding: 1px 6px 2px 6px; }
</style>
<div id="adminbarmenu">
	<div class="KartrisMenu-Horizontal">
		<ul class="KartrisMenu">
			<li class="KartrisMenu-WithChildren">
				<asp:HyperLink ID="lnkMenuMain" runat="server" NavigateUrl="~/Admin/_Default.aspx"
					Text="" ToolTip="<%$ Resources: AdminBar_ViewBackend %>" CssClass="KartrisMenu-Link"></asp:HyperLink>
				<% 'Extra category links %>
				<asp:PlaceHolder ID="phdCategoryLink" runat="server" Visible="false">
					<ul class="KartrisSubMenu">
						<li class="KartrisMenu-Leaf">
							<asp:HyperLink ID="lnkNavigateToCategory" runat="server" ToolTip="<%$ Resources: AdminBar_NavigateToCategory %>"
								Text="<%$ Resources: AdminBar_NavigateToCategory %>"></asp:HyperLink>
						</li>
						<li class="KartrisMenu-Leaf">
							<asp:HyperLink ID="lnkNewProductHere" runat="server" ToolTip="<%$ Resources: AdminBar_AddNewProductHere %>"
								Text="<%$ Resources: AdminBar_AddNewProductHere %>"></asp:HyperLink>
						</li>
					</ul>
				</asp:PlaceHolder>
				<% 'Edit home page link %>
				<asp:PlaceHolder ID="phdEditHomePageLink" runat="server" Visible="False">
					<ul class="KartrisSubMenu">
						<li class="KartrisMenu-Leaf">
							<asp:HyperLink ID="lnkEditHomePage" runat="server" ToolTip="<%$ Resources: AdminBar_EditThisPage %>"
								Text="<%$ Resources: AdminBar_EditThisPage %>"></asp:HyperLink>
						</li>
					</ul>
				</asp:PlaceHolder>
			</li>
		</ul>
	</div>
</div>
<% 'Close the site %>
