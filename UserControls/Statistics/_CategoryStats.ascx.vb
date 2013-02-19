'========================================================================
'Kartris - www.kartris.com
'Copyright 2013 CACTUSOFT INTERNATIONAL FZ LLC

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class UserControls_Statistics_CategoryStats
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            For Each itm As ListItem In ddlDuration.Items
                itm.Text &= " " & GetGlobalResourceObject("_Statistics", "ContentText_Months")
            Next
            GetCategoryYearSummary()
        End If
    End Sub

    Protected Sub gvwYearSummary_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwYearSummary.RowCommand
        If e.CommandName = "DateSelected" Then
            gvwYearSummary.SelectedIndex = CInt(e.CommandArgument)
            Dim strKey() As String = Split(gvwYearSummary.SelectedValue, "_")
            Dim numMonth As Byte = CByte(strKey(0)) '' To Get the selected month
            Dim numYear As Short = CShort(strKey(1)) '' To Get the selected year

            ShowCategoryList(numMonth, numYear)
        End If
    End Sub

    Protected Sub gvwCategoryList_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwCategoryList.PageIndexChanging
        gvwCategoryList.PageIndex = e.NewPageIndex
        Dim strKey() As String = Split(gvwYearSummary.SelectedValue, "_")
        Dim numMonth As Byte = CByte(strKey(0)) '' To Get the selected month
        Dim numYear As Short = CShort(strKey(1)) '' To Get the selected year

        ShowCategoryList(numMonth, numYear)
    End Sub

    Protected Sub lnkBackTable_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBackTable.Click
        mvwYearSummaryTable.SetActiveView(viwYearSummaryListTable)
        phdOptions.Visible = True
        litTitle.Text = GetGlobalResourceObject("_Stats", "ContentText_MonthlyTotals")
        updMain.Update()
    End Sub

    Protected Sub lnkBackChart_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBackChart.Click
        mvwYearSummaryChart.SetActiveView(viwYearSummaryListChart)
        phdOptions.Visible = True
        litTitle.Text = GetGlobalResourceObject("_Stats", "ContentText_MonthlyTotals")
        updMain.Update()
    End Sub

    Private Sub GetCategoryYearSummary()

        Dim tblCategorySummary As New DataTable
        tblCategorySummary = StatisticsBLL._GetCategoryYearSummary()

        Dim numReturnedMonths As Byte = tblCategorySummary.Rows.Count

        Dim tblYearSummary As New DataTable
        tblYearSummary.Columns.Add(New DataColumn("MonthYear", Type.GetType("System.String")))
        tblYearSummary.Columns.Add(New DataColumn("NoOfHits", Type.GetType("System.Int64")))
        tblYearSummary.Columns.Add(New DataColumn("TheMonth", Type.GetType("System.Byte")))
        tblYearSummary.Columns.Add(New DataColumn("TheYear", Type.GetType("System.Int16")))
        tblYearSummary.Columns.Add(New DataColumn("TheDate", Type.GetType("System.String")))
        tblYearSummary.Columns.Add(New DataColumn("TopHits", Type.GetType("System.Int64")))

        Dim numCurrentMonth As Byte = Now.Month
        Dim numCurrentYear As Short = Now.Year
        Dim blnEndOfYear As Boolean = False

        Dim numHits As Integer = 0
        Dim numMonth As Byte = Now.Month
        Dim numYear As Integer = numCurrentYear
        Dim numTopHits As Integer = 0
        Dim numCounter As Integer = 0

        'Find highest number of hits to use for scale
        While Not numCounter = ddlDuration.SelectedValue
            If numMonth = 0 Then
                numMonth = 12
                numYear -= 1
            End If

            'Note: we create a unique number for year month, which is the year x 100, plus the month
            'This makes it easier to compare and select using this
            Dim rowCategories() As DataRow = tblCategorySummary.Select("MonthYear=" & (numMonth + (numYear * 100)))

            If rowCategories.Length > 0 Then numHits = rowCategories(0)("NoOfHits")
            If numHits > numTopHits Then numTopHits = numHits
            numHits = 0
            numMonth -= 1
            numCounter += 1
        End While

        'reset counters
        numHits = 0
        numMonth = Now.Month
        numYear = numCurrentYear
        numCounter = 0

        'loop to fill table, using scale value obtained above
        While Not numCounter = ddlDuration.SelectedValue
            If numMonth = 0 Then
                numMonth = 12
                numYear -= 1
            End If

            'Note: we create a unique number for year month, which is the year x 100, plus the month
            'This makes it easier to compare and select using this
            Dim rowCategories() As DataRow = tblCategorySummary.Select("MonthYear=" & (numMonth + (numYear * 100)))

            If rowCategories.Length > 0 Then numHits = rowCategories(0)("NoOfHits")
            'If numTopHits = 0 Then numTopHits = numHits

            tblYearSummary.Rows.Add( _
            numMonth & "_" & numYear, numHits, numMonth, numYear, MonthName(numMonth) & ", " & numYear, numTopHits)

            numHits = 0
            numMonth -= 1
            numCounter += 1

        End While

        litTitle.Text = GetGlobalResourceObject("_Stats", "ContentText_MonthlyTotals")
        phdOptions.Visible = True

        Dim dvwYearSummary As DataView = tblYearSummary.DefaultView

        If ddlDisplayType.SelectedValue = "table" Then
            dvwYearSummary.Sort = "TheYear DESC, TheMonth DESC"
            gvwYearSummary.DataSource = dvwYearSummary
            gvwYearSummary.DataBind()
            mvwDisplayType.SetActiveView(viwDisplayTable)
        Else
            dvwYearSummary.Sort = "TheYear, TheMonth"
            With _UC_KartChartCategoryYearSummary
                .YTitle = GetGlobalResourceObject("_Statistics", "ContentText_StoreHits")
                .XDataField = "TheDate"
                .YDataField = "NoOfHits"
                .PostBackField = "TheDate"
                .ToolTipField = "TheDate"
                .DataSource = dvwYearSummary
                .DrawChart()
            End With
            mvwDisplayType.SetActiveView(viwDisplayChart)
        End If
        updMain.Update()

    End Sub

    Sub ShowCategoryList(ByVal numMonth As Byte, ByVal numYear As Short)

        Dim numCounter As Integer = 0

        Dim tblMonthCategoryList As New DataTable
        tblMonthCategoryList = StatisticsBLL._GetCategoriesByDate(numMonth, numYear, Session("_LANG"))

        tblMonthCategoryList.Columns.Add(New DataColumn("TopHits", Type.GetType("System.Int64")))

        If tblMonthCategoryList.Rows.Count = 0 Then
            phdNoResults.Visible = True
        Else
            phdNoResults.Visible = False

            Do Until numCounter = tblMonthCategoryList.Rows.Count
                Try
                    tblMonthCategoryList.Rows.Item(numCounter)("TopHits") = tblMonthCategoryList.Rows.Item(0)("NoOfHits")
                Catch ex As Exception

                End Try
                numCounter = numCounter + 1
            Loop
        End If

        litTitle.Text = MonthName(numMonth) & ", " & numYear
        phdOptions.Visible = False

        Dim dvwCategoryList As DataView = tblMonthCategoryList.DefaultView
        dvwCategoryList.Sort = "NoOfHits DESC"

        If ddlDisplayType.SelectedValue = "table" Then
            gvwCategoryList.DataSource = dvwCategoryList
            gvwCategoryList.DataBind()
            mvwYearSummaryTable.SetActiveView(viwCategoryListTable)
        Else
            With _UC_KartChartCategoryMonthDetails
                .CopyDesign(_UC_KartChartCategoryYearSummary)
                .YTitle = GetGlobalResourceObject("_Statistics", "ContentText_StoreHits")
                .XDataField = "CategoryName"
                .YDataField = "NoOfHits"
                .ToolTipField = "CategoryName"
                .ShowOptions = False
                .DataSource = dvwCategoryList
                .DrawChart()
            End With
            mvwYearSummaryChart.SetActiveView(viwCategoryListChart)
        End If

        updMain.Update()

    End Sub

    Protected Sub _UC_KartChartCategoryYearSummary_ChartClicked(ByVal value As String) Handles _UC_KartChartCategoryYearSummary.ChartClicked
        Dim dat As Date = CDate(value)
        ShowCategoryList(dat.Month, dat.Year)
    End Sub

    Protected Sub _UC_KartChartCategoryYearSummary_OptionsChanged() Handles _UC_KartChartCategoryYearSummary.OptionsChanged
        GetCategoryYearSummary()
    End Sub

    Protected Sub _UC_KartChartCategoryMonthDetails_OptionsChanged() Handles _UC_KartChartCategoryMonthDetails.OptionsChanged
        Dim dat As Date = CDate(_UC_KartChartCategoryYearSummary.PostBackValue)
        ShowCategoryList(dat.Month, dat.Year)
    End Sub

    Protected Sub ddlDuration_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlDuration.SelectedIndexChanged
        GetCategoryYearSummary()
    End Sub

    Protected Sub ddlDisplayType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlDisplayType.SelectedIndexChanged
        GetCategoryYearSummary()
    End Sub
End Class
