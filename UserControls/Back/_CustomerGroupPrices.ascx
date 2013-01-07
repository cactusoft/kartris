<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_CustomerGroupPrices.ascx.vb"
	Inherits="UserControls_Back_CustomerGroupPrices" %>

<asp:UpdatePanel ID="updCustomerGroupPrices" runat="server" UpdateMode="Conditional">
	<ContentTemplate>
	<div class="subtabsection"><p>
		<asp:Literal ID="litContentTextCustomerGroupPricesExplanation" runat="server" Text="<%$ Resources:_Kartris, ContentText_CustomerGroupPricesExp %>" /></p>
		<asp:Literal ID="litVersionID" runat="server" Visible="false" />
		<asp:HiddenField ID="hidVersionID" runat ="server" Value="" />
		<p>
		<asp:UpdatePanel ID="updUpdateCustomerGroupPrices" runat="server" UpdateMode="Conditional">
			<ContentTemplate>
				<table class="kartristable">
					<tr>
						<th><asp:Literal ID="litFormLabelCustomerGroup" runat="server" Text='<%$ Resources:_Customers, FormLabel_CustomerGroup %>' /></th>
						<th><asp:Literal ID="litFormLabelPrice" runat="server" Text='<%$ Resources:_Version, FormLabel_Price %>' /></th>
					</tr>
					<asp:Repeater ID="rptCustomerGroupPrices" runat="server">
					<ItemTemplate>
						<tr>
							<td>
								<asp:HiddenField ID="hidCustomerGroupID" runat ="server" Value='<%# Eval("CG_ID") %>' />
								<asp:HiddenField ID="hidCustomerGroupPriceID" runat ="server" Value='<%# Eval("CGP_ID") %>' />
								<asp:PlaceHolder ID="phdCGLive" runat ="server" Visible ="false">
									<asp:LinkButton ID="lnkCustomerGroupLive" runat ="server" Text='<%# Eval("CG_Name") %>' OnCommand ='CustomerGroup_Click' CommandArgument='<%# Eval("CG_ID") %>' />
								</asp:PlaceHolder>
								<asp:PlaceHolder ID="phdCGNotLive" runat ="server" Visible ="false">
									<em>
									<asp:LinkButton ID="lnkCustomerGroupNotLive" runat ="server" Text='<%# Eval("CG_Name")%>' OnCommand ='CustomerGroup_Click' CommandArgument='<%# Eval("CG_ID") %>' />
									</em>
								</asp:PlaceHolder>
							</td>
							<td>
								<asp:TextBox ID="txtPrice" runat="server" Text='<%# CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency(), CSng(Eval("CGP_Price"))) %>' CssClass="shorttext" maxLength="8" />
								<asp:RequiredFieldValidator ID="valRequired" runat="server" CssClass="error" ForeColor=""
									ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ControlToValidate="txtPrice" />
								<asp:RegularExpressionValidator ID="valRegexTaxRate" runat="server" Display="Dynamic" SetFocusOnError="true"
									ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>" CssClass="error" ForeColor="" ControlToValidate="txtPrice"
									ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
								<ajaxToolkit:FilteredTextBoxExtender ID="filPrice" runat="server" TargetControlID="txtPrice"
										  FilterType="Numbers, Custom" ValidChars=".," />
							</td>
						</tr>
					</ItemTemplate>
					<AlternatingItemTemplate>
						<tr class="Kartris-GridView-Alternate">
							<td>
								<asp:HiddenField ID="hidCustomerGroupID" runat ="server" Value='<%# Eval("CG_ID") %>'  />
								<asp:HiddenField ID="hidCustomerGroupPriceID" runat ="server" Value='<%# Eval("CGP_ID") %>' />
								<asp:PlaceHolder ID="phdCGLive" runat ="server" Visible ="false">
									<asp:LinkButton ID="lnkCustomerGroupLive" runat ="server" Text='<%# Eval("CG_Name") %>' OnCommand ='CustomerGroup_Click' CommandArgument='<%# Eval("CG_ID") %>' />
								</asp:PlaceHolder>
								<asp:PlaceHolder ID="phdCGNotLive" runat ="server" Visible ="false">
									<em>
									<asp:LinkButton ID="lnkCustomerGroupNotLive" runat ="server" Text='<%# Eval("CG_Name") %>' OnCommand ='CustomerGroup_Click' CommandArgument='<%# Eval("CG_ID") %>' />
								</asp:PlaceHolder>
									</em>
							</td>
							<td>
								<asp:TextBox ID="txtPrice" runat="server" Text='<%# CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency(), CSng(Eval("CGP_Price"))) %>' CssClass="shorttext" maxLength="8" />
								<asp:RequiredFieldValidator ID="valRequired" runat="server" CssClass="error" ForeColor=""
									ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ControlToValidate="txtPrice" />
								<asp:RegularExpressionValidator ID="valRegexTaxRate" runat="server" Display="Dynamic" SetFocusOnError="true"
									ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>" CssClass="error" ForeColor="" ControlToValidate="txtPrice"
									ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
								<ajaxToolkit:FilteredTextBoxExtender ID="filPrice" runat="server" TargetControlID="txtPrice"
										  FilterType="Numbers, Custom" ValidChars=".," />
							</td>
					  </tr>
					</AlternatingItemTemplate>
					</asp:Repeater>
				</table>
				<div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
					<asp:LinkButton ID="btnUpdateCustomerGroupPrices" runat="server" CssClass="button savebutton" Text="<%$ Resources:_Kartris, FormButton_Update %>" />
					<asp:ValidationSummary ID="valSummary" runat="server" CssClass="valsummary" DisplayMode="BulletList"
						ForeColor="" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
				</div>
			</ContentTemplate>
		</asp:UpdatePanel>
   </div>
   </ContentTemplate>
</asp:UpdatePanel>

<_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
