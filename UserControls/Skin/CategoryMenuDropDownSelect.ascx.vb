'========================================================================
'Kartris - www.kartris.com
'Copyright 2013 CACTUSOFT INTERNATIONAL FZ LLC

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class UserControls_Skin_CategoryMenuDropDownSelect

    Inherits System.Web.UI.UserControl
    Private _lngCategoryID As Long = 0
    Private _strInitialDropdownText As String = "-"

    ''' <summary>
    ''' Get or set the root category for this control - must be one of the TOP level categories
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
    ''' Set the initial text on the dropdown/select menu
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property DropdownText() As String
        Get
            Return _strInitialDropdownText
        End Get
        Set(ByVal value As String)
            _strInitialDropdownText = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ddlCategories.Attributes.Add("onChange", "javascript:" & ddlCategories.ClientID & "_CategorySelected();")
        ddlCategories.Items(0).Text = _strInitialDropdownText

        'Set starting node of sitemap
        'This allows the possibility of having two
        'or more menus, each starting from a top
        'level category.
        If _lngCategoryID > 0 Then
            Dim nodeCategory As SiteMapNode = SiteMap.Providers("CategorySiteMapProvider").FindSiteMapNodeFromKey("0-" & CkartrisBLL.GetLanguageIDfromSession & "," & _lngCategoryID)
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

End Class
