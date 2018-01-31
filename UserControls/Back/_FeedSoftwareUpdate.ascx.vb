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
Imports System.Xml.Linq
Imports System.Xml
Imports CkartrisEnumerations
Imports KartSettingsManager

Partial Class UserControls_Back_FeedSoftwareUpdate
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Me.IsPostBack Then
            Try
                GetXML(0)
                phdSoftwareUpdate.Visible = True
                phdSoftwareUpdateNotAccessible.Visible = False
            Catch ex As Exception
                phdSoftwareUpdate.Visible = False
                phdSoftwareUpdateNotAccessible.Visible = True
            End Try
        End If
    End Sub

    Protected Sub GetXML(ByVal numItem As Integer)

        'Dim xmlDoc As XDocument
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
                Dim reqFeed As System.Net.HttpWebRequest = DirectCast(System.Net.WebRequest.Create("https://www.kartris.com/feed/revisions/?url=" & CkartrisBLL.WebShopURL), System.Net.HttpWebRequest)
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
        Order By datReleaseDate Descending _
        Skip numItem _
        Take 1

        'Use the stringbuilder class for performance
        Dim objStringBuilder As New StringBuilder

        'Write data to literal control
        litXMLData.Text = ""
        For Each xmlItem In xmlChannel

            'Message depends on whether Kartris is up-to-date or not
            If xmlItem.numMinorVersion = Format(KARTRIS_VERSION, "0.0000") Then
                litExtraClass.Text = " softwareupdate_OK"
                objStringBuilder.Append("<div class=""softwareupdate_OK"">" & vbCrLf)
                objStringBuilder.Append("<span class=""minorversion"">v" & xmlItem.numMinorVersion & "</span>" & vbCrLf)
                objStringBuilder.Append("<span class=""type"">" & GetGlobalResourceObject("_SoftwareUpdate", "ContentText_YourSoftwareIsUpToDate") & "</div>" & vbCrLf)
            ElseIf xmlItem.numMinorVersion < Format(KARTRIS_VERSION, "0.0000") Then
                'Pre-release version running
                litExtraClass.Text = " softwareupdate_Prerelease"
                objStringBuilder.Append("<div class=""softwareupdate_Prerelease"">" & vbCrLf)
                objStringBuilder.Append("<span class=""minorversion"">v" & Format(KARTRIS_VERSION, "0.0000") & "</span>" & vbCrLf)
                objStringBuilder.Append("<span class=""type"">Pre-release version running</span>" & vbCrLf)
                objStringBuilder.Append("<span class=""moreinfo""><a href=""_Revisions.aspx"">" & GetGlobalResourceObject("_SoftwareUpdate", "ContentText_ViewDetails") & "</a></span>" & vbCrLf)
                objStringBuilder.Append("</div>" & vbCrLf)
            Else
                'Update available
                litExtraClass.Text = " softwareupdate_Available"
                objStringBuilder.Append("<div class=""softwareupdate_Available"">" & vbCrLf)
                objStringBuilder.Append("<span class=""minorversion"">v" & xmlItem.numMinorVersion & "</span>" & vbCrLf)
                objStringBuilder.Append("<span class=""currentlyinstalled"">" & GetGlobalResourceObject("_SoftwareUpdate", "ContentText_Installed") & ": v" & Format(KARTRIS_VERSION, "0.0000") & "</span>" & vbCrLf)
                objStringBuilder.Append("<span class=""title"">" & GetGlobalResourceObject("_SoftwareUpdate", "PageTitle_SoftwareUpdate") & ":</span> <span class=""type"">" & xmlItem.strType & "</span>" & vbCrLf)
                objStringBuilder.Append("<span class=""moreinfo""><a href=""_Revisions.aspx"">" & GetGlobalResourceObject("_SoftwareUpdate", "ContentText_ViewDetails") & "</a></span>" & vbCrLf)
                objStringBuilder.Append("</div>" & vbCrLf)
            End If
        Next xmlItem

        'If no data
        If objStringBuilder.ToString = "" Then
            objStringBuilder.Append("<div>No change log info.</div>") 'hardcoded english as change log only available in English
        End If

        'Set text to page
        litXMLData.Text = objStringBuilder.ToString

    End Sub

End Class
