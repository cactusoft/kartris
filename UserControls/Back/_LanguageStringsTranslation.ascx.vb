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
Imports CkartrisEnumerations
Imports CkartrisFormatErrors
Imports KartSettingsManager
Partial Class UserControls_Back_LanguageStringsTranslation
    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '' The following line is important for the confirmation msg box
        ''  => it will allow the event of the server side button to be fired
        Page.ClientScript.GetPostBackEventReference(Me, String.Empty)

        If Not Page.IsPostBack Then

            ddlFromLanguage.DataSource = GetLanguagesFromCache()
            ddlFromLanguage.DataBind()

            GetToLanguageList()

        End If
    End Sub

    Sub SearchLanguageStringsForTranslation()
        Dim strSearchBy As String = ddlSearchBy.SelectedValue
        Dim strSearchKey As String = txtSearch.Text
        Dim numFromLangID As Byte = CByte(ddlFromLanguage.SelectedValue)
        Dim numToLangID As Byte = CByte(ddlToLanguage.SelectedValue)
        Dim strFrontBack As String = ""
        If chkFront.Checked AndAlso (Not chkBack.Checked) Then
            strFrontBack = "f"
        ElseIf chkBack.Checked AndAlso (Not chkFront.Checked) Then
            strFrontBack = "b"
        Else
            strFrontBack = ""
        End If

        Dim tblLS As New DataTable
        tblLS = LanguageStringsBLL._SearchForUpdate(strSearchBy, strSearchKey, strFrontBack, numFromLangID, numToLangID)

        gvwTranslation.DataSource = tblLS

        If gvwTranslation.Rows.Count = 0 Then gvwTranslation.Visible = False Else gvwTranslation.Visible = True
        gvwTranslation.DataBind()

        updTranslation.Update()

    End Sub

    Public Function GetLanguage(ByVal strToFrom As String) As String
        If strToFrom = "To" Then
            Return ddlToLanguage.SelectedItem.Text
        Else
            Return ddlFromLanguage.SelectedItem.Text
        End If
    End Function

    Protected Sub btnFind_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnFind.Click
        SearchLanguageStringsForTranslation()
        gvwTranslation.Visible = True
        updTranslation.Update()
    End Sub

    Protected Sub ddlFromLanguage_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlFromLanguage.SelectedIndexChanged
        GetToLanguageList()
    End Sub

    Sub GetToLanguageList()
        ddlToLanguage.Items.Clear()
        For Each row As DataRow In GetLanguagesFromCache().Rows
            If CByte(row("LANG_ID")) <> CByte(ddlFromLanguage.SelectedValue) Then
                ddlToLanguage.Items.Add(New ListItem(row("LANG_BackName"), row("LANG_ID")))
            End If
        Next
    End Sub

    Private Function SaveStringTranslation() As Boolean

        Dim chrFrontBack As Char = litLS_FrontBack.Text
        Dim strStringName As String = litLS_Name.Text
        Dim strStringValue As String = txtValue.Text
        Dim strStringDescription As String = txtDesc.Text

        Dim strMessage As String = Nothing

        Try
            If Not LanguageStringsBLL._TranslateLanguageString(chrFrontBack, strStringName, _
                strStringValue, strStringDescription, ddlToLanguage.SelectedValue, strMessage) Then
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                Return False
            End If

            RaiseEvent ShowMasterUpdate()
            Return True
        Catch ex As SqlException
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMessage)
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMessage)
        End Try

        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)

        Return False
    End Function

    Protected Sub lnkSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkSave.Click
        If SaveStringTranslation() Then SearchLanguageStringsForTranslation()
    End Sub

    Protected Sub gvwTranslation_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwTranslation.PageIndexChanging
        gvwTranslation.PageIndex = e.NewPageIndex
        SearchLanguageStringsForTranslation()
    End Sub

    Protected Sub gvwTranslation_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvwTranslation.SelectedIndexChanged
        litLS_FrontBack.Text = gvwTranslation.SelectedRow.Cells(1).Text
        litLS_Name.Text = gvwTranslation.SelectedRow.Cells(2).Text
        litLS_Value.Text = CType(gvwTranslation.SelectedRow.Cells(3).FindControl("litFromValue"), Literal).Text
        litLS_Description.Text = CType(gvwTranslation.SelectedRow.Cells(3).FindControl("litFromDesc"), Literal).Text
        txtValue.Text = CType(gvwTranslation.SelectedRow.Cells(4).FindControl("litToValue"), Literal).Text
        txtDesc.Text = CType(gvwTranslation.SelectedRow.Cells(4).FindControl("litToDesc"), Literal).Text

        litFromLanguageName2.Text = GetLanguage("From")
        litFromLanguageName3.Text = GetLanguage("From")
        litToLanguageName2.Text = GetLanguage("To")
        litToLanguageName3.Text = GetLanguage("To")
        popExtender.Show()
    End Sub
End Class
