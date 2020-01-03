'========================================================================
'Kartris - www.kartris.com
'Copyright 2020 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisDataManipulation

Partial Class _CategoryMenu

    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()

    ''' <summary>
    ''' Page load
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            LoadCategoryMenu()
        Else
            '
        End If
    End Sub

    ''' <summary>
    ''' Loads the category menu and selects the current page 
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub LoadCategoryMenu()
        BuildTopLevelMenu()
        BuildDefaultLevels()
        SelectCurrentPage()
    End Sub

    ''' <summary>
    ''' Refresh and clears caches when button clicked
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub btnRefresh_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnRefresh.Click

        'Refresh caches
        CkartrisBLL.RefreshKartrisCache()

        'Rebuild the treeview
        Dim _CatSiteMap As _CategorySiteMapProvider = DirectCast(SiteMap.Providers("_CategorySiteMapProvider"), _CategorySiteMapProvider)
        _CatSiteMap.ResetSiteMap()
        Dim CatSiteMap As CategorySiteMapProvider = DirectCast(SiteMap.Provider, CategorySiteMapProvider)
        CatSiteMap.RefreshSiteMap()
        BuildTopLevelMenu()
        SelectCurrentPage()
        RaiseEvent ShowMasterUpdate()
        updMenu.Update()
    End Sub

    ''' <summary>
    ''' Build top level cats of treeview
    ''' </summary>
    ''' <remarks>
    ''' New sproc for Kartris v3, now includes subsites
    ''' </remarks>
    Sub BuildTopLevelMenu()
        Dim tblChilds As DataTable = CategoriesBLL._Treeview(Session("_LANG"))
        Dim childNode As TreeNode = Nothing
        For Each drwChilds As DataRow In tblChilds.Rows
            childNode = New TreeNode(drwChilds("CAT_Name"), drwChilds("CAT_ID") & "|" & drwChilds("SUB_ID"))
            childNode.NavigateUrl = _CategorySiteMapProvider.CreateURL(_CategorySiteMapProvider.BackEndPage.Category, drwChilds("CAT_ID"), drwChilds("SUB_ID"))
            childNode.PopulateOnDemand = True
            If (drwChilds("SUB_ID")) > 0 Then 'It is a sub site
                childNode.ImageUrl = "~/Skins/Admin/Images/site-tree.gif"
                childNode.ToolTip = drwChilds("SUB_Name")
                'childNode.NavigateUrl &= "&SiteID=" & drwChilds("SUB_ID")
            ElseIf CBool(drwChilds("CAT_Live")) Then
                childNode.ImageUrl = "~/Skins/Admin/Images/category-tree.gif"
            Else
                childNode.ImageUrl = "~/Skins/Admin/Images/offline-category-tree.gif"
            End If
            tvwCategory.Nodes.Add(childNode)
        Next
    End Sub

    ''' <summary>
    ''' Builds sub levels if required, depending on back end levels setting
    ''' </summary>
    ''' <remarks></remarks>
    Sub BuildDefaultLevels()
        Dim numLevels As Integer = CInt(KartSettingsManager.GetKartConfig("backend.categorymenu.levels")) - 1
        If numLevels = 0 Then Return
        For Each node As TreeNode In tvwCategory.Nodes
            BuildLevelsRecursive(numLevels, node)
        Next
    End Sub

    ''' <summary>
    ''' Recursive build levels
    ''' </summary>
    ''' <remarks></remarks>
    Sub BuildLevelsRecursive(ByVal numLevels As Integer, ByVal node As TreeNode)
        If numLevels = 0 Then Return
        node.Expand()

        For Each childNode As TreeNode In node.ChildNodes
            BuildLevelsRecursive(numLevels - 1, childNode)
        Next
    End Sub

    ''' <summary>
    ''' Build child nodes
    ''' </summary>
    ''' <remarks></remarks>
    Sub BuildChildNodes(ByRef node As TreeNode, ByVal numParentID As Integer, ByVal numSiteID As Integer, Optional ByVal chrParentType As Char = "c")
        If chrParentType = "c" Then
            Dim tblChilds As DataTable = CategoriesBLL._GetCategoriesPageByParentID(numParentID, Session("_LANG"), 0, 2000, 0)
            Dim childNode As TreeNode = Nothing
            For Each drwChilds As DataRow In tblChilds.Rows
                childNode = New TreeNode(drwChilds("CAT_Name"), drwChilds("CAT_ID") & "|" & numSiteID)

                Dim strParents As String = node.ValuePath.Replace("/", ",")

                'Clean up so we just have cat IDs comma-separated, not the site IDs
                If strParents.Contains("|") Then
                    strParents = CleanParentsString(strParents)
                End If

                Try
                    Dim aryParentKey As String() = Split(strParents, "::")
                    'parentkey = parentkey.Replace(numSiteID & "::", "")
                    strParents = aryParentKey(1)
                Catch ex As Exception
                    'erm, oh... this is embarrassing
                End Try

                childNode.NavigateUrl = _CategorySiteMapProvider.CreateURL(
                    _CategorySiteMapProvider.BackEndPage.Category, drwChilds("CAT_ID"), GetIDFromNodeValue(node.Value, True),
                    numSiteID & "::" & strParents)

                If childNode.ChildNodes.Count = 0 Then childNode.PopulateOnDemand = True
                If CBool(drwChilds("CAT_Live")) Then
                    childNode.ImageUrl = "~/Skins/Admin/Images/category-tree.gif"
                Else
                    childNode.ImageUrl = "~/Skins/Admin/Images/offline-category-tree.gif"
                End If
                node.ChildNodes.Add(childNode)
            Next
        ElseIf chrParentType = "p" Then
            Dim tblChilds As DataTable = ProductsBLL._GetProductsPageByCategory(numParentID, Session("_LANG"), 0, 2000, 0)
            Dim childNode As TreeNode = Nothing
            For Each drwChilds As DataRow In tblChilds.Rows
                childNode = New TreeNode(drwChilds("P_Name"), drwChilds("P_ID") & "|" & numSiteID)
                Dim strParents As String = node.ValuePath.Replace("/", ",")

                'Clean up so we just have cat IDs comma-separated, not the site IDs
                If strParents.Contains("|") Then
                    strParents = CleanParentsString(strParents)
                End If

                Try
                    Dim aryParentKey As String() = Split(strParents, "::")
                    'parentkey = parentkey.Replace(numSiteID & "::", "")
                    strParents = aryParentKey(1)
                Catch ex As Exception
                    'erm, oh... this is embarrassing
                End Try

                If strParents.EndsWith("," & GetIDFromNodeValue(node.Value)) Then
                    strParents = Replace(strParents, "," & GetIDFromNodeValue(node.Value), "")
                ElseIf strParents = GetIDFromNodeValue(node.Value).ToString Then
                    strParents = "0"
                End If

                Dim strNavigateURL As String = _CategorySiteMapProvider.CreateURL(
                        _CategorySiteMapProvider.BackEndPage.Product, drwChilds("P_ID"),
                        GetIDFromNodeValue(node.Value, True),
                        numSiteID & "::" & strParents,
                        GetIDFromNodeValue(node.Value))

                childNode.NavigateUrl = strNavigateURL
                If CBool(drwChilds("P_Live")) Then
                    childNode.ImageUrl = "~/Skins/Admin/Images/product-tree.gif"
                Else
                    childNode.ImageUrl = "~/Skins/Admin/Images/offline-product-tree.gif"
                End If
                node.ChildNodes.Add(childNode)
            Next
        End If
    End Sub

    ''' <summary>
    ''' Highlight link for the current product or category, if viewing product or category
    ''' </summary>
    ''' <remarks></remarks>
    Sub SelectCurrentPage()
        Dim strCurrentURL As String = Request.Url.AbsoluteUri.ToString

        If strCurrentURL.Contains("_Category.aspx") OrElse strCurrentURL.Contains("_ModifyCategory.aspx") Then
            Dim strParents As String = ""
            Dim aryParents As String() = Split(_GetParentCategory(), "::")
            Try
                strParents = aryParents(1)
            Catch ex As Exception
                'this wasn't what we were hoping for
            End Try
            If Not String.IsNullOrEmpty(Request.QueryString("sub")) AndAlso Not String.IsNullOrEmpty(strParents) Then
                FindPageNode("c", strParents & "," & Request.QueryString("sub"))
            ElseIf Not String.IsNullOrEmpty(strParents) Then
                FindPageNode("c", strParents)
            Else
                SelectCategoryNode()
            End If

        ElseIf strCurrentURL.Contains("_ModifyProduct.aspx") Then
            Dim strParents As String = ""
            Dim aryParents As String() = Split(_GetParentCategory(), "::")
            Try
                strParents = aryParents(1)
                If String.IsNullOrEmpty(_GetParentCategory()) AndAlso Not String.IsNullOrEmpty(_GetCategoryID) Then
                    FindPageNode("p", _GetCategoryID())
                ElseIf Not String.IsNullOrEmpty(_GetParentCategory()) AndAlso Not String.IsNullOrEmpty(_GetCategoryID) Then
                    FindPageNode("p", strParents & "," & _GetCategoryID())
                End If
            Catch ex As Exception
                'this wasn't what we were hoping for
            End Try

        End If
        If tvwCategory.SelectedNode IsNot Nothing Then
            tvwCategory.SelectedNode.SelectAction = TreeNodeSelectAction.None
            If tvwCategory.SelectedNode.ChildNodes.Count = 0 Then
                tvwCategory.SelectedNode.PopulateOnDemand = False
            End If
        End If
    End Sub

    ''' <summary>
    ''' Select category node
    ''' </summary>
    ''' <remarks></remarks>
    Sub SelectCategoryNode(Optional ByVal ParentNode As TreeNode = Nothing)
        Dim ValueID As Int64 = _GetCategoryID()
        Dim numSiteID As Integer = 0
        Try
            numSiteID = Request.QueryString("SiteID")
        Catch ex As Exception
            'oh dear
        End Try

        If ParentNode Is Nothing Then
            For Each node As TreeNode In tvwCategory.Nodes
                If node.NavigateUrl.Contains("_Category.aspx") Then
                    If GetIDFromNodeValue(node.Value) = ValueID And GetIDFromNodeValue(node.Value, True) = numSiteID Then
                        node.Selected = True
                        If node.ChildNodes.Count = 0 Then node.PopulateOnDemand = True
                        node.Expand()
                        Exit For
                    End If
                End If
            Next
        Else
            For Each node As TreeNode In ParentNode.ChildNodes
                If node.NavigateUrl.Contains("_Category.aspx") Then
                    If GetIDFromNodeValue(node.Value) = ValueID And GetIDFromNodeValue(node.Value, True) = numSiteID Then
                        node.Selected = True
                        If node.ChildNodes.Count = 0 Then node.PopulateOnDemand = True
                        node.Expand()
                        Exit For
                    End If
                End If
            Next
        End If
    End Sub

    ''' <summary>
    ''' Select product node
    ''' </summary>
    ''' <remarks></remarks>
    Sub SelectProductNode(ByVal ParentNode As TreeNode)
        Dim ValueID As Integer = _GetProductID()
        Dim numSiteID As Integer = 0
        Try
            numSiteID = Request.QueryString("SiteID")
        Catch ex As Exception
            'oh dear
        End Try

        For Each node As TreeNode In ParentNode.ChildNodes
            If node.NavigateUrl.Contains("_ModifyProduct.aspx") Then
                If GetIDFromNodeValue(node.Value) = ValueID And GetIDFromNodeValue(node.Value, True) = numSiteID Then
                    node.Selected = True
                    Exit For
                End If
            End If
        Next
    End Sub

    ''' <summary>
    ''' Find page node
    ''' </summary>
    ''' <remarks></remarks>
    Sub FindPageNode(ByVal PageType As Char, ByVal Parents As String)
        Dim numSiteID As Integer = 0
        Try
            numSiteID = Request.QueryString("SiteID")
        Catch ex As Exception
            'oh dear
        End Try
        If PageType = "c" Then
            Parents = _CategorySiteMapProvider.StripParents(Parents)
            Dim arrCategories() As String = Split(Parents, ",")
            For i As Integer = 0 To arrCategories.Length - 1

                'This might come in with the numsite ID for uniqueness, to 
                'distinguish between same product in different sites
                Dim strCatContent As String = arrCategories(i)

                Dim CatID As Integer = CLng(strCatContent)

                For Each node As TreeNode In tvwCategory.Nodes
                    If node.NavigateUrl.Contains("_Category.aspx") Then
                        If GetIDFromNodeValue(node.Value) = CatID And GetIDFromNodeValue(node.Value, True) = numSiteID Then
                            Try
                                node.Expand()
                                node.Selected = True
                                If node.Expanded Then
                                    Dim arrRest(arrCategories.Length - 2) As String
                                    Dim counter As Integer = 0
                                    For x As Integer = 0 To arrCategories.Length - 1
                                        If arrCategories(x) <> CatID Then
                                            arrRest(counter) = arrCategories(x)
                                            counter += 1
                                        End If
                                    Next
                                    SelectCategoryNode(node)
                                    FindChildNodeRecursive(node, arrRest)
                                End If
                            Catch ex As Exception
                            End Try
                            Return
                        End If
                    End If
                Next
            Next
        ElseIf PageType = "p" Then
            Parents = _CategorySiteMapProvider.StripParents(Parents)
            Dim arrCategories() As String = Split(Parents, ",")
            For i As Integer = 0 To arrCategories.Length - 1

                'This might come in with the numsite ID for uniqueness, to 
                'distinguish between same product in different sites
                Dim strCatContent As String = arrCategories(i)

                Dim CatID As Integer = CLng(strCatContent)
                For Each node As TreeNode In tvwCategory.Nodes
                    If node.NavigateUrl.Contains("_Category.aspx") Then
                        If GetIDFromNodeValue(node.Value) = CatID And GetIDFromNodeValue(node.Value, True) = numSiteID Then
                            Try
                                node.Expand()
                                If node.Expanded Then
                                    Dim arrRest(arrCategories.Length - 2) As String
                                    Dim counter As Integer = 0
                                    For x As Integer = 0 To arrCategories.Length - 1
                                        If arrCategories(x) <> CatID Then
                                            arrRest(counter) = arrCategories(x)
                                            counter += 1
                                        End If
                                    Next
                                    FindChildNodeRecursive(node, arrRest)
                                    If tvwCategory.SelectedNode IsNot Nothing Then
                                        SelectProductNode(tvwCategory.SelectedNode)
                                    Else
                                        SelectProductNode(node)
                                    End If
                                End If
                            Catch ex As Exception
                            End Try
                            Return
                        End If
                    Else
                        SelectProductNode(node)
                    End If
                Next
            Next
        End If
    End Sub

    ''' <summary>
    ''' Find child node, recursively
    ''' </summary>
    ''' <remarks></remarks>
    Sub FindChildNodeRecursive(ByVal node As TreeNode, ByVal arrCategories() As String)
        Dim numSiteID As Integer = 0
        Try
            numSiteID = Request.QueryString("SiteID")
        Catch ex As Exception
            'oh dear
        End Try

        For i As Integer = 0 To arrCategories.Length - 1
            Dim CatID As Integer = CInt(arrCategories(i))
            For Each childNode As TreeNode In node.ChildNodes
                If childNode.NavigateUrl.Contains("_Category.aspx") Then
                    If GetIDFromNodeValue(childNode.Value) = CatID And GetIDFromNodeValue(node.Value, True) = numSiteID Then
                        Try
                            childNode.Expand()
                            childNode.Selected = True
                            If childNode.Expanded Then
                                Dim arrRest(arrCategories.Length - 2) As String
                                Dim counter As Integer = 0
                                For x As Integer = 0 To arrCategories.Length - 1
                                    If arrCategories(x) <> CatID Then
                                        arrRest(counter) = arrCategories(x)
                                        counter += 1
                                    End If
                                Next
                                If _GetCategoryID() <> GetIDFromNodeValue(childNode.Value) Then SelectCategoryNode(childNode)
                                If arrRest.Length > 0 Then FindChildNodeRecursive(childNode, arrRest)
                            End If
                        Catch ex As Exception
                        End Try
                        Return
                    End If
                End If
            Next
        Next
    End Sub

    ''' <summary>
    ''' Handle populated node when expanded
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub tvwCategory_TreeNodePopulate(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.TreeNodeEventArgs) Handles tvwCategory.TreeNodePopulate
        Dim currentNode As TreeNode = e.Node
        Dim numSiteID As Integer = 0
        numSiteID = GetIDFromNodeValue(e.Node.Value, True)

        'Here we look up the sub site ID to send down to child
        'cats and products based on the site name of a sub site
        'matching the treeview text for the link (i.e. the domain)
        'Dim tblSubSites As DataTable = SubSitesBLL.GetSubSites()
        'For Each drwSubSite As DataRow In tblSubSites.Rows
        '    If drwSubSite("SUB_Domain").ToLower = e.Node.Text.ToLower Then numSiteID = drwSubSite("SUB_ID")
        'Next

        BuildChildNodes(currentNode, GetIDFromNodeValue(currentNode.Value), numSiteID)
        BuildChildNodes(currentNode, GetIDFromNodeValue(currentNode.Value), numSiteID, "p")
    End Sub

    ''' <summary>
    ''' Pull out the category ID from the node value
    ''' </summary>
    ''' <remarks>
    ''' The value used to be just category ID, but now in v3, we
    ''' also store side ID, so we need function to return
    ''' the category or site from the pipe separated
    ''' string</remarks>
    Private Function GetIDFromNodeValue(ByVal strNodeValue As String, Optional ByVal blnSiteID As Boolean = False) As Int64
        Dim aryIDs As String() = Split(strNodeValue, "|")
        Dim numOutputID As Int64 = 0
        If blnSiteID Then
            'Site ID
            numOutputID = CLng(aryIDs(1))
        Else
            numOutputID = CLng(aryIDs(0))
        End If
        Return numOutputID
    End Function

    ''' <summary>
    ''' Clean up parents string
    ''' </summary>
    ''' <remarks>
    ''' With the new multi-site functionality, we get a parents
    ''' string that includes catid|siteid values instead of just
    ''' catID. This should clean it up.</remarks>
    Private Function CleanParentsString(ByVal strParentsString As String) As String
        Dim aryString As String() = Split(strParentsString, ",")
        For i = 0 To UBound(aryString)
            aryString(i) = GetIDFromNodeValue(aryString(i))
        Next

        Dim strOutput As String = ""
        strOutput = String.Join(",", aryString)
        Return strOutput
    End Function
End Class
