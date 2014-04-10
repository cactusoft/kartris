'========================================================================
'Kartris - www.kartris.com
'Copyright 2014 CACTUSOFT INTERNATIONAL FZ LLC

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class _AffiliateOneRep
    Inherits _PageBaseClass
    Private numMonth, numYear, numAffiliateID As Integer
    Private intPageSize As Integer = 15

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Kartris", "PageTitle_AffiliateStats") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        Try
            numAffiliateID = Request.QueryString("CustomerID")
        Catch ex As Exception
            Response.Redirect("_AffiliateReport.aspx")
        End Try

        Try
            numMonth = Request.QueryString("GivenMonth")
            numYear = Request.QueryString("GivenYear")
        Catch ex As Exception
            numMonth = Month(CkartrisDisplayFunctions.NowOffset)
            numYear = Year(CkartrisDisplayFunctions.NowOffset)
        End Try

        If Not (IsPostBack) Then

            litHitsReportDate.Text = MonthName(numMonth) & " " & numYear

            DisplaySummaryReport()

            DisplayRawDataHitsReport()

            DisplayRawDataSalesReport()

            lnkAffPayReport.NavigateUrl = "_AffiliatePayRep.aspx?CustomerID=" & numAffiliateID

        End If


    End Sub

    Private Sub DisplaySummaryReport()
        Dim tblSummary As New Data.DataTable
        Dim objBasket As New BasketBLL

        tblSummary = objBasket._GetAffiliateSummaryReport(numMonth, numYear, numAffiliateID)
        If tblSummary.Rows.Count > 0 Then
            litAffiliateName.Text = tblSummary.Rows(0).Item("U_EmailAddress")
            litTotalOrder.Text = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, tblSummary.Rows(0).Item("OrderTotal"))
            litCommissionMonth.Text = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, tblSummary.Rows(0).Item("Commission"))
            litTotalHits.Text = tblSummary.Rows(0).Item("Clicks")
        End If

        tblSummary.Dispose()
        objBasket = Nothing

    End Sub

    Private Sub DisplayRawDataHitsReport()
        Dim tblSummary As New Data.DataTable
        Dim objBasket As New BasketBLL
        Dim intTotalRowCount As Integer

        tblSummary = objBasket._GetAffiliateRawDataHitsReport(numMonth, numYear, numAffiliateID, 1, 1000000)
        intTotalRowCount = tblSummary.Rows.Count

        phdNoResults.Visible = IIf(intTotalRowCount > 0, False, True)

        If intTotalRowCount <= _UC_RawDataHitsPager.CurrentPage * _UC_RawDataHitsPager.ItemsPerPage Then
            _UC_RawDataHitsPager.CurrentPage = IIf(_UC_RawDataHitsPager.CurrentPage - 1 < 0, 0, _UC_RawDataHitsPager.CurrentPage - 1)
        End If

        gvwRawDataHits.DataSource = objBasket._GetAffiliateRawDataHitsReport(numMonth, numYear, numAffiliateID, _UC_RawDataHitsPager.CurrentPage + 1, intPageSize)
        gvwRawDataHits.DataBind()

        _UC_RawDataHitsPager.TotalItems = intTotalRowCount
        _UC_RawDataHitsPager.ItemsPerPage = intPageSize
        _UC_RawDataHitsPager.PopulatePagerControl()

        tblSummary.Dispose()
        objBasket = Nothing

    End Sub

    Private Sub DisplayRawDataSalesReport()
        Dim tblSummary As New Data.DataTable
        Dim objBasket As New BasketBLL
        Dim intTotalRowCount As Integer

        tblSummary = objBasket._GetAffiliateRawDataSalesReport(numMonth, numYear, numAffiliateID, 1, 1000000)
        intTotalRowCount = tblSummary.Rows.Count

        phdNoResults2.Visible = IIf(intTotalRowCount > 0, False, True)

        If intTotalRowCount <= _UC_RawDataSalesPager.CurrentPage * _UC_RawDataSalesPager.ItemsPerPage Then
            _UC_RawDataSalesPager.CurrentPage = IIf(_UC_RawDataSalesPager.CurrentPage - 1 < 0, 0, _UC_RawDataSalesPager.CurrentPage - 1)
        End If

        gvwRawDataSales.DataSource = objBasket._GetAffiliateRawDataSalesReport(numMonth, numYear, numAffiliateID, _UC_RawDataSalesPager.CurrentPage + 1, intPageSize)
        gvwRawDataSales.DataBind()

        _UC_RawDataSalesPager.TotalItems = intTotalRowCount
        _UC_RawDataSalesPager.ItemsPerPage = intPageSize
        _UC_RawDataSalesPager.PopulatePagerControl()

        tblSummary.Dispose()
        objBasket = Nothing

    End Sub

    Protected Sub _UC_RawDataHitsPager_PageChanged() Handles _UC_RawDataHitsPager.PageChanged
        DisplayRawDataHitsReport()
    End Sub

    Protected Sub _UC_RawDataSalesPager_PageChanged() Handles _UC_RawDataSalesPager.PageChanged
        DisplayRawDataSalesReport()
    End Sub

    Protected Function GetDateTime(ByVal datDate As DateTime) As String
        Return CkartrisDisplayFunctions.FormatDate(datDate, "t", Session("_LANG"))
    End Function

End Class
