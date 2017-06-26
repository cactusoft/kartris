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
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports MailChimp.Net.Models
Imports MailChimp.Net.Core

Partial Class _ConfigSetting
    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'Reset messages to blank
        phdMessageError.Visible = False
        lstRadioButtons.Visible = False

        If Not Page.IsPostBack Then

            'Set the text of the 'details' link
            lnkDetails.Text = "[+] <span class=""bold"">" & GetGlobalResourceObject("_Kartris", "ContentText_Details") & "</span>"

            CreateMenu()

            'Set number of records per page
            Dim intRowsPerPage As Integer = 25
            Try
                intRowsPerPage = CInt(KartSettingsManager.GetKartConfig("backend.display.pagesize"))
            Catch ex As Exception
                'Stays at 25
            End Try
            gvwConfig.PageSize = intRowsPerPage

            'Not in expert mode
            'Disable 'new' config setting link
            If KartSettingsManager.GetKartConfig("backend.expertmode") <> "y" Then
                btnNew.Visible = False
            End If
            If Request.QueryString("name") IsNot Nothing Then
                txtSearchStarting.Text = Request.QueryString("name")
                SearchConfig(txtSearchStarting.Text)
            End If
        End If
    End Sub

    Sub CreateMenu()
        If HttpRuntime.Cache("KartSettingsCache") IsNot Nothing Then
            menConfig.Items.Clear()
            Dim tblWebSettings As DataTable = CType(HttpRuntime.Cache("KartSettingsCache"), DataTable)
            For Each drwWebSetting As DataRow In tblWebSettings.Rows

                Dim arrConfig As Array = Split(drwWebSetting(0).ToString, ".")

                For numCounter As Integer = 0 To UBound(arrConfig)
                    If LCase(arrConfig(0)) = "hidden" Then Exit For
                    Dim strConfigTrail As String = ""
                    Dim strConfigName As String = arrConfig(numCounter)
                    Dim strConfigValue As String = drwWebSetting(1).ToString
                    Dim itmParent As MenuItem = Nothing

                    For i As Integer = 0 To numCounter
                        If i > 0 Then strConfigTrail += "."
                        strConfigTrail += arrConfig(i)
                    Next
                    Dim strParentTrail As String = ""
                    If numCounter = 0 Then strParentTrail = strConfigName Else strParentTrail = Left(strConfigTrail, InStrRev(strConfigTrail, ".") - 1)


                    Dim itmConfigMenu As New MenuItem
                    itmConfigMenu.Text = strConfigName
                    itmConfigMenu.Value = strConfigTrail
                    If LCase(strConfigValue) = "y" Then strConfigValue = "yes"
                    If LCase(strConfigValue) = "n" Then strConfigValue = "no"
                    itmConfigMenu.ToolTip = strConfigTrail & " : " & strConfigValue
                    itmConfigMenu.NavigateUrl = CkartrisBLL.WebShopURL & "Admin/_Config.aspx?name=" & strConfigTrail
                    itmConfigMenu.Selectable = (numCounter = UBound(arrConfig) Or numCounter = UBound(arrConfig) - 1)


                    For Each itmConfig As MenuItem In menConfig.Items
                        If itmConfig.Value = strParentTrail Then
                            itmParent = itmConfig
                            Exit For
                        Else
                            Dim itmFind As MenuItem = FindSubMenuItem(itmConfig, strParentTrail)
                            If itmFind IsNot Nothing Then
                                itmParent = itmFind
                                Exit For
                            End If
                        End If
                    Next
                    If itmParent Is Nothing Then
                        menConfig.Items.Add(itmConfigMenu)
                    Else
                        If FindSubMenuItem(itmParent, strConfigTrail) Is Nothing And numCounter > 0 Then itmParent.ChildItems.Add(itmConfigMenu)
                    End If
                Next
            Next
        End If

    End Sub

    ''' <summary>
    ''' recursively find a menuitem
    ''' </summary>
    ''' <param name="itmMenu"></param>
    ''' <param name="strValue"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function FindSubMenuItem(ByVal itmMenu As MenuItem, ByVal strValue As String) As MenuItem
        Dim itmReturn As MenuItem = Nothing
        If (itmMenu.ChildItems.Count <> 1 And itmMenu.Parent IsNot Nothing) Then itmMenu.Selectable = True Else itmMenu.Selectable = False
        If itmMenu.ChildItems.Count > 0 Then itmMenu.ToolTip = ""
        For Each itmChild As MenuItem In itmMenu.ChildItems
            If itmChild.Value = strValue Then Return itmChild
            itmReturn = FindSubMenuItem(itmChild, strValue)
        Next
        Return itmReturn
    End Function

    Protected Sub lnkCreateStore_Click() Handles lnkCreateStore.Click
        Dim manager As MailChimpBLL = New MailChimpBLL()
        Try
            Dim storeEmail As String = If((txtStoreEmail.Text.Equals("")), Nothing, txtStoreEmail.Text)
            Dim storeDomain As String = If((txtStoreDomain.Text.Equals("")), Nothing, txtStoreDomain.Text)
            Dim storeName As String = If((txtStoreName.Text.Equals("")), Nothing, txtStoreName.Text)
            Dim store As Store = manager.AddStore(txtCFG_Value.Text, storeName, storeDomain, storeEmail).Result()
        Catch ex As Exception
            If ex.InnerException IsNot Nothing Then
                Dim exceptionType As Type = ex.InnerException.GetType()
                If exceptionType.Name.Equals("MailChimpException") Then
                    Dim mcException As MailChimpException = DirectCast(ex.InnerException, MailChimpException)
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, mcException.Detail)
                End If
            End If

        End Try
    End Sub

    Protected Sub lnkBtnBack_Click() Handles lnkBtnBack.Click
        ClearTextControls()
        mvwConfig.SetActiveView(viwResult)
    End Sub

    Protected Sub btnFind_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnFind.Click
        gvwConfig.PageIndex = 0
        SearchConfig(txtSearchStarting.Text)
    End Sub

    Protected Sub btnClear_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnClear.Click
        txtSearchStarting.Text = String.Empty
        SearchConfig(txtSearchStarting.Text)
    End Sub


    Protected Sub btnNew_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnNew.Click
        PrepareNewEntry()
    End Sub

    Private Sub SearchConfig(ByVal pstrText As String, Optional ByVal pIndx As Integer = 0, Optional ByVal pPageIndx As Integer = 0)

        Dim tblConfig As New DataTable

        If ddlConfigFilter.SelectedValue = "i" Then
            tblConfig = ConfigBLL._SearchConfig(pstrText, True)
        Else
            tblConfig = ConfigBLL._SearchConfig(pstrText, False)
        End If

        If tblConfig.Rows.Count = 0 Then
            'No results
            mvwConfig.SetActiveView(viwNoResult)
        ElseIf tblConfig.Rows.Count = 1 Then
            'One result, try to select it
            gvwConfig.DataSource = tblConfig
            gvwConfig.DataBind()
            gvwConfig.SelectedIndex = pIndx

            PrepareEditEntry()
            mvwConfig.SetActiveView(viwEdit)
        Else
            'If search blank, show config selection menu instead
            'of search results
            If pstrText = "" Then
                'Blank search, show menu
                mvwConfig.SetActiveView(viwMenu)
            Else
                'Searched for something,
                'show results
                gvwConfig.DataSource = tblConfig
                gvwConfig.DataBind()
                gvwConfig.SelectedIndex = pIndx

                mvwConfig.SetActiveView(viwResult)
            End If

        End If
    End Sub

    Protected Sub lstRadioButtons_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles lstRadioButtons.SelectedIndexChanged
        litConfigName.Text = lstRadioButtons.SelectedValue
        txtSearchStarting.Focus()
    End Sub

    Protected Sub gvwConfig_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwConfig.PageIndexChanging
        gvwConfig.PageIndex = e.NewPageIndex
        SearchConfig(litConfigName.Text & txtSearchStarting.Text)
    End Sub

    Protected Sub gvwConfig_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvwConfig.SelectedIndexChanged
        If gvwConfig.SelectedIndex = -1 Then Return
        PrepareEditEntry()
        mvwConfig.SetActiveView(viwEdit)
    End Sub

    Private Sub PrepareNewEntry()
        gvwConfig.SelectedIndex = -1

        ddlCFG_DataType.Items.Clear()
        ddlCFG_DataType.Items.Add(New ListItem("-", "-"))
        ddlCFG_DataType.Items.Add(New ListItem("string", "s"))
        ddlCFG_DataType.Items.Add(New ListItem("numeric", "n"))

        ddlCFG_DisplayType.Items.Clear()
        ddlCFG_DisplayType.Items.Add(New ListItem("-", "-"))
        ddlCFG_DisplayType.Items.Add(New ListItem("string", "s"))
        ddlCFG_DisplayType.Items.Add(New ListItem("numeric", "n"))
        ddlCFG_DisplayType.Items.Add(New ListItem("text", "t"))
        ddlCFG_DisplayType.Items.Add(New ListItem("boolean", "b"))
        ddlCFG_DisplayType.Items.Add(New ListItem("list", "l"))

        ClearTextControls()

        'Prepare value dropdown if required
        Dim blnShowValuesInDropDownList = BuildDisplayInfoDropDownList(txtCFG_DisplayInfo.Text, txtCFG_Value.Text)

        litPleaseEnterValue.Visible = False
        phdNameAlreadyExist.Visible = False
        phdCheckChange.Visible = True

        txtCFG_Name.Visible = True : valRequiredName.Enabled = True
        litCFG_Name.Visible = False

        LockControls()

        mvwConfig.SetActiveView(viwEdit)

        txtCFG_Name.Focus()
    End Sub

    Private Sub PrepareEditEntry()

        ddlCFG_DataType.Items.Clear()
        ddlCFG_DataType.Items.Add(New ListItem("string", "s"))
        ddlCFG_DataType.Items.Add(New ListItem("numeric", "n"))

        ddlCFG_DisplayType.Items.Clear()
        ddlCFG_DisplayType.Items.Add(New ListItem("string", "s"))
        ddlCFG_DisplayType.Items.Add(New ListItem("numeric", "n"))
        ddlCFG_DisplayType.Items.Add(New ListItem("text", "t"))
        ddlCFG_DisplayType.Items.Add(New ListItem("boolean", "b"))
        ddlCFG_DisplayType.Items.Add(New ListItem("list", "l"))

        ClearTextControls()

        Dim drConfig As DataRow = ConfigBLL._GetConfigByName(gvwConfig.SelectedRow.Cells(0).Text).Rows(0)
        litCFG_Name.Text = FixNullFromDB(drConfig("CFG_Name"))
        txtCFG_Value.Text = FixNullFromDB(drConfig("CFG_Value"))
        ddlCFG_DataType.SelectedValue = FixNullFromDB(drConfig("CFG_DataType"))
        ddlCFG_DisplayType.SelectedValue = FixNullFromDB(drConfig("CFG_DisplayType"))
        txtCFG_DefaultValue.Text = FixNullFromDB(drConfig("CFG_DefaultValue"))
        txtCFG_Desc.Text = FixNullFromDB(drConfig("CFG_Description"))
        txtCFG_DisplayInfo.Text = FixNullFromDB(drConfig("CFG_DisplayInfo"))
        txtCFG_VersionAdded.Text = FixNullFromDB(drConfig("CFG_VersionAdded"))
        chkCFG_Important.Checked = FixNullFromDB(drConfig("CFG_Important"))

        ' Fill Up MailChimp Extra Fields
        If litCFG_Name.Text.Equals("general.mailchimp.storeid") Then
            If Not txtCFG_Value.Text.Equals("") Then
                Dim manager As MailChimpBLL = New MailChimpBLL()
                Dim store As Store = manager.manager.ECommerceStores.GetAsync(txtCFG_Value.Text).Result
                If store IsNot Nothing Then
                    txtStoreName.Text = store.Name
                    txtStoreDomain.Text = store.Domain
                    txtStoreEmail.Text = store.EmailAddress
                End If
            End If
        End If

        'Prepare value dropdown if required
        Dim blnShowValuesInDropDownList = BuildDisplayInfoDropDownList(txtCFG_DisplayInfo.Text, txtCFG_Value.Text)

        phdNameAlreadyExist.Visible = False
        litPleaseEnterValue.Visible = False
        phdCheckChange.Visible = False

        txtCFG_Name.Visible = False : valRequiredName.Enabled = False
        litCFG_Name.Visible = True

        ddlCFG_DataType.Enabled = SetExpertSetting()
        ddlCFG_DisplayType.Enabled = SetExpertSetting()
        txtCFG_DisplayInfo.Enabled = SetExpertSetting()
        txtCFG_DefaultValue.Enabled = SetExpertSetting()
        txtCFG_Desc.Enabled = SetExpertSetting()
        txtCFG_VersionAdded.Enabled = SetExpertSetting()
        chkCFG_Important.Enabled = SetExpertSetting()

    End Sub

    Function BuildDisplayInfoDropDownList(ByVal strDisplayInfo As String, ByVal strCFG_Value As String) As Boolean
        ddlCFG_Value.Items.Clear()
        If strDisplayInfo.Contains("|") Then
            'We have a list of options
            'First step is to build array from the list
            Dim aryOptions = Split(strDisplayInfo, "|", -1)
            For numCounter = 0 To UBound(aryOptions)
                ddlCFG_Value.Items.Add(New ListItem(aryOptions(numCounter), aryOptions(numCounter)))

            Next
            'Try to set the dropdown to a value if
            'config value matches one item in the menu
            Try
                ddlCFG_Value.SelectedValue = strCFG_Value
            Catch ex As Exception
                'Just fail softly
            End Try

            'Hide text field, show dropdown
            txtCFG_Value.Visible = False
            ddlCFG_Value.Visible = True

            Return True
        Else
            'Hide dropdown, show text field
            txtCFG_Value.Visible = True
            ddlCFG_Value.Visible = False
            Return False
        End If
    End Function

    Private Sub ClearTextControls()
        txtCFG_Name.Text = String.Empty
        txtCFG_Value.Text = String.Empty
        txtCFG_DefaultValue.Text = String.Empty
        txtCFG_Desc.Text = String.Empty
        txtCFG_DisplayInfo.Text = String.Empty
        txtCFG_VersionAdded.Text = KARTRIS_VERSION
        chkCFG_Important.Checked = False
    End Sub

    Private Sub SaveChanges(ByVal enumOperation As DML_OPERATION)
        Dim chrDataType As Char = "", chrDisplayType As Char = ""
        Dim strConfigName As String = "", strValue As String = "", strValueDropdown As String = "", strDesc As String = "", strDefaultValue As String = "", strDisplayInfo As String = ""
        Dim sngVersionAdded As Single = 0.0F
        Dim blnImportant As Boolean
        Dim strMessage As String = ""

        strConfigName = txtCFG_Name.Text

        'We collect values from both the value text field
        'and the dropdown
        strValue = txtCFG_Value.Text
        strValueDropdown = ddlCFG_Value.Text

        'If a value is selected from the dropdown, we use
        'this as the value, otherwise we stick to the text
        'field value
        If strValueDropdown <> "" Then strValue = strValueDropdown

        chrDataType = ddlCFG_DataType.SelectedValue
        chrDisplayType = ddlCFG_DisplayType.SelectedValue
        strDefaultValue = txtCFG_DefaultValue.Text
        strDesc = txtCFG_Desc.Text
        strDisplayInfo = txtCFG_DisplayInfo.Text
        sngVersionAdded = CSng(txtCFG_VersionAdded.Text)
        blnImportant = chkCFG_Important.Checked

        Select Case enumOperation
            Case DML_OPERATION.INSERT
                If ConfigBLL._AddConfig( _
                                strConfigName, strValue, chrDataType, chrDisplayType, _
                                strDisplayInfo, strDesc, strDefaultValue, sngVersionAdded, blnImportant, strMessage) Then

                    KartSettingsManager.RefreshCache()

                    If Request.QueryString("name") Is Nothing And String.IsNullOrEmpty(txtSearchStarting.Text) Then
                        CreateMenu()
                        mvwConfig.SetActiveView(viwMenu)
                    Else
                        mvwConfig.SetActiveView(viwResult)
                    End If


                    RaiseEvent ShowMasterUpdate()
                Else
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    phdMessageError.Visible = True
                End If
            Case DML_OPERATION.UPDATE
                If ConfigBLL._UpdateConfig( _
                        litCFG_Name.Text, strValue, chrDataType, chrDisplayType, _
                        strDisplayInfo, strDesc, strDefaultValue, sngVersionAdded, blnImportant, strMessage) Then

                    '' If isn't a postback, we read the search term from a querystring; this functionality allows us to
                    ''  receive links from the main search, and know what config setting we need to find
                    If Not Request.QueryString("name") Is Nothing And Not Me.IsPostBack Then
                        txtSearchStarting.Text = Request.QueryString("name")
                        SearchConfig(txtSearchStarting.Text)
                    Else
                        SearchConfig(txtSearchStarting.Text)
                    End If

                    RaiseEvent ShowMasterUpdate()
                    KartSettingsManager.RefreshCache()
                    If strConfigName.ToLower = "general.seofriendlyurls.enabled" Then CkartrisDataManipulation.RefreshSiteMap()

                Else
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    phdMessageError.Visible = True
                End If
        End Select

    End Sub

    Public Function SetExpertSetting() As Boolean
        If KartSettingsManager.GetKartConfig("backend.expertmode") <> "y" Then
            Return False
        Else
            Return True
        End If
    End Function

    'Formats Kartris version number nicely, to 4 decimal places
    Public Function FormatVersion(ByVal numVersion As Single) As String
        Return numVersion.ToString("N4")
    End Function
    Private Function CheckConfigName() As Boolean
        Dim strNewName As String = txtCFG_Name.Text
        If ConfigBLL._GetConfigByName(strNewName).Rows.Count = 1 Then
            Return False
        End If
        Return True
    End Function
    Protected Sub lnkBtnViewConfigName_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnViewConfigName.Click
        SearchConfig(txtCFG_Name.Text)
    End Sub

    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.Click
        If gvwConfig.SelectedIndex = -1 Then
            SaveChanges(DML_OPERATION.INSERT)
        Else
            SaveChanges(DML_OPERATION.UPDATE)
        End If
        CreateMenu()
    End Sub

    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancel.Click
        ClearTextControls()
        mvwConfig.SetActiveView(viwResult)
    End Sub

    Protected Sub lnkBtnCFG_CheckName_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCFG_CheckName.Click
        If txtCFG_Name.Text <> "" Then
            If CheckConfigName() Then
                UnlockControls()
                lnkBtnCFG_ChangeName.Visible = True
                lnkBtnCFG_CheckName.Visible = False
                phdNameAlreadyExist.Visible = False
                litPleaseEnterValue.Visible = False
                txtCFG_Value.Focus()
            Else
                phdNameAlreadyExist.Visible = True
                litPleaseEnterValue.Visible = False
            End If
        Else
            litPleaseEnterValue.Visible = True
            phdNameAlreadyExist.Visible = False
        End If
    End Sub

    Sub LockControls()
        txtCFG_Name.Enabled = True
        txtCFG_Value.Enabled = False
        ddlCFG_DataType.Enabled = False
        ddlCFG_DisplayType.Enabled = False
        txtCFG_DisplayInfo.Enabled = False
        txtCFG_DefaultValue.Enabled = False
        txtCFG_Desc.Enabled = False
        txtCFG_VersionAdded.Enabled = False
        chkCFG_Important.Enabled = False
    End Sub

    Sub UnlockControls()
        txtCFG_Name.Enabled = False
        txtCFG_Value.Enabled = True
        ddlCFG_DataType.Enabled = True
        ddlCFG_DisplayType.Enabled = True
        txtCFG_DisplayInfo.Enabled = True
        txtCFG_DefaultValue.Enabled = True
        txtCFG_Desc.Enabled = True
        txtCFG_VersionAdded.Enabled = True
        chkCFG_Important.Enabled = True
    End Sub

    Protected Sub lnkBtnCFG_ChangeName_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCFG_ChangeName.Click
        LockControls()
        lnkBtnCFG_ChangeName.Visible = False
        lnkBtnCFG_CheckName.Visible = True
        txtCFG_Name.Focus()
    End Sub

    Protected Sub lnkDetails_Click(sender As Object, e As EventArgs) Handles lnkDetails.Click
        If phdDetails.Visible Then
            phdDetails.Visible = False
            'Set the text of the 'details' link
            lnkDetails.Text = "[+] <span class=""bold"">" & GetGlobalResourceObject("_Kartris", "ContentText_Details") & "</span>"
        Else
            phdDetails.Visible = True
            'Set the text of the 'details' link
            lnkDetails.Text = "[-] <span class=""bold"">" & GetGlobalResourceObject("_Kartris", "ContentText_Details") & "</span>"
        End If
    End Sub
End Class
