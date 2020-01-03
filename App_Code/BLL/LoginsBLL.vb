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

    ''' <summary>
    ''' Validate admin login
    ''' Check username and password against db
    ''' </summary>
    ''' <param name="UserName">The UserName (login)</param>
    ''' <param name="Password">The password</param>
    ''' <param name="blnDirect">If true, ID and pw are run directly against the db (i.e. assumed password supplied is hashed already)</param>
    ''' <remarks></remarks>
    Public Shared Function Validate(ByVal UserName As String, ByVal Password As String, Optional ByVal blnDirect As Boolean = False) As Integer
        If blnDirect Then
            Return Adptr._Validate(UserName, Password)

            'KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Logins,
            ' "Login", "username: " & UserName & " ---  password(hashed): " & Password, UserName)
        Else
            Dim strUserSalt As String = _GetSaltByUserName(UserName)
            Dim blnUserValidated As Boolean = Adptr._Validate(UserName, UsersBLL.EncryptSHA256Managed(Password, strUserSalt, True))

            KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Logins,
             "Login", "username: " & UserName & " ---  password(hashed): " & UsersBLL.EncryptSHA256Managed(Password, strUserSalt, True), UserName)

            'LogError("Login info: " & "username: " & UserName & " ---  password(hashed): " & UsersBLL.EncryptSHA256Managed(Password, strUserSalt, True))

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
                            Throw New Exception("Login ID And the Updated ID don't match")
                        End If

                        KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Logins,
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

    ''' <summary>
    ''' Get login details
    ''' </summary>
    ''' <param name="UserName">The UserName (login)</param>
    ''' <remarks></remarks>
    Public Shared Function GetDetails(ByVal UserName As String) As DataTable
        Return Adptr.GetData(UserName)
    End Function

    ''' <summary>
    ''' Delete login
    ''' </summary>
    ''' <param name="LOGIN_ID">The db ID of the login record</param>
    ''' <remarks></remarks>
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

                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Logins,
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

    ''' <summary>
    ''' Update login
    ''' </summary>
    ''' <param name="LOGIN_ID">The db ID of the login record</param>
    ''' <param name="LOGIN_UserName">The UserName (login)</param>
    ''' <param name="LOGIN_Password">Password (raw)</param>
    ''' <param name="LOGIN_Live">Whether login is activated/live</param>
    ''' <param name="LOGIN_Orders">Whether login can admin orders and customer data</param>
    ''' <param name="LOGIN_Products">Whether login can admin product data</param>
    ''' <param name="LOGIN_Config">Whether login can change config settings and other administration tasks</param>
    ''' <param name="LOGIN_Protected">Default logins are protected, so you cannot delete all logins from a site</param>
    ''' <param name="LOGIN_LanguageID">Language ID for interface for this login</param>
    ''' <param name="LOGIN_EmailAddress">Email address</param>
    ''' <param name="LOGIN_Tickets">Whether login can deal with support tickets</param>
    ''' <param name="LOGIN_Pushnotifications">Key for push notifications on Android or Windows apps</param>
    ''' <remarks></remarks>
    Public Shared Sub Update(ByVal LOGIN_ID As Integer, ByVal LOGIN_UserName As String, ByVal LOGIN_Password As String, ByVal LOGIN_Live As Boolean,
                                  ByVal LOGIN_Orders As Boolean, ByVal LOGIN_Products As Boolean, ByVal LOGIN_Config As Boolean, ByVal LOGIN_Protected As Boolean,
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

                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Logins,
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

    ''' <summary>
    ''' Add login
    ''' </summary>
    ''' <param name="LOGIN_UserName">The UserName (login)</param>
    ''' <param name="LOGIN_Password">Password (raw)</param>
    ''' <param name="LOGIN_Live">Whether login is activated/live</param>
    ''' <param name="LOGIN_Orders">Whether login can admin orders and customer data</param>
    ''' <param name="LOGIN_Products">Whether login can admin product data</param>
    ''' <param name="LOGIN_Config">Whether login can change config settings and other administration tasks</param>
    ''' <param name="LOGIN_Protected">Default logins are protected, so you cannot delete all logins from a site</param>
    ''' <param name="LOGIN_LanguageID">Language ID for interface for this login</param>
    ''' <param name="LOGIN_EmailAddress">Email address</param>
    ''' <param name="LOGIN_Tickets">Whether login can deal with support tickets</param>
    ''' <param name="LOGIN_Pushnotifications">Key for push notifications on Android or Windows apps</param>
    ''' <remarks></remarks>
    Public Shared Sub Add(ByVal LOGIN_UserName As String, ByVal LOGIN_Password As String, ByVal LOGIN_Live As Boolean,
                                  ByVal LOGIN_Orders As Boolean, ByVal LOGIN_Products As Boolean, ByVal LOGIN_Config As Boolean, ByVal LOGIN_Protected As Boolean,
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

                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Logins,
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

    ''' <summary>
    ''' Find login ID from UserName
    ''' </summary>
    ''' <param name="UserName">The UserName (login)</param>
    ''' <remarks></remarks>
    Public Shared Function _GetIDbyName(ByVal UserName As String) As String
        Return Adptr._GetIDbyName(UserName)
    End Function

    ''' <summary>
    ''' Find logins with support ticket access
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Function _GetSupportUsers() As DataTable
        Return Adptr._GetSupportTicketsUsers()
    End Function

    ''' <summary>
    ''' Find logins with support ticket access (front end version)
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Function GetSupportUsers() As DataTable
        Return Adptr.GetSupportTicketsUsers()
    End Function

    ''' <summary>
    ''' Find a login's salt value (random string used for hashing password)
    ''' </summary>
    ''' <param name="UserName">The UserName (login)</param>
    ''' <remarks></remarks>
    Public Shared Function _GetSaltByUserName(ByVal UserName As String) As String
        Return Adptr._GetSaltByUserName(UserName)
    End Function

    ''' <summary>
    ''' List of all logins
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Function GetLoginsList() As DataTable
        Return Adptr._GetList()
    End Function
End Class
