'========================================================================
'Kartris - www.kartris.com
'Copyright 2021 CACTUSOFT

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

Partial Class LargeImage
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim P_ID As Integer = Request.QueryString("P_ID")
        Dim blnFullSize = (Request.QueryString("blnFullSize") = "y")

        If blnFullSize = True Then
            'Set height and width to zero, this will trigger
            'image as full size in imageviewer
            UC_ImageView.CreateImageViewer(IMAGE_TYPE.enum_ProductImage, _
                P_ID, _
                0, _
                0, _
                "", _
                "")
        Else
            'Set image height and width to defaults
            UC_ImageView.CreateImageViewer(IMAGE_TYPE.enum_ProductImage, _
                P_ID, _
                KartSettingsManager.GetKartConfig("frontend.display.images.large.height"), _
                KartSettingsManager.GetKartConfig("frontend.display.images.large.width"), _
                "", _
                "")
        End If
    End Sub

    Protected Sub Page_PreInit(ByVal sender As Object, ByVal e As EventArgs) Handles Me.PreInit

        Dim strSkin As String = CkartrisBLL.Skin(Session("LANG"))

        'We used a skin specified in the language record, if none
        'then use the default 'Kartris' one.
        If Not String.IsNullOrEmpty(strSkin) Then
            strSkin = "Kartris"
        End If

    End Sub
End Class
