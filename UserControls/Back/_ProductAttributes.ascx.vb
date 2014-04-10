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
Imports CkartrisDataManipulation

Partial Class UserControls_Back_ProductAttributes
    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()
    Public Event NeedCategoryRefresh()

    Public Sub ShowProductAttributes()

        Dim tblAttributes As New DataTable
        tblAttributes = AttributesBLL._GetAttributesByLanguage(Session("_LANG"))

        If tblAttributes.Rows.Count = 0 Then
            mvwAttributes.SetActiveView(viwNoAttributes)
        Else
            rptAttributes.DataSource = tblAttributes
            rptAttributes.DataBind()

            Dim tblAttributeValues As New DataTable
            tblAttributeValues = AttributesBLL._GetAttributeValuesByProduct(_GetProductID())
            For Each itm As RepeaterItem In rptAttributes.Items
                If itm.ItemType = ListItemType.Item OrElse itm.ItemType = ListItemType.AlternatingItem Then
                    Try
                        Dim AttributeID As Byte = CByte(CType(itm.FindControl("litAttributeID"), Literal).Text)
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
                        Dim AttributeID As Byte = CByte(CType(itm.FindControl("litAttributeID"), Literal).Text)
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

        Dim tblLanguageElements As New DataTable
        tblLanguageElements.Columns.Add(New DataColumn("_LE_LanguageID", Type.GetType("System.String")))
        tblLanguageElements.Columns.Add(New DataColumn("_LE_FieldID", Type.GetType("System.String")))
        tblLanguageElements.Columns.Add(New DataColumn("_LE_Value", Type.GetType("System.String")))
        tblLanguageElements.Columns.Add(New DataColumn("ProductID", Type.GetType("System.Int32")))
        tblLanguageElements.Columns.Add(New DataColumn("AttributeID", Type.GetType("System.Byte")))

        Dim tblProductAttribute As New DataTable
        tblProductAttribute.Columns.Add(New DataColumn("ProductID", Type.GetType("System.Int32")))
        tblProductAttribute.Columns.Add(New DataColumn("AttributeID", Type.GetType("System.Byte")))


        For Each itm As RepeaterItem In rptAttributes.Items
            If CType(itm.FindControl("chkAttribute"), CheckBox).Checked Then
                Dim AttributeID As Integer = CInt(CType(itm.FindControl("litAttributeID"), Literal).Text)
                Dim ProductID As Integer = _GetProductID()

                Dim tblTempContents As New DataTable
                tblTempContents = CType(itm.FindControl("_UC_LangContainer"), _LanguageContainer).ReadContent()
                tblTempContents.Columns.Add(New DataColumn("ProductID", Type.GetType("System.Int32")))
                tblTempContents.Columns.Add(New DataColumn("AttributeID", Type.GetType("System.Byte")))
                For Each row As DataRow In tblTempContents.Rows
                    row("ProductID") = CInt(ProductID)
                    row("AttributeID") = CByte(AttributeID)
                Next
                tblProductAttribute.Rows.Add(CInt(ProductID), CByte(AttributeID))

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
