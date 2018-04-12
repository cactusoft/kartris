'========================================================================
'Kartris - www.kartris.com
'Copyright 2018 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class _AffiliateReport
    Inherits _PageBaseClass

    Private numTotalMonthlyHits As Integer = 0
    Private numTotalMonthlySales As Double = 0
    Private numTotalAnnualSales As Double = 0
    Protected Shared Report_Month, Report_Year As Integer

    Private Class AffiliateReport

        Private _AffValue As Double
        Private _AffMonth As Integer
        Private _AffYear As Integer
        Private _GraphValue As Integer

        Public Property AffValue() As Double
            Get
                Return _AffValue
            End Get
            Set(ByVal value As Double)
                _AffValue = value
            End Set
        End Property

        Public Property AffMonth() As Integer
            Get
                Return _AffMonth
            End Get
            Set(ByVal value As Integer)
                _AffMonth = value
            End Set
        End Property

        Public Property AffYear() As Integer
            Get
                Return _AffYear
            End Get
            Set(ByVal value As Integer)
                _AffYear = value
            End Set
        End Property

        Public Property GraphValue() As Integer
            Get
                Return _GraphValue
            End Get
            Set(ByVal value As Integer)
                _GraphValue = value
            End Set
        End Property

    End Class

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Kartris", "PageTitle_AffiliateStats") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Page.IsPostBack Then
            DisplayHitsReport()
            DisplaySalesReport()
        Else
            CType(Me.Master, Skins_Admin_Template).LoadCategoryMenu()
        End If

    End Sub

    Private Sub DisplayHitsReport()
        Dim aryAffiliateHits As New ArrayList
        Dim tblAffiliateHits As New Data.DataTable
        Dim objBasket As New kartris.Basket
        Dim datReport As Date = CkartrisDisplayFunctions.NowOffset
        Dim numMaxValue, numHitsTotal As Integer
        Dim numMonth As Integer = Month(CkartrisDisplayFunctions.NowOffset)
        Dim numYear As Integer = Year(CkartrisDisplayFunctions.NowOffset)

        If Request.QueryString("Report_Month") <> "" Then
            Try
                numMonth = Request.QueryString("Report_Month")
            Catch ex As Exception

            End Try
        End If
        If Request.QueryString("Report_Year") <> "" Then
            Try
                numYear = Request.QueryString("Report_Year")
            Catch ex As Exception

            End Try
        End If

        litHitsReportDate.Text = MonthName(numMonth) & " " & numYear

        Report_Month = numMonth
        Report_Year = numYear

        ''// get monthly hits
        numTotalMonthlyHits = 0
        tblAffiliateHits = AffiliateBLL._GetAffiliateMonthlyHitsReport(numMonth, numYear)
        rptMonthlyHits.DataSource = tblAffiliateHits
        rptMonthlyHits.DataBind()
        litTotalMonthlyHits.Text = numTotalMonthlyHits

        ''// get annual hits
        aryAffiliateHits.Clear()
        For i As Integer = 1 To 12
            Dim objAffRep As New AffiliateReport
            objAffRep.AffMonth = Month(datReport)
            objAffRep.AffYear = Year(datReport)
            objAffRep.AffValue = 0
            objAffRep.GraphValue = 1
            aryAffiliateHits.Add(objAffRep)
            datReport = DateAdd(DateInterval.Month, -1, datReport)
        Next

        numMaxValue = 0
        tblAffiliateHits = AffiliateBLL._GetAffiliateAnnualHitsReport
        For i As Integer = 1 To tblAffiliateHits.Rows.Count
            For Each itmAffiliateMonth As AffiliateReport In aryAffiliateHits
                If tblAffiliateHits.Rows(i - 1).Item("TheMonth") = itmAffiliateMonth.AffMonth AndAlso tblAffiliateHits.Rows(i - 1).Item("TheYear") = itmAffiliateMonth.AffYear Then
                    itmAffiliateMonth.AffValue = tblAffiliateHits.Rows(i - 1).Item("Hits")
                    If itmAffiliateMonth.AffValue > numMaxValue Then numMaxValue = itmAffiliateMonth.AffValue
                End If
            Next
        Next

        numHitsTotal = 0
        For Each itmAffiliateMonth As AffiliateReport In aryAffiliateHits
            If numMaxValue > 0 Then
                itmAffiliateMonth.GraphValue = (itmAffiliateMonth.AffValue / numMaxValue) * 100
            End If
            numHitsTotal = numHitsTotal + itmAffiliateMonth.AffValue
        Next

        rptAnnualHits.DataSource = aryAffiliateHits
        rptAnnualHits.DataBind()

        tblAffiliateHits.Dispose()
        objBasket = Nothing

    End Sub

    Private Sub DisplaySalesReport()
        Dim aryAffiliateSales As New ArrayList
        Dim tblAffiliateSales As New Data.DataTable
        Dim objBasket As New kartris.Basket
        Dim datReport As Date = CkartrisDisplayFunctions.NowOffset
        Dim numMaxValue, numSalesTotal As Integer
        Dim numMonth As Integer = Month(CkartrisDisplayFunctions.NowOffset)
        Dim numYear As Integer = Year(CkartrisDisplayFunctions.NowOffset)

        If Request.QueryString("Report_Month") <> "" Then
            Try
                numMonth = Request.QueryString("Report_Month")
            Catch ex As Exception

            End Try
        End If
        If Request.QueryString("Report_Year") <> "" Then
            Try
                numYear = Request.QueryString("Report_Year")
            Catch ex As Exception

            End Try
        End If

        litSalesReportDate.Text = MonthName(Month(CkartrisDisplayFunctions.NowOffset)) & " " & Year(CkartrisDisplayFunctions.NowOffset)

        Report_Month = numMonth
        Report_Year = numYear

        numTotalAnnualSales = 0

        ''// get monthly sales
        numTotalMonthlySales = 0
        tblAffiliateSales = AffiliateBLL._GetAffiliateMonthlySalesReport(numMonth, numYear)
        rptMonthlySales.DataSource = tblAffiliateSales
        rptMonthlySales.DataBind()
        litTotalMonthlySales.Text = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, numTotalMonthlySales)

        ''// get annual sales
        aryAffiliateSales.Clear()
        For i As Integer = 1 To 12
            Dim objAffRep As New AffiliateReport
            objAffRep.AffMonth = Month(datReport)
            objAffRep.AffYear = Year(datReport)
            objAffRep.AffValue = 0
            objAffRep.GraphValue = 1
            aryAffiliateSales.Add(objAffRep)
            datReport = DateAdd(DateInterval.Month, -1, datReport)
        Next

        numMaxValue = 0
        tblAffiliateSales = AffiliateBLL._GetAffiliateAnnualSalesReport
        For i As Integer = 1 To tblAffiliateSales.Rows.Count
            For Each itmAffiliateMonth As AffiliateReport In aryAffiliateSales
                If tblAffiliateSales.Rows(i - 1).Item("TheMonth") = itmAffiliateMonth.AffMonth AndAlso tblAffiliateSales.Rows(i - 1).Item("TheYear") = itmAffiliateMonth.AffYear Then
                    itmAffiliateMonth.AffValue = tblAffiliateSales.Rows(i - 1).Item("OrderAmount")
                    If itmAffiliateMonth.AffValue > numMaxValue Then numMaxValue = itmAffiliateMonth.AffValue
                End If
            Next
        Next

        numSalesTotal = 0
        For Each itmAffiliateMonth As AffiliateReport In aryAffiliateSales
            If numMaxValue > 0 Then
                itmAffiliateMonth.GraphValue = (itmAffiliateMonth.AffValue / numMaxValue) * 100
            End If
            numSalesTotal = numSalesTotal + itmAffiliateMonth.AffValue
        Next

        rptAnnualSales.DataSource = aryAffiliateSales
        rptAnnualSales.DataBind()

        tblAffiliateSales.Dispose()
        objBasket = Nothing


    End Sub

    Protected Sub rptMonthlyHits_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptMonthlyHits.ItemDataBound

        If (e.Item.ItemType = ListItemType.Item) Or (e.Item.ItemType = ListItemType.AlternatingItem) Then
            numTotalMonthlyHits = numTotalMonthlyHits + CInt(e.Item.DataItem("Hits"))
        End If

    End Sub

    Protected Sub rptAnnualHits_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptAnnualHits.ItemDataBound
        Dim numHits As Double
        Dim numMonth, numYear As Integer
        Dim objAffiliateReport As AffiliateReport

        If (e.Item.ItemType = ListItemType.Item) Or (e.Item.ItemType = ListItemType.AlternatingItem) Then
            objAffiliateReport = CType(e.Item.DataItem, AffiliateReport)
            numHits = objAffiliateReport.AffValue
            numMonth = objAffiliateReport.AffMonth
            numYear = objAffiliateReport.AffYear
            CType(e.Item.FindControl("litHitsValue"), Literal).Text = numHits
            CType(e.Item.FindControl("lnkHitsDate"), LinkButton).Text = MonthName(numMonth) & " " & numYear
            CType(e.Item.FindControl("lnkHitsDate"), LinkButton).CommandArgument = numMonth & "," & numYear
        End If

    End Sub

    Protected Sub rptMonthlySales_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptMonthlySales.ItemDataBound

        If (e.Item.ItemType = ListItemType.Item) Or (e.Item.ItemType = ListItemType.AlternatingItem) Then
            numTotalMonthlySales = numTotalMonthlySales + CDbl(e.Item.DataItem("OrderAmount"))
        End If

    End Sub

    Protected Sub rptAnnualSales_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptAnnualSales.ItemDataBound
        Dim numSales As Double
        Dim numMonth, numYear As Integer
        Dim objAffiliateReport As AffiliateReport

        If (e.Item.ItemType = ListItemType.Item) Or (e.Item.ItemType = ListItemType.AlternatingItem) Then
            objAffiliateReport = CType(e.Item.DataItem, AffiliateReport)
            numSales = objAffiliateReport.AffValue
            numMonth = objAffiliateReport.AffMonth
            numYear = objAffiliateReport.AffYear
            CType(e.Item.FindControl("litSalesValue"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, numSales)
            CType(e.Item.FindControl("lnkSalesDate"), LinkButton).Text = MonthName(numMonth) & " " & numYear
            CType(e.Item.FindControl("lnkSalesDate"), LinkButton).CommandArgument = numMonth & "," & numYear
            numTotalAnnualSales = numTotalAnnualSales + numSales
        End If

    End Sub

    Protected Sub HitsDate_Click(ByVal sender As Object, ByVal e As CommandEventArgs)
        Dim strDate As String = e.CommandArgument
        Dim aryDates As String() = strDate.Split(",")
        Dim numMonth As Integer = CInt(aryDates(0))
        Dim numYear As Integer = CInt(aryDates(1))

        litHitsReportDate.Text = MonthName(numMonth) & " " & numYear

        Report_Month = numMonth
        Report_Year = numYear

        Dim tblAffiliateHits As New Data.DataTable
        Dim objBasket As New kartris.Basket

        tblAffiliateHits = AffiliateBLL._GetAffiliateMonthlyHitsReport(numMonth, numYear)

        numTotalMonthlyHits = 0
        rptMonthlyHits.DataSource = tblAffiliateHits
        rptMonthlyHits.DataBind()
        litTotalMonthlyHits.Text = numTotalMonthlyHits

        tblAffiliateHits.Dispose()
        objBasket = Nothing

    End Sub

    Protected Sub SalesDate_Click(ByVal sender As Object, ByVal e As CommandEventArgs)
        Dim numMonth, numYear As Integer
        Dim strDate As String = e.CommandArgument

        Dim aryDates As String() = strDate.Split(",")
        numMonth = CInt(aryDates(0))
        numYear = CInt(aryDates(1))

        litSalesReportDate.Text = MonthName(numMonth) & " " & numYear

        Dim tblAffiliateSales As New Data.DataTable
        Dim objBasket As New kartris.Basket

        tblAffiliateSales = AffiliateBLL._GetAffiliateMonthlySalesReport(numMonth, numYear)

        numTotalMonthlySales = 0
        rptMonthlySales.DataSource = tblAffiliateSales
        rptMonthlySales.DataBind()
        litTotalMonthlySales.Text = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, numTotalMonthlySales)

        tblAffiliateSales.Dispose()
        objBasket = Nothing

    End Sub


End Class
