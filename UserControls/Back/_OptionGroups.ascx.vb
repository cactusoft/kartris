'========================================================================
'Kartris - www.kartris.com
'Copyright 2016 CACTUSOFT

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
Imports CkartrisFormatErrors

Partial Class _OptionGroups
    Inherits System.Web.UI.UserControl

    Private _RowsPerPage As Short = 100

    '' The URL Query String Key that holds the Options' PageNo. to display.
    Const c_PAGER_QUERY_STRING_KEY As String = "opgr"

    Public Event ShowMasterUpdate()
    Public Event OptionGroupDeleted()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        '' Loading the LanguageStrings for the OptionGroups' Part
        If dtlOptionGroups.Controls.Count > 0 Then
            Dim ctlGrpFooter As Control = dtlOptionGroups.Controls(dtlOptionGroups.Controls.Count - 1)
            CType(ctlGrpFooter.FindControl("_UC_LangContainer_NewGrp"),  _
                   _LanguageContainer).CreateLanguageStrings( _
                   LANG_ELEM_TABLE_TYPE.OptionGroups, True, 0)
            If dtlOptionGroups.SelectedIndex <> -1 Then
                Dim numOptionGrpID As Integer = CInt(CType(dtlOptionGroups.SelectedItem.FindControl("litOptionGrpID"), Literal).Text)
                CType(dtlOptionGroups.SelectedItem.FindControl("_UC_LangContainer_SelectedGrp"),  _
                         _LanguageContainer).CreateLanguageStrings( _
                          LANG_ELEM_TABLE_TYPE.OptionGroups, False, numOptionGrpID)
            End If
        End If
        '' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        '' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        '' Loading the LanguageStrings for the Options' Part
        If dtlOptions.Controls.Count > 0 Then
            Dim ctlOptFooter As Control = dtlOptions.Controls(dtlOptions.Controls.Count - 1)
            CType(ctlOptFooter.FindControl("_UC_LangContainer_NewOption"),  _
                   _LanguageContainer).CreateLanguageStrings( _
                    LANG_ELEM_TABLE_TYPE.Options, True, 0)
            If dtlOptions.SelectedIndex <> -1 Then
                Dim numOptionID As Integer = CInt(CType(dtlOptions.SelectedItem.FindControl("litOptionID"), Literal).Text)
                CType(dtlOptions.SelectedItem.FindControl("_UC_LangContainer_SelectedOption"),  _
                         _LanguageContainer).CreateLanguageStrings( _
                         LANG_ELEM_TABLE_TYPE.Options, False, numOptionID)
            End If
        End If
        '' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    End Sub

    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSearch.Click
        ShowOptionGroups()
    End Sub

    Protected Sub btnClear_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnClear.Click
        txtSearch.Text = ""
        ShowOptionGroups()
    End Sub

    Protected Sub dtlOptionGroups_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.DataListCommandEventArgs) Handles dtlOptionGroups.ItemCommand
        Select Case e.CommandName
            Case "optionvalues" '' OPTION VALUES
                OptionValues(e.Item)
            Case "edit"     '' Option Group selected for edit
                EditGroupItem(e.Item)
            Case "cancel"   '' Cancel the current operation(selection, edit or new)
                CancelGroupOperation()
            Case "delete"   '' Delete the current Option Group
                DeleteOptionGroup()
            Case "new"      '' Create New Option Group
                PrepareNewGroupEntry()
            Case "update"   '' Save the changes (updating to db)
                UpdateOptionGrp()
            Case "save"     '' Save the changes (inserting to db)
                InsertNewOptionGrp()
        End Select

    End Sub

    Protected Sub dtlOptionGroups_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataListItemEventArgs) Handles dtlOptionGroups.ItemDataBound
        If e.Item.ItemType = ListItemType.SelectedItem Then
            Dim displayType As String = CType(e.Item.FindControl("litDisplayType"), Literal).Text
            CType(e.Item.FindControl("ddlDisplayType"), DropDownList).SelectedValue = displayType

            Dim numOptionGrpID As Integer = CInt(CType(e.Item.FindControl("litOptionGrpID"), Literal).Text)
            CType(e.Item.FindControl("_UC_LangContainer_SelectedGrp"),  _
                     _LanguageContainer).CreateLanguageStrings( _
                     LANG_ELEM_TABLE_TYPE.OptionGroups, False, numOptionGrpID)
        End If
    End Sub

    Protected Sub dtlOptions_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.DataListCommandEventArgs) Handles dtlOptions.ItemCommand
        Select Case e.CommandName

            Case "optionvalues" '' OPTION VALUES
                OptionValues(e.Item)
            Case "edit"     '' Option selected for edit
                ShowOptions(e.Item.ItemIndex)
            Case "cancel"   '' Cancel the current operation(selection, edit or new)
                ShowOptions()
            Case "delete"   '' Delete the current Option
                DeleteOptionValue()
            Case "new"      '' Create New Option
                PrepareNewOptionEntry()
            Case "update"   '' Save the changes (updating to db)
                UpdateOption()
            Case "save"     '' Save the changes (inserting to db)
                InsertNewOption()
        End Select
    End Sub

    Protected Sub dtlOptions_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataListItemEventArgs) Handles dtlOptions.ItemDataBound

        If e.Item.ItemType = ListItemType.AlternatingItem OrElse e.Item.ItemType = ListItemType.Item Then
            Dim litPrice As Literal = CType(e.Item.FindControl("litOPT_DefPriceChange"), Literal)
            litPrice.Text = _HandleDecimalValues(litPrice.Text)
            Dim litWeight As Literal = CType(e.Item.FindControl("litOPT_DefWeightChange"), Literal)
            litWeight.Text = _HandleDecimalValues(litWeight.Text)
        End If
        If e.Item.ItemType = ListItemType.SelectedItem Then
            Dim numOptionID As Integer = CInt(CType(e.Item.FindControl("litOptionID"), Literal).Text)
            CType(e.Item.FindControl("_UC_LangContainer_SelectedOption"),  _
                     _LanguageContainer).CreateLanguageStrings( _
                     LANG_ELEM_TABLE_TYPE.Options, False, numOptionID)
        End If
        If e.Item.ItemType = ListItemType.SelectedItem OrElse e.Item.ItemType = ListItemType.Footer Then
            Dim txtPrice As TextBox = CType(e.Item.FindControl("txtPriceChange"), TextBox)
            txtPrice.Text = _HandleDecimalValues(CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency(), txtPrice.Text))
            Dim txtWeight As TextBox = CType(e.Item.FindControl("txtWeightChange"), TextBox)
            txtWeight.Text = _HandleDecimalValues(txtWeight.Text)

            If litGroupDisplayType.Text = "c" Then
                CType(e.Item.FindControl("chkSelected"), CheckBox).Enabled = True
            Else
                CType(e.Item.FindControl("chkSelected"), CheckBox).Checked = False
                CType(e.Item.FindControl("chkSelected"), CheckBox).Enabled = False
            End If
        End If

    End Sub

    Public Sub ShowOptionGroups(Optional ByVal intIndex As Integer = -1)

        '' Gets the value of the Paging Key "PPGR" from the URL.
        Dim numPageIndex As Short
        If Request.QueryString(c_PAGER_QUERY_STRING_KEY) Is Nothing Then
            numPageIndex = 0
        Else
            numPageIndex = Request.QueryString(c_PAGER_QUERY_STRING_KEY)
        End If

        '' Gets No. of Groups from the CONFIG Setting.

        Dim numTotalGroups As Integer = 0

        Dim tblOptionGrps As New DataTable
        tblOptionGrps = OptionsBLL._GetOptionGroupPage(numPageIndex, _RowsPerPage, numTotalGroups)


        tblOptionGrps.Columns.Add(New DataColumn("Display")) '' Used to hold the full value name of DisplayType
        For Each row As DataRow In tblOptionGrps.Rows
            Select Case CChar(row("OPTG_OptionDisplayType"))
                Case "d"
                    row("Display") = "DropDown"
                Case "l"
                    row("Display") = "List"
            End Select
        Next
        dtlOptionGroups.SelectedIndex = intIndex

        'We need to put the data into a dataview in order to
        'filter by the keywords
        Dim dvwOptionGroups As DataView = New DataView(tblOptionGrps)

        If txtSearch.Text <> "" Then
            dvwOptionGroups.RowFilter = "OPTG_BackendName LIKE'%" & txtSearch.Text & "%'"
            dvwOptionGroups.Sort = "OPTG_BackendName"
        End If

        dtlOptionGroups.DataSource = dvwOptionGroups
        dtlOptionGroups.DataBind()

        updOptionGrpList.Update()

        '' TO SHOW A LABEL THAT SAYS NO OPTION_GROUPS YET.
        If tblOptionGrps.Rows.Count = 0 Then
            Dim ctlFooter As Control = dtlOptionGroups.Controls(dtlOptionGroups.Controls.Count - 1)
            CType(ctlFooter.FindControl("phdNoOptionGroups"), PlaceHolder).Visible = True
        End If

    End Sub

    Protected Sub ShowOptions(Optional ByVal intIndex As Integer = -1)

        Dim tblOptions As New DataTable
        tblOptions = OptionsBLL._GetOptionsByGroupID(CInt(litOptGrpID.Text), Session("_LANG"))

        dtlOptions.SelectedIndex = intIndex
        dtlOptions.DataSource = tblOptions
        dtlOptions.DataBind()

        updOptions.Update()

        '' TO SHOW A LABEL THAT SAYS NO OPTIONS YET.
        If tblOptions.Rows.Count = 0 Then
            Dim ctlFooter As Control = dtlOptions.Controls(dtlOptions.Controls.Count - 1)
            CType(ctlFooter.FindControl("phdNoOption"), PlaceHolder).Visible = True
        End If
    End Sub

    'NEW
    Private Sub OptionValues(ByVal itmSelected As DataListItem)
        phdOptionGroups.Visible = False
        phdOptions.Visible = True

        litOptGrpID.Text = CType(itmSelected.FindControl("litOptionGrpID"), Literal).Text
        ShowOptions()
    End Sub

    Private Sub EditGroupItem(ByVal itmSelected As DataListItem)

        'show groups, hide options
        phdOptionGroups.Visible = True
        phdOptions.Visible = False

        CancelGroupOperation()
        ShowOptionGroups(itmSelected.ItemIndex)
    End Sub

    Private Sub DeleteOptionGroup()
        litToDelete_Hidden.Text = "optiongroup#" & dtlOptionGroups.SelectedValue
        Dim strOptionGroupName As String = CType(dtlOptionGroups.SelectedItem.FindControl("litBackEndName_Hidden"), Literal).Text
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, Replace(GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItem"), "[itemname]", strOptionGroupName))
    End Sub

    Private Sub DeleteOptionValue()
        litToDelete_Hidden.Text = "optionvalue#" & dtlOptions.SelectedValue
        Dim strOptionName As String = CType(dtlOptions.SelectedItem.FindControl("litOptionName"), Literal).Text
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, Replace(GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItem"), "[itemname]", strOptionName))
    End Sub

    Private Sub CancelGroupOperation()
        ShowOptionGroups()
        updOptions.Update()
    End Sub

    Private Sub InsertNewOptionGrp()

        Dim ctlFooter As Control = dtlOptionGroups.Controls(dtlOptionGroups.Controls.Count - 1)

        Dim strBackendName As String _
            = CType(ctlFooter.FindControl("txtBackEndName"), TextBox).Text
        Dim chrDisplayType As Char _
            = CChar(CType(ctlFooter.FindControl("ddlDisplayType"), DropDownList).SelectedValue)
        Dim numOrderByValue As Integer _
            = CInt(CType(ctlFooter.FindControl("txtOrderByValue"), TextBox).Text)

        Dim strMessage As String = ""
        Try
            Dim tblContents As DataTable _
            = CType(ctlFooter.FindControl("_UC_LangContainer_NewGrp"),  _
                                            _LanguageContainer).ReadContent()
            If tblContents.Rows.Count > 0 Then
                If Not OptionsBLL._AddOptionGrp(strBackendName, chrDisplayType, numOrderByValue, tblContents, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return
                End If
                ShowOptionGroups()
                RaiseEvent ShowMasterUpdate()
            End If
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMessage)
        End Try

    End Sub

    Private Sub UpdateOptionGrp()
        Dim itmSelected As DataListItem = dtlOptionGroups.SelectedItem
        Dim numOptionGroupID As Integer _
            = CInt(CType(itmSelected.FindControl("litOptionGrpID"), Literal).Text)
        Dim strBackendName As String _
            = CType(itmSelected.FindControl("txtBackEndName"), TextBox).Text
        Dim chrDisplayType As Char _
            = CChar(CType(itmSelected.FindControl("ddlDisplayType"), DropDownList).SelectedValue)
        Dim numOrderByValue As Integer _
            = CInt(CType(itmSelected.FindControl("txtOrderByValue"), TextBox).Text)

        Dim strMessage As String = ""
        Try
            Dim tblContents As DataTable _
            = CType(itmSelected.FindControl("_UC_LangContainer_SelectedGrp"),  _
                                            _LanguageContainer).ReadContent()
            If tblContents.Rows.Count > 0 Then
                If Not OptionsBLL._UpdateOptionGrp(numOptionGroupID, strBackendName, _
                                                    chrDisplayType, numOrderByValue, tblContents, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return
                End If
                ShowOptionGroups()
                CancelGroupOperation()
                RaiseEvent ShowMasterUpdate()
            End If

        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMessage)
        End Try
    End Sub

    Private Sub PrepareNewGroupEntry()
        CancelGroupOperation()
        ShowOptionGroups()
        Dim ctlFooter As Control = dtlOptionGroups.Controls(dtlOptionGroups.Controls.Count - 1)
        CType(ctlFooter.FindControl("phdNewGrpItem"), PlaceHolder).Visible = True
        CType(ctlFooter.FindControl("phdCreateNewOptionGrp"), PlaceHolder).Visible = False
        CType(ctlFooter.FindControl("_UC_LangContainer_NewGrp"),  _
           _LanguageContainer).CreateLanguageStrings( _
          LANG_ELEM_TABLE_TYPE.OptionGroups, True, 0)
        CType(ctlFooter.FindControl("txtBackEndName"), TextBox).Focus()
    End Sub

    Private Sub PrepareNewOptionEntry()
        ShowOptions()
        Dim ctlFooter As Control = dtlOptions.Controls(dtlOptions.Controls.Count - 1)
        CType(ctlFooter.FindControl("phdNewItem"), PlaceHolder).Visible = True
        CType(ctlFooter.FindControl("phdNoOption"), PlaceHolder).Visible = False
        CType(ctlFooter.FindControl("_UC_LangContainer_NewOption"),  _
           _LanguageContainer).CreateLanguageStrings( _
           LANG_ELEM_TABLE_TYPE.Options, True, 0)
    End Sub

    Private Sub InsertNewOption()

        Dim ctlFooter As Control = dtlOptions.Controls(dtlOptions.Controls.Count - 1)

        Dim numOptionGroupID As Integer _
            = CInt(litOptGrpID.Text)
        Dim blnChkBoxValue As Boolean _
            = CBool(CType(ctlFooter.FindControl("chkSelected"), CheckBox).Checked)
        Dim numPriceChange As Single _
            = HandleDecimalValues(CType(ctlFooter.FindControl("txtPriceChange"), TextBox).Text)
        Dim numWeightChange As Single _
            = HandleDecimalValues(CType(ctlFooter.FindControl("txtWeightChange"), TextBox).Text)
        Dim numOrderByValue As Integer _
            = CInt(CType(ctlFooter.FindControl("txtOrderByValue"), TextBox).Text)
        Dim strMessage As String = ""
        Try
            Dim tblContents As DataTable _
            = CType(ctlFooter.FindControl("_UC_LangContainer_NewOption"),  _
                                            _LanguageContainer).ReadContent()
            If tblContents.Rows.Count > 0 Then
                If Not OptionsBLL._AddOption(numOptionGroupID, blnChkBoxValue, numPriceChange, _
                                                     numWeightChange, numOrderByValue, tblContents, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return
                End If
                ShowOptions()
                RaiseEvent ShowMasterUpdate()
            End If
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMessage)
        End Try

    End Sub

    Private Sub UpdateOption()
        Dim itmSelected As DataListItem = dtlOptions.SelectedItem

        Dim numOptionGroupID As Integer _
            = CInt(litOptGrpID.Text)
        Dim blnChkBoxValue As Boolean _
            = CBool(CType(itmSelected.FindControl("chkSelected"), CheckBox).Checked)
        Dim numPriceChange As Single _
            = HandleDecimalValues(CType(itmSelected.FindControl("txtPriceChange"), TextBox).Text)
        Dim numWeightChange As Single _
            = HandleDecimalValues(CType(itmSelected.FindControl("txtWeightChange"), TextBox).Text)
        Dim numOrderByValue As Integer _
            = CInt(CType(itmSelected.FindControl("txtOrderByValue"), TextBox).Text)

        Dim blnChkResetOptions As Boolean _
            = CBool(CType(itmSelected.FindControl("chkResetOptions"), CheckBox).Checked)

        Dim strMessage As String = ""
        Try
            Dim tblContents As DataTable _
            = CType(itmSelected.FindControl("_UC_LangContainer_SelectedOption"),  _
                                            _LanguageContainer).ReadContent()
            Dim numOptionID As Integer = CInt(CType(itmSelected.FindControl("litOptionID"), Literal).Text)
            If tblContents.Rows.Count > 0 Then
                If Not OptionsBLL._UpdateOption(numOptionID, numOptionGroupID, blnChkBoxValue, numPriceChange,
                                                        numWeightChange, numOrderByValue, tblContents, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return
                End If

                'Update price/weight of option values in products
                'using this option
                If blnChkResetOptions Then
                    'Need to find all tblKartrisProductOptionLink records that are
                    'based on this tblKartrisOptions record
                End If

                ShowOptions()
                RaiseEvent ShowMasterUpdate()
            End If
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMessage)
        End Try
    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        If String.IsNullOrEmpty(litToDelete_Hidden.Text) Then Exit Sub
        Dim strToDelete() As String = Split(litToDelete_Hidden.Text, "#")
        If strToDelete.Length = 2 AndAlso IsNumeric(strToDelete(1)) Then
            Select Case strToDelete(0).ToLower
                Case "optiongroup"
                    DeleteOptionGroup(CInt(strToDelete(1)))
                Case "optionvalue"
                    DeleteOptionValue(CInt(strToDelete(1)))
                Case Else
            End Select
        End If
        litToDelete_Hidden.Text = Nothing
    End Sub

    Sub DeleteOptionGroup(numOptionGroupID As Integer)
        Dim strMessage As String = Nothing
        If OptionsBLL._DeleteOptionGrp(numOptionGroupID, strMessage) Then
            CancelGroupOperation()
            RaiseEvent ShowMasterUpdate()
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        End If
    End Sub
    Sub DeleteOptionValue(numOptionID As Integer)
        Dim strMessage As String = Nothing
        If OptionsBLL._DeleteOption(numOptionID, strMessage) Then
            ShowOptions()
            RaiseEvent ShowMasterUpdate()
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        End If
    End Sub
End Class