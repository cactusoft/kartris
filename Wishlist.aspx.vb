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
Partial Class Wishlist
    Inherits PageBaseClass
    Private blnPrivate As Boolean = False

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim numCustomerID As Integer = 0
        Dim numWishlistID As Integer = 0

        blnPrivate = False
        If Not (IsPostBack) Then

            Try
                numWishlistID = CInt(Request.QueryString("WishlistID"))
            Catch ex As Exception
            End Try

            If numWishlistID > 0 Then ''// query string paramater passed

                If Not (User.Identity.IsAuthenticated) Then
                    numCustomerID = 0
                Else
                    numCustomerID = CurrentLoggedUser.ID
                End If

                Dim tblWishList As New DataTable
                Dim objBasket As New BasketBLL

                tblWishList = objBasket.GetCustomerWishList(numCustomerID, numWishlistID)

                Dim blnAllow As Boolean = False
                If tblWishList.Rows.Count > 0 Then
                    If tblWishList.Rows(0).Item("WL_UserID") = numCustomerID Then blnAllow = True
                End If

                If blnAllow Then ''// current login is the owner of passed wishlist id 
                    blnPrivate = True
                    litOwnerName.Text = Server.HtmlEncode(CkartrisDataManipulation.FixNullFromDB(tblWishList.Rows(0).Item("U_AccountHolderName"))) & ""
                    If litOwnerName.Text = "" Then litOwnerName.Text = Server.HtmlEncode(tblWishList.Rows(0).Item("U_EmailAddress")) & ""
                    litMessage.Text = tblWishList.Rows(0).Item("WL_Message")
                    rptWishList.DataSource = objBasket.GetRequiredWishlist(numCustomerID, numWishlistID, Session("LANG"))
                    rptWishList.DataBind()
                    pnlLogin.Visible = False
                    pnlWishlist.Visible = True
                Else ''// wishlist id is from the other owner or wishlist id doesn't exist
                    With popMessage
                        .SetTitle = GetGlobalResourceObject("Kartris", "PageTitle_WishListLogin")
                        .SetTextMessage = GetGlobalResourceObject("Kartris", "ContentText_WishListNotFound")
                        .ShowPopup()
                    End With
                    pnlLogin.Visible = True
                    pnlWishlist.Visible = False
                End If

                tblWishList.Dispose()
                objBasket = Nothing

            Else ''// invalid passed wishlist id or not passed

                blnPrivate = False

                ''// for kartris v2
                Dim objSession As New SessionsBLL
                If Val(objSession.Value("WL_ID")) > 0 Then ''// get wishlist from current session

                    Dim tblWishList As New DataTable
                    Dim objBasket As New BasketBLL


                    ''// for kartris v2
                    With objSession
                        Session("WL_ID") = .Value("WL_ID")
                        litOwnerName.Text = Server.HtmlEncode(.Value("WL_Owner"))
                        litMessage.Text = Server.HtmlEncode(.Value("WL_Message"))
                        rptWishList.DataSource = objBasket.GetRequiredWishlist(Val(.Value("WL_UserID")), Val(.Value("WL_ID")), Session("LANG"))
                        rptWishList.DataBind()
                    End With

                    tblWishList.Dispose()
                    objBasket = Nothing

                    pnlLogin.Visible = False
                    pnlWishlist.Visible = True

                Else
                    pnlLogin.Visible = True
                    pnlWishlist.Visible = False
                End If

            End If

        End If

    End Sub

    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If blnPrivate Then
            phdLogout.Visible = False
        Else
            phdLogout.Visible = True
        End If
    End Sub

    Protected Sub rptWishList_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptWishList.ItemDataBound

        If e.Item.ItemType = ListItemType.Item Or e.Item.ItemType = ListItemType.AlternatingItem Then
            CType(e.Item.FindControl("lnkWishListItem"), HyperLink).Text = e.Item.DataItem("VersionName")
            Dim strURL As String = SiteMapHelper.CreateURL(SiteMapHelper.Page.CanonicalProduct, e.Item.DataItem("V_ProductID"))
            Dim strOptionLink As String = ""

            Dim objOptionsBasket As New BasketBLL

            If Not String.IsNullOrEmpty(objOptionsBasket.GetOptionText(CkartrisBLL.GetLanguageIDfromSession, e.Item.DataItem("BV_ID"), strOptionLink)) Then
                strOptionLink = "&strOptions=" & strOptionLink
            Else
                strOptionLink = "&strOptions=0"
            End If

            If strURL.Contains("?") Then
                strURL = strURL & strOptionLink
            Else
                strURL = strURL & Replace(strOptionLink, "&", "?")
            End If

            CType(e.Item.FindControl("lnkWishListItem"), HyperLink).NavigateUrl = strURL

            objOptionsBasket = Nothing

            If blnPrivate Then
                CType(e.Item.FindControl("litRequired"), Literal).Text = e.Item.DataItem("WishlistQty") & "/" & e.Item.DataItem("BV_Quantity") & " " & GetGlobalResourceObject("Kartris", "ContentText_StillRequired")
            Else
                CType(e.Item.FindControl("litRequired"), Literal).Text = e.Item.DataItem("WishlistQty") & " " & GetGlobalResourceObject("Kartris", "ContentText_StillRequired")
            End If

            If e.Item.DataItem("WishlistQty") < 1 Then
                CType(e.Item.FindControl("litRequired"), Literal).Text = GetGlobalResourceObject("Kartris", "ContentText_AllRequiredPurchased")
            End If

        End If

    End Sub

    Sub WishListLogin_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        Dim objBasket As New BasketBLL

        Dim strWishlistEmail As String = Trim(txtWishListEmail.Text)
        Dim strPassword As String = Trim(txtPassword.Text)

        Dim tblWishList As DataTable = objBasket.GetWishListLogin(strWishlistEmail, strPassword)

        If tblWishList.Rows.Count > 0 Then

            ''// for kartris v2
            Dim objSession As New SessionsBLL
            With objSession
                .Edit("WL_UserID", tblWishList.Rows(0).Item("WL_UserID"))
                .Edit("WL_ID", tblWishList.Rows(0).Item("WL_ID"))
                .Edit("WL_Owner", IIf(tblWishList.Rows(0).Item("U_AccountHolderName") & "" = "", strWishlistEmail, tblWishList.Rows(0).Item("U_AccountHolderName")))
                .Edit("WL_Message", tblWishList.Rows(0).Item("WL_Message"))
            End With
            litOwnerName.Text = Server.HtmlEncode(IIf(tblWishList.Rows(0).Item("U_AccountHolderName") & "" = "", strWishlistEmail, tblWishList.Rows(0).Item("U_AccountHolderName")))
            litMessage.Text = Server.HtmlEncode(tblWishList.Rows(0).Item("WL_Message"))

            rptWishList.DataSource = objBasket.GetRequiredWishlist(tblWishList.Rows(0).Item("WL_UserID"), tblWishList.Rows(0).Item("WL_ID"), Session("LANG"))
            rptWishList.DataBind()

            Session("WL_UserID") = tblWishList.Rows(0).Item("WL_UserID")
            Session("WL_ID") = tblWishList.Rows(0).Item("WL_ID")
            Session("WL_Owner") = IIf(tblWishList.Rows(0).Item("U_AccountHolderName") & "" = "", strWishlistEmail, tblWishList.Rows(0).Item("U_AccountHolderName"))
            Session("WL_Message") = tblWishList.Rows(0).Item("WL_Message")

            tblWishList.Dispose()
            objBasket = Nothing

            pnlLogin.Visible = False
            pnlWishlist.Visible = True

            updWishlist.Update()
        Else
            With popMessage
                .SetTitle = GetGlobalResourceObject("Kartris", "PageTitle_WishListLogin")
                .SetTextMessage = GetGlobalResourceObject("Kartris", "ContentText_WishListNotFound")
                .ShowPopup()
            End With
        End If

        tblWishList.Dispose()
        objBasket = Nothing

    End Sub

    Protected Sub Logout_Click()

        ''// for kartris v2
        Dim objSession As New SessionsBLL
        With objSession
            .Delete("WL_UserID")
            .Delete("WL_ID")
            .Delete("WL_Owner")
            .Delete("WL_Message")
        End With
        ''//

        ''// to be removed
        Session("WL_UserID") = 0
        Session("WL_ID") = 0
        Session("WL_Owner") = ""
        Session("WL_Message") = ""

        txtPassword.Text = ""

        pnlLogin.Visible = True
        pnlWishlist.Visible = False

        updWishlist.Update()

    End Sub
End Class
