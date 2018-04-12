'========================================================================
'Kartris - www.kartris.com
'Copyright 2018 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisDataManipulation

''' <summary>
''' Used in CompareItem.ascx, to view the product's attributes that could be used to compare products.
''' </summary>
''' <remarks></remarks>
Partial Class ProductCompareValues
    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' Loads and Prepares the attributes to be compared with the other products, it receives a table of the products
    '''   and their attributes, also receives an array that holds the attributes that should be excluded from the comparison.
    ''' </summary>
    ''' <param name="pProductID"></param>
    ''' <param name="pProductToCompare">DataTable the hold the products with their attributes</param>
    ''' <param name="pLanguageID"></param>
    ''' <param name="pNotIncludedAttributes">String Array that holds the attributes that should be excluded from comparison.</param>
    ''' <remarks></remarks>
    Public Sub LoadProductComparisonValues(ByVal pProductID As Integer, ByVal pProductToCompare As DataTable, _
                                     ByVal pLanguageID As Short, ByVal pNotIncludedAttributes As String())

        '' Creating a table (Attribute Table) to hold the attributes that should be shown in the page.
        Dim tblAttributes As New DataTable
        tblAttributes.Columns.Add("ATTRIB_ID", Type.GetType("System.Int32"))
        tblAttributes.Columns.Add("ATTRIB_Name", Type.GetType("System.String"))
        tblAttributes.Columns.Add("ATTRIB_Value", Type.GetType("System.String"))
        tblAttributes.Columns.Add("ATTRIB_OrderByValue", Type.GetType("System.Int16"))
        tblAttributes.Constraints.Add("PK", tblAttributes.Columns("ATTRIB_ID"), True)

        '' Setting the Price String to be shown as an attribute.
        Dim strProductPrice As String = ""

        If KartSettingsManager.GetKartConfig("frontend.products.display.fromprice") = "y" Then
            strProductPrice = GetGlobalResourceObject("Products", "ContentText_ProductPriceFrom")
        End If

        '' Converting & formating the price according to the current currency.
        Dim numPrice As Single = 0.0F
        numPrice = CurrenciesBLL.ConvertCurrency(Session("CUR_ID"), CDbl(litPriceHidden.Text))
        strProductPrice += CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), numPrice)

        '' Show minimum price for each comparison item
        litMinPrice.Text = strProductPrice

        '' Flag to know if the attribute should be added to the Attributes Table or not.
        Dim blnToBeAdded As Boolean
        Dim blnAtLeastOneRow As Boolean = False

        '' Reading the productsToBeCompared Table
        For Each itmRow In pProductToCompare.Rows

            blnToBeAdded = True
            '' Reading the array of the Excluded Attributes
            If pNotIncludedAttributes.Length > 0 Then
                For i As Integer = 0 To pNotIncludedAttributes.Length - 1
                    Try
                        '' If the ArributeID is in the Excluded Attributes, then it will not be added to the Attributes Table.
                        If FixNullFromDB(itmRow("ATTRIB_ID")) = CInt(pNotIncludedAttributes(i)) Then
                            blnToBeAdded = False
                            Exit For
                        End If
                    Catch ex As Exception
                    End Try
                Next
            End If

            '' If the current product's attribute shouldn't be added, then Countinue The Loop.
            If Not blnToBeAdded Then Continue For

            '' Adding the attribute to the (Attribute Table)
            '' Used in a TRY block, cause it could violate the PK constraints; because the 
            ''   productsToCompare Table has a duplicate attributeIDs along with diff. products.
            Try
                tblAttributes.Rows.Add(FixNullFromDB(itmRow("ATTRIB_ID")), _
                               "<strong>" & Server.HtmlEncode(FixNullFromDB(itmRow("ATTRIB_Name"))) & "</strong>", _
                               ProductsBLL.GetAttributeValueByAttributeID_s( _
                                           pLanguageID, pProductID, FixNullFromDB(itmRow("ATTRIB_ID"))), FixNullFromDB(itmRow("ATTRIB_OrderByValue")))

                blnAtLeastOneRow = True
            Catch ex As Exception
            End Try

        Next

        Dim dv As DataView = tblAttributes.DefaultView
        dv.Sort = "ATTRIB_OrderByValue, ATTRIB_Name "

        '' Binding the newly generated table to the repeater.
        rptProductAttributes.DataSource = dv
        rptProductAttributes.DataBind()

        '' Hide repeater if no rows, so no empty 'table' tags
        If blnAtLeastOneRow = False Then rptProductAttributes.Visible = False
    End Sub
End Class
