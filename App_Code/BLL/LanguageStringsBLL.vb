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
Imports CkartrisDataManipulation
Imports System.Web.HttpContext
Imports kartrisLanguageData
Imports kartrisLanguageDataTableAdapters
Imports CkartrisFormatErrors
Imports CkartrisEnumerations

Public Class LanguageStringsBLL

    Private Shared _Adptr As LanguageStringsTblAdptr = Nothing

    Protected Shared ReadOnly Property Adptr() As LanguageStringsTblAdptr
        Get
            'If _Adptr Is Nothing Then
            _Adptr = New LanguageStringsTblAdptr
            'End If
            Return _Adptr
        End Get
    End Property

    Public Shared Function GetLanguageStringsByID(ByVal _LanguageID As Short) As LanguageStringsDataTable
        Return Adptr.GetDataByLanguageID(_LanguageID)
    End Function

    Public Shared Function GetLanguageStringsByClassName(ByVal _LanguageID As Short, ByVal _ClassName As String) As LanguageStringsDataTable
        Return Adptr.GetDataByClassName(_LanguageID, _ClassName)
    End Function

    Public Shared Function GetLanguageStringsByVirtualPath(ByVal _LanguageID As Short, ByVal _VirtualPath As String) As LanguageStringsDataTable
        Return Adptr.GetDataByVirtualPath(_LanguageID, _VirtualPath)
    End Function
    Public Shared Function _GetByID(ByVal pLanguageID As Byte, ByVal pFrontBack As Char, ByVal pLSName As String) As DataTable
        Return Adptr._GetByID(pFrontBack, pLanguageID, pLSName)
    End Function
    Public Shared Function _Search(ByVal pSearchBy As String, ByVal pSearchKey As String, ByVal pFrontBack As String, ByVal pLanguageID As Byte) As DataTable
        Return Adptr._Search(pSearchBy, pSearchKey, pLanguageID, pFrontBack)
    End Function

    Public Shared Function _SearchForUpdate(ByVal pSearchBy As String, ByVal pSearchKey As String, _
                                        ByVal pFrontBack As String, ByVal pDefaultLanguageID As Byte, ByVal pLanguageID As Byte) As DataTable
        Return Adptr._SearchForUpdate(pSearchBy, pSearchKey, pFrontBack, pDefaultLanguageID, pLanguageID)
    End Function
    Public Shared Function _GetTotalsPerLanguage() As DataTable
        Return Adptr.GetTotalsPerLanguage()
    End Function

    Public Shared Function _FixLanguageStrings(ByVal numSourceLanguageID As Byte, ByVal numDistinationLanguageID As Byte, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisLanguageStrings_FixMissingStrings"

            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try

                cmd.Parameters.AddWithValue("@SourceLanguage", FixNullToDB(numSourceLanguageID, "i"))
                cmd.Parameters.AddWithValue("@DistinationLanguage", FixNullToDB(numDistinationLanguageID, "i"))

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                cmd.ExecuteNonQuery()

                savePoint.Commit()
                sqlConn.Close()
                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try

        End Using

        Return False
    End Function
    Public Shared Function _AddLanguageString(ByVal _LanguageID As Short, ByVal _FrontBack As String, ByVal _Name As String, _
         ByVal _Value As String, ByVal _Description As String, ByVal _DefaultValue As String, _
         ByVal _VirtualPath As String, ByVal _ClassName As String, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlClient.SqlConnection(strConnString) '', cmdAddLanguageString As New SqlClient.SqlCommand("_spKartrisLanguageStrings_Add", sqlConn)

            Dim cmdAddLanguageString As SqlCommand = sqlConn.CreateCommand
            cmdAddLanguageString.CommandText = "_spKartrisLanguageStrings_Add"

            Dim savePoint As SqlClient.SqlTransaction = Nothing
            cmdAddLanguageString.CommandType = CommandType.StoredProcedure

            Try
                cmdAddLanguageString.Parameters.AddWithValue("@LS_LangID", _LanguageID)
                cmdAddLanguageString.Parameters.AddWithValue("@LS_FrontBack", FixNullToDB(_FrontBack))
                cmdAddLanguageString.Parameters.AddWithValue("@LS_Name", FixNullToDB(_Name))
                cmdAddLanguageString.Parameters.AddWithValue("@LS_Value", FixNullToDB(_Value))
                cmdAddLanguageString.Parameters.AddWithValue("@LS_Description", FixNullToDB(_Description))
                cmdAddLanguageString.Parameters.AddWithValue("@LS_VersionAdded", KARTRIS_VERSION)
                cmdAddLanguageString.Parameters.AddWithValue("@LS_DefaultValue", FixNullToDB(_DefaultValue))
                cmdAddLanguageString.Parameters.AddWithValue("@LS_VirtualPath", FixNullToDB(_VirtualPath))
                cmdAddLanguageString.Parameters.AddWithValue("@LS_ClassName", FixNullToDB(_ClassName))

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddLanguageString.Transaction = savePoint

                cmdAddLanguageString.ExecuteNonQuery()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.SiteText, _
                   strMsg, CreateQuery(cmdAddLanguageString), _Name, sqlConn, savePoint)

                savePoint.Commit()
                sqlConn.Close()

                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return False
    End Function

    Public Shared Function _UpdateLanguageString(ByVal _LanguageID As Short, ByVal _FrontBack As String, ByVal _Name As String, _
        ByVal _Value As String, ByVal _Description As String, ByVal _DefaultValue As String, _
        ByVal _VirtualPath As String, ByVal _ClassName As String, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlClient.SqlConnection(strConnString) '', cmdUpdateLanguageString As New SqlClient.SqlCommand("_spKartrisLanguageStrings_Update", sqlConn)

            Dim cmdUpdateLanguageString As SqlCommand = sqlConn.CreateCommand
            cmdUpdateLanguageString.CommandText = "_spKartrisLanguageStrings_Update"

            Dim savePoint As SqlClient.SqlTransaction = Nothing
            cmdUpdateLanguageString.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateLanguageString.Parameters.AddWithValue("@Original_LS_LanguageID", _LanguageID)
                cmdUpdateLanguageString.Parameters.AddWithValue("@Original_LS_FrontBack", FixNullToDB(_FrontBack))
                cmdUpdateLanguageString.Parameters.AddWithValue("@Original_LS_Name", FixNullToDB(_Name))
                cmdUpdateLanguageString.Parameters.AddWithValue("@LS_Value", FixNullToDB(_Value))
                cmdUpdateLanguageString.Parameters.AddWithValue("@LS_Description", FixNullToDB(_Description))
                cmdUpdateLanguageString.Parameters.AddWithValue("@LS_DefaultValue", FixNullToDB(_DefaultValue))
                cmdUpdateLanguageString.Parameters.AddWithValue("@LS_VirtualPath", FixNullToDB(_VirtualPath))
                cmdUpdateLanguageString.Parameters.AddWithValue("@LS_ClassName", FixNullToDB(_ClassName))

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateLanguageString.Transaction = savePoint

                cmdUpdateLanguageString.ExecuteNonQuery()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.SiteText, _
                   strMsg, CreateQuery(cmdUpdateLanguageString), _Name, sqlConn, savePoint)

                savePoint.Commit()
                sqlConn.Close()

                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return False
    End Function

    Public Shared Function _TranslateLanguageString(ByVal chrFrontBack As Char, ByVal strName As String, _
        ByVal strValue As String, ByVal strDescription As String, _
        ByVal numLanguageID As Byte, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlClient.SqlConnection(strConnString) '', cmdTranslateLS As New SqlClient.SqlCommand("_spKartrisLanguageStrings_Translate", sqlConn)

            Dim cmdTranslateLS As SqlCommand = sqlConn.CreateCommand
            cmdTranslateLS.CommandText = "_spKartrisLanguageStrings_Translate"

            Dim savePoint As SqlClient.SqlTransaction = Nothing
            cmdTranslateLS.CommandType = CommandType.StoredProcedure

            Try
                cmdTranslateLS.Parameters.AddWithValue("@LanguageID", numLanguageID)
                cmdTranslateLS.Parameters.AddWithValue("@FrontBack", FixNullToDB(chrFrontBack, "c"))
                cmdTranslateLS.Parameters.AddWithValue("@Name", FixNullToDB(strName))
                cmdTranslateLS.Parameters.AddWithValue("@Value", FixNullToDB(strValue))
                cmdTranslateLS.Parameters.AddWithValue("@Description", FixNullToDB(strDescription))

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdTranslateLS.Transaction = savePoint

                cmdTranslateLS.ExecuteNonQuery()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.SiteText, _
                   strMsg, CreateQuery(cmdTranslateLS), strName, sqlConn, savePoint)

                savePoint.Commit()
                sqlConn.Close()

                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return False
    End Function

    ''=======================
    '' TO BE DEPRECATED LATER
    ''=======================
    Public Shared Sub _UpdateLSUsage(ByVal strName As String, ByVal strIdentifier As String, ByVal chrClassOrPath As Char)
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Dim sqlConn As New SqlClient.SqlConnection(strConnString)
        Dim cmdUpdateUsage As New SqlClient.SqlCommand("_spKartrisLSUsage_SetUsed", sqlConn)
        cmdUpdateUsage.CommandType = CommandType.StoredProcedure

        cmdUpdateUsage.Parameters.AddWithValue("@LS_Name", strName)
        cmdUpdateUsage.Parameters.AddWithValue("@LS_Identifier", strIdentifier)
        cmdUpdateUsage.Parameters.AddWithValue("@LS_ClassOrPath", chrClassOrPath)
        Try
            sqlConn.Open()
            cmdUpdateUsage.ExecuteNonQuery()
            sqlConn.Close()
        Catch ex As SqlClient.SqlException
            MsgBox("error" & ex.Message)
        Catch ex As Exception
            MsgBox("error" & ex.Message)
        Finally
            If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
        End Try

    End Sub
End Class
