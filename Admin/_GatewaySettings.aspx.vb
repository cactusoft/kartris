'========================================================================
'Kartris - www.kartris.com
'Copyright 2015 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisEnumerations
Imports CkartrisImages
Imports CkartrisFormatErrors

Partial Class Admin_GatewaySettings
    Inherits _PageBaseClass

    Private _GatewayName As String = ""

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetGlobalResourceObject("_Kartris", "ContentText_PaymentShippingGateways") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
    End Sub

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init

        If Not String.IsNullOrEmpty(Request.QueryString("g")) Then
            Dim blnIsProtected As Boolean = False
            _GatewayName = Server.HtmlEncode(Request.QueryString("g"))
            If _GatewayName <> "" Then
                Dim objGatewaySettingsSection As ClientSettingsSection = GetGatewaySettings(_GatewayName)
                If objGatewaySettingsSection IsNot Nothing Then

                    
                    For Each txtBox In phdSettings.Controls.OfType(Of TextBox)()
                        phdSettings.Controls.Remove(txtBox)
                    Next
                    For Each lblControl In phdSettings.Controls.OfType(Of Label)()
                        phdSettings.Controls.Remove(lblControl)
                    Next
                    lblGatewayName.Text = _GatewayName
                    blnIsProtected = objGatewaySettingsSection.Settings.Get("IsProtected").Value.ValueXml.InnerText.ToLower = "yes"
                    If blnIsProtected Then chkEncrypt.Checked = True Else chkEncrypt.Checked = False

                    'Generate a friendly name textbox for each live language in the backend - LANG_LiveBack
                    Dim dtbLanguages As DataTable = LanguagesBLL.GetLanguages
                    For Each drwLanguage As DataRow In dtbLanguages.Rows
                        If drwLanguage("LANG_LiveBack") = True Then
                            Dim strSettingName As String = "FriendlyName(" & CkartrisDataManipulation.FixNullFromDB(drwLanguage("LANG_Culture")) & ")"
                            'Start of line
                            Dim litLineStart As New Literal
                            litLineStart.Text = "<li><span class=""Kartris-DetailsView-Name"">"
                            phdSettings.Controls.Add(litLineStart)

                            'Add the label control
                            Dim lblSetting As Label = New Label()
                            lblSetting.Text = strSettingName
                            lblSetting.ID = "lbl" & _GatewayName & strSettingName
                            phdSettings.Controls.Add(lblSetting)

                            'Middle of line
                            Dim litLineMiddle As New Literal
                            litLineMiddle.Text = "</span><span class=""Kartris-DetailsView-Value"">"
                            phdSettings.Controls.Add(litLineMiddle)

                            Dim txtSetting As TextBox = New TextBox()
                            txtSetting.ID = "txt" & _GatewayName & strSettingName
                            phdSettings.Controls.Add(txtSetting)

                            'End of line
                            Dim litLineEnd As New Literal
                            litLineEnd.Text = "</span></li>"
                            phdSettings.Controls.Add(litLineEnd)

                        End If
                    Next

                    Dim blnAnonymousCheckout As Boolean = False

                    For Each keySettingElement As SettingElement In objGatewaySettingsSection.Settings
                        If keySettingElement.Name.ToLower <> "isprotected" Then
                            If Not InStr(UCase(keySettingElement.Name), "FRIENDLYNAME(") > 0 AndAlso (keySettingElement.Name.ToLower <> "anonymouscheckout") Then
                                'Start of line
                                Dim litLineStart As New Literal
                                litLineStart.Text = "<li><span class=""Kartris-DetailsView-Name"">"
                                phdSettings.Controls.Add(litLineStart)

                                'Add the label control
                                Dim lblSetting As Label = New Label()
                                lblSetting.Text = keySettingElement.Name
                                lblSetting.ID = "lbl" & _GatewayName & keySettingElement.Name
                                phdSettings.Controls.Add(lblSetting)

                                'Middle of line
                                Dim litLineMiddle As New Literal
                                litLineMiddle.Text = "</span><span class=""Kartris-DetailsView-Value"">"
                                phdSettings.Controls.Add(litLineMiddle)

                                'Add form input control (text, checkbox, etc)
                                Select Case UCase(keySettingElement.Name)
                                    Case "STATUS"
                                        Dim ddlStatus As DropDownList = New DropDownList
                                        ddlStatus.ID = "ddlStatus"
                                        ddlStatus.Items.Add("ON")
                                        ddlStatus.Items.Add("OFF")
                                        ddlStatus.Items.Add("TEST")
                                        ddlStatus.Items.Add("FAKE")
                                        ddlStatus.SelectedValue = UCase(GetConfigValue(keySettingElement, blnIsProtected))
                                        phdSettings.Controls.Add(ddlStatus)
                                    Case "AUTHORIZEDONLY"
                                        Dim chkAuthorizedOnly As CheckBox = New CheckBox
                                        chkAuthorizedOnly.ID = "chkAuthorizedOnly"
                                        chkAuthorizedOnly.CssClass = "checkbox"
                                        If UCase(GetConfigValue(keySettingElement, blnIsProtected)) = "TRUE" Then
                                            chkAuthorizedOnly.Checked = True
                                        Else
                                            chkAuthorizedOnly.Checked = False
                                        End If
                                        phdSettings.Controls.Add(chkAuthorizedOnly)
                                    Case Else
                                        Dim txtSetting As TextBox = New TextBox()
                                        If Not IsPostBack Then txtSetting.Text = GetConfigValue(keySettingElement, blnIsProtected)
                                        txtSetting.ID = "txt" & _GatewayName & keySettingElement.Name
                                        phdSettings.Controls.Add(txtSetting)
                                End Select

                                'End of line
                                Dim litLineEnd As New Literal
                                litLineEnd.Text = "</span></li>"
                                phdSettings.Controls.Add(litLineEnd)
                            Else
                                If keySettingElement.Name.ToLower <> "anonymouscheckout" Then
                                    'Populate the friendly name textboxes
                                    Dim txtSetting As TextBox = DirectCast(FindControlRecursive(phdSettings, "txt" & _GatewayName & keySettingElement.Name), TextBox)
                                    If txtSetting IsNot Nothing And Not IsPostBack Then
                                        txtSetting.Text = GetConfigValue(keySettingElement, False)
                                    End If
                                Else
                                    If UCase(GetConfigValue(keySettingElement, blnIsProtected)) = "TRUE" Then
                                        blnAnonymousCheckout = True
                                    Else
                                        blnAnonymousCheckout = False
                                    End If
                                End If

                            End If
                        End If
                    Next

                    'Start of line
                    Dim litAnoLineStart As New Literal
                    litAnoLineStart.Text = "<li><span class=""Kartris-DetailsView-Name"">"
                    phdSettings.Controls.Add(litAnoLineStart)

                    'Add the label control
                    Dim lblAnoSetting As Label = New Label()
                    lblAnoSetting.Text = "AnonymousCheckout"
                    lblAnoSetting.ID = "lbl" & _GatewayName & "AnonymousCheckout"
                    phdSettings.Controls.Add(lblAnoSetting)

                    'Middle of line
                    Dim litAnoLineMiddle As New Literal
                    litAnoLineMiddle.Text = "</span><span class=""Kartris-DetailsView-Value"">"
                    phdSettings.Controls.Add(litAnoLineMiddle)

                    Dim chkAnonymousCheckout As CheckBox = New CheckBox
                    chkAnonymousCheckout.ID = "chkAnonymousCheckout"
                    chkAnonymousCheckout.CssClass = "checkbox"
                    If blnAnonymousCheckout Then
                        chkAnonymousCheckout.Checked = True
                    Else
                        chkAnonymousCheckout.Checked = False
                    End If
                    phdSettings.Controls.Add(chkAnonymousCheckout)

                    'End of line
                    Dim litAnoLineEnd As New Literal
                    litAnoLineEnd.Text = "</span></li>"
                    phdSettings.Controls.Add(litAnoLineEnd)
                    

                    btnUpdate.Visible = True
                    chkEncrypt.Visible = True

                    btnUpdate.CommandArgument = _GatewayName
                End If
            End If
        End If
    End Sub

    Private Function GetConfigValue(ByVal elemSetting As SettingElement, ByVal isProtected As Boolean) As String
        Dim strSettingValue As String = Interfaces.Utils.TrimWhiteSpace(elemSetting.Value.ValueXml.InnerText)
        If isProtected Then
            Return Interfaces.Utils.Crypt(strSettingValue, ConfigurationManager.AppSettings("HashSalt").ToString, _
                                   Interfaces.Utils.CryptType.Decrypt)
        Else
            Return strSettingValue
        End If
    End Function

    Private Function SetConfigValue(ByVal strValue As String, ByVal blnProtectSetting As Boolean) As String
        If blnProtectSetting Then
            Return Interfaces.Utils.Crypt(strValue, ConfigurationManager.AppSettings("HashSalt").ToString, _
                                   Interfaces.Utils.CryptType.Encrypt)
        Else
            Return strValue
        End If
    End Function

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdate.Click
        Dim strGatewayName As String = btnUpdate.CommandArgument
        Dim configFileMap As New ExeConfigurationFileMap()

        configFileMap.ExeConfigFilename = Path.Combine(Request.PhysicalApplicationPath, "Plugins\" & strGatewayName & "\" & strGatewayName & ".dll.config")
        configFileMap.MachineConfigFilename = Path.Combine(Request.PhysicalApplicationPath, "Uploads\resources\Machine.Config")

        Dim objConfiguration As Configuration = ConfigurationManager.OpenMappedExeConfiguration(configFileMap, ConfigurationUserLevel.None)
        Dim grpSection As ConfigurationSectionGroup = objConfiguration.GetSectionGroup("applicationSettings")
        Dim objGatewaySettingsSection As ClientSettingsSection = DirectCast(grpSection.Sections.Item("Kartris.My.MySettings"), ClientSettingsSection)

        If objGatewaySettingsSection IsNot Nothing Then
            Dim blnFound As Boolean = False

            For Each keySettingElement As SettingElement In objGatewaySettingsSection.Settings
                Select Case UCase(keySettingElement.Name)
                    Case "STATUS"
                        Dim ddlStatus As DropDownList = DirectCast(FindControlRecursive(phdSettings, "ddlStatus"), DropDownList)
                        If ddlStatus IsNot Nothing Then
                            keySettingElement.Value.ValueXml.InnerText = SetConfigValue(ddlStatus.SelectedValue, chkEncrypt.Checked)
                            blnFound = True
                        End If
                    Case "AUTHORIZEDONLY"
                        Dim chkAuthorizedOnly As CheckBox = DirectCast(FindControlRecursive(phdSettings, "chkAuthorizedOnly"), CheckBox)
                        If chkAuthorizedOnly IsNot Nothing Then
                            keySettingElement.Value.ValueXml.InnerText = SetConfigValue(UCase(chkAuthorizedOnly.Checked.ToString), chkEncrypt.Checked)
                            blnFound = True
                        End If
                    Case "ISPROTECTED"
                        If chkEncrypt.Checked Then
                            keySettingElement.Value.ValueXml.InnerText = "Yes"
                        Else
                            keySettingElement.Value.ValueXml.InnerText = "No"
                        End If
                    Case Else
                        If Not InStr(UCase(keySettingElement.Name), "FriendlyName") > 0 Then
                            Dim txtSetting As TextBox = DirectCast(FindControlRecursive(phdSettings, "txt" & strGatewayName & keySettingElement.Name), TextBox)
                            If txtSetting IsNot Nothing Then
                                keySettingElement.Value.ValueXml.InnerText = SetConfigValue(txtSetting.Text, chkEncrypt.Checked)
                                blnFound = True
                            End If
                        End If
                End Select
            Next
            If blnFound Then
                'Process all Friendly Name textboxes
                For Each txtBox In phdSettings.Controls.OfType(Of TextBox)()
                    Dim intNamePos As Integer = InStr(UCase(txtBox.ID), "FRIENDLYNAME(")
                    If intNamePos > 0 Then
                        Dim strSettingElementName As String = Mid(txtBox.ID, intNamePos)
                        Dim blnSettingElementExists As Boolean = False
                        For Each keySettingElement As SettingElement In objGatewaySettingsSection.Settings
                            If UCase(keySettingElement.Name) = UCase(strSettingElementName) Then
                                keySettingElement.Value.ValueXml.InnerText = txtBox.Text
                                blnSettingElementExists = True
                            End If
                        Next
                        'Friendly Name doesn't exist in the config file yet - add it
                        If Not blnSettingElementExists Then
                            Dim docFriendlyName As New XmlDocument()
                            Dim seFriendlyName As New SettingElement(strSettingElementName, SettingsSerializeAs.String)
                            Dim veFriendlyName As New SettingValueElement()
                            Dim nodeFriendlyName As XmlNode = docFriendlyName.CreateNode(XmlNodeType.Element, "value", "")
                            nodeFriendlyName.InnerText = txtBox.Text
                            veFriendlyName.ValueXml = nodeFriendlyName
                            seFriendlyName.Value = veFriendlyName
                            objGatewaySettingsSection.Settings.Add(seFriendlyName)
                        End If
                        
                    End If
                Next

                'check if anonymous checkout is already present in config file
                Dim chkAnonymousCheckout As CheckBox = DirectCast(FindControlRecursive(phdSettings, "chkAnonymousCheckout"), CheckBox)
                Dim strAnonymousCheckoutValue As String = SetConfigValue(UCase(chkAnonymousCheckout.Checked.ToString), chkEncrypt.Checked)
                Dim blnAnonymousCheckoutExists As Boolean = False
                For Each keySettingElement As SettingElement In objGatewaySettingsSection.Settings
                    If UCase(keySettingElement.Name) = UCase("ANONYMOUSCHECKOUT") Then
                        keySettingElement.Value.ValueXml.InnerText = strAnonymousCheckoutValue
                        blnAnonymousCheckoutExists = True
                    End If
                Next

                If Not blnAnonymousCheckoutExists Then
                    Dim docFriendlyName As New XmlDocument()
                    Dim seFriendlyName As New SettingElement("AnonymousCheckout", SettingsSerializeAs.String)
                    Dim veFriendlyName As New SettingValueElement()
                    Dim nodeFriendlyName As XmlNode = docFriendlyName.CreateNode(XmlNodeType.Element, "value", "")
                    nodeFriendlyName.InnerText = strAnonymousCheckoutValue
                    veFriendlyName.ValueXml = nodeFriendlyName
                    seFriendlyName.Value = veFriendlyName
                    objGatewaySettingsSection.Settings.Add(seFriendlyName)
                End If

                objGatewaySettingsSection.SectionInformation.ForceSave = True

                Try
                    'Clean up the temporary folder first in case something went wrong in the last gateway setting update
                    For Each TempSettingFile As String In Directory.GetFiles(Path.Combine(Request.PhysicalApplicationPath, "Uploads\"), "*.dll.config")
                        File.Delete(TempSettingFile)
                    Next

                    Dim strTempPath As String = Path.Combine(Request.PhysicalApplicationPath, "Uploads\" & strGatewayName & ".dll.config")
                    Dim strConfigFilePath As String = objConfiguration.FilePath
                    objConfiguration.SaveAs(strTempPath, ConfigurationSaveMode.Modified)
                    objConfiguration = Nothing

                    'Reload saved config file, remove whitespace from empty settings, delete file and save again
                    Dim xmlDoc As XmlDocument = New XmlDocument
                    xmlDoc.PreserveWhitespace = True
                    xmlDoc.Load(strTempPath)
                    Dim StringWriter As StringWriter = New StringWriter
                    Dim XmlTextWriter As XmlTextWriter = New XmlTextWriter(StringWriter)
                    xmlDoc.WriteTo(XmlTextWriter)
                    Dim regex As New Regex("<value>\s*</value>")
                    Dim cleanedXml As String = regex.Replace(StringWriter.ToString, "<value></value>")
                    xmlDoc = Nothing
                    File.Delete(strTempPath)
                    Dim objStreamWriter As StreamWriter
                    objStreamWriter = File.AppendText(strTempPath)
                    objStreamWriter.Write(cleanedXml)
                    objStreamWriter.Close()

                    'replace the config file in the gateway folder with the updated one in the uploads folder
                    File.Delete(strConfigFilePath)
                    File.Copy(strTempPath, strConfigFilePath)
                    'clean up - remove the temp config file from the uploads folder
                    File.Delete(strTempPath)

                    'refresh the payment gateways settings cache
                    Dim clsPlugin As Kartris.Interfaces.PaymentGateway = Nothing
                    Try
                        clsPlugin = Payment.PPLoader(strGatewayName)
                        clsPlugin.RefreshSettingsCache()

                    Catch ex As Exception

                    End Try

                    'refresh the shipping gateways settings cache
                    If clsPlugin Is Nothing Then
                        Try
                            Dim clsShippingPlugin As Kartris.Interfaces.ShippingGateway
                            clsShippingPlugin = Payment.SPLoader(strGatewayName)
                            clsShippingPlugin.RefreshSettingsCache()
                        Catch ex As Exception

                        End Try
                    End If
                    clsPlugin = Nothing

                    'update the gatewayslist config setting
                    Dim strGatewayListConfig As String = ""
                    Dim strGatewayListDisplay As String = ""
                    Dim files() As String = Directory.GetFiles(Server.MapPath("~/Plugins/"), "*.dll", SearchOption.AllDirectories)
                    For Each File As String In files
                        If IsValidGatewayPlugin(File.ToString) And Not InStr(File.ToString, "Kartris.Interfaces.dll") Then
                            If Not String.IsNullOrEmpty(strGatewayListDisplay) Then strGatewayListDisplay += ","
                            Dim strPaymentGatewayName As String = Replace(Mid(File.ToString, File.LastIndexOf("\") + 2), ".dll", "")
                            Dim GatewayPlugin As Kartris.Interfaces.PaymentGateway = Payment.PPLoader(strPaymentGatewayName)
                            If GatewayPlugin.Status.ToLower <> "off" Then
                                If Not String.IsNullOrEmpty(strGatewayListConfig) Then strGatewayListConfig += ","
                                strGatewayListConfig += strPaymentGatewayName & "::" & GatewayPlugin.Status.ToLower & "::" & GatewayPlugin.AuthorizedOnly.ToLower & "::" & Payment.isAnonymousCheckoutEnabled(strPaymentGatewayName) & "::p"
                            End If
                            strGatewayListDisplay += strPaymentGatewayName & "::" & GatewayPlugin.Status.ToLower & "::" & GatewayPlugin.AuthorizedOnly.ToLower & "::" & Payment.isAnonymousCheckoutEnabled(strPaymentGatewayName) & "::p"
                            GatewayPlugin = Nothing
                        ElseIf IsValidShippingGatewayPlugin(File.ToString) And Not InStr(File.ToString, "Kartris.Interfaces.dll") Then
                            If Not String.IsNullOrEmpty(strGatewayListDisplay) Then strGatewayListDisplay += ","
                            Dim strShippingGatewayName As String = Replace(Mid(File.ToString, File.LastIndexOf("\") + 2), ".dll", "")
                            Dim GatewayPlugin As Kartris.Interfaces.ShippingGateway = Payment.SPLoader(strShippingGatewayName)
                            If GatewayPlugin.Status.ToLower <> "off" Then
                                If Not String.IsNullOrEmpty(strGatewayListConfig) Then strGatewayListConfig += ","
                                strGatewayListConfig += strShippingGatewayName & "::" & GatewayPlugin.Status.ToLower & "::n::false::s"
                            End If
                            strGatewayListDisplay += strShippingGatewayName & "::" & GatewayPlugin.Status.ToLower & "::n::false::s"
                            GatewayPlugin = Nothing
                        End If
                    Next
                    KartSettingsManager.SetKartConfig("frontend.payment.gatewayslist", strGatewayListConfig)

                    CType(Me.Master, Skins_Admin_Template).DataUpdated()
                Catch ex As Exception
                    'Probably permissions error trying to save config
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgGeneral"))
                    'Throw New Exception("Error saving a payment gateway config file, most likely due to permissions.")
                    ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())

                End Try

            End If
        End If
    End Sub
    ''' <summary>
    ''' this function retrieves the config file for specific gateway
    ''' </summary>
    ''' <param name="GatewayName"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function GetGatewaySettings(ByVal GatewayName As String) As ClientSettingsSection
        On Error Resume Next
        Dim configFileMap As New ExeConfigurationFileMap()
        configFileMap.ExeConfigFilename = Path.Combine(Request.PhysicalApplicationPath, "Plugins\" & GatewayName & "\" & GatewayName & ".dll.config")
        configFileMap.MachineConfigFilename = Path.Combine(Request.PhysicalApplicationPath, "Uploads\resources\Machine.Config")
        Dim objConfiguration As Configuration = ConfigurationManager.OpenMappedExeConfiguration(configFileMap, ConfigurationUserLevel.None)
        Dim grpSection As ConfigurationSectionGroup = objConfiguration.GetSectionGroup("applicationSettings")
        Dim appSettingsSection As ClientSettingsSection = DirectCast(grpSection.Sections.Item("Kartris.My.MySettings"), ClientSettingsSection)
        On Error GoTo 0
        If appSettingsSection IsNot Nothing Then
            Return appSettingsSection
        Else
            Return Nothing
        End If
    End Function
    ''' <summary>
    ''' ''' check if the dll being loaded is a valid payment gateway plugin
    ''' </summary>
    ''' <param name="GateWayPath"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function IsValidGatewayPlugin(ByVal GateWayPath As String) As Boolean
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
    ''' <summary>
    ''' check if the dll being loaded is a valid shipping gateway plugin
    ''' </summary>
    ''' <param name="GateWayPath"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
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