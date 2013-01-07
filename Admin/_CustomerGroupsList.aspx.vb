'[[[NEW COPYRIGHT NOTICE]]]
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports KartSettingsManager

Partial Class Admin_CustomerGroupsList
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetLocalResourceObject("PageTitle_CustomerGroups") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        lnkBtnSave.ValidationGroup = LANG_ELEM_TABLE_TYPE.CustomerGroups
        valRequiredDiscount.ValidationGroup = LANG_ELEM_TABLE_TYPE.CustomerGroups
        valRegexDiscount.ValidationGroup = LANG_ELEM_TABLE_TYPE.CustomerGroups
        valSummary.ValidationGroup = LANG_ELEM_TABLE_TYPE.CustomerGroups

        If Not Page.IsPostBack Then GetCustomersList()
        If GetCGID() = 0 Then
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.CustomerGroups, True)
        Else
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.CustomerGroups, False, GetCGID)
        End If
    End Sub

    Sub GetCustomersList()

        gvwCustomers.DataSource = Nothing
        gvwCustomers.DataBind()

        mvwCustomerGroupList.SetActiveView(viwCGData)

        Using tblCGs As New DataTable
            Dim rowCustomer As DataRow() = GetCustomerGroupsFromCache.Select("LANG_ID=" & Session("_LANG"))

            If rowCustomer.Length = 0 Then mvwCustomerGroupList.SetActiveView(viwCGNoItems) : Return

            tblCGs.Columns.Add(New DataColumn("CG_ID", Type.GetType("System.Int16")))
            tblCGs.Columns.Add(New DataColumn("LANG_ID", Type.GetType("System.Byte")))
            tblCGs.Columns.Add(New DataColumn("CG_Name", Type.GetType("System.String")))
            tblCGs.Columns.Add(New DataColumn("CG_Discount", Type.GetType("System.Single")))
            tblCGs.Columns.Add(New DataColumn("CG_Live", Type.GetType("System.Boolean")))

            For i As Integer = 0 To rowCustomer.Length - 1
                tblCGs.Rows.Add(CShort(rowCustomer(i)("CG_ID")), CByte(rowCustomer(i)("LANG_ID")), _
                                CStr(rowCustomer(i)("CG_Name")), CSng(rowCustomer(i)("CG_Discount")), CBool(rowCustomer(i)("CG_Live")))
            Next

            gvwCustomers.DataSource = tblCGs
            gvwCustomers.DataBind()

        End Using

    End Sub

    Private Sub gvwCustomers_RowCommand(ByVal src As Object, ByVal e As GridViewCommandEventArgs) Handles gvwCustomers.RowCommand
        Select Case e.CommandName
            Case "EditCustomerGroup"
                gvwCustomers.SelectedIndex = CInt(e.CommandArgument) - (gvwCustomers.PageSize * gvwCustomers.PageIndex)
                litCustomerGroupID.Text = gvwCustomers.SelectedValue
                PrepareExistingCG()
        End Select
    End Sub

    Protected Sub lnkBtnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancel.Click
        litCustomerGroupID.Text = "0"
        mvwCustomerGroups.SetActiveView(viwMain)
        updCGDetails.Update()
    End Sub

    Protected Sub lnkBtnNewCG_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnNewCG.Click
        PrepareNewCG()
    End Sub

    Protected Sub lnkBtnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSave.Click
        '' calling the save method for (INSERT/UPDATE)
        If GetCGID() = 0 Then '' new
            If Not SaveCG(DML_OPERATION.INSERT) Then Return
        Else                        '' update
            If Not SaveCG(DML_OPERATION.UPDATE) Then Return
        End If

        'Show animated 'updated' message
        CType(Me.Master, Skins_Admin_Template).DataUpdated()

        GetCustomersList()

        litCustomerGroupID.Text = "0"
        mvwCustomerGroups.SetActiveView(viwMain)
        updCGDetails.Update()
    End Sub

    Function SaveCG(ByVal enumOperation As DML_OPERATION) As Boolean

        Dim tblLanguageElements As New DataTable
        tblLanguageElements = _UC_LangContainer.ReadContent()

        Dim snglDiscount As Single = HandleDecimalValues(txtDiscount.Text)
        Dim blnLive As Boolean = chkCGLive.Checked

        Dim strMessage As String = ""
        Select Case enumOperation
            Case DML_OPERATION.UPDATE
                If Not UsersBLL._UpdateCustomerGroups( _
                                tblLanguageElements, GetCGID(), snglDiscount, blnLive, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
            Case DML_OPERATION.INSERT
                If Not UsersBLL._AddCustomerGroups( _
                                tblLanguageElements, snglDiscount, blnLive, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
        End Select
        RefreshCustomerGroupsCache()
        Return True

    End Function

    Private Function GetCGID() As Integer
        If litCustomerGroupID.Text <> "" Then
            Return CLng(litCustomerGroupID.Text)
        End If
        Return 0
    End Function

    Sub PrepareNewCG()
        litCustomerGroupID.Text = "0"
        _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.CustomerGroups, True)
        txtDiscount.Text = "0"
        chkCGLive.Checked = False
        mvwCustomerGroups.SetActiveView(viwDetails)
        updCGDetails.Update()
    End Sub

    Sub PrepareExistingCG()
        _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.CustomerGroups, False, CLng(litCustomerGroupID.Text))
        chkCGLive.Checked = DirectCast(gvwCustomers.SelectedRow.Cells(2).FindControl("chkCG_Live"), CheckBox).Checked
        txtDiscount.Text = gvwCustomers.SelectedRow.Cells(1).Text
        mvwCustomerGroups.SetActiveView(viwDetails)
        updCGDetails.Update()
    End Sub
End Class
