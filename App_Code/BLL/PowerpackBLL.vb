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
Imports kartrisAttributesData
Imports kartrisAttributesDataTableAdapters
Imports System.Web.HttpContext
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports CkartrisFormatErrors

Public Class PowerpackBLL

    Public Shared Sub LoadCategoryFilters(ByVal intCategoryID As Integer, ByVal Request As HttpRequest, _
                                          ByRef xmlDoc As XmlDocument, ByRef arrSelectedValues() As String,
                                               ByVal numCurrencyID As Short, ByRef phdCategoryFilters As PlaceHolder, _
                                               ByRef phdPriceRange As PlaceHolder, ByRef ddlPriceRange As DropDownList, _
                                               ByRef txtFromPrice As TextBox, ByRef txtToPrice As TextBox, _
                                               ByRef litFromSymbol As Literal, ByRef litToSymbol As Literal, _
                                               ByRef phdCustomPrice As PlaceHolder, ByRef txtSearch As TextBox, _
                                               ByRef ddlOrderBy As DropDownList, ByRef phdAttributes As PlaceHolder, _
                                               ByRef rptAttributes As Repeater)
        phdCategoryFilters.Visible = False
    End Sub
    Public Shared Sub BoundRepeaterAttributeItem(xmlDoc As XmlDocument, arrSelectedValues() As String, ByRef itm As RepeaterItem)
        
    End Sub
    Public Shared Function GetFilteredProductsByCategory(Request As HttpRequest, _
                                                ByVal _CategoryID As Integer, ByVal _LanguageID As Short, _
                                                ByVal _PageIndx As Short, ByVal _RowsPerPage As Short, _
                                                ByVal _CGroupID As Short, ByRef _TotalNoOfProducts As Integer) As DataTable
        Return Nothing
    End Function
    Public Shared Sub GoToFilterURL(Request As HttpRequest, strFromPrice As String, strToPrice As String, strKeywords As String, _
                                        strAttributeValues As String, strOrderBy As String)

    End Sub
    Public Shared Function _IsFiltersEnabled() As Boolean
        Return False
    End Function
    Public Shared Function _GetFilterXMLByCategory(numCategoryID As Integer) As String
        Return "Not Enabled"
    End Function
    Public Shared Function _GenerateFilterXML(numCategoryID As Integer, numLanguageID As Byte) As String
        Return Nothing
    End Function
    Public Shared Function _GetFilterObjectID() As Integer
        Return 0
    End Function
    Private Shared Function _GetAttributesAndValues(ByVal _CategoryID As Integer, ByVal _LanguageID As Short) As DataTable
        Return Nothing
    End Function
    Private Shared Function _GetMaxPriceByCategory_s(ByVal _CategoryID As Integer, ByVal _LanguageID As Short) As Integer
        Return Nothing
    End Function
End Class
