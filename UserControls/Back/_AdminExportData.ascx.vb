'========================================================================
'Kartris - www.kartris.com
'Copyright 2018 CACTUSOFT

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

Partial Class UserControls_Back_AdminExportData
    Inherits System.Web.UI.UserControl

    Public Event ExportSaved()

    Protected Sub btnExportOrders_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnExportOrders.Click

        Dim blnParametersAllOK As Boolean = False
        Dim strStartDate As String = Nothing
        Dim strEndDate As String = Nothing
        If IsDate(txtStartDate.Text) Then
            strStartDate = MonthName(CDate(txtStartDate.Text).Month, True) & " " & CDate(txtStartDate.Text).Day & " " & CDate(txtStartDate.Text).Year
        ElseIf IsNumeric(txtStartDate.Text) Then
            strStartDate = CLng(txtStartDate.Text)
        Else
            valCustomStartDate.IsValid = False
        End If        
        If IsDate(txtEndDate.Text) Then
            strEndDate = MonthName(CDate(txtEndDate.Text).Month, True) & " " & CDate(txtEndDate.Text).Day & " " & CDate(txtEndDate.Text).Year
        ElseIf IsNumeric(txtEndDate.Text) Then
            strEndDate = CLng(txtEndDate.Text)
        Else
            valCustomEndDate.IsValid = False
        End If
        'check if start and end fields are both date or isnumeric
        If (IsDate(txtStartDate.Text) And IsDate(txtEndDate.Text)) Or (IsNumeric(txtStartDate.Text) And IsNumeric(txtEndDate.Text)) Then
            blnParametersAllOK = True
        End If

        If blnParametersAllOK Then
            Dim FieldSeparator As Integer = ddlFieldDelimiter.SelectedValue
            Dim StringSeparator As Integer = ddlStringDelimiter.SelectedValue
            Dim tblExportedData As DataTable = ExportBLL._ExportOrders(strStartDate, strEndDate, chkOrderDetails.Checked, chkIncompleteOrders.Checked)
            CKartrisCSVExporter.WriteToCSV(tblExportedData, txtFileName.Text, FieldSeparator, StringSeparator)
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            LoadSavedExports()
        End If
    End Sub

    Protected Sub btnCustomExport_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCustomExport.Click
        CustomExport()
    End Sub

    Sub CustomExport()
        'If txtSqlQuery.Text.ToUpper.StartsWith("SELECT") Then
        Dim FieldSeparator As Integer = ddlCustomFieldDelimiter.SelectedValue
            Dim StringSeparator As Integer = ddlCustomStringDelimiter.SelectedValue
            Dim tblExportedData As DataTable = ExportBLL._CustomExecute(txtSqlQuery.Text)
            CKartrisCSVExporter.WriteToCSV(tblExportedData, txtExportName.Text, FieldSeparator, StringSeparator)
        'End If
    End Sub

    Protected Sub btnSaveExport_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSaveExport.Click
        If _GetExportID() = 0 Then  '' on new
            SaveExport(DML_OPERATION.INSERT)
        Else                        '' on update
            SaveExport(DML_OPERATION.UPDATE)
        End If

    End Sub

    Sub SaveExport(ByVal enumOperation As DML_OPERATION)
        Dim strMessage As String = ""

        Select enumOperation
            Case DML_OPERATION.UPDATE
                If Not ExportBLL._UpdateSavedExport(_GetExportID(), txtExportName.Text, txtSqlQuery.Text, _
                                        ddlCustomFieldDelimiter.SelectedValue, ddlCustomStringDelimiter.SelectedValue, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Exit Sub
                End If
            Case DML_OPERATION.INSERT
                If Not ExportBLL._AddSavedExport(txtExportName.Text, txtSqlQuery.Text, _
                                        ddlCustomFieldDelimiter.SelectedValue, ddlCustomStringDelimiter.SelectedValue, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Exit Sub
                End If
        End Select

        LoadSavedExports()
        tabExport.ActiveTab = tabSavedExports
        ClearFields()
        updMain.Update()
        RaiseEvent ExportSaved()
    End Sub

    Sub LoadSavedExports()
        Dim tblSavedExports As DataTable = ExportBLL._GetSavedExports()
        gvwSavedExports.DataSource = tblSavedExports
        gvwSavedExports.DataBind()
        updSavedExports.Update()
    End Sub

    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancel.Click
        ClearFields()
    End Sub

    Sub ClearFields()
        txtExportName.Text = Nothing
        txtSqlQuery.Text = Nothing
        ddlCustomFieldDelimiter.SelectedIndex = 0
        ddlCustomStringDelimiter.SelectedIndex = 0
        litSavedExportID.Text = "0"
        litSavedExportName.Text = ""
        lnkBtnDelete.Visible = False
        btnCancel.Visible = False
        updCustomExport.Update()
    End Sub

    Function _GetExportID() As Integer
        If Not IsNumeric(litSavedExportID.Text) Then
            litSavedExportID.Text = "0"
        End If
        Return CInt(litSavedExportID.Text)
    End Function

    Protected Sub gvwSavedExports_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwSavedExports.RowCommand
        Select Case e.CommandName
            Case "cmdExport"
                ExportByID(e.CommandArgument)
            Case "cmdEdit"
                LoadSavedExport(e.CommandArgument)
        End Select
    End Sub

    Sub LoadSavedExport(ByVal numExportID As Long)
        Dim tblSavedExport As DataTable = ExportBLL._GetSavedExport(numExportID)
        If tblSavedExport.Rows.Count <> 1 Then Exit Sub
        Dim row As DataRow = tblSavedExport.Rows(0)

        txtExportName.Text = FixNullFromDB(row("Export_Name"))
        txtSqlQuery.Text = FixNullFromDB(row("Export_Details"))
        ddlCustomFieldDelimiter.SelectedValue = FixNullFromDB(row("Export_FieldDelimiter"))
        ddlCustomStringDelimiter.SelectedValue = FixNullFromDB(row("Export_StringDelimiter"))

        lnkBtnDelete.Visible = True
        btnCancel.Visible = True
        litSavedExportID.Text = numExportID
        litSavedExportName.Text = FixNullFromDB(row("Export_Name"))
        tabExport.ActiveTab = tabCustomExport
        updMain.Update()
    End Sub

    Sub ExportByID(ByVal numExportID As Long)
        Dim tblSavedExport As DataTable = ExportBLL._GetSavedExport(numExportID)
        If tblSavedExport.Rows.Count <> 1 Then Exit Sub

        Dim row As DataRow = tblSavedExport.Rows(0)

        Dim tblExportedData As DataTable = ExportBLL._CustomExecute(FixNullFromDB(row("Export_Details")))
        CKartrisCSVExporter.WriteToCSV(tblExportedData, FixNullFromDB(row("Export_Name")), _
                                       FixNullFromDB(row("Export_FieldDelimiter")), FixNullFromDB(row("Export_StringDelimiter")))
    End Sub

    Protected Sub lnkBtnDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDelete.Click
        Dim strMessage As String = Replace(GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItem"), "[itemname]", _
                                        litSavedExportName.Text)
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, strMessage)
    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        Dim strMessage As String = ""
        If ExportBLL._DeleteSavedExport(_GetExportID(), strMessage) Then
            LoadSavedExports()
            ClearFields()
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        End If
    End Sub
End Class
