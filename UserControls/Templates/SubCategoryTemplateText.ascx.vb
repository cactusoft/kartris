'========================================================================
'Kartris - www.kartris.com
'Copyright 2020 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================

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
