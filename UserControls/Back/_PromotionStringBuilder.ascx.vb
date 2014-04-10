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
Imports CkartrisDataManipulation
Imports CkartrisEnumerations

Partial Class UserControls_Back_PromotionStringBuilder
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        BuildForm()
        ReadStrings()
    End Sub

    Public Event SelectionChanged()

    Public Sub CreatePromotionPart(ByVal chrPartNo As Char)
        litPartLetter.Text = Char.ToUpper(chrPartNo)
        If ddlPromotionString.Items.Count = 1 Then
            Dim tblPromotionStrings As New DataTable
            tblPromotionStrings = PromotionsBLL._GetPromotionStringsByType(chrPartNo, Session("_LANG"))
            ddlPromotionString.DataTextField = "PS_Text"
            ddlPromotionString.DataValueField = "PS_ID"
            ddlPromotionString.DataSource = tblPromotionStrings
            ddlPromotionString.DataBind()
        End If
    End Sub

    Sub BuildForm()

        ClearForm()

        If ddlPromotionString.SelectedValue = "-1" Then ClearForm() : Return
        Dim tblPromotionString As New DataTable
        tblPromotionString = PromotionsBLL._GetPromotionString(CByte(ddlPromotionString.SelectedValue), Session("_LANG"))

        If tblPromotionString.Rows.Count = 0 Then Return
        Dim PS_No As Byte = CByte(tblPromotionString.Rows(0)("PS_ID"))
        Dim charPart As Char = CChar(tblPromotionString.Rows(0)("PS_PartNo"))
        Dim charType As Char = CChar(tblPromotionString.Rows(0)("PS_Type"))
        Dim charItem As Char = FixNullFromDB(tblPromotionString.Rows(0)("PS_Item"))
        Dim strText As String = CStr(tblPromotionString.Rows(0)("PS_Text"))

        Dim tempStr As String = ""
        Dim currentIndx As Integer = 1
        Dim newIndex As Integer = 0
        Dim stringLength As Integer = 0
        Dim litStr As New Literal
        litStr.Text = ddlPromotionString.SelectedValue
        litStr.ID = "litPromotionStringID"
        litStr.Visible = False
        phdForm.Controls.Add(litStr)
        While currentIndx < strText.Length
            stringLength = GetLength(currentIndx, strText)
            If stringLength > 1 Then
                tempStr = Mid(strText, currentIndx, stringLength)
                litStr = New Literal
                litStr.Text = tempStr
                phdForm.Controls.Add(litStr)
            End If
            newIndex = strText.IndexOf("]", currentIndx) - 2
            If newIndex < 0 Then
                tempStr = Mid(strText, currentIndx)
                If tempStr.Length > 0 Then
                    litStr = New Literal
                    litStr.Text = tempStr
                    phdForm.Controls.Add(litStr)
                End If
                Exit While
            End If
            AddControl(Mid(strText, newIndex + 2, 1), charType)
            currentIndx = newIndex + 4
        End While
        phdButtons.Visible = True
        updButtons.Update()

        updPromotionForm.Update()
    End Sub

    Protected Sub ddlPromotionString_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlPromotionString.SelectedIndexChanged
        RaiseEvent SelectionChanged()
        BuildForm()
    End Sub

    Private Sub AddControl(ByVal charEntry As Char, ByVal charType As Char)
        Select Case charEntry
            Case "X"
                Dim txtBox As New TextBox
                txtBox.ID = "txtValue"
                txtBox.CssClass = "shorttext"
                Dim filTextBox As New AjaxControlToolkit.FilteredTextBoxExtender
                filTextBox.ID = "filterTXT"
                filTextBox.TargetControlID = "txtValue"
                filTextBox.FilterType = AjaxControlToolkit.FilterTypes.Numbers Or AjaxControlToolkit.FilterTypes.Custom
                filTextBox.ValidChars = "."
                Dim valRequired As New RequiredFieldValidator
                valRequired.ID = "valRequired"
                valRequired.ControlToValidate = "txtValue"
                valRequired.ErrorMessage = "*"
                valRequired.ValidationGroup = "updatestring"
                phdForm.Controls.Add(filTextBox)
                phdForm.Controls.Add(txtBox)
                phdForm.Controls.Add(valRequired)
            Case "C"
                Dim _UC_AutoComplete As _AutoCompleteInput
                _UC_AutoComplete = CType(LoadControl("_AutoCompleteInput.ascx"), _AutoCompleteInput)
                _UC_AutoComplete.ID = "_UC_AutoComplete_Item"
                _UC_AutoComplete.MethodName = "GetCategories"
                phdForm.Controls.Add(_UC_AutoComplete)
            Case "P"
                Dim _UC_AutoComplete As _AutoCompleteInput
                _UC_AutoComplete = CType(LoadControl("_AutoCompleteInput.ascx"), _AutoCompleteInput)
                _UC_AutoComplete.ID = "_UC_AutoComplete_Item"
                _UC_AutoComplete.MethodName = "GetProducts"
                phdForm.Controls.Add(_UC_AutoComplete)
            Case "V"
                Dim _UC_AutoComplete As _AutoCompleteInput
                _UC_AutoComplete = CType(LoadControl("_AutoCompleteInput.ascx"), _AutoCompleteInput)
                _UC_AutoComplete.ID = "_UC_AutoComplete_Item"
                _UC_AutoComplete.MethodName = "GetVersions"
                phdForm.Controls.Add(_UC_AutoComplete)
            Case "£"
                Dim litSymbol As New Literal
                litSymbol.ID = "txtSymbol"
                litSymbol.Text = CurrenciesBLL.CurrencySymbol(CurrenciesBLL.GetDefaultCurrency)
                phdForm.Controls.Add(litSymbol)
        End Select
    End Sub

    Private Function GetLength(ByVal currentIndx As Integer, ByVal strText As String) As Integer
        Return strText.IndexOf("[", currentIndx) - currentIndx + 1
    End Function

    Private Sub ClearForm()
        phdButtons.Visible = False
        updButtons.Update()
        phdForm.Controls.Clear()
        updPromotionForm.Update()
    End Sub

    Public Sub ResetSelection()
        ddlPromotionString.Enabled = True
        ddlPromotionString.SelectedIndex = 0
        updPromotionStrings.Update()
        ClearForm()
    End Sub

    Protected Sub lnkAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkAdd.Click
        AddString()
    End Sub

    Function CheckAutoCompleteData() As Boolean
        Dim strMethodName As String = ""
        Dim strAutoCompleteText As String = ""

        Try
            strMethodName = CType(phdForm.FindControl("_UC_AutoComplete_Item"),  _
                                        _AutoCompleteInput).MethodName()
            strAutoCompleteText = CType(phdForm.FindControl("_UC_AutoComplete_Item"),  _
                                        _AutoCompleteInput).GetText()
        Catch ex As Exception
            Return True
        End Try


        If strAutoCompleteText <> "" AndAlso strAutoCompleteText.Contains("(") _
                AndAlso strAutoCompleteText.Contains(")") Then
            Try
                Dim numItemID As Integer = CInt(Mid(strAutoCompleteText, strAutoCompleteText.LastIndexOf("(") + 2, strAutoCompleteText.LastIndexOf(")") - strAutoCompleteText.LastIndexOf("(") - 1))

                Dim strItemName As String = ""

                Select Case strMethodName
                    Case "GetCategories"
                        strItemName = CategoriesBLL._GetNameByCategoryID(numItemID, Session("_LANG"))
                    Case "GetProducts"
                        strItemName = ProductsBLL._GetNameByProductID(numItemID, Session("_LANG"))
                    Case "GetVersions"
                        strItemName = VersionsBLL._GetNameByVersionID(numItemID, Session("_LANG"))
                End Select
                If strItemName Is Nothing Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidValue"))
                    Return False
                End If
            Catch ex As Exception
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidValue"))
                Return False
            End Try
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidValue"))
            Return False
        End If

        Return True
    End Function

    Sub AddString()
        If Not CheckAutoCompleteData() Then Return

        Dim strBldrText As New StringBuilder("")
        Dim Value As String = ""
        Dim Item As String = ""
        
        For Each ctrl As Control In phdForm.Controls
            Dim ctrlContenet As String = ""
            If TypeOf (ctrl) Is TextBox Then
                ctrlContenet = CType(ctrl, TextBox).Text
                strBldrText.Append(ctrlContenet)
                If ctrl.ID.Contains("Value") Then
                    Value = ctrlContenet
                End If
                Continue For
            End If
            If TypeOf (ctrl) Is Literal Then
                ctrlContenet = CType(ctrl, Literal).Text
                If ctrl.Visible = False Then Continue For
                strBldrText.Append(ctrlContenet)
                Continue For
            End If
            If TypeOf (ctrl) Is _AutoCompleteInput Then
                ctrlContenet = CType(ctrl, _AutoCompleteInput).GetText()
                strBldrText.Append(Left(ctrlContenet, ctrlContenet.LastIndexOf("(")))
                If ctrl.ID.Contains("Item") Then
                    Item = ctrlContenet
                End If
                Continue For
            End If
        Next

        Dim numPromotionStringID As Byte = CByte(CType(phdForm.FindControl("litPromotionStringID"), Literal).Text)
        Dim tblPromotionString As New DataTable
        tblPromotionString = PromotionsBLL._GetPromotionString(numPromotionStringID, Session("_LANG"))

        lbxStrings.Items.Add(strBldrText.ToString)
        lbxStringID.Items.Add(numPromotionStringID)
        lbxStringValue.Items.Add(Value)
        lbxStringItem.Items.Add(Item)

        ResetSelection()

        ReadStrings()
        updStringList.Update()
    End Sub

    Sub ReadStrings()

        phdStringLinks.Controls.Clear()
        If lbxStrings.Items.Count = 0 Then Return
        For i As Integer = 0 To lbxStrings.Items.Count - 1

            If i <> 0 Then
                Dim litComma As New Literal
                litComma.Text = ", "
                phdStringLinks.Controls.Add(litComma)
            End If
            Dim lnkString As New LinkButton
            lnkString.CssClass = "linkbutton icon_edit"
            lnkString.ID = "lnkPart" & i
            lnkString.Text = lbxStrings.Items(i).Text
            lnkString.CommandArgument = i
            AddHandler lnkString.Click, AddressOf EditEntryString
            phdStringLinks.Controls.Add(lnkString)
            Dim trig As New AsyncPostBackTrigger
            trig.ControlID = lnkString.ID
            trig.EventName = "Click"
            updStringList.Triggers.Add(trig)

        Next
    End Sub

    Sub EditEntryString(ByVal sender As Object, ByVal e As EventArgs)
        RaiseEvent SelectionChanged()

        ClearForm()

        Dim indx As Integer = CType(sender, LinkButton).CommandArgument
        lbxStrings.SelectedIndex = indx
        ddlPromotionString.SelectedValue = lbxStringID.Items(indx).Text
        updPromotionStrings.Update()
        BuildForm()

        Dim strValue As String = lbxStringValue.Items(indx).Text
        Dim strItem As String = lbxStringItem.Items(indx).Text

        For Each ctrl As Control In phdForm.Controls
            If TypeOf (ctrl) Is Literal Then Continue For
            If TypeOf (ctrl) Is AjaxControlToolkit.FilteredTextBoxExtender Then Continue For
            If ctrl.ID.Contains("Value") Then
                CType(ctrl, TextBox).Text = strValue
            End If
            If ctrl.ID.Contains("Item") Then
                CType(ctrl, _AutoCompleteInput).SetText(strItem)
            End If
        Next

        BeginEdit()
        updPromotionForm.Update()

    End Sub

    Sub BeginEdit()

        ddlPromotionString.Enabled = False
        updPromotionStrings.Update()

        lnkAdd.Visible = False
        lnkOk.Visible = True
        lnkRemove.Visible = True
        lnkCancel.Visible = True
        updButtons.Update()
    End Sub

    Sub EndEdit()
        ddlPromotionString.Enabled = True
        ddlPromotionString.SelectedIndex = 0
        BuildForm()
        updPromotionStrings.Update()

        lnkAdd.Visible = True
        lnkOk.Visible = False
        lnkRemove.Visible = False
        lnkCancel.Visible = False
        updButtons.Update()
    End Sub

    Protected Sub lnkRemove_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkRemove.Click
        Dim indx As Integer = lbxStrings.SelectedIndex
        lbxStrings.Items.RemoveAt(indx)
        lbxStringID.Items.RemoveAt(indx)
        lbxStringValue.Items.RemoveAt(indx)
        lbxStringItem.Items.RemoveAt(indx)
        EndEdit()
        ReadStrings()
        updStringList.Update()
    End Sub

    Protected Sub lnkCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkCancel.Click
        EndEdit()
    End Sub

    Protected Sub lnkOk_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkOk.Click
        If Not CheckAutoCompleteData() Then Return

        Dim strBldrText As New StringBuilder("")
        Dim Value As String = ""
        Dim Item As String = ""

        For Each ctrl As Control In phdForm.Controls
            Dim strType As String = ctrl.GetType.ToString()
            Dim ctrlContenet As String = ""
            If TypeOf (ctrl) Is TextBox Then
                ctrlContenet = CType(ctrl, TextBox).Text
                strBldrText.Append(ctrlContenet)
                If ctrl.ID.Contains("Value") Then
                    Value = ctrlContenet
                End If
                Continue For
            End If
            If TypeOf (ctrl) Is Literal Then
                ctrlContenet = CType(ctrl, Literal).Text
                If ctrl.Visible = False Then Continue For
                strBldrText.Append(ctrlContenet)
                Continue For
            End If
            If TypeOf (ctrl) Is _AutoCompleteInput Then
                ctrlContenet = CType(ctrl, _AutoCompleteInput).GetText()
                strBldrText.Append(Mid(ctrlContenet, 1, ctrlContenet.LastIndexOf("(")))
                If ctrl.ID.Contains("Item") Then
                    Item = ctrlContenet
                End If
                Continue For
            End If
        Next

        Dim numPromotionStringID As Byte = CByte(CType(phdForm.FindControl("litPromotionStringID"), Literal).Text)
        Dim tblPromotionString As New DataTable
        tblPromotionString = PromotionsBLL._GetPromotionString(numPromotionStringID, Session("_LANG"))

        Dim indx As Integer = lbxStrings.SelectedIndex

        lbxStrings.Items(indx).Text = strBldrText.ToString
        lbxStringID.Items(indx).Text = numPromotionStringID
        lbxStringValue.Items(indx).Text = Value
        lbxStringItem.Items(indx).Text = Item

        ClearForm()
        EndEdit()

        ReadStrings()
        updStringList.Update()
    End Sub

    Public Sub GetPromotionData(ByVal chrPartNo As Char, ByVal intPromotionID As Integer)
        litPartLetter.Text = Char.ToUpper(chrPartNo)

        CreatePromotionPart(chrPartNo)
        Dim tblPromotionParts As New DataTable
        tblPromotionParts = PromotionsBLL._GetByPartsAndPromotion(chrPartNo, intPromotionID, Session("_LANG"))

        lbxStrings.Items.Clear()
        lbxStringID.Items.Clear()
        lbxStringItem.Items.Clear()
        lbxStringValue.Items.Clear()


        For Each rowParts As DataRow In tblPromotionParts.Rows
            Dim strText As String = rowParts("PS_Text")
            Dim strStringID As String = rowParts("PS_ID")
            Dim strValue As String = FixNullFromDB(rowParts("PP_Value"))
            Dim strItemID As String = FixNullFromDB(rowParts("PP_ItemID"))
            Dim strItemName As String = ""

            If strText.Contains("[X]") Then
                strText = strText.Replace("[X]", rowParts("PP_Value"))
            End If

            If strText.Contains("[C]") AndAlso strItemID <> "" Then
                strItemName = CategoriesBLL._GetNameByCategoryID(CInt(strItemID), Session("_LANG"))
                strText = strText.Replace("[C]", strItemName)
            End If

            If strText.Contains("[P]") AndAlso strItemID <> "" Then
                strItemName = ProductsBLL._GetNameByProductID(CInt(strItemID), Session("_LANG"))
                strText = strText.Replace("[P]", strItemName)
            End If

            If strText.Contains("[V]") AndAlso strItemID <> "" Then
                strItemName = VersionsBLL._GetNameByVersionID(CInt(strItemID), Session("_LANG"))
                strText = strText.Replace("[V]", strItemName)
            End If

            If strText.Contains("[£]") Then
                strText = strText.Replace("[£]", CurrenciesBLL.CurrencySymbol(CurrenciesBLL.GetDefaultCurrency))
            End If

            lbxStrings.Items.Add(strText)
            lbxStringID.Items.Add(strStringID)
            lbxStringValue.Items.Add(strValue)

            If strItemID <> "" AndAlso strItemName <> "" Then
                lbxStringItem.Items.Add(strItemName & "(" & strItemID & ")")
            Else
                lbxStringItem.Items.Add("-")
            End If
        Next

        ReadStrings()
        updStringList.Update()

    End Sub

    Public Sub ClearStrings()
        lbxStrings.Items.Clear()
        lbxStringID.Items.Clear()
        lbxStringItem.Items.Clear()
        lbxStringValue.Items.Clear()
        ReadStrings()
        updStringList.Update()
    End Sub

    Public Function HasStrings() As Boolean
        Return lbxStrings.Items.Count > 0
    End Function

    Public Function ReadParts(ByVal chrPartNo As Char) As DataTable

        Dim tblParts As New DataTable
        tblParts.Columns.Add(New DataColumn("PP_ID", Type.GetType("System.Int32")))
        tblParts.Columns.Add(New DataColumn("PROM_ID", Type.GetType("System.Int32")))
        tblParts.Columns.Add(New DataColumn("PP_PartNo", Type.GetType("System.Char")))
        tblParts.Columns.Add(New DataColumn("PP_ItemType", Type.GetType("System.Char")))
        tblParts.Columns.Add(New DataColumn("PP_ItemID", Type.GetType("System.Int64")))
        tblParts.Columns.Add(New DataColumn("PP_Type", Type.GetType("System.Char")))
        tblParts.Columns.Add(New DataColumn("PP_Value", Type.GetType("System.Single")))

        Dim tblString As New DataTable
        For i As Integer = 0 To lbxStrings.Items.Count - 1
            tblString = PromotionsBLL._GetPromotionString(CByte(lbxStringID.Items(i).Text), Session("_LANG"))
            Dim numItemID As Long = Nothing
            If lbxStringItem.Items(i).Text.Contains(")") Then
                numItemID = CInt(Mid(lbxStringItem.Items(i).Text, lbxStringItem.Items(i).Text.LastIndexOf("(") + 2, lbxStringItem.Items(i).Text.LastIndexOf(")") - lbxStringItem.Items(i).Text.LastIndexOf("(") - 1))
            End If
            tblParts.Rows.Add(Nothing, Nothing, chrPartNo, CChar(tblString.Rows(0)("PS_Item")), _
                              numItemID, CChar(tblString.Rows(0)("PS_Type")), CDbl(lbxStringValue.Items(i).Text))
        Next

        Return tblParts
    End Function

End Class
