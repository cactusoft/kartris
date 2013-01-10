'========================================================================
'Kartris - www.kartris.com
'Copyright 2013 CACTUSOFT INTERNATIONAL FZ LLC

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
Imports CkartrisDisplayFunctions
Imports System.Web.HttpContext
Imports CkartrisBLL
Imports CkartrisDataManipulation

Partial Class contact
    Inherits PageBaseClass

    Shared Basket As New BasketBLL
    Shared BasketItems As ArrayList

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetGlobalResourceObject("Kartris", "PageTitle_ContactUs") & " | " & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))
        If Not Page.IsPostBack Then
            If GetKartConfig("frontend.cataloguemode") = "y" Then
                chkIncludeItems.Checked = False
                chkIncludeItems.Visible = False
            End If
        End If
    End Sub

    Protected Sub btnSendMessage_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSendMessage.Click
        Page.Validate()
        If Page.IsValid AndAlso ajaxNoBotContact.IsValid Then

            Dim strTo As String = LanguagesBLL.GetEmailToContact(GetLanguageIDfromSession)
            Dim strBody As String = CreateMessageBody()
            Dim strFrom As String = ""
            If GetKartConfig("general.email.spoofcontactmail") = "y" Then strFrom = txtEmail.Text Else strFrom = LanguagesBLL.GetEmailFrom(GetLanguageIDfromSession)
            If SendEmail(strFrom, strTo, GetGlobalResourceObject("Kartris", "PageTitle_ContactUs") & " - " & txtName.Text, strBody, strFrom, txtName.Text) Then
                litResult.Text = GetGlobalResourceObject("Kartris", "ContentText_MailWasSent")
                ClearForm()
            Else
                litResult.Text = GetGlobalResourceObject("Kartris", "ContentText_Error")
            End If

            ClearForm() '' Clear the form for new reviews.
            mvwWriting.SetActiveView(viwWritingResult)   '' Activates the Result View.

        End If
        updMain.Update()
    End Sub

    Function CreateMessageBody() As String
        Dim strBldr As New StringBuilder("")
        strBldr.Append(GetGlobalResourceObject("Email", "EmailText_ContactStart") & " " & Current.Request.Url.ToString & vbCrLf)
        strBldr.Append(GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker"))
        strBldr.Append(GetGlobalResourceObject("Email", "EmailText_ContactName") & txtName.Text & vbCrLf)
        strBldr.Append(GetGlobalResourceObject("Email", "EmailText_ContactEmail") & txtEmail.Text & vbCrLf)
        strBldr.Append(GetGlobalResourceObject("Email", "EmailText_ContactIP") & Request.ServerVariables("REMOTE_ADDR") & vbCrLf)
        strBldr.Append(GetGlobalResourceObject("Email", "EmailText_ContactDateStamp") & Now.ToString & vbCrLf)
        strBldr.Append(GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker"))
        strBldr.Append(txtMessage.Text)
        If chkIncludeItems.Checked Then strBldr.Append(GetBasket())
        Return strBldr.ToString
    End Function

    Function GetBasket() As String
        Dim _Item As BasketItem
        Basket.LoadBasketItems()
        BasketItems = Basket.GetItems
        If BasketItems.Count = 0 Then Return vbCrLf
        Dim strBldrItems As New StringBuilder("")
        strBldrItems.Append(vbCrLf & GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker"))
        strBldrItems.Append(GetGlobalResourceObject("Email", "EmailText_ContactBasketContents") & vbCrLf)
        For i As Integer = 0 To BasketItems.Count - 1
            _Item = BasketItems(i)
            strBldrItems.Append(_Item.Quantity & " X " & _Item.ProductName & " - " & _Item.VersionName & " (" & _Item.VersionCode & ")" & vbCrLf)
        Next
        strBldrItems.Append(GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker"))
        Return strBldrItems.ToString
    End Function

    Sub ClearForm()
        txtName.Text = String.Empty
        txtEmail.Text = String.Empty
        txtMessage.Text = String.Empty
    End Sub

    Protected Sub btnBack_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        mvwWriting.SetActiveView(viwWritingForm)
    End Sub

End Class
