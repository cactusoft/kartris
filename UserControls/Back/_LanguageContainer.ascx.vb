'========================================================================
'Kartris - www.kartris.com
'Copyright 2021 CACTUSOFT

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

Partial Class _LanguageContainer

    Inherits System.Web.UI.UserControl

    Public Sub CreateLanguageStrings(ByVal elementTypeID As LANG_ELEM_TABLE_TYPE, _
                                     ByVal pIsNew As Boolean, Optional ByVal numItemID As Long = 0)

        updLanguageStrings.ContentTemplateContainer.Controls.Clear()
        Dim dr() As DataRow = LanguagesBLL._GetBackendLanguages()

        Dim tblLanguageElementContent As New DataTable

        If numItemID <> 0 Then
            tblLanguageElementContent = LanguageElementsBLL._GetElementsByTypeAndParent(elementTypeID, numItemID)
        Else
            If pIsNew = False Then tblLanguageElementContent = LanguageElementsBLL._GetElementsByTypeAndParent(elementTypeID, numItemID)
        End If

        Dim tabLanguageStrings As New AjaxControlToolkit.TabContainer
        tabLanguageStrings.ID = "tabLanguageStrings"
        tabLanguageStrings.CssClass = ".tab"
        tabLanguageStrings.EnableTheming = False
        tabLanguageStrings.AutoPostBack = False

        Dim pnlTab As AjaxControlToolkit.TabPanel
        Dim litLanguageID As Literal
        Dim numCounter As Byte = 0
        For i As Integer = 0 To dr.Length - 1
            numCounter += 1

            litLanguageID = New Literal
            litLanguageID.ID = "litLANG_ID"
            litLanguageID.Text = dr(i)("LANG_ID")
            litLanguageID.Visible = False

            pnlTab = New AjaxControlToolkit.TabPanel
            pnlTab.ID = "pnlTab" & numCounter
            pnlTab.HeaderText = FixNullFromDB(dr(i)("LANG_FrontName"))

            Dim ctlLanguageContent As _LanguageContent
            ctlLanguageContent = CType(LoadControl("_LanguageContent.ascx"), _LanguageContent)
            ctlLanguageContent.ID = "_UC_LanguageContent"
            ctlLanguageContent.GetFields(elementTypeID)

            '' If the current status is Edit, then Load contents from LanguageElement
            If Not pIsNew Then
                ctlLanguageContent.SetFields(tblLanguageElementContent, CByte(dr(i)("LANG_ID")))
            End If

            '' Creates a Required Field Validators for the default language.
            If dr(i)("LANG_ID") = LanguagesBLL.GetDefaultLanguageID() Then
                ctlLanguageContent.EnableValidators()
            End If

            Dim updNewPanel As UpdatePanel = New UpdatePanel()
            updNewPanel.UpdateMode = UpdatePanelUpdateMode.Conditional
            updNewPanel.ContentTemplateContainer.Controls.Add(litLanguageID)
            updNewPanel.ContentTemplateContainer.Controls.Add(ctlLanguageContent)

            pnlTab.Controls.Add(updNewPanel)
            tabLanguageStrings.Tabs.Add(pnlTab)

        Next
        tabLanguageStrings.ActiveTabIndex = 0
        updLanguageStrings.ContentTemplateContainer.Controls.Add(tabLanguageStrings)
        updLanguageStrings.Update()

    End Sub

    Public Function ReadContent() As DataTable
        Dim tblLanguageContents As New DataTable()

        tblLanguageContents.Columns.Add(New DataColumn("_LE_LanguageID"))
        tblLanguageContents.Columns.Add(New DataColumn("_LE_FieldID"))
        tblLanguageContents.Columns.Add(New DataColumn("_LE_Value"))

        Dim numLanguageID As Byte, numFieldID As Byte, strValue As String

        For Each itmTabPanel As AjaxControlToolkit.TabPanel In _
            CType(updLanguageStrings.FindControl("tabLanguageStrings"),  _
            AjaxControlToolkit.TabContainer).Tabs

            Dim arrValues(,) As String
            arrValues = CType(itmTabPanel.FindControl("_UC_LanguageContent"), _LanguageContent).GetValues()
            numLanguageID = CByte(CType(itmTabPanel.FindControl("litLANG_ID"), Literal).Text)

            For i As Integer = 0 To arrValues.GetUpperBound(0)
                numFieldID = CByte(arrValues(i, 0))
                strValue = CStr(arrValues(i, 1))
                tblLanguageContents.Rows.Add(numLanguageID, numFieldID, strValue)
            Next
        Next

        Return tblLanguageContents

    End Function

    Public Sub SetFieldEditable(ByVal numFieldID As LANG_ELEM_FIELD_NAME, ByVal blnIsEditable As Boolean)
        For Each itmTabPanel As AjaxControlToolkit.TabPanel In _
            CType(updLanguageStrings.FindControl("tabLanguageStrings"),  _
            AjaxControlToolkit.TabContainer).Tabs

            CType(itmTabPanel.FindControl("_UC_LanguageContent"), _LanguageContent).SetEditable(numFieldID, blnIsEditable)

        Next
    End Sub
End Class
