'========================================================================
'Kartris - www.kartris.com
'Copyright 2018 CACTUSOFT

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
Imports System.Threading
Imports System.Web.Script.Serialization
Imports CkartrisBLL
Imports CkartrisDataManipulation
Imports KartSettingsManager
Imports Newtonsoft.Json.Linq

Partial Class Notification
    Inherits PageBaseClass

    Private clsPlugin As Kartris.Interfaces.PaymentGateway

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Dim strCallbackError As String = ""
            Dim strResult As String = ""
            Dim strUpdateResult As String = ""
            Dim strMultibancoData As String() = Split("", " ")
            Dim strBodyText As String = ""
            Dim blnFullDisplay As Boolean = True
            If Request.QueryString("d") = "off" Then blnFullDisplay = False
            Dim strGatewayName As String = StrConv(Request.QueryString("g"), vbProperCase)
            Dim clsPlugin As Kartris.Interfaces.PaymentGateway = Nothing


            If Not String.IsNullOrEmpty(strGatewayName) Then
                'Let's turn some comment gateway names which
                'might be sent in any case format to the correct
                'mixed case format so they look nice.
                If LCase(strGatewayName) = "sagepaydirect" Then strGatewayName = "SagePayDirect"
                If LCase(strGatewayName) = "sagepay" Then strGatewayName = "SagePay"
                If LCase(strGatewayName) = "cp" Then strGatewayName = "Cactuspay"
                If LCase(strGatewayName) = "easypay" Then
                    strGatewayName = "EasypayCreditCard"
                    CreateQueryStringParams("e", Request.QueryString.Get("?e"))
                    RemoveQueryStringParams("?e")
                    'Request.QueryString = 

                End If

                'Load in the payment gateway in question
                'This is why it is important that the name is
                'passed correctly when setting up the callback.aspx
                clsPlugin = Payment.PPLoader(strGatewayName)

                'According to the dictionary, 'referrer' is the
                'correct spelling and whoever decided on 'referer'
                'is the one who is wrong :)
                Dim strReferrerURL As String
                Try
                    strReferrerURL = Request.UrlReferrer.ToString()
                Catch ex As Exception
                    strReferrerURL = Request.ServerVariables("HTTP_REFERER")
                End Try

                If strGatewayName.ToLower = "afforditnow" Then

                    Dim dataStream As Stream = Request.InputStream
                    ' Open the stream using a StreamReader for easy access.
                    Dim reader As New StreamReader(dataStream)
                    ' Read the content.
                    Dim requestStream As String = reader.ReadToEnd()

                    Dim jsonParse = JValue.Parse(requestStream)
                    Dim applicationId = Int64.Parse(jsonParse("application").ToString())
                    Dim new_status = jsonParse("new_status").ToString()
                    'Response.Write("Hello  <br>")

                    CkartrisFormatErrors.LogError("Notification app: " & applicationId & " new status: " & new_status)

                    Response.ClearHeaders()
                    Response.StatusCode = 200
                    Response.Flush()
                    Response.End()
                Else
                    Response.ClearHeaders()
                    Response.StatusCode = 404
                    Response.Flush()
                    Response.End()
                End If

                'Return Response.StatusCode
            End If
        End If
    End Sub

    Protected Sub RemoveQueryStringParams(rname As String)
        ' reflect to readonly property
        Dim isReadOnly As PropertyInfo = GetType(System.Collections.Specialized.NameValueCollection).GetProperty("IsReadOnly", BindingFlags.Instance Or BindingFlags.NonPublic)
        ' make collection editable
        isReadOnly.SetValue(Me.Request.QueryString, False, Nothing)
        ' remove
        Me.Request.QueryString.Remove(rname)
        ' make collection readonly again
        isReadOnly.SetValue(Me.Request.QueryString, True, Nothing)
    End Sub


    Protected Sub CreateQueryStringParams(pname As String, pvalue As String)
        ' reflect to readonly property
        Dim isReadOnly As PropertyInfo = GetType(System.Collections.Specialized.NameValueCollection).GetProperty("IsReadOnly", BindingFlags.Instance Or BindingFlags.NonPublic)
        ' make collection editable
        isReadOnly.SetValue(Me.Request.QueryString, False, Nothing)
        ' modify
        Me.Request.QueryString.[Set](pname, pvalue)
        ' make collection readonly again
        isReadOnly.SetValue(Me.Request.QueryString, True, Nothing)
    End Sub

    Public Shared Sub Log(logMessage As String, w As TextWriter)

        w.Write(vbCrLf + "Log Entry : ")
        w.WriteLine("{0} {1}", DateTime.Now.ToLongTimeString(),
            DateTime.Now.ToLongDateString())
        w.WriteLine("  :")
        w.WriteLine("  :{0}", logMessage)
        w.WriteLine("-------------------------------")
        w.Flush()
    End Sub

End Class
