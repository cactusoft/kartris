'========================================================================
'Kartris - www.kartris.com
'Copyright 2023 CACTUSOFT

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
Imports KartSettingsManager

Partial Public Class _LanguageContent

    Inherits System.Web.UI.UserControl

    Public Sub GetFields(ByVal pTableTypeID As LANG_ELEM_TABLE_TYPE)
        Dim dvwTypeFields As DataView = GetLETypesFieldsFromCache().DefaultView
        dvwTypeFields.RowFilter = "LET_ID = " & pTableTypeID
        dvwTypeFields.Sort = "LEFN_SearchEngineInput"

        rptLanguageControls.DataSource = dvwTypeFields
        rptLanguageControls.DataBind()

        If pTableTypeID = LANG_ELEM_TABLE_TYPE.Products _
                OrElse pTableTypeID = LANG_ELEM_TABLE_TYPE.Categories _
                OrElse pTableTypeID = LANG_ELEM_TABLE_TYPE.Pages Then

            phdShowHideSearchEngineInputs.Visible = True
            HideSearchEngineInputs()
        End If

        lnkShow.Text = "[+] <span class=""bold"">" & GetGlobalResourceObject("_Kartris", "ContentText_SEO") & "</span>"
        lnkHide.Text = "[-] <span class=""bold"">" & GetGlobalResourceObject("_Kartris", "ContentText_SEO") & "</span>"

    End Sub

    Public Sub SetFields(ByVal ptblContent As DataTable, ByVal pLanguageID As Byte)
        For Each rowLanguageContent As DataRow In ptblContent.Rows
            If CByte(FixNullFromDB(rowLanguageContent("LE_LanguageID"))) = pLanguageID Then
                Dim strFieldID As String, strValue As String
                strFieldID = CStr(FixNullFromDB(rowLanguageContent("LE_FieldID")))
                strValue = CStr(FixNullFromDB(rowLanguageContent("LE_Value")))
                If strValue <> "" Then
                    For Each itm As RepeaterItem In rptLanguageControls.Items
                        If CType(itm.FindControl("litFieldNameID"), Literal).Text = strFieldID Then
                            CType(itm.FindControl("txtValue"), TextBox).Text = strValue
                        End If
                    Next
                End If
            End If
        Next
    End Sub

    Protected Sub rptLanguageControls_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.RepeaterCommandEventArgs) Handles rptLanguageControls.ItemCommand
        If e.CommandName = "ShowEditor" Then
            Session("HTMLEditorFieldID") = CByte(e.CommandArgument)
            _UC_Editor.Visible = True
            _UC_Editor.SetText(CType(e.Item.FindControl("txtValue"), TextBox).Text)
            _UC_Editor.OpenEditor()
        End If
    End Sub

    Protected Sub rptLanguageControls_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptLanguageControls.ItemDataBound
        If e.Item.ItemType = ListItemType.AlternatingItem OrElse _
            e.Item.ItemType = ListItemType.Item Then
            If CType(e.Item.FindControl("chkMultiLine"), CheckBox).Checked Then
                CType(e.Item.FindControl("txtValue"), TextBox).TextMode = TextBoxMode.MultiLine
            End If
        End If
    End Sub

    Public Sub EnableValidators()
        For Each itm As RepeaterItem In rptLanguageControls.Items
            CType(itm.FindControl("valRequiredValue"), RequiredFieldValidator).Enabled = _
            CType(itm.FindControl("chkMandatory"), CheckBox).Checked
        Next
    End Sub

    Public Function GetValues() As String(,)

        Dim strValues(rptLanguageControls.Items.Count - 1, 1) As String
        Dim intCounter As Integer = 0
        For Each itm As RepeaterItem In rptLanguageControls.Items
            strValues(intCounter, 0) = CType(itm.FindControl("litFieldNameID"), Literal).Text
            strValues(intCounter, 1) = CType(itm.FindControl("txtValue"), TextBox).Text
            intCounter += 1
        Next
        Return strValues
    End Function

    Public Sub SetEditable(ByVal numFieldID As LANG_ELEM_FIELD_NAME, ByVal blnIsEditable As Boolean)
        For Each itm As RepeaterItem In rptLanguageControls.Items
            If itm.ItemType = ListItemType.AlternatingItem OrElse _
                itm.ItemType = ListItemType.Item Then
                If CType(itm.FindControl("litFieldNameID"), Literal).Text = numFieldID Then
                    CType(itm.FindControl("txtValue"), TextBox).Enabled = False
                    CType(itm.FindControl("btnEdit"), ImageButton).Enabled = False
                    CType(itm.FindControl("valRequiredValue"), RequiredFieldValidator).Enabled = False
                    Exit For
                End If
            End If
        Next
    End Sub

    Protected Sub _UC_Editor_Saved() Handles _UC_Editor.Saved
        For Each itm As RepeaterItem In rptLanguageControls.Items
            If itm.ItemType = ListItemType.AlternatingItem OrElse _
                itm.ItemType = ListItemType.Item Then
                If CByte(CType(itm.FindControl("litID"), Literal).Text) = Session("HTMLEditorFieldID") Then
                    CType(itm.FindControl("txtValue"), TextBox).Text = _UC_Editor.GetText()
                    Session("HTMLEditorFieldID") = 0
                    Exit For
                End If
            End If
        Next
    End Sub

    Protected Sub lnkShow_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkShow.Click
        ShowSearchEngineInputs()
        lnkHide.Visible = True
        lnkShow.Visible = False
        updSearchEngineControls.Update()
    End Sub

    Protected Sub lnkHide_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkHide.Click
        HideSearchEngineInputs()
        lnkHide.Visible = False
        lnkShow.Visible = True
        updSearchEngineControls.Update()
    End Sub

    Sub HideSearchEngineInputs()
        For Each itm As RepeaterItem In rptLanguageControls.Items
            If itm.ItemType = ListItemType.AlternatingItem OrElse itm.ItemType = ListItemType.Item Then
                If CType(itm.FindControl("chkSearchEngineInput"), CheckBox).Checked Then
                    itm.Visible = False
                End If
            End If
        Next
    End Sub

    Sub ShowSearchEngineInputs()
        For Each itm As RepeaterItem In rptLanguageControls.Items
            If itm.ItemType = ListItemType.AlternatingItem OrElse itm.ItemType = ListItemType.Item Then
                If CType(itm.FindControl("chkSearchEngineInput"), CheckBox).Checked Then
                    itm.Visible = True
                End If
            End If
        Next
    End Sub
End Class