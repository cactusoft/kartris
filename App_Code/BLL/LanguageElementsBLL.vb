'========================================================================
'Kartris - www.kartris.com
'Copyright 2015 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports kartrisLanguageData
Imports kartrisLanguageDataTableAdapters
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports CkartrisFormatErrors

Public Class LanguageElementsBLL

    Private Shared _Adptr As LanguageElementsTblAdptr = Nothing

    Protected Shared ReadOnly Property Adptr() As LanguageElementsTblAdptr
        Get
            _Adptr = New LanguageElementsTblAdptr()
            Return _Adptr
        End Get
    End Property

    Public Shared Function GetLanguageElements() As LanguageElementsDataTable
        Return Adptr.GetData()
    End Function

    Public Shared Function GetLanguageElementsByLanguageID(ByVal _LanguageID As Int16) As LanguageElementsDataTable
        Return Adptr.GetDataByLanguageID(_LanguageID)
    End Function

    Public Shared Function GetElementValue(ByVal _LanguageID As Short, ByVal _TypeID As LANG_ELEM_TABLE_TYPE, _
                                        ByVal _FieldID As LANG_ELEM_FIELD_NAME, ByVal _ParentID As Long) As String
        Dim strValue As String = FixNullFromDB(Adptr.GetElementValue_s(_LanguageID, _TypeID, _FieldID, _ParentID))
        If strValue Is Nothing Then strValue = "# -LE- #" '' The string is not found
        Return strValue
    End Function

    Public Shared Function _GetElementsByTypeAndParent(ByVal pTypeID As Byte, ByVal pParentID As Long) As DataTable
        Return Adptr._GetByTypeAndParent(pTypeID, pParentID)
    End Function

    Public Shared Function _GetLanguageElementsSchema() As DataTable
        Return Adptr.GetDataByLanguageID(0)
    End Function

    Public Shared Function _GetTotalsPerLanguage() As DataTable
        Return Adptr.GetTotalsPerLanguage()
    End Function

    Public Shared Function _FixLanguageElements(ByVal numSourceLanguageID As Byte, ByVal numDistinationLanguageID As Byte, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisLanguageElements_FixMissingElements"

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

    Public Shared Function _AddLanguageElements( _
                            ByVal ptblElements As DataTable, _
                            ByVal enumType As LANG_ELEM_TABLE_TYPE, _
                            ByVal ItemID As Long, _
                            ByVal sqlConn As SqlClient.SqlConnection, _
                            ByVal savePoint As SqlClient.SqlTransaction) As Boolean
        Try
            Dim cmd As New SqlClient.SqlCommand("_spKartrisLanguageElements_Add", sqlConn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Transaction = savePoint
            For Each row As DataRow In ptblElements.Rows
                cmd.Parameters.AddWithValue("@LE_LanguageID", row("_LE_LanguageID"))
                cmd.Parameters.AddWithValue("@LE_TypeID", enumType)
                cmd.Parameters.AddWithValue("@LE_FieldID", row("_LE_FieldID"))
                cmd.Parameters.AddWithValue("@LE_ParentID", ItemID)
                cmd.Parameters.AddWithValue("@LE_Value", FixNullToDB(row("_LE_Value")))
                cmd.ExecuteNonQuery()
                cmd.Parameters.Clear()
            Next
            'End Using
            Return True
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try

        Return False
    End Function
    Public Shared Function _UpdateLanguageElements( _
                            ByVal ptblElements As DataTable, _
                            ByVal enumType As LANG_ELEM_TABLE_TYPE, _
                            ByVal ItemID As Long, _
                            ByVal sqlConn As SqlClient.SqlConnection, _
                            ByVal savePoint As SqlClient.SqlTransaction) As Boolean
        '' No need to update the languageElements, will send nothing as parameter (like Update Basic Info.)
        If ptblElements Is Nothing Then Return True

        Try
            Dim cmd As New SqlClient.SqlCommand("_spKartrisLanguageElements_Update", sqlConn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Transaction = savePoint
            For Each row As DataRow In ptblElements.Rows
                cmd.Parameters.AddWithValue("@LE_LanguageID", row("_LE_LanguageID"))
                cmd.Parameters.AddWithValue("@LE_TypeID", enumType)
                cmd.Parameters.AddWithValue("@LE_FieldID", row("_LE_FieldID"))
                cmd.Parameters.AddWithValue("@LE_ParentID", ItemID)
                cmd.Parameters.AddWithValue("@LE_Value", FixNullToDB(row("_LE_Value"), "s"))
                cmd.ExecuteNonQuery()
                cmd.Parameters.Clear()
            Next
            Return True
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try
        Return False
    End Function
    

End Class
