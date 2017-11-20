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
Imports Microsoft.VisualBasic
Imports kartrisBasketDataTableAdapters
Imports System.Web.HttpContext
Imports KartSettingsManager
Imports kartrisBasketData
Imports CkartrisDataManipulation
Imports KartrisClasses
Imports SiteMapHelper
Imports MailChimp.Net.Models
Imports MailChimp.Net.Core

''' <summary>
''' Basket business logic layer
''' </summary>
''' <remarks></remarks>
Public Class BasketBLL

    ''' <summary>
    ''' Where the basket comes from. This can be a normal basket or something saved such as a wishlist etc.
    ''' </summary>
    ''' <remarks></remarks>
    Public Enum BASKET_PARENTS
        BASKET = 1
        SAVED_BASKET = 2
        WISH_LIST = 3
    End Enum

    ''' <summary>
    ''' Defines the usage purpose of this entity object
    ''' </summary>
    ''' <remarks></remarks>
    Public Enum VIEW_TYPE
        MAIN_BASKET = 1
        CHECKOUT_BASKET = 2
        MINI_BASKET = 3
    End Enum

    ''' <summary>
    ''' Basket Values Table Adapter
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Protected Shared ReadOnly Property _BasketValuesAdptr() As BasketValuesTblAdptr
        Get
            Return New BasketValuesTblAdptr
        End Get
    End Property

    ''' <summary>
    ''' Basket Options Table Adapter
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Protected Shared ReadOnly Property _BasketOptionsAdptr() As BasketOptionValuesTblAdptr
        Get
            Return New BasketOptionValuesTblAdptr
        End Get
    End Property

    ''' <summary>
    ''' Coupons Table Adapter
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Protected Shared ReadOnly Property _CouponsAdptr() As CouponsTblAdptr
        Get
            Return New CouponsTblAdptr
        End Get
    End Property

    ''' <summary>
    ''' Customers Table Adapter
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Protected Shared ReadOnly Property _CustomersAdptr() As CustomersTblAdptr
        Get
            Return New CustomersTblAdptr
        End Get
    End Property

    ''' <summary>
    ''' The precision to be used with rounding currency numbers. 
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks>in other words how many numbers after the decimal point (e.g. 1.123456 to a precision of 3 is 1.123)</remarks>
    Public Shared Function CurrencyRoundNumber() As Short
        Try
            Dim numCurrencyID As Integer = Current.Session("CUR_ID")
            Dim rowCurrencies() As DataRow = GetCurrenciesFromCache().Select("CUR_ID = " & numCurrencyID)
            Return CInt(rowCurrencies(0)("CUR_RoundNumbers"))
        Catch ex As Exception
            Return 2
        End Try
    End Function

    ''' <summary>
    ''' Calculate the values of the coupons
    ''' </summary>
    ''' <param name="strCouponCode"></param>
    ''' <param name="strCouponError"></param>
    ''' <param name="blnZeroTotalTaxRate"></param>
    ''' <remarks>This instanciates the CustomerDiscount and CouponDiscount BasketModifier but only initialises the CouponDiscount</remarks>
    Public Shared Sub CalculateCoupon(ByRef Basket As Kartris.Basket, ByVal strCouponCode As String, ByRef strCouponError As String, ByVal blnZeroTotalTaxRate As Boolean)
        Dim strCouponType As String = ""
        Dim numCouponValue As Double
        With Basket
            .CouponDiscount = New Kartris.BasketModifier
            .CustomerDiscount = New Kartris.BasketModifier       ' Possibly remove?

            Call GetCouponDiscount(Basket, strCouponCode, strCouponError, strCouponType, numCouponValue)

            .CouponDiscount.TaxRate = .TotalDiscountPriceTaxRate
            Select Case strCouponType.ToLower
                Case "p"
                    'Percentage coupons
                    .CouponDiscount.IncTax = -Math.Round((numCouponValue * .TotalDiscountPriceIncTax / 100), CurrencyRoundNumber)
                    .CouponDiscount.ExTax = -Math.Round((numCouponValue * .TotalDiscountPriceExTax / 100), CurrencyRoundNumber)

                Case "f"
                    'Fixed rate coupons
                    If numCouponValue > .TotalDiscountPriceExTax Then
                        .CouponDiscount.ExTax = -.TotalDiscountPriceExTax
                        .CouponDiscount.IncTax = -.TotalDiscountPriceIncTax
                    Else
                        Dim blnPricesExtax As Boolean = False

                        If Not blnZeroTotalTaxRate Then
                            If GetKartConfig("general.tax.pricesinctax") = "y" Then
                                .CouponDiscount.ExTax = -Math.Round(numCouponValue * (1 / (1 + .CouponDiscount.TaxRate)), CurrencyRoundNumber)
                                If .D_Tax = 1 Then
                                    .CouponDiscount.IncTax = -Math.Round(numCouponValue, CurrencyRoundNumber)
                                Else
                                    .CouponDiscount.IncTax = .CouponDiscount.ExTax
                                End If
                            Else
                                blnPricesExtax = True
                            End If
                        Else
                            blnPricesExtax = True
                        End If

                        If blnPricesExtax Then
                            .CouponDiscount.IncTax = -Math.Round(numCouponValue, CurrencyRoundNumber)
                            .CouponDiscount.ExTax = -Math.Round(numCouponValue / (1 + .CouponDiscount.TaxRate), CurrencyRoundNumber)
                        End If
                    End If

                Case Else
                    'Dodgy coupon - ignore
                    .CouponDiscount.IncTax = 0
                    .CouponDiscount.ExTax = 0
            End Select
        End With
    End Sub

    ''' <summary>
    ''' Get information about an existing discount coupon.
    ''' </summary>
    ''' <param name="strCouponCode">Coupon to get the information from</param>
    ''' <param name="strCouponError">Error data (return)</param>
    ''' <param name="strCouponType">Type such as percentage or fixed amount (return)</param>
    ''' <param name="numCouponValue">Value (return)</param>
    ''' <remarks></remarks>
    Public Shared Sub GetCouponDiscount(ByRef Basket As Kartris.Basket, ByVal strCouponCode As String, ByRef strCouponError As String,
                                        ByRef strCouponType As String, ByRef numCouponValue As Decimal)
        Dim tblCoupons As CouponsDataTable
        With Basket
            .SetCouponName("") : .SetCouponCode("")

            tblCoupons = _CouponsAdptr.GetCouponCode(strCouponCode)
            If tblCoupons.Rows.Count = 0 Then
                strCouponError = GetGlobalResourceObject("Basket", "ContentText_CouponDoesntExist")
            Else
                Dim drwCoupon As DataRow = tblCoupons.Rows(0)
                If drwCoupon("CP_Used") AndAlso Not (drwCoupon("CP_Reusable")) Then
                    strCouponError = GetGlobalResourceObject("Basket", "ContentText_CouponExpended")
                ElseIf CDate(drwCoupon("CP_StartDate")) > CkartrisDisplayFunctions.NowOffset Then
                    strCouponError = GetGlobalResourceObject("Basket", "ContentText_CouponNotYetValid")
                ElseIf CDate(drwCoupon("CP_EndDate")) < CkartrisDisplayFunctions.NowOffset OrElse Not (drwCoupon("CP_Enabled")) Then
                    strCouponError = GetGlobalResourceObject("Basket", "ContentText_CouponExpired")
                Else
                    numCouponValue = drwCoupon("CP_DiscountValue")
                    strCouponType = drwCoupon("CP_DiscountType")
                    If strCouponType.ToLower = "p" Then
                        .SetCouponName(drwCoupon("CP_CouponCode") & " - " & numCouponValue & "%")
                    ElseIf strCouponType.ToLower = "t" Then
                        numCouponValue = CInt(numCouponValue)
                        .SetCouponName(drwCoupon("CP_CouponCode") & " - " & PromotionsBLL.GetPromotionText(numCouponValue, True))
                    Else
                        .SetCouponName(drwCoupon("CP_CouponCode") & " - " & CurrenciesBLL.FormatCurrencyPrice(HttpContext.Current.Session("CUR_ID"), numCouponValue))
                    End If
                    .SetCouponCode(drwCoupon("CP_CouponCode"))
                End If
            End If
        End With
    End Sub

    ''' <summary>
    ''' Calculate the value of the customer discount
    ''' </summary>
    ''' <param name="numCustomerDiscount"></param>
    ''' <remarks></remarks>
    Public Overloads Shared Sub CalculateCustomerDiscount(ByRef Basket As Kartris.Basket, ByVal numCustomerDiscount As Double)
        With Basket
            .CustomerDiscount = New Kartris.BasketModifier
            .CustomerDiscount.TaxRate = .TotalDiscountPriceTaxRate
            .CustomerDiscount.IncTax = -Math.Round((.TotalDiscountPriceIncTax - (.SubTotalExTax + .SubTotalTaxAmount)) * (numCustomerDiscount / 100), CurrencyRoundNumber)
            .CustomerDiscount.ExTax = -Math.Round((.TotalDiscountPriceExTax - .SubTotalExTax) * (numCustomerDiscount / 100), CurrencyRoundNumber)

            If Not (.ApplyTax) Then
                .CustomerDiscount.IncTax = .CustomerDiscount.ExTax
            End If

            ' Remember the percentage that was applied.
            .CustomerDiscountPercentage = numCustomerDiscount
        End With

    End Sub

    ''' <summary>
    ''' Add a new item to a basket. This may be added to an existing row or create a new row. 
    ''' </summary>
    ''' <param name="pParentType">What type of basket is it (stored, wishlist etc.)</param>
    ''' <param name="pParentID">The basket ID (or wishlist ID etc. if the parent is not a basket)</param>
    ''' <param name="pVersionID">Product version ID to be added</param>
    ''' <param name="pQuantity">Quantity of product to be added</param>
    ''' <param name="pCustomText">Custom text if the product being added has custom text</param>
    ''' <param name="pOptionsValues">Options value if the product being added has an options list.</param>
    ''' <param name="numBasketValueID">The basket item from within the target basket that this product replaces. Only use for replacing, not for adding to existing</param>
    ''' <remarks></remarks>
    Public Shared Sub AddNewBasketValue(ByRef BasketItems As List(Of Kartris.BasketItem), ByVal pParentType As BASKET_PARENTS, ByVal pParentID As Integer, _
                                 ByVal pVersionID As Long, ByVal pQuantity As Single, _
                                 Optional ByVal pCustomText As String = Nothing, _
                                 Optional ByVal pOptionsValues As String = Nothing, Optional ByVal numBasketValueID As Integer = 0)

        Dim chrParentType As Char = ""
        Select Case pParentType
            Case BASKET_PARENTS.BASKET
                chrParentType = "b"
            Case BASKET_PARENTS.SAVED_BASKET
                chrParentType = "s"
            Case BASKET_PARENTS.WISH_LIST
                chrParentType = "w"
        End Select

        Dim numIdenticalBasketValueID As Long = -1

        If numBasketValueID > 0 Then
            DeleteBasketItems(numBasketValueID)
        Else
            '' check if item to be added already in basket
            Dim arrOptions As String() = {""}
            If Not pOptionsValues Is Nothing Then
                arrOptions = Split(pOptionsValues, ",")
            End If

            Dim cntOption As Integer, numFoundBasketValueID As Integer = 0
            For Each oBasketItem As Kartris.BasketItem In basketitems
                If oBasketItem.VersionID = pVersionID Then
                    Dim strOption As String = Replace(oBasketItem.OptionLink, "&strOptions=", "")
                    If strOption = "" OrElse strOption = "0" Then '' not a version options so exit
                        If oBasketItem.CustomText = pCustomText Then
                            numIdenticalBasketValueID = oBasketItem.ID : Exit For
                        End If
                    Else
                        cntOption = 0
                        Dim arrBasketOptions As String()
                        arrBasketOptions = Split(strOption, ",")
                        If UBound(arrOptions) = UBound(arrBasketOptions) Then     ''possible it match.. same number of options
                            For i = LBound(arrOptions) To UBound(arrOptions)
                                For j = LBound(arrBasketOptions) To UBound(arrBasketOptions)
                                    If arrOptions(i) = arrBasketOptions(j) Then
                                        cntOption = cntOption + 1
                                        Exit For
                                    End If
                                Next
                            Next
                            If arrOptions.Count = cntOption Then
                                numIdenticalBasketValueID = oBasketItem.ID
                                Exit For
                            End If
                        End If
                    End If
                End If
            Next

        End If

        If numIdenticalBasketValueID = -1 Then
            '' The Item is not in the basket, so it should be added.
            Dim numNewBasketValueID As Long = Nothing
            If _BasketValuesAdptr.Insert(chrParentType, pParentID, pVersionID, _
             pQuantity, pCustomText, CkartrisDisplayFunctions.NowOffset, Nothing, numNewBasketValueID) <> 1 Then Exit Sub

            If numBasketValueID > 0 Then
                Dim aBasketItemInfo() As String = Split(Current.Session("BasketItemInfo"), ";")
                Current.Session("BasketItemInfo") = numNewBasketValueID & ";" & pVersionID & ";" & pQuantity
            End If

            '' Adding the Item options as well (if any)
            If Not pOptionsValues Is Nothing Then
                Dim arrOptions As String() = New String() {""}
                arrOptions = Split(pOptionsValues, ",")
                If arrOptions.GetUpperBound(0) >= 0 Then
                    For i As Integer = 0 To arrOptions.GetUpperBound(0)
                        If Val(arrOptions(i)) <> 0 Then AddBasketOptionValues(numNewBasketValueID, CInt(arrOptions(i)))
                    Next
                End If
            End If
            HttpContext.Current.Trace.Warn("^^^^^^^^^^^^^^ Version does NOT exist")

        Else

            '' The Item already exist in the basket, so the quantity will be increased.
            AddQuantityToMyBasket(numIdenticalBasketValueID, pQuantity)
            HttpContext.Current.Trace.Warn("^^^^^^^^^^^^^^ Version exists")

        End If

        HttpContext.Current.Session("NewBasketItem") = 1

    End Sub

    ''' <summary>
    ''' Find a basket item within the given basket that matches the supplied product information
    ''' </summary>
    ''' <param name="pParentID">The basket ID (or wishlist ID etc. if the parent is not a basket)</param>
    ''' <param name="pVersionID">Product version ID to be added</param>
    ''' <param name="pOptionsValues">Options value if the product being added has an options list.</param>
    ''' <param name="strCustomText">Custom text if the product being added has custom text</param>
    ''' <returns></returns>
    ''' <remarks>Can be used to replace an existing entry of the same product in a given basket.</remarks>
    Public Shared Function GetIdenticalBasketValueID(ByVal pParentID As Integer, ByVal pVersionID As Long, ByVal pOptionsValues As String, Optional ByVal strCustomText As String = "") As Long
        Dim numLanguageID As Short = 1
        Dim tblBasketItems As New DataTable

        tblBasketItems = GetBasketItemsDatatable(pParentID, numLanguageID)

        Dim drwIdenticalVersion As DataRow()
        drwIdenticalVersion = tblBasketItems.Select("BV_VersionID=" & pVersionID & " AND isnull(BV_CustomText,'')='" & strCustomText & "'")

        Dim arrNewOptionValues As String() = New String() {}
        If Not pOptionsValues Is Nothing Then
            If pOptionsValues <> "" Then
                arrNewOptionValues = pOptionsValues.Split(",")
            End If
        End If

        If drwIdenticalVersion.Length = 0 Then
            HttpContext.Current.Trace.Warn("^^^^^^ version does NOT exist in my basket ")
            Return -1
        Else
            HttpContext.Current.Trace.Warn("^^^^^^ " & drwIdenticalVersion.GetUpperBound(0) & " Identical versions exist in my basket ")
            For i As Integer = 0 To drwIdenticalVersion.GetUpperBound(0)
                If CInt(drwIdenticalVersion(i)("NoOfOptions")) <> arrNewOptionValues.Length Then
                    Continue For
                Else
                    If CInt(drwIdenticalVersion(i)("NoOfOptions")) <> 0 Then
                        '' Read the options from database .. for the current BasketValueID
                        Dim strExistingOptionValues As String
                        strExistingOptionValues = GetMiniBasketOptions(CLng(drwIdenticalVersion(i)("BV_ID")))

                        Dim arrOldOptionValues As String() = New String() {""}
                        arrOldOptionValues = strExistingOptionValues.Split(",")

                        Dim numIdenticalOptionsCounter As Integer = 0
                        For iNew As Integer = 0 To arrNewOptionValues.GetUpperBound(0)
                            For iOld As Integer = 0 To arrOldOptionValues.GetUpperBound(0)
                                If arrNewOptionValues(iNew) = arrOldOptionValues(iOld) Then
                                    numIdenticalOptionsCounter += 1
                                    Exit For
                                End If
                            Next
                        Next

                        If numIdenticalOptionsCounter = arrNewOptionValues.Length Then
                            Return CLng(drwIdenticalVersion(i)("BV_ID"))
                        End If

                        HttpContext.Current.Trace.Warn( _
                          "^^^^^^ options identical found BV_ID=" & drwIdenticalVersion(i)("BV_ID"))
                    Else
                        Return CLng(drwIdenticalVersion(i)("BV_ID"))
                    End If
                End If
            Next
            Return -1
        End If
        Return -1
    End Function

    ''' <summary>
    ''' Add quantity to a given basket item. 
    ''' </summary>
    ''' <param name="pBasketValueID">Basket item ID</param>
    ''' <param name="pQuantityToAdd">Quantity to add</param>
    ''' <remarks>Basket item IDs are unique within the database so we do not need to know the basket as no two baskets will contain the same basket item IDs</remarks>
    Private Shared Sub AddQuantityToMyBasket(ByVal pBasketValueID As Long, ByVal pQuantityToAdd As String)
        _BasketValuesAdptr.AddQuantityToItem(pQuantityToAdd, pBasketValueID)
    End Sub

    ''' <summary>
    ''' Get all basket items for a given session. 
    ''' </summary>
    ''' <param name="pSessionID">Session ID</param>
    ''' <param name="pLanguageID">Language that is being used (used for retrieving product and shipping names etc.)</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetBasketItemsDatatable(ByVal pSessionID As Long, ByVal pLanguageID As Short) As DataTable
        Return _BasketValuesAdptr.GetBasketItems(pSessionID, pLanguageID)
    End Function

    Public Overloads Shared Function GetBasketItems() As List(Of Kartris.BasketItem)
        Dim numLanguageID As Integer = Current.Session("LANG")
        Dim numSessionID As Integer = Current.Session("SessionID")
        Return GetBasketItems(numSessionID, numLanguageID)
    End Function

    ''' <summary>
    ''' Return a list of basket items retrieved from database
    ''' </summary>
    ''' <param name="SessionId">The session ID that the basket is associated with</param>
    ''' <param name="LanguageId">Language that the text should be in.</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Overloads Shared Function GetBasketItems(ByVal SessionId As Long, ByVal LanguageId As String) As List(Of Kartris.BasketItem)
        GetBasketItems = New List(Of Kartris.BasketItem)        ' Initial value
        Dim objItem As Kartris.BasketItem
        Dim tblBasketValues As DataTable
        Dim numCurrencyID As Integer ', numLanguageId, numSessionId
        Dim BasketItems As New List(Of Kartris.BasketItem)

        Dim SESS_CurrencyID As Short
        If numCurrencyID > 0 Then
            SESS_CurrencyID = numCurrencyID
        Else
            SESS_CurrencyID = Current.Session("CUR_ID")
        End If

        'numLanguageID = Current.Session("LANG")
        'numSessionID = Current.Session("SessionID")

        ' Load datatable from database
        tblBasketValues = _BasketValuesAdptr.GetItems(LanguageId, SessionId)

        Try
            For Each drwBasketValues As DataRow In tblBasketValues.Rows
                objItem = New Kartris.BasketItem
                objItem.ProductID = drwBasketValues("ProductID")
                objItem.ProductType = drwBasketValues("ProductType")
                objItem.TaxRate1 = FixNullFromDB(drwBasketValues("TaxRate"))
                objItem.TaxRate2 = FixNullFromDB(drwBasketValues("TaxRate2"))
                objItem.TaxRateItem = FixNullFromDB(drwBasketValues("TaxRate"))
                objItem.Weight = FixNullFromDB(drwBasketValues("Weight"))
                objItem.RRP = FixNullFromDB(drwBasketValues("RRP"))
                objItem.ProductName = drwBasketValues("ProductName") & ""
                objItem.ID = drwBasketValues("BV_ID")
                objItem.VersionBaseID = drwBasketValues("V_ID")
                objItem.VersionID = drwBasketValues("BV_VersionID")
                objItem.VersionName = drwBasketValues("VersionName") & ""
                objItem.VersionCode = drwBasketValues("CodeNumber") & ""
                objItem.CodeNumber = drwBasketValues("CodeNumber") & ""
                objItem.Price = FixNullFromDB(drwBasketValues("Price"))
                objItem.Quantity = FixNullFromDB(drwBasketValues("Quantity"))
                objItem.StockQty = FixNullFromDB(drwBasketValues("V_Quantity"))
                objItem.QtyWarnLevel = FixNullFromDB(drwBasketValues("QtyWarnLevel"))
                objItem.DownloadType = drwBasketValues("V_DownloadType") & ""
                objItem.OptionPrice = Math.Round(CDbl(FixNullFromDB(drwBasketValues("OptionsPrice"))), CurrencyRoundNumber)
                objItem.CategoryIDs = GetCategoryIDs(objItem.ProductID)
                objItem.PromoQty = objItem.Quantity
                objItem.VersionType = FixNullFromDB(drwBasketValues("VersionType"))

                'Added v2.9010 - lets us exclude particular products
                'from the customer discount 
                objItem.ExcludeFromCustomerDiscount = CBool(ObjectConfigBLL.GetValue("K:product.excustomerdiscount", drwBasketValues("ProductID")))

                'We can tell if this is an combinations product
                If objItem.VersionType = "c" Then
                    objItem.HasCombinations = True
                    objItem.DownloadType = FixNullFromDB(drwBasketValues("BaseVersion_DownloadType"))

                    'Normally, combinations products will use the price derived from the base version
                    'and any options that are selected, just like a regular options product. However,
                    'by setting the usecombination object config setting for the product to 'on', you
                    'can specify pricing individually for each combination.
                    If ObjectConfigBLL.GetValue("K:product.usecombinationprice", objItem.ProductID) = "1" Then
                        objItem.Price = FixNullFromDB(drwBasketValues("CombinationPrice"))
                        objItem.Price = Math.Round(CDbl(CurrenciesBLL.ConvertCurrency(SESS_CurrencyID, objItem.Price)), CurrencyRoundNumber)
                        objItem.OptionPrice = Math.Round(0, CurrencyRoundNumber)
                    End If

                    'We determine whether stock tracking is on or not from the
                    'base version rather than the actual combination in the
                    'basket
                    If VersionsBLL.IsStockTrackingInBase(objItem.ProductID) Then
                        'Nowt
                    Else
                        objItem.QtyWarnLevel = 0
                    End If

                ElseIf objItem.ProductType = "o" Then
                    objItem.OptionLink = ""

                    'We don't stock track plain old versions; it doesn't really make sense
                    'since they're configurable items, and if stock tracking is needed you
                    'really need to track individual combinations rather than the base
                    'version
                    'objItem.QtyWarnLevel = 0
                End If

                objItem.OptionText = GetOptionText(LanguageId, objItem.ID, objItem.OptionLink)
                objItem.CustomText = drwBasketValues("CustomText") & ""
                    objItem.CustomType = drwBasketValues("V_CustomizationType") & ""
                    objItem.CustomDesc = drwBasketValues("V_CustomizationDesc") & ""
                    objItem.CustomCost = Math.Round(CDbl(CurrenciesBLL.ConvertCurrency(SESS_CurrencyID, FixNullFromDB(drwBasketValues("V_CustomizationCost")))), CurrencyRoundNumber)
                    objItem.Price = Math.Round(CDbl(CurrenciesBLL.ConvertCurrency(SESS_CurrencyID, objItem.Price)), CurrencyRoundNumber)
                    objItem.TableText = ""

                    'Handle the price differently if basket item is from a custom product
                    Dim strCustomControlName As String = ObjectConfigBLL.GetValue("K:product.customcontrolname", objItem.ProductID)
                    If Not String.IsNullOrEmpty(strCustomControlName) Then
                        Try
                            Dim strParameterValues As String = FixNullFromDB(drwBasketValues("CustomText"))
                            'Split the custom text field
                            Dim arrParameters As String() = Split(strParameterValues, "|||")

                            ' arrParameters(0) contains the comma separated list of the custom control's parameters values
                            ' we don't use this value when loading the basket, this is only needed when validating the price in the checkout

                            ' arrParameters(1) contains the custom description of the item
                            If Not String.IsNullOrEmpty(arrParameters(1)) Then
                                objItem.VersionName = arrParameters(1)
                            End If

                            ' arrParameters(2) contains the custom price
                            objItem.Price = arrParameters(2)

                            'just set the option price to 0 just to be safe
                            objItem.OptionPrice = Math.Round(0, CurrencyRoundNumber)
                        Catch ex As Exception
                            'Failed to retrieve custom price, ignore this basket item
                            objItem.Quantity = 0
                        End Try

                    End If

                    'there must be something wrong if quantity is 0 so don't add this item to the basketitems array
                    If objItem.Quantity > 0 Then BasketItems.Add(objItem)
                Next
            Catch ex As Exception
                SqlConnection.ClearPool(_BasketValuesAdptr.Connection)
            CkartrisFormatErrors.LogError("BasketBLL.GetBasketItems - " & ex.Message)
        End Try

        Return BasketItems
    End Function

    ''' <summary>
    ''' Get a list of product options that are inside a basket
    ''' </summary>
    ''' <param name="pBasketValueID">Basket row to get options from</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetMiniBasketOptions(ByVal pBasketValueID As Long) As String
        Dim tblBasketOptions As New DataTable
        tblBasketOptions = _BasketOptionsAdptr.GetBasketOptionsByBasketValueID(pBasketValueID)

        Dim strBasketOptions As String = Nothing
        For Each drwOptions As DataRow In tblBasketOptions.Rows
            strBasketOptions += CStr(drwOptions("BSKTOPT_OptionID")) + ","
        Next
        If Not strBasketOptions Is Nothing Then strBasketOptions = strBasketOptions.TrimEnd(",")

        Return strBasketOptions
    End Function

    ''' <summary>
    ''' Add a product option to a basket
    ''' </summary>
    ''' <param name="pBasketValueID">Basket row to add option to</param>
    ''' <param name="pOptionID">Option to add</param>
    ''' <remarks></remarks>
    Private Shared Sub AddBasketOptionValues(ByVal pBasketValueID As Long, ByVal pOptionID As Integer)
        _BasketOptionsAdptr.Insert(pBasketValueID, pOptionID)
    End Sub

    ''' <summary>
    ''' Delete all items in a basket 
    ''' </summary>
    ''' <remarks></remarks>
    Public Overloads Shared Sub DeleteBasket()
        DeleteBasket(Current.Session("SessionID"))
    End Sub

    ''' <summary>
    ''' Delete all items in a basket
    ''' </summary>
    ''' <param name="numParentID">Reference to the basket parent (same for entire basket)</param>
    ''' <remarks></remarks>
    Public Overloads Shared Sub DeleteBasket(ByVal numParentID As Long)
        _BasketValuesAdptr.DeleteBasketItems(1, numParentID)
    End Sub

    ''' <summary>
    ''' Delete a single basket item
    ''' </summary>
    ''' <param name="numBasketID">reference to the item in the basket we wish to delete</param>
    ''' <remarks></remarks>
    Public Shared Sub DeleteBasketItems(ByVal numBasketID As Long)
        _BasketValuesAdptr.DeleteBasketItems(2, numBasketID)
    End Sub

    ''' <summary>
    ''' Replace the quantity for a single row in the basket
    ''' </summary>
    ''' <param name="intBasketID">Basket row to affect (BasketValueID)</param>
    ''' <param name="numQuantity">Quantity that it should be updated to.</param>
    ''' <remarks></remarks>
    Public Shared Sub UpdateQuantity(ByVal intBasketID As Integer, ByVal numQuantity As Single)
        If numQuantity > 0 Then
            _BasketValuesAdptr.UpdateQuantity(intBasketID, numQuantity)
        End If
    End Sub

    ''' <summary>
    ''' Get the customer percentage discount
    ''' </summary>
    ''' <param name="numCustomerID"></param>
    ''' <returns></returns>
    ''' <remarks>how much discount we give to the given customer as a percentage</remarks>
    Public Shared Function GetCustomerDiscount(ByVal numCustomerID As Integer) As Double
        Dim tblCustomers As CustomersDataTable
        Dim numDiscount As Double = 0

        tblCustomers = _CustomersAdptr.GetCustomerDiscount(numCustomerID)
        If tblCustomers.Rows.Count > 0 Then
            numDiscount = tblCustomers.Rows(0).Item("Discount")
        End If

        Return numDiscount
    End Function

    ''' <summary>
    ''' Get the price for the given customer for a product version.
    ''' </summary>
    ''' <param name="intCustomerID">Customer ID</param>
    ''' <param name="numVersionID">Product Version ID</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetCustomerGroupPriceForVersion(ByVal intCustomerID As Integer, ByVal numVersionID As Long) As Double
        Dim tblCustomers As CustomersDataTable
        Dim numPrice As Double = 0

        tblCustomers = _CustomersAdptr.GetCustomerGroupPrice(intCustomerID, numVersionID)
        If tblCustomers.Rows.Count > 0 Then
            numPrice = tblCustomers.Rows(0).Item("CGP_Price")
        End If

        Return numPrice

    End Function

    ''' <summary>
    ''' Get the quantity discount for this product version
    ''' </summary>
    ''' <param name="numVersionID">Product version we want to get discount for</param>
    ''' <param name="numQuantity">Quantity being purchased</param>
    ''' <returns></returns>
    ''' <remarks>Some versions have a discount (e.g. purchase more than 100 and price is reduced 25%). Retrieve this discount here.</remarks>
    Public Shared Function GetQuantityDiscount(ByVal numVersionID As Long, ByVal numQuantity As Double) As Double
        Dim tblCustomers As CustomersDataTable
        Dim numDiscount As Double = 0

        tblCustomers = _CustomersAdptr.GetQtyDiscount(numVersionID, numQuantity)
        If tblCustomers.Rows.Count > 0 Then
            numDiscount = tblCustomers.Rows(0).Item("QD_Price")
        End If

        Return numDiscount
    End Function

    ''' <summary>
    ''' Get customer information
    ''' </summary>
    ''' <param name="numUserID">Customer ID</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetCustomerData(ByVal numUserID As Long) As DataTable
        Dim tblCustomers As New DataTable
        tblCustomers = _CustomersAdptr.GetCustomer(numUserID, "", "")
        Return tblCustomers
    End Function

    ''' <summary>
    ''' Save custom text against an item in the basket. 
    ''' </summary>
    ''' <param name="numBasketItemID">The basket item (row) that we wish to save the text against</param>
    ''' <param name="strCustomText">The custom text to be saved</param>
    ''' <remarks></remarks>
    Public Shared Sub SaveCustomText(ByVal numBasketItemID As Long, ByVal strCustomText As String)
        _BasketValuesAdptr.SaveCustomText(numBasketItemID, strCustomText)
    End Sub

    ''' <summary>
    ''' Save the basket. This takes an active basket and stores it for retrieval at a later date. This is a customer triggered event
    ''' </summary>
    ''' <param name="numCustomerID">The customer that this basket is stored for</param>
    ''' <param name="strBasketName">Name of basket (to help customer remember it later)</param>
    ''' <param name="numBasketID">Basket identifier</param>
    ''' <remarks>Can only be used for a logged in customer (or else there is no customer ID)</remarks>
    Public Shared Sub SaveBasket(ByVal numCustomerID As Long, ByVal strBasketName As String, ByVal numBasketID As Long)
        _CustomersAdptr.SaveBasket(numCustomerID, strBasketName, numBasketID, CkartrisDisplayFunctions.NowOffset)
    End Sub

    ''' <summary>
    ''' Retrieve a basket that was previously saved using OldBasketBLL.SaveBasket
    ''' </summary>
    ''' <param name="numUserID">User or Customer ID</param>
    ''' <param name="PageIndex">Page to display (paginated output)</param>
    ''' <param name="PageSize">Number of rows to show per page (paginated output)</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetSavedBasket(ByVal numUserID As Long, Optional ByVal PageIndex As Integer = -1, Optional ByVal PageSize As Integer = -1) As DataTable
        Dim tblSavedBaskets As New DataTable
        tblSavedBaskets = _CustomersAdptr.GetSavedBasket(1, numUserID, PageIndex, PageIndex + PageSize - 1)
        Return tblSavedBaskets
    End Function

    ''' <summary>
    ''' Gets the total value of all saved baskets for a single customer. 
    ''' </summary>
    ''' <param name="numUserID">The customer we want to retrieve the total for.</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetSavedBasketTotal(ByVal numUserID As Long) As Integer
        Dim tblSavedBaskets As New DataTable
        Dim numTotalBasket As Integer = 0

        tblSavedBaskets = _CustomersAdptr.GetSavedBasket(0, numUserID, 0, 0)
        If tblSavedBaskets.Rows.Count > 0 Then
            numTotalBasket = tblSavedBaskets.Rows(0).Item("TotalRec")
        End If

        tblSavedBaskets.Dispose()
        Return numTotalBasket
    End Function

    ''' <summary>
    ''' Delete a single saved basket from the database
    ''' </summary>
    ''' <param name="numBasketID">The basket to delete</param>
    ''' <remarks></remarks>
    Public Shared Sub DeleteSavedBasket(ByVal numBasketID As Long)
        _CustomersAdptr.DeleteSavedBasket(numBasketID)
    End Sub

    ''' <summary>
    ''' Load a saved basket into an active basket
    ''' </summary>
    ''' <param name="numBasketSavedID">The saved basket ID to load</param>
    ''' <param name="numBasketID">The target active basket to put the items into</param>
    ''' <remarks></remarks>
    Public Shared Sub LoadSavedBasket(ByVal numBasketSavedID As Long, ByVal numBasketID As Long)
        _CustomersAdptr.LoadSavedBasket(numBasketSavedID, numBasketID, CkartrisDisplayFunctions.NowOffset)
    End Sub

    ''' <summary>
    ''' Load a saved AUTOSAVE basket
    ''' </summary>
    ''' <param name="numCustomerID">The saved basket ID to load</param>
    ''' <param name="numBasketID">The target active basket to put the items into</param>
    ''' <remarks></remarks>
    Public Shared Sub LoadAutosaveBasket(ByVal numCustomerID As Long, ByVal numBasketID As Long)
        _CustomersAdptr.LoadAutosaveBasket(numCustomerID, numBasketID, CkartrisDisplayFunctions.NowOffset)
    End Sub

    ''' <summary>
    ''' Save a basket to a wishlist 
    ''' </summary>
    ''' <param name="numWishlistsID">The wishlist to be updated. Leave as zero to create a new wishlist</param>
    ''' <param name="numBasketID">The basket that contains the items that should be put in the wishlist. Ignored if updating an existing wishlist</param>
    ''' <param name="numUserID">Customer or User ID</param>
    ''' <param name="strName">Name of wishlist (used to help customer identify wishlist)</param>
    ''' <param name="strPublicPassword">Public password to allow other users to open wishlist</param>
    ''' <param name="strMessage">Text message to users other than the customer that may open wishlist. For example, to purchase items from the wishlist for the customer.</param>
    ''' <remarks>If the wishlist ID is zero a new wishlist will be generated. If a wishlist ID is supplied the name and comments will be replaced, but not the actual basket rows</remarks>
    Public Shared Sub SaveWishLists(ByVal numWishlistsID As Long, ByVal numBasketID As Long, ByVal numUserID As Integer, ByVal strName As String, ByVal strPublicPassword As String, ByVal strMessage As String)
        _CustomersAdptr.SaveWishList(numWishlistsID, numBasketID, numUserID, strName, strPublicPassword, strMessage, CkartrisDisplayFunctions.NowOffset)
    End Sub

    ''' <summary>
    ''' Return the total value for all items in all wishlists for a given customer.
    ''' </summary>
    ''' <param name="numUserId">Customer that we want to calculate for.</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetWishListTotal(ByVal numUserId As Long) As Integer
        Dim tblWishList As New DataTable
        Dim numTotalWishList As Integer = 0

        tblWishList = _CustomersAdptr.GetWishList(0, numUserId, 0, 0, 0, "", "", 0)
        If tblWishList.Rows.Count > 0 Then
            numTotalWishList = tblWishList.Rows(0).Item("TotalRec")
        End If

        tblWishList.Dispose()
        Return numTotalWishList
    End Function

    ''' <summary>
    ''' Get a list of wishlists for a given customer.
    ''' </summary>
    ''' <param name="numUserId">The customer we want to find wishlists for</param>
    ''' <param name="PageIndex">Page to display (paginated output)</param>
    ''' <param name="PageSize">Number of rows to show per page (paginated output)</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetWishLists(ByVal numUserId As Long, Optional ByVal PageIndex As Integer = -1, Optional ByVal PageSize As Integer = -1) As DataTable
        Dim tblWishList As New DataTable
        tblWishList = _CustomersAdptr.GetWishList(1, numUserId, PageIndex, PageIndex + PageSize - 1, 0, "", "", 0)
        Return tblWishList
    End Function

    ''' <summary>
    ''' Get a single wishlist
    ''' </summary>
    ''' <param name="numWishlistID">Identifier for wishlist we wish to retrieve</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetWishListByID(ByVal numWishlistID As Long) As DataTable
        Dim tblWishList As DataTable
        tblWishList = _CustomersAdptr.GetWishList(-1, 0, 0, 0, numWishlistID, "", "", 0)
        Return tblWishList
    End Function

    ''' <summary>
    ''' Get a single wishlist 
    ''' </summary>
    ''' <param name="numCustomerID">Identifier for customer that created wishlist</param>
    ''' <param name="numWishlistID">Identifier for wishlist.</param>
    ''' <returns></returns>
    ''' <remarks>Consider using GetWishListById for simplicity and speedier execution</remarks>
    Public Shared Function GetCustomerWishList(ByVal numCustomerID As Long, ByVal numWishlistID As Long) As DataTable
        Dim tblWishList As New DataTable
        tblWishList = _CustomersAdptr.GetWishList(2, numCustomerID, 0, 0, numWishlistID, "", "", 0)
        Return tblWishList
    End Function

    ''' <summary>
    ''' Retrieve wishlist using login details
    ''' </summary>
    ''' <param name="strEmail">Email account that wishlist is attached to</param>
    ''' <param name="strPassword">Password required to access wishlist.</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetWishListLogin(ByVal strEmail As String, ByVal strPassword As String) As DataTable
        Dim tblWishList As New DataTable
        tblWishList = _CustomersAdptr.GetWishList(3, 0, 0, 0, 0, strEmail, strPassword, 0)
        Return tblWishList
    End Function

    ''' <summary>
    ''' Get the remaining items from a wishlist
    ''' </summary>
    ''' <param name="numCustomerID">The customer that owns the wishlist</param>
    ''' <param name="numWishlistID">The required wishlist</param>
    ''' <param name="numLanguage">Display language</param>
    ''' <returns>Returns items that have not been purchased from wishlist. Does not return items that have already been purchased</returns>
    ''' <remarks></remarks>
    Public Shared Function GetRequiredWishlist(ByVal numCustomerID As Long, ByVal numWishlistID As Long, ByVal numLanguage As Short) As DataTable
        Dim tblWishList As New DataTable
        tblWishList = _CustomersAdptr.GetWishList(4, numCustomerID, 0, 0, numWishlistID, "", "", numLanguage)
        Return tblWishList
    End Function

    ''' <summary>
    ''' Delete a wishlist
    ''' </summary>
    ''' <param name="numWishListsID">The wishlist to be deleted.</param>
    ''' <remarks></remarks>
    Public Shared Sub DeleteWishLists(ByVal numWishListsID As Long)
        _CustomersAdptr.DeleteWishList(numWishListsID)
    End Sub

    ''' <summary>
    ''' Transfer a stored wishlist into an active basket
    ''' </summary>
    ''' <param name="numWishlistsID">The wishlist to be loaded</param>
    ''' <param name="numBasketID">The basket to transfer the wishlist into</param>
    ''' <remarks></remarks>
    Public Shared Sub LoadWishlists(ByVal numWishlistsID As Long, ByVal numBasketID As Long)
        _CustomersAdptr.LoadWishlist(numWishlistsID, numBasketID, CkartrisDisplayFunctions.NowOffset)
    End Sub

    ''' <summary>
    ''' Calculate the handling charge for the order inside the current basket. 
    ''' </summary>
    ''' <param name="numShippingCountryID">Country that the items will be shipped to.</param>
    ''' <remarks></remarks>
    Public Shared Sub CalculateOrderHandlingCharge(ByRef Basket As Kartris.Basket, ByVal numShippingCountryID As Integer)
        Dim numOrderHandlingPriceValue As Double, numOrderHandlingTaxBand1 As Double = 0, numOrderHandlingTaxBand2 As Double = 0

        If numShippingCountryID = 0 Then Exit Sub

        numOrderHandlingPriceValue = KartSettingsManager.GetKartConfig("frontend.checkout.orderhandlingcharge")

        Dim SESS_CurrencyID As Short

        With Basket


            If .CurrencyID > 0 Then
                SESS_CurrencyID = .CurrencyID
            Else
                SESS_CurrencyID = Current.Session("CUR_ID")
            End If

            If SESS_CurrencyID <> CurrenciesBLL.GetDefaultCurrency Then numOrderHandlingPriceValue = CurrenciesBLL.ConvertCurrency(SESS_CurrencyID, numOrderHandlingPriceValue)

            Dim DestinationCountry As Country = Country.Get(numShippingCountryID)

            Try
                numOrderHandlingTaxBand1 = KartSettingsManager.GetKartConfig("frontend.checkout.orderhandlingchargetaxband")
                numOrderHandlingTaxBand2 = KartSettingsManager.GetKartConfig("frontend.checkout.orderhandlingchargetaxband2")
            Catch ex As Exception
            End Try

            If ConfigurationManager.AppSettings("TaxRegime").ToLower = "us" Or ConfigurationManager.AppSettings("TaxRegime").ToLower = "simple" Then
                .OrderHandlingPrice.TaxRate = DestinationCountry.ComputedTaxRate
                .D_Tax = DestinationCountry.ComputedTaxRate
            Else
                If DestinationCountry.D_Tax Then .D_Tax = 1 Else .D_Tax = 0

                Try
                    If Current.Session("blnEUVATValidated") IsNot Nothing Then
                        If CBool(Current.Session("blnEUVATValidated")) Then
                            DestinationCountry.D_Tax = False
                            .D_Tax = 0
                        End If
                    End If
                Catch ex As Exception

                End Try

                .OrderHandlingPrice.TaxRate = TaxRegime.CalculateTaxRate(TaxBLL.GetTaxRate(numOrderHandlingTaxBand1), TaxBLL.GetTaxRate(numOrderHandlingTaxBand2), DestinationCountry.TaxRate1, DestinationCountry.TaxRate2, DestinationCountry.TaxExtra)

            End If



            If .PricesIncTax Then
                .OrderHandlingPrice.ExTax = Math.Round(numOrderHandlingPriceValue * (1 / (1 + .OrderHandlingPrice.TaxRate)), CurrencyRoundNumber)

                'If tax is off, then inc tax can be set to just the ex tax
                If DestinationCountry.D_Tax Then
                    'Set the inctax order handling values
                    .OrderHandlingPrice.IncTax = Math.Round(numOrderHandlingPriceValue, CurrencyRoundNumber)
                Else
                    .OrderHandlingPrice.IncTax = .OrderHandlingPrice.ExTax
                    .OrderHandlingPrice.TaxRate = 0
                End If
            Else
                'Set the extax order handling values
                .OrderHandlingPrice.ExTax = numOrderHandlingPriceValue

                'Tax rate for order handling
                'Modified to set order handling to zero if 
                'frontend.checkout.orderhandlingchargetaxband is 1 or 0
                '(should really be 1, as this is the likely db ID that
                'corresponds to a zero rate, but support zero too because
                'lots of people set it to that by mistake).
                If DestinationCountry.D_Tax And (numOrderHandlingTaxBand1 > 1) Then
                    .OrderHandlingPrice.IncTax = Math.Round(.OrderHandlingPrice.ExTax * (1 + .OrderHandlingPrice.TaxRate), CurrencyRoundNumber)
                Else
                    .OrderHandlingPrice.IncTax = numOrderHandlingPriceValue
                    .OrderHandlingPrice.TaxRate = 0
                End If
            End If
        End With
    End Sub

    ''' <summary>
    ''' Get a list of orders for the given customer
    ''' </summary>
    ''' <param name="numUserId">The customer to get the orders for</param>
    ''' <param name="PageIndex">The page number to get (paginated output)</param>
    ''' <param name="PageSize">The size of the page to return (paginated output)</param>
    ''' <returns>Complete and incomplete orders.</returns>
    ''' <remarks></remarks>
    Public Shared Function GetCustomerOrders(ByVal numUserId As Long, Optional ByVal PageIndex As Integer = -1, Optional ByVal PageSize As Integer = -1) As DataTable
        Dim tblCustomerOrders As New DataTable
        tblCustomerOrders = _CustomersAdptr.GetCustomerOrders(1, numUserId, PageIndex, PageIndex + PageSize - 1)
        Return tblCustomerOrders
    End Function


    ''' <summary>
    ''' Get total value of all orders for a given customer
    ''' </summary>
    ''' <param name="numUserId">The customer we want to totalise data for</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetCustomerOrdersTotal(ByVal numUserId As Long) As Integer
        Dim tblCustomerOrders As New DataTable
        Dim numTotalOrders As Integer = 0

        tblCustomerOrders = _CustomersAdptr.GetCustomerOrders(0, numUserId, 0, 0)
        If tblCustomerOrders.Rows.Count > 0 Then
            numTotalOrders = tblCustomerOrders.Rows(0).Item("TotalRec")
        End If

        tblCustomerOrders.Dispose()
        Return numTotalOrders
    End Function

    ''' <summary>
    ''' Get all of the details related to a single order.
    ''' </summary>
    ''' <param name="numOrderID">The order we want to get data for</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetCustomerOrderDetails(ByVal numOrderID As Integer) As DataTable
        Dim tblCustomerOrders As New DataTable
        tblCustomerOrders = _CustomersAdptr.GetOrderDetails(numOrderID)
        Return tblCustomerOrders
    End Function

    ''' <summary>
    ''' Get a list of all downloadable products that a particular customer has purchased and are available for download.
    ''' </summary>
    ''' <param name="numUserID">The customer that we want to get the orders for</param>
    ''' <returns>Does not return products where the download date has expired</returns>
    ''' <remarks></remarks>
    Public Shared Function GetDownloadableProducts(ByVal numUserID As Integer) As DataTable
        Dim tblDownloads As New DataTable
        Dim O_Shipped As Boolean = LCase(GetKartConfig("frontend.downloads.instant")) = "n"
        Dim intDaysAvailable As Integer = 0
        Try
            intDaysAvailable = CInt(LCase(GetKartConfig("frontend.downloads.daysavailable")))
        Catch ex As Exception
        End Try

        Dim datAvailableUpTo As DateTime
        If intDaysAvailable > 0 Then
            datAvailableUpTo = Today.AddDays(-intDaysAvailable)
        Else
            datAvailableUpTo = Today.AddYears(-100)
        End If
        tblDownloads = _CustomersAdptr.GetDownloadableProducts(numUserID, O_Shipped, datAvailableUpTo)
        Return tblDownloads
    End Function

    ''' <summary>
    ''' Return a single invoice
    ''' </summary>
    ''' <param name="numOrderID">The order reference number taken from the order table (non visible)</param>
    ''' <param name="numUserID">Reference to the selected customer</param>
    ''' <param name="numType">Defines what data should be returned. A value of 0 returns only summary and address data; any other value returns the row level detail</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetCustomerInvoice(ByVal numOrderID As Integer, ByVal numUserID As Integer, Optional ByVal numType As Integer = 0) As DataTable
        Dim tblInvoice As New DataTable
        tblInvoice = _CustomersAdptr.GetInvoice(numOrderID, numUserID, numType)
        Return tblInvoice
    End Function

    ''' <summary>
    ''' Generate a random string
    ''' </summary>
    ''' <param name="numLength"></param>
    ''' <returns></returns>
    ''' <remarks>used for password generation</remarks>
    Public Shared Function GetRandomString(ByVal numLength As Integer) As String
        Dim strRandomString As String
        Dim numRandomNumber As Integer

        Randomize()
        strRandomString = ""

        Do While Len(strRandomString) < numLength
            numRandomNumber = Int(Rnd(1) * 36) + 1
            If numRandomNumber < 11 Then
                'If it's less than 11 then we'll do a number
                strRandomString = strRandomString & Chr(numRandomNumber + 47)
            Else
                'Otherwise we'll do a letter; + 86 because 96 (min being 97, 'a') - 10 (the first 10 was for the number)
                strRandomString = strRandomString & Chr(numRandomNumber + 86)
            End If
        Loop

        'Zero and 'o' and '1' and 'I' are easily confused...
        'So we replace any of these with alternatives
        'To ensure best randomness, replace the numbers
        'with alternative letters and letters
        'with alternative numbers

        strRandomString = Replace(strRandomString, "0", "X")
        strRandomString = Replace(strRandomString, "1", "Y")
        strRandomString = Replace(strRandomString, "O", "4")
        strRandomString = Replace(strRandomString, "I", "9")

        Return strRandomString
    End Function

    ''' <summary>
    ''' Get all information related to a coupon.
    ''' </summary>
    ''' <param name="strCouponName">The coupon code.</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetCouponData(ByVal strCouponName As String) As DataTable
        Dim tblCoupon As New DataTable
        tblCoupon = _CouponsAdptr.GetCouponCode(strCouponName)
        Return tblCoupon
    End Function

    ''' <summary>
    ''' Get the type for a version customization
    ''' </summary>
    ''' <param name="numVersionID">The version to get customisation data for</param>
    ''' <returns>a single character (e.g. 't' = text)</returns>
    ''' <remarks>Customisation data is applied to the product in the version table. This data is not customer / order specific; this data is product version specific</remarks>
    Public Shared Function GetVersionCustomType(ByVal numVersionID As Long) As String
        Dim strCustomType As String = ""
        Dim tblCoupon As CustomersDataTable

        tblCoupon = _CustomersAdptr.GetCustomization(numVersionID)

        If tblCoupon.Rows.Count > 0 Then
            strCustomType = tblCoupon.Rows(0).Item("V_CustomizationType") & ""
        End If

        Return strCustomType
    End Function

    ''' <summary>
    ''' Get customisation data for a product version
    ''' </summary>
    ''' <param name="numVersionID">The version to get customisation data for</param>
    ''' <returns></returns>
    ''' <remarks>Customisation data is applied to the product in the version table. This data is not customer / order specific; this data is product version specific</remarks>
    Public Shared Function GetCustomization(ByVal numVersionID As Long) As DataTable
        Dim tblCustomization As DataTable
        tblCustomization = _CustomersAdptr.GetCustomization(numVersionID)
        Return tblCustomization
    End Function

    ''' <summary>
    ''' Get all Version IDs for the current basket.
    ''' </summary>
    ''' <returns>a comma delimited string.</returns>
    ''' <remarks></remarks>
    Private Shared Function GetBasketItemVersionIDs(ByRef BasketItems As List(Of Kartris.BasketItem)) As String
        Dim strIDs As String = ""
        For Each Item As Kartris.BasketItem In BasketItems
            strIDs = strIDs & Item.VersionID & ","
        Next
        If strIDs <> "" Then
            strIDs = Left(strIDs, Len(strIDs) - 1)
        End If
        Return strIDs
    End Function

    ''' <summary>
    ''' Get all product IDs for the current basket
    ''' </summary>
    ''' <returns>a comma delimited string</returns>
    ''' <remarks></remarks>
    Private Shared Function GetBasketItemProductIDs(ByRef BasketItems As List(Of Kartris.BasketItem)) As String
        Dim strIDs As String = ""
        For Each Item As Kartris.BasketItem In BasketItems
            strIDs = strIDs & Item.ProductID & ","
        Next
        strIDs = IIf(strIDs <> "", Left(strIDs, Len(strIDs) - 1), strIDs)
        Return strIDs
    End Function

    ''' <summary>
    ''' Get all category IDs in the current basket
    ''' </summary>
    ''' <returns>a comma delimited string</returns>
    ''' <remarks></remarks>
    Private Shared Function GetBasketItemCategoryIDs(ByRef BasketItems As List(Of Kartris.BasketItem)) As String
        Dim strIDs As String = ""
        For Each Item As Kartris.BasketItem In BasketItems
            strIDs = strIDs & Item.CategoryIDs & ","
        Next
        strIDs = IIf(strIDs <> "", Left(strIDs, Len(strIDs) - 1), strIDs)
        Return strIDs
    End Function

    ''' <summary>
    ''' Return the basket items that matches the given version ID
    ''' </summary>
    ''' <param name="numVersionID">The product version ID we are looking for</param>
    ''' <returns></returns>
    ''' <remarks>acts upon the current basket</remarks>
    Private Shared Function GetBasketItemByVersionID(ByRef BasketItems As List(Of Kartris.BasketItem), ByVal numVersionID As Integer) As Kartris.BasketItem
        GetBasketItemByVersionID = Nothing
        ' Removed blnReload logic as not used.
        For Each Item As Kartris.BasketItem In BasketItems
            ' Item found
            If Item.VersionID = numVersionID Then Return Item
        Next
    End Function

    ''' <summary>
    ''' Find the highest value of a given product within the current basket. 
    ''' </summary>
    ''' <param name="numProductID"></param>
    ''' <returns>finds highest value (including tax) from all versions of a single product in the basket</returns>
    ''' <remarks></remarks>
    Private Shared Function GetItemMaxProductValue(ByRef BasketItems As List(Of Kartris.BasketItem), ByVal numProductID As Integer) As Integer
        Dim objItem, tmpItem As New Kartris.BasketItem
        Dim index As Integer = -1

        ' Search through the items in the basket to find the product we are looking for
        For i As Integer = 0 To BasketItems.Count - 1
            objItem = BasketItems(i)
            If objItem.ProductID = numProductID And objItem.PromoQty > 0 Then
                index = IIf(index = -1, i, index)
                tmpItem = BasketItems(index)
                If objItem.IncTax > tmpItem.IncTax Then
                    index = i
                End If
            End If
        Next

        Return index
    End Function

    ''' <summary>
    ''' Find the ordinal position of the lowest value of a given product within the current basket. 
    ''' </summary>
    ''' <param name="numProductID">Product to search for</param>
    ''' <param name="strVersionIDArray">comma delimited string of versions that should be excluded from our search.</param>
    ''' <returns>finds lowest value (including tax) from all versions of a single product in the basket and returns its ordinal position within the collection</returns>
    ''' <remarks></remarks>
    Private Shared Function GetItemMinProductValue(ByRef BasketItems As List(Of Kartris.BasketItem), ByVal numProductID As Integer, Optional ByVal strVersionIDArray As String = "") As Integer
        Dim objItem, tmpItem As New Kartris.BasketItem
        Dim index As Integer = -1
        Dim arrVersionIDsToExclude As String() = Nothing


        If strVersionIDArray <> "" Then
            arrVersionIDsToExclude = Split(strVersionIDArray, ",")
        End If
        Dim blnSkipVersion As Boolean = False

        For i As Integer = 0 To BasketItems.Count - 1
            objItem = BasketItems(i)
            If arrVersionIDsToExclude IsNot Nothing Then
                blnSkipVersion = False
                For x As Integer = 0 To arrVersionIDsToExclude.Count - 1
                    If arrVersionIDsToExclude(x) = objItem.VersionID Then
                        blnSkipVersion = True
                        Continue For
                    End If
                Next
                If blnSkipVersion Then Continue For
            End If
            'If MinVersionID > 0 AndAlso MinVersionID = objItem.VersionID Then Continue For
            If objItem.ProductID = numProductID And objItem.PromoQty > 0 Then
                index = IIf(index = -1, i, index)
                tmpItem = BasketItems(index)
                If objItem.IncTax < tmpItem.IncTax Then
                    index = i
                End If
            End If
        Next

        Return index
    End Function

    ''' <summary>
    ''' Find the ordinal position of the highest value item in the basket that belongs to a given product category
    ''' </summary>
    ''' <param name="numProductID">Category that we are searching within (not Product ID strangely)</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Shared Function GetItemMaxCategoryValue(ByRef BasketItems As List(Of Kartris.BasketItem), ByVal numProductID As Integer) As Integer
        Dim objItem, tmpItem As New Kartris.BasketItem
        Dim index As Integer = -1

        For i As Integer = 0 To BasketItems.Count - 1
            objItem = BasketItems(i)
            If InStr(objItem.CategoryIDs, numProductID.ToString) > 0 Then
                index = IIf(index = -1, i, index)
                tmpItem = BasketItems(index)
                If objItem.IncTax > tmpItem.IncTax Then
                    index = i
                End If
            End If
        Next

        Return index
    End Function

    ''' <summary>
    ''' Find the ordinal position of the lowest value item in the basket that belongs to a given product category
    ''' </summary>
    ''' <param name="numProductID">The category to search within (not the product ID)</param>
    ''' <param name="strVersionIDArray">comma delimited string of product versions to exclude from this search</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Shared Function GetItemMinCategoryValue(ByRef BasketItems As List(Of Kartris.BasketItem), ByVal numProductID As Integer, Optional ByVal strVersionIDArray As String = "") As Integer
        Dim objItem, tmpItem As New Kartris.BasketItem
        Dim index As Integer = -1
        Dim arrVersionIDsToExclude As String() = Nothing

        If strVersionIDArray <> "" Then
            arrVersionIDsToExclude = Split(strVersionIDArray, ",")
        End If
        Dim blnSkipVersion As Boolean = False

        For i As Integer = 0 To BasketItems.Count - 1
            objItem = BasketItems(i)
            If arrVersionIDsToExclude IsNot Nothing Then
                blnSkipVersion = False
                For x As Integer = 0 To arrVersionIDsToExclude.Count - 1
                    If arrVersionIDsToExclude(x) = objItem.VersionID Then
                        blnSkipVersion = True
                        Continue For
                    End If
                Next
                If blnSkipVersion Then Continue For
            End If
            If InStr(objItem.CategoryIDs, numProductID.ToString) > 0 Then
                index = IIf(index = -1, i, index)
                tmpItem = BasketItems(index)
                If objItem.IncTax < tmpItem.IncTax Then
                    index = i
                End If
            End If
        Next

        Return index
    End Function

    ''' <summary>
    ''' Get all promotions
    ''' </summary>
    ''' <param name="numLanguageID">Applicable language</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetPromotions(ByVal numLanguageID As Integer) As DataTable
        Dim tblPromotions As New DataTable
        tblPromotions = _CustomersAdptr.GetPromotions(numLanguageID)
        Return tblPromotions
    End Function

    ''' <summary>
    ''' Get the option text for an item in the basket
    ''' </summary>
    ''' <param name="numLanguageID">Applicable language</param>
    ''' <param name="numBasketItemID">Basket item to search for</param>
    ''' <param name="strOptionLink">return parameter which has a comma delimited string of the option numbers</param>
    ''' <returns>All option texts seperated by HTML break symbols</returns>
    ''' <remarks></remarks>
    Public Shared Function GetOptionText(ByVal numLanguageID As Integer, ByVal numBasketItemID As Integer, ByRef strOptionLink As String) As String
        Dim tblOptionText As New DataTable
        Dim strOptionText As String = ""
        Dim strOptions, strBreak As String

        strBreak = "<br />"
        strOptions = ""

        tblOptionText = _CustomersAdptr.GetOptionText(numLanguageID, numBasketItemID)
        If tblOptionText.Rows.Count > 0 Then
            For Each drwOptionText As DataRow In tblOptionText.Rows
                If LCase(drwOptionText("OPTG_OptionDisplayType") & "") = "c" Then
                    strOptionText = strOptionText & drwOptionText("LE_Value") & strBreak
                Else
                    strOptionText = strOptionText & drwOptionText("OPTG_BackendName") & ": " & drwOptionText("LE_Value") & strBreak
                End If
                strOptions = strOptions & drwOptionText("BSKTOPT_OptionID") & ","
            Next
        End If

        tblOptionText.Dispose()

        If strOptions <> "" Then strOptions = Left(strOptions, strOptions.Length - 1)
        strOptionLink = strOptions

        Return strOptionText
    End Function

    ''' <summary>
    ''' Find all categories that a product appears in 
    ''' </summary>
    ''' <param name="numProductID">The product we want to find categories for</param>
    ''' <returns>a comma delimited string</returns>
    ''' <remarks></remarks>
    Public Shared Function GetCategoryIDs(ByVal numProductID As Long) As String
        Dim tblCategoryIDs As New DataTable
        Dim strCategoryIDs As String = ""

        tblCategoryIDs = _CustomersAdptr.GetCategoryID(numProductID)

        If tblCategoryIDs.Rows.Count > 0 Then
            For Each drwCategoryID As DataRow In tblCategoryIDs.Rows
                strCategoryIDs = strCategoryIDs & drwCategoryID("PCAT_CategoryID") & ","
            Next
        End If

        If strCategoryIDs <> "" Then strCategoryIDs = Left(strCategoryIDs, strCategoryIDs.Length - 1)

        Return strCategoryIDs
    End Function

    ''' <summary>
    ''' Transfer the information in the data row into the promotion object
    ''' </summary>
    ''' <param name="objPromotion">promotion object</param>
    ''' <param name="drwBuy">data row containing data to be put into promotion object</param>
    ''' <remarks></remarks>
    Private Shared Sub SetPromotionData(ByRef objPromotion As Promotion, ByVal drwBuy As DataRow)

        With objPromotion
            .ID = drwBuy("PROM_ID")
            .StartDate = drwBuy("PROM_StartDate")
            .EndDate = drwBuy("PROM_EndDate")
            .Live = IIf(drwBuy("PROM_Live") & "" = "", 0, drwBuy("PROM_Live") & "")
            .OrderByValue = IIf(drwBuy("PROM_OrderByValue") & "" = "", 0, drwBuy("PROM_OrderByValue"))
            .MaxQuantity = IIf(drwBuy("PROM_MaxQuantity") & "" = "", 0, drwBuy("PROM_MaxQuantity"))
            .PartNo = drwBuy("PP_PartNo") & ""
            .Type = drwBuy("PP_Type") & ""
            .Value = drwBuy("PP_Value")
            .ItemType = drwBuy("PP_ItemType") & ""
            .ItemID = drwBuy("PP_ItemID")
            .ItemName = drwBuy("PP_ItemName") & ""
        End With

    End Sub

    ''' <summary>
    ''' Set the promotion quantities and values using reference parameters
    ''' </summary>
    ''' <param name="numMaxPromoQty">Maximum quantity permitted by promotion</param>
    ''' <param name="Item">The basket item object</param>
    ''' <param name="strType">promotion type (e.g. 'q' = free, 'p' = percentage off, 'v' price (or value) off.</param>
    ''' <param name="numBuyQty"></param>
    ''' <param name="numBuyValue"></param>
    ''' <param name="numGetQty"></param>
    ''' <param name="numGetValue"></param>
    ''' <param name="numIncTax"></param>
    ''' <param name="numExTax"></param>
    ''' <param name="numQty"></param>
    ''' <param name="numTaxRate"></param>
    ''' <param name="intExcessGetQty"></param>
    ''' <remarks></remarks>
    Private Shared Sub SetPromotionValue(ByVal numMaxPromoQty As Integer, ByVal Item As Kartris.BasketItem, ByVal strType As String, ByVal numBuyQty As Double, ByVal numBuyValue As Decimal, ByVal numGetQty As Double, ByVal numGetValue As Decimal,
      ByRef numIncTax As Decimal, ByRef numExTax As Decimal, ByRef numQty As Double, ByRef numTaxRate As Decimal, Optional ByRef intExcessGetQty As Integer = 0)

        If strType.ToLower = "q" Then   ''  for free
            numIncTax = -(Item.IncTax * numGetValue)
            numExTax = -(Item.ExTax * numGetValue)
            numQty = Math.Floor(Math.Min((numBuyQty / numBuyValue), (numGetQty / numGetValue)))
            numQty = Math.Min(numMaxPromoQty, numQty)
            numTaxRate = Item.ComputedTaxRate
        ElseIf strType.ToLower = "p" Then '' percentage off
            numIncTax = -(Item.IncTax * numGetValue) / 100
            numExTax = -(Item.ExTax * numGetValue) / 100
            numQty = Math.Floor(Math.Min((numBuyQty / numBuyValue), numGetQty))
            numQty = Math.Min(numMaxPromoQty, numQty)
        ElseIf strType.ToLower = "v" Then '' price off
            numIncTax = -(Item.IncTax - numGetValue)
            numExTax = -(Item.IncTax - numGetValue)
            numQty = Math.Floor(Math.Min((numBuyQty / numBuyValue), numGetQty))
            numQty = Math.Min(numMaxPromoQty, numQty)
        End If
        intExcessGetQty = Math.Floor(numBuyQty - (numBuyValue * numQty))
        If Item.PromoQty <= 0 Then numQty = 0

    End Sub

    ''' <summary>
    ''' Get the text related to the promotion
    ''' </summary>
    ''' <param name="intPromotionID">The promotion we want the text for</param>
    ''' <param name="blnTextOnly">return on the text and not a HTML anchor etc. (used when calling from presentation layer)</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Shared Function GetPromotionText(ByVal intPromotionID As Integer, Optional ByVal blnTextOnly As Boolean = False) As String
        Dim tblPromotionParts As New DataTable    ''==== language_ID =====
        tblPromotionParts = PromotionsBLL._GetPartsByPromotion(intPromotionID, Current.Session("LANG"))

        Dim strPromotionText As String = ""
        Dim intTextCounter As Integer = 0
        Dim numLanguageId As Integer

        numLanguageId = Current.Session("LANG")

        For Each drwPromotionParts As DataRow In tblPromotionParts.Rows

            Dim strText As String = FixNullFromDB(drwPromotionParts("PS_Text"))
            Dim strStringID As String = drwPromotionParts("PS_ID")
            Dim strValue As String = CkartrisDisplayFunctions.FixDecimal(FixNullFromDB(drwPromotionParts("PP_Value")))
            Dim strItemID As String = FixNullFromDB(drwPromotionParts("PP_ItemID"))
            Dim intProductID As Integer = VersionsBLL.GetProductID_s(CLng(strItemID))
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
                strItemName = CategoriesBLL.GetNameByCategoryID(CInt(strItemID), numLanguageId)
                strItemLink = " <b><a href='" & CreateURL(Page.CanonicalCategory, strItemID) & "'>" & strItemName & "</a></b>"
                strItemLink = IIf(blnTextOnly, strItemName, strItemLink)
                strText = strText.Replace("[C]", strItemLink)
            End If

            If strText.Contains("[P]") AndAlso strItemID <> "" Then ''==== language_ID =====
                strItemName = ProductsBLL.GetNameByProductID(CInt(strItemID), numLanguageId)
                strItemLink = " <b><a href='" & CreateURL(Page.CanonicalProduct, strItemID) & "'>" & strItemName & "</a></b>"
                strItemLink = IIf(blnTextOnly, strItemName, strItemLink)
                strText = strText.Replace("[P]", strItemLink)
            End If

            If strText.Contains("[V]") AndAlso strItemID <> "" Then ''==== language_ID =====
                strItemName = ProductsBLL.GetNameByProductID(intProductID, numLanguageId) & " (" & VersionsBLL._GetNameByVersionID(CInt(strItemID), numLanguageId) & ")"
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

    ''' <summary>
    ''' Add promotion to the promotion collection for this basket.
    ''' </summary>
    ''' <param name="blnBasketPromo">Allow promotion to be added multiple times to same basket</param>
    ''' <param name="strPromoDiscountIDs"></param>
    ''' <param name="objPromotion">The promotion to be added</param>
    ''' <param name="numPromoID"></param>
    ''' <param name="numIncTax"></param>
    ''' <param name="numExTax"></param>
    ''' <param name="numQty"></param>
    ''' <param name="numTaxRate"></param>
    ''' <param name="blnIsFixedValuePromo"></param>
    ''' <param name="blnForceAdd"></param>
    ''' <remarks></remarks>
    Private Shared Sub AddPromotion(ByRef Basket As Kartris.Basket, ByVal blnBasketPromo As Boolean, ByRef strPromoDiscountIDs As String, ByRef objPromotion As Kartris.Promotion, ByVal numPromoID As Integer, ByVal numIncTax As Decimal, ByVal numExTax As Decimal,
                             ByVal numQty As Double, ByVal numTaxRate As Decimal, Optional ByVal blnIsFixedValuePromo As Boolean = False, Optional ByVal blnForceAdd As Boolean = False)
        Dim intMaxPromoOrder As Integer = 0

        intMaxPromoOrder = Val(GetKartConfig("frontend.promotions.maximum"))

        If (blnBasketPromo And (Basket.objPromotionsDiscount.Count < intMaxPromoOrder Or intMaxPromoOrder = 0)) OrElse blnForceAdd Then
            strPromoDiscountIDs = strPromoDiscountIDs & numPromoID & ";"
            Dim objPromotionDiscount As New PromotionBasketModifier
            With objPromotionDiscount
                .PromotionID = numPromoID
                .Name = GetPromotionText(objPromotion.ID, True)
                .ApplyTax = Basket.ApplyTax
                .ComputedTaxRate = numTaxRate
                .ExTax = CurrenciesBLL.ConvertCurrency(Current.Session("CUR_ID"), numExTax)
                .IncTax = CurrenciesBLL.ConvertCurrency(Current.Session("CUR_ID"), numIncTax)
                .Quantity = numQty
                .TotalIncTax = .TotalIncTax + (.IncTax * .Quantity)
                .TotalExTax = .TotalExTax + (.ExTax * .Quantity)
                .isFixedValuePromo = blnIsFixedValuePromo
            End With
            Basket.objPromotionsDiscount.Add(objPromotionDiscount)
        Else
            '' add only to promotion if not in promotion discount yet
            Dim blnFound As Boolean = False
            For Each objPromo As PromotionBasketModifier In Basket.objPromotionsDiscount
                If objPromo.PromotionID = objPromotion.ID Then
                    blnFound = True : Exit For
                End If
            Next

            If blnFound = False Then
                objPromotion.PromoText = GetPromotionText(objPromotion.ID)
                Basket.objPromotions.Add(objPromotion)
            End If

        End If

    End Sub

    ''' <summary>
    ''' Reset any applied promotions and apply the promotion collection to the basket and all items contained therein.
    ''' </summary>
    ''' <param name="aryPromotions">List of promotions</param>
    ''' <param name="aryPromotionsDiscount"></param>
    ''' <param name="blnZeroTotalTaxRate">Do not calculate tax</param>
    ''' <remarks></remarks>
    Public Shared Sub CalculatePromotions(ByRef Basket As Kartris.Basket, ByRef aryPromotions As List(Of Kartris.Promotion), ByRef aryPromotionsDiscount As ArrayList, ByVal blnZeroTotalTaxRate As Boolean)
        Dim tblPromotions As Data.DataTable
        Dim drwBuys() As Data.DataRow
        Dim drwGets() As Data.DataRow
        Dim drwSpends() As Data.DataRow
        Dim strPromoIDs, strPromoDiscountIDs, strList As String
        Dim vPromoID, vMaxPromoQty, vItemID As Integer
        Dim strItemType, strType As String
        Dim strItemVersionIDs, strItemProductIDs, strItemCategoryIDs As String
        Dim vIncTax, vExTax, vQuantity, vBuyQty, vValue, vTaxRate As Double
        Dim numTotalBasketAmount As Decimal
        If Basket.BasketItems.Count = 0 Then Exit Sub

        'Clear AppliedPromotion to all Basket Items
        For Each objBasketItem As Kartris.BasketItem In Basket.BasketItems
            objBasketItem.AppliedPromo = 0
        Next

        Dim numLanguageID As Integer
        Dim objItem As New Kartris.BasketItem

        numLanguageID = 1
        strPromoIDs = ";" : strPromoDiscountIDs = ";"
        strItemVersionIDs = GetBasketItemVersionIDs(Basket.BasketItems)
        strItemProductIDs = GetBasketItemProductIDs(Basket.BasketItems)
        strItemCategoryIDs = GetBasketItemCategoryIDs(Basket.BasketItems)
        Basket.PromotionDiscount.IncTax = 0 : Basket.PromotionDiscount.ExTax = 0

        aryPromotions.Clear() : aryPromotionsDiscount.Clear()
        Basket.objPromotions.Clear() : Basket.objPromotionsDiscount.Clear()

        Dim intCouponPromotionID As Integer = 0
        If Not String.IsNullOrEmpty(Basket.CouponCode) Then
            Dim strCouponType As String = ""
            Dim strCouponError As String = ""
            Dim numCouponValue As Decimal = 0

            Call GetCouponDiscount(Basket, Basket.CouponCode, strCouponError, strCouponType, numCouponValue)
            If strCouponType = "t" Then
                intCouponPromotionID = CInt(numCouponValue)
            End If
        End If
        tblPromotions = PromotionsBLL.GetAllPromotions(numLanguageID, intCouponPromotionID)

        '' get promotions from Basket version IDs (buy promotion parts)
        strList = "PP_PartNo='a' and PP_ItemType='v' and PP_Type='q' and PP_ItemID in (" & strItemVersionIDs & ")"
        drwBuys = tblPromotions.Select(strList)
        For Each drwBuy As DataRow In drwBuys
            vPromoID = drwBuy("PROM_ID")
            If InStr(strPromoIDs, vPromoID) = 0 Then
                strPromoIDs = strPromoIDs & vPromoID & ";"

                Dim objPromotion As New Promotion
                Call SetPromotionData(objPromotion, drwBuy)

                objItem = GetBasketItemByVersionID(Basket.BasketItems, objPromotion.ItemID)

                If objItem.Quantity >= objPromotion.Value And objItem.AppliedPromo = 0 Then
                    vIncTax = 0 : vExTax = 0 : vQuantity = 0 : vTaxRate = 0
                    vBuyQty = objItem.Quantity

                    Dim blnGetFound As Boolean = False

                    strList = "PP_PartNo='b' and PROM_ID=" & objPromotion.ID
                    drwGets = tblPromotions.Select(strList)
                    For Each drGet As DataRow In drwGets 'loop the get items
                        strItemType = drGet("PP_ItemType") & ""
                        strType = drGet("PP_Type") & ""
                        vItemID = drGet("PP_ItemID")
                        vValue = drGet("PP_Value")
                        vMaxPromoQty = IIf(drGet("PROM_MaxQuantity") = 0, 1000000, drGet("PROM_MaxQuantity"))
                        Select Case strItemType.ToLower
                            Case "v" 'buy version and get item from version
                                If InStr("," & strItemVersionIDs & ",", "," & vItemID & ",") > 0 Then
                                    'vBuyQty (qty in basket), objPromo.value (buy qty in db), objItem.Quantity(qty in basket get promo), vValue (get qty in db) 
                                    objItem = GetBasketItemByVersionID(Basket.BasketItems, vItemID)
                                    If objItem.AppliedPromo = 1 Then Exit Select
                                    If objPromotion.ItemID = vItemID Then 'buy item is equal to get item
                                        If (vBuyQty > vValue AndAlso strType = "q") OrElse
                                           (vBuyQty >= drwBuy("PP_Value") AndAlso strType = "p") Then
                                            blnGetFound = True
                                            Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, vValue, vValue, vIncTax, vExTax, vQuantity, vTaxRate)
                                        End If
                                    Else
                                        blnGetFound = True
                                        Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate)
                                    End If
                                End If

                                If vQuantity <= 0 Then blnGetFound = False
                                Call AddPromotion(Basket, blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
                                If blnGetFound Then objItem.AppliedPromo = 1
                            Case "p" 'buy version and get item from product
                                If InStr("," & strItemProductIDs & ",", "," & vItemID & ",") > 0 Then
                                    Dim vTotalQtyGot, vQtyBalance As Double
                                    Dim index As Integer

                                    vTotalQtyGot = 0
                                    blnGetFound = True
                                    vTotalQtyGot = vTotalQtyGot + vQuantity
                                    vQtyBalance = (vBuyQty / objPromotion.Value) - vTotalQtyGot

                                    Do While vQtyBalance > 0
                                        index = GetItemMinProductValue(Basket.BasketItems, vItemID)
                                        If index < 0 Then Exit Do
                                        objItem = Basket.BasketItems(index)
                                        If objItem.AppliedPromo = 0 Then
                                            vQtyBalance = Math.Min(vQtyBalance, objItem.Quantity)
                                            Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, vQtyBalance, vValue, vIncTax, vExTax, vQuantity, vTaxRate)
                                            Basket.BasketItems(index).PromoQty = Basket.BasketItems(index).Quantity - vQuantity

                                            If vQuantity <= 0 Then blnGetFound = False
                                            Call AddPromotion(Basket, blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
                                            If blnGetFound Then objItem.AppliedPromo = 1
                                            vTotalQtyGot = vTotalQtyGot + vQuantity
                                            vQtyBalance = (vBuyQty / objPromotion.Value) - vTotalQtyGot

                                            If blnGetFound = False Then Exit Do
                                        End If
                                    Loop

                                End If

                                blnGetFound = False
                                Call AddPromotion(Basket, blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
                                If blnGetFound Then objItem.AppliedPromo = 1
                            Case "c" 'buy version and get item from category
                                If InStr("," & strItemCategoryIDs & ",", "," & vItemID & ",") > 0 Then
                                    Dim index As Integer
                                    index = GetItemMinCategoryValue(Basket.BasketItems, vItemID)
                                    objItem = Basket.BasketItems(index)
                                    If objItem.AppliedPromo = 1 Then Exit Select
                                    blnGetFound = True
                                    Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate)
                                End If

                                If vQuantity <= 0 Then blnGetFound = False
                                Call AddPromotion(Basket, blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
                                If blnGetFound Then objItem.AppliedPromo = 1
                            Case "a"
                                vQuantity = Math.Floor(Math.Min((vBuyQty / objPromotion.Value), (objItem.Quantity / objPromotion.Value)))
                                vQuantity = Math.Min(vQuantity, vMaxPromoQty) 'Make sure it didn't exceed the MaxQty / promotion
                                If vQuantity <= 0 Then blnGetFound = False Else blnGetFound = True

                                vTaxRate = Basket.TotalDiscountPriceTaxRate

                                If vValue > Basket.TotalDiscountPriceExTax Then
                                    vExTax = -Basket.TotalDiscountPriceExTax
                                    vIncTax = -Basket.TotalDiscountPriceIncTax
                                Else
                                    Dim blnPricesExtax As Boolean = False

                                    If Not blnZeroTotalTaxRate Then
                                        If GetKartConfig("general.tax.pricesinctax") = "y" Then
                                            vExTax = -Math.Round(vValue * (1 / (1 + vTaxRate)), CurrencyRoundNumber)
                                            If Basket.D_Tax = 1 Then
                                                vIncTax = -Math.Round(vValue, CurrencyRoundNumber)
                                            Else
                                                vIncTax = vExTax
                                            End If
                                        Else
                                            blnPricesExtax = True
                                        End If
                                    Else
                                        blnPricesExtax = True
                                    End If

                                    If blnPricesExtax Then
                                        vIncTax = -Math.Round(vValue * (1 + vTaxRate), CurrencyRoundNumber)
                                        vExTax = -Math.Round(vValue, CurrencyRoundNumber)
                                    End If
                                End If

                                Call AddPromotion(Basket, blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, True)
                                objItem.AppliedPromo = 1
                        End Select
                    Next
                Else
                    Call AddPromotion(Basket, False, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
                End If

            End If
        Next

        'products
        'get promotions from basket product IDs
        strList = "PP_PartNo='a' and PP_ItemType='p' and PP_Type='q' and PP_ItemID in (" & strItemProductIDs & ")"
        drwBuys = tblPromotions.Select(strList)
        For Each drwBuy As DataRow In drwBuys
            vPromoID = drwBuy("PROM_ID")
            If InStr(strPromoIDs, vPromoID) = 0 Then
                strPromoIDs = strPromoIDs & vPromoID & ";"

                Dim objPromotion As New Promotion
                Call SetPromotionData(objPromotion, drwBuy)

                Dim cnt As Integer = 0
                For i As Integer = 0 To Basket.BasketItems.Count - 1
                    objItem = Basket.BasketItems(i)
                    If objItem.ProductID = objPromotion.ItemID And objItem.AppliedPromo = 0 Then cnt = cnt + objItem.Quantity
                Next

                If cnt >= objPromotion.Value Then
                    vIncTax = 0 : vExTax = 0 : vQuantity = 0 : vTaxRate = 0
                    vBuyQty = cnt

                    Dim blnGetFound As Boolean = False

                    strList = "PP_PartNo='b' and PROM_ID=" & objPromotion.ID
                    drwGets = tblPromotions.Select(strList)
                    Dim blnIsFixedValuePromo As Boolean = False
                    Dim blnForceAdd As Boolean = False
                    For Each drGet As DataRow In drwGets '' loop the get items
                        strItemType = drGet("PP_ItemType")
                        strType = drGet("PP_Type") & ""
                        vItemID = drGet("PP_ItemID")
                        vValue = drGet("PP_Value")
                        vMaxPromoQty = IIf(drGet("PROM_MaxQuantity") = 0, 1000000, drGet("PROM_MaxQuantity"))
                        blnIsFixedValuePromo = False

                        Select Case strItemType.ToLower
                            Case "v"                    '' buy product and get item from version
                                If InStr("," & strItemVersionIDs & ",", "," & vItemID & ",") > 0 Then
                                    objItem = GetBasketItemByVersionID(Basket.BasketItems, vItemID)
                                    If objItem.AppliedPromo = 1 Then Continue For
                                    blnGetFound = True
                                    Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate)
                                End If

                            Case "p"                    '' buy product and get item from product
                                If InStr("," & strItemProductIDs & ",", "," & vItemID & ",") > 0 Then
                                    Dim index As Integer
                                    index = GetItemMinProductValue(Basket.BasketItems, vItemID)
                                    objItem = Basket.BasketItems(index)
                                    If objItem.AppliedPromo = 1 Then Continue For
                                    blnGetFound = True
                                    Dim intExcessGetQty As Integer
                                    Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                    Dim strVersionIDArray As String = ""
                                    Do While intExcessGetQty > 0
                                        If strVersionIDArray <> "" Then strVersionIDArray += ","
                                        blnIsFixedValuePromo = True
                                        objItem.AppliedPromo = 1
                                        vMaxPromoQty = vMaxPromoQty - vQuantity
                                        If intExcessGetQty < objPromotion.Value Or vMaxPromoQty < 1 Then
                                            intExcessGetQty = 0
                                            Exit Do
                                        End If
                                        Call AddPromotion(Basket, blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                                        If blnGetFound Then objItem.AppliedPromo = 1
                                        strVersionIDArray = strVersionIDArray & objItem.VersionID
                                        'Dim numExcessItemsInPromo As Double = vBuyQty - (objPromotion.Value * objItem.Quantity)
                                        index = GetItemMinProductValue(Basket.BasketItems, vItemID, strVersionIDArray)
                                        If index <> -1 Then
                                            objItem = Basket.BasketItems(index)
                                            If objItem.AppliedPromo = 1 Then Continue For
                                            Call SetPromotionValue(vMaxPromoQty, objItem, strType, intExcessGetQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                            blnForceAdd = True
                                        Else
                                            intExcessGetQty = 0
                                        End If
                                    Loop
                                End If

                            Case "c"                    '' buy product and get item from category
                                If InStr("," & strItemCategoryIDs & ",", "," & vItemID & ",") > 0 Then
                                    Dim index As Integer
                                    index = GetItemMinCategoryValue(Basket.BasketItems, vItemID)
                                    objItem = Basket.BasketItems(index)
                                    'If objItem.AppliedPromo = 1 Then Continue For
                                    blnGetFound = True
                                    Dim intExcessGetQty As Integer = 0
                                    Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                    Dim strVersionIDArray As String = ""
                                    Do While intExcessGetQty > 0
                                        If strVersionIDArray <> "" Then strVersionIDArray += ","
                                        blnIsFixedValuePromo = True
                                        objItem.AppliedPromo = 1
                                        vMaxPromoQty = vMaxPromoQty - vQuantity
                                        If intExcessGetQty < objPromotion.Value Or vMaxPromoQty < 1 Then
                                            intExcessGetQty = 0
                                            Exit Do
                                        End If
                                        Call AddPromotion(Basket, blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                                        If blnGetFound Then objItem.AppliedPromo = 1
                                        strVersionIDArray = strVersionIDArray & objItem.VersionID
                                        'Dim numExcessItemsInPromo As Double = vBuyQty - (objPromotion.Value * objItem.Quantity)
                                        index = GetItemMinCategoryValue(Basket.BasketItems, vItemID, strVersionIDArray)
                                        If index <> -1 Then
                                            objItem = Basket.BasketItems(index)
                                            'If objItem.AppliedPromo = 1 Then Continue For
                                            Call SetPromotionValue(vMaxPromoQty, objItem, strType, intExcessGetQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                            blnForceAdd = True
                                        Else
                                            intExcessGetQty = 0
                                        End If
                                    Loop
                                End If
                            Case "a"
                                vQuantity = Math.Floor(Math.Min((vBuyQty / objPromotion.Value), (cnt / objPromotion.Value)))
                                vQuantity = Math.Min(vQuantity, vMaxPromoQty) '' Make sure it didn't exceed the MaxQty / promotion
                                If vQuantity <= 0 Then blnGetFound = False Else blnGetFound = True

                                vTaxRate = Basket.TotalDiscountPriceTaxRate

                                If vValue > Basket.TotalDiscountPriceExTax Then
                                    vExTax = -Basket.TotalDiscountPriceExTax
                                    vIncTax = -Basket.TotalDiscountPriceIncTax
                                Else
                                    Dim blnPricesExtax As Boolean = False

                                    If Not blnZeroTotalTaxRate Then
                                        If GetKartConfig("general.tax.pricesinctax") = "y" Then
                                            vExTax = -Math.Round(vValue * (1 / (1 + vTaxRate)), CurrencyRoundNumber)
                                            If Basket.D_Tax = 1 Then
                                                vIncTax = -Math.Round(vValue, CurrencyRoundNumber)
                                            Else
                                                vIncTax = vExTax
                                            End If
                                        Else
                                            blnPricesExtax = True
                                        End If
                                    Else
                                        blnPricesExtax = True
                                    End If

                                    If blnPricesExtax Then
                                        vIncTax = -Math.Round(vValue * (1 + vTaxRate), CurrencyRoundNumber)
                                        vExTax = -Math.Round(vValue, CurrencyRoundNumber)
                                    End If
                                End If

                                blnIsFixedValuePromo = True
                                objItem.AppliedPromo = 1
                        End Select
                    Next
                    Call AddPromotion(Basket, blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                    If blnGetFound Then objItem.AppliedPromo = 1
                Else
                    Call AddPromotion(Basket, False, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
                End If

            End If
        Next

        '' get promotions from basket category IDs
        strList = "PP_PartNo='a' and PP_ItemType='c' and PP_Type='q' and PP_ItemID in (" & strItemCategoryIDs & ")"
        drwBuys = tblPromotions.Select(strList)
        For Each drwBuy As DataRow In drwBuys
            vPromoID = drwBuy("PROM_ID")
            If InStr(strPromoIDs, vPromoID) = 0 Then
                strPromoIDs = strPromoIDs & vPromoID & ";"

                Dim objPromotion As New Promotion
                Call SetPromotionData(objPromotion, drwBuy)

                Dim cnt As Integer = 0
                For i As Integer = 0 To Basket.BasketItems.Count - 1
                    objItem = Basket.BasketItems(i)
                    If InStr("," & objItem.CategoryIDs & ",", "," & objPromotion.ItemID & ",") > 0 Then
                        cnt = cnt + objItem.Quantity
                    End If
                Next

                If cnt >= objPromotion.Value Then
                    vIncTax = 0 : vExTax = 0 : vQuantity = 0 : vTaxRate = 0
                    vBuyQty = cnt

                    Dim blnGetFound As Boolean = False

                    strList = "PP_PartNo='b' and PROM_ID=" & objPromotion.ID
                    drwGets = tblPromotions.Select(strList)
                    Dim blnIsFixedValuePromo As Boolean = False
                    Dim blnForceAdd As Boolean = False

                    For Each drGet As DataRow In drwGets '' loop the get items
                        strItemType = drGet("PP_ItemType") & ""
                        strType = drGet("PP_Type") & ""
                        vItemID = drGet("PP_ItemID")
                        vValue = drGet("PP_Value")
                        vMaxPromoQty = IIf(drGet("PROM_MaxQuantity") = 0, 1000000, drGet("PROM_MaxQuantity"))
                        blnIsFixedValuePromo = False
                        Select Case strItemType.ToLower
                            Case "v"                    '' buy category and get item from version
                                If InStr("," & strItemVersionIDs & ",", "," & vItemID & ",") > 0 Then
                                    objItem = GetBasketItemByVersionID(Basket.BasketItems, vItemID)
                                    If objItem.AppliedPromo = 1 Then Exit Select
                                    blnGetFound = True
                                    Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate)
                                End If

                            Case "p"                    '' buy category and get item from product
                                If InStr("," & strItemProductIDs & ",", "," & vItemID & ",") > 0 Then
                                    Dim index As Integer
                                    index = GetItemMinProductValue(Basket.BasketItems, vItemID)
                                    objItem = Basket.BasketItems(index)
                                    If objItem.AppliedPromo = 1 Then Exit Select
                                    blnGetFound = True
                                    Dim intExcessGetQty As Integer = 0
                                    Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                    Dim strVersionIDArray As String = ""
                                    Do While intExcessGetQty > 0
                                        If strVersionIDArray <> "" Then strVersionIDArray += ","
                                        blnIsFixedValuePromo = True
                                        objItem.AppliedPromo = 1
                                        vMaxPromoQty = vMaxPromoQty - vQuantity
                                        If intExcessGetQty < objPromotion.Value Or vMaxPromoQty < 1 Then
                                            intExcessGetQty = 0
                                            Exit Do
                                        End If
                                        Call AddPromotion(Basket, blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                                        If blnGetFound Then objItem.AppliedPromo = 1
                                        strVersionIDArray = strVersionIDArray & objItem.VersionID
                                        'Dim numExcessItemsInPromo As Double = vBuyQty - (objPromotion.Value * objItem.Quantity)
                                        index = GetItemMinProductValue(Basket.BasketItems, vItemID, strVersionIDArray)
                                        If index <> -1 Then
                                            objItem = Basket.BasketItems(index)
                                            If objItem.AppliedPromo = 1 Then Continue For
                                            Call SetPromotionValue(vMaxPromoQty, objItem, strType, intExcessGetQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                            blnForceAdd = True
                                        Else
                                            intExcessGetQty = 0
                                        End If
                                    Loop
                                End If

                            Case "c"                    '' buy category and get item from category
                                If InStr("," & strItemCategoryIDs & ",", "," & vItemID & ",") > 0 Then
                                    Dim index As Integer
                                    index = GetItemMinCategoryValue(Basket.BasketItems, vItemID)
                                    objItem = Basket.BasketItems(index)
                                    If objItem.AppliedPromo = 1 Then Exit Select
                                    blnGetFound = True
                                    Dim intExcessGetQty As Integer = 0
                                    Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                    Dim strVersionIDArray As String = ""
                                    Do While intExcessGetQty > 0
                                        If strVersionIDArray <> "" Then strVersionIDArray += ","
                                        blnIsFixedValuePromo = True
                                        objItem.AppliedPromo = 1
                                        vMaxPromoQty = vMaxPromoQty - vQuantity
                                        If intExcessGetQty < objPromotion.Value Or vMaxPromoQty < 1 Then
                                            intExcessGetQty = 0
                                            Exit Do
                                        End If
                                        Call AddPromotion(Basket, blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                                        If blnGetFound Then objItem.AppliedPromo = 1
                                        strVersionIDArray = strVersionIDArray & objItem.VersionID
                                        'Dim numExcessItemsInPromo As Double = vBuyQty - (objPromotion.Value * objItem.Quantity)
                                        index = GetItemMinCategoryValue(Basket.BasketItems, vItemID, strVersionIDArray)
                                        If index <> -1 Then
                                            objItem = Basket.BasketItems(index)
                                            If objItem.AppliedPromo = 1 Then Continue For
                                            Call SetPromotionValue(vMaxPromoQty, objItem, strType, intExcessGetQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                            blnForceAdd = True
                                        Else
                                            intExcessGetQty = 0
                                        End If
                                    Loop
                                End If
                            Case "a"
                                vQuantity = Math.Floor(Math.Min((vBuyQty / objPromotion.Value), (cnt / objPromotion.Value)))
                                vQuantity = Math.Min(vQuantity, vMaxPromoQty) '' Make sure it didn't exceed the MaxQty / promotion
                                If vQuantity <= 0 Then blnGetFound = False Else blnGetFound = True

                                vTaxRate = Basket.TotalDiscountPriceTaxRate

                                If vValue > Basket.TotalDiscountPriceExTax Then
                                    vExTax = -Basket.TotalDiscountPriceExTax
                                    vIncTax = -Basket.TotalDiscountPriceIncTax
                                Else
                                    Dim blnPricesExtax As Boolean = False

                                    If Not blnZeroTotalTaxRate Then
                                        If GetKartConfig("general.tax.pricesinctax") = "y" Then
                                            vExTax = -Math.Round(vValue * (1 / (1 + vTaxRate)), CurrencyRoundNumber)
                                            If Basket.D_Tax = 1 Then
                                                vIncTax = -Math.Round(vValue, CurrencyRoundNumber)
                                            Else
                                                vIncTax = vExTax
                                            End If
                                        Else
                                            blnPricesExtax = True
                                        End If
                                    Else
                                        blnPricesExtax = True
                                    End If

                                    If blnPricesExtax Then
                                        vIncTax = -Math.Round(vValue * (1 + vTaxRate), CurrencyRoundNumber)
                                        vExTax = -Math.Round(vValue, CurrencyRoundNumber)
                                    End If
                                End If

                                blnIsFixedValuePromo = True
                                objItem.AppliedPromo = 1
                        End Select
                    Next
                    Call AddPromotion(Basket, blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                    If blnGetFound Then objItem.AppliedPromo = 1
                Else
                    Call AddPromotion(Basket, False, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
                End If

            End If
        Next

        'get spend value from basket
        Dim vSpend As Decimal = 0
        strList = "PP_PartNo='a' and PP_ItemType='a'"
        drwSpends = tblPromotions.Select(strList)


        For Each drSpend As DataRow In drwSpends
            vPromoID = drSpend("PROM_ID")
            If InStr(strPromoIDs, vPromoID) = 0 Then
                strPromoIDs = strPromoIDs & vPromoID & ";"

                Dim objPromotion As New Promotion
                Call SetPromotionData(objPromotion, drSpend)

                vSpend = drSpend("PP_Value")

                vSpend = Math.Round(CDec(CurrenciesBLL.ConvertCurrency(Current.Session("CUR_ID"), drSpend("PP_Value"))), 4)

                vIncTax = 0 : vExTax = 0 : vQuantity = 0 : vTaxRate = 0

                Dim blnGetFound As Boolean = False

                strList = "PP_PartNo='b' and PROM_ID=" & objPromotion.ID
                drwGets = tblPromotions.Select(strList)
                Dim blnIsFixedValuePromo As Boolean = False
                Dim blnForceAdd As Boolean = False

                If GetKartConfig("general.tax.pricesinctax") = "y" Then
                    numTotalBasketAmount = Basket.TotalIncTax
                Else
                    numTotalBasketAmount = Basket.TotalExTax
                End If

                For Each drGet As DataRow In drwGets     '' loop the get items
                    strItemType = drGet("PP_ItemType") & ""
                    strType = drGet("PP_Type") & ""
                    vItemID = drGet("PP_ItemID")
                    vValue = drGet("PP_Value")
                    vMaxPromoQty = IIf(drGet("PROM_MaxQuantity") = 0, 1000000, drGet("PROM_MaxQuantity"))
                    blnIsFixedValuePromo = False
                    Select Case strItemType.ToLower
                        Case "v" 'spend a certain amount and get item from version
                            If InStr("," & strItemVersionIDs & ",", "," & vItemID & ",") > 0 Then
                                objItem = GetBasketItemByVersionID(Basket.BasketItems, vItemID)
                                If objItem.AppliedPromo = 1 Then Exit Select
                                blnGetFound = True
                                vBuyQty = vValue * (Int(Basket.TotalIncTax / vSpend))
                                objPromotion.Value = vValue
                                Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate)
                            End If

                        Case "p" 'spend a certain amount and get item from product
                            If InStr("," & strItemProductIDs & ",", "," & vItemID & ",") > 0 Then
                                Dim index As Integer
                                index = GetItemMinProductValue(Basket.BasketItems, vItemID)
                                objItem = Basket.BasketItems(index)
                                If objItem.AppliedPromo = 1 Then Exit Select
                                blnGetFound = True
                                vBuyQty = vValue * (Int(Basket.TotalIncTax / vSpend))
                                objPromotion.Value = vValue
                                Dim intExcessGetQty As Integer = 0
                                Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                Dim strVersionIDArray As String = ""

                                Do While intExcessGetQty > 0
                                    If strVersionIDArray <> "" Then strVersionIDArray += ","
                                    blnIsFixedValuePromo = True

                                    vMaxPromoQty = vMaxPromoQty - vQuantity
                                    If intExcessGetQty < objPromotion.Value Or vMaxPromoQty < 1 Then
                                        intExcessGetQty = 0
                                        Exit Do
                                    End If

                                    strVersionIDArray = strVersionIDArray & objItem.VersionID
                                    index = GetItemMinProductValue(Basket.BasketItems, vItemID, strVersionIDArray)
                                    If index <> -1 Then
                                        If objItem.AppliedPromo = 0 Then
                                            Call AddPromotion(Basket, blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                                            objItem.AppliedPromo = 1
                                        End If
                                        objItem = Basket.BasketItems(index)
                                        If objItem.AppliedPromo = 1 Then Continue For
                                        Call SetPromotionValue(vMaxPromoQty, objItem, strType, intExcessGetQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                        blnForceAdd = True
                                    Else
                                        intExcessGetQty = 0
                                    End If
                                Loop

                            End If

                        Case "c" 'spend a certain amount and get item from category
                            If InStr("," & strItemCategoryIDs & ",", "," & vItemID & ",") > 0 Then
                                Dim index As Integer
                                index = GetItemMinCategoryValue(Basket.BasketItems, vItemID)
                                objItem = Basket.BasketItems(index)
                                If objItem.AppliedPromo = 1 Then Exit Select
                                blnGetFound = True
                                vBuyQty = vValue * (Int(Basket.TotalIncTax / vSpend))
                                objPromotion.Value = vValue

                                Dim intExcessGetQty As Integer = 0
                                Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                Dim strVersionIDArray As String = ""

                                Do While intExcessGetQty > 0
                                    If strVersionIDArray <> "" Then strVersionIDArray += ","
                                    blnIsFixedValuePromo = True
                                    vMaxPromoQty = vMaxPromoQty - vQuantity
                                    If intExcessGetQty < objPromotion.Value Or vMaxPromoQty < 1 Then
                                        intExcessGetQty = 0
                                        Exit Do
                                    End If

                                    'comment out the string below as I think this blocks applying
                                    'the discount to item that triggers the discount which in the
                                    'case of spend/get promotions doesn't make sense

                                    strVersionIDArray = strVersionIDArray & objItem.VersionID

                                    index = GetItemMinCategoryValue(Basket.BasketItems, vItemID, strVersionIDArray)
                                    If index <> -1 Then

                                        If objItem.AppliedPromo = 0 Then
                                            Call AddPromotion(Basket, blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                                            objItem.AppliedPromo = 1
                                        End If

                                        objItem = Basket.BasketItems(index)
                                        If objItem.AppliedPromo = 1 Then Continue For
                                        Call SetPromotionValue(vMaxPromoQty, objItem, strType, intExcessGetQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                        blnForceAdd = True
                                    Else
                                        intExcessGetQty = 0
                                    End If
                                Loop

                            End If
                        Case "a" 'Total spend promotion

                            'If total in basket (inc or ex, depending on settings)
                            'is more than the vSpend required, Qty will be above zero
                            vQuantity = Int(numTotalBasketAmount / vSpend)

                            'If Qty above zero (i.e. promotion is triggered) then set
                            'as zero so we don't apply multiple times
                            If vQuantity > 1 Then vQuantity = 1
                            If vQuantity <= 0 Then blnGetFound = False Else blnGetFound = True

                            vTaxRate = Basket.TotalDiscountPriceTaxRate

                            If vValue > Basket.TotalDiscountPriceExTax Then
                                vExTax = -Basket.TotalDiscountPriceExTax
                                vIncTax = -Basket.TotalDiscountPriceIncTax
                            Else
                                Dim blnPricesExtax As Boolean = False

                                If Not blnZeroTotalTaxRate Then
                                    If GetKartConfig("general.tax.pricesinctax") = "y" Then
                                        vExTax = -Math.Round(vValue * (1 / (1 + vTaxRate)), CurrencyRoundNumber)
                                        If Basket.D_Tax = 1 Then
                                            vIncTax = -Math.Round(vValue, CurrencyRoundNumber)
                                        Else
                                            vIncTax = vExTax
                                        End If
                                    Else
                                        blnPricesExtax = True
                                    End If
                                Else
                                    blnPricesExtax = True
                                End If

                                If blnPricesExtax Then
                                    vIncTax = -Math.Round(vValue * (1 + vTaxRate), CurrencyRoundNumber)
                                    vExTax = -Math.Round(vValue, CurrencyRoundNumber)
                                End If
                            End If

                            blnIsFixedValuePromo = True
                    End Select
                Next

                If blnGetFound Then
                    If numTotalBasketAmount >= vSpend Then
                        Call AddPromotion(Basket, blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                    Else
                        Call AddPromotion(Basket, False, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
                    End If
                End If

            End If
        Next


        'get promotions from Basket version IDs (get parts)
        strList = "PP_PartNo='b' and PP_ItemType='v' and PP_Type='q' and PP_ItemID in (" & strItemVersionIDs & ")"
        drwGets = tblPromotions.Select(strList)

        For Each drGet As DataRow In drwGets
            vPromoID = drGet("PROM_ID")
            If InStr(strPromoIDs, vPromoID) = 0 Then
                strPromoIDs = strPromoIDs & vPromoID & ";"
                Dim objPromotion As New Promotion
                Call SetPromotionData(objPromotion, drGet)
                Call AddPromotion(Basket, False, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
            End If
        Next

        For i As Integer = 1 To Basket.objPromotionsDiscount.Count
            Basket.PromotionDiscount.ExTax = Basket.PromotionDiscount.ExTax + Basket.objPromotionsDiscount.Item(i - 1).TotalexTax
            Basket.PromotionDiscount.IncTax = Basket.PromotionDiscount.IncTax + Basket.objPromotionsDiscount.Item(i - 1).TotalIncTax
        Next

        aryPromotions = Basket.objPromotions
        aryPromotionsDiscount = Basket.objPromotionsDiscount

    End Sub

    ''' <summary>
    ''' Autosave basket
    ''' We trigger this when adding items to the basket, or removing them.
    ''' It creates a saved basket for the user called AUTOSAVE. We can
    ''' recover this automatically when they next login.
    ''' </summary>
    ''' <param name="numCustomerID">The db ID of the customer</param>
    ''' <remarks></remarks>
    Public Shared Sub AutosaveBasket(ByRef numCustomerID As Int32)
        If numCustomerID > 0 Then
            BasketBLL.SaveBasket(numCustomerID, "AUTOSAVE", Current.Session("SessionID"))
        End If
    End Sub

    ''' <summary>
    ''' Restore Autosaved basket
    ''' When a user logs in, we can recover an autosaved basket. We
    ''' only want to do this if the user's basket is blank, otherwise
    ''' they might add items on a subsequent visit, but we'd then
    ''' wipe these when they login or come to checkout.
    ''' </summary>
    ''' <param name="numCustomerID">The db ID of the customer</param>
    ''' <remarks></remarks>
    Public Shared Sub RecoverAutosaveBasket(ByRef numCustomerID As Int32)

        'First we want to check if there are items in the basket already
        Dim TestBasket As New Kartris.Basket
        Dim TestBasketItems As List(Of Kartris.BasketItem)

        'Load up basket from session
        TestBasket.LoadBasketItems()
        TestBasketItems = TestBasket.BasketItems

        'Check number of items
        If TestBasketItems.Count > 0 Then
            'This means the user has items in basket already.
            'In this case, we don't want to load items over the
            'top. In fact, we can save their current items as
            'an AUTOSAVE record!
            BasketBLL.AutosaveBasket(numCustomerID)
        Else
            'No existing basket, let's recover the AUTOSAVE one
            'if it exists
            If numCustomerID > 0 Then
                BasketBLL.LoadAutosaveBasket(numCustomerID, Current.Session("SessionID"))
            End If
        End If

    End Sub

