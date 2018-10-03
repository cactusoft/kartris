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

            ViewState("Referer") = Request.ServerVariables("HTTP_REFERER")


            Try
                'Get the Order ID QueryString - if it won't convert to integer then force return to Orders List page
                ViewState("numSubSiteID") = CType(Request.QueryString("SubSiteID"), Integer)
                If ViewState("numSubSiteID") <> 0 Then
                    Dim subSiteDataTable As DataTable = SubSitesBLL.GetSubSiteByID(ViewState("numSubSiteID"))
                    fvwSubSiteDetails.DataSource = subSiteDataTable
                    fvwSubSiteDetails.DataBind()

                    Dim numCategoryID As Object = subSiteDataTable.Rows.Item(0).Item("SUB_BaseCategoryID")

                    If numCategoryID IsNot Nothing Then
                        Dim strCategoryName As Object = subSiteDataTable.Rows.Item(0).Item("CAT_Name")
                        lbxCategory.Items.Add(New ListItem(strCategoryName, CStr(numCategoryID)))
                        lbxCategory.SelectedIndex = lbxCategory.Items.Count - 1
                    End If
                Else
                    fvwSubSiteDetails.ChangeMode(FormViewMode.Insert)
                    'txtSubSiteName.Text = ""
                End If

            Catch ex As Exception
                CkartrisFormatErrors.LogError(ex.Message)
                Response.Redirect("_SubSitesList.aspx")
            End Try

            SetThemeDropDown()
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
        If GetSubSiteID() > 0 Then
            Page.Validate()
            If Page.IsValid Then

                SubSitesBLL._Update(GetSubSiteID(), txtSubSiteName.Text, txtSubSiteDomain.Text, lbxCategory.Items(0).Value, 1, txtSubSiteNotes.Text, chkSubSiteLive.Checked)

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
        strURL = "javascript:history.back()"

        Return strURL
    End Function


    ''' <summary>
    ''' when the order details are bound to the data
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub fvwOrderDetails_DataBound(ByVal sender As Object, ByVal e As System.EventArgs) Handles fvwSubSiteDetails.DataBound

        'Dim hidOrderCoupon As HiddenField = DirectCast(fvwSubSiteDetails.FindControl("hidOrderCoupon"), HiddenField)
        'Dim hidOrderText As HiddenField = DirectCast(fvwSubSiteDetails.FindControl("hidOrderText"), HiddenField)

        'Dim hidAffiliatePaymentID As HiddenField = DirectCast(fvwOrderDetails.FindControl("hidAffiliatePaymentID"), HiddenField)
        'Dim hidOrderCurrencyID As HiddenField = DirectCast(fvwOrderDetails.FindControl("hidOrderCurrencyID"), HiddenField)
        'Dim phdAffiliate As PlaceHolder = DirectCast(fvwOrderDetails.FindControl("phdAffiliate"), PlaceHolder)
        'Dim litOrderTotalPrice As Literal = DirectCast(fvwOrderDetails.FindControl("litOrderTotalPrice"), Literal)
        'Dim litOrderLanguage As Literal = DirectCast(fvwOrderDetails.FindControl("litOrderLanguage"), Literal)
        'Dim txtOrderShippingAddress As TextBox = DirectCast(fvwOrderDetails.FindControl("txtOrderShippingAddress"), TextBox)
        'Dim hidOrderData As HiddenField = DirectCast(fvwOrderDetails.FindControl("hidOrderData"), HiddenField)

        'Dim dblOrderTotalPrice As Single = CSng(litOrderTotalPrice.Text)
        'Dim srtOrderCurrencyID As Short = CShort(hidOrderCurrencyID.Value)

        'Get the initial values of the checkboxes and store them in the variables
        'ViewState("SUB_Live") = DirectCast(fvwSubSiteDetails.FindControl("chkSubSiteLive"), CheckBox).Checked

    End Sub

    Protected Function GetSubSiteID() As Integer
        Try
            Return CInt(Request.QueryString("SubSiteID"))
        Catch ex As Exception
        End Try
        Return 0
    End Function

    ''' <summary>
    ''' handles updating the order
    ''' </summary>
    ''' <remarks></remarks>
    'Public Sub fvwOrderDetails_ItemUpdating(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.FormViewUpdateEventArgs) Handles fvwSubSiteDetails.ItemUpdating
    '    Dim chkOrderSent As CheckBox = DirectCast(fvwOrderDetails.FindControl("chkOrderSent"), CheckBox)
    '    Dim chkOrderPaid As CheckBox = DirectCast(fvwOrderDetails.FindControl("chkOrderPaid"), CheckBox)
    '    Dim chkOrderInvoiced As CheckBox = DirectCast(fvwOrderDetails.FindControl("chkOrderInvoiced"), CheckBox)
    '    Dim chkOrderShipped As CheckBox = DirectCast(fvwOrderDetails.FindControl("chkOrderShipped"), CheckBox)
    '    Dim txtOrderStatus As TextBox = DirectCast(fvwOrderDetails.FindControl("txtOrderStatus"), TextBox)
    '    Dim txtOrderNotes As TextBox = DirectCast(fvwOrderDetails.FindControl("txtOrderNotes"), TextBox)
    '    Dim chkOrderCancelled As CheckBox = DirectCast(fvwOrderDetails.FindControl("chkOrderCancelled"), CheckBox)

    '    Dim hidSendOrderUpdateEmail As HiddenField = DirectCast(fvwOrderDetails.FindControl("hidSendOrderUpdateEmail"), HiddenField)

    '    'This line is actually the one that updates the order - not the built-in FormView update. Gives us more flexibility - needs to catch some thingies. =)
    '    If OrdersBLL._UpdateStatus(ViewState("numOrderID"), chkOrderSent.Checked, chkOrderPaid.Checked, chkOrderShipped.Checked,
    '                            chkOrderInvoiced.Checked, txtOrderStatus.Text, txtOrderNotes.Text, chkOrderCancelled.Checked) > 0 Then
    '        If KartSettingsManager.GetKartConfig("general.mailchimp.enabled") = "y" Then
    '            Try
    '                If chkOrderPaid.Checked Then
    '                    Dim hidOrderCurrencyID As HiddenField = DirectCast(fvwOrderDetails.FindControl("hidOrderCurrencyID"), HiddenField)
    '                    Dim intOrderCurrencyID As Integer = CInt(hidOrderCurrencyID.Value)
    '                    Dim hidCustomerID As HiddenField = DirectCast(fvwOrderDetails.FindControl("hidCustomerID"), HiddenField)
    '                    Dim kartrisUser As KartrisMemberShipUser = Membership.GetUser(UsersBLL.GetEmailByID(CInt(hidCustomerID.Value)))
    '                    Dim basketObj As Basket = GetBasket(ViewState("numOrderID"))

    '                End If
    '            Catch ex As Exception
    '                'Oops
    '            End Try

    '        End If

    '        RaiseEvent ShowMasterUpdate()
    '    Else
    '        'error
    '    End If

    'End Sub

    ''' <summary>
    ''' If 'edit' clicked, redirects to order editing page
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub lnkBtnEdit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("_ModifySubSite.aspx?SubSiteID=" & ViewState("numSubSiteID"))
    End Sub

End Class
