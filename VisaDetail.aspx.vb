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
Imports System.Reflection
Imports CkartrisBLL
Imports CkartrisDataManipulation
Imports KartSettingsManager
Imports Kartris.Interfaces.Utils

Partial Class Callback
    Inherits PageBaseClass
    Dim strEntity As String = ""
    Dim strRef As String = ""
    Dim strAmount As String = ""

    Private clsPlugin As Kartris.Interfaces.PaymentGateway

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Dim strEntity As String = ""
            Dim strRef As String = ""
            Dim strAmount As String = ""
            Dim strGateway As String = ""
            Dim strAction As String = ""
            Dim strGatewayName As String = ""
            'Callback Step 0 - normal callback
            'Callback Step 1 - update order but don't display full HTML if d=off QS is passed, write gateway dll output to screen
            'Callback Step 2 - don't update order, just display result as usual
            Dim intCallbackStep As Integer
            Try
                intCallbackStep = CInt(Request.QueryString("step"))
            Catch ex As Exception
                intCallbackStep = 0
            End Try
            Dim blnFullDisplay As Boolean = True
            If Request.QueryString("d") = "off" Then blnFullDisplay = False
            Try
                strGateway = Request.QueryString("g").ToLower
                strAction = Request.QueryString("a").ToLower
            Catch ex As Exception
            End Try

            If strGateway = "easypay" Then
                If strAction = "mbrefer" Then
                    Dim EasypayPayment = Session("EasypayPayment")
                    Dim sdCallbackFields As System.Collections.Specialized.StringDictionary = ConvertCallbackDataStr2Dict(EasypayPayment)
                    With sdCallbackFields
                        strEntity = .Item("npcentity")
                        valEntity.Text = strEntity
                        strRef = .Item("payment_cluster_key")
                        valRef.Text = addBlanks(strRef, 3)
                        strAmount = .Item("npcamount")
                        valAmount.Text = strAmount & " €"
                    End With
                End If
            End If

        End If
    End Sub

    Private Function addBlanks(str As String, eachChar As Integer) As String
        Dim strResult As String = ""
        Dim lastValue As Integer = 0
        For value As Integer = 0 To str.Length
            If value > 0 And value Mod eachChar = 0 Then
                strResult += str.Substring(lastValue, eachChar) & " "
                lastValue = value
            ElseIf value = str.Length Then  ' Add the Last Part
                strResult += str.Substring(lastValue)
            End If
        Next
        Return strResult
    End Function


End Class
