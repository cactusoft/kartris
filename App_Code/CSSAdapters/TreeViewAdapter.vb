Imports System
Imports System.Collections.Specialized
Imports System.Configuration
Imports System.Data
Imports System.Web
Imports System.Web.Configuration
Imports System.Web.Security
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI.WebControls.WebParts
Imports System.Web.UI.HtmlControls
Imports System.Reflection


Namespace Kartris
    Public Class TreeViewAdapter
        Inherits System.Web.UI.WebControls.Adapters.HierarchicalDataBoundControlAdapter
        Implements IPostBackEventHandler, IPostBackDataHandler

        Private _extender As WebControlAdapterExtender = Nothing
        Private _checkboxIndex As Integer = 1
        Private _viewState As HiddenField = Nothing
        Private _updateViewState As Boolean = False
        Private _newViewState As String = ""

        Public Sub New()
            MyBase.New()
            If (_viewState Is Nothing) Then
                _viewState = New HiddenField
            End If
        End Sub

        Protected This As WebControlAdapterExtender = Nothing
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

        ' Implementation of IPostBackDataHandler
        Public Overridable Function LoadPostData(ByVal postDataKey As String, ByVal postCollection As NameValueCollection) As Boolean _
            Implements IPostBackDataHandler.LoadPostData
            Return True
        End Function

        Public Overridable Sub RaisePostDataChangedEvent() _
            Implements IPostBackDataHandler.RaisePostDataChangedEvent
            Dim treeView As TreeView = CType(Control, TreeView)
            If (Not (treeView) Is Nothing) Then
                Dim items As TreeNodeCollection = treeView.Nodes
                _checkboxIndex = 1
                UpdateCheckmarks(items)
            End If
        End Sub

        ' Implementation of IPostBackEventHandler
        Public Sub RaisePostBackEvent(ByVal eventArgument As String) _
            Implements IPostBackEventHandler.RaisePostBackEvent
            Dim treeView As TreeView = CType(Control, TreeView)
            If (Not (treeView) Is Nothing) Then
                Dim items As TreeNodeCollection = treeView.Nodes
                If (Not (eventArgument) Is Nothing) Then
                    If (eventArgument.StartsWith("s") OrElse eventArgument.StartsWith("e")) Then
                        Dim selectedNodeValuePath As String = eventArgument.Substring(1).Replace("\", "/")
                        Dim selectedNode As TreeNode = treeView.FindNode(selectedNodeValuePath)
                        If (Not (selectedNode) Is Nothing) Then
                            Dim bSelectedNodeChanged As Boolean = Not selectedNode.Equals(treeView.SelectedNode)
                            ClearSelectedNode(items)
                            selectedNode.Selected = True
                            ' does not raise the SelectedNodeChanged event so we have to do it manually (below).
                            If eventArgument.StartsWith("e") Then
                                selectedNode.Expand()
                            End If
                            If bSelectedNodeChanged Then
                                Extender.RaiseAdaptedEvent("SelectedNodeChanged", New EventArgs)
                            End If
                        End If
                    ElseIf eventArgument.StartsWith("p") Then
                        Dim parentNodeValuePath As String = eventArgument.Substring(1).Replace("\", "/")
                        Dim parentNode As TreeNode = treeView.FindNode(parentNodeValuePath)
                        If ((Not parentNode Is Nothing) AndAlso _
                            ((parentNode.ChildNodes Is Nothing) OrElse (parentNode.ChildNodes.Count = 0))) Then
                            parentNode.Expand()
                            ' Raises the TreeNodePopulate event
                        End If
                    End If
                End If
            End If
        End Sub

        Protected Overrides Function SaveAdapterViewState() As Object
            Dim retStr As String = ""
            Dim treeView As TreeView = CType(Control, TreeView)
            If ((Not (treeView) Is Nothing) AndAlso (Not (_viewState) Is Nothing)) Then
                If ((Not (_viewState) Is Nothing) AndAlso _
                    (Not (Page) Is Nothing) AndAlso _
                    (Not (Page.Form) Is Nothing) AndAlso _
                    (Not Page.Form.Controls.Contains(_viewState))) Then

                    Dim panel As Panel = New Panel()
                    panel.Controls.Add(_viewState)
                    Page.Form.Controls.Add(panel)
                    Dim script As String = ("document.getElementById('" _
                                + (_viewState.ClientID + ("').value = GetViewState__KartrisTreeView('" _
                                + (Extender.MakeChildId("UL") + "');"))))
                    Page.ClientScript.RegisterOnSubmitStatement(Me.GetType(), _viewState.ClientID, script)
                End If
                retStr = (_viewState.UniqueID + ("|" + ComposeViewState(treeView.Nodes, "")))
            End If
            Return retStr
        End Function

        Protected Overrides Sub LoadAdapterViewState(ByVal state As Object)
            Dim treeView As TreeView = CType(Control, TreeView)
            Dim oldViewState As String = CType(state, String)
            If ((Not (treeView) Is Nothing) AndAlso _
                (Not (oldViewState) Is Nothing) AndAlso _
                (oldViewState.Split(Microsoft.VisualBasic.ChrW(124)).Length = 2)) Then
                Dim hiddenInputName As String = oldViewState.Split(Microsoft.VisualBasic.ChrW(124))(0)
                Dim oldExpansionState As String = oldViewState.Split(Microsoft.VisualBasic.ChrW(124))(1)
                If (Not treeView.ShowExpandCollapse) Then
                    _newViewState = oldExpansionState
                    _updateViewState = True
                ElseIf (Not (Page.Request.Form(hiddenInputName)) Is Nothing) Then
                    _newViewState = Page.Request.Form(hiddenInputName)
                    _updateViewState = True
                End If
            End If
        End Sub

        Protected Overrides Sub OnInit(ByVal e As EventArgs)
            If Extender.AdapterEnabled Then
                _updateViewState = False
                _newViewState = ""
                Dim treeView As TreeView = CType(Control, TreeView)
                If (Not (treeView) Is Nothing) Then
                    treeView.EnableClientScript = False
                End If
            End If
            MyBase.OnInit(e)
            If Extender.AdapterEnabled Then
                RegisterScripts()
            End If
        End Sub

        Protected Overrides Sub OnLoad(ByVal e As EventArgs)
            MyBase.OnLoad(e)
            Dim treeView As TreeView = CType(Control, TreeView)
            If (Extender.AdapterEnabled AndAlso _updateViewState AndAlso (Not (treeView) Is Nothing)) Then
                treeView.CollapseAll()
                ExpandToState(treeView.Nodes, _newViewState)
                _updateViewState = False
            End If
        End Sub

        Private Sub RegisterScripts()
            Extender.RegisterScripts()

            Dim folderPath As String = WebConfigurationManager.AppSettings.Get("Kartris-JavaScript-Path")
            If (String.IsNullOrEmpty(folderPath)) Then
                folderPath = "~/JavaScript"
            End If

            Dim filePath As String = IIf(folderPath.EndsWith("/"), folderPath & "TreeViewAdapter.js", folderPath & "/TreeViewAdapter.js")
            Page.ClientScript.RegisterClientScriptInclude(Me.GetType(), Me.GetType().ToString(), Page.ResolveUrl(filePath))
        End Sub

        Protected Overrides Sub RenderBeginTag(ByVal writer As HtmlTextWriter)
            If Extender.AdapterEnabled Then
                Extender.RenderBeginTag(writer, "Kartris-TreeView")
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
                Dim treeView As TreeView = CType(Control, TreeView)
                If (Not (treeView) Is Nothing) Then
                    writer.Indent = (writer.Indent + 1)
                    _checkboxIndex = 1
                    BuildItems(treeView.Nodes, True, True, writer)
                    writer.Indent = (writer.Indent - 1)
                    writer.WriteLine()
                End If
            Else
                MyBase.RenderContents(writer)
            End If
        End Sub

        Private Sub BuildItems(ByVal items As TreeNodeCollection, ByVal isRoot As Boolean, ByVal isExpanded As Boolean, ByVal writer As HtmlTextWriter)
            If (items.Count > 0) Then
                writer.WriteLine()
                writer.WriteBeginTag("ul")
                If isRoot Then
                    writer.WriteAttribute("id", Extender.MakeChildId("UL"))
                End If
                If Not isExpanded Then
                    writer.WriteAttribute("class", "Kartris-TreeView-Hide")
                End If
                writer.Write(HtmlTextWriter.TagRightChar)
                writer.Indent = (writer.Indent + 1)
                For Each item As TreeNode In items
                    BuildItem(item, writer)
                Next
                writer.Indent = (writer.Indent - 1)
                writer.WriteLine()
                writer.WriteEndTag("ul")
            End If
        End Sub

        Private Sub BuildItem(ByVal item As TreeNode, ByVal writer As HtmlTextWriter)
            Dim treeView As TreeView = CType(Control, TreeView)
            If ((Not (treeView) Is Nothing) AndAlso (Not (item) Is Nothing) AndAlso (Not (writer) Is Nothing)) Then
                writer.WriteLine()
                writer.WriteBeginTag("li")
                writer.WriteAttribute("class", GetNodeClass(item))
                writer.Write(HtmlTextWriter.TagRightChar)
                writer.Indent = (writer.Indent + 1)
                writer.WriteLine()
                If (IsExpandable(item) AndAlso treeView.ShowExpandCollapse) Then
                    WriteNodeExpander(treeView, item, writer)
                End If
                If IsCheckbox(treeView, item) Then
                    WriteNodeCheckbox(treeView, item, writer)
                ElseIf IsLink(item) Then
                    WriteNodeLink(treeView, item, writer)
                Else
                    WriteNodePlain(treeView, item, writer)
                End If
                If HasChildren(item) Then
                    BuildItems(item.ChildNodes, False, item.Expanded.Equals(True), writer)
                End If
                writer.Indent = (writer.Indent - 1)
                writer.WriteLine()
                writer.WriteEndTag("li")
            End If
        End Sub

        Private Sub WriteNodeExpander(ByVal treeView As TreeView, ByVal item As TreeNode, ByVal writer As HtmlTextWriter)
            writer.WriteBeginTag("span")
            writer.WriteAttribute("class", IIf(item.Expanded.Equals(True), "Kartris-TreeView-Collapse", "Kartris-TreeView-Expand"))
            If HasChildren(item) Then
                writer.WriteAttribute("onclick", "ExpandCollapse__KartrisTreeView(this)")
            Else
                writer.WriteAttribute("onclick", Page.ClientScript.GetPostBackEventReference(treeView, ("p" + Page.Server.HtmlEncode(item.ValuePath).Replace("/", "\")), True))
            End If
            writer.Write(HtmlTextWriter.TagRightChar)
            writer.Write("&nbsp;")
            writer.WriteEndTag("span")
            writer.WriteLine()
        End Sub

        Private Sub WriteNodeImage(ByVal treeView As TreeView, ByVal item As TreeNode, ByVal writer As HtmlTextWriter)
            Dim imgSrc As String = GetImageSrc(treeView, item)
            If (Not String.IsNullOrEmpty(imgSrc)) Then
                writer.WriteBeginTag("img")
                writer.WriteAttribute("src", treeView.ResolveClientUrl(imgSrc))
                writer.WriteAttribute("alt", IIf(Not String.IsNullOrEmpty(item.ToolTip), item.ToolTip, IIf(Not String.IsNullOrEmpty(treeView.ToolTip), treeView.ToolTip, item.Text)))
                writer.Write(HtmlTextWriter.SelfClosingTagEnd)
            End If
        End Sub

        Private Sub WriteNodeCheckbox(ByVal treeView As TreeView, ByVal item As TreeNode, ByVal writer As HtmlTextWriter)
            writer.WriteBeginTag("input")
            writer.WriteAttribute("type", "checkbox")
            writer.WriteAttribute("id", (treeView.ClientID + ("n" _
                            + (_checkboxIndex.ToString + "CheckBox"))))
            writer.WriteAttribute("name", (treeView.UniqueID + ("n" _
                            + (_checkboxIndex.ToString + "CheckBox"))))
            If (Not String.IsNullOrEmpty(treeView.Attributes("OnClientClickedCheckbox"))) Then
                writer.WriteAttribute("onclick", treeView.Attributes("OnClientClickedCheckbox"))
            End If
            If item.Checked Then
                writer.WriteAttribute("checked", "checked")
            End If
            writer.Write(HtmlTextWriter.SelfClosingTagEnd)
            If (Not String.IsNullOrEmpty(item.Text)) Then
                writer.WriteLine()
                writer.WriteBeginTag("label")
                writer.WriteAttribute("for", (treeView.ClientID + ("n" _
                                + (_checkboxIndex.ToString + "CheckBox"))))
                writer.Write(HtmlTextWriter.TagRightChar)
                writer.Write(item.Text)
                writer.WriteEndTag("label")
            End If
            _checkboxIndex = (_checkboxIndex + 1)
        End Sub

        Private Sub WriteNodeLink(ByVal treeView As TreeView, ByVal item As TreeNode, ByVal writer As HtmlTextWriter)
            writer.WriteBeginTag("a")
            If (Not String.IsNullOrEmpty(item.NavigateUrl)) Then
                writer.WriteAttribute("href", Extender.ResolveUrl(item.NavigateUrl))
            Else
                Dim codePrefix As String = ""
                If (item.SelectAction = TreeNodeSelectAction.Select) Then
                    codePrefix = "s"
                ElseIf (item.SelectAction = TreeNodeSelectAction.SelectExpand) Then
                    codePrefix = "e"
                ElseIf item.PopulateOnDemand Then
                    codePrefix = "p"
                End If
                writer.WriteAttribute("href", Page.ClientScript.GetPostBackClientHyperlink(treeView, (codePrefix + Page.Server.HtmlEncode(item.ValuePath).Replace("/", "\")), True))
            End If
            WebControlAdapterExtender.WriteTargetAttribute(writer, item.Target)
            If (Not String.IsNullOrEmpty(item.ToolTip)) Then
                writer.WriteAttribute("title", item.ToolTip)
            ElseIf (Not String.IsNullOrEmpty(treeView.ToolTip)) Then
                writer.WriteAttribute("title", treeView.ToolTip)
            End If
            writer.Write(HtmlTextWriter.TagRightChar)
            writer.Indent = (writer.Indent + 1)
            writer.WriteLine()
            WriteNodeImage(treeView, item, writer)
            writer.Write(item.Text)
            writer.Indent = (writer.Indent - 1)
            writer.WriteEndTag("a")
        End Sub

        Private Sub WriteNodePlain(ByVal treeView As TreeView, ByVal item As TreeNode, ByVal writer As HtmlTextWriter)
            writer.WriteBeginTag("span")
            If IsExpandable(item) Then
                writer.WriteAttribute("class", "Kartris-TreeView-ClickableNonLink")
                If (treeView.ShowExpandCollapse) Then
                    writer.WriteAttribute("onclick", "ExpandCollapse__KartrisTreeView(this.parentNode.getElementsByTagName('span')[0])")
                End If
            Else
                writer.WriteAttribute("class", "Kartris-TreeView-NonLink")
            End If
            writer.Write(HtmlTextWriter.TagRightChar)
            writer.Indent = (writer.Indent + 1)
            writer.WriteLine()
            WriteNodeImage(treeView, item, writer)
            writer.Write(item.Text)
            writer.Indent = (writer.Indent - 1)
            writer.WriteEndTag("span")
        End Sub

        Private Sub UpdateCheckmarks(ByVal items As TreeNodeCollection)
            Dim treeView As TreeView = CType(Control, TreeView)
            If ((Not (treeView) Is Nothing) AndAlso (Not (items) Is Nothing)) Then
                For Each item As TreeNode In items
                    If IsCheckbox(treeView, item) Then
                        Dim name As String = (treeView.UniqueID + ("n" _
                                    + (_checkboxIndex.ToString + "CheckBox")))
                        Dim bIsNowChecked As Boolean = (Not (Page.Request.Form(name)) Is Nothing)
                        If (item.Checked <> bIsNowChecked) Then
                            item.Checked = bIsNowChecked
                            Extender.RaiseAdaptedEvent("TreeNodeCheckChanged", New TreeNodeEventArgs(item))
                        End If
                        _checkboxIndex = (_checkboxIndex + 1)
                    End If
                    If HasChildren(item) Then
                        UpdateCheckmarks(item.ChildNodes)
                    End If
                Next
            End If
        End Sub

        Private Function IsLink(ByVal item As TreeNode) As Boolean
            Return ((Not (item) Is Nothing) AndAlso _
                    ((Not String.IsNullOrEmpty(item.NavigateUrl)) OrElse _
                     (item.PopulateOnDemand) OrElse _
                     (item.SelectAction = TreeNodeSelectAction.Select) OrElse _
                     (item.SelectAction = TreeNodeSelectAction.SelectExpand)))
        End Function

        Private Function IsCheckbox(ByVal treeView As TreeView, ByVal item As TreeNode) As Boolean
            Dim bItemCheckBoxDisallowed As Boolean = ((Not IsNothing(item.ShowCheckBox)) AndAlso (item.ShowCheckBox.Value = False))
            Dim bItemCheckBoxWanted As Boolean = ((Not IsNothing(item.ShowCheckBox)) AndAlso (item.ShowCheckBox.Value = True))
            Dim bTreeCheckBoxWanted As Boolean = _
               (treeView.ShowCheckBoxes = TreeNodeTypes.All) OrElse _
                (((treeView.ShowCheckBoxes = TreeNodeTypes.Leaf) AndAlso Not IsExpandable(item)) OrElse _
                 ((treeView.ShowCheckBoxes = TreeNodeTypes.Parent) AndAlso IsExpandable(item)) OrElse _
                 ((treeView.ShowCheckBoxes = TreeNodeTypes.Root) AndAlso (item.Depth = 0)))
            Return (Not bItemCheckBoxDisallowed AndAlso (bItemCheckBoxWanted OrElse bTreeCheckBoxWanted))
        End Function

        Private Function GetNodeClass(ByVal item As TreeNode) As String
            Dim value As String = "Kartris-TreeView-Leaf"
            If (Not (item) Is Nothing) Then
                If (item.Depth = 0) Then
                    If IsExpandable(item) Then
                        value = "Kartris-TreeView-Root"
                    Else
                        value = "Kartris-TreeView-Root Kartris-TreeView-Leaf"
                    End If
                ElseIf IsExpandable(item) Then
                    value = "Kartris-TreeView-Parent"
                End If
                If item.Selected Then
                    value = (value + " Kartris-TreeView-Selected")
                ElseIf IsChildNodeSelected(item) Then
                    value = (value + " Kartris-TreeView-ChildSelected")
                ElseIf IsParentNodeSelected(item) Then
                    value = (value + " Kartris-TreeView-ParentSelected")
                End If
            End If
            Return value
        End Function

        Private Function GetImageSrc(ByVal treeView As TreeView, ByVal item As TreeNode) As String
            Dim imgSrc As String = ""
            If ((Not (treeView) Is Nothing) AndAlso (Not (item) Is Nothing)) Then
                imgSrc = item.ImageUrl
                If (String.IsNullOrEmpty(imgSrc)) Then
                    If (item.Depth = 0) Then
                        If ((Not (treeView.RootNodeStyle) Is Nothing) AndAlso (Not String.IsNullOrEmpty(treeView.RootNodeStyle.ImageUrl))) Then
                            imgSrc = treeView.RootNodeStyle.ImageUrl
                        End If
                    ElseIf Not IsExpandable(item) Then
                        If ((Not (treeView.LeafNodeStyle) Is Nothing) AndAlso (Not String.IsNullOrEmpty(treeView.LeafNodeStyle.ImageUrl))) Then
                            imgSrc = treeView.LeafNodeStyle.ImageUrl
                        End If
                    ElseIf ((Not (treeView.ParentNodeStyle) Is Nothing) AndAlso (Not String.IsNullOrEmpty(treeView.ParentNodeStyle.ImageUrl))) Then
                        imgSrc = treeView.ParentNodeStyle.ImageUrl
                    End If
                End If
                If ((String.IsNullOrEmpty(imgSrc)) AndAlso (Not (treeView.LevelStyles) Is Nothing) AndAlso (treeView.LevelStyles.Count > item.Depth)) Then
                    If (Not String.IsNullOrEmpty(treeView.LevelStyles(item.Depth).ImageUrl)) Then
                        imgSrc = treeView.LevelStyles(item.Depth).ImageUrl
                    End If
                End If
            End If
            Return imgSrc
        End Function

        Private Function HasChildren(ByVal item As TreeNode) As Boolean
            Return ((Not (item) Is Nothing) AndAlso (Not (item.ChildNodes) Is Nothing) AndAlso (item.ChildNodes.Count > 0))
        End Function

        Private Function IsExpandable(ByVal item As TreeNode) As Boolean
            Return (HasChildren(item) OrElse ((Not (item) Is Nothing) AndAlso item.PopulateOnDemand))
        End Function

        Private Sub ClearSelectedNode(ByVal nodes As TreeNodeCollection)
            If (Not (nodes) Is Nothing) Then
                For Each node As TreeNode In nodes
                    If node.Selected Then
                        node.Selected = False
                    End If
                    If (Not (node.ChildNodes) Is Nothing) Then
                        ClearSelectedNode(node.ChildNodes)
                    End If
                Next
            End If
        End Sub

        Private Overloads Function IsChildNodeSelected(ByVal item As TreeNode) As Boolean
            Dim bRet As Boolean = False
            If ((Not (item) Is Nothing) AndAlso (Not (item.ChildNodes) Is Nothing)) Then
                bRet = IsChildNodeSelected(item.ChildNodes)
            End If
            Return bRet
        End Function

        Private Overloads Function IsChildNodeSelected(ByVal nodes As TreeNodeCollection) As Boolean
            Dim bRet As Boolean = False
            If (Not (nodes) Is Nothing) Then
                For Each node As TreeNode In nodes
                    If (node.Selected OrElse IsChildNodeSelected(node.ChildNodes)) Then
                        bRet = True
                        Exit For
                    End If
                Next
            End If
            Return bRet
        End Function

        Private Function IsParentNodeSelected(ByVal item As TreeNode) As Boolean
            Dim bRet As Boolean = False
            If ((Not (item) Is Nothing) AndAlso (Not (item.Parent) Is Nothing)) Then
                If item.Parent.Selected Then
                    bRet = True
                Else
                    bRet = IsParentNodeSelected(item.Parent)
                End If
            End If
            Return bRet
        End Function

        Private Function ComposeViewState(ByVal nodes As TreeNodeCollection, ByVal state As String) As String
            If (Not (nodes) Is Nothing) Then
                For Each node As TreeNode In nodes
                    If (IsExpandable(node)) Then
                        If node.Expanded.Equals(True) Then
                            state &= "e"
                            state = ComposeViewState(node.ChildNodes, state)
                        Else
                            state &= "n"
                        End If
                    End If
                Next
            End If
            Return state
        End Function

        Private Function ExpandToState(ByVal nodes As TreeNodeCollection, ByVal state As String) As String
            If ((Not (nodes) Is Nothing) AndAlso (Not String.IsNullOrEmpty(state))) Then
                For Each node As TreeNode In nodes
                    If IsExpandable(node) Then
                        Dim bExpand As Boolean = (state(0) = Microsoft.VisualBasic.ChrW(101))
                        state = state.Substring(1)
                        If bExpand Then
                            node.Expand()
                            state = ExpandToState(node.ChildNodes, state)
                        End If
                    End If
                Next
            End If
            Return state
        End Function

        Public Shared Sub ExpandToDepth(ByVal nodes As TreeNodeCollection, ByVal expandDepth As Integer)
            If (Not (nodes) Is Nothing) Then
                For Each node As TreeNode In nodes
                    If (node.Depth < expandDepth) Then
                        node.Expand()
                        ExpandToDepth(node.ChildNodes, expandDepth)
                    End If
                Next
            End If
        End Sub
    End Class
End Namespace
