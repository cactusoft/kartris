Imports System
Imports System.Data
Imports System.Configuration
Imports System.IO
Imports System.Web
Imports System.Web.Security
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI.WebControls.WebParts
Imports System.Web.UI.HtmlControls

Namespace Kartris
    Public MustInherit Class CompositeDataBoundControlAdapter
        Inherits System.Web.UI.WebControls.Adapters.DataBoundControlAdapter

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

        Protected _classMain As String = ""
        Protected _classHeader As String = ""
        Protected _classData As String = ""
        Protected _classFooter As String = ""
        Protected _classPagination As String = ""
        Protected _classOtherPage As String = ""
        Protected _classActivePage As String = ""

        Protected ReadOnly Property View() As CompositeDataBoundControl
            Get
                Try
                    Return CType(Control, CompositeDataBoundControl)
                Catch ex As Exception
                    Return Nothing
                End Try
            End Get
        End Property

        Protected ReadOnly Property ControlAsDetailsView() As DetailsView
            Get
                Try
                    Return CType(Control, DetailsView)
                Catch ex As Exception
                    Return Nothing
                End Try
            End Get
        End Property

        Protected ReadOnly Property IsDetailsView() As Boolean
            Get
                Return Not IsNothing(ControlAsDetailsView)
            End Get
        End Property

        Protected ReadOnly Property ControlAsFormView() As FormView
            Get
                Try
                    Return CType(Control, FormView)
                Catch ex As Exception
                    Return Nothing
                End Try
            End Get
        End Property

        Protected ReadOnly Property IsFormView() As Boolean
            Get
                Return Not IsNothing(ControlAsFormView)
            End Get
        End Property

        Protected MustOverride ReadOnly Property HeaderText() As String
        Protected MustOverride ReadOnly Property FooterText() As String
        Protected MustOverride ReadOnly Property HeaderTemplate() As ITemplate
        Protected MustOverride ReadOnly Property FooterTemplate() As ITemplate
        Protected MustOverride ReadOnly Property HeaderRow() As TableRow
        Protected MustOverride ReadOnly Property FooterRow() As TableRow
        Protected MustOverride ReadOnly Property AllowPaging() As Boolean
        Protected MustOverride ReadOnly Property DataItemCount() As Integer
        Protected MustOverride ReadOnly Property DataItemIndex() As Integer
        Protected MustOverride ReadOnly Property PagerSettings() As PagerSettings

        '/ ///////////////////////////////////////////////////////////////////////////////
        '/ METHODS

        Protected Overrides Sub OnInit(ByVal e As EventArgs)
            MyBase.OnInit(e)

            If (Extender.AdapterEnabled) Then
                RegisterScripts()
            End If
        End Sub

        Protected Overrides Sub RenderBeginTag(ByVal writer As HtmlTextWriter)
            If (Extender.AdapterEnabled) Then
                If ((Not IsNothing(Control)) AndAlso (Not String.IsNullOrEmpty(Control.Attributes.Item("CssSelectorClass")))) Then
                    writer.WriteLine()
                    writer.WriteBeginTag("div")
                    writer.WriteAttribute("class", Control.Attributes("CssSelectorClass"))
                    writer.Write(HtmlTextWriter.TagRightChar)
                    writer.Indent = writer.Indent + 1
                End If

                writer.WriteLine()
                writer.WriteBeginTag("div")
                writer.WriteAttribute("class", _classMain)
                writer.Write(HtmlTextWriter.TagRightChar)
            Else
                MyBase.RenderBeginTag(writer)
            End If
        End Sub

        Protected Overrides Sub RenderEndTag(ByVal writer As HtmlTextWriter)
            If (Extender.AdapterEnabled) Then
                writer.WriteEndTag("div")

                If ((Not IsNothing(Control)) AndAlso (Not String.IsNullOrEmpty(Control.Attributes.Item("CssSelectorClass")))) Then
                    writer.Indent = writer.Indent - 1
                    writer.WriteLine()
                    writer.WriteEndTag("div")
                End If

                writer.WriteLine()
            Else
                MyBase.RenderEndTag(writer)
            End If
        End Sub

        Protected Overrides Sub RenderContents(ByVal writer As HtmlTextWriter)
            If (Extender.AdapterEnabled) Then
                If Not IsNothing(View) Then
                    writer.Indent = writer.Indent + 1

                    BuildRow(HeaderRow, _classHeader, writer)
                    BuildItem(writer)
                    BuildRow(FooterRow, _classFooter, writer)
                    BuildPaging(writer)

                    writer.Indent = writer.Indent - 1
                    writer.WriteLine()
                End If
            Else
                MyBase.RenderContents(writer)
            End If
        End Sub

        Protected Overridable Sub BuildItem(ByVal writer As HtmlTextWriter)
        End Sub

        Protected Overridable Sub BuildRow(ByVal row As TableRow, ByVal cssClass As String, ByVal writer As HtmlTextWriter)
            If ((Not IsNothing(row)) AndAlso row.Visible) Then

                ' If there isn't any content, don't render anything.

                Dim bHasContent As Boolean = False
                Dim iCell As Integer
                Dim cell As TableCell
                For iCell = 0 To row.Cells.Count - 1
                    cell = row.Cells(iCell)
                    If ((Not String.IsNullOrEmpty(cell.Text)) OrElse (cell.Controls.Count > 0)) Then
                        bHasContent = True
                        Exit For
                    End If
                Next

                If (bHasContent) Then
                    writer.WriteLine()
                    writer.WriteBeginTag("div")
                    writer.WriteAttribute("class", cssClass)
                    writer.Write(HtmlTextWriter.TagRightChar)
                    writer.Indent = writer.Indent + 1
                    writer.WriteLine()

                    For iCell = 0 To row.Cells.Count - 1
                        cell = row.Cells(iCell)
                        If (Not String.IsNullOrEmpty(cell.Text)) Then
                            writer.Write(cell.Text)
                        End If
                        Dim cellChildControl As Control
                        For Each cellChildControl In cell.Controls
                            cellChildControl.RenderControl(writer)
                        Next
                    Next

                    writer.Indent = writer.Indent - 1
                    writer.WriteLine()
                    writer.WriteEndTag("div")
                End If
            End If
        End Sub

        Protected Overridable Sub BuildPaging(ByVal writer As HtmlTextWriter)
            If (AllowPaging AndAlso (DataItemCount > 0)) Then
                writer.WriteLine()
                writer.WriteBeginTag("div")
                writer.WriteAttribute("class", _classPagination)
                writer.Write(HtmlTextWriter.TagRightChar)
                writer.Indent = writer.Indent + 1

                Dim iStart As Integer = 0
                Dim iEnd As Integer = DataItemCount
                Dim nPages As Integer = iEnd - iStart + 1
                Dim bExceededPageButtonCount As Boolean = nPages > PagerSettings.PageButtonCount

                If (bExceededPageButtonCount) Then
                    iStart = (DataItemIndex \ PagerSettings.PageButtonCount) * PagerSettings.PageButtonCount
                    iEnd = Math.Min(iStart + PagerSettings.PageButtonCount, DataItemCount)
                End If

                writer.WriteLine()

                If (bExceededPageButtonCount AndAlso (iStart > 0)) Then
                    writer.WriteBeginTag("a")
                    writer.WriteAttribute("class", _classOtherPage)
                    writer.WriteAttribute("href", Page.ClientScript.GetPostBackClientHyperlink(Control, "Page$" + iStart.ToString(), True))
                    writer.Write(HtmlTextWriter.TagRightChar)
                    writer.Write("...")
                    writer.WriteEndTag("a")
                End If

                Dim iDataItem As Integer
                For iDataItem = iStart To iEnd - 1
                    Dim strPage As String = (iDataItem + 1).ToString()
                    If (DataItemIndex = iDataItem) Then
                        writer.WriteBeginTag("span")
                        writer.WriteAttribute("class", _classActivePage)
                        writer.Write(HtmlTextWriter.TagRightChar)
                        writer.Write(strPage)
                        writer.WriteEndTag("span")
                    Else
                        writer.WriteBeginTag("a")
                        writer.WriteAttribute("class", _classOtherPage)
                        writer.WriteAttribute("href", Page.ClientScript.GetPostBackClientHyperlink(Control, "Page$" & strPage, True))
                        writer.Write(HtmlTextWriter.TagRightChar)
                        writer.Write(strPage)
                        writer.WriteEndTag("a")
                    End If
                Next

                If (bExceededPageButtonCount AndAlso (iEnd < DataItemCount)) Then
                    writer.WriteBeginTag("a")
                    writer.WriteAttribute("class", _classOtherPage)
                    writer.WriteAttribute("href", Page.ClientScript.GetPostBackClientHyperlink(Control, "Page$" & (iEnd + 1).ToString(), True))
                    writer.Write(HtmlTextWriter.TagRightChar)
                    writer.Write("...")
                    writer.WriteEndTag("a")
                End If

                writer.Indent = writer.Indent - 1
                writer.WriteLine()
                writer.WriteEndTag("div")
            End If
        End Sub

        Protected Overridable Sub RegisterScripts()
        End Sub
    End Class
End Namespace
