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
Imports System.Drawing
Imports System.Web.UI.DataVisualization.Charting

Public Enum kartChrtType
    Area = 13
    Bar = 7 'Default
    Column = 10
    Line = 3
    Pie = 17
    Doughnut = 18
    Pyramid = 34
    StepLine = 5
    Spline = 4
End Enum

Public Enum kartChrtStyle
    Cube = 0 'Default
    Cylinder = 1
    Emboss = 2
    LightToDark = 3
    Wedge = 4
End Enum

Partial Class UserControls_Back_KartrisChart
    Inherits System.Web.UI.UserControl

    Private numMinHeight As Integer = 400  '' Min allowed height (used for the dynamic size)
    Private numMinWidth As Integer = 500   '' Min allowed width (used for the dynamic size)
    Private numMaxHeight As Integer = 500   '' Max allowed height (used for the dynamic size)
    Private numMaxWidth As Integer = 800   '' Max allowed width (used for the dynamic size)

    Private numHeight As Integer = 30 '' 30px for each vertical point (used for the dynamic size)

    Public WriteOnly Property SetHeight() As Integer
        Set(ByVal value As Integer)
            numHeight = value
        End Set
    End Property

    Private numWidth As Integer = 25  '' 25px for each horizantal point (used for the dynamic size)
    Public WriteOnly Property SetWidth() As Integer
        Set(ByVal value As Integer)
            numWidth = value
        End Set
    End Property

    Private blnDynamicSize As Boolean = True
    Public WriteOnly Property DynamicSize() As Boolean
        Set(ByVal value As Boolean)
            blnDynamicSize = value
        End Set
    End Property

    Private strTitle As String = String.Empty
    Public WriteOnly Property Title() As String
        Set(ByVal value As String)
            strTitle = value
        End Set
    End Property

    Private valChartType As kartChrtType = kartChrtType.Column
    Public Property ChartType() As kartChrtType
        Get
            Return ddlChartType.SelectedValue
        End Get
        Set(ByVal value As kartChrtType)
            valChartType = value
        End Set
    End Property

    Private valChartStyle As kartChrtStyle = kartChrtStyle.LightToDark
    Public Property ChartStyle() As kartChrtStyle
        Get
            Return ddlChartStyle.SelectedValue
        End Get
        Set(ByVal value As kartChrtStyle)
            valChartStyle = value
        End Set
    End Property

    Private strTooltipField As String = Nothing
    Public WriteOnly Property ToolTipField() As String
        Set(ByVal value As String)
            strTooltipField = value
        End Set
    End Property

    Private strPostBackField As String = Nothing
    Public WriteOnly Property PostBackField() As String
        Set(ByVal value As String)
            strPostBackField = value
        End Set
    End Property

    Private blnValueAsLabel As Boolean = True
    Public Property ValueAsLabel() As Boolean
        Get
            Return chkShowLabel.Checked
        End Get
        Set(ByVal value As Boolean)
            blnValueAsLabel = value
        End Set
    End Property

    Private blnEnable3D As Boolean = False
    Public Property Enable3DView() As Boolean
        Get
            Return chkEnable3D.Checked
        End Get
        Set(ByVal value As Boolean)
            blnEnable3D = value
        End Set
    End Property

    Private strXTitle As String = String.Empty
    Public WriteOnly Property XTitle() As String
        Set(ByVal value As String)
            strXTitle = value
        End Set
    End Property

    Private strYTitle As String = String.Empty
    Public WriteOnly Property YTitle() As String
        Set(ByVal value As String)
            strYTitle = value
        End Set
    End Property

    Private dvwDataSource As DataView = Nothing
    Public WriteOnly Property DataSource() As DataView
        Set(ByVal value As DataView)
            dvwDataSource = value
        End Set
    End Property

    Private strXDataField As String = String.Empty
    Public WriteOnly Property XDataField() As String
        Set(ByVal value As String)
            strXDataField = value
        End Set
    End Property

    Private strYDataField As String = String.Empty
    Public WriteOnly Property YDataField() As String
        Set(ByVal value As String)
            strYDataField = value
        End Set
    End Property

    Private strYDataFormat As String = String.Empty
    Public WriteOnly Property YDataFormat() As String
        Set(ByVal value As String)
            strYDataFormat = value
        End Set
    End Property

    Private strSelectedPostBackValue As String = Nothing
    Public ReadOnly Property PostBackValue() As String
        Get
            Return strSelectedPostBackValue
        End Get
    End Property

    Private strLable As String = String.Empty
    Public WriteOnly Property ChartLable() As String
        Set(ByVal value As String)
            strLable = value
        End Set
    End Property

    '' Show/Hide Options' link
    Public WriteOnly Property ShowOptions() As Boolean
        Set(ByVal value As Boolean)
            btnOptions.Visible = value
            updOptions.Update()
        End Set
    End Property

    Public Event ChartClicked(ByVal value As String)
    Public Event OptionsChanged()

    Public Sub DrawChart()


        '' Add a Title control to the chart
        kartChart.Titles.Clear()
        If Not String.IsNullOrEmpty(strTitle) Then kartChart.Titles.Add(New Title(strTitle))

        '' Clear existing legends
        kartChart.Legends.Clear()

        '' Set the chart type
        kartChart.Series(0).ChartType = valChartType

        '' Set the chart style
        'kartChart.Series(0)("DrawingStyle") = IIf(valChartStyle = kartChrtStyle.Cube, "Default", valChartStyle.ToString)

        '' Show/Hide label on each point
        kartChart.Series(0).IsValueShownAsLabel = blnValueAsLabel

        '' Enable/Disable 3D view
        kartChart.ChartAreas(0).Area3DStyle.Enable3D = blnEnable3D

        '' Set Axies' Titles
        kartChart.ChartAreas(0).AxisX.Title = strXTitle
        kartChart.ChartAreas(0).AxisY.Title = strYTitle

        If valChartType = kartChrtType.Pie AndAlso Not String.IsNullOrEmpty(strYDataFormat) Then
            strLable = "#VALX (#VALY{" & strYDataFormat & "})"
        ElseIf Not String.IsNullOrEmpty(strYDataFormat) Then
            kartChart.ChartAreas(0).AxisY.LabelStyle.Format = strYDataFormat
            kartChart.Series(0).LabelFormat = strYDataFormat
            strLable = "#VALY{" & strYDataFormat & "}"
        End If

        If Not String.IsNullOrEmpty(strLable) Then
            kartChart.Series(0).Label = strLable
        End If

        kartChart.Series(0).SmartLabelStyle.Enabled = True
        kartChart.Series(0).SmartLabelStyle.AllowOutsidePlotArea = LabelOutsidePlotAreaStyle.No
        kartChart.Series(0).SmartLabelStyle.CalloutLineAnchorCapStyle = LineAnchorCapStyle.Diamond
        kartChart.Series(0).SmartLabelStyle.CalloutLineColor = Color.Red
        kartChart.Series(0).SmartLabelStyle.CalloutLineWidth = 1
        kartChart.Series(0).SmartLabelStyle.CalloutStyle = LabelCalloutStyle.Box

        '' To force the chart to show all the points in the X axis
        kartChart.ChartAreas(0).AxisY.IntervalAutoMode = IntervalAutoMode.VariableCount
        'kartChart.ChartAreas(0).AxisY.IntervalOffset = 1
        kartChart.ChartAreas(0).AxisX.IntervalAutoMode = IntervalAutoMode.VariableCount
        'kartChart.ChartAreas(0).AxisX.IntervalOffset = 1

        kartChart.Series(0).Points.DataBind(dvwDataSource, strXDataField, strYDataField, GetChartAttributes())


        '' Show up a legend if the Chart type is pie or doughnut
        If valChartType = kartChrtType.Pie OrElse valChartType = kartChrtType.Doughnut Then
            kartChart.Series(0)("PieDrawingStyle") = "SoftEdge"
            kartChart.ChartAreas(0).Area3DStyle.Enable3D = False
            kartChart.Legends.Add("KartLegends")
            kartChart.Legends("KartLegends").Alignment = StringAlignment.Center
            kartChart.Legends("KartLegends").LegendStyle = LegendStyle.Table
            kartChart.Legends("KartLegends").TableStyle = LegendTableStyle.Wide
            kartChart.Legends("KartLegends").Docking = Docking.Bottom
        End If

        If blnDynamicSize Then
            '' Dynamic Size: Will specify the size of the chart depending on no. of points
            kartChart.Height = numHeight * kartChart.Series(0).Points.Count
            kartChart.Width = numWidth * kartChart.Series(0).Points.Count
            '' Check if the dimentions exceed the max.
            AdjustChartDimensions()
        Else
            '' Fixed Size (set by user)
            kartChart.Height = numHeight
            kartChart.Width = numWidth
        End If

        '' For small home page summary chart, we want to flip labels on
        'x-axis to be horizontal, so better use of space
        If numHeight < 201 Then
            kartChart.ChartAreas(0).AxisX().LabelStyle.Angle = 0
            kartChart.ChartAreas(0).AxisX().LabelStyle.IsStaggered = True
        End If

        '' Show up a 'No Data Message', if there is no rendered points
        If kartChart.Series(0).Points.Count = 0 Then
            kartChart.Annotations("NoDataAnnotation").Visible = True
        Else
            kartChart.Annotations("NoDataAnnotation").Visible = False
        End If

        '' Refresh the chart
        'kartChart.ResetAutoValues()
        updKartChart.Update()

    End Sub

    Public Sub CopyDesign(ByVal chart As ASP.usercontrols_statistics__kartrischart_ascx)
        Me.valChartType = chart.ChartType
        Me.valChartStyle = chart.ChartStyle
        Me.Enable3DView = chart.Enable3DView
        Me.ValueAsLabel = chart.ValueAsLabel
    End Sub

    Protected Sub kartChart_Click(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ImageMapEventArgs) Handles kartChart.Click
        strSelectedPostBackValue = e.PostBackValue
        RaiseEvent ChartClicked(e.PostBackValue)
    End Sub

    Private Function GetChartAttributes() As String
        Dim strAttributes As String = ""
        If Not String.IsNullOrEmpty(strTooltipField) Then strAttributes += "Tooltip=" & strTooltipField & ","
        If Not String.IsNullOrEmpty(strPostBackField) Then strAttributes += "PostBackValue=" & strPostBackField
        If strAttributes.EndsWith(",") Then strAttributes = strAttributes.TrimEnd(",")
        Return strAttributes
    End Function

    Private Sub AdjustChartDimensions()
        If kartChart.Height.Value < numMinHeight Then kartChart.Height = numMinHeight
        If kartChart.Width.Value < numMinWidth Then kartChart.Width = numMinWidth
        If kartChart.Height.Value > numMaxHeight Then kartChart.Height = numMaxHeight
        If kartChart.Width.Value > numMaxWidth Then kartChart.Width = numMaxWidth
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        kartChart.ViewStateContent = SerializationContents.Default
        Page.ClientScript.GetPostBackEventReference(Me, String.Empty)
        If Not Page.IsPostBack Then
            ddlChartType.Items.Clear()
            For Each chtType In [Enum].GetValues(GetType(kartChrtType))
                ddlChartType.Items.Add(New ListItem(CType(chtType, kartChrtType).ToString(), CType(chtType, kartChrtType)))
            Next
            ddlChartStyle.Items.Clear()
            For Each chtStyle In [Enum].GetValues(GetType(kartChrtStyle))
                ddlChartStyle.Items.Add(New ListItem(CType(chtStyle, kartChrtStyle).ToString(), CType(chtStyle, kartChrtStyle)))
            Next
            ddlChartType.SelectedValue = valChartType
            ddlChartStyle.SelectedValue = valChartStyle
            chkEnable3D.Checked = blnEnable3D
            chkShowLabel.Checked = blnValueAsLabel
        End If
    End Sub

    Protected Sub btnOptions_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnOptions.Click
        popExtender.Show()
    End Sub

    Protected Sub lnkOk_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkOk.Click
        valChartType = ddlChartType.SelectedValue
        valChartStyle = ddlChartStyle.SelectedValue
        blnEnable3D = chkEnable3D.Checked
        blnValueAsLabel = chkShowLabel.Checked
        RaiseEvent OptionsChanged()
        updKartChart.Update()
    End Sub

End Class
