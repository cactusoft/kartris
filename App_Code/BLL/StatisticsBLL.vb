'========================================================================
'Kartris - www.kartris.com
'Copyright 2017 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports System.Web.HttpContext
Imports kartrisStatisticsDataTableAdapters
Imports CkartrisFormatErrors
Imports CkartrisDataManipulation
Imports CkartrisDisplayFunctions

Public Class StatisticsBLL

    Private Shared _Adptr As StatisticsTblAdptr = Nothing

    Protected Shared ReadOnly Property Adptr() As StatisticsTblAdptr
        Get
            _Adptr = New StatisticsTblAdptr
            Return _Adptr
        End Get
    End Property

    Public Shared Function _GetCategoryYearSummary() As DataTable
        Return Adptr._GetCategoryYearSummary(NowOffset)
    End Function

    Public Shared Function _GetCategoriesByDate(ByVal numMonth As Byte, ByVal numYear As Short, ByVal numLanguage As Byte) As DataTable
        Return Adptr._GetCategoriesByDate(numMonth, numYear, numLanguage)
    End Function

    Public Shared Function _GetProductYearSummary() As DataTable
        Return Adptr._GetProductYearSummary(NowOffset)
    End Function

    Public Shared Function _GetProductsByDate(ByVal numMonth As Byte, ByVal numYear As Short, ByVal numLanguage As Byte) As DataTable
        Return Adptr._GetProductsByDate(numMonth, numYear, numLanguage)
    End Function

    Public Shared Function _GetProductStatsDetailsByDate(ByVal numProductID As Integer, ByVal numMonth As Byte, ByVal numYear As Short, ByVal numLanguage As Byte) As DataTable
        Return Adptr._GetProductStatsDetailsByDate(numProductID, numMonth, numYear, numLanguage)
    End Function

    Public Shared Function GetRecentlyViewedProducts(ByVal numLanguageID As Byte) As DataTable
        Return Adptr.GetRecentlyViewedProducts(numLanguageID)
    End Function

    Public Shared Sub AddNewStatsRecord(ByVal chrItemType As Char, ByVal numItemID As Integer, _
                          Optional ByVal numItemParentID As Integer = 0)

        If Not IsValidUserAgent() OrElse numItemID = 0 Then Return

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdAddStats As SqlCommand = sqlConn.CreateCommand
            cmdAddStats.CommandText = "spKartrisStatistics_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmdAddStats.CommandType = CommandType.StoredProcedure
            Try
                cmdAddStats.Parameters.AddWithValue("@Type", FixNullToDB(chrItemType, "c"))
                cmdAddStats.Parameters.AddWithValue("@ParentID", FixNullToDB(numItemParentID, "i"))
                cmdAddStats.Parameters.AddWithValue("@ItemID", FixNullToDB(numItemID, "i"))
                cmdAddStats.Parameters.AddWithValue("@IP", CkartrisEnvironment.GetClientIPAddress())
                cmdAddStats.Parameters.AddWithValue("@NowOffset", NowOffset)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddStats.Transaction = savePoint

                cmdAddStats.ExecuteNonQuery()
                savePoint.Commit()
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using

    End Sub

    Public Shared Function _GetOrdersTurnover(ByVal datFrom As Date, ByVal datTo As Date) As DataTable
        Return Adptr._GetOrdersTurnover(datFrom, datTo)
    End Function

    Public Shared Function _GetAverageVisits() As DataTable
        Return Adptr._GetAverageVisits(NowOffset)
    End Function

    Public Shared Function _GetAverageOrders() As DataTable
        Return Adptr._GetAverageOrders(NowOffset)
    End Function

    Private Shared _AdptrSearch As SearchStatisticsTblAdptr = Nothing

    Protected Shared ReadOnly Property AdptrSearch() As SearchStatisticsTblAdptr
        Get
            _AdptrSearch = New SearchStatisticsTblAdptr
            Return _AdptrSearch
        End Get
    End Property

    Public Shared Sub ReportSearchStatistics(ByVal strKeywordList As String)
        Dim datCurrentDate As Date = NowOffset()
        AdptrSearch.ReportSearchStatistics(strKeywordList, datCurrentDate.Year, datCurrentDate.Month, datCurrentDate.Day, _
                                           New Date(datCurrentDate.Year, datCurrentDate.Month, datCurrentDate.Day))
    End Sub

    Public Shared Function _GetTopSearches(ByVal datFrom As Date, ByVal datTo As Date, ByVal numNoOfRecords As Integer) As DataTable
        Return AdptrSearch._GetTopSearches(datFrom, datTo, numNoOfRecords)
    End Function

End Class
