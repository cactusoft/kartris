'    DispatchLabels.ascx is a custom control that allows users to select
'    a label format from a drop down and then send the client to a handler
'    that will output a PDF file of dispatch labels in that format.
'    Copyright (C) 2014  Craig Moore - Deadline Automation Limited.
'
'    GNU GENERAL PUBLIC LICENSE v2
'    This program is free software distributed under the GPL without any
'    warranty.
'    www.gnu.org/licenses/gpl-2.0.html
'
'    If you make any modifications to this program please clearly state who,
'    when and some small details in this header.

Imports Microsoft.VisualBasic
Imports kartrisLabelFormatDataTableAdapters

Public Class LabelFormatBLL

    Private Shared _Adptr As tblKartrisLabelFormatsTableAdapter = Nothing

    Protected Shared ReadOnly Property Adptr() As tblKartrisLabelFormatsTableAdapter
        Get
            If IsNothing(_Adptr) Then
                _Adptr = New tblKartrisLabelFormatsTableAdapter
            End If
            Return _Adptr
        End Get
    End Property

    ''' <summary>
    ''' Return all label formats in the database.
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetLabelFormats() As List(Of LabelFormat)
        GetLabelFormats = Nothing
        Dim dt As DataTable = Adptr.GetData
        Dim lf As LabelFormat
        If Not IsNothing(dt) Then
            GetLabelFormats = New List(Of LabelFormat)
            For Each dr As DataRow In dt.Rows
                lf = New LabelFormat
                With lf
                    .Id = dr("LBF_ID")
                    .Name = dr("LBF_LabelName")
                    .Description = dr("LBF_LabelDescription")
                    .PageWidth = CDbl(dr("LBF_PageWidth"))
                    .PageHeight = CDbl(dr("LBF_PageHeight"))
                    .LabelWidth = CDbl(dr("LBF_LabelWidth"))
                    .LabelHeight = CDbl(dr("LBF_LabelHeight"))
                    .TopMargin = CDbl(dr("LBF_TopMargin"))
                    .LeftMargin = CDbl(dr("LBF_LeftMargin"))
                    .LabelPaddingLeft = CDbl(dr("LBF_LabelPaddingLeft"))
                    .LabelPaddingRight = CDbl(dr("LBF_LabelPaddingRight"))
                    .LabelPaddingTop = CDbl(dr("LBF_LabelPaddingTop"))
                    .LabelPaddingBottom = CDbl(dr("LBF_LabelPaddingBottom"))
                    .VerticalPitch = CDbl(dr("LBF_VerticalPitch"))
                    .HorizontalPitch = CDbl(dr("LBF_HorizontalPitch"))
                    .ColumnCount = CInt(dr("LBF_LabelColumnCount"))
                    .RowCount = CInt(dr("LBF_LabelRowCount"))
                End With
                GetLabelFormats.Add(lf)
            Next
        End If
    End Function

    ''' <summary>
    ''' Return only one label format from the database.
    ''' </summary>
    ''' <param name="FormatId">The Id that uniquely identifies the label format we wish to retrieve</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetLabelFormat(ByVal FormatId As Integer) As LabelFormat
        Dim dt As DataTable = Adptr.GetSingleFormat(FormatId)
        If Not IsNothing(dt) Then
            GetLabelFormat = New LabelFormat
            With GetLabelFormat
                .Id = dt(0)("LBF_ID")
                .Name = dt(0)("LBF_LabelName")
                .Description = dt(0)("LBF_LabelDescription")
                .PageWidth = CDbl(dt(0)("LBF_PageWidth"))
                .PageHeight = CDbl(dt(0)("LBF_PageHeight"))
                .LabelWidth = CDbl(dt(0)("LBF_LabelWidth"))
                .LabelHeight = CDbl(dt(0)("LBF_LabelHeight"))
                .TopMargin = CDbl(dt(0)("LBF_TopMargin"))
                .LeftMargin = CDbl(dt(0)("LBF_LeftMargin"))
                .LabelPaddingLeft = CDbl(dt(0)("LBF_LabelPaddingLeft"))
                .LabelPaddingRight = CDbl(dt(0)("LBF_LabelPaddingRight"))
                .LabelPaddingTop = CDbl(dt(0)("LBF_LabelPaddingTop"))
                .LabelPaddingBottom = CDbl(dt(0)("LBF_LabelPaddingBottom"))
                .VerticalPitch = CDbl(dt(0)("LBF_VerticalPitch"))
                .HorizontalPitch = CDbl(dt(0)("LBF_HorizontalPitch"))
                .ColumnCount = CInt(dt(0)("LBF_LabelColumnCount"))
                .RowCount = CInt(dt(0)("LBF_LabelRowCount"))
            End With
        Else
            Return Nothing
        End If
    End Function
End Class
