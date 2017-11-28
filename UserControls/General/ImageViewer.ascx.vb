'========================================================================
'Kartris - www.kartris.com
'Copyright 2017 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports System.Web.UI
Imports CkartrisEnumerations
Imports CkartrisImages

''' <summary>
''' User Control used to view images.
''' Can generate a single image and the enclosing
''' sized div, or an image gallery effect that
''' includes javascript to dynamically swamp the
''' main image when the small thumbs are clicked.
''' </summary>
''' <remarks>By Paul</remarks>
Partial Class ImageViewer
    Inherits System.Web.UI.UserControl

    Private _eImageType As IMAGE_TYPE
    Private _strFolderPath As String
    Private _strImagesDirName As String
    Private _eViewType As SmallImagesType
    Private _strItemType As String
    Private _blnPlaceHolder As Boolean = False
    Private _blnFoundImage As Boolean = True
    Public _blnLargeViewClickable As Boolean = False
    Public _blnVersionImages As Boolean = False

    'We can use this on pages with the image viewer
    'to switch off the large link when no image
    'found (even if placeholder shows)
    Public ReadOnly Property FoundImage() As Boolean
        Get
            Return _blnFoundImage
        End Get
    End Property

    'This determines if the main image is clickable to
    'produce a large view. A product image on the product
    'page will be clickable for large view, but the image
    'on the large view itself won't be. So we can also use
    'this property to determine if the image is a preview
    'one on a product, or a large view.
    Public WriteOnly Property LargeViewClickable() As Boolean
        Set(ByVal value As Boolean)
            _blnLargeViewClickable = value
        End Set
    End Property

    'Is this set of images being called for versions?
    'If so, we need to hide the main image and use some
    'classes in Foundation to get the desired effect
    Public WriteOnly Property VersionImages() As Boolean
        Set(ByVal value As Boolean)
            _blnVersionImages = value
        End Set
    End Property

    Enum SmallImagesType
        enum_ImageButton = 1
        'enum_Link = 2
    End Enum

    'Folder path
    Public ReadOnly Property GetFolderPath() As String
        Get
            Return _strFolderPath
        End Get
    End Property

    Public Sub ClearImages()
        litGalleryThumbs.Text = ""
        litSingleImage.Text = ""
    End Sub

    'this is called from various pages that need to display
    'an image or gallery
    Public Sub CreateImageViewer(ByVal eImageType As IMAGE_TYPE,
        ByVal strImagesDirName As String,
        ByVal numImageHeight As Integer,
        ByVal numImageWidth As Integer,
        ByVal strHyperlink As String,
        Optional ByVal strParentDirName As String = Nothing,
        Optional ByVal viewType As SmallImagesType = SmallImagesType.enum_ImageButton,
        Optional ByVal strAltText As String = "")

        'We need to be able to handle showing full size
        'images directly (not via Image.ashx script) if
        'the imageview is called within the new page
        'rather than an AJAX popup. Easiest way is to
        'have zero height and width passed in. Then we
        'set a boolean for convenience to use later.
        Dim blnFullSizeImage As Boolean = False

        'Set AltText to the property if nothing
        'passed into this optional value
        If (Not String.IsNullOrEmpty(strAltText)) And strAltText <> "" Then
            strAltText = CkartrisDisplayFunctions.RemoveXSS(strAltText)
        End If

        If numImageHeight = 0 And numImageWidth = 0 Then
            'Set boolean to use later
            blnFullSizeImage = True

            'Set some default height and width for 'no image'
            numImageHeight = KartSettingsManager.GetKartConfig("frontend.display.images.large.height")
            numImageWidth = KartSettingsManager.GetKartConfig("frontend.display.images.large.width")
        End If

        'Declare max height and width to use for surrounding div
        Dim numImageHeightMax, numImageWidthMax As Integer

        'Set surrounding div to be square
        'same height and width depending on
        'longest dimension of image
        If numImageHeight > numImageWidth Then
            numImageHeightMax = numImageHeight
            numImageWidthMax = numImageHeight
        Else
            numImageHeightMax = numImageWidth
            numImageWidthMax = numImageWidth
        End If

        'make sure hyperlink uses webshop URL settings
        If strHyperlink.Contains("~/") Then
            strHyperlink = Replace(strHyperlink, "~/", CkartrisBLL.WebShopURL)
        End If

        'product, category or version - set type and path accordingly
        Select Case eImageType
            Case IMAGE_TYPE.enum_ProductImage
                _strFolderPath = strProductImagesPath & "/" & strImagesDirName & "/"
                _strItemType = "p"
                _blnPlaceHolder = (KartSettingsManager.GetKartConfig("frontend.display.image.products.placeholder") = "y")
            Case IMAGE_TYPE.enum_CategoryImage
                _strFolderPath = strCategoryImagesPath & "/" & strImagesDirName & "/"
                _strItemType = "c"
                _blnPlaceHolder = (KartSettingsManager.GetKartConfig("frontend.display.image.categories.placeholder") = "y")
            Case IMAGE_TYPE.enum_VersionImage
                _strFolderPath = strProductImagesPath & "/" & strParentDirName & "/" & strImagesDirName & "/"
                _strItemType = "v"
                _blnPlaceHolder = (KartSettingsManager.GetKartConfig("frontend.display.image.versions.placeholder") = "y")
            Case IMAGE_TYPE.enum_PromotionImage
                _strFolderPath = strPromotionImagesPath & "/" & strImagesDirName & "/"
                _strItemType = "s" 's for "specials" as p is already taken!
                _blnPlaceHolder = (KartSettingsManager.GetKartConfig("frontend.display.image.promotions.placeholder") = "y")
            Case Else
                Exit Sub
        End Select

        _eImageType = eImageType
        _strImagesDirName = strImagesDirName
        _eViewType = viewType

        'find what folder and images we're looking for
        Dim dirFolder As New DirectoryInfo(Server.MapPath(_strFolderPath))
        Dim objFile As FileInfo = Nothing
        Dim intIndex As Integer = 0
        Dim strImageLinkPath As String = ""
        Dim strImageFilePath As String = ""
        Dim strImageMainView As String = ""
        Dim strImageMainViewStart As String = ""
        Dim strJSFunctionDifferentiate As String = "_" & _strItemType & "_" & strImagesDirName ' & "_" & _strDifferentiation
        Dim strFirstImageName As String = ""

        'if folder exists
        If dirFolder.Exists Then
            If dirFolder.GetFiles().Length < 1 Then
                '=======================================
                'NO IMAGES FOUND
                'But folder found
                '=======================================
                NoImage(numImageHeight, numImageWidth, _blnPlaceHolder, strHyperlink)

                'If we don't want placeholders, then we hide whole 
                'control instead
                If _blnPlaceHolder = False Then
                    Me.Visible = False
                End If

            ElseIf (dirFolder.GetFiles().Length = 1 Or strHyperlink <> "") And (_blnLargeViewClickable = False And Not _blnVersionImages) Then

                '=======================================
                'SINGLE IMAGE
                '=======================================
                pnlImageViewer.Visible = False
                pnlSingleImage.Visible = True

                'loop through all images
                'in folder and form image button links
                For Each objFile In dirFolder.GetFiles()
                    intIndex += 1
                    If intIndex = 1 Then strFirstImageName = objFile.Name
                    Select Case _eViewType
                        Case SmallImagesType.enum_ImageButton
                            strImageMainViewStart = "Image.ashx?strFileName=" & objFile.Name & "&amp;strItemType=" & _strItemType & "&amp;numMaxHeight=" & numImageHeight & "&amp;numMaxWidth=" & numImageWidth & "&amp;numItem=" & strImagesDirName & "&amp;strParent=" & strParentDirName

                            '---------------------------------------
                            'LARGE VIEW DISPLAY, OR GENERAL IMAGE
                            'DISPLAY WHERE NO POPUP LARGE VIEW IS
                            'REQUIRED
                            'Can be 'New page' or AJAX type
                            '---------------------------------------
                            If blnFullSizeImage Then
                                '---------------------------------------
                                'IN 'NEW PAGE' LARGE VIEW MODE
                                'Direct link to the image itself
                                '---------------------------------------
                                strImageMainView = Replace(_strFolderPath & objFile.Name, "~/", "")
                                litSingleImage.Text &= "<!-- LARGE VIEW DISPLAY: IN 'NEW PAGE' LARGE VIEW MODE Direct link to the image itself --><img alt=""" & strAltText & """ src=""" &
                                    strImageMainView & """ />"
                            Else
                                '---------------------------------------
                                'IN 'AJAX' LARGE VIEW MODE
                                'Link to Image.ashx resizer
                                '---------------------------------------
                                litSingleImage.Text &= "<!-- IMAGE DISPLAY: Image with no 'large view' click --><div class=""imageholder singleimage"" style=""width: " &
                                    numImageWidthMax & "px;" &
                                    "height: " & numImageHeightMax & "px;"">"

                                If strHyperlink <> "" Then litSingleImage.Text &= "<a href=""" & strHyperlink & """>"
                                litSingleImage.Text &= "<img alt=""" & strAltText & """ src=""" &
                                    strImageMainViewStart & """ />"
                                If strHyperlink <> "" Then litSingleImage.Text &= "</a>"
                                litSingleImage.Text &= "</div>" & vbCrLf
                            End If
                    End Select
                    Exit For
                Next
            Else

                '=======================================
                'PRODUCT PAGE VIEWER WITH GALLERY
                '=======================================
                pnlImageViewer.Visible = True
                pnlSingleImage.Visible = False

                'loop through all images
                'in folder and form image button links
                For Each objFile In dirFolder.GetFiles()
                    intIndex += 1
                    Select Case _eViewType
                        Case SmallImagesType.enum_ImageButton

                            'Product main product image
                            'Set link to thumbnail image
                            'This is the same for 'new page' and 'AJAX' settings
                            'because it is always a thumbnail
                            strImageLinkPath = "Image.ashx?strFileName=" & objFile.Name & "&amp;strItemType=" & _strItemType & "&amp;numMaxHeight=" & KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.height") & "&amp;numMaxWidth=" & KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.width") & "&amp;numItem=" & strImagesDirName & "&amp;strParent=" & strParentDirName

                            If blnFullSizeImage Then
                                '---------------------------------------
                                'IN 'NEW PAGE' LARGE VIEW MODE
                                'Direct link to the image itself
                                '---------------------------------------
                                strImageMainView = Replace(_strFolderPath & objFile.Name, "~/", "")
                            Else
                                '---------------------------------------
                                'IN 'AJAX' LARGE VIEW MODE
                                'Link to Image.ashx resizer
                                '---------------------------------------
                                strImageMainView = "Image.ashx?strFileName=" & objFile.Name & "&amp;strItemType=" & _strItemType & "&amp;numMaxHeight=" & numImageHeight & "&amp;numMaxWidth=" & numImageWidth & "&amp;numItem=" & strImagesDirName & "&amp;strParent=" & strParentDirName
                            End If

                            If intIndex = 1 And Not _blnVersionImages Then
                                '---------------------------------------
                                'SET INITIAL LARGE IMAGE PREVIEW
                                'Defaults to first image in folder
                                '---------------------------------------
                                strFirstImageName = objFile.Name
                                strImageMainViewStart = "Image.ashx?strFileName=" & objFile.Name & "&amp;strItemType=" & _strItemType & "&amp;numMaxHeight=" & numImageHeight & "&amp;numMaxWidth=" & numImageWidth & "&amp;numItem=" & strImagesDirName & "&amp;strParent=" & strParentDirName
                            End If

                            '---------------------------------------
                            'BUILD UP GALLERY
                            '---------------------------------------

                            'Foundation Clearing lightbox version
                            strImageFilePath = Replace(_strFolderPath & objFile.Name, "~/", "")

                            'Only need gallery if more than one image; but
                            'if we don't have this code at all, the main
                            'image doesn't seem to produce a popup. Instead,
                            'we just set it invisible, this seems to hide
                            'it while the popup functionality is retained.
                            If _blnVersionImages Then
                                'Version images
                                If intIndex = 1 Then
                                    'First image in version gallery
                                    litGalleryThumbs.Text &= "<li class=""clearing-featured-img""><a href=""" & strImageFilePath & """><img src=""" & strImageLinkPath & """></a></li>" ' & vbCrLf
                                Else
                                    'Subsequent images in version gallery
                                    litGalleryThumbs.Text &= "<li class=""hide""><a href=""" & strImageFilePath & """><img src=""" & strImageLinkPath & """></a></li>" ' & vbCrLf
                                End If
                            Else
                                'product images
                                If dirFolder.GetFiles().Length > 1 Then
                                    'Product image gallery thumbs
                                    litGalleryThumbs.Text &= "<li><a href=""" & strImageFilePath & """><img src=""" & strImageLinkPath & """></a></li>" ' & vbCrLf
                                Else
                                    'Hide gallery
                                    litGalleryThumbs.Text &= "<li style=""visibility: hidden;""><a href=""" & strImageFilePath & """><img src=""" & strImageLinkPath & """></a></li>" ' & vbCrLf
                                End If
                            End If
                    End Select

                Next


                '---------------------------------------
                'MAIN IMAGE PREVIEW (not large view)
                '---------------------------------------
                If KartSettingsManager.GetKartConfig("frontend.display.images.large.linktype") = "n" Then
                    If Not _blnVersionImages Then
                        '---------------------------------------
                        'IN 'NEW PAGE' LARGE VIEW MODE
                        'Direct link to the image itself
                        '---------------------------------------
                        litMainImage.Text &= "<!-- MAIN IMAGE PREVIEW: IN 'NEW PAGE' LARGE VIEW MODE Direct link to the image itself --><div class=""imageholder hand"" >"
                        litMainImage.Text &= "<a target=""_blank"" href=""" &
                            "LargeImage.aspx?P_ID=" & strImagesDirName & "&blnFullSize=y" & """>"
                        litMainImage.Text &= "<img alt=""" & strAltText & """ src=""" &
                            strImageMainViewStart & """ /></a>"
                        litMainImage.Text &= "</div>" & vbCrLf
                    Else
                        litMainImage.Text = ""
                    End If

                Else
                    If Not _blnVersionImages Then
                        '---------------------------------------
                        'IN 'AJAX' LARGE VIEW MODE
                        '---------------------------------------
                        litMainImage.Text &= "<!-- MAIN IMAGE PREVIEW: IN 'AJAX' LARGE VIEW MODE --><div class=""imageholder hand"" " &
                        "style=""height: " & numImageHeightMax & "px;"">"
                        litMainImage.Text &= "<img alt=""" & strAltText & """ src=""" & strImageMainViewStart & """ />" & vbCrLf
                        litMainImage.Text &= "</div>"
                    End If
                End If

            End If


        Else
            '=======================================
            'NO FOLDER FOUND
            'No images, and even no folder for this
            'item
            '=======================================
            NoImage(numImageHeight, numImageWidth, _blnPlaceHolder, strHyperlink)

        End If

    End Sub

    '=======================================
    'NO IMAGE FOUND
    'Display placeholder, or hide image
    '=======================================
    Public Sub NoImage(ByVal numImageHeight As Integer, ByVal numImageWidth As Integer, ByVal blnPlaceHolder As Boolean, ByVal strHyperlink As String)

        _blnFoundImage = False

        If strHyperlink <> "" Then
            strHyperlink = "<a href=""" & strHyperlink & """>"
        End If

        If blnPlaceHolder Then
            'either zero or just one file - no need for gallery
            pnlImageViewer.Visible = False
            pnlSingleImage.Visible = True

            'this should for an image placeholder
            Dim strStartImage As String = "Image.ashx?strItemType=" & _strItemType & "&amp;numMaxHeight=" & numImageHeight & "&amp;numMaxWidth=" & numImageWidth & "&amp;numItem=0&amp;strParent=0"

            litSingleImage.Text &= "<!-- NO IMAGE FOUND --><div class=""imageviewer""><div class=""imageholder singleimage"" style=""height: " & numImageHeight & "px;width: " & numImageWidth & "px;"">"

            'Open hyperlink (if not blank) and show image
            litSingleImage.Text &= strHyperlink & "<img alt=""No image"" src=""" & _
                strStartImage & """ />"

            'Close hyperlink if start is not blank
            If strHyperlink <> "" Then
                litSingleImage.Text &= "</a>"
            End If

            litSingleImage.Text &= "</div></div>" & vbCrLf
        Else
            pnlImageViewer.Visible = False
            pnlSingleImage.Visible = False
        End If
    End Sub

End Class
