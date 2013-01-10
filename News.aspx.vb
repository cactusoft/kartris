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
Partial Class News
    Inherits PageBaseClass

    'We set a value to keep track of any trapped
    'error handled, this way, we can avoid throwing
    'a generic error on top of the handled one.
    Dim strErrorThrown As String = ""

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If KartSettingsManager.GetKartConfig("frontend.navigationmenu.sitenews") = "y" Then
            Page.Title = GetGlobalResourceObject("News", "PageTitle_SiteNews") & " | " & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))
            If Not Page.IsPostBack Then
                LoadNews()
            End If
        Else
            'An item was called with correctly formatted URL, but
            'the ID doesn't appear to pull out an item, so it's
            'likely the item is no longer available.
            strErrorThrown = "404"
            HttpContext.Current.Server.Transfer("~/404.aspx")
        End If
    End Sub

    Private Sub LoadNews()
        Try
            Dim numID As Integer = CLng(Request.QueryString("NewsID"))
            rptSiteNews.DataSource = NewsBLL.GetByID(Session("LANG"), numID)
            rptSiteNews.DataBind()

            If numID = 0 And UC_SiteNews.TitleTagType = "h2" Then
                UC_SiteNews.TitleTagType = "h1"
            End If

            If numID <> 0 And rptSiteNews.Items.Count = 0 Then
                strErrorThrown = "404"
                HttpContext.Current.Server.Transfer("~/404.aspx")
            Else
                'Set pagetitle for specific news story
                For Each itmRow In rptSiteNews.Items
                    Page.Title = itmRow.FindControl("N_Name").Text & " | " & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))
                Next
            End If
        Catch ex As Exception
            'Some other error occurred - it seems the ID of the item
            'exists, but loading or displaying the item caused some
            'other error.
            CkartrisFormatErrors.ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            If strErrorThrown = "" Then HttpContext.Current.Server.Transfer("~/Error.aspx")
        End Try

    End Sub
End Class
