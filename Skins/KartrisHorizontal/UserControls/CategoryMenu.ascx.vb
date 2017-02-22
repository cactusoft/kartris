'========================================================================
'Kartris - www.kartris.com
'Copyright 2017 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class UserControls_Skin_CategoryMenu

    Inherits System.Web.UI.UserControl
    Private _lngCategoryID As Long = 0
    Private _strParent As String = ""
    Private _strInitialDropdownText As String = "-"

    ''' <summary>
    ''' Get or set the root category for this control 
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property RootCategoryID() As Long
        Get
            Return _lngCategoryID
        End Get
        Set(ByVal value As Long)
            _lngCategoryID = value
        End Set
    End Property
    ''' <summary>
    ''' Get or set the category parent string - QS: strParent
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property CategoryParentString() As String
        Get
            Return _strParent
        End Get
        Set(ByVal value As String)
            _strParent = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        menCategory.MaximumDynamicDisplayLevels = CInt(KartSettingsManager.GetKartConfig("frontend.display.categorymenu.levels")) - 1

        'Set starting node of sitemap
        'This allows the possibility of having two
        'or more menus, each starting from a top
        'level category.
        If _lngCategoryID > 0 Then
            Dim nodeCategory As SiteMapNode = SiteMap.Providers("CategorySiteMapProvider").FindSiteMapNodeFromKey("0-" &
                        CkartrisBLL.GetLanguageIDfromSession & "," & IIf(_strParent <> "", _strParent & ",", "") & _lngCategoryID)
            If nodeCategory IsNot Nothing Then
                srcSiteMap.StartingNodeUrl = nodeCategory.Url
            End If
        End If

        'Handles caching
        Dim dependencyKey As [String]() = New [String](0) {}
        dependencyKey(0) = "CategoryMenuKey"
        Dim pcc As BasePartialCachingControl = TryCast(Parent, BasePartialCachingControl)
        pcc.Dependency = New CacheDependency(Nothing, dependencyKey)
    End Sub

    ''' <summary>
    ''' CSS Fold-out menu - on menu item bound
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Protected Sub menCategory_MenuItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.MenuEventArgs) Handles menCategory.MenuItemDataBound
        Dim intCategory_CGID As Integer = CInt(CType(e.Item.DataItem, SiteMapNode)("CG_ID"))
        If intCategory_CGID > 0 Then
            Dim blnRemove As Boolean = False
            If Page.User.Identity.IsAuthenticated Then
                Try
                    If DirectCast(Page, PageBaseClass).CurrentLoggedUser.CustomerGroupID <> intCategory_CGID Then blnRemove = True
                Catch ex As Exception
                    blnRemove = True
                End Try
            Else
                blnRemove = True
            End If

            If blnRemove Then
                If e.Item.Parent IsNot Nothing Then
                    e.Item.Parent.ChildItems.Remove(e.Item)
                Else
                    menCategory.Items.Remove(e.Item)
                End If
            End If
        End If
    End Sub

End Class
