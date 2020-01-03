'========================================================================
'Kartris - www.kartris.com
'Copyright 2020 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisDataManipulation
Imports CkartrisEnumerations

Partial Class UserControls_Back_QuantityDiscount
    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()

    Public Sub LoadVersionQuantityDiscount(ByVal VersionID As Long)

        litVersionID.Text = CStr(VersionID)

        Dim tblQuantityDiscount As New DataTable
        tblQuantityDiscount = VersionsBLL._GetQuantityDiscountsByVersion(GetVersionID())

        lbxQty.Items.Clear()
        lbxPrice.Items.Clear()
        For Each row As DataRow In tblQuantityDiscount.Rows
            lbxQty.Items.Add(FixNullToDB(row("QD_Quantity"), "g"))
            lbxPrice.Items.Add(FixNullToDB(row("QD_Price"), "g"))
        Next
        ShowQtyDiscount()

    End Sub

    Sub ShowQtyDiscount()
        gvwQtyDiscount.DataSource = Nothing
        gvwQtyDiscount.DataBind()

        Dim tblQuantityDiscount As New DataTable
        tblQuantityDiscount.Columns.Add(New DataColumn("QD_Quantity", Type.GetType("System.Single")))
        tblQuantityDiscount.Columns.Add(New DataColumn("QD_Price", Type.GetType("System.Single")))

        For i As Integer = 0 To lbxQty.Items.Count - 1
            tblQuantityDiscount.Rows.Add(CSng(lbxQty.Items(i).Text), CSng(lbxPrice.Items(i).Text))
        Next

        If tblQuantityDiscount.Rows.Count > 0 Then
            gvwQtyDiscount.DataSource = tblQuantityDiscount
            gvwQtyDiscount.DataBind()
        End If
        updQtyDiscount.Update()

    End Sub

    Private Function GetVersionID() As Long
        If litVersionID.Text <> "" Then
            Return CLng(litVersionID.Text)
        End If
        Return 0
    End Function

    Protected Sub gvwQtyDiscount_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwQtyDiscount.RowCommand
        If e.CommandName = "remove" Then
            lbxQty.Items.RemoveAt(e.CommandArgument)
            lbxPrice.Items.RemoveAt(e.CommandArgument)
            ShowQtyDiscount()
        End If
    End Sub

    Protected Sub gvwQtyDiscount_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwQtyDiscount.RowDataBound
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim litPrice As Literal = CType(e.Row.Cells(1).FindControl("litPrice"), Literal)
            If Not IsNumeric(litPrice.Text) Then Exit Sub
            litPrice.Text = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency(), CSng(litPrice.Text))
            litPrice.Text = _HandleDecimalValues(litPrice.Text)
        End If
    End Sub

    Protected Sub btnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAdd.Click
        Session("inner-tab") = "quantity"
        Dim qty As String = txtQty.Text
        Dim price As String = txtPrice.Text
        If lbxQty.Items.FindByText(qty) Is Nothing Then
            lbxQty.Items.Add(qty)
            lbxPrice.Items.Add(price)
            
            ShowQtyDiscount()
            txtQty.Text = ""
            txtPrice.Text = ""
            txtQty.Focus()
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_AlreadyExists"))
            txtQty.Text = ""
            txtPrice.Text = ""
            txtQty.Focus()
        End If

    End Sub

    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancel.Click
        LoadVersionQuantityDiscount(GetVersionID())
    End Sub

    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.Click
        Dim tblQtyDiscount As New DataTable
        tblQtyDiscount.Columns.Add(New DataColumn("QD_VersionID", Type.GetType("System.Int64")))
        tblQtyDiscount.Columns.Add(New DataColumn("QD_Quantity", Type.GetType("System.Single")))
        tblQtyDiscount.Columns.Add(New DataColumn("QD_Price", Type.GetType("System.Single")))

        For i As Integer = 0 To lbxQty.Items.Count - 1
            tblQtyDiscount.Rows.Add(GetVersionID(), CSng(lbxQty.Items(i).Text), HandleDecimalValues(lbxPrice.Items(i).Text))
        Next

        Dim strMessage As String = ""
        If Not VersionsBLL._UpdateQuantityDiscount(tblQtyDiscount, GetVersionID(), strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            Return
        End If
        ShowQtyDiscount()
        RaiseEvent ShowMasterUpdate()
    End Sub


End Class
