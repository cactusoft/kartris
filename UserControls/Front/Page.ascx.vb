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
''' This displays custom page content
''' </summary>
''' <remarks>By Paul</remarks>
Partial Class UserControls_Front_Page
    Inherits System.Web.UI.UserControl

    Private _PageName As String

    Public Property PageName() As String
        Get
            Return _PageName
        End Get
        Set(ByVal value As String)
            _PageName = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim strPage As String = _PageName
        If strPage = "" Then
            strPage = Request.QueryString("strPage")
        End If
        If InStr(LCase(Request.ServerVariables("SCRIPT_NAME")), "page.aspx") > 0 Then
            Page.Title = Replace(StrConv(strPage, VbStrConv.ProperCase), "-", " ") & " | " & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))
        End If
        LoadPage(Session("LANG"), strPage)
    End Sub

    ''' <summary>
    ''' Loads/Bind the page
    ''' </summary>
    ''' <param name="pPageName"></param>
    ''' <param name="pLanguageID"></param>
    ''' <remarks></remarks>
    Public Sub LoadPage(ByVal pLanguageID As Short, ByVal pPageName As String)

        _PageName = pPageName

        'Retrieves the page
        Dim tblPage As New DataTable
        tblPage = PagesBLL.GetPageByName(pLanguageID, _PageName)

        'Filters the LIVE pages only to show.
        Dim drwPages As DataRow()
        drwPages = tblPage.Select("PAGE_ID > 0")

        If tblPage.Rows.Count > 0 Then
            Dim strPageTitle As String = CkartrisDataManipulation.FixNullFromDB(tblPage.Rows(0)("PAGE_Title"))
            Dim strPageMetaDesc As String = CkartrisDataManipulation.FixNullFromDB(tblPage.Rows(0)("PAGE_MetaDescription"))
            Dim strPageMetaKeywords As String = CkartrisDataManipulation.FixNullFromDB(tblPage.Rows(0)("PAGE_MetaKeywords"))

            If Not String.IsNullOrEmpty(strPageTitle) Then
                Page.Title = CkartrisDisplayFunctions.StripHTML(strPageTitle) & " | " & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))
            End If

            Dim metaTag As New HtmlMeta
            Dim HeadTag As HtmlHead = CType(Page.Header, HtmlHead)

            If Not String.IsNullOrEmpty(strPageMetaDesc) Then
                CType(Page, PageBaseClass).MetaDescription = strPageMetaDesc
            End If

            If Not String.IsNullOrEmpty(strPageMetaKeywords) Then
                CType(Page, PageBaseClass).MetaKeywords = strPageMetaKeywords
            End If

            rptPage.DataSource = tblPage
            rptPage.DataBind()
        Else
            If LCase(_PageName) = "default" Then
                'For homepage, if no 'default' page found,
                'just display nothing
                litContentTextContentNotAvailable.Visible = False
            Else
                'An item was called with correctly formatted URL, but
                'the ID doesn't appear to pull out an item, so it's
                'likely the item is no longer available.
                HttpContext.Current.Server.Transfer("~/404.aspx")
            End If
        End If

    End Sub

End Class
