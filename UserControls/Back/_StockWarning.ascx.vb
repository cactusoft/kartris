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
Imports CkartrisDataManipulation
Imports KartSettingsManager
Imports System.Data.OleDb

Partial Class UserControls_Back_StockWarning

    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            'Set number of records per page
            Dim intRowsPerPage As Integer = 25
            Try
                intRowsPerPage = CType(KartSettingsManager.GetKartConfig("backend.display.pagesize"), Double)
            Catch ex As Exception
                'Stays at 25
            End Try
            gvwStockLevel.PageSize = intRowsPerPage

            If ddlSupplier.Items.Count <= 1 Then
                Dim drwSuppliers As DataRow() = GetSuppliersFromCache.Select("SUP_Live = 1")
                ddlSupplier.DataTextField = "SUP_Name"
                ddlSupplier.DataValueField = "SUP_ID"
                ddlSupplier.DataSource = drwSuppliers
                ddlSupplier.DataBind()
            End If
            LoadStockLevel()
        End If
    End Sub

    Private Sub LoadStockLevel()
        Dim tblStockLevel As DataTable
        tblStockLevel = VersionsBLL._GetStockLevel(Session("_LANG"))

        Dim dvwStock As DataView = tblStockLevel.DefaultView
        If ddlSupplier.SelectedValue <> 0 Then
            dvwStock.RowFilter = "P_SupplierID = " & ddlSupplier.SelectedValue
        End If

        gvwStockLevel.DataSource = dvwStock
        gvwStockLevel.DataBind()

        If dvwStock.Count = 0 Then
            mvwStockWarning.SetActiveView(viwNoItems)
        Else
            mvwStockWarning.SetActiveView(viwStockData)
        End If

        updStockLevelList.Update()
    End Sub

    Protected Sub btnSubmitSupplier_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSubmitSupplier.Click
        LoadStockLevel()
    End Sub

    Protected Sub gvwStockLevel_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwStockLevel.PageIndexChanging
        gvwStockLevel.PageIndex = e.NewPageIndex
        LoadStockLevel()
    End Sub

    'Here we do some natty styling of rows with colour,
    'so we can show items that are out of stock differently
    'to those that are just below their warning level, but
    'still in stock
    Private Sub gvwStockLevel_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwStockLevel.RowDataBound
        If e.Row.RowType <> Web.UI.WebControls.DataControlRowType.Header And e.Row.RowType <> Web.UI.WebControls.DataControlRowType.Footer Then
            If e.Row.RowType = DataControlRowType.DataRow Then
                Dim txtStockQty As TextBox = DirectCast(e.Row.FindControl("txtStockQty"), TextBox)
                Dim txtWarnLevel As TextBox = DirectCast(e.Row.FindControl("txtWarnLevel"), TextBox)
                Dim numStockQty As Integer = CInt(txtStockQty.Text)
                Dim numWarnLevel As Integer = CInt(txtWarnLevel.Text)
                If numStockQty <= 0 Then e.Row.CssClass = "Kartris-GridView-Red"
            End If
        End If
    End Sub


    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.Click
        UpdateStockLevel()
    End Sub

    Private Sub UpdateStockLevel()
        Dim tblVersionsToUpdate As New DataTable
        tblVersionsToUpdate.Columns.Add(New DataColumn("VersionID", Type.GetType("System.Int64")))
        tblVersionsToUpdate.Columns.Add(New DataColumn("StockQty", Type.GetType("System.Single")))
        tblVersionsToUpdate.Columns.Add(New DataColumn("WarnLevel", Type.GetType("System.Single")))

        For Each rowStock As GridViewRow In gvwStockLevel.Rows
            If rowStock.RowType = DataControlRowType.DataRow Then
                Dim strStockQty As String = CType(rowStock.Cells(3).FindControl("txtStockQty"), TextBox).Text
                Dim strWarnLevel As String = CType(rowStock.Cells(4).FindControl("txtWarnLevel"), TextBox).Text
                If strStockQty <> "" AndAlso strWarnLevel <> "" Then
                    Dim strVersionID As String = CType(rowStock.Cells(0).FindControl("litVersionID"), Literal).Text
                    tblVersionsToUpdate.Rows.Add(CLng(strVersionID), CSng(strStockQty), CSng(strWarnLevel))

                End If
            End If
        Next
        Dim strMessage As String = ""
        If Not VersionsBLL._UpdateVersionStockLevel(tblVersionsToUpdate, strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        Else
            'success, show updated message
            RaiseEvent ShowMasterUpdate()
            LoadStockLevel()
        End If

    End Sub

    Protected Sub btnExportCSV_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnExportCSV.Click

        Dim tblStockLevel As DataTable
        tblStockLevel = VersionsBLL._GetStockLevel(Session("_LANG"))

        Dim strFileName As String = "Stock Level"
        Dim dvwStock As DataView = tblStockLevel.DefaultView
        If ddlSupplier.SelectedValue <> 0 Then
            dvwStock.RowFilter = "P_SupplierID = " & ddlSupplier.SelectedValue
            strFileName &= " " & ddlSupplier.SelectedItem.Text
        End If

        Dim tblExport As New DataTable
        tblExport.Columns.Add(New DataColumn("SKU", Type.GetType("System.String")))
        tblExport.Columns.Add(New DataColumn("Name", Type.GetType("System.String")))
        tblExport.Columns.Add(New DataColumn("Stock Quantity", Type.GetType("System.Single")))
        tblExport.Columns.Add(New DataColumn("Warning Level", Type.GetType("System.Single")))

        For Each row As DataRow In dvwStock.ToTable.Rows
            tblExport.Rows.Add("""" & Replace(FixNullFromDB(row("V_CodeNumber").ToString), """", """""") & """", """" & Replace(FixNullFromDB(row("V_Name").ToString), """", """""") & """", _
                               FixNullFromDB(row("V_Quantity")), FixNullFromDB(row("V_QuantityWarnLevel")))
        Next

        CKartrisCSVExporter.WriteToCSV(tblExport, strFileName, 44, 0)
    End Sub

    Protected Sub btnUpload_Click(sender As Object, e As System.EventArgs) Handles btnUpload.Click
        If filUpload.HasFile Then
            Dim arrTemp = Split(filUpload.PostedFile.FileName, ".")
            If arrTemp.Length = 0 Then _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_ErrorOnlyXLSorCSV")) : Exit Sub
            Dim numSegments = UBound(arrTemp)
            Dim strFileExt As String = arrTemp(numSegments)

            If strFileExt = "xls" OrElse strFileExt = "csv" Then
                Dim strTempName As String = Guid.NewGuid.ToString & "." & strFileExt
                Dim strFilePath As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "Temp/" & strTempName
                filUpload.SaveAs(Server.MapPath(strFilePath))
                If File.Exists(Server.MapPath(strFilePath)) Then
                    ImportStockLevel(strFilePath)
                    File.Delete(Server.MapPath(strFilePath))
                Else
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgFileUpload"))
                End If
            Else
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_ErrorOnlyXLSorCSV"))
            End If
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgFileUpload"))
        End If
    End Sub

    Sub ImportStockLevel(strFilePath As String)
        Dim connString As String
        Dim connFile As OleDbConnection
        Dim cmd As OleDbCommand
        Dim fi As New FileInfo(Server.MapPath(strFilePath))
        Dim strFileName As String = fi.Name

        'To read .xls files, we need to use the Microsoft 'Jet' driver, which is part of MS Office
        'The problem is, that the Jet 4.0 driver, which is widely used, is not 64-bit compatible, 
        'but lots of servers (probably most in fact) these days are 64-bit. Now you could change
        'the app pool to run 32-bit, and this fixes it. But with Office 2010, there was an updated
        'driver package called 'ACE' released that supports 64-bit. So below, we detect whether the
        'site is running on 64 or 32 bit, and then use the appropriate driver. If you do receive
        'error messages still that the driver is not registered on the local machine, make sure you
        'do have the appropriate driver installed.
        If IntPtr.Size = 8 Then
            '64 bit
            If LCase(strFileName).EndsWith(".xls") Then
                connString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" & Server.MapPath(strFilePath) & _
                            ";Extended Properties='Excel 12.0;HDR=Yes;MAXSCANROWS=1;IMEX=1'"
            Else
                connString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" & Server.MapPath(strFilePath.Replace(strFileName, "")) & _
                            ";Extended Properties='text;HDR=Yes;FMT=Delimited;MAXSCANROWS=1;IMEX=1'"
            End If
        Else
            '32 bit
            If LCase(strFileName).EndsWith(".xls") Then
                connString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & Server.MapPath(strFilePath) & _
                            ";Extended Properties='Excel 8.0;HDR=Yes;MAXSCANROWS=1;IMEX=1'"
            Else
                connString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & Server.MapPath(strFilePath.Replace(strFileName, "")) & _
                            ";Extended Properties='text;HDR=Yes;FMT=Delimited;MAXSCANROWS=1;IMEX=1'"
            End If
        End If


        connFile = New OleDbConnection(connString)
        Try
            connFile.Open()
        Catch ex As Exception
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_ErrorCantReadSheetFile"))
            Exit Sub
        End Try

        If LCase(strFileName).EndsWith(".xls") Then
            Dim strSheetName As String = Nothing
            Dim dtSheets As DataTable = connFile.GetOleDbSchemaTable(OleDb.OleDbSchemaGuid.Tables, Nothing)
            For Each row As DataRow In dtSheets.Rows
                If Not row("Table_Name").ToString().Replace("'", "").EndsWith("$") Then Continue For
                strSheetName = row("Table_Name").ToString().Replace("'", "")
                Exit For
            Next
            If connFile.State = ConnectionState.Open Then connFile.Close()
            If String.IsNullOrEmpty(strSheetName) Then
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_ErrorEmptyXLSFile"))
                Exit Sub
            End If
            cmd = New OleDbCommand("SELECT * FROM [" & strSheetName & "]", connFile)
        Else
            cmd = New OleDbCommand("SELECT * FROM [" & strFileName & "]", connFile)
        End If

        Dim strSKUCode As String = Nothing, strQty As String = Nothing, strWarnLevel As String = Nothing
        Dim intRecords As Integer = 0

        Dim tblVersionsToUpdate As New DataTable
        tblVersionsToUpdate.Columns.Add(New DataColumn("SKU", Type.GetType("System.String")))
        tblVersionsToUpdate.Columns.Add(New DataColumn("StockQty", Type.GetType("System.Single")))
        tblVersionsToUpdate.Columns.Add(New DataColumn("WarnLevel", Type.GetType("System.Single")))
        Dim strMessage As String = Nothing

        If connFile.State <> ConnectionState.Open Then connFile.Open()
        Dim rdr As OleDbDataReader = cmd.ExecuteReader
        Do While rdr.Read()
            If intRecords = 0 AndAlso LCase(strFileName).EndsWith(".xls") Then
                intRecords += 1 : Continue Do
            Else
                Try
                    strSKUCode = FixNullFromDB(rdr("SKU"))
                    strQty = FixNullFromDB(rdr("Stock Quantity"))
                    strWarnLevel = FixNullFromDB(rdr("Warning Level"))

                    '' Check if this is the of records
                    If String.IsNullOrEmpty(strSKUCode) OrElse String.IsNullOrEmpty(strQty) OrElse String.IsNullOrEmpty(strWarnLevel) Then Continue Do

                    If Not IsValidString(strSKUCode) Then Continue Do
                    If Not IsNumeric(strQty) Then Continue Do
                    If Not IsNumeric(strWarnLevel) Then Continue Do

                    tblVersionsToUpdate.Rows.Add(strSKUCode, CSng(strQty), CSng(strWarnLevel))

                Catch ex As Exception
                End Try
                intRecords += 1
            End If
        Loop

        rdr.Close()
        connFile.Close()

        If tblVersionsToUpdate.Rows.Count > 0 Then
            gvwImportStockLevel.DataSource = tblVersionsToUpdate
            gvwImportStockLevel.DataBind()
            gvwImportStockLevel.Visible = True
            btnSaveImport.Visible = True
        Else
            gvwImportStockLevel.Visible = False
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Information, GetGlobalResourceObject("_Kartris", "ContentText_NoItemsFound"))
        End If

    End Sub

    Function IsValidString(ByVal strText As String) As Boolean
        If strText IsNot Nothing Then
            If Not String.IsNullOrEmpty(strText) Then
                Return True
            End If
        End If
        Return False
    End Function

    Protected Sub btnSaveImport_Click(sender As Object, e As System.EventArgs) Handles btnSaveImport.Click
        If gvwImportStockLevel.Rows.Count = 0 Then Exit Sub
        Dim tblVersionsToUpdate As New DataTable
        tblVersionsToUpdate.Columns.Add(New DataColumn("VersionCode", Type.GetType("System.String")))
        tblVersionsToUpdate.Columns.Add(New DataColumn("StockQty", Type.GetType("System.Single")))
        tblVersionsToUpdate.Columns.Add(New DataColumn("WarnLevel", Type.GetType("System.Single")))

        For Each rowStock As GridViewRow In gvwImportStockLevel.Rows
            If rowStock.RowType = DataControlRowType.DataRow Then
                Dim strStockQty As String = CType(rowStock.Cells(1).FindControl("txtStockQty"), TextBox).Text
                Dim strWarnLevel As String = CType(rowStock.Cells(2).FindControl("txtWarnLevel"), TextBox).Text
                If strStockQty <> "" AndAlso strWarnLevel <> "" Then
                    Dim strVersionCode As String = CType(rowStock.Cells(0).FindControl("litVersionCode"), Literal).Text
                    tblVersionsToUpdate.Rows.Add(strVersionCode, CSng(strStockQty), CSng(strWarnLevel))
                End If
            End If
        Next
        Dim strMessage As String = ""
        If Not VersionsBLL._UpdateVersionStockLevelByCode(tblVersionsToUpdate, strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        Else
            'success, show updated message
            RaiseEvent ShowMasterUpdate()
            LoadStockLevel()
            gvwImportStockLevel.Visible = False
        End If
    End Sub
End Class
