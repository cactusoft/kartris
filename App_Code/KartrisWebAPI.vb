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
                    '    <Parameter Name="Param1" Type="String" Value="Value1">
                    '    <Parameter Name="Param2" Type="Integer" Value="Value2">
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
                        Dim strType As String = ndeParameter.Attributes.GetNamedItem("Type").Value
                        Dim strValue As String = ndeParameter.Attributes.GetNamedItem("Value").Value

                        'cast the generic object variable just to be safe
                        Select Case strType.ToLower
                            Case "string"
                                objParam = strValue
                            Case "integer"
                                objParam = CInt(strValue)
                            Case "boolean"
                                If strValue.ToLower = "true" Then objParam = True Else objParam = False
                            Case "address"
                                ' TODO: add support to Address type parameters in Web API
                                objParam = DirectCast(objParam, KartrisClasses.Address)
                            Case "long"
                                objParam = CLng(strValue)
                            Case "short"
                                objParam = CShort(strValue)
                            Case "arraylist"
                                ' TODO: add support to arraylist type parameters in Web API
                                objParam = DirectCast(objParam, System.Collections.ArrayList)
                            Case "double"
                                objParam = CDbl(strValue)
                            Case "byte"
                                objParam = CByte(strValue)
                            Case "single"
                                objParam = CSng(strValue)
                        End Select

                        Params(intIndex) = objParam
                        intIndex = intIndex + 1
                    Next

                    Dim pTypes(Params.Length - 1) As Type

                    For i As Integer = 0 To Params.GetUpperBound(0)
                        pTypes(i) = Params(i).GetType()
                    Next

                    m = t.GetMethod(strMethodName, pTypes)
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

        Return strOutput

    End Function

End Class
