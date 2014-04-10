'========================================================================
'Kartris - www.kartris.com
'Copyright 2014 CACTUSOFT INTERNATIONAL FZ LLC

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
Imports System.Web.Security

Public Class KartrisMemberShipUser
    Inherits MembershipUser
    Private _ID As Integer
    Private _userName As String
    Private _emailAddress As String
    Private _customerGroupID As Integer
    Private _customerDiscount As Decimal
    Private _defaultBillingID As Integer
    Private _defaultShippingID As Integer
    Private _isAffiliate As Boolean
    Private _affiliateID As Integer
    Private _AffiliateCommission As Decimal
    Private _DefaultLangugeID As Integer
    Private _isAuthorized As Boolean
    Private _isSupportValid As Boolean
    Private _SupportEndDate As Date
    Private _customerBalance As Decimal

    Sub New(ByVal id As Integer, ByVal emailAddress As String, ByVal customerGroupID As Integer, ByVal customerDiscount As Decimal, _
            ByVal defaultBillingID As Integer, ByVal defaultShippingID As Integer, ByVal defaultLanguageID As Integer, _
            ByVal isApproved As Boolean, Optional ByVal isAffiliate As Boolean = False, Optional ByVal affiliateID As Integer = 0, _
            Optional ByVal affiliatecommission As Decimal = 0, Optional ByVal isSupportValid As Boolean = False, Optional ByVal SupportEndDate As Date = Nothing, Optional ByVal customerBalance As Decimal = 0)
        Me.ID = id
        Me.Email = emailAddress
        Me.CustomerGroupID = customerGroupID
        Me.CustomerDiscount = customerDiscount
        Me.DefaultBillingAddressID = defaultBillingID
        Me.DefaultShippingAddressID = defaultShippingID
        Me.IsAffiliate = isAffiliate
        Me.AffiliateID = affiliateID
        Me.AffiliateCommision = affiliatecommission
        Me.DefaultLanguageID = defaultLanguageID
        Me.isAuthorized = isApproved
        _isSupportValid = isSupportValid
        _SupportEndDate = SupportEndDate
        _customerBalance = customerBalance
    End Sub
    Public Property ID() As Integer
        Get
            Return _ID
        End Get
        Set(ByVal value As Integer)
            _ID = value
        End Set
    End Property
    Public Property CustomerGroupID() As Integer
        Get
            Return _customerGroupID
        End Get
        Set(ByVal value As Integer)
            _customerGroupID = value
        End Set
    End Property
    Public Property CustomerDiscount() As Decimal
        Get
            Return _customerDiscount
        End Get
        Set(ByVal value As Decimal)
            _customerDiscount = value
        End Set
    End Property
    Public Property DefaultBillingAddressID() As Integer
        Get
            Return _defaultBillingID
        End Get
        Set(ByVal value As Integer)
            _defaultBillingID = value
        End Set
    End Property
    Public Property DefaultShippingAddressID() As Integer
        Get
            Return _defaultShippingID
        End Get
        Set(ByVal value As Integer)
            _defaultShippingID = value
        End Set
    End Property
    Public Property DefaultLanguageID() As Integer
        Get
            Return _DefaultLangugeID
        End Get
        Set(ByVal value As Integer)
            _DefaultLangugeID = value
        End Set
    End Property
    Public Property IsAffiliate() As Boolean
        Get
            Return _isAffiliate
        End Get
        Set(ByVal value As Boolean)
            _isAffiliate = value
        End Set
    End Property
    Public Property AffiliateID() As Integer
        Get
            If _isAffiliate Then Return _affiliateID Else Return 0
        End Get
        Set(ByVal value As Integer)
            If IsAffiliate Then _affiliateID = value Else _affiliateID = 0
        End Set
    End Property
    Public Property AffiliateCommision() As Decimal
        Get
            If _isAffiliate Then Return _AffiliateCommission Else Return 0
        End Get
        Set(ByVal value As Decimal)
            _customerDiscount = value
        End Set
    End Property
    Public Property isAuthorized() As Boolean
        Get
            Return _isAuthorized
        End Get
        Set(ByVal value As Boolean)
            _isAuthorized = value
        End Set
    End Property
    Public ReadOnly Property isSupportValid() As Boolean
        Get
            Return _isSupportValid
        End Get
    End Property
    Public ReadOnly Property SupportEndDate() As Date
        Get
            Return _SupportEndDate
        End Get
    End Property
    Public ReadOnly Property CustomerBalance() As Decimal
        Get
            Return _customerBalance
        End Get
    End Property
