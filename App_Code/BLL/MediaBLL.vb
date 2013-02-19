'========================================================================
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
Imports kartrisMediaDataTableAdapters
Imports CkartrisEnumerations
Imports CkartrisBLL
Imports CkartrisFormatErrors
Imports System.Web.HttpContext
Imports CkartrisDataManipulation
Imports KartSettingsManager
Public Class MediaBLL

    Private Shared _MediaLinksAdptr As MediaLinksTblAdptr = Nothing
    Protected Shared ReadOnly Property MediaLinksAdptr() As MediaLinksTblAdptr
        Get
            _MediaLinksAdptr = New MediaLinksTblAdptr
            Return _MediaLinksAdptr
        End Get
    End Property

    Private Shared _MediaTypesAdptr As MediaTypesTblAdptr = Nothing
    Protected Shared ReadOnly Property MediaTypesAdptr() As MediaTypesTblAdptr
        Get
            _MediaTypesAdptr = New MediaTypesTblAdptr
            Return _MediaTypesAdptr
        End Get
    End Property
    
    Public Shared Function _GetMediaLinksByParent(ByVal intParentID As Integer, ByVal strParentType As String) As DataTable
        Return MediaLinksAdptr._GetByParent(intParentID, strParentType)
    End Function
    Public Shared Function GetMediaLinksByParent(ByVal intParentID As Integer, ByVal strParentType As String) As DataTable
        Return MediaLinksAdptr.GetByParent(intParentID, strParentType)
    End Function
    Public Shared Function _GetMediaLinkByID(ByVal numMediaLinkID As Integer) As DataTable
        Return MediaLinksAdptr._GetByID(numMediaLinkID)
    End Function

    Public Shared Function _GetMediaTypes() As DataTable
        Return MediaTypesAdptr._GetData()
    End Function
    Public Shared Function _GetMediaTypesByID(ByVal numMediaTypeID As Integer) As DataTable
        Return MediaTypesAdptr._GetByID(numMediaTypeID)
    End Function

    Public Shared Sub _ChangeMediaLinkOrder(ByVal numMediaLinkID As Integer, ByVal numParentID As Integer, ByVal chrParentType As Char, ByVal chrDirection As Char)
        MediaLinksAdptr._ChangeSortValue(numMediaLinkID, numParentID, chrParentType, chrDirection)
    End Sub
    Public Shared Function _AddMediaLink(ByVal numParentID As Integer, ByVal chrParentType As Char, _
                                         ByVal strEmbedSource As String, ByVal numMediaTypeID As Short, ByVal numHeight As Integer, _
                                         ByVal numWidth As Integer, ByVal blnDownloadable As Boolean, ByVal strParameter As String, _
                                         ByVal blnLive As Boolean, ByRef NewID As Integer, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisMediaLinks_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                cmd.Parameters.AddWithValue("@ParentID", FixNullToDB(numParentID, "i"))
                cmd.Parameters.AddWithValue("@ParentType", FixNullToDB(chrParentType, "c"))
                cmd.Parameters.AddWithValue("@EmbedSource", FixNullToDB(strEmbedSource))
                cmd.Parameters.AddWithValue("@MediaTypeID", FixNullToDB(numMediaTypeID, "i"))
                cmd.Parameters.AddWithValue("@Height", FixNullToDB(numHeight, "i"))
                cmd.Parameters.AddWithValue("@Width", FixNullToDB(numWidth, "i"))
                cmd.Parameters.AddWithValue("@Downloadable", FixNullToDB(blnDownloadable, "b"))
                cmd.Parameters.AddWithValue("@Parameters", FixNullToDB(strParameter))
                cmd.Parameters.AddWithValue("@Live", FixNullToDB(blnLive, "b"))
                cmd.Parameters.AddWithValue("@NewML_ID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint
                cmd.ExecuteNonQuery()

                If cmd.Parameters("@NewML_ID").Value Is Nothing OrElse _
                    cmd.Parameters("@NewML_ID").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                NewID = cmd.Parameters("@NewML_ID").Value

                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
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
    Public Shared Function _UpdateMediaLink(ByVal MediaLinkID As Integer, _
                                         ByVal strEmbedSource As String, ByVal numMediaTypeID As Short, ByVal numHeight As Integer, _
                                         ByVal numWidth As Integer, ByVal blnDownloadable As Boolean, ByVal strParameter As String, _
                                         ByVal blnLive As Boolean, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisMediaLinks_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                cmd.Parameters.AddWithValue("@ML_ID", FixNullToDB(MediaLinkID, "i"))
                cmd.Parameters.AddWithValue("@EmbedSource", FixNullToDB(strEmbedSource))
                cmd.Parameters.AddWithValue("@MediaTypeID", FixNullToDB(numMediaTypeID, "i"))
                cmd.Parameters.AddWithValue("@Height", FixNullToDB(numHeight, "i"))
                cmd.Parameters.AddWithValue("@Width", FixNullToDB(numWidth, "i"))
                cmd.Parameters.AddWithValue("@Downloadable", FixNullToDB(blnDownloadable, "b"))
                cmd.Parameters.AddWithValue("@Parameters", FixNullToDB(strParameter))
                cmd.Parameters.AddWithValue("@Live", FixNullToDB(blnLive, "b"))

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint
                cmd.ExecuteNonQuery()
                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
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
    Public Shared Function _DeleteMediaLink(ByVal MediaLinkID As Integer, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisMediaLinks_Delete"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                cmd.Parameters.AddWithValue("@ML_ID", FixNullToDB(MediaLinkID, "i"))
                
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint
                cmd.ExecuteNonQuery()
                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
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

    Public Shared Function _AddMediaType(ByVal strMediaType As String, ByVal numDefaultHeight As Integer, _
                                         ByVal numDefaultWidth As Integer, ByVal strDefaultParameters As String, _
                                         ByVal blnDownloadable As Boolean, ByVal blnEmbed As Boolean, _
                                         ByVal blnInline As Boolean, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisMediaTypes_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                cmd.Parameters.AddWithValue("@Extension", FixNullToDB(strMediaType))
                cmd.Parameters.AddWithValue("@DefaultHeight", FixNullToDB(numDefaultHeight, "i"))
                cmd.Parameters.AddWithValue("@DefaultWidth", FixNullToDB(numDefaultWidth, "i"))
                cmd.Parameters.AddWithValue("@DefaultParameters", FixNullToDB(strDefaultParameters))
                cmd.Parameters.AddWithValue("@Downloadable", FixNullToDB(blnDownloadable, "b"))
                cmd.Parameters.AddWithValue("@Embed", FixNullToDB(blnEmbed, "b"))
                cmd.Parameters.AddWithValue("@Inline", FixNullToDB(blnInline, "b"))
                cmd.Parameters.AddWithValue("@NewMT_ID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint
                cmd.ExecuteNonQuery()

                If cmd.Parameters("@NewMT_ID").Value Is Nothing OrElse _
                    cmd.Parameters("@NewMT_ID").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
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
    Public Shared Function _UpdateMediaType(ByVal numDefaultHeight As Integer, ByVal numDefaultWidth As Integer, _
                                        ByVal strDefaultParameters As String, _
                                        ByVal blnDownloadable As Boolean, ByVal blnEmbed As Boolean, _
                                        ByVal blnInline As Boolean, _
                                        ByVal MediaTypeID As Integer, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisMediaTypes_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                cmd.Parameters.AddWithValue("@MT_ID", FixNullToDB(MediaTypeID, "i"))
                cmd.Parameters.AddWithValue("@DefaultHeight", FixNullToDB(numDefaultHeight, "i"))
                cmd.Parameters.AddWithValue("@DefaultWidth", FixNullToDB(numDefaultWidth, "i"))
                cmd.Parameters.AddWithValue("@DefaultParameters", FixNullToDB(strDefaultParameters))
                cmd.Parameters.AddWithValue("@Downloadable", FixNullToDB(blnDownloadable, "b"))
                cmd.Parameters.AddWithValue("@Embed", FixNullToDB(blnEmbed, "b"))
                cmd.Parameters.AddWithValue("@Inline", FixNullToDB(blnInline, "b"))

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint
                cmd.ExecuteNonQuery()
                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
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
    Public Shared Function _DeleteMediaType(ByVal MediaTypeID As Integer, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisMediaTypes_Delete"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                cmd.Parameters.AddWithValue("@MT_ID", FixNullToDB(MediaTypeID, "i"))

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint
                cmd.ExecuteNonQuery()
                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
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
End Class
