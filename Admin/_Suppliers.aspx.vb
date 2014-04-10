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
Imports System.Web.HttpContext

Partial Class Admin_Suppliers

    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetGlobalResourceObject("_Suppliers", "PageTitle_Suppliers") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
        If Not Page.IsPostBack Then GetSuppliersList()
    End Sub

    Sub GetSuppliersList()
        mvwSuppliersData.SetActiveView(viwSuppliersList)

        gvwSuppliers.DataSource = Nothing
        gvwSuppliers.DataBind()

        Dim tblSuppliersList As New DataTable
        tblSuppliersList = GetSuppliersFromCache()

        If tblSuppliersList.Rows.Count = 0 Then mvwSuppliersData.SetActiveView(viwNoItems)

        gvwSuppliers.DataSource = tblSuppliersList
        gvwSuppliers.DataBind()

    End Sub

    Protected Sub gvwSuppliers_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwSuppliers.PageIndexChanging
        gvwSuppliers.PageIndex = e.NewPageIndex
        GetSuppliersList()
    End Sub

    Private Sub gvwSuppliers_RowCommand(ByVal src As Object, ByVal e As GridViewCommandEventArgs) Handles gvwSuppliers.RowCommand
        Select Case e.CommandName
            Case "EditSupplier"
                gvwSuppliers.SelectedIndex = CInt(e.CommandArgument) - (gvwSuppliers.PageSize * gvwSuppliers.PageIndex)
                litSupplierID.Text = gvwSuppliers.SelectedValue
                PrepareExistingSupplier()
            Case "viwLinkedProducts"
                gvwSuppliers.SelectedIndex = CInt(e.CommandArgument) - (gvwSuppliers.PageSize * gvwSuppliers.PageIndex)
                litSupplierID.Text = gvwSuppliers.SelectedValue
                GetLinkedProducts()
        End Select
    End Sub

    Private Sub GetLinkedProducts()
        pnlNoLinkedProducts.Visible = False
        gvwLinkedProducts.DataSource = Nothing
        gvwLinkedProducts.DataBind()

        Dim tblLinkedProducts As New DataTable
        tblLinkedProducts = ProductsBLL._GetProductsBySupplier(Session("_LANG"), GetSupplierID())

        If tblLinkedProducts.Rows.Count = 0 Then
            pnlNoLinkedProducts.Visible = True
            gvwLinkedProducts.Visible = False
        Else
            pnlNoLinkedProducts.Visible = False
            gvwLinkedProducts.Visible = True
            gvwLinkedProducts.DataSource = tblLinkedProducts
            gvwLinkedProducts.DataBind()
        End If

        mvwSuppliers.SetActiveView(viwLinkedProducts)
        updSupplierDetails.Update()

    End Sub

    Protected Sub lnkBtnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancel.Click
        litSupplierID.Text = "0"
        mvwSuppliers.SetActiveView(viwSuppliersData)
        updSupplierDetails.Update()
    End Sub

    Protected Sub lnkBtnNewSupplier_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnNewSupplier.Click
        PrepareNewSupplier()
    End Sub

    Protected Sub lnkBtnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSave.Click
        '' calling the save method for (INSERT/UPDATE)
        If GetSupplierID() = 0 Then '' new
            If Not SaveSupplier(DML_OPERATION.INSERT) Then Return
        Else                        '' update
            If Not SaveSupplier(DML_OPERATION.UPDATE) Then Return
        End If

        'Show animated 'updated' message


        CType(Me.Master, Skins_Admin_Template).DataUpdated()

        GetSuppliersList()

        litSupplierID.Text = "0"
        mvwSuppliers.SetActiveView(viwSuppliersData)
        updSupplierDetails.Update()
    End Sub

    Function SaveSupplier(ByVal enumOperation As DML_OPERATION) As Boolean

        Dim strSupplierName As String = txtSupplierName.Text
        Dim blnLive As Boolean = chkSupplierLive.Checked

        Dim strMessage As String = ""
        Select Case enumOperation
            Case DML_OPERATION.UPDATE
                If Not UsersBLL._UpdateSuppliers(GetSupplierID(), strSupplierName, blnLive, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
            Case DML_OPERATION.INSERT
                If Not UsersBLL._AddSuppliers(strSupplierName, blnLive, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
        End Select

        RefreshSuppliersCache()
        Return True

    End Function

    Private Function GetSupplierID() As Integer
        If litSupplierID.Text <> "" Then
            Return CLng(litSupplierID.Text)
        End If
        Return 0
    End Function

    Sub PrepareNewSupplier()
        litSupplierID.Text = "0"
        txtSupplierName.Text = Nothing
        chkSupplierLive.Checked = False
        mvwSuppliers.SetActiveView(viwDetails)
        updSupplierDetails.Update()
    End Sub

    Sub PrepareExistingSupplier()
        chkSupplierLive.Checked = DirectCast(gvwSuppliers.SelectedRow.Cells(1).FindControl("chkSup_Live"), CheckBox).Checked
        txtSupplierName.Text = gvwSuppliers.SelectedRow.Cells(0).Text
        mvwSuppliers.SetActiveView(viwDetails)
        updSupplierDetails.Update()
    End Sub

    Protected Sub lnkBtnHideLinkedProducts_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnHideLinkedProducts.Click
        mvwSuppliers.SetActiveView(viwSuppliersData)
    End Sub

    Protected Sub gvwLinkedProducts_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwLinkedProducts.PageIndexChanging
        gvwLinkedProducts.PageIndex = e.NewPageIndex
        GetLinkedProducts()
    End Sub
End Class
