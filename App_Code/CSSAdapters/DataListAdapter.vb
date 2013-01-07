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
    '    Public Class DataListAdapter
    '        Inherits System.Web.UI.WebControls.Adapters.WebControlAdapter
    '        Private _extender As WebControlAdapterExtender = Nothing

    '        Private ReadOnly Property Extender() As WebControlAdapterExtender
    '            Get
    '                If ((IsNothing(_extender) AndAlso (Not IsNothing(Control))) OrElse _
    '                    ((Not IsNothing(_extender)) AndAlso (Not Control.Equals(_extender.AdaptedControl)))) Then
    '                    _extender = New WebControlAdapterExtender(Control)
    '                End If

    '                System.Diagnostics.Debug.Assert(Not IsNothing(_extender), "CSS Friendly adapters internal error", "Null extender instance")
    '                Return _extender
    '            End Get
    '        End Property

    '        'Private ReadOnly Property Extender() As WebControlAdapterExtender
    '        '    Get
    '        '        If ((_extender Is Nothing) AndAlso (Control IsNot Nothing)) OrElse ((_extender IsNot Nothing) AndAlso (Control <> _extender.AdaptedControl)) Then
    '        '            _extender = New WebControlAdapterExtender(Control)
    '        '        End If

    '        '        System.Diagnostics.Debug.Assert(_extender IsNot Nothing, "CSS Friendly adapters internal error", "Null extender instance")
    '        '        Return _extender
    '        '    End Get
    '        'End Property

    '        Private ReadOnly Property RepeatColumns() As Integer
    '            Get
    '                Dim dataList As DataList = TryCast(Control, DataList)
    '                Dim nRet As Integer = 1
    '                If dataList IsNot Nothing Then
    '                    If dataList.RepeatColumns = 0 Then
    '                        If dataList.RepeatDirection = RepeatDirection.Horizontal Then
    '                            nRet = dataList.Items.Count
    '                        End If
    '                    Else
    '                        nRet = dataList.RepeatColumns
    '                    End If
    '                End If
    '                Return nRet
    '            End Get
    '        End Property

    '        ''' ///////////////////////////////////////////////////////////////////////////////
    '        ''' PROTECTED        

    '        Protected Overloads Overrides Sub OnInit(ByVal e As EventArgs)
    '            MyBase.OnInit(e)

    '            If Extender.AdapterEnabled Then
    '                RegisterScripts()
    '            End If
    '        End Sub

    '        Protected Overloads Overrides Sub RenderBeginTag(ByVal writer As HtmlTextWriter)
    '            If Extender.AdapterEnabled Then
    '                Extender.RenderBeginTag(writer, "Kartris-DataList")
    '            Else
    '                MyBase.RenderBeginTag(writer)
    '            End If
    '        End Sub

    '        Protected Overloads Overrides Sub RenderEndTag(ByVal writer As HtmlTextWriter)
    '            If Extender.AdapterEnabled Then
    '                Extender.RenderEndTag(writer)
    '            Else
    '                MyBase.RenderEndTag(writer)
    '            End If
    '        End Sub

    '        Protected Overloads Overrides Sub RenderContents(ByVal writer As HtmlTextWriter)
    '            If Extender.AdapterEnabled Then
    '                Dim dataList As DataList = TryCast(Control, DataList)
    '                If dataList IsNot Nothing Then
    '                    writer.Indent += 1
    '                    writer.WriteLine()
    '                    writer.WriteBeginTag("table")
    '                    writer.WriteAttribute("cellpadding", dataList.CellPadding.ToString())
    '                    writer.WriteAttribute("cellspacing", dataList.CellSpacing.ToString())
    '                    writer.WriteAttribute("summary", Control.ToolTip)
    '                    writer.Write(HtmlTextWriter.TagRightChar)
    '                    writer.Indent += 1

    '                    If dataList.HeaderTemplate IsNot Nothing AndAlso dataList.ShowHeader Then
    '                        If Not [String].IsNullOrEmpty(dataList.Caption) Then
    '                            writer.WriteLine()
    '                            writer.WriteBeginTag("caption")
    '                            writer.Write(HtmlTextWriter.TagRightChar)
    '                            writer.Write(dataList.Caption)
    '                            writer.WriteEndTag("caption")
    '                        End If

    '                        writer.WriteLine()
    '                        writer.WriteBeginTag("thead")
    '                        writer.Write(HtmlTextWriter.TagRightChar)
    '                        writer.Indent += 1

    '                        writer.WriteLine()
    '                        writer.WriteBeginTag("tr")
    '                        writer.Write(HtmlTextWriter.TagRightChar)
    '                        writer.Indent += 1

    '                        writer.WriteLine()
    '                        writer.WriteBeginTag("th")
    '                        writer.WriteAttribute("colspan", RepeatColumns.ToString())
    '                        Dim className As String = "Kartris-DataList-Header "
    '                        If dataList.HeaderStyle IsNot Nothing Then
    '                            className += dataList.HeaderStyle.CssClass
    '                        End If
    '                        writer.WriteAttribute("class", className)
    '                        writer.Write(HtmlTextWriter.TagRightChar)
    '                        writer.Indent += 1

    '                        Dim container As New PlaceHolder()
    '                        dataList.Controls.Add(container)
    '                        dataList.HeaderTemplate.InstantiateIn(container)
    '                        container.DataBind()
    '                        container.RenderControl(writer)

    '                        writer.Indent -= 1
    '                        writer.WriteLine()
    '                        writer.WriteEndTag("th")

    '                        writer.Indent -= 1
    '                        writer.WriteLine()
    '                        writer.WriteEndTag("tr")

    '                        writer.Indent -= 1
    '                        writer.WriteLine()

    '                        writer.WriteEndTag("thead")
    '                    End If

    '                    If dataList.FooterTemplate IsNot Nothing AndAlso dataList.ShowFooter Then
    '                        writer.WriteLine()
    '                        writer.WriteBeginTag("tfoot")
    '                        writer.Write(HtmlTextWriter.TagRightChar)
    '                        writer.Indent += 1

    '                        writer.WriteLine()
    '                        writer.WriteBeginTag("tr")
    '                        writer.Write(HtmlTextWriter.TagRightChar)
    '                        writer.Indent += 1

    '                        writer.WriteLine()
    '                        writer.WriteBeginTag("td")
    '                        writer.WriteAttribute("colspan", RepeatColumns.ToString())
    '                        Dim className As String = "Kartris-DataList-Footer "
    '                        If dataList.FooterStyle IsNot Nothing Then
    '                            className += dataList.FooterStyle.CssClass
    '                        End If
    '                        writer.WriteAttribute("class", className)
    '                        writer.Write(HtmlTextWriter.TagRightChar)
    '                        writer.Indent += 1

    '                        Dim container As New PlaceHolder()
    '                        dataList.Controls.Add(container)
    '                        dataList.FooterTemplate.InstantiateIn(container)
    '                        container.DataBind()
    '                        container.RenderControl(writer)

    '                        writer.Indent -= 1
    '                        writer.WriteLine()
    '                        writer.WriteEndTag("td")

    '                        writer.Indent -= 1
    '                        writer.WriteLine()
    '                        writer.WriteEndTag("tr")

    '                        writer.Indent -= 1
    '                        writer.WriteLine()
    '                        writer.WriteEndTag("tfoot")
    '                    End If

    '                    If dataList.ItemTemplate IsNot Nothing Then
    '                        writer.WriteLine()
    '                        writer.WriteBeginTag("tbody")
    '                        writer.Write(HtmlTextWriter.TagRightChar)
    '                        writer.Indent += 1

    '                        Dim nItemsInColumn As Integer = CInt(Math.Ceiling(CDbl(dataList.Items.Count) / CDbl(RepeatColumns)))
    '                        For iItem As Integer = 0 To dataList.Items.Count - 1
    '                            Dim nRow As Integer = iItem / RepeatColumns
    '                            Dim nCol As Integer = iItem Mod RepeatColumns
    '                            Dim nDesiredIndex As Integer = iItem
    '                            If dataList.RepeatDirection = RepeatDirection.Vertical Then
    '                                nDesiredIndex = (nCol * nItemsInColumn) + nRow
    '                            End If

    '                            If (iItem Mod RepeatColumns) = 0 Then
    '                                writer.WriteLine()
    '                                writer.WriteBeginTag("tr")
    '                                writer.Write(HtmlTextWriter.TagRightChar)
    '                                writer.Indent += 1
    '                            End If

    '                            writer.WriteLine()
    '                            writer.WriteBeginTag("td")

    '                            Dim className As String = GetRowClass(dataList, dataList.Items(iItem))
    '                            If Not [String].IsNullOrEmpty(className) Then
    '                                writer.WriteAttribute("class", className)
    '                            End If

    '                            writer.Write(HtmlTextWriter.TagRightChar)
    '                            writer.Indent += 1

    '                            For Each itemCtrl As Control In dataList.Items(iItem).Controls
    '                                itemCtrl.RenderControl(writer)
    '                            Next

    '                            writer.Indent -= 1
    '                            writer.WriteLine()
    '                            writer.WriteEndTag("td")

    '                            If ((iItem + 1) Mod RepeatColumns) = 0 Then
    '                                writer.Indent -= 1
    '                                writer.WriteLine()
    '                                writer.WriteEndTag("tr")
    '                            End If
    '                        Next

    '                        If (dataList.Items.Count Mod RepeatColumns) <> 0 Then
    '                            writer.Indent -= 1
    '                            writer.WriteLine()
    '                            writer.WriteEndTag("tr")
    '                        End If

    '                        writer.Indent -= 1
    '                        writer.WriteLine()
    '                        writer.WriteEndTag("tbody")
    '                    End If

    '                    writer.Indent -= 1
    '                    writer.WriteLine()
    '                    writer.WriteEndTag("table")

    '                    writer.Indent -= 1
    '                    writer.WriteLine()
    '                End If
    '            Else
    '                MyBase.RenderContents(writer)
    '            End If
    '        End Sub

    '        ''' ///////////////////////////////////////////////////////////////////////////////
    '        ''' PRIVATE        

    '        Private Sub RegisterScripts()
    '        End Sub

    '        ''' <summary>
    '        ''' Gets the row's CSS class.
    '        ''' </summary>
    '        ''' <param name="DataList">The data list.</param>
    '        ''' <param name="Item">The current item.</param>
    '        ''' <returns>The CSS class.</returns>
    '        ''' <remarks>
    '        ''' Added 10/31/2007 by SelArom based on similar code for GridView control.
    '        ''' </remarks>
    '        Private Function GetRowClass(ByVal list As DataList, ByVal item As DataListItem) As String
    '            Dim className As String = item.CssClass

    '            If list.ItemStyle IsNot Nothing Then
    '                className += list.ItemStyle.CssClass
    '            End If

    '            Select Case item.ItemType
    '                Case ListItemType.Item
    '                    className += " Kartris-DataList-Item "
    '                    If list.ItemStyle IsNot Nothing Then
    '                        className += list.AlternatingItemStyle.CssClass
    '                    End If
    '                    Exit Select
    '                Case ListItemType.AlternatingItem
    '                    className += " Kartris-DataList-Alternate "
    '                    If list.AlternatingItemStyle IsNot Nothing Then
    '                        className += list.AlternatingItemStyle.CssClass
    '                    End If
    '                    Exit Select
    '                Case ListItemType.EditItem
    '                    className += " Kartris-DataList-EditItem "
    '                    If list.EditItemStyle IsNot Nothing Then
    '                        className += list.EditItemStyle.CssClass
    '                    End If
    '                    Exit Select
    '                Case ListItemType.SelectedItem
    '                    className += " Kartris-DataList-SelectedItem "
    '                    If list.SelectedItemStyle IsNot Nothing Then
    '                        className += list.SelectedItemStyle.CssClass
    '                    End If
    '                    Exit Select
    '                Case ListItemType.Separator
    '                    className += " Kartris-DataList-Separator "
    '                    If list.SeparatorStyle IsNot Nothing Then
    '                        className += list.SeparatorStyle.CssClass
    '                    End If
    '                    Exit Select
    '            End Select

    '            Return className.Trim()
    '        End Function
    '    End Class

    Public Class DataListAdapter
        Inherits System.Web.UI.WebControls.Adapters.WebControlAdapter

        'Protected This As WebControlAdapterExtender = Nothing
        'Private _extender As WebControlAdapterExtender = Nothing
        'Private ReadOnly Property Extender() As WebControlAdapterExtender
        '    Get
        '        If ((IsNothing(_extender) AndAlso (Not IsNothing(Control))) OrElse _
        '            ((Not IsNothing(_extender)) AndAlso (Not Control.Equals(_extender.AdaptedControl)))) Then
        '            _extender = New WebControlAdapterExtender(Control)
        '        End If

        '        System.Diagnostics.Debug.Assert(Not IsNothing(_extender), "CSS Friendly adapters internal error", "Null extender instance")
        '        Return _extender
        '    End Get
        'End Property

        'Private ReadOnly Property RepeatColumns() As Integer
        '    Get
        '        Dim dataList As DataList = Control
        '        Dim nRet As Integer = 1
        '        If (Not IsNothing(dataList)) Then
        '            If dataList.RepeatColumns = 0 Then
        '                If dataList.RepeatDirection = RepeatDirection.Horizontal Then
        '                    nRet = dataList.Items.Count
        '                End If
        '            Else
        '                nRet = dataList.RepeatColumns
        '            End If
        '        End If
        '        Return nRet
        '    End Get
        'End Property

        ''/ ///////////////////////////////////////////////////////////////////////////////
        ''/ PROTECTED        

        'Protected Overrides Sub OnInit(ByVal e As EventArgs)
        '    MyBase.OnInit(e)

        '    If (Extender.AdapterEnabled) Then
        '        RegisterScripts()
        '    End If
        'End Sub

        'Protected Overrides Sub RenderBeginTag(ByVal writer As HtmlTextWriter)
        '    If (Extender.AdapterEnabled) Then
        '        If ((Not IsNothing(Control)) AndAlso (Not String.IsNullOrEmpty(Control.Attributes.Item("CssSelectorClass")))) Then
        '            writer.WriteLine()
        '            writer.WriteBeginTag("div")
        '            writer.WriteAttribute("class", Control.Attributes("CssSelectorClass"))
        '            writer.Write(HtmlTextWriter.TagRightChar)
        '            writer.Indent = writer.Indent + 1
        '        End If

        '        writer.WriteLine()
        '        writer.WriteBeginTag("div")
        '        writer.WriteAttribute("class", "Kartris-DataList")
        '        writer.Write(HtmlTextWriter.TagRightChar)
        '    Else
        '        MyBase.RenderBeginTag(writer)
        '    End If
        'End Sub

        'Protected Overrides Sub RenderEndTag(ByVal writer As HtmlTextWriter)
        '    If (Extender.AdapterEnabled) Then
        '        writer.WriteEndTag("div")

        '        If ((Not IsNothing(Control)) AndAlso (Not String.IsNullOrEmpty(Control.Attributes.Item("CssSelectorClass")))) Then
        '            writer.Indent = writer.Indent - 1
        '            writer.WriteLine()
        '            writer.WriteEndTag("div")
        '        End If

        '        writer.WriteLine()
        '    Else
        '        MyBase.RenderEndTag(writer)
        '    End If
        'End Sub

        'Protected Overrides Sub RenderContents(ByVal writer As HtmlTextWriter)
        '    If (Extender.AdapterEnabled) Then
        '        Dim dataList As DataList = Control
        '        If Not IsNothing(dataList) Then
        '            writer.Indent = writer.Indent + 1
        '            writer.WriteLine()
        '            writer.WriteBeginTag("table")
        '            writer.WriteAttribute("cellpadding", "0")
        '            writer.WriteAttribute("cellspacing", "0")
        '            writer.WriteAttribute("summary", Control.ToolTip)
        '            writer.Write(HtmlTextWriter.TagRightChar)
        '            writer.Indent = writer.Indent + 1

        '            If Not IsNothing(dataList.HeaderTemplate) Then
        '                Dim container As PlaceHolder = New PlaceHolder()
        '                dataList.HeaderTemplate.InstantiateIn(container)
        '                container.DataBind()

        '                If (container.Controls.Count = 1) AndAlso GetType(LiteralControl).IsInstanceOfType(container.Controls.Item(0)) Then
        '                    writer.WriteLine()
        '                    writer.WriteBeginTag("caption")
        '                    writer.Write(HtmlTextWriter.TagRightChar)

        '                    Dim literalControl As LiteralControl = CType(container.Controls.Item(0), LiteralControl)
        '                    writer.Write(literalControl.Text.Trim())
        '                    writer.WriteEndTag("caption")
        '                Else
        '                    writer.WriteLine()
        '                    writer.WriteBeginTag("thead")
        '                    writer.Write(HtmlTextWriter.TagRightChar)
        '                    writer.Indent = writer.Indent + 1

        '                    writer.WriteLine()
        '                    writer.WriteBeginTag("tr")
        '                    writer.Write(HtmlTextWriter.TagRightChar)
        '                    writer.Indent = writer.Indent + 1

        '                    writer.WriteLine()
        '                    writer.WriteBeginTag("th")
        '                    writer.WriteAttribute("colspan", RepeatColumns.ToString())
        '                    writer.Write(HtmlTextWriter.TagRightChar)
        '                    writer.Indent = writer.Indent + 1

        '                    container.RenderControl(writer)

        '                    writer.Indent = writer.Indent - 1
        '                    writer.WriteLine()
        '                    writer.WriteEndTag("th")

        '                    writer.Indent = writer.Indent - 1
        '                    writer.WriteLine()
        '                    writer.WriteEndTag("tr")

        '                    writer.Indent = writer.Indent - 1
        '                    writer.WriteLine()
        '                    writer.WriteEndTag("thead")
        '                End If
        '            End If

        '            If Not IsNothing(dataList.FooterTemplate) Then
        '                writer.WriteLine()
        '                writer.WriteBeginTag("tfoot")
        '                writer.Write(HtmlTextWriter.TagRightChar)
        '                writer.Indent = writer.Indent + 1

        '                writer.WriteLine()
        '                writer.WriteBeginTag("tr")
        '                writer.Write(HtmlTextWriter.TagRightChar)
        '                writer.Indent = writer.Indent + 1

        '                writer.WriteLine()
        '                writer.WriteBeginTag("td")
        '                writer.WriteAttribute("colspan", RepeatColumns.ToString())
        '                writer.Write(HtmlTextWriter.TagRightChar)
        '                writer.Indent = writer.Indent + 1

        '                Dim container As PlaceHolder = New PlaceHolder()
        '                dataList.FooterTemplate.InstantiateIn(container)
        '                container.DataBind()
        '                container.RenderControl(writer)

        '                writer.Indent = writer.Indent - 1
        '                writer.WriteLine()
        '                writer.WriteEndTag("td")

        '                writer.Indent = writer.Indent - 1
        '                writer.WriteLine()
        '                writer.WriteEndTag("tr")

        '                writer.Indent = writer.Indent - 1
        '                writer.WriteLine()
        '                writer.WriteEndTag("tfoot")
        '            End If

        '            If Not IsNothing(dataList.ItemTemplate) Then
        '                writer.WriteLine()
        '                writer.WriteBeginTag("tbody")
        '                writer.Write(HtmlTextWriter.TagRightChar)
        '                writer.Indent = writer.Indent + 1

        '                Dim nItemsInColumn As Integer = CType(Math.Ceiling((CType(dataList.Items.Count, Double)) / (CType(RepeatColumns, Double))), Integer)
        '                Dim iItem As Integer
        '                For iItem = 0 To dataList.Items.Count - 1
        '                    Dim nRow As Integer = iItem \ RepeatColumns
        '                    Dim nCol As Integer = Decimal.Remainder(iItem, RepeatColumns)
        '                    Dim nDesiredIndex As Integer = iItem
        '                    If dataList.RepeatDirection = RepeatDirection.Vertical Then
        '                        nDesiredIndex = (nCol * nItemsInColumn) + nRow
        '                    End If

        '                    If (Decimal.Remainder(iItem, RepeatColumns) = 0) Then
        '                        writer.WriteLine()
        '                        writer.WriteBeginTag("tr")
        '                        writer.Write(HtmlTextWriter.TagRightChar)
        '                        writer.Indent = writer.Indent + 1
        '                    End If

        '                    writer.WriteLine()
        '                    writer.WriteBeginTag("td")
        '                    writer.Write(HtmlTextWriter.TagRightChar)
        '                    writer.Indent = writer.Indent + 1

        '                    Dim itemCtrl As Control
        '                    For Each itemCtrl In dataList.Items(iItem).Controls
        '                        itemCtrl.RenderControl(writer)
        '                    Next

        '                    writer.Indent = writer.Indent - 1
        '                    writer.WriteLine()
        '                    writer.WriteEndTag("td")

        '                    If (Decimal.Remainder((iItem + 1), RepeatColumns) = 0) Then
        '                        writer.Indent = writer.Indent - 1
        '                        writer.WriteLine()
        '                        writer.WriteEndTag("tr")
        '                    End If
        '                Next

        '                If (Decimal.Remainder(dataList.Items.Count, RepeatColumns) <> 0) Then
        '                    writer.Indent = writer.Indent - 1
        '                    writer.WriteLine()
        '                    writer.WriteEndTag("tr")
        '                End If

        '                writer.Indent = writer.Indent - 1
        '                writer.WriteLine()
        '                writer.WriteEndTag("tbody")
        '            End If

        '            writer.Indent = writer.Indent - 1
        '            writer.WriteLine()
        '            writer.WriteEndTag("table")

        '            writer.Indent = writer.Indent - 1
        '            writer.WriteLine()
        '        End If
        '    Else
        '        MyBase.RenderContents(writer)
        '    End If
        'End Sub

        ''/ ///////////////////////////////////////////////////////////////////////////////
        ''/ PRIVATE        

        'Private Sub RegisterScripts()
        'End Sub

    End Class
