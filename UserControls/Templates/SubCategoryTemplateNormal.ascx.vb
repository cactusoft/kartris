'[[[NEW COPYRIGHT NOTICE]]]
Imports CkartrisImages
Imports CkartrisDisplayFunctions
Imports KartSettingsManager

''' <summary>
''' User Control Template for the Normal View of the Child Categories (SubCategories)
''' </summary>
''' <remarks>By Mohammad</remarks>
Partial Class SubCategoryTemplateNormal
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        lnkCategoryName.NavigateUrl = SiteMapHelper.CreateURL(SiteMapHelper.Page.Category, _
                                        litCategoryID.Text, Request.QueryString("strParent") & "," & Request.QueryString("CategoryID"))

        lnkMore.NavigateUrl = lnkCategoryName.NavigateUrl
        

        UC_ImageView.CreateImageViewer(IMAGE_TYPE.enum_CategoryImage, _
            litCategoryID.Text, _
            KartSettingsManager.GetKartConfig("frontend.display.images.thumb.height"), _
            KartSettingsManager.GetKartConfig("frontend.display.images.thumb.width"), _
            lnkCategoryName.NavigateUrl, _
            "")

        '' Truncating the Description Text, depending on the related key in CONFIG Setting
        '' The Full Description Text is Held by a Hidden Literal Control.
        Dim intMaxChar As Integer
        intMaxChar = GetKartConfig("frontend.categories.display.normal.truncatedescription")
        litCategoryDesc.Text = TruncateDescription(litCategoryDescHidden.Text, intMaxChar)

    End Sub

End Class