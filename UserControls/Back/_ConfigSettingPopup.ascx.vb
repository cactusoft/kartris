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
Partial Class UserControls_Back_ConfigSettingPopup
    Inherits System.Web.UI.UserControl

    Public Property ConfigString() As String
        Get
            Return ViewState("ConfigString")
        End Get
        Set(ByVal value As String)
            ViewState("ConfigString") = value
        End Set
    End Property

    Public Sub ShowPopup(ByVal strConfig As String)
        litConfigName.Text = strConfig

        Dim tblConfig As New DataTable
        tblConfig = ConfigBLL._SearchConfig(strConfig, False)

        For Each dr As DataRow In tblConfig.Rows
            Dim strConfigDisplayType As String = dr("CFG_DisplayType").ToString
            Select Case strConfigDisplayType
                Case "b"
                    phdSettings.Controls.Add(GetLiteral("<span class=""checkbox"">"))
                    Dim chkConfig As New CheckBox
                    chkConfig.ID = "CFG_CHK_" & dr("CFG_Name")
                    If tblConfig.Rows.Count > 1 Then chkConfig.Text = dr("CFG_Name")

                    chkConfig.EnableViewState = True
                    chkConfig.Checked = (dr("CFG_Value") = "y")
                    phdSettings.Controls.Add(chkConfig)
                    phdSettings.Controls.Add(GetLiteral("</span>"))
                    If tblConfig.Rows.Count > 1 Then phdSettings.Controls.Add(GetLiteral("<br/>"))
                Case "t"
                    Dim strConfigName As String = dr("CFG_Name")

                    Dim lblConfigName As New Label
                    lblConfigName.Text = strConfigName & " "
                    lblConfigName.Font.Bold = True
                    If tblConfig.Rows.Count > 1 Then phdSettings.Controls.Add(lblConfigName)
                    Dim txtConfig As New TextBox
                    txtConfig.ID = "CFG_TXT_" & strConfigName
                    txtConfig.EnableViewState = True
                    If String.IsNullOrEmpty(txtConfig.Text) Then
                        txtConfig.Text = dr("CFG_Value")
                    End If

                    phdSettings.Controls.Add(txtConfig)

                    If strConfigName.ToLower <> "general.webshopfolder" Then
                        Dim valConfig As New RequiredFieldValidator
                        valConfig.ControlToValidate = txtConfig.ID
                        valConfig.Text = "*"
                        valConfig.ErrorMessage = strConfigName & " is required!"
                        phdSettings.Controls.Add(valConfig)
                    End If

                    phdSettings.Controls.Add(GetLiteral("<br/>"))
                Case "n"
                    Dim strConfigName As String = dr("CFG_Name")
                    Dim lblConfigName As New Label
                    lblConfigName.Text = strConfigName & " "
                    lblConfigName.Font.Bold = True
                    If tblConfig.Rows.Count > 1 Then phdSettings.Controls.Add(lblConfigName)
                    Dim txtConfig As New TextBox
                    txtConfig.ID = "CFG_TXT_" & strConfigName
                    txtConfig.EnableViewState = True
                    txtConfig.Width = "100"
                    If String.IsNullOrEmpty(txtConfig.Text) Then
                        txtConfig.Text = dr("CFG_Value")
                    End If
                    phdSettings.Controls.Add(txtConfig)
                    Dim numval As New RegularExpressionValidator
                    numval.ControlToValidate = txtConfig.ID
                    numval.Text = "!"
                    numval.ValidationExpression = "^[0-9]$"
                    numval.ErrorMessage = "!"
                    phdSettings.Controls.Add(numval)
                    phdSettings.Controls.Add(GetLiteral("<br/>"))
            End Select

            Dim lblConfigDescription As New Label
            lblConfigDescription.Text = CkartrisDataManipulation.FixNullFromDB(dr("CFG_Description"))
            phdSettings.Controls.Add(lblConfigDescription)
            phdSettings.Controls.Add(GetLiteral("<br/>"))
            phdSettings.Controls.Add(GetLiteral("</p>"))

        Next

        updPopup.Update()
        popConfigSetting.Show()
    End Sub

    Private Function GetLiteral(ByVal text As String) As Literal
        Dim rv As Literal
        rv = New Literal
        rv.Text = text
        Return rv
    End Function

    Protected Sub btnAccept_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAccept.Click
        Page.Validate()
        If Page.IsValid Then
            Dim objSQLCommand As New SqlCommand
            For Each Ctrl As Control In phdSettings.Controls
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

                            ConfigBLL._UpdateConfigValue(strConfigName, strConfigValue)
                        End If
                    End If
                Catch ex As Exception
                    'phdError.Visible = True
                    'litError.Text = GetLocalResourceObject("Step5_Error_UpdatingConfigSettings") & " --- " & ex.Message
                End Try
            Next

        Else
            'e.Cancel = True
        End If
    End Sub

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init

    End Sub
End Class
