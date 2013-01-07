'[[[NEW COPYRIGHT NOTICE]]]
Imports CkartrisEnumerations

Partial Class Admin_Attributes
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Product", "FormLabel_TabProductAttributes") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        valSummary.ValidationGroup = LANG_ELEM_TABLE_TYPE.Attributes
        lnkBtnSave.ValidationGroup = LANG_ELEM_TABLE_TYPE.Attributes
        ShowAttributeList()

    End Sub

    Protected Sub lnkBtnNewAttribute_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnNewAttribute.Click
        _UC_EditAttribute.EditAttribute(0)
        mvwAttributes.SetActiveView(vwEditAttribute)
        updAttributes.Update()
    End Sub

    Protected Sub gvwAttributes_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwAttributes.PageIndexChanging
        gvwAttributes.PageIndex = e.NewPageIndex
        ShowAttributeList()
    End Sub

    Protected Sub gvwAttributes_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwAttributes.RowCommand
        If e.CommandName = "EditAttribute" Then
            gvwAttributes.SelectedIndex = e.CommandArgument Mod gvwAttributes.PageSize
            _UC_EditAttribute.EditAttribute(CInt(gvwAttributes.SelectedValue()))
            mvwAttributes.SetActiveView(vwEditAttribute)
            updAttributes.Update()
        End If
    End Sub

    Protected Sub lnkBtnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancel.Click
        mvwAttributes.SetActiveView(viwAttributeList)
        updAttributes.Update()
    End Sub

    Protected Sub lnkBtnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSave.Click
        If _UC_EditAttribute.SaveChanges() Then
            ShowAttributeList()
            mvwAttributes.SetActiveView(viwAttributeList)
            updAttributes.Update()
            CType(Me.Master, Skins_Admin_Template).DataUpdated()
        End If
    End Sub

    Protected Sub lnkBtnDelete_Click(sender As Object, e As System.EventArgs) Handles lnkBtnDelete.Click
        _UC_EditAttribute.Delete()
    End Sub

    Private Sub ShowAttributeList()
        Dim tblAttributes As New DataTable
        tblAttributes = AttributesBLL._GetAttributesByLanguage(Session("_LANG"))

        If tblAttributes.Rows.Count = 0 Then mvwAttributeData.SetActiveView(vwNoItems) : Return
        mvwAttributeData.SetActiveView(vwAttributeList)
        tblAttributes.Columns.Add(New DataColumn("ATTRIB_TypeModified", Type.GetType("System.String")))
        tblAttributes.Columns.Add(New DataColumn("ATTRIB_CompareModified", Type.GetType("System.String")))

        For Each row As DataRow In tblAttributes.Rows
            Select Case CChar(row("ATTRIB_Type"))
                Case "t"
                    row("ATTRIB_TypeModified") = GetGlobalResourceObject("_Attributes", "FormLabel_AttributeTypeText")
                Case "d"
                    row("ATTRIB_TypeModified") = GetGlobalResourceObject("_Attributes", "FormLabel_AttributeTypeDropdown")
                Case "c"
                    row("ATTRIB_TypeModified") = GetGlobalResourceObject("_Attributes", "FormLabel_AttributeTypeCheckbox")
            End Select
            Select Case CChar(row("ATTRIB_Compare"))
                Case "a"
                    row("ATTRIB_CompareModified") = GetGlobalResourceObject("_Attributes", "FormLabel_CompareAlways")
                Case "e"
                    row("ATTRIB_CompareModified") = GetGlobalResourceObject("_Attributes", "FormLabel_CompareEvery")
                Case "o"
                    row("ATTRIB_CompareModified") = GetGlobalResourceObject("_Attributes", "FormLabel_CompareOne")
                Case "n"
                    row("ATTRIB_CompareModified") = GetGlobalResourceObject("_Attributes", "FormLabel_CompareNever")
            End Select
        Next

        gvwAttributes.DataSource = tblAttributes
        gvwAttributes.DataBind()
    End Sub

    
    Protected Sub _UC_EditAttribute_AttributeDeleted() Handles _UC_EditAttribute.AttributeDeleted
        ShowAttributeList()
        mvwAttributes.SetActiveView(viwAttributeList)
        updAttributes.Update()
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub
End Class
