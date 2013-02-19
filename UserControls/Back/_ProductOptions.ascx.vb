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
Imports CkartrisDataManipulation
Imports CkartrisDisplayFunctions

Partial Class _ProductOptions
    Inherits System.Web.UI.UserControl

    Public Sub CreateOptionsByGroupID(ByVal pGrpID As Integer, ByVal pProductID As Integer)
        'Reading the Options as they exist in the main table.
        Dim tblOptions As New DataTable
        litOptGrpID.Text = CStr(pGrpID)
        litProductID.Text = pProductID
        tblOptions = OptionsBLL._GetOptionsByGroupID(pGrpID, Session("_LANG"))

        'Used for the Main CheckBox in the Options' List
        tblOptions.Columns.Add(New DataColumn("ExistInTheProduct"))

        Dim tblProductOptions As New DataTable
        tblProductOptions = OptionsBLL._GetOptionsByProductID(pProductID)
        For Each drwOption As DataRow In tblOptions.Rows
            drwOption("ExistInTheProduct") = False
        Next

        'Updating the Options that are to the product
        For Each drwProduct As DataRow In tblProductOptions.Rows
            For Each drwOption As DataRow In tblOptions.Rows
                If drwProduct("P_OPT_OptionID") = drwOption("OPT_ID") Then
                    drwOption("OPT_DefOrderByValue") = drwProduct("P_OPT_OrderByValue")
                    drwOption("OPT_DefPriceChange") = drwProduct("P_OPT_PriceChange")
                    drwOption("OPT_DefWeightChange") = drwProduct("P_OPT_WeightChange")
                    drwOption("OPT_CheckBoxValue") = drwProduct("P_OPT_Selected")
                    drwOption("ExistInTheProduct") = True
                End If
            Next
        Next

        rptOptions.DataSource = tblOptions
        rptOptions.DataBind()
    End Sub

    Protected Sub RadioChanged(ByVal sender As Object, ByVal e As EventArgs)
        Dim btnRadio As New RadioButton
        For Each objItem As RepeaterItem In rptOptions.Items
            If objItem.ItemType = ListItemType.Item OrElse objItem.ItemType = ListItemType.AlternatingItem Then
                btnRadio = CType(objItem.FindControl("btnOptSelected"), RadioButton)
                If Not sender Is btnRadio Then
                    btnRadio.Checked = False
                End If
            End If
        Next
    End Sub

    Public Function GetSelectedOptions() As DataTable
        Dim tblSelectedOptions As New DataTable
        tblSelectedOptions = OptionsBLL._GetProductOptionSchema()

        Dim intOptionID As Integer = 0, intProductID As Integer = 0, intOrderByValue As Integer = 0
        Dim numPriceChanged As Single = 0.0F, numWeightChanged As Single = 0.0F, blnSelected As Boolean = False

        For Each objItem As RepeaterItem In rptOptions.Items


            If CType(objItem.FindControl("_UC_ItemSelection"), UserControls_Back_ItemSelection).IsSelected Then
                intOptionID = CInt(CType(objItem.FindControl("litOptionID"), Literal).Text)
                intProductID = CInt(litProductID.Text)
                intOrderByValue = CInt(CType(objItem.FindControl("txtOptOrderBy"), TextBox).Text)
                numPriceChanged = HandleDecimalValues(CType(objItem.FindControl("txtOptPriceChange"), TextBox).Text)
                numWeightChanged = HandleDecimalValues(CType(objItem.FindControl("txtOptWeightChange"), TextBox).Text)
                If CType(objItem.FindControl("litOptionGroupDisplayType"), Literal).Text = "c" Then
                    blnSelected = CType(objItem.FindControl("chkOptSelected"), CheckBox).Checked
                Else
                    blnSelected = CType(objItem.FindControl("btnOptSelected"), RadioButton).Checked
                End If

                tblSelectedOptions.Rows.Add(intOptionID, intProductID, intOrderByValue, numPriceChanged, numWeightChanged, blnSelected)
            End If
        Next
        Return tblSelectedOptions
    End Function

    Protected Sub ItemSelectionChanged(ByVal sender As UserControls_Back_ItemSelection)
        ItemSelected(rptOptions.Items(sender.GetItemNo()))
    End Sub

    Protected Sub rptOptions_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.RepeaterCommandEventArgs) Handles rptOptions.ItemCommand
        If e.CommandName = "select" Then
            Dim itmSelection As UserControls_Back_ItemSelection
            itmSelection = CType(e.Item.FindControl("_UC_ItemSelection"), UserControls_Back_ItemSelection)
            itmSelection.Checked = Not itmSelection.IsSelected
            ItemSelected(e.Item)
        End If
    End Sub

    Sub ItemSelected(ByVal itmRepeater As RepeaterItem)
        CType(itmRepeater.FindControl("pnlOptions"), Panel).Enabled = _
                CType(itmRepeater.FindControl("_UC_ItemSelection"), UserControls_Back_ItemSelection).IsSelected

    End Sub

    Protected Sub rptOptions_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptOptions.ItemDataBound
        If CType(e.Item.FindControl("litOptionGroupDisplayType"), Literal).Text = "c" Then
            CType(e.Item.FindControl("chkOptSelected"), CheckBox).Visible = True
            CType(e.Item.FindControl("btnOptSelected"), RadioButton).Visible = False
        End If
        If e.Item.ItemType = ListItemType.AlternatingItem OrElse e.Item.ItemType = ListItemType.Item Then
            CType(e.Item.FindControl("txtOptWeightChange"), TextBox).Text = _
                _HandleDecimalValues(CType(e.Item.FindControl("txtOptWeightChange"), TextBox).Text)
            CType(e.Item.FindControl("txtOptPriceChange"), TextBox).Text = _
                _HandleDecimalValues(CType(e.Item.FindControl("txtOptPriceChange"), TextBox).Text)
        End If
        CType(e.Item.FindControl("pnlOptions"), Panel).Enabled = True
    End Sub

End Class
