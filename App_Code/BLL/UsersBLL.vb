'========================================================================
'Kartris - www.kartris.com
'Copyright 2021 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports System.Web.HttpContext
Imports kartrisUserData
Imports kartrisUserDataTableAdapters
Imports CkartrisEnumerations
Imports CkartrisFormatErrors
Public Class UsersBLL

    'Private _Detailsadptr As UserDetailsTblAdptr = Nothing
    Private _CustomerDetailsAdptr As CustomerDetailsTblAdptr = Nothing
    Private _AddressesAdptr As AddressesTblAdptr = Nothing
    Private _CustomerGroupsAdptr As CustomerGroupsTblAdptr = Nothing
    Private _SuppliersAdptr As SuppliersTblAdptr = Nothing
    Private _UsersTicketsAdptr As UsersTicketsDetailsTblAdptr = Nothing

#Region "Properties - Adapters"
    Protected ReadOnly Property CustomerGroupsAdptr() As CustomerGroupsTblAdptr
        Get
            _CustomerGroupsAdptr = New CustomerGroupsTblAdptr
            Return _CustomerGroupsAdptr
        End Get
    End Property
    Protected ReadOnly Property CustomerDetailsAdptr() As CustomerDetailsTblAdptr
        Get
            _CustomerDetailsAdptr = New CustomerDetailsTblAdptr
            Return _CustomerDetailsAdptr
        End Get
    End Property
    Protected ReadOnly Property AddressesAdptr() As AddressesTblAdptr
        Get
            _AddressesAdptr = New AddressesTblAdptr
            Return _AddressesAdptr
        End Get
    End Property
    Protected ReadOnly Property SuppliersAdptr() As SuppliersTblAdptr
        Get
            _SuppliersAdptr = New SuppliersTblAdptr
            Return _SuppliersAdptr
        End Get
    End Property
    Protected ReadOnly Property UserTicketsAdptr() As UsersTicketsDetailsTblAdptr
        Get
            _UsersTicketsAdptr = New UsersTicketsDetailsTblAdptr
            Return _UsersTicketsAdptr
        End Get
    End Property

    Protected ReadOnly Property DetailsAdptr() As UserDetailsTblAdptr
        Get
            Return New UserDetailsTblAdptr
        End Get
    End Property
