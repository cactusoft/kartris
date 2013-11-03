Imports Microsoft.VisualBasic
Imports System.Collections.Generic
Imports System.ComponentModel
Imports CkartrisDataManipulation
Imports System.Web.HttpContext
Imports CkartrisFormatErrors

Public Class LinnworksServices

    Public Shared Function _CreateNewLinnowrksOrder(intOrderID As Integer, strToken As String, ByRef strMessage As String) As Boolean
        Try
            Kartris.Linnworks.KartrisHelper.strConnString = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
            Kartris.Linnworks.KartrisHelper.numLanguage = CkartrisBLL.GetLanguageIDfromSession()
            Kartris.Linnworks.KartrisHelper.numTimeOffset = CInt(KartSettingsManager.GetKartConfig("general.timeoffset"))
            Return Kartris.Linnworks.KartrisLinnServices._CreateNewOrder(intOrderID, strToken, strMessage)
        Catch ex As Exception
            CkartrisFormatErrors.ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMessage)
        End Try
        Return False
    End Function
    Public Shared Function _GetLinnworksStockLevel(strToken As String, intPageNo As Integer, ByRef strMessage As String) As DataTable
        Try
            Return Kartris.Linnworks.KartrisLinnServices._GetStockLevel(strToken, intPageNo, strMessage)
        Catch ex As Exception
            CkartrisFormatErrors.ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMessage)
        End Try
        Return Nothing
    End Function
    Public Shared Function _GenerateNewLinnworksToken(strEmail As String, strPassword As String, ByRef strMessage As String) As String
        Try
            Return Kartris.Linnworks.KartrisLinnServices._GenerateNewToken(strEmail, strPassword, strMessage)
        Catch ex As Exception
            CkartrisFormatErrors.ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMessage)
        End Try
        Return ""
    End Function
    Public Shared Function _IsValidLinnworksToken(strToken As String) As Boolean
        Try
            Return Kartris.Linnworks.KartrisLinnServices._IsValidToken(strToken)
        Catch ex As Exception
            CkartrisFormatErrors.ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try
        Return False
    End Function

    Public Shared Function _GetLinnworksPending() As DataTable
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.Connection = sqlConn
            cmd.CommandText = "_spKartrisOrders_GetLinnworksPending"
            cmd.CommandType = CommandType.StoredProcedure
            Try
                Dim da As New SqlDataAdapter(cmd)
                Dim ds As New DataSet()
                da.Fill(ds, "tblOrders")
                Return ds.Tables("tblOrders")
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try
        End Using
        Return Nothing
    End Function
    Public Shared Function _GetLinnworksOrders() As DataTable

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.Connection = sqlConn
            cmd.CommandText = "_spKartrisLinnworksOrders_Get"
            cmd.CommandType = CommandType.StoredProcedure
            Try
                Dim da As New SqlDataAdapter(cmd)
                Dim ds As New DataSet()
                da.Fill(ds, "tblOrders")
                Return ds.Tables("tblOrders")
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try
        End Using
        Return Nothing
    End Function

End Class
