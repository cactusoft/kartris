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
Imports System.Net

Partial Class Skins_Hugofox_UserControls_HugoFoxContent
    Inherits System.Web.UI.UserControl
    Private _DisplayItem As String

    'We set a property so we can use the same
    'control to pull various different HTML
    'content from Hugofox
    Public Property DisplayItem() As String
        Get
            Return _DisplayItem
        End Get
        Set(ByVal value As String)
            _DisplayItem = value
        End Set
    End Property

    ''' <summary>
    ''' On page load
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim strHugoFoxHTML As String = ""

        'First, we need to know the customer's HugoFox
        'account ID number
        Dim strHugoFoxID As String = KartSettingsManager.GetKartConfig("hugofox.account.id")

        ' Blank string management
        Dim numHugoFoxID As Integer = 0
        If IsNumeric(strHugoFoxID) Then
            numHugoFoxID = CInt(strHugoFoxID)
        End If

        'Account ID is not zero, proceed, otherwise, flag issue
        If numHugoFoxID > 0 Then
            'Try to get HugoFox HTML using the function below
            strHugoFoxHTML = GetHTMLFromHugoFox(numHugoFoxID)
        Else
            Response.Write("Please set the HugoFox ID in the ecommerce config settings: hugofox.account.id")
            Response.End()
        End If

        'Put the response into an array, breaking it up around
        'the six pipes we use as separator
        Dim aryHugoFoxHTML As Array = Split(strHugoFoxHTML, "||||||")

        Select Case _DisplayItem
            Case "headerimagecss"
                litHeaderImageCSS.Text = aryHugoFoxHTML(0)
            Case "cookiemessage"
                litCookieMessage.Text = aryHugoFoxHTML(1)
            Case "hugofoxheader"
                litHugoFoxHeader.Text = aryHugoFoxHTML(2)
            Case "userheader"
                aryHugoFoxHTML(3) = Replace(aryHugoFoxHTML(3), "<header class=""row main-header"">", "<div class=""row main-header hide-for-small"" style=""margin-top: 16px;"">")
                aryHugoFoxHTML(3) = Replace(aryHugoFoxHTML(3), "</header>", "</div>")
                litUserHeader.Text = aryHugoFoxHTML(3)
            Case "leftsidebarlinks"
                litLeftSideBarLinks.Text = aryHugoFoxHTML(4)
            Case "usertitles"
                litUserTitles.Text = aryHugoFoxHTML(5)
            Case "reportpage"
                litReportPage.Text = aryHugoFoxHTML(6)
            Case "footer"
                litFooter.Text = aryHugoFoxHTML(7)
        End Select

    End Sub

    ''' <summary>
    ''' Grab HTML feed from HugoFox web site
    ''' </summary>
    ''' <param name="numHugoFoxID"></param>
    ''' <remarks></remarks>
    Protected Function GetHTMLFromHugoFox(ByVal numHugoFoxID As Integer) As String

        'Nice easy way during dev to skip the caching so changes
        'we make show up instantly. Set to 'false' when site is
        'live and running to ensure caching for performance
        Dim blnSkipCache As Boolean = True

        Dim strCacheKey As String = "HugoFoxSkinHTML_" & numHugoFoxID.ToString
        Dim xmlDoc As XDocument = Nothing
        Dim strResponse As String = ""
        Dim strFormattedFeed As String = ""
        Dim strConnection As String = "http://www.hugofox.com/business/kartris-" & numHugoFoxID.ToString & "/kartris"

        'We want to pull from cache if possible, it is
        'faster and keeps traffic to kartris.com down
        If Cache.[Get](strCacheKey) Is Nothing Or blnSkipCache = True Then
            Try

                Dim objRequest As System.Net.HttpWebRequest = WebRequest.Create(strConnection)
                objRequest.Timeout = 2000 'milliseconds

                'Get the response
                Dim objWebResponse As WebResponse = objRequest.GetResponse
                Dim objResponseStream As Stream = objWebResponse.GetResponseStream
                Dim objStreamReader As StreamReader = New StreamReader(objResponseStream)
                strResponse = objStreamReader.ReadToEnd

                'Here we format a cleaned up HTML string separated
                'by pipes
                strFormattedFeed &= FormatHTMLPageForCaching(strResponse, "HEADERIMAGECSS")
                strFormattedFeed &= "||||||"
                strFormattedFeed &= FormatHTMLPageForCaching(strResponse, "COOKIEMESSAGE")
                strFormattedFeed &= "||||||"
                strFormattedFeed &= FormatHTMLPageForCaching(strResponse, "HUGOFOXHEADER")
                strFormattedFeed &= "||||||"
                strFormattedFeed &= FormatHTMLPageForCaching(strResponse, "USERHEADER")
                strFormattedFeed &= "||||||"
                strFormattedFeed &= FormatHTMLPageForCaching(strResponse, "LEFTSIDEBARLINKS")
                strFormattedFeed &= "||||||"
                strFormattedFeed &= FormatHTMLPageForCaching(strResponse, "USERTITLES")
                strFormattedFeed &= "||||||"
                strFormattedFeed &= FormatHTMLPageForCaching(strResponse, "REPORTPAGE")
                strFormattedFeed &= "||||||"
                strFormattedFeed &= FormatHTMLPageForCaching(strResponse, "FOOTER")

                'Now we need to add in the main HugoFox URL to images and links
                strFormattedFeed = Replace(strFormattedFeed, "href=""/business/", "href=""//www.hugofox.com/business/")
                strFormattedFeed = Replace(strFormattedFeed, "/getImage.asp", "//www.hugofox.com/getImage.asp")
                strFormattedFeed = Replace(strFormattedFeed, "<script src=""/scripts/", "<script src=""//www.hugofox.com/scripts/")

                'Add feed data to local cache for one hour
                Cache.Insert(strCacheKey, strFormattedFeed, Nothing, DateTime.Now.AddMinutes(60), TimeSpan.Zero)

            Catch ex As Exception
                CkartrisFormatErrors.LogError("Problem receiving HTML from HugoFox. " & ex.Message)

            End Try
        Else
            'Pull feed data from cache
            strFormattedFeed = DirectCast(Cache.[Get](strCacheKey), String)
        End If

        Return strFormattedFeed
    End Function

    ''' <summary>
    ''' Extra HTML from between two placeholder tags
    ''' </summary>
    ''' <param name="strResponse">The HTML entire content picked up from the HF site</param>
    ''' <param name="strNameOfTags">The name of the comment tags embedded to separate sections so we can isolate them</param>
    ''' <remarks></remarks>
    Protected Function FormatHTMLPageForCaching(ByVal strResponse As String, ByVal strNameOfTags As String) As String
        'Find position of first tag
        Dim strTagOpen As String = "<!--" & strNameOfTags & "-->"
        Dim strTagClose As String = "<!--/" & strNameOfTags & "-->"
        Dim numTextStart As Integer = strResponse.IndexOf(strTagOpen) + Len(strTagOpen) + 1
        Dim numTextEnd As Integer = strResponse.IndexOf(strTagClose)
        Return Mid(strResponse, numTextStart, numTextEnd - numTextStart + 1)
    End Function

End Class
