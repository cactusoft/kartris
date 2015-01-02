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

''' <summary>
''' Represents the layout of a sheet of labels such as Avery L7163.
''' </summary>
''' <remarks>All dimensions in Millimeters</remarks>
Public Class LabelFormat
    ''' <summary>
    ''' Numerical Id of the label format
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property Id As Integer
    ''' <summary>
    ''' Name of the label format (e.g. Avery L7163)
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property Name As String
    ''' <summary>
    ''' Description of label format (e.g. A4 Sheet of 99.1 x 38.1mm address labels)
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property Description As String
    ''' <summary>
    ''' Width of page in millimeters
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property PageWidth As Double
    ''' <summary>
    ''' Height of page in millimeters
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property PageHeight As Double
    ''' <summary>
    ''' Margin between top of page and top of first label in millimeters
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property TopMargin As Double
    ''' <summary>
    ''' Margin between left of page and left of first label in millimeters
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property LeftMargin As Double
    ''' <summary>
    ''' Width of individual label in millimeters
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property LabelWidth As Double
    ''' <summary>
    ''' Height of individual label in millimeters
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property LabelHeight As Double
    ''' <summary>
    ''' Padding on the left of an individual label, creates space between label edge and start of content
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property LabelPaddingLeft As Double
    ''' <summary>
    ''' Padding on the Right of an individual label, creates space between label edge and end of content
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property LabelPaddingRight As Double
    ''' <summary>
    ''' Padding on the top of an individual label, creates space between label edge and start of content
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property LabelPaddingTop As Double
    ''' <summary>
    ''' Padding on the Bottom of an individual label, creates space between label edge and end of content
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property LabelPaddingBottom As Double
    ''' <summary>
    ''' Distance between top of one label and top of label below it in millimeters
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property VerticalPitch As Double
    ''' <summary>
    ''' Distance between left of one label and left of label to the right of it in millimeters
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property HorizontalPitch As Double
    ''' <summary>
    ''' Number of labels going across the page
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property ColumnCount As Integer
    ''' <summary>
    ''' Number of labels going down the page
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property RowCount As Integer

    ''' <summary>
    ''' Instantiate a new label sheet format definition
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub New()

    End Sub

    ''' <summary>
    ''' Instantiate a new label sheet format definition
    ''' </summary>
    ''' <param name="Id">Numerical Id of the label format</param>
    ''' <param name="Name">Name of the label format (e.g. Avery L7163)</param>
    ''' <param name="Description">Description of label format (e.g. A4 Sheet of 99.1 x 38.1mm address labels)</param>
    ''' <param name="PageWidth">Width of page in millimeters</param>
    ''' <param name="PageHeight">Height of page in millimeters</param>
    ''' <param name="TopMargin">Margin between top of page and top of first label in millimeters</param>
    ''' <param name="LeftMargin">Margin between left of page and left of first label in millimeters</param>
    ''' <param name="LabelWidth">Width of individual label in millimeters</param>
    ''' <param name="LabelHeight">Height of individual label in millimeters</param>
    ''' <param name="VerticalPitch">Distance between top of one label and top of label below it in millimeters</param>
    ''' <param name="HorizontalPitch">Distance between left of one label and left of label to the right of it in millimeters</param>
    ''' <param name="ColumnCount">Number of labels going across the page</param>
    ''' <param name="RowCount">Number of labels going down the page</param>
    ''' <param name="LabelPaddingLeft">Padding on the left of an individual label, creates space between label edge and start of content</param>
    ''' <param name="LabelPaddingRight">Padding on the Right of an individual label, creates space between label edge and end of content</param>
    ''' <param name="LabelPaddingTop">Padding on the top of an individual label, creates space between label edge and start of content</param>
    ''' <param name="LabelPaddingBottom">Padding on the Bottom of an individual label, creates space between label edge and end of content</param>
    ''' <remarks></remarks>
    Public Sub New(ByVal Id As Integer,
                    ByVal Name As String,
                    ByVal Description As String,
                    ByVal PageWidth As Double,
                    ByVal PageHeight As Double,
                    ByVal TopMargin As Double,
                    ByVal LeftMargin As Double,
                    ByVal LabelWidth As Double,
                    ByVal LabelHeight As Double,
                    ByVal VerticalPitch As Double,
                    ByVal HorizontalPitch As Double,
                    ByVal ColumnCount As Integer,
                    ByVal RowCount As Integer,
                    Optional ByVal LabelPaddingLeft As Double = 0.0,
                    Optional ByVal LabelPaddingRight As Double = 0.0,
                    Optional ByVal LabelPaddingTop As Double = 0.0,
                    Optional ByVal LabelPaddingBottom As Double = 0.0)
        Me.Id = Id
        Me.Name = Name
        Me.Description = Description
        Me.PageWidth = PageWidth
        Me.PageHeight = PageHeight
        Me.TopMargin = TopMargin
        Me.LeftMargin = LeftMargin
        Me.LabelWidth = LabelWidth
        Me.LabelHeight = LabelHeight
        Me.VerticalPitch = VerticalPitch
        Me.HorizontalPitch = HorizontalPitch
        Me.ColumnCount = ColumnCount
        Me.RowCount = RowCount
        Me.LabelPaddingLeft = LabelPaddingLeft
        Me.LabelPaddingRight = LabelPaddingRight
        Me.LabelPaddingTop = LabelPaddingTop
        Me.LabelPaddingBottom = LabelPaddingBottom
    End Sub

End Class



