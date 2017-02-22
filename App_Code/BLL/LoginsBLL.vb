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
Imports System.Data
Imports System.Data.SqlClient
Imports kartrisLoginData
Imports kartrisLoginDataTableAdapters
Imports CkartrisFormatErrors
Imports System.Web.HttpContext
Imports CkartrisDataManipulation
Imports CkartrisEnumerations

Public Class LoginsBLL
    Private Shared _Adptr As LoginsTblAdptr = Nothing
    Protected Shared ReadOnly Property Adptr() As LoginsTblAdptr
        Get
            _Adptr = New LoginsTblAdptr
            Return _Adptr
        End Get
    End Property


    Public Shared Function Validate(ByVal UserName As String, ByVal Password As String, Optional ByVal blnDirect As Boolean = False) As Integer
        If blnDirect Then
            Return Adptr._Validate(UserName, Password)
        Else
            Dim strUserSalt As String = _GetSaltByUserName(UserName)
            Dim blnUserValidated As Boolean = Adptr._Validate(UserName, UsersBLL.EncryptSHA256Managed(Password, strUserSalt, True))
            'Password still doesn't use hash salt so update login record
            If blnUserValidated AndAlso String.IsNullOrEmpty(strUserSalt) Then
                Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
                Dim strRandomSalt As String = Membership.GeneratePassword(20, 0)
                Using sqlConn As New SqlClient.SqlConnection(strConnString)

                    Dim cmdUpdateLogin As SqlCommand = sqlConn.CreateCommand
                    cmdUpdateLogin.CommandText = "_spKartrisLogins_UpdatePassword"

                    Dim savePoint As SqlClient.SqlTransaction = Nothing
                    cmdUpdateLogin.CommandType = CommandType.StoredProcedure

                    Try
                        Dim ReturnedID As Integer
                        Dim LOGIN_ID As Integer = LoginsBLL._GetIDbyName(UserName)
                        With cmdUpdateLogin
                            .Parameters.AddWithValue("@LOGIN_ID", LOGIN_ID)
                            .Parameters.AddWithValue("@LOGIN_Password", UsersBLL.EncryptSHA256Managed(Password, strRandomSalt, True))
                            .Parameters.AddWithValue("@LOGIN_SaltValue", strRandomSalt)
                            sqlConn.Open()
                            savePoint = sqlConn.BeginTransaction()
                            .Transaction = savePoint
                            ReturnedID = .ExecuteScalar()
                        End With

                        If ReturnedID <> LOGIN_ID Then
                            Throw New Exception("Login ID and the Updated ID don't match")
                        End If

                        KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Logins, _
                         GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully"), CreateQuery(cmdUpdateLogin), UserName, sqlConn, savePoint)

                        savePoint.Commit()
                        sqlConn.Close()
                    Catch ex As Exception
                        ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                        If Not savePoint Is Nothing Then savePoint.Rollback()
                    Finally
                        If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
                    End Try

                End Using
            End If
            Return blnUserValidated
        End If
    End Function
    Public Shared Function GetDetails(ByVal UserName As String) As DataTable
        Return Adptr.GetData(UserName)
    End Function
    Public Shared Function Delete(ByVal LOGIN_ID As Integer) As Integer

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlClient.SqlConnection(strConnString)

            Dim cmdDeleteLogin As SqlCommand = sqlConn.CreateCommand
            cmdDeleteLogin.CommandText = "_spKartrisLogins_Delete"

            Dim savePoint As SqlClient.SqlTransaction = Nothing
            cmdDeleteLogin.CommandType = CommandType.StoredProcedure

            Try
                Dim ReturnedID As Integer
                With cmdDeleteLogin
                    .Parameters.AddWithValue("@LOGIN_ID", LOGIN_ID)
                    sqlConn.Open()
                    savePoint = sqlConn.BeginTransaction()
                    .Transaction = savePoint
                    ReturnedID = .ExecuteScalar()
                End With

                If ReturnedID <> LOGIN_ID Then
                    Throw New Exception("Login ID and the Deleted ID don't match")
                End If

                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Logins, _
                 GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully"), CreateQuery(cmdDeleteLogin), LOGIN_ID, sqlConn, savePoint)

                savePoint.Commit()
                sqlConn.Close()
                Return ReturnedID
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                If Not savePoint Is Nothing Then savePoint.Rollback()
                Return 0
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try

        End Using

    End Function
    Public Shared Sub Update(ByVal LOGIN_ID As Integer, ByVal LOGIN_UserName As String, ByVal LOGIN_Password As String, ByVal LOGIN_Live As Boolean, _
                                  ByVal LOGIN_Orders As Boolean, ByVal LOGIN_Products As Boolean, ByVal LOGIN_Config As Boolean, ByVal LOGIN_Protected As Boolean, _
                                  ByVal LOGIN_LanguageID As Integer, ByVal LOGIN_EmailAddress As String, ByVal LOGIN_Tickets As Boolean, ByVal LOGIN_Pushnotifications As String)

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Dim strRandomSalt As String = Membership.GeneratePassword(20, 0)
        Using sqlConn As New SqlClient.SqlConnection(strConnString)

            Dim cmdUpdateLogin As SqlCommand = sqlConn.CreateCommand
            cmdUpdateLogin.CommandText = "_spKartrisLogins_Update"

            Dim savePoint As SqlClient.SqlTransaction = Nothing
            cmdUpdateLogin.CommandType = CommandType.StoredProcedure

            Try
                Dim ReturnedID As Integer
                With cmdUpdateLogin
                    .Parameters.AddWithValue("@LOGIN_ID", LOGIN_ID)
                    .Parameters.AddWithValue("@LOGIN_Username", LOGIN_UserName)
                    .Parameters.AddWithValue("@LOGIN_Password", IIf(String.IsNullOrEmpty(LOGIN_Password), "", UsersBLL.EncryptSHA256Managed(LOGIN_Password, strRandomSalt, True)))
                    .Parameters.AddWithValue("@LOGIN_Live", LOGIN_Live)
                    .Parameters.AddWithValue("@LOGIN_Orders", LOGIN_Orders)
                    .Parameters.AddWithValue("@LOGIN_Products", LOGIN_Products)
                    .Parameters.AddWithValue("@LOGIN_Config", LOGIN_Config)
                    .Parameters.AddWithValue("@LOGIN_Protected", LOGIN_Protected)
                    .Parameters.AddWithValue("@LOGIN_LanguageID", LOGIN_LanguageID)
                    .Parameters.AddWithValue("@LOGIN_EmailAddress", LOGIN_EmailAddress)
                    .Parameters.AddWithValue("@LOGIN_Tickets", LOGIN_Tickets)
                    .Parameters.AddWithValue("@LOGIN_SaltValue", strRandomSalt)
                    .Parameters.AddWithValue("@LOGIN_PushNotifications", LOGIN_Pushnotifications)
                    sqlConn.Open()
                    savePoint = sqlConn.BeginTransaction()
                    .Transaction = savePoint
                    ReturnedID = .ExecuteScalar()
                End With

                If ReturnedID <> LOGIN_ID Then
                    Throw New Exception("Login ID and the Updated ID don't match")
                End If

                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Logins, _
                 GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully"), CreateQuery(cmdUpdateLogin), LOGIN_UserName, sqlConn, savePoint)

                savePoint.Commit()
                sqlConn.Close()
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try

        End Using
    End Sub
    Public Shared Sub Add(ByVal LOGIN_UserName As String, ByVal LOGIN_Password As String, ByVal LOGIN_Live As Boolean, _
                                  ByVal LOGIN_Orders As Boolean, ByVal LOGIN_Products As Boolean, ByVal LOGIN_Config As Boolean, ByVal LOGIN_Protected As Boolean, _
                                  ByVal LOGIN_LanguageID As Integer, ByVal LOGIN_EmailAddress As String, ByVal LOGIN_Tickets As Boolean, ByVal LOGIN_Pushnotifications As String)

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Dim strRandomSalt As String = Membership.GeneratePassword(20, 0)
        Using sqlConn As New SqlClient.SqlConnection(strConnString)

            Dim cmdAddLogin As SqlCommand = sqlConn.CreateCommand
            cmdAddLogin.CommandText = "_spKartrisLogins_Add"

            Dim savePoint As SqlClient.SqlTransaction = Nothing
            cmdAddLogin.CommandType = CommandType.StoredProcedure

            Try
                Dim ReturnedID As Integer
                With cmdAddLogin
                    .Parameters.AddWithValue("@LOGIN_Username", LOGIN_UserName)
                    .Parameters.AddWithValue("@LOGIN_Password", UsersBLL.EncryptSHA256Managed(LOGIN_Password, strRandomSalt, True))
                    .Parameters.AddWithValue("@LOGIN_Live", LOGIN_Live)
                    .Parameters.AddWithValue("@LOGIN_Orders", LOGIN_Orders)
                    .Parameters.AddWithValue("@LOGIN_Products", LOGIN_Products)
                    .Parameters.AddWithValue("@LOGIN_Config", LOGIN_Config)
                    .Parameters.AddWithValue("@LOGIN_Protected", LOGIN_Protected)
                    .Parameters.AddWithValue("@LOGIN_LanguageID", LOGIN_LanguageID)
                    .Parameters.AddWithValue("@LOGIN_EmailAddress", LOGIN_EmailAddress)
                    .Parameters.AddWithValue("@LOGIN_Tickets", LOGIN_Tickets)
                    .Parameters.AddWithValue("@LOGIN_SaltValue", strRandomSalt)
                    .Parameters.AddWithValue("@LOGIN_PushNotifications", LOGIN_Pushnotifications)
                    sqlConn.Open()
                    savePoint = sqlConn.BeginTransaction()
                    .Transaction = savePoint
                    ReturnedID = .ExecuteScalar()
                End With

                If ReturnedID = 0 Then
                    Throw New Exception("ID is 0? Something's not right")
                End If

                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Logins, _
                 GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully"), CreateQuery(cmdAddLogin), LOGIN_UserName, sqlConn, savePoint)

                savePoint.Commit()
                sqlConn.Close()
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try

        End Using
    End Sub
    Public Shared Function _GetIDbyName(ByVal UserName As String) As String
        Return Adptr._GetIDbyName(UserName)
    End Function
    Public Shared Function _GetSupportUsers() As DataTable
        Return Adptr._GetSupportTicketsUsers()
    End Function
    Public Shared Function GetSupportUsers() As DataTable
        Return Adptr.GetSupportTicketsUsers()
    End Function
    Public Shared Function _GetSaltByUserName(ByVal UserName As String) As String
        Return Adptr._GetSaltByUserName(UserName)
    End Function
    Public Shared Function GetLoginsList() As DataTable
        Return Adptr._GetList()
    End Function
End Class
