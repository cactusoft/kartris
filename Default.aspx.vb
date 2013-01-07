'[[[NEW COPYRIGHT NOTICE]]]
Imports KartSettingsManager

Partial Class Main
    Inherits PageBaseClass

    Private objBasket As New BasketBLL

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'Mailing list confirmation
        'Do this here rather than myaccount so
        'it does not rely on user being logged
        'in to account

        If Request.QueryString("id") <> "" And Request.QueryString("r") <> "" Then
            Dim intResult, UserID As Integer, strPassword As String

            UserID = CInt(Request.QueryString("id"))
            strPassword = Request.QueryString("r")
            'strAction = "home"

            intResult = objBasket.ConfirmMail(UserID, strPassword)
            If intResult <> 0 Then
                With UC_PopUpConfirmMail
                    '.SetWidthHeight(300, 75)
                    .SetTitle = GetGlobalResourceObject("Kartris", "PageTitle_MailingListProcess")
                    .SetTextMessage = GetGlobalResourceObject("Kartris", "ContentText_Thankyou")
                    .ShowPopup()
                End With
            End If

        End If

        If Not Page.IsPostBack Then
            'Set number of news stories
            UC_SiteNews.MaxItems = CShort(GetKartConfig("frontend.news.max"))

            'Set canonical tag to webshopURL
            Me.CanonicalTag = LCase(GetKartConfig("general.webshopurl"))
        End If

        If CInt(GetKartConfig("frontend.featuredproducts.display.max")) = 0 Then UC_FeaturedProducts.Visible = False

    End Sub

End Class
