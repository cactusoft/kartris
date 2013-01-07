Imports System
Imports System.Data
Imports System.Collections
Imports System.Configuration
Imports System.Web
Imports System.Web.Security
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI.WebControls.WebParts
Imports System.Web.UI.HtmlControls

Namespace Kartris
    Public Class GridViewAdapter
        Inherits System.Web.UI.WebControls.Adapters.WebControlAdapter

        Protected This As WebControlAdapterExtender = Nothing
        Private _extender As WebControlAdapterExtender = Nothing
        Private ReadOnly Property Extender() As WebControlAdapterExtender
            Get
                If ((IsNothing(_extender) AndAlso (Not IsNothing(Control))) OrElse _
                    ((Not IsNothing(_extender)) AndAlso (Not Control.Equals(_extender.AdaptedControl)))) Then
                    _extender = New WebControlAdapterExtender(Control)
                End If

                System.Diagnostics.Debug.Assert(Not IsNothing(_extender), "CSS Friendly adapters internal error", "Null extender instance")
                Return _extender
            End Get
        End Property

        '/ ///////////////////////////////////////////////////////////////////////////////
        '/ PROTECTED        

        Protected Overrides Sub OnInit(ByVal e As EventArgs)
            MyBase.OnInit(e)

            If Extender.AdapterEnabled Then
                RegisterScripts()
            End If
        End Sub

        Protected Overrides Sub RenderBeginTag(ByVal writer As HtmlTextWriter)
            If Extender.AdapterEnabled Then
                Extender.RenderBeginTag(writer, "Kartris-GridView")
            Else
                MyBase.RenderBeginTag(writer)
            End If
        End Sub

        Protected Overrides Sub RenderEndTag(ByVal writer As HtmlTextWriter)
            If Extender.AdapterEnabled Then
                Extender.RenderEndTag(writer)
            Else
                MyBase.RenderEndTag(writer)
            End If
        End Sub

        Protected Overrides Sub RenderContents(ByVal writer As HtmlTextWriter)
            If Extender.AdapterEnabled Then
                Dim gridView As GridView = Control
                If (Not IsNothing(gridView)) Then
                    writer.Indent = writer.Indent + 1
                    WritePagerSection(writer, PagerPosition.Top)

                    writer.WriteLine()
                    writer.WriteBeginTag("table")
                    writer.WriteAttribute("cellpadding", "0")
                    writer.WriteAttribute("cellspacing", "0")
                    writer.WriteAttribute("summary", Control.ToolTip)

                    If Not String.IsNullOrEmpty(gridView.CssClass) Then
                        writer.WriteAttribute("class", gridView.CssClass)
                    End If

                    writer.Write(HtmlTextWriter.TagRightChar)
                    writer.Indent = writer.Indent + 1

                    Dim rows As ArrayList = New ArrayList()
                    Dim gvrc As GridViewRowCollection = Nothing

                    '/////////////////// HEAD /////////////////////////////

                    rows.Clear()
                    If (gridView.ShowHeader AndAlso (Not IsNothing(gridView.HeaderRow))) Then
                        rows.Add(gridView.HeaderRow)
                    End If
                    gvrc = New GridViewRowCollection(rows)
                    WriteRows(writer, gridView, gvrc, "thead")

                    '/////////////////// FOOT /////////////////////////////

                    rows.Clear()
                    If (gridView.ShowFooter AndAlso (Not IsNothing(gridView.FooterRow))) Then
                        rows.Add(gridView.FooterRow)
                    End If
                    gvrc = New GridViewRowCollection(rows)
                    WriteRows(writer, gridView, gvrc, "tfoot")

                    '/////////////////// BODY /////////////////////////////

                    WriteRows(writer, gridView, gridView.Rows, "tbody")

                    '//////////////////////////////////////////////////////

                    writer.Indent = writer.Indent - 1
                    writer.WriteLine()
                    writer.WriteEndTag("table")

                    WritePagerSection(writer, PagerPosition.Bottom)

                    writer.Indent = writer.Indent - 1
                    writer.WriteLine()
                End If
            Else
                MyBase.RenderContents(writer)
            End If
        End Sub

        '/ ///////////////////////////////////////////////////////////////////////////////
        '/ PRIVATE        

        Private Sub RegisterScripts()
        End Sub

        Private Sub WriteRows(ByVal writer As HtmlTextWriter, ByVal gridView As GridView, ByVal rows As GridViewRowCollection, ByVal tableSection As String)
            If rows.Count > 0 Then
                writer.WriteLine()
                writer.WriteBeginTag(tableSection)
                writer.Write(HtmlTextWriter.TagRightChar)
                writer.Indent = writer.Indent + 1

                Dim row As GridViewRow
                For Each row In rows
                    writer.WriteLine()
                    writer.WriteBeginTag("tr")

                    Dim className As String = GetRowClass(gridView, row)
                    If row.CssClass <> "" Then className = row.CssClass
                    If (Not String.IsNullOrEmpty(className)) Then
                        writer.WriteAttribute("class", className)
                    End If

                    ' We can uncomment the following block of code if we want to add arbitrary attributes.
                    '
                    ' Dim key As String
                    ' For Each key In row.Attributes.Keys
                    '      writer.WriteAttribute(key, row.Attributes(key))
                    ' Next

                    writer.Write(HtmlTextWriter.TagRightChar)
                    writer.Indent = writer.Indent + 1

                    Dim cell As TableCell
                    For Each cell In row.Cells
                        Dim fieldCell As DataControlFieldCell = cell
                        If ((Not IsNothing(fieldCell)) AndAlso (Not IsNothing(fieldCell.ContainingField))) Then
                            Dim field As DataControlField = fieldCell.ContainingField
                            If (Not field.Visible) Then
                                cell.Visible = False
                            End If

                            If ((Not IsNothing(field.ItemStyle)) AndAlso (Not String.IsNullOrEmpty(field.ItemStyle.CssClass))) Then
                                If (Not String.IsNullOrEmpty(cell.CssClass)) Then
                                    cell.CssClass &= " "
                                End If
                                cell.CssClass &= field.ItemStyle.CssClass
                            End If
                        End If

                        writer.WriteLine()
                        cell.RenderControl(writer)
                    Next

                    writer.Indent = writer.Indent - 1
                    writer.WriteLine()
                    writer.WriteEndTag("tr")
                Next

                writer.Indent = writer.Indent - 1
                writer.WriteLine()
                writer.WriteEndTag(tableSection)
            End If
        End Sub

        Private Function GetRowClass(ByVal gridView As GridView, ByVal row As GridViewRow) As String
            Dim className As String = ""

            If ((row.RowState And DataControlRowState.Alternate) = DataControlRowState.Alternate) Then
                className &= " Kartris-GridView-Alternate "
                If (Not IsNothing(gridView.AlternatingRowStyle)) Then
                    className &= gridView.AlternatingRowStyle.CssClass
                End If
            ElseIf (row.Equals(gridView.HeaderRow) AndAlso (Not IsNothing(gridView.HeaderStyle)) AndAlso (Not String.IsNullOrEmpty(gridView.HeaderStyle.CssClass))) Then
                className &= " " & gridView.HeaderStyle.CssClass
            ElseIf (row.Equals(gridView.FooterRow) AndAlso (Not IsNothing(gridView.FooterStyle)) AndAlso (Not String.IsNullOrEmpty(gridView.FooterStyle.CssClass))) Then
                className &= " " & gridView.FooterStyle.CssClass
            ElseIf ((Not IsNothing(gridView.RowStyle)) AndAlso (Not String.IsNullOrEmpty(gridView.RowStyle.CssClass))) Then
                className &= " " & gridView.RowStyle.CssClass
            End If

            If ((row.RowState And DataControlRowState.Edit) = DataControlRowState.Edit) Then
                className &= " Kartris-GridView-Edit "
                If (Not IsNothing(gridView.EditRowStyle)) Then
                    className &= gridView.EditRowStyle.CssClass
                End If
            End If

            If ((row.RowState And DataControlRowState.Insert) = DataControlRowState.Insert) Then
                className &= " Kartris-GridView-Insert "
            End If

            If ((row.RowState And DataControlRowState.Selected) = DataControlRowState.Selected) Then
                className &= " Kartris-GridView-Selected "
                If (Not IsNothing(gridView.SelectedRowStyle)) Then
                    className &= gridView.SelectedRowStyle.CssClass
                End If
            End If

            Return className.Trim()
        End Function

        Private Sub WritePagerSection(ByVal writer As HtmlTextWriter, ByVal pos As PagerPosition)
            Dim gridView As GridView = Control

            If ((Not IsNothing(gridView)) AndAlso _
                gridView.AllowPaging AndAlso _
                ((gridView.PagerSettings.Position = pos) OrElse (gridView.PagerSettings.Position = PagerPosition.TopAndBottom))) Then

                Dim innerTable As Table = Nothing

                If ((pos = PagerPosition.Top) AndAlso _
                    (Not IsNothing(gridView.TopPagerRow)) AndAlso _
                    (gridView.TopPagerRow.Cells.Count = 1) AndAlso _
                    (gridView.TopPagerRow.Cells(0).Controls.Count = 1) AndAlso _
                    (TypeOf gridView.TopPagerRow.Cells(0).Controls(0) Is Table)) Then
                    innerTable = CType(gridView.TopPagerRow.Cells(0).Controls(0), Table)
                ElseIf ((pos = PagerPosition.Bottom) AndAlso _
                    (Not IsNothing(gridView.BottomPagerRow)) AndAlso _
                    (gridView.BottomPagerRow.Cells.Count = 1) AndAlso _
                    (gridView.BottomPagerRow.Cells(0).Controls.Count = 1) AndAlso _
                    (TypeOf gridView.BottomPagerRow.Cells(0).Controls(0) Is Table)) Then
                    innerTable = CType(gridView.BottomPagerRow.Cells(0).Controls(0), Table)
                End If

                If ((Not IsNothing(innerTable)) AndAlso (innerTable.Rows.Count = 1)) Then
                    Dim className As String = "Kartris-GridView-Pagination Kartris-GridView-"
                    className &= IIf(pos = PagerPosition.Top, "Top ", "Bottom ")
                    If (Not IsNothing(gridView.PagerStyle)) Then
                        className &= gridView.PagerStyle.CssClass
                    End If
                    className = className.Trim()

                    writer.WriteLine()
                    writer.WriteBeginTag("div")
                    writer.WriteAttribute("class", className)
                    writer.Write(HtmlTextWriter.TagRightChar)
                    writer.Indent = writer.Indent + 1

                    Dim row As TableRow = innerTable.Rows(0)
                    Dim cell As TableCell
                    For Each cell In row.Cells
                        Dim ctrl As Control
                        For Each ctrl In cell.Controls
                            writer.WriteLine()
                            ctrl.RenderControl(writer)
                        Next
                    Next

                    writer.Indent = writer.Indent - 1
                    writer.WriteLine()
                    writer.WriteEndTag("div")
                End If
            End If
        End Sub
    End Class
End Namespace
