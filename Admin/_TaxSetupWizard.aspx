<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_TaxSetupWizard.aspx.vb"
	Inherits="Admin_Destinations" MasterPageFile="~/Skins/Admin/Template.master" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
	<asp:UpdatePanel ID="updDefaultCountry" runat="server" UpdateMode="Conditional">
		<ContentTemplate>
		<h1><asp:Literal ID="litPageTitleTaxSetupWizard" runat="server" Text="<%$ Resources: _RegionalWizard, PageTitle_RegionalSetupWizard %>" /></h1>
		<div class="Kartris-DetailsView">
			<div class="Kartris-DetailsView-Data">
			<ul>
				<li>
				<!-- Tax regime information -->
					<span class="Kartris-DetailsView-Name"><asp:Label runat="server" ID="lblTaxRegime" Text="<%$ Resources: _RegionalWizard, FormLabel_TaxRegime %>" /></span>
					<span class="Kartris-DetailsView-Value"><asp:Literal runat="server" ID="litTaxRegime" Text="" /></span>
				</li>

				<li>
				<!-- Base Currency - Same for all regions-->
					<span class="Kartris-DetailsView-Name"><asp:Literal runat="server" ID="litBaseCurrency" Text="<%$ Resources: _RegionalWizard, ContentText_TaxWizBaseCurrencyQuestion %>" /></span>
					<span class="Kartris-DetailsView-Value"><asp:DropDownList ID="ddlCurrency" runat="server" AutoPostBack="True" CssClass="midtext">
					</asp:DropDownList>
					
					<!-- Currency Language elements - This just holds the language elements currency
					related info in case we need to switch default currency -->
					<asp:UpdatePanel ID="updLanguageContainer" runat="server" UpdateMode="Conditional">
						<ContentTemplate>
							<asp:PlaceHolder ID="phdLanguages" runat="server">
								<_user:LanguageContainer ID="_UC_LangContainer" runat="server" />
							</asp:PlaceHolder>
						</ContentTemplate>
					</asp:UpdatePanel></span>


				</li>
			</ul>

			<!-- Use different set of questions based on selected tax regime in web.config -->
					
			<asp:MultiView ID="mvwRegionalSetupWizard" runat="server" Visible="false" >
				<asp:View ID="viwEU" runat="server">
				<!-- EU -->
				<ul>
					<li>
						<span class="Kartris-DetailsView-Name"><asp:Literal runat="server" ID="litEUVatRegistered" Text="<%$ Resources: _RegionalWizard, ContentText_TaxWizEUVATRegisteredQuestion %>" /></span>
						<span class="Kartris-DetailsView-Value"><asp:DropDownList ID="ddlEUVatRegistered" runat="server" AutoPostBack="True" CssClass="midtext">
							<asp:ListItem Text="<%$ Resources: _Kartris, ContentText_DropDownSelect%>"></asp:ListItem>
							<asp:ListItem Text="<%$ Resources: _Kartris, ContentText_Yes%>" Value="y"></asp:ListItem>
							<asp:ListItem Text="<%$ Resources: _Kartris, ContentText_No %>" Value="n"></asp:ListItem>
						</asp:DropDownList></span>
					</li>


					<asp:PlaceHolder ID="phdEUBaseCountry" runat="server" Visible="false">
					<li>
					<!-- Base country selection -->
						<span class="Kartris-DetailsView-Name"><asp:Literal runat="server" ID="litQBaseCountry" Text="<%$ Resources: _RegionalWizard, ContentText_TaxWizEUBaseCountryQuestion %>" /></span>
						<span class="Kartris-DetailsView-Value"><asp:DropDownList ID="ddlEUCountries" runat="server" AutoPostBack="True">
						</asp:DropDownList></span>
					</li>
					</asp:PlaceHolder>

					<asp:PlaceHolder ID="phdEUVATRate" runat="server" Visible="false">                   
					<li>
					<!-- EU VAT rate -->
						<span class="Kartris-DetailsView-Name"><asp:Literal runat="server" ID="litQVATRate" Text="<%$ Resources: _RegionalWizard, ContentText_TaxWizEUVATRateQuestion %>" /></span>
						<span class="Kartris-DetailsView-Value"><asp:TextBox runat="server" ID="txtQVatRate" AutoPostBack="true" CssClass="shorttext" /> %
							<asp:RegularExpressionValidator ID="valRegexEUTaxRate" runat="server" Display="Dynamic"
								SetFocusOnError="true" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
								CssClass="error" ForeColor="" ControlToValidate="txtQVatRate" ValidationExpression="<%$ AppSettings:PercentageRegex %>" />
							<ajaxToolkit:FilteredTextBoxExtender ID="filEUTaxRate" runat="server" TargetControlID="txtQVatRate"
								FilterType="Numbers, Custom" ValidChars=".," /></span>
					</li>
					</asp:PlaceHolder>
				</ul>
				</asp:View>

				
				<asp:View ID="viwUS" runat="server">
				<!-- US -->
				<ul>
					<li>
					<!-- Base state selection -->
						<span class="Kartris-DetailsView-Name"><asp:Literal runat="server" ID="litUSBaseState" Text="<%$ Resources: _RegionalWizard, ContentText_TaxWizUSBaseStateQuestion %>" /></span>
						<span class="Kartris-DetailsView-Value"><asp:DropDownList ID="ddlUSStates" runat="server" AutoPostBack="True">
						</asp:DropDownList></span>
					</li>

					<asp:PlaceHolder ID="phdUSStateTaxRate" runat="server" Visible="false">
					<li>
					<!-- Tax rate selection -->
						<span class="Kartris-DetailsView-Name"><asp:Literal runat="server" ID="litUSStateTaxRate" Text="<%$ Resources: _RegionalWizard, ContentText_TaxWizUSStateTaxRateQuestion %>" /></span>
						<span class="Kartris-DetailsView-Value"><asp:TextBox runat="server" ID="txtUSStateTaxRate" AutoPostBack="true" CssClass="shorttext" /> %
