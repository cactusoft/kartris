<%@ Page Language="VB" AutoEventWireup="false" MasterPageFile="~/Skins/Kartris/Template.master"
	CodeFile="Search.aspx.vb" Inherits="Search" EnableSessionState="ReadOnly" %>

<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
	<user:BreadCrumbTrail ID="UC_BreadCrumbTrail" runat="server" EnableViewState="False" />
	<div class="search">
		<h1>
			<asp:Literal ID="litHeader" runat="server" Text="<%$ Resources: Search, PageTitle_ProductSearch %>"></asp:Literal>
		</h1>
		<ajaxToolkit:TabContainer ID="tabSearchContainer" runat="server" EnableTheming="false"
			CssClass="tab">
			<ajaxToolkit:TabPanel ID="tabSearch_Basic" runat="server" OnClientClick="SetToBasic">
				<HeaderTemplate>
					<asp:Literal ID="litTextTabSearch_Basic" runat="server" Text="<%$ Resources: Search, FormLabel_Search %>"></asp:Literal>
				</HeaderTemplate>
				<ContentTemplate>
					<div class="inputform row">
						<!-- BASIC SEARCH FORM -->
						<div class="small-12 large-4 columns">
							<input type="text" size="40" class="textbox" id="searchbox_basic" onkeypress="javascript:presssearchkey_basic(event);" />
						</div>
						<div class="small-12 large-8 columns">
							<input id="searchbutton_basic" type="button" value='<asp:Literal ID="litContentText_Search_Basic" runat="server" Text="<%$ Resources: Kartris, ContentText_Search%>" />'
								class="button" onclick="javascript: submitsearchbox_basic()" />
						</div>
						<br />
						<div class="spacer">
						</div>
					</div>
					
					<script type="text/javascript">
						function submitsearchbox_basic() {
							window.location.href = document.getElementById('baseTag').href + 'Search.aspx?strSearchText=' + document.getElementById('searchbox_basic').value.replace(/ /gi, "+") + '&strType=basic';
						}
						function presssearchkey_basic(e) {
							if (typeof e == 'undefined' && window.event) { e = window.event; }
							if (e.keyCode == 13) {
								document.getElementById('searchbutton_basic').click();
							}
						}
					</script>
				</ContentTemplate>
			</ajaxToolkit:TabPanel>
			<ajaxToolkit:TabPanel ID="tabSearch_Advanced" runat="server" OnClientClick="SetToAdvanced">
				<HeaderTemplate>
					<asp:Literal ID="litTextTabSearch_Advanced" runat="server" Text="<%$ Resources: Search, FormLabel_AdvancedSearch %>"></asp:Literal>
				</HeaderTemplate>
				<ContentTemplate>
					<div class="inputform row">
						<!-- ADVANCED SEARCH FORM -->
						<div class="small-12 large-4 columns">
						<input type="text" size="40" class="textbox" id="searchbox_advanced" onkeypress="javascript:presssearchkey_advanced(event);" />
						</div>
						<div class="small-12 large-3 columns"><select id="searchmethod">
							<option value="any"><asp:Literal runat="server" ID="litSearchOption1" Text='<%$ Resources: Search, ContentText_SearchMethodAny %>' /></option>
							<option value="all"><asp:Literal runat="server" ID="litSearchOption2" Text='<%$ Resources: Search, ContentText_SearchMethodAll %>' /></option>
							<option value="exact"><asp:Literal runat="server" ID="litSearchOption3" Text='<%$ Resources: Search, ContentText_SearchMethodExact %>' /></option>
						</select></div>
						<div class="small-12 large-5 columns">
						<input id="searchbutton_advanced" type="button" value='<asp:Literal ID="litContentText_Search_Advanced" runat="server" Text="<%$ Resources: Kartris, ContentText_Search%>" />'
							class="button" onclick="javascript:submitsearchbox_advanced()" />
							</div>
						<div class="spacer">
						</div>
						<div class="advanceline small-12 columns">
							<asp:Label ID="litTextFrom" runat="server" Text="<%$ Resources: Search, FormLabel_PriceRangeFrom %>"></asp:Label>
							<asp:Literal ID="litPriceSymbol" runat="server"></asp:Literal>
							<input type="text" size="4" id="pricefrom" class="small" />
							<asp:Label ID="litTextTo" runat="server" Text="<%$ Resources: Search, FormLabel_PriceRangeTo %>"></asp:Label>
							<asp:Literal ID="litPriceSymbol2" runat="server"></asp:Literal>
							<input type="text" size="4" id="priceto" class="small" />
						</div>
					</div>
					<script type="text/javascript">
						function submitsearchbox_advanced() {
							window.location.href = document.getElementById('baseTag').href + 'Search.aspx?strSearchText=' + document.getElementById('searchbox_advanced').value.replace(/ /gi, "+") + '&numPriceFrom=' + document.getElementById('pricefrom').value + '&numPriceTo=' + document.getElementById('priceto').value + '&strSearchMethod=' + document.getElementById('searchmethod').value + '&strType=advanced';
						}
						function presssearchkey_advanced(e) {
							if (typeof e == 'undefined' && window.event) { e = window.event; }
							if (e.keyCode == 13) {
								document.getElementById('searchbutton_advanced').click();
							}
						}
					</script>
				</ContentTemplate>
			</ajaxToolkit:TabPanel>
		</ajaxToolkit:TabContainer>
		<asp:UpdatePanel ID="updSearchResultArea" runat="server" UpdateMode="Conditional" Visible="False">
			<ContentTemplate>
				<div class="results">
					<asp:HyperLink ID="lnkNewSearch" runat="server" CssClass="link2 floatright" NavigateUrl="~/Search.aspx"
						Text="<%$ Resources: Search, ContentText_NewSearch %>"></asp:HyperLink><h2>
							<asp:Literal ID="litTextSearchResults" runat="server" Text="<%$ Resources: Search, PageTitle_SearchResults %>"></asp:Literal>
						</h2>
					<p id="searchsummary">
						<asp:Literal ID="litSearchResult" runat="server"></asp:Literal></p>
					<user:SearchResult ID="UC_SearchResult" runat="server" />
					<user:ItemPager ID="UC_ItemPager_Footer" runat="server" Visible="False" />
				</div>
			</ContentTemplate>
		</asp:UpdatePanel>
		<script type="text/javascript">
			function SetToBasic() {
				setTimeout("DoFocus()", 100);
			}
			function DoFocus() {
				document.getElementById("searchbox_basic").focus();
			}

			function SetToAdvanced() {
				setTimeout("DoFocus2()", 100);
			}
			function DoFocus2() {
				document.getElementById("searchbox_advanced").focus();
			}
		
		</script>
		<% 'Default to basic search %>
		<asp:Panel ID="pnlClassic" runat="server">
			<script type="text/javascript">
				SetToBasic();
			</script>
		</asp:Panel>
		<% 'Can show this one to default to advanced search %>
		<asp:Panel ID="pnlAdvanced" runat="server" Visible="false">
			<script type="text/javascript">
				SetToAdvanced();
			</script>
		</asp:Panel>
	</div>
</asp:Content>
