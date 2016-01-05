'========================================================================
'Kartris - www.kartris.com
'Copyright 2016 CACTUSOFT

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

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            LoadCategoryMenu()
        End If
    End Sub

    Public Sub LoadCategoryMenu()
        BuildTopLevelMenu()
        BuildDefaultLevels()
        SelectCurrentPage()
    End Sub

    Public Function GetTree() As TreeView
        Return tvwCategory
    End Function

    'This refreshes the category menu, but also clears all
    'caches. Useful if certain data which has been updated is
    'not visible on the front end.
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

    Sub BuildTopLevelMenu()
        Dim tblChilds As DataTable = CategoriesBLL._GetCategoriesPageByParentID(0, Session("_LANG"), 0, 2000, 0)
        Dim childNode As TreeNode = Nothing
        For Each drwChilds As DataRow In tblChilds.Rows
            childNode = New TreeNode(drwChilds("CAT_Name"), drwChilds("CAT_ID"))
            childNode.NavigateUrl = _CategorySiteMapProvider.CreateURL(_CategorySiteMapProvider.BackEndPage.Category, drwChilds("CAT_ID"))
            childNode.PopulateOnDemand = True
            If CBool(drwChilds("CAT_Live")) Then
                childNode.ImageUrl = "~/Skins/Admin/Images/category-tree.gif"
            Else
                childNode.ImageUrl = "~/Skins/Admin/Images/offline-category-tree.gif"
            End If
            tvwCategory.Nodes.Add(childNode)
        Next
    End Sub

    Sub BuildDefaultLevels()
        Dim numLevels As Integer = CInt(KartSettingsManager.GetKartConfig("backend.categorymenu.levels")) - 1
        If numLevels = 0 Then Return
        For Each node As TreeNode In tvwCategory.Nodes
            BuildLevelsRecursive(numLevels, node)
        Next
    End Sub

    Sub BuildLevelsRecursive(ByVal numLevels As Integer, ByVal node As TreeNode)
        If numLevels = 0 Then Return
        node.Expand()
        For Each childNode As TreeNode In node.ChildNodes
            BuildLevelsRecursive(numLevels - 1, childNode)
        Next
    End Sub

    Sub BuildChildNodes(ByRef node As TreeNode, ByVal numParentID As Integer, Optional ByVal chrParentType As Char = "c")
        If chrParentType = "c" Then
            Dim tblChilds As DataTable = CategoriesBLL._GetCategoriesPageByParentID(numParentID, Session("_LANG"), 0, 2000, 0)
            Dim childNode As TreeNode = Nothing
            For Each drwChilds As DataRow In tblChilds.Rows
                childNode = New TreeNode(drwChilds("CAT_Name"), drwChilds("CAT_ID"))
                childNode.NavigateUrl = _CategorySiteMapProvider.CreateURL( _
                    _CategorySiteMapProvider.BackEndPage.Category, drwChilds("CAT_ID"), _
                    node.ValuePath.Replace("/", ","), node.Value)
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
                childNode = New TreeNode(drwChilds("P_Name"), drwChilds("P_ID"))
                Dim strParents As String = node.ValuePath.Replace("/", ",")
                If strParents.EndsWith("," & node.Value) Then
                    strParents = Replace(strParents, "," & node.Value, "")
                ElseIf strParents = node.Value Then
                    strParents = "0"
                End If

                Dim strNavigateURL As String = _CategorySiteMapProvider.CreateURL( _
                        _CategorySiteMapProvider.BackEndPage.Product, drwChilds("P_ID"), _
                        strParents) & "&CategoryID=" & node.Value
                If strParents = "0" Then strNavigateURL &= "&strParent=0"
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

    Sub SelectCurrentPage()
        Dim strCurrentURL As String = Request.Url.AbsoluteUri.ToString

        If strCurrentURL.Contains("_Category.aspx") OrElse strCurrentURL.Contains("_ModifyCategory.aspx") Then
            If Not String.IsNullOrEmpty(Request.QueryString("sub")) AndAlso Not String.IsNullOrEmpty(_GetParentCategory()) Then
                FindPageNode("c", _GetParentCategory() & "," & Request.QueryString("sub"))
            ElseIf Not String.IsNullOrEmpty(_GetParentCategory()) Then
                FindPageNode("c", _GetParentCategory())
            Else
                SelectCategoryNode()
            End If
        ElseIf strCurrentURL.Contains("_ModifyProduct.aspx") Then
            If String.IsNullOrEmpty(_GetParentCategory()) AndAlso Not String.IsNullOrEmpty(_GetCategoryID) Then
                FindPageNode("p", _GetCategoryID())
            ElseIf Not String.IsNullOrEmpty(_GetParentCategory()) AndAlso Not String.IsNullOrEmpty(_GetCategoryID) Then
                FindPageNode("p", _GetParentCategory() & "," & _GetCategoryID())
            End If
        End If
        If tvwCategory.SelectedNode IsNot Nothing Then
            tvwCategory.SelectedNode.SelectAction = TreeNodeSelectAction.None
            If tvwCategory.SelectedNode.ChildNodes.Count = 0 Then
                tvwCategory.SelectedNode.PopulateOnDemand = False
            End If
        End If
    End Sub

    Sub SelectCategoryNode(Optional ByVal ParentNode As TreeNode = Nothing)
        Dim ValueID As Integer = _GetCategoryID()
        If ParentNode Is Nothing Then
            For Each node As TreeNode In tvwCategory.Nodes
                If node.NavigateUrl.Contains("_Category.aspx") Then
                    If node.Value = ValueID Then
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
                    If node.Value = ValueID Then
                        node.Selected = True
                        If node.ChildNodes.Count = 0 Then node.PopulateOnDemand = True
                        node.Expand()
                        Exit For
                    End If
                End If
            Next
        End If
    End Sub

    Sub SelectProductNode(ByVal ParentNode As TreeNode)
        Dim ValueID As Integer = _GetProductID()
        For Each node As TreeNode In ParentNode.ChildNodes
            If node.NavigateUrl.Contains("_ModifyProduct.aspx") Then
                If node.Value = ValueID Then
                    node.Selected = True
                    Exit For
                End If
            End If
        Next
    End Sub

    Sub FindPageNode(ByVal PageType As Char, ByVal Parents As String)
        If PageType = "c" Then
            Dim arrCategories() As String = Split(Parents, ",")
            For i As Integer = 0 To arrCategories.Length - 1
                Dim CatID As Integer = CInt(arrCategories(i))
                For Each node As TreeNode In tvwCategory.Nodes
                    If node.NavigateUrl.Contains("_Category.aspx") Then
                        If node.Value = CatID Then
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
            Dim arrCategories() As String = Split(Parents, ",")
            For i As Integer = 0 To arrCategories.Length - 1
                Dim CatID As Integer = CInt(arrCategories(i))
                For Each node As TreeNode In tvwCategory.Nodes
                    If node.NavigateUrl.Contains("_Category.aspx") Then
                        If node.Value = CatID Then
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

    Sub FindChildNodeRecursive(ByVal node As TreeNode, ByVal arrCategories() As String)
        For i As Integer = 0 To arrCategories.Length - 1
            Dim CatID As Integer = CInt(arrCategories(i))
            For Each childNode As TreeNode In node.ChildNodes
                If childNode.NavigateUrl.Contains("_Category.aspx") Then
                    If childNode.Value = CatID Then
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
                                If _GetCategoryID() <> childNode.Value Then SelectCategoryNode(childNode)
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

    Protected Sub tvwCategory_TreeNodePopulate(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.TreeNodeEventArgs) Handles tvwCategory.TreeNodePopulate
        Dim currentNode As TreeNode = e.Node
        BuildChildNodes(currentNode, currentNode.Value)
        BuildChildNodes(currentNode, currentNode.Value, "p")
    End Sub
End Class
