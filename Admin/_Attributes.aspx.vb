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
Imports CkartrisFormatErrors

Partial Class Admin_Attributes
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Product", "FormLabel_TabProductAttributes") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        valSummary.ValidationGroup = LANG_ELEM_TABLE_TYPE.Attributes
        lnkBtnSave.ValidationGroup = LANG_ELEM_TABLE_TYPE.Attributes
        ShowAttributeList("")

        If dtlOptions.Controls.Count > 0 Then
            '' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            '' Loading the LanguageStrings for the Options' Part
            Dim ctlOptFooter As Control = dtlOptions.Controls(dtlOptions.Controls.Count - 1)
            CType(ctlOptFooter.FindControl("_UC_LangContainer_NewOption"),  _
                   _LanguageContainer).CreateLanguageStrings( _
                    LANG_ELEM_TABLE_TYPE.AttributeOption, True, 0)
            If dtlOptions.SelectedIndex <> -1 Then
                Dim numOptionID As Integer = CInt(CType(dtlOptions.SelectedItem.FindControl("litOptionID"), Literal).Text)
                CType(dtlOptions.SelectedItem.FindControl("_UC_LangContainer_SelectedOption"),  _
                         _LanguageContainer).CreateLanguageStrings( _
                         LANG_ELEM_TABLE_TYPE.AttributeOption, False, numOptionID)
            End If
        End If


        If Page.Form.Enctype <> "multipart/form-data" Then
            ' In this form there is a repeater with a file uploader. Becuase of the lifecycle of this page, the file upload control
            ' cannot set the form encoding type at the correct time. For this reason we set the encoding type to Multipart at this point.
            ' which is the required encoding type for file uploads.
            Page.Form.Enctype = "multipart/form-data"
        End If

    End Sub

    Protected Sub lnkBtnNewAttribute_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnNewAttribute.Click
        _UC_EditAttribute.EditAttribute(0)
        mvwAttributes.SetActiveView(vwEditAttribute)
        updAttributes.Update()
    End Sub

    Protected Sub gvwAttributes_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwAttributes.PageIndexChanging
        gvwAttributes.PageIndex = e.NewPageIndex
        'ShowAttributeList(txtSearch.Text)
    End Sub

    Protected Sub gvwAttributes_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwAttributes.RowCommand
        If e.CommandName = "EditAttribute" Then
            gvwAttributes.SelectedIndex = e.CommandArgument Mod gvwAttributes.PageSize
            _UC_EditAttribute.EditAttribute(CInt(gvwAttributes.SelectedValue()))
            mvwAttributes.SetActiveView(vwEditAttribute)
            updAttributes.Update()
        ElseIf e.CommandName = "EditValues" Then
            mvwAttributes.SetActiveView(vwEditValues)
            litAttribID.Text = e.CommandArgument
            LoadAttributeOptions(CInt(e.CommandArgument))
            updAttributes.Update()
        End If
    End Sub

    ''' <summary>
    ''' If an attribute option was selected, cancel this.
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub CancelOptionSelection()
        dtlOptions.SelectedIndex = -1
    End Sub

    ''' <summary>
    ''' Load options for a given attribute
    ''' </summary>
    ''' <param name="AttributeId"></param>
    ''' <remarks>Works for checklist and dropdown option lists</remarks>
    Private Sub LoadAttributeOptions(ByVal AttributeId As Integer)
        Dim dtOptions As DataTable = AttributesBLL.GetOptionsByAttributeID(AttributeId)

        ' Add data that is not alreaddy in the table.
        dtOptions.Columns.Add("ATTRIB_ID", GetType(Integer))
        dtOptions.Columns.Add("ImageURL", GetType(String))
        For Each dr As DataRow In dtOptions.Rows
            dr("ATTRIB_ID") = AttributeId
        Next

        dtlOptions.DataSource = dtOptions
        dtlOptions.DataBind()
    End Sub

    Protected Sub lnkBtnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancel.Click
        mvwAttributes.SetActiveView(viwAttributeList)
        updAttributes.Update()
    End Sub

    Protected Sub lnkBtnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSave.Click
        If _UC_EditAttribute.SaveChanges() Then
            ShowAttributeList("")
            mvwAttributes.SetActiveView(viwAttributeList)
            updAttributes.Update()
            CType(Me.Master, Skins_Admin_Template).DataUpdated()
        End If
    End Sub

    Protected Sub lnkBtnDelete_Click(sender As Object, e As System.EventArgs) Handles lnkBtnDelete.Click
        _UC_EditAttribute.Delete()
    End Sub

    ''' <summary>
    ''' Close any add or edit controls and show the options.
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub ShowAttributeOptions(ByVal AttributeId As Integer)


        Dim ctlFooter As Control = dtlOptions.Controls(dtlOptions.Controls.Count - 1)
        CType(ctlFooter.FindControl("phdNewItem"), PlaceHolder).Visible = False
        LoadAttributeOptions(AttributeId)
        updEditValues.Update()
    End Sub

    ''' <summary>
    ''' Prepare the area for editing an existing option
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub PrepareEditOptionEntry(Optional ByVal OptionIndex As Integer = -1)
        If OptionIndex > -1 Then
            dtlOptions.SelectedIndex = OptionIndex
        End If
        Dim ctlFooter As Control = dtlOptions.Controls(dtlOptions.Controls.Count - 1)
        If Not IsNothing(ctlFooter) Then
            If CType(ctlFooter.FindControl("phdNewItem"), PlaceHolder).Visible = True Then
                ' Hide "new" control is displayed
                CType(ctlFooter.FindControl("phdNewItem"), PlaceHolder).Visible = False
            End If
        End If
    End Sub

    ''' <summary>
    ''' Prepare the area for adding new attribute options
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub PrepareNewOptionEntry()
        dtlOptions.SelectedIndex = -1
        ShowAttributeOptions(litAttribID.Text)

        Dim ctlFooter As Control = dtlOptions.Controls(dtlOptions.Controls.Count - 1)
        CType(ctlFooter.FindControl("phdNewItem"), PlaceHolder).Visible = True
        CType(ctlFooter.FindControl("_UC_LangContainer_NewOption"),  _
           _LanguageContainer).CreateLanguageStrings( _
          LANG_ELEM_TABLE_TYPE.AttributeOption, True, 0)
        CType(ctlFooter.FindControl("chkSelected"), CheckBox).Focus()

    End Sub

    ''' <summary>
    ''' Record a new Attribute Option to the database
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub InsertNewOptionEntry()

        Dim ctlFooter As Control = dtlOptions.Controls(dtlOptions.Controls.Count - 1)
        Dim numAttributeID As Integer _
            = CInt(litAttribID.Text)
        Dim numOrderByValue As Integer _
            = CInt(CType(ctlFooter.FindControl("txtOrderByValue"), TextBox).Text)
        Dim strMessage As String = ""
        Try
            Dim tblContents As DataTable _
            = CType(ctlFooter.FindControl("_UC_LangContainer_NewOption"),  _
                                            _LanguageContainer).ReadContent()
            If tblContents.Rows.Count > 0 Then
                If Not AttributesBLL._AddNewAttributeOption(tblContents, numAttributeID, numOrderByValue, strMessage) Then
                    ' If Not then raise error.
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return
                End If
            End If
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMessage)
        End Try
        ShowAttributeOptions(numAttributeID)
    End Sub

    ''' <summary>
    ''' Update an option that already exists (Edit)
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub UpdateOptionEntry()
        Dim strMessage As String = ""               ' Holds the return error message from called functions / methods
        Dim LangContainer As _LanguageContainer     ' Language control that holds the name of the option in all different languages
        Dim tblContents As DataTable = Nothing      ' Table of language strings (names of option) extracted from language container control
        Dim txtSortOrder As TextBox                 ' text box that holds the sort order
        Dim numOrderByValue As Integer = 0          ' Sort order extracted from control
        Dim litAttributeOptionId As Literal               ' Control that holds the attribute Option ID
        Dim numAttributeOptionId As Integer = 0     ' Attribute Option ID extracted from literal control
        Dim DLI As DataListItem = Nothing

        For Each item As DataListItem In dtlOptions.Items
            If item.ItemType = ListItemType.SelectedItem Then
                DLI = item
                Exit For
            End If
        Next

        ' Get the Attribute ID
        litAttributeOptionId = CType(DLI.FindControl("litOptionID"), Literal)
        If Not IsNothing(litAttributeOptionId) Then
            numAttributeOptionId = litAttributeOptionId.Text
        End If

        ' Get sort order
        txtSortOrder = CType(DLI.FindControl("txtOrderByValue"), TextBox)
        If Not IsNothing(txtSortOrder) Then
            If IsNumeric(txtSortOrder.Text) Then
                numOrderByValue = CInt(txtSortOrder.Text)
            End If
        End If

        ' Get string (name of option)
        LangContainer = CType(DLI.FindControl("_UC_LangContainer_SelectedOption"), _LanguageContainer)
        If Not IsNothing(LangContainer) Then
            tblContents = LangContainer.ReadContent
        End If

        Try
            If Not IsNothing(tblContents) Then
                If tblContents.Rows.Count > 0 Then
                    If Not AttributesBLL._UpdateAttributeOption(tblContents, numAttributeOptionId, numOrderByValue, strMessage) Then
                        ' If Not then raise error.
                        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                        Return
                    End If
                End If
            End If
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMessage)
        End Try

        dtlOptions.SelectedIndex = -1
        LoadAttributeOptions(CInt(litAttribID.Text))
        updEditValues.Update()

    End Sub

    Private Sub ShowAttributeList(ByVal strKeyword As String)
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

        'We need to put the data into a dataview in order to
        'filter by the keywords
        Dim dvwAttributes As DataView = New DataView(tblAttributes)

        If strKeyword <> "" Then
            dvwAttributes.RowFilter = "ATTRIB_Name LIKE'%" & strKeyword & "%'"
            dvwAttributes.Sort = "ATTRIB_Name"
        End If

        gvwAttributes.DataSource = dvwAttributes
        gvwAttributes.DataBind()
    End Sub


    Protected Sub _UC_EditAttribute_AttributeDeleted() Handles _UC_EditAttribute.AttributeDeleted
        ShowAttributeList("")
        mvwAttributes.SetActiveView(viwAttributeList)
        updAttributes.Update()
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub

    Protected Sub gvwAttributes_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvwAttributes.RowDataBound
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim lnkBtnAttributeValues As LinkButton = CType(e.Row.FindControl("lnkBtnAttributeValues"), LinkButton)
            If Not IsNothing(lnkBtnAttributeValues) Then
                Dim dr As DataRowView = e.Row.DataItem
                If dr("ATTRIB_Type") = "c" Or dr("ATTRIB_Type") = "d" Then

                    lnkBtnAttributeValues.Visible = True
                Else
                    lnkBtnAttributeValues.Visible = False
                End If
            End If
        End If
    End Sub

    Protected Sub dtlOptions_ItemCommand(source As Object, e As DataListCommandEventArgs) Handles dtlOptions.ItemCommand
        Select Case e.CommandName
            Case "new"
                PrepareNewOptionEntry()
            Case "save"
                InsertNewOptionEntry()
            Case "edit"
                PrepareEditOptionEntry(e.Item.ItemIndex)
                LoadAttributeOptions(CInt(litAttribID.Text))
            Case "cancel"
                dtlOptions.SelectedIndex = -1
                LoadAttributeOptions(CInt(litAttribID.Text))
                updEditValues.Update()
            Case "update"
                UpdateOptionEntry()
            Case "delete"
                DeleteOptionEntry()
            Case "LinkOptionGroupOptions"
                With _UC_PopupAttributeOption
                    .AttributeOptionId = CInt(e.CommandArgument)
                    .ShowAttributeOptions()
                End With
        End Select
    End Sub

    ''' <summary>
    ''' User has clicked the delete button.
    ''' </summary>
    ''' <remarks>We need to confirm this selection</remarks>
    Private Overloads Sub DeleteOptionEntry()
        Dim strOptionName As String = CType(dtlOptions.SelectedItem.FindControl("litOptionName"), Literal).Text
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, Replace(GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItem"), "[itemname]", strOptionName))
    End Sub

    ''' <summary>
    ''' Delete a given attribute option
    ''' </summary>
    ''' <param name="OptionId"></param>
    ''' <remarks></remarks>
    Private Overloads Sub DeleteOptionEntry(ByVal OptionId As Integer)
        Dim strMessage As String = Nothing
        If AttributesBLL._DeleteAttributeOption(OptionId, strMessage) Then
            CancelOptionSelection()
            ShowAttributeOptions(litAttribID.Text)
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        End If
    End Sub


    Protected Sub dtlOptions_ItemDataBound(sender As Object, e As DataListItemEventArgs) Handles dtlOptions.ItemDataBound
        If e.Item.ItemType = ListItemType.SelectedItem Then
            Dim numOptionID As Integer = CInt(CType(e.Item.FindControl("litOptionID"), Literal).Text)
            CType(e.Item.FindControl("_UC_LangContainer_SelectedOption"),  _
                     _LanguageContainer).CreateLanguageStrings( _
                     LANG_ELEM_TABLE_TYPE.AttributeOption, False, numOptionID)

            Dim FileUploader As _FileUploader = CType(e.Item.FindControl("UC_SwatchFileUploader"), _FileUploader)
            If Not IsNothing(FileUploader) Then
                FileUploader.LoadImages()
            End If
        End If
    End Sub

    ''' <summary>
    ''' User wants to confirm the question that was asked in the popup box
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        If dtlOptions.SelectedIndex > -1 Then
            Dim numOptionID As Integer = CInt(CType(dtlOptions.SelectedItem.FindControl("litOptionID"), Literal).Text)
            DeleteOptionEntry(numOptionID)
        End If
    End Sub
End Class
