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
Partial Class UserControls_Statistics_ProductStats
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            For Each itm As ListItem In ddlDuration.Items
                itm.Text &= " " & GetGlobalResourceObject("_Statistics", "ContentText_Months")
            Next
            GetProductYearSummary()
        End If
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

    Protected Sub gvwYearSummary_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwYearSummary.RowCommand
        If e.CommandName = "DateSelected" Then
            gvwYearSummary.SelectedIndex = CInt(e.CommandArgument)
            Dim strKey() As String = Split(gvwYearSummary.SelectedValue, "_")
            Dim numMonth As Byte = CByte(strKey(0)) '' To Get the selected month
            Dim numYear As Short = CShort(strKey(1)) '' To Get the selected year

            ShowProductList(numMonth, numYear)
        End If
    End Sub

    Protected Sub gvwProductList_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwProductList.PageIndexChanging
        gvwProductList.PageIndex = e.NewPageIndex
        Dim strKey() As String = Split(gvwYearSummary.SelectedValue, "_")
        Dim numMonth As Byte = CByte(strKey(0)) '' To Get the selected month
        Dim numYear As Short = CShort(strKey(1)) '' To Get the selected year

        ShowProductList(numMonth, numYear)
    End Sub

    Private Sub GetProductYearSummary()

        Dim tblProductSummary As New DataTable
        tblProductSummary = StatisticsBLL._GetProductYearSummary()

        Dim numReturnedMonths As Byte = tblProductSummary.Rows.Count

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
            Dim rowProducts() As DataRow = tblProductSummary.Select("MonthYear=" & (numMonth + (numYear * 100)))

            If rowProducts.Length > 0 Then numHits = rowProducts(0)("NoOfHits")
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
            Dim rowProducts() As DataRow = tblProductSummary.Select("MonthYear=" & (numMonth + (numYear * 100)))

            If rowProducts.Length > 0 Then numHits = rowProducts(0)("NoOfHits")
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
            With _UC_KartChartProductYearSummary
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

    Sub ShowProductList(ByVal numMonth As Byte, ByVal numYear As Short)

        Dim numCounter As Integer = 0

        Dim tblMonthProductList As New DataTable
        tblMonthProductList = StatisticsBLL._GetProductsByDate(numMonth, numYear, Session("_LANG"))

        tblMonthProductList.Columns.Add(New DataColumn("TopHits", Type.GetType("System.Int64")))

        If tblMonthProductList.Rows.Count = 0 Then
            phdNoResults.Visible = True
        Else
            phdNoResults.Visible = False

            Do Until numCounter = tblMonthProductList.Rows.Count
                Try
                    tblMonthProductList.Rows.Item(numCounter)("TopHits") = tblMonthProductList.Rows.Item(0)("NoOfHits")
                Catch ex As Exception

                End Try
                numCounter = numCounter + 1
            Loop
        End If

        litTitle.Text = MonthName(numMonth) & ", " & numYear
        phdOptions.Visible = False

        Dim dvwProductList As DataView = tblMonthProductList.DefaultView
        dvwProductList.Sort = "NoOfHits DESC"

        If ddlDisplayType.SelectedValue = "table" Then
            gvwProductList.DataSource = dvwProductList
            gvwProductList.DataBind()
            mvwYearSummaryTable.SetActiveView(viwProductListTable)
        Else
            With _UC_KartChartProductMonthDetails
                .CopyDesign(_UC_KartChartProductYearSummary)
                .YTitle = GetGlobalResourceObject("_Statistics", "ContentText_StoreHits")
                .XDataField = "ProductName"
                .YDataField = "NoOfHits"
                .ToolTipField = "ProductName"
                .ShowOptions = False
                .DataSource = dvwProductList
                .DrawChart()
            End With
            mvwYearSummaryChart.SetActiveView(viwProductListChart)
        End If

        updMain.Update()

    End Sub

    Protected Sub gvwProductList_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwProductList.RowCommand
        Select Case e.CommandName
            Case "DetailsSelected"
                gvwProductList.SelectedIndex = CInt(e.CommandArgument) - (gvwProductList.PageSize * gvwProductList.PageIndex)

                Dim numProductID As Integer
                numProductID = CInt(CType(gvwProductList.SelectedRow.Cells(1).FindControl("litProductID"), Literal).Text)

                Dim strKey() As String = Split(gvwYearSummary.SelectedValue, "_")
                Dim numMonth As Byte = CByte(strKey(0)) '' To Get the selected month
                Dim numYear As Short = CShort(strKey(1)) '' To Get the selected year

                Dim tblProductStatsDetails As New DataTable
                tblProductStatsDetails = _
                StatisticsBLL._GetProductStatsDetailsByDate(numProductID, numMonth, numYear, Session("_LANG"))
                CType(gvwProductList.SelectedRow.Cells(1).FindControl("grdStatsDetails"), GridView).DataSource = tblProductStatsDetails

                Dim numCounter As Integer = 0
                tblProductStatsDetails.Columns.Add(New DataColumn("TopHits", Type.GetType("System.Int64")))

                If tblProductStatsDetails.Rows.Count = 0 Then
                    '
                Else

                    Do Until numCounter = tblProductStatsDetails.Rows.Count
                        Try
                            tblProductStatsDetails.Rows.Item(numCounter)("TopHits") = tblProductStatsDetails.Rows.Item(0)("NoOfHits")
                        Catch ex As Exception

                        End Try
                        numCounter = numCounter + 1

                    Loop
                End If

                CType(gvwProductList.SelectedRow.Cells(1).FindControl("grdStatsDetails"), GridView).DataBind()
                HideDetails()
                CType(gvwProductList.SelectedRow.Cells(1).FindControl("lnkDetails"), LinkButton).Visible = False
                CType(gvwProductList.SelectedRow.Cells(2).FindControl("pnlProductDetails"), Panel).Visible = True

            Case "HideDetails"
                CType(gvwProductList.SelectedRow.Cells(1).FindControl("lnkDetails"), LinkButton).Visible = True
                CType(gvwProductList.SelectedRow.Cells(2).FindControl("pnlProductDetails"), Panel).Visible = False
        End Select

    End Sub

    Private Sub HideDetails()
        For Each rowProductStats As GridViewRow In gvwProductList.Rows
            If rowProductStats.RowType = DataControlRowType.DataRow Then
                CType(rowProductStats.FindControl("lnkDetails"), LinkButton).Visible = True
                CType(rowProductStats.FindControl("pnlProductDetails"), Panel).Visible = False
            End If
        Next
    End Sub

    Protected Sub _UC_KartChartProductYearSummary_ChartClicked(ByVal value As String) Handles _UC_KartChartProductYearSummary.ChartClicked
        Dim dat As Date = CDate(value)
        ShowProductList(dat.Month, dat.Year)
    End Sub

    Protected Sub _UC_KartChartProductYearSummary_OptionsChanged() Handles _UC_KartChartProductYearSummary.OptionsChanged
        GetProductYearSummary()
    End Sub

    Protected Sub _UC_KartChartProductMonthDetails_OptionsChanged() Handles _UC_KartChartProductMonthDetails.OptionsChanged
        Dim dat As Date = CDate(_UC_KartChartProductYearSummary.PostBackValue)
        ShowProductList(dat.Month, dat.Year)
    End Sub

    Protected Sub ddlDuration_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlDuration.SelectedIndexChanged
        GetProductYearSummary()
    End Sub

    Protected Sub ddlDisplayType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlDisplayType.SelectedIndexChanged
        GetProductYearSummary()
    End Sub

End Class
