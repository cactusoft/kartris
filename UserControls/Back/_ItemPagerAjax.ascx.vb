'========================================================================
'Kartris - www.kartris.com
'Copyright 2023 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class _ItemPagerAjax
    Inherits System.Web.UI.UserControl
    ''' <summary>
    ''' Set/Get the total number of items
    ''' </summary>
    Public Property TotalItems() As Integer
        Get
            Return CInt(ViewState("_TotalItems"))
        End Get
        Set(ByVal value As Integer)
            ViewState("_TotalItems") = value
        End Set
    End Property

    ''' <summary>
    ''' Set/Get the number of items to display per page
    ''' </summary>
    Public Property ItemsPerPage() As Integer
        Get
            Return CInt(ViewState("_ItemsPerPage"))
        End Get
        Set(ByVal value As Integer)
            ViewState("_ItemsPerPage") = value
        End Set
    End Property

    ''' <summary>
    ''' Retrieves the total number of pages that will be generated based on Total Items and Items Per Page
    ''' </summary>
    Public ReadOnly Property NoOfPages() As Integer
        Get
            ' Compute the total number of pages to be created in the Pager.
            Try
                Return Math.Ceiling(TotalItems / ItemsPerPage)
            Catch ex As Exception
                Return 0
            End Try
        End Get
    End Property

    ''' <summary>
    ''' Set/Retrieve the current page number being viewed
    ''' </summary>
    Public Property CurrentPage() As Integer
        Get
            Return CInt(ViewState("_CurrentPage"))
        End Get
        Set(ByVal value As Integer)
            ViewState("_CurrentPage") = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        PopulatePagerControl()
    End Sub

    Public Sub PopulatePagerControl()
        phdPages.Controls.Clear()
        Dim GroupPager As Integer = CShort(KartSettingsManager.GetKartConfig("general.paging.group.size"))

        ViewState("_CurrentGroup") = 0
        Dim intCurrentPage = CInt(ViewState("_CurrentPage"))
        If intCurrentPage + 1 > GroupPager Then
            ViewState("_CurrentGroup") = Math.Floor(intCurrentPage / GroupPager)
        End If

        If NoOfPages > 0 Then
            ''****************************** STEP 1 ******************************
            ''---------- Creating the '<< Pervious' link ----------------------------
            Dim lnkPrevious As New LinkButton
            With lnkPrevious
                .ID = "lnkPrevious"     '' The link ID, to be referenced easily.
                .Text = " « Previous "  '' The link Text, that will be viewed.
                AddHandler .Click, AddressOf ChangePage
                .CssClass = "arrow previous"
            End With

            If ViewState("_CurrentPage") = 0 Then
                lnkPrevious.Enabled = False
                lnkPrevious.CssClass = "arrow disabled"
            End If

            '' Adding the link to the pager.
            phdPages.Controls.Add(lnkPrevious)
            ''-----------------------------------------------------------------------
        End If

        If NoOfPages > GroupPager Then
            ''****************************** STEP 1 ******************************
            ''---------- Creating the '<< Pervious' link ----------------------------
            Dim lnkPreviousGroup As New LinkButton
            With lnkPreviousGroup
                .ID = "lnkPreviousGroup"     '' The link ID, to be referenced easily.
                .Text = " «.. "  '' The link Text, that will be viewed.
                AddHandler .Click, AddressOf ChangePage
                .CssClass = "arrow previous"
            End With

            If intCurrentPage < GroupPager Then
                lnkPreviousGroup.Enabled = False
            End If
            '' Adding the link to the pager.
            phdPages.Controls.Add(lnkPreviousGroup)
            ''-----------------------------------------------------------------------
        End If

        If NoOfPages > GroupPager Then
            Dim maxPageGroup As Integer = ((ViewState("_CurrentGroup") + 1) * (GroupPager))
            If maxPageGroup > (NoOfPages + 1) Then maxPageGroup = NoOfPages

            For i As Short = (ViewState("_CurrentGroup") * GroupPager) To maxPageGroup - 1
                Dim lnkPage As New LinkButton
                With lnkPage
                    .ID = "lnkPage" & i         '' The link ID, to be referenced easily.
                    .Text = " " & i + 1 & " "
                    AddHandler .Click, AddressOf ChangePage
                    If i = intCurrentPage Then
                        .Text = .Text.Replace("[", "")
                        .Text = .Text.Replace("]", "")
                        ' disable the current page's linkbutton
                        .Enabled = False
                        ' set a different style for the current page
                        .CssClass = "currentpage"
                    End If
                End With
                '' Adding the link to the pager.
                phdPages.Controls.Add(lnkPage)
            Next
        Else
            For i As Short = 0 To NoOfPages - 1
                Dim lnkPage As New LinkButton
                With lnkPage
                    .ID = "lnkPage" & i
                    .Text = " " & i + 1 & " "
                    AddHandler .Click, AddressOf ChangePage
                    If i = intCurrentPage Then
                        .Text = .Text.Replace("[", "")
                        .Text = .Text.Replace("]", "")
                        ' disable the current page's linkbutton
                        .Enabled = False
                        ' set a different style for the current page
                        .CssClass = "currentpage"
                    End If
                End With
                phdPages.Controls.Add(lnkPage)

                'Hide pager if only one page of results
                If NoOfPages = 1 Then phdWrapper.Visible = False Else phdWrapper.Visible = True

            Next
        End If

        If NoOfPages > GroupPager Then
            ''****************************** STEP 1 ******************************
            ''---------- Creating the '>> Next Group' link ----------------------------
            Dim lnkNextGroup As New LinkButton
            With lnkNextGroup
                .ID = "lnkNextGroup"     '' The link ID, to be referenced easily.
                .Text = " ..» " '' The link Text, that will be viewed.
                .CssClass = "arrow next"
                AddHandler .Click, AddressOf ChangePage
            End With
            If ViewState("_CurrentGroup") = Math.Floor(NoOfPages / GroupPager) Then
                lnkNextGroup.CssClass = "arrow disabled"
                lnkNextGroup.Enabled = False
            End If
            '' Adding the link to the pager.
            phdPages.Controls.Add(lnkNextGroup)
            ''-----------------------------------------------------------------------
        End If

        If NoOfPages > 0 Then
            ''****************************** STEP 3 ******************************
            ''---------- Creating the ' Next >> ' link ----------------------------
            Dim lnkNext As New LinkButton
            With lnkNext
                .ID = "lnkNext"     '' The link ID, to be referenced easily.
                .Text = " Next » "  '' The link Text, that will be viewed.
                AddHandler .Click, AddressOf ChangePage
                .CssClass = "arrow next"
            End With

            If ViewState("_CurrentPage") + 1 = NoOfPages Then
                lnkNext.Enabled = False
                lnkNext.CssClass = "arrow disabled"
            End If
            '' Adding the link to the pager.
            phdPages.Controls.Add(lnkNext)
            ''-----------------------------------------------------------------------
        End If

    End Sub

    Protected Sub ChangePage(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim GroupPager As Integer = CShort(KartSettingsManager.GetKartConfig("general.paging.group.size"))
        Dim strLinkText As String = CType(sender, LinkButton).Text
        Select Case strLinkText
            Case " «.. "
                ViewState("_CurrentPage") = (ViewState("_CurrentGroup") - 1) * GroupPager
            Case " ..» "
                ViewState("_CurrentPage") = (ViewState("_CurrentGroup") + 1) * GroupPager
            Case " « Previous "
                ViewState("_CurrentPage") = ViewState("_CurrentPage") - 1
            Case " Next » "
                ViewState("_CurrentPage") = ViewState("_CurrentPage") + 1
            Case Else
                ViewState("_CurrentPage") = CInt(CType(sender, LinkButton).Text) - 1
        End Select

        RaiseEvent PageChanged()
    End Sub

    ''' <summary>
    ''' This event gets triggered if a page turning link is clicked
    ''' </summary>
    Public Event PageChanged()
End Class
