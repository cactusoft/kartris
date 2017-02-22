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
Imports CkartrisDisplayFunctions
Imports CkartrisDataManipulation

Partial Class UserControls_Statistics_AverageOrders
    Inherits System.Web.UI.UserControl

    Private blnMiniDisplay As Boolean = True

    Public WriteOnly Property IsMiniDisplay() As Boolean
        Set(ByVal value As Boolean)
            blnMiniDisplay = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack And KartSettingsManager.GetKartConfig("backend.homepage.graphs") <> "OFF" Then
            LoadAverageOrders()
        End If
    End Sub

    Sub LoadAverageOrders()
        Try
            Dim tblDummy As DataTable = StatisticsBLL._GetAverageOrders()
            Dim drwDummy As DataRow = tblDummy.Rows(0)
            Dim strTurnover As String = String.Empty
            Dim numOrders As Integer = 0
            Dim tblOrders As New DataTable

            If ddlDisplayType.SelectedValue = "table" Then
                tblOrders.Columns.Add(New DataColumn("Period", Type.GetType("System.String")))
                tblOrders.Columns.Add(New DataColumn("Orders", Type.GetType("System.Int32")))
                tblOrders.Columns.Add(New DataColumn("Turnover", Type.GetType("System.String")))
                tblOrders.Columns.Add(New DataColumn("TurnoverOrders", Type.GetType("System.String")))
                tblOrders.Columns.Add(New DataColumn("SortValue", Type.GetType("System.Int32")))

                strTurnover = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, FixNullFromDB(drwDummy("Last24HoursTurnover")))
                numOrders = FixNullFromDB(drwDummy("Last24HoursOrders"))
                tblOrders.Rows.Add(GetGlobalResourceObject("_Kartris", "ContentText_Last24Hours"), numOrders, strTurnover, strTurnover & " (" & numOrders & " " & GetGlobalResourceObject("_Statistics", "ContentText_Orders") & ")", 1)

                strTurnover = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, FixNullFromDB(drwDummy("LastWeekTurnover")))
                numOrders = FixNullFromDB(drwDummy("LastWeekOrders"))
                tblOrders.Rows.Add(GetGlobalResourceObject("_Kartris", "ContentText_Last7Days"), numOrders, strTurnover, strTurnover & " (" & numOrders & " " & GetGlobalResourceObject("_Statistics", "ContentText_Orders") & ")", 2)

                strTurnover = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, FixNullFromDB(drwDummy("LastMonthTurnover")))
                numOrders = FixNullFromDB(drwDummy("LastMonthOrders"))
                tblOrders.Rows.Add(GetGlobalResourceObject("_Kartris", "ContentText_LastMonth"), numOrders, strTurnover, strTurnover & " (" & numOrders & " " & GetGlobalResourceObject("_Statistics", "ContentText_Orders") & ")", 3)

                strTurnover = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, FixNullFromDB(drwDummy("LastYearTurnover")))
                numOrders = FixNullFromDB(drwDummy("LastYearOrders"))
                tblOrders.Rows.Add(GetGlobalResourceObject("_Kartris", "ContentText_LastYear"), numOrders, strTurnover, strTurnover & " (" & numOrders & " " & GetGlobalResourceObject("_Statistics", "ContentText_Orders") & ")", 4)
            Else
                tblOrders.Columns.Add(New DataColumn("Period", Type.GetType("System.String")))
                tblOrders.Columns.Add(New DataColumn("Orders", Type.GetType("System.Int32")))
                tblOrders.Columns.Add(New DataColumn("Turnover", Type.GetType("System.Single")))
                tblOrders.Columns.Add(New DataColumn("TurnoverOrders", Type.GetType("System.String")))
                tblOrders.Columns.Add(New DataColumn("SortValue", Type.GetType("System.Int32")))

                strTurnover = CurrenciesBLL.ConvertCurrency(CurrenciesBLL.GetDefaultCurrency, FixNullFromDB(drwDummy("Last24HoursTurnover")))
                numOrders = FixNullFromDB(drwDummy("Last24HoursOrders"))
                tblOrders.Rows.Add(GetGlobalResourceObject("_Kartris", "ContentText_Last24Hours"), numOrders, strTurnover, strTurnover & " (" & numOrders & " " & GetGlobalResourceObject("_Statistics", "ContentText_Orders") & ")", 1)

                strTurnover = CurrenciesBLL.ConvertCurrency(CurrenciesBLL.GetDefaultCurrency, FixNullFromDB(drwDummy("LastWeekTurnover")))
                numOrders = FixNullFromDB(drwDummy("LastWeekOrders"))
                tblOrders.Rows.Add(GetGlobalResourceObject("_Kartris", "ContentText_Last7Days"), numOrders, strTurnover, strTurnover & " (" & numOrders & " " & GetGlobalResourceObject("_Statistics", "ContentText_Orders") & ")", 2)

                strTurnover = CurrenciesBLL.ConvertCurrency(CurrenciesBLL.GetDefaultCurrency, FixNullFromDB(drwDummy("LastMonthTurnover")))
                numOrders = FixNullFromDB(drwDummy("LastMonthOrders"))
                tblOrders.Rows.Add(GetGlobalResourceObject("_Kartris", "ContentText_LastMonth"), numOrders, strTurnover, strTurnover & " (" & numOrders & " " & GetGlobalResourceObject("_Statistics", "ContentText_Orders") & ")", 3)

                strTurnover = CurrenciesBLL.ConvertCurrency(CurrenciesBLL.GetDefaultCurrency, FixNullFromDB(drwDummy("LastYearTurnover")))
                numOrders = FixNullFromDB(drwDummy("LastYearOrders"))
                tblOrders.Rows.Add(GetGlobalResourceObject("_Kartris", "ContentText_LastYear"), numOrders, strTurnover, strTurnover & " (" & numOrders & " " & GetGlobalResourceObject("_Statistics", "ContentText_Orders") & ")", 4)
            End If

            If tblOrders.Rows.Count > 1 Then
                Dim dvwOrders As DataView = tblOrders.DefaultView
                If ddlDisplayType.SelectedValue = "table" Then
                    dvwOrders.Sort = "SortValue"
                    gvwAverageOrders.DataSource = dvwOrders
                    gvwAverageOrders.DataBind()
                    mvwOrders.SetActiveView(viwAverageOrdersTable)
                Else
                    dvwOrders.Sort = "SortValue DESC"
                    Dim drwCurrency() As DataRow = CurrenciesBLL._GetByCurrencyID(CurrenciesBLL.GetDefaultCurrency)
                    Dim numRounds As Integer = FixNullFromDB(drwCurrency(0)("CUR_RoundNumbers"))
                    Dim strDataFormat As String = CurrenciesBLL.CurrencySymbol(CurrenciesBLL.GetDefaultCurrency) & "0"
                    If numRounds > 0 Then
                        strDataFormat += "."
                        For i As Integer = 0 To numRounds - 1
                            strDataFormat += "0"
                        Next
                    End If
                    With _UC_KartChartAverageOrders
                        .YTitle = GetGlobalResourceObject("_Statistics", "ContentText_Turnover") & "(" & CurrenciesBLL.CurrencySymbol(CurrenciesBLL.GetDefaultCurrency) & ")"
                        .XDataField = "Period"
                        .YDataField = "Turnover"
                        .YDataFormat = strDataFormat
                        .ToolTipField = "TurnoverOrders"
                        If blnMiniDisplay Then
                            .ShowOptions = False
                            .DynamicSize = False
                            .SetHeight = 140
                            .SetWidth = 250
                        End If
                        .DataSource = dvwOrders
                        .DrawChart()
                    End With
                    updAverageOrdersChart.Update()
                    mvwOrders.SetActiveView(viwAverageOrdersChart)
                End If
            Else
                mvwOrders.SetActiveView(viwNoData)
            End If
            updAverageOrders.Update()
        Catch ex As Exception
            CkartrisFormatErrors.ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try
    End Sub

    Protected Sub ddlDisplayType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlDisplayType.SelectedIndexChanged
        LoadAverageOrders()
    End Sub
End Class
