'[[[NEW COPYRIGHT NOTICE]]]
Partial Class BreadCrumbTrail
    Inherits System.Web.UI.UserControl

    Private _SiteMapProvider As String

    Public Property SiteMapProvider() As String
        Set(ByVal value As String)
            _SiteMapProvider = value
        End Set
        Get
            Return _SiteMapProvider
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'Set the breadcrumbtrail to default to the breadcrumb
        'sitemap - on productview control and category page, we
        'have to set to use the categorysitemap.
        If _SiteMapProvider <> "" Then
            smpTrail.SiteMapProvider = SiteMapProvider
        Else
            smpTrail.SiteMapProvider = "BreadCrumbSiteMap"
        End If


    End Sub

End Class
