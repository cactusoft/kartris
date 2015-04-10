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

Partial Class UserControls_Back_ProductAttributes
    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()
    Public Event NeedCategoryRefresh()

    Public Sub ShowProductAttributes()

        Dim tblAttributes As New DataTable
        tblAttributes = AttributesBLL._GetAttributesByLanguage(Session("_LANG"))

        'We add the column to say whether the attribute
        'has value for this product in order to be able to
        'sort by that, so when new attributes are added, we
        'can make them show at the top of the list.
        Dim colExistInTheProduct As New DataColumn("ExistInTheProduct")
        colExistInTheProduct.DefaultValue = False
        tblAttributes.Columns.Add(colExistInTheProduct)

        'Get the attribute values for this product
        Dim tblAttributeValues As New DataTable
        tblAttributeValues = AttributesBLL._GetAttributeValuesByProduct(_GetProductID())

        'We store the number of attributes here so we
        'can use it to determine whether to expand the
        'selected attributes or not. Basically over 50 we
        'will collapse by default, over 50 we will expand
        Dim numAttributesTotal As Integer = CInt(tblAttributes.Rows.Count)
        If numAttributesTotal < 25 Then
            phdOptionsAllSelected.Visible = False
        End If

        'If we display all items, then we want attributes to show in place
        'without sorting. If there is text of items, we want to sort.

        'Loop through all attribute values and then set whether the
        'attribute has values as a new field ExistInTheProduct so 
        'we can sort these to the bottom of the list.
        'If Session("_ProductAttributeFilters") <> "ShowAll" Then
        For Each drwAttributeValue As DataRow In tblAttributeValues.Rows
            For Each drwAttribute As DataRow In tblAttributes.Rows
                If drwAttributeValue("ATTRIBV_AttributeID") = drwAttribute("ATTRIB_ID") Then
                    drwAttribute("ExistInTheProduct") = True
                    Exit For
                End If
            Next

        Next
        'End If

        'Put attributes into datavew so we can sort them, 
        'which is not possible in raw datatable. If less 
        'than 25 attributes, skip this, as we just show all
        'of them.
        Dim dvwAttributes As DataView = New DataView(tblAttributes)
        If Session("_ProductAttributeFilters") <> "ShowAll" And numAttributesTotal >= 25 Then
            Dim strFilterValue As String = ""
            If txtFilterText.Text = "" Then
                strFilterValue = "ExistInTheProduct=True"
            Else
                strFilterValue = "ATTRIB_Name LIKE'%" & txtFilterText.Text & "%' OR ExistInTheProduct=True"
            End If
            dvwAttributes.RowFilter = strFilterValue
            dvwAttributes.Sort = "ExistInTheProduct"
        End If

        If tblAttributes.Rows.Count = 0 Then
            mvwAttributes.SetActiveView(viwNoAttributes)
        Else
            rptAttributes.DataSource = dvwAttributes
            rptAttributes.DataBind()

            For Each itm As RepeaterItem In rptAttributes.Items
                If itm.ItemType = ListItemType.Item OrElse itm.ItemType = ListItemType.AlternatingItem Then
                    Try
                        Dim AttributeID As Integer = CInt(CType(itm.FindControl("litAttributeID"), Literal).Text)
                        Dim arrRowValues() As DataRow = tblAttributeValues.Select("ATTRIBV_AttributeID=" & AttributeID)
                        If arrRowValues.Length = 1 Then
                            CType(itm.FindControl("chkAttribute"), CheckBox).Checked = True
                            CType(itm.FindControl("phdLanguageStrings"), PlaceHolder).Visible = True
                            CType(itm.FindControl("updLanguageStrings"), UpdatePanel).Update()
                            CType(itm.FindControl("_UC_LangContainer"),  _
                            _LanguageContainer).CreateLanguageStrings( _
                                LANG_ELEM_TABLE_TYPE.AttributeValues, False, CLng(arrRowValues(0)("ATTRIBV_ID")))
                        Else
                            CType(itm.FindControl("_UC_LangContainer"),  _
                            _LanguageContainer).CreateLanguageStrings( _
                                LANG_ELEM_TABLE_TYPE.AttributeValues, True)
                        End If
                    Catch ex As Exception
                    End Try
                End If
            Next
            CheckSelectedAttributes()
            mvwAttributes.SetActiveView(viwAttributes)
            updMain.Update()
        End If

    End Sub

    Public Sub RefreshCategoryMenu()
        RaiseEvent NeedCategoryRefresh()
    End Sub

    Protected Sub rptAttributes_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.RepeaterCommandEventArgs) Handles rptAttributes.ItemCommand
        If e.CommandName = "select" Then
            CType(e.Item.FindControl("chkAttribute"), CheckBox).Checked = _
             Not CType(e.Item.FindControl("chkAttribute"), CheckBox).Checked
            CheckSelectedAttributes()
        End If
        RaiseEvent NeedCategoryRefresh()
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        btnSave.ValidationGroup = LANG_ELEM_TABLE_TYPE.AttributeValues
        valSummary.ValidationGroup = LANG_ELEM_TABLE_TYPE.AttributeValues
        If Session("_tab") = "attributes" Then CheckSelectedAttributes()

        'Style the filter links on first load
        If Not Me.IsPostBack Then
            If Session("_ProductAttributeFilters") = "ShowAll" Then
                phdFilterBox.Visible = False
                lnkShowAll.CssClass = "filterselected"
                lnkJustSelected.CssClass = ""
            Else
                phdFilterBox.Visible = True
                lnkShowAll.CssClass = ""
                lnkJustSelected.CssClass = "filterselected"
            End If
        End If
    End Sub

    Protected Sub lnkShowAll_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkShowAll.Click
        Session("_ProductAttributeFilters") = "ShowAll"
        phdFilterBox.Visible = False
        lnkShowAll.CssClass = "filterselected"
        lnkJustSelected.CssClass = ""
        ShowProductAttributes()
        updMain.Update()
    End Sub

    Protected Sub lnkJustSelected_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkJustSelected.Click
        Session("_ProductAttributeFilters") = "JustSelected"
        phdFilterBox.Visible = True
        lnkShowAll.CssClass = ""
        lnkJustSelected.CssClass = "filterselected"
        ShowProductAttributes()
        updMain.Update()
    End Sub

    Protected Sub btnFilterSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnFilterSubmit.Click
        ShowProductAttributes()
        updMain.Update()
    End Sub

    Private Sub CheckSelectedAttributes()
        Dim tblAttributeValues As New DataTable
        tblAttributeValues = AttributesBLL._GetAttributeValuesByProduct(_GetProductID())

        For Each itm As RepeaterItem In rptAttributes.Items
            If itm.ItemType = ListItemType.Item OrElse itm.ItemType = ListItemType.AlternatingItem Then
                Try
                    If CType(itm.FindControl("chkAttribute"), CheckBox).Checked Then
                        CType(itm.FindControl("phdLanguageStrings"), PlaceHolder).Visible = True
                        CType(itm.FindControl("updLanguageStrings"), UpdatePanel).Update()
                        Dim AttributeID As Integer = CInt(CType(itm.FindControl("litAttributeID"), Literal).Text)
                        Dim arrRowValues() As DataRow = tblAttributeValues.Select("ATTRIBV_AttributeID=" & AttributeID)
                        If arrRowValues.Length = 1 Then
                            CType(itm.FindControl("_UC_LangContainer"),  _
                            _LanguageContainer).CreateLanguageStrings( _
                                LANG_ELEM_TABLE_TYPE.AttributeValues, False, CLng(arrRowValues(0)("ATTRIBV_ID")))
                        Else
                            CType(itm.FindControl("_UC_LangContainer"),  _
                            _LanguageContainer).CreateLanguageStrings( _
                                LANG_ELEM_TABLE_TYPE.AttributeValues, True)
                        End If
                    Else
                        CType(itm.FindControl("phdLanguageStrings"), PlaceHolder).Visible = False
                        CType(itm.FindControl("updLanguageStrings"), UpdatePanel).Update()
                    End If
                Catch ex As Exception
                End Try
            End If
        Next
    End Sub

    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.Click
        SaveChanges()
    End Sub

    Private Sub SaveChanges()

        'Clear filter text
        txtFilterText.Text = ""

        Dim tblLanguageElements As New DataTable
        tblLanguageElements.Columns.Add(New DataColumn("_LE_LanguageID", Type.GetType("System.String")))
        tblLanguageElements.Columns.Add(New DataColumn("_LE_FieldID", Type.GetType("System.String")))
        tblLanguageElements.Columns.Add(New DataColumn("_LE_Value", Type.GetType("System.String")))
        tblLanguageElements.Columns.Add(New DataColumn("ProductID", Type.GetType("System.Int32")))
        tblLanguageElements.Columns.Add(New DataColumn("AttributeID", Type.GetType("System.Int32")))

        Dim tblProductAttribute As New DataTable
        tblProductAttribute.Columns.Add(New DataColumn("ProductID", Type.GetType("System.Int32")))
        tblProductAttribute.Columns.Add(New DataColumn("AttributeID", Type.GetType("System.Int32")))


        For Each itm As RepeaterItem In rptAttributes.Items
            If CType(itm.FindControl("chkAttribute"), CheckBox).Checked Then
                Dim AttributeID As Integer = CInt(CType(itm.FindControl("litAttributeID"), Literal).Text)
                Dim ProductID As Integer = _GetProductID()

                Dim tblTempContents As New DataTable
                tblTempContents = CType(itm.FindControl("_UC_LangContainer"), _LanguageContainer).ReadContent()
                tblTempContents.Columns.Add(New DataColumn("ProductID", Type.GetType("System.Int32")))
                tblTempContents.Columns.Add(New DataColumn("AttributeID", Type.GetType("System.Int32")))
                For Each row As DataRow In tblTempContents.Rows
                    row("ProductID") = CInt(ProductID)
                    row("AttributeID") = CInt(AttributeID)
                Next
                tblProductAttribute.Rows.Add(CInt(ProductID), CInt(AttributeID))

                tblLanguageElements.Merge(tblTempContents)
            End If
        Next
        Dim strMessage As String = ""
        If Not AttributesBLL._UpdateAttributeValues(_GetProductID(), tblProductAttribute, tblLanguageElements, strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            Return
        End If

        RaiseEvent ShowMasterUpdate()
    End Sub

    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancel.Click
        ResetAttributeValues()
    End Sub

    Sub ResetAttributeValues()
        ShowProductAttributes()
        updMain.Update()
    End Sub
End Class
