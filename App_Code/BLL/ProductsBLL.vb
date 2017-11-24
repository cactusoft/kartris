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
Imports kartrisProductsDataTableAdapters
Imports System.Web.HttpContext
Imports CkartrisFormatErrors
Imports CkartrisDisplayFunctions
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports KartSettingsManager

Public Class ProductsBLL

    Private Shared _Adptr As ProductsTblAdptr = Nothing
    Private Shared _ProdcutCategoryLinkAdptr As ProductCategoryLinkTblAdptr = Nothing
    Private Shared _RelatedAdptr As RelatedProductsTblAdptr = Nothing

    Protected Shared ReadOnly Property Adptr() As ProductsTblAdptr
        Get
            _Adptr = New ProductsTblAdptr
            Return _Adptr
        End Get
    End Property

    Protected Shared ReadOnly Property ProductCategoryLinkAdptr() As ProductCategoryLinkTblAdptr
        Get
            _ProdcutCategoryLinkAdptr = New ProductCategoryLinkTblAdptr
            Return _ProdcutCategoryLinkAdptr
        End Get
    End Property

    Protected Shared ReadOnly Property RelatedAdptr() As RelatedProductsTblAdptr
        Get
            _RelatedAdptr = New RelatedProductsTblAdptr
            Return _RelatedAdptr
        End Get
    End Property

    Public Shared Function _GetRelatedProductsByParent(ByVal intParentID As Integer) As DataTable
        Return RelatedAdptr._GetRelatedProductsByParent(intParentID)
    End Function

    Public Shared Function GetProductDetailsByID(ByVal _ProductID As Integer, ByVal _LanguageID As Short) As DataTable
        Return Adptr.GetByID(_ProductID, _LanguageID)
    End Function

    Public Shared Function _GetProductsBySupplier(ByVal numLanguageID As Byte, ByVal numSupplierID As Short) As DataTable
        Return Adptr._GetBySupplier(numLanguageID, numSupplierID)
    End Function

    Public Shared Function _GetFeaturedProducts(ByVal numLanguageID As Byte) As DataTable
        Return _Adptr._GetFeaturedProducts(numLanguageID)
    End Function

    'We can use this in the back end to check easily
    'if an options product is a combinations product.
    'We can also use it on the front end to nullify
    'the UseCombinationPrices object config setting
    'for a product that is not a combinations product.
    Public Shared Function _NumberOfCombinations(ByVal _ProductID As Integer) As Integer
        Dim dtbData As DataTable = _Adptr._NumberOfCombinations(_ProductID)
        Dim intCombinations As Integer = 0
        For Each drwData As DataRow In dtbData.Rows
            intCombinations = drwData("Combinations")
            Exit For
        Next
        Return intCombinations
    End Function

    Public Shared Function _UpdateFeaturedProducts(ByVal tblFeaturedProducts As DataTable, ByVal strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisProducts_UpdateAsFeatured"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                cmd.Parameters.Add("@ProductID", SqlDbType.Int)
                cmd.Parameters.Add("@Featured", SqlDbType.TinyInt)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                If Not _DeleteFeaturedProducts(sqlConn, savePoint) Then Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                For Each row As DataRow In tblFeaturedProducts.Rows
                    cmd.Parameters("@ProductID").Value = CInt(row("ProductID"))
                    cmd.Parameters("@Featured").Value = CByte(row("Priority"))
                    cmd.ExecuteNonQuery()
                Next

                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using

        Return False
    End Function

    Private Shared Function _DeleteFeaturedProducts(ByVal sqlConn As SqlConnection, ByVal savePoint As SqlTransaction) As Boolean
        Try
            Dim cmd As New SqlCommand("_spKartrisProducts_DeleteFeaturedProducts", sqlConn, savePoint)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.ExecuteNonQuery()
            Return True
            'End Using
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try
        Return False
    End Function

    'Cached Featured Products
    Public Shared Function GetFeaturedProducts(ByVal numLanguageID As Byte) As DataRow()
        Return GetFeaturedProductsFromCache.Select("LANG_ID = " & numLanguageID)
    End Function

    Public Shared Function GetFeaturedProductForCache() As DataTable
        Return Adptr.GetFeaturedProducts()
    End Function

    'Cached Newest Products
    Public Shared Function GetNewestProducts(ByVal numLanguageID As Byte) As DataRow()
        Return GetNewestProductsFromCache.Select("LANG_ID = " & numLanguageID)
    End Function

    Public Shared Function GetNewestProductsForCache() As DataTable
        Dim tblNewestProducts As New DataTable
        For Each rowLanguage As DataRow In LanguagesBLL.GetLanguages.Rows
            tblNewestProducts.Merge(Adptr.GetNewestProducts(rowLanguage("LANG_ID")), False)
        Next
        Return tblNewestProducts
    End Function

    'Cached Top List Products
    Public Shared Function GetTopListProducts(ByVal numLanguageID As Byte) As DataRow()
        Return GetTopListProductsForCache.Select("LANG_ID = " & numLanguageID)
    End Function

    Public Shared Function GetTopListProductsForCache() As DataTable
        Dim tblTopListProducts As New DataTable
        Dim datRange As Date = Today.AddDays(-CDbl(GetKartConfig("frontend.display.topsellers.days")))
        If datRange = Today Then datRange = Today.AddYears(-100)
        Dim intTopSellingCount As Integer = CInt(GetKartConfig("frontend.display.topsellers.quantity"))
        For Each rowLanguage As DataRow In LanguagesBLL.GetLanguages.Rows
            tblTopListProducts.Merge(Adptr.GetTopList(intTopSellingCount, rowLanguage("LANG_ID"), datRange), False)
        Next
        Return tblTopListProducts
    End Function

    Public Shared Function _SearchProductByName(ByVal _Key As String, ByVal _LanguageID As Byte) As DataTable
        Dim tbl As New DataTable
        tbl = Adptr._SearchByName(_Key, _LanguageID)
        If tbl.Rows.Count = 0 Then
            tbl = Adptr._GetData(_LanguageID)
        End If
        Return tbl
    End Function

    Public Shared Function GetProductsPageByCategory(ByVal _CategoryID As Integer, ByVal _LanguageID As Short, _
                                            ByVal _PageIndx As Short, ByVal _RowsPerPage As Short, _
                                            ByVal _CGroupID As Short, ByRef _TotalNoOfProducts As Integer) As DataTable
        _TotalNoOfProducts = GetTotalProductsInCategory_s(_CategoryID, _LanguageID, _CGroupID)
        Return Adptr.GetProductsPageByCategoryID(_LanguageID, _CategoryID, _PageIndx, _RowsPerPage, _CGroupID)
    End Function
    Public Shared Function GetProductsPageByCategory(Request As HttpRequest, ByVal _CategoryID As Integer, ByVal _LanguageID As Short, _
                                            ByVal _PageIndx As Short, ByVal _RowsPerPage As Short, _
                                            ByVal _CGroupID As Short, ByRef _TotalNoOfProducts As Integer) As DataTable
        If Request.QueryString("f") = 1 Then
            Dim dtFilteredProducts As DataTable = PowerpackBLL.GetFilteredProductsByCategory(Request, _CategoryID, _LanguageID, _PageIndx, _
                                                                _RowsPerPage, _CGroupID, _TotalNoOfProducts)
            If dtFilteredProducts IsNot Nothing Then Return dtFilteredProducts
        End If

        Return GetProductsPageByCategory(_CategoryID, _LanguageID, _PageIndx, _RowsPerPage, _CGroupID, _TotalNoOfProducts)
    End Function

    Public Shared Function _GetProductsPageByCategory(ByVal _CategoryID As Integer, ByVal _LanguageID As Short, _
                                            ByVal _PageIndx As Short, ByVal _RowsPerPage As Short, ByRef _TotalNoOfProducts As Integer) As DataTable
        _TotalNoOfProducts = _GetTotalProductsInCategory_s(_CategoryID, _LanguageID)
        Return Adptr._GetProductsPageByCategoryID(_LanguageID, _CategoryID, _PageIndx, _RowsPerPage)
    End Function

    Public Shared Function _GetCustomerGroup(ByVal numProductID As Integer) As Integer
        Dim qAdptr As New ProductQTblAdptr
        Dim _CGroupID As Integer
        qAdptr._GetCustomerGroup(numProductID, _CGroupID)
        Return _CGroupID
    End Function

    Public Shared Function GetTotalProductsInCategory_s(ByVal _CategoryID As Integer, ByVal _LanguageID As Short, ByVal _CGroupID As Short) As Object
        Dim qAdptr As New ProductQTblAdptr
        Dim totalProducts As Integer
        qAdptr.GetTotalByCatID_s(_LanguageID, _CategoryID, _CGroupID, totalProducts)
        Return totalProducts
    End Function

    Public Shared Function _GetTotalProductsInCategory_s(ByVal _CategoryID As Integer, ByVal _LanguageID As Short) As Object
        Dim qAdptr As New ProductQTblAdptr
        Dim totalProducts As Integer
        qAdptr._GetTotalByCatID_s(_LanguageID, _CategoryID, totalProducts)
        Return totalProducts
    End Function

    Public Shared Function GetMinPriceByCG(ByVal numProductID As Integer, ByVal numCG_ID As Integer) As Double
        Dim qAdptr As New ProductQTblAdptr
        Dim MinPrice As Single = 0.0F
        qAdptr.GetMinPriceWithCG_s(numProductID, numCG_ID, MinPrice)
        Return MinPrice
    End Function

    Public Shared Function GetRelatedProducts(ByVal _ProductID As Integer, ByVal _LanguageId As Short, ByVal _CustomerGroupID As Short) As DataTable
        Return Adptr.GetRelatedProducts(_ProductID, _LanguageId, _CustomerGroupID)
    End Function

    Public Shared Function GetPeopleWhoBoughtThis(ByVal ProductID As Integer, ByVal LanguageID As Short, ByVal numPeopleWhoBoughtThis As Integer) As DataTable
        Dim intType As Boolean
        If KartSettingsManager.GetKartConfig("frontend.crossselling.peoplewhoboughtthis.type") = "y" Then intType = True Else intType = False
        Return Adptr.GetPeopleWhoBoughtThis(ProductID, LanguageID, numPeopleWhoBoughtThis, intType)
    End Function

    Public Shared Function GetParentCategories(ByVal _ProductID As Integer, ByVal _LanguageID As Short) As DataTable
        Return Adptr.GetParentCategories(_LanguageID, _ProductID)
    End Function

    Public Shared Function GetNameByProductID(ByVal _ProductID As Integer, ByVal _LanguageID As Short) As String
        Return LanguageElementsBLL.GetElementValue( _
          _LanguageID, LANG_ELEM_TABLE_TYPE.Products, LANG_ELEM_FIELD_NAME.Name, _ProductID)
    End Function

    Public Shared Function GetMetaDescriptionByProductID(ByVal _ProductID As Integer, ByVal _LanguageID As Short) As String
        Dim strMetaDescription As String = LanguageElementsBLL.GetElementValue( _
          _LanguageID, LANG_ELEM_TABLE_TYPE.Products, LANG_ELEM_FIELD_NAME.MetaDescription, _ProductID)
        If String.IsNullOrEmpty(strMetaDescription) Or strMetaDescription = "# -LE- #" Then _
            strMetaDescription = LanguageElementsBLL.GetElementValue(_LanguageID, LANG_ELEM_TABLE_TYPE.Products, LANG_ELEM_FIELD_NAME.Description, _ProductID)
        If strMetaDescription = "# -LE- #" Then strMetaDescription = Nothing
        Return Left(StripHTML(strMetaDescription), 160)
    End Function

    Public Shared Function GetMetaKeywordsByProductID(ByVal _ProductID As Integer, ByVal _LanguageID As Short) As String
        Dim strMetaKeywords As String = LanguageElementsBLL.GetElementValue( _
          _LanguageID, LANG_ELEM_TABLE_TYPE.Products, LANG_ELEM_FIELD_NAME.MetaKeywords, _ProductID)
        If strMetaKeywords = "# -LE- #" Then strMetaKeywords = Nothing
        Return StripHTML(strMetaKeywords)
    End Function

    Public Shared Function _GetNameByProductID(ByVal _ProductID As Integer, ByVal _LanguageID As Short) As String
        Return LanguageElementsBLL.GetElementValue( _
          _LanguageID, LANG_ELEM_TABLE_TYPE.Products, LANG_ELEM_FIELD_NAME.Name, _ProductID)
    End Function

    Public Shared Function GetAttributeValueByAttributeID_s(ByVal _LanguageID As Short, ByVal _ProductID As Integer, ByVal _AttributeID As Integer) As String
        Dim qAdptr As New ProductQTblAdptr
        Dim _AttributeValue As String = ""
        qAdptr.GetAttributeValue_s(_ProductID, _AttributeID, _LanguageID, _AttributeValue)
        Return _AttributeValue
    End Function

    Public Shared Function _GetProductType_s(ByVal _ProductID As Integer) As Char
        Dim qAdptr As New ProductQTblAdptr
        Dim _ProductType As Char = ""
        qAdptr._GetProductType_s(_ProductID, _ProductType)
        Return _ProductType
    End Function

    Public Shared Function _GetProductInfoByID(ByVal pProductID As Integer) As DataTable
        Return Adptr._GetProductInfoByID(pProductID)
    End Function

    Public Shared Function _GetCategoriesByProductID(ByVal pProductID As Integer) As DataTable
        Return ProductCategoryLinkAdptr._GetCategoriesByProductID(pProductID)
    End Function

    Public Shared Sub _GetProductStatus( _
                            ByVal numProductID As Integer, ByRef blnProductLive As Boolean, _
                            ByRef strProductType As String, ByRef numLiveVersions As Integer, _
                            ByRef numLiveCategories As Integer, ByRef numCustomerGroup As Short)
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisProducts_GetStatus"

            cmd.CommandType = CommandType.StoredProcedure
            Try

                cmd.Parameters.AddWithValue("@P_ID", numProductID)
                cmd.Parameters.AddWithValue("@ProductLive", False).Direction = ParameterDirection.Output
                cmd.Parameters.AddWithValue("@ProductType", "").Direction = ParameterDirection.Output
                cmd.Parameters.AddWithValue("@NoOfLiveVersions", 0).Direction = ParameterDirection.Output
                cmd.Parameters.AddWithValue("@NoOfLiveCategories", 0).Direction = ParameterDirection.Output
                cmd.Parameters.AddWithValue("@ProductCustomerGroup", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                cmd.ExecuteNonQuery()

                blnProductLive = FixNullFromDB(cmd.Parameters("@ProductLive").Value)
                strProductType = FixNullFromDB(cmd.Parameters("@ProductType").Value)
                numLiveVersions = FixNullFromDB(cmd.Parameters("@NoOfLiveVersions").Value)
                numLiveCategories = FixNullFromDB(cmd.Parameters("@NoOfLiveCategories").Value)
                numCustomerGroup = FixNullFromDB(cmd.Parameters("@ProductCustomerGroup").Value)

            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())

            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try

        End Using
    End Sub

    Public Shared Function _DeleteProduct(ByVal intProductID As Integer, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdDeleteProduct As SqlCommand = sqlConn.CreateCommand
            cmdDeleteProduct.CommandText = "_spKartrisProducts_Delete"
            Dim savePoint As SqlTransaction = Nothing
            cmdDeleteProduct.CommandType = CommandType.StoredProcedure
            Try
                cmdDeleteProduct.Parameters.AddWithValue("@ProductID", intProductID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdDeleteProduct.Transaction = savePoint
                cmdDeleteProduct.ExecuteNonQuery()
                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using

        Return False
    End Function

    Public Shared Function _AddProduct(ByVal ptblElements As DataTable, ByVal pParentsList As String,
                                    ByRef pProductID As Integer, ByVal pLive As Boolean, ByVal pFeatured As Byte,
                                    ByVal pOrderVersionsBy As String, ByVal pVersionsSortDirection As Char,
                                    ByVal pReviews As Char, ByVal pVersionDisplayType As Char, ByVal pSupplier As Integer,
                                    ByVal pProductType As Char, ByVal pCustomerGroupID As Integer, ByRef strMsg As String, Optional ByRef blnIsClone As Boolean = False) As Integer

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisProducts_Add"

            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try

                cmd.Parameters.AddWithValue("@NewP_ID", pProductID).Direction = ParameterDirection.Output
                cmd.Parameters.AddWithValue("@P_Live", pLive)
                cmd.Parameters.AddWithValue("@P_Featured", pFeatured)
                cmd.Parameters.AddWithValue("@P_OrderVersionsBy", pOrderVersionsBy)
                cmd.Parameters.AddWithValue("@P_VersionsSortDirection", pVersionsSortDirection)
                cmd.Parameters.AddWithValue("@P_VersionDisplayType", pVersionDisplayType)
                cmd.Parameters.AddWithValue("@P_Reviews", pReviews)
                cmd.Parameters.AddWithValue("@P_SupplierID", FixNullToDB(pSupplier, "i"))
                cmd.Parameters.AddWithValue("@P_Type", pProductType)
                cmd.Parameters.AddWithValue("@P_CustomerGroupID", FixNullToDB(pCustomerGroupID, "i"))
                cmd.Parameters.AddWithValue("@NowOffset", CkartrisDisplayFunctions.NowOffset)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                ' 1. Add The Main Info.
                cmd.ExecuteNonQuery()

                If cmd.Parameters("@NewP_ID").Value Is Nothing OrElse
                    cmd.Parameters("@NewP_ID").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If
                pProductID = cmd.Parameters("@NewP_ID").Value

                ' 2. Add the Language Elements
                If Not LanguageElementsBLL._AddLanguageElements(
                        ptblElements, LANG_ELEM_TABLE_TYPE.Products,
                        pProductID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                ' 3. Add the Hierarchy
                If Not _UpdateProductCategories(pProductID, pParentsList, sqlConn, savePoint, strMsg) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                ' 4. Add single version, only if single version type product
                ' and not cloning (clones we will run a separate procedure
                ' to create the version[s])
                If pProductType = "s" And Not blnIsClone Then
                    If Not VersionsBLL._AddNewVersionAsSingle(
                            _GetVersionElements(ptblElements), "SKU_" & CStr(pProductID), pProductID, pCustomerGroupID, sqlConn, savePoint, strMsg) Then
                        Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                    End If
                End If

                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")

                Return pProductID
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try

        End Using

        Return -1
    End Function

    'Creates records such as version(s), related product links, attribute values
    'etc. that are linked to a product
    Public Shared Function _CloneProductRecords(ByVal pProductID_OLD As Integer, ByVal pProductID_NEW As Integer) As Boolean
        Dim strMsg As String = ""
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisProducts_CloneRecords"

            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try

                cmd.Parameters.AddWithValue("@P_ID_OLD", pProductID_OLD)
                cmd.Parameters.AddWithValue("@P_ID_NEW", pProductID_NEW)
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint
                cmd.ExecuteNonQuery()
                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")

                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return False
    End Function

    Private Shared Function _GetVersionElements(ByVal tblProductElements As DataTable) As DataTable
        Dim tblVersionElements As New DataTable
        tblVersionElements.Columns.Add(New DataColumn("_LE_LanguageID"))
        tblVersionElements.Columns.Add(New DataColumn("_LE_FieldID"))
        tblVersionElements.Columns.Add(New DataColumn("_LE_Value"))

        For Each row As DataRow In tblProductElements.Rows
            Dim numType As Integer = CInt(FixNullFromDB(row("_LE_FieldID")))
            If numType = LANG_ELEM_FIELD_NAME.Name OrElse _
                numType = LANG_ELEM_FIELD_NAME.Description Then
                tblVersionElements.Rows.Add(row("_LE_LanguageID"), row("_LE_FieldID"), _
                IIf(numType = LANG_ELEM_FIELD_NAME.Name, row("_LE_Value"), ""))
            End If
        Next
        Return tblVersionElements
    End Function

    Public Shared Function _UpdateProduct(ByVal ptblElements As DataTable, ByVal pParentsList As String, _
                                    ByVal pProductID As Integer, ByVal pLive As Boolean, ByVal pFeatured As Byte, _
                                    ByVal pOrderVersionsBy As String, ByVal pVersionsSortDirection As Char, ByVal pReviews As Char, _
                                    ByVal pVersionDisplayType As Char, ByVal pSupplier As Integer, ByVal pProductType As Char, _
                                    ByVal pCustomerGroupID As Integer, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisProducts_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure

            Try
                cmd.Parameters.AddWithValue("@P_ID", pProductID)
                cmd.Parameters.AddWithValue("@P_Live", pLive)
                cmd.Parameters.AddWithValue("@P_Featured", pFeatured)
                cmd.Parameters.AddWithValue("@P_OrderVersionsBy", pOrderVersionsBy)
                cmd.Parameters.AddWithValue("@P_VersionsSortDirection", pVersionsSortDirection)
                cmd.Parameters.AddWithValue("@P_VersionDisplayType", pVersionDisplayType)
                cmd.Parameters.AddWithValue("@P_Reviews", pReviews)
                cmd.Parameters.AddWithValue("@P_SupplierID", FixNullToDB(pSupplier, "i"))
                cmd.Parameters.AddWithValue("@P_Type", pProductType)
                cmd.Parameters.AddWithValue("@P_CustomerGroupID", FixNullToDB(pCustomerGroupID, "i"))
                cmd.Parameters.AddWithValue("@NowOffset", CkartrisDisplayFunctions.NowOffset)

                '' Needed to update the products' version (product' type is single version only)
                Dim numSingleVersionID As Long = 0
                If pProductType = "s" Then numSingleVersionID = VersionsBLL._GetSingleVersionByProduct(pProductID).Rows(0)("V_ID")

                Dim NoOfVersions As Integer = 0
                If pProductType = "o" OrElse pProductType = "s" Then NoOfVersions = VersionsBLL._GetNoOfVersionsByProductID(pProductID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                '1. Add The Main Info.
                cmd.ExecuteNonQuery()

                '2. Update the Language Elements
                If Not LanguageElementsBLL._UpdateLanguageElements( _
                        ptblElements, LANG_ELEM_TABLE_TYPE.Products, _
                        pProductID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                '3. Add the Hierarchy
                If Not _UpdateProductCategories(pProductID, pParentsList, sqlConn, savePoint, strMsg) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                '4. Check the product type
                If pProductType = "o" AndAlso NoOfVersions = 1 Then
                    If Not VersionsBLL._SetVersionAsBaseByProductID(pProductID, sqlConn, savePoint, strMsg) Then
                        Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                    End If
                ElseIf pProductType = "s" AndAlso NoOfVersions = 1 Then
                    '' Update the versions' info, the versions will be readonly in the backend
                    If Not LanguageElementsBLL._UpdateLanguageElements( _
                        _GetVersionElements(ptblElements), LANG_ELEM_TABLE_TYPE.Versions, _
                        numSingleVersionID, sqlConn, savePoint) Then
                        Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                    End If
                End If

                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")

                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try

        End Using
        Return False
    End Function

    Private Shared Function _UpdateProductCategories(ByVal pProductID As Integer, ByVal pNewParents As String, _
                                             ByVal sqlConn As SqlConnection, ByVal savePoint As SqlTransaction, ByRef strMsg As String) As Boolean

        Try
            If pNewParents.EndsWith(",") Then pNewParents = pNewParents.TrimEnd(",")

            Dim cmdAddParents As New SqlCommand("_spKartrisProductCategoryLink_AddParentList", sqlConn, savePoint)
            cmdAddParents.CommandType = CommandType.StoredProcedure
            cmdAddParents.Parameters.AddWithValue("@ProductID", pProductID)
            cmdAddParents.Parameters.AddWithValue("@ParentList", pNewParents)

            cmdAddParents.ExecuteNonQuery()

            Return True
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
        End Try

        Return False
    End Function

    Public Shared Function _UpdateRelatedProducts(ByVal intParentProduct As Integer, ByVal strChildList As String, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdDeleteRelatedProducts As SqlCommand = sqlConn.CreateCommand
            cmdDeleteRelatedProducts.CommandText = "_spKartrisRelatedProducts_DeleteByParentID"

            Dim savePoint As SqlTransaction = Nothing
            cmdDeleteRelatedProducts.CommandType = CommandType.StoredProcedure

            Try
                cmdDeleteRelatedProducts.Parameters.AddWithValue("@ParentID", intParentProduct)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdDeleteRelatedProducts.Transaction = savePoint

                cmdDeleteRelatedProducts.ExecuteNonQuery()

                If strChildList.EndsWith(",") Then strChildList = strChildList.TrimEnd(",")

                Dim cmdAddRelatedProducts As New SqlCommand("_spKartrisRelatedProducts_AddChildList", sqlConn, savePoint)
                cmdAddRelatedProducts.CommandType = CommandType.StoredProcedure
                cmdAddRelatedProducts.Parameters.AddWithValue("@ParentID", intParentProduct)
                cmdAddRelatedProducts.Parameters.AddWithValue("@ChildList", strChildList)
                cmdAddRelatedProducts.ExecuteNonQuery()

                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try

        End Using

        Return False
    End Function

    Public Shared Sub _ChangeSortValue(ByVal numCategoryID As Integer, ByVal numProductID As Integer, ByVal chrDirection As Char)
        ProductCategoryLinkAdptr._ChangeSortValue(numProductID, numCategoryID, chrDirection)
    End Sub

    Public Shared Function GetRichSnippetProperties(numProductID As Integer, numLanguageID As Byte) As DataTable
        Return Adptr.GetRichSnippetProperties(numProductID, numLanguageID)
    End Function

    'Set whether product live or not
    Public Shared Function _HideShowAllByCategoryID(ByVal pCategoryID As Integer, ByVal pLive As Boolean) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisProducts_HideShowAllByCategoryID"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure

            Try
                cmd.Parameters.AddWithValue("@CAT_ID", pCategoryID)
                cmd.Parameters.AddWithValue("@P_Live", pLive)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                cmd.ExecuteNonQuery()

                savePoint.Commit()
                sqlConn.Close()

                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try

        End Using
        Return False
    End Function
End Class
