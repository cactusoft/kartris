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
Imports System.Globalization
Imports System.Threading
Imports System.Web.Configuration
Imports Microsoft.SqlServer.Server

Partial Class Admin_Install
    Inherits System.Web.UI.Page

    '---------------------------------------
    'SET CONSTANTS AND VARIABLES
    '---------------------------------------
    'Private Shared strResLangs As String() = {"en", "ar", "de", "es", "fr", "ja"}
    Private Shared strResLangs As String() = {"en"}
    Private Shared strConnectionString As String = ""
    Private Shared strUploadsPath As String = ""
    Private Shared blnPermissionsOK As Boolean = False
    Private Shared blnConfigDownloadedOnce As Boolean = False
    Private Shared ModifiedConfig As Configuration = Nothing
    Private Shared blnConfigUpdatable As Boolean = False
    Private Shared objSQLConnection As SqlConnection = Nothing
    Private Shared blnConfigControlsCreated As Boolean = False
    Private Shared strCreatedDBName As String = ""

    '---------------------------------------
    'CHECK LANGUAGE
    '---------------------------------------
    Protected Overrides Sub InitializeCulture()
        ' override virtual method InitializeCulture() to check if profile contains a user language setting
        If Session("CultureName") IsNot Nothing Then
            Dim UserCulture As String = Session("CultureName")
            If UserCulture <> "" Then
                ' there is a user language setting in the profile: switch to it
                Thread.CurrentThread.CurrentUICulture = New CultureInfo(UserCulture)
                Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(UserCulture)
            End If
        End If
    End Sub 'InitializeCulture

    '---------------------------------------
    'LANGUAGE CHANGED
    '---------------------------------------
    Protected Sub ddlLanguage_SelectedIndexChanged(ByVal sender As Object, ByVal e As EventArgs)
        Dim SelectedLanguage As String = ddlLanguage.SelectedValue.ToString()
        'Save selected user language in profile 
        Session("CultureName") = SelectedLanguage

        'Force re-initialization of the page to fire InitializeCulture()
        Response.Redirect(Request.Url.LocalPath)

    End Sub

    'Protected Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Error
    '    Response.Write("Globalization Error")
    'End Sub

    '---------------------------------------
    'PRE-INIT
    'Looks up important config settings once
    'db exists to allow them to be changed.
    '---------------------------------------
    Protected Sub Page_PreInit(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreInit
        If objSQLConnection IsNot Nothing Then
            Try
                Dim objSQLCommand As New SqlCommand
                With objSQLCommand
                    .CommandType = CommandType.Text
                    .CommandText = "SELECT * FROM tblKartrisConfig WHERE CFG_Important = 1"
                    .Connection = objSQLConnection
                    .Connection.Open()
                    Dim drwConfigSettings As SqlDataReader = .ExecuteReader
                    Do While drwConfigSettings.Read
                        phdConfigSettings.Controls.Add(GetLiteral("<p>"))
                        Dim strConfigDisplayType As String = drwConfigSettings("CFG_DisplayType").ToString
                        Select Case strConfigDisplayType

                            Case "b" 'Boolean
                                phdConfigSettings.Controls.Add(GetLiteral("<span class=""checkbox2"">"))
                                Dim chkConfig As New CheckBox
                                chkConfig.ID = "CFG_CHK_" & drwConfigSettings("CFG_Name")
                                chkConfig.Text = drwConfigSettings("CFG_Name")
                                chkConfig.EnableViewState = True
                                chkConfig.Checked = (drwConfigSettings("CFG_Value") = "y")
                                phdConfigSettings.Controls.Add(chkConfig)
                                phdConfigSettings.Controls.Add(GetLiteral("</span><br />"))

                            Case "t" 'Text
                                Dim strConfigName As String = drwConfigSettings("CFG_Name")

                                Dim lblConfigName As New Label
                                lblConfigName.Text = strConfigName & " "
                                lblConfigName.Font.Bold = True
                                phdConfigSettings.Controls.Add(lblConfigName)
                                Dim txtConfig As New TextBox
                                txtConfig.ID = "CFG_TXT_" & strConfigName
                                txtConfig.EnableViewState = True
                                If String.IsNullOrEmpty(txtConfig.Text) Then
                                    If strConfigName.ToLower = "general.webshopurl" Then
                                        txtConfig.Text = HttpContext.Current.Request.Url.AbsoluteUri.ToLower.Replace("admin/install.aspx", "")
                                    ElseIf strConfigName.ToLower = "general.webshopfolder" Then
                                        Dim strDetectedWebShopFolder = Trim(Request.ApplicationPath)
                                        If Not String.IsNullOrEmpty(strDetectedWebShopFolder) Then
                                            If strDetectedWebShopFolder = "/" Then
                                                strDetectedWebShopFolder = ""
                                            ElseIf Left(strDetectedWebShopFolder, 1) = "/" Then
                                                strDetectedWebShopFolder = Mid(strDetectedWebShopFolder, 2)
                                            End If
                                            If strDetectedWebShopFolder <> "" Then
                                                If Not (strDetectedWebShopFolder.LastIndexOf("/") + 1 = strDetectedWebShopFolder.Length) Then
                                                    strDetectedWebShopFolder += "/"
                                                End If
                                            End If
                                        Else
                                            strDetectedWebShopFolder = ""
                                        End If

                                        txtConfig.Text = strDetectedWebShopFolder
                                    Else
                                        txtConfig.Text = drwConfigSettings("CFG_Value")
                                    End If
                                End If

                                phdConfigSettings.Controls.Add(txtConfig)

                                If strConfigName.ToLower <> "general.webshopfolder" Then
                                    Dim valConfig As New RequiredFieldValidator
                                    valConfig.ControlToValidate = txtConfig.ID
                                    valConfig.Text = "*"
                                    valConfig.ErrorMessage = strConfigName & " is required!"
                                    phdConfigSettings.Controls.Add(valConfig)
                                End If

                                phdConfigSettings.Controls.Add(GetLiteral("<br />"))

                        End Select

                        Dim lblConfigDescription As New Label
                        lblConfigDescription.Text = drwConfigSettings("CFG_Description")
                        phdConfigSettings.Controls.Add(lblConfigDescription)
                        phdConfigSettings.Controls.Add(GetLiteral("<br />"))
                        phdConfigSettings.Controls.Add(GetLiteral("</p>"))
                    Loop
                End With
                blnConfigControlsCreated = True
            Catch ex As Exception
                litError.Text = ex.Message
                phdError.Visible = True
            Finally
                If objSQLConnection.State = ConnectionState.Open Then objSQLConnection.Close()
            End Try
        End If
    End Sub

    '---------------------------------------
    'PAGE LOAD
    'Checks if install routine should run or
    'not, depending on if globalization tag
    'in web.config is commented, and SQL
    'db cannot be found.
    '---------------------------------------
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        phdError.Visible = False
        litError.Text = ""

        If (Not IsPostBack) And wizInstallation.ActiveStepIndex = 0 Then

            txtHashKey.Text = Guid.NewGuid.ToString

            'Check if this shop is already set up
            'If Application("DBConnected") Then
            '    Dim conKartris As New SqlConnection(ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString)
            '    Dim comCheck As New SqlCommand("SELECT COUNT(*) as LoginCount FROM tblKartrisLogins", conKartris)
            '    conKartris.Open()
            '    If comCheck.ExecuteScalar() > 0 Then
            '        'There's an existing Login record! This shop is already set up.
            '        Page_Load_Error(GetLocalResourceObject("Error_KartrisAlreadyInstalled"))
            '        Exit Sub
            '    End If
            'End If
            Dim webConfigFile As String = Path.Combine(HttpContext.Current.Request.PhysicalApplicationPath, "web.config")
            'Also on first load, check if the web.config is updatable
            Try
                Dim result As Boolean = False
                Try
                    If ModifiedConfig Is Nothing Then
                        ModifiedConfig = System.Web.Configuration.WebConfigurationManager.OpenWebConfiguration(Request.ApplicationPath)
                        Dim configSection As System.Web.Configuration.GlobalizationSection = CType(ModifiedConfig.GetSection("system.web/globalization"),  _
                        System.Web.Configuration.GlobalizationSection)
                        If configSection.ResourceProviderFactoryType = "Kartris.SqlResourceProviderFactory" Then result = True
                    End If
                Catch ex As Exception
                    'Hmmm....Kartris must be running under medium trust
                    ModifiedConfig = Nothing
                    Dim webConfigReader As New XmlTextReader(New StreamReader(webConfigFile))
                    result = ((webConfigReader.ReadToFollowing("globalization")) AndAlso (webConfigReader.GetAttribute("resourceProviderFactoryType") = "Kartris.SqlResourceProviderFactory"))
                    webConfigReader.Close()
                End Try

            Catch ex As Exception
                Page_Load_Error(GetLocalResourceObject("Error_OpeningWebConfig") & " --- " & ex.Message)
                Exit Sub
            End Try

            Try
                File.Copy(webConfigFile, Request.PhysicalApplicationPath & "test.txt")
                blnConfigUpdatable = True
                phdNote.Visible = False
            Catch ex As Exception
                blnConfigUpdatable = False
                phdNote.Visible = True
            End Try

            If blnConfigUpdatable Then
                Try
                    File.Delete(Request.PhysicalApplicationPath & "test.txt")
                Catch ex As Exception

                End Try
            End If

            If CStr(Session("CultureName")) <> CultureInfo.CurrentCulture.Name Then
                ' Populate the language dropdown with the list of available languages on the server
                ddlLanguage.Items.Clear() ' Clears the dropdown in case of a culture change
                Dim ResLanguage As String
                For Each ResLanguage In strResLangs
                    Dim TempCultureInfo As New CultureInfo(ResLanguage)
                    Dim ResourceLanguage As New ListItem(TempCultureInfo.NativeName, TempCultureInfo.Name)
                    If TempCultureInfo.Equals(CultureInfo.CurrentUICulture) Then
                        ResourceLanguage.Selected = True
                    End If
                    ddlLanguage.Items.Add(ResourceLanguage)
                Next ResLanguage

                Session("CultureName") = CultureInfo.CurrentCulture.Name
            End If

        End If
    End Sub

    '---------------------------------------
    'HANDLES PAGE LOAD ERRORS
    'For example, if globalization tag not
    'commented (so run install) but db
    'already exists.
    '---------------------------------------
    Private Sub Page_Load_Error(ByVal strErrorText As String)
        wizInstallation.Visible = False
        phdError.Visible = True
        litError.Text = strErrorText
        phdNote.Visible = False
    End Sub

    '---------------------------------------
    '1. WELCOM TO KARTRIS
    '---------------------------------------
    Protected Sub ws1_Welcome_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles ws1_Welcome.Activate
        ' Do nothing
    End Sub

    '---------------------------------------
    '2. HASH KEY CHECK
    '---------------------------------------
    Protected Sub ws2_HashandMachineKey_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles ws2_HashandMachineKey.Activate
        Dim strHashKey As String = ConfigurationManager.AppSettings("hashsalt")
        If Not (String.IsNullOrEmpty(strHashKey) Or strHashKey = "PutSomeRandomTextHere") Then
            litHashDesc.Text = GetLocalResourceObject("Step2_YourHashKeyAlreadySetTo") & """<strong>" & Server.HtmlEncode(strHashKey) & "</strong>""" & GetLocalResourceObject("Step2_YourHashKeyAlreadySetTo_2")
            'If String.IsNullOrEmpty(txtHashKey.Text) Then

            'End If
            txtHashKey.Text = strHashKey
        End If
    End Sub

    '---------------------------------------
    '3. DB CONNECTION SETUP
    '---------------------------------------
    Protected Sub ws3_ConnectionString_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles ws3_ConnectionString.Activate
        If String.IsNullOrEmpty(strConnectionString) Then
            Application("DBConnected") = False
            phdRetryCheckButton.Visible = False
            'Hide connection info
            phdConnectionChecking.Visible = False
            litConnectionString.Text = ""
            btnUseSavedConnection.Visible = False
        Else
            'Show connection info
            phdConnectionChecking.Visible = True
            litConnectionString.Text = strConnectionString
            If CheckConnectionDetails(strConnectionString) Then
                litConnectionString.Text += " --> " & GetLocalResourceObject("Step3_SuccessText")
                btnUseSavedConnection.Visible = True
            End If
        End If

        If Application("DBConnected") Then
            mvwConnectionString.ActiveViewIndex = 0
            phdRetryCheckButton.Visible = False
        Else
            mvwConnectionString.ActiveViewIndex = 1
        End If
    End Sub

    '---------------------------------------
    '4. SETUP DATABASE STRUCTURE AND CONTENT
    'Only if does not already exist.
    '---------------------------------------
    Protected Sub ws4_SetUpDatabase_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles ws4_SetUpDatabase.Activate
        'STEP 4 - SET UP DATABASE
        Dim strConnection As String
        litBackendPassword.Text = ""
        If Not String.IsNullOrEmpty(strConnectionString) Then
            strConnection = strConnectionString
        Else
            strConnection = ConfigurationManager.ConnectionStrings("kartrisSQLConnection").ToString
        End If
        objSQLConnection = New SqlConnection(strConnection)
        Dim objSQLCommand As New SqlCommand
        Try
            objSQLCommand = New SqlCommand("SELECT TOP 1 P_ID FROM tblKartrisProducts", objSQLConnection)
            objSQLConnection.Open()
            objSQLCommand.ExecuteNonQuery()
            mvwSetUpDatabase.ActiveViewIndex = 0
        Catch ex As Exception
            mvwSetUpDatabase.ActiveViewIndex = 1
            Try
                Dim strSQLPath As String = Server.MapPath("~/Uploads/resources/kartrisSQL_MainData.sql")
                Dim strError As String = ""
                If File.Exists(strSQLPath) Then
                    ExecuteSQLScript(strSQLPath, objSQLConnection, strError)
                    If Not String.IsNullOrEmpty(strError) Then Throw New Exception(strError)
                End If
            Catch SQLex As Exception
                litError.Text = " Database Schema Creation Failed - " & SQLex.Message
                phdError.Visible = True
                wizInstallation.ActiveStepIndex = 2
            End Try
            If chkCreateSampleData.checked Then
                Try
                    Dim strSQLPath As String = Server.MapPath("~/Uploads/resources/kartrisSQL_SampleData.sql")
                    Dim strError As String = ""
                    If File.Exists(strSQLPath) Then
                        ExecuteSQLScript(strSQLPath, objSQLConnection, strError)
                        If Not String.IsNullOrEmpty(strError) Then Throw New Exception(strError)
                    End If
                Catch SQLex As Exception
                    litError.Text = " Database Sample Creation Failed - " & SQLex.Message
                    phdError.Visible = True
                    wizInstallation.ActiveStepIndex = 2
                End Try
            End If
        Finally
            If objSQLConnection.State = ConnectionState.Open Then objSQLConnection.Close()
        End Try

        If Not String.IsNullOrEmpty(txtHashKey.Text) Then
            Try
                Dim strNewRandomSalt As String = Membership.GeneratePassword(20, 0)
                litBackendPassword.Text = Trim(Membership.GeneratePassword(8, 0))
                Dim uEncode As New UnicodeEncoding()
                Dim bytClearString() As Byte = uEncode.GetBytes(txtHashKey.Text & litBackendPassword.Text & strNewRandomSalt)
                Dim sha As New System.Security.Cryptography.SHA256Managed()
                Dim hash() As Byte = sha.ComputeHash(bytClearString)
                Dim strEncryptedPass As String = Convert.ToBase64String(hash)
                objSQLCommand = New SqlCommand("DELETE FROM tblKartrisLogins WHERE LOGIN_Username = 'Admin';" &
                                        "INSERT INTO tblKartrisLogins VALUES ('Admin','" & strEncryptedPass & "',1,1,1,1,1,1,'',1,'" & strNewRandomSalt & "',NULL);",
                                        objSQLConnection)
                objSQLConnection.Open()
                objSQLCommand.ExecuteNonQuery()
            Catch ex As Exception
                wizInstallation.ActiveStepIndex = 2
            Finally
                If objSQLConnection.State = ConnectionState.Open Then objSQLConnection.Close()
            End Try
        Else
            wizInstallation.ActiveStepIndex = 1
        End If
    End Sub

    '---------------------------------------
    '5. CHECK/CHANGE IMPORTANT CONFIG
    'No code needed here, but there is some
    'on the aspx page.
    '---------------------------------------

    '---------------------------------------
    '6. FOLDER PERMISSIONS
    'For image uploads, etc.
    '---------------------------------------
    Protected Sub ws6_FolderPermissions_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles ws6_FolderPermissions.Activate
        TestFoldersPermissions()
    End Sub

    '---------------------------------------
    '7. REVIEW SETTINGS
    'For image uploads, etc.
    '---------------------------------------
    Protected Sub ws7_ReviewSettings_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles ws7_ReviewSettings.Activate
        Dim strTaxRegime As String = ddlTaxRegime.SelectedValue
        
        If String.IsNullOrEmpty(strConnectionString) Then
            phdConnectionString.Visible = False
        Else
            phdConnectionString.Visible = True
            litReviewConnectionString.Text = strConnectionString
        End If

        If Trim(txtHashKey.Text) <> Trim(ConfigurationManager.AppSettings("hashsalt")) Then
            phdHashSaltKey.Visible = True
            litReviewHashSaltKey.Text = txtHashKey.Text
        Else
            phdHashSaltKey.Visible = False
        End If

        If strTaxRegime <> "" Then
            phdTaxRegime.Visible = True
            litReviewTaxRegime.Text = strTaxRegime
        End If

        Try
            Dim doc As New XmlDocument()
            If ModifiedConfig IsNot Nothing Then
                Dim section As System.Configuration.ConfigurationSection = ModifiedConfig.GetSection("appSettings")

                Dim element As KeyValueConfigurationElement = CType(ModifiedConfig.AppSettings.Settings("hashsalt"), KeyValueConfigurationElement)
                If element IsNot Nothing And Not String.IsNullOrEmpty(txtHashKey.Text) And phdHashSaltKey.Visible Then
                    element.Value = txtHashKey.Text
                End If

                element = CType(ModifiedConfig.AppSettings.Settings("TaxRegime"), KeyValueConfigurationElement)
                If element IsNot Nothing And ddlTaxRegime.SelectedValue <> "Select One" Then
                    If strTaxRegime = "European Union" Then strTaxRegime = "EU"
                    If strTaxRegime = "Other" Then strTaxRegime = "SIMPLE"
                    element.Value = strTaxRegime
                End If


                Dim ErrorSection As System.Web.Configuration.CustomErrorsSection = CType(ModifiedConfig.GetSection("system.web/customErrors"), System.Web.Configuration.CustomErrorsSection)
                ErrorSection.Mode = CustomErrorsMode.RemoteOnly
                ErrorSection.DefaultRedirect = "Error.aspx"

                Dim configSection As System.Web.Configuration.GlobalizationSection = CType(ModifiedConfig.GetSection("system.web/globalization"),  _
                System.Web.Configuration.GlobalizationSection)
                configSection.ResourceProviderFactoryType = "Kartris.SqlResourceProviderFactory"

                If phdConnectionString.Visible Then
                    ModifiedConfig.ConnectionStrings.ConnectionStrings("KartrisSQLConnection").ConnectionString = strConnectionString
                End If
            End If

            If phdConnectionString.Visible Or phdHashSaltKey.Visible Or phdTaxRegime.Visible Then
                If blnConfigUpdatable Then
                    btnSaveCopy.Visible = False
                Else
                    litReviewSettingsDesc.Text = GetLocalResourceObject("Step7_CannotUpdateWebConfigText")
                    btnSaveCopy.Visible = True
                End If
            Else
                litReviewSettingsDesc.Text = GetLocalResourceObject("Step7_NoChangesToWebConfigText")
                btnSaveCopy.Visible = False
            End If


        Catch ex As Exception
            wizInstallation.ActiveStepIndex = 5
            phdError.Visible = True
            litError.Text = GetLocalResourceObject("Error_OpeningWebConfig") & " --- " & ex.Message
        End Try
    End Sub

    '---------------------------------------
    '8. SETUP COMPLETE!
    'No code needed here, but there is some
    'on the aspx page.
    '---------------------------------------

#Region "INSTALLATION WIZARD NAVIGATION BUTTONS EVENTS"
    Protected Sub wizInstallation_NextButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wizInstallation.NextButtonClick, wizInstallation.SideBarButtonClick
        btnSaveCopy.Visible = False

        Select Case e.NextStepIndex
            Case 2
                Dim strHashKey As String = ConfigurationManager.AppSettings("hashsalt")
                If (String.IsNullOrEmpty(strHashKey) Or strHashKey = "PutSomeRandomTextHere") Then
                    If String.IsNullOrEmpty(txtHashKey.Text) Then
                        phdError.Visible = True
                        litError.Text = GetLocalResourceObject("Step2_Error_HashKeyRequiredText")
                        e.Cancel = True
                    Else
                        phdError.Visible = False
                    End If
                End If
            Case 3
                Page.Validate()
                If Page.IsValid Then
                    If Not Application("DBConnected") Then

                        strConnectionString = "Data Source=" & txtServerName.Text
                        If chkUseWindowsAuthentication.Checked Then
                            strConnectionString += ";Integrated Security=True"
                        Else
                            strConnectionString += ";User ID=" & txtUsername.Text & ";Password=" & txtPassword.Text
                        End If
                        
                        strConnectionString += ";Initial Catalog=" & txtDatabaseName.Text

                        '' ======== Added By Mohammad =========='
                        If rbnCreateDB.Checked Then
                            Dim strError As String = Nothing
                            If Not CreateNewDB(strConnectionString, txtDatabaseName.Text, strError) Then
                                litError.Text = strError
                                phdError.Visible = True
                                btnRetryCheck.Visible = True
                                e.Cancel = True
                                Exit Select
                            End If
                        End If
                        litError.Text = ""
                        phdError.Visible = False
                        btnRetryCheck.Visible = False
                        '' ==================================='
                        If CheckConnectionDetails(strConnectionString) Then
                            phdError.Visible = False
                        Else
                            e.Cancel = True
                            btnRetryCheck.Visible = True
                        End If
                    End If
                End If
            Case 5
                Page.Validate()
                If Page.IsValid Then
                    Dim objSQLCommand As New SqlCommand
                    For Each Ctrl As Control In phdConfigSettings.Controls
                        Try
                            If InStr(Ctrl.ID, "CFG_") Then
                                Dim arrConfig As String() = Split(Ctrl.ID, "_")
                                If UBound(arrConfig) = 2 Then
                                    Dim strConfigName As String = arrConfig(2)
                                    Dim strConfigValue As String = ""
                                    Select Case arrConfig(1)
                                        Case "TXT"
                                            strConfigValue = CType(Ctrl, TextBox).Text
                                        Case "CHK"
                                            If CType(Ctrl, CheckBox).Checked Then strConfigValue = "y" Else strConfigValue = "n"
                                    End Select

                                    objSQLCommand = New SqlCommand("_spKartrisConfig_UpdateConfigValue", objSQLConnection)
                                    Dim paramConfig As SqlParameter
                                    With objSQLCommand
                                        .CommandType = CommandType.StoredProcedure
                                        paramConfig = New SqlParameter("@CFG_Name", strConfigName)
                                        .Parameters.Add(paramConfig)
                                        If String.IsNullOrEmpty(strConfigValue) Then strConfigValue = ""
                                        If strConfigName.ToLower = "general.webshopurl" Then
                                            If Not (strConfigValue.LastIndexOf("/") + 1 = strConfigValue.Length) Then
                                                strConfigValue += "/"
                                            End If
                                        End If
                                        paramConfig = New SqlParameter("@CFG_Value", strConfigValue)
                                        .Parameters.Add(paramConfig)
                                        .Connection.Open()
                                        .ExecuteNonQuery()
                                        .Connection.Close()
                                    End With
                                End If
                            End If
                        Catch ex As Exception
                            phdError.Visible = True
                            litError.Text = GetLocalResourceObject("Step5_Error_UpdatingConfigSettings") & " --- " & ex.Message
                        End Try
                    Next
                Else
                    e.Cancel = True
                End If
            Case 6
                ' -- Commented out to allow user to proceed next step even if folder permissions aren't set yet
                'If Not blnPermissionsOK Then
                '    e.Cancel = True
                'End If
        End Select
    End Sub

    Protected Sub wizInstallation_PreviousButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wizInstallation.NextButtonClick, wizInstallation.PreviousButtonClick
        If e.CurrentStepIndex = 6 Then blnConfigDownloadedOnce = False
    End Sub

    Protected Sub wizInstallation_FinishButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wizInstallation.FinishButtonClick
        If (phdHashSaltKey.Visible Or phdConnectionString.Visible) And (Not blnConfigUpdatable) Then
            If Not blnConfigDownloadedOnce Then
                litError.Text = GetLocalResourceObject("Step6_Error_MustDownloadWebConfigText")
                btnSaveCopy.Visible = True
                phdError.Visible = True
                e.Cancel = True
            Else
                btnSaveCopy.Visible = False
                phdNote.Visible = False
            End If
        Else
            Try
                If ModifiedConfig IsNot Nothing Then
                    ModifiedConfig.Save()
                End If

                Application("DBConnected") = True
                litReminder.Visible = False
            Catch ex As Exception
                If ModifiedConfig IsNot Nothing Then
                    ModifiedConfig = Nothing
                End If
                blnConfigUpdatable = False
                litError.Text = GetLocalResourceObject("Step6_Error_MustDownloadWebConfigText")
                phdError.Visible = True
                btnSaveCopy.Visible = True
                phdNote.Visible = True
                litReminder.Visible = True
                e.Cancel = True
            End Try
        End If
    End Sub

#End Region

#Region "FUNCTIONS AND SUBS USED BY THE INSTALLATION SCRIPT"
    ''' <summary>
    ''' Create database on the specified server
    ''' </summary>
    ''' <param name="strConnString"></param>
    ''' <param name="strDBName"></param>
    ''' <param name="strError"></param>
    ''' <returns></returns>
    ''' <remarks>By Mohammad</remarks>
    Function CreateNewDB(ByVal strConnString As String, ByVal strDBName As String, ByRef strError As String) As Boolean
        If strCreatedDBName = strDBName Then Return True '' skip creation
        strConnString = strConnString.Replace("Initial Catalog=" & strDBName, "Initial Catalog=master")
        Dim conSQL As New SqlClient.SqlConnection(strConnString)
        Dim cmdSQL As New SqlClient.SqlCommand
        Try
            cmdSQL.CommandType = CommandType.Text
            cmdSQL.Connection = conSQL
            conSQL.Open()
            cmdSQL.CommandText = "CREATE DATABASE [" & strDBName & "] COLLATE SQL_Latin1_General_CP1_CI_AS"
            cmdSQL.ExecuteNonQuery()
            strCreatedDBName = strDBName
        Catch ex As Exception
            strError = ex.Message
            Return False
        Finally
            conSQL.Close()
        End Try
        CreateDBUsers(strConnString, strDBName)
        Return True
    End Function

    ''' <summary>
    ''' Create users with permissions on the specified database
    ''' </summary>
    ''' <param name="strConnString"></param>
    ''' <param name="strDBName"></param>
    ''' <remarks>By Mohammad</remarks>
    Sub CreateDBUsers(ByVal strConnString As String, ByVal strDBName As String)
        'strConnString = strConnString.Replace("Database=master", "Database=" & strDBName)
        strConnString = strConnString.Replace("Initial Catalog=" & strDBName, "Initial Catalog=master")
        Dim conSQL As New SqlClient.SqlConnection(strConnString)
        Dim cmdSQL As New SqlClient.SqlCommand

        Try
            cmdSQL.CommandType = CommandType.Text
            cmdSQL.Connection = conSQL
            conSQL.Open()
            cmdSQL.CommandText = "CREATE USER [NT_KartrisUser] FOR LOGIN [NT AUTHORITY\NETWORK SERVICE] WITH DEFAULT_SCHEMA=[dbo]"
            cmdSQL.ExecuteNonQuery()
        Catch ex As Exception
        Finally
            conSQL.Close()
        End Try

        Try
            Dim strSvr As String = txtServerName.Text
            If strSvr.Contains("\") Then strSvr = Split(strSvr, "\")(0)
            cmdSQL.CommandType = CommandType.Text
            cmdSQL.Connection = conSQL
            conSQL.Open()
            cmdSQL.CommandText = "CREATE USER [ASPNET_KartrisUser] FOR LOGIN [" & strSvr & "\ASPNET] WITH DEFAULT_SCHEMA=[dbo]"
            cmdSQL.ExecuteNonQuery()
        Catch ex As Exception
        Finally
            conSQL.Close()
        End Try
    End Sub

    ''' <summary>
    ''' Test a connection string
    ''' </summary>
    ''' <param name="strInputConnectionString"></param>
    ''' <returns></returns>
    ''' <remarks>uses the connection string setting in web.config if there's no parameter passed</remarks>
    Private Function CheckConnectionDetails(Optional ByVal strInputConnectionString As String = "") As Boolean
        Dim blnUsedWebConfig As Boolean = False
        Dim strConnection As String = ""
        If String.IsNullOrEmpty(strInputConnectionString) Then
            strConnection = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString
            blnUsedWebConfig = True
        Else
            strConnectionString = strInputConnectionString
            strConnection = strInputConnectionString
            litConnectionString.Text = strInputConnectionString
        End If
        Dim objSQLConnectionKartris As New SqlConnection(strConnection)
        Try
            objSQLConnectionKartris.Open()
            phdRetryCheckButton.Visible = False
            CheckConnectionDetails = True
            If blnUsedWebConfig Then Application("DBConnected") = True
        Catch ex As Exception
            phdRetryCheckButton.Visible = True
            CheckConnectionDetails = False
            phdError.Visible = True
            litError.Text = GetLocalResourceObject("Error_ConnectionFailedText") & "<code>" & ex.Message & "</code>"
        Finally
            If objSQLConnectionKartris.State = ConnectionState.Open Then objSQLConnectionKartris.Close()
        End Try
    End Function

    ''' <summary>
    ''' Execute SQL script - used by ws4_SetUPDatabase step to create the Kartris Database Structure
    ''' </summary>
    ''' <param name="Filename"></param>
    ''' <param name="conn"></param>
    ''' <param name="strError"></param>
    ''' <remarks></remarks>
    Private Sub ExecuteSQLScript(ByVal Filename As String, ByVal conn As SqlClient.SqlConnection, Optional ByRef strError As String = Nothing)
        Dim objSQLCommand As New SqlClient.SqlCommand
        Dim Reader As New System.IO.StreamReader(Filename)
        Dim chrDelimiter As Char = Chr(0)
        Dim I As Integer
        Dim objTrans As SqlTransaction

        objSQLCommand.CommandType = CommandType.Text
        objSQLCommand.Connection = objSQLConnection
        If objSQLConnection.State = ConnectionState.Closed Then objSQLConnection.Open()
        objTrans = objSQLConnection.BeginTransaction
        objSQLCommand.Transaction = objTrans

        Try
            Dim s As String = Reader.ReadToEnd
            s = Replace(s, vbCrLf & "GO" & vbCrLf, chrDelimiter)
            Dim SQL() As String = s.Split(chrDelimiter)

            For I = 0 To UBound(SQL)
                If Trim(SQL(I)) <> "" Then
                    objSQLCommand.CommandText = SQL(I)
                    objSQLCommand.ExecuteNonQuery()
                End If
            Next

            Reader.Close()
            Reader = Nothing
        Catch ex As Exception
            objTrans.Rollback()
            Reader.Close()
            Reader = Nothing
            strError = ex.Message
        Finally
            If objTrans.Connection IsNot Nothing Then objTrans.Commit()
            objSQLConnection.Close()
        End Try
        objSQLCommand = Nothing
    End Sub

    ''' <summary>
    ''' GET KARTRIS CONFIG SETTING VALUE
    ''' </summary>
    ''' <param name="ConfigName"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function GetConfigValue(ByVal ConfigName As String) As String
        Dim strValue As String = ""
        If Not String.IsNullOrEmpty(ConfigName) Then
            Dim strConnection As String
            If Not String.IsNullOrEmpty(strConnectionString) Then
                strConnection = strConnectionString
            Else
                strConnection = ConfigurationManager.ConnectionStrings("kartrisSQLConnection").ToString
            End If
            Dim objSQLConnection As New SqlConnection(strConnection)
            Try
                Dim objSQLCommand As New SqlClient.SqlCommand("SELECT CFG_Value FROM tblKartrisConfig WHERE CFG_Name = '" & Server.HtmlEncode(ConfigName) & "'", objSQLConnection)
                objSQLConnection.Open()
                Dim reader As SqlDataReader = objSQLCommand.ExecuteReader
                Do While reader.Read()
                    strValue = reader(0).ToString : Exit Do
                Loop

            Catch ex As Exception

            Finally
                If objSQLConnection.State = ConnectionState.Open Then objSQLConnection.Close()
            End Try
        End If
        Return strValue
    End Function

    ''' <summary>
    ''' Code that actually test the folder permissions - used by ws5_FolderPermissions_ON_LOAD and Retry Tests Button_CLICK
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub TestFoldersPermissions()
        Dim blnFoldersAccessible As Boolean = True
        Dim sw As StreamWriter
        litUploadsStatus.Text = GetLocalResourceObject("Step3_FailedText")
        litImagesStatus.Text = GetLocalResourceObject("Step3_FailedText")
        litPaymentStatus.Text = GetLocalResourceObject("Step3_FailedText")
        litError.Text = ""
        Try
            Dim strUploadsFolder As String = GetConfigValue("general.uploadfolder")
            strUploadsPath = Server.MapPath(strUploadsFolder)

            If Not String.IsNullOrEmpty(strUploadsPath) Then
                sw = File.CreateText(strUploadsPath & "KartrisInstallTest.txt")
                sw.WriteLine("Kartris Uploads Folder Permissions Test")
                sw.Flush()
                sw.Close()
                File.Delete(strUploadsPath & "KartrisInstallTest.txt")

                litUploadsStatus.Text = GetLocalResourceObject("Step3_SuccessText")

            End If
        Catch ex As Exception
            blnFoldersAccessible = False
            phdError.Visible = True
            litError.Text = ex.Message
        End Try
        Try
            sw = File.CreateText(Server.MapPath("~/Images/") & "KartrisInstallTest.txt")
            sw.WriteLine("Kartris Images Folder Permissions Test")
            sw.Flush()
            sw.Close()
            File.Delete(Server.MapPath("~/Images/") & "KartrisInstallTest.txt")
            litImagesStatus.Text = GetLocalResourceObject("Step3_SuccessText")
        Catch ex As Exception
            blnFoldersAccessible = False
            phdError.Visible = True
            litError.Text += "<br/><br/>" & ex.Message
        End Try
        Try
            sw = File.CreateText(Server.MapPath("~/Plugins/") & "KartrisInstallTest.txt")
            sw.WriteLine("Kartris Payment Folder Permissions Test")
            sw.Flush()
            sw.Close()
            File.Delete(Server.MapPath("~/Plugins/") & "KartrisInstallTest.txt")
            litPaymentStatus.Text = GetLocalResourceObject("Step3_SuccessText")
        Catch ex As Exception
            blnFoldersAccessible = False
            phdError.Visible = True
            litError.Text += "<br/><br/>" & ex.Message
        End Try
        If blnFoldersAccessible Then
            btnRetryTests.Visible = False
        Else
            'Message to say that folder permission aren't properly set yet but setup will still allow user to proceed
            phdError.Visible = True
            litError.Text += "<br/><br/>" & GetLocalResourceObject("Step6_Error_PermissionsNotSetText")
        End If

        blnPermissionsOK = blnFoldersAccessible
    End Sub

    Private Function GetLiteral(ByVal text As String) As Literal
        Dim rv As Literal
        rv = New Literal
        rv.Text = text
        Return rv
    End Function
#End Region

#Region "CONTROL EVENTS IN DIFFERENT WIZARD STEPS"
    ''' <summary>
    ''' (STEP 3 - Connection String) Use Windows Authentication checkbox -> Disable/Enable Username and Password fields
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub chkUseWindowsAuthentication_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles chkUseWindowsAuthentication.CheckedChanged

        If chkUseWindowsAuthentication.Checked = True Then
            txtUsername.Enabled = False
            txtPassword.Enabled = False
            txtUsername.Visible = False
            txtPassword.Visible = False
            Step3_Password.Visible = False
            Step3_Username.Visible = False
            valUsername.Enabled = False
            valPassword.Enabled = False
        Else
            Step3_Password.Visible = True
            Step3_Username.Visible = True
            txtUsername.Visible = True
            txtPassword.Visible = True
            txtUsername.Enabled = True
            txtPassword.Enabled = True
            valUsername.Enabled = True
            valPassword.Enabled = True
            txtUsername.Focus()
        End If

    End Sub
    ''' <summary>
    ''' (STEP 3 - Connection String) RETRY CHECK BUTTON Click Event Handler
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub btnRetryCheck_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnRetryCheck.Click
        If String.IsNullOrEmpty(strConnectionString) Then
            CheckConnectionDetails()
        Else
            CheckConnectionDetails(strConnectionString)
        End If
    End Sub
    ''' <summary>
    ''' (STEP 5 - Folder Permissions) RETRY TESTS BUTTON Click Event Handler
    ''' ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub btnRetryTests_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnRetryTests.Click
        TestFoldersPermissions()
    End Sub
    ''' <summary>
    ''' (STEP 6 - Review Settings) DOWNLOAD MODIFIED WEB.CONFIG BUTTON Click Event Handler 
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub btnSaveCopy_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSaveCopy.Click
        Try
            Dim docSave As XmlDocument = New XmlDocument()
            docSave.Load(UpdateWebConfig)
            blnConfigDownloadedOnce = True
            Response.Clear()
            Response.ContentType = "text/plain"
            Response.AppendHeader("Content-Disposition", "attachment; filename=web.config")
            docSave.Save(Response.OutputStream)
            Response.End()
        Catch eEx As Exception
            litReason.Text = "<p>" & eEx.Message & "</p>"
        End Try
    End Sub
    Private Function UpdateWebConfig() As XmlTextReader
        Dim webConfigFile As String = Path.Combine(HttpContext.Current.Request.PhysicalApplicationPath, "web.config")
        Dim docSave As XmlDocument = New XmlDocument()
        docSave.Load(webConfigFile)
        If phdConnectionString.Visible Then
            Dim _xmlConnectionNodeList As XmlNodeList = docSave.SelectNodes("/configuration/connectionStrings/add")
            If _xmlConnectionNodeList.Count > 0 Then
                For Each Node As XmlNode In _xmlConnectionNodeList
                    For Each attrib As XmlAttribute In Node.Attributes
                        If attrib.Name.ToLower = "name" And attrib.Value.ToLower = "kartrissqlconnection" Then
                            Node.Attributes("connectionString").Value = strConnectionString
                            Exit For : Exit For
                        End If
                    Next
                Next
            End If
        End If

        Dim _xmlNodeList As XmlNodeList = docSave.SelectNodes("/configuration/appSettings/add")
        If _xmlNodeList.Count > 0 Then
            Dim blnHashFound As Boolean = Not (Not String.IsNullOrEmpty(txtHashKey.Text) And phdHashSaltKey.Visible)
            Dim blnTaxRegimeSet As Boolean = False
            For Each Node As XmlNode In _xmlNodeList
                For Each attrib As XmlAttribute In Node.Attributes
                    If attrib.Name.ToLower = "key" Then

                        If Not String.IsNullOrEmpty(txtHashKey.Text) And phdHashSaltKey.Visible And Not blnHashFound Then
                            If attrib.Value.ToLower = "hashsalt" Then
                                Node.Attributes("value").Value = txtHashKey.Text
                                blnHashFound = True
                            End If
                        End If
                        
                        If attrib.Value.ToLower = "TaxRegime" Then
                            Dim strTaxRegime As String = ddlTaxRegime.SelectedValue
                            If strTaxRegime = "European Union" Then strTaxRegime = "EU"
                            If strTaxRegime = "Other" Then strTaxRegime = "SIMPLE"
                            Node.Attributes("value").Value = strTaxRegime
                            blnTaxRegimeSet = True
                        End If

                        Exit For
                    End If
                Next
                If blnHashFound And blnTaxRegimeSet Then Exit For
            Next
        End If

        Dim _xmlCustomErrorNode As XmlNode = docSave.SelectSingleNode("/configuration/system.web/customErrors")
        If _xmlCustomErrorNode IsNot Nothing Then
            _xmlCustomErrorNode.Attributes("mode").Value = "RemoteOnly"
            _xmlCustomErrorNode.Attributes("defaultRedirect").Value = "Error.aspx"
        End If

        Dim xmlSystemWebnode As XmlNode = docSave.SelectSingleNode("/configuration/system.web")

        Dim elemWeb As XmlElement = docSave.CreateElement("globalization")

        Dim Resourceattrib As XmlAttribute = docSave.CreateAttribute("resourceProviderFactoryType")
        Resourceattrib.Value = "Kartris.SqlResourceProviderFactory"
        elemWeb.Attributes.Append(Resourceattrib)

        xmlSystemWebnode.AppendChild(elemWeb)

        Dim sr As New IO.StringReader(docSave.OuterXml)
        Dim t As New XmlTextReader(sr)
        Return t
    End Function

    ''' <summary>
    ''' (Setp 3 - continue with exiting connection)
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks>by mohammad</remarks>
    Protected Sub btnUseSavedConnection_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUseSavedConnection.Click
        wizInstallation.ActiveStepIndex += 1
    End Sub
#End Region

End Class
