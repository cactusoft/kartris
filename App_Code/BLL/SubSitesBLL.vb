'========================================================================
'Kartris - www.kartris.com
'Copyright 2020 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisDataManipulation
Imports CkartrisFormatErrors
Imports System.Data
Imports System.Data.SqlClient
Imports kartrisSubSitesData
Imports kartrisSubSitesDataTableAdapters
Imports System.Web.HttpContext
Imports CkartrisEnumerations

Public Class SubSitesBLL


    Private Shared _Adptr As SubSitesTblAdptr = Nothing


    Protected Shared ReadOnly Property Adptr() As SubSitesTblAdptr
        Get
            _Adptr = New SubSitesTblAdptr
            Return _Adptr
        End Get
    End Property

    ''' <summary>
    ''' Function to return subsite ID.
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Function ViewingSubSite(ByVal SUB_ID As Integer) As Integer
        'We will return 0 if not viewing a subsite, otherwise we'll return the site ID

        Dim strCurrentDomain As String = ""
        Dim strMainDomainConfigWebShopURL = ""

        If SUB_ID > 0 Then
            'We are in preview mode
            Return SUB_ID
        Else
            'We need to look at URL and see if it matches the webshopURL config setting
            strCurrentDomain = Replace(Replace(Current.Request.Url.AbsoluteUri.ToLower, "https://", ""), "http://", "")
            strCurrentDomain = Left(strCurrentDomain, strCurrentDomain.IndexOf("/"))
            strMainDomainConfigWebShopURL = Replace(Replace(KartSettingsManager.GetKartConfig("general.webshopurl").ToLower(), "http://", ""), "/", "")

            'Now we should have two domains
            'If they match, we're looking at the main site URL and since
            'no SUB_ID was found, we're not previewing a subsite. So we can
            'basically return 0.
            If strCurrentDomain = strMainDomainConfigWebShopURL Then
                Return 0
            Else
                'Different URLs, let's look up which subsite this is
                Dim tblSubSitesList As DataTable = Nothing
                tblSubSitesList = SubSitesBLL.GetSubSites()
                For Each drwSubSite In tblSubSitesList.Rows
                    If drwSubSite("SUB_Domain") = strCurrentDomain Then
                        Return drwSubSite("SUB_ID")
                    End If
                Next
            End If
        End If
    End Function

    ''' <summary>
    ''' Get all subsites
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Function GetSubSites() As DataTable
        Return Adptr.GetData()
    End Function

    ''' <summary>
    ''' Get a particular sub site by ID
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Function GetSubSiteByID(ByVal SUB_ID As Long) As DataTable
        Return Adptr._GetSubSiteByID(SUB_ID)
    End Function

    ''' <summary>
    ''' Update sub site
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Function _Update(ByVal SUB_ID As Integer, ByVal SUB_Name As String, ByVal SUB_Domain As String, ByVal SUB_BaseCategoryID As Integer, ByVal SUB_Skin As String, ByVal SUB_Notes As String, ByVal SUB_Live As Boolean) As Integer
        Try
            Dim dtNull As Nullable(Of DateTime) = Nothing
            Dim strRandomSalt As String = Membership.GeneratePassword(20, 0)
            Return Adptr._Update(SUB_ID, SUB_Name, SUB_Domain, SUB_BaseCategoryID, SUB_Skin, SUB_Notes, SUB_Live)
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            Return Nothing
        End Try

    End Function

    ''' <summary>
    ''' Insert new sub site
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Function _Add(ByVal SUB_Name As String, ByVal SUB_Domain As String, ByVal SUB_BaseCategoryID As Integer, ByVal SUB_Skin As String, ByVal SUB_Notes As String, ByVal SUB_Live As Boolean) As Integer
        Try
            Dim dtNull As Nullable(Of DateTime) = Nothing
            Dim strRandomSalt As String = Membership.GeneratePassword(20, 0)
            Return Adptr._Add(SUB_Name, SUB_Domain, SUB_BaseCategoryID, SUB_Skin, SUB_Notes, SUB_Live)
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            Return Nothing
        End Try

    End Function


End Class