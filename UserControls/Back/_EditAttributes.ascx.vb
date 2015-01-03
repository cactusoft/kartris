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
Imports CkartrisDataManipulation
Imports CkartrisEnumerations

Partial Class UserControls_Back_EditAttributes
    Inherits System.Web.UI.UserControl

    Public Event AttributeDeleted()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        '' validation group for the controls
        valCompareAttributeType2.ValidationGroup = LANG_ELEM_TABLE_TYPE.Attributes
        valCompareAttributeType.ValidationGroup = LANG_ELEM_TABLE_TYPE.Attributes
        valCompareSort.ValidationGroup = LANG_ELEM_TABLE_TYPE.Attributes
        valRequiredOrderByValue.ValidationGroup = LANG_ELEM_TABLE_TYPE.Attributes

        If GetAttributeID() = "0" Then '' new
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Attributes, True)
        Else                            '' update
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Attributes, False, CLng(litAttributeID.Text))
        End If
    End Sub

    ''' <summary>
    ''' prepares attribute for edit
    ''' </summary>
    ''' <param name="AttributeID"></param>
    ''' <remarks></remarks>
    Public Sub EditAttribute(ByVal AttributeID As Integer)
        litAttributeID.Text = CStr(AttributeID)
        If GetAttributeID() = 0 Then '' new
            PrepareNewAttribute()
        Else                    '' update
            GetAttributeInfo()
        End If
    End Sub

    ''' <summary>
    ''' prepares the controls for new entries
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub PrepareNewAttribute()
        chkLive.Checked = False : chkShowInProductPage.Checked = False : chkGoogleSpecial.Checked = False
        ddlCompare.SelectedValue = "0" : txtSortByValue.Text = "0"
        mvwOptions.SetActiveView(viwNotGoogleSpecial)
        _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Attributes, True)
    End Sub

    ''' <summary>
    ''' reads the promotion data from the db
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub GetAttributeInfo()

        Dim tblAttribute As New DataTable
        tblAttribute = AttributesBLL._GetByAttributeID(CByte(litAttributeID.Text))

        If tblAttribute.Rows.Count = 0 Then Return '' the attribute is not exist 

        chkLive.Checked = CBool(tblAttribute.Rows(0)("ATTRIB_Live"))
        chkShowInProductPage.Checked = CBool(tblAttribute.Rows(0)("ATTRIB_ShowFrontend"))
        chkShowOnSearch.Checked = CBool(tblAttribute.Rows(0)("ATTRIB_ShowSearch"))
        ddlCompare.SelectedValue = CStr(tblAttribute.Rows(0)("ATTRIB_Compare"))
        txtSortByValue.Text = CStr(FixNullFromDB(tblAttribute.Rows(0)("ATTRIB_OrderByValue")))

        _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Attributes, False, CLng(litAttributeID.Text))
    End Sub

    ''' <summary>
    ''' calls the save method of the promotion
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function SaveChanges() As Boolean
        If GetAttributeID() = 0 Then    '' new
            If Not SaveAttribute(DML_OPERATION.INSERT) Then Return False
        Else                            '' update
            If Not SaveAttribute(DML_OPERATION.UPDATE) Then Return False
        End If
        Return True
    End Function

    ''' <summary>
    ''' saving the changes 
    '''  - (update the existing attribute)
    '''  - (add new attribute)
    '''  Steps:
    '''  1. read the Language Elements of the promotion to save them.
    '''  2. read the main attribute info.
    '''  3. saving the changes
    ''' </summary>
    ''' <param name="enumOperation"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function SaveAttribute(ByVal enumOperation As DML_OPERATION) As Boolean

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 1. Language Contents
        Dim tblLanguageContents As New DataTable
        tblLanguageContents = _UC_LangContainer.ReadContent()

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 2. Attribute Main Info.
        Dim numAttributeID As Byte = CByte(litAttributeID.Text)
        Dim chrType As Char = CChar(ddlAttributeType.SelectedValue())
        Dim blnLive As Boolean = chkLive.Checked

        'Item(s) below were DEPRECATED, default to FALSE
        'Dim blnFastEntry As Boolean = chkFastEntry.Checked
        Dim blnFastEntry As Boolean = False

        Dim blnShowFront As Boolean = chkShowInProductPage.Checked
        Dim blnShowOnSearch As Boolean = chkShowOnSearch.Checked

        Dim blnSpecial As Boolean = chkGoogleSpecial.Checked

        Dim chrComparisonType As Char = CChar(ddlCompare.SelectedValue())
        Dim numOrderBy As Byte = CByte(txtSortByValue.Text)

        If blnSpecial Then chrComparisonType = "n"

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 3. Saving the changes
        Dim strMessage As String = ""
        Select Case enumOperation
            Case DML_OPERATION.UPDATE
                If Not AttributesBLL._UpdateAttribute( _
                                tblLanguageContents, numAttributeID, chrType, blnLive, blnFastEntry, blnShowFront, _
                                blnShowOnSearch, numOrderBy, chrComparisonType, blnSpecial, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
            Case DML_OPERATION.INSERT
                If Not AttributesBLL._AddNewAttribute( _
                                tblLanguageContents, chrType, blnLive, blnFastEntry, blnShowFront, _
                                blnShowOnSearch, numOrderBy, chrComparisonType, blnSpecial, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
        End Select

        Return True

    End Function

    ''' <summary>
    ''' returns the selected attribute id (saved in a hidden control)
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function GetAttributeID() As Integer
        If litAttributeID.Text <> "" Then
            Return CInt(litAttributeID.Text)
        End If
        Return 0
    End Function

    Protected Sub chkGoogleSpecial_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles chkGoogleSpecial.CheckedChanged
        If chkGoogleSpecial.Checked Then
            mvwOptions.SetActiveView(viwGoogleSpecial)
        Else
            mvwOptions.SetActiveView(viwNotGoogleSpecial)
        End If
        updOptions.Update()
    End Sub

    Public Sub Delete()
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified"))
    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        Dim strMessage As String = Nothing
        If AttributesBLL._DeleteAttribute(GetAttributeID(), strMessage) Then
            RaiseEvent AttributeDeleted()
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        End If
    End Sub
End Class
