'========================================================================
'Kartris - www.kartris.com
'Copyright 2021 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisEnumerations
Imports KartSettingsManager
Imports CkartrisDataManipulation
Imports CkartrisDisplayFunctions
Imports CKartrisSearchManager

Partial Class Knowledgebase
    Inherits PageBaseClass

    'We set a value to keep track of any trapped
    'error handled, this way, we can avoid throwing
    'a generic error on top of the handled one.
    Dim strErrorThrown As String = ""

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("Knowledgebase", "PageTitle_Knowledgebase") & " | " & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))

        If KartSettingsManager.GetKartConfig("frontend.knowledgebase.enabled") = "y" Then
            pnlSearch.Visible = True

            If Request.QueryString("list") = "all" Then
                GetKBList()
            ElseIf IsNumeric(Request.QueryString("kb")) Then
                GetKBArticle()
            ElseIf Request.QueryString("strSearchText") <> "" Then
                SearchKnowledgebase()
            Else
                'Er, just start page
            End If
        Else
            'do nothing
        End If

    End Sub

    Sub GetKBList()
        pnlSearch.Visible = False
        Dim tblKB As DataTable = KBBLL.GetKB(Session("LANG"))
        rptKBList.DataSource = tblKB
        rptKBList.DataBind()
        mvwKnowledgebase.SetActiveView(viwKBList)
    End Sub

    Sub GetKBArticle()
        Dim tblKB As DataTable = KBBLL.GetKBByID(Session("LANG"), Request.QueryString("kb"))
        If tblKB.Rows.Count = 0 Then
            'An item was called with correctly formatted URL, but
            'the ID doesn't appear to pull out an item, so it's
            'likely the item is no longer available.
            strErrorThrown = "404"
            HttpContext.Current.Server.Transfer("~/404.aspx")
        Else
            Dim drwKB As DataRow = tblKB.Rows(0)
            If Not FixNullFromDB(drwKB("KB_PageTitle")) Is Nothing Then Me.Title = FixNullFromDB(drwKB("KB_PageTitle"))
            litDateUpdated.Text = FormatDate(FixNullFromDB(drwKB("KB_LastUpdated")), "d", Session("LANG"))
            litKBName.Text = FixNullFromDB(drwKB("KB_Name"))
            litKBText.Text = FixNullFromDB(drwKB("KB_Text"))
            litKBID.Text = FixNullFromDB(drwKB("KB_ID"))

            Dim strPageMetaDesc As String = FixNullFromDB(drwKB("KB_MetaDescription"))
            Dim strPageMetaKeywords As String = FixNullFromDB(drwKB("KB_MetaKeywords"))

            If Not String.IsNullOrEmpty(Me.Title) Then
                Me.Title = CkartrisDisplayFunctions.StripHTML(Me.Title) & " | " & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))
            End If

            Dim metaTag As New HtmlMeta
            Dim HeadTag As HtmlHead = CType(Page.Header, HtmlHead)

            If Not String.IsNullOrEmpty(strPageMetaDesc) Then
                CType(Page, PageBaseClass).MetaDescription = strPageMetaDesc
            End If

            If Not String.IsNullOrEmpty(strPageMetaKeywords) Then
                CType(Page, PageBaseClass).MetaKeywords = strPageMetaKeywords
            End If

            mvwKnowledgebase.SetActiveView(viwKBDetails)
            pnlSearch.Visible = False
        End If
    End Sub

    Function FormatLink(ByVal KB_ID As Integer, ByVal KB_Name As String) As String
        Return "[#" & KB_ID.ToString & "] " & KB_Name

    End Function

    Sub SearchKnowledgebase()
        Dim strSearchText As String = ValidateSearchKeywords(Request.QueryString("strSearchText"))

        If strSearchText <> "" Then
            Dim tblSearchResult As DataTable = KBBLL.Search(strSearchText, Session("LANG"))

            For Each drwResults As DataRow In tblSearchResult.Rows
                drwResults("KB_Name") = HighLightResultText(FixNullFromDB(drwResults("KB_Name")), strSearchText)
                drwResults("KB_Text") = HighLightResultText(FixNullFromDB(drwResults("KB_Text")), strSearchText)
            Next

            Dim strSearchSummaryTemplate = GetGlobalResourceObject("Search", "ContentText_SearchSummaryTemplate")

            strSearchSummaryTemplate = Replace(strSearchSummaryTemplate, "[searchterms]", strSearchText)
            strSearchSummaryTemplate = Replace(strSearchSummaryTemplate, "[matches]", tblSearchResult.Rows.Count)
            litSearchResult.Text = strSearchSummaryTemplate

            rptSearchList.DataSource = tblSearchResult
            rptSearchList.DataBind()

        End If
        mvwKnowledgebase.SetActiveView(viwSearchResult)
        updMain.Update()
    End Sub
End Class