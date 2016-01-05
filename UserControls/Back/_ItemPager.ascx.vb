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

''' <summary>
''' Item Pager is used to Create a Pager for a list of Items, depending on the total number of Items
'''   and number of items per page.
''' In order to create a pager for an Item, You need to call the Method "LoadPager" with 3 parameters
'''    1.(Total Number Of Items)  2.(Number Of Items Per Page)  3.(URL Query String Key)
''' The 3rd parameter (URL Key), is used to hold the Item's page number.
''' </summary>
''' <remarks>By Mohammad</remarks>
Partial Class _ItemPager
    Inherits System.Web.UI.UserControl

    Private GroupPager As Short
    Private numPages As Short
    Private intTotalItems As Integer
    Private numItemsPerPage As Short
    Private strQueryStringKey As String
    Private intCurrentGroup As Integer = 0
    ''' <summary>
    ''' Loads/Creates the Pages of the Pager.
    ''' </summary>
    ''' <param name="pTotalItems">Total Number of Items</param>
    ''' <param name="pItemsPerPage">Number of Items in each page.</param>
    ''' <param name="pQueryStringKey">The URL related Pager Key, to hold the page index </param>
    ''' <remarks>By Mohammad</remarks>
    Public Sub LoadPager(ByVal pTotalItems As Integer, ByVal pItemsPerPage As Short, ByVal pQueryStringKey As String)


        intTotalItems = pTotalItems
        numItemsPerPage = pItemsPerPage
        GroupPager = CShort(KartSettingsManager.GetKartConfig("general.paging.group.size"))


        '' Gets the number of pages to be created in the Pager.
        numPages = Math.Ceiling(pTotalItems / pItemsPerPage)

        'Hide pager if only one page of results
        If numPages = 1 Then phdWrapper.Visible = False Else phdWrapper.Visible = True


        strQueryStringKey = pQueryStringKey
        Dim intPageNumber As Integer = CInt(Request.QueryString(strQueryStringKey))
        If intPageNumber + 1 > GroupPager Then
            intCurrentGroup = Math.Floor(intPageNumber / GroupPager)
        End If


       

        ''****************************** STEP 1 ******************************
        ''---------- Creating the '<< Pervious' link ----------------------------
        Dim lnkPrevious As New HyperLink
        With lnkPrevious
            .ID = "lnkPrevious"     '' The link ID, to be referenced easily.
            .Text = " « Previous "  '' The link Text, that will be viewed.
            .NavigateUrl = GetURL(CShort(Request.QueryString(strQueryStringKey)) - 1)  '' The link Redirect URL.
            .CssClass = "arrow previous"
        End With
        If intPageNumber = 0 Then
            lnkPrevious.NavigateUrl = ""
            lnkPrevious.CssClass = "arrow disabled"
        End If
        '' Adding the link to the pager.
        phdPages.Controls.Add(lnkPrevious)
        ''-----------------------------------------------------------------------

        If numPages > GroupPager Then
            ''****************************** STEP 1 ******************************
            ''---------- Creating the '<< Pervious' link ----------------------------
            Dim lnkPreviousGroup As New HyperLink
            With lnkPreviousGroup
                .ID = "lnkPreviousGroup"     '' The link ID, to be referenced easily.
                .Text = " «.. " '' The link Text, that will be viewed.
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

        If numPages > GroupPager Then

            Dim maxPageGroup As Integer = ((intCurrentGroup + 1) * (GroupPager))
            If maxPageGroup > (numPages + 1) Then maxPageGroup = numPages

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
            For i As Short = 0 To numPages - 1
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

        If numPages > GroupPager Then
            ''****************************** STEP 1 ******************************
            ''---------- Creating the '>> Next Group' link ----------------------------
            Dim lnkNextGroup As New HyperLink
            With lnkNextGroup
                .ID = "lnkNextGroup"     '' The link ID, to be referenced easily.
                .Text = " ..» " '' The link Text, that will be viewed.
                .NavigateUrl = GetURL(CShort((intCurrentGroup + 1) * GroupPager))  '' The link Redirect URL.
                .CssClass = "arrow next"
            End With
            If intCurrentGroup = Math.Floor(numPages / GroupPager) Then
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
            .Text = " Next » "  '' The link Text, that will be viewed.
            .NavigateUrl = GetURL(CShort(Request.QueryString(strQueryStringKey)) + 1) '' The link Redirect URL.
            .CssClass = "arrow next"
        End With
        If intPageNumber + 1 = numPages Then
            lnkNext.NavigateUrl = ""
            lnkNext.CssClass = "arrow disabled"
        End If
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


        '======= DEPRECATED URL GENERATION CODE - REPLACED BY THE CreateURL FUNCTION BELOW - MEDZ
        '
        If strCurrentUrl.Contains("&" & strQueryStringKey & "=" & Request.QueryString(strQueryStringKey)) Then
            strCurrentUrl = strCurrentUrl.Replace("&" & strQueryStringKey & "=" & Request.QueryString(strQueryStringKey), "")
            strActualUrl = strCurrentUrl & "&" & strQueryStringKey & "=" & pPageIndx
        Else
            If Not strCurrentUrl.Contains("?") Then
                strCurrentUrl += "?"
                strActualUrl = strCurrentUrl & strQueryStringKey & "=" & pPageIndx
            Else
                If strCurrentUrl.IndexOf(strQueryStringKey & "=") <> -1 Then
                    strCurrentUrl = strCurrentUrl.Replace("&" & strQueryStringKey & "=" & Request.QueryString(strQueryStringKey), "&")
                    strCurrentUrl = strCurrentUrl.Replace(strQueryStringKey & "=" & Request.QueryString(strQueryStringKey), "")
                    strActualUrl = strCurrentUrl & strQueryStringKey & "=" & pPageIndx
                Else
                    strActualUrl = strCurrentUrl & "&" & strQueryStringKey & "=" & pPageIndx
                End If
            End If
        End If

        '==========================================================================================
        Dim strActiveTab As String = "p"
        
        If strQueryStringKey = "CPGR" Then
            strActiveTab = "s"
        End If
        
        If strActiveTab = "s" Then
            If Not strCurrentUrl.Contains("&T=S") Then strActualUrl += "&T=S"
        Else
            strActualUrl = strActualUrl.Replace("&T=S", "")
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
            Case numPages - 1  '' The Last Page
                CType(phdPages.FindControl("lnkNext"), HyperLink).NavigateUrl = ""
                CType(phdPages.FindControl("lnkNext"), HyperLink).CssClass = "arrow disabled"
            Case Else
                Exit Sub
        End Select
    End Sub

End Class
