'========================================================================
'Kartris - www.kartris.com
'Copyright 2023 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisImages
Imports CkartrisDataManipulation

Partial Class UserControls_Back_AdminDataRemoval
    Inherits System.Web.UI.UserControl

    Public Event BackUpData()

    Sub LoadTablesToBeRemoved(ByVal chrDataType As Char)
        Dim tblTablesToBeRemoved As DataTable = KartrisDBBLL._GetAdminRelatedTables(chrDataType)

        bulTablesToBeRemoved.DataSource = tblTablesToBeRemoved
        bulTablesToBeRemoved.DataTextField = "ShortName"
        bulTablesToBeRemoved.DataBind()
    End Sub

    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSubmit.Click
        Select Case ddlDataToRemove.SelectedValue
            Case "P", "O", "S", "C"
                LoadTablesToBeRemoved(CChar(ddlDataToRemove.SelectedValue))
                mvwAdminRelatedTables.SetActiveView(viwAdminRelatedTablesWarning)
            Case Else
                mvwAdminRelatedTables.SetActiveView(viwAdminRelatedTablesEmpty)
        End Select
    End Sub

    Protected Sub lnkBtnOpenLogin_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnOpenLogin.Click
        _UC_LoginPopup.ShowLogin()
    End Sub

    Sub ClearData(ByVal chrDataType As Char, ByVal strUserName As String, ByVal strPassword As String)
        Dim blnSucceeded As Boolean = False, strOutput As String = ""
        KartrisDBBLL._AdminClearRelatedData(chrDataType, strUserName, strPassword, blnSucceeded, strOutput)
        ddlDataToRemove.SelectedIndex = 0
        If Not blnSucceeded Then
            litError.Text = strOutput
            mvwAdminRelatedTables.SetActiveView(viwAdminRelatedTablesFailed)
        Else
            If chrDataType = "P" Then RemoveProductsRelatedImages()
            RefreshSiteMap()
            litOutput.Text = strOutput
            mvwAdminRelatedTables.SetActiveView(viwAdminRelatedTablesSucceeded)
        End If
        updAdminDataRemoval.Update()
    End Sub

    Protected Sub _UC_LoginPopup_SubmitClicked(ByVal strUserName As String, ByVal strPassword As String) Handles _UC_LoginPopup.SubmitClicked
        Select Case ddlDataToRemove.SelectedValue
            Case "P", "O", "S", "C"
                ClearData(CChar(ddlDataToRemove.SelectedValue), strUserName, strPassword)
        End Select
    End Sub

    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancel.Click
        ddlDataToRemove.SelectedIndex = 0
        mvwAdminRelatedTables.SetActiveView(viwAdminRelatedTablesEmpty)
        updAdminDataRemoval.Update()
    End Sub

    Protected Sub btnBackupNow_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnBackupNow.Click
        RaiseEvent BackUpData()
    End Sub
End Class