#End Region

    Public Sub _Delete(ByVal U_ID As Integer, ByVal blnReturnStock As Boolean)
        Try
            CustomerDetailsAdptr._Delete(U_ID, blnReturnStock)
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try
    End Sub

    Public Function _Update(ByVal U_ID As Integer, ByVal U_AccountHolderName As String, ByVal U_EmailAddress As String, ByVal U_Password As String, ByVal U_LanguageID As Integer,
                                   ByVal U_CustomerGroupID As Integer, ByVal U_CustomerDiscount As Double, ByVal blnUserApproved As Boolean,
                                ByVal blnUserAffiliate As Boolean, ByVal U_AffiliateCommission As Double, ByVal U_SupportEndDate As Date, ByVal U_Notes As String) As Integer
        Try
            Dim dtNull As Nullable(Of DateTime) = Nothing
            Dim strRandomSalt As String = Membership.GeneratePassword(20, 0)
            Return CustomerDetailsAdptr._Update(U_ID, U_AccountHolderName, U_EmailAddress, IIf(String.IsNullOrEmpty(U_Password), "", EncryptSHA256Managed(U_Password, strRandomSalt)), U_LanguageID, U_CustomerGroupID, U_CustomerDiscount, blnUserApproved,
                                            blnUserAffiliate, U_AffiliateCommission, IIf(U_SupportEndDate = Nothing Or U_SupportEndDate = "#12:00:00 AM#", dtNull, U_SupportEndDate), U_Notes, strRandomSalt)
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            Return Nothing
        End Try

    End Function

    Public Function _Add(ByVal U_AccountHolderName As String, ByVal U_EmailAddress As String, ByVal U_Password As String, ByVal U_LanguageID As Integer,
                               ByVal U_CustomerGroupID As Integer, ByVal U_CustomerDiscount As Double, ByVal blnUserApproved As Boolean,
                            ByVal blnUserAffiliate As Boolean, ByVal U_AffiliateCommission As Double, ByVal U_SupportEndDate As Date, ByVal U_Notes As String) As Integer
        Try
            Dim dtNull As Nullable(Of DateTime) = Nothing
            Dim strRandomSalt As String = Membership.GeneratePassword(20, 0)
            Return CustomerDetailsAdptr._Add(U_AccountHolderName, U_EmailAddress, EncryptSHA256Managed(U_Password, strRandomSalt), U_LanguageID, U_CustomerGroupID, U_CustomerDiscount, blnUserApproved,
                                            blnUserAffiliate, U_AffiliateCommission, IIf(U_SupportEndDate = Nothing Or U_SupportEndDate = "#12:00:00 AM#", dtNull, U_SupportEndDate), U_Notes, strRandomSalt)
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            Return Nothing
        End Try

    End Function

    Public Sub _AnonymizeAll()
        CustomerDetailsAdptr._AnonymizeAll()
    End Sub
    Public Function _GetGuestList() As DataTable
        Return CustomerDetailsAdptr.GetGuests()
    End Function

    Public Function _GetAddressesByUserID(ByVal U_ID As Integer, ByVal ADR_Type As String) As DataTable
        Return AddressesAdptr._GetData(U_ID, ADR_Type)
    End Function

    Public Function ValidateUser(ByVal strEmailAddress As String, ByVal strPassword As String) As Integer
        Return DetailsAdptr.Validate(strEmailAddress, EncryptSHA256Managed(strPassword, GetSaltByEmail(strEmailAddress)))
    End Function

    Public Function GetDetails(ByVal strEmailAddress As String) As DataTable
        Return DetailsAdptr.GetData(strEmailAddress)
    End Function
    Public Function UpdateCustomerBalance(ByVal CustomerID As Integer, ByVal U_CustomerBalance As Decimal) As Integer
        Return DetailsAdptr.UpdateCustomerBalance(CustomerID, U_CustomerBalance)
    End Function
    Public Function GetNameandEUVAT(ByVal U_ID As Integer) As String
        Return DetailsAdptr.GetNameAndEUVAT(U_ID)
    End Function
    Public Function UpdateNameandEUVAT(ByVal U_ID As Integer, ByVal strName As String, ByVal strEUVat As String) As String
        Return DetailsAdptr.UpdateNameAndEUVAT(U_ID, strName, strEUVat)
    End Function
    Public Function UpdateQBListID(ByVal U_ID As Integer, ByVal strQBListID As String) As Integer
        Try
            Return DetailsAdptr.UpdateQBListID(U_ID, strQBListID)
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try
        Return 0
    End Function
    Public Function GetEmailByID(ByVal U_ID As Integer) As String
        Return DetailsAdptr.GetEmailByID(U_ID)
    End Function

    'Now includes details of whether this user is a guest or not
    'Guest ones are tagged so we can delete/anonymize them later
    Public Function Add(ByVal strEmailAddress As String, ByVal strPassword As String, ByVal Optional blnIsGuest As Boolean = False) As Integer
        Try
            Dim strRandomSalt As String = Membership.GeneratePassword(20, 0)
            Return DetailsAdptr.Add(strEmailAddress, EncryptSHA256Managed(strPassword, strRandomSalt), strRandomSalt, CkartrisEnvironment.GetClientIPAddress(), blnIsGuest)
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try
        Return 0
    End Function


    Public Function ChangePassword(ByVal U_ID As Integer, ByVal U_Password As String, ByVal strNewPassword As String) As Integer
        Try
            Dim strNewRandomSalt As String = Membership.GeneratePassword(20, 0)
            Dim strOldSalt As String = GetSaltByEmail(GetEmailByID(U_ID))
            Return CustomerDetailsAdptr.ChangePassword(U_ID, EncryptSHA256Managed(U_Password, strOldSalt), EncryptSHA256Managed(strNewPassword, strNewRandomSalt), strNewRandomSalt)
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try
        Return 0
    End Function

    Public Function ChangePasswordViaRecovery(ByVal U_ID As Integer, ByVal strNewPassword As String) As Integer
        Try
            Dim strNewRandomSalt As String = Membership.GeneratePassword(20, 0)
            Return DetailsAdptr.ChangePasswordfromRecovery(U_ID, EncryptSHA256Managed(strNewPassword, strNewRandomSalt), strNewRandomSalt)
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try
        Return 0
    End Function

    Public Function ResetPassword(ByVal U_ID As Integer, ByVal strNewPassword As String) As Integer
        Try
            Dim strOldSalt As String = GetSaltByEmail(GetEmailByID(U_ID))
            Return CustomerDetailsAdptr.ResetPassword(U_ID, EncryptSHA256Managed(strNewPassword, strOldSalt), CkartrisDisplayFunctions.NowOffset.AddHours(1))
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try
        Return 0
    End Function
    Public Function GetSaltByEmail(ByVal U_EmailAddress As String) As String
        Try
            Return DetailsAdptr.GetSaltByEmail(U_EmailAddress)
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try
        Return Nothing
    End Function

    Public Function EncryptSHA256Managed(ByVal ClearString As String, ByVal SaltString As String, Optional ByVal blnIsBackend As Boolean = False) As String
        Dim uEncode As New Text.UnicodeEncoding()
        Dim bytClearString() As Byte = Nothing
        If blnIsBackend Then
            If String.IsNullOrEmpty(SaltString) Then
                bytClearString = uEncode.GetBytes(ClearString & ConfigurationManager.AppSettings("hashsalt"))
            Else
                bytClearString = uEncode.GetBytes(ConfigurationManager.AppSettings("hashsalt") & ClearString & SaltString)
            End If

        Else
            bytClearString = uEncode.GetBytes(SaltString & ClearString & ConfigurationManager.AppSettings("hashsalt"))
        End If

        Dim sha As New System.Security.Cryptography.SHA256Managed()
        Dim hash() As Byte = sha.ComputeHash(bytClearString)
        Return Convert.ToBase64String(hash)
    End Function

