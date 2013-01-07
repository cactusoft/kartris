Imports System
Imports System.Data
Imports System.Configuration
Imports System.Web
Imports System.Web.Security
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI.WebControls.WebParts
Imports System.Web.UI.HtmlControls

Namespace Kartris
    Public Class DetailsViewAdapter
        Inherits CompositeDataBoundControlAdapter

        Protected Overrides ReadOnly Property HeaderText() As String
            Get
                Return ControlAsDetailsView.HeaderText
            End Get
        End Property
        Protected Overrides ReadOnly Property FooterText() As String
            Get
                Return ControlAsDetailsView.FooterText
            End Get
        End Property
        Protected Overrides ReadOnly Property HeaderTemplate() As ITemplate
            Get
                Return ControlAsDetailsView.HeaderTemplate
            End Get
        End Property
        Protected Overrides ReadOnly Property FooterTemplate() As ITemplate
            Get
                Return ControlAsDetailsView.FooterTemplate
            End Get
        End Property
        Protected Overrides ReadOnly Property HeaderRow() As TableRow
            Get
                Return ControlAsDetailsView.HeaderRow
            End Get
        End Property
        Protected Overrides ReadOnly Property FooterRow() As TableRow
            Get
                Return ControlAsDetailsView.FooterRow
            End Get
        End Property
        Protected Overrides ReadOnly Property AllowPaging() As Boolean
            Get
                Return ControlAsDetailsView.AllowPaging
            End Get
        End Property
        Protected Overrides ReadOnly Property DataItemCount() As Integer
            Get
                Return ControlAsDetailsView.DataItemCount
            End Get
        End Property
        Protected Overrides ReadOnly Property DataItemIndex() As Integer
            Get
                Return ControlAsDetailsView.DataItemIndex
            End Get
        End Property
        Protected Overrides ReadOnly Property PagerSettings() As PagerSettings
            Get
                Return ControlAsDetailsView.PagerSettings
            End Get
        End Property

        Public Sub New()
            _classMain = "Kartris-DetailsView"
            _classHeader = "Kartris-DetailsView-Header"
            _classData = "Kartris-DetailsView-Data"
            _classFooter = "Kartris-DetailsView-Footer"
            _classPagination = "Kartris-DetailsView-Pagination"
            _classOtherPage = "Kartris-DetailsView-OtherPage"
            _classActivePage = "Kartris-DetailsView-ActivePage"
        End Sub

        Protected Overrides Sub BuildItem(ByVal writer As HtmlTextWriter)
            If (IsDetailsView AndAlso (ControlAsDetailsView.Rows.Count > 0)) Then
                writer.WriteLine()
                writer.WriteBeginTag("div")
                writer.WriteAttribute("class", _classData)
                writer.Write(HtmlTextWriter.TagRightChar)
                writer.Indent = writer.Indent + 1

                writer.WriteLine()
                writer.WriteBeginTag("ul")
                writer.Write(HtmlTextWriter.TagRightChar)
                writer.Indent = writer.Indent + 1

                Dim useFields As Boolean = (Not ControlAsDetailsView.AutoGenerateRows) AndAlso (ControlAsDetailsView.Fields.Count = ControlAsDetailsView.Rows.Count)
                Dim countRenderedRows As Integer = 0
                Dim iRow As Integer
                For iRow = 0 To ControlAsDetailsView.Rows.Count - 1
                    If ((Not useFields) OrElse ControlAsDetailsView.Fields(iRow).Visible) Then
                        Dim row As DetailsViewRow = ControlAsDetailsView.Rows(iRow)

                        If ((Not ControlAsDetailsView.AutoGenerateRows) AndAlso _
                                ((row.RowState And DataControlRowState.Insert) = DataControlRowState.Insert) AndAlso _
                                (Not ControlAsDetailsView.Fields.Item(row.RowIndex).InsertVisible)) Then
                            Continue For
                        End If

                        writer.WriteLine()
                        writer.WriteBeginTag("li")

                        Dim theClass As String = IIf(((countRenderedRows Mod 2) = 1), "Kartris-DetailsView-Alternate", "")
                        If (useFields AndAlso (Not IsNothing(ControlAsDetailsView.Fields(iRow).ItemStyle)) AndAlso (Not String.IsNullOrEmpty(ControlAsDetailsView.Fields(iRow).ItemStyle.CssClass))) Then
                            If (Not String.IsNullOrEmpty(theClass)) Then
                                theClass &= " "
                            End If
                            theClass &= ControlAsDetailsView.Fields(iRow).ItemStyle.CssClass
                        End If
                        If (Not String.IsNullOrEmpty(theClass)) Then
                            writer.WriteAttribute("class", theClass)
                        End If
                        writer.Write(HtmlTextWriter.TagRightChar)
                        writer.Indent = writer.Indent + 1
                        writer.WriteLine()

                        Dim iCell As Integer
                        For iCell = 0 To row.Cells.Count - 1
                            Dim cell As TableCell = row.Cells(iCell)
                            writer.WriteBeginTag("span")
                            If iCell = 0 Then
                                writer.WriteAttribute("class", "Kartris-DetailsView-Name")
                            ElseIf iCell = 1 Then
                                writer.WriteAttribute("class", "Kartris-DetailsView-Value")
                            Else
                                writer.WriteAttribute("class", "Kartris-DetailsView-Misc")
                            End If
                            writer.Write(HtmlTextWriter.TagRightChar)
                            If (Not String.IsNullOrEmpty(cell.Text)) Then
                                writer.Write(cell.Text)
                            End If
                            Dim cellChildControl As Control
                            For Each cellChildControl In cell.Controls
                                cellChildControl.RenderControl(writer)
                            Next
                            writer.WriteEndTag("span")
                        Next

                        writer.Indent = writer.Indent - 1
                        writer.WriteLine()
                        writer.WriteEndTag("li")
                        countRenderedRows += 1
                    End If
                Next

                writer.Indent = writer.Indent - 1
                writer.WriteLine()
                writer.WriteEndTag("ul")

                writer.Indent = writer.Indent - 1
                writer.WriteLine()
                writer.WriteEndTag("div")
            End If
        End Sub
    End Class
End Namespace
