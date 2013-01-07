'---------------------------------------------------
'     Copyright (c) 2007 Jeffrey Bazinet, VWD-CMS 
'     http://www.vwd-cms.com/  All rights reserved.
'---------------------------------------------------

Imports System.Data
Imports System.Configuration
Imports System.Web
Imports System.Web.Security
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI.WebControls.WebParts
Imports System.Web.UI.HtmlControls
Imports System.Text
Imports System.Collections.Specialized

Namespace VwdCms
    ' this enum tells ths SplitterBar what technique to 
    ' use when hiding IFrames. IFrames capture mouse 
    ' events which prevent the SplitterBar from functioning
    ' properly
    Public Enum SplitterBarIFrameHiding
        DoNotHide
        ' don't hide IFrames, this is really for testing, debugging
        UseVisibility
        ' use iframe.style.visibility = "hidden"
        UseDisplay
        ' use iframe.style.display = "none"
    End Enum

    Public Enum SplitterBarOrientations
        Vertical
        Horizontal
    End Enum

    Public Class SplitterBar
        Inherits Panel
        Implements INamingContainer
        Implements IPostBackDataHandler
        Protected hdnWidth As HtmlInputHidden
        Protected hdnMinWidth As HtmlInputHidden
        Protected hdnMaxWidth As HtmlInputHidden
        Protected hdnHeight As HtmlInputHidden
        Protected hdnMinHeight As HtmlInputHidden
        Protected hdnMaxHeight As HtmlInputHidden

        Private _orientation As SplitterBarOrientations = SplitterBarOrientations.Vertical

        Private _leftResizeTargets As String = String.Empty
        ' semi-colon delimited
        Private _rightResizeTargets As String = String.Empty
        ' semi-colon delimited
        Private _topResizeTargets As String = String.Empty
        ' semi-colon delimited
        Private _bottomResizeTargets As String = String.Empty
        ' semi-colon delimited
        Private _dynamicResizing As Boolean = False
        Private _backgroundColor As String = Nothing
        Private _backgroundColorHilite As String = Nothing
        Private _backgroundColorResizing As String = Nothing
        Private _backgroundColorLimit As String = Nothing
        'private int _maxWidth = 0; // pixels, max size of LeftResizeTarget
        'private int _minWidth = 0; // pixels, min size of LeftResizeTarget
        Private _totalWidth As Integer = 0
        ' pixels, Total size of Left + Right target widths
        Private _saveWidthToElement As String = Nothing
        ' element id to save the width to (input text or hidden)
        'private int _maxHeight = 0; // pixels, max size of TopResizeTarget
        'private int _minHeight = 0; // pixels, min size of TopResizeTarget
        Private _totalHeight As Integer = 0
        ' pixels, Total size of Top + Bottom target widths
        Private _saveHeightToElement As String = Nothing
        ' element id to save the Height to (input text or hidden)
        Private _onResizeStart As String = Nothing
        ' onmousedown fires this
        Private _onResize As String = Nothing
        ' dynamic resizing and onmouseup fires this
        Private _onResizeComplete As String = Nothing
        ' onmouseup fires this
        Private _onDoubleClick As String = Nothing
        Private _splitterWidth As Integer = 6
        Private _splitterHeight As Integer = 6
        Private _debugElement As String = Nothing
        Private _iframeHiding As SplitterBarIFrameHiding = SplitterBarIFrameHiding.UseVisibility

        Public Property Orientation() As SplitterBarOrientations
            Get
                Return _orientation
            End Get
            Set(ByVal value As SplitterBarOrientations)
                _orientation = value
            End Set
        End Property

        Protected Overrides Sub OnLoad(ByVal e As EventArgs)
            Me.Page.RegisterRequiresPostBack(Me)
            AddCompositeControls()
            Me.RegisterPageStartupScript()
            Me.ResizeTargetControls()

            MyBase.OnLoad(e)
        End Sub

        Public Sub ResizeTargetControls()
            If Me.Orientation = SplitterBarOrientations.Vertical Then
                SetTargetControlWidths()
            ElseIf Me.Orientation = SplitterBarOrientations.Horizontal Then
                SetTargetControlHeights()
            End If
        End Sub

        Private Sub SetTargetControlWidths()
            If Me.Page IsNot Nothing AndAlso Me.Page.IsPostBack Then
                Dim targets As Control() = Nothing
                Dim width As String = Nothing

                ' set the width of the controls in the 
                ' LeftResizeTargets
                width = Me.LeftColumnWidth
                If Not String.IsNullOrEmpty(width) Then
                    targets = GetTargetControls(Me.LeftResizeTargets)
                    If targets IsNot Nothing AndAlso targets.Length > 0 Then
                        For Each c As Control In targets
                            SetControlWidth(c, width)
                        Next
                    End If
                End If

                ' set the width of the controls in the 
                ' RightResizeTargets
                width = Me.RightColumnWidth
                If Not String.IsNullOrEmpty(width) Then
                    targets = GetTargetControls(Me.RightResizeTargets)
                    If targets IsNot Nothing AndAlso targets.Length > 0 Then
                        For Each c As Control In targets
                            SetControlWidth(c, width)
                        Next
                    End If
                End If
            End If
        End Sub

        Private Sub SetControlWidth(ByVal control As Control, ByVal width As String)
            If control IsNot Nothing Then
                If TypeOf control Is WebControl Then
                    Dim wc As WebControl = DirectCast(control, WebControl)
                    wc.Style.Add("width", width)
                ElseIf TypeOf control Is HtmlControl Then
                    Dim hc As HtmlControl = DirectCast(control, HtmlControl)
                    hc.Style.Add("width", width)
                End If
            End If
        End Sub

        Private Sub SetTargetControlHeights()
            If Me.Page.IsPostBack Then
                Dim targets As Control() = Nothing
                Dim height As String = Nothing

                ' set the height of the controls in the 
                ' LeftResizeTargets
                height = Me.TopRowHeight
                If Not String.IsNullOrEmpty(height) Then
                    targets = GetTargetControls(Me.TopResizeTargets)
                    If targets IsNot Nothing AndAlso targets.Length > 0 Then
                        For Each c As Control In targets
                            SetControlHeight(c, height)
                        Next
                    End If
                End If

                ' set the height of the controls in the 
                ' BottomResizeTargets
                height = Me.BottomRowHeight
                If Not String.IsNullOrEmpty(height) Then
                    targets = GetTargetControls(Me.BottomResizeTargets)
                    If targets IsNot Nothing AndAlso targets.Length > 0 Then
                        For Each c As Control In targets
                            SetControlHeight(c, height)
                        Next
                    End If
                End If
            End If
        End Sub

        Private Sub SetControlHeight(ByVal control As Control, ByVal height As String)
            If control IsNot Nothing Then
                If TypeOf control Is WebControl Then
                    Dim wc As WebControl = DirectCast(control, WebControl)
                    wc.Style.Add("height", height)
                ElseIf TypeOf control Is HtmlControl Then
                    Dim hc As HtmlControl = DirectCast(control, HtmlControl)
                    hc.Style.Add("height", height)
                End If
            End If
        End Sub

        Private Function GetTargetControls(ByVal controlIds As String) As Control()
            ' warning: the controls array that this method returns
            ' may contain null values if a control is not found
            Dim controls As Control() = Nothing
            Dim ids As String() = GetTargetControlIds(controlIds)

            Dim container As Control = Me.Page
            If Me.NamingContainer IsNot Nothing AndAlso Me.NamingContainer IsNot Me.Page Then
                container = Me.NamingContainer
            End If

            If ids IsNot Nothing AndAlso ids.Length > 0 Then
                Dim i As Integer = 0
                Dim c As Control = Nothing
                Dim id As String = Nothing
                controls = New Control(ids.Length - 1) {}
                For i = 0 To ids.Length - 1
                    id = ids(i)
                    If Not String.IsNullOrEmpty(id) Then
                        c = container.FindControl(id)
                        If c IsNot Nothing Then
                            controls(i) = c
                        End If
                    End If
                Next
            End If
            Return controls
        End Function

        Private Function GetTargetControlIds(ByVal controlIds As String) As String()
            Dim ids As String() = Nothing
            If Not String.IsNullOrEmpty(controlIds) Then
                ids = controlIds.Split(";"c)
            End If
            Return ids
        End Function

        Private Sub AddCompositeControls()
            ' save the width to a hidden field so that
            ' on PostBacks the width will be available
            If Me.Orientation = SplitterBarOrientations.Vertical Then
                If Me.hdnWidth Is Nothing Then
                    Me.hdnWidth = New HtmlInputHidden()
                    Me.hdnWidth.ID = "hdnWidth"
                End If
                Me.Controls.Add(Me.hdnWidth)

                If Me.hdnMinWidth Is Nothing Then
                    Me.hdnMinWidth = New HtmlInputHidden()
                    Me.hdnMinWidth.ID = "hdnMinWidth"
                End If
                Me.Controls.Add(Me.hdnMinWidth)

                If Me.hdnMaxWidth Is Nothing Then
                    Me.hdnMaxWidth = New HtmlInputHidden()
                    Me.hdnMaxWidth.ID = "hdnMaxWidth"
                End If
                Me.Controls.Add(Me.hdnMaxWidth)
            ElseIf Me.Orientation = SplitterBarOrientations.Horizontal Then
                If Me.hdnHeight Is Nothing Then
                    Me.hdnHeight = New HtmlInputHidden()
                    Me.hdnHeight.ID = "hdnHeight"
                End If
                Me.Controls.Add(Me.hdnHeight)

                If Me.hdnMinHeight Is Nothing Then
                    Me.hdnMinHeight = New HtmlInputHidden()
                    Me.hdnMinHeight.ID = "hdnMinHeight"
                End If
                Me.Controls.Add(Me.hdnMinHeight)

                If Me.hdnMaxHeight Is Nothing Then
                    Me.hdnMaxHeight = New HtmlInputHidden()
                    Me.hdnMaxHeight.ID = "hdnMaxHeight"
                End If
                Me.Controls.Add(Me.hdnMaxHeight)
            End If
        End Sub

        Protected Overridable Function LoadPostData(ByVal postDataKey As String, ByVal postCollection As NameValueCollection) As Boolean
            AddCompositeControls()

            If Me.Orientation = SplitterBarOrientations.Vertical Then
                Me.hdnWidth.Value = postCollection(Me.hdnWidth.UniqueID)
                Me.hdnMinWidth.Value = postCollection(Me.hdnMinWidth.UniqueID)
                Me.hdnMaxWidth.Value = postCollection(Me.hdnMaxWidth.UniqueID)
            ElseIf Me.Orientation = SplitterBarOrientations.Horizontal Then
                Me.hdnHeight.Value = postCollection(Me.hdnHeight.UniqueID)


                Me.hdnMinHeight.Value = postCollection(Me.hdnMinHeight.UniqueID)


                Me.hdnMaxHeight.Value = postCollection(Me.hdnMaxHeight.UniqueID)


            End If

            Return True
        End Function

        Public Property LeftColumnWidth() As String
            Get
                AddCompositeControls()
                Return Me.hdnWidth.Value
            End Get
            Set(ByVal value As String)
                AddCompositeControls()
                Me.hdnWidth.Value = value
                Me.ResizeTargetControls()
            End Set
        End Property

        Public ReadOnly Property RightColumnWidth() As String
            Get
                Dim rcWidth As String = String.Empty
                Dim total As Integer = Me.TotalWidth
                If total <> 0 Then
                    Dim width As Integer = 0
                    If Not String.IsNullOrEmpty(Me.LeftColumnWidth) Then
                        width = Convert.ToInt32(Me.LeftColumnWidth.Replace("px", String.Empty))
                        width = total - width
                        width = If((width < 1), 1, width)
                        rcWidth = width.ToString() & "px"
                    End If
                End If
                Return rcWidth
            End Get
        End Property

        Public Property SaveWidthToElement() As String
            Get
                Return _saveWidthToElement
            End Get
            Set(ByVal value As String)
                _saveWidthToElement = value
            End Set
        End Property

        Public Property TopRowHeight() As String
            Get
                AddCompositeControls()
                'string height = "100px"; // default value
                'if(!string.IsNullOrEmpty(this.hdnHeight.Value))
                '{
                '    height = this.hdnHeight.Value;
                '}
                'else if (this.MinHeight > 0)
                '{
                '    height = this.MinHeight.ToString() + "px";
                '}
                'return height;
                Return Me.hdnHeight.Value
            End Get
            Set(ByVal value As String)
                AddCompositeControls()
                Me.hdnHeight.Value = value
                Me.ResizeTargetControls()
            End Set
        End Property

        Public ReadOnly Property BottomRowHeight() As String
            Get
                Dim rcHeight As String = String.Empty
                Dim total As Integer = Me.TotalHeight
                If total <> 0 Then
                    Dim height As Integer = 0
                    If Not String.IsNullOrEmpty(Me.TopRowHeight) Then
                        height = Convert.ToInt32(Me.TopRowHeight.Replace("px", String.Empty))
                        height = total - height
                        height = If((height < 1), 1, height)
                        rcHeight = height.ToString() & "px"
                    End If
                End If
                Return rcHeight
            End Get
        End Property

        Public Property SaveHeightToElement() As String
            Get
                Return _saveHeightToElement
            End Get
            Set(ByVal value As String)
                _saveHeightToElement = value
            End Set
        End Property

        Public Property LeftResizeTargets() As String
            Get
                Return _leftResizeTargets
            End Get
            Set(ByVal value As String)
                _leftResizeTargets = value
            End Set
        End Property

        Public Property RightResizeTargets() As String
            Get
                Return _rightResizeTargets
            End Get
            Set(ByVal value As String)
                _rightResizeTargets = value
            End Set
        End Property

        Public Property TopResizeTargets() As String
            Get
                Return _topResizeTargets
            End Get
            Set(ByVal value As String)
                _topResizeTargets = value
            End Set
        End Property

        Public Property BottomResizeTargets() As String
            Get
                Return _bottomResizeTargets
            End Get
            Set(ByVal value As String)
                _bottomResizeTargets = value
            End Set
        End Property

        Public Property DynamicResizing() As Boolean
            Get
                Return _dynamicResizing
            End Get
            Set(ByVal value As Boolean)
                _dynamicResizing = value
            End Set
        End Property

        Public Property BackgroundColor() As String
            Get
                Return _backgroundColor
            End Get
            Set(ByVal value As String)
                _backgroundColor = value
                Me.Style.Add("background-color", _backgroundColor)
            End Set
        End Property

        Public Property BackgroundColorHilite() As String
            Get
                Return _backgroundColorHilite
            End Get
            Set(ByVal value As String)
                _backgroundColorHilite = value
            End Set
        End Property

        Public Property BackgroundColorResizing() As String
            Get
                Return _backgroundColorResizing
            End Get
            Set(ByVal value As String)
                _backgroundColorResizing = value
            End Set
        End Property

        Public Property BackgroundColorLimit() As String
            Get
                Return _backgroundColorLimit
            End Get
            Set(ByVal value As String)
                _backgroundColorLimit = value
            End Set
        End Property

        Public Property OnResizeStart() As String
            Get
                Return _onResizeStart
            End Get
            Set(ByVal value As String)
                _onResizeStart = value
            End Set
        End Property

        Public Property OnResize() As String
            Get
                Return _onResize
            End Get
            Set(ByVal value As String)
                _onResize = value
            End Set
        End Property

        Public Property OnResizeComplete() As String
            Get
                Return _onResizeComplete
            End Get
            Set(ByVal value As String)
                _onResizeComplete = value
            End Set
        End Property

        Public Property OnDoubleClick() As String
            Get
                Return _onDoubleClick
            End Get
            Set(ByVal value As String)
                _onDoubleClick = value
            End Set
        End Property

        Public Property DebugElement() As String
            Get
                Return _debugElement
            End Get
            Set(ByVal value As String)
                _debugElement = value
            End Set
        End Property

        Public Property MinWidth() As Integer
            'get { return _minWidth; }
            'set { _minWidth = value; }
            Get
                AddCompositeControls()
                Return GetInt32(Me.hdnMinWidth.Value)
            End Get
            Set(ByVal value As Integer)
                AddCompositeControls()
                Me.hdnMinWidth.Value = Convert.ToString(value) & "px"
            End Set
        End Property

        Public Property MaxWidth() As Integer
            'get { return _maxWidth; }
            'set { _maxWidth = value; }
            Get
                AddCompositeControls()
                Return GetInt32(Me.hdnMaxWidth.Value)
            End Get
            Set(ByVal value As Integer)
                AddCompositeControls()
                Me.hdnMaxWidth.Value = Convert.ToString(value) & "px"
            End Set
        End Property

        Public Property TotalWidth() As Integer
            Get
                Return _totalWidth
            End Get
            Set(ByVal value As Integer)
                _totalWidth = value
            End Set
        End Property

        Public Property SplitterWidth() As Integer
            Get
                Return _splitterWidth
            End Get
            Set(ByVal value As Integer)
                _splitterWidth = value
            End Set
        End Property

        Public Property MinHeight() As Integer
            'get { return _minHeight; }
            'set { _minHeight = value; }
            Get
                AddCompositeControls()
                Return GetInt32(Me.hdnMinHeight.Value)
            End Get
            Set(ByVal value As Integer)
                AddCompositeControls()
                Me.hdnMinHeight.Value = Convert.ToString(value) & "px"
            End Set
        End Property

        Public Property MaxHeight() As Integer
            'get { return _maxHeight; }
            'set { _maxHeight = value; }
            Get
                AddCompositeControls()
                Return GetInt32(Me.hdnMaxHeight.Value)
            End Get
            Set(ByVal value As Integer)
                AddCompositeControls()
                Me.hdnMaxHeight.Value = Convert.ToString(value) & "px"
            End Set
        End Property

        Public Property TotalHeight() As Integer
            Get
                Return _totalHeight
            End Get
            Set(ByVal value As Integer)
                _totalHeight = value
            End Set
        End Property

        Public Property SplitterHeight() As Integer
            Get
                Return _splitterHeight
            End Get
            Set(ByVal value As Integer)
                _splitterHeight = value
            End Set
        End Property

        Public Function GetInt32(ByVal size As String) As Integer
            Dim intsize As Integer = 0
            If Not String.IsNullOrEmpty(size) Then
                Try
                    size = size.Replace("px", String.Empty)
                    If Not String.IsNullOrEmpty(size) Then
                        intsize = Convert.ToInt32(size)
                    End If
                Catch
                    intsize = 0
                End Try
            End If
            Return intsize
        End Function

        Public Property IFrameHiding() As SplitterBarIFrameHiding
            Get
                Return _iframeHiding
            End Get
            Set(ByVal value As SplitterBarIFrameHiding)
                _iframeHiding = value
            End Set
        End Property

        Private Sub RegisterPageStartupScript()
            Dim sb As New StringBuilder()
            Const newline As String = vbCr & vbLf

            sb.Append("<script type=""text/javascript""> <!-- ")
            sb.Append(newline)

            Dim id As String = "sbar_" & Me.ClientID

            ' createNew / constructor
            sb.Append("var ")
            sb.Append(id)
            sb.Append("= VwdCmsSplitterBar.createNew(""")
            sb.Append(Me.ClientID)
            sb.Append(""",")
            If Me.DebugElement Is Nothing Then
                sb.Append(" null);")
            Else
                sb.Append("""")
                sb.Append(Me.DebugElement)
                sb.Append(""");")
            End If
            sb.Append(newline)

            ' set the namingContainerId
            If Me.NamingContainer IsNot Nothing AndAlso Me.NamingContainer IsNot Me.Page Then
                Dim prefix As String = Me.NamingContainer.ClientID & Me.ClientIDSeparator.ToString()

                sb.Append(id)
                sb.Append(".namingContainerId = """)
                sb.Append(prefix)
                sb.Append(""";")
                sb.Append(newline)
            End If

            ' set the orientation
            sb.Append(id)
            sb.Append(".orientation = """)
            sb.Append(Me.Orientation.ToString().ToLower())
            sb.Append(""";")
            sb.Append(newline)

            ' set the debugElementId
            If Not String.IsNullOrEmpty(Me.DebugElement) Then
                sb.Append(id)
                sb.Append(".debugElementId = """)
                sb.Append(Me.DebugElement)
                sb.Append(""";")
                sb.Append(newline)
            End If

            If Me.Orientation = SplitterBarOrientations.Vertical Then
                ' set the left resize target Ids
                sb.Append(id)
                sb.Append(".leftResizeTargetIds = """)
                sb.Append(Me.LeftResizeTargets)
                sb.Append(""";")
                sb.Append(newline)

                ' set the right resize target Ids
                sb.Append(id)
                sb.Append(".rightResizeTargetIds = """)
                sb.Append(Me.RightResizeTargets)
                sb.Append(""";")
                sb.Append(newline)

                If Me.SplitterWidth <> 6 Then
                    sb.Append(id)
                    sb.Append(".splitterWidth = new Number(")
                    sb.Append(Me.SplitterWidth.ToString())
                    sb.Append(");")
                    sb.Append(newline)
                End If

                If Not String.IsNullOrEmpty(Me.SaveWidthToElement) Then
                    sb.Append(id)
                    sb.Append(".saveWidthToElement = """)
                    sb.Append(Me.SaveWidthToElement)
                    sb.Append(""";")
                    sb.Append(newline)
                End If

                If Me.MinWidth > 0 Then
                    sb.Append(id)
                    sb.Append(".minWidth = ")
                    sb.Append(Me.MinWidth.ToString())
                    sb.Append(";")
                    sb.Append(newline)
                End If

                If Me.MaxWidth > 0 Then
                    sb.Append(id)
                    sb.Append(".maxWidth = ")
                    sb.Append(Me.MaxWidth.ToString())
                    sb.Append(";")
                    sb.Append(newline)
                End If

                If Me.TotalWidth > 0 Then
                    sb.Append(id)
                    sb.Append(".totalWidth = ")
                    sb.Append(Me.TotalWidth.ToString())
                    sb.Append(";")
                    sb.Append(newline)
                End If
            ElseIf Me.Orientation = SplitterBarOrientations.Horizontal Then
                ' set the top resize target Ids
                sb.Append(id)
                sb.Append(".topResizeTargetIds = """)
                sb.Append(Me.TopResizeTargets)
                sb.Append(""";")
                sb.Append(newline)

                ' set the bottom resize target Ids
                sb.Append(id)
                sb.Append(".bottomResizeTargetIds = """)
                sb.Append(Me.BottomResizeTargets)
                sb.Append(""";")
                sb.Append(newline)

                If Me.SplitterHeight <> 6 Then
                    sb.Append(id)
                    sb.Append(".splitterHeight = new Number(")
                    sb.Append(Me.SplitterHeight.ToString())
                    sb.Append(");")
                    sb.Append(newline)
                End If

                If Not String.IsNullOrEmpty(Me.SaveHeightToElement) Then
                    sb.Append(id)
                    sb.Append(".saveHeightToElement = """)
                    sb.Append(Me.SaveHeightToElement)
                    sb.Append(""";")
                    sb.Append(newline)
                End If

                If Me.MinHeight > 0 Then
                    sb.Append(id)
                    sb.Append(".minHeight = ")
                    sb.Append(Me.MinHeight.ToString())
                    sb.Append(";")
                    sb.Append(newline)
                End If

                If Me.MaxHeight > 0 Then
                    sb.Append(id)
                    sb.Append(".maxHeight = ")
                    sb.Append(Me.MaxHeight.ToString())
                    sb.Append(";")
                    sb.Append(newline)
                End If

                If Me.TotalHeight > 0 Then
                    sb.Append(id)
                    sb.Append(".totalHeight = ")
                    sb.Append(Me.TotalHeight.ToString())
                    sb.Append(";")
                    sb.Append(newline)
                End If
            End If

            ' IFrameHiding
            sb.Append(id)
            sb.Append(".iframeHiding = """)
            sb.Append(Me.IFrameHiding.ToString())
            sb.Append(""";")
            sb.Append(newline)


            If Not String.IsNullOrEmpty(Me.OnResizeStart) Then
                sb.Append(id)
                sb.Append(".onResizeStart = ")
                sb.Append(Me.OnResizeStart)
                sb.Append(";")
                sb.Append(newline)
            End If

            If Not String.IsNullOrEmpty(Me.OnResize) Then
                sb.Append(id)
                sb.Append(".onResize = ")
                sb.Append(Me.OnResize)
                sb.Append(";")
                sb.Append(newline)
            End If

            If Not String.IsNullOrEmpty(Me.OnResizeComplete) Then
                sb.Append(id)
                sb.Append(".onResizeComplete = ")
                sb.Append(Me.OnResizeComplete)
                sb.Append(";")
                sb.Append(newline)
            End If

            If Not String.IsNullOrEmpty(Me.OnDoubleClick) Then
                sb.Append(id)
                sb.Append(".OnDoubleClick = ")
                sb.Append(Me.OnDoubleClick)
                sb.Append(";")
                sb.Append(newline)
            End If

            If Me.DynamicResizing Then
                sb.Append(id)
                sb.Append(".liveResize = true;")
                sb.Append(newline)
            End If
            If Not String.IsNullOrEmpty(Me.BackgroundColor) Then
                sb.Append(id)
                sb.Append(".SetBackgroundColor(""")
                sb.Append(Me.BackgroundColor)
                sb.Append(""");")
                sb.Append(newline)
            End If

            If Not String.IsNullOrEmpty(Me.BackgroundColorHilite) Then
                sb.Append(id)
                sb.Append(".backgroundColorHilite = """)
                sb.Append(Me.BackgroundColorHilite)
                sb.Append(""";")
                sb.Append(newline)
            End If
            If Not String.IsNullOrEmpty(Me.BackgroundColorResizing) Then

                sb.Append(id)
                sb.Append(".backgroundColorResizing = """)
                sb.Append(Me.BackgroundColorResizing)
                sb.Append(""";")
                sb.Append(newline)
            End If
            If Not String.IsNullOrEmpty(Me.BackgroundColorLimit) Then

                sb.Append(id)
                sb.Append(".backgroundColorLimit = """)
                sb.Append(Me.BackgroundColorLimit)
                sb.Append(""";")
                sb.Append(newline)
            End If


            ' do this last...
            ' be sure to call configure after all of the 
            ' configuration properties have been set
            sb.Append(id)
            sb.Append(".configure();")
            sb.Append(newline)

            sb.Append("// -->")
            sb.Append(newline)
            sb.Append("</script>")
            sb.Append(newline)

            Me.Page.ClientScript.RegisterStartupScript(Me.[GetType](), Me.ClientID & "_VwdCmsSplitterBarStartupScript", sb.ToString())
        End Sub

        ' IPostBackDataHandler Members

        Private Function IPostBackDataHandler_LoadPostData(ByVal postDataKey As String, ByVal postCollection As NameValueCollection) As Boolean Implements IPostBackDataHandler.LoadPostData
            Return Me.LoadPostData(postDataKey, postCollection)
        End Function

        Private Sub IPostBackDataHandler_RaisePostDataChangedEvent() Implements IPostBackDataHandler.RaisePostDataChangedEvent
            'not implemented
        End Sub
    End Class
End Namespace
