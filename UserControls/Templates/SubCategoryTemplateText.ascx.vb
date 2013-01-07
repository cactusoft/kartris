'[[[NEW COPYRIGHT NOTICE]]]

Imports CkartrisDisplayFunctions
Imports KartSettingsManager
''' <summary>
''' User Control Template for the Text View of the Child Categories (SubCategories)
''' </summary>
''' <remarks></remarks>
Partial Class SubCategoryTemplateText
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load


        lnkCategoryName.NavigateUrl = SiteMapHelper.CreateURL(SiteMapHelper.Page.Category, _
                                        litCategoryID.Text, Request.QueryString("strParent") & "," & Request.QueryString("CategoryID"))

        '' Trancating the Description Text, depending on the related key in CONFIG Setting
        '' The Full Description Text is Held by a Hidden Literal Control.
        Dim intMaxChar As Integer
        intMaxChar = GetKartConfig("frontend.categories.display.text.truncatedescription")
        litCategoryDesc.Text = TruncateDescription(litCategoryDescHidden.Text, intMaxChar)
    End Sub
End Class