End Namespace

'Imports System
'Imports System.Data
'Imports System.Collections
'Imports System.Configuration
'Imports System.Web
'Imports System.Web.Security
'Imports System.Web.UI
'Imports System.Web.UI.WebControls
'Imports System.Web.UI.WebControls.WebParts
'Imports System.Web.UI.HtmlControls

'Namespace Kartris
'    Public Class DataListAdapter
'        Inherits System.Web.UI.WebControls.Adapters.WebControlAdapter
'        Private _extender As WebControlAdapterExtender = Nothing
'        Private ReadOnly Property Extender() As WebControlAdapterExtender
'            Get
'                If ((_extender Is Nothing) AndAlso (Control IsNot Nothing)) OrElse ((_extender IsNot Nothing) AndAlso (Not Control.Equals(_extender.AdaptedControl))) Then
'                    _extender = New WebControlAdapterExtender(Control)
'                End If

'                System.Diagnostics.Debug.Assert(_extender IsNot Nothing, "CSS Friendly adapters internal error", "Null extender instance")
'                Return _extender
'            End Get
'        End Property

'        Private ReadOnly Property RepeatColumns() As Integer
'            Get
'                Dim dataList As DataList = TryCast(Control, DataList)
'                Dim nRet As Integer = 1
'                If dataList IsNot Nothing Then
'                    If dataList.RepeatColumns = 0 Then
'                        If dataList.RepeatDirection = RepeatDirection.Horizontal Then
'                            nRet = dataList.Items.Count
'                        End If
'                    Else
'                        nRet = dataList.RepeatColumns
'                    End If
'                End If
'                Return nRet
'            End Get
'        End Property