#Region "   Customer Details"
    '_GetCustomerGroups - This is used by the Customer Details page on the backend. Please don't delete.
    Public Function _GetCustomerGroups(ByVal numLanguageID As Byte) As DataTable
        Return CustomerGroupsAdptr._GetData(numLanguageID)
    End Function

    Public Function _GetCustomerDetails(ByVal U_ID As Integer) As DataTable
        Return CustomerDetailsAdptr.GetData(U_ID)
    End Function

    Public Function _GetDataBySearchTerm(ByVal strSearchTerm As String, ByVal intPageIndex As Integer, ByVal intPageSize As Integer, Optional ByVal blnIsAffiliates As Boolean = False, Optional ByVal blnIsMailingList As Boolean = False, Optional ByVal intCustomerGroupID As Integer = 0, Optional ByVal blnIsAffiliateApproved As Boolean = False) As DataTable
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Using cmdSQL As New SqlCommand("_spKartrisUsers_ListBySearchTerm")
                cmdSQL.Connection = sqlConn
                cmdSQL.CommandType = CommandType.StoredProcedure
                cmdSQL.Parameters.AddWithValue("@SearchTerm", strSearchTerm)
                cmdSQL.Parameters.AddWithValue("@PageIndex", intPageIndex)
                cmdSQL.Parameters.AddWithValue("@PageSize", intPageSize)
                cmdSQL.Parameters.AddWithValue("@isAffiliate", blnIsAffiliates)
                cmdSQL.Parameters.AddWithValue("@isMailingList", blnIsMailingList)
                cmdSQL.Parameters.AddWithValue("@CustomerGroupID", intCustomerGroupID)
                cmdSQL.Parameters.AddWithValue("@isAffiliateApproved", blnIsAffiliateApproved)
                Using adpGetData As New SqlDataAdapter(cmdSQL)
                    Dim tblUserData As New DataTable()
                    adpGetData.Fill(tblUserData)
                    Return tblUserData
                End Using
            End Using
        End Using

        'Dim tblUserData As New DataTable

        'Return CustomerDetailsAdptr._GetDataBySearchTerm(strSearchTerm, blnIsAffiliates, blnIsMailingList, intCustomerGroupID, blnIsAffiliateApproved, intPageIndex, intPageSize)
    End Function
    Public Function _GetDataBySearchTermCount(ByVal strSearchTerm As String, Optional ByVal blnIsAffiliates As Boolean = False, Optional ByVal blnisMailingList As Boolean = False, Optional ByVal intCustomerGroupID As Integer = 0, Optional ByVal blnIsAffiliateApproved As Boolean = False) As Integer
        Return CustomerDetailsAdptr._GetDataBySearchTermCount(strSearchTerm, blnIsAffiliates, blnisMailingList, intCustomerGroupID, blnIsAffiliateApproved)
    End Function


    ''' <summary>
    ''' Get customer EU VAT number
    ''' </summary>
    ''' <remarks>
    ''' Can use this to pull through existing one into checkout for repeat
    ''' orders
    ''' </remarks>  
    Public Function GetCustomerEUVATNumber(ByVal U_ID As Integer) As String
        Dim strEUVATNumber As String = ""
        Dim tblCustomer As DataTable = _GetCustomerDetails(U_ID)
        Try
            strEUVATNumber = CkartrisDataManipulation.FixNullFromDB(tblCustomer.Rows(0).Item("U_CardholderEUVATNum"))
        Catch ex As Exception

        End Try

        Return strEUVATNumber
    End Function

    ''' <summary>
    ''' Clean guest email address
    ''' </summary>
    ''' <remarks>
    ''' For guest accounts, the email field contains 
    ''' extra text at the end to ensure uniqueness. If
    ''' the admins look at a guest account in the back
    ''' end, we want to ensure they don't see this.
    ''' </remarks>  
    Public Shared Function CleanGuestEmailUsername(ByVal strEmail As String) As String
        'The email may have |GUEST|[ID] at the end of it. If so,
        'we want to remove this and return just the email
        'address.
        Dim numPipeLast As Byte = 0, numPipePenultimate As Byte = 0
        Try
            'Find position of the last pipe char.
            numPipeLast = strEmail.LastIndexOf("|")

            If numPipeLast > 0 Then 'we have one
                'Trim last part off
                strEmail = Left(strEmail, numPipeLast)
            End If

            'Find position of the last pipe char.
            numPipePenultimate = strEmail.LastIndexOf("|")

            If numPipePenultimate > 0 Then 'we have one
                'Trim last part off
                strEmail = Left(strEmail, numPipePenultimate)
            End If
        Catch ex As Exception
            'Probably not a guest email
        End Try


        Return strEmail
    End Function
#End Region

#Region "   Customer Groups"

    Protected Friend Function _GetCustomerGroupsForCache() As DataTable
        Return CustomerGroupsAdptr._GetForCache()
    End Function

    Public Function _AddCustomerGroups(ByVal dtbElements As DataTable, ByVal pCG_Discount As Single,
                                   ByVal pCG_Live As Boolean, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdSQL As SqlCommand = sqlConn.CreateCommand
            cmdSQL.CommandText = "_spKartrisCustomerGroups_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmdSQL.CommandType = CommandType.StoredProcedure
            Try
                cmdSQL.Parameters.AddWithValue("@NewCG_ID", 0).Direction = ParameterDirection.Output
                cmdSQL.Parameters.AddWithValue("@CG_Discount", pCG_Discount)
                cmdSQL.Parameters.AddWithValue("@CG_Live", pCG_Live)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdSQL.Transaction = savePoint

                '' 1. Add The Main Info.
                cmdSQL.ExecuteNonQuery()

                If cmdSQL.Parameters("@NewCG_ID").Value Is Nothing OrElse
                    cmdSQL.Parameters("@NewCG_ID").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                Dim numNewCG_ID As Short
                numNewCG_ID = cmdSQL.Parameters("@NewCG_ID").Value

                '' 2. Add the Language Elements
                If Not LanguageElementsBLL._AddLanguageElements(
                        dtbElements, LANG_ELEM_TABLE_TYPE.CustomerGroups,
                        numNewCG_ID, sqlConn, savePoint) Then
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

    Public Function _UpdateCustomerGroups(ByVal dtbElements As DataTable, ByVal pCG_ID As Short, ByVal pCG_Discount As Single,
                                    ByVal pCG_Live As Boolean, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdSQL As SqlCommand = sqlConn.CreateCommand
            cmdSQL.CommandText = "_spKartrisCustomerGroups_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmdSQL.CommandType = CommandType.StoredProcedure
            Try

                cmdSQL.Parameters.AddWithValue("@CG_ID", pCG_ID)
                cmdSQL.Parameters.AddWithValue("@CG_Discount", pCG_Discount)
                cmdSQL.Parameters.AddWithValue("@CG_Live", pCG_Live)


                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdSQL.Transaction = savePoint

                '' 1. Add The Main Info.
                cmdSQL.ExecuteNonQuery()

                '' 2. Update the Language Elements
                If Not LanguageElementsBLL._UpdateLanguageElements(
                        dtbElements, LANG_ELEM_TABLE_TYPE.CustomerGroups,
                        pCG_ID, sqlConn, savePoint) Then
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

#End Region

#Region "   Suppliers"
    Protected Friend Function _GetSuppliersForCache() As DataTable
        Return SuppliersAdptr._GetData()
    End Function

    Public Function _AddSuppliers(ByVal pSupplierName As String, ByVal pSupplier_Live As Boolean, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdSQL As SqlCommand = sqlConn.CreateCommand
            cmdSQL.CommandText = "_spKartrisSuppliers_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmdSQL.CommandType = CommandType.StoredProcedure
            Try
                cmdSQL.Parameters.AddWithValue("@NewSUP_ID", 0).Direction = ParameterDirection.Output
                cmdSQL.Parameters.AddWithValue("@SUP_Name", pSupplierName)
                cmdSQL.Parameters.AddWithValue("@SUP_Live", pSupplier_Live)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdSQL.Transaction = savePoint

                '' Add the supplier's info.
                cmdSQL.ExecuteNonQuery()

                If cmdSQL.Parameters("@NewSUP_ID").Value Is Nothing OrElse
                    cmdSQL.Parameters("@NewSUP_ID").Value Is DBNull.Value Then
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

    Public Function _UpdateSuppliers(ByVal pSupplier_ID As Short, ByVal pSupplierName As String,
                                    ByVal pSupplier_Live As Boolean, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdSQL As SqlCommand = sqlConn.CreateCommand
            cmdSQL.CommandText = "_spKartrisSuppliers_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmdSQL.CommandType = CommandType.StoredProcedure
            Try
                cmdSQL.Parameters.AddWithValue("@SUP_ID", pSupplier_ID)
                cmdSQL.Parameters.AddWithValue("@SUP_Name", pSupplierName)
                cmdSQL.Parameters.AddWithValue("@SUP_Live", pSupplier_Live)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdSQL.Transaction = savePoint

                '' Update the supplier's info.
                cmdSQL.ExecuteNonQuery()

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

#Region "User Tickets"
    Public Function _GetUsersTicketDetails() As DataTable
        Return UserTicketsAdptr._GetData()
    End Function
    Public Function _GetTicketDetailsByUser(ByVal numUserID As Integer) As DataTable
        Return UserTicketsAdptr._GetByUserID(numUserID)
    End Function
#End Region
End Class
