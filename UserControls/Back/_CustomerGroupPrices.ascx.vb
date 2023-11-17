'========================================================================
'Kartris - www.kartris.com
'Copyright 2023 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisDataManipulation
Imports CkartrisEnumerations

Partial Class UserControls_Back_CustomerGroupPrices
	Inherits System.Web.UI.UserControl

	Public Event ShowMasterUpdate()
	Private _VersionID As Long

	Public Property VersionID() As Long
		Get
			Return _VersionID
		End Get
		Set(ByVal value As Long)
			_VersionID = value
		End Set
	End Property

	Public Sub LoadCustomerGroupPrices(ByVal LanguageID As Integer)
		Dim tblCustomerGroupPrices As New DataTable
		Dim objVersionsBLL As New VersionsBLL
		tblCustomerGroupPrices = objVersionsBLL._GetCustomerGroupPricesForVersion(LanguageID, VersionID)
		rptCustomerGroupPrices.DataSource = tblCustomerGroupPrices
		rptCustomerGroupPrices.DataBind()

		hidVersionID.Value = VersionID

	End Sub

	Public Sub UpdateCustomerGroupPrices()
		Dim intCustomerGroupID, intCustomerGroupPriceID, intVersionID As Integer
		Dim numPrice As Double
		Dim strMsg As String = ""
		Dim objVersionsBLL As New VersionsBLL
		For Each itm As RepeaterItem In rptCustomerGroupPrices.Items
			If itm.ItemType = ListItemType.AlternatingItem OrElse itm.ItemType = ListItemType.Item Then
				intCustomerGroupID = CInt(CType(itm.FindControl("hidCustomerGroupID"), HiddenField).Value)
				intCustomerGroupPriceID = CInt(CType(itm.FindControl("hidCustomerGroupPriceID"), HiddenField).Value)
				intVersionID = CInt(hidVersionID.Value)
				numPrice = CDbl(CType(itm.FindControl("txtPrice"), TextBox).Text)
				If objVersionsBLL._UpdateCustomerGroupPrice(intCustomerGroupID, intVersionID, numPrice, intCustomerGroupPriceID, strMsg) Then
					'' successfull
				Else
					'' error in updating record
				End If
			End If
		Next

		updCustomerGroupPrices.Update()

	End Sub

	Protected Sub btnUpdateCustomerGroupPrices_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdateCustomerGroupPrices.Click
		UpdateCustomerGroupPrices()
		RaiseEvent ShowMasterUpdate()
	End Sub

	Sub CustomerGroup_Click(ByVal sender As Object, ByVal e As CommandEventArgs)
		Dim strCG_ID As String = e.CommandArgument
		Response.Redirect(CkartrisBLL.WebShopURL & "Admin/_CustomerGroupsList.aspx?CG_ID=" & strCG_ID)
	End Sub

	Protected Sub rptCustomerGroupPrices_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptCustomerGroupPrices.ItemDataBound

		If e.Item.ItemType = ListItemType.Item Or e.Item.ItemType = ListItemType.AlternatingItem Then
			If e.Item.DataItem("CG_Live") = "1" Then
				CType(e.Item.FindControl("phdCGLive"), PlaceHolder).Visible = True
				CType(e.Item.FindControl("phdCGNotLive"), PlaceHolder).Visible = False
			Else
				CType(e.Item.FindControl("phdCGLive"), PlaceHolder).Visible = False
				CType(e.Item.FindControl("phdCGNotLive"), PlaceHolder).Visible = True
			End If
		End If

	End Sub


	Protected Sub UserControls_Back_CustomerGroupPrices_Load(sender As Object, e As EventArgs) Handles Me.Load
		If Not Page.IsPostBack Then
			litCurrencySymbol.Text = "(" & CurrenciesBLL.CurrencySymbol(CurrenciesBLL.GetDefaultCurrency()) & ")"
		End If
	End Sub
End Class
