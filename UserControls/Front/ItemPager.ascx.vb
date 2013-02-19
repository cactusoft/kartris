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

''' <summary>
''' Item Pager is used to Create a Pager for a list of Items, depending on the total number of Items
'''   and number of items per page.
''' In order to create a pager for an Item, You need to call the Method "LoadPager" with 3 parameters
'''    1.(Total Number Of Items)  2.(Number Of Items Per Page)  3.(URL Query String Key)
''' The 3rd parameter (URL Key), is used to hold the Item's page number.
''' </summary>
''' <remarks>By Mohammad</remarks>
Partial Class ItemPager
    Inherits System.Web.UI.UserControl

    Private NoOfPages As Short
    Private GroupPager As Short
    Private TotalItems As Integer
    Private ItemsPerPage As Short
    Private QueryStringKey As String
    Private intCurrentGroup As Integer = 0

    ''' <summary>
    ''' Loads/Creates the Pages of the Pager.
    ''' </summary>
    ''' <param name="pTotalItems">Total Number of Items</param>
    ''' <param name="pItemsPerPage">Number of Items in each page.</param>
    ''' <param name="pQueryStringKey">The URL related Pager Key, to hold the page index </param>
    ''' <remarks>By Mohammad</remarks>
    Public Sub LoadPager(ByVal pTotalItems As Integer, ByVal pItemsPerPage As Short, ByVal pQueryStringKey As String)

        TotalItems = pTotalItems
        ItemsPerPage = pItemsPerPage
        GroupPager = CShort(KartSettingsManager.GetKartConfig("general.paging.group.size"))

        '' Gets the number of pages to be created in the Pager.
        NoOfPages = Math.Ceiling(pTotalItems / pItemsPerPage)

        'Hide pager if only one page of results
        If NoOfPages = 1 Then phdWrapper.Visible = False Else phdWrapper.Visible = True


        QueryStringKey = pQueryStringKey

        Dim intPageNumber As Integer = CInt(Request.QueryString(QueryStringKey))
        If intPageNumber + 1 > GroupPager Then
            intCurrentGroup = Math.Floor(intPageNumber / GroupPager)
        End If





        ''****************************** STEP 1 ******************************
        ''---------- Creating the '<< Pervious' link ----------------------------
        Dim lnkPrevious As New HyperLink
        With lnkPrevious
            .ID = "lnkPrevious"     '' The link ID, to be referenced easily.
            .Text = " « "  '' The link Text, that will be viewed.
            .NavigateUrl = GetURL(CShort(Request.QueryString(QueryStringKey)) - 1)  '' The link Redirect URL.
            .CssClass = "arrow previous"
        End With
        '' Adding the link to the pager.
        phdPages.Controls.Add(lnkPrevious)
        ''-----------------------------------------------------------------------

        If NoOfPages > GroupPager Then
            ''****************************** STEP 1 ******************************
            ''---------- Creating the '<< Pervious' link ----------------------------
            Dim lnkPreviousGroup As New HyperLink
            With lnkPreviousGroup
                .ID = "lnkPreviousGroup"     '' The link ID, to be referenced easily.
                .Text = " ... " '& GroupPager  '' The link Text, that will be viewed.
                .NavigateUrl = GetURL(CShort((intCurrentGroup - 1) * GroupPager))  '' The link Redirect URL.
                .CssClass = "arrow previous"
            End With
            If intPageNumber < GroupPager Then
                lnkPreviousGroup.NavigateUrl = ""
                lnkPreviousGroup.CssClass = "arrow disabled"
            End If
            '' Adding the link to the pager.
            phdPages.Controls.Add(lnkPreviousGroup)
            ''-----------------------------------------------------------------------
        End If

        If NoOfPages > GroupPager Then

            Dim maxPageGroup As Integer = ((intCurrentGroup + 1) * (GroupPager))
            If maxPageGroup = (NoOfPages + 1) Then maxPageGroup = NoOfPages

            For i As Short = (intCurrentGroup * GroupPager) To maxPageGroup - 1
                Dim lnkPage As New HyperLink
                With lnkPage
                    .ID = "lnkPage" & i         '' The link ID, to be referenced easily.
                    .Text = " " & i + 1 & " "   '' The link Text, that will be viewed.
                    .NavigateUrl = GetURL(i)    '' The link Redirect URL.
                End With
                '' Adding the link to the pager.
                phdPages.Controls.Add(lnkPage)
            Next
        Else
            ''****************************** STEP 2 ******************************
            ''---------- Creating the pages' links (1 2 3 ...) ----------------------
            For i As Short = 0 To NoOfPages - 1
                Dim lnkPage As New HyperLink
                With lnkPage
                    .ID = "lnkPage" & i         '' The link ID, to be referenced easily.
                    .Text = " " & i + 1 & " "   '' The link Text, that will be viewed.
                    .NavigateUrl = GetURL(i)    '' The link Redirect URL.
                End With
                '' Adding the link to the pager.
                phdPages.Controls.Add(lnkPage)
            Next
            ''-----------------------------------------------------------------------
        End If

        If NoOfPages > GroupPager Then
            ''****************************** STEP 1 ******************************
            ''---------- Creating the '>> Next Group' link ----------------------------
            Dim lnkNextGroup As New HyperLink
            With lnkNextGroup
                .ID = "lnkNextGroup"     '' The link ID, to be referenced easily.
                .Text = " ... " '& GroupPager & " » " '' The link Text, that will be viewed.
                .NavigateUrl = GetURL(CShort((intCurrentGroup + 1) * GroupPager))  '' The link Redirect URL.
                .CssClass = "arrow next"
            End With
            If intCurrentGroup = Math.Floor((NoOfPages - 1) / GroupPager) Then
                lnkNextGroup.NavigateUrl = ""
                lnkNextGroup.CssClass = "arrow disabled"
            End If
            '' Adding the link to the pager.
            phdPages.Controls.Add(lnkNextGroup)
            ''-----------------------------------------------------------------------
        End If

        ''****************************** STEP 3 ******************************
        ''---------- Creating the ' Next >> ' link ----------------------------
        Dim lnkNext As New HyperLink
        With lnkNext
            .ID = "lnkNext"     '' The link ID, to be referenced easily.
            .Text = " » "  '' The link Text, that will be viewed. [hardcode]
            .NavigateUrl = GetURL(CShort(Request.QueryString(QueryStringKey)) + 1) '' The link Redirect URL.
            .CssClass = "arrow next"
        End With
        '' Adding the link to the pager.
        phdPages.Controls.Add(lnkNext)
        ''-----------------------------------------------------------------------



    End Sub

    ''' <summary>
    ''' Creates the Navigation(Redirect) URL of the link.
    ''' </summary>
    ''' <param name="pPageIndx">The Index of the Page you need to Create its URL</param>
    ''' <returns></returns>
    ''' <remarks>By Mohammad</remarks>
    Private Function GetURL(ByVal pPageIndx As Short) As String

        Dim strCurrentUrl As String, strActualUrl As String = ""

        '' Gets the Current Address URL to be manipulated
        strCurrentUrl = Request.Url.ToString()

        Dim strActiveTab As String = "p"
        Dim intCPGRID As Integer = CInt(Request.QueryString("CPGR"))
        Dim intPPGRID As Integer = CInt(Request.QueryString("PPGR"))
        If QueryStringKey = "PPGR" Then intPPGRID = pPageIndx
        If QueryStringKey = "CPGR" Then
            intCPGRID = pPageIndx
            strActiveTab = "s"
        End If
        Dim strScriptName As String = Page.Request.Url.ToString.ToLower

        If InStr(LCase(strScriptName), "/search.aspx") Then
            strActualUrl = SiteMapHelper.CreateURL(SiteMapHelper.Page.Search, 0, , , , intPPGRID)
        Else
            strActualUrl = SiteMapHelper.CreateURL(SiteMapHelper.Page.Category, Request.QueryString("CategoryID"), Request.QueryString("strParent"), , intCPGRID, intPPGRID, strActiveTab)
        End If

        If strActiveTab = "s" And KartSettingsManager.GetKartConfig("general.seofriendlyurls.enabled") <> "y" Then
            If Not strCurrentUrl.Contains("&T=S") Then strActualUrl += "&T=S"
        Else
            If InStr(strScriptName, "search.aspx") = -1 Then strActualUrl = strActualUrl.Replace("&T=S", "")
        End If

        Return strActualUrl
    End Function

    ''' <summary>
    ''' Disables the link of current Page.
    ''' </summary>
    ''' <param name="pLinkNo">The page number to be disabled(Actually, the value of the URL Pager Key)</param>
    ''' <remarks></remarks>
    Public Sub DisableLink(ByVal pLinkNo As Short)
        For Each obj As Object In phdPages.Controls
            If obj.ID = "lnkPage" & pLinkNo Then
                '' Remove the selection (if any...)
                CType(obj, HyperLink).Text = CType(obj, HyperLink).Text.Replace("[", "")
                CType(obj, HyperLink).Text = CType(obj, HyperLink).Text.Replace("]", "")
                '' Disables the Current Page's Link 
                CType(obj, HyperLink).Enabled = False
                '' Set style for current page
                CType(obj, HyperLink).CssClass = "currentpage"
                '' Checks if its (the 1st OR the last) page, so the Previous OR Next will be disabled as well.
                CheckForPreviousNextLinks(CShort(pLinkNo))
                Exit Sub
            End If
        Next
    End Sub

    ''' <summary>
    ''' Checks if the current page is (the 1st OR the last) page, to disable Previous OR Next Links.
    ''' </summary>
    ''' <param name="pLinkNo"></param>
    ''' <remarks>By Mohammad</remarks>
    Private Sub CheckForPreviousNextLinks(ByVal pLinkNo As Short)
        Select Case pLinkNo
            Case 0              '' The 1st Page
                CType(phdPages.FindControl("lnkPrevious"), HyperLink).NavigateUrl = ""
                CType(phdPages.FindControl("lnkPrevious"), HyperLink).CssClass = "arrow disabled"
            Case NoOfPages - 1  '' The Last Page
                CType(phdPages.FindControl("lnkNext"), HyperLink).NavigateUrl = ""
                CType(phdPages.FindControl("lnkNext"), HyperLink).CssClass = "arrow disabled"
            Case Else
                Exit Sub
        End Select
    End Sub

End Class
