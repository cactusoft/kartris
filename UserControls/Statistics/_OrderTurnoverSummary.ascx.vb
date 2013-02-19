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
Imports CkartrisDisplayFunctions
Imports CkartrisDataManipulation

Partial Class UserControls_Back_OrderTurnoverSummary
    Inherits System.Web.UI.UserControl

    Private blnMiniDisplay As Boolean
    Public WriteOnly Property IsMiniDisplay() As Boolean
        Set(ByVal value As Boolean)
            blnMiniDisplay = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            If blnMiniDisplay Then phdOptions.Visible = False
            GetOrdersTurnover()
        End If
    End Sub

    Function AdjustTime(ByVal datToAdjust As Date, ByVal blnStartOfDay As Boolean) As Date
        Dim datObject As Date
        If blnStartOfDay Then
            datObject = New Date(datToAdjust.Year, datToAdjust.Month, datToAdjust.Day, 12, 0, 0)
            Return datObject
        End If
        datObject = New Date(datToAdjust.Year, datToAdjust.Month, datToAdjust.Day, 23, 59, 59)
        Return datObject
    End Function

    Sub GetOrdersTurnover()

        Dim datFrom As Date = AdjustTime(NowOffset.AddDays(ddlDuration.SelectedValue), True)
        Dim datTo As Date = AdjustTime(NowOffset, False)

        Using tblOrderTurnover As DataTable = StatisticsBLL._GetOrdersTurnover(datFrom, datTo)
            If ddlDisplayType.SelectedValue = "table" Then
                tblOrderTurnover.Columns.Add(New DataColumn("Date", Type.GetType("System.String")))
                tblOrderTurnover.Columns.Add(New DataColumn("Turnover", Type.GetType("System.String")))
                tblOrderTurnover.Columns.Add(New DataColumn("TurnoverOrders", Type.GetType("System.String")))
                For Each drwOrderTurnover As DataRow In tblOrderTurnover.Rows
                    drwOrderTurnover("Date") = FixNullFromDB(drwOrderTurnover("Day")) & ", " & MonthName(FixNullFromDB(drwOrderTurnover("Month")), True) ' & "/" & FixNullFromDB(row("Year"))
                    drwOrderTurnover("Date") &= " " & FixNullFromDB(drwOrderTurnover("Year"))
                    drwOrderTurnover("Turnover") = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, FixNullFromDB(drwOrderTurnover("TotalValue")))
                    drwOrderTurnover("TurnoverOrders") = CurrenciesBLL.CurrencySymbol(CurrenciesBLL.GetDefaultCurrency) & drwOrderTurnover("Turnover") & " (" & drwOrderTurnover("Orders") & " " & GetGlobalResourceObject("_Statistics", "ContentText_Orders") & ")"
                Next
            Else
                tblOrderTurnover.Columns.Add(New DataColumn("Date", Type.GetType("System.String")))
                tblOrderTurnover.Columns.Add(New DataColumn("Turnover", Type.GetType("System.Single")))
                tblOrderTurnover.Columns.Add(New DataColumn("TurnoverOrders", Type.GetType("System.String")))
                For Each drwOrderTurnover As DataRow In tblOrderTurnover.Rows
                    drwOrderTurnover("Date") = FixNullFromDB(drwOrderTurnover("Day")) & ", " & MonthName(FixNullFromDB(drwOrderTurnover("Month")), True) ' & "/" & FixNullFromDB(row("Year"))
                    drwOrderTurnover("Date") &= " " & FixNullFromDB(drwOrderTurnover("Year"))
                    drwOrderTurnover("Turnover") = CurrenciesBLL.ConvertCurrency(CurrenciesBLL.GetDefaultCurrency, FixNullFromDB(drwOrderTurnover("TotalValue")))
                    drwOrderTurnover("TurnoverOrders") = CurrenciesBLL.CurrencySymbol(CurrenciesBLL.GetDefaultCurrency) & drwOrderTurnover("Turnover") & " (" & drwOrderTurnover("Orders") & " " & GetGlobalResourceObject("_Statistics", "ContentText_Orders") & ")"
                Next
            End If

            If tblOrderTurnover.Rows.Count > 0 Then
                Dim dvwOrderTurnover As DataView = tblOrderTurnover.DefaultView
                If ddlDisplayType.SelectedValue = "table" Then
                    dvwOrderTurnover.Sort = "Year DESC, Month DESC, Day DESC"
                    gvwOrdersTurnover.DataSource = dvwOrderTurnover
                    gvwOrdersTurnover.DataBind()
                    mvwOrderStats.SetActiveView(viwTurnoverTable)
                Else
                    dvwOrderTurnover.Sort = "Year, Month, Day"
                    Dim drwCurrency() As DataRow = CurrenciesBLL._GetByCurrencyID(CurrenciesBLL.GetDefaultCurrency)
                    Dim numRounds As Integer = FixNullFromDB(drwCurrency(0)("CUR_RoundNumbers"))
                    Dim strDataFormat As String = CurrenciesBLL.CurrencySymbol(CurrenciesBLL.GetDefaultCurrency) & "0"
                    If numRounds > 0 Then
                        strDataFormat += "."
                        For i As Integer = 0 To numRounds - 1
                            strDataFormat += "0"
                        Next
                    End If
                    With _UC_KartChartOrderTurnover
                        .YTitle = GetGlobalResourceObject("_Statistics", "ContentText_TotalTurnover") & " (" & CurrenciesBLL.CurrencySymbol(CurrenciesBLL.GetDefaultCurrency) & ")"
                        .XDataField = "Date"
                        .YDataField = "Turnover"
                        .YDataFormat = strDataFormat
                        .ToolTipField = "TurnoverOrders"
                        .DataSource = dvwOrderTurnover
                        If blnMiniDisplay Then
                            .ShowOptions = False
                            .DynamicSize = False
                            .SetHeight = 140
                            .SetWidth = 250
                        End If
                        .DrawChart()
                    End With
                    updTurnoverChart.Update()
                    mvwOrderStats.SetActiveView(viwTurnoverChart)
                End If
            Else
                mvwOrderStats.SetActiveView(viwNoData)
            End If
            updTurnover.Update()
        End Using
    End Sub

    Protected Sub _UC_KartChartOrderTurnover_OptionsChanged() Handles _UC_KartChartOrderTurnover.OptionsChanged
        GetOrdersTurnover()
    End Sub

    Protected Sub ddlDisplayType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlDisplayType.SelectedIndexChanged
        GetOrdersTurnover()
    End Sub

    Protected Sub ddlDuration_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlDuration.SelectedIndexChanged
        GetOrdersTurnover()
    End Sub
End Class
