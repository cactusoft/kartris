'========================================================================
'Kartris - www.kartris.com
'Copyright 2016 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports kartrisConfigData
Imports kartrisShippingDataTableAdapters
Imports CkartrisEnumerations
Imports System.Web.HttpContext
Imports CkartrisFormatErrors
Imports CkartrisDataManipulation

Public Class ShippingBLL
    Private Shared _ShippingMethodsRatesAdptr As ShippingMethodsRatesTblAdptr = Nothing
    Protected Shared ReadOnly Property ShippingMethodsRatesAdptr() As ShippingMethodsRatesTblAdptr
        Get
            _ShippingMethodsRatesAdptr = New ShippingMethodsRatesTblAdptr
            Return _ShippingMethodsRatesAdptr
        End Get
    End Property

    Private Shared _ShippingMethodsAdptr As ShippingMethodsTblAdptr = Nothing
    Protected Shared ReadOnly Property ShippingMethodsAdptr() As ShippingMethodsTblAdptr
        Get
            _ShippingMethodsAdptr = New ShippingMethodsTblAdptr
            Return _ShippingMethodsAdptr
        End Get
    End Property

    Private Shared _ShippingRatesAdptr As ShippingRatesTblAdptr = Nothing
    Protected Shared ReadOnly Property ShippingRatesAdptr() As ShippingRatesTblAdptr
        Get
            _ShippingRatesAdptr = New ShippingRatesTblAdptr
            Return _ShippingRatesAdptr
        End Get
    End Property

    Private Shared _ShippingZonesAdptr As ShippingZonesTblAdptr = Nothing
    Protected Shared ReadOnly Property ShippingZonesAdptr() As ShippingZonesTblAdptr
        Get
            _ShippingZonesAdptr = New ShippingZonesTblAdptr
            Return _ShippingZonesAdptr
        End Get
    End Property

    Private Shared _DestinationsAdptr As DestinationsTblAdptr = Nothing
    Protected Shared ReadOnly Property DestinationsAdptr() As DestinationsTblAdptr
        Get
            _DestinationsAdptr = New DestinationsTblAdptr
            Return _DestinationsAdptr
        End Get
    End Property

#Region " Shipping Methods Rates  "
    Public Shared Function GetShippingMethodsRatesByLanguage(ByVal _DestinationID As Integer, ByVal _Boundary As Decimal, ByVal _LanguageID As Integer) As DataTable
        Return ShippingMethodsRatesAdptr.GetData(_DestinationID, _Boundary, _LanguageID)
    End Function
    Public Shared Function GetShippingMethodsRatesByNameAndLanguage(ByVal _ShippingName As String, ByVal _DestinationID As Integer, ByVal _Boundary As Decimal, ByVal _LanguageID As Integer) As DataTable
        Return ShippingMethodsRatesAdptr.GetDataByName(_DestinationID, _Boundary, _ShippingName, _LanguageID)
    End Function
#End Region

