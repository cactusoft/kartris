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
Partial Class UserControls_Skin_LanguageDropdown
    Inherits System.Web.UI.UserControl

    Dim strLanguageImages As String = "~/Images/Languages/"

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If KartSettingsManager.GetKartConfig("frontend.languages.display") = "dropdown" Then
            selLanguage.Visible = True
            phdLanguageImages.Visible = False
        Else
            selLanguage.Visible = False
            phdLanguageImages.Visible = True
        End If
        If LanguagesBLL.GetLanguagesCount() = 1 Then
            Me.Visible = False
        End If
    End Sub

    Protected Sub selLanguage_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles selLanguage.SelectedIndexChanged
        ChangeLanguage(selLanguage.SelectedValue.ToString)
    End Sub

    Protected Sub selLanguage_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles selLanguage.Load
        If Not Page.IsPostBack And KartSettingsManager.GetKartConfig("frontend.languages.display") = "dropdown" _
           And Session("KartrisUserCulture") IsNot Nothing Then
            If Not String.IsNullOrEmpty(Session("KartrisUserCulture")) Then
                selLanguage.SelectedValue = Session("KartrisUserCulture").ToString
            End If
        End If
    End Sub

    Protected Sub rptLanguages_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.RepeaterCommandEventArgs) Handles rptLanguages.ItemCommand
        If e.CommandName = "ChangeLanguage" Then
            ChangeLanguage(e.CommandArgument)
        End If
    End Sub

    Protected Sub rptLanguages_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptLanguages.ItemDataBound
        If e.Item.ItemType = ListItemType.AlternatingItem OrElse _
                e.Item.ItemType = ListItemType.Item Then
            Dim strImageName As String = CType(e.Item.FindControl("lnkImage"), LinkButton).CommandArgument
            Dim dirLanguageImages As New DirectoryInfo(Server.MapPath(strLanguageImages))
            For Each objFile As FileInfo In dirLanguageImages.GetFiles()
                If objFile.Name.StartsWith(strImageName & ".") Then
                    CType(e.Item.FindControl("imgLanguage"), Image).ImageUrl = strLanguageImages & objFile.Name & "?nocache=" & Now.ToBinary
                    Exit For
                End If
            Next
            If CType(e.Item.FindControl("lnkImage"), LinkButton).CommandArgument = Session("KartrisUserCulture").ToString Then
                CType(e.Item.FindControl("lnkImage"), LinkButton).Enabled = False
            End If
        End If
    End Sub

    Sub ChangeLanguage(ByVal strCulture As String)
        'if the session differs from the value in the ddl, the session-object is changed and the cookie is created
        Dim CQSC As New CurrentQSCollection

        Session("KartrisUserCulture") = strCulture
        Dim numLangID As Byte = LanguagesBLL.GetLanguageIDByCulture_s(strCulture)
        Session("LANG") = numLangID
        CQSC.Set("L", numLangID)
        Dim aCookie As New HttpCookie(Trim(KartSettingsManager.GetKartConfig("general.sessions.cookiename")))
        aCookie.Values("KartrisUserCulture") = Session("KartrisUserCulture")
        aCookie.Expires = System.DateTime.Now.AddDays(21)
        Response.Cookies.Add(aCookie)
        Session("Skin_Location") = LanguagesBLL.GetSkinURLByCulture(strCulture)

        'Reload the page
        Response.Redirect(Request.Url.GetLeftPart(UriPartial.Path) & CQSC.ToString())
    End Sub

    ''' <summary>
    ''' This class allows us to get and modify any QueryString value from the URL. See usage above.
    ''' </summary>
    ''' <remarks></remarks>
    Public Class CurrentQSCollection
        Inherits NameValueCollection
        Public Sub New()
            For Each key As String In HttpContext.Current.Request.QueryString.AllKeys
                Add(key, HttpContext.Current.Request.QueryString(key))
            Next
        End Sub

        Public Overloads Overrides Function ToString() As String
            Dim sb As New StringBuilder()
            For i As Integer = 0 To Count - 1
                Dim key As String = Keys(i)
                sb.Append(((If((i = 0), "?", "&")) + key & "=") + HttpContext.Current.Server.UrlEncode(Me(key)))
            Next
            Return sb.ToString()
        End Function
    End Class

End Class
