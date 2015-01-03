'========================================================================
'Copyright 2014 BORNXenon
'incorporated into Kartris with permission

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html
'========================================================================
Imports System.Xml
Imports System.Text
Imports CkartrisDisplayFunctions

Partial Class rss
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load

        Dim intSizeOfFeed As Integer = 25
        Dim strWebshopURL As String = CkartrisBLL.WebShopURLhttp
        Dim strWebshopName As String = Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))
        Dim intLanguageID As Integer = CkartrisBLL.GetLanguageIDfromSession
        Dim strSkinFolder As String = LanguagesBLL.GetTheme(intLanguageID)
        Dim intLanguage As Integer = Session("LANG")

        'If Session is empty, get default language
        If intLanguage = 0 Then
            intLanguage = KartSettingsManager.GetKartConfig("frontend.languages.default")
        End If

        'Check for Empty Skin Folder
        If String.IsNullOrEmpty(strSkinFolder) Then
            strSkinFolder = "Kartris"
        End If

        ' Clear any previous output from the buffer
        Response.Clear()
        Response.ContentType = "application/xml"

        ' XML Declaration Tag
        Using xml As XmlTextWriter = New XmlTextWriter(Response.OutputStream, Encoding.UTF8)
            xml.WriteStartDocument()

            ' RSS Tag
            xml.WriteStartElement("rss")
            xml.WriteAttributeString("version", "2.0")
            xml.WriteAttributeString("xmlns:atom", "http://www.w3.org/2005/Atom")

            ' The Channel Tag - RSS Feed Details
            xml.WriteStartElement("channel")
            xml.WriteElementString("title", strWebshopName & " RSS Feed")
            xml.WriteElementString("link", strWebshopURL)
            xml.WriteElementString("description", "All the latest news, marketing and promotions from " & strWebshopName)
            xml.WriteElementString("copyright", "Copyright " & Year(now()) & ". All rights reserved.")

            ' Image
            xml.WriteStartElement("image")
            xml.WriteElementString("url", strWebshopURL & "Skins/" & strSkinFolder & "/Images/logo.png")
            xml.WriteElementString("title", strWebshopName & " RSS Feed")
            xml.WriteElementString("link", strWebshopURL)
            xml.WriteElementString("width", "130")
            xml.WriteElementString("height", "90")
            xml.WriteEndElement()

            ' Atom Tag
            xml.WriteStartElement("atom:link")
            xml.WriteAttributeString("href", strWebshopURL & "rss.aspx")
            xml.WriteAttributeString("rel", "self")
            xml.WriteAttributeString("type", "application/rss+xml")
            xml.WriteEndElement()

            'Pull news records into a DataTable
            Dim tblLatestNews As DataTable = NewsBLL.GetLatestNews(intLanguage, intSizeOfFeed)

            'Loop through DataTable and write news items to xml output
            For Each row As DataRow In tblLatestNews.Rows
                xml.WriteStartElement("item")
                xml.WriteElementString("title", row("N_Name").ToString())
                xml.WriteElementString("description", CkartrisDisplayFunctions.TruncateDescription(Server.HtmlDecode(row("N_Text").ToString()), KartSettingsManager.GetKartConfig("frontend.news.display.truncatestory")) & " <a href=""" & strWebshopURL & "News.aspx?NewsID=" & row("N_ID").ToString() & """>[more]</a>")
                xml.WriteElementString("link", strWebshopURL & "News.aspx?NewsID=" & row("N_ID").ToString())
                xml.WriteElementString("guid", strWebshopURL & "News.aspx?NewsID=" & row("N_ID").ToString())
                xml.WriteElementString("pubDate", dateRFC822(row("N_DateCreated")))
                xml.WriteEndElement()
            Next

            xml.WriteEndElement()
            xml.WriteEndElement()
            xml.WriteEndDocument()
            xml.Flush()
            xml.Close()
            Response.End()

        End Using
    End Sub

    'Function converts date string to RFC822 format
    Public Function dateRFC822([date] As DateTime) As String
        Dim offset As Integer = TimeZone.CurrentTimeZone.GetUtcOffset(DateTime.Now).Hours
        Dim timeZone__1 As String = "+" & offset.ToString().PadLeft(2, "0"c)
        If offset < 0 Then
            Dim i As Integer = offset * -1
            timeZone__1 = "-" & i.ToString().PadLeft(2, "0"c)
        End If
        Return [date].ToString("ddd, dd MMM yyy HH:mm:ss " & timeZone__1.PadRight(5, "0"c))
    End Function

End Class