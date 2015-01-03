'========================================================================
'Kartris - www.kartris.com
'Copyright 2015 CACTUSOFT

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
Imports CkartrisEnumerations
Imports KartSettingsManager

Partial Class Admin_Revisions
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Kartris", "BackMenu_Revisions") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Me.IsPostBack Then
            'GetXML(0)
            Try
                GetXML(0)
                phdFeed.Visible = True
                phdFeedNotAccessible.Visible = False
            Catch ex As Exception
                phdFeed.Visible = False
                phdFeedNotAccessible.Visible = True
            End Try
        End If


    End Sub

    Protected Sub GetXML(ByVal numItem As Integer)

        Dim strCacheKey As String = "RevisionsFeed"
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
                Dim reqFeed As System.Net.HttpWebRequest = DirectCast(System.Net.WebRequest.Create("http://www.kartris.com/feed/revisions/?url=" & CkartrisBLL.WebShopURL), System.Net.HttpWebRequest)
                reqFeed.Timeout = 1000 'milliseconds
                Dim resFeed As System.Net.WebResponse = reqFeed.GetResponse()
                Dim responseStream As Stream = resFeed.GetResponseStream()
                Dim docXML As New XmlDocument()
                docXML.Load(responseStream)
                responseStream.Close()

                'Set XDocument to the XML string we got back from feed
                xmlDoc = XDocument.Parse(docXML.OuterXml)

                'Add feed data to local cache for one hour
                Cache.Insert("RevisionsFeed", XDocument.Parse(xmlDoc.ToString), Nothing, DateTime.Now.AddMinutes(60), TimeSpan.Zero)
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
        Select intMajorVersion = xmlItem.Element("majorVersion").Value, _
        numMinorVersion = xmlItem.Element("minorVersion").Value, _
        blnIsBeta = xmlItem.Element("beta").Value, _
        datReleaseDate = CDate(xmlItem.Element("releaseDate").Value), _
        strType = xmlItem.Element("type").Value, _
        strBugFixes = xmlItem.Element("bugFixes").Value, _
        strImprovements = xmlItem.Element("improvements").Value _
        Order By datReleaseDate Descending

        'Use the stringbuilder class for performance
        Dim objStringBuilder As New StringBuilder
        Dim numCounter As Integer = 0

        For Each xmlItem In xmlChannel

            'If prerelease version, append to top of list
            If numCounter = 0 And xmlItem.numMinorVersion < KARTRIS_VERSION Then
                objStringBuilder.Append("<span class=""versionlabel"">" & GetGlobalResourceObject("_SoftwareUpdate", "ContentText_Installed") & "*</span>" & vbCrLf)
                objStringBuilder.Append("<div>" & vbCrLf)
                objStringBuilder.Append("<div class=""revisions_Prerelease""><span class=""minorversion"">" & KARTRIS_VERSION.ToString("N4") & "</span>" & vbCrLf)
                objStringBuilder.Append("<span class=""type"">Pre-release</span></div>" & vbCrLf)
                objStringBuilder.Append("</div>" & vbCrLf)
            End If
            numCounter = +1

            If xmlItem.numMinorVersion = KARTRIS_VERSION Then objStringBuilder.Append("<span class=""versionlabel"">" & GetGlobalResourceObject("_SoftwareUpdate", "ContentText_Installed") & "*</span>" & vbCrLf)

            objStringBuilder.Append("<div>" & vbCrLf)
            objStringBuilder.Append("<div class=""revisions_" & xmlItem.strType & """><span class=""minorversion"">" & xmlItem.numMinorVersion & "</span>" & vbCrLf)
            objStringBuilder.Append("<span class=""type"">" & xmlItem.strType & "</span>" & vbCrLf)
            objStringBuilder.Append("<span class=""date"">(" & CkartrisDisplayFunctions.FormatDate(xmlItem.datReleaseDate, "t", Session("_LANG")) & ")</span></div>" & vbCrLf)
            If xmlItem.strBugFixes <> "" Then objStringBuilder.Append("<blockquote class=""bugfixes"">" & Replace(xmlItem.strBugFixes, "* ", "<br />* ") & "</blockquote>" & vbCrLf)
            If xmlItem.strImprovements <> "" Then objStringBuilder.Append("<blockquote class=""improvements"">" & Replace(xmlItem.strImprovements, "* ", "<br />* ") & "</blockquote>" & vbCrLf)
            objStringBuilder.Append("</div>" & vbCrLf)

        Next xmlItem

        'If no data
        If objStringBuilder.ToString = "" Then
            objStringBuilder.Append("<div>No change log info.</div>")
        End If

        'Set text to page
        litXMLData.Text = objStringBuilder.ToString

    End Sub

End Class
