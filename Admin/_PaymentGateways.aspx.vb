'========================================================================
'Kartris - www.kartris.com
'Copyright 2017 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisBLL

Partial Class Admin_PaymentGateways

    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Kartris", "ContentText_PaymentShippingGateways") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Page.IsPostBack Then
            RefreshGatewayDisplay()
            Dim objBasket As ArrayList = New ArrayList
        End If
    End Sub

    Protected Sub RefreshGatewayDisplay()
        Dim clsPlugin As Kartris.Interfaces.PaymentGateway
        Dim clsShippingPlugin As Kartris.Interfaces.ShippingGateway
        Dim dtsGateways As DataSet = New DataSet
        Dim tblGateways As DataTable = New DataTable
        Dim colGateway As DataColumn
        Dim strDLLPath As String

        With tblGateways.Columns
            colGateway = New DataColumn("ID", System.Type.GetType("System.Int32"))
            .Add(colGateway)
            colGateway = New DataColumn("Name", System.Type.GetType("System.String"))
            .Add(colGateway)
            colGateway = New DataColumn("DLL", System.Type.GetType("System.String"))
            .Add(colGateway)
            colGateway = New DataColumn("Type", System.Type.GetType("System.String"))
            .Add(colGateway)
            colGateway = New DataColumn("Status", System.Type.GetType("System.String"))
            .Add(colGateway)
        End With

        Dim aryGateways() As String = Split(LoadGateways, ",")

        For Each strGatewayName In aryGateways

            strGatewayName = Left(strGatewayName, InStr(strGatewayName, "::") - 1)
            strDLLPath = Server.MapPath("~/Plugins/" & strGatewayName & "/" & strGatewayName & ".dll")
            'Response.Write(strDLLPath)
            If Not String.IsNullOrEmpty(strGatewayName) Then

                Try
                    clsPlugin = Payment.PPLoader(strGatewayName)
                    If clsPlugin IsNot Nothing Then
                        Dim rowGateway As DataRow = tblGateways.NewRow
                        rowGateway("ID") = 1
                        rowGateway("Name") = clsPlugin.GatewayName
                        rowGateway("DLL") = FileVersionInfo.GetVersionInfo(strDLLPath).FileVersion
                        rowGateway("Type") = GetGlobalResourceObject("_Orders", "ContentText_PaymentGateWay")
                        rowGateway("Status") = UCase(clsPlugin.Status)
                        tblGateways.Rows.Add(rowGateway)
                    Else
                        clsShippingPlugin = Payment.SPLoader(strGatewayName)
                        If clsShippingPlugin IsNot Nothing Then
                            Dim rowGateway As DataRow = tblGateways.NewRow
                            rowGateway("ID") = 1
                            rowGateway("Name") = clsShippingPlugin.GatewayName
                            rowGateway("DLL") = FileVersionInfo.GetVersionInfo(strDLLPath).FileVersion
                            rowGateway("Type") = GetGlobalResourceObject("_Orders", "ContentText_ShippingGateway")
                            rowGateway("Status") = UCase(clsShippingPlugin.Status)
                            tblGateways.Rows.Add(rowGateway)
                        End If
                    End If
                    clsPlugin = Nothing
                    clsShippingPlugin = Nothing
                Catch ex As Exception
                    'Whoops, this means something didn't go right above
                    CkartrisFormatErrors.LogError("Error loading up a payment gateway - " & ex.Message)
                End Try
            End If
        Next

        If UBound(aryGateways) > -1 Then
            rptGateways.DataSource = tblGateways
            rptGateways.DataBind()
        End If
    End Sub

    Function ShowBlank(ByVal strStatus As String) As String
        If strStatus = "OFF" Then
            Return "-"
        Else
            Return strStatus
        End If
    End Function

    Protected Sub btnRefresh_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnRefresh.Click
        RefreshGatewayDisplay()
        CType(Page.Master, Skins_Admin_Template).LoadCategoryMenu()
    End Sub

    Private Function LoadGateways() As String
        Dim strGatewayListConfig As String = ""
        Dim strGatewayListDisplay As String = ""
        Dim files() As String = Directory.GetFiles(Server.MapPath("~/Plugins/"), "*.dll", SearchOption.AllDirectories)
        For Each File As String In files
            If IsValidPaymentGatewayPlugin(File.ToString) And Not InStr(File.ToString, "Kartris.Interfaces.dll") Then
                If Not String.IsNullOrEmpty(strGatewayListDisplay) Then strGatewayListDisplay += ","
                Dim strGatewayName As String = Replace(Mid(File.ToString, File.LastIndexOf("\") + 2), ".dll", "")
                Dim GatewayPlugin As Kartris.Interfaces.PaymentGateway = Payment.PPLoader(strGatewayName)
                If GatewayPlugin.Status.ToLower <> "off" Then
                    If Not String.IsNullOrEmpty(strGatewayListConfig) Then strGatewayListConfig += ","
                    strGatewayListConfig += strGatewayName & "::" & GatewayPlugin.Status.ToLower & "::" & GatewayPlugin.AuthorizedOnly.ToLower & "::" & Payment.isAnonymousCheckoutEnabled(strGatewayName) & "::p"
                End If
                strGatewayListDisplay += strGatewayName & "::" & GatewayPlugin.Status.ToLower & "::" & GatewayPlugin.AuthorizedOnly.ToLower & "::" & Payment.isAnonymousCheckoutEnabled(strGatewayName) & "::p"
                GatewayPlugin = Nothing
            ElseIf IsValidShippingGatewayPlugin(File.ToString) And Not InStr(File.ToString, "Kartris.Interfaces.dll") Then
                If Not String.IsNullOrEmpty(strGatewayListDisplay) Then strGatewayListDisplay += ","
                Dim strGatewayName As String = Replace(Mid(File.ToString, File.LastIndexOf("\") + 2), ".dll", "")
                Dim GatewayPlugin As Kartris.Interfaces.ShippingGateway = Payment.SPLoader(strGatewayName)
                If GatewayPlugin.Status.ToLower <> "off" Then
                    If Not String.IsNullOrEmpty(strGatewayListConfig) Then strGatewayListConfig += ","
                    strGatewayListConfig += strGatewayName & "::" & GatewayPlugin.Status.ToLower & "::n::false::s"
                End If
                strGatewayListDisplay += strGatewayName & "::" & GatewayPlugin.Status.ToLower & "::n::false::s"
                GatewayPlugin = Nothing
            End If
        Next
        KartSettingsManager.SetKartConfig("frontend.payment.gatewayslist", strGatewayListConfig)
        Return strGatewayListDisplay
    End Function

    Private Function IsValidPaymentGatewayPlugin(ByVal GateWayPath As String) As Boolean
        Dim blnResult As Boolean = False
        Try
            Dim strGatewayName As String = Replace(Mid(GateWayPath, GateWayPath.LastIndexOf("\") + 2), ".dll", "")
            Dim GatewayPlugin As Kartris.Interfaces.PaymentGateway = Payment.PPLoader(strGatewayName)
            If GatewayPlugin IsNot Nothing Then
                blnResult = True
            End If
            GatewayPlugin = Nothing
        Catch ex As Exception

        End Try

        Return blnResult
    End Function

    Private Function IsValidShippingGatewayPlugin(ByVal GateWayPath As String) As Boolean
        Dim blnResult As Boolean = False
        Try
            Dim strGatewayName As String = Replace(Mid(GateWayPath, GateWayPath.LastIndexOf("\") + 2), ".dll", "")
            Dim GatewayPlugin As Kartris.Interfaces.ShippingGateway = Payment.SPLoader(strGatewayName)
            If GatewayPlugin IsNot Nothing Then
                blnResult = True
            End If
            GatewayPlugin = Nothing
        Catch ex As Exception

        End Try

        Return blnResult
    End Function
End Class
