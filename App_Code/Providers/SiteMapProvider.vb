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
Imports System.Collections.Specialized
Imports System.Web.Configuration
Imports System.Web
Imports System.Web.Caching
Imports CkartrisDataManipulation
Imports CkartrisBLL
Imports System.Web.HttpContext
Imports CkartrisDisplayFunctions

''' <summary>
''' uses the standard StaticSiteMapProvider in .NET framework - here we're creating a class that inherits this
''' provider to build the dynamic sitemap from the Kartris database.
''' </summary>
Public Class CategorySiteMapProvider
    Inherits StaticSiteMapProvider

    Private _isInitialized As Boolean = False
    Private _rootNode As SiteMapNode

    Private _navigateUrl As String
    Private _idFieldName As String

    Private numLANGID As Int16
    Private _htRootNodes As Hashtable = New Hashtable

    ''' <summary>
    ''' Loads configuration settings from Web configuration file
    ''' </summary>
    Public Overrides Sub Initialize(ByVal name As String, ByVal attributes As NameValueCollection)
        If _isInitialized Then
            Return
        End If
        MyBase.Initialize(name, attributes)
        ' Get navigateUrl from config file
        _navigateUrl = attributes("navigateUrl")
        If (String.IsNullOrEmpty(_navigateUrl)) Then
            Throw New Exception("You must provide a navigateUrl attribute")
        End If

        ' Get idFieldName from config file
        _idFieldName = attributes("idFieldName")
        If String.IsNullOrEmpty(_idFieldName) Then
            _idFieldName = "CategoryID"
        End If
        _isInitialized = True
    End Sub

    ''' <summary>
    ''' Retrieve the root node by building the Site Map
    ''' </summary>
    Protected Overrides Function GetRootNodeCore() As SiteMapNode

        numLANGID = GetLanguageIDfromSession()
        Return BuildSiteMap()
    End Function

    ''' <summary>
    ''' Resets the Category SiteMap by deleting the 
    ''' root node if the current language session variable
    ''' is different to the language that the current sitemap uses.
    ''' </summary>
    Public Sub ResetSiteMap()
        numLANGID = GetLanguageIDfromSession()
        If Not IsNothing(_rootNode) Then
            If _rootNode.Key <> "0-" & numLANGID Then _rootNode = Nothing
        End If
    End Sub

    ''' <summary>
    ''' Clears all the nodes in the Category SiteMap (all languages).
    ''' This will cause the SiteMap to rebuild all of its nodes from stratch.
    ''' *Primarily used for category updates in the backend.
    ''' </summary>
    Public Sub RefreshSiteMap()
        _rootNode = Nothing
        Clear()
        _htRootNodes.Clear()
        HttpRuntime.Cache.Insert("CategoryMenuKey", DateTime.Now)
    End Sub

    ''' <summary>
    ''' Build the Site Map by retrieving
    ''' records from database table
    ''' </summary>
    Public Overrides Function BuildSiteMap() As SiteMapNode
        ' Only allow the Site Map to be created by a single thread
        SyncLock Me
            _rootNode = DirectCast(_htRootNodes.Item(numLANGID), SiteMapNode)
            If _rootNode Is Nothing Then
                ' Show trace for debugging
                HttpContext.Current.Trace.Warn("Loading category site map from database")

                ' Clear current Site Map
                'Clear()

                ' Load the database data
                Dim tblSiteMap As DataTable = GetSiteMapFromDB(numLANGID)
                ' Set the root node
                Dim strCategoryLabel As String = HttpContext.GetGlobalResourceObject("Kartris", "ContentText_Categories")
                _rootNode = New SiteMapNode(Me, "0-" & numLANGID, "~/Category.aspx?L=" & numLANGID, strCategoryLabel, strCategoryLabel)
                Dim HomeNode As SiteMapNode = New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), "Home", "~/Default.aspx", HttpContext.GetGlobalResourceObject("Kartris", "ContentText_Home"))
                AddNode(_rootNode, HomeNode)
                _htRootNodes.Add(numLANGID, _rootNode)
                ' Build the child nodes 
                BuildSiteMapRecurse(tblSiteMap, _rootNode, "0-" & numLANGID)
            End If
            Return _rootNode
        End SyncLock
    End Function

    ''' <summary>
    ''' Load the contents of the database table
    ''' that contains the Site Map
    ''' </summary>
    Private Function GetSiteMapFromDB(ByVal numLANGID As Integer) As DataTable
        Return CategoriesBLL.GetHierarchyByLanguageID(numLANGID)
    End Function

    ''' <summary>
    ''' Recursively build the Site Map from the DataTable
    ''' </summary>
    Private Sub BuildSiteMapRecurse(ByVal siteMapTable As DataTable, ByVal parentNode As SiteMapNode, ByVal parentkey As String, Optional ByVal parentCGroup As Integer = 0)
        Dim arr As Array = Split(parentNode.Key, ",")

        Dim strMainParent As String = ""
        If arr(UBound(arr)) = "0-" & numLANGID Then
            strMainParent = 0
        Else
            strMainParent = arr(UBound(arr))
        End If

        Dim results() As DataRow = siteMapTable.Select("ParentID=" & strMainParent)
        For Each row As DataRow In results
            Dim url As String
            Dim strParentKey As String
            If InStr(parentkey, "0-" & numLANGID & ",") Then strParentKey = Mid(parentkey, InStr(parentkey, ",") + 1) Else strParentKey = parentkey
            If strParentKey = "0-" & numLANGID Then strParentKey = ""
            If strParentKey <> "" Then
                Dim arrTempParentKeys As String() = Split(strParentKey, ",")
                If UBound(arrTempParentKeys) > 0 Then
                    If arrTempParentKeys(UBound(arrTempParentKeys)) <> row("parentid") Then
                        strParentKey = strParentKey & "," & row("parentid")
                        parentkey = parentkey & "," & row("parentid")
                    End If
                Else
                    If strParentKey <> row("parentid") Then
                        strParentKey = strParentKey & "," & row("parentid")
                        parentkey = parentkey & "," & row("parentid")
                    End If
                End If

            Else
                strParentKey = row("parentid")
                If row("parentid") = 0 Then parentkey = "0-" & numLANGID Else parentkey = parentkey & "," & row("parentid")
            End If

            url = SiteMapHelper.CreateURL(SiteMapHelper.Page.Category, row("CAT_ID"), strParentKey, , , , , row("title").ToString())
            Dim node As New SiteMapNode(Me, parentkey & "," & row("CAT_ID").ToString(), url, row("title").ToString())
            Dim intCategoryCustomerGroup = CInt(FixNullFromDB(row("CAT_CustomerGroupID")))
            'if the parent has customer group, override this category's customer group
            If parentCGroup > 0 Then intCategoryCustomerGroup = parentCGroup
            node.Item("CG_ID") = intCategoryCustomerGroup
            node.Item("CAT_ID") = row("CAT_ID")
            AddNode(node, parentNode)

            BuildSiteMapRecurse(siteMapTable, node, parentNode.Key, intCategoryCustomerGroup)
        Next
    End Sub

End Class

#Region "SITEMAP HELPER CLASS"
Public Class SiteMapHelper
    Public Enum Page
        Product
        Category
        CustomPage
        Search
        News
        CanonicalProduct
        CanonicalCategory
        Knowledgebase
        SupportTicket
    End Enum

    ''' <summary>
    ''' Map friendly URL to parametrized equivalent
    ''' </summary>
    Public Shared Function ExpandPathForUnmappedPages(ByVal sender As Object, ByVal e As SiteMapResolveEventArgs) As SiteMapNode
        Dim context As HttpContext = HttpContext.Current
        Dim numLangID As Integer = GetLanguageIDfromSession()
        Dim PageHandler As System.Web.UI.Page = context.Handler
        If Not PageHandler.IsPostBack Then
            If Not (context.Request.RawUrl.ToLower().Contains("/javascript/") Or context.Request.RawUrl.ToLower().Contains("/skins/") Or context.Request.RawUrl.ToLower().Contains("/images/")) Then
                Try
                    'Create a custom SiteMapNode for various pages that display records based on ID
                    If context.Request.Path.ToLower().Contains("/product.aspx") Then
                        If Not [String].IsNullOrEmpty(context.Request("CategoryID")) And Not [String].IsNullOrEmpty(context.Request("ProductID")) Then
                            Dim strParentkeys As String = [String].Empty

                            Dim id As Integer = Convert.ToString(context.Request("CategoryID"))
                            Dim pid As Integer = Convert.ToString(context.Request("ProductID"))

                            ' Create a new SiteMapNode to represent the requested page 
                            'Dim node As New SiteMapNode(SiteMap.Provider, context.Request.Path, context.Request.Path, ProductsBLL.GetNameByProductID(pid, 1))
                            Dim node As New SiteMapNode(SiteMap.Provider, context.Request.Path, context.Request.Path, GetProductName(pid, numLangID))


                            If Not [String].IsNullOrEmpty(context.Request("strParent")) Then strParentkeys = Convert.ToString(context.Request("strParent")) & ","


                            If [String].IsNullOrEmpty(strParentkeys) Then
                                node.ParentNode = SiteMap.Provider.FindSiteMapNodeFromKey("0-" & numLangID & "," & id)
                            Else
                                ' Get the parent node from the site map and parent the new node to it 
                                node.ParentNode = SiteMap.Provider.FindSiteMapNodeFromKey("0-" & numLangID & "," & strParentkeys & id)
                            End If

                            Return node
                            'Create a custom SiteMapNode for Search 
                        ElseIf (context.Request("strReferer")) = "search" And Not [String].IsNullOrEmpty(context.Request("ProductID")) Then
                            Dim pid As Integer = Convert.ToString(context.Request("ProductID"))

                            ' Create a new SiteMapNode to represent the requested page 
                            'Dim node As New SiteMapNode(SiteMap.Provider, context.Request.Path, context.Request.Path, ProductsBLL.GetNameByProductID(pid, 1))
                            Dim node As New SiteMapNode(SiteMap.Provider, context.Request.Path, context.Request.Path, GetProductName(pid, numLangID))

                            'The link came from the search results
                            Dim ParentSearchNode As New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), "Search", "~/Search.aspx", HttpContext.GetGlobalResourceObject("Kartris", "ContentText_Search"))

                            'What page of results did user click from?
                            Dim intPageNumber As Integer = 0
                            Try
                                intPageNumber = context.Request("PPGR")
                            Catch ex As Exception
                                intPageNumber = 0
                            End Try

                            'Format URL for search results breadcrumb
                            Dim strSearchResultsLink As String = "~/Search.aspx?strResults=y&PPGR=" & intPageNumber

                            Dim SearchResultsNode As New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), "SearchResults", strSearchResultsLink, HttpContext.GetGlobalResourceObject("Search", "ContentText_SearchResults"))
                            SearchResultsNode.ParentNode = ParentSearchNode
                            node.ParentNode = SearchResultsNode
                            Return node
                        ElseIf Not [String].IsNullOrEmpty(context.Request("ProductID")) Then
                            Dim pid As Integer = CInt(context.Request("ProductID"))
                            If pid > 0 Then
                                Dim HomeNode As SiteMapNode = New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), "Home", "~/Default.aspx", HttpContext.GetGlobalResourceObject("Kartris", "ContentText_Home"))
                                Dim node As SiteMapNode = New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), "Product", context.Request.Url.ToString(), GetProductName(pid, numLangID))
                                node.ParentNode = HomeNode
                                Return node
                            End If
                        End If
                    ElseIf context.Request.Path.ToLower().Contains("/category.aspx") Then
                        ' Create a custom SiteMapNode for category.aspx. 
                        If Not [String].IsNullOrEmpty(context.Request("CategoryID")) Then
                            Dim id As Integer = Convert.ToString(context.Request("CategoryID"))
                            Dim node As SiteMapNode
                            Dim strParentkeys As String = ""
                            If Not [String].IsNullOrEmpty(context.Request("strParent")) Then strParentkeys = "0-" & numLangID & "," & Convert.ToString(context.Request("strParent")) Else strParentkeys = "0-" & numLangID
                            node = SiteMap.Provider.FindSiteMapNodeFromKey(strParentkeys & "," & id)
                            If node Is Nothing Then
                                Dim HomeNode As SiteMapNode = New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), "Home", "~/Default.aspx", HttpContext.GetGlobalResourceObject("Kartris", "ContentText_Home"))
                                node = New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), "custom" & id, CreateURL(Page.CanonicalCategory, id), GetCategoryName(id, numLangID))
                                node.ParentNode = HomeNode
                            End If
                            Return node
                        End If
                    ElseIf context.Request.Path.ToLower.Contains("compare.aspx") Then
                        Dim HomeNode As SiteMapNode = New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), "Home", "~/Default.aspx", HttpContext.GetGlobalResourceObject("Kartris", "ContentText_Home"))
                        If Not [String].IsNullOrEmpty(context.Request("CategoryID")) Then
                            Dim id As Integer = Convert.ToString(context.Request("CategoryID"))
                            Dim node As SiteMapNode
                            Dim strParentkeys As String = ""
                            If Not [String].IsNullOrEmpty(context.Request("strParent")) Then strParentkeys = "&strParent=" & Convert.ToString(context.Request("strParent"))


                            If Not [String].IsNullOrEmpty(context.Request("ProductID")) Then
                                If context.Request("action") = "add" Then
                                    Dim strNodePath As String
                                    strNodePath = "~/Product.aspx?ProductID=" & context.Request("ProductID") & "&strPageHistory=compare"
                                    Dim parentNode As SiteMapNode
                                    'parentNode = New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), context.Request.Path, strNodePath, ProductsBLL.GetNameByProductID(context.Request("id"), 1))
                                    parentNode = New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), context.Request.Path, strNodePath, GetProductName(context.Request("id"), numLangID))
                                    parentNode.ParentNode = SiteMap.Provider.FindSiteMapNodeFromKey(strParentkeys & "," & id)
                                    node = New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), "Compare", context.Request.Url.ToString(), HttpContext.GetGlobalResourceObject("Products", "PageTitle_ProductComparision"))
                                    node.ParentNode = parentNode
                                Else
                                    node = Nothing
                                End If
                            Else
                                node = New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), "Compare", context.Request.Url.ToString(), HttpContext.GetGlobalResourceObject("Products", "PageTitle_ProductComparision"))
                                node.Title += "(" & GetProductName(context.Request("id"), numLangID) & ")"
                                node.ParentNode = SiteMap.Provider.FindSiteMapNodeFromKey(strParentkeys & "," & id)
                            End If

                            Return node
                        Else
                            Dim node As SiteMapNode = New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), "Compare", context.Request.Url.ToString(), HttpContext.GetGlobalResourceObject("Products", "PageTitle_ProductComparision"))
                            node.ParentNode = HomeNode
                            Return node
                        End If
                    ElseIf context.Request.Path.ToLower.Contains("page.aspx") Then
                        Dim strPage As String = Convert.ToString(context.Request("strPage"))
                        Dim tblPage As DataTable = PagesBLL.GetPageByName(numLangID, strPage)
                        Dim node As SiteMapNode
                        If tblPage.Rows.Count > 0 Then
                            Dim strPageName As String = tblPage.Rows(0).Item("Page_Title").ToString()
                            strPageName = Replace(strPageName, "-", " ")
                            node = New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), "CustomPage", context.Request.Url.ToString(), strPageName)

                            Dim HomeNode As SiteMapNode = SiteMap.Providers.Item("BreadCrumbSiteMap").RootNode

                            Dim intParentID As Integer = tblPage.Rows(0).Item("Page_ParentID").ToString

                            If intParentID > 0 Then
                                RecursiveNodeToHome(numLangID, node, intParentID, HomeNode)
                            Else
                                node.ParentNode = HomeNode
                            End If
                        Else
                            node = Nothing
                        End If
                        Return node
                    ElseIf context.Request.Path.ToLower.Contains("news.aspx") Then
                        Dim intNewsID As Integer = Convert.ToString(context.Request("NewsID"))
                        If intNewsID > 0 Then
                            Dim strNewsTitle As String = NewsBLL.GetNewsTitleByID(intNewsID, numLangID)
                            Dim node As New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), "NewsPage", context.Request.Url.ToString(), strNewsTitle)
                            Dim NewsNode As SiteMapNode = SiteMap.Providers.Item("BreadCrumbSiteMap").FindSiteMapNode("~/News.aspx")
                            node.ParentNode = NewsNode
                            Return node
                        End If
                        Return Nothing
                    ElseIf context.Request.Path.ToLower.Contains("knowledgebase.aspx") Then
                        If Not context.Request("kb") Is Nothing Then
                            Dim intKBID As Integer = Convert.ToString(context.Request("kb"))
                            If intKBID > 0 Then
                                Dim strKBTitle As String = GetKnowledgebaseTitle(intKBID, numLangID)
                                Dim node As New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), "Knowledgebase", context.Request.Url.ToString(), strKBTitle)
                                Dim KBNode As SiteMapNode = SiteMap.Providers.Item("BreadCrumbSiteMap").FindSiteMapNode("~/Knowledgebase.aspx")
                                node.ParentNode = KBNode
                                Return node
                            End If
                        End If

                    ElseIf context.Request.Path.ToLower.Contains("customertickets.aspx") Then
                        If Not context.Request("TIC_ID") Is Nothing Then
                            Dim intTICID As Integer = Convert.ToString(context.Request("TIC_ID"))
                            If intTICID > 0 Then
                                Dim strTicketTitle As String = "#" & intTICID.ToString
                                Dim node As New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), "SupportTicket", context.Request.Url.ToString(), strTicketTitle)
                                Dim TicNode As SiteMapNode = SiteMap.Providers.Item("BreadCrumbSiteMap").FindSiteMapNode("~/CustomerTickets.aspx")
                                node.ParentNode = TicNode
                                Return node
                            End If
                        End If

                    End If
                Catch ex As Exception
                    'Give a 404 responsive by transferring
                    HttpContext.Current.Server.Transfer("~/404.aspx")
                End Try
            End If
        End If

        'Also check the backend URLs
        If context.Request.Path.ToLower().Contains("_modifycategory.aspx") Then
            Dim id As Integer = CInt(context.Request("CategoryID"))
            Dim node As SiteMapNode
            If id > 0 Then
                node = New SiteMapNode(SiteMap.Providers("_CategorySiteMapProvider"), "_category-" & id, context.Request.Path.ToString, GetGlobalResourceObject("_Category", "ContentText_EditThisCategory"))
                node.ParentNode = SiteMap.Providers.Item("_CategorySiteMapProvider").FindSiteMapNodeFromKey(Convert.ToString(context.Request("strParent") & "," & id))
            Else
                node = New SiteMapNode(SiteMap.Providers("_CategorySiteMapProvider"), "_category-" & id, context.Request.Path.ToString, GetGlobalResourceObject("_Category", "ContentText_AddNewSubcategory"))
                Dim strSub As String = IIf(String.IsNullOrEmpty(CStr(context.Request("Sub"))), "0,", CStr(context.Request("Sub")) & ",")
                node.ParentNode = SiteMap.Providers.Item("_CategorySiteMapProvider").FindSiteMapNodeFromKey(strSub & Convert.ToString(context.Request("strParent")))
            End If

            Return node

            'DISABLED AS THE BREADCRUMB TRAIL WAS REMOVED FROM THE MODIFYPRODUCT PAGE
            '
        ElseIf context.Request.Path.ToLower().Contains("_modifyproduct.aspx") Then
            Dim id As Integer = CInt(context.Request("CategoryID"))
            Dim ProductID As Integer = Convert.ToString(context.Request("ProductID"))
            Dim node As SiteMapNode
            If ProductID > 0 Then
                node = New SiteMapNode(SiteMap.Providers("_CategorySiteMapProvider"), "_product-" & ProductID, context.Request.Path.ToString, GetProductName(ProductID, numLangID))
            Else
                node = New SiteMapNode(SiteMap.Providers("_CategorySiteMapProvider"), "_product-" & ProductID, context.Request.Path.ToString, GetGlobalResourceObject("_Category", "ContentText_AddNewProduct"))
                'Dim strSub As String = IIf(String.IsNullOrEmpty(CStr(context.Request("Sub"))), "0,", CStr(context.Request("Sub")) & ",")
                'node.ParentNode = SiteMap.Providers.Item("_CategorySiteMapProvider").FindSiteMapNodeFromKey(strSub & Convert.ToString(context.Request("strParent")))
            End If
            node.ParentNode = SiteMap.Providers.Item("_CategorySiteMapProvider").FindSiteMapNodeFromKey(Convert.ToString(context.Request("strParent") & "," & id))

            Return node

        End If

        ' 
        ' Do nothing for other pages. 
        ' 

        Return Nothing
    End Function

    Private Shared Function RecursiveNodeToHome(ByVal intLangID As Integer, ByVal node As SiteMapNode, ByVal intParentID As Integer, ByVal HomeNode As SiteMapNode) As SiteMapNode

        Dim tblPage As DataTable = PagesBLL._GetPageByID(intLangID, intParentID)
        If tblPage.Rows.Count > 0 Then
            Dim strPageName As String = tblPage.Rows(0).Item("Page_Name").ToString()
            Dim intNewParent As String = tblPage.Rows(0).Item("Page_ParentID").ToString()
            Dim CustomParentNode As SiteMapNode = New SiteMapNode(SiteMap.Providers.Item("BreadCrumbSiteMap"), "CustomParentPage", "~/t-" & strPageName & ".aspx", Replace(strPageName, "-", " "))
            node.ParentNode = CustomParentNode
            If intNewParent > 0 Then
                RecursiveNodeToHome(intLangID, CustomParentNode, intNewParent, HomeNode)
            Else
                CustomParentNode.ParentNode = HomeNode
            End If
        Else
            node.ParentNode = HomeNode
        End If
        Return node
    End Function

    Public Shared Function CreateURL(ByVal strPageType As Page, ByVal ID As Integer, Optional ByVal strParents As String = "", Optional ByVal ParentID As Integer = 0, _
                                     Optional ByVal CPagerID As Integer = 0, Optional ByVal PPagerID As Integer = 0, Optional ByVal strActiveTab As String = "p", Optional ByVal strRetrievedName As String = "") As String

        Dim numLangID As Integer = GetLanguageIDfromSession()

        Dim strUserCulture As String

        If LanguagesBLL.GetLanguagesCount > 1 Then
            If String.IsNullOrEmpty(HttpContext.Current.Session.Item("KartrisUserCulture")) Then
                strUserCulture = LanguagesBLL.GetCultureByLanguageID_s(LanguagesBLL.GetDefaultLanguageID()) & "/"
            Else
                strUserCulture = CStr(HttpContext.Current.Session.Item("KartrisUserCulture")) & "/"
            End If
        Else
            strUserCulture = ""
        End If


        Dim blnSEOLinks As Boolean = KartSettingsManager.GetKartConfig("general.seofriendlyurls.enabled") = "y"
        Dim strWebShopFolder As String = FixURLText(WebShopFolder())
        Dim strURL As String
        Select Case strPageType
            Case Page.Category
                If Left(strParents, 1) = "," Then strParents = Mid(strParents, 2)
                If blnSEOLinks Then
                    Dim strFriendlyParent As String = ""
                    Dim strCategoryName As String = ""
                    If Not (strParents = "" Or strParents = "0") Then
                        strFriendlyParent = Replace(strParents, ",", "-")
                        Dim strCategoryParents As String = ""

                        Dim arrParents As Array = Split(strFriendlyParent, "-")
                        For index As Integer = 0 To UBound(arrParents)
                            strCategoryParents += Replace(GetCategoryName(arrParents(index), numLangID, True), " ", "-") & "/"
                        Next

                        If String.IsNullOrEmpty(strRetrievedName) Then
                            strCategoryName = GetCategoryName(ID, numLangID, True)
                        Else
                            strCategoryName = CleanURL(strRetrievedName)
                        End If
                        strCategoryParents = strCategoryParents & Replace(strCategoryName, " ", "-")
                        strURL = String.Format("/{0}{6}{1}__c-{5}-{4}-{2}-{3}", strWebShopFolder, FixURLText(strCategoryParents), FixURLText(strFriendlyParent), ID, CPagerID & "-" & PPagerID, strActiveTab, strUserCulture)
                    Else
                        strURL = String.Format("/{2}{5}{0}__c-{4}-{3}-{1}", FixURLText(Replace(GetCategoryName(ID, numLangID, True), " ", "-")), ID, strWebShopFolder, CPagerID & "-" & PPagerID, strActiveTab, strUserCulture)
                    End If
                    strURL += ".aspx"
                    strURL = CkartrisDisplayFunctions.CleanURL(strURL)

                    'Check if URL length is greater than 280
                    If (strURL.Length + WebShopURL.Length - 1) > 280 Then
                        strURL = String.Format("/{0}{6}{1}__c-{5}-{4}-{2}-{3}", strWebShopFolder, FixURLText(Replace(strCategoryName, " ", "-")), FixURLText(strFriendlyParent), ID, CPagerID & "-" & PPagerID, strActiveTab, strUserCulture)
                        strURL += ".aspx"
                        strURL = CkartrisDisplayFunctions.CleanURL(strURL)
                        'If URL length is still greater than 280 post processing then just return a canonical link
                        If (strURL.Length + WebShopURL.Length - 1) > 280 Then strURL = CreateURL(Page.CanonicalCategory, ID)
                    End If

                Else
                    Dim strPageName As String = "~/Category.aspx"
                    If Not (strParents = "" Or strParents = "0") Then
                        strURL = String.Format("{0}?CategoryID={1}&strParent={2}", strPageName, ID, strParents)
                    Else
                        If ParentID = 0 Then
                            strURL = String.Format("{0}?CategoryID={1}", strPageName, ID)
                        Else
                            strURL = String.Format("{0}?CategoryID={1}&strParent={2}", strPageName, ID, ParentID)
                        End If
                    End If
                    'If numLangID > 1 Then strURL += "&L=" & numLangID
                    If CPagerID <> 0 Then strURL += "&CPGR=" & CPagerID
                    If PPagerID <> 0 Then strURL += "&PPGR=" & PPagerID
                    If strActiveTab = "s" Then strURL += "&T=S"
                End If
            Case Page.Product
                Dim strPageName As String = "~/Product.aspx"
                If strParents IsNot Nothing Then
                    If strParents.ToLower = "search" Then
                        strURL = String.Format("{0}?ProductID={1}&strParent=search", strPageName, ID)
                        Exit Select
                    End If
                End If

                If blnSEOLinks Then

                    Dim strFriendlyParent As String = ""
                    If strParents = "" Then
                        strURL = ""
                        If ParentID > 0 Then strURL = Replace(GetCategoryName(ParentID, numLangID, True), " ", "-") & "/"
                        strURL += Replace(GetProductName(ID, numLangID, True), " ", "-")
                        If ParentID > 0 Then
                            strURL = String.Format("/{3}{4}{0}__p-{2}-{1}", FixURLText(strURL), ID, ParentID, strWebShopFolder, strUserCulture)
                        Else
                            strURL = String.Format("/{2}{3}{0}__p-{1}", FixURLText(strURL), ID, strWebShopFolder, strUserCulture)
                        End If
                    Else
                        strFriendlyParent = Replace(strParents, ",", "-")
                        Dim strCategoryParents As String = ""
                        Dim arrParents As Array = Split(strFriendlyParent, "-")
                        For index As Integer = 0 To UBound(arrParents)

                            strCategoryParents += Replace(GetCategoryName(arrParents(index), numLangID, True), " ", "-") & "/"
                        Next

                        strCategoryParents += Replace(GetCategoryName(ParentID, numLangID, True), " ", "-") & "/" & Replace(GetProductName(ID, numLangID, True), " ", "-")

                        strURL = String.Format("/{4}{5}{0}__p-{3}-{2}-{1}", FixURLText(strCategoryParents), ID, ParentID, FixURLText(strFriendlyParent), strWebShopFolder, strUserCulture)
                    End If
                    strURL += ".aspx"
                    strURL = CkartrisDisplayFunctions.CleanURL(strURL)

                    'Check if URL length is greater than 280
                    If (strURL.Length + WebShopURL.Length - 1) > 280 Then
                        strURL = String.Format("/{4}{5}{0}__p-{3}-{2}-{1}", FixURLText(Replace(GetCategoryName(ParentID, numLangID, True), " ", "-") & "/" & Replace(GetProductName(ID, numLangID, True), " ", "-")), _
                                               ID, ParentID, FixURLText(strFriendlyParent), strWebShopFolder, strUserCulture)
                        strURL += ".aspx"
                        strURL = CkartrisDisplayFunctions.CleanURL(strURL)
                        'If URL length is still greater than 280 post processing then just return a canonical link
                        If (strURL.Length + WebShopURL.Length - 1) > 280 Then strURL = CreateURL(Page.CanonicalProduct, ID)
                    End If
                Else
                    If strParents = "" Then
                        If ParentID > 0 Then
                            strURL = String.Format("{0}?ProductID={1}&CategoryID={2}", strPageName, ID, ParentID)
                        Else
                            strURL = String.Format("{0}?ProductID={1}", strPageName, ID)
                        End If
                    Else
                        strURL = String.Format("{0}?ProductID={1}&CategoryID={2}&strParent={3}", strPageName, ID, ParentID, strParents)
                    End If
                    If numLangID > 1 Then strURL += "&L=" & numLangID
                End If
            Case Page.CanonicalProduct
                If blnSEOLinks Then
                    strURL = Replace(GetProductName(ID, numLangID, True), " ", "-")
                    strURL = String.Format("/{2}{3}{0}__p-{1}", FixURLText(strURL), ID, strWebShopFolder, strUserCulture)
                    strURL += ".aspx"
                    strURL = CkartrisDisplayFunctions.CleanURL(strURL)

                    If (strURL.Length + WebShopURL.Length - 1) > 280 Then
                        strURL = String.Format("/{2}{3}{0}__p-{1}", "", ID, strWebShopFolder, strUserCulture)
                        strURL += ".aspx"
                        strURL = CkartrisDisplayFunctions.CleanURL(strURL)
                    End If
                Else
                    Dim strPageName As String = WebShopURL() & "Product.aspx"
                    strURL = String.Format("{0}?ProductID={1}", strPageName, ID)
                    If numLangID > 1 Then strURL += "&L=" & numLangID
                End If
            Case Page.CanonicalCategory
                If blnSEOLinks Then
                    strURL = String.Format("/{2}{4}{0}__c-{3}-0-0-{1}", FixURLText(Replace(GetCategoryName(ID, numLangID, True), " ", "-")), ID, strWebShopFolder, strActiveTab, strUserCulture)
                    strURL += ".aspx"
                    strURL = CkartrisDisplayFunctions.CleanURL(strURL)
                    If (strURL.Length + WebShopURL.Length - 1) > 280 Then
                        strURL = String.Format("/{2}{4}{0}__c-{3}-0-0-{1}", "", ID, strWebShopFolder, strActiveTab, strUserCulture)
                        strURL += ".aspx"
                        strURL = CkartrisDisplayFunctions.CleanURL(strURL)
                    End If
                Else
                    Dim strPageName As String = WebShopURL() & "Category.aspx"
                    strURL = String.Format("{0}?CategoryID={1}", strPageName, ID)
                    If numLangID > 1 Then strURL += "&L=" & numLangID
                End If
            Case Page.News
                If blnSEOLinks Then
                    strURL = String.Format("/{2}{3}{0}__n-{1}", FixURLText(Replace(GetNewsTitle(ID, numLangID), " ", "-")), ID, strWebShopFolder, strUserCulture)
                    strURL += ".aspx"
                    strURL = CkartrisDisplayFunctions.CleanURL(strURL)
                Else
                    Dim strPageName As String = WebShopURL() & "News.aspx"
                    strURL = String.Format("{0}?NewsID={1}", strPageName, ID)
                End If
            Case Page.Search
                Dim strPageName As String = "~/Search.aspx?strResults=y"
                strURL = strPageName
                If PPagerID <> 0 Then strURL += "&PPGR=" & PPagerID
                If numLangID > 1 Then strURL += "&L=" & numLangID
            Case Page.Knowledgebase
                If blnSEOLinks Then
                    strURL = String.Format("/{2}{3}{4}{0}__k-{1}", FixURLText(Replace(GetKnowledgebaseTitle(ID, numLangID), " ", "-")), ID, strWebShopFolder, strUserCulture, FixURLText(GetGlobalResourceObject("Knowledgebase", "PageTitle_Knowledgebase")) & "/")
                    strURL += ".aspx"
                    strURL = CkartrisDisplayFunctions.CleanURL(strURL)
                Else
                    Dim strPageName As String = WebShopURL() & "Knowledgebase.aspx"
                    strURL = String.Format("{0}?kb={1}", strPageName, ID)
                End If
            Case Else
                Return Nothing
        End Select

        Return TrimBadChars(strURL)
    End Function

    Private Shared Function TrimBadChars(ByVal strURL As String) As String
        Dim strTrimmedURL As String = strURL

        'Trim double dots
        Try
            While InStr(strTrimmedURL, "..") > 0
                strTrimmedURL = Replace(strTrimmedURL, "..", ".")
            End While
        Catch ex As Exception
            strTrimmedURL = strURL
        End Try

        'Trim plus sign
        strTrimmedURL = Replace(strTrimmedURL, "+", "")

        'Trim dot-slash
        strTrimmedURL = Replace(strTrimmedURL, "./", "/")

        'Trim double quote sign
        strTrimmedURL = Replace(strTrimmedURL, """", "")

        Return strTrimmedURL
    End Function

    Private Shared Function FixURLText(ByVal strText As String) As String
        If String.IsNullOrEmpty(strText) Then Return strText
        Return strText.Replace("__", "_")
    End Function

    Public Shared Function FindItemBackEndURL(ByVal strCurrentPath As String) As String
        Dim arrKeys As Array
        Dim strWebShopFolder As String = "~/"
        Dim strQueryStrings As String = ""
        'Extract the language and culture info from the friendly URL
        strCurrentPath = LCase(Replace(strCurrentPath, ":80", ""))
        Dim strWebShopURL As String
        Dim strURLCultureInfo As String
        Dim strOriginalPath As String = strCurrentPath

        If InStr(strCurrentPath, WebShopURL) Then
            strWebShopURL = LCase(WebShopURL())
        Else
            strWebShopURL = LCase(WebShopFolder())
        End If
        Dim numLangID As Short
        If LanguagesBLL.GetLanguagesCount > 1 Then
            strURLCultureInfo = Left(Mid(strCurrentPath, InStr(strCurrentPath, strWebShopURL) + Len(strWebShopURL)), 5)
            numLangID = LanguagesBLL.GetLanguageIDByCulture_s(strURLCultureInfo)
        Else
            numLangID = LanguagesBLL.GetDefaultLanguageID
        End If

        If numLangID = 0 Then numLangID = GetLanguageIDfromSession()

        If strCurrentPath.Contains(".aspx?") Then
            strQueryStrings = "&" & Mid(strCurrentPath, strCurrentPath.LastIndexOf("?") + 2)
            strCurrentPath = Left(strCurrentPath, strCurrentPath.LastIndexOf("?"))
        End If

        If Right(strCurrentPath, 5) = ".aspx" Then strCurrentPath = Left(strCurrentPath, Len(strCurrentPath) - 5)

        'What kind of page is this?
        If (strCurrentPath.ToLower.Contains("__c-")) Then
            '-----------------------------------
            'Category
            '-----------------------------------
            Dim strParent As String = strCurrentPath.Substring(strCurrentPath.IndexOf("__c-") + 4)
            arrKeys = Split(strParent, "-")
            Dim intUpper As Integer = UBound(arrKeys)
            Dim strOutput As String
            If intUpper = 3 Then
                strOutput = "Admin/_ModifyCategory.aspx?CategoryID=" + arrKeys(intUpper) + "&CPGR=" + arrKeys(1) + "&PPGR=" + arrKeys(2)
            ElseIf intUpper = 4 Then
                strOutput = "Admin/_ModifyCategory.aspx?CategoryID=" + arrKeys(4) + "&strParent=" + arrKeys(3) + "&CPGR=" + arrKeys(1) + "&PPGR=" + arrKeys(2)
            ElseIf intUpper > 4 Then
                strParent = arrKeys(3)
                For ctr As Integer = 4 To (intUpper - 1)
                    strParent += "," & arrKeys(ctr)
                Next
                strOutput = "Admin/_ModifyCategory.aspx?CategoryID=" + arrKeys(intUpper).ToString + "&strParent=" + strParent + "&CPGR=" + arrKeys(1) + "&PPGR=" + arrKeys(2)
            Else : strOutput = ""
            End If
            If arrKeys(0) = "s" Then strOutput += "&T=S"
            strOutput += "&L=" & numLangID
            Return strWebShopFolder & strOutput
        ElseIf (strOriginalPath.Contains("category.aspx?categoryid=")) Then
            '-----------------------------------
            'Category QS Parameterized Link
            '-----------------------------------
            Dim strParent As String = strOriginalPath.Substring(strOriginalPath.IndexOf("category.aspx?categoryid=") + 25)
            Return strWebShopFolder & "Admin/_ModifyCategory.aspx?CategoryID=" & strParent
        ElseIf (strCurrentPath.ToLower.Contains("__p-")) Then
            '-----------------------------------
            'Product
            '-----------------------------------
            Dim strOptions As String = ""
            If strCurrentPath.ToLower.Contains("?stroptions=") Then strOptions = strCurrentPath.Substring(strCurrentPath.ToLower.IndexOf("?stroptions=") + 12)
            Dim strParent As String
            Dim intIDstartindex = strCurrentPath.IndexOf("__p-") + 4
            If String.IsNullOrEmpty(strOptions) Then
                strParent = strCurrentPath.Substring(intIDstartindex)
            Else
                strParent = strCurrentPath.Substring(intIDstartindex, strCurrentPath.LastIndexOf(".aspx") - intIDstartindex)
            End If

            arrKeys = Split(strParent, "-")
            Dim intUpper As Integer = UBound(arrKeys)
            Dim strOutputURL As String
            If intUpper = 0 Then
                strOutputURL = strWebShopFolder & "Admin/_ModifyProduct.aspx?ProductID=" + arrKeys(intUpper).ToString
            ElseIf intUpper = 1 Then
                strOutputURL = strWebShopFolder & "Admin/_ModifyProduct.aspx?ProductID=" + arrKeys(1).ToString + "&CategoryID=" + arrKeys(0)
            ElseIf intUpper > 1 Then
                strParent = arrKeys(0)
                If intUpper > 2 Then
                    For ctr As Integer = 1 To intUpper - 2
                        strParent += "," & arrKeys(ctr)
                    Next
                End If
                strOutputURL = strWebShopFolder & "Admin/_ModifyProduct.aspx?ProductID=" + arrKeys(intUpper).ToString + "&CategoryID=" + arrKeys(intUpper - 1) + "&strParent=" + strParent
            Else
                strOutputURL = ""
            End If
            strOutputURL += "&L=" & numLangID
            If Not String.IsNullOrEmpty(strOptions) Then strOutputURL += "&strOptions=" & strOptions
            Return strOutputURL
        ElseIf (strOriginalPath.Contains("product.aspx?productid=")) Then
            '-----------------------------------
            'Product QS Parameterized Link
            '-----------------------------------
            Dim strParent As String = strOriginalPath.Substring(strOriginalPath.IndexOf("product.aspx?productid=") + 23)
            Return strWebShopFolder & "Admin/_ModifyProduct.aspx?ProductID=" & strParent
        ElseIf (strCurrentPath.ToLower.Contains("__n-")) Then
            '-----------------------------------
            'News
            '-----------------------------------
            Dim strParent As String = strCurrentPath.Substring(strCurrentPath.IndexOf("__n-") + 4)
            strParent = CInt(Replace(strParent, "_", ""))
            Return strWebShopFolder & "Admin/_SiteNews.aspx?NewsID=" & strParent
        ElseIf (strOriginalPath.Contains("news.aspx?newsid=")) Then
            '-----------------------------------
            'News QS Parameterized Link
            '-----------------------------------
            Dim strParent As String = strOriginalPath.Substring(strOriginalPath.IndexOf("news.aspx?newsid=") + 17)
            Return strWebShopFolder & "Admin/_SiteNews.aspx?NewsID=" & strParent
        ElseIf (strCurrentPath.ToLower.Contains("/news")) Then
            '-----------------------------------
            'News Home
            '-----------------------------------
            Return strWebShopFolder & "Admin/_SiteNews.aspx"
        ElseIf (strCurrentPath.ToLower.Contains("/t-")) Then
            '-----------------------------------
            'CMS Page
            '-----------------------------------
            Dim strParent As String = strCurrentPath.Substring(strCurrentPath.IndexOf("/t-") + 3)
            strParent = Replace(strParent, "/", "")
            Return strWebShopFolder & "Admin/_CustomPages.aspx?test=test&strPage=" & strParent
        ElseIf (strOriginalPath.Contains("/page.aspx?strpage=")) Then
            '-----------------------------------
            'CMS Page QS Parameterized Link
            '-----------------------------------
            Dim strParent As String = strOriginalPath.Substring(strOriginalPath.IndexOf("/page.aspx?strpage=") + 19)
            Return strWebShopFolder & "Admin/_CustomPages.aspx?strPage=" & strParent
        ElseIf (strCurrentPath.ToLower.Contains("/default")) Then
            '-----------------------------------
            'Home Page
            '-----------------------------------
            Return strWebShopFolder & "Admin/Default.aspx"
        ElseIf (strCurrentPath.ToLower.Contains("__k-")) Then
            '-----------------------------------
            'Knowledgebase
            '-----------------------------------
            Dim strParent As String = strCurrentPath.Substring(strCurrentPath.IndexOf("__k-") + 4)
            strParent = Replace(strParent, "_", "")
            Return strWebShopFolder & "Admin/_Knowledgebase.aspx?kb=" & strParent
        ElseIf strOriginalPath.Contains("knowledgebase.aspx?kb=") Then
            '-----------------------------------
            'Knowledgebase QS Parameterized Link
            '-----------------------------------
            Dim strParent As String = strOriginalPath.Substring(strOriginalPath.IndexOf("knowledgebase.aspx?kb=") + 22)
            Return strWebShopFolder & "Admin/_Knowledgebase.aspx?kb=" & strParent
        ElseIf (strCurrentPath.ToLower.Contains("/knowledgebase")) Then
            '-----------------------------------
            'Knowledgebase home
            '-----------------------------------
            Return strWebShopFolder & "Admin/_Knowledgebase.aspx"
        Else
            Return ""
        End If
    End Function

    Friend Shared Function SEORewrite(ByVal strCurrentPath As String) As String
        Dim arrKeys As Array
        Dim strWebShopFolder As String = "~/"
        Dim strQueryStrings As String = ""
        'Extract the language and culture info from the friendly URL
        'Dim strURLCultureInfo As String = Left(Replace(LCase(strCurrentPath), LCase(WebShopURL), ""), 5)
        strCurrentPath = LCase(Replace(strCurrentPath, ":80", ""))
        Dim strWebShopURL As String
        Dim strURLCultureInfo As String
        If InStr(strCurrentPath, WebShopURL) Then
            strWebShopURL = LCase(WebShopURL())
        Else
            strWebShopURL = LCase(WebShopFolder())
        End If
        Dim numLangID As Short
        If LanguagesBLL.GetLanguagesCount > 1 Then
            If Len(strWebShopURL) = 0 Then
                '' There is no webshopurl (coming from no webshop folder), means we need to
                ''   skip the first character because the strCurrentPath will be similar to
                ''      "/nl-NL/CATEGORY_OR_PRODUCT_NAME", so to read the language do:
                strURLCultureInfo = Mid(strCurrentPath, 2, 5)
            Else
                strURLCultureInfo = Left(Mid(strCurrentPath, InStr(strCurrentPath, strWebShopURL) + Len(strWebShopURL)), 5)
            End If
            numLangID = LanguagesBLL.GetLanguageIDByCulture_s(strURLCultureInfo)
        Else
            numLangID = LanguagesBLL.GetDefaultLanguageID
        End If

            If numLangID = 0 Then numLangID = GetLanguageIDfromSession()

            If strCurrentPath.Contains(".aspx?") Then
                strQueryStrings = "&" & Mid(strCurrentPath, strCurrentPath.LastIndexOf("?") + 2)
                strCurrentPath = Left(strCurrentPath, strCurrentPath.LastIndexOf("?"))
            End If
            If Right(strCurrentPath, 5) = ".aspx" Then strCurrentPath = Left(strCurrentPath, Len(strCurrentPath) - 5)
            'If Right(strCurrentPath, 1) = "/" Then strCurrentPath = Left(strCurrentPath, Len(strCurrentPath) - 1)
            If (strCurrentPath.Contains("__c-")) Then
                Dim strParent As String = strCurrentPath.Substring(strCurrentPath.IndexOf("__c-") + 4)
                arrKeys = Split(strParent, "-")
                Dim intUpper As Integer = UBound(arrKeys)
                Dim strOutput As String
                If intUpper = 3 Then
                    strOutput = "Category.aspx?CategoryID=" + arrKeys(intUpper) + "&CPGR=" + arrKeys(1) + "&PPGR=" + arrKeys(2)
                ElseIf intUpper = 4 Then
                    strOutput = "Category.aspx?CategoryID=" + arrKeys(4) + "&strParent=" + arrKeys(3) + "&CPGR=" + arrKeys(1) + "&PPGR=" + arrKeys(2)
                ElseIf intUpper > 4 Then
                    strParent = arrKeys(3)
                    For ctr As Integer = 4 To (intUpper - 1)
                        strParent += "," & arrKeys(ctr)
                    Next
                    strOutput = "Category.aspx?CategoryID=" + arrKeys(intUpper).ToString + "&strParent=" + strParent + "&CPGR=" + arrKeys(1) + "&PPGR=" + arrKeys(2)
                Else : strOutput = ""
                End If
                If arrKeys(0) = "s" Then strOutput += "&T=S"
                strOutput += "&L=" & numLangID
                Return strWebShopFolder & strOutput & strQueryStrings
            ElseIf (strCurrentPath.Contains("__p-")) Then
                Dim strOptions As String = ""
                If strCurrentPath.ToLower.Contains("?stroptions=") Then strOptions = strCurrentPath.Substring(strCurrentPath.ToLower.IndexOf("?stroptions=") + 12)
                Dim strParent As String
                Dim intIDstartindex = strCurrentPath.IndexOf("__p-") + 4
                If String.IsNullOrEmpty(strOptions) Then
                    strParent = strCurrentPath.Substring(intIDstartindex)
                Else
                    strParent = strCurrentPath.Substring(intIDstartindex, strCurrentPath.LastIndexOf(".aspx") - intIDstartindex)
                End If

                arrKeys = Split(strParent, "-")
                Dim intUpper As Integer = UBound(arrKeys)
                Dim strOutputURL As String
                If intUpper = 0 Then
                    strOutputURL = strWebShopFolder & "Product.aspx?ProductID=" + arrKeys(intUpper).ToString
                ElseIf intUpper = 1 Then
                    strOutputURL = strWebShopFolder & "Product.aspx?ProductID=" + arrKeys(1).ToString + "&CategoryID=" + arrKeys(0)
                ElseIf intUpper > 1 Then
                    strParent = arrKeys(0)
                    If intUpper > 2 Then
                        For ctr As Integer = 1 To intUpper - 2
                            strParent += "," & arrKeys(ctr)
                        Next
                    End If
                    strOutputURL = strWebShopFolder & "Product.aspx?ProductID=" + arrKeys(intUpper).ToString + "&CategoryID=" + arrKeys(intUpper - 1) + "&strParent=" + strParent
                Else
                    strOutputURL = ""
                End If
                strOutputURL += "&L=" & numLangID
                If Not String.IsNullOrEmpty(strOptions) Then strOutputURL += "&strOptions=" & strOptions
                Return strOutputURL & strQueryStrings
            ElseIf (strCurrentPath.Contains("__n-")) Then
                Dim strParent As String = strCurrentPath.Substring(strCurrentPath.IndexOf("__n-") + 4)
                strParent = CInt(Replace(strParent, "_", ""))
                Return strWebShopFolder & "News.aspx?NewsID=" & strParent & strQueryStrings
            ElseIf (strCurrentPath.Contains("/t-")) Then
                Dim strParent As String = strCurrentPath.Substring(strCurrentPath.IndexOf("/t-") + 3)
                strParent = Replace(strParent, "/", "")
                Return strWebShopFolder & "Page.aspx?strPage=" & strParent & strQueryStrings
            ElseIf (strCurrentPath.Contains("__k-")) Then
                Dim strParent As String = strCurrentPath.Substring(strCurrentPath.IndexOf("__k-") + 4)
                strParent = Replace(strParent, "_", "")
                Return strWebShopFolder & "Knowledgebase.aspx?kb=" & strParent & strQueryStrings
            Else
                Return ""
            End If
    End Function

    Private Shared Function GetCategoryName(ByVal numCategoryID As Integer, ByVal numLanguageID As Short, Optional ByVal blnCheckURLName As Boolean = False) As String
        If numCategoryID = 0 Then Return ""
        Dim strCategoryNameInURL As String = ""
        If blnCheckURLName Then
            strCategoryNameInURL = LanguageElementsBLL.GetElementValue( _
            numLanguageID, CkartrisEnumerations.LANG_ELEM_TABLE_TYPE.Categories, CkartrisEnumerations.LANG_ELEM_FIELD_NAME.URLName, numCategoryID)
        End If

        If strCategoryNameInURL.ToLower = "# -le- #" Then
            strCategoryNameInURL = CategoriesBLL.GetNameByCategoryID(numCategoryID, numLanguageID)
        End If

        'URL Safe
        Return CleanURL(strCategoryNameInURL)
    End Function

    Private Shared Function GetProductName(ByVal numProductID As Integer, ByVal numLanguageID As Short, Optional ByVal blnCheckURLName As Boolean = False) As String
        Dim strProductNameInURL As String = ""
        If blnCheckURLName Then
            strProductNameInURL = LanguageElementsBLL.GetElementValue( _
            numLanguageID, CkartrisEnumerations.LANG_ELEM_TABLE_TYPE.Products, CkartrisEnumerations.LANG_ELEM_FIELD_NAME.URLName, numProductID)
        End If

        If strProductNameInURL.ToLower = "# -le- #" Or strProductNameInURL = "" Then
            strProductNameInURL = ProductsBLL.GetNameByProductID(numProductID, numLanguageID)
        End If

        Return strProductNameInURL
    End Function

    Private Shared Function GetNewsTitle(ByVal numNewsID As Integer, ByVal numLanguageID As Short) As String
        Return StripHTML(NewsBLL.GetNewsTitleByID(numNewsID, numLanguageID))
    End Function

    Private Shared Function GetKnowledgebaseTitle(ByVal numKBID As Integer, ByVal numLanguageID As Short) As String
        Return KBBLL.GetKBTitleByID(numLanguageID, numKBID)
    End Function

End Class
#End Region

#Region "BACKEND CATEGORY SITEMAP PROVIDER"
Public Class _CategorySiteMapProvider

    Inherits StaticSiteMapProvider

    Public Enum BackEndPage
        Product
        Category
        Page
        Search
    End Enum

    Private _isInitialized As Boolean = False
    Private _rootNode As SiteMapNode

    Private _connectionString As String
    Private _navigateUrl As String
    Private _idFieldName As String

    Private Const _cacheDependencyName As String = "__SiteMapCacheDependency"

    ' Database info for SQL Server 7/2000 cache dependency 
    Private _2005dependency As Boolean = False
    ' Database info for SQL Server 2005 cache dependency 
    Private _indexID As Integer, _indexTitle As Integer, _indexUrl As Integer, _indexDesc As Integer, _indexRoles As Integer, _indexParent As Integer
    'Private _nodes As New Dictionary(Of Integer, SiteMapNode)(16)
    Private ReadOnly _lock As New Object()
    Private _root As SiteMapNode

    ''' <summary>
    ''' Loads configuration settings from Web configuration file
    ''' </summary>
    Public Overrides Sub Initialize(ByVal name As String, ByVal attributes As NameValueCollection)
        If _isInitialized Then
            Return
        End If

        MyBase.Initialize(name, attributes)

        ' Get database connection string from config file
        Dim connectionStringName As String = attributes("connectionStringName")
        If (String.IsNullOrEmpty(connectionStringName)) Then
            Throw New Exception("You must provide a connectionStringName attribute")
        End If
        _connectionString = WebConfigurationManager.ConnectionStrings(connectionStringName).ConnectionString
        If (String.IsNullOrEmpty(_connectionString)) Then
            Throw New Exception("Could not find connection String " + connectionStringName)
        End If

        ' Get navigateUrl from config file
        _navigateUrl = attributes("navigateUrl")
        If (String.IsNullOrEmpty(_navigateUrl)) Then
            Throw New Exception("You must provide a navigateUrl attribute")
        End If

        ' Get idFieldName from config file
        _idFieldName = attributes("idFieldName")
        If String.IsNullOrEmpty(_idFieldName) Then
            _idFieldName = "CategoryID"
        End If
        _isInitialized = True
    End Sub

    ''' <summary>
    ''' Retrieve the root node by building the Site Map
    ''' </summary>
    Protected Overrides Function GetRootNodeCore() As SiteMapNode
        Dim context As HttpContext = HttpContext.Current
        Return BuildSiteMap()
    End Function

    ''' <summary>
    ''' Resets the Site Map by deleting the 
    ''' root node. This causes the BuildSiteMap()
    ''' method to rebuild the Site Map
    ''' </summary>
    Public Sub ResetSiteMap()
        _rootNode = Nothing
    End Sub

    ''' <summary>
    ''' Build the Site Map by retrieving
    ''' records from database table
    ''' </summary>
    Public Overrides Function BuildSiteMap() As SiteMapNode
        ' Only allow the Site Map to be created by a single thread
        SyncLock Me
            If _rootNode Is Nothing Then
                ' Show trace for debugging
                Dim context As HttpContext = HttpContext.Current
                HttpContext.Current.Trace.Warn("Loading back-end category site map from database")

                ' Clear current Site Map
                Clear()

                ' Load the database data
                Dim tblSiteMap As DataTable = GetSiteMapFromDB()
                ' Set the root node
                Dim strCategoryLabel As String = HttpContext.GetGlobalResourceObject("Kartris", "ContentText_Categories")
                _rootNode = New SiteMapNode(Me, "0", "~/Admin/_Category.aspx", strCategoryLabel, strCategoryLabel)

                AddNode(_rootNode)

                ' Build the child nodes 
                BuildSiteMapRecurse(tblSiteMap, _rootNode, 0)
            End If
            Return _rootNode
        End SyncLock
    End Function

    ''' <summary>
    ''' Load the contents of the database table
    ''' that contains the Site Map
    ''' </summary>
    Private Function GetSiteMapFromDB() As DataTable
        Dim numLANGID As Int16
        If String.IsNullOrEmpty(HttpContext.Current.Session.Item("_LANG")) Then
            numLANGID = 1
        Else
            numLANGID = CInt(HttpContext.Current.Session.Item("_LANG"))
        End If
        Return CategoriesBLL._GetHierarchyByLangaugeID(numLANGID)
    End Function

    ''' <summary>
    ''' Recursively build the Site Map from the DataTable
    ''' </summary>
    Private Sub BuildSiteMapRecurse(ByVal siteMapTable As DataTable, ByVal parentNode As SiteMapNode, ByVal parentkey As String)
        Dim arr As Array = Split(parentNode.Key, ",")
        Dim results() As DataRow = siteMapTable.Select("ParentID=" & arr(UBound(arr)))
        For Each row As DataRow In results
            Dim url As String
            Dim strParentKey As String
            If Left(parentkey, 2) = "0," Then strParentKey = Mid(parentkey, 3) Else strParentKey = parentkey
            If strParentKey = "0" Then strParentKey = ""
            If strParentKey <> "" Then strParentKey = strParentKey & "," & row("parentid") Else strParentKey = row("parentid")

            url = CreateURL(BackEndPage.Category, row("CAT_ID"), strParentKey)
            Dim node As New SiteMapNode(Me, strParentKey & "," & row("CAT_ID").ToString(), url, row("title").ToString())
            AddNode(node, parentNode)
            BuildSiteMapRecurse(siteMapTable, node, parentNode.Key)
        Next
    End Sub

    Public Shared Function CreateURL(ByVal strPageType As BackEndPage, ByVal ID As Integer, Optional ByVal strParents As String = "", Optional ByVal ParentID As Integer = 0, Optional ByVal CPagerID As Integer = 0, Optional ByVal PPagerID As Integer = 0, Optional ByVal strActiveTab As String = "p") As String
        Dim numLangID As Integer
        If String.IsNullOrEmpty(HttpContext.Current.Session.Item("_LANG")) Then
            numLangID = 1
        Else
            numLangID = CInt(HttpContext.Current.Session.Item("_LANG"))
        End If
        Dim strUserCulture As String
        If String.IsNullOrEmpty(HttpContext.Current.Session.Item("KartrisUserCulture")) Then
            strUserCulture = "en/"
        Else
            strUserCulture = CStr(HttpContext.Current.Session.Item("KartrisUserCulture")) & "/"
        End If

        Dim strWebShopFolder As String = KartSettingsManager.GetKartConfig("general.webshopfolder")
        Dim strURL As String
        Select Case strPageType
            Case BackEndPage.Category
                If Left(strParents, 1) = "," Then strParents = Mid(strParents, 2)
                Dim strPageName As String = "~/Admin/_Category.aspx"
                If Not (strParents = "" Or strParents = "0") Then
                    strURL = String.Format("{0}?CategoryID={1}&strParent={2}", strPageName, ID, strParents)
                Else
                    If ParentID = 0 Then
                        strURL = String.Format("{0}?CategoryID={1}", strPageName, ID)
                    Else
                        strURL = String.Format("{0}?CategoryID={1}&strParent={2}", strPageName, ID, ParentID)
                    End If
                End If
                If CPagerID <> 0 Then strURL += "&CPGR=" & CPagerID
                If PPagerID <> 0 Then strURL += "&PPGR=" & PPagerID
                If strActiveTab = "s" Then strURL += "&T=S"
            Case BackEndPage.Product
                If Left(strParents, 1) = "," Then strParents = Mid(strParents, 2)
                Dim strPageName As String = "~/Admin/_ModifyProduct.aspx"
                If Not (strParents = "" Or strParents = "0") Then
                    strURL = String.Format("{0}?ProductID={1}&strParent={2}", strPageName, ID, strParents)
                Else
                    If ParentID = 0 Then
                        strURL = String.Format("{0}?ProductID={1}", strPageName, ID)
                    Else
                        strURL = String.Format("{0}?ProductID={1}&strParent={2}", strPageName, ID, ParentID)
                    End If
                End If
                If CPagerID <> 0 Then strURL += "&CPGR=" & CPagerID
                If PPagerID <> 0 Then strURL += "&PPGR=" & PPagerID
                If strActiveTab = "s" Then strURL += "&T=S"
            Case Else
                Return Nothing
        End Select
        Return strURL
    End Function
End Class
#End Region