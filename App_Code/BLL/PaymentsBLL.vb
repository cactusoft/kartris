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
Imports kartrisPagesDataTableAdapters
Imports System.Web.HttpContext
Imports CkartrisEnumerations
Imports CkartrisFormatErrors
Imports Braintree

Public Class PaymentsBLL

    Public Shared ReadOnly transactionSuccessStatuses As TransactionStatus() = {
                                                                                    TransactionStatus.AUTHORIZED,
                                                                                    TransactionStatus.AUTHORIZING,
                                                                                    TransactionStatus.SETTLED,
                                                                                    TransactionStatus.SETTLING,
                                                                                    TransactionStatus.SETTLEMENT_CONFIRMED,
                                                                                    TransactionStatus.SETTLEMENT_PENDING,
                                                                                    TransactionStatus.SUBMITTED_FOR_SETTLEMENT
                                                                                }

    '<summary>
    'Braintree Transaction Request   
    '</summary>
    Public Shared Function BrainTreePayment(paymentMethodNonce As String, amount As Decimal, currencyId As Short) As String
        Dim gateway As BraintreeGateway
        gateway = BT_GetGateway()

        Dim merchAccId As String = "MerchantAccId_"
        Dim CurrencyCode As String = ""

        CurrencyCode = CurrenciesBLL.CurrencyCode(currencyId)
        merchAccId = merchAccId.Concat(merchAccId, CurrencyCode)
        Dim gatewayCurrencyCode As String = BT_GetBrainTreeConfigMember("ProcessCurrency")
        Dim gatewayCurrencyId As Short = CurrenciesBLL.CurrencyID(gatewayCurrencyCode)
        merchAccId = BT_GetBrainTreeConfigMember(merchAccId)
        Dim tRequest As TransactionRequest = New TransactionRequest()
        Dim convertedAmount As Decimal = 0
        If merchAccId.Equals("") Then
            convertedAmount = Math.Round(CurrenciesBLL.ConvertCurrency(gatewayCurrencyId, amount, currencyId), BasketBLL.CurrencyRoundNumber)
            amount = convertedAmount
        Else
            tRequest.MerchantAccountId = merchAccId
        End If

        tRequest.Amount = amount
        tRequest.PaymentMethodNonce = paymentMethodNonce
        If BT_GetBrainTreeConfigMember("SubmitSettlement").ToLower().Equals("y") Then
            tRequest.Options = New TransactionOptionsRequest()
            tRequest.Options.SubmitForSettlement = True
        End If

        Dim result As Result(Of Transaction) = gateway.Transaction.Sale(tRequest)
        If result.IsSuccess() Then
            Dim transaction As Transaction = result.Target
            Return transaction.Id
        ElseIf Not transactionSuccessStatuses.Contains(result.Transaction.Status) Then
            '---------------------------------------
            'Something went wrong with the BrainTree Transaction
            '
            'Throwing Exception
            '---------------------------------------
            Throw New BrainTreeException("Your transaction has a status of ", result.Transaction.Id, result.Message)
        Else
            '---------------------------------------
            'Something went wrong with the BrainTree Transaction
            '
            'Throwing Exception
            '---------------------------------------
            Dim errorMessages As String = ""
            For Each singleError As ValidationError In result.Errors.DeepAll()
                errorMessages += "Error: " + Int32.Parse(singleError.Code) + " - " + singleError.Message + "\n"
            Next
            Throw New BrainTreeException(errorMessages, result.Transaction.Id)
        End If

    End Function

    '<summary>
    'Generates the Braintree client token (necessary to call the Braintree Form)  
    '</summary>
    Public Shared Function GenerateClientToken() As String
        Dim gateway As BraintreeGateway = New BraintreeGateway()
        Dim clientToken As String = ""

        gateway = BT_GetGateway()
        clientToken = BT_GenerateClientToken(gateway)

        Return clientToken
    End Function


End Class

