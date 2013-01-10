﻿'========================================================================
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
