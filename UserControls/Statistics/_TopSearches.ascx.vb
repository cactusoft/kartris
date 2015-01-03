'========================================================================
'Kartris - www.kartris.com
'Copyright 2015 CACTUSOFT

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

Partial Class UserControls_Statistics_TopSearches
    Inherits System.Web.UI.UserControl

    Private blnMiniDisplay As Boolean
    Public WriteOnly Property IsMiniDisplay() As Boolean
        Set(ByVal value As Boolean)
            blnMiniDisplay = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            For Each itm As ListItem In ddlDuration.Items
                itm.Text &= " " & GetGlobalResourceObject("_Statistics", "ContentText_Days")
            Next
            For Each itm As ListItem In ddlTerms.Items
                itm.Text &= " " & GetGlobalResourceObject("_Statistics", "ContentText_Terms")
            Next
            If blnMiniDisplay Then
                ddlDisplayType.SelectedValue = "chart"
                ddlDuration.SelectedValue = "-7"
                ddlTerms.SelectedValue = "5"
            End If
            If blnMiniDisplay Then phdOptions.Visible = False
            GetSearchStatistics()
        End If
    End Sub

    Function AdjustTime(ByVal datToAdjust As Date, ByVal blnStartOfDay As Boolean) As Date
        Dim datObject As Date
        If blnStartOfDay Then
            datObject = New Date(datToAdjust.Year, datToAdjust.Month, datToAdjust.Day, 0, 0, 0)
            Return datObject
        End If
        datObject = New Date(datToAdjust.Year, datToAdjust.Month, datToAdjust.Day, 23, 59, 59)
        Return datObject
    End Function

    Sub GetSearchStatistics()

        Dim datFrom As Date = AdjustTime(NowOffset.AddDays(ddlDuration.SelectedValue), True)
        Dim datTo As Date = AdjustTime(NowOffset, False)

        Using tblTopSearches As DataTable = StatisticsBLL._GetTopSearches(datFrom, datTo, ddlTerms.SelectedValue)

            If tblTopSearches.Rows.Count > 0 Then

                Dim dvwTopSearches As DataView = tblTopSearches.DefaultView

                If ddlDisplayType.SelectedValue = "table" Then
                    dvwTopSearches.Sort = "TotalSearches DESC"
                    gvwSearch.DataSource = dvwTopSearches
                    gvwSearch.DataBind()
                    mvwSearchStats.SetActiveView(viwSearchTable)
                Else
                    dvwTopSearches.Sort = "TotalSearches"
                    With _UC_KartChartSearch
                        .YTitle = GetGlobalResourceObject("_Statistics", "ContentText_TotalSearches")
                        .XDataField = "SS_Keyword"
                        .YDataField = "TotalSearches"
                        .ToolTipField = "SS_Keyword"
                        .DataSource = dvwTopSearches
                        If blnMiniDisplay Then
                            .ShowOptions = False
                            .DynamicSize = False
                            .SetHeight = 140
                            .SetWidth = 250
                        End If
                        .DrawChart()
                    End With
                    updSearchChart.Update()
                    mvwSearchStats.SetActiveView(viwSearchChart)
                End If
            Else
                mvwSearchStats.SetActiveView(viwNoData)
            End If

            updSearch.Update()
        End Using
    End Sub

    Protected Sub _UC_KartChartSearch_OptionsChanged() Handles _UC_KartChartSearch.OptionsChanged
        GetSearchStatistics()
    End Sub

    Protected Sub ddlDisplayType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlDisplayType.SelectedIndexChanged
        GetSearchStatistics()
    End Sub

    Protected Sub ddlDuration_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlDuration.SelectedIndexChanged
        GetSearchStatistics()
    End Sub

    Protected Sub ddlTerms_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlTerms.SelectedIndexChanged
        GetSearchStatistics()
    End Sub
End Class
