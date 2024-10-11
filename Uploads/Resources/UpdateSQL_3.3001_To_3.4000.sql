
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_ExportOrders]    Script Date: 2024-09-03 21:54:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	Now pulls tax and value from
-- XML basket object saved with order
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisDB_ExportOrders]
(
	@StartDate as nvarchar(100),
	@EndDate as nvarchar(100),
	@IncludeDetails as bit,
	@IncludeIncomplete as bit
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Cmd as nvarchar(MAX);
	
   SET @Cmd = 'SELECT tblKartrisOrders.O_ID,
                        tblKartrisOrders.O_CustomerID,
                        tblKartrisUsers.U_EmailAddress,
                        tblKartrisUsers.U_AccountHolderName, 
                        FORMAT(tblKartrisOrders.O_Date, ''yyyy-MM-dd'') AS O_Date '
	
	IF @IncludeDetails = 1	BEGIN

	SET @Cmd = @Cmd +		', Cast(Round((SELECT CASE
								WHEN tblKartrisOrders.O_PricesIncTax = 1
								   THEN
										(SELECT Round(SUM(IR_PricePerItem * IR_Quantity),4) FROM tblKartrisInvoiceRows WHERE IR_OrderNumberID=tblKartrisOrders.O_ID) - (SELECT SUM(IR_TaxPerItem * IR_Quantity) FROM tblKartrisInvoiceRows WHERE IR_OrderNumberID=tblKartrisOrders.O_ID)
								   ELSE
										(SELECT Round(SUM(IR_PricePerItem * IR_Quantity),4) FROM tblKartrisInvoiceRows WHERE IR_OrderNumberID=tblKartrisOrders.O_ID)
							END), 4) As Decimal(18,4)) As ItemsExTax,

							Cast(Round((SELECT Round(SUM(IR_TaxPerItem * IR_Quantity),4) FROM tblKartrisInvoiceRows WHERE IR_OrderNumberID=tblKartrisOrders.O_ID), 4) As Decimal(18,4))
							As ItemsTax,

							Cast(SUBSTRING(O_Data,CHARINDEX(''|||'', O_Data) + 3, CHARINDEX(''</Basket>'', O_Data) - (CHARINDEX(''|||'', O_Data) + 3 - 9)) As XML).value(''(Basket/CouponDiscount/ExTax)[1]'', ''decimal(18,4)'') as CouponDiscountExTax,
						   
							Cast(SUBSTRING(O_Data,CHARINDEX(''|||'', O_Data) + 3, CHARINDEX(''</Basket>'', O_Data) - (CHARINDEX(''|||'', O_Data) + 3 - 9)) As XML).value(''(Basket/CouponDiscount/IncTax)[1]'', ''decimal(18,4)'') -
							Cast(SUBSTRING(O_Data,CHARINDEX(''|||'', O_Data) + 3, CHARINDEX(''</Basket>'', O_Data) - (CHARINDEX(''|||'', O_Data) + 3 - 9)) As XML).value(''(Basket/CouponDiscount/ExTax)[1]'', ''decimal(18,4)'') as CouponDiscountTax,

							Cast(SUBSTRING(O_Data,CHARINDEX(''|||'', O_Data) + 3, CHARINDEX(''</Basket>'', O_Data) - (CHARINDEX(''|||'', O_Data) + 3 - 9)) As XML).value(''(Basket/PromotionDiscount/ExTax)[1]'', ''decimal(18,4)'') as PromotionDiscountExTax,
						   
							Cast(SUBSTRING(O_Data,CHARINDEX(''|||'', O_Data) + 3, CHARINDEX(''</Basket>'', O_Data) - (CHARINDEX(''|||'', O_Data) + 3 - 9)) As XML).value(''(Basket/PromotionDiscount/IncTax)[1]'', ''decimal(18,4)'') -
							Cast(SUBSTRING(O_Data,CHARINDEX(''|||'', O_Data) + 3, CHARINDEX(''</Basket>'', O_Data) - (CHARINDEX(''|||'', O_Data) + 3 - 9)) As XML).value(''(Basket/PromotionDiscount/ExTax)[1]'', ''decimal(18,4)'') as PromotionDiscountTax,

							Cast(SUBSTRING(O_Data,CHARINDEX(''|||'', O_Data) + 3, CHARINDEX(''</Basket>'', O_Data) - (CHARINDEX(''|||'', O_Data) + 3 - 9)) As XML).value(''(Basket/ShippingPrice/ExTax)[1]'', ''decimal(18,4)'') as ShippingPriceExTax,
							Cast(tblKartrisOrders.O_ShippingTax As Decimal(18,4)) As O_ShippingTax, 
							Cast(tblKartrisOrders.O_TotalPrice As Decimal(18,4)) As O_TotalPrice,
							tblKartrisOrders.O_DiscountPercentage, tblKartrisOrders.O_AffiliatePercentage, 
							tblKartrisOrders.O_PurchaseOrderNo, tblKartrisOrders.O_SecurityID, tblKartrisOrders.O_Sent, tblKartrisOrders.O_Invoiced, 
							tblKartrisOrders.O_Shipped, tblKartrisOrders.O_Paid,tblKartrisOrders.O_Status, FORMAT(tblKartrisOrders.O_LastModified, ''yyyy-MM-dd'') AS O_LastModified, tblKartrisOrders.O_WishListID, 
							tblKartrisOrders.O_CouponCode, tblKartrisOrders.O_CouponDiscountTotal, tblKartrisOrders.O_PricesIncTax, tblKartrisOrders.O_TaxDue, 
							tblKartrisOrders.O_PaymentGateWay, tblKartrisOrders.O_ReferenceCode, tblKartrisLanguages.LANG_BackName, tblKartrisCurrencies.CUR_Symbol, 
							tblKartrisOrders.O_TotalPriceGateway, tblKartrisOrders.O_AffiliatePaymentID, tblKartrisOrders.O_AffiliateTotalPrice, tblKartrisOrders.O_SendOrderUpdateEmail '
	END

	SET @Cmd = @Cmd + ' FROM tblKartrisOrders INNER JOIN
							tblKartrisUsers ON tblKartrisOrders.O_CustomerID = tblKartrisUsers.U_ID INNER JOIN
							tblKartrisLanguages ON tblKartrisOrders.O_LanguageID = tblKartrisLanguages.LANG_ID INNER JOIN
							tblKartrisCurrencies ON tblKartrisOrders.O_CurrencyID = tblKartrisCurrencies.CUR_ID
							WHERE left(O_Data, 5) = ''<?xml'' '
	
	IF (@StartDate IS NOT NULL) AND (@EndDate IS NOT NULL)
	BEGIN
		IF (isnumeric(@StartDate) = 1) AND (isnumeric(@EndDate) = 1)
			BEGIN
				SET @Cmd = @Cmd + ' AND O_ID > (CAST(' + @StartDate + ' as int)-1) AND O_ID < (CAST('  + @EndDate + ' as int)+1)'
			END
		ELSE
			BEGIN
				SET @Cmd = @Cmd + ' AND O_Date BETWEEN CAST(''' + @StartDate + ''' as DateTime) AND CAST('''  + @EndDate + ''' as DateTime)'
			END
		
	END
	IF @IncludeIncomplete = 0 OR @IncludeIncomplete IS NULL
	BEGIN
		SET @Cmd = @Cmd + ' AND O_Paid = 1 '
	END

	SET @Cmd = @Cmd + ' ORDER BY O_Date'
	
	EXECUTE(@Cmd);
	
	
END


/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='3.4000', CFG_VersionAdded=3.4000 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO

PRINT '-------------------------------------------------------'
PRINT 'That''s all folks! Looks like we reached the end....'
PRINT '-------------------------------------------------------'
