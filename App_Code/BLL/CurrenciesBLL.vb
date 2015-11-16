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
Imports CkartrisDataManipulation
Imports System.Web.HttpContext
Imports CkartrisEnumerations
Imports CkartrisFormatErrors
Imports kartrisCurrenciesData
Imports kartrisCurrenciesDataTableAdapters
Imports KartSettingsManager
Public Class CurrenciesBLL

    Private Shared _Adptr As CurrenciesTblAdptr = Nothing

    Protected Shared ReadOnly Property Adptr() As CurrenciesTblAdptr
        Get
            _Adptr = New CurrenciesTblAdptr
            Return _Adptr
        End Get
    End Property

    Public Shared Function CurrencyID(ByVal _CurrencyCode As String) As Short
        Dim rowCurrencies As DataRow() = GetCurrenciesFromCache().Select("CUR_ISOCode = '" & _CurrencyCode & "'")
        Return CShort(rowCurrencies(0)("CUR_ID"))
    End Function

    Public Shared Function CurrencySymbol(ByVal _CurrencyID As Short) As Char
        Dim rowCurrencies As DataRow() = GetCurrenciesFromCache().Select("CUR_ID = " & _CurrencyID)
        Return CChar(rowCurrencies(0)("CUR_Symbol"))
    End Function

    Public Shared Function CurrencyCode(ByVal _CurrencyID As Short) As String
        Dim rowCurrencies As DataRow() = GetCurrenciesFromCache().Select("CUR_ID = " & _CurrencyID)
        Return CStr(Trim(rowCurrencies(0)("CUR_ISOCode")))
    End Function

    Public Shared Function CurrencyRate(ByVal _CurrencyID As Short) As Single
        Dim rowCurrencies As DataRow() = GetCurrenciesFromCache().Select("CUR_ID = " & _CurrencyID)
        If rowCurrencies.Length > 0 Then Return CSng(rowCurrencies(0)("CUR_ExchangeRate"))
        Return 0
    End Function

    Public Shared Function ConvertCurrency(ByVal _ToCurrencyID As Short, ByVal _FromValue As Single, Optional ByVal _FromCurrencyID As Short = 0) As Single
        If _FromCurrencyID = 0 Then _FromCurrencyID = GetDefaultCurrency()
        Dim sngFromRate As Single = 0, sngToRate As Single = 0
        Dim rowCurrenciesFrom As DataRow() = GetCurrenciesFromCache().Select("CUR_ID = " & _FromCurrencyID)
        sngFromRate = CSng(FixNullFromDB(rowCurrenciesFrom(0)("CUR_ExchangeRate")))
        Dim rowCurrenciesTo As DataRow() = GetCurrenciesFromCache().Select("CUR_ID = " & _ToCurrencyID)
        sngToRate = CSng(FixNullFromDB(rowCurrenciesTo(0)("CUR_ExchangeRate")))
        Return (_FromValue / sngFromRate) * sngToRate
    End Function

    Public Shared Function FormatCurrencyPrice( _
        ByVal _CurrencyID As Short, ByVal _Price As Single, _
        Optional ByVal blnShowSymbol As Boolean = True, Optional ByVal blnIncludeLeftDirectionTag As Boolean = True) As String

        If KartSettingsManager.GetKartConfig("frontend.users.access") = "partial" Then
            'We check path of page, as we only want to obscure prices for front end 
            'if 'partial'
            Dim strFullOriginalPath As String = HttpContext.Current.Request.Url.ToString()

            If Not HttpContext.Current.User.Identity.IsAuthenticated _
            And Not strFullOriginalPath.ToLower.Contains("/admin") Then
                'Change text to hidden message
                Try
                    Return GetGlobalResourceObject("Kartris", "ContentText_HiddenPriceText")
                Catch
                    Return "XXXX"
                End Try
                Exit Function
            End If
        End If

        Dim rowCurrencies As DataRow()
        rowCurrencies = GetCurrenciesFromCache().Select("CUR_ID=" & _CurrencyID)
        Dim strSymbol As String = rowCurrencies(0)("CUR_Symbol")
        Dim strResult As String = ""
        Dim sbdZeros As New Text.StringBuilder("")
        _Price = Decimal.Round(CDec(_Price), rowCurrencies(0)("CUR_RoundNumbers"))

        If FixNullFromDB(rowCurrencies(0)("CUR_RoundNumbers")) > 0 Then
            For i As Byte = 0 To FixNullFromDB(rowCurrencies(0)("CUR_RoundNumbers")) - 1
                If sbdZeros.ToString = "" Then sbdZeros.Append(".")
                sbdZeros.Append("0")
            Next
        End If

        Dim strFormatedPrice As String
        strFormatedPrice = Format(_Price, "##0" & sbdZeros.ToString)
        strFormatedPrice = Replace(strFormatedPrice, ".", FixNullFromDB(rowCurrencies(0)("CUR_DecimalPoint")))


        If blnShowSymbol Then
            'We're formatting the value as text, with a currencysymbol
            If rowCurrencies(0)("CUR_Format").ToString.IndexOf("[symbol]") < _
            rowCurrencies(0)("CUR_Format").ToString.IndexOf("[value]") Then
                strResult = strSymbol
                If rowCurrencies(0)("CUR_Format").ToString.IndexOf(" ") <> -1 Then
                    strResult += " "
                End If
                strResult += strFormatedPrice
            Else
                strResult = strFormatedPrice
                If rowCurrencies(0)("CUR_Format").ToString.IndexOf(" ") <> -1 Then
                    strResult += " "
                End If
                strResult += strSymbol
            End If

            'RtL support is to ensure that currency formatting is correct for languages like Arabic
            If GetKartConfig("general.prices.rtlsupport") = "y" AndAlso blnIncludeLeftDirectionTag Then strResult = "<span dir=""ltr"">" & strResult & "</span>"
        Else
            'Returns a price without any non-numeric parts
            '(spaces, currency symbol, etc.)
            strResult += strFormatedPrice
        End If

        Return strResult
    End Function

    Public Shared Function _GetByCurrencyID(ByVal CurrencyID As Byte) As DataRow()
        Return GetCurrenciesFromCache().Select("CUR_ID=" & CurrencyID)
    End Function

    Public Shared Function GetDefaultCurrency() As Byte
        Dim LowestOrderNo = (From a In GetCurrenciesFromCache()
                             Where a.Field(Of Boolean)("CUR_Live") = True
                            Select a.Field(Of Byte)("CUR_OrderNo")).Min()

        Dim rowCurrencies As DataRow() = GetCurrenciesFromCache().Select("CUR_OrderNo = " & LowestOrderNo)
        Dim numMinID As Byte = CByte(rowCurrencies(0)("CUR_ID"))
        For i As Integer = 1 To rowCurrencies.Length - 1
            numMinID = Math.Min(Math.Min(numMinID, CByte(rowCurrencies(i - 1)("CUR_ID"))), CByte(rowCurrencies(i)("CUR_ID")))
        Next
        Return numMinID
    End Function

    Public Shared Function _GetCurrencies() As DataTable
        Return Adptr._GetData()
    End Function

    Public Shared Function _AddNewCurrency(ByVal tblElements As DataTable, ByVal strSymbol As String, _
              ByVal strIsoCode As String, ByVal strIsoCodeNumeric As String, ByVal snglExchangeRate As Single, _
              ByVal blnHasDecimal As Boolean, ByVal blnLive As Boolean, ByVal strFormat As String, _
              ByVal strIsoFormat As String, ByVal chrDecimalPoint As Char, ByVal numRoundNumbers As Byte, _
              ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdAddCurrency As SqlCommand = sqlConn.CreateCommand
            cmdAddCurrency.CommandText = "_spKartrisCurrencies_Add"

            Dim savePoint As SqlTransaction = Nothing
            cmdAddCurrency.CommandType = CommandType.StoredProcedure
            Try
                cmdAddCurrency.Parameters.AddWithValue("@CUR_Symbol", FixNullToDB(strSymbol))
                cmdAddCurrency.Parameters.AddWithValue("@CUR_ISOCode", FixNullToDB(strIsoCode))
                cmdAddCurrency.Parameters.AddWithValue("@CUR_ISOCodeNumeric", FixNullToDB(strIsoCodeNumeric))
                cmdAddCurrency.Parameters.AddWithValue("@CUR_ExchangeRate", FixNullToDB(snglExchangeRate, "g"))
                cmdAddCurrency.Parameters.AddWithValue("@CUR_HasDecimals", FixNullToDB(blnHasDecimal, "b"))
                cmdAddCurrency.Parameters.AddWithValue("@CUR_Live", FixNullToDB(blnLive, "b"))
                cmdAddCurrency.Parameters.AddWithValue("@CUR_Format", strFormat)
                cmdAddCurrency.Parameters.AddWithValue("@CUR_IsoFormat", strIsoFormat)
                cmdAddCurrency.Parameters.AddWithValue("@CUR_DecimalPoint", FixNullToDB(chrDecimalPoint, "c"))
                cmdAddCurrency.Parameters.AddWithValue("@CUR_RoundNumbers", numRoundNumbers)
                cmdAddCurrency.Parameters.AddWithValue("@CUR_NewID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddCurrency.Transaction = savePoint

                cmdAddCurrency.ExecuteNonQuery()
                Dim intNewCurrencyID As Long = cmdAddCurrency.Parameters("@CUR_NewID").Value
                If Not LanguageElementsBLL._AddLanguageElements( _
                  tblElements, LANG_ELEM_TABLE_TYPE.Currencies, intNewCurrencyID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Currency, _
                   strMsg, CreateQuery(cmdAddCurrency), intNewCurrencyID, sqlConn, savePoint)

                savePoint.Commit()
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

    Public Shared Function _UpdateCurrency(ByVal tblElements As DataTable, ByVal numCurrencyID As Byte, ByVal strSymbol As String, _
              ByVal strIsoCode As String, ByVal strIsoCodeNumeric As String, ByVal snglExchangeRate As Single, _
              ByVal blnHasDecimal As Boolean, ByVal blnLive As Boolean, ByVal strFormat As String, _
              ByVal strIsoFormat As String, ByVal chrDecimalPoint As Char, ByVal numRoundNumbers As Byte, _
              ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdUpdateCurrency As SqlCommand = sqlConn.CreateCommand
            cmdUpdateCurrency.CommandText = "_spKartrisCurrencies_Update"

            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateCurrency.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateCurrency.Parameters.AddWithValue("@CUR_Symbol", FixNullToDB(strSymbol))
                cmdUpdateCurrency.Parameters.AddWithValue("@CUR_ISOCode", FixNullToDB(strIsoCode))
                cmdUpdateCurrency.Parameters.AddWithValue("@CUR_ISOCodeNumeric", FixNullToDB(strIsoCodeNumeric))
                cmdUpdateCurrency.Parameters.AddWithValue("@CUR_ExchangeRate", FixNullToDB(snglExchangeRate, "g"))
                cmdUpdateCurrency.Parameters.AddWithValue("@CUR_HasDecimals", FixNullToDB(blnHasDecimal, "b"))
                cmdUpdateCurrency.Parameters.AddWithValue("@CUR_Live", FixNullToDB(blnLive, "b"))
                cmdUpdateCurrency.Parameters.AddWithValue("@CUR_Format", strFormat)
                cmdUpdateCurrency.Parameters.AddWithValue("@CUR_IsoFormat", strIsoFormat)
                cmdUpdateCurrency.Parameters.AddWithValue("@CUR_DecimalPoint", FixNullToDB(chrDecimalPoint, "c"))
                cmdUpdateCurrency.Parameters.AddWithValue("@CUR_RoundNumbers", numRoundNumbers)
                cmdUpdateCurrency.Parameters.AddWithValue("@Original_CUR_ID", numCurrencyID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateCurrency.Transaction = savePoint

                cmdUpdateCurrency.ExecuteNonQuery()
                If Not LanguageElementsBLL._UpdateLanguageElements( _
                  tblElements, LANG_ELEM_TABLE_TYPE.Currencies, numCurrencyID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Currency, _
                   strMsg, CreateQuery(cmdUpdateCurrency), numCurrencyID, sqlConn, savePoint)

                savePoint.Commit()
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

    Public Shared Function _DeleteCurrency(ByVal CurrencyID As Byte, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdDeleteCurrency As SqlCommand = sqlConn.CreateCommand
            cmdDeleteCurrency.CommandText = "_spKartrisCurrencies_Delete"

            Dim savePoint As SqlTransaction = Nothing
            cmdDeleteCurrency.CommandType = CommandType.StoredProcedure
            Try
                cmdDeleteCurrency.Parameters.AddWithValue("@Original_CUR_ID", CurrencyID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdDeleteCurrency.Transaction = savePoint

                cmdDeleteCurrency.ExecuteNonQuery()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Currency, _
                     strMsg, CreateQuery(cmdDeleteCurrency), CurrencyID, sqlConn, savePoint)
                savePoint.Commit()
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

    Public Shared Function _UpdateCurrencyRate(ByVal CurrencyID As Byte, ByVal NewRate As Single) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdUpdateCurrencyRates As SqlCommand = sqlConn.CreateCommand
            cmdUpdateCurrencyRates.CommandText = "_spKartrisCurrencies_UpdateRates"

            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateCurrencyRates.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateCurrencyRates.Parameters.AddWithValue("@CUR_ExchangeRate", NewRate)
                cmdUpdateCurrencyRates.Parameters.AddWithValue("@Original_CUR_ID", CurrencyID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateCurrencyRates.Transaction = savePoint

                cmdUpdateCurrencyRates.ExecuteNonQuery()
                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Currency, _
                     GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully"), _
                     CreateQuery(cmdUpdateCurrencyRates), Nothing, sqlConn, savePoint)

                savePoint.Commit()
                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return False
    End Function

    Public Shared Function _SetDefault(ByVal CurrencyID As Byte, ByRef strMessage As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisCurrencies_SetDefault"

            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                cmd.Parameters.AddWithValue("@CUR_ID", CurrencyID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                cmd.ExecuteNonQuery()
                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Currency, _
                     GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully"), _
                     CreateQuery(cmd), Nothing, sqlConn, savePoint)

                savePoint.Commit()
                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return False
    End Function

End Class