<%--							<asp:RegularExpressionValidator ID="valRegexUSStateTaxRate" runat="server" Display="Dynamic"
								SetFocusOnError="true" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
								CssClass="error" ForeColor="" ControlToValidate="txtUSStateTaxRate" ValidationExpression="<%$ AppSettings:PercentageRegex %>" />--%>
							<ajaxToolkit:FilteredTextBoxExtender ID="filUSStateTaxRate" runat="server" TargetControlID="txtUSStateTaxRate"
								FilterType="Numbers, Custom" ValidChars=".," /></span>
					</li>
					</asp:PlaceHolder>

				</ul>
				</asp:View>

				
				<asp:View ID="viwCanada" runat="server">
				<!-- CANADA -->
				<ul>
					<li>
					<!-- Base province/territory selection -->
						<span class="Kartris-DetailsView-Name"><asp:Literal runat="server" ID="litCanadaBaseProvince" Text="<%$ Resources: _RegionalWizard, ContentText_TaxWizCanadaBaseProviceQuestion %>" /></span>
						<span class="Kartris-DetailsView-Value"><asp:DropDownList ID="ddlCanadaBaseProvince" runat="server" AutoPostBack="True">
						</asp:DropDownList></span>
					</li>


					<asp:PlaceHolder ID="phdCanadaProvinceTax" runat="server" Visible="false">
					<li>
					<!-- Heading -->
						<p><asp:Literal runat="server" ID="litCanadaConfirmTaxRates" Text="<%$ Resources: _RegionalWizard, ContentText_TaxWizCanadaConfirmTaxRates %>" /></p>
					</li>

					<li>
					<!-- Tax rate selection -->
						<span class="Kartris-DetailsView-Name"><asp:Label runat="server" ID="lblCanadaBaseProvince" /></span>
						<span class="Kartris-DetailsView-Value"></span>
					</li>
					<li>
						<span class="Kartris-DetailsView-Name"><asp:Literal runat="server" ID="litCanadaGST" Text="<%$ Resources: _RegionalWizard, ContentText_TaxWizCanadaGST %>" /></span>
						<span class="Kartris-DetailsView-Value"><asp:TextBox runat="server" ID="txtCanadaGST" CssClass="shorttext" /><asp:Literal runat="server"
							ID="litCanadaGSTPercent" Text="%" />
							<asp:RegularExpressionValidator ID="valRegexCanadaGST" runat="server" Display="Dynamic"
								SetFocusOnError="true" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
								CssClass="error" ForeColor="" ControlToValidate="txtCanadaGST" ValidationExpression="<%$ AppSettings:PercentageRegex %>" />
							<ajaxToolkit:FilteredTextBoxExtender ID="filCanadaGST" runat="server" TargetControlID="txtCanadaGST"
								FilterType="Numbers, Custom" ValidChars=".," /></span>
					</li>
					<li>
						<span class="Kartris-DetailsView-Name"><asp:Literal runat="server" ID="litCanadaPST" Text="<%$ Resources: _RegionalWizard, ContentText_TaxWizCanadaPST %>" /></span>
						<span class="Kartris-DetailsView-Value"><asp:TextBox runat="server" ID="txtCanadaPST" AutoPostBack="true" CssClass="shorttext" /> %
							<asp:RegularExpressionValidator ID="valRegexCanadaPST" runat="server" Display="Dynamic"
								SetFocusOnError="true" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
								CssClass="error" ForeColor="" ControlToValidate="txtCanadaPST" ValidationExpression="<%$ AppSettings:PercentageRegex %>" />
							<ajaxToolkit:FilteredTextBoxExtender ID="filCanadaPST" runat="server" TargetControlID="txtCanadaPST"
								FilterType="Numbers, Custom" ValidChars=".," /></span>
					</li>
					<li>
						<span class="Kartris-DetailsView-Name"><asp:Literal runat="server" ID="litPSTonGST" Text="<%$ Resources: _RegionalWizard, ContentText_TaxWizCanadaPSTChargedOnGST %>" /></span>
						<span class="Kartris-DetailsView-Name"><asp:CheckBox runat="server" ID="chkCanadaPSTChargedOnPST" class="checkbox" /></span>
					</li>
					</asp:PlaceHolder>
				</ul>
				</asp:View>

				<asp:View ID="viwOther" runat="server">
				<!-- SIMPLE -->
				<ul>
					<li>
						<span class="Kartris-DetailsView-Name"><asp:Literal runat="server" ID="litSimpleBaseCountry" Text="<%$ Resources: _RegionalWizard, ContentText_TaxWizSimpleBaseCountryQuestion %>" /></span>
						<span class="Kartris-DetailsView-Value"><asp:DropDownList ID="ddlSimpleBaseCountry" runat="server" AutoPostBack="True">
							</asp:DropDownList></span>
					</li>

					<asp:PlaceHolder ID="phdSimpleTaxRate" runat="server" Visible="false">
					<li>
						<span class="Kartris-DetailsView-Name"><asp:Literal runat="server" ID="litSimpleTaxRate" Text="<%$ Resources: _RegionalWizard, ContentText_TaxWizSimpleTaxRateQuestion %>" /></span>
						<span class="Kartris-DetailsView-Value"><asp:TextBox runat="server" ID="txtSimpleTaxRate" AutoPostBack="true" CssClass="shorttext"/> %
							<asp:RegularExpressionValidator ID="valRegexSimpleTaxRate" runat="server" Display="Dynamic"
								SetFocusOnError="true" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
								CssClass="error" ForeColor="" ControlToValidate="txtSimpleTaxRate" ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
							<ajaxToolkit:FilteredTextBoxExtender ID="filSimpleTaxRate" runat="server" TargetControlID="txtSimpleTaxRate"
								FilterType="Numbers, Custom" ValidChars=".," /></span>
					</li>

					</asp:PlaceHolder>
				</ul>
				</asp:View>
			</asp:MultiView>
			

			<!-- SUMMARY - Same for all regions -->
			<asp:Panel runat="server" ID="pnlSummary" Visible ="false" >

				<p><asp:Label runat="server" ID="lblRecommend" Text="<%$ Resources: _RegionalWizard, ContentText_TazWizConfigRecommend %>" /></p>

				<ul>
					<li>
						<span class="Kartris-DetailsView-Name"><asp:Literal  runat="server" ID="litPricesIncTaxConfig" Text="general.tax.pricesinctax = " /></span>
						<span class="Kartris-DetailsView-Value"><asp:DropDownList ID="ddlPricesIncTaxConfig" runat="server" CssClass="midtext">
							<asp:ListItem Text="<%$ Resources: _Kartris, ContentText_Yes%>" Value="y"></asp:ListItem>
							<asp:ListItem Text="<%$ Resources: _Kartris, ContentText_No %>" Value="n"></asp:ListItem>
						</asp:DropDownList></span>
					</li>            
					<li>
						<span class="Kartris-DetailsView-Name"><asp:Literal  runat="server" ID="litShowTaxConfig" Text="frontend.display.showtax = " /></span>
						<span class="Kartris-DetailsView-Value"><asp:DropDownList ID="ddlShowTaxConfig" runat="server" CssClass="midtext">
							<asp:ListItem Text="<%$ Resources: _Kartris, ContentText_Yes%>" Value="y"></asp:ListItem>
							<asp:ListItem Text="<%$ Resources: _Kartris, ContentText_No %>" Value="n"></asp:ListItem>
							<asp:ListItem Text="Only at checkout" Value="c"></asp:ListItem>
						</asp:DropDownList></span>
					</li>    
				</ul>

				<asp:Button runat="server" ID="btnConfirmSetup" Text="<%$ Resources: _Kartris, ContentText_Confirm %>" CssClass="button" />
				<br /><br />
				<asp:Hyperlink runat="server" ID="lnkCurrencyLink" Text="<%$ Resources: _Kartris, BackMenu_LiveCurrencyRates %>" Visible="false"
					NavigateURL="~/Admin/_LiveCurrencies.aspx"/>
			</asp:Panel>


			</div>
		</div>
		</ContentTemplate>
	</asp:UpdatePanel>
	<asp:UpdateProgress ID="prgRegionalWizard" runat="server" AssociatedUpdatePanelID="updDefaultCountry">
		<ProgressTemplate>
			<div class="loadingimage">
			</div>
			<div class="updateprogress">
			</div>
		</ProgressTemplate>
	</asp:UpdateProgress>
</asp:Content>
