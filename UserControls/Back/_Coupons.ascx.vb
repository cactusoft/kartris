'========================================================================
'Kartris - www.kartris.com
'Copyright 2016 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisEnumerations
Imports CkartrisDataManipulation

Partial Class UserControls_Back_KartrisCoupons
    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then LoadCouponsGroups()
    End Sub
    Protected Function GetPromotionName(numPromotionID As Integer) As String
        Return LanguageElementsBLL.GetElementValue(Session("_lang"), CkartrisEnumerations.LANG_ELEM_TABLE_TYPE.Promotions, _
                                                                   CkartrisEnumerations.LANG_ELEM_FIELD_NAME.Name, numPromotionID)
    End Function
    Private Sub LoadCouponsGroups()
        mvwCouponGroups.SetActiveView(viwCouponGroupsData)

        Dim tblCouponGroups As DataTable
        tblCouponGroups = CouponsBLL._GetCouponGroups()

        If tblCouponGroups.Rows.Count = 0 Then mvwCouponGroups.SetActiveView(viwNoItems)

        gvwCouponGroups.DataSource = tblCouponGroups
        gvwCouponGroups.DataBind()

        mvwCoupons.SetActiveView(viwCouponGroups)
        updCouponsList.Update()
    End Sub

    Protected Sub gvwCouponGroups_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwCouponGroups.PageIndexChanging
        gvwCouponGroups.PageIndex = e.NewPageIndex
        LoadCouponsGroups()
    End Sub

    Protected Sub gvwCouponGroups_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwCouponGroups.RowCommand
        Select Case e.CommandName
            Case "selectCoupon"
                gvwCouponGroups.SelectedIndex = CInt(e.CommandArgument) - (gvwCouponGroups.PageSize * gvwCouponGroups.PageIndex)
                LoadCoupons()
        End Select
    End Sub

    Private Sub LoadCoupons()
        Dim tblCoupons As DataTable
        tblCoupons = CouponsBLL._GetCouponsByDate(CDate(gvwCouponGroups.SelectedValue))
        If tblCoupons.Rows.Count = 0 Then LoadCouponsGroups() : Exit Sub
        '' To preview the coupon's value
        tblCoupons.Columns.Add(New DataColumn("CouponValue", Type.GetType("System.String")))
        For Each row As DataRow In tblCoupons.Rows
            If CChar(row("CP_DiscountType")) = "f" Then
                row("CouponValue") = CurrenciesBLL.CurrencyCode(CurrenciesBLL.GetDefaultCurrency()) & " " & CStr(row("CP_DiscountValue"))
                row("CouponValue") = _HandleDecimalValues(row("CouponValue"))
            ElseIf CChar(row("CP_DiscountType")) = "p" Then
                row("CouponValue") = CStr(row("CP_DiscountValue")) & " %"
                row("CouponValue") = _HandleDecimalValues(row("CouponValue"))
            Else
                '' Promotion
                row("CouponValue") = GetGlobalResourceObject("_Coupons", "ContentText_Promotion") & ": " & GetPromotionName(CInt(row("CP_DiscountValue")))
            End If

        Next

        gvwCoupons.DataSource = tblCoupons
        gvwCoupons.DataBind()

        mvwCoupons.SetActiveView(viwCoupons)
        updCouponsList.Update()
    End Sub

    Protected Sub gvwCoupons_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwCoupons.PageIndexChanging
        gvwCoupons.PageIndex = e.NewPageIndex
        LoadCoupons()
    End Sub

    Protected Sub gvwCoupons_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwCoupons.RowCommand
        Select Case e.CommandName
            Case "BackToGroup"
                LoadCouponsGroups()
            Case "DeleteCoupon"
                gvwCoupons.SelectedIndex = CInt(e.CommandArgument) - (gvwCoupons.PageSize * gvwCoupons.PageIndex)
                DeleteCoupon()
            Case "EnableCoupon"
                gvwCoupons.SelectedIndex = CInt(e.CommandArgument) - (gvwCoupons.PageSize * gvwCoupons.PageIndex)
                UpdateCoupon(True)
            Case "DisableCoupon"
                gvwCoupons.SelectedIndex = CInt(e.CommandArgument) - (gvwCoupons.PageSize * gvwCoupons.PageIndex)
                UpdateCoupon(False)
            Case "EditCoupon"
                gvwCoupons.SelectedIndex = CInt(e.CommandArgument) - (gvwCoupons.PageSize * gvwCoupons.PageIndex)
                _UC_EditCoupon.LoadCouponInfo(CShort(gvwCoupons.SelectedValue))
        End Select
    End Sub

    Private Sub DeleteCoupon()
        Dim numCouponID As Short = CShort(gvwCoupons.SelectedValue)
        Dim strCouponCode As String = gvwCoupons.SelectedRow.Cells(0).Text
        Dim strMessage As String = GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified")
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, strMessage)
    End Sub

    Private Sub UpdateCoupon(ByVal blnEnabled As Boolean)
        Dim strMessage As String = ""
        Dim numCouponID As Short = CShort(gvwCoupons.SelectedValue)
        If Not CouponsBLL._UpdateCouponStatus(numCouponID, blnEnabled, strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        Else
            RaiseEvent ShowMasterUpdate()
            gvwCoupons.SelectedIndex = -1
            LoadCoupons()
        End If
    End Sub

    Private Sub PrepareNewCoupon()
        txtStartDate.Text = Format(CkartrisDisplayFunctions.NowOffset(), "yyyy/MM/dd")
        txtEndDate.Text = ""
        ddlDiscountType.Items.Clear()
        ddlDiscountType.Items.Add(New ListItem("%", "p"))
        ddlDiscountType.Items.Add(New ListItem(CurrenciesBLL.CurrencyCode(CurrenciesBLL.GetDefaultCurrency()), "f"))
        ddlDiscountType.Items.Add(New ListItem(GetGlobalResourceObject("_Coupons", "ContentText_Promotion"), "t"))

        '' Support for the promotions in coupons
        Dim tblPromotions As New DataTable
        tblPromotions.Columns.Add(New DataColumn("PROM_ID", Type.GetType("System.Int32")))
        tblPromotions.Columns.Add(New DataColumn("PROM_Name", Type.GetType("System.String")))

        Dim drPromotions As DataRow() = PromotionsBLL._GetData().Select("PROM_Live = 0")
        For i As Integer = 0 To drPromotions.Length - 1
            tblPromotions.Rows.Add(drPromotions(i)("PROM_ID"), GetPromotionName(CStr(drPromotions(i)("PROM_ID"))))
        Next
        ddlPromotions.Items.Clear()
        ddlPromotions.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_DropDownSelect"), "0"))
        ddlPromotions.AppendDataBoundItems = True
        ddlPromotions.DataTextField = "PROM_Name"
        ddlPromotions.DataValueField = "PROM_ID"
        ddlPromotions.DataSource = tblPromotions
        ddlPromotions.DataBind()

        ClearFields()
        mvwCoupons.SetActiveView(viwNewCoupon)
        updCouponsList.Update()
    End Sub

    Private Sub ClearFields()
        txtCouponCode.Text = Nothing
        txtDiscountValue.Text = Nothing
        ddlDiscountType.SelectedIndex = 0
        chkReusable.Checked = False
        txtQty.Text = Nothing
        chkFixedCouponCode.Checked = False
        chkFixedCouponCode_CheckedChanged(Me, New EventArgs)
    End Sub

    Protected Sub ddlDiscountType_SelectedIndexChanged(sender As Object, e As System.EventArgs) Handles ddlDiscountType.SelectedIndexChanged
        If ddlDiscountType.SelectedValue = "t" Then
            valRegexCouponValue.Enabled = False
            valRequiredCouponValue.Enabled = False
            phdNonPromotionType.Visible = False
            phdPromotionType.Visible = True
            valComparePromotion.Enabled = True
        Else
            valRegexCouponValue.Enabled = True
            valRequiredCouponValue.Enabled = True
            phdNonPromotionType.Visible = True
            phdPromotionType.Visible = False
            valComparePromotion.Enabled = False
        End If
    End Sub

    Protected Sub lnkBtnSaveCoupon_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSaveCoupon.Click
        SaveChanges()
    End Sub

    Protected Sub lnkBtnCancelCoupon_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancelCoupon.Click
        mvwCoupons.SetActiveView(viwCouponGroups)
        updCouponsList.Update()
    End Sub

    Private Sub SaveChanges()

        Dim strCouponCode As String = ""
        If chkFixedCouponCode.Checked Then strCouponCode = txtCouponCode.Text
        Dim chrDiscountType As Char = CChar(ddlDiscountType.SelectedValue)
        Dim sngDiscountValue As Single = 0.0F
        If chrDiscountType = "t" Then
            sngDiscountValue = ddlPromotions.SelectedValue
        Else
            sngDiscountValue = HandleDecimalValues(txtDiscountValue.Text)
        End If
        Dim datStartDate As Date = CDate(txtStartDate.Text)
        Dim datEndDate As Date = CDate(txtEndDate.Text)
        Dim blnReusable As Boolean = chkReusable.Checked
        Dim numQty As Integer = CInt(txtQty.Text)
        Dim strMessage As String = ""

        If Not CouponsBLL._AddNewCoupons(strCouponCode, sngDiscountValue, chrDiscountType, _
                                datStartDate, datEndDate, numQty, blnReusable, strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        Else
            'success, show updated message

            RaiseEvent ShowMasterUpdate()
            LoadCouponsGroups()
        End If
    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        Dim strMessage As String = ""
        If Not CouponsBLL._DeleteCoupon(gvwCoupons.SelectedValue, strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        Else
            'success, show updated message


            RaiseEvent ShowMasterUpdate()
            gvwCoupons.SelectedIndex = -1
            LoadCoupons()
        End If
    End Sub

    Protected Sub chkFixedCouponCode_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles chkFixedCouponCode.CheckedChanged
        If chkFixedCouponCode.Checked Then
            txtCouponCode.Visible = True
            valRequiredCouponCode.Enabled = True
            txtQty.Text = 1
            txtQty.Enabled = False
            txtCouponCode.Focus()
        Else
            txtCouponCode.Visible = False
            valRequiredCouponCode.Enabled = False
            txtQty.Text = ""
            txtQty.Enabled = True
            txtQty.Focus()
        End If
    End Sub

    Protected Sub _UC_EditCoupon_CouponSaved() Handles _UC_EditCoupon.CouponSaved
        RaiseEvent ShowMasterUpdate()
        gvwCoupons.SelectedIndex = -1
        LoadCoupons()
    End Sub

    Protected Sub _UC_EditCoupon_CouponErrorOnSave() Handles _UC_EditCoupon.CouponErrorOnSave
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, _UC_EditCoupon.GetErrorMessage())
    End Sub

    Protected Sub btnSearchCoupon_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSearchCoupon.Click
        SearchCoupons()
    End Sub

    Sub SearchCoupons()
        Dim tblCoupons As DataTable
        tblCoupons = CouponsBLL._SearchByCouponCode(txtSearchCouponCode.Text)
        If tblCoupons.Rows.Count = 0 Then mvwCoupons.SetActiveView(viwNoResult) : Exit Sub
        '' To preview the coupon's value
        tblCoupons.Columns.Add(New DataColumn("CouponValue", Type.GetType("System.String")))
        For Each row As DataRow In tblCoupons.Rows
            If CChar(row("CP_DiscountType")) = "f" Then
                row("CouponValue") = CurrenciesBLL.CurrencyCode(CurrenciesBLL.GetDefaultCurrency()) & " " & CStr(row("CP_DiscountValue"))
            Else
                row("CouponValue") = CStr(row("CP_DiscountValue")) & " %"
            End If
        Next

        gvwCoupons.DataSource = tblCoupons
        gvwCoupons.DataBind()

        mvwCoupons.SetActiveView(viwCoupons)
        updCouponsList.Update()
    End Sub

    Protected Sub lnkBtnBack_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnBack.Click
        LoadCouponsGroups()
    End Sub

    Protected Sub btnClear_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnClear.Click
        txtSearchCouponCode.Text = ""
        LoadCouponsGroups()
    End Sub

    Protected Sub lnkAddCouponGroup_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkAddCouponGroup.Click
        PrepareNewCoupon()
    End Sub
End Class