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
Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.Collections.Generic
Imports System.Xml

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="http://developer.intuit.com/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class KartrisQBService
    Inherits QBWebConnectorSvc

    ''' <summary>
    ''' WebMethod - clientVersion()
    ''' To enable web service with QBWC version control
    ''' Signature: public string clientVersion(string strVersion)
    '''
    ''' IN: 
    ''' string strVersion
    '''
    ''' OUT: 
    ''' string errorOrWarning
    ''' Possible values: 
    ''' string retVal
    ''' - NULL or [emptyString] = QBWC will let the web service update
    ''' - "E:[any text]" = popup ERROR dialog with [any text] 
    ''' - abort update and force download of new QBWC.
    ''' - "W:[any text]" = popup WARNING dialog with [any text]
    ''' - choice to user, continue update or not.
    ''' </summary>
    <WebMethod()> _
   Public Function clientVersion(ByVal strVersion As String) As String
        Dim evLogTxt As String = "WebMethod: clientVersion() has been called " & "by QBWebconnector" & vbCrLf & vbCrLf
        evLogTxt += "Parameters received:" & vbCrLf
        evLogTxt += ("string strVersion = ") + strVersion & vbCrLf
        evLogTxt += vbCrLf

        Dim retVal As String = Nothing
        If Not String.IsNullOrEmpty(strVersion) Then
            Dim recommendedVersion As Double = 1.5
            Dim supportedMinVersion As Double = 1.0R
            Dim suppliedVersion As Double = Convert.ToDouble(Me.parseForVersion(strVersion))
            evLogTxt += ("QBWebConnector version = ") + strVersion & vbCrLf
            evLogTxt += ("Recommended Version = ") + recommendedVersion.ToString() & vbCrLf
            evLogTxt += ("Supported Minimum Version = ") + supportedMinVersion.ToString() & vbCrLf
            evLogTxt += ("SuppliedVersion = ") + suppliedVersion.ToString() & vbCrLf
            If suppliedVersion < recommendedVersion Then
                retVal = "W:We recommend that you upgrade your QBWebConnector"
            ElseIf suppliedVersion < supportedMinVersion Then
                retVal = "E:You need to upgrade your QBWebConnector"
            End If
            evLogTxt += vbCrLf
            evLogTxt += "Return values: " & vbCrLf
            evLogTxt += ("string retVal = ") + retVal
            'CkartrisFormatErrors.LogError(evLogTxt)
        End If
        Return retVal
    End Function
    <WebMethod()> _
    Public Overrides Function authenticate(ByVal strUserName As String, ByVal strPassword As String) As String()
        Dim evLogTxt As String = "WebMethod: authenticate() has been called by QBWebconnector" & vbCrLf & vbCrLf
        evLogTxt += "Parameters received:" & vbCrLf
        evLogTxt += ("string strUserName = ") + strUserName & vbCrLf
        evLogTxt += ("string strPassword = ") + strPassword & vbCrLf
        evLogTxt += vbCrLf


        Dim authReturn As String() = New String(1) {}
        ' Code below uses a random GUID to use as session ticket
        ' a GUID looks like this -> {85B41BEE-5CD9-427a-A61B-83964F1EB426}
        authReturn(0) = System.Guid.NewGuid().ToString()
        
        Dim pwd As String = KartSettingsManager.GetKartConfig("general.quickbooks.pass")
        If strUserName.Trim().Equals("Kartris") AndAlso UsersBLL.EncryptSHA256Managed(strPassword.Trim(), LoginsBLL._GetSaltByUserName(strUserName), True) = pwd Then
            ' An empty string for authReturn[1] means asking QBWebConnector 
            ' to connect to the company file that is currently openned in QB
            'authReturn(1) = "c:\Program Files\Intuit\QuickBooks\sample_product-based business.qbw"
            authReturn(1) = ""
        Else
            authReturn(1) = "nvu"
        End If
        ' "none" to indicate there is no work to do
        If OrdersBLL.GetQBQueue.Rows.Count = 0 Then authReturn(1) = "none"
        ' or a company filename in the format C:\full\path\to\company.qbw

        evLogTxt += vbCrLf
        evLogTxt += "Return values: " & vbCrLf
        evLogTxt += ("string[] authReturn[0] = ") + authReturn(0).ToString() & vbCrLf
        evLogTxt += ("string[] authReturn[1] = ") + authReturn(1).ToString()
        'CkartrisFormatErrors.LogError(evLogTxt)

        Return (authReturn)
    End Function
    <WebMethod()> _
    Public Overrides Function closeConnection(ByVal ticket As String) As String
        Dim evLogTxt As String = "WebMethod: closeConnection() has been called by QBWebconnector" & vbCrLf & vbCrLf
        evLogTxt += "Parameters received:" & vbCrLf
        evLogTxt += ("string ticket = ") + ticket & vbCrLf
        evLogTxt += vbCrLf
        Dim retVal As String = Nothing

        retVal = "OK"

        evLogTxt += vbCrLf
        evLogTxt += "Return values: " & vbCrLf
        evLogTxt += ("string retVal= ") + retVal & vbCrLf

        'CkartrisFormatErrors.LogError(evLogTxt)
        Return (retVal)
    End Function
    <WebMethod(True)> _
    Public Overrides Function connectionError(ByVal ticket As String, ByVal hresult As String, ByVal message As String) As String
        If Session("ce_counter") Is Nothing Then
            Session("ce_counter") = 0
        End If

        Dim evLogTxt As String = "WebMethod: connectionError() has been called by QBWebconnector" & vbCrLf & vbCrLf
        evLogTxt += "Parameters received:" & vbCrLf
        evLogTxt += ("string ticket = ") + ticket & vbCrLf
        evLogTxt += ("string hresult = ") + hresult & vbCrLf
        evLogTxt += ("string message = ") + message & vbCrLf
        evLogTxt += vbCrLf

        Dim retVal As String = Nothing
        ' 0x80040400 - QuickBooks found an error when parsing the provided XML text stream. 
        Const QB_ERROR_WHEN_PARSING As String = "0x80040400"
        ' 0x80040401 - Could not access QuickBooks. 
        Const QB_COULDNT_ACCESS_QB As String = "0x80040401"
        ' 0x80040402 - Unexpected error. Check the qbsdklog.txt file for possible, additional information. 
        Const QB_UNEXPECTED_ERROR As String = "0x80040402"
        ' Add more as we need...

        If hresult.Trim().Equals(QB_ERROR_WHEN_PARSING) Then
            evLogTxt += ("HRESULT = ") + hresult & vbCrLf
            evLogTxt += ("Message = ") + message & vbCrLf
            retVal = "DONE"
        ElseIf hresult.Trim().Equals(QB_COULDNT_ACCESS_QB) Then
            evLogTxt += ("HRESULT = ") + hresult & vbCrLf
            evLogTxt += ("Message = ") + message & vbCrLf
            retVal = "DONE"
        ElseIf hresult.Trim().Equals(QB_UNEXPECTED_ERROR) Then
            evLogTxt += ("HRESULT = ") + hresult & vbCrLf
            evLogTxt += ("Message = ") + message & vbCrLf
            retVal = "DONE"
        Else
            ' Depending on various hresults return different value 
            If CInt(Session("ce_counter")) = 0 Then
                ' Try again with this company file
                evLogTxt += ("HRESULT = ") + hresult & vbCrLf
                evLogTxt += ("Message = ") + message & vbCrLf
                evLogTxt += "Sending empty company file to try again."
                retVal = ""
            Else
                evLogTxt += ("HRESULT = ") + hresult & vbCrLf
                evLogTxt += ("Message = ") + message & vbCrLf
                evLogTxt += "Sending DONE to stop."
                retVal = "DONE"
            End If
        End If
        evLogTxt += vbCrLf
        evLogTxt += "Return values: " & vbCrLf
        evLogTxt += ("string retVal = ") + retVal & vbCrLf
        'CkartrisFormatErrors.LogError(evLogTxt)
        Session("ce_counter") = CInt(Session("ce_counter")) + 1
        Return retVal
    End Function
    <WebMethod(True)> _
    Public Overrides Function getLastError(ByVal ticket As String) As String
        Dim evLogTxt As String = "WebMethod: getLastError() has been called by QBWebconnector" & vbCrLf & vbCrLf
        evLogTxt += "Parameters received:" & vbCrLf
        evLogTxt += ("string ticket = ") + ticket & vbCrLf
        evLogTxt += vbCrLf

        'Dim errorCode As Integer = 0
        Dim retVal As String = Nothing

        If Session("QBLastError") IsNot Nothing Then
            retVal = Session("QBLastError")
        Else
            retVal = ""
        End If
        evLogTxt += vbCrLf
        evLogTxt += "Return values: " & vbCrLf
        evLogTxt += ("string retVal= ") + retVal & vbCrLf
        'CkartrisFormatErrors.LogError(evLogTxt)
        Return (retVal)
    End Function
    <WebMethod(True)> _
    Public Overrides Function receiveResponseXML(ByVal ticket As String, ByVal response As String, ByVal hresult As String, ByVal message As String) As Integer
        Dim retVal As Integer = 0
        Dim evLogTxt As String = "WebMethod: receiveResponseXML() has been called by QBWebconnector" & vbCrLf & vbCrLf
        evLogTxt += "Parameters received:" & vbCrLf
        evLogTxt += ("string ticket = ") + ticket & vbCrLf
        evLogTxt += ("string response = ") + response & vbCrLf
        evLogTxt += ("string hresult = ") + hresult & vbCrLf
        evLogTxt += ("string message = ") + message & vbCrLf
        evLogTxt += vbCrLf


        If Not hresult.ToString().Equals("") Then
            ' if there is an error with response received, web service could also return a -ve int 
            evLogTxt += ("HRESULT = ") + hresult & vbCrLf
            evLogTxt += ("Message = ") + message & vbCrLf
            Session("QBLastError") = "QB Status Code:" & hresult & " - " & message
            retVal = -101
        Else
            evLogTxt += "Length of response received = " & response.Length & vbCrLf
            Dim outputXMLDoc As New XmlDocument()
            outputXMLDoc.LoadXml(response)
            Dim strCurrentQBProcess As String = Session("QBProcess")
            Select Case strCurrentQBProcess
                Case "SearchKartrisItem"
                    Dim qbXMLMsgsRsNodeList As XmlNodeList = outputXMLDoc.GetElementsByTagName("ItemQueryRs")

                    If qbXMLMsgsRsNodeList.Count = 1 Then
                        'it's always true, since we will only add a single 'Kartris Order Item' in Quickbooks
                        Dim rsAttributes As XmlAttributeCollection = qbXMLMsgsRsNodeList.Item(0).Attributes
                        'get the status Code, info and Severity
                        Dim retStatusCode As String = rsAttributes.GetNamedItem("statusCode").Value
                        Dim retStatusSeverity As String = rsAttributes.GetNamedItem("statusSeverity").Value
                        Dim retStatusMessage As String = rsAttributes.GetNamedItem("statusMessage").Value

                        If retStatusCode = "0" Then
                            'get the ItemNonInventoryRet node for detailed info
                            'an ItemQueryRs contains max one childNode for "ItemNonInverntoryRet"
                            Dim ItemQueryRsNodeList As XmlNodeList = qbXMLMsgsRsNodeList.Item(0).ChildNodes
                            If ItemQueryRsNodeList.Count = 1 AndAlso ItemQueryRsNodeList.Item(0).Name.Equals("ItemNonInventoryRet") Then
                                Dim ItemNonInventoryRetNodeList As XmlNodeList = ItemQueryRsNodeList.Item(0).ChildNodes

                                For Each ItemNonInventoryRetNode As XmlNode In ItemNonInventoryRetNodeList
                                    If ItemNonInventoryRetNode.Name.Equals("ListID") Then
                                        Application("KartrisQBItemListID") = ItemNonInventoryRetNode.InnerText
                                        retVal = 1
                                        Exit For
                                    End If
                                Next
                            End If
                        Else
                            If retStatusCode = "500" Then
                                Session("QBLastError") = "Cannot find 'Kartris Order Item' in Quickbooks."
                            Else
                                Session("QBLastError") = "QB Status Code: " & retStatusCode & " - QB message: " & retStatusMessage
                            End If

                            Return -1
                        End If
                    End If
                Case "AddCustomer"
                    Dim qbXMLMsgsRsNodeList As XmlNodeList = outputXMLDoc.GetElementsByTagName("CustomerAddRs")

                    If qbXMLMsgsRsNodeList.Count = 1 Then
                        'it's always true, since we added a single Customer
                        Dim rsAttributes As XmlAttributeCollection = qbXMLMsgsRsNodeList.Item(0).Attributes
                        'get the status Code, info and Severity
                        Dim retStatusCode As String = rsAttributes.GetNamedItem("statusCode").Value
                        Dim retStatusSeverity As String = rsAttributes.GetNamedItem("statusSeverity").Value
                        Dim retStatusMessage As String = rsAttributes.GetNamedItem("statusMessage").Value

                        If retStatusCode = "0" Then
                            'get the CustomerRet node for detailed info
                            'a CustomerAddRs contains max one childNode for "CustomerRet"
                            Dim custAddRsNodeList As XmlNodeList = qbXMLMsgsRsNodeList.Item(0).ChildNodes
                            If custAddRsNodeList.Count = 1 AndAlso custAddRsNodeList.Item(0).Name.Equals("CustomerRet") Then
                                Dim custRetNodeList As XmlNodeList = custAddRsNodeList.Item(0).ChildNodes

                                For Each custRetNode As XmlNode In custRetNodeList
                                    If custRetNode.Name.Equals("ListID") Then
                                        Dim intCustomerID As String = CInt(Session("QBCustomerID"))
                                        Dim strListId As String = custRetNode.InnerText
                                        UsersBLL.UpdateQBListID(intCustomerID, strListId)
                                        Exit For
                                    End If
                                Next
                            End If
                        Else
                            Session("QBLastError") = "QB Status Code: " & retStatusCode & " - " & retStatusMessage & _
                                                            " - Error while trying to add customer."
                            Return -1
                        End If
                    End If
                Case "AddOrder"
                    Dim qbXMLMsgsRsNodeList As XmlNodeList = outputXMLDoc.GetElementsByTagName("SalesReceiptAddRs")

                    If qbXMLMsgsRsNodeList.Count = 1 Then
                        Dim rsAttributes As XmlAttributeCollection = qbXMLMsgsRsNodeList.Item(0).Attributes
                        'get the status Code, info and Severity
                        Dim retStatusCode As String = rsAttributes.GetNamedItem("statusCode").Value
                        Dim retStatusSeverity As String = rsAttributes.GetNamedItem("statusSeverity").Value
                        Dim retStatusMessage As String = rsAttributes.GetNamedItem("statusMessage").Value

                        If retStatusCode = "0" Then
                            'get the SalesReceiptRet node for detailed info
                            'a SalesReceiptAddRs contains max one childNode for "SalesReceiptRet"
                            Dim SalesReceiptAddRsNodeList As XmlNodeList = qbXMLMsgsRsNodeList.Item(0).ChildNodes
                            If SalesReceiptAddRsNodeList.Count = 1 AndAlso SalesReceiptAddRsNodeList.Item(0).Name.Equals("SalesReceiptRet") Then
                                Dim SalesReceiptRet As XmlNodeList = SalesReceiptAddRsNodeList.Item(0).ChildNodes

                                For Each SalesReceiptRetNode As XmlNode In SalesReceiptRet
                                    If SalesReceiptRetNode.Name.Equals("RefNumber") Then
                                        Dim O_ID As Integer = CInt(SalesReceiptRetNode.InnerText)
                                        Session("O_ctr") += 1
                                        OrdersBLL.UpdateQBSent(O_ID)
                                        Exit For
                                    End If
                                Next
                            End If
                        Else
                            Session("QBLastError") = "QB Status Code: " & retStatusCode & " - " & retStatusMessage & _
                                                            " - Error while trying to add order."
                            Return -1
                        End If
                    End If
            End Select

            If Session("QBProcess") = "SearchKartrisItem" Then
                retVal = 1
            Else
                Dim count As Integer = CInt(Session("O_ctr"))
                Dim total As Integer = CInt(Session("O_TotalCount"))
                Dim percentage As Integer = (count * 100) / total
                'If percentage >= 100 Then
                '    count = 0
                '    Session("O_ctr") = 0
                'End If
                retVal = percentage
            End If
        End If




        evLogTxt += vbCrLf
        evLogTxt += "Return values: " & vbCrLf
        evLogTxt += "int retVal= " + retVal.ToString() & vbCrLf
        'CkartrisFormatErrors.LogError(evLogTxt)
        Return retVal
    End Function
    <WebMethod(True)> _
    Public Overrides Function sendRequestXML(ByVal ticket As String, ByVal strHCPResponse As String, ByVal strCompanyFileName As String, ByVal qbXMLCountry As String, ByVal qbXMLMajorVers As Integer, ByVal qbXMLMinorVers As Integer) As String

        If Not String.IsNullOrEmpty(strHCPResponse) Then
            DoVersionCheck(strHCPResponse)
        End If

        'UK or US?
        Dim strQBCountry As String = Session("QBCountry")
        'Newer than version 2006?
        Dim blnQBNew As Boolean = Session("QBNew")

        Dim request As String = ""
        If Session("O_ctr") Is Nothing Then Session("O_ctr") = 0
        If Application("KartrisQBItemListID") IsNot Nothing Then
            Dim dtQueue As DataTable = OrdersBLL.GetQBQueue
            If Session("O_ctr") = 0 Then Session("O_TotalCount") = dtQueue.Rows.Count
            If dtQueue.Rows.Count > 0 Then
                Dim intOrderID As Integer = dtQueue.Rows(0)("O_ID")
                Dim strCustomerListID As String = CkartrisDataManipulation.FixNullFromDB(dtQueue.Rows(0)("U_QBListID"))
                Dim intCustomerID As Integer = dtQueue.Rows(0)("O_CustomerID")
                Dim arrBillAdd As String() = Split(dtQueue.Rows(0)("O_BillingAddress"), vbCrLf)
                Dim arrShipAdd As String() = Split(dtQueue.Rows(0)("O_ShippingAddress"), vbCrLf)
                Dim strEmailAddress As String = dtQueue.Rows(0)("U_EmailAddress")


                Dim strFullName As String = arrBillAdd(0)
                Dim strFirstName As String
                Dim strLastName As String
                If InStr(strFullName, " ") > 0 Then
                    strFirstName = Left(strFullName, InStrRev(strFullName, " ") - 1)
                    Dim aryName As String() = Split(Trim(strFullName), " ", -1)
                    strLastName = aryName(UBound(aryName))
                Else
                    strFirstName = strFullName
                    strLastName = strFullName
                End If

                If strCustomerListID Is Nothing Then
                    'Customer is not in QB yet, add Customer in QB first
                    Dim inputXMLDoc As XmlDocument = Nothing
                    Dim qbXMLMsgsRq As XmlElement = Nothing

                    CreateQBReqXML(inputXMLDoc, qbXMLMsgsRq, (Not blnQBNew) And strQBCountry = "UK")
                    Dim CustomerAddRq As XmlElement = inputXMLDoc.CreateElement("CustomerAddRq")
                    qbXMLMsgsRq.AppendChild(CustomerAddRq)
                    CustomerAddRq.SetAttribute("requestID", "2")

                    Dim custAdd As XmlElement = inputXMLDoc.CreateElement("CustomerAdd")
                    CustomerAddRq.AppendChild(custAdd)

                    '.FullName 
                    '.Company 
                    '.StreetAddress 
                    '.TownCity 
                    '.County
                    '.PostCode
                    '.Country.Name 
                    '.Phone

                    custAdd.AppendChild(inputXMLDoc.CreateElement("Name")).InnerText = strFullName
                    If Not String.IsNullOrEmpty(arrBillAdd(1)) Then
                        custAdd.AppendChild(inputXMLDoc.CreateElement("CompanyName")).InnerText = arrBillAdd(1)
                    End If

                    With custAdd
                        .AppendChild(inputXMLDoc.CreateElement("FirstName")).InnerText = strFirstName
                        .AppendChild(inputXMLDoc.CreateElement("LastName")).InnerText = strLastName
                    End With

                    Dim BillAdd As XmlElement = inputXMLDoc.CreateElement("BillAddress")
                    custAdd.AppendChild(BillAdd)
                    With BillAdd
                        .AppendChild(inputXMLDoc.CreateElement("Addr1")).InnerText = arrBillAdd(2)
                        .AppendChild(inputXMLDoc.CreateElement("City")).InnerText = arrBillAdd(3)
                        If strQBCountry = "US" Or blnQBNew Then
                            .AppendChild(inputXMLDoc.CreateElement("State")).InnerText = arrBillAdd(4)
                        Else
                            .AppendChild(inputXMLDoc.CreateElement("County")).InnerText = arrBillAdd(4)
                        End If

                        .AppendChild(inputXMLDoc.CreateElement("PostalCode")).InnerText = arrBillAdd(5)
                        .AppendChild(inputXMLDoc.CreateElement("Country")).InnerText = arrBillAdd(6)
                    End With

                    Dim ShipAdd As XmlElement = inputXMLDoc.CreateElement("ShipAddress")
                    custAdd.AppendChild(ShipAdd)
                    With ShipAdd
                        .AppendChild(inputXMLDoc.CreateElement("Addr1")).InnerText = arrShipAdd(2)
                        .AppendChild(inputXMLDoc.CreateElement("City")).InnerText = arrShipAdd(3)
                        If strQBCountry = "US" Or blnQBNew Then
                            .AppendChild(inputXMLDoc.CreateElement("State")).InnerText = arrShipAdd(4)
                        Else
                            .AppendChild(inputXMLDoc.CreateElement("County")).InnerText = arrShipAdd(4)
                        End If
                        .AppendChild(inputXMLDoc.CreateElement("PostalCode")).InnerText = arrShipAdd(5)
                        .AppendChild(inputXMLDoc.CreateElement("Country")).InnerText = arrShipAdd(6)
                    End With


                    With custAdd
                        Try
                            .AppendChild(inputXMLDoc.CreateElement("Phone")).InnerText = arrBillAdd(7)
                        Catch ex As Exception
                        End Try
                        .AppendChild(inputXMLDoc.CreateElement("Email")).InnerText = strEmailAddress
                        .AppendChild(inputXMLDoc.CreateElement("Contact")).InnerText = strFullName
                    End With



                    request = inputXMLDoc.OuterXml
                    Session("QBCustomerID") = intCustomerID
                    Session("QBProcess") = "AddCustomer"

                Else
                    'Customer is already in QB, just add order (sales receipt)
                    Dim inputXMLDoc As XmlDocument = Nothing
                    Dim qbXMLMsgsRq As XmlElement = Nothing
                    CreateQBReqXML(inputXMLDoc, qbXMLMsgsRq, (Not blnQBNew) And strQBCountry = "UK")
                    Dim SalesReceiptAddRq As XmlElement = inputXMLDoc.CreateElement("SalesReceiptAddRq")
                    qbXMLMsgsRq.AppendChild(SalesReceiptAddRq)
                    SalesReceiptAddRq.SetAttribute("requestID", "2")

                    Dim SalesReceiptAdd As XmlElement = inputXMLDoc.CreateElement("SalesReceiptAdd")
                    SalesReceiptAddRq.AppendChild(SalesReceiptAdd)

                    Dim CustomerRef As XmlElement = inputXMLDoc.CreateElement("CustomerRef")
                    SalesReceiptAdd.AppendChild(CustomerRef)

                    CustomerRef.AppendChild(inputXMLDoc.CreateElement("ListID")).InnerText = strCustomerListID

                    Dim DT As Data.DataTable
                    Dim objBasket As New BasketBLL
                    DT = objBasket.GetCustomerOrderDetails(intOrderID)

                    Dim dtOrderDate As DateTime
                    dtOrderDate = DT.Rows(0).Item("O_Date")
                    Dim strOrderDate As String = dtOrderDate.ToString("yyyy-MM-dd")

                    SalesReceiptAdd.AppendChild(inputXMLDoc.CreateElement("TxnDate")).InnerText = strOrderDate
                    SalesReceiptAdd.AppendChild(inputXMLDoc.CreateElement("RefNumber")).InnerText = intOrderID

                    Dim BillAdd As XmlElement = inputXMLDoc.CreateElement("BillAddress")
                    SalesReceiptAdd.AppendChild(BillAdd)
                    With BillAdd
                        .AppendChild(inputXMLDoc.CreateElement("Addr1")).InnerText = arrBillAdd(2)
                        .AppendChild(inputXMLDoc.CreateElement("City")).InnerText = arrBillAdd(3)
                        If strQBCountry = "US" Or blnQBNew Then
                            .AppendChild(inputXMLDoc.CreateElement("State")).InnerText = arrBillAdd(4)
                        Else
                            .AppendChild(inputXMLDoc.CreateElement("County")).InnerText = arrBillAdd(4)
                        End If
                        .AppendChild(inputXMLDoc.CreateElement("PostalCode")).InnerText = arrBillAdd(5)
                        .AppendChild(inputXMLDoc.CreateElement("Country")).InnerText = arrBillAdd(6)
                    End With

                    'We need to specify the correct term here based on the QBXML number
                    Dim strSalesTaxRefCodeTerm As String = "SalesTaxCodeRef"
                    If (Not blnQBNew) And strQBCountry = "UK" Then
                        strSalesTaxRefCodeTerm = "TaxCodeRef"
                    End If


                    Dim ShipAdd As XmlElement = inputXMLDoc.CreateElement("ShipAddress")
                    SalesReceiptAdd.AppendChild(ShipAdd)
                    With ShipAdd
                        .AppendChild(inputXMLDoc.CreateElement("Addr1")).InnerText = arrShipAdd(2)
                        .AppendChild(inputXMLDoc.CreateElement("City")).InnerText = arrShipAdd(3)
                        If strQBCountry = "US" Or blnQBNew Then
                            .AppendChild(inputXMLDoc.CreateElement("State")).InnerText = arrShipAdd(4)
                        Else
                            .AppendChild(inputXMLDoc.CreateElement("County")).InnerText = arrShipAdd(4)
                        End If
                        .AppendChild(inputXMLDoc.CreateElement("PostalCode")).InnerText = arrShipAdd(5)
                        .AppendChild(inputXMLDoc.CreateElement("Country")).InnerText = arrShipAdd(6)
                    End With

                    'check if the prices in the order are inctax or extax
                    Dim APP_PricesIncTax As Boolean = DT.Rows(0).Item("O_PricesIncTax") = True
                    If strQBCountry = "UK" Then
                        With SalesReceiptAdd
                            If blnQBNew Then
                                .AppendChild(inputXMLDoc.CreateElement("IsTaxIncluded")).InnerText = APP_PricesIncTax.ToString.ToLower
                            End If
                        End With
                    End If


                    Dim numTaxDue As Double = DT.Rows(0).Item("O_TaxDue")


                    Dim dicTaxRAtes As New Dictionary(Of Double, Double)



                    Dim numDiscountPercentage As Double = DT.Rows(0).Item("O_DiscountPercentage")
                    If numDiscountPercentage > 0 Then
                        numDiscountPercentage = numDiscountPercentage / 100
                    End If


                    For Each drLine As DataRow In DT.Rows
                        Dim strVersionCode As String = drLine("IR_VersionCode")

                        Dim numPricePerItem, numTaxPerItem, numQuantity As Double
                        Dim strItemLineName As String
                        'If drLine("IR_OptionsText") <> "" Then strItemLineName = strVersionCode & " - " & drLine("IR_OptionsText") Else 
                        strItemLineName = strVersionCode
                        numPricePerItem = drLine("IR_PricePerItem")
                        numTaxPerItem = drLine("IR_TaxPerItem")
                        numQuantity = drLine("IR_Quantity")

                        Dim numRate As Double = numPricePerItem

                        If (Not blnQBNew) And APP_PricesIncTax Then numRate = numPricePerItem - numTaxPerItem

                        'If APP_PricesIncTax Then
                        '    numRate = numPricePerItem - numTaxPerItem
                        'Else
                        '    numRate = numPricePerItem
                        'End If
                        'Else
                        'numRate = numPricePerItem
                        ''If APP_PricesIncTax Then
                        ''    numRate = numPricePerItem
                        ''Else
                        ''    numRate = 0.0001 + numPricePerItem + (numPricePerItem * numTaxPerItem)
                        ''End If
                        'End If


                If numDiscountPercentage > 0 Then
                    'numRate = numRate - (numRate * numDiscountPercentage)
                            Dim numTaxRate As Double
                            Dim numTaxItemValue As Double
                            If APP_PricesIncTax Then
                                numTaxRate = TaxBLL.GetClosestRate(Math.Round((numTaxPerItem / numPricePerItem) * 100, 2))
                            Else
                                numTaxRate = numTaxPerItem
                            End If

                            numTaxItemValue = (numRate * numDiscountPercentage) * numQuantity

                            If dicTaxRAtes.ContainsKey(numTaxRate) Then
                                dicTaxRAtes(numTaxPerItem) += numTaxItemValue
                            Else
                                dicTaxRAtes.Add(numTaxRate, numTaxItemValue)
                            End If
                End If



                Dim BasketItemLineAdd As XmlElement = inputXMLDoc.CreateElement("SalesReceiptLineAdd")
                SalesReceiptAdd.AppendChild(BasketItemLineAdd)

                Dim ItemRefBasketLineAdd As XmlElement = inputXMLDoc.CreateElement("ItemRef")
                BasketItemLineAdd.AppendChild(ItemRefBasketLineAdd)
                ItemRefBasketLineAdd.AppendChild(inputXMLDoc.CreateElement("ListID")).InnerText = Application("KartrisQBItemListID").ToString
                With BasketItemLineAdd
                    .AppendChild(inputXMLDoc.CreateElement("Desc")).InnerText = strItemLineName
                    .AppendChild(inputXMLDoc.CreateElement("Quantity")).InnerText = numQuantity
                    .AppendChild(inputXMLDoc.CreateElement("Rate")).InnerText = Math.Round(numRate, 2)
                End With

                Dim SalesTaxCodeRefBasketLineAdd As XmlElement = inputXMLDoc.CreateElement(strSalesTaxRefCodeTerm)
                BasketItemLineAdd.AppendChild(SalesTaxCodeRefBasketLineAdd)
                SalesTaxCodeRefBasketLineAdd.AppendChild(inputXMLDoc.CreateElement("FullName")).InnerText = TaxBLL.GetQBTaxRefCode(strVersionCode)
                    Next


                    If numDiscountPercentage > 0 Then
                        For Each item In dicTaxRAtes
                            Dim BasketItemLineAdd As XmlElement = inputXMLDoc.CreateElement("SalesReceiptLineAdd")
                            SalesReceiptAdd.AppendChild(BasketItemLineAdd)

                            Dim ItemRefBasketLineAdd As XmlElement = inputXMLDoc.CreateElement("ItemRef")
                            BasketItemLineAdd.AppendChild(ItemRefBasketLineAdd)
                            ItemRefBasketLineAdd.AppendChild(inputXMLDoc.CreateElement("ListID")).InnerText = Application("KartrisQBItemListID").ToString
                            With BasketItemLineAdd
                                .AppendChild(inputXMLDoc.CreateElement("Desc")).InnerText = CStr(numDiscountPercentage * 100) & "% Discount on items with " & item.Key & "% tax"
                                .AppendChild(inputXMLDoc.CreateElement("Quantity")).InnerText = 1
                                .AppendChild(inputXMLDoc.CreateElement("Rate")).InnerText = -Math.Round(item.Value, 2)
                            End With

                            Dim SalesTaxCodeRefBasketLineAdd As XmlElement = inputXMLDoc.CreateElement(strSalesTaxRefCodeTerm)
                            BasketItemLineAdd.AppendChild(SalesTaxCodeRefBasketLineAdd)
                            SalesTaxCodeRefBasketLineAdd.AppendChild(inputXMLDoc.CreateElement("FullName")).InnerText = TaxBLL.GetQBTaxRefCode(CDbl(item.Key))
                        Next

                    End If

                    ' Add Coupon Discount Line (if there's any)
                    Dim numCouponDiscountTotal As Double = DT.Rows(0).Item("O_CouponDiscountTotal")
                    Dim strCouponCode As String = DT.Rows(0).Item("O_CouponCode") & ""

                    If strCouponCode <> "" Then
                        Dim CouponLineAdd As XmlElement = inputXMLDoc.CreateElement("SalesReceiptLineAdd")
                        SalesReceiptAdd.AppendChild(CouponLineAdd)

                        Dim ItemRefCouponLineAdd As XmlElement = inputXMLDoc.CreateElement("ItemRef")
                        CouponLineAdd.AppendChild(ItemRefCouponLineAdd)
                        ItemRefCouponLineAdd.AppendChild(inputXMLDoc.CreateElement("ListID")).InnerText = Application("KartrisQBItemListID").ToString

                        With CouponLineAdd
                            .AppendChild(inputXMLDoc.CreateElement("Desc")).InnerText = "Coupon Discount"
                            .AppendChild(inputXMLDoc.CreateElement("Quantity")).InnerText = "1"
                            .AppendChild(inputXMLDoc.CreateElement("Rate")).InnerText = Math.Round(numCouponDiscountTotal, 2)
                        End With

                        Dim SalesTaxCodeRefCouponLineAdd As XmlElement = inputXMLDoc.CreateElement(strSalesTaxRefCodeTerm)
                        CouponLineAdd.AppendChild(SalesTaxCodeRefCouponLineAdd)
                        SalesTaxCodeRefCouponLineAdd.AppendChild(inputXMLDoc.CreateElement("FullName")).InnerText = "S"
                        '_ TaxBLL.GetQBTaxRefCode(6)
                    End If

                    ' Add Promotion Discount Line
                    Dim numPromotionDiscountTotal As Double = DT.Rows(0).Item("O_PromotionDiscountTotal")

                    If numPromotionDiscountTotal < 0 Then
                        Dim PromotionLineAdd As XmlElement = inputXMLDoc.CreateElement("SalesReceiptLineAdd")
                        SalesReceiptAdd.AppendChild(PromotionLineAdd)

                        Dim ItemRefPromotionLineAdd As XmlElement = inputXMLDoc.CreateElement("ItemRef")
                        PromotionLineAdd.AppendChild(ItemRefPromotionLineAdd)
                        ItemRefPromotionLineAdd.AppendChild(inputXMLDoc.CreateElement("ListID")).InnerText = Application("KartrisQBItemListID").ToString

                        With PromotionLineAdd
                            .AppendChild(inputXMLDoc.CreateElement("Desc")).InnerText = "Promotion Discount"
                            .AppendChild(inputXMLDoc.CreateElement("Quantity")).InnerText = "1"
                            .AppendChild(inputXMLDoc.CreateElement("Rate")).InnerText = Math.Round(numPromotionDiscountTotal, 2)
                        End With

                        Dim SalesTaxCodeRefPromotionLineAdd As XmlElement = inputXMLDoc.CreateElement(strSalesTaxRefCodeTerm)
                        PromotionLineAdd.AppendChild(SalesTaxCodeRefPromotionLineAdd)
                        SalesTaxCodeRefPromotionLineAdd.AppendChild(inputXMLDoc.CreateElement("FullName")).InnerText = TaxBLL.GetQBTaxRefCode(6)
                    End If

                    'Add Shipping line
                    Dim numShippingPrice As Double = DT.Rows(0).Item("O_ShippingPrice")
                    If blnQBNew Then
                        If APP_PricesIncTax Then
                            numShippingPrice += DT.Rows(0).Item("O_ShippingTax")
                        End If
                    End If
                    
                    If numShippingPrice > 0 Then
                        Dim ShippingLineAdd As XmlElement = inputXMLDoc.CreateElement("SalesReceiptLineAdd")
                        SalesReceiptAdd.AppendChild(ShippingLineAdd)

                        Dim ItemRefShippingLineAdd As XmlElement = inputXMLDoc.CreateElement("ItemRef")
                        ShippingLineAdd.AppendChild(ItemRefShippingLineAdd)
                        ItemRefShippingLineAdd.AppendChild(inputXMLDoc.CreateElement("ListID")).InnerText = Application("KartrisQBItemListID").ToString

                        With ShippingLineAdd
                            .AppendChild(inputXMLDoc.CreateElement("Desc")).InnerText = "Shipping"
                            .AppendChild(inputXMLDoc.CreateElement("Quantity")).InnerText = "1"
                            .AppendChild(inputXMLDoc.CreateElement("Rate")).InnerText = Math.Round(numShippingPrice, 2)
                        End With

                        Dim SalesTaxCodeRefShippingLineAdd As XmlElement = inputXMLDoc.CreateElement(strSalesTaxRefCodeTerm)
                        ShippingLineAdd.AppendChild(SalesTaxCodeRefShippingLineAdd)
                        SalesTaxCodeRefShippingLineAdd.AppendChild(inputXMLDoc.CreateElement("FullName")).InnerText = _
                            TaxBLL.GetQBTaxRefCode(CInt(KartSettingsManager.GetKartConfig("frontend.checkout.shipping.taxband")))
                    End If


                    'Add Order Handling Charge line
                    Dim numOrderHandlingPrice As Double = DT.Rows(0).Item("O_OrderHandlingCharge")
                    If blnQBNew Then
                        If APP_PricesIncTax Then
                            numOrderHandlingPrice += DT.Rows(0).Item("O_OrderHandlingChargeTax")
                        End If
                    End If
                    

                    If numOrderHandlingPrice > 0 Then
                        Dim OrderHandlingLineAdd As XmlElement = inputXMLDoc.CreateElement("SalesReceiptLineAdd")
                        SalesReceiptAdd.AppendChild(OrderHandlingLineAdd)

                        Dim ItemRefHandlingLineAdd As XmlElement = inputXMLDoc.CreateElement("ItemRef")
                        OrderHandlingLineAdd.AppendChild(ItemRefHandlingLineAdd)
                        ItemRefHandlingLineAdd.AppendChild(inputXMLDoc.CreateElement("ListID")).InnerText = Application("KartrisQBItemListID").ToString

                        With OrderHandlingLineAdd
                            .AppendChild(inputXMLDoc.CreateElement("Desc")).InnerText = "Order Handling Charge"
                            .AppendChild(inputXMLDoc.CreateElement("Quantity")).InnerText = "1"
                            .AppendChild(inputXMLDoc.CreateElement("Rate")).InnerText = Math.Round(numOrderHandlingPrice, 2)
                        End With

                        Dim SalesTaxCodeRefHandlingLineAdd As XmlElement = inputXMLDoc.CreateElement(strSalesTaxRefCodeTerm)
                        OrderHandlingLineAdd.AppendChild(SalesTaxCodeRefHandlingLineAdd)
                        SalesTaxCodeRefHandlingLineAdd.AppendChild(inputXMLDoc.CreateElement("FullName")).InnerText = _
                            TaxBLL.GetQBTaxRefCode(CInt(KartSettingsManager.GetKartConfig("frontend.checkout.orderhandlingchargetaxband")))
                    End If

                    'How about the customer discount???

                    ' MAYBE WE'LL SUPPORT THESE TAGS LATER
                    '.AppendChild(inputXMLDoc.CreateElement("IsPending")).InnerText = "true"
                    '.AppendChild(inputXMLDoc.CreateElement("IsToBePrinted")).InnerText = "true"
                    '.AppendChild(inputXMLDoc.CreateElement("IsToBeEmailed")).InnerText = "false"

                    If strQBCountry = "UK" Then
                        With SalesReceiptAdd
                            If Not blnQBNew Then
                                .AppendChild(inputXMLDoc.CreateElement("AmountIncludesVAT")).InnerText = APP_PricesIncTax.ToString.ToLower
                            End If
                        End With
                    End If


                    request = inputXMLDoc.OuterXml
                    Session("QBProcess") = "AddOrder"
                    Session("O_ctr") += 1
                End If
            End If
        Else
            Dim inputXMLDoc As XmlDocument = Nothing
            Dim qbXMLMsgsRq As XmlElement = Nothing
            CreateQBReqXML(inputXMLDoc, qbXMLMsgsRq, (Not blnQBNew) And strQBCountry = "UK")
            Dim ItemQueryRq As XmlElement = inputXMLDoc.CreateElement("ItemQueryRq")
            qbXMLMsgsRq.AppendChild(ItemQueryRq)
            ItemQueryRq.SetAttribute("requestID", "1")
            ItemQueryRq.AppendChild(inputXMLDoc.CreateElement("FullName")).InnerText = "Kartris Order Item"
            request = inputXMLDoc.OuterXml
            Session("QBProcess") = "SearchKartrisItem"
        End If

        Dim evLogTxt As String = "WebMethod: sendRequestXML() has been called by QBWebconnector" & vbCrLf & vbCrLf
        evLogTxt += "Parameters received:" & vbCrLf
        evLogTxt += ("string ticket = ") + ticket & vbCrLf
        evLogTxt += ("string strHCPResponse = ") + strHCPResponse & vbCrLf
        evLogTxt += ("string strCompanyFileName = ") + strCompanyFileName & vbCrLf
        evLogTxt += ("string qbXMLCountry = ") + qbXMLCountry & vbCrLf
        evLogTxt += ("int qbXMLMajorVers = ") + qbXMLMajorVers.ToString() & vbCrLf
        evLogTxt += ("int qbXMLMinorVers = ") + qbXMLMinorVers.ToString() & vbCrLf
        evLogTxt += vbCrLf & vbCrLf
        evLogTxt += "Return values: " & vbCrLf
        evLogTxt += ("string request = ") + request & vbCrLf
        'CkartrisFormatErrors.LogError(evLogTxt)
        Return request
    End Function
    Private Sub CreateQBReqXML(ByRef inputXMLDoc As XmlDocument, ByRef qbXMLMgsRq As XmlElement, ByVal blnOldUK As Boolean)
        inputXMLDoc = New XmlDocument()
        inputXMLDoc.AppendChild(inputXMLDoc.CreateXmlDeclaration("1.0", Nothing, Nothing))
        If blnOldUK Then
            inputXMLDoc.AppendChild(inputXMLDoc.CreateProcessingInstruction("qbxml", "version=""UK2.0"""))
        Else
            inputXMLDoc.AppendChild(inputXMLDoc.CreateProcessingInstruction("qbxml", "version=""6.0"""))
        End If

        Dim qbXML As XmlElement = inputXMLDoc.CreateElement("QBXML")
        inputXMLDoc.AppendChild(qbXML)
        qbXMLMgsRq = inputXMLDoc.CreateElement("QBXMLMsgsRq")
        qbXML.AppendChild(qbXMLMgsRq)
        qbXMLMgsRq.SetAttribute("onError", "stopOnError")
    End Sub

    Private Function parseForVersion(ByVal input As String) As String
        ' This method is created just to parse the first two version components
        ' out of the standard four component version number:
        ' <Major>.<Minor>.<Release>.<Build>
        ' 
        Dim retVal As String = ""
        Dim major As String = ""
        Dim minor As String = ""
        Dim version As New System.Text.RegularExpressions.Regex("^(?<major>\d+)\.(?<minor>\d+)(\.\w+){0,2}$", _
                                                                System.Text.RegularExpressions.RegexOptions.Compiled)
        Dim versionMatch As System.Text.RegularExpressions.Match = version.Match(input)
        If versionMatch.Success Then
            major = versionMatch.Result("${major}")
            minor = versionMatch.Result("${minor}")
            retVal = (major & ".") + minor
        Else
            retVal = input
        End If
        Return retVal
    End Function
    ''' <summary>
    ''' WebMethod - serverVersion()
    ''' To enable web service with its version number returned back to QBWC
    ''' Signature: public string serverVersion()
    '''
    ''' OUT: 
    ''' string 
    ''' Possible values: 
    ''' Version string representing server version
    ''' </summary>

    <WebMethod()> _
    Public Function serverVersion() As String
        serverVersion = "2.0.0.1"
        Dim evLogTxt As String = "WebMethod: serverVersion() has been called " & "by QBWebconnector" & vbCrLf & vbCrLf
        evLogTxt += "No Parameters required."
        evLogTxt += ("Returned: ") + serverVersion
        Return serverVersion
    End Function
    Private Sub DoVersionCheck(ByVal strResponse As String)
        Dim outputXMLDoc As New XmlDocument()
        outputXMLDoc.LoadXml(strResponse)
        Dim qbXMLMsgsRsNodeList As XmlNodeList = outputXMLDoc.GetElementsByTagName("HostRet")
        Dim HostRet As XmlNodeList = qbXMLMsgsRsNodeList.Item(0).ChildNodes
        For Each custRetNode As XmlNode In HostRet
            If custRetNode.Name.Equals("Country") Then
                Session("QBCountry") = custRetNode.InnerText
            ElseIf custRetNode.Name.Equals("MajorVersion") Then
                Dim intMajorVersion As Integer = CInt(custRetNode.InnerText)
                If intMajorVersion < 16 Then Session("QBNew") = False Else Session("QBNew") = True
            ElseIf custRetNode.Name.Equals("SupportedQBXMLVersion") Then
                If custRetNode.InnerText = "6.0" Then
                    Session("QBNew") = True
                ElseIf custRetNode.InnerText = "UK2.0" Then
                    Session("QBCountry") = "US"
                    Session("QBNew") = False
                    Exit For
                End If
            End If
        Next
        HostRet = Nothing
        qbXMLMsgsRsNodeList = Nothing
        outputXMLDoc = Nothing
    End Sub
End Class
