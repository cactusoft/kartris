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
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports SiteMapHelper

''' <summary>
''' Used in the ProductView.ascx/Promotions.aspx to view:
''' 1. The available promotions under that product "ProductView.ascx"
''' OR
''' 2. The whole available promotions in the WebSite "Promotions.aspx"
''' </summary>
''' <remarks></remarks>
Partial Class ProductPromotions
    Inherits System.Web.UI.UserControl

    Private _ProductID As Integer = -1
    Private _LanguageID As Short

    Private _PageOwner As String

    Private c_strImageID As String = Nothing
    Private c_strItemType As String = Nothing

    '' Gets the Promotions of the Product.
    Private c_tblPromotions As DataTable

    Public WriteOnly Property PageOwner() As String
        Set(ByVal value As String)
            _PageOwner = value
        End Set
    End Property

    ''' <summary>
    ''' Loads the Promotions that are related to the current Product.
    ''' </summary>
    ''' <param name="pProductID"></param>
    ''' <param name="pLanguageID"></param>
    ''' <remarks>By Mohammad</remarks>
    ''' 
    Public Sub LoadProductPromotions(ByVal pProductID As Integer, ByVal pLanguageID As Short)

        _ProductID = pProductID
        _LanguageID = pLanguageID

        Dim intCouponPromotionID As Integer = 0
        Dim strCouponCode As String = Session("CouponCode")

        If Not String.IsNullOrEmpty(strCouponCode) Then
            Dim strCouponType As String = ""
            Dim strCouponError As String = ""
            Dim numCouponValue As Double

            Dim objCouponBasket As New kartris.Basket
            Call BasketBLL.GetCouponDiscount(objCouponBasket, strCouponCode, strCouponError, strCouponType, numCouponValue)
            If strCouponType = "t" Then
                intCouponPromotionID = CInt(numCouponValue)
            End If
            objCouponBasket = Nothing
        End If

        '' Gets the Product's Promotions.
        c_tblPromotions = PromotionsBLL.GetPromotionsByProductID(_ProductID, _LanguageID, intCouponPromotionID)

        If _PageOwner = "Promotions.aspx" Then
            phdSubHeading.Visible = False
        End If
        If c_tblPromotions.Rows.Count = 0 Then
            pnlPromotions.Visible = False
            Exit Sub
        Else : phdNoResults.Visible = False
        End If

        '' Collects the parts of each Promotion.
        ShowPromotions()

    End Sub

    ''' <summary>
    ''' Loads all the available Promotions.
    ''' </summary>
    ''' <param name="pLanguageID"></param>
    ''' <remarks></remarks>
    Public Sub LoadAllPromotions(ByVal pLanguageID As Short)

        _LanguageID = pLanguageID

        Dim intCouponPromotionID As Integer = 0
        Dim strCouponCode As String = Session("CouponCode")

        If Not String.IsNullOrEmpty(strCouponCode) Then
            Dim strCouponType As String = ""
            Dim strCouponError As String = ""
            Dim numCouponValue As Double

            Dim objCouponBasket As New kartris.Basket
            Call BasketBLL.GetCouponDiscount(objCouponBasket, strCouponCode, strCouponError, strCouponType, numCouponValue)
            If strCouponType = "t" Then
                intCouponPromotionID = CInt(numCouponValue)
            End If
            objCouponBasket = Nothing
        End If

        '' Gets the available Promotions.
        c_tblPromotions = PromotionsBLL.GetAllPromotions(_LanguageID, intCouponPromotionID)

        If _PageOwner = "Promotions.aspx" Then
            phdSubHeading.Visible = False
        End If
        If c_tblPromotions.Rows.Count = 0 Then

            phdNoResults.Visible = True
            Exit Sub
        Else : phdNoResults.Visible = False
        End If


        '' Collects the parts of each Promotion.
        ShowPromotions()

    End Sub


    Private Sub ShowPromotions()

        '' Array to hold the Promotions' IDs
        Dim arrPromotionIDs As String() = New String() {}
        '' Array to hold the Promotions' Texts
        Dim arrPromotionText As String() = New String() {}

        Dim numPROM_ID As Integer = 0

        Dim numNoOfPromotions As Integer = 0
        Dim blnPromReadAlready As Boolean = False

        For Each drwPromotions As DataRow In c_tblPromotions.Rows

            blnPromReadAlready = False

            Try
                For i As Integer = 0 To UBound(arrPromotionIDs)
                    If arrPromotionIDs(i) = CStr(drwPromotions("PROM_ID")) Then
                        blnPromReadAlready = True
                        Exit For
                    End If
                Next

                If blnPromReadAlready = True Then Continue For

                If numPROM_ID <> CInt(drwPromotions("PROM_ID")) Then
                    numPROM_ID = CInt(drwPromotions("PROM_ID"))
                    ReDim Preserve arrPromotionIDs(arrPromotionIDs.Length + 1)
                    ReDim Preserve arrPromotionText(arrPromotionText.Length + 1)

                    arrPromotionIDs(numNoOfPromotions) = CStr(numPROM_ID)
                    arrPromotionText(numNoOfPromotions) = GetPromotionText(numPROM_ID)
                    numNoOfPromotions += 1
                End If
            Catch ex As Exception
            End Try
        Next

        Dim tblPromotionsSummary As New DataTable()
        tblPromotionsSummary.Columns.Add("PROM_ID", Type.GetType("System.Int32"))
        tblPromotionsSummary.Columns.Add("PROM_TEXT", Type.GetType("System.String"))
        tblPromotionsSummary.Columns.Add("PROM_Name", Type.GetType("System.String"))

        For i = 0 To numNoOfPromotions - 1
            Dim drwTemp As DataRow

            drwTemp = tblPromotionsSummary.NewRow()
            drwTemp.Item("PROM_ID") = arrPromotionIDs(i)
            drwTemp.Item("PROM_TEXT") = arrPromotionText(i)
            drwTemp.Item("PROM_Name") = GetPromotionName(CInt(arrPromotionIDs(i)))

            If Not LanguageElementsBLL.GetElementValue(Session("LANG"), _
                    LANG_ELEM_TABLE_TYPE.Promotions, LANG_ELEM_FIELD_NAME.Name, CInt(arrPromotionIDs(i))) Is Nothing Then
                tblPromotionsSummary.Rows.Add(drwTemp)
            End If

        Next

        If tblPromotionsSummary.Rows.Count = 0 Then
            phdNoResults.Visible = True
            Exit Sub
        Else : phdNoResults.Visible = False
        End If

        rptProductPromotion.DataSource = tblPromotionsSummary.DefaultView
        rptProductPromotion.DataBind()
    End Sub
    Private Function GetPromotionName(ByVal intPromotionID As Integer) As String
        Dim strPromotionName As String = PromotionsBLL.GetPromotionName(intPromotionID, Session("LANG"))
        If String.IsNullOrEmpty(strPromotionName) Then Return ""
        Return strPromotionName
    End Function
    Private Function GetPromotionText(ByVal intPromotionID As Integer) As String

        Dim tblPromotionParts As New DataTable
        tblPromotionParts = PromotionsBLL._GetPartsByPromotion(intPromotionID, Session("LANG"))

        Dim sbdPromotionText As New StringBuilder("")
        Dim intTextCounter As Integer = 0

        For Each drwPromoParts As DataRow In tblPromotionParts.Rows

            Dim strText As String = drwPromoParts("PS_Text")
            Dim strStringID As String = drwPromoParts("PS_ID")
            Dim strValue As String = CkartrisDisplayFunctions.FixDecimal((drwPromoParts("PP_Value")))
            Dim strItemID As String = FixNullFromDB(drwPromoParts("PP_ItemID"))
            Dim strItemName As String = ""
            Dim strItemLink As String = ""

            If strText.Contains("[X]") Then
                If strText.Contains("[£]") Then
                    strText = strText.Replace("[X]", CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), CurrenciesBLL.ConvertCurrency(Session("CUR_ID"), strValue)))
                Else
                    strText = strText.Replace("[X]", strValue)
                End If
            End If

            If strText.Contains("[C]") AndAlso strItemID <> "" Then
                strItemName = Server.HtmlEncode(CategoriesBLL.GetNameByCategoryID(CInt(strItemID), Session("LANG")))
                strItemLink = " <a href='" & CreateURL(SiteMapHelper.Page.CanonicalCategory, strItemID) & "'>" & strItemName & "</a>"
                strText = strText.Replace("[C]", strItemLink)
            End If

            If strText.Contains("[P]") AndAlso strItemID <> "" Then
                strItemName = Server.HtmlEncode(ProductsBLL.GetNameByProductID(CInt(strItemID), Session("LANG")))
                strItemLink = " <a href='" & CreateURL(SiteMapHelper.Page.CanonicalProduct, strItemID) & "'>" & strItemName & "</a>"
                strText = strText.Replace("[P]", strItemLink)
            End If

            If strText.Contains("[V]") AndAlso strItemID <> "" Then
                Dim ProductID As Integer = VersionsBLL.GetProductID_s(CInt(strItemID))
                strItemName = Server.HtmlEncode(VersionsBLL._GetNameByVersionID(CInt(strItemID), Session("LANG")))
                strItemLink = " <a href='" & CreateURL(SiteMapHelper.Page.CanonicalProduct, ProductID) & "'>" & _
                ProductsBLL.GetNameByProductID(ProductID, Session("LANG")) & " (" & strItemName & ")</a>"
                strText = strText.Replace("[V]", strItemLink)
            End If

            If strText.Contains("[£]") Then
                strText = strText.Replace("[£]", "")
            End If

            intTextCounter += 1
            If intTextCounter > 1 Then
                sbdPromotionText.Append(", ")
            End If
            sbdPromotionText.Append(strText)
        Next
        Return sbdPromotionText.ToString
    End Function

End Class
