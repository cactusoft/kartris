'========================================================================
'Kartris - www.kartris.com
'Copyright 2014 CACTUSOFT INTERNATIONAL FZ LLC

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
Imports KartSettingsManager

Partial Class UserControls_Back_AdminErrorLogs
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            GetErrorLogs()
            litErrorLogPath.Text = ConfigurationManager.AppSettings("errorlogpath")
            litErrorLogStatus.Text = IIf(GetKartConfig("general.errorlogs.enabled") = "y", _
                                    GetGlobalResourceObject("_Kartris", "ContentText_Enabled"), _
                                    GetGlobalResourceObject("_Kartris", "ContentText_Disabled"))

            btnSubmit_Click(sender, e) 'this submits most recent month to preload
            Try
                'Try to preset to today's file, most people will want to
                'view this so handy to default it
                'lbxFiles.SelectedValue = "2014.08/2014.08.30.config"
                lbxFiles.SelectedValue = Format(Now, "yyyy.MM") & "/" & CStr(Now.Year) & "." & Format(Now, "MM") & "." & Format(Now, "dd") & ".config"
                lbxFiles_SelectedIndexChanged(sender, e)
            Catch ex As Exception
                'No harm done
            End Try

        End If
    End Sub

    Sub GetErrorLogs()
        ClearErrorText()
        ddlMonthYear.Items.Clear()
        ddlMonthYear.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_DropDownSelect"), "0"))
        Dim dirErrors As New DirectoryInfo(Server.MapPath("~/" & ConfigurationManager.AppSettings("errorlogpath") & "/Errors"))
        If dirErrors.Exists Then
            For Each d As DirectoryInfo In dirErrors.GetDirectories()
                ddlMonthYear.Items.Add(New ListItem(d.Name, d.Name))
            Next
        End If

        If ddlMonthYear.Items.Count > 0 Then ddlMonthYear.SelectedValue = ddlMonthYear.Items(ddlMonthYear.Items.Count - 1).Value
    End Sub

    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSubmit.Click
        ClearErrorText()
        If ddlMonthYear.SelectedValue <> "0" Then
            Dim dirErrors As New DirectoryInfo(Server.MapPath("~/" & ConfigurationManager.AppSettings("errorlogpath") & _
                                     "/Errors/" & ddlMonthYear.SelectedValue))
            If dirErrors.Exists Then
                For Each f As FileInfo In dirErrors.GetFiles()
                    Dim strName As String
                    strName = Microsoft.VisualBasic.Left(f.Name, f.Name.IndexOf(".config"))
                    strName = IIf(strName.StartsWith("_"), strName.TrimStart("_"), strName)
                    lbxFiles.Items.Add(New ListItem(strName, ddlMonthYear.SelectedValue & "/" & f.Name))
                Next
            End If
        End If
        btnRefresh.Visible = False
    End Sub

    Protected Sub lbxFiles_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles lbxFiles.SelectedIndexChanged
        Dim strFilePath As String = Server.MapPath("~/" & ConfigurationManager.AppSettings("errorlogpath")) & _
                  "/Errors/" & lbxFiles.SelectedValue
        Dim filReader As New StreamReader(strFilePath)
        Try
            txtFileText.Text = filReader.ReadToEnd()
            filReader.Close()
        Catch ex As Exception
            ClearErrorText()
        End Try
        Try
            filReader.Close()
        Catch ex As Exception
        End Try
        btnRefresh.Visible = True
    End Sub

    Private Sub ClearErrorText()
        lbxFiles.Items.Clear()
        txtFileText.Text = String.Empty
    End Sub


    Protected Sub lnkBtnDeleteAllErrorLogs_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDeleteAllErrorLogs.Click
        Dim strMessage As String = Replace(GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItem"), "[itemname]", _
                                    GetGlobalResourceObject("_Admin", "ContentText_AllErrorLogs"))
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, strMessage)
    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        Dim strResult As String = DeleteErrorLogs()
        If Not strResult Is Nothing Then
            If Not String.IsNullOrEmpty(strResult) Then
                litError.Text = GetGlobalResourceObject("_Kartris", "ContentText_NotDeletedFolders") & "<br/>" & strResult
                phdError.Visible = True
            End If
        Else
            litError.Text = ""
            phdError.Visible = False
        End If
        GetErrorLogs()
    End Sub

    Function DeleteErrorLogs() As String

        Dim strBldrNotDeletedFolders As New StringBuilder("")
        Dim strBldrNotDeletedFiles As New StringBuilder("")
        Dim strLogPath As String = ConfigurationManager.AppSettings("errorlogpath") 'GetKartConfig("general.errorlogs.path")
        Dim dirErrors As New DirectoryInfo(Server.MapPath("~/" & strLogPath))
        Dim strBldr As New StringBuilder("")
        Dim fleLog() As FileInfo
        If dirErrors.Exists Then
            For Each d As DirectoryInfo In dirErrors.GetDirectories()
                If Not Application("isMediumTrust") Then
                    Try
                        d.Delete(True)
                    Catch ex As Exception
                        strBldrNotDeletedFolders.AppendLine(d.Name)
                    End Try
                Else
                    For Each innerDir As DirectoryInfo In d.GetDirectories()
                        fleLog = innerDir.GetFiles()
                        For i As Integer = 0 To fleLog.Length - 1
                            Try
                                fleLog(i).Delete()
                            Catch ex As Exception
                                strBldrNotDeletedFiles.AppendLine(d.Name).AppendLine(fleLog(i).Name)
                            End Try
                        Next
                    Next
                End If
            Next

        End If
        If Not Application("isMediumTrust") Then
            Return strBldrNotDeletedFolders.ToString()
        End If
        Return strBldrNotDeletedFiles.ToString()

        btnRefresh.Visible = False
    End Function

    Protected Sub btnRefresh_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs) Handles btnRefresh.Click
        Dim strFilePath As String = Server.MapPath("~/" & ConfigurationManager.AppSettings("errorlogpath")) & _
                  "/Errors/" & lbxFiles.SelectedValue
        Dim filReader As New StreamReader(strFilePath)
        Try
            txtFileText.Text = filReader.ReadToEnd()
            filReader.Close()
        Catch ex As Exception
            ClearErrorText()
        End Try
        Try
            filReader.Close()
        Catch ex As Exception
        End Try

    End Sub
End Class
