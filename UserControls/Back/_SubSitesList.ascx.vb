'========================================================================
'Kartris - www.kartris.com
'Copyright 2024 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'
'Modification by Craig Moore - Deadline Automation Limited
'2014-11-20 - Add calls to custom control _DispatchLabels.ascx for the 
'purpose of printing labels through PDFSharp
'========================================================================
Imports CkartrisBLL
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports KartSettingsManager

Partial Class UserControls_Back_SubSiteList
    Inherits System.Web.UI.UserControl

    Private _RowCount As Integer

    ''' <summary>
    ''' this runs when an update to data is made to trigger the animation
    ''' </summary>
    ''' <remarks></remarks>
    Public Event ShowMasterUpdate()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Culture = System.Globalization.CultureInfo.CreateSpecificCulture(System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName).Name
        If Not IsPostBack Then
            RefreshSubSiteList()
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
        ddlistTheme.Items.Add(New ListItem("-", ""))

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

    Private Sub PrepareNewSubSite()
        chkSubSiteLive.Checked = False

        txtSubSiteName.Text = Nothing
        txtSubSiteDomain.Text = Nothing
        txtSubSiteNotes.Text = Nothing
        txtTheme.Text = Nothing

        tabContainerSubSite.ActiveTabIndex = 0
        _UC_ObjectConfig.ItemID = Nothing
        SetThemeDropDown()
    End Sub

    Protected Sub tabContainerSubSite_ActiveTabChanged(ByVal sender As Object, ByVal e As EventArgs)
        Session("_tab") = sender.ActiveTabIndex
        If sender.ActiveTabIndex = 1 Then
            _UC_ObjectConfig.LoadObjectConfig()
        End If
    End Sub

    Protected Sub lnkBtnAddCategory_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnAddCategory.Click
        Try
            Dim strCategoryText As String = _UC_AutoComplete.GetText()
            If strCategoryText <> "" Then
                If lbxCategory.Items.Count = 0 Then
                    Dim objCategoriesBLL As New CategoriesBLL
                    Dim numCategoryID As Integer = CInt(Mid(strCategoryText, strCategoryText.LastIndexOf("(") + 2, strCategoryText.LastIndexOf(")") - strCategoryText.LastIndexOf("(") - 1))
                    Dim strCategoryName As String = objCategoriesBLL._GetNameByCategoryID(numCategoryID, Session("_LANG"))
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

    Protected Sub lnkBtnBack_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        phdupdSubSiteDetails.Visible = False
        gvwSubSites.Visible = True
        RefreshSubSiteList()
        updSubSites.Update()
    End Sub

    Protected Sub btnNew_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnNew.Click
        PrepareNewSubSite()
        gvwSubSites.Visible = False
        phdupdSubSiteDetails.Visible = True
    End Sub

    Public Sub RefreshSubSiteList(Optional ByVal blnRetrieveTotalCount As Boolean = True)
        Dim tblSubSitesList As DataTable = Nothing

        tblSubSitesList = SubSitesBLL.GetSubSites()
        gvwSubSites.DataSource = tblSubSitesList
        gvwSubSites.DataBind()

    End Sub

    Protected Sub lnkBtnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Page.Validate()
        If Page.IsValid Then
            Dim newId = SubSitesBLL._Add(txtSubSiteName.Text, txtSubSiteDomain.Text, lbxCategory.Items(0).Value, ddlistTheme.SelectedItem.Value, txtSubSiteNotes.Text, chkSubSiteLive.Checked)
            If newId > 0 Then
                'Save Object config Options
                _UC_ObjectConfig.ItemID = newId
                _UC_ObjectConfig.SaveConfig()

                phdupdSubSiteDetails.Visible = False
                gvwSubSites.Visible = True
                RefreshSubSiteList()
                updSubSites.Update()
                RaiseEvent ShowMasterUpdate()
            End If

        End If
    End Sub

End Class
