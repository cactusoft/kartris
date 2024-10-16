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
'========================================================================
Imports KartSettingsManager

Partial Class Main
    Inherits PageBaseClass

    Private objBasket As New kartris.Basket

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

            intResult = BasketBLL.ConfirmMail(UserID, strPassword)
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
            'Set canonical tag to webshopURL
            Me.CanonicalTag = CkartrisBLL.WebShopURL
        End If

    End Sub

End Class
