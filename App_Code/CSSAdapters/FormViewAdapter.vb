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
    Public Class FormViewAdapter
        Inherits CompositeDataBoundControlAdapter

        Protected Overrides ReadOnly Property HeaderText() As String
            Get
                Return ControlAsFormView.HeaderText
            End Get
        End Property
        Protected Overrides ReadOnly Property FooterText() As String
            Get
                Return ControlAsFormView.FooterText
            End Get
        End Property
        Protected Overrides ReadOnly Property HeaderTemplate() As ITemplate
            Get
                Return ControlAsFormView.HeaderTemplate
            End Get
        End Property
        Protected Overrides ReadOnly Property FooterTemplate() As ITemplate
            Get
                Return ControlAsFormView.FooterTemplate
            End Get
        End Property
        Protected Overrides ReadOnly Property HeaderRow() As TableRow
            Get
                Return ControlAsFormView.HeaderRow
            End Get
        End Property
        Protected Overrides ReadOnly Property FooterRow() As TableRow
            Get
                Return ControlAsFormView.FooterRow
            End Get
        End Property
        Protected Overrides ReadOnly Property AllowPaging() As Boolean
            Get
                Return ControlAsFormView.AllowPaging
            End Get
        End Property
        Protected Overrides ReadOnly Property DataItemCount() As Integer
            Get
                Return ControlAsFormView.DataItemCount
            End Get
        End Property
        Protected Overrides ReadOnly Property DataItemIndex() As Integer
            Get
                Return ControlAsFormView.DataItemIndex
            End Get
        End Property
        Protected Overrides ReadOnly Property PagerSettings() As PagerSettings
            Get
                Return ControlAsFormView.PagerSettings
            End Get
        End Property

        Public Sub New()
            _classMain = "Kartris-FormView"
            _classHeader = "Kartris-FormView-Header"
            _classData = "Kartris-FormView-Data"
            _classFooter = "Kartris-FormView-Footer"
            _classPagination = "Kartris-FormView-Pagination"
            _classOtherPage = "Kartris-FormView-OtherPage"
            _classActivePage = "Kartris-FormView-ActivePage"
        End Sub

        Protected Overrides Sub BuildItem(ByVal writer As HtmlTextWriter)
            If ((Not IsNothing(ControlAsFormView.Row)) AndAlso _
                (ControlAsFormView.Row.Cells.Count > 0) AndAlso _
                (ControlAsFormView.Row.Cells.Item(0).Controls.Count > 0)) Then

                writer.WriteLine()
                writer.WriteBeginTag("div")
                writer.WriteAttribute("class", _classData)
                writer.Write(HtmlTextWriter.TagRightChar)
                writer.Indent = writer.Indent + 1
                writer.WriteLine()

                Dim itemCtrl As Control
                For Each itemCtrl In ControlAsFormView.Row.Cells(0).Controls
                    itemCtrl.RenderControl(writer)
                Next

                writer.Indent = writer.Indent - 1
                writer.WriteLine()
                writer.WriteEndTag("div")
            End If
        End Sub
    End Class
End Namespace