End Class
Public Class KartrisMembershipProvider
    Inherits MembershipProvider
    Private _requiresQuestionAndAnswer As Boolean
    Private _minRequiredPasswordLength As Integer

    Public Overrides Sub Initialize(ByVal name As String, ByVal config As System.Collections.Specialized.NameValueCollection)

        '===retrives the attribute values set in 
        'web.config and assign to local variables===

        If config("requiresQuestionAndAnswer") = "true" Then _requiresQuestionAndAnswer = True
        MyBase.Initialize(name, config)

    End Sub

    Public Overrides Property ApplicationName() As String
        Get
            Return Nothing
        End Get
        Set(ByVal value As String)
        End Set
    End Property

    Public Overrides Function ChangePassword(ByVal username As String, ByVal oldPassword As String, ByVal newPassword As String) As Boolean
        Return Nothing
    End Function

    Public Overrides Function ChangePasswordQuestionAndAnswer(ByVal username As String, ByVal password As String, ByVal newPasswordQuestion As String, ByVal newPasswordAnswer As String) As Boolean
        Return Nothing
    End Function

    Public Overrides Function CreateUser(ByVal username As String, ByVal password As String, ByVal email As String, ByVal passwordQuestion As String, ByVal passwordAnswer As String, ByVal isApproved As Boolean, ByVal providerUserKey As Object, ByRef status As System.Web.Security.MembershipCreateStatus) As System.Web.Security.MembershipUser
        Dim KartrisUser As KartrisMemberShipUser

        '----perform checking all the relevant checks here
        ' and set the status of the error accordingly, e.g.:
        'status = MembershipCreateStatus.InvalidPassword
        'status = MembershipCreateStatus.InvalidAnswer
        'status = MembershipCreateStatus.InvalidEmail

        '---add the user to the database
        Try
            Dim U_ID As Integer = UsersBLL.Add(username, password)
            If U_ID > 0 Then
                KartrisUser = New KartrisMemberShipUser(U_ID, username, 0, 0, 0, 0, 1, True)
                status = MembershipCreateStatus.Success
                Return KartrisUser
            End If


        Catch ex As Exception
            '---failed; determine the reason why
            status = MembershipCreateStatus.UserRejected
            Return Nothing
        End Try
        Return Nothing
    End Function

    Public Overrides Function DeleteUser(ByVal username As String, ByVal deleteAllRelatedData As Boolean) As Boolean
        Return Nothing
    End Function

    Public Overrides ReadOnly Property EnablePasswordReset() As Boolean
        Get
            Return Nothing
        End Get
    End Property

    Public Overrides ReadOnly Property EnablePasswordRetrieval() As Boolean
        Get
            Return Nothing
        End Get
    End Property

    Public Overrides Function FindUsersByEmail(ByVal emailToMatch As String, ByVal pageIndex As Integer, ByVal pageSize As Integer, ByRef totalRecords As Integer) As System.Web.Security.MembershipUserCollection
        Return Nothing
    End Function

    Public Overrides Function FindUsersByName(ByVal usernameToMatch As String, ByVal pageIndex As Integer, ByVal pageSize As Integer, ByRef totalRecords As Integer) As System.Web.Security.MembershipUserCollection
        Return Nothing
    End Function

    Public Overrides Function GetAllUsers(ByVal pageIndex As Integer, ByVal pageSize As Integer, ByRef totalRecords As Integer) As System.Web.Security.MembershipUserCollection
        Return Nothing
    End Function

    Public Overrides Function GetNumberOfUsersOnline() As Integer
        Return Nothing
    End Function

    Public Overrides Function GetPassword(ByVal username As String, ByVal answer As String) As String
        Return Nothing
    End Function

    Public Overloads Overrides Function GetUser(ByVal username As String, ByVal userIsOnline As Boolean) As System.Web.Security.MembershipUser
        Dim User As KartrisMemberShipUser

        Dim UserDetails As DataTable = UsersBLL.GetDetails(username)
        If UserDetails.Rows.Count > 0 Then
            Dim blnSupportValid As Boolean = False

            If FixNullFromDB(UserDetails.Rows(0)("U_SupportEndDate")) IsNot Nothing Then
                If IsDate(UserDetails.Rows(0)("U_SupportEndDate")) Then
                    If CDate(UserDetails.Rows(0)("U_SupportEndDate")) > CkartrisDisplayFunctions.NowOffset Then blnSupportValid = True
                End If
            End If

            User = New KartrisMemberShipUser(UserDetails.Rows(0)("U_ID"), username, _
                                             FixNullFromDB(UserDetails.Rows(0)("U_CustomerGroupID")), _
                                             FixNullFromDB(UserDetails.Rows(0)("U_CustomerDiscount")), _
                                             FixNullFromDB(UserDetails.Rows(0)("U_DefBillingAddressID")), _
                                             FixNullFromDB(UserDetails.Rows(0)("U_DefShippingAddressID")), _
                                             UserDetails.Rows(0)("U_LanguageID"), _
                                             UserDetails.Rows(0)("U_Approved"), , , , _
                                            blnSupportValid, FixNullFromDB(UserDetails.Rows(0)("U_SupportEndDate")), _
                                            FixNullFromDB(UserDetails.Rows(0)("U_CustomerBalance")))
            Return User
        Else
            Return Nothing
        End If


    End Function

    Public Overloads Overrides Function GetUser(ByVal providerUserKey As Object, ByVal userIsOnline As Boolean) As System.Web.Security.MembershipUser
        Return Nothing
    End Function

    Public Overrides Function GetUserNameByEmail(ByVal email As String) As String
        Return Nothing
    End Function

    Public Overrides ReadOnly Property MaxInvalidPasswordAttempts() As Integer
        Get
            Return Nothing
        End Get
    End Property

    Public Overrides ReadOnly Property MinRequiredNonAlphanumericCharacters() As Integer
        Get
            Return Nothing
        End Get
    End Property

    Public Overrides ReadOnly Property MinRequiredPasswordLength() As Integer
        Get
            Return Nothing
        End Get
    End Property

    Public Overrides ReadOnly Property PasswordAttemptWindow() As Integer
        Get
            Return Nothing
        End Get
    End Property

    Public Overrides ReadOnly Property PasswordFormat() As System.Web.Security.MembershipPasswordFormat
        Get
            Return Nothing
        End Get
    End Property

    Public Overrides ReadOnly Property PasswordStrengthRegularExpression() As String
        Get
            Return Nothing
        End Get
    End Property

    Public Overrides ReadOnly Property RequiresQuestionAndAnswer() As Boolean
        Get
            If _requiresQuestionAndAnswer = True Then
                Return True
            Else
                Return False
            End If
        End Get
    End Property

    Public Overrides ReadOnly Property RequiresUniqueEmail() As Boolean
        Get
            Return Nothing
        End Get
    End Property

    Public Overrides Function ResetPassword(ByVal username As String, ByVal answer As String) As String
        Return Nothing
    End Function

    Public Overrides Function UnlockUser(ByVal userName As String) As Boolean
        Return Nothing
    End Function

    Public Overrides Sub UpdateUser(ByVal user As System.Web.Security.MembershipUser)

    End Sub

    Public Overrides Function ValidateUser(ByVal username As String, ByVal password As String) As Boolean
        Try
            Dim U_ID As Integer = UsersBLL.ValidateUser(username, password)
            If U_ID > 0 Then
                'Dim UserDetails As DataTable = UsersBLL.GetDetails(username)
                'KartrisUser = New KartrisMemberShipUser(U_ID, username, UserDetails.Rows(0)("U_CustomerGroupID"), UserDetails.Rows(0)("U_CustomerDiscount"), UserDetails.Rows(0)("U_DefBillingAddressID"), _
                'UserDetails.Rows(0)("U_DefShippingAddressID"), UserDetails.Rows(0)("U_LanguageID"), True)
                'UserDetails.Rows(0)("U_Approved")
                'System.Web.HttpContext.Current.Session("KartrisUserCulture") = LanguagesBLL.GetCultureByLanguageID_s(UserDetails.Rows(0)("U_LanguageID"))
                Return True
            Else
                Return False
            End If
        Catch ex As Exception
            Console.Write(ex.ToString)
            Return False
        End Try
    End Function
    Public Shared Function UserExists(ByVal username As String) As Boolean
        If Membership.GetUser(username) IsNot Nothing Then Return True
        Return False
    End Function
End Class
