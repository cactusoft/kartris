'========================================================================
'Kartris - www.kartris.com
'Copyright 2024 CACTUSOFT

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
    Private _AutoSelectedOptions() As String

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
                        Else
                            CType(itm.FindControl("chkAttribute"), CheckBox).Checked = False
                        End If
                        ShowHideAttributeRow(itm)

                    Catch ex As Exception
                    End Try
                End If
            Next
            mvwAttributes.SetActiveView(viwAttributes)
            updMain.Update()
        End If

    End Sub

    Protected Sub rptAttributes_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.RepeaterCommandEventArgs) Handles rptAttributes.ItemCommand
        If e.CommandName = "select" Then
            ' Only fires if you press the link button
            ' Toggle the checkbox
            CType(e.Item.FindControl("chkAttribute"), CheckBox).Checked = _
             Not CType(e.Item.FindControl("chkAttribute"), CheckBox).Checked
            ' Show or hide the control
            ShowHideAttributeRow(e.Item)
        ElseIf e.CommandName = "AutoPopulate" Then
            If IsNumeric(e.CommandArgument) AndAlso e.CommandArgument > 0 Then
                AutoPopulateAttributeOptions(e.CommandArgument, _GetProductID(), e.Item)
            End If
        End If
        RaiseEvent NeedCategoryRefresh()
    End Sub

    ''' <summary>
    ''' Find the applicable attribute options and link them here
    ''' </summary>
    ''' <param name="AttributeId"></param>
    ''' <remarks></remarks>
    Private Sub AutoPopulateAttributeOptions(ByVal AttributeId As Integer, ByVal ProductId As Integer, ByVal r As RepeaterItem)
        Dim dtOptions As DataTable = AttributesBLL._GetPotentialAttributeOptionsByProduct(ProductId, AttributeId)
        _AutoSelectedOptions = Nothing
        Dim OptionsList As New List(Of String)
        If Not IsNothing(dtOptions) AndAlso dtOptions.Rows.Count > 0 Then
            For Each dr As DataRow In dtOptions.Rows
                OptionsList.Add(dr("DOA_AttributeOptionID"))
            Next

            _AutoSelectedOptions = OptionsList.ToArray
        End If
        LoadYesNoAttribute(AttributeId, r)
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        btnSave.ValidationGroup = LANG_ELEM_TABLE_TYPE.AttributeValues
        valSummary.ValidationGroup = LANG_ELEM_TABLE_TYPE.AttributeValues
        'If Session("_tab") = "attributes" Then CheckSelectedAttributes()

        If Session("_tab") = "attributes" Then BuildLanguageControls()

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

    ''' <summary>
    ''' Show or hide the controls in the repeater row
    ''' </summary>
    ''' <param name="item"></param>
    ''' <remarks></remarks>
    Private Sub ShowHideAttributeRow(ByRef item As RepeaterItem)
        Dim chkSelected As CheckBox = CType(item.FindControl("chkAttribute"), CheckBox)
        Dim AttributeType As String = CType(item.FindControl("litAttributeType"), Literal).Text
        Dim AttributeID As Integer = CInt(CType(item.FindControl("litAttributeID"), Literal).Text)
        If chkSelected.Checked Then
            If AttributeType = "t" Then
                CType(item.FindControl("mvAttributeData"), MultiView).ActiveViewIndex = 0
                BuildLanguageControls()
            ElseIf AttributeType = "c" Then
                CType(item.FindControl("mvAttributeData"), MultiView).ActiveViewIndex = 1
                LoadYesNoAttribute(AttributeID, item)
            End If
        Else
            ' Deselected
            CType(item.FindControl("mvAttributeData"), MultiView).ActiveViewIndex = 0
            CType(item.FindControl("phdLanguageStrings"), PlaceHolder).Visible = False
        End If
    End Sub

    ''' <summary>
    ''' Build all visible language controls
    ''' </summary>
    ''' <remarks></remarks>
    Private Overloads Sub BuildLanguageControls()

        For Each item As RepeaterItem In rptAttributes.Items
            If CType(item.FindControl("litAttributeType"), Literal).Text = "t" And CType(item.FindControl("chkAttribute"), CheckBox).Checked = True Then
                ' Build this language control
                BuildLanguageControls(item)
            End If
        Next
    End Sub

    ''' <summary>
    ''' The language controls have to be built on each redraw, so they are separated out to here for simplicity.
    ''' </summary>
    ''' <remarks></remarks>
    Private Overloads Sub BuildLanguageControls(ByRef item As RepeaterItem)
        Dim tblAttributeValues As New DataTable
        tblAttributeValues = AttributesBLL._GetAttributeValuesByProduct(_GetProductID())

        If item.ItemType = ListItemType.Item OrElse item.ItemType = ListItemType.AlternatingItem Then
            Try

                ' Show the attribute data.
                Dim AttributeID As Integer = CInt(CType(item.FindControl("litAttributeID"), Literal).Text)
                'Load the attribute so that we can see it's display type (checkbox, text, etc.)
                Dim AttributeType As String = CStr(CType(item.FindControl("litAttributeType"), Literal).Text)
                'Dim dtAttribute As DataTable = AttributesBLL._GetByAttributeID(AttributeID)


                If AttributeType = "t" Then
                    ' Attribute is text
                    Dim mvAttributeData As MultiView = CType(item.FindControl("mvAttributeData"), MultiView)
                    Dim vwLanguage As View = CType(mvAttributeData.FindControl("vwLanguage"), View)
                    mvAttributeData.SetActiveView(vwLanguage)


                    CType(item.FindControl("phdLanguageStrings"), PlaceHolder).Visible = True
                    CType(item.FindControl("updLanguageStrings"), UpdatePanel).Update()

                    Dim arrRowValues() As DataRow = tblAttributeValues.Select("ATTRIBV_AttributeID=" & AttributeID)
                    If arrRowValues.Length = 1 Then
                        CType(item.FindControl("_UC_LangContainer"),
                        _LanguageContainer).CreateLanguageStrings(
                            LANG_ELEM_TABLE_TYPE.AttributeValues, False, CLng(arrRowValues(0)("ATTRIBV_ID")))
                    Else
                        CType(item.FindControl("_UC_LangContainer"),
                        _LanguageContainer).CreateLanguageStrings(
                            LANG_ELEM_TABLE_TYPE.AttributeValues, True)
                    End If
                End If

            Catch ex As Exception
            End Try
        End If
    End Sub

    ''' <summary>
    ''' Load the checked (Yes No) attribute list.
    ''' </summary>
    ''' <param name="AttributeId"></param>
    ''' <remarks></remarks>
    Private Sub LoadYesNoAttribute(ByVal AttributeId As Integer, ByRef itm As RepeaterItem)
        Dim mvAttributeData As MultiView = CType(itm.FindControl("mvAttributeData"), MultiView)
        Dim vwYesNo As View = CType(mvAttributeData.FindControl("vwYesNo"), View)
        mvAttributeData.SetActiveView(vwYesNo)


        Dim rptYesNoOptions As Repeater = CType(mvAttributeData.FindControl("rptYesNoOptions"), Repeater)

        ' All available options
        Dim dtCheckOptions As DataTable = AttributesBLL.GetOptionsByAttributeID(AttributeId)
        dtCheckOptions.Columns.Add("checked", GetType(Boolean))

        For Each dr As DataRow In dtCheckOptions.Rows
            ' Set the default values
            dr("checked") = False
        Next

        ' Options already assigned to this product
        Dim dtProductOptions As DataTable = AttributesBLL.GetAttributeOptionsByProductID(_GetProductID())

        If Not IsNothing(dtProductOptions) Then
            If dtProductOptions.Rows.Count > 0 Then
                ' Some attributes have already been assigned to this product.
                For Each poRow As DataRow In dtProductOptions.Rows
                    For Each aoRow As DataRow In dtCheckOptions.Rows
                        If aoRow("ATTRIBO_ID") = poRow("ATTRIBPO_AttributeOptionID") Then
                            aoRow("checked") = True
                        End If
                    Next
                Next
            End If
        End If

        If Not IsNothing(_AutoSelectedOptions) AndAlso _AutoSelectedOptions.Count > 0 Then
            ' Auto selected options need to be set too.
            For Each aoRow As DataRow In dtCheckOptions.Rows
                If _AutoSelectedOptions.Contains(aoRow("ATTRIBO_ID").ToString) Then
                    aoRow("checked") = True
                End If
            Next
        End If

        rptYesNoOptions.DataSource = dtCheckOptions
        rptYesNoOptions.DataBind()
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

        Dim tblAttributeProductOptions As New DataTable
        tblAttributeProductOptions.Columns.Add(New DataColumn("AttributeId", Type.GetType("System.Int32")))
        tblAttributeProductOptions.Columns.Add(New DataColumn("AttributeOptionId", Type.GetType("System.Int32")))

        Dim tblProductAttribute As New DataTable
        tblProductAttribute.Columns.Add(New DataColumn("ProductID", Type.GetType("System.Int32")))
        tblProductAttribute.Columns.Add(New DataColumn("AttributeID", Type.GetType("System.Int32")))
        tblProductAttribute.Columns.Add(New DataColumn("AttributeType", GetType(String)))

        Dim ProductID As Integer = _GetProductID()
        Dim tblTempContents As DataTable
        Dim AttributeID As Integer = 0
        Dim AttributeType As String = ""
        Dim rptYesNoOptions As Repeater
        Dim litOptionID As Integer

        For Each itm As RepeaterItem In rptAttributes.Items
            If CType(itm.FindControl("chkAttribute"), CheckBox).Checked Then
                AttributeID = CInt(CType(itm.FindControl("litAttributeID"), Literal).Text)
                AttributeType = CType(itm.FindControl("litAttributeType"), Literal).Text
                tblProductAttribute.Rows.Add(CInt(ProductID), CInt(AttributeID), AttributeType)

                ' Save display type specific data.
                If AttributeType = "t" Then
                    tblTempContents = New DataTable
                    tblTempContents = CType(itm.FindControl("_UC_LangContainer"), _LanguageContainer).ReadContent()
                    tblTempContents.Columns.Add(New DataColumn("ProductID", Type.GetType("System.Int32")))
                    tblTempContents.Columns.Add(New DataColumn("AttributeID", Type.GetType("System.Int32")))
                    For Each row As DataRow In tblTempContents.Rows
                        row("ProductID") = CInt(ProductID)
                        row("AttributeID") = CInt(AttributeID)
                    Next

                    tblLanguageElements.Merge(tblTempContents)
                ElseIf AttributeType = "c" Then
                    ' Checked rows (Yes No)
                    rptYesNoOptions = CType(itm.FindControl("rptYesNoOptions"), Repeater)
                    If Not IsNothing(rptYesNoOptions) Then
                        For Each ynRow As RepeaterItem In rptYesNoOptions.Items
                            If CType(ynRow.FindControl("chkAttributeOption"), CheckBox).Checked Then
                                ' Attribute option is checked.
                                litOptionID = CInt(CType(ynRow.FindControl("litOptionID"), Literal).Text)
                                ' Remember this attribute ID as being checked
                                tblAttributeProductOptions.Rows.Add(AttributeID, litOptionID)
                            End If
                        Next
                    End If
                End If
            End If
        Next
        Dim strMessage As String = ""
        If Not AttributesBLL._UpdateAttributeValues(_GetProductID(), tblProductAttribute, tblLanguageElements, tblAttributeProductOptions, strMessage) Then
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

    Protected Sub chkAttribute_CheckedChanged(sender As Object, e As EventArgs) Handles chkAttribute.CheckedChanged
        RaiseEvent NeedCategoryRefresh()
        '    ' We want to either show or hide the row of the repeater based on the state of the checkbox, however, there is no 
        '    ' command argument that can be attached to the checkbox, hence my hacky solution below.
        Dim AttributeId As Integer = sender.Attributes("CommandArgument")       ' Get command argument for checkbox.
        If AttributeId > 0 Then
            For Each item As RepeaterItem In rptAttributes.Items
                If CType(item.FindControl("litAttributeID"), Literal).Text = AttributeId.ToString Then
                    ' This is the required item
                    ShowHideAttributeRow(item)
                End If
            Next
        End If
    End Sub

    'Protected Sub rptAttributes_ItemCreated(sender As Object, e As RepeaterItemEventArgs) Handles rptAttributes.ItemCreated
    '    If e.Item.ItemType = ListItemType.Item Then
    '        ' Link the label and the checkbox if the repeater is a checkbox type.
    '        If CType(e.Item.FindControl("litAttributeType"), Literal).Text = "c" Then

    '        End If
    '    End If
    'End Sub
End Class
