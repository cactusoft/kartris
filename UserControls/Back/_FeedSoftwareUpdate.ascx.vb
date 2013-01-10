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

        'Cache XML for 10 hrs to help save our server!
        If Cache.[Get](strCacheKey) Is Nothing Then
            'Load XML from Kartris feed, use SSL if possible
            Try
                xmlDoc = XDocument.Load("https://www.kartris.com/feed/revisions/?url=" & KartSettingsManager.GetKartConfig("general.webshopurl"))
            Catch ex As Exception
                xmlDoc = XDocument.Load("http://www.kartris.com/feed/revisions/?url=" & KartSettingsManager.GetKartConfig("general.webshopurl"))
            End Try
            Cache.Insert("RevisionsFeed", XDocument.Parse(xmlDoc.ToString), Nothing, DateTime.Now.AddMinutes(600), TimeSpan.Zero)
        Else
            xmlDoc = DirectCast(Cache.[Get]("RevisionsFeed"), XDocument)
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