#Region " Shipping Methods  "
    Public Shared Function _GetShippingMethdsByLanguage(ByVal _LanguageID As Byte) As DataTable
        Return ShippingMethodsAdptr._GetByLanguage(_LanguageID)
    End Function

    Public Shared Function _GetShippingMethodNameByID(ByVal numMethodID As Byte, ByVal numLanguageID As Byte) As String
        Return LanguageElementsBLL.GetElementValue( _
          numLanguageID, LANG_ELEM_TABLE_TYPE.ShippingMethods, LANG_ELEM_FIELD_NAME.Name, numMethodID)
    End Function

    Public Shared Function _AddNewShippingMethod(ByVal tblElements As DataTable, ByVal blnLive As Boolean, _
                                          ByVal numOrderBy As Byte, ByVal numTaxBandID As Byte, ByVal numTaxBandID2 As Byte, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdAddShippingMethod As SqlCommand = sqlConn.CreateCommand
            cmdAddShippingMethod.CommandText = "_spKartrisShippingMethods_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmdAddShippingMethod.CommandType = CommandType.StoredProcedure

            Try
                cmdAddShippingMethod.Parameters.AddWithValue("@SM_Live", blnLive)
                cmdAddShippingMethod.Parameters.AddWithValue("@SM_OrderByValue", numOrderBy)
                cmdAddShippingMethod.Parameters.AddWithValue("@SM_Tax", numTaxBandID)
                cmdAddShippingMethod.Parameters.AddWithValue("@SM_Tax2", numTaxBandID2)
                cmdAddShippingMethod.Parameters.AddWithValue("@SM_NewID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddShippingMethod.Transaction = savePoint

                cmdAddShippingMethod.ExecuteNonQuery()

                If cmdAddShippingMethod.Parameters("@SM_NewID").Value Is Nothing OrElse _
                    cmdAddShippingMethod.Parameters("@SM_NewID").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                Dim intNewShippingMethodID As Long = cmdAddShippingMethod.Parameters("@SM_NewID").Value
                If Not LanguageElementsBLL._AddLanguageElements( _
                        tblElements, LANG_ELEM_TABLE_TYPE.ShippingMethods, intNewShippingMethodID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                savePoint.Commit()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
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

    Public Shared Function _UpdateShippingMethod(ByVal tblElements As DataTable, ByVal numShippingMethodID As Byte, ByVal blnLive As Boolean, _
                                          ByVal numOrderBy As Byte, ByVal numTaxBandID As Byte, ByVal numTaxBandID2 As Byte, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdUpdateShippingMethod As SqlCommand = sqlConn.CreateCommand
            cmdUpdateShippingMethod.CommandText = "_spKartrisShippingMethods_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateShippingMethod.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateShippingMethod.Parameters.AddWithValue("@SM_ID", numShippingMethodID)
                cmdUpdateShippingMethod.Parameters.AddWithValue("@SM_Live", blnLive)
                cmdUpdateShippingMethod.Parameters.AddWithValue("@SM_Tax", numTaxBandID)
                cmdUpdateShippingMethod.Parameters.AddWithValue("@SM_Tax2", numTaxBandID2)
                cmdUpdateShippingMethod.Parameters.AddWithValue("@SM_OrderByValue", numOrderBy)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateShippingMethod.Transaction = savePoint

                cmdUpdateShippingMethod.ExecuteNonQuery()

                If Not LanguageElementsBLL._UpdateLanguageElements( _
                        tblElements, LANG_ELEM_TABLE_TYPE.ShippingMethods, numShippingMethodID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                savePoint.Commit()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
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

    Public Shared Function _DeleteShippingMethod(ByVal numShippingMethodID As Long, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdDeleteShippingMethod As SqlCommand = sqlConn.CreateCommand
            cmdDeleteShippingMethod.CommandText = "_spKartrisShippingMethods_Delete"
            Dim savePoint As SqlTransaction = Nothing
            cmdDeleteShippingMethod.CommandType = CommandType.StoredProcedure
            Try
                cmdDeleteShippingMethod.Parameters.AddWithValue("@SM_ID", numShippingMethodID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdDeleteShippingMethod.Transaction = savePoint

                cmdDeleteShippingMethod.ExecuteNonQuery()

                savePoint.Commit()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
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

#End Region

#Region " Shipping Rates  "

    Public Shared Function _GetRatesByMethodAndZone(ByVal ShippingMethodID As Byte, ByVal ShippingZoneID As Byte) As DataTable
        Return ShippingRatesAdptr._GetByMethodAndZone(ShippingMethodID, ShippingZoneID)
    End Function
    Public Shared Function _GetShippingZonesByMethod(ByVal numShippingMethodID As Byte) As DataTable
        Return ShippingRatesAdptr._GetZonesByMethod(numShippingMethodID)
    End Function

    Public Shared Function _UpdateShippingRate(ByVal numShippingRateID As Integer, ByVal numNewRate As Single, ByVal strShippingGateways As String, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdUpdateShippingRate As SqlCommand = sqlConn.CreateCommand
            cmdUpdateShippingRate.CommandText = "_spKartrisShippingRates_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateShippingRate.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateShippingRate.Parameters.AddWithValue("@S_ID", numShippingRateID)
                cmdUpdateShippingRate.Parameters.AddWithValue("@NewRate", numNewRate)
                cmdUpdateShippingRate.Parameters.AddWithValue("@S_ShippingGateways", strShippingGateways)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateShippingRate.Transaction = savePoint

                cmdUpdateShippingRate.ExecuteNonQuery()

                savePoint.Commit()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
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
    Public Shared Function _DeleteShippingRate(ByVal numShippingRateID As Integer, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdDeleteShippingRate As SqlCommand = sqlConn.CreateCommand
            cmdDeleteShippingRate.CommandText = "_spKartrisShippingRates_DeleteByID"
            Dim savePoint As SqlTransaction = Nothing
            cmdDeleteShippingRate.CommandType = CommandType.StoredProcedure
            Try
                cmdDeleteShippingRate.Parameters.AddWithValue("@S_ID", numShippingRateID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdDeleteShippingRate.Transaction = savePoint

                cmdDeleteShippingRate.ExecuteNonQuery()

                savePoint.Commit()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
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
    Public Shared Function _DeleteShippingRateByMethodAndZone(ByVal numShippingMethodID As Byte, _
                                                       ByVal numShippingZoneID As Byte, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdDeleteShippingRate As SqlCommand = sqlConn.CreateCommand
            cmdDeleteShippingRate.CommandText = "_spKartrisShippingRates_DeleteByMethodAndZone"
            Dim savePoint As SqlTransaction = Nothing
            cmdDeleteShippingRate.CommandType = CommandType.StoredProcedure

            Try
                cmdDeleteShippingRate.Parameters.AddWithValue("@SM_ID", numShippingMethodID)
                cmdDeleteShippingRate.Parameters.AddWithValue("@SZ_ID", numShippingZoneID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdDeleteShippingRate.Transaction = savePoint

                cmdDeleteShippingRate.ExecuteNonQuery()

                savePoint.Commit()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
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
    Public Shared Function _AddNewShippingRate(ByVal numShippingMethodID As Byte, ByVal numShippingZoneID As Byte, _
                              ByVal numBoundary As Single, ByVal numRate As Single, ByVal strShippingGateways As String, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdAddShippingRate As SqlCommand = sqlConn.CreateCommand
            cmdAddShippingRate.CommandText = "_spKartrisShippingRates_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmdAddShippingRate.CommandType = CommandType.StoredProcedure
            Try
                cmdAddShippingRate.Parameters.AddWithValue("@SM_ID", numShippingMethodID)
                cmdAddShippingRate.Parameters.AddWithValue("@SZ_ID", numShippingZoneID)
                cmdAddShippingRate.Parameters.AddWithValue("@S_Boundary", numBoundary)
                cmdAddShippingRate.Parameters.AddWithValue("@S_Rate", numRate)
                cmdAddShippingRate.Parameters.AddWithValue("@S_ShippingGateways", strShippingGateways)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddShippingRate.Transaction = savePoint

                cmdAddShippingRate.ExecuteNonQuery()

                savePoint.Commit()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
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
    Public Shared Function _CopyRates(ByVal numShippingMethodID As Byte, ByVal numFromZone As Byte, _
                               ByVal numToZone As Byte, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdCopyShippingRate As SqlCommand = sqlConn.CreateCommand
            cmdCopyShippingRate.CommandText = "_spKartrisShippingRates_Copy"
            Dim savePoint As SqlTransaction = Nothing
            cmdCopyShippingRate.CommandType = CommandType.StoredProcedure
            Try

                cmdCopyShippingRate.Parameters.AddWithValue("@SM_ID", numShippingMethodID)
                cmdCopyShippingRate.Parameters.AddWithValue("@FromZone", numFromZone)
                cmdCopyShippingRate.Parameters.AddWithValue("@ToZone", numToZone)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdCopyShippingRate.Transaction = savePoint

                cmdCopyShippingRate.ExecuteNonQuery()

                savePoint.Commit()
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

#End Region

#Region " Shipping Zones "

    Public Shared Function _GetShippingZoneNameByID(ByVal numZoneID As Byte, ByVal numLanguageID As Byte) As String
        Dim strZoneName As String = ""
        Try
            strZoneName = CStr(ShippingZonesAdptr._GetNameByID(numZoneID, numLanguageID).Rows(0)("ZoneName"))
        Catch ex As Exception
            strZoneName = ""
        End Try
        Return strZoneName
    End Function
    Public Shared Function _GetShippingZonesByLanguage(ByVal _LanguageID As Byte) As DataTable
        Return ShippingZonesAdptr._GetByLanguage(_LanguageID)
    End Function

    Public Shared Function _AddNewShippingZone(ByVal tblElements As DataTable, ByVal blnLive As Boolean, _
                                         ByVal numOrderBy As Byte, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdAddShippingZone As SqlCommand = sqlConn.CreateCommand
            cmdAddShippingZone.CommandText = "_spKartrisShippingZones_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmdAddShippingZone.CommandType = CommandType.StoredProcedure
            Try
                cmdAddShippingZone.Parameters.AddWithValue("@SZ_Live", blnLive)
                cmdAddShippingZone.Parameters.AddWithValue("@SZ_OrderByValue", numOrderBy)
                cmdAddShippingZone.Parameters.AddWithValue("@SZ_NewID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddShippingZone.Transaction = savePoint

                cmdAddShippingZone.ExecuteNonQuery()

                If cmdAddShippingZone.Parameters("@SZ_NewID").Value Is Nothing OrElse _
                    cmdAddShippingZone.Parameters("@SZ_NewID").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                Dim intNewShippingZoneID As Long = cmdAddShippingZone.Parameters("@SZ_NewID").Value
                If Not LanguageElementsBLL._AddLanguageElements( _
                        tblElements, LANG_ELEM_TABLE_TYPE.ShippingZones, intNewShippingZoneID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                savePoint.Commit()
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
    Public Shared Function _UpdateShippingZone(ByVal tblElements As DataTable, ByVal numShippingZoneID As Byte, ByVal blnLive As Boolean, _
                                          ByVal numOrderBy As Byte, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdUpdateShippingZone As SqlCommand = sqlConn.CreateCommand
            cmdUpdateShippingZone.CommandText = "_spKartrisShippingZones_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateShippingZone.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateShippingZone.Parameters.AddWithValue("@SZ_ID", numShippingZoneID)
                cmdUpdateShippingZone.Parameters.AddWithValue("@SZ_Live", blnLive)
                cmdUpdateShippingZone.Parameters.AddWithValue("@SZ_OrderByValue", numOrderBy)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateShippingZone.Transaction = savePoint

                cmdUpdateShippingZone.ExecuteNonQuery()

                If Not LanguageElementsBLL._UpdateLanguageElements( _
                        tblElements, LANG_ELEM_TABLE_TYPE.ShippingZones, numShippingZoneID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                savePoint.Commit()
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
    Public Shared Function _DeleteShippingZone(ByVal numZoneID As Byte, ByVal numAssignedZoneID As Byte, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdDeleteZone As SqlCommand = sqlConn.CreateCommand
            cmdDeleteZone.CommandText = "_spKartrisShippingZones_Delete"
            Dim savePoint As SqlTransaction = Nothing
            cmdDeleteZone.CommandType = CommandType.StoredProcedure
            Try
                cmdDeleteZone.Parameters.AddWithValue("@ZoneID", numZoneID)
                cmdDeleteZone.Parameters.AddWithValue("@AssignedZoneID", numAssignedZoneID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdDeleteZone.Transaction = savePoint

                cmdDeleteZone.ExecuteNonQuery()

                savePoint.Commit()
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

#End Region

#Region " Destinations "

    Public Shared Function _GetDestinationsByLanguage(ByVal _LanguageID As Byte) As DataTable
        Return DestinationsAdptr._GetByLanguage(_LanguageID)
    End Function
    Public Shared Function _GetDestinationsByZone(ByVal _ZoneID As Byte, ByVal _LanguageID As Byte) As DataTable
        Return DestinationsAdptr._GetDestinationsByZone(_ZoneID, _LanguageID)
    End Function
    Public Shared Function _GetISOCodesForFilter() As DataTable
        Return DestinationsAdptr._GetISOCodesForFilter()
    End Function
    Public Shared Function _GetTotalDestinationsByZone(ByVal numZoneID As Byte) As Integer
        Return CInt(DestinationsAdptr._GetTotalDestinationsByZone(numZoneID).Rows(0)("TotalDestinations"))
    End Function

    Public Shared Function _UpdateDestination(ByVal tblElements As DataTable, ByVal numDesinationID As Short, ByVal numZoneID As Byte, _
                                       ByVal sngTax As Single, ByVal sngTax2 As Single, ByVal strISOCode As String, ByVal strISOCode3Letters As String, _
                                       ByVal strISONumeric As String, ByVal strRegion As String, ByVal blnLive As Boolean, ByRef strMsg As String, ByVal strTaxExtra As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdUpdateDestination As SqlCommand = sqlConn.CreateCommand
            cmdUpdateDestination.CommandText = "_spKartrisDestinations_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateDestination.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateDestination.Parameters.AddWithValue("@D_ID", numDesinationID)
                cmdUpdateDestination.Parameters.AddWithValue("@D_ShippingZoneID", numZoneID)
                cmdUpdateDestination.Parameters.AddWithValue("@D_Tax", sngTax)
                cmdUpdateDestination.Parameters.AddWithValue("@D_Tax2", FixNullToDB(sngTax2, "d"))
                cmdUpdateDestination.Parameters.AddWithValue("@D_ISOCode", FixNullToDB(strISOCode, "s"))
                cmdUpdateDestination.Parameters.AddWithValue("@D_ISOCode3Letter", FixNullToDB(strISOCode3Letters, "s"))
                cmdUpdateDestination.Parameters.AddWithValue("@D_ISOCodeNumeric", FixNullToDB(strISONumeric, "s"))
                cmdUpdateDestination.Parameters.AddWithValue("@D_Region", FixNullToDB(strRegion))
                cmdUpdateDestination.Parameters.AddWithValue("@D_Live", blnLive)
                cmdUpdateDestination.Parameters.AddWithValue("@D_TaxExtra", FixNullToDB(strTaxExtra, "s"))

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateDestination.Transaction = savePoint

                cmdUpdateDestination.ExecuteNonQuery()

                If Not LanguageElementsBLL._UpdateLanguageElements( _
                                    tblElements, LANG_ELEM_TABLE_TYPE.Destination, numDesinationID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                savePoint.Commit()
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
    Public Shared Function _UpdateDestinationForTaxWizard(ByVal numDesinationID As Short, ByVal numZoneID As Byte, _
                                       ByVal sngTax As Single, ByVal sngTax2 As Single, ByVal strISOCode As String, ByVal strISOCode3Letters As String, _
                                       ByVal strISONumeric As String, ByVal strRegion As String, ByVal blnLive As Boolean, ByRef strMsg As String, ByVal strTaxExtra As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdUpdateDestination As SqlCommand = sqlConn.CreateCommand
            cmdUpdateDestination.CommandText = "_spKartrisDestinations_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateDestination.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateDestination.Parameters.AddWithValue("@D_ID", numDesinationID)
                cmdUpdateDestination.Parameters.AddWithValue("@D_ShippingZoneID", numZoneID)
                cmdUpdateDestination.Parameters.AddWithValue("@D_Tax", sngTax)
                cmdUpdateDestination.Parameters.AddWithValue("@D_Tax2", FixNullToDB(sngTax2, "d"))
                cmdUpdateDestination.Parameters.AddWithValue("@D_ISOCode", FixNullToDB(strISOCode, "s"))
                cmdUpdateDestination.Parameters.AddWithValue("@D_ISOCode3Letter", FixNullToDB(strISOCode3Letters, "s"))
                cmdUpdateDestination.Parameters.AddWithValue("@D_ISOCodeNumeric", FixNullToDB(strISONumeric, "s"))
                cmdUpdateDestination.Parameters.AddWithValue("@D_Region", FixNullToDB(strRegion))
                cmdUpdateDestination.Parameters.AddWithValue("@D_Live", blnLive)
                cmdUpdateDestination.Parameters.AddWithValue("@D_TaxExtra", FixNullToDB(strTaxExtra, "s"))

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateDestination.Transaction = savePoint

                cmdUpdateDestination.ExecuteNonQuery()

                savePoint.Commit()
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

#End Region

End Class
