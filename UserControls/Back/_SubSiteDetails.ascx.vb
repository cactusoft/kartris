'========================================================================
'Kartris - www.kartris.com
'Copyright 2018 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisBLL
Imports CkartrisEnumerations
Imports CkartrisDisplayFunctions
Imports CkartrisDataManipulation
Imports KartSettingsManager
Imports LanguageStringsBLL

Partial Class UserControls_Back_SubSiteDetails
    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' this runs when an update to data is made to trigger the animation
    ''' </summary>
    ''' <remarks></remarks>
    Public Event ShowMasterUpdate()


    ''' <summary>
    ''' this runs each time the page is called
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            Dim numSubSiteID As Integer = 0
            If Request.QueryString("SubSiteID") <> "" Then
                Try
                    numSubSiteID = CType(Request.QueryString("SubSiteID"), Integer)
                Catch ex As Exception
                    numSubSiteID = 0
                End Try
            End If

            Try
                If numSubSiteID <> 0 Then
                    Dim subSiteDataTable As DataTable = SubSitesBLL.GetSubSiteByID(numSubSiteID)
                    fvwSubSiteDetails.DataSource = subSiteDataTable
                    fvwSubSiteDetails.DataBind()

                    Dim numCategoryID As Object = subSiteDataTable.Rows.Item(0).Item("SUB_BaseCategoryID")

                    If numCategoryID IsNot Nothing Then
                        Dim strCategoryName As Object = subSiteDataTable.Rows.Item(0).Item("CAT_Name")
                        lbxCategory.Items.Add(New ListItem(strCategoryName, CStr(numCategoryID)))
                        lbxCategory.SelectedIndex = lbxCategory.Items.Count - 1
                    End If

                    'Full the skins selection menu
                    SetThemeDropDown()

                    'Set skins selection menu to currently selected item
                    Try
                        ddlistTheme.SelectedValue = CStr(FixNullFromDB(subSiteDataTable.Rows.Item(0).Item("SUB_Skin")))
                    Catch ex As Exception
                        'Ignore
                    End Try
                Else
                    SetThemeDropDown()
                End If

            Catch ex As Exception
                CkartrisFormatErrors.LogError(ex.Message)
                Response.Redirect("_SubSitesList.aspx")
            End Try
        Else
            'RaiseEvent ShowMasterUpdate()

        End If
    End Sub

    '''' <summary> 
    '''' Fills skin dropdown from contents of 'Skins' folder'
    '''' For legacy reasons, it uses the term 'theme' instead
    '''' of 'skin'
    '''' </summary> 
    Protected Sub SetThemeDropDown()
        Dim blnSkip As Boolean

        If ddlistTheme.Items.Count > 0 Then
            ddlistTheme.Items.Clear()
        End If
        'ddlistTheme.Items.Add(New ListItem("-", ""))

        Dim dirThemes As New DirectoryInfo(Server.MapPath("~/Skins"))
        If dirThemes.Exists Then
            For Each dirTheme As DirectoryInfo In dirThemes.GetDirectories
                blnSkip = False
                If (dirTheme.Name.ToLower = ("admin")) Then blnSkip = True 'skip admin theme
                If (dirTheme.Name.ToLower = ("invoice")) Then blnSkip = True 'skip invoice theme
                If blnSkip = False Then
                    ddlistTheme.Items.Add(New ListItem(dirTheme.Name, dirTheme.Name))
                End If
            Next
        End If

    End Sub


    ''' <summary>
    ''' adds the selected category from autocomplete list to the parents' list
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub lnkBtnAddCategory_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnAddCategory.Click
        Try
            Dim strCategoryText As String = _UC_AutoComplete.GetText()
            If strCategoryText <> "" Then
                If lbxCategory.Items.Count = 0 Then

                    Dim numCategoryID As Integer = CInt(Mid(strCategoryText, strCategoryText.LastIndexOf("(") + 2, strCategoryText.LastIndexOf(")") - strCategoryText.LastIndexOf("(") - 1))
                    Dim strCategoryName As String = CategoriesBLL._GetNameByCategoryID(numCategoryID, Session("_LANG"))
                    If Not strCategoryName Is Nothing Then
                        If lbxCategory.Items.FindByValue(CStr(numCategoryID)) Is Nothing Then
                            lbxCategory.Items.Add(New ListItem(strCategoryName, CStr(numCategoryID)))
                            lbxCategory.SelectedIndex = lbxCategory.Items.Count - 1
                        End If
                    Else
                        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidCategory"))
                    End If
                Else
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, "You can only select one Base Category")
                End If
            End If
        Catch ex As Exception
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidCategory"))
        Finally
            _UC_AutoComplete.ClearText()
            _UC_AutoComplete.SetFoucs()
        End Try

    End Sub

    Protected Sub lnkBtnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim subSiteId = GetSubSiteID()
        Page.Validate()
        If Page.IsValid Then
            If subSiteId > 0 Then
                SubSitesBLL._Update(subSiteId, txtSubSiteName.Text, txtSubSiteDomain.Text, lbxCategory.Items(0).Value, ddlistTheme.SelectedItem.Value, txtSubSiteNotes.Text, chkSubSiteLive.Checked)
                RaiseEvent ShowMasterUpdate()
            Else
                SubSitesBLL._Add(txtSubSiteName.Text, txtSubSiteDomain.Text, lbxCategory.Items(0).Value, ddlistTheme.SelectedItem.Value, txtSubSiteNotes.Text, chkSubSiteLive.Checked)
                Response.Redirect("_SubSitesList.aspx")
            End If
        End If
    End Sub




    ''' <summary>
    ''' removes the selected parent category from the parents' list
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub lnkBtnRemoveCategory_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnRemoveCategory.Click
        Dim selectedIndx As Integer = lbxCategory.SelectedIndex
        If selectedIndx >= 0 Then
            lbxCategory.Items.RemoveAt(selectedIndx)
            If lbxCategory.Items.Count >= selectedIndx Then
                lbxCategory.SelectedIndex = selectedIndx - 1
            Else
                If lbxCategory.Items.Count <> 0 Then
                    lbxCategory.SelectedIndex = lbxCategory.Items.Count - 1
                End If
            End If
        End If
    End Sub

    'Format back link
    Public Function FormatBackLink() As String
        Dim strURL As String = ""
        strURL = "~/Admin/_SubSitesList.aspx"

        Return strURL
    End Function


    Protected Function GetSubSiteID() As Integer
        Try
            Return CInt(Request.QueryString("SubSiteID"))
        Catch ex As Exception
        End Try
        Return 0
    End Function

    ''' <summary>
    ''' If 'edit' clicked, redirects to order editing page
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub lnkBtnEdit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("_ModifySubSite.aspx?SubSiteID=" & ViewState("numSubSiteID"))
    End Sub

    ''' <summary>
    ''' If 'cancel' clicked, redirects to order editing page
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub lnkBtnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancel.Click
        Response.Redirect("~/Admin/_SubSitesList.aspx")
    End Sub

End Class
