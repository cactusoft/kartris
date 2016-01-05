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

''' <summary>
''' Used in the ProductView.ascx, to show the reviews that are related to the current Product.
''' </summary>
''' <remarks>By Mohammad</remarks>
Partial Class ProductReviews
    Inherits System.Web.UI.UserControl

    Private _ProductID As Integer
    Private _ProductName As String

    Public ReadOnly Property ProductName() As String
        Get
            Return _ProductName
        End Get
    End Property

    ''' <summary>
    ''' Loads/Bind the reviews to the Repeater and Loads the FORM for writing new reviews.
    ''' </summary>
    ''' <param name="pProductID"></param>
    ''' <param name="pLanguageID"></param>
    ''' <param name="pProductName"></param>
    ''' <remarks></remarks>
    Public Sub LoadReviews(ByVal pProductID As Integer, ByVal pLanguageID As Short, ByVal pProductName As String)

        _ProductID = pProductID
        _ProductName = pProductName

        'Retrieves all the reviews that are related to the Current Product.
        Dim tblReviews As New DataTable
        tblReviews = ReviewsBLL.GetReviewsByProductID(_ProductID, pLanguageID)

        'Set tab header text
        litReviewsHeader.Text = GetGlobalResourceObject("Reviews", "ContentText_CustomerReviews")
        litWriteReviewText.Text = GetGlobalResourceObject("Reviews", "ContentText_WriteReview")

        'If there are reviews
        If tblReviews.Rows.Count > 0 Then
            rptReviews.DataSource = tblReviews
            rptReviews.DataBind()
        Else
            'There are no reviews.
            mvwReview.SetActiveView(viwNoReview)
        End If

        'Loads the FORM to write reviews.
        UC_WriteReview.CreateWriter(_ProductID, _ProductName)

    End Sub
End Class
