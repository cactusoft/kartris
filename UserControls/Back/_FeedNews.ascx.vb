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
Imports System.Xml.Linq
Imports System.Xml
Imports KartSettingsManager

Partial Class UserControls_Back_FeedNews
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Me.IsPostBack Then
            Try
                GetXML(0)
                phdNewsFeed.Visible = True
                phdNewsFeedNotAccessible.Visible = False
            Catch ex As Exception
                phdNewsFeed.Visible = False
                phdNewsFeedNotAccessible.Visible = True
            End Try

        End If

    End Sub

    Protected Sub GetXML(ByVal numItem As Integer)

        Dim strCacheKey As String = "NewsFeed"
        Dim xmlDoc As XDocument = Nothing

        'We want to pull from cache if possible, it is
        'faster and keeps traffic to kartris.com down
        If Cache.[Get](strCacheKey) Is Nothing Then

            'Put it in a try, in case a bad result is or some
            'other problem like an error
            Try
                'We've reworked this in v2.5004 to prevent timeouts
                'if the kartris.com site where the feed is located
                'is unreachable. We use the httpWebRequest so we can
                'apply a timeout setting of 1 second.
                Dim reqFeed As System.Net.HttpWebRequest = DirectCast(System.Net.WebRequest.Create("http://www.kartris.com/feed/news/?url=" & KartSettingsManager.GetKartConfig("general.webshopurl")), System.Net.HttpWebRequest)
                reqFeed.Timeout = 1000 'milliseconds
                Dim resFeed As System.Net.WebResponse = reqFeed.GetResponse()
                Dim responseStream As Stream = resFeed.GetResponseStream()
                Dim docXML As New XmlDocument()
                docXML.Load(responseStream)
                responseStream.Close()

                'Set XDocument to the XML string we got back from feed
                xmlDoc = XDocument.Parse(docXML.OuterXml)

                'Add feed data to local cache for one hour
                Cache.Insert(strCacheKey, XDocument.Parse(xmlDoc.ToString), Nothing, DateTime.Now.AddMinutes(60), TimeSpan.Zero)
            Catch ex As Exception
                'Oh dear
            End Try
        Else
            'Pull feed data from cache
            xmlDoc = DirectCast(Cache.[Get](strCacheKey), XDocument)
        End If

        'Define LINQ query to pull 1 record from XML
        'Note the 'skip' second line from bottom - so we can jump to a record
        'Note the 'take' at end, similar to 'top' in SQL
        Dim xmlChannel = From xmlItem In xmlDoc.Descendants("item") _
        Select strTitle = xmlItem.Element("title").Value, _
        strType = xmlItem.Element("type").Value, _
        datPubDate = CDate(xmlItem.Element("pubDate").Value), _
        strDescription = xmlItem.Element("description").Value, _
        strLink = xmlItem.Element("guid").Value _
        Order By datPubDate Descending _
        Skip numItem _
        Take 1

        'Use the stringbuilder class for performance
        Dim objStringBuilder As New StringBuilder

        For Each xmlItem In xmlChannel
            objStringBuilder.Append("<div class=""newsfeed_" & xmlItem.strType & """>" & vbCrLf)
            objStringBuilder.Append("<span class=""date"">" & CkartrisDisplayFunctions.FormatDate(xmlItem.datPubDate, "t", Session("_LANG")).ToString & "</span>" & vbCrLf)
            objStringBuilder.Append("<span class=""title""><a href=""" & xmlItem.strLink.ToString & """>" & xmlItem.strTitle & "</a></span>" & vbCrLf)
            objStringBuilder.Append("<span class=""description""><a href=""" & xmlItem.strLink.ToString & """>" & xmlItem.strDescription.ToString & "</a></span>" & vbCrLf)
            objStringBuilder.Append("</div>" & vbCrLf)
        Next xmlItem

        'If no more data, show message and disable forward button
        If objStringBuilder.ToString = "" Then
            litXMLData.Text = "<div>No more news.</div>"
            lnkForward.Enabled = False
        Else
            'Set text to page
            litXMLData.Text = objStringBuilder.ToString
            lnkForward.Enabled = True
        End If

        'Hide back button if first result
        If hidItem.Value = 0 Then
            lnkBack.Visible = False
        Else
            lnkBack.Visible = True
        End If

    End Sub

    'Handle click to next news
    Protected Sub lnkForward_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkForward.Click
        Dim numItem As Integer = hidItem.Value
        numItem += 1
        hidItem.Value = numItem
        GetXML(numItem)
    End Sub

    'Handle click to previous news
    Protected Sub lnkBack_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBack.Click
        Dim numItem As Integer = hidItem.Value
        numItem -= 1
        hidItem.Value = numItem
        GetXML(numItem)
    End Sub
End Class