'<summary>
'BrainTree Aux. Class
'To avoid having a new Lib on the BIN folder
'</summary>
Module BrainTreePayment

    Public Function BT_GenerateClientToken(gateway As BraintreeGateway) As String
        Dim clientToken As String
        clientToken = gateway.ClientToken.generate()
        Return clientToken
    End Function

    Public Function BT_CreateGateway(merchantId As String, publicKey As String, privateKey As String) As BraintreeGateway
        Dim status As String = BT_GetBrainTreeConfigMember("Status")
        Dim environment As Environment = Braintree.Environment.SANDBOX
        If status.ToLower().Equals("test") Then
            environment = Braintree.Environment.SANDBOX
        Else
            environment = Braintree.Environment.PRODUCTION
        End If
        Dim gateway As BraintreeGateway = New BraintreeGateway(environment,
                                                               merchantId,
                                                               publicKey,
                                                               privateKey)
        Return gateway

    End Function

    Public Function BT_GetGateway() As BraintreeGateway
        Dim gateway As BraintreeGateway = New BraintreeGateway()
        Dim btConfig As String() = BT_GetBrainTreeGatewayStartConfig()
        gateway = BT_CreateGateway(btConfig(0),
                            btConfig(1),
                            btConfig(2))
        Return gateway
    End Function

    Public Function BT_GetBrainTreeGatewayStartConfig() As String()
        Try
            Dim strSettings() As String = {"MerchantId", "PublicKey", "PrivateKey"}
            Dim toReturn() As String = {"", "", ""}

            Dim objConfigFileMap As New ExeConfigurationFileMap()
            objConfigFileMap.ExeConfigFilename = Path.Combine(Current.Request.PhysicalApplicationPath, "Plugins\BrainTreePayment\BrainTreePayment.dll.config")
            objConfigFileMap.MachineConfigFilename = Path.Combine(Current.Request.PhysicalApplicationPath, "Uploads\resources\Machine.Config")
            Dim objConfiguration As System.Configuration.Configuration = ConfigurationManager.OpenMappedExeConfiguration(objConfigFileMap, ConfigurationUserLevel.None)

            Dim objSectionGroup As ConfigurationSectionGroup = objConfiguration.GetSectionGroup("applicationSettings")
            Dim appSettingsSection As ClientSettingsSection = DirectCast(objSectionGroup.Sections.Item("Kartris.My.MySettings"), ClientSettingsSection)
            For index As Integer = 0 To strSettings.Length() - 1
                toReturn(index) = appSettingsSection.Settings.Get(strSettings(index)).Value.ValueXml.InnerText
            Next
            Return toReturn
        Catch ex As Exception
            Return {}
        End Try
    End Function

    Public Function BT_GetBrainTreeConfigMember(member As String) As String
        Try
            Dim toReturn As String = ""
            Dim merchAccId As String = ""

            Dim objConfigFileMap As New ExeConfigurationFileMap()
            objConfigFileMap.ExeConfigFilename = Path.Combine(Current.Request.PhysicalApplicationPath, "Plugins\BrainTreePayment\BrainTreePayment.dll.config")
            objConfigFileMap.MachineConfigFilename = Path.Combine(Current.Request.PhysicalApplicationPath, "Uploads\resources\Machine.Config")
            Dim objConfiguration As System.Configuration.Configuration = ConfigurationManager.OpenMappedExeConfiguration(objConfigFileMap, ConfigurationUserLevel.None)

            Dim objSectionGroup As ConfigurationSectionGroup = objConfiguration.GetSectionGroup("applicationSettings")
            Dim appSettingsSection As ClientSettingsSection = DirectCast(objSectionGroup.Sections.Item("Kartris.My.MySettings"), ClientSettingsSection)
            toReturn = appSettingsSection.Settings.Get(member).Value.ValueXml.InnerText

            Return toReturn
        Catch ex As Exception
            Return ""
        End Try
    End Function

End Module

'<summary>
'User defined exception
'
'Added _transactionId returned by Braintree
'Added _status (the error, ex: gateway_rejected)
'Added _customMessage (Message + _status)
'</summary>
Public Class BrainTreeException
    Inherits Exception

    Private _transactionId As String
    Private _status As String
    Private _customMessage As String

    Public Property TransactionId() As String
        Get
            Return _transactionId
        End Get
        Set(value As String)
            _transactionId = value
        End Set
    End Property
    Public Property Status() As String
        Get
            Return _status
        End Get
        Set(value As String)
            _status = value
        End Set
    End Property
    Public Property CustomMessage() As String
        Get
            Return _customMessage
        End Get
        Set(value As String)
            _customMessage = value
        End Set
    End Property

    Public Sub New()
        MyBase.New()
    End Sub

    Public Sub New(message As String)
        MyBase.New(message)
    End Sub

    Public Sub New(Message As String, inner As Exception)
        MyBase.New(Message, inner)
    End Sub

    Public Sub New(Message As String, transactionId As String)
        MyBase.New(Message)
        Me.TransactionId = transactionId
    End Sub


    Public Sub New(Message As String, transactionId As String, status As String)
        MyBase.New(Message)
        Me.TransactionId = transactionId
        Me.Status = status
        Me.CustomMessage = Me.Message + status
    End Sub
End Class