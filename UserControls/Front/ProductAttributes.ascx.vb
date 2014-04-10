'========================================================================
'Kartris - www.kartris.com
'Copyright 2014 CACTUSOFT INTERNATIONAL FZ LLC

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
''' Used in the ProductView.ascx, to view the attributes(if any) of the current product.
''' </summary>
''' <remarks>By Mohammad</remarks>
Partial Class ProductAttributes
    Inherits System.Web.UI.UserControl

    Private _ProductID As Integer
    Private _LanguageID As Short

    ''' <summary>
    ''' Loads the product's attributes.
    ''' </summary>
    ''' <param name="pProductID"></param>
    ''' <param name="pLanguageID"></param>
    ''' <remarks>By Mohammad</remarks>
    Public Sub LoadProductAttributes(ByVal pProductID As Integer, ByVal pLanguageID As Short)

        _ProductID = pProductID
        _LanguageID = pLanguageID

        Me.Visible = False

        '' Getting the attributes of the Current Product.
        Dim tblAttributes As New DataTable
        tblAttributes = AttributesBLL.GetSummaryAttributesByProductID(_ProductID, _LanguageID)

        If tblAttributes.Rows.Count = 0 Then Exit Sub

        '' Bind the DataTable to the Repeater.
        Me.Visible = True
        rptAttributes.DataSource = tblAttributes.DefaultView
        rptAttributes.DataBind()

    End Sub

End Class