'        ''' ///////////////////////////////////////////////////////////////////////////////
'        ''' PROTECTED        

'        Protected Overloads Overrides Sub OnInit(ByVal e As EventArgs)
'            MyBase.OnInit(e)

'            If Extender.AdapterEnabled Then
'                RegisterScripts()
'            End If
'        End Sub

'        Protected Overloads Overrides Sub RenderBeginTag(ByVal writer As HtmlTextWriter)
'            If Extender.AdapterEnabled Then
'                Extender.RenderBeginTag(writer, "AspNet-DataList")
'            Else
'                MyBase.RenderBeginTag(writer)
'            End If
'        End Sub

'        Protected Overloads Overrides Sub RenderEndTag(ByVal writer As HtmlTextWriter)
'            If Extender.AdapterEnabled Then
'                Extender.RenderEndTag(writer)
'            Else
'                MyBase.RenderEndTag(writer)
'            End If
'        End Sub

'        Protected Overloads Overrides Sub RenderContents(ByVal writer As HtmlTextWriter)
'            If Extender.AdapterEnabled Then
'                Dim dataList As DataList = TryCast(Control, DataList)
'                Dim columns As Integer = (IIf(dataList.SeparatorTemplate Is Nothing, RepeatColumns, RepeatColumns * 2))

