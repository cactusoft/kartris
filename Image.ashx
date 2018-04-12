<%@ WebHandler Language="VB" Class="Image" %>

Imports System
Imports System.Web
Imports System.Drawing

Public Class Image : Implements IHttpHandler, System.Web.SessionState.IReadOnlySessionState

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest

        'Set watermark here, if required
        Dim strWaterMarkText As String = ""

        'Set this below to force a particular output type
        'Default is jpg, but removing it will respect the original
        'file type, e.g. png, gif
        Dim strOutputType As String = ".JPG" '.PNG, .GIF, .JPG

        Dim numMaxHeight As Double = 1000   ' max height in pixels
        Dim numMaxWidth As Double = 1000    ' max width in pixels
        Dim numItem As Double = 0           ' ID number of product/category/version

        Dim req As HttpRequest = context.Request    ' Alias the request object

        If IsNumeric(req.QueryString("numMaxHeight")) Then
            ' Get max height
            numMaxHeight = CDbl(req.QueryString("numMaxHeight"))
        End If

        If IsNumeric(req.QueryString("numMaxWidth")) Then
            ' Get max width
            numMaxWidth = CDbl(req.QueryString("numMaxWidth"))
        End If

        If IsNumeric(req.QueryString("numItem")) Then
            ' Get item number (ID)
            numItem = CDbl(req.QueryString("numItem"))
        End If

        Dim strFullPath As String = req.QueryString("strFullPath")  ' root path to where the images are stored
        Dim strItemType As String = req.QueryString("strItemType")  ' [p]roduct / [c]ategory / [v]ersion / [s]pecials (promotions)
        Dim strFileName As String = req.QueryString("strFileName")  ' optional, exact name of file to display
        Dim strParent As String = req.QueryString("strParent")      ' parent product for versions
        Dim strImagesPath As String = HttpContext.Current.Server.MapPath("images")      ' Path to images folder 
        Dim strFolderPath As String = ""
        Dim i As Integer
        Dim strImagePathToTry As String = ""
        Dim strImagePath As String = ""

        'array of acceptable image type, from config setting - png / jpg / jpeg / gif
        Dim aryFileTypes = Split(".jpg,.jpeg,.gif,.png", ",")

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
                    strImagePathToTry = strImagesPath & strFolderPath & numItem & Trim(aryFileTypes(i))
                    If System.IO.File.Exists(strImagePathToTry) Then
                        strImagePath = strImagePathToTry
                        ' We have a value, let's exit early.
                        Exit For
                    End If
                Next
            Else
                strImagePath = strImagesPath & strFolderPath & strFileName
            End If
        Else
            'We got full path, let's just tweak it for use
            'here
            strImagePath = HttpContext.Current.Server.MapPath((Replace(strFullPath, "~/", "")))
        End If

        'If strImagePath is blank, must have no image so show holder
        If strImagePath = "" Then strImagePath = HttpContext.Current.Server.MapPath("Skins/" & CkartrisBLL.Skin(context.Session("LANG")) & "/Images/no_image_available.png")

        'Now we have image path, let's create the output
        Dim objImage As System.Drawing.Image

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
            Dim numImageNewHeight As Integer
            Dim numImageNewWidth As Integer

            Dim Params = New System.Drawing.Imaging.EncoderParameters(1)
            Params.Param(0) = New Imaging.EncoderParameter(System.Drawing.Imaging.Encoder.Quality, 90L)
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
            grphCanvas.SmoothingMode = Drawing2D.SmoothingMode.AntiAlias
            grphCanvas.InterpolationMode = Drawing2D.InterpolationMode.HighQualityBicubic
            grphCanvas.DrawImage(objImage, 0, 0, bmpImage.Width, bmpImage.Height)

            ' Watermark settings
            If Not String.IsNullOrEmpty(strWaterMarkText) AndAlso
                numImageNewWidth >= 120 AndAlso numImageNewHeight >= 120 Then
                '' Setting the watermark text
                Dim wmText As String = strWaterMarkText
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

            context.Response.Clear()

            'Here we can write some headers to stop the image
            'being cached, if there is a cache=clear passed to the page
            If req.QueryString("cache") = "clear" Then
                context.Response.AppendHeader("Cache-Control", "no-cache, no-store, must-revalidate") 'HTTP 1.1.
                context.Response.AppendHeader("Pragma", "no-cache") 'HTTP 1.0.
                context.Response.AppendHeader("Expires", "0") 'Proxies.
            Else
                ' Allow the image to be cached
                context.Response.Cache.SetCacheability(HttpCacheability.Public)
                context.Response.Cache.SetExpires(DateTime.Now.AddMinutes(60))
                context.Response.Cache.SetMaxAge(New TimeSpan(1, 30, 0))
                context.Response.Cache.SetLastModified(DateTime.Now.AddMinutes(-20))
                context.Response.Cache.SetVaryByCustom("*")
                context.Response.Cache.VaryByParams("*") = True
            End If

            'Set output type so that it is recognised as a jpeg.
            'context.Response.ContentType = "image/jpeg"
            'bmpImage.Save(context.Response.OutputStream, Imaging.ImageFormat.Jpeg)

            'In theory this lets us output thumbnails
            'in the original format, but PNGs don't
            'seem to work reliably
            If strOutputType = "" Then
                strOutputType = FInfo.Extension.ToUpper
            End If

            Select Case strOutputType
                Case ".PNG"
                    bmpImage.Save(context.Response.OutputStream, Imaging.ImageFormat.Png)
                    context.Response.ContentType = "image/png"
                Case ".GIF"
                    bmpImage.Save(context.Response.OutputStream, Imaging.ImageFormat.Gif)
                    context.Response.ContentType = "image/gif"
                Case Else
                    bmpImage.Save(context.Response.OutputStream, Imaging.ImageFormat.Jpeg)
                    context.Response.ContentType = "image/jpeg"
            End Select

        Catch ex As Exception
            'Return nothing
        End Try

    End Sub

    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class