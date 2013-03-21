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
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports KartSettingsManager

Partial Class Admin_GeneralFiles
    Inherits _PageBaseClass

    Dim blnFileSaved As Boolean = False

    Dim strFilesFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "General/"
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Page.IsPostBack Then
            Page.ClientScript.GetPostBackEventReference(Me, String.Empty)
        Else
            Page.Form.Enctype = "multipart/form-data"
            LoadGeneralFiles()
        End If
        Page.Title = GetGlobalResourceObject("_Kartris", "PageTitle_GeneralFiles") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
    End Sub

    Private Sub LoadGeneralFiles()
        Dim dtFiles As New DataTable
        dtFiles.Columns.Add(New DataColumn("F_Name", Type.GetType("System.String")))
        dtFiles.Columns.Add(New DataColumn("F_Type", Type.GetType("System.String")))
        dtFiles.Columns.Add(New DataColumn("F_Size", Type.GetType("System.String")))
        dtFiles.Columns.Add(New DataColumn("F_LastUpdated", Type.GetType("System.String")))

        Dim dirGeneralFiles As New DirectoryInfo(Server.MapPath(strFilesFolder))
        Dim fInfo() As FileInfo
        If Not dirGeneralFiles.Exists() Then Exit Sub
        fInfo = dirGeneralFiles.GetFiles()
        Dim strName As String = "", strType As String = "", _
            strSize As String = "", strLastUpdated As String = ""
        For i As Integer = 0 To fInfo.GetUpperBound(0)
            strName = fInfo(i).Name
            strType = fInfo(i).Extension
            strSize = CStr(fInfo(i).Length() / 1000) & " KB"
            strLastUpdated = CkartrisDisplayFunctions.FormatDate(fInfo(i).LastWriteTime, "t", Session("_LANG"))
            If strName.ToLower = "web.config" Then Continue For
            dtFiles.Rows.Add(strName, strType, strSize, strLastUpdated)
        Next

        If dtFiles.Rows.Count > 0 Then
            gvwFiles.DataSource = dtFiles
            gvwFiles.DataBind()
            mvwGeneralFiles.SetActiveView(viwFiles)
        Else
            mvwGeneralFiles.SetActiveView(viwNoFiles)
        End If
        updFiles.Update()
    End Sub
    Protected Sub gvwFiles_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwFiles.PageIndexChanging
        gvwFiles.PageIndex = e.NewPageIndex
        LoadGeneralFiles()
    End Sub

    Protected Sub lnkUpload_Click(ByVal sender As Object, ByVal e As System.EventArgs) 'Handles lnkUpload.Click
        If filUploader.HasFile Then
            If Not IsFileExist(filUploader.FileName) Then
                '' To avoid saving the file twice
                If Not blnFileSaved Then
                    Try
                        filUploader.SaveAs(Server.MapPath(strFilesFolder & filUploader.FileName))
                        CType(Me.Master, Skins_Admin_Template).DataUpdated()
                        LoadGeneralFiles()
                    Catch ex As Exception
                        litStatus2.Text = ex.Message
                        popExtender2.Show()
                        blnFileSaved = False
                    End Try
                End If
            Else
                litStatus2.Text = GetGlobalResourceObject("_Kartris", "ContentText_AlreadyExists")
                popExtender2.Show()
            End If
        Else
            litStatus2.Text = GetGlobalResourceObject("_Kartris", "ContentText_NoFile")
            popExtender2.Show()
        End If
    End Sub

    Function IsFileExist(strFileName As String) As Boolean
        Dim dirGeneralFiles As New DirectoryInfo(Server.MapPath(strFilesFolder))
        If Not dirGeneralFiles.Exists() Then Directory.CreateDirectory(Server.MapPath(strFilesFolder))
        Dim fInfo() As FileInfo
        fInfo = dirGeneralFiles.GetFiles(strFileName)
        If fInfo.Length > 0 Then Return True
        Return False
    End Function

    Protected Sub btnAdd_Click(sender As Object, e As EventArgs) Handles btnAdd.Click
        popExtender.Show()
    End Sub

    Protected Sub gvwFiles_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvwFiles.RowCommand
        If e.CommandName = "DeleteFile" Then
            hidFileNameToDelete.Value = e.CommandArgument
            Dim strMessage As String = Replace(GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItem"), "[itemname]", _
                                        e.CommandArgument)
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, strMessage)
        End If
    End Sub
    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        If Not String.IsNullOrEmpty(hidFileNameToDelete.Value) Then
            Try
                File.Delete(Server.MapPath(strFilesFolder & hidFileNameToDelete.Value))
                hidFileNameToDelete.Value = ""
                CType(Me.Master, Skins_Admin_Template).DataUpdated()
                LoadGeneralFiles()
            Catch ex As Exception
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, ex.Message)
            End Try
        End If
    End Sub
End Class
