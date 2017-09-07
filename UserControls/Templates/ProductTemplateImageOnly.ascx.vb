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
Imports CkartrisImages
Imports KartSettingsManager

''' <summary>
''' User Control Template for tiny image thumbs for basket, recent products, etc.
''' We've got our own image handling built in here to make this control far simpler
''' than normal image controls which use the gallery.
''' </summary>
''' <remarks>By Paul</remarks>
Partial Class ProductTemplateImageOnly
    Inherits System.Web.UI.UserControl

    Function CreateImageTag() As String
        Dim strImageTag As String = " "
        Dim strFolderPath As String = strProductImagesPath & "/" & litProductID.Text & "/"
        Dim strItemType As String = "p"
        Dim blnPlaceHolder As Boolean = (KartSettingsManager.GetKartConfig("frontend.display.image.products.placeholder") = "y")
        Dim objFile As FileInfo = Nothing
        Dim intIndex As Integer = 0
        Dim strImageLinkPath As String = ""

        'Dim strNavigateURL As String = SiteMapHelper.CreateURL(SiteMapHelper.Page.Product, litProductID.Text, Request.QueryString("strParent"), Request.QueryString("CategoryID"))

        'If recent products, the above can generate a bad path on pages called
        'with unfriend URLs, such as from search results. So let's
        'use canonical URL instead.
        Dim strNavigateURL = SiteMapHelper.CreateURL(SiteMapHelper.Page.CanonicalProduct, litProductID.Text)

        Try
            Dim dirFolder As New DirectoryInfo(Server.MapPath(strFolderPath))

            'See if there is an image to display
            If dirFolder.GetFiles().Length < 1 Then
                '=======================================
                'NO IMAGES FOUND
                'But folder found
                '=======================================
                strImageLinkPath = CkartrisBLL.WebShopURL & "Image.ashx?strItemType=" & strItemType & "&amp;numMaxHeight=" & KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.height") & "&amp;numMaxWidth=" & KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.width") & "&amp;numItem=0&amp;strParent=0"
                If blnPlaceHolder Then
                    strImageTag = "<a href=""" & strNavigateURL & """><img alt=""No image"" src=""" & strImageLinkPath & """ /></a>"
                Else
                    Me.Visible = False 'turn off this whole control
                End If

            Else
                '=======================================
                'SHOW IMAGE
                '=======================================
                Try


                    For Each objFile In dirFolder.GetFiles()
                        strImageLinkPath = CkartrisBLL.WebShopURL & "Image.ashx?strFileName=" & objFile.Name & "&amp;strItemType=" & strItemType & "&amp;numMaxHeight=" & KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.height") & "&amp;numMaxWidth=" & KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.width") & "&amp;numItem=" & litProductID.Text & "&amp;strParent=0"
                        strImageTag = "<a href=""" & strNavigateURL & """><img alt=""" & litP_Name.Text & """ src=""" & strImageLinkPath & """ /></a>"
                        Exit For
                    Next

                Catch ex As Exception
                    '=======================================
                    'SHOW NO IMAGES FOUND
                    'Best to do this if some error
                    '=======================================
                    strImageLinkPath = CkartrisBLL.WebShopURL & "Image.ashx?strItemType=" & strItemType & "&amp;numMaxHeight=" & KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.height") & "&amp;numMaxWidth=" & KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.width") & "&amp;numItem=0&amp;strParent=0"
                    If blnPlaceHolder Then
                        strImageTag = "<a href=""" & strNavigateURL & """><img alt=""No image"" src=""" & strImageLinkPath & """ /></a>"
                    Else
                        Me.Visible = False 'turn off this whole control
                    End If
                End Try
            End If
        Catch ex As Exception

            '=======================================
            'NO IMAGES FOUND
            'But folder found
            '=======================================
            strImageLinkPath = CkartrisBLL.WebShopURL & "Image.ashx?strItemType=" & strItemType & "&amp;numMaxHeight=" & KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.height") & "&amp;numMaxWidth=" & KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.width") & "&amp;numItem=0&amp;strParent=0"
            If blnPlaceHolder Then
                strImageTag = "<a href=""" & strNavigateURL & """><img alt=""No image"" src=""" & strImageLinkPath & """ /></a>"
            Else
                Me.Visible = False 'turn off this whole control
            End If
        End Try

        Return strImageTag
    End Function

End Class
