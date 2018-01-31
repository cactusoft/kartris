'========================================================================
'Kartris - www.kartris.com
'Copyright 2018 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisDisplayFunctions

Partial Class UserControls_Front_SiteNews
    Inherits System.Web.UI.UserControl

    Private _TitleTagType As String

    Private _MaxItems As Integer = CShort(KartSettingsManager.GetKartConfig("frontend.news.max"))

    Public Property TitleTagType() As String
        Set(ByVal value As String)
            _TitleTagType = value
        End Set
        Get
            Return _TitleTagType
        End Get
    End Property

    Public Property MaxItems() As Integer
        Set(ByVal value As Integer)
            _MaxItems = value
        End Set
        Get
            Return _MaxItems
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If KartSettingsManager.GetKartConfig("frontend.navigationmenu.sitenews") <> "y" Then
            phdNews.Visible = False
            litDisabledCommentMessage.Text = "<!-- News Disabled - frontend.navigationmenu.sitenews is set to 'n' -->"
        ElseIf Not Page.IsPostBack Then
            LoadLatestNews(_MaxItems)
        End If
    End Sub

    Public Sub LoadLatestNews(Optional ByVal numNoOfRecords As Short = 0)
        If numNoOfRecords = -1 Then
            phdNews.Visible = False
            litDisabledCommentMessage.Text = "<!-- News Disabled - frontend.news.max is set to '-1' -->"
        Else
            Dim tblLatestNews As DataTable
            tblLatestNews = NewsBLL.GetLatestNews(Session("LANG"), numNoOfRecords)

            rptSiteNews.DataSource = tblLatestNews
            rptSiteNews.DataBind()

            If rptSiteNews.Items.Count = 0 Then
                phdNoResults.Visible = True
            Else
                phdNoResults.Visible = False
            End If

            'This control is used on home page and also on
            'the news page. We need to decide which heading
            'to show.
            Select Case _TitleTagType
                Case "none"
                    phdH1Tag.Visible = False
                    phdH2Tag.Visible = False
                Case "h1"
                    phdH1Tag.Visible = True
                    phdH2Tag.Visible = False
                Case "h2"
                    phdH1Tag.Visible = False
                    phdH2Tag.Visible = True
            End Select
        End If


    End Sub

    Public Function FormatNewsLink(ByVal numID As Integer) As String
        Return "~/News.aspx?NewsID=" & numID.ToString
    End Function

    Protected Sub rptSiteNews_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptSiteNews.ItemDataBound
        If e.Item.ItemType = ListItemType.AlternatingItem OrElse _
            e.Item.ItemType = ListItemType.Item Then
            CType(e.Item.FindControl("lnkNews"), HyperLink).NavigateUrl = SiteMapHelper.CreateURL(SiteMapHelper.Page.News, CType(e.Item.DataItem, DataRowView).Item(0))
        End If
    End Sub

End Class
