'========================================================================
'Kartris - www.kartris.com
'Copyright 2017 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports System.Web.HttpContext
Partial Class _Affiliate_PayRep
    Inherits _PageBaseClass
    Private UserID, intPageSize, numDueDays As Integer
    Protected Shared blnCheckHeader As Boolean


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Kartris", "PageTitle_AffiliateReportFor") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        intPageSize = 10

        Try
            UserID = CInt(Request.QueryString("CustomerID"))
        Catch ex As Exception
            Current.Response.Redirect("_CustomersList.aspx?mode=af")
        End Try

        numDueDays = KartSettingsManager.GetKartConfig("frontend.users.affiliates.commissionduedays")

        If Not (IsPostBack) Then

            RefreshCommissionSummary()
            RefreshUnpaidCommissionList()
            RefreshPaidCommissionList()

        End If


    End Sub

    Protected Sub gvwUnpaid_DataBound(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvwUnpaid.DataBound

        Try
            sender.HeaderRow.Cells(2).Text = GetGlobalResourceObject("_Kartris", "ContentText_Commission")

            CType(gvwUnpaid.HeaderRow.FindControl("chkHeader"), CheckBox).Checked = blnCheckHeader
        Catch ex As Exception

        End Try

    End Sub

    Protected Sub gvwUnpaid_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwUnpaid.RowDataBound
        Dim drvUnpaid As System.Data.DataRowView

        If e.Row.RowType = DataControlRowType.DataRow Then
            drvUnpaid = e.Row.DataItem

            If CDate(drvUnpaid.Item("O_Date")) <= Today.AddDays(-numDueDays) Then
                CType(e.Row.FindControl("chkPaid"), CheckBox).Checked = True
            Else
                CType(e.Row.FindControl("chkPaid"), CheckBox).Checked = False
            End If

        End If


    End Sub

    Protected Sub gvwPaid_DataBound(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvwPaid.DataBound

        Try
            sender.HeaderRow.Cells(2).Text = GetGlobalResourceObject("_Kartris", "ContentText_Value")
        Catch ex As Exception

        End Try

    End Sub

    Protected Function GetDateTime(ByVal datInput As DateTime) As String
        Return CkartrisDisplayFunctions.FormatDate(datInput, "t", Session("_LANG"))
    End Function

    Protected Function GetCommission(ByVal numCommission As Double, ByVal numPercentage As Double) As String
        Return CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, numCommission) & " (" & numPercentage & "%)"
    End Function

    Protected Function GetTotalPayment(ByVal numPayment As Double) As String
        Return CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, numPayment)
    End Function

    Sub RefreshCommissionSummary()
        Dim objBasket As New kartris.Basket
        Dim tblCommissions As New DataTable

        tblCommissions = AffiliateBLL._GetCustomerAffiliateCommissionSummary(UserID)
        If tblCommissions.Rows.Count > 0 Then
            litEmail.Text = tblCommissions.Rows(0).Item("EmailAddress")
            litPaidCommission.Text = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, tblCommissions.Rows(0).Item("PaidCommission"))
            litUnpaidCommission.Text = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, tblCommissions.Rows(0).Item("UnpaidCommission"))
        End If

        If tblCommissions.Rows(0).Item("EmailAddress") = "" Then
            'Current.Response.Redirect("_CustomersList.aspx?mode=af")
        End If

        tblCommissions.Dispose()
        objBasket = Nothing

    End Sub

    Sub RefreshUnpaidCommissionList()
        Dim objBasket As New kartris.Basket
        Dim intTotalRowCount As Integer
        Dim tblCommissions As New DataTable

        tblCommissions = AffiliateBLL._GetCustomerAffiliateUnpaidCommission(UserID, 1, 1000000)
        intTotalRowCount = tblCommissions.Rows.Count

        If intTotalRowCount = 0 Then
            litNoUnpaidRec.Text = GetGlobalResourceObject("_Kartris", "ContentText_BackSearchNoResults")
            btnSetAsPaid.Visible = False
            gvwUnpaid.Visible = False
            divNoUnpaidRec.Visible = True
        Else
            litNoUnpaidRec.Text = ""
            btnSetAsPaid.Visible = True
            gvwUnpaid.Visible = True
            divNoUnpaidRec.Visible = False
        End If

        If intTotalRowCount <= _UC_UnpaidPager.CurrentPage * _UC_UnpaidPager.ItemsPerPage Then
            _UC_UnpaidPager.CurrentPage = IIf(_UC_UnpaidPager.CurrentPage - 1 < 0, 0, _UC_UnpaidPager.CurrentPage - 1)
        End If

        gvwUnpaid.DataSource = AffiliateBLL._GetCustomerAffiliateUnpaidCommission(UserID, _UC_UnpaidPager.CurrentPage + 1, intPageSize)
        gvwUnpaid.DataBind()
        _UC_UnpaidPager.TotalItems = intTotalRowCount
        _UC_UnpaidPager.ItemsPerPage = intPageSize
        _UC_UnpaidPager.PopulatePagerControl()


        objBasket = Nothing
        tblCommissions.Dispose()

    End Sub

    Sub RefreshPaidCommissionList()
        Dim objBasket As New kartris.Basket
        Dim intTotalRowCount As Integer
        Dim tblCommissions As New DataTable

        tblCommissions = AffiliateBLL._GetCustomerAffiliatePaidCommission(UserID, 1, 1000000)
        intTotalRowCount = tblCommissions.Rows.Count

        If intTotalRowCount = 0 Then
            litNoPaidRec.Text = GetGlobalResourceObject("_Kartris", "ContentText_BackSearchNoResults")
            gvwPaid.Visible = False
            divNoPaidRec.Visible = True
        Else
            litNoPaidRec.Text = ""
            gvwPaid.Visible = True
            divNoPaidRec.Visible = False
        End If

        If intTotalRowCount <= _UC_PaidPager.CurrentPage * _UC_PaidPager.ItemsPerPage Then
            _UC_PaidPager.CurrentPage = IIf(_UC_PaidPager.CurrentPage - 1 < 0, 0, _UC_PaidPager.CurrentPage - 1)
        End If

        gvwPaid.DataSource = AffiliateBLL._GetCustomerAffiliatePaidCommission(UserID, _UC_PaidPager.CurrentPage + 1, intPageSize)
        gvwPaid.DataBind()

        _UC_PaidPager.TotalItems = intTotalRowCount
        _UC_PaidPager.ItemsPerPage = intPageSize
        _UC_PaidPager.PopulatePagerControl()

        objBasket = Nothing
        tblCommissions.Dispose()

    End Sub

    Protected Sub _UC_UnpaidPager_PageChanged() Handles _UC_UnpaidPager.PageChanged
        RefreshUnpaidCommissionList()
    End Sub

    Protected Sub _UC_PaidPager_PageChanged() Handles _UC_PaidPager.PageChanged
        RefreshPaidCommissionList()
    End Sub

    Sub CheckAll_Click(ByVal sender As Object, ByVal e As EventArgs)

        blnCheckHeader = sender.checked

        RefreshUnpaidCommissionList()

        For Each grwCommission As GridViewRow In gvwUnpaid.Rows
            CType(grwCommission.FindControl("chkPaid"), CheckBox).Checked = sender.checked
        Next

    End Sub

    Sub CheckPaid_Click(ByVal sender As Object, ByVal e As EventArgs)

        If sender.Checked = False Then
            CType(gvwUnpaid.HeaderRow.FindControl("chkHeader"), CheckBox).Checked = False
        End If

    End Sub


    Protected Sub btnSetAsPaid_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSetAsPaid.Click
        Dim objBasket As New kartris.Basket
        Dim intAffiliatePaymentID, intOrderID As Integer

        intAffiliatePaymentID = AffiliateBLL._AddAffiliatePayments(UserID)

        For Each grwCommission As GridViewRow In gvwUnpaid.Rows
            If CType(grwCommission.FindControl("chkPaid"), CheckBox).Checked Then
                intOrderID = CInt(CType(grwCommission.FindControl("hidOrderID"), HiddenField).Value)
                AffiliateBLL._UpdateAffiliateCommission(intAffiliatePaymentID, intOrderID)
            End If
        Next

        RefreshCommissionSummary()

        RefreshUnpaidCommissionList()

        RefreshPaidCommissionList()



        objBasket = Nothing

    End Sub

    Protected Sub MarkUnpaid_Click(ByVal sender As Object, ByVal E As CommandEventArgs)
        Dim objBasket As New kartris.Basket
        Dim intAffiliatePaymentID As Integer

        intAffiliatePaymentID = E.CommandArgument

        AffiliateBLL._UpdateAffiliatePayment(intAffiliatePaymentID)

        RefreshCommissionSummary()

        RefreshUnpaidCommissionList()

        RefreshPaidCommissionList()

        CType(gvwUnpaid.HeaderRow.FindControl("chkHeader"), CheckBox).Checked = False

        objBasket = Nothing

    End Sub

End Class