#Region "MailingList"

    ''' <summary>
    ''' Update the customer mail format
    ''' </summary>
    ''' <param name="numUserID">Customer ID</param>
    ''' <param name="strMailFormat">Mail format (plain, html etc.)</param>
    ''' <remarks></remarks>
    Public Shared Sub UpdateCustomerMailFormat(ByVal numUserID As Integer, ByVal strMailFormat As String)
        _CustomersAdptr.UpdateMailFormat(CkartrisBLL.GetLanguageIDfromSession, numUserID, strMailFormat)
    End Sub

    ''' <summary>
    ''' Update settings for the mailing list for a given customer.
    ''' </summary>
    ''' <param name="strEmail"></param>
    ''' <param name="strPassword"></param>
    ''' <param name="strMailFormat"></param>
    ''' <param name="strSignupIP"></param>
    ''' <remarks></remarks>
    Public Shared Sub UpdateCustomerMailingList(ByVal strEmail As String, ByRef strPassword As String, Optional ByVal strMailFormat As String = "t", Optional ByVal strSignupIP As String = "")
        Dim datSignup As DateTime
        Dim numPasswordLength As Integer

        numPasswordLength = Val(KartSettingsManager.GetKartConfig("minimumcustomercodesize"))
        If numPasswordLength = 0 Then numPasswordLength = 8
        strPassword = GetRandomString(numPasswordLength)

        datSignup = CkartrisDisplayFunctions.NowOffset

        _CustomersAdptr.UpdateMailingList(strEmail, datSignup, strSignupIP, strPassword, strMailFormat, CkartrisBLL.GetLanguageIDfromSession)

    End Sub


    Public Shared Function ConfirmMail(ByVal numUserID As Integer, ByVal strPassword As String, Optional ByVal strIP As String = "") As Integer
        Dim tblConfirmMail As New DataTable
        Dim UserID As Integer = 0

        tblConfirmMail = _CustomersAdptr.ConfirmMail(numUserID, strPassword, CkartrisDisplayFunctions.NowOffset, strIP)

        If tblConfirmMail.Rows.Count > 0 Then
            UserID = Val(tblConfirmMail.Rows(0).Item("UserID") & "")
        End If

        'If mailchimp is active, we want to add the user to the mailing list
        If KartSettingsManager.GetKartConfig("general.mailchimp.enabled") = "y" Then
            'Lookup user email
            Dim strEmail As String = UsersBLL.GetEmailByID(UserID)
            AddListSubscriber(strEmail)
        End If

        Return UserID

    End Function

    'Add user to MailChimp mailing list
    Public Shared Sub AddListSubscriber(ByVal strEmail As String)
        Dim manager As MailChimpBLL = New MailChimpBLL()
        Dim member As Member = manager.AddListSubscriber(strEmail).Result()
    End Sub
