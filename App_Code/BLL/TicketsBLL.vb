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
Imports kartrisTicketsDataTableAdapters
Imports CkartrisDisplayFunctions
Imports CkartrisFormatErrors
Imports KartSettingsManager
Imports CkartrisDataManipulation
Imports System.Web.HttpContext
Imports CkartrisEnumerations

Public Class TicketsBLL

    Private Shared _Adptr As TicketsTblAdptr = Nothing

    Protected Shared ReadOnly Property Adptr() As TicketsTblAdptr
        Get
            _Adptr = New TicketsTblAdptr
            Return _Adptr
        End Get
    End Property

    Public Shared Function AddSupportTicket(ByVal numUserID As Integer, ByVal numTypeID As Integer, ByVal strSubject As String, ByVal strText As String, ByRef strMsg As String) As Integer
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "spKartrisSupportTickets_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure

            Dim intReturnID As Integer = 0
            Try
                cmd.Parameters.AddWithValue("@OpenedDate", NowOffset)
                cmd.Parameters.AddWithValue("@TicketType", FixNullToDB(numTypeID, "i"))
                cmd.Parameters.AddWithValue("@Subject", FixNullToDB(strSubject))
                cmd.Parameters.AddWithValue("@Text", FixNullToDB(strText))
                cmd.Parameters.AddWithValue("@U_ID", FixNullToDB(numUserID, "i"))
                cmd.Parameters.AddWithValue("@TIC_NewID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                cmd.ExecuteNonQuery()

                If cmd.Parameters("@TIC_NewID").Value Is Nothing OrElse _
                    cmd.Parameters("@TIC_NewID").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If
                intReturnID = cmd.Parameters("@TIC_NewID").Value
                savePoint.Commit()
                Return intReturnID
            Catch ex As Exception
                If Not savePoint Is Nothing Then savePoint.Rollback()
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return 0
    End Function

    Public Shared Function GetSupportTicketsByUser(ByVal numUserID As Integer) As DataTable
        Return Adptr.GetByUserID(numUserID)
    End Function

    Public Shared Function GetTicketDetailsByID(ByVal numTicketID As Long, ByVal numUserID As Integer) As DataTable
        Return Adptr.GetDetailsByID(numTicketID, numUserID)
    End Function

    Public Shared Function AddCustomerReply(ByVal numTicketID As Long, ByVal strText As String, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "spKartrisSupportTickets_AddCustomerReply"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                cmd.Parameters.AddWithValue("@TIC_ID", FixNullToDB(numTicketID, "i"))
                cmd.Parameters.AddWithValue("@NowOffset", NowOffset)
                cmd.Parameters.AddWithValue("@STM_Text", FixNullToDB(strText))
                cmd.Parameters.AddWithValue("@STM_NewID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                cmd.ExecuteNonQuery()

                If cmd.Parameters("@STM_NewID").Value Is Nothing OrElse _
                    cmd.Parameters("@STM_NewID").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                savePoint.Commit()
                Return True
            Catch ex As Exception
                If Not savePoint Is Nothing Then savePoint.Rollback()
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return False
    End Function

    Public Shared Function _GetTickets() As DataTable
        Return Adptr._GetSummary()
    End Function

    Public Shared Function _GetTicketDetails(ByVal numTicketID As Long) As DataTable
        Return Adptr._GetDetailsByID(numTicketID)
    End Function

    Public Shared Sub _TicketsCounterSummary(ByRef numUnassigned As Integer, ByRef numAwaiting As Integer, ByVal numLoginID As Integer)
        Adptr._TicketsCounterSummary(numUnassigned, numAwaiting, numLoginID)
    End Sub

    Public Shared Function _SearchTickets(ByVal strKeyword As String, ByVal numLangID As Short, ByVal numAssignedID As Short, _
                                          ByVal numTypeID As Short, numUserID As Integer, strUserEmail As String, ByVal chrStatus As Char) As DataTable
        Return Adptr._SearchTickets(strKeyword, numLangID, numAssignedID, numTypeID, numUserID, strUserEmail, chrStatus)
    End Function

    Public Shared Function _AddOwnerReply(ByVal numTicketID As Long, ByVal numLoginID As Integer, ByVal strText As String, ByVal numTimeSpent As Integer, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisSupportTickets_AddOwnerReply"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                cmd.Parameters.AddWithValue("@TIC_ID", FixNullToDB(numTicketID, "i"))
                cmd.Parameters.AddWithValue("@LOGIN_ID", numLoginID)
                cmd.Parameters.AddWithValue("@NowOffset", NowOffset)
                cmd.Parameters.AddWithValue("@STM_Text", FixNullToDB(strText))
                cmd.Parameters.AddWithValue("@TIC_TimeSpent", FixNullToDB(numTimeSpent, "i"))
                cmd.Parameters.AddWithValue("@STM_NewID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                cmd.ExecuteNonQuery()

                If cmd.Parameters("@STM_NewID").Value Is Nothing OrElse _
                    cmd.Parameters("@STM_NewID").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                savePoint.Commit()
                Return True
            Catch ex As Exception
                If Not savePoint Is Nothing Then savePoint.Rollback()
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return False
    End Function

    Public Shared Function _UpdateTicket(ByVal numTicketID As Long, ByVal numAssignedLoginID As Integer, ByVal chrStatus As Char, _
                                   ByVal numTimeSpent As Integer, ByVal strTags As String, ByVal numTicketTypeID As Short, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisSupportTickets_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                cmd.Parameters.AddWithValue("@TIC_ID", FixNullToDB(numTicketID, "i"))
                cmd.Parameters.AddWithValue("@LOGIN_ID", numAssignedLoginID)
                cmd.Parameters.AddWithValue("@NowOffset", NowOffset)
                cmd.Parameters.AddWithValue("@TIC_Status", FixNullToDB(chrStatus, "c"))
                cmd.Parameters.AddWithValue("@TIC_TimeSpent", numTimeSpent)
                cmd.Parameters.AddWithValue("@TIC_Tags", FixNullToDB(strTags))
                cmd.Parameters.AddWithValue("@STT_ID", FixNullToDB(numTicketTypeID, "i"))

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                cmd.ExecuteNonQuery()
                savePoint.Commit()
                Return True
            Catch ex As Exception
                If Not savePoint Is Nothing Then savePoint.Rollback()
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return False
    End Function

    Public Shared Function _DeleteTicket(ByVal numTicketID As Integer, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisSupportTickets_Delete"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                cmd.Parameters.AddWithValue("@TIC_ID", FixNullToDB(numTicketID, "i"))

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                cmd.ExecuteNonQuery()
                savePoint.Commit()
                Return True
            Catch ex As Exception
                If Not savePoint Is Nothing Then savePoint.Rollback()
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return False
    End Function

    Private Shared _AdptrTypes As TicketTypesTblAdptr = Nothing

    Protected Shared ReadOnly Property AdptrTypes() As TicketTypesTblAdptr
        Get
            _AdptrTypes = New TicketTypesTblAdptr
            Return _AdptrTypes
        End Get
    End Property

    Public Shared Function _GetTicketTypes() As DataTable
        Return AdptrTypes._GetData()
    End Function

    Public Shared Function _AddTicketType(ByVal strType As String, ByVal chrLevel As Char, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisSupportTicketTypes_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                cmd.Parameters.AddWithValue("@Type", FixNullToDB(strType))
                cmd.Parameters.AddWithValue("@Level", FixNullToDB(chrLevel, "c"))
                cmd.Parameters.AddWithValue("@New_ID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                cmd.ExecuteNonQuery()

                If cmd.Parameters("@New_ID").Value Is Nothing OrElse _
                    cmd.Parameters("@New_ID").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                savePoint.Commit()
                Return True
            Catch ex As Exception
                If Not savePoint Is Nothing Then savePoint.Rollback()
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return False
    End Function

    Public Shared Function _UpdateTicketType(ByVal numTypeID As Integer, ByVal strType As String, ByVal chrLevel As Char, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisSupportTicketTypes_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                cmd.Parameters.AddWithValue("@ID", FixNullToDB(numTypeID, "i"))
                cmd.Parameters.AddWithValue("@Type", FixNullToDB(strType))
                cmd.Parameters.AddWithValue("@Level", FixNullToDB(chrLevel, "c"))

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                cmd.ExecuteNonQuery()

                savePoint.Commit()
                Return True
            Catch ex As Exception
                If Not savePoint Is Nothing Then savePoint.Rollback()
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return False
    End Function

    Public Shared Function _DeleteTicketType(ByVal numTypeID As Integer, ByVal numNewTypeID As Integer, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisSupportTicketTypes_Delete"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                cmd.Parameters.AddWithValue("@ID", FixNullToDB(numTypeID, "i"))
                cmd.Parameters.AddWithValue("@NewTypeID", FixNullToDB(numNewTypeID, "i"))

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                cmd.ExecuteNonQuery()

                savePoint.Commit()
                Return True
            Catch ex As Exception
                If Not savePoint Is Nothing Then savePoint.Rollback()
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return False
    End Function

    Private Shared _AdptrMessages As TicketMessagesTblAdptr = Nothing

    Protected Shared ReadOnly Property AdptrMessages() As TicketMessagesTblAdptr
        Get
            _AdptrMessages = New TicketMessagesTblAdptr
            Return _AdptrMessages
        End Get
    End Property

    Public Shared Function _GetTicketMessages(ByVal numTicketID As Integer) As DataTable
        Return AdptrMessages._GetByTicketID(numTicketID)
    End Function

    Public Shared Function _GetLastByCustomer(ByVal numTicketID As Integer) As DataTable
        Return AdptrMessages._GetLastByCustomer(numTicketID)
    End Function

    Public Shared Function GetLastByOwner(ByVal numTicketID As Integer) As DataTable
        Return AdptrMessages.GetLastByOwner(numTicketID)
    End Function

End Class
