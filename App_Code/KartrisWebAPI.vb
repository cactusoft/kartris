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

Imports System.Reflection
Imports Kartris
Imports System.ServiceModel.Activation

<AspNetCompatibilityRequirements(RequirementsMode:=AspNetCompatibilityRequirementsMode.Required)> _
 Public Class KartrisWebAPI
    Implements IKartrisWebAPI

    ''' <summary>
    ''' Execute Kartris method
    ''' </summary>
    ''' <param name="strMethod">Name of the method that you want to execute (fully qualified name, case-sensitive) e.g. CKartrisBLL.WebShopURL </param>
    ''' <param name="strParametersXML">XML parameter array for the specified method</param>
    ''' <returns>XML Serialized Object</returns>
    ''' <remarks></remarks>
    Public Function Execute(ByVal strMethod As String, ByVal strParametersXML As String) As String Implements IKartrisWebAPI.Execute
        Dim strOutput As String = ""
        Dim blnKeyValidated As Boolean = False
        Dim blnAllowIP As Boolean = True

        Dim strAuthorizationKey As String = HttpContext.Current.Request.Headers("Authorization")
        blnKeyValidated = ValidateKey(strAuthorizationKey)

        If Not blnKeyValidated Then strOutput = "Sorry. Cant authenticate request!"

        'Get user's IP address
        Dim strClientIP As String = HttpContext.Current.Request.ServerVariables("HTTP_X_FORWARDED_FOR")
        If String.IsNullOrEmpty(strClientIP) Then
            strClientIP = HttpContext.Current.Request.ServerVariables("REMOTE_ADDR")
        End If

        'Check matches specified IPs in web.config, if not blank
        Dim strBackEndIPLock = ConfigurationManager.AppSettings("KartrisWebAPIIPLock").ToString()
        If strBackEndIPLock <> "" Then
            Try
                Dim arrBackendIPs As String() = Split(strBackEndIPLock, ",")
                Dim blnFullIP As Boolean
                For x As Integer = 0 To arrBackendIPs.Count - 1
                    'check if the IP is a range or a full IP, if its a full ip then it must be matched exactly
                    If Split(arrBackendIPs(x), ".").Count = 4 Then blnFullIP = True Else blnFullIP = False
                    If IIf(blnFullIP, arrBackendIPs(x) = strClientIP, Left(strClientIP, arrBackendIPs(x).Length) = arrBackendIPs(x)) Then
                        'ok, let 'em in
                        blnAllowIP = True
                        Exit For
                    End If
                Next
                If Not blnAllowIP Then
                    strOutput = "Sorry. Cant authenticate request!"
                End If
            Catch ex As Exception
                blnAllowIP = False
                strOutput = "Invalid Web API IP lock settings!"
            End Try
        End If

        'HttpContext.Current.Request.UserHostAddress
        If blnKeyValidated And blnAllowIP Then
            Try
                Dim obj As New Object

                Dim strClassName As String = Left(strMethod, InStr(strMethod, ".") - 1)
                Dim strMethodName As String = Mid(strMethod, InStr(strMethod, ".") + 1)

                Dim t As Type = System.Type.GetType(strClassName)

                Dim m As MethodInfo

                Dim Params() As Object = Nothing

                If t IsNot Nothing Then
                    'method was found, try to load it up
                    If strParametersXML Is Nothing OrElse String.IsNullOrEmpty(strParametersXML) Then
                        m = t.GetMethod(strMethodName, Type.EmptyTypes)
                    Else
                        '<?xml version="1.0" encoding="utf-8" ?>
                        '<KartrisWebAPI>
                        '  <Parameters>
                        '    <Parameter Name="Param1" Type="String">
                        '       <Value>Value1</Value>
                        '    </Parameter>
                        '    <Parameter Name="Param2" Type="Integer">
                        '       <Value>Value2</Value>
                        '    </Parameter>
                        '    ...
                        '  </Parameters>
                        '<KartrisWebAPI>

                        'parse the parameter array XML
                        Dim docXML As XmlDocument = New XmlDocument
                        'Load the xml 
                        docXML.LoadXml(strParametersXML)

                        Dim lstNodes As XmlNodeList
                        Dim ndeParameter As XmlNode

                        Dim strParametersNodePath As String = "/KartrisWebAPI/Parameters/Parameter"
                        lstNodes = docXML.SelectNodes(strParametersNodePath)

                        Array.Resize(Params, lstNodes.Count)

                        Dim intIndex As Integer = 0
                        For Each ndeParameter In lstNodes

                            Dim objParam As New Object

                            'Dim blnisByRefType As Boolean = False

                            'Try
                            '    Dim strIsByRefTypeValue As String = ndeParameter.Attributes.GetNamedItem("isByRef").Value
                            '    If Not String.IsNullOrEmpty(strIsByRefTypeValue) Then blnisByRefType = CBool(strIsByRefTypeValue)
                            'Catch ex As Exception

                            'End Try

                            Dim strType As String = ndeParameter.Attributes.GetNamedItem("Type").Value
                            Dim strValue As String = ndeParameter.FirstChild.InnerText

                            'remove trailing spaces if parameter is not string
                            If strType.ToLower <> "string" And Not String.IsNullOrEmpty(strValue) Then strValue = strValue.Trim

                            Select Case strType.ToLower
                                Case "string"
                                    objParam = strValue
                                Case "integer"
                                    If String.IsNullOrEmpty(strValue) Then
                                        objParam = DirectCast(objParam, Integer)
                                        objParam = Nothing
                                    Else
                                        objParam = CInt(strValue)
                                    End If

                                Case "boolean"
                                    If String.IsNullOrEmpty(strValue) Then
                                        objParam = DirectCast(objParam, Boolean)
                                        objParam = Nothing
                                    Else
                                        If strValue.ToLower = "true" Then objParam = True Else objParam = False
                                    End If
                                Case "address"
                                    Dim objAddress As KartrisClasses.Address = Payment.Deserialize(strValue, GetType(KartrisClasses.Address))
                                    objParam = objAddress
                                Case "long"
                                    objParam = CLng(strValue)
                                Case "short"
                                    objParam = CShort(strValue)
                                Case "arraylist"
                                    Dim arrObject As ArrayList = Payment.Deserialize(strValue, GetType(ArrayList))
                                    objParam = arrObject
                                Case "basket"
                                    Dim objBasket As BasketBLL = Payment.Deserialize(strValue, GetType(BasketBLL))
                                    objParam = objBasket
                                Case "datatable"
                                    Dim tblObject As DataTable = Payment.Deserialize(strValue, GetType(DataTable))
                                    objParam = tblObject
                                Case "datarow"
                                    Dim tblObject As DataRow = Payment.Deserialize(strValue, GetType(DataRow))
                                    objParam = tblObject
                                Case "double"
                                    objParam = CDbl(strValue)
                                Case "byte"
                                    objParam = CByte(strValue)
                                Case "single"
                                    If String.IsNullOrEmpty(strValue) Then
                                        objParam = DirectCast(objParam, Single)
                                        objParam = Nothing
                                    Else
                                        objParam = CSng(strValue)
                                    End If
                                Case "date"
                                    If String.IsNullOrEmpty(strValue) Then
                                        objParam = DirectCast(objParam, Date)
                                        objParam = Nothing
                                    Else
                                        objParam = CDate(strValue)
                                    End If
                                Case "orders_list_callmode"
                                    Dim callmode As OrdersBLL.ORDERS_LIST_CALLMODE
                                    callmode = strValue
                                    objParam = callmode
                                Case "char"
                                    objParam = CChar(strValue)
                            End Select

                            'If blnisByRefType Then
                            '    objParam = objParam.GetType.MakeByRefType
                            'End If

                            Params(intIndex) = objParam
                            intIndex = intIndex + 1
                        Next

                        Dim pTypes(Params.Length - 1) As Type

                        For i As Integer = 0 To Params.GetUpperBound(0)
                            pTypes(i) = Params(i).GetType()
                        Next

                        m = t.GetMethod(strMethodName)
                    End If

                    If m IsNot Nothing Then
                        strOutput = Payment.Serialize(m.Invoke(obj, Params))
                    Else
                        Throw New Exception("Can't find method """ & strMethodName & """ in Class """ & strClassName & """")
                    End If

                Else
                    'method wasn't found
                    strOutput = Payment.Serialize("Can't find specified Class """ & strClassName & """")
                End If
            Catch ex As Exception
                'an exception occured while try to parse strMethod
                strOutput = Payment.Serialize("Error parsing method string! Exception Details -> " & ex.Message)
            End Try
        End If

        Return strOutput

    End Function
    ''' <summary>
    ''' Validate the key in the request authorization header against the KartrisWebAPISecretKey appsetting
    ''' </summary>
    ''' <param name="strKartrisAPIKey"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function ValidateKey(ByVal strKartrisAPIKey As String) As Boolean
        Dim strConfigAPIKey As String = ConfigurationManager.AppSettings("KartrisWebAPISecretKey")
        'always invalidate request if API key is not set in the web.config (its safer that way)
        If String.IsNullOrEmpty(strConfigAPIKey) Then Return False
        If (strKartrisAPIKey = strConfigAPIKey) Then Return True Else Return False
    End Function

End Class
Public Class UserNamePassValidator
    Inherits System.IdentityModel.Selectors.UserNamePasswordValidator
    ''' <summary>
    ''' This method is only used when wsHTTPBinding is enabled
    ''' Uses backend login details to authenticate API user in addition to the WebAPISecretKey validation
    ''' </summary>
    ''' <param name="userName"></param>
    ''' <param name="password"></param>
    ''' <remarks></remarks>
    Public Overrides Sub Validate(userName As String, password As String)
        If userName Is Nothing OrElse password Is Nothing Then
            Throw New ArgumentNullException()
        End If

        If Not LoginsBLL.Validate(userName, password) Then
            Throw New System.ServiceModel.FaultException("Incorrect Username or Password")
        End If
    End Sub
End Class
