﻿'========================================================================
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
Imports System.Collections.Generic
Imports System.IO
Imports CkartrisDataManipulation
Imports CkartrisDisplayFunctions
Imports KartSettingsManager
Imports FeedsBLL

Partial Class Admin_GenerateFeeds

    Inherits _PageBaseClass

    Private Shared strAppUploadsFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder")

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetGlobalResourceObject("_Feeds", "PageTitle_GenerateFeeds") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
    End Sub

    ''' <summary>
    ''' Create full friendly URL
    ''' </summary>
    Public Function CreateFeedURL(ByVal strCulture As String, ByVal strTitle As String, ByVal strType As String, ByVal strItemID As String) As String
        Dim strURL As String = ""

        'Formats the text/name part of the URL, replaces spaces with a 
        'dash and then strips or replaces disallowed URL chars
        strTitle = CleanURL(Replace(strTitle, " ", "-"))

        Select Case strType
            Case "p"
                'Product
                strURL = CkartrisBLL.WebShopURL & strCulture & strTitle & "__p-" & strItemID & ".aspx"
            Case "c"
                'Category
                strURL = CkartrisBLL.WebShopURL & strCulture & strTitle & "__c-p-0-0-" & strItemID & ".aspx"
            Case "t"
                'Custom page text
                strURL = CkartrisBLL.WebShopURL & "t-" & strTitle & ".aspx"
            Case "n"
                'News
                strURL = CkartrisBLL.WebShopURL & strCulture & strTitle & "__n-" & strItemID & ".aspx"
        End Select

        Return strURL
    End Function

    ''' <summary>
    ''' Generate the Sitemap file
    ''' </summary>
    Protected Sub btnGenerate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSitemap.Click

        Dim CurrentXmlSiteMap As XmlTextWriter = CreateXMLSiteMap("sitemap.xml")

        Dim lstAdded As New List(Of String)()
        Dim lstAddedProducts As New List(Of String)()
        Dim intTotalURLs As Integer = 0
        Dim intCurrentURLCounter As Integer = 0
        Dim strLink As String = ""


        'Add nodes from the web.sitemap file
        For Each node As SiteMapNode In SiteMap.Providers("MenuSiteMap").RootNode.GetAllNodes
            If Not String.IsNullOrEmpty(node.Url) Then
                Dim strURL As String = node.Url
                If Right(strURL, 1) = "?" Then strURL = Left(strURL, strURL.Length - 1)
                strURL = FixURL(strURL)
                If Not lstAdded.Contains(strURL) Then
                    AddURLElement(CurrentXmlSiteMap, strURL)
                    lstAdded.Add(strURL)
                    intTotalURLs += 1
                End If
            End If
        Next

        lstAdded.Clear()
        Dim intSiteMapCounter As Integer = 0
        Dim tblProducts As DataTable = Nothing

        Dim dtbFeedData As DataTable = _GetFeedData()

        For Each drwFeedData In dtbFeedData.Rows

            Dim strCulture As String = drwFeedData("LANG_Culture").ToString & "/"
            If strCulture = "/" Then strCulture = ""

            'Try/catch so one bad URL won't crash the whole thing
            Try
                AddURLElement(CurrentXmlSiteMap, CreateFeedURL(strCulture, drwFeedData("PAGE_Name").ToString, drwFeedData("RecordType").ToString, drwFeedData("ItemID").ToString))

                If intCurrentURLCounter = 49990 Then 'safely under the 50,000 urls limit
                    intCurrentURLCounter = 0
                    intSiteMapCounter += 1
                    CloseXMLSitemap(CurrentXmlSiteMap)
                    CurrentXmlSiteMap = CreateXMLSiteMap("sitemap" & intSiteMapCounter & ".xml")
                End If
                intCurrentURLCounter += 1
            Catch ex As Exception
                'Oops, this shouldn't happen
            End Try

        Next

        CloseXMLSitemap(CurrentXmlSiteMap)

        'create a sitemap index if multiple files were generated
        If intSiteMapCounter > 0 Then
            Dim xmlSiteMap As New XmlTextWriter(Path.Combine(Request.PhysicalApplicationPath, "xmlsitemapindex.xml"),
                                                            System.Text.Encoding.UTF8)
            With xmlSiteMap

                .WriteStartDocument()
                .WriteWhitespace(vbCrLf)
                .WriteStartElement("sitemapindex")
                .WriteAttributeString("xmlns", "http://www.sitemaps.org/schemas/sitemap/0.9")

                .WriteAttributeString("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
                .WriteAttributeString("xsi:schemaLocation", "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd")


                .WriteWhitespace(vbCrLf)
                .WriteStartElement("sitemap")
                .WriteWhitespace(vbCrLf)
                .WriteElementString("loc", CkartrisBLL.WebShopURLhttp & "sitemap.xml")
                .WriteWhitespace(vbCrLf)
                .WriteEndElement()

                For i As Integer = 1 To intSiteMapCounter
                    .WriteWhitespace(vbCrLf)
                    .WriteStartElement("sitemap")
                    .WriteWhitespace(vbCrLf)
                    .WriteElementString("loc", CkartrisBLL.WebShopURLhttp & "sitemap" & i & ".xml")
                    .WriteWhitespace(vbCrLf)
                    .WriteEndElement()
                Next
                .Flush()
                .Close()

            End With

            'We have a sitemap index file, so link to that
            lnkGenerated.NavigateUrl = CkartrisBLL.WebShopURLhttp & "xmlsitemapindex.xml"
            litFilePath.Text = CkartrisBLL.WebShopURLhttp & "xmlsitemapindex.xml"
        Else
            'Just one sitemap, link to that
            lnkGenerated.NavigateUrl = CkartrisBLL.WebShopURLhttp & "sitemap.xml"
            litFilePath.Text = CkartrisBLL.WebShopURLhttp & "sitemap.xml"
        End If

        'Show link to file
        lnkGenerated.Visible = True
        litFilePath.Visible = True

        'Show update animation
        ShowMasterUpdateMessage()
    End Sub

    ''' <summary>
    ''' Generate start lines of sitemap.xml file
    ''' </summary>
    Private Function CreateXMLSiteMap(ByVal strFileName As String) As XmlTextWriter
        Dim xmlSiteMap As New XmlTextWriter(Server.MapPath("~/") & strFileName, System.Text.Encoding.UTF8)
        With xmlSiteMap
            .WriteStartDocument()
            .WriteWhitespace(vbCrLf)
            .WriteStartElement("urlset")
            .WriteAttributeString("xmlns", "http://www.sitemaps.org/schemas/sitemap/0.9")

            .WriteAttributeString("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
            .WriteAttributeString("xsi:schemaLocation", "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd")

        End With

        Return xmlSiteMap
    End Function

    ''' <summary>
    ''' Generate closing lines of sitemap.xml file
    ''' </summary>
    Private Sub CloseXMLSitemap(ByRef xmlSiteMap As XmlTextWriter)
        With xmlSiteMap
            .WriteWhitespace(vbCrLf)
            .WriteEndElement()
            .WriteWhitespace(vbCrLf)
            .WriteEndDocument()
            .Flush()
            .Close()
        End With
    End Sub

    ''' <summary>
    ''' Add a URL line to the sitemap.xml
    ''' </summary>
    Private Sub AddURLElement(ByRef xmlSiteMap As XmlTextWriter, ByVal strURL As String, _
                              Optional ByVal strPriority As String = "0.5")
        With xmlSiteMap
            .WriteWhitespace(vbCrLf)
            .WriteStartElement("url")
            .WriteWhitespace(vbCrLf)
            .WriteWhitespace("   ")
            .WriteElementString("loc", strURL)
            .WriteWhitespace(vbCrLf)
            .WriteWhitespace("   ")
            'Set default page to higher priority
            If Right(strURL, 13).ToLower = "/default.aspx" Then
                .WriteElementString("priority", "1.0")
            ElseIf Right(strURL, 10).ToLower = "/news.aspx" Then
                .WriteElementString("priority", "1.0")
            Else
                .WriteElementString("priority", strPriority)
            End If
            .WriteWhitespace(vbCrLf)
            .WriteWhitespace("   ")
            .WriteElementString("changefreq", ddlChangeFrequency.SelectedValue)
            .WriteWhitespace(vbCrLf)
            .WriteEndElement()
        End With
    End Sub

    ''' <summary>
    ''' Generate the Froogle / GoogleBase / Google Merchant Feed
    ''' (at some point, Google will settle on a name and keep it!)
    ''' </summary>
    Protected Sub btnFroogle_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnFroogle.Click

        Dim tblProducts As DataTable = Nothing
        Dim tblVersions As DataTable = Nothing
        Dim lstAddedProducts As New List(Of String)()
        Dim lstAdded As New List(Of String)()
        Dim strDesc As String
        Dim strProductName As String
        Dim strVersionName As String
        Dim strPrice As String
        Dim strLink As String
        Dim strImageLink As String
        Dim strAvailability As String = ""

        Dim objFileStream As FileStream = Nothing
        Dim objStreamWriter As StreamWriter = Nothing
        Dim xmlGoogleBase As XmlTextWriter = Nothing

        'We can generate two formats; txt and xml
        'The XML one is preferred but we've found Google
        'to be a bit more picky and unhelpful with error
        'messages. So .txt format gives a good fallback.
        'The .txt feed is typically smaller too.
        If ddlXMLorTXT.SelectedValue = "txt" Then
            objFileStream = New FileStream(Server.MapPath(strAppUploadsFolder) & "\temp\GoogleBase.txt", FileMode.Create, FileAccess.Write)
            objStreamWriter = New StreamWriter(objFileStream)
            'the seek method is used to move the cursor to next position to avoid text to be overwritten
            's.BaseStream.Seek(0, SeekOrigin.End)
            'write out the headers
            objStreamWriter.WriteLine("id" & vbTab & "title" & vbTab & "description" & vbTab & "price" & vbTab & "link" & vbTab & "image_link" & vbTab & "condition")
        ElseIf ddlXMLorTXT.SelectedValue = "csv" Then
            objFileStream = New FileStream(Server.MapPath(strAppUploadsFolder) & "\temp\GoogleBase.csv", FileMode.Create, FileAccess.Write)
            objStreamWriter = New StreamWriter(objFileStream)
            'the seek method is used to move the cursor to next position to avoid text to be overwritten
            's.BaseStream.Seek(0, SeekOrigin.End)
            'write out the headers
            objStreamWriter.WriteLine("'id','title','description','price','link','image_link','condition'")
        Else
            'XML feed format
            xmlGoogleBase = New XmlTextWriter(Server.MapPath(strAppUploadsFolder) & "\temp\GoogleBase.xml", System.Text.Encoding.UTF8)
            'Add the header parts
            With xmlGoogleBase
                .WriteStartDocument()
                .WriteWhitespace(vbCrLf)
                .WriteStartElement("rss")
                .WriteAttributeString("version", "2.0")
                .WriteAttributeString("xmlns:g", "http://base.google.com/ns/1.0")
                .WriteWhitespace(vbCrLf)
                .WriteStartElement("channel")
                .WriteWhitespace(vbCrLf)
                .WriteElementString("title", Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname")))
                .WriteWhitespace(vbCrLf)
                .WriteElementString("link", CkartrisBLL.WebShopURLhttp)
                .WriteWhitespace(vbCrLf)
                .WriteElementString("description", GetGlobalResourceObject("Kartris", "ContentText_DefaultMetaDescription"))
            End With
        End If

        'Add lines for each item
        Dim objProductsBLL As New ProductsBLL
        Dim objVersionsBLL As New VersionsBLL
        For Each node As SiteMapNode In SiteMap.Providers("CategorySiteMapProvider").RootNode.GetAllNodes

            Dim intCategoryID As Integer = CInt(Mid(node.Key, InStrRev(node.Key, ",") + 1))
            If Not lstAdded.Contains(intCategoryID) Then
                lstAdded.Add(intCategoryID)

                'Fill table with products for each category
                tblProducts = objProductsBLL.GetProductsPageByCategory(intCategoryID, 1, 0, Short.MaxValue, 0, Short.MaxValue)

                'Loop through each product
                For Each drwProduct As DataRow In tblProducts.Rows
                    If Not lstAddedProducts.Contains(drwProduct("P_ID")) Then
                        lstAddedProducts.Add(drwProduct("P_ID"))
                        strProductName = CkartrisDisplayFunctions.StripHTML(FixNullFromDB(drwProduct("P_Name")))

                        Dim dtGoogleAttributes As DataTable = AttributesBLL.GetSpecialAttributesByProductID(drwProduct("P_ID"), 1)

                        Try
                            'Loop through each version
                            For Each drwVersion As DataRow In objVersionsBLL.GetByProduct(drwProduct("P_ID"), 1, 0).Rows

                                strVersionName = FixNullFromDB(drwVersion("V_Name"))
                                strDesc = Replace(Replace(FixNullFromDB(drwVersion("V_Desc")), vbTab, ""), vbCrLf, "")
                                strPrice = CurrenciesBLL.FormatCurrencyPrice(1, CDbl(FixNullFromDB((drwVersion("V_Price")))), False)
                                strLink = SiteMapHelper.CreateURL(SiteMapHelper.Page.CanonicalProduct, drwProduct("P_ID"), , , , , , drwProduct("P_Name"))

                                'Format image link
                                'Ideally we look to see if there is a version image
                                'If not, we use a product image
                                'If nothing found, we leave blank
                                'Note that Froogle/Google will not accept URLs
                                'that go to scripts (such as Image.ashx that provides
                                'thumbnails). Instead, we have to give them the full
                                'image link.
                                strImageLink = ImageLink(FixNullFromDB(drwVersion("V_ID")), FixNullFromDB(drwProduct("P_ID")))

                                strLink = FixURL(strLink)

                                If strProductName <> strVersionName And String.IsNullOrEmpty(strVersionName) Then strProductName += " - " & strVersionName
                                If String.IsNullOrEmpty(strDesc) Then strDesc = FixNullFromDB(drwProduct("P_Desc"))

                                If ddlXMLorTXT.SelectedValue = "txt" Then
                                    AddFroogleTextLine(objStreamWriter, FixNullFromDB(drwVersion("V_CodeNumber")), strProductName, strDesc, strPrice, strLink, strImageLink)
                                ElseIf ddlXMLorTXT.SelectedValue = "csv" Then
                                    AddFroogleCSVLine(objStreamWriter, FixNullFromDB(drwVersion("V_CodeNumber")), strProductName, strDesc, strPrice, strLink, strImageLink)
                                Else
                                    With xmlGoogleBase
                                        '====================================
                                        'BASIC DETAILS
                                        '====================================
                                        .WriteWhitespace(vbCrLf)
                                        .WriteStartElement("item")
                                        .WriteWhitespace(vbCrLf)
                                        .WriteWhitespace("   ")
                                        .WriteElementString("g:id", FixNullFromDB(drwVersion("V_CodeNumber")))
                                        .WriteWhitespace(vbCrLf)
                                        .WriteWhitespace("   ")
                                        .WriteElementString("title", CkartrisDisplayFunctions.StripHTML(strProductName))
                                        .WriteWhitespace(vbCrLf)
                                        .WriteWhitespace("   ")
                                        .WriteElementString("description", CkartrisDisplayFunctions.StripHTML(strDesc))
                                        .WriteWhitespace(vbCrLf)
                                        .WriteWhitespace("   ")
                                        .WriteElementString("g:price", strPrice & " " & CurrenciesBLL.CurrencyCode(CurrenciesBLL.GetDefaultCurrency)) 'v3, now format currency with ISO code after it
                                        .WriteWhitespace(vbCrLf)
                                        .WriteWhitespace("   ")
                                        .WriteElementString("link", strLink)
                                        .WriteWhitespace(vbCrLf)
                                        .WriteWhitespace("   ")

                                        '====================================
                                        'GTIN, MPN or Brand
                                        '====================================
                                        'Google wants one of MPN, GTIN or Brand
                                        'Many stores use MPN as their SKU/VersionCode
                                        'If so, uncommented section below to take care of this

                                        '.WriteElementString("g:mpn", FixNullFromDB(drwVersion("V_CodeNumber")))
                                        '.WriteWhitespace(vbCrLf)
                                        '.WriteWhitespace("   ")

                                        '====================================
                                        'STOCK AVAILABILITY
                                        '====================================
                                        'Need to check if out of stock
                                        If drwVersion("V_Quantity") < 1.0F And drwVersion("V_QuantityWarnLevel") > 0.0F Then
                                            'out of stock
                                            strAvailability = "out of stock"
                                        Else
                                            'in stock
                                            strAvailability = "in stock"
                                        End If
                                        .WriteElementString("g:availability", strAvailability) 'v3, in or out of stock
                                        .WriteWhitespace(vbCrLf)
                                        .WriteWhitespace("   ")

                                        '====================================
                                        'IMAGE LINK
                                        '====================================
                                        If strImageLink <> "" Then
                                            .WriteElementString("g:image_link", strImageLink)
                                            .WriteWhitespace(vbCrLf)
                                            .WriteWhitespace("   ")
                                        End If
                                        .WriteElementString("g:condition", UCase(ddlCondition.SelectedValue))
                                        .WriteWhitespace(vbCrLf)

                                        '====================================
                                        'OTHER GOOGLE ATTRIBUTES
                                        '====================================
                                        'Next, we loop through all the special Google attributes that have
                                        'been setup 
                                        For Each drwGoogle As DataRow In dtGoogleAttributes.Rows
                                            If FixNullFromDB(drwGoogle("ATTRIBV_Value")) IsNot Nothing Then
                                                .WriteWhitespace("   ")
                                                .WriteElementString(FixNullFromDB(drwGoogle("ATTRIB_Name")), FixNullFromDB(drwGoogle("ATTRIBV_Value")))
                                                .WriteWhitespace(vbCrLf)
                                            End If
                                        Next
                                        .WriteEndElement()
                                    End With
                                End If
                            Next
                        Catch ex As Exception
                            'Well, it can happen
                        End Try

                    End If
                Next
            End If
        Next

        If ddlXMLorTXT.SelectedValue = "txt" Then
            objStreamWriter.Close()
            lnkGenerated.NavigateUrl = strAppUploadsFolder & "temp/GoogleBase.txt"

            'Show full URL that needs to be given to Google
            litFilePath.Text = Replace(strAppUploadsFolder, "~/", cKartrisBLL.WebShopURLhttp) & "temp/GoogleBase.txt"
            litFilePath.Visible = True
        ElseIf ddlXMLorTXT.SelectedValue = "csv" Then
            objStreamWriter.Close()
            lnkGenerated.NavigateUrl = strAppUploadsFolder & "temp/GoogleBase.csv"

            'Show full URL that needs to be given to Google
            litFilePath.Text = Replace(strAppUploadsFolder, "~/", CkartrisBLL.WebShopURLhttp) & "temp/GoogleBase.csv"
            litFilePath.Visible = True
        Else
            CloseXMLSitemap(xmlGoogleBase)
            lnkGenerated.NavigateUrl = strAppUploadsFolder & "temp/GoogleBase.xml"

            'Show full URL that needs to be given to Google
            litFilePath.Text = Replace(strAppUploadsFolder, "~/", CkartrisBLL.WebShopURLhttp) & "temp/GoogleBase.xml"
            litFilePath.Visible = True
        End If
        lnkGenerated.Visible = True

        ShowMasterUpdateMessage()
    End Sub

    ''' <summary>
    ''' Add a text line to Froogle/Google feed
    ''' </summary>
    Private Sub AddFroogleTextLine(ByRef objStreamWriter As StreamWriter, ByVal V_Codenumber As String, ByVal V_Name As String, ByVal V_Desc As String, _
                                   ByVal V_Price As Double, ByVal strProductLink As String, ByVal strImageLink As String)
        objStreamWriter.WriteLine(V_Codenumber & vbTab & V_Name & vbTab & V_Desc & vbTab & V_Price & vbTab & strProductLink & vbTab & strImageLink & vbTab & UCase(ddlCondition.SelectedValue))
    End Sub

    ''' <summary>
    ''' Add a text line to Froogle/Google feed
    ''' </summary>
    Private Sub AddFroogleCSVLine(ByRef objStreamWriter As StreamWriter, ByVal V_Codenumber As String, ByVal V_Name As String, ByVal V_Desc As String, _
                                   ByVal V_Price As Double, ByVal strProductLink As String, ByVal strImageLink As String)
        objStreamWriter.WriteLine("""" & V_Codenumber & """,""" & Replace(V_Name, """", """""") & """,""" & Replace(V_Desc, """", """""") & """,""" & V_Price & """,""" & strProductLink & """,""" & strImageLink & """,""" & UCase(ddlCondition.SelectedValue) & """")
    End Sub

    ''' <summary>
    ''' Fix URL - ensure is fully qualified absolute URL
    ''' </summary>
    Private Function FixURL(ByVal strLink As String) As String
        'Dim numPortNumber As Integer = Context.Request.ServerVariables("SERVER_PORT")
        'Dim strServerName As String = Context.Request.ServerVariables("SERVER_NAME")

        'Dim strNewWebShopURL As String = strServerName

        'Add port number to end, if not default one
        'If numPortNumber <> 80 Then
        'strNewWebShopURL &= ":" & numPortNumber.ToString
        'End If

        If InStr(strLink, "~/") > 0 Then
            strLink = Replace(strLink, "~/", cKartrisBLL.WebShopURLhttp)
        Else
            If Not InStr(strLink, cKartrisBLL.WebShopURLhttp) > 0 Then
                'Link begins with just /
                strLink = Left(CkartrisBLL.WebShopURLhttp, Len(CkartrisBLL.WebShopURLhttp) - 1) & strLink
            End If
        End If

        If InStr(strLink, CkartrisBLL.WebShopURLhttp & CkartrisBLL.WebShopFolder) Then
            strLink = Replace(strLink, CkartrisBLL.WebShopURLhttp & CkartrisBLL.WebShopFolder, CkartrisBLL.WebShopURLhttp)
        End If
        Return strLink
    End Function

    ''' <summary>
    ''' Find an image, create a fully qualified link for it
    ''' We need to look first for version image, then if
    ''' none exists, a product one.
    ''' Last straw is to return a blank.
    ''' </summary>
    Private Function ImageLink(ByVal V_ID As Integer, ByVal P_ID As Integer) As String
        Dim arrImageTypes As Array = Split(KartSettingsManager.GetKartConfig("backend.imagetypes"), ",")

        Dim strImageLink As String = ""

        strImageLink = ""

        'This is folder where product images would be, if there
        'are any
        Dim dirFolderProducts As New DirectoryInfo(Server.MapPath("~/Images/Products/" & P_ID))
        Dim objFile As FileInfo = Nothing

        'Does product folder exist? If yes, continue, otherwise
        'we can stop - no images.
        If dirFolderProducts.Exists Then

            'Folder where versions would be
            Dim dirFolderVersions As New DirectoryInfo(Server.MapPath("~/Images/Products/" & P_ID & "/" & V_ID))
            If dirFolderVersions.Exists Then
                'Try to find a version image
                For Each objFile In dirFolderVersions.GetFiles()
                    strImageLink = cKartrisBLL.WebShopURLhttp & "Images/Products/" & P_ID & "/" & V_ID & "/" & objFile.Name
                    Exit For
                Next
            Else
                'No versions folder, let's pull product image instead
                For Each objFile In dirFolderProducts.GetFiles()
                    strImageLink = cKartrisBLL.WebShopURLhttp & "Images/Products/" & P_ID & "/" & objFile.Name
                    Exit For
                Next
            End If
        Else
            'No product image folder = no product or version images
            strImageLink = ""
        End If

        Return strImageLink
    End Function

    'Just show the 'updated' message
    Protected Sub ShowMasterUpdateMessage()
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub
End Class