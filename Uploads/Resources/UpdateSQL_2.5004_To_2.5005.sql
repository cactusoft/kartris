
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetByID]    Script Date: 9/9/2013 3:29:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisOrders_GetByID]
(
	@OrderID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT        tblKartrisOrders.O_ID, tblKartrisOrders.O_CustomerID, tblKartrisOrders.O_Details, tblKartrisOrders.O_ShippingPrice, tblKartrisOrders.O_ShippingTax, 
						 tblKartrisOrders.O_DiscountPercentage, tblKartrisOrders.O_AffiliatePercentage, tblKartrisOrders.O_TotalPrice, tblKartrisOrders.O_Date, 
						 tblKartrisOrders.O_PurchaseOrderNo, tblKartrisOrders.O_SecurityID, tblKartrisOrders.O_Sent, tblKartrisOrders.O_Invoiced, tblKartrisOrders.O_Shipped, 
						 tblKartrisOrders.O_Paid, tblKartrisOrders.O_Status, tblKartrisOrders.O_LastModified, tblKartrisOrders.O_WishListID, tblKartrisOrders.O_CouponCode, 
						 tblKartrisOrders.O_CouponDiscountTotal, tblKartrisOrders.O_PricesIncTax, tblKartrisOrders.O_TaxDue, tblKartrisOrders.O_PaymentGateWay, 
						 tblKartrisOrders.O_ReferenceCode, tblKartrisOrders.O_LanguageID, tblKartrisOrders.O_CurrencyID, tblKartrisOrders.O_TotalPriceGateway, 
						 tblKartrisOrders.O_CurrencyIDGateway, tblKartrisOrders.O_AffiliatePaymentID, tblKartrisOrders.O_AffiliateTotalPrice, 
						 tblKartrisOrders.O_SendOrderUpdateEmail, tblKartrisOrders.O_OrderHandlingCharge, tblKartrisOrders.O_OrderHandlingChargeTax, 
						 tblKartrisOrders.O_CurrencyRate, tblKartrisOrders.O_ShippingMethod, tblKartrisOrders.O_BillingAddress, tblKartrisOrders.O_ShippingAddress, 
						 tblKartrisOrders.O_PromotionDiscountTotal, tblKartrisOrders.O_PromotionDescription, tblKartrisOrders.O_SentToQB, tblKartrisOrders.O_Notes, 
						 tblKartrisOrders.O_Data, tblKartrisOrders.O_Comments, tblKartrisOrders.O_Cancelled, tblKartrisCurrencies.CUR_ISOCode, tblKartrisUsers.U_EmailAddress, 
						 tblKartrisUsers.U_AccountHolderName, tblKartrisUsers.U_Telephone
FROM            tblKartrisUsers INNER JOIN
						 tblKartrisOrders ON tblKartrisUsers.U_ID = tblKartrisOrders.O_CustomerID INNER JOIN
						 tblKartrisCurrencies ON tblKartrisOrders.O_CurrencyID = tblKartrisCurrencies.CUR_ID
WHERE        (tblKartrisOrders.O_ID = @OrderID)
END

GO

/****** Object:  StoredProcedure [dbo].[_spKartrisInvoiceRows_GetByOrderID]    Script Date: 9/9/2013 3:29:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisInvoiceRows_GetByOrderID]
(
	@OrderID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT tblKartrisInvoiceRows.IR_ID, tblKartrisInvoiceRows.IR_VersionCode, tblKartrisInvoiceRows.IR_VersionName, tblKartrisInvoiceRows.IR_Quantity, 
		   tblKartrisInvoiceRows.IR_PricePerItem, tblKartrisInvoiceRows.IR_TaxPerItem, tblKartrisInvoiceRows.IR_OptionsText, tblKartrisTaxRates.T_Taxrate
	FROM   tblKartrisVersions INNER JOIN
		   tblKartrisTaxRates ON tblKartrisVersions.V_Tax = tblKartrisTaxRates.T_ID INNER JOIN
		   tblKartrisInvoiceRows ON tblKartrisVersions.V_CodeNumber = tblKartrisInvoiceRows.IR_VersionCode 
	WHERE IR_OrderNumberID = @OrderID;
END

GO

/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_UpdateStockLevelByCode]    Script Date: 9/9/2013 3:29:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_UpdateStockLevelByCode]
(
	@V_CodeNumber as nvarchar(25),
	@V_Quantity as real,
	@V_QuantityWarnLevel as real = NULL
)							
AS
BEGIN
	
	SET NOCOUNT ON;

	UPDATE tblKartrisVersions
	SET V_Quantity = @V_Quantity, V_QuantityWarnLevel = ISNULL(@V_QuantityWarnLevel, V_QuantityWarnLevel)
	WHERE V_CodeNumber = @V_CodeNumber;

END

GO

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
	@NoCustomersInArrears as int OUTPUT
)
AS
BEGIN
	SELECT @NoOrdersToInvoice = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Invoiced = 'False' AND O_Paid = 'False' AND O_Sent = 'True' AND O_Cancelled = 'False';
	SELECT @NoOrdersNeedPayment = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Paid = 'False' AND O_Invoiced = 'True' AND O_Sent = 'True' AND O_Cancelled = 'False';
	SELECT @NoOrdersToDispatch = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Sent = 'True' AND O_Paid = 'True' AND O_Shipped = 'False' AND O_Cancelled = 'False';
	
	SELECT @NoStockWarnings = Count(DISTINCT V_ID) FROM dbo.vKartrisProductsVersions WHERE V_QuantityWarnLevel >= V_Quantity AND V_QuantityWarnLevel <> 0;
	SELECT @NoOutOfStock = Count(DISTINCT V_ID) FROM dbo.vKartrisProductsVersions WHERE V_Quantity = 0 AND V_QuantityWarnLevel <> 0;

	SELECT @NoReviewsWaiting = Count(REV_ID) FROM dbo.tblKartrisReviews WHERE REV_Live = 'a';
	SELECT @NoAffiliatesWaiting  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_IsAffiliate = 'True' AND U_AffiliateCommission = 0;
	SELECT @NoCustomersWaitingRefunds  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_CustomerBalance > 0;
	SELECT @NoCustomersInArrears  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_CustomerBalance < 0;
END

GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetTileAppData]    Script Date: 10/08/2013 09:02:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisOrders_GetTileAppData]
(
	@Sent varchar(5),
	@Invoiced varchar(5),
	@Paid varchar(5),
	@Shipped varchar(5),
	@Cancelled varchar(5),
	@DateRangeStart smalldatetime = NULL,
	@DateRangeEnd smalldatetime = NULL,
	@RangeInMinutes int = NULL
)
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @O_Sent bit;
	DECLARE @O_Invoiced bit;
	DECLARE @O_Paid bit;
	DECLARE @O_Shipped bit ;
	DECLARE @O_Cancelled bit ;
	
	IF @Sent = 'true'
	BEGIN
		SET @O_Sent = 1;
	END
	ELSE IF @Sent = 'false'
	BEGIN
		SET @O_Sent = 0;
	END
	ELSE
	BEGIN
		SET @O_Sent = NULL;
	END
	
	IF @Invoiced = 'true'
	BEGIN
		SET @O_Invoiced = 1;
	END
	ELSE IF @Invoiced = 'false'
	BEGIN
		SET @O_Invoiced = 0;
	END
	ELSE
	BEGIN
		SET @O_Invoiced = NULL;
	END
	
	IF @Paid = 'true'
	BEGIN
		SET @O_Paid = 1;
	END
	ELSE IF @Paid = 'false'
	BEGIN
		SET @O_Paid = 0;
	END
	ELSE
	BEGIN
		SET @O_Paid = NULL;
	END
	
	IF @Shipped = 'true'
	BEGIN
		SET @O_Shipped = 1;
	END
	ELSE IF @Shipped = 'false'
	BEGIN
		SET @O_Shipped = 0;
	END
	ELSE
	BEGIN
		SET @O_Shipped = NULL;
	END
	
	IF @Cancelled = 'true'
	BEGIN
		SET @O_Cancelled = 1;
	END
	ELSE IF @Cancelled = 'false'
	BEGIN
		SET @O_Cancelled = 0;
	END
	ELSE
	BEGIN
		SET @O_Cancelled = NULL;
	END

	IF @RangeInMinutes > 0
		BEGIN
			SET @DateRangeEnd = GETDATE();
			SET @DateRangeStart = DATEADD(MI,-@RangeInMinutes,@DateRangeEnd);
			
		END
	
	
	BEGIN
		SELECT      ROW_NUMBER() OVER (ORDER BY O_ID DESC) AS Row, tblKartrisOrders.O_ID, tblKartrisOrders.O_Date, tblKartrisOrders.O_TotalPrice, tblKartrisOrders.O_CustomerID, tblKartrisOrders.O_Sent, tblKartrisOrders.O_Invoiced, tblKartrisOrders.O_Shipped, 
					  tblKartrisOrders.O_Paid, tblKartrisOrders.O_Cancelled, tblKartrisOrders.O_CurrencyID, SUBSTRING(tblKartrisOrders.O_BillingAddress, 0, CHARINDEX(CHAR(13) + CHAR(10), 
					  tblKartrisOrders.O_BillingAddress)) AS O_BillingName, REPLACE(tblKartrisOrders.O_BillingAddress,CHAR(13) + CHAR(10),'-*-') as O_BillingAddress, tblKartrisOrders.O_LanguageID, tblKartrisClonedOrders.CO_OrderID, tblKartrisCurrencies.CUR_Symbol, 
					  tblKartrisCurrencies.CUR_ISOCode, tblKartrisOrders.O_PaymentGateway
FROM         tblKartrisOrders LEFT OUTER JOIN
					  tblKartrisCurrencies ON tblKartrisOrders.O_CurrencyID = tblKartrisCurrencies.CUR_ID LEFT OUTER JOIN
					  tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
WHERE     (tblKartrisOrders.O_Sent = COALESCE (@O_Sent, tblKartrisOrders.O_Sent)) AND (tblKartrisOrders.O_Invoiced = COALESCE (@O_Invoiced, tblKartrisOrders.O_Invoiced)) AND 
					  (tblKartrisOrders.O_Paid = COALESCE (@O_Paid, tblKartrisOrders.O_Paid)) AND (tblKartrisOrders.O_Shipped = COALESCE (@O_Shipped, tblKartrisOrders.O_Shipped)) AND 
					  (tblKartrisOrders.O_Cancelled = COALESCE (@O_Cancelled, tblKartrisOrders.O_Cancelled)) AND (tblKartrisOrders.O_Date >= COALESCE (@DateRangeStart, tblKartrisOrders.O_Date)) AND 
					  (tblKartrisOrders.O_Date <= COALESCE (@DateRangeEnd, tblKartrisOrders.O_Date))
		
	END
		
END