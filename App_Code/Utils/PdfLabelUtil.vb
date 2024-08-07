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

Imports System.IO
Imports PdfSharp
Imports PdfSharp.Drawing
Imports PdfSharp.Pdf

''' <summary>
''' Utility class for creating labels within a PDF document
''' </summary>
''' <remarks></remarks>
Public Class PdfLabelUtil

    ''' <summary>
    ''' Generate a list of labels on a PDF page. Use a format sheet to define the layout of each label
    ''' </summary>
    ''' <param name="Addresses">List of strings that represent the postal address</param>
    ''' <param name="lf">Format of label sheet that is to be printed</param>
    ''' <param name="QtyEachLabel">How many of each label that should be printed</param>
    ''' <returns>Memorystream object representing a PDF document.</returns>
    ''' <remarks></remarks>
    Public Shared Function GeneratePdfLabels(ByVal Addresses As List(Of String),
                                      ByVal lf As LabelFormat,
                                      Optional ByVal QtyEachLabel As Integer = 1) As MemoryStream
        GeneratePdfLabels = New MemoryStream

        ' The label sheet is basically a table and each cell is a single label

        ' Format related
        Dim CellsPerPage As Integer = lf.RowCount * lf.ColumnCount
        Dim CellsThisPage As Integer = 0
        Dim ContentRectangle As XRect       ' A single cell content rectangle. This is the rectangle that can be used for contents and accounts for margins and padding.
        Dim ContentSize As XSize            ' Size of content area inside a cell.
        Dim ContentLeftPos As Double        ' left edge of current content area.
        Dim ContentTopPos As Double         ' Top edge of current content area

        ' Layout related
        Dim StrokeColor As XColor = XColors.Black
        Dim FillColor As XColor = XColors.Black
        Dim Pen As XPen = New XPen(StrokeColor, 0.1)
        Dim Brush As XBrush = New XSolidBrush(FillColor)
        Dim Gfx As XGraphics
        Dim Path As XGraphicsPath

        Dim LoopTemp As Integer = 0         ' Counts each itteration. Used with QtyEachLabel
        Dim CurrentColumn As Integer = 1
        Dim CurrentRow As Integer = 1
        Dim Doc As New PdfDocument
        Dim page As PdfPage = Nothing
        AddPage(Doc, page, lf)
        Gfx = XGraphics.FromPdfPage(page)

        ' Ensure that at least 1 of each label is printed.
        If QtyEachLabel < 1 Then QtyEachLabel = 1

        ' Define the content area size
        ContentSize = New XSize(XUnit.FromMillimeter(lf.LabelWidth - lf.LabelPaddingLeft - lf.LabelPaddingRight).Point,
                             XUnit.FromMillimeter(lf.LabelHeight - lf.LabelPaddingTop - lf.LabelPaddingBottom).Point)

        If Not IsNothing(Addresses) Then
            If Addresses.Count > 0 Then
                ' We actually have addresses to output.
                For Each Address As String In Addresses
                    ' Once for each address
                    For LoopTemp = 1 To QtyEachLabel
                        ' Once for each copy of this address.
                        If CellsThisPage = CellsPerPage Then
                            ' This pages worth of cells are filled up. Create a new page
                            AddPage(Doc, page, lf)
                            Gfx = XGraphics.FromPdfPage(page)
                            CellsThisPage = 0
                        End If

                        ' Calculate which row and column we are working on.
                        CurrentColumn = (CellsThisPage + 1) Mod lf.ColumnCount
                        CurrentRow = Fix((CellsThisPage + 1) / lf.ColumnCount)

                        If CurrentColumn = 0 Then
                            ' This occurs when you are working on the last column of the row. 
                            ' This affects the count for column and row
                            CurrentColumn = lf.ColumnCount
                        Else
                            ' We are not viewing the last column so this number will be decremented by one.
                            CurrentRow = CurrentRow + 1
                        End If

                        ' Calculate the left position of the current cell.
                        ContentLeftPos = ((CurrentColumn - 1) * lf.HorizontalPitch) + lf.LeftMargin + lf.LabelPaddingLeft

                        ' Calculate the top position of the current cell.
                        ContentTopPos = ((CurrentRow - 1) * lf.VerticalPitch) + lf.TopMargin + lf.LabelPaddingTop

                        ' Define the content rectangle.
                        ContentRectangle = New XRect(New XPoint(XUnit.FromMillimeter(ContentLeftPos).Point, XUnit.FromMillimeter(ContentTopPos).Point),
                                                     ContentSize)

                        Path = New XGraphicsPath

                        ' Add the address string to the page.
                        Path.AddString(Address,
                                        New XFontFamily("Arial"),
                                        XFontStyleEx.Regular,
                                        11,
                                        ContentRectangle,
                                        XStringFormats.TopLeft)

                        Gfx.DrawPath(Pen, Brush, Path)

                        ' Increment the cell count
                        CellsThisPage = CellsThisPage + 1
                    Next LoopTemp
                Next
                ' Output the document
                Doc.Save(GeneratePdfLabels, False)
            End If
        End If
    End Function

    ''' <summary>
    ''' Generate shipping address labels for all orders that are ready for dispatch
    ''' </summary>
    ''' <param name="lf">Format of label sheet that is to be printed</param>
    ''' <param name="QtyEachLabel">How many of each label that should be printed</param>
    ''' <returns>Memorystream object representing a PDF document.</returns>
    ''' <remarks></remarks>
    Public Shared Function GeneratePdfDispatchLabels(ByVal lf As LabelFormat, Optional ByVal QtyEachLabel As Integer = 0) As MemoryStream
        GeneratePdfDispatchLabels = Nothing
        Dim FromDateTime As DateTime = New Date(2000, 1, 1)
        Dim ToDateTime As DateTime = New Date(2049, 1, 1)
        Dim tblOrdersList As DataTable = Nothing                ' All dispatch labels
        Dim tblSingleOrder As DataTable = Nothing               ' A single dispatch label
        Dim ShippingAddress As String = String.Empty
        Dim ShippingAddresses As New List(Of String)

        ' Get the dispatch label information.
        Dim objOrdersBLL As New OrdersBLL
        tblOrdersList = objOrdersBLL._GetByStatus(OrdersBLL.ORDERS_LIST_CALLMODE.DISPATCH, 0, 0, FromDateTime, ToDateTime, "", "", 999)

        If Not IsNothing(tblOrdersList) Then
            If tblOrdersList.Rows.Count > 0 Then
                For Each OrdersRow As DataRow In tblOrdersList.Rows
                    ' Itterate each order.
                    tblSingleOrder = objOrdersBLL.GetOrderByID(OrdersRow("O_ID"))
                    If Not IsNothing(tblSingleOrder) Then
                        For Each DetailRow As DataRow In tblSingleOrder.Rows
                            ' Itterate each detail row in the single order (should only be one).
                            ShippingAddress = StripTelephoneNumber(DetailRow("O_ShippingAddress").ToString)
                            ShippingAddresses.Add(ShippingAddress)
                        Next
                    End If
                Next
            End If
        End If
        If ShippingAddresses.Count > 0 Then
            ' We have shipping addresses. Generate the PDF from these.
            GeneratePdfDispatchLabels = GeneratePdfLabels(ShippingAddresses, lf, QtyEachLabel)
        End If
    End Function

    Private Shared Sub AddPage(ByRef Doc As PdfDocument,
                        ByRef Page As PdfPage,
                        ByVal lf As LabelFormat)
        Page = Doc.AddPage
        Page.Width = XUnit.FromMillimeter(lf.PageWidth)
        Page.Height = XUnit.FromMillimeter(lf.PageHeight)
    End Sub

    ''' <summary>
    ''' Takes a string in that is seperated by newline characters and returns the same text with the telephone number stripped.
    ''' </summary>
    ''' <param name="str">Complete string</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Shared Function StripTelephoneNumber(ByVal str As String) As String
        StripTelephoneNumber = str  ' Initial Value

        Dim lines As String() = str.Split(Chr(10))

        If lines.Count > 0 Then
            str = String.Empty
            For Each line As String In lines
                If Not IsPhoneNumber(line) Then
                    line = Replace(line, Chr(13), String.Empty)
                    If Trim(line).Length > 0 Then
                        ' Line does not contain a telephone number, add it to the string.
                        str = str & line & vbCrLf
                    End If
                End If
            Next
            Return str
        End If
    End Function


    ''' <summary>
    '''  Test to see if a string contains anythign that cannot be used in a phone number. 
    ''' As standard the return is true, but return false if a non-phone number character is found.    
    ''' </summary>
    ''' <param name="input"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Shared Function IsPhoneNumber(ByVal input As String) As Boolean
        If input.Length < 6 Then
            ' Prevents door numbers etc. being detected as a phone number
            Return False
        End If
        For Each c As Char In input
            If Not IsNumeric(c) Then
                If c <> "+" And c <> "-" And c <> " " And c <> "" And Asc(c) <> 10 Then
                    Return False
                End If
            End If
        Next
        Return True
    End Function

End Class
