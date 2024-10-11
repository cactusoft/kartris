'========================================================================
'Kartris - www.kartris.com
'Copyright 2024 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class UserControls_Statistics_AverageHits
    Inherits System.Web.UI.UserControl
    Private blnMiniDisplay As Boolean = True

    Public WriteOnly Property IsMiniDisplay() As Boolean
        Set(ByVal value As Boolean)
            blnMiniDisplay = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack And KartSettingsManager.GetKartConfig("backend.homepage.graphs") <> "OFF" Then
            LoadAverageVisits()
        End If
    End Sub

    Sub LoadAverageVisits()
        Using tblDummy As DataTable = StatisticsBLL._GetAverageVisits()
            Using tblHits As New DataTable
                tblHits.Columns.Add(New DataColumn("Period", Type.GetType("System.String")))
                tblHits.Columns.Add(New DataColumn("Hits", Type.GetType("System.Int32")))
                tblHits.Columns.Add(New DataColumn("SortValue", Type.GetType("System.Int32")))

                tblHits.Rows.Add(GetGlobalResourceObject("_Kartris", "ContentText_Last24Hours"), tblDummy.Rows(0)("Last24Hours"), 1)
                tblHits.Rows.Add(GetGlobalResourceObject("_Kartris", "ContentText_Last7Days"), tblDummy.Rows(0)("LastWeek"), 2)
                tblHits.Rows.Add(GetGlobalResourceObject("_Kartris", "ContentText_LastMonth"), tblDummy.Rows(0)("LastMonth"), 3)
                tblHits.Rows.Add(GetGlobalResourceObject("_Kartris", "ContentText_LastYear"), tblDummy.Rows(0)("LastYear"), 4)

                If tblHits.Rows.Count > 0 Then
                    Dim dvwHits As DataView = tblHits.DefaultView
                    If ddlDisplayType.SelectedValue = "table" Then
                        dvwHits.Sort = "SortValue"

                        gvwAverageHits.DataSource = dvwHits
                        gvwAverageHits.DataBind()
                        mvwHits.SetActiveView(viwAverageHitsTable)
                    Else
                        dvwHits.Sort = "SortValue DESC"
                        With _UC_KartChartAverageHits
                            .YTitle = GetGlobalResourceObject("_Statistics", "ContentText_StoreHits")
                            .XDataField = "Period"
                            .YDataField = "Hits"
                            .ToolTipField = "Period"
                            If blnMiniDisplay Then
                                .ShowOptions = False
                                .DynamicSize = False
                                .SetHeight = 140
                                .SetWidth = 250
                            End If
                            .DataSource = dvwHits
                            .DrawChart()
                        End With
                        updAverageHits.Update()
                        mvwHits.SetActiveView(viwAverageHitsChart)
                    End If
                Else
                    mvwHits.SetActiveView(viwNoData)
                End If
                updAverageVisits.Update()
            End Using
        End Using
    End Sub

    Protected Sub ddlDisplayType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlDisplayType.SelectedIndexChanged
        LoadAverageVisits()
    End Sub
End Class
