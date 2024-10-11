'========================================================================
'Kartris - www.kartris.com
'Copyright 2024 CACTUSOFT

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
''' <summary>
''' Business logic layer for handling affiliates
''' </summary>
''' <remarks>Affiliates are customers that sell product on behalf of the shop and receive a commission for this. Like an Avon representative</remarks>
Public Class AffiliateBLL

    ' Affiliates are people who can sell on behalf of the shop owner.
    ' Examples would be an Avon representative, they sell on behalf of Avon but are not
    ' direct employees neither are they on the payroll.

    Protected Shared ReadOnly Property _CustomersAdptr() As CustomersTblAdptr
        Get
            Return New CustomersTblAdptr
        End Get
    End Property

    ''' <summary>
    ''' Set the user as an affiliate
    ''' </summary>
    ''' <param name="numUserID">User to set as affiliate</param>
    ''' <remarks></remarks>
    Public Shared Sub UpdateCustomerAffiliateStatus(ByVal numUserID As Integer)
        _CustomersAdptr.UpdateAffiliate(1, numUserID, 0, 0)
    End Sub

    ''' <summary>
    ''' Set the commission rate for the user
    ''' </summary>
    ''' <param name="numUserID">User to update</param>
    ''' <param name="numCommission">commission rate (percentage)</param>
    ''' <remarks></remarks>
    Public Shared Sub UpdateCustomerAffiliateCommission(ByVal numUserID As Integer, ByVal numCommission As Double)
        _CustomersAdptr.UpdateAffiliate(2, numUserID, numCommission, 0)
    End Sub

    ''' <summary>
    ''' Set the affiliate ID
    ''' </summary>
    ''' <param name="numUserID">User to update</param>
    ''' <param name="numAffiliateID">Affiliate Id to set</param>
    ''' <remarks>Only works if the ID is currently NULL</remarks>
    Public Shared Sub UpdateCustomerAffiliateID(ByVal numUserID As Integer, ByVal numAffiliateID As Integer)
        _CustomersAdptr.UpdateAffiliate(3, numUserID, 0, numAffiliateID)
    End Sub

    ''' <summary>
    ''' Log that the session has used a reference to an affiliate, this way we know that all orders within this session should result in payment to the referenced affiliate.
    ''' </summary>
    ''' <param name="numAffiliateId">The affiliate reference number</param>
    ''' <param name="strReferer">the page and HTTP referrer that trigged this log addition</param>
    ''' <param name="strIP">Source IP</param>
    ''' <param name="strRequestedItem">Requested item (taken from query string at time of trigger)</param>
    ''' <remarks>used to track which purchases should credit the affiliate with commission</remarks>
    Public Shared Sub UpdateCustomerAffiliateLog(ByVal numAffiliateId As Integer, ByVal strReferer As String, ByVal strIP As String, ByVal strRequestedItem As String)
        _CustomersAdptr.UpdateAffiliateLog(numAffiliateId, strReferer, strIP, strRequestedItem, CkartrisDisplayFunctions.NowOffset)
    End Sub

    ''' <summary>
    ''' Is the selected user an affiliate
    ''' </summary>
    ''' <param name="numUserID">User to check</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function IsCustomerAffiliate(ByVal numUserID As Long) As Boolean
        Dim tblAffiliate As DataTable
        Dim blnIsAffiliate As Boolean = False

        tblAffiliate = BasketBLL.GetCustomerData(numUserID)
        If tblAffiliate.Rows.Count > 0 Then
            blnIsAffiliate = tblAffiliate.Rows(0).Item("U_IsAffiliate")
        End If
        tblAffiliate.Dispose()

        Return blnIsAffiliate
    End Function

    ''' <summary>
    ''' Get the affiliate ID for a given user
    ''' </summary>
    ''' <param name="numUserID"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetCustomerAffiliateID(ByVal numUserID As Long) As Long
        Dim tblAffiliate As DataTable
        Dim numAffiliateID As Long

        tblAffiliate = BasketBLL.GetCustomerData(numUserID)
        If tblAffiliate.Rows.Count > 0 Then
            numAffiliateID = tblAffiliate.Rows(0).Item("U_AffiliateID")
        End If
        tblAffiliate.Dispose()

        Return numAffiliateID
    End Function

    ''' <summary>
    ''' Check to see if the affiliate needs to be logged to ensure that the affiliate gets their commission if an item is being purchased.
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Sub CheckAffiliateLink()
        Dim numAffiliateID, sessAffiliateID As Integer
        Dim objBasket As New Kartris.Basket

        numAffiliateID = Val(Current.Request.QueryString("af"))

        If numAffiliateID > 0 AndAlso AffiliateBLL.IsCustomerAffiliate(numAffiliateID) Then

            If Not (Current.Session("C_AffiliateID") Is Nothing) Then
                sessAffiliateID = Val(Current.Session("C_AffiliateID"))
            Else
                sessAffiliateID = 0
            End If

            If numAffiliateID <> sessAffiliateID Then
                Dim strReferer, strIP, strRequestedItem As String
                strReferer = Current.Request.ServerVariables("HTTP_REFERER")
                If strReferer Is Nothing Then strReferer = ""
                strIP = CkartrisEnvironment.GetClientIPAddress()
                strRequestedItem = Left(Current.Request.ServerVariables("PATH_INFO") & "?" & Current.Request.ServerVariables("QUERY_STRING"), 255)

                AffiliateBLL.UpdateCustomerAffiliateLog(numAffiliateID, strReferer, strIP, strRequestedItem)
                Current.Session("C_AffiliateID") = numAffiliateID

            End If

        End If

        objBasket = Nothing
    End Sub

    ''' <summary>
    ''' Get information related to an affiliate showing sales data group by month
    ''' </summary>
    ''' <param name="numUserID">the user ID</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetCustomerAffiliateActivitySales(ByVal numUserID As Integer) As DataTable
        Dim tblAffiliate As New DataTable
        tblAffiliate = _CustomersAdptr.GetAffiliateData(1, numUserID, 0, 0)
        Return tblAffiliate
    End Function

    ''' <summary>
    ''' Return number of hits for an affiliate grouped by month
    ''' </summary>
    ''' <param name="numUserID">User Id to check</param>
    ''' <returns></returns>
    ''' <remarks>hits are retrieved from the affiliate log table</remarks>
    Public Shared Function GetCustomerAffiliateActivityHits(ByVal numUserID As Integer) As DataTable
        Dim tblAffiliate As New DataTable
        tblAffiliate = _CustomersAdptr.GetAffiliateData(2, numUserID, 0, 0)
        Return tblAffiliate
    End Function

    ''' <summary>
    ''' Returns commission for affiliate for a specific month
    ''' </summary>
    ''' <param name="numUserID">User to retrieve data for</param>
    ''' <param name="numMonth">Month number (e.g. May = 5, June = 6)</param>
    ''' <param name="numYear">Year four digit number (e.g. '1996, 2005')</param>
    ''' <returns>Order total, commission and hit count</returns>
    ''' <remarks></remarks>
    Public Shared Function GetCustomerAffiliateCommission(ByVal numUserID As Integer, ByVal numMonth As Integer, ByVal numYear As Integer) As DataTable
        Dim tblAffiliate As New DataTable
        tblAffiliate = _CustomersAdptr.GetAffiliateData(3, numUserID, numMonth, numYear)
        Return tblAffiliate
    End Function

    ''' <summary>
    ''' Sales information for a single affiliate for a specific month. 
    ''' </summary>
    ''' <param name="numUserID">The user that is an affiliate</param>
    ''' <param name="numMonth">Month number (e.g. 5 = May, 6 = June)</param>
    ''' <param name="numYear">Year four digit number (e.g. '1996, 2005')</param>
    ''' <returns>Commission, hit counts and order numbers</returns>
    ''' <remarks></remarks>
    Public Shared Function GetCustomerAffiliateSalesLink(ByVal numUserID As Integer, ByVal numMonth As Integer, ByVal numYear As Integer) As DataTable
        Dim tblAffiliate As New DataTable
        tblAffiliate = _CustomersAdptr.GetAffiliateData(4, numUserID, numMonth, numYear)
        Return tblAffiliate
    End Function

    ''' <summary>
    ''' Get table of payments to an affiliate
    ''' </summary>
    ''' <param name="numUserID">User number that we want to retrieve data for</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetCustomerAffiliatePayments(ByVal numUserID As Integer) As DataTable
        Dim tblAffiliate As New DataTable
        tblAffiliate = _CustomersAdptr.GetAffiliateData(5, numUserID, 0, 0)
        Return tblAffiliate
    End Function

    ''' <summary>
    ''' Get a list of sales commission information for an affiliate that has not been paid to them already
    ''' </summary>
    ''' <param name="numUserID">User number that we want to retrieve data for</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetCustomerAffiliateUnpaidSales(ByVal numUserID As Integer) As DataTable
        Dim tblAffiliate As New DataTable
        tblAffiliate = _CustomersAdptr.GetAffiliateData(6, numUserID, 0, 0)
        Return tblAffiliate
    End Function

    ''' <summary>
    ''' Get a single line summary of paid and unpaid commission for a given user
    ''' </summary>
    ''' <param name="numUserId"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function _GetCustomerAffiliateCommissionSummary(ByVal numUserId As Long) As DataTable
        Dim tblAffiliate As New DataTable
        Dim intPaid As Integer = IIf(LCase(KartSettingsManager.GetKartConfig("frontend.users.affiliates.commissiononlyonpaid")) = "y", 1, 0)
        tblAffiliate = _CustomersAdptr._GetAffiliateCommission(0, numUserId, intPaid, 0, 0)
        Return tblAffiliate
    End Function

    ''' <summary>
    ''' Get unpaid commission details grouped by order
    ''' </summary>
    ''' <param name="numUserId">User ID for affiliate</param>
    ''' <param name="PageIndex">The page number to show (paginated output)</param>
    ''' <param name="PageSize">The page size (paginated output)</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function _GetCustomerAffiliateUnpaidCommission(ByVal numUserId As Long, Optional ByVal PageIndex As Integer = 0, Optional ByVal PageSize As Integer = 10) As DataTable
        Dim tblAffiliate As New DataTable
        Dim intPaid As Integer = IIf(LCase(KartSettingsManager.GetKartConfig("frontend.users.affiliates.commissiononlyonpaid")) = "y", 1, 0)
        tblAffiliate = _CustomersAdptr._GetAffiliateCommission(1, numUserId, intPaid, ((PageIndex - 1) * PageSize) + 1, (PageIndex * PageSize))
        Return tblAffiliate
    End Function

    ''' <summary>
    ''' Get paid commission details grouped by order
    ''' </summary>
    ''' <param name="numUserId">User ID for affiliate</param>
    ''' <param name="PageIndex">The page number to show (paginated output)</param>
    ''' <param name="PageSize">The page size (paginated output)</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function _GetCustomerAffiliatePaidCommission(ByVal numUserId As Long, Optional ByVal PageIndex As Integer = 0, Optional ByVal PageSize As Integer = 10) As DataTable
        Dim tblAffiliate As New DataTable
        Dim intPaid As Integer = IIf(LCase(KartSettingsManager.GetKartConfig("frontend.users.affiliates.commissiononlyonpaid")) = "y", 1, 0)
        tblAffiliate = _CustomersAdptr._GetAffiliateCommission(2, numUserId, intPaid, ((PageIndex - 1) * PageSize) + 1, (PageIndex * PageSize))
        Return tblAffiliate
    End Function

    ''' <summary>
    ''' Record payment to an affiliate
    ''' </summary>
    ''' <param name="intAffiliateID">The affiliate ID to add the information to</param>
    ''' <returns></returns>
    ''' <remarks>only records the affiliate ID, date, and time</remarks>
    Public Shared Function _AddAffiliatePayments(ByVal intAffiliateID As Integer) As Integer
        Dim tblAffiliate As New DataTable

        tblAffiliate = _CustomersAdptr._AddAffiliatePayments(intAffiliateID, CkartrisDisplayFunctions.NowOffset)
        If tblAffiliate.Rows.Count > 0 Then
            Return tblAffiliate.Rows(0).Item("AFP_ID")
        Else
            Return 0
        End If

    End Function

    ''' <summary>
    ''' Record an affiliate payment ID against an order ID
    ''' </summary>
    ''' <param name="intAffilliatePaymentID">The reference to the affiliate payment transaction</param>
    ''' <param name="intOrderID">Order that the affiliate was paid for</param>
    ''' <remarks>Used to record that the affiliate has been paid for the order</remarks>
    Public Shared Sub _UpdateAffiliateCommission(ByVal intAffilliatePaymentID As Integer, ByVal intOrderID As Integer)

        _CustomersAdptr._UpdateAffiliateOrders(1, intAffilliatePaymentID, intOrderID)

    End Sub

    ''' <summary>
    ''' Delete references to the affiliate being paid
    ''' </summary>
    ''' <param name="intAffilliatePaymentID">The affiliate payment transation reference</param>
    ''' <remarks></remarks>
    Public Shared Sub _UpdateAffiliatePayment(ByVal intAffilliatePaymentID As Integer)

        _CustomersAdptr._UpdateAffiliateOrders(2, intAffilliatePaymentID, 0)

    End Sub

    ''' <summary>
    ''' Show number of hits for month and year for all affiliates
    ''' </summary>
    ''' <param name="numMonth">Month number (e.g. 5 = May, 6 = June)</param>
    ''' <param name="numYear">Year four digit number (e.g. '1996, 2005')</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function _GetAffiliateMonthlyHitsReport(ByVal numMonth As Integer, ByVal numYear As Integer) As DataTable

        Return _CustomersAdptr._GetAffiliateReport(1, numMonth, numYear, CkartrisDisplayFunctions.NowOffset, 0, 0, 0, 0)

    End Function

    ''' <summary>
    ''' Generate affiliate hits report grouped by year. Grouped by affiliate and year
    ''' </summary>
    ''' <returns>shows number of hits each affiliate gained for each year</returns>
    ''' <remarks></remarks>
    Public Shared Function _GetAffiliateAnnualHitsReport() As DataTable

        Return _CustomersAdptr._GetAffiliateReport(2, 0, 0, Format(DateAdd(DateInterval.Month, -11, CkartrisDisplayFunctions.NowOffset), "yyyy/MM/01 0:00:00"), 0, 0, 0, 0)

    End Function

    ''' <summary>
    ''' Generate report showing all affiliate sales for a given month and year. Grouped by affiliate
    ''' </summary>
    ''' <param name="numMonth">Month number (e.g. 5 = May, 6 = June)</param>
    ''' <param name="numYear">Year four digit number (e.g. '1996, 2005')</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function _GetAffiliateMonthlySalesReport(ByVal numMonth As Integer, ByVal numYear As Integer) As DataTable

        Dim numPaid As Short = IIf(Trim(LCase(GetKartConfig("frontend.users.affiliates.commissiononlyonpaid"))) = "y", 1, 0)
        Return _CustomersAdptr._GetAffiliateReport(3, numMonth, numYear, CkartrisDisplayFunctions.NowOffset, numPaid, 0, 0, 0)

    End Function

    ''' <summary>
    ''' Generate report showing all affiliate sales. grouped by affiliate and year.
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function _GetAffiliateAnnualSalesReport() As DataTable

        Dim numPaid As Short = IIf(Trim(LCase(GetKartConfig("frontend.users.affiliates.commissiononlyonpaid"))) = "y", 1, 0)
        Return _CustomersAdptr._GetAffiliateReport(4, 0, 0, Format(DateAdd(DateInterval.Month, -11, CkartrisDisplayFunctions.NowOffset), "yyyy/MM/01 0:00:00"), numPaid, 0, 0, 0)

    End Function

    ''' <summary>
    ''' Get a report showing sales, commission and hits for a given affiliate
    ''' </summary>
    ''' <param name="numMonth">Month number (e.g. 5 = May, 6 = June)</param>
    ''' <param name="numYear">Year four digit number (e.g. '1996, 2005')</param>
    ''' <param name="numAffiliateID">The affiliate you want to get data for</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function _GetAffiliateSummaryReport(ByVal numMonth As Integer, ByVal numYear As Integer, ByVal numAffiliateID As Integer) As DataTable

        Dim numPaid As Short = IIf(Trim(LCase(GetKartConfig("frontend.users.affiliates.commissiononlyonpaid"))) = "y", 1, 0)
        Return _CustomersAdptr._GetAffiliateReport(5, numMonth, numYear, CkartrisDisplayFunctions.NowOffset, numPaid, numAffiliateID, 0, 0)

    End Function

    ''' <summary>
    ''' Get a report of hits associated with an affiliate. No grouping
    ''' </summary>
    ''' <param name="numMonth">Month number (e.g. 5 = May, 6 = June)</param>
    ''' <param name="numYear">Year four digit number (e.g. '1996, 2005')</param>
    ''' <param name="numAffiliateID">Affiliate we want to run the report for</param>
    ''' <param name="PageIndex">The page we wish to view (paginated output)</param>
    ''' <param name="PageSize">The size of each page (paginated output)</param>
    ''' <returns></returns>
    ''' <remarks>hits are clicks etc.</remarks>
    Public Shared Function _GetAffiliateRawDataHitsReport(ByVal numMonth As Integer, ByVal numYear As Integer, ByVal numAffiliateID As Integer, Optional ByVal PageIndex As Integer = 0, Optional ByVal PageSize As Integer = 10) As DataTable

        Return _CustomersAdptr._GetAffiliateReport(6, numMonth, numYear, CkartrisDisplayFunctions.NowOffset, 0, numAffiliateID, ((PageIndex - 1) * PageSize) + 1, (PageIndex * PageSize))

    End Function

    ''' <summary>
    ''' Get a report of all sales associated with an affiliate. No grouping
    ''' </summary>
    ''' <param name="numMonth">Month number (e.g. 5 = May, 6 = June)</param>
    ''' <param name="numYear">Year four digit number (e.g. '1996, 2005')</param>
    ''' <param name="numAffiliateID">Affiliate we want to run the report for</param>
    ''' <param name="PageIndex">The page we wish to view (paginated output)</param>
    ''' <param name="PageSize">The size of each page (paginated output)</param>
    ''' <returns></returns>
    ''' <remarks>shows sales data</remarks>
    Public Shared Function _GetAffiliateRawDataSalesReport(ByVal numMonth As Integer, ByVal numYear As Integer, ByVal numAffiliateID As Integer, Optional ByVal PageIndex As Integer = 0, Optional ByVal PageSize As Integer = 10) As DataTable

        Dim numPaid As Short = IIf(Trim(LCase(GetKartConfig("frontend.users.affiliates.commissiononlyonpaid"))) = "y", 1, 0)
        Return _CustomersAdptr._GetAffiliateReport(7, numMonth, numYear, CkartrisDisplayFunctions.NowOffset, numPaid, numAffiliateID, ((PageIndex - 1) * PageSize) + 1, (PageIndex * PageSize))

    End Function

End Class
