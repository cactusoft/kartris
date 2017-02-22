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
''' <summary>
''' User Control Template for Promotions.
''' </summary>
''' <remarks>By Paul</remarks>
Partial Class Templates_PromotionTemplate
	Inherits System.Web.UI.UserControl

	Private _PromotionID As String
	Private _PromotionName As String
	Private _PromotionText As String

	Public Property PromotionID() As String
		Get
			Return _PromotionID
		End Get
		Set(ByVal value As String)
			_PromotionID = value
		End Set
	End Property

	Public Property PromotionName() As String
		Get
			Return _PromotionName
		End Get
		Set(ByVal value As String)
			_PromotionName = value
		End Set
	End Property

	Public Property PromotionText() As String
		Get
			Return _PromotionText
		End Get
		Set(ByVal value As String)
			_PromotionText = value
		End Set
	End Property

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

		LoadPromotions(PromotionID, PromotionName, PromotionText)

	End Sub

	Public Sub LoadPromotions(ByVal strPromotionID As String, ByVal strPromotionName As String, ByVal strPromotionText As String)

		litPromotionIDHidden.Text = strPromotionID
		litPromotionName.Text = strPromotionName
		litPromotionText.Text = strPromotionText

		If PromotionID <> "" Then
			UC_ImageView.CreateImageViewer(IMAGE_TYPE.enum_PromotionImage, _
			litPromotionIDHidden.Text, _
			KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.height"), _
			KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.width"), _
			"", _
			"")
		End If

	End Sub


End Class
