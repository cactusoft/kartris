'[[[NEW COPYRIGHT NOTICE]]]
Imports CkartrisImages
Imports CkartrisDisplayFunctions
Imports KartSettingsManager

''' <summary>
''' User Control Template for the Shortened View of the Child Categories (SubCategories)
''' </summary>
''' <remarks>By Mohammad</remarks>
Partial Class SubCategoryTemplateShortened
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        lnkCategoryName.NavigateUrl = SiteMapHelper.CreateURL(SiteMapHelper.Page.Category, _
                                        litCategoryID.Text, Request.QueryString("strParent") & "," & Request.QueryString("CategoryID"))

        UC_ImageView.CreateImageViewer(IMAGE_TYPE.enum_CategoryImage, _
            litCategoryID.Text, _
            KartSettingsManager.GetKartConfig("frontend.display.images.thumb.height"), _
            KartSettingsManager.GetKartConfig("frontend.display.images.thumb.width"), _
            lnkCategoryName.NavigateUrl, _
            "")

        '' Trancating the Description Text, depending on the related key in CONFIG Setting
        '' The Full Description Text is Held by a Hidden Literal Control.
        Dim intMaxChar As Integer
        intMaxChar = GetKartConfig("frontend.categories.display.shortened.truncatedescription")


    End Sub
End Class
