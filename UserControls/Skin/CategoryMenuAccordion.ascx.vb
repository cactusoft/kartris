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
Partial Class UserControls_Skin_CategoryMenuAccordion

    Inherits System.Web.UI.UserControl
    Private _lngCategoryID As Long = 0
    Private _strParent As String = ""

    Public Property RootCategoryID() As Long
        Get
            Return _lngCategoryID
        End Get
        Set(ByVal value As Long)
            _lngCategoryID = value
        End Set
    End Property
    Public Property CategoryParentString() As String
        Get
            Return _strParent
        End Get
        Set(ByVal value As String)
            _strParent = value
        End Set
    End Property
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'We can try to build the accordion and set
        'the right pane open. But on canonical URLs
        'or pages accessed via URLs that don't give
        'hierarchy information, this would error
        'out. So put it in a 'try-catch'.
        Try

            Dim nodeStarting As SiteMapNode = Nothing

            'Set starting node of sitemap
            'This allows the possibility of having two
            'or more menus, each starting from a top
            'level category.
            If _lngCategoryID > 0 Then
                nodeStarting = SiteMap.Providers("CategorySiteMapProvider").FindSiteMapNodeFromKey("0-" &
                                CkartrisBLL.GetLanguageIDfromSession & "," & IIf(_strParent <> "", _strParent & ",", "") & _lngCategoryID)
                If nodeStarting Is Nothing Then
                    nodeStarting = SiteMap.RootNode
                End If

            Else
                nodeStarting = SiteMap.RootNode
            End If

            For numCounter As Integer = 0 To nodeStarting.ChildNodes.Count - 1

                Dim nodSiteMap As SiteMapNode = DirectCast(nodeStarting.ChildNodes(numCounter), SiteMapNode)
                Dim acpCategory As New AjaxControlToolkit.AccordionPane()
                Dim intCategory_CGID As Integer = CInt(nodSiteMap("CG_ID")) 'Need to hide items user not allowed to see
                Dim intThisUser As Integer = 0
                Try
                    intThisUser = DirectCast(Page, PageBaseClass).CurrentLoggedUser.CustomerGroupID
                Catch ex As Exception
                    'Ignore, will be 
                End Try

                If intThisUser = intCategory_CGID Or intCategory_CGID = 0 Then
                    'Each accordion pane needs a unique ID
                    acpCategory.ID = "Pane" & nodeStarting.ChildNodes(numCounter).Key

                    Dim lnkCatName As New HyperLink()
                    lnkCatName.NavigateUrl = nodeStarting.ChildNodes(numCounter).Url.ToString()
                    lnkCatName.Text = nodeStarting.ChildNodes(numCounter).Title.ToString()

                    'link added to pane
                    acpCategory.HeaderContainer.Controls.Add(lnkCatName)

                    'produce list of children
                    Dim objMenu As New BulletedList()
                    objMenu.DisplayMode = BulletedListDisplayMode.HyperLink

                    'If child nodes, then loop to produce submenu
                    If nodSiteMap.HasChildNodes Then

                        'since this pane has childnodes, blank the navigateurl to suppress postback when header is clicked
                        lnkCatName.NavigateUrl = ""

                        'items list added to menu
                        For numSubCounter As Integer = nodSiteMap.ChildNodes.Count - 1 To 0 Step -1
                            Dim intCategory_sub_CGID As Integer = CInt(nodSiteMap.ChildNodes(numSubCounter)("CG_ID")) 'Need to hide items user not allowed to see
                            If intThisUser = intCategory_sub_CGID Or intCategory_sub_CGID = 0 Then
                                objMenu.Items.Insert(0, (New ListItem(nodSiteMap.ChildNodes(numSubCounter).Title.ToString(), nodSiteMap.ChildNodes(numSubCounter).Url.ToString())))
                            End If
                        Next
                        'adds menu to container pane
                        acpCategory.ContentContainer.Controls.Add(objMenu)

                        'adds pane to accordion
                        accCategories.Panes.Add(acpCategory)
                    End If


                    'adds menu to container pane
                    acpCategory.ContentContainer.Controls.Add(objMenu)

                    'adds pane to accordion
                    accCategories.Panes.Add(acpCategory)
                End If

            Next

            If SiteMap.CurrentNode Is Nothing Then
                accCategories.SelectedIndex = -1
            Else
                'get the top level node for the current node 
                If SiteMap.CurrentNode IsNot Nothing Then
                    Dim nodCurrentTopLevel As SiteMapNode = GetTopLevelNode(SiteMap.CurrentNode)

                    'cycle through all accordine panes and open the one that matches the current top level node
                    Dim intCount = 0
                    For Each pane As AjaxControlToolkit.AccordionPane In accCategories.Panes
                        If (pane.ID = "Pane" & nodCurrentTopLevel.Key) Then
                            accCategories.SelectedIndex = intCount
                            Exit For
                        End If
                        intCount += 1
                    Next
                End If
            End If
        Catch ex As Exception
            'Do nothing
        End Try


    End Sub

    Private Function GetTopLevelNode(ByVal node As SiteMapNode) As SiteMapNode

        Dim nodeStarting As SiteMapNode = Nothing

        If _lngCategoryID > 0 Then
            nodeStarting = SiteMap.Providers("CategorySiteMapProvider").FindSiteMapNodeFromKey("0-" & CkartrisBLL.GetLanguageIDfromSession & "," &
                                                            IIf(_strParent <> "", _strParent & ",", "") & _lngCategoryID)
            If nodeStarting Is Nothing Then
                nodeStarting = SiteMap.RootNode
            End If

        Else
            nodeStarting = SiteMap.RootNode
        End If

        If _lngCategoryID = 0 Then
            Do Until node.ParentNode Is nodeStarting
                node = node.ParentNode
            Loop
        Else
            Return nodeStarting
        End If

        Return node
    End Function

End Class