#End Region

    ''' <summary>
    ''' Return Image Tag for a version/product to use in basket and on order email - if no version image, uses product image 
    ''' </summary>
    ''' <param name="numVersionID">The version we want to find images for</param>
    ''' <param name="numProductID">The product we want to find images for</param>
    ''' <returns>a string of html</returns>
    ''' <remarks></remarks>
    Public Shared Function GetImageURL(ByVal numVersionID As Long, ByVal numProductID As Long) As String

        Dim strImageURL As String = ""
        Dim strProductsFolderPath As String = HttpContext.Current.Server.MapPath(CkartrisImages.strProductImagesPath & "/" & numProductID & "/")
        Dim strVersionsFolderPath As String = strProductsFolderPath & "/" & numVersionID & "/"

        If numVersionID > 0 And Directory.Exists(strVersionsFolderPath) Then
            Try
                'we look for version image
                Dim dirFolder As New DirectoryInfo(strVersionsFolderPath)

                If dirFolder.GetFiles().Length < 1 Then
                    'folder found, but no images in it
                    strImageURL = ""
                Else
                    Try
                        For Each objFile In dirFolder.GetFiles()
                            strImageURL = CkartrisBLL.WebShopURL & "Image.ashx?strFileName=" & objFile.Name & "&amp;strItemType=v&amp;numMaxHeight=" & KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.height") & "&amp;numMaxWidth=" & KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.width") & "&amp;numItem=" & numVersionID & "&amp;strParent=" & numProductID
                            Exit For
                        Next

                    Catch ex As Exception
                        strImageURL = ""
                    End Try
                End If
            Catch ex As Exception
                'Maybe version folder, but no versions (if they were deleted)
            End Try
        End If

        'no version image found, so look for product images
        If numProductID > 0 And strImageURL = "" Then
            Try
                Dim dirFolder As New DirectoryInfo(strProductsFolderPath)

                If dirFolder.GetFiles().Length < 1 Then
                    'folder found, but no images in it
                    strImageURL = ""
                Else
                    Try
                        For Each objFile In dirFolder.GetFiles()
                            strImageURL = CkartrisBLL.WebShopURL & "Image.ashx?strFileName=" & objFile.Name & "&amp;strItemType=p&amp;numMaxHeight=" & KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.height") & "&amp;numMaxWidth=" & KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.width") & "&amp;numItem=" & numProductID & "&amp;strParent=0"
                            Exit For
                        Next

                    Catch ex As Exception
                        strImageURL = ""
                    End Try
                End If
            Catch ex As Exception
                'Maybe no directory
            End Try

        End If

        Return strImageURL
    End Function

End Class