'                If dataList IsNot Nothing Then
'                    writer.Indent += 1
'                    writer.WriteLine()
'                    writer.WriteBeginTag("table")
'                    writer.WriteAttribute("cellpadding", dataList.CellPadding.ToString())
'                    writer.WriteAttribute("cellspacing", dataList.CellSpacing.ToString())
'                    writer.WriteAttribute("summary", Control.ToolTip)
'                    writer.Write(HtmlTextWriter.TagRightChar)
'                    writer.Indent += 1

'                    If dataList.HeaderTemplate IsNot Nothing AndAlso dataList.ShowHeader Then
'                        If Not [String].IsNullOrEmpty(dataList.Caption) Then
'                            writer.WriteLine()
'                            writer.WriteBeginTag("caption")
'                            writer.Write(HtmlTextWriter.TagRightChar)
'                            writer.Write(dataList.Caption)
'                            writer.WriteEndTag("caption")
'                        End If

'                        writer.WriteLine()
'                        writer.WriteBeginTag("thead")
'                        writer.Write(HtmlTextWriter.TagRightChar)
'                        writer.Indent += 1

'                        writer.WriteLine()
'                        writer.WriteBeginTag("tr")
'                        writer.Write(HtmlTextWriter.TagRightChar)
'                        writer.Indent += 1

'                        writer.WriteLine()
'                        writer.WriteBeginTag("th")
'                        writer.WriteAttribute("colspan", columns.ToString())
'                        Dim className As String = "AspNet-DataList-Header "
'                        If dataList.HeaderStyle IsNot Nothing Then
'                            className += dataList.HeaderStyle.CssClass
'                        End If
'                        writer.WriteAttribute("class", className)
'                        writer.Write(HtmlTextWriter.TagRightChar)
'                        writer.Indent += 1

'                        Dim container As New PlaceHolder()
'                        dataList.HeaderTemplate.InstantiateIn(container)
'                        container.DataBind()
'                        container.RenderControl(writer)

'                        writer.Indent -= 1
'                        writer.WriteLine()
'                        writer.WriteEndTag("th")

'                        writer.Indent -= 1
'                        writer.WriteLine()
'                        writer.WriteEndTag("tr")

'                        writer.Indent -= 1
'                        writer.WriteLine()

'                        writer.WriteEndTag("thead")
'                    End If

'                    If dataList.FooterTemplate IsNot Nothing AndAlso dataList.ShowFooter Then
'                        writer.WriteLine()
'                        writer.WriteBeginTag("tfoot")
'                        writer.Write(HtmlTextWriter.TagRightChar)
'                        writer.Indent += 1

'                        writer.WriteLine()
'                        writer.WriteBeginTag("tr")
'                        writer.Write(HtmlTextWriter.TagRightChar)
'                        writer.Indent += 1

'                        writer.WriteLine()
'                        writer.WriteBeginTag("td")
'                        writer.WriteAttribute("colspan", columns.ToString())
'                        Dim className As String = "AspNet-DataList-Footer "
'                        If dataList.FooterStyle IsNot Nothing Then
'                            className += dataList.FooterStyle.CssClass
'                        End If
'                        writer.WriteAttribute("class", className)
'                        writer.Write(HtmlTextWriter.TagRightChar)
'                        writer.Indent += 1

'                        Dim container As New PlaceHolder()
'                        dataList.FooterTemplate.InstantiateIn(container)
'                        container.DataBind()
'                        container.RenderControl(writer)

'                        writer.Indent -= 1
'                        writer.WriteLine()
'                        writer.WriteEndTag("td")

'                        writer.Indent -= 1
'                        writer.WriteLine()
'                        writer.WriteEndTag("tr")

'                        writer.Indent -= 1
'                        writer.WriteLine()
'                        writer.WriteEndTag("tfoot")
'                    End If

'                    If dataList.ItemTemplate IsNot Nothing Then
'                        writer.WriteLine()
'                        writer.WriteBeginTag("tbody")
'                        writer.Write(HtmlTextWriter.TagRightChar)
'                        writer.Indent += 1

'                        Dim nItemsInColumn As Integer = CInt(Math.Ceiling(CDbl(dataList.Items.Count) / CDbl(RepeatColumns)))
'                        For iItem As Integer = 0 To dataList.Items.Count - 1
'                            Dim nRow As Integer = iItem / RepeatColumns
'                            Dim nCol As Integer = iItem Mod RepeatColumns
'                            Dim nDesiredIndex As Integer = iItem
'                            If dataList.RepeatDirection = RepeatDirection.Vertical Then
'                                nDesiredIndex = (nCol * nItemsInColumn) + nRow
'                            End If

'                            If (iItem Mod RepeatColumns) = 0 Then
'                                writer.WriteLine()
'                                writer.WriteBeginTag("tr")
'                                writer.Write(HtmlTextWriter.TagRightChar)
'                                writer.Indent += 1
'                            End If

'                            writer.WriteLine()
'                            writer.WriteBeginTag("td")

'                            Dim className As String = GetRowClass(dataList, dataList.Items(iItem))
'                            If Not [String].IsNullOrEmpty(className) Then
'                                writer.WriteAttribute("class", className)
'                            End If

'                            writer.Write(HtmlTextWriter.TagRightChar)
'                            writer.Indent += 1

'                            For Each itemCtrl As Control In dataList.Items(iItem).Controls
'                                itemCtrl.RenderControl(writer)
'                            Next

'                            writer.Indent -= 1
'                            writer.WriteLine()
'                            writer.WriteEndTag("td")

'                            If dataList.SeparatorTemplate IsNot Nothing AndAlso (iItem + 1 < dataList.Items.Count) Then
'                                writer.WriteLine()
'                                writer.WriteBeginTag("td")
'                                className = "AspNet-DataList-Separator "
'                                If dataList.SeparatorStyle IsNot Nothing Then
'                                    className += dataList.SeparatorStyle.CssClass
'                                End If
'                                writer.WriteAttribute("class", className.Trim())
'                                writer.Write(HtmlTextWriter.TagRightChar)
'                                writer.Indent += 1

'                                Dim container As New PlaceHolder()
'                                dataList.SeparatorTemplate.InstantiateIn(container)
'                                container.DataBind()
'                                container.RenderControl(writer)

'                                writer.Indent -= 1
'                                writer.WriteLine()
'                                writer.WriteEndTag("td")
'                            End If

'                            If ((iItem + 1) Mod RepeatColumns) = 0 Then
'                                writer.Indent -= 1
'                                writer.WriteLine()
'                                writer.WriteEndTag("tr")
'                            End If
'                        Next

'                        If (dataList.Items.Count Mod RepeatColumns) <> 0 Then
'                            writer.Indent -= 1
'                            writer.WriteLine()
'                            writer.WriteEndTag("tr")
'                        End If

'                        writer.Indent -= 1
'                        writer.WriteLine()
'                        writer.WriteEndTag("tbody")
'                    End If

'                    writer.Indent -= 1
'                    writer.WriteLine()
'                    writer.WriteEndTag("table")

'                    writer.Indent -= 1
'                    writer.WriteLine()
'                End If
'            Else
'                MyBase.RenderContents(writer)
'            End If
'        End Sub

'        ''' ///////////////////////////////////////////////////////////////////////////////
'        ''' PRIVATE        

'        Private Sub RegisterScripts()
'        End Sub

'        ''' <summary>
'        ''' Gets the row's CSS class.
'        ''' </summary>
'        ''' <param name="DataList">The data list.</param>
'        ''' <param name="Item">The current item.</param>
'        ''' <returns>The CSS class.</returns>
'        ''' <remarks>
'        ''' Added 10/31/2007 by SelArom based on similar code for GridView control.
'        ''' </remarks>
'        Private Function GetRowClass(ByVal list As DataList, ByVal item As DataListItem) As String
'            Dim className As String = item.CssClass

'            If list.ItemStyle IsNot Nothing Then
'                className += list.ItemStyle.CssClass
'            End If

'            Select Case item.ItemType
'                Case ListItemType.Item
'                    className += " Kartris-DataList-Item "
'                    If list.ItemStyle IsNot Nothing Then
'                        className += list.AlternatingItemStyle.CssClass
'                    End If
'                    Exit Select
'                Case ListItemType.AlternatingItem
'                    className += " Kartris-DataList-Alternate "
'                    If list.AlternatingItemStyle IsNot Nothing Then
'                        className += list.AlternatingItemStyle.CssClass
'                    End If
'                    Exit Select
'                Case ListItemType.EditItem
'                    className += " Kartris-DataList-EditItem "
'                    If list.EditItemStyle IsNot Nothing Then
'                        className += list.EditItemStyle.CssClass
'                    End If
'                    Exit Select
'                Case ListItemType.SelectedItem
'                    className += " Kartris-DataList-SelectedItem "
'                    If list.SelectedItemStyle IsNot Nothing Then
'                        className += list.SelectedItemStyle.CssClass
'                    End If
'                    Exit Select
'            End Select

'            Return className.Trim()
'        End Function
'    End Class
'End Namespace



