/****** Object:  StoredProcedure [dbo].[_spKartrisDB_GetTaskList]    Script Date: 01/23/2013 21:59:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Modified by:		Medz 02/11/09
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisDB_GetTaskList]
(	
	@NoOrdersToInvoice as int OUTPUT,
	@NoOrdersNeedPayment as int OUTPUT,
	@NoOrdersToDispatch as int OUTPUT,
	@NoStockWarnings as int OUTPUT,
	@NoOutOfStock as int OUTPUT,
	@NoReviewsWaiting as int OUTPUT,
	@NoAffiliatesWaiting as int OUTPUT,
	@NoCustomersWaitingRefunds as int OUTPUT,
	@NoCustomersInArrears as int OUTPUT,
	@NoOfLinnworksOrdersToBeSent as int OUTPUT
)
AS
BEGIN
	SELECT @NoOrdersToInvoice = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Invoiced = 'False' AND O_Paid = 'False' AND O_Sent = 'True' AND O_Cancelled = 'False';
	SELECT @NoOrdersNeedPayment = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Paid = 'False' AND O_Invoiced = 'True' AND O_Sent = 'True' AND O_Cancelled = 'False';
	SELECT @NoOrdersToDispatch = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Sent = 'True' AND O_Paid = 'True' AND O_Shipped = 'False' AND O_Cancelled = 'False';
	
	SELECT @NoStockWarnings = Count(V_ID) FROM dbo.tblKartrisVersions WHERE V_QuantityWarnLevel >= V_Quantity AND V_QuantityWarnLevel <> 0;
	SELECT @NoOutOfStock = Count(V_ID) FROM dbo.tblKartrisVersions WHERE V_Quantity = 0 AND V_QuantityWarnLevel <> 0;

	SELECT @NoReviewsWaiting = Count(REV_ID) FROM dbo.tblKartrisReviews WHERE REV_Live = 'a';
	SELECT @NoAffiliatesWaiting  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_IsAffiliate = 'True' AND U_AffiliateCommission = 0;
	SELECT @NoCustomersWaitingRefunds  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_CustomerBalance > 0;
	SELECT @NoCustomersInArrears  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_CustomerBalance < 0;

	SELECT @NoOfLinnworksOrdersToBeSent = Count(O_ID) FROM tblKartrisOrders WHERE (O_Paid = 1) AND (O_Cancelled IS NULL or O_Cancelled = 0) AND O_ID NOT IN (SELECT [LWO_OrderID] FROM [dbo].[tblKartrisLinnworksOrders])
END
GO
ALTER TABLE tblKartrisAddresses ADD CONSTRAINT CK_AddressesPreventZeroID CHECK (ADR_ID > 0); 
ALTER TABLE tblKartrisAdminLog ADD CONSTRAINT CK_AdminLogPreventZeroID CHECK (AL_ID > 0); 
ALTER TABLE tblKartrisAffiliateLog ADD CONSTRAINT CK_AffiliateLogPreventZeroID CHECK (AFLG_ID > 0); 
ALTER TABLE tblKartrisAffiliatePayments ADD CONSTRAINT CK_AffiliatePaymentsPreventZeroID CHECK (AFP_ID > 0); 
ALTER TABLE tblKartrisAttributes ADD CONSTRAINT CK_AttributesPreventZeroID CHECK (ATTRIB_ID > 0); 
ALTER TABLE tblKartrisAttributeValues ADD CONSTRAINT CK_AttributeValuesPreventZeroID CHECK (ATTRIBV_ID > 0); 
ALTER TABLE tblKartrisBasketOptionValues ADD CONSTRAINT CK_BasketOptionValuesPreventZeroID CHECK (BSKTOPT_ID > 0); 
ALTER TABLE tblKartrisBasketValues ADD CONSTRAINT CK_BasketValuesPreventZeroID CHECK (BV_ID > 0); 
ALTER TABLE tblKartrisCoupons ADD CONSTRAINT CK_CouponsPreventZeroID CHECK (CP_ID > 0); 
ALTER TABLE tblKartrisCreditCards ADD CONSTRAINT CK_CreditCardsPreventZeroID CHECK (CR_ID > 0); 
ALTER TABLE tblKartrisCurrencies ADD CONSTRAINT CK_CurrenciesPreventZeroID CHECK (CUR_ID > 0); 
ALTER TABLE tblKartrisCustomerGroupPrices ADD CONSTRAINT CK_CustomerGroupPricesPreventZeroID CHECK (CGP_ID > 0); 
ALTER TABLE tblKartrisCustomerGroups ADD CONSTRAINT CK_CustomerGroupsPreventZeroID CHECK (CG_ID > 0); 
ALTER TABLE tblKartrisDestination ADD CONSTRAINT CK_DestinationPreventZeroID CHECK (D_ID > 0); 
ALTER TABLE tblKartrisInvoiceRows ADD CONSTRAINT CK_InvoiceRowsPreventZeroID CHECK (IR_ID > 0); 
ALTER TABLE tblKartrisKnowledgeBase ADD CONSTRAINT CK_KnowledgeBasePreventZeroID CHECK (KB_ID > 0); 
ALTER TABLE tblKartrisLanguageElements ADD CONSTRAINT CK_LanguageElementsPreventZeroID CHECK (LE_ID > 0); 
ALTER TABLE tblKartrisLanguages ADD CONSTRAINT CK_LanguagesPreventZeroID CHECK (LANG_ID > 0); 
ALTER TABLE tblKartrisLanguageStrings ADD CONSTRAINT CK_LanguageStringsPreventZeroID CHECK (LS_ID > 0); 
ALTER TABLE tblKartrisLogins ADD CONSTRAINT CK_LoginsPreventZeroID CHECK (LOGIN_ID > 0); 
ALTER TABLE tblKartrisMediaLinks ADD CONSTRAINT CK_MediaLinksPreventZeroID CHECK (ML_ID > 0); 
ALTER TABLE tblKartrisMediaTypes ADD CONSTRAINT CK_MediaTypesPreventZeroID CHECK (MT_ID > 0); 
ALTER TABLE tblKartrisNews ADD CONSTRAINT CK_NewsPreventZeroID CHECK (N_ID > 0); 
ALTER TABLE tblKartrisObjectConfig ADD CONSTRAINT CK_ObjectConfigPreventZeroID CHECK (OC_ID > 0); 
ALTER TABLE tblKartrisOptionGroups ADD CONSTRAINT CK_OptionGroupsPreventZeroID CHECK (OPTG_ID > 0); 
ALTER TABLE tblKartrisOptions ADD CONSTRAINT CK_OptionsPreventZeroID CHECK (OPT_ID > 0); 
ALTER TABLE tblKartrisOrders ADD CONSTRAINT CK_OrdersPreventZeroID CHECK (O_ID > 0); 
ALTER TABLE tblKartrisPages ADD CONSTRAINT CK_PagesPreventZeroID CHECK (PAGE_ID > 0); 
ALTER TABLE tblKartrisPayments ADD CONSTRAINT CK_PaymentsPreventZeroID CHECK (Payment_ID > 0); 
ALTER TABLE tblKartrisProducts ADD CONSTRAINT CK_ProductsPreventZeroID CHECK (P_ID > 0); 
ALTER TABLE tblKartrisPromotionParts ADD CONSTRAINT CK_PromotionPartsPreventZeroID CHECK (PP_ID > 0); 
ALTER TABLE tblKartrisPromotions ADD CONSTRAINT CK_PromotionsPreventZeroID CHECK (PROM_ID > 0); 
ALTER TABLE tblKartrisReviews ADD CONSTRAINT CK_ReviewsPreventZeroID CHECK (REV_ID > 0); 
ALTER TABLE tblKartrisSavedBaskets ADD CONSTRAINT CK_SavedBasketsPreventZeroID CHECK (SBSKT_ID > 0); 
ALTER TABLE tblKartrisSavedExports ADD CONSTRAINT CK_SavedExportsPreventZeroID CHECK (EXPORT_ID > 0); 
ALTER TABLE tblKartrisSearchHelper ADD CONSTRAINT CK_SearchHelperPreventZeroID CHECK (SH_ID > 0); 
ALTER TABLE tblKartrisSearchStatistics ADD CONSTRAINT CK_SearchStatisticsPreventZeroID CHECK (SS_ID > 0); 
ALTER TABLE tblKartrisSessions ADD CONSTRAINT CK_SessionsPreventZeroID CHECK (SESS_ID > 0); 
ALTER TABLE tblKartrisSessionValues ADD CONSTRAINT CK_SessionValuesPreventZeroID CHECK (SESSV_ID > 0); 
ALTER TABLE tblKartrisShippingMethods ADD CONSTRAINT CK_ShippingMethodsPreventZeroID CHECK (SM_ID > 0); 
ALTER TABLE tblKartrisShippingRates ADD CONSTRAINT CK_ShippingRatesPreventZeroID CHECK (S_ID > 0); 
ALTER TABLE tblKartrisShippingZones ADD CONSTRAINT CK_ShippingZonesPreventZeroID CHECK (SZ_ID > 0); 
ALTER TABLE tblKartrisStatistics ADD CONSTRAINT CK_StatisticsPreventZeroID CHECK (ST_ID > 0); 
ALTER TABLE tblKartrisSuppliers ADD CONSTRAINT CK_SuppliersPreventZeroID CHECK (SUP_ID > 0); 
ALTER TABLE tblKartrisSupportTicketMessages ADD CONSTRAINT CK_SupportTicketMessagesPreventZeroID CHECK (STM_ID > 0); 
ALTER TABLE tblKartrisSupportTickets ADD CONSTRAINT CK_SupportTicketsPreventZeroID CHECK (TIC_ID > 0); 
ALTER TABLE tblKartrisSupportTicketTypes ADD CONSTRAINT CK_SupportTicketTypesPreventZeroID CHECK (STT_ID > 0); 
ALTER TABLE tblKartrisTaxRates ADD CONSTRAINT CK_TaxRatesPreventZeroID CHECK (T_ID > 0); 
ALTER TABLE tblKartrisUsers ADD CONSTRAINT CK_UsersPreventZeroID CHECK (U_ID > 0); 
ALTER TABLE tblKartrisVersions ADD CONSTRAINT CK_VersionsPreventZeroID CHECK (V_ID > 0); 
ALTER TABLE tblKartrisWishLists ADD CONSTRAINT CK_WishListsPreventZeroID CHECK (WL_ID > 0); 
GO