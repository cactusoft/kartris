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
Imports CkartrisDataManipulation
Imports CkartrisEnumerations
Partial Class UserControls_Back_RelatedProducts

    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()

    Public Sub LoadRelatedProducts()
        lbxRelatedProducts.Items.Clear()
        Dim tblRelatedProducts As DataTable = ProductsBLL._GetRelatedProductsByParent(_GetProductID())
        For Each row As DataRow In tblRelatedProducts.Rows
            AddProductToList(row("RP_ChildID"))
        Next
    End Sub

    Private Sub AddProductToList(ByVal intProductID As Integer)

        If lbxRelatedProducts.Items.FindByValue(CStr(intProductID)) Is Nothing Then
            Dim strItemName As String = ProductsBLL._GetNameByProductID(intProductID, 1)
            If Not strItemName Is Nothing Then
                lbxRelatedProducts.Items.Add(New ListItem(strItemName, CStr(intProductID)))
            Else
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidValue"))
            End If
        End If
        ReLoadRelatedProducts()

    End Sub

    Private Sub RemoveProductFromList(ByVal intProductID As Integer)
        If Not lbxRelatedProducts.Items.FindByValue(CStr(intProductID)) Is Nothing Then
            lbxRelatedProducts.Items.Remove(lbxRelatedProducts.Items.FindByValue(CStr(intProductID)))
        End If
        ReLoadRelatedProducts()
    End Sub

    Private Sub ReLoadRelatedProducts()

        Dim tblRelatedProducts As New DataTable
        tblRelatedProducts.Columns.Add(New DataColumn("ProductID", Type.GetType("System.Int32")))
        tblRelatedProducts.Columns.Add(New DataColumn("ProductName", Type.GetType("System.String")))

        For Each itm As ListItem In lbxRelatedProducts.Items
            tblRelatedProducts.Rows.Add(CInt(itm.Value), itm.Text)
        Next
        If tblRelatedProducts.Rows.Count > 0 Then
            phdProductsList.Visible = True
        Else
            phdProductsList.Visible = False
        End If
        gvwRelatedProducts.DataSource = tblRelatedProducts
        gvwRelatedProducts.DataBind()
        updRelatedProducts.Update()

    End Sub

    Protected Sub btnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAdd.Click
        If txtProduct.Text <> "" Then
            CheckAutoCompleteData()
            txtProduct.Text = ""
        End If
    End Sub

    Sub CheckAutoCompleteData()
        Dim strAutoCompleteText As String = ""
        Dim numItemID As Integer = 0
        Dim strItemName As String = ""
        strAutoCompleteText = txtProduct.Text

        'Find position of the last open bracket, we use this to locate
        'the item number in the string. Works even if the cat name has
        'open brackets in, because we always look for the last only.
        Dim numIndex = strAutoCompleteText.LastIndexOf("(")

        If strAutoCompleteText <> "" AndAlso strAutoCompleteText.Contains("(") _
                AndAlso strAutoCompleteText.Contains(")") Then
            Try
                'We want to get the number in brackets, which is at the end of the string.
                'Find the last open brack in string (there might be more than one!) then
                'we can grab everything after that and remove the closing brack to find
                'our number.
                numItemID = CInt(Replace(Mid(strAutoCompleteText, numIndex + 2), ")", ""))

                If numItemID <> _GetProductID() Then AddProductToList(numItemID)
            Catch ex As Exception
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidValue") & " - " & Replace(Mid(strAutoCompleteText, numIndex + 2), ")", ""))
            End Try
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidValue"))
        End If

    End Sub

    Protected Sub gvwRelatedProducts_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwRelatedProducts.RowCommand
        Select Case e.CommandName
            Case "EditRelatedProducts"
                Session("tab") = "related_products"
                Response.Redirect("~/Admin/_ModifyProduct.aspx?ProductID=" & e.CommandArgument)
            Case "RemoveProduct"
                RemoveProductFromList(e.CommandArgument)
        End Select
    End Sub

    Protected Sub btnSaveChanges_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSaveChanges.Click
        SaveChanges()
    End Sub

    Sub SaveChanges()

        Dim tblRelatedProducts As New DataTable
        tblRelatedProducts.Columns.Add(New DataColumn("RP_ParentID", Type.GetType("System.Int32")))
        tblRelatedProducts.Columns.Add(New DataColumn("RP_ChildID", Type.GetType("System.Int32")))

        Dim strChildProducts As String = ""
        Dim sbdChildList As New StringBuilder()

        For Each itmRelatedProduct As ListItem In lbxRelatedProducts.Items
            sbdChildList.Append(itmRelatedProduct.Value)
            sbdChildList.Append(",")
        Next

        Dim strMessage As String = ""
        If Not ProductsBLL._UpdateRelatedProducts(_GetProductID(), sbdChildList.ToString(), strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            Return
        End If

        RaiseEvent ShowMasterUpdate()
    End Sub
End Class
