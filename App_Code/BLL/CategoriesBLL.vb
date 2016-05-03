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
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports System.Web.HttpContext
Imports CkartrisFormatErrors
Imports kartrisCategoriesData
Imports kartrisCategoriesDataTableAdapters
Imports CkartrisDisplayFunctions

Public Class CategoriesBLL

    Private Shared _Adptr As CategoriesTblAdptr = Nothing
    Private Shared _AdptrHierarchy As CategoryHierarchyTblAdptr = Nothing

    Protected Shared ReadOnly Property Adptr() As CategoriesTblAdptr
        Get
            _Adptr = New CategoriesTblAdptr
            Return _Adptr
        End Get
    End Property

    Protected Shared ReadOnly Property AdptrHierarchy() As CategoryHierarchyTblAdptr
        Get
            _AdptrHierarchy = New CategoryHierarchyTblAdptr
            Return _AdptrHierarchy
        End Get
    End Property

    Public Shared Function _GetWithProducts(ByVal _LanguageID As Short) As DataTable
        Return Adptr._GetWithProductsOnly(_LanguageID)
    End Function

    Public Shared Function _SearchCategoryByName(ByVal _Key As String, ByVal _LanguageID As Byte) As DataTable
        Dim tbl As New DataTable
        tbl = Adptr._SearchByName(_Key, _LanguageID)
        If tbl.Rows.Count = 0 Then
            tbl = Adptr.GetData(_LanguageID)
        End If
        Return tbl
    End Function

    Public Shared Function GetCategoryByID(ByVal _CategoryID As Integer, ByVal _LanguageID As Short) As DataTable
        Return Adptr.GetByCategoryID(_CategoryID, _LanguageID)
    End Function

    Public Shared Function GetCategoriesByProductID(ByVal _ProductID As Integer, ByVal _LanguageID As Short) As DataTable
        Return Adptr.GetByProductID(_ProductID, _LanguageID)
    End Function

    Public Shared Function GetCategoriesPageByParentID(ByVal _ParentCategoryID As Integer, ByVal _LanguageID As Short, _
                                            ByVal _PageIndx As Short, ByVal _RowsPerPage As Short, _
                                            ByVal _CGroupID As Short, ByRef _TotalNoOfCategories As Integer) As DataTable
        _TotalNoOfCategories = GetTotalCategoriesByParentID_o(_LanguageID, _ParentCategoryID, _CGroupID)
        Return Adptr.GetCategoriesPageByParentID(_LanguageID, _ParentCategoryID, _PageIndx, _RowsPerPage, _CGroupID)
    End Function

    Public Shared Function _GetCategoriesPageByParentID(ByVal _ParentCategoryID As Integer, ByVal _LanguageID As Short, _
                                            ByVal _PageIndx As Short, ByVal _RowsPerPage As Short, ByRef _TotalNoOfCategories As Integer) As DataTable
        _TotalNoOfCategories = _GetTotalCategoriesByParentID_o(_LanguageID, _ParentCategoryID)
        Return Adptr._GetCategoriesPageByParentID(_LanguageID, _ParentCategoryID, _PageIndx, _RowsPerPage)
    End Function

    Public Shared Function _GetTotalCategoriesByParentID_o(ByVal _LanguageID As Short, ByVal _ParentCategoryID As Integer) As Integer
        Dim totalCategories As Integer
        Dim qAdptr As New CategoriesQTblAdptr
        qAdptr._GetTotalByParentID_o(_LanguageID, _ParentCategoryID, totalCategories)
        Return totalCategories
    End Function

    Public Shared Function GetTotalCategoriesByParentID_o(ByVal _LanguageID As Short, ByVal _ParentCategoryID As Integer, ByVal _CGroupID As Short) As Integer
        Dim totalCategories As Integer
        Dim qAdptr As New CategoriesQTblAdptr
        qAdptr.GetTotalByParentID_o(_LanguageID, _ParentCategoryID, _CGroupID, totalCategories)
        Return totalCategories
    End Function

    Public Shared Function GetHierarchyByLanguageID(ByVal _LanguageID As Short) As DataTable
        Dim blnSortByName As Boolean = False
        If LCase(KartSettingsManager.GetKartConfig("frontend.categories.display.sortdefault")) = "cat_name" Then blnSortByName = True
        Return AdptrHierarchy.GetHierarchyByLanguage(_LanguageID, blnSortByName)
    End Function

    Public Shared Function _GetHierarchyByLanguageId(ByVal _LanguageID As Short) As DataTable
        Return AdptrHierarchy._GetHierarchyByLanguage(_LanguageID)
    End Function

    Public Shared Function GetNameByCategoryID(ByVal _CategoryID As Integer, ByVal _LanguageID As Short) As String
        Return LanguageElementsBLL.GetElementValue( _
          _LanguageID, LANG_ELEM_TABLE_TYPE.Categories, LANG_ELEM_FIELD_NAME.Name, _CategoryID)
    End Function

    Public Shared Function GetMetaDescriptionByCategoryID(ByVal _CategoryID As Integer, ByVal _LanguageID As Short) As String
        Dim strMetaDescription As String = LanguageElementsBLL.GetElementValue( _
          _LanguageID, LANG_ELEM_TABLE_TYPE.Categories, LANG_ELEM_FIELD_NAME.MetaDescription, _CategoryID)
        If String.IsNullOrEmpty(strMetaDescription) Or strMetaDescription = "# -LE- #" Then _
            strMetaDescription = LanguageElementsBLL.GetElementValue(_LanguageID, LANG_ELEM_TABLE_TYPE.Categories, LANG_ELEM_FIELD_NAME.Description, _CategoryID)
        If strMetaDescription = "# -LE- #" Then strMetaDescription = ""
        Return Left(StripHTML(strMetaDescription), 160)
    End Function

    Public Shared Function GetMetaKeywordsByCategoryID(ByVal _CategoryID As Integer, ByVal _LanguageID As Short) As String
        Dim strMetaKeywords As String = LanguageElementsBLL.GetElementValue( _
          _LanguageID, LANG_ELEM_TABLE_TYPE.Categories, LANG_ELEM_FIELD_NAME.MetaKeywords, _CategoryID)
        If strMetaKeywords = "# -LE- #" Then strMetaKeywords = ""
        Return StripHTML(strMetaKeywords)
    End Function

    Public Shared Function _GetNameByCategoryID(ByVal _CategoryID As Integer, ByVal _LanguageID As Short) As String
        Return LanguageElementsBLL.GetElementValue( _
          _LanguageID, LANG_ELEM_TABLE_TYPE.Categories, LANG_ELEM_FIELD_NAME.Name, _CategoryID)

    End Function

    Public Shared Function _GetTotalCategoriesByLanguageID(ByVal numLanguageID As Byte) As Integer
        Dim numTotalCategories As Integer = 0
        Adptr._GetTotalCategoriesByLanguageID(numLanguageID, numTotalCategories)
        Return numTotalCategories
    End Function

    Public Shared Function _GetParentsByID(ByVal pLanguageID As Byte, ByVal pChildID As Integer) As DataTable
        Return AdptrHierarchy._GetParentsByID(pLanguageID, pChildID)
    End Function

    Public Shared Function _GetByID(ByVal pCategoryID As Integer) As DataTable
        Return Adptr._GetByCategoryID(pCategoryID)
    End Function

    Public Shared Function _GetTotalSubCategories_s(ByVal CategoryID As Integer) As Short
        Dim totalSubcategories As Short = 0
        AdptrHierarchy._GetTotalSubcategories(CategoryID, totalSubcategories)
        Return totalSubcategories
    End Function

    Public Shared Sub _GetCategoryStatus( _
             ByVal numCategoryID As Integer, ByRef blnCategoryLive As Boolean, _
             ByRef numLiveParents As Integer, ByRef numCustomerGroup As Short)
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisCategories_GetStatus"
            cmd.CommandType = CommandType.StoredProcedure

            Try

                cmd.Parameters.AddWithValue("@CAT_ID", numCategoryID)
                cmd.Parameters.AddWithValue("@CategoryLive", False).Direction = ParameterDirection.Output
                cmd.Parameters.AddWithValue("@NoOfLiveParents", 0).Direction = ParameterDirection.Output
                cmd.Parameters.AddWithValue("@CategoryCustomerGroup", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                cmd.ExecuteNonQuery()

                blnCategoryLive = FixNullFromDB(cmd.Parameters("@CategoryLive").Value)
                numLiveParents = FixNullFromDB(cmd.Parameters("@NoOfLiveParents").Value)
                numCustomerGroup = FixNullFromDB(cmd.Parameters("@CategoryCustomerGroup").Value)

            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())

            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try

        End Using
    End Sub

    Public Shared Function _AddCategory(ByVal ptblElements As DataTable, ByVal pParentsList As String, _
       ByRef pCategoryID As Integer, ByVal pLive As Boolean, ByVal pProductDisplayType As Char, _
       ByVal pSubCatDisplayType As Char, ByVal pOrderProductsBy As String, _
       ByVal pProductsSortDirection As Char, ByVal pOrderSubcatBy As String, _
        ByVal pSubcatSortDirection As Char, ByVal pCustomerGroupID As Integer, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisCategories_Add"

            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure

            Try
                cmd.Parameters.AddWithValue("@NewCAT_ID", pCategoryID).Direction = ParameterDirection.Output
                cmd.Parameters.AddWithValue("@CAT_Live", pLive)
                cmd.Parameters.AddWithValue("@CAT_ProductDisplayType", pProductDisplayType)
                cmd.Parameters.AddWithValue("@CAT_SubCatDisplayType", pSubCatDisplayType)
                cmd.Parameters.AddWithValue("@CAT_OrderProductsBy", pOrderProductsBy)
                cmd.Parameters.AddWithValue("@CAT_ProductsSortDirection", pProductsSortDirection)
                cmd.Parameters.AddWithValue("@CAT_CustomerGroupID", FixNullToDB(pCustomerGroupID, "i"))
                cmd.Parameters.AddWithValue("@CAT_OrderCategoriesBy", pOrderSubcatBy)
                cmd.Parameters.AddWithValue("@CAT_CategoriesSortDirection", pSubcatSortDirection)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                '' 1. Add The Main Info.
                cmd.ExecuteNonQuery()

                If cmd.Parameters("@NewCAT_ID").Value Is Nothing OrElse _
                  cmd.Parameters("@NewCAT_ID").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                pCategoryID = FixNullFromDB(cmd.Parameters("@NewCAT_ID").Value)

                '' 2. Add the Language Elements
                If Not LanguageElementsBLL._AddLanguageElements( _
                  ptblElements, LANG_ELEM_TABLE_TYPE.Categories, _
                  pCategoryID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                '' 3. Add the Hierarchy
                If Not _UpdateCategoryHierarchy(pCategoryID, pParentsList, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
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

    Public Shared Function _UpdateCategory(ByVal ptblElements As DataTable, ByVal pParentsList As String, _
         ByVal pCategoryID As Integer, ByVal pLive As Boolean, ByVal pProductDisplayType As Char, _
        ByVal pSubCatDisplayType As Char, ByVal pOrderProductsBy As String, _
        ByVal pProductsSortDirection As Char, ByVal pOrderSubcatBy As String, _
        ByVal pSubcatSortDirection As Char, ByVal pCustomerGroupID As Integer, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisCategories_Update"

            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                cmd.Parameters.AddWithValue("@CAT_ID", pCategoryID)
                cmd.Parameters.AddWithValue("@CAT_Live", pLive)
                cmd.Parameters.AddWithValue("@CAT_ProductDisplayType", pProductDisplayType)
                cmd.Parameters.AddWithValue("@CAT_SubCatDisplayType", pSubCatDisplayType)
                cmd.Parameters.AddWithValue("@CAT_OrderProductsBy", pOrderProductsBy)
                cmd.Parameters.AddWithValue("@CAT_ProductsSortDirection", pProductsSortDirection)
                cmd.Parameters.AddWithValue("@CAT_CustomerGroupID", FixNullToDB(pCustomerGroupID, "i"))
                cmd.Parameters.AddWithValue("@CAT_OrderCategoriesBy", pOrderSubcatBy)
                cmd.Parameters.AddWithValue("@CAT_CategoriesSortDirection", pSubcatSortDirection)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                If pCategoryID = 0 Then '' Used to modify the category no. 0
                    If Not LanguageElementsBLL._UpdateLanguageElements(ptblElements, LANG_ELEM_TABLE_TYPE.Categories, _
                      pCategoryID, sqlConn, savePoint) Then
                        Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                    End If

                    savePoint.Commit()
                    sqlConn.Close()
                    strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                    Return True
                End If

                '' 1. Update The Main Info.
                cmd.ExecuteNonQuery()

                '' 2. Update the Language Elements
                If Not LanguageElementsBLL._UpdateLanguageElements( _
                  ptblElements, LANG_ELEM_TABLE_TYPE.Categories, _
                  pCategoryID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                '' 3. Add the Hierarchy
                'Need to remove the empty check, because we want to allow categories
                'to be saved without parents (to make them top level cats)
                If Not String.IsNullOrEmpty(pParentsList) Then
                    If Not _UpdateCategoryHierarchy(pCategoryID, pParentsList, sqlConn, savePoint) Then
                        Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                    End If
                End If

                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")

                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using

        Return False
    End Function

    Private Shared Function _UpdateCategoryHierarchy(ByVal pChildID As Integer, ByVal pNewParents As String, _
                                             ByVal sqlConn As SqlConnection, ByVal savePoint As SqlTransaction) As Boolean

        Dim cmd As New SqlCommand("_spKartrisCategoryHierarchy_DeleteByChild", sqlConn, savePoint)
        cmd.CommandType = CommandType.StoredProcedure
        Try
            cmd.Parameters.AddWithValue("@ChildID", pChildID)
            cmd.ExecuteNonQuery()

            If pNewParents.EndsWith(",") Then pNewParents = pNewParents.TrimEnd(",")
            If pNewParents.Length = 0 Then pNewParents = "0"

            Dim cmdAddParents As New SqlCommand("_spKartrisCategoryHierarchy_AddParentList", sqlConn, savePoint)
            cmdAddParents.CommandType = CommandType.StoredProcedure
            cmdAddParents.Parameters.AddWithValue("@ParentList", pNewParents)
            cmdAddParents.Parameters.AddWithValue("@ChildID", pChildID)
            cmdAddParents.ExecuteNonQuery()

            Return True
        Catch ex As SqlException
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        Finally
        End Try
        'End Using
        Return False
    End Function

    Public Shared Function _DeleteCategory(ByVal intCategoryID As Integer, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdDeleteCategory As SqlCommand = sqlConn.CreateCommand
            cmdDeleteCategory.CommandText = "_spKartrisCategories_Delete"

            Dim savePoint As SqlTransaction = Nothing
            cmdDeleteCategory.CommandType = CommandType.StoredProcedure
            Try

                cmdDeleteCategory.Parameters.AddWithValue("@CAT_ID", intCategoryID)
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdDeleteCategory.Transaction = savePoint

                cmdDeleteCategory.ExecuteNonQuery()

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

    Public Shared Sub _ChangeSortValue(ByVal numParentID As Integer, ByVal numCategoryID As Integer, ByVal chrDirection As Char)
        AdptrHierarchy._ChangeSortValue(numParentID, numCategoryID, chrDirection)
    End Sub

    '' Delete Category Cascade (with subcategories)
    Public Shared Function _DeleteCategoryCascade(ByVal intCategoryID As Integer, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Try
                sqlConn.Open()
                _RecursiveCategoryDelete(intCategoryID, sqlConn)
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try
        End Using
        Return False

    End Function
    Public Shared Function _RecursiveCategoryDelete(ByVal intCategoryID As Integer, ByVal sqlConn As SqlConnection) As Boolean
        Dim tblChildCategories As DataTable = AdptrHierarchy._GetSubcategoriesIDs(intCategoryID)
        For Each child As DataRow In tblChildCategories.Rows

            '' Check Parent Categories
            Dim tblParentCategories As DataTable = AdptrHierarchy._GetOtherParents(child("CH_ChildID"), intCategoryID)
            If tblParentCategories.Rows.Count = 0 Then
                '' If there is no other parents, then delete recursive
                _RecursiveCategoryDelete(child("CH_ChildID"), sqlConn)
            End If

            '' Delete Hierarchy Link (Child, Parent)
            If Not _DeleteHierarchyLink(child("CH_ChildID"), intCategoryID, sqlConn) Then
                Return False
            End If
        Next

        Return _DeleteCategoryWithoutTransaction(intCategoryID, sqlConn)
    End Function
    Public Shared Function _DeleteCategoryWithoutTransaction(ByVal numCategoryID As Integer, ByVal sqlConn As SqlConnection) As Boolean

        Dim cmdDeleteCategory As SqlCommand = sqlConn.CreateCommand
        cmdDeleteCategory.CommandText = "_spKartrisCategories_Delete"
        cmdDeleteCategory.CommandType = CommandType.StoredProcedure
        cmdDeleteCategory.Parameters.AddWithValue("@CAT_ID", numCategoryID)

        Try
            cmdDeleteCategory.ExecuteNonQuery()
            Return True
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        Finally
        End Try

        Return False
    End Function
    Public Shared Function _DeleteHierarchyLink(ByVal numChildID As Integer, ByVal numParentID As Integer, ByVal sqlConn As SqlConnection) As Boolean

        Dim cmd As SqlCommand = sqlConn.CreateCommand
        cmd.CommandText = "_spKartrisCategoryHierarchy_DeleteLink"
        cmd.CommandType = CommandType.StoredProcedure
        cmd.Parameters.AddWithValue("@ChildID", numChildID)
        cmd.Parameters.AddWithValue("@ParentID", numParentID)
        Try
            cmd.ExecuteNonQuery()

            Return True
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        Finally
        End Try
        Return False
    End Function

End Class