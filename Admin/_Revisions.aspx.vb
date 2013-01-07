'[[[NEW COPYRIGHT NOTICE]]]
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

        'Cache XML for 10 hrs to help save our server!
        If Cache.[Get](strCacheKey) Is Nothing Then
            'Load XML from Kartris feed, use SSL if possible
            Try
                xmlDoc = XDocument.Load("https://www.kartris.com/feed/revisions/?url=" & KartSettingsManager.GetKartConfig("general.webshopurl"))
            Catch ex As Exception
                xmlDoc = XDocument.Load("http://www.kartris.com/feed/revisions/?url=" & KartSettingsManager.GetKartConfig("general.webshopurl"))
            End Try
            Cache.Insert(strCacheKey, XDocument.Parse(xmlDoc.ToString), Nothing, DateTime.Now.AddMinutes(600), TimeSpan.Zero)
        Else
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
