'========================================================================
'Kartris - www.kartris.com
'Copyright 2017 CACTUSOFT

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

Partial Class Admin_FeaturedProducts

    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Kartris", "PageTitle_FeaturedProducts") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Page.IsPostBack Then
            LoadFeaturedProducts()
            Dim numMax As Short = CInt(GetKartConfig("frontend.featuredproducts.display.max"))
            Select Case numMax
                Case 0
                    litMaxNumberToDisplay.Text = GetGlobalResourceObject("_Kartris", "ContentText_None")
                Case -1
                    litMaxNumberToDisplay.Text = GetGlobalResourceObject("_Kartris", "ContentText_Unlimited")
                Case Else
                    litMaxNumberToDisplay.Text = numMax
            End Select
        End If
    End Sub

    Private Sub LoadFeaturedProducts()
        mvwFeaturedProducts.SetActiveView(viwProductList)
        lbxFeaturedProducts.Items.Clear()
        Try
            Dim tblFeaturedProducts As DataTable = ProductsBLL._GetFeaturedProducts(Session("_LANG"))
            If tblFeaturedProducts.Rows.Count = 0 Then mvwFeaturedProducts.SetActiveView(viwNoItems)
            If tblFeaturedProducts.Rows.Count > 0 Then
                tblFeaturedProducts.DefaultView.Sort = "ProductPriority DESC"
            End If
            For Each rowProduct As DataRow In tblFeaturedProducts.Rows
                AddProductToList(rowProduct("ProductID"), rowProduct("ProductName"), rowProduct("ProductPriority"))
            Next
        Catch ex As Exception
            'Can happen if no featured products
        End Try
    End Sub

    Private Sub AddProductToList(ByVal intProductID As Integer, ByVal strProductName As String, ByVal intPriority As Byte)

        'Add item if ID is not already there
        If lbxFeaturedProducts.Items.FindByValue(CStr(intProductID)) Is Nothing Then
            Dim intIndex As Integer = 0
            Dim blnAdded As Boolean = False
            For Each itmProduct As ListItem In lbxFeaturedPriorities.Items
                If itmProduct.Value <= intPriority Then
                    lbxFeaturedProducts.Items.Insert(intIndex, New ListItem(strProductName, intProductID))
                    lbxFeaturedPriorities.Items.Insert(intIndex, New ListItem(intProductID, intPriority))
                    blnAdded = True
                    Exit For
                End If
                intIndex += 1
            Next
            If blnAdded = False Then
                lbxFeaturedProducts.Items.Add(New ListItem(strProductName, intProductID))
                lbxFeaturedPriorities.Items.Add(New ListItem(intProductID, intPriority))
            End If
            ReLoadFeaturedProducts()
        End If
        'ReLoadFeaturedProducts()

    End Sub

    Private Sub RemoveProductFromList(ByVal intProductID As Integer)
        If Not lbxFeaturedProducts.Items.FindByValue(CStr(intProductID)) Is Nothing Then
            lbxFeaturedProducts.Items.Remove(lbxFeaturedProducts.Items.FindByValue(CStr(intProductID)))
            lbxFeaturedPriorities.Items.Remove(lbxFeaturedPriorities.Items.FindByText(CStr(intProductID)))
        End If
        ReLoadFeaturedProducts()
    End Sub

    Private Sub ReLoadFeaturedProducts()

        Dim tblFeaturedProducts As New DataTable
        tblFeaturedProducts.Columns.Add(New DataColumn("ProductID", Type.GetType("System.Int32")))
        tblFeaturedProducts.Columns.Add(New DataColumn("ProductName", Type.GetType("System.String")))
        tblFeaturedProducts.Columns.Add(New DataColumn("ProductPriority", Type.GetType("System.Byte")))

        For Each itmProduct As ListItem In lbxFeaturedProducts.Items
            tblFeaturedProducts.Rows.Add(CInt(itmProduct.Value), itmProduct.Text, lbxFeaturedPriorities.Items.FindByText(itmProduct.Value).Value)
        Next
        If tblFeaturedProducts.Rows.Count = 0 Then
            mvwFeaturedProducts.SetActiveView(viwNoItems)
            'phdProductsList.Visible = True
        Else
            mvwFeaturedProducts.SetActiveView(viwProductList)
            'phdProductsList.Visible = False

            gvwFeaturedProducts.DataSource = tblFeaturedProducts
            gvwFeaturedProducts.DataBind()
        End If

        updFeaturedProducts.Update()

    End Sub

    Protected Sub btnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAdd.Click
        If txtProduct.Text <> "" Then
            CheckAutoCompleteData()
            txtProduct.Text = ""
            txtFeaturedLevel.Text = ""
        End If
    End Sub

    Sub CheckAutoCompleteData()
        Dim strAutoCompleteText As String = ""
        Dim numItemID As Integer = 0
        Dim strItemName As String = ""
        strAutoCompleteText = txtProduct.Text
        Dim numIndex = strAutoCompleteText.LastIndexOf("(")

        If txtFeaturedLevel.Text > 0 Then
            If strAutoCompleteText <> "" AndAlso strAutoCompleteText.Contains("(") _
                AndAlso strAutoCompleteText.Contains(")") Then
                Try
                    numItemID = CInt(Replace(Mid(strAutoCompleteText, numIndex + 2), ")", ""))

                    If ProductsBLL._GetCustomerGroup(numItemID) <> 0 Then
                        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_ProductLimitedToCustomerGroupAsFeatured"))
                        Exit Sub
                    End If
                    AddProductToList(numItemID, Left(strAutoCompleteText, numIndex - 1), txtFeaturedLevel.Text)
                Catch ex As Exception
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidValue"))
                End Try
            Else
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidValue"))
            End If
        End If
    End Sub

    Protected Sub gvwFeaturedProducts_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwFeaturedProducts.RowCommand
        Select Case e.CommandName
            Case "EditFeaturedProducts"
                Session("tab") = "Featured_products"
                Response.Redirect("~/Admin/_ModifyProduct.aspx?ProductID=" & e.CommandArgument)
            Case "ChangePriority"
                Dim strNewPriority As String = CType(gvwFeaturedProducts.Rows(e.CommandArgument).Cells(1).FindControl("txtPriority"), TextBox).Text
                If IsNumeric(strNewPriority) Then
                    ChangePriority(CShort(e.CommandArgument), CInt(strNewPriority))
                Else
                    CType(gvwFeaturedProducts.Rows(e.CommandArgument).Cells(1).FindControl("txtPriority"), TextBox).Text = ""
                    Return
                End If
            Case "RemoveProduct"
                RemoveProductFromList(e.CommandArgument)
        End Select
    End Sub

    Sub ChangePriority(ByVal numIndx As Short, ByVal numNewPriority As Integer)
        Dim numPID As Integer = lbxFeaturedProducts.Items(numIndx).Value
        Dim strPName As String = lbxFeaturedProducts.Items(numIndx).Text
        RemoveProductFromList(numPID)
        AddProductToList(numPID, strPName, numNewPriority)
    End Sub

    Protected Sub btnSaveChanges_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSaveChanges.Click
        SaveChanges()
    End Sub

    Sub SaveChanges()

        Dim tblFeaturedProducts As New DataTable
        tblFeaturedProducts.Columns.Add(New DataColumn("ProductID", Type.GetType("System.Int32")))
        tblFeaturedProducts.Columns.Add(New DataColumn("Priority", Type.GetType("System.Byte")))

        For Each itm As ListItem In lbxFeaturedPriorities.Items
            tblFeaturedProducts.Rows.Add(CInt(itm.Text), CByte(itm.Value))
        Next
        
        Dim strMessage As String = ""
        If Not ProductsBLL._UpdateFeaturedProducts(tblFeaturedProducts, strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            Return
        End If

        RefreshFeaturedProductsCache()
        CType(Me.Master, Skins_Admin_Template).DataUpdated()

    End Sub

End Class
