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
Imports kartrisCouponsData
Imports kartrisCouponsDataTableAdapters
Imports CkartrisFormatErrors
Imports System.Web.HttpContext
Imports CkartrisDataManipulation


Public Class CouponsBLL

    Private Shared _Adptr As CouponsTblAdptr = Nothing

    Protected Shared ReadOnly Property Adptr() As CouponsTblAdptr
        Get
            _Adptr = New CouponsTblAdptr
            Return _Adptr
        End Get
    End Property

    Public Shared Function _GetCouponGroups() As DataTable
        Return Adptr._GetCouponGroups()
    End Function
    Public Shared Function _GetCouponByID(ByVal numCouponID As Short) As DataRow
        Dim tblCoupon As DataTable = Adptr._GetByID(numCouponID)
        If tblCoupon.Rows.Count = 1 Then Return tblCoupon.Rows(0)
        Return Nothing
    End Function
    Public Shared Function _GetCouponsByDate(ByVal datCreationDate As DateTime) As DataTable
        Return Adptr._GetByDate(Year(datCreationDate), Month(datCreationDate), Day(datCreationDate))
    End Function
    Private Shared Function _GenerateNewCouponCode() As String
        Dim numRandomElement1 As Short, numRandomElement2 As Short, numRandomElement3 As Short
        Dim numRandomElement4 As Short, numRandomElement5 As Short
        Dim strCouponCode As String = ""

        Do
            Randomize()
            numRandomElement1 = Int(Rnd() * 26)
            Randomize()
            numRandomElement2 = Int(Rnd() * 26)
            Randomize()
            numRandomElement3 = Int(Rnd() * 26)
            Randomize()
            numRandomElement4 = Int(Rnd() * 26)
            Randomize()
            numRandomElement5 = Int(Rnd() * 26)

            strCouponCode = Chr(numRandomElement1 + 65) & Chr(numRandomElement2 + 65) & _
                        Chr(numRandomElement3 + 65) & Chr(numRandomElement4 + 65) & Chr(numRandomElement5 + 65)

        Loop While _IsCouponCodeExist(strCouponCode)

        Return strCouponCode
    End Function
    Public Shared Function _IsCouponCodeExist(ByVal strCouponCode As String) As Boolean

        If strCouponCode = "" Then Return True

        Return Adptr._GetByCouponCode(strCouponCode).Rows.Count > 0

    End Function
    Public Shared Function _SearchByCouponCode(ByVal strCouponCode As String) As DataTable
        Return Adptr._SearchByCode(strCouponCode)
    End Function
    Public Shared Function _GetByCouponCode(ByVal strCouponCode As String) As Short
        Try
            Return FixNullFromDB(Adptr._GetByCouponCode(strCouponCode).Rows(0)("CP_ID"))
        Catch ex As Exception
            Return -1
        End Try

    End Function

    Public Shared Function _AddNewCoupons(ByVal strCouponCode As String, ByVal sngDiscountValue As Single, ByVal chrDiscountType As Char, ByVal datStartDate As Date, _
                                   ByVal datEndDate As Date, ByVal numQty As Integer, ByVal blnReusable As Boolean, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdAddCoupon As SqlCommand = sqlConn.CreateCommand
            cmdAddCoupon.CommandText = "_spKartrisCoupons_Add"

            Dim savePoint As SqlTransaction = Nothing
            cmdAddCoupon.CommandType = CommandType.StoredProcedure
            Try
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddCoupon.Transaction = savePoint
                Dim strCodes() As String = New String(numQty) {}
                If strCouponCode = "" Then
                    For i As Integer = 0 To numQty - 1
                        strCodes(i) = _GenerateNewCouponCode()
                    Next
                End If
                Dim blnCouponIsFixed As Boolean = False
                For i As Integer = 1 To numQty
                    If strCouponCode = "" Then
                        strCouponCode = strCodes(i - 1)
                    Else
                        If _IsCouponCodeExist(strCouponCode) Then
                            Throw New ApplicationException(GetGlobalResourceObject("_Coupons", "ContentText_CouponCodeAlreadyInUse"))
                        End If
                        blnCouponIsFixed = True
                    End If

                    cmdAddCoupon.Parameters.Clear()
                    cmdAddCoupon.Parameters.AddWithValue("@CouponCode", strCouponCode)
                    cmdAddCoupon.Parameters.AddWithValue("@Reusable", blnReusable)
                    cmdAddCoupon.Parameters.AddWithValue("@StartDate", datStartDate)
                    cmdAddCoupon.Parameters.AddWithValue("@EndDate", datEndDate)
                    cmdAddCoupon.Parameters.AddWithValue("@DiscountValue", sngDiscountValue)
                    cmdAddCoupon.Parameters.AddWithValue("@DiscountType", chrDiscountType)
                    cmdAddCoupon.Parameters.AddWithValue("@CouponCodeIsFixed", blnCouponIsFixed)
                    cmdAddCoupon.Parameters.AddWithValue("@NowOffset", CkartrisDisplayFunctions.NowOffset)

                    cmdAddCoupon.ExecuteNonQuery()
                    strCouponCode = ""
                Next
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

    Public Shared Function _UpdateCoupon(ByVal numCouponID As Short, ByVal sngDiscountValue As Single, ByVal chrDiscountType As Char, ByVal datStartDate As Date, _
       ByVal datEndDate As Date, ByVal blnReusable As Boolean, ByVal blnLive As Boolean, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdAddCoupon As SqlCommand = sqlConn.CreateCommand
            cmdAddCoupon.CommandText = "_spKartrisCoupons_Update"

            Dim savePoint As SqlTransaction = Nothing
            cmdAddCoupon.CommandType = CommandType.StoredProcedure
            Try

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddCoupon.Transaction = savePoint

                cmdAddCoupon.Parameters.AddWithValue("@CouponID", numCouponID)
                cmdAddCoupon.Parameters.AddWithValue("@Reusable", blnReusable)
                cmdAddCoupon.Parameters.AddWithValue("@StartDate", datStartDate)
                cmdAddCoupon.Parameters.AddWithValue("@EndDate", datEndDate)
                cmdAddCoupon.Parameters.AddWithValue("@DiscountValue", sngDiscountValue)
                cmdAddCoupon.Parameters.AddWithValue("@DiscountType", chrDiscountType)
                cmdAddCoupon.Parameters.AddWithValue("@Live", blnLive)

                cmdAddCoupon.ExecuteNonQuery()
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

    Public Shared Function _UpdateCouponStatus(ByVal numCouponID As Short, ByVal blnEnabled As Boolean, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdUpdateCoupon As SqlCommand = sqlConn.CreateCommand
            cmdUpdateCoupon.CommandText = "_spKartrisCoupons_UpdateStatus"

            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateCoupon.CommandType = CommandType.StoredProcedure
            Try
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateCoupon.Transaction = savePoint

                cmdUpdateCoupon.Parameters.AddWithValue("@CouponID", numCouponID)
                cmdUpdateCoupon.Parameters.AddWithValue("@Enabled", blnEnabled)

                cmdUpdateCoupon.ExecuteNonQuery()
                savePoint.Commit()
                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                If Not savePoint Is Nothing Then savePoint.Rollback()
                Return False
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
    End Function

    Public Shared Function _DeleteCoupon(ByVal numCouponID As Short, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdDeleteCoupon As SqlCommand = sqlConn.CreateCommand
            cmdDeleteCoupon.CommandText = "_spKartrisCoupons_Delete"

            Dim savePoint As SqlTransaction = Nothing
            cmdDeleteCoupon.CommandType = CommandType.StoredProcedure
            Try
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdDeleteCoupon.Transaction = savePoint

                cmdDeleteCoupon.Parameters.AddWithValue("@CouponID", numCouponID)

                cmdDeleteCoupon.ExecuteNonQuery()
                savePoint.Commit()
                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                If Not savePoint Is Nothing Then savePoint.Rollback()
                Return False
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
    End Function
End Class
