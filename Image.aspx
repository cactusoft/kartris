<%@ Page Language="VB" Theme="" %>
<%@ OutputCache Duration="1800" VaryByParam="*" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Drawing.Drawing2D" %>
<%@ Import Namespace="System.Drawing.Image" %>
<%@ Import Namespace="System.Drawing.Imaging" %>
<%@ Import Namespace="System.Drawing.Imaging.EncoderParameters" %>
<%@ Import Namespace="System.Drawing.Imaging.ImageCodecInfo" %>
<script runat="server">
    '========================================================================
    'Kartris - www.kartris.com
    'Copyright 2016 CACTUSOFT

    'GNU GENERAL PUBLIC LICENSE v2
    'This program is free software distributed under the GPL without any
    'warranty.
    'www.gnu.org/licenses/gpl-2.0.html

    'KARTRIS COMMERCIAL LICENSE
    'If a valid license.config issued by Cactusoft is present, the KCL
    'overrides the GPL v2.
    'www.kartris.com/t-Kartris-Commercial-License.aspx
    '========================================================================

    '======================================================
    'IMPORTANT
    'This page does not have code behind because that
    'seems to result in errors as there are no XML/HTML
    'elements on the page.
    '======================================================
    Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)

        'Set max height and width limits
        Dim numMaxHeight As Double = 1000
        Try
            numMaxHeight = Request.QueryString("numMaxHeight") 'max height in pixels
        Catch
        End Try
        Dim numMaxWidth As Double = 1000
        Try
            numMaxWidth = Request.QueryString("numMaxWidth") 'max width in pixels
        Catch
        End Try
        Dim numItem As Double = 0
        Try
            numItem = Request.QueryString("numItem") 'ID number of product/category/version
        Catch
        End Try

        Dim strFullPath As String = Request.QueryString("strFullPath") 'used by back end
        Dim strItemType As String = Request.QueryString("strItemType") '[p]roduct / [c]ategory / [v]ersion / [s]pecials (promotions)
        Dim strFileName As String = Request.QueryString("strFileName") 'optional, exact name of file to display
        Dim strParent As String = Request.QueryString("strParent") 'parent product for versions
        Dim strFolderPath As String = ""
        Dim i As Integer
        Dim strImagePathToTry As String = ""
        Dim strImagePath As String = ""

        'array of acceptable image type, from config setting - png / jpg / jpeg / gif
        Dim aryFileTypes = Split(KartSettingsManager.GetKartConfig("backend.imagetypes", False), ",")

        If strFullPath = "" Then
            'Determine which folder to look at
            Select Case strItemType
                Case "p"
                    strFolderPath = "\Products\" & numItem & "\"
                Case "c"
                    strFolderPath = "\Categories\" & numItem & "\"
                Case "v"
                    strFolderPath = "\Products\" & strParent & "\" & numItem & "\"
                Case "s" 's for "specials" as 'p' is already taken!
                    strFolderPath = "\Promotions\" & numItem & "\"
            End Select

            'if whole directory, scan for suitable image
            If strFileName = "" Then
                For i = 0 To UBound(aryFileTypes)
                    strImagePathToTry = Server.MapPath("images") & strFolderPath & numItem & Trim(aryFileTypes(i))
                    If System.IO.File.Exists(strImagePathToTry) Then
                        strImagePath = strImagePathToTry
                    End If
                Next
            Else
                strImagePath = Server.MapPath("images") & strFolderPath & strFileName
            End If
        Else
            'We got full path, let's just tweak it for use
            'here
            strImagePath = Server.MapPath((Replace(strFullPath, "~/", "")))
        End If

        'If strImagePath is blank, must have no image so show holder
        If strImagePath = "" Then strImagePath = Server.MapPath("Skins/" & CkartrisBLL.Skin(Session("LANG")) & "/Images/no_image_available.png")


        'Now e have image path, let's create the output
        Dim objImage As System.Drawing.Image
        'Dim objThumbnail As System.Drawing.Image 'we say thumbnail, but it can actually be any image reduction

        Try
            'This could fail if no placeholder image

            objImage = System.Drawing.Image.FromFile(strImagePath)

            'Rotate the image 180 degrees twice so embedded thumbnail destroyed
            'otherwise will pick up and resize the thumbnail many digital
            'cameras put into large image formats
            objImage.RotateFlip(RotateFlipType.Rotate180FlipNone)
            objImage.RotateFlip(RotateFlipType.Rotate180FlipNone)

            Dim numImageOldHeight As Integer = objImage.Height
            Dim numImageOldWidth As Integer = objImage.Width
            'Dim strImageFormat = objImage.RawFormat
            Dim numImageNewHeight As Integer
            Dim numImageNewWidth As Integer

            Dim Params = New System.Drawing.Imaging.EncoderParameters(1)
            Params.Param(0) = New EncoderParameter(System.Drawing.Imaging.Encoder.Quality, 90L)
            Dim Info = System.Drawing.Imaging.ImageCodecInfo.GetImageEncoders()

            If numImageOldHeight / numMaxHeight < numImageOldWidth / numMaxWidth Then
                'Resize by width
                numImageNewWidth = numMaxWidth
                numImageNewHeight = numImageOldHeight / (numImageOldWidth / numMaxWidth)
            Else
                'Resize by height
                numImageNewHeight = numMaxHeight
                numImageNewWidth = numImageOldWidth / (numImageOldHeight / numMaxHeight)
            End If
            Dim bmpImage As New Bitmap(numImageNewWidth, numImageNewHeight) '= objThumbnail
            Dim grphCanvas As Graphics = Graphics.FromImage(bmpImage)
            grphCanvas.SmoothingMode = SmoothingMode.AntiAlias
            grphCanvas.InterpolationMode = InterpolationMode.HighQualityBicubic
            grphCanvas.DrawImage(objImage, 0, 0, bmpImage.Width, bmpImage.Height)

            ' Watermark settings
            If Not String.IsNullOrEmpty(KartSettingsManager.GetKartConfig("frontend.display.images.watermarktext")) AndAlso _
                numImageNewWidth >= 120 AndAlso numImageNewHeight >= 120 Then
                '' Setting the watermark text
                Dim wmText As String = KartSettingsManager.GetKartConfig("frontend.display.images.watermarktext")
                If wmText.ToLower = "[webshopurl]" Then wmText = CkartrisBLL.WebShopURLhttp

                '' Font and Text setting
                Dim wmFont As Font = New Font("Arial", 5, FontStyle.Bold)
                Dim wmTextColor As Color = Color.FromArgb(75, 255, 0, 119) '' #FF0077
                Dim wmTextWidth As Single = bmpImage.Width * 0.65
                Dim wmTextSize As SizeF = grphCanvas.MeasureString(wmText, wmFont)
                Dim wmFontRatio As Single = wmTextSize.Width / wmFont.SizeInPoints
                Dim wmFontSize As Single = wmTextWidth / wmFontRatio

                '' Final used font
                wmFont = New Font("Arial", wmFontSize, FontStyle.Bold)

                '' Place the watemark in the center of the image
                Dim numWidthCenter As Single = (numImageNewWidth / 2)
                Dim numHeightCenter As Single = (numImageNewHeight / 2)
                Dim strFormat As New StringFormat()
                strFormat.Alignment = StringAlignment.Center

                '' Draw the watermark text
                grphCanvas.DrawString(wmText, wmFont, New SolidBrush(wmTextColor), numWidthCenter, numHeightCenter, strFormat)
                bmpImage.SetResolution(95, 95)
            End If
            Dim FInfo As New FileInfo(strImagePath)

            'Here we can write some headers to stop the image
            'being cached, if there is a cache=clear passed to the page
            If Request.QueryString("cache") = "clear" Then
                Response.AppendHeader("Cache-Control", "no-cache, no-store, must-revalidate") 'HTTP 1.1.
                Response.AppendHeader("Pragma", "no-cache") 'HTTP 1.0.
                Response.AppendHeader("Expires", "0") 'Proxies.
            End If

            'In theory this lets us output thumbnails
            'in the original format, but PNGs don't
            'seem to work reliably
            'Select Case FInfo.Extension.ToUpper
            '    Case ".PNG"
            '        bmpImage.Save(Response.OutputStream, ImageFormat.Png)
            '    Case ".GIF"
            '        bmpImage.Save(Response.OutputStream, ImageFormat.Gif)
            '    Case Else
            '        bmpImage.Save(Response.OutputStream, ImageFormat.Jpeg)
            'End Select
            Response.ContentType = "image/jpeg"

            bmpImage.Save(Response.OutputStream, ImageFormat.Jpeg)
        Catch ex As Exception
            'Return nothing
        End Try

    End Sub
</script>