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
Imports CkartrisImages
''' <summary>
''' User Control Template for the Category View
''' </summary>
''' <remarks>By Mohammad</remarks>
Partial Class CategoryTemplate
    Inherits System.Web.UI.UserControl

    Private _CategoryID As Integer
    Private _CategoryName As String
    Private _CategoryDesc As String

    '' Returns the Current Category ID
    Public ReadOnly Property CategoryID() As Integer
        Get
            Return _CategoryID
        End Get
    End Property

    '' Returns the Current Category Name
    Public ReadOnly Property CategoryName() As String
        Get
            Return _CategoryName
        End Get
    End Property

    '' Returns the Current Category Description
    Public ReadOnly Property CategoryDesc() As String
        Get
            Return _CategoryDesc
        End Get
    End Property


    ''' <summary>
    ''' Loads the Category's Info. into the Template's Attributes/Controls
    ''' </summary>
    ''' <param name="pCategoryID"></param>
    ''' <param name="pCategoryName"></param>
    ''' <param name="pCategoryDesc"></param>
    ''' <remarks>By Mohammad</remarks>
    Public Sub LoadCategoryTemplate(ByVal pCategoryID As Integer, ByVal pCategoryName As String, _
                                    ByVal pCategoryDesc As String)
        _CategoryID = pCategoryID
        _CategoryName = pCategoryName
        _CategoryDesc = pCategoryDesc

        '' Load the Name/Description of the Category.
        litCategoryName.Text = _CategoryName
        litCategoryDesc.Text = ShowLineBreaks(_CategoryDesc)

        'Don't need all that text in viewstate, just bulks up page
        litCategoryName.EnableViewState = False
        litCategoryDesc.EnableViewState = False

        If KartSettingsManager.GetKartConfig("frontend.category.showimage") = "y" Then
            UC_ImageView.CreateImageViewer(IMAGE_TYPE.enum_CategoryImage,
            _CategoryID.ToString(),
            KartSettingsManager.GetKartConfig("frontend.display.images.thumb.height"),
            KartSettingsManager.GetKartConfig("frontend.display.images.thumb.width"),
            "",
            "", , _CategoryName)
            phdCategoryImage.Visible = True
        Else
            phdCategoryImage.Visible = False
        End If
        
        phdCategoryDetails.Visible = True

    End Sub

    Public Sub HideImage()
        'imgCategory.Visible = False
    End Sub

    Function ShowLineBreaks(ByVal strInput As String) As String
        Dim strOutput As String = strInput
        If InStr(strInput, "<") > 0 And InStr(strInput, ">") > 0 Then
            'Input probably contains HTML, so we want to ignore line
            'breaks for display purposes

            'Do nothing
        Else
            strOutput = Replace(strOutput, vbCrLf, "<br />" & vbCrLf)
            strOutput = Replace(strOutput, vbLf, "<br />" & vbCrLf)
        End If
        Return strOutput
    End Function
End Class