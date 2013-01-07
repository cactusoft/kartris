'[[[NEW COPYRIGHT NOTICE]]]
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports KartSettingsManager
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
            tblExport.Rows.Add(FixNullFromDB(row("V_CodeNumber")), FixNullFromDB(row("V_Name")), _
                               FixNullFromDB(row("V_Quantity")), FixNullFromDB(row("V_QuantityWarnLevel")))
        Next

        CKartrisCSVExporter.WriteToCSV(tblExport, strFileName, 44, 0)
    End Sub
End Class
