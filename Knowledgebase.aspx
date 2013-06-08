<%@ Page Title="" Language="VB" MasterPageFile="~/Skins/Kartris/Template.master"
	AutoEventWireup="false" CodeFile="Knowledgebase.aspx.vb" Inherits="Knowledgebase" %>

<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
	<asp:MultiView ID="mvwMain" runat="server" ActiveViewIndex="0">
		<asp:View ID="viwExist" runat="server">
			<user:BreadCrumbTrail ID="UC_BreadCrumbTrail" runat="server" EnableViewState="False" />
			<div id="knowledgebase">
				<asp:Panel ID="pnlSearch" runat="server">
					<h1>
						<asp:Literal EnableViewState="False" ID="litTitle" runat="server" Text="<%$ Resources: Knowledgebase, PageTitle_Knowledgebase %>" /></h1>
					<div class="inputform row">
						<!-- BASIC SEARCH FORM -->
						<div class="small-12 large-4 columns">
							<input type="text" size="40" class="textbox" id="searchbox_kb_basic" onkeypress="javascript:presssearchkey_kb_basic(event);" />
						</div>
						<div class="small-12 large-8 columns">
							<input id="searchbutton_kb_basic" type="button" value='<asp:Literal ID="litContentText_Search_Basic" runat="server" Text="<%$ Resources: Kartris, ContentText_Search%>" />'
								class="button" onclick="javascript: submitsearchbox_kb_basic()" />
						</div>
					</div>
					
					<script type="text/javascript">
						function submitsearchbox_kb_basic() {
							window.location.href = 'Knowledgebase.aspx?strSearchText=' + document.getElementById('searchbox_kb_basic').value.replace(/ /gi, "+") + '&strType=basic';
						}
						function presssearchkey_kb_basic(e) {
							if (typeof e == 'undefined' && window.event) { e = window.event; }
							if (e.keyCode == 13) {
								document.getElementById('searchbutton_kb_basic').click();
							}
						}
						function SetToBasic() {
							setTimeout("DoFocus()", 100);
						}
						function DoFocus() {
							document.getElementById("searchbox_kb_basic").focus();
						}
					</script>
					<script type="text/javascript">
						SetToBasic();
					</script>
				</asp:Panel>
                <div class="spacer"></div>
				<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
					<ContentTemplate>
						<asp:MultiView ID="mvwKnowledgebase" runat="server" ActiveViewIndex="0">
							<asp:View ID="viwAbout" runat="server">
								<br />
								<p>
									<asp:Literal EnableViewState="False" ID="litContentTextAboutKnowledgebase" runat="server" Text="<%$ Resources:Knowledgebase, ContentText_AboutKnowledgebase %>" />
								</p>
								<p style="display: none;">
									<asp:HyperLink EnableViewState="False" ID="lnkFullListing" runat="server" Text="<%$ Resources:Knowledgebase, ContentText_KnowledgebaseListing %>"
										NavigateUrl="~/Knowledgebase.aspx?list=all" CssClass="link2" /></p>
							</asp:View>
							<asp:View ID="viwKBList" runat="server">
								<h1>
									<asp:Literal EnableViewState="False" ID="litContentTextKnowledgebaseListing" runat="server" Text="<%$ Resources:Knowledgebase, ContentText_KnowledgebaseListing %>" /></h1>
								<div class="fulllist">
									<asp:Repeater ID="rptKBList" runat="server">
										<ItemTemplate>
											<p>
												<asp:HyperLink EnableViewState="False" ID="lnkKB" runat="server" Text='<%# FormatLink(Eval("KB_ID"), Eval("KB_Name")) %>'
													NavigateUrl='<%# SiteMapHelper.CreateURL(SiteMapHelper.Page.Knowledgebase, Eval("KB_ID")) %>' />
											</p>
										</ItemTemplate>
									</asp:Repeater>
								</div>
							</asp:View>
							<asp:View ID="viwSearchResult" runat="server">
								<div class="results">
									<p style="display: none;"><asp:HyperLink EnableViewState="False" ID="lnkListAll" runat="server" Text="<%$ Resources:Knowledgebase, ContentText_KnowledgebaseListing %>"
										NavigateUrl="~/Knowledgebase.aspx?list=all" CssClass="link2 floatright" /></p>
									<h2>
										<asp:Literal ID="litTextSearchResults" EnableViewState="False" runat="server" Text="<%$ Resources: Search, PageTitle_SearchResults %>"></asp:Literal>
									</h2>
									<p id="searchsummary">
										<asp:Literal ID="litSearchResult" runat="server"></asp:Literal></p>
									<asp:Repeater ID="rptSearchList" runat="server">
										<ItemTemplate>
											<div class="item">
												<div class="box">
													<div class="pad">
														<div class="details">
															<h2>
																<asp:HyperLink EnableViewState="False" ID="lnkKB" runat="server" Text='<%# Eval("KB_Name") %>' NavigateUrl='<%# SiteMapHelper.CreateURL(SiteMapHelper.Page.Knowledgebase, Eval("KB_ID")) %>' /></b>
															</h2>
															<asp:Literal EnableViewState="False" ID="litText" runat="server" Text='<%# Eval("KB_Text") %>' />
														</div>
													</div>
												</div>
											</div>
										</ItemTemplate>
									</asp:Repeater>
								</div>
							</asp:View>
							<asp:View ID="viwKBDetails" runat="server">
								<p style="display: none;"><asp:HyperLink EnableViewState="False" ID="lnkListAll2" runat="server" Text="<%$ Resources:Knowledgebase, ContentText_KnowledgebaseListing %>"
									NavigateUrl="~/Knowledgebase.aspx?list=all" CssClass="link2 floatright" /></p>
								<h1>
									<asp:Literal ID="litKBName" runat="server" /></h1>
								<div class="summary">
									[<strong>#<asp:Literal ID="litKBID" runat="server" /></strong>]
									<asp:Literal ID="litUpdateDate" runat="server" Text="<%$ Resources:Kartris,ContentText_LastUpdate %>" />
									<asp:Literal ID="litDateUpdated" runat="server" EnableViewState="False" /></div>
								<div class="article">
									<asp:Literal ID="litKBText" runat="server" EnableViewState="False"></asp:Literal></div>
							</asp:View>
						</asp:MultiView>
					</ContentTemplate>
				</asp:UpdatePanel>
			</div>
		</asp:View>
	</asp:MultiView>

</asp:Content>
