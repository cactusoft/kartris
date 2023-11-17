'========================================================================
'Kartris - www.kartris.com
'Copyright 2023 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports System.Web.HttpContext
Imports CkartrisFormatErrors
Imports CkartrisEnumerations
Imports kartrisPromotionsData
Imports kartrisPromotionsDataTableAdapters
Imports CkartrisDisplayFunctions
Imports CkartrisDataManipulation
Imports SiteMapHelper

Public Class PromotionsBLL

    Private Shared _Adptr As PromotionsTblAdptr = Nothing
    Private Shared _AdptrParts As PromotionPartsTblAdptr = Nothing
    Private Shared _AdptrPromotionString As PromotionStringsTblAdptr = Nothing

    Protected Shared ReadOnly Property Adptr() As PromotionsTblAdptr
        Get
            _Adptr = New PromotionsTblAdptr
            Return _Adptr
        End Get
    End Property

    Protected Shared ReadOnly Property AdptrParts() As PromotionPartsTblAdptr
        Get
            _AdptrParts = New PromotionPartsTblAdptr
            Return _AdptrParts
        End Get
    End Property

    Protected Shared ReadOnly Property AdptrStrings() As PromotionStringsTblAdptr
        Get
            _AdptrPromotionString = New PromotionStringsTblAdptr
            Return _AdptrPromotionString
        End Get
    End Property

    Public Shared Function _GetData() As DataTable
        Return Adptr._GetData()
    End Function
    Public Shared Function _GetPromotionByID(ByVal PromotionID As Integer) As DataTable
        Return Adptr._GetByID(PromotionID)
    End Function
    Public Shared Function GetPromotionsByProductID(ByVal _ProductID As Integer, ByVal _LanguageID As Short, ByVal numPromotionID As Integer) As DataTable
        Return Adptr.GetByProductID(_ProductID, _LanguageID, NowOffset, numPromotionID)
    End Function
    Public Shared Function GetPromotionName(ByVal numPromotionID As Integer, ByVal numLanguageID As Short) As String
        Dim objLanguageElementsBLL As New LanguageElementsBLL()
        Dim strName As String = objLanguageElementsBLL.GetElementValue(numLanguageID, LANG_ELEM_TABLE_TYPE.Promotions, LANG_ELEM_FIELD_NAME.Name, numPromotionID)
        If strName = "# -LE- #" Then Return Nothing
        Return strName
    End Function

    Public Shared Function GetAllPromotions(ByVal _LanguageID As Short, ByVal numPromotionID As Integer) As DataTable
        Return Adptr.GetAllPromotions(_LanguageID, NowOffset, numPromotionID)
    End Function

    Public Shared Function _GetAllPromotions(ByVal LanguageID As Short) As DataTable
        Return Adptr._GetAllPromotions(LanguageID)
    End Function

    Public Shared Function _GetPromotionStringsByType(ByVal charType As Char, ByVal languageID As Byte) As DataTable
        Return AdptrStrings._GetByType(charType, languageID)
    End Function
    Public Shared Function _GetPromotionString(ByVal bytPromotionStringID As Byte, ByVal languageID As Byte) As DataTable
        Return AdptrStrings._GetByID(bytPromotionStringID, languageID)
    End Function

    Public Shared Function _GetByPartsAndPromotion(ByVal chrPart As Char, ByVal intPromotionID As Integer, ByVal languageID As Byte) As DataTable
        Return AdptrParts._GetByPartsPromotionID(chrPart, intPromotionID, languageID)
    End Function
    Public Shared Function _GetPartsByPromotion(ByVal intPromotionID As Integer, ByVal languageID As Byte) As DataTable
        Return AdptrParts._GetByPromotionID(intPromotionID, languageID)
    End Function

    Public Shared Function _AddNewPromotion(ByVal tblElements As DataTable, ByRef intPromotionID As Integer, ByVal dtStartDate As Date, ByVal dtEndDate As Date, _
                                  ByVal intMaxQty As Byte, ByVal intOrderNo As Short, ByVal blnLive As Boolean, _
                                  ByVal tblParts As DataTable, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdAddPromotion As SqlCommand = sqlConn.CreateCommand
            cmdAddPromotion.CommandText = "_spKartrisPromotions_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmdAddPromotion.CommandType = CommandType.StoredProcedure

            Try
                cmdAddPromotion.Parameters.AddWithValue("@PROM_StartDate", dtStartDate)
                cmdAddPromotion.Parameters.AddWithValue("@PROM_EndDate", dtEndDate)
                cmdAddPromotion.Parameters.AddWithValue("@PROM_Live", blnLive)
                cmdAddPromotion.Parameters.AddWithValue("@PROM_OrderByValue", intOrderNo)
                cmdAddPromotion.Parameters.AddWithValue("@PROM_MaxQuantity", intMaxQty)
                cmdAddPromotion.Parameters.AddWithValue("@NewPROM_ID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddPromotion.Transaction = savePoint


                cmdAddPromotion.ExecuteNonQuery()

                If cmdAddPromotion.Parameters("@NewPROM_ID").Value Is Nothing OrElse _
                cmdAddPromotion.Parameters("@NewPROM_ID").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                intPromotionID = cmdAddPromotion.Parameters("@NewPROM_ID").Value
                If Not LanguageElementsBLL._AddLanguageElements( _
                        tblElements, LANG_ELEM_TABLE_TYPE.Promotions, intPromotionID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                For Each row As DataRow In tblParts.Rows
                    row("PROM_ID") = intPromotionID
                Next

                If Not _AddPromotionParts(tblParts, sqlConn, savePoint, strMsg) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                savePoint.Commit()
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
    Public Shared Function _UpdatePromotion(ByVal tblElements As DataTable, ByVal intPromotionID As Integer, ByVal dtStartDate As Date, _
                                     ByVal dtEndDate As Date, ByVal intMaxQty As Byte, ByVal intOrderNo As Short, ByVal blnLive As Boolean, _
                                  ByVal tblParts As DataTable, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdUpdatePromotion As SqlCommand = sqlConn.CreateCommand
            cmdUpdatePromotion.CommandText = "_spKartrisPromotions_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmdUpdatePromotion.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdatePromotion.Parameters.AddWithValue("@PROM_ID", intPromotionID)
                cmdUpdatePromotion.Parameters.AddWithValue("@PROM_StartDate", dtStartDate)
                cmdUpdatePromotion.Parameters.AddWithValue("@PROM_EndDate", dtEndDate)
                cmdUpdatePromotion.Parameters.AddWithValue("@PROM_Live", blnLive)
                cmdUpdatePromotion.Parameters.AddWithValue("@PROM_OrderByValue", intOrderNo)
                cmdUpdatePromotion.Parameters.AddWithValue("@PROM_MaxQuantity", intMaxQty)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdatePromotion.Transaction = savePoint

                cmdUpdatePromotion.ExecuteNonQuery()

                If Not LanguageElementsBLL._UpdateLanguageElements( _
                        tblElements, LANG_ELEM_TABLE_TYPE.Promotions, intPromotionID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                For Each row As DataRow In tblParts.Rows
                    row("PROM_ID") = intPromotionID
                Next

                If Not _DeletePromotionParts(intPromotionID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                If Not _AddPromotionParts(tblParts, sqlConn, savePoint, strMsg) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                savePoint.Commit()
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

    Public Shared Function GetPromotionText(ByVal intPromotionID As Integer, Optional ByVal blnTextOnly As Boolean = False) As String
        Dim tblPromotionParts As New DataTable    ''==== language_ID =====
        tblPromotionParts = PromotionsBLL._GetPartsByPromotion(intPromotionID, Current.Session("LANG"))

        Dim strPromotionText As String = ""
        Dim intTextCounter As Integer = 0
        Dim numLanguageID As Long

        numLanguageID = Current.Session("LANG")

        Dim objCategoriesBLL As New CategoriesBLL
        Dim objProductsBLL As New ProductsBLL
        Dim objVersionsBLL As New VersionsBLL

        For Each drwPromotionParts As DataRow In tblPromotionParts.Rows

            Dim strText As String = drwPromotionParts("PS_Text")
            Dim strStringID As String = drwPromotionParts("PS_ID")
            Dim strValue As String = CkartrisDisplayFunctions.FixDecimal(FixNullFromDB(drwPromotionParts("PP_Value")))
            Dim strItemID As String = FixNullFromDB(drwPromotionParts("PP_ItemID"))
            Dim intProductID As Integer = objVersionsBLL.GetProductID_s(CLng(strItemID))
            Dim strItemName As String = ""
            Dim strItemLink As String = ""

            If strText.Contains("[X]") Then
                If strText.Contains("[£]") Then
                    strText = strText.Replace("[X]", CurrenciesBLL.FormatCurrencyPrice(Current.Session("CUR_ID"), CurrenciesBLL.ConvertCurrency(Current.Session("CUR_ID"), drwPromotionParts("PP_Value"))))
                Else
                    strText = strText.Replace("[X]", strValue)
                End If
            End If

            If strText.Contains("[C]") AndAlso strItemID <> "" Then ''==== language_ID =====
                strItemName = objCategoriesBLL.GetNameByCategoryID(CInt(strItemID), numLanguageID)
                strItemLink = " <b><a href='" & CreateURL(Page.CanonicalCategory, strItemID) & "'>" & strItemName & "</a></b>"
                strItemLink = IIf(blnTextOnly, strItemName, strItemLink)
                strText = strText.Replace("[C]", strItemLink)
            End If

            If strText.Contains("[P]") AndAlso strItemID <> "" Then ''==== language_ID =====
                strItemName = objProductsBLL.GetNameByProductID(CInt(strItemID), numLanguageID)
                strItemLink = " <b><a href='" & CreateURL(Page.CanonicalProduct, strItemID) & "'>" & strItemName & "</a></b>"
                strItemLink = IIf(blnTextOnly, strItemName, strItemLink)
                strText = strText.Replace("[P]", strItemLink)
            End If

            If strText.Contains("[V]") AndAlso strItemID <> "" Then ''==== language_ID =====
                strItemName = objProductsBLL.GetNameByProductID(intProductID, numLanguageID) & " (" & objVersionsBLL._GetNameByVersionID(CInt(strItemID), numLanguageID) & ")"
                strItemLink = " <b><a href='" & CreateURL(Page.CanonicalProduct, intProductID) & "'>" & strItemName & "</a></b>"
                strItemLink = IIf(blnTextOnly, strItemName, strItemLink)
                strText = strText.Replace("[V]", strItemLink)
            End If

            If strText.Contains("[£]") Then
                strText = strText.Replace("[£]", "")
            End If

            intTextCounter += 1
            If intTextCounter > 1 Then
                strPromotionText += ", "
            End If
            strPromotionText += strText
        Next

        Return strPromotionText

    End Function

    Private Shared Function _DeletePromotionParts(ByVal intPromotionID As Integer, ByVal sqlConn As SqlConnection, ByVal savePoint As SqlTransaction) As Boolean
        Try
            Dim cmd As New SqlCommand("_spKartrisPromotionParts_DeleteByPromotionID", sqlConn, savePoint)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@PromotionID", intPromotionID)
            cmd.ExecuteNonQuery()
            Return True
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try
        Return False
    End Function
    Private Shared Function _AddPromotionParts(ByVal tblParts As DataTable, ByVal sqlConn As SqlConnection, ByVal savePoint As SqlTransaction, ByRef strMsg As String) As Boolean
        Try
            Dim cmd As New SqlCommand("_spKartrisPromotionParts_Add", sqlConn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Transaction = savePoint
            For Each row As DataRow In tblParts.Rows
                cmd.Parameters.AddWithValue("@PROM_ID", CInt(row("PROM_ID")))
                cmd.Parameters.AddWithValue("@PP_PartNo", CChar(row("PP_PartNo")))
                cmd.Parameters.AddWithValue("@PP_ItemType", CChar(row("PP_ItemType")))
                cmd.Parameters.AddWithValue("@PP_ItemID", CLng(row("PP_ItemID")))
                cmd.Parameters.AddWithValue("@PP_Type", CChar(row("PP_Type")))
                cmd.Parameters.AddWithValue("@PP_Value", CDbl(row("PP_Value")))
                cmd.ExecuteNonQuery()
                cmd.Parameters.Clear()
            Next
            Return True
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
        End Try

        Return False
    End Function
End Class
