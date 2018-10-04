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

    Private blnTableCopied As Boolean = False
    Private tblOriginal As DataTable

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

    ''' <summary>
    ''' Order List Call Mode. See ORDERS_LIST_CALLMODE Enum in OrdersBLL to check the available call modes.
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Public Property CallMode() As OrdersBLL.ORDERS_LIST_CALLMODE
        Get
            Return ViewState("_Callmode")
        End Get
        Set(ByVal value As OrdersBLL.ORDERS_LIST_CALLMODE)
            ViewState("_Callmode") = value
        End Set
    End Property

    ''' <summary>
    ''' Activate / Deactivate Order List Batch Process Mode. 
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Public Property BatchProcess() As Boolean
        Get
            Return ViewState("_BatchProcess")
        End Get
        Set(ByVal value As Boolean)
            ViewState("_BatchProcess") = value
        End Set
    End Property

    Public ReadOnly Property RowCount() As Integer
        Get
            Return _RowCount
        End Get
    End Property

    ''' <summary>
    ''' A generic parameter. Expects either the Affiliate ID, Payment Gateway Code, or the Date depending on the callmode.
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Public Property datValue1() As String
        Get
            Return ViewState("_datValue1")
        End Get
        Set(ByVal value As String)
            ViewState("_datValue1") = value
        End Set
    End Property


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

    ''' <summary>
    ''' A generic parameter. Expects the Gateway Reference Code but will also accept the second Date value in case we decide to search the orders by date range.
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Public Property datValue2() As String
        Get
            Return ViewState("_datValue2")
        End Get
        Set(ByVal value As String)
            ViewState("_datValue2") = value
        End Set
    End Property

    Private Sub PrepareNewSubSite()
        chkSubSiteLive.Checked = False

        txtSubSiteName.Text = Nothing
        txtSubSiteDomain.Text = Nothing
        txtSubSiteNotes.Text = Nothing
        txtTheme.Text = Nothing

        SetThemeDropDown()
        'SetMasterDropDown()
    End Sub

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

    Protected Sub lnkBtnBack_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        phdupdSubSiteDetails.Visible = False
        gvwSubSites.Visible = True
        RefreshSubSiteList()
        updSubSites.Update()
    End Sub

    Protected Sub gvwSubSites_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwSubSites.RowCommand
        If e.CommandName = "CreateNewSubSite" Then
            PrepareNewSubSite()
            gvwSubSites.Visible = False
            phdupdSubSiteDetails.Visible = True

            'updLanguage.Update()
        End If
    End Sub

    Public Sub RefreshSubSiteList(Optional ByVal blnRetrieveTotalCount As Boolean = True)
        If ViewState("intTotalRowCount") Is Nothing Then blnRetrieveTotalCount = True
        'If the callmode if 'ByDate' then we need to convert the parameters to 'Date'
        Dim tblSubSitesList As DataTable = Nothing

        Dim intRowsPerPage As Integer = 25
        Try
            intRowsPerPage = CType(KartSettingsManager.GetKartConfig("backend.display.pagesize"), Double)
        Catch ex As Exception
            'Stays at 25
        End Try

        'See if date passed to page by querystring
        Dim strDateQS As String = Request.QueryString("strDate")

        'If date passed by querystring, set up page
        If IsDate(strDateQS) And Not Me.IsPostBack Then
            ViewState("_Callmode") = OrdersBLL.ORDERS_LIST_CALLMODE.BYDATE
            ViewState("_datValue1") = strDateQS
            ViewState("_datValue2") = Date.MinValue
        End If

        'backend.search.pagesize
        If ViewState("_BatchProcess") Then ViewState("_Callmode") = OrdersBLL.ORDERS_LIST_CALLMODE.BYDATE

        tblSubSitesList = SubSitesBLL.GetSubSites()

        _RowCount = tblSubSitesList.Rows.Count



        If Not blnTableCopied Then
            ViewState("originalValuesDataTable") = tblSubSitesList
            blnTableCopied = True
        End If

        gvwSubSites.DataSource = tblSubSitesList
        gvwSubSites.DataBind()

    End Sub

    Protected Sub lnkBtnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Page.Validate()
        If Page.IsValid Then
            Dim newId = SubSitesBLL._Add(txtSubSiteName.Text, txtSubSiteDomain.Text, lbxCategory.Items(0).Value, ddlistTheme.SelectedItem.Value, txtSubSiteNotes.Text, chkSubSiteLive.Checked)
            If newId > 0 Then
                phdupdSubSiteDetails.Visible = False
                gvwSubSites.Visible = True
                RefreshSubSiteList()
                updSubSites.Update()
                RaiseEvent ShowMasterUpdate()
            End If

        End If
    End Sub

End Class
