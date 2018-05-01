Imports Microsoft.VisualBasic
Imports System.Net.Mail
Imports System.Data.SqlClient
Imports System.Data
'Imports GoCardlessSdk
Imports GoCardless
Imports System.IO
Imports System.Diagnostics
Imports System.Configuration

'****************************************************
'GoCardlessCore
'----
'This class is our base class, not part of the SDK.
'****************************************************

Public Class GoCardlessCore

    'Public Shared logger As NLog.Logger = NLog.LogManager.GetCurrentClassLogger()

    Private _emailTo As String,
            _emailFrom As String,
            _websiteUrl As String,
            _smtpHost As String,
            _AppId As String,
            _AppSecret As String,
            _AccessToken As String,
            _merchantId As String,
            _maxLimit As Integer,
            _environmentIsSandbox As GoCardlessClient.Environment,
            _client As GoCardlessClient

    Public Property Client() As GoCardlessClient
        Get
            Return _client
        End Get
        Private Set(value As GoCardlessClient)
            _client = value
        End Set
    End Property

    Public Property WebsiteUrl() As String
        Get
            Return _websiteUrl
        End Get
        Private Set(value As String)
            _websiteUrl = value
        End Set
    End Property

    Public Property AppId() As String
        Get
            Return _AppId
        End Get
        Private Set(value As String)
            _AppId = value
        End Set
    End Property

    Public Property AppSecret() As String
        Get
            Return _AppSecret
        End Get
        Private Set(value As String)
            _AppSecret = value
        End Set
    End Property

    Public Property AccessToken() As String
        Get
            Return _AccessToken
        End Get
        Private Set(value As String)
            _AccessToken = value
        End Set
    End Property

    Public Property MerchantId() As String
        Get
            Return _merchantId
        End Get
        Private Set(value As String)
            _merchantId = value
        End Set
    End Property

    Public Property MaxLimit() As String
        Get
            Return _maxLimit
        End Get
        Private Set(value As String)
            _maxLimit = value
        End Set
    End Property

    Public Sub New(ByVal mode As String)
        Me._emailFrom = ConfigurationManager.AppSettings("EmailSettings.FromEmail")
        Me._smtpHost = ConfigurationManager.AppSettings("EmailSettings.SMTPHost")

        If mode.ToLower() = "test" Then
            Me._websiteUrl = ConfigurationManager.AppSettings("SiteSettings.DevUrl")
            Me._emailTo = ConfigurationManager.AppSettings("EmailSettings.DeveloperEmail")

            'Set the account settings for the gateway
            Me.MerchantId = ConfigurationManager.AppSettings("GoCardlessMerchantId")
            Me.AppId = ConfigurationManager.AppSettings("sandbox.GoCardlessAppId")
            Me.AppSecret = ConfigurationManager.AppSettings("sandbox.GoCardlessAppSecret")
            Me.AccessToken = ConfigurationManager.AppSettings("sandbox.GoCardlessAccessToken")
            Me.MaxLimit = CType(ConfigurationManager.AppSettings("sandbox.MaxAuthLimit"), System.Int32)

            'Switch To Sandbox mode
            'GoCardless.Environment = GoCardless.Environments.Sandbox
            Me._environmentIsSandbox = GoCardlessClient.Environment.SANDBOX

        ElseIf mode.ToLower() = "live" Then
            Me._websiteUrl = ConfigurationManager.AppSettings("SiteSettings.liveUrl")
            Me._emailTo = ConfigurationManager.AppSettings("EmailSettings.AdminEmail")

            'Set the account settings for the gateway
            Me.MerchantId = ConfigurationManager.AppSettings("GoCardlessMerchantId")
            Me.AppId = ConfigurationManager.AppSettings("live.GoCardlessAppId")
            Me.AppSecret = ConfigurationManager.AppSettings("live.GoCardlessAppSecret")
            Me.AccessToken = ConfigurationManager.AppSettings("live.GoCardlessAccessToken")
            Me.MaxLimit = CType(ConfigurationManager.AppSettings("live.MaxAuthLimit"), System.Int32)

            'Switch To Production mode
            'GoCardless.Environment = GoCardless.Environments.Production
            Me._environmentIsSandbox = GoCardlessClient.Environment.LIVE

        End If

        'Account settings for the gateway
        'GoCardless.AccountDetails = New AccountDetails() With {
        '	.AppId = Me.AppId,
        '	.AppSecret = Me.AppSecret,
        '	.Token = Me.AccessToken
        '}

        '// We recommend storing your access token in an
        '// configuration setting for security, but you could
        '// include it as a string directly in your code
        '// Change me to LIVE when you're ready to go live
        'logger.Error(Me._environmentIsSandbox)
        CkartrisFormatErrors.LogError(Me._environmentIsSandbox)
        Client = GoCardlessClient.Create(ConfigurationManager.AppSettings("sandbox.GoCardlessAccessToken"), Me._environmentIsSandbox)

    End Sub

    Public Async Sub checkCustomers()
        Dim listResponse = Await Client.Customers.ListAsync()
        Dim customers = listResponse.Customers
        Debug.WriteLine("Customers: " + String.Join(", ", customers.Select(Function(c) c.Id)))
    End Sub

    '### Proc that will update the customer and invoice records on a Callback
    Public Sub UpdateCustomer(ByVal hfCustId As String, ByVal custId As String, ByVal mandId As String, ByVal subId As String)

        Dim strConnString = ConfigurationManager.ConnectionStrings("dbConnString").ConnectionString

        'Using sqlConn As New SqlConnection(strConnString), cmd As New SqlCommand("GoCardless_UpdateCustomer", sqlConn)
        Using sqlConn As New SqlConnection(strConnString), cmd As New SqlCommand("GoCardless_UpdateCustomer_v2", sqlConn)

            cmd.CommandType = CommandType.StoredProcedure
            cmd.CommandTimeout = 2700
            Try
                'cmd.Parameters.AddWithValue("@cusid", CInt(objResource.State))
                'cmd.Parameters.AddWithValue("@resourceid", objResource.ResourceId)
                cmd.Parameters.AddWithValue("@cusid", CInt(hfCustId))
                'cmd.Parameters.AddWithValue("@resourceid", mandId)
                'cmd.Parameters.AddWithValue("@resourceuri", custId)
                cmd.Parameters.AddWithValue("@gocardlessId", custId)
                cmd.Parameters.AddWithValue("@mandateId", mandId)
                cmd.Parameters.AddWithValue("@subsId", subId)
                cmd.Parameters.AddWithValue("@RecordsUpdated", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                cmd.ExecuteNonQuery()
                sqlConn.Close()

                If cmd.Parameters("@RecordsUpdated").Value = 0 Then
                    'logger.Info("UpdateCustomer: No records updated, CUS_ID: " & hfCustId & " - mandId: " & mandId)
                    CkartrisFormatErrors.LogError("UpdateCustomer: No records updated, CUS_ID: " & hfCustId & " - mandId: " & mandId)
                Else
                    CkartrisFormatErrors.LogError("UpdateCustomer: Customer updated successfully, CUS_ID:" & hfCustId & " - mandId: " & mandId)
                End If
            Catch ex As Exception
                CkartrisFormatErrors.LogError("Method:UpdateCustomer - CUS_ID:" & hfCustId & " - mandId: " & mandId & " - Message:" & ex.Message)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try
        End Using
    End Sub


    Public Sub ShowError(ByVal ex As Exception, ByVal context As HttpContext)
        context.Response.StatusCode = 422
        context.Response.Write("<h1>Error</h1>" & vbCrLf & "<p>" & ex.Message & "</p>")
    End Sub

    Public Sub SendMail(ByVal cc As String, ByVal bcc As String, ByVal subject As String, ByVal body As String)
        'create the mail message
        Dim mail As New System.Net.Mail.MailMessage()
        mail.IsBodyHtml = False

        'set the addresses
        mail.From = New Net.Mail.MailAddress(Me._emailFrom)
        mail.To.Add(Me._emailTo)
        If Not String.IsNullOrEmpty(cc) Then mail.CC.Add(cc)
        If Not String.IsNullOrEmpty(bcc) Then mail.Bcc.Add(bcc)

        'set the content
        mail.Subject = subject
        mail.Body = body

        'send the message
        Dim smtp As New Net.Mail.SmtpClient()
        smtp.Host = Me._smtpHost
        smtp.Send(mail)
    End Sub

    Function FixNullFromDB(ByVal objData As Object) As Object
        If objData Is DBNull.Value Then
            Return Nothing
        End If
        Return objData
    End Function
End Class
