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