'========================================================================
'Kartris - www.kartris.com
'Copyright 2017 CACTUSOFT

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
Imports System.Web.HttpContext
Imports CkartrisDataManipulation

Partial Class Customer
    Inherits PageBaseClass

    Protected Shared blnNoBasketItem As Boolean
    Protected numCustomerDiscount As Double
    Protected Shared AFF_IsAffiliate As Boolean
    Protected Shared AFF_AffiliateCommission As Double
    Protected ML_SignupDateTime, ML_ConfirmationDateTime As DateTime

    Private objBasket As New kartris.Basket
    Private numAppMaxOrders, numAppMaxBaskets As Integer
    Private strAppUploadsFolder, strShow As String
    Private tblOrder, tblSavedBasket, tblWishLists, dtbDownloadableProducts As Data.DataTable
    Private numCustomerID As Integer
    Private ML_SendMail As Boolean
    Private ML_Format As String
    Private strAction As String
    Private SESSION_ID As Integer

    Private Shared Order_PageSize As Integer
    Private Shared SavedBasket_PageSize As Integer
    Private Shared WishList_PageSize As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        strAction = LCase(Request.QueryString("action"))
        If strAction <> "savebasket" AndAlso strAction <> "wishlists" Then strAction = "home"

        SESSION_ID = Session("SessionID")

        If Not (User.Identity.IsAuthenticated) Then
            Response.Redirect("~/CustomerAccount.aspx")
        Else
            numCustomerID = CurrentLoggedUser.ID
        End If

        Try
            numAppMaxOrders = CInt(KartSettingsManager.GetKartConfig("frontend.users.myaccount.orderhistory.max"))
            numAppMaxBaskets = CInt(KartSettingsManager.GetKartConfig("frontend.users.myaccount.savedbaskets.max"))
            strAppUploadsFolder = KartSettingsManager.GetKartConfig("general.uploadfolder")
        Catch ex As Exception
        End Try

        strShow = ""
        'If we're showing a full list, or config settings set to 0, then don't limit (-2)
        If numAppMaxOrders = 0 Or strShow = "orders" Then numAppMaxOrders = -2
        If numAppMaxBaskets = 0 Or strShow = "baskets" Then numAppMaxBaskets = -2
        If numAppMaxBaskets = 0 Or strShow = "wishlists" Then numAppMaxBaskets = -2

        numCustomerDiscount = BasketBLL.GetCustomerDiscount(numCustomerID)

        'Hide tabs when not necessary
        If LCase(KartSettingsManager.GetKartConfig("frontend.cataloguemode")) = "y" Then
            acpDownloadableProducts.Visible = False
            acpSavedBaskets.Visible = False
            acpWishLists.Visible = False
            pnlSaveWishLists.Visible = False
            pnlSaveBasket.Visible = False
        Else
            'Show/hide order history
            If Val(KartSettingsManager.GetKartConfig("frontend.users.myaccount.orderhistory.max")) = 0 Then
                acpOrderHistory.Visible = False
            Else
                acpOrderHistory.Visible = True
            End If
            'Show/hide saved baskets
            If Val(KartSettingsManager.GetKartConfig("frontend.users.myaccount.savedbaskets.max")) = 0 Then
                acpSavedBaskets.Visible = False
            Else
                acpSavedBaskets.Visible = True
            End If
            'Show/hide wishlists
            If LCase(KartSettingsManager.GetKartConfig("frontend.users.wishlists.enabled")) = "n" Or Val(KartSettingsManager.GetKartConfig("frontend.users.myaccount.wishlists.max")) = 0 Then
                acpWishLists.Visible = False
            Else
                acpWishLists.Visible = True
            End If
            'Show/hide affiliates
            If LCase(KartSettingsManager.GetKartConfig("frontend.users.myaccount.affiliates.enabled")) = "n" Then
                acpAffiliates.Visible = False
            Else
                acpAffiliates.Visible = True
            End If
            'Show/hide mailing list
            If LCase(KartSettingsManager.GetKartConfig("frontend.users.mailinglist.enabled")) = "n" Then
                acpMailingList.Visible = False
            Else
                acpMailingList.Visible = True
            End If
        End If

    End Sub

    'We create two download links on the page (.aspx),
    'one is a linkbutton to trigger local file download,
    'the other is a hyperlink to a fully-qualified URL.
    'We use the code below to hide the one that isn't
    'needed when the item is databound.
    Protected Sub rptDownloadableProducts_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptDownloadableProducts.ItemDataBound
        Dim strDownloadType As String
        If e.Item.ItemType = ListItemType.Item Or e.Item.ItemType = ListItemType.AlternatingItem Then
            strDownloadType = e.Item.DataItem("V_DownloadType")
            If strDownloadType = "l" Then
                'Full qualified path
                'Hide link button
                CType(e.Item.FindControl("lnkDownload"), LinkButton).Visible = False
            Else
                'local file, type "u"
                'Hide hyperlink
                CType(e.Item.FindControl("hlnkDownload"), HyperLink).Visible = False
            End If
        End If
    End Sub

    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender

        If Not IsPostBack Then

            phdSaveBasket.Visible = False
            phdHome.Visible = False
            phdSaveWishLists.Visible = False

            dtbDownloadableProducts = BasketBLL.GetDownloadableProducts(numCustomerID)
            If dtbDownloadableProducts.Rows.Count > 0 Then
                phdDownloadableProducts.Visible = True
                rptDownloadableProducts.DataSource = dtbDownloadableProducts
                rptDownloadableProducts.DataBind()
            Else
                phdDownloadableProducts.Visible = False
                acpDownloadableProducts.Visible = False
            End If
            Select Case LCase(strAction)
                Case "savebasket"
                    Me.Title = GetGlobalResourceObject("Basket", "PageTitle_SaveRecoverBasketContents") & GetGlobalResourceObject("Kartris", "PageTitle_Separator") & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))
                    phdSaveBasket.Visible = True

                Case "home"
                    Me.Title = GetGlobalResourceObject("Kartris", "PageTitle_MyAccount") & GetGlobalResourceObject("Kartris", "PageTitle_Separator") & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))
                    phdHome.Visible = True

                    Dim tblCustomerData As Data.DataTable

                    ''// initialize orders navigation page
                    Order_PageSize = CInt(KartSettingsManager.GetKartConfig("frontend.users.myaccount.orderhistory.max"))
                    ViewState("Order_PageTotalSize") = BasketBLL.GetCustomerOrdersTotal(numCustomerID)
                    ViewState("Order_PageIndex") = 1
                    lnkBtnOrderPrev.Enabled = False : lnkBtnOrderNext.Enabled = True
                    If Order_PageSize >= ViewState("Order_PageTotalSize") Then
                        lnkBtnOrderPrev.Visible = False : lnkBtnOrderNext.Visible = False
                    End If

                    Call BuildNavigatePage("order")

                    ''// initialize saved baskets navigation page
                    SavedBasket_PageSize = CInt(KartSettingsManager.GetKartConfig("frontend.users.myaccount.savedbaskets.max"))
                    ViewState("SavedBasket_PageTotalSize") = BasketBLL.GetSavedBasketTotal(numCustomerID)
                    ViewState("SavedBasket_PageIndex") = 1
                    lnkBtnBasketPrev.Enabled = False : lnkBtnBasketNext.Enabled = True
                    If SavedBasket_PageSize >= ViewState("SavedBasket_PageTotalSize") Then
                        lnkBtnBasketPrev.Visible = False : lnkBtnBasketNext.Visible = False
                    End If

                    Call BuildNavigatePage("basket")

                    ''// initialize wishlists navigation page
                    WishList_PageSize = CInt(KartSettingsManager.GetKartConfig("frontend.users.myaccount.wishlists.max"))
                    ViewState("WishList_PageTotalSize") = BasketBLL.GetWishListTotal(numCustomerID)
                    ViewState("WishList_PageIndex") = 1
                    lnkBtnWishlistPrev.Enabled = False : lnkBtnWishlistNext.Enabled = True
                    If WishList_PageSize >= ViewState("WishList_PageTotalSize") Then
                        lnkBtnWishlistPrev.Visible = False : lnkBtnWishlistNext.Visible = False
                    End If

                    Call BuildNavigatePage("wishlist")

                    Dim oItems As New List(Of Kartris.BasketItem)
                    objBasket.LoadBasketItems()
                    oItems = objBasket.BasketItems
                    blnNoBasketItem = (oItems.Count = 0)


                    tblCustomerData = BasketBLL.GetCustomerData(numCustomerID)
                    If tblCustomerData.Rows.Count > 0 Then
                        ''// affiliate
                        AFF_IsAffiliate = FixNullFromDB(tblCustomerData.Rows(0).Item("U_IsAffiliate"))
                        AFF_AffiliateCommission = FixNullFromDB(tblCustomerData.Rows(0).Item("U_AffiliateCommission"))

                        ''// mailing list
                        ML_ConfirmationDateTime = FixNullFromDB(tblCustomerData.Rows(0).Item("U_ML_ConfirmationDateTime"))
                        ML_SignupDateTime = FixNullFromDB(tblCustomerData.Rows(0).Item("U_ML_SignupDateTime"))
                        ML_SendMail = FixNullFromDB(tblCustomerData.Rows(0).Item("U_ML_SendMail"))
                        ML_Format = FixNullFromDB(tblCustomerData.Rows(0).Item("U_ML_Format"))
                    End If

                    ddlMailingList.Items.Clear()
                    ddlMailingList.Items.Add(GetGlobalResourceObject("Kartris", "ContentText_SendMailsOff").ToString)
                    ddlMailingList.Items.Add(GetGlobalResourceObject("Checkout", "ContentText_SendMailsPlain").ToString)
                    ddlMailingList.Items.Add(GetGlobalResourceObject("Checkout", "ContentText_SendMailsHTML").ToString)
                    ddlMailingList.Items(0).Value = "n"
                    ddlMailingList.Items(1).Value = "t"
                    ddlMailingList.Items(2).Value = "h"
                    If ML_SendMail Then ddlMailingList.SelectedIndex = 0
                    If ML_SendMail AndAlso ML_Format <> "h" Then ddlMailingList.SelectedIndex = 1
                    If ML_SendMail AndAlso ML_Format = "h" Then ddlMailingList.SelectedIndex = 2


                Case "wishlists"
                    Me.Title = GetGlobalResourceObject("Kartris", "PageTitle_WishListLogin") & GetGlobalResourceObject("Kartris", "PageTitle_Separator") & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))
                    phdSaveWishLists.Visible = True

                    Dim numWishlistsID As Long

                    Try
                        numWishlistsID = IIf(Request.QueryString("WL_ID") = "", 0, CInt(Request.QueryString("WL_ID")))
                    Catch ex As Exception
                        Current.Response.Redirect("~/Customer.aspx")
                    End Try

                    If numWishlistsID <> 0 Then
                        tblWishLists = BasketBLL.GetCustomerWishList(numCustomerID, numWishlistsID)

                        If tblWishLists.Rows.Count > 0 Then
                            txtWL_Name.Text = FixNullFromDB(tblWishLists.Rows(0).Item("WL_Name")) & ""
                            txtWL_PublicPassword.Text = FixNullFromDB(tblWishLists.Rows(0).Item("WL_PublicPassword")) & ""
                            txtWL_Message.Text = FixNullFromDB(tblWishLists.Rows(0).Item("WL_Message")) & ""
                        Else
                            Current.Response.Redirect("~/Customer.aspx")
                        End If

                        tblWishLists = Nothing

                    Else
                        Dim tblCustomerData As New Data.DataTable
                        tblCustomerData = BasketBLL.GetCustomerData(numCustomerID)
                    End If
                Case Else

            End Select


        Else ''postback

            Select Case LCase(strAction)
                Case "savebasket"
                    Me.Title = GetGlobalResourceObject("Basket", "PageTitle_SaveRecoverBasketContents") & GetGlobalResourceObject("Kartris", "PageTitle_Separator") & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))

                Case "home"
                    Me.Title = GetGlobalResourceObject("Kartris", "PageTitle_MyAccount") & GetGlobalResourceObject("Kartris", "PageTitle_Separator") & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))

                Case "wishlists"
                    Me.Title = GetGlobalResourceObject("Kartris", "PageTitle_WishListLogin") & GetGlobalResourceObject("Kartris", "PageTitle_Separator") & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))

                Case Else

            End Select


        End If

    End Sub

    Sub RemoveSavedBasket_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        Dim numBasketID As Long

        numBasketID = E.CommandArgument
        BasketBLL.DeleteSavedBasket(numBasketID)
        Call BuildNavigatePage("basket")

    End Sub

    Sub LoadSavedBasket_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        Dim numSavedBasketID, numBasketID As Long

        numSavedBasketID = E.CommandArgument
        numBasketID = SESSION_ID
        BasketBLL.LoadSavedBasket(numSavedBasketID, numBasketID)
        blnNoBasketItem = objBasket.BasketItems.Count > 0

        Call RefreshMiniBasket()


    End Sub

    Sub SaveBasket_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        If Me.IsValid Then
            Call BasketBLL.SaveBasket(numCustomerID, Trim(txtBasketName.Text), SESSION_ID)
            Response.Redirect("~/Customer.aspx?action=home")
        End If
    End Sub

    Sub SaveWishLists_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        Dim strName, strPublicPassword, strMessage As String
        Dim strErrorMsg As New StringBuilder("")

        strName = txtWL_Name.Text
        strPublicPassword = txtWL_PublicPassword.Text
        strMessage = txtWL_Message.Text

        If Me.IsValid Then
            Dim tblWishLists As New DataTable

            Dim numWishlistsID As Long = IIf(Request.QueryString("WL_ID") = "", 0, CInt(Request.QueryString("WL_ID")))

            If numWishlistsID = 0 Then

                Dim strEmail As String = ""
                strEmail = CurrentLoggedUser.Email

                tblWishLists = BasketBLL.GetWishListLogin(strEmail, strPublicPassword)
                If tblWishLists.Rows.Count > 0 Then ''// password already exist for this owner
                    With UC_PopUpInfo
                        Dim strError As String = GetGlobalResourceObject("Kartris", "ContentText_WishListPublicPasswordExists")
                        strError = Replace(strError, "<label>", GetGlobalResourceObject("Kartris", "ContentText_WishListPublicPassword"))
                        .SetTitle = GetGlobalResourceObject("Kartris", "PageTitle_WishListLogin")
                        .SetTextMessage = strError
                        .ShowPopup()
                    End With
                Else ''// new wishlist (create it)
                    Call BasketBLL.SaveWishLists(numWishlistsID, SESSION_ID, numCustomerID, strName, strPublicPassword, strMessage)
                    Response.Redirect("~/Customer.aspx?action=home")
                End If

            Else ''// existing wishlist (update it)
                Call BasketBLL.SaveWishLists(numWishlistsID, SESSION_ID, numCustomerID, strName, strPublicPassword, strMessage)
                Response.Redirect("~/Customer.aspx?action=home")
            End If

        End If

    End Sub

    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancel.Click
        Response.Redirect("~/Customer.aspx?action=home")
    End Sub

    Protected Sub lnkDownload_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        DownloadFile(E.CommandArgument)
    End Sub

    Sub RemoveWishLists_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        Dim numWishListsID As Long

        numWishListsID = E.CommandArgument
        BasketBLL.DeleteWishLists(numWishListsID)
        Call BuildNavigatePage("wishlist")

    End Sub

    Sub EditWishLists_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        Dim numWishListsID As Long

        numWishListsID = E.CommandArgument

        Response.Redirect("~/Customer.aspx?action=wishlists&WL_ID=" & numWishListsID)

    End Sub

    Sub LoadWishLists_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        Dim numWishListsID, numBasketID As Long

        numWishListsID = E.CommandArgument
        numBasketID = SESSION_ID

        BasketBLL.LoadWishlists(numWishListsID, numBasketID)

        blnNoBasketItem = objBasket.BasketItems.Count > 0

        Call RefreshMiniBasket()

    End Sub

    Sub RefreshMiniBasket()
        Dim objMaster As MasterPage
        Dim objBasket As Object

        objMaster = Page.Master
        objBasket = objMaster.FindControl("UC_MiniBasket")
        objBasket.LoadMiniBasket()

    End Sub

    Function GetCustomerDiscount() As Double
        Dim numCustomerID As Integer
        numCustomerID = Val(SESSION_ID)
        Return BasketBLL.GetCustomerDiscount(numCustomerID)
    End Function

    Protected Sub PageNavigate_Click(ByVal sender As Object, ByVal E As CommandEventArgs)

        Select Case LCase(E.CommandName)
            Case "order"
                If LCase(sender.id) = "lnkbtnorderprev" Then
                    ViewState("Order_PageIndex") = ViewState("Order_PageIndex") - 1
                ElseIf LCase(sender.id) = "lnkbtnordernext" Then
                    ViewState("Order_PageIndex") = ViewState("Order_PageIndex") + 1
                End If
                lnkBtnOrderPrev.Enabled = IIf(ViewState("Order_PageIndex") <= 1, False, True)
                lnkBtnOrderNext.Enabled = IIf(ViewState("Order_PageIndex") >= ViewState("Order_PageTotalSize") / Order_PageSize, False, True)
                Call BuildNavigatePage("order")

            Case "basket"
                If LCase(sender.id) = "lnkbtnbasketprev" Then
                    ViewState("SavedBasket_PageIndex") = ViewState("SavedBasket_PageIndex") - 1
                ElseIf LCase(sender.id) = "lnkbtnbasketnext" Then
                    ViewState("SavedBasket_PageIndex") = ViewState("SavedBasket_PageIndex") + 1
                End If
                lnkBtnBasketPrev.Enabled = IIf(ViewState("SavedBasket_PageIndex") <= 1, False, True)
                lnkBtnBasketNext.Enabled = IIf(ViewState("SavedBasket_PageIndex") >= ViewState("SavedBasket_PageTotalSize") / SavedBasket_PageSize, False, True)
                Call BuildNavigatePage("basket")

            Case "wishlist"
                If LCase(sender.id) = "lnkbtnwishlistprev" Then
                    ViewState("WishList_PageIndex") = ViewState("WishList_PageIndex") - 1
                ElseIf LCase(sender.id) = "lnkbtnwishlistnext" Then
                    ViewState("WishList_PageIndex") = ViewState("WishList_PageIndex") + 1
                End If
                lnkBtnWishlistPrev.Enabled = IIf(ViewState("WishList_PageIndex") <= 1, False, True)
                lnkBtnWishlistNext.Enabled = IIf(ViewState("WishList_PageIndex") >= ViewState("WishList_PageTotalSize") / WishList_PageSize, False, True)
                Call BuildNavigatePage("wishlist")

        End Select

    End Sub

    Private Sub BuildNavigatePage(ByVal strPage As String)

        Select Case LCase(strPage)
            Case "order"
                tblOrder = BasketBLL.GetCustomerOrders(numCustomerID, (((ViewState("Order_PageIndex") - 1) * Order_PageSize) + 1), Order_PageSize)
                rptOrder.DataSource = tblOrder
                rptOrder.DataBind()
                updOrder.Update()

            Case "basket"
                tblSavedBasket = BasketBLL.GetSavedBasket(numCustomerID, (((ViewState("SavedBasket_PageIndex") - 1) * SavedBasket_PageSize) + 1), SavedBasket_PageSize)
                rptSavedBasket.DataSource = tblSavedBasket
                rptSavedBasket.DataBind()
                updSavedBaskets.Update()

            Case "wishlist"
                tblWishLists = BasketBLL.GetWishLists(numCustomerID, (((ViewState("WishList_PageIndex") - 1) * WishList_PageSize) + 1), WishList_PageSize)
                rptWishLists.DataSource = tblWishLists
                rptWishLists.DataBind()
                updWishlists.Update()

        End Select

    End Sub

    Sub Affiliate_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        Dim tblAffiliates As Data.DataTable

        With UC_PopUpInfo
            .SetTitle = GetGlobalResourceObject("Kartris", "PageTitle_Affiliates")
            .SetTextMessage = GetGlobalResourceObject("Kartris", "ContentText_AffiliateApplicationDetail")
            .ShowPopup()
        End With

        AffiliateBLL.UpdateCustomerAffiliateStatus(numCustomerID)

        tblAffiliates = BasketBLL.GetCustomerData(numCustomerID)
        If tblAffiliates.Rows.Count > 0 Then
            AFF_IsAffiliate = tblAffiliates.Rows(0).Item("U_IsAffiliate")
            AFF_AffiliateCommission = tblAffiliates.Rows(0).Item("U_AffiliateCommission")
        End If

        updAffiliates.Update()

    End Sub

    Sub MailingList_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        Dim strCommand As String
        Dim tblCustomerData As New Data.DataTable

        strCommand = E.CommandName

        If LCase(strCommand) = LCase("MailVerified") Then

            BasketBLL.UpdateCustomerMailFormat(numCustomerID, LCase(ddlMailingList.SelectedValue))

            With UC_PopUpMessage
                .SetTitle = GetGlobalResourceObject("Kartris", "PageTitle_MailingList")
                .SetTextMessage = GetGlobalResourceObject("Kartris", "ContentText_PreferencesChanged")
                .ShowPopup()
            End With

        Else ''// mail not verified or mail not signed up

            tblCustomerData = BasketBLL.GetCustomerData(numCustomerID)
            Dim strEmail As String = "", strPassword As String = ""

            If tblCustomerData.Rows.Count > 0 Then
                strEmail = FixNullFromDB(tblCustomerData.Rows(0).Item("U_EmailAddress")) & ""
            End If

            'Update user in our db
            BasketBLL.UpdateCustomerMailingList(strEmail, strPassword)

            'If mailchimp is active, we want to add the user to the mailing list
            If KartSettingsManager.GetKartConfig("general.mailchimp.enabled") = "y" Then
                'Add user direct to MailChimp
                BasketBLL.AddListSubscriber(strEmail)
            Else
                'Use the built in mailing list
                Dim sbdBodyText As StringBuilder = New StringBuilder()
                Dim strBodyText As String
                Dim strMailingListSignUpLink As String = WebShopURL() & "Default.aspx?id=" & numCustomerID & "&r=" & strPassword

                sbdBodyText.Append(GetGlobalResourceObject("Kartris", "EmailText_NewsletterSignup") & vbCrLf & vbCrLf)
                sbdBodyText.Append(strMailingListSignUpLink & vbCrLf & vbCrLf)
                sbdBodyText.Append(GetGlobalResourceObject("Kartris", "EmailText_NewsletterAuthorizeFooter"))

                strBodyText = sbdBodyText.ToString
                strBodyText = Replace(strBodyText, "[IPADDRESS]", Request.UserHostAddress())
                strBodyText = Replace(strBodyText, "[WEBSHOPNAME]", GetGlobalResourceObject("Kartris", "Config_Webshopname"))
                strBodyText = Replace(strBodyText, "[WEBSHOPURL]", WebShopURL)
                strBodyText = strBodyText & GetGlobalResourceObject("Kartris", "ContentText_NewsletterSignup")

                Dim strFrom As String = LanguagesBLL.GetEmailFrom(GetLanguageIDfromSession)

                Dim blnHTMLEmail As Boolean = KartSettingsManager.GetKartConfig("general.email.enableHTML") = "y"
                If blnHTMLEmail Then
                    Dim strHTMLEmailText As String = RetrieveHTMLEmailTemplate("MailingListSignUp")
                    'build up the HTML email if template is found
                    If Not String.IsNullOrEmpty(strHTMLEmailText) Then
                        strHTMLEmailText = strHTMLEmailText.Replace("[mailinglistconfirmationlink]", strMailingListSignUpLink)
                        strHTMLEmailText = strHTMLEmailText.Replace("[websitename]", GetGlobalResourceObject("Kartris", "Config_Webshopname"))
                        strHTMLEmailText = strHTMLEmailText.Replace("[customerip]", Request.UserHostAddress())
                        strBodyText = strHTMLEmailText
                    Else
                        blnHTMLEmail = False
                    End If
                End If
                SendEmail(strFrom, strEmail, GetGlobalResourceObject("Kartris", "PageTitle_MailingList"), strBodyText, , , , , blnHTMLEmail)
            End If





        End If

        tblCustomerData = BasketBLL.GetCustomerData(numCustomerID)
        If tblCustomerData.Rows.Count Then
            ML_ConfirmationDateTime = FixNullFromDB(tblCustomerData.Rows(0).Item("U_ML_ConfirmationDateTime"))
            ML_SignupDateTime = FixNullFromDB(tblCustomerData.Rows(0).Item("U_ML_SignupDateTime"))
            ML_SendMail = FixNullFromDB(tblCustomerData.Rows(0).Item("U_ML_SendMail"))
            ML_Format = FixNullFromDB(tblCustomerData.Rows(0).Item("U_ML_Format"))
        End If

        updMailingList.Update()
    End Sub

    Protected Sub rptOrder_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptOrder.ItemDataBound
        Dim numTotal As Double
        If e.Item.ItemType = ListItemType.Item Or e.Item.ItemType = ListItemType.AlternatingItem Then
            CType(e.Item.FindControl("lnkBtnOrderView"), LinkButton).PostBackUrl = "~/CustomerViewOrder.aspx?O_ID=" & e.Item.DataItem("O_ID")
            CType(e.Item.FindControl("lnkBtnOrderInvoice"), LinkButton).PostBackUrl = "~/CustomerInvoice.aspx?O_ID=" & e.Item.DataItem("O_ID")
            numTotal = e.Item.DataItem("O_TotalPrice")
            CType(e.Item.FindControl("litOrdersTotal"), Literal).Text = e.Item.DataItem("CUR_Symbol") & FormatNumber(Math.Round(numTotal, e.Item.DataItem("CUR_RoundNumbers")), 2)
        End If

    End Sub

    Protected Sub rptSavedBasket_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptSavedBasket.ItemDataBound

        If e.Item.ItemType = ListItemType.Item Or e.Item.ItemType = ListItemType.AlternatingItem Then
            CType(e.Item.FindControl("divBasketName"), HtmlGenericControl).InnerText = e.Item.DataItem("SBSKT_Name")
        End If

    End Sub

    Protected Sub rptWishLists_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptWishLists.ItemDataBound

        If e.Item.ItemType = ListItemType.Item Or e.Item.ItemType = ListItemType.AlternatingItem Then
            CType(e.Item.FindControl("spnWishListName"), HtmlGenericControl).InnerText = e.Item.DataItem("WL_Name")
        End If

    End Sub

End Class
