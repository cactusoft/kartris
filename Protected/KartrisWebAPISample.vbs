'========================================================================
'Kartris Web API VBScript Sample- www.kartris.com
'Copyright 2013 CACTUSOFT INTERNATIONAL FZ LLC
'www.cactusoft.com

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================

'========================================================================
'Kartris WebShop URL
'========================================================================
'NOTE: Your Kartris shop must be up and running in order to access its Web API
strKartrisWebShopURL = "http://localhost:52038/Kartris/"

'========================================================================
'Web API Key set in your Kartris' web.config
strKartrisWebAPIKey = "dXNlcm5hbWU6cGFzc3dvcmQ="
'========================================================================

'========================================================================
'Kartris method Name that you want to execute
'========================================================================
'Name of the method that you want to execute (fully qualified name, case-sensitive) e.g. TaxBLL.GetTaxRate (ClassName.MethodName)
strMethodName = "TaxBLL.GetTaxRate"

'========================================================================
'strParametersXML
'========================================================================
strParametersXML = "<Parameter Name=""numTaxID"" Type=""Byte"" Value=""2""/>"

'to pass multiple parameters ->
'strParametersXML = "<Parameter Name=""Param1"" Type=""Integer"" Value=""1""/><Parameter Name=""Param2"" Type=""String"" Value=""Param2StringValue""/>..."
'just pass an empty string for functions that don't have any parameters like CKartrisBLL.WebShopURL 

'========================================================================================================

'LET'S START!!

SoapServer = strKartrisWebShopURL & "Protected/KartrisWebAPI.svc"

Set requestDoc = WScript.CreateObject("MSXML2.DOMDocument.6.0")
Set root = requestDoc.createNode(1, "Envelope", "http://schemas.xmlsoap.org/soap/envelope/")
requestDoc.appendChild root
Set nodeBody = requestDoc.createNode(1, "Body", "http://schemas.xmlsoap.org/soap/envelope/")
root.appendChild nodeBody
Set nodeOp = requestDoc.createNode(1, "Execute", "http://tempuri.org/")
nodeBody.appendChild nodeOp
Set nodeRequest = requestDoc.createNode(1, "strMethod", "http://tempuri.org/")

nodeRequest.text = strMethodName
nodeOp.appendChild nodeRequest

Set nodeRequest = requestDoc.createNode(1, "strParametersXML", "http://tempuri.org/")
      
nodeRequest.text = "<?xml version=""1.0"" encoding=""utf-8"" ?><KartrisWebAPI><Parameters>" & _ 
strParametersXML & _
"</Parameters></KartrisWebAPI>"

nodeOp.appendChild nodeRequest

'the request will look something like this:
'       <s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'>
'         <s:Body> 
'           <Execute xmlns='http://tempuri.org/'> 
'               <strMethod>...</strMethod> 
'               <strParametersXML>...</strParametersXML> 
'           </Execute> 
'         </s:Body> 
'       </s:Envelope>

WSCript.Echo  "Sending Request: " & vbcrlf & requestDoc.xml

set xmlhttp = WScript.CreateObject("MSXML2.ServerXMLHTTP.6.0")
xmlhttp.Open "POST", SoapServer, False
xmlhttp.setRequestHeader "Authorization", strKartrisWebAPIKey
xmlhttp.setRequestHeader "Content-Type", "text/xml"
' set SOAPAction as appropriate for the operation '
xmlhttp.setRequestHeader "SOAPAction", "http://tempuri.org/IKartrisWebAPI/Execute"
xmlhttp.send requestDoc.xml

strResponseXML = xmlhttp.responseXML.xml

'display RAW XML response
WScript.Echo vbcrlf & "Raw XML Response: " & vbcrlf & strResponseXML

'display extracted ExecuteResult XML
intExecuteResultStartPos = instr(strResponseXML,"<ExecuteResult>") + 15
If intExecuteResultStartPos > 15 Then
   strTrimmedXML = mid(strResponseXML, intExecuteResultStartPos)
   strTrimmedXML = Replace(strTrimmedXML, "&lt;?xml version=""1.0"" encoding=""utf-16""?&gt;", "")
   intExecuteResultEndPos = instr(strTrimmedXML,"</ExecuteResult>") - 1
   strTrimmedXML = Left(strTrimmedXML, intExecuteResultEndPos)
   strTrimmedXML = Replace(strTrimmedXML,"&lt;", "<" )
   strTrimmedXML = Replace(strTrimmedXML,"&gt;", ">" )
   WScript.Echo vbcrlf & "Extracted Result Data: " & vbcrlf & strTrimmedXML
End If

set response= xmlhttp.responseXML

Set nodeRequest = Nothing
Set nodeOp = Nothing
Set nodeBody = Nothing
Set root = Nothing