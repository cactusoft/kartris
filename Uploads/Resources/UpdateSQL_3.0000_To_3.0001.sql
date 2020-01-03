/****** Object:  StoredProcedure [dbo].[_spKartrisDB_ExportOrders]    Script Date: 17/10/2019 11:00:52 ******/
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
							tblKartrisOrders.O_Date 
							'
	
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
							tblKartrisOrders.O_Shipped, tblKartrisOrders.O_Paid,tblKartrisOrders.O_Status, tblKartrisOrders.O_LastModified, tblKartrisOrders.O_WishListID, 
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

GO

/****** Object:  Index [OrderID]    Script Date: 20/12/2019 10:12:50 ******/
CREATE NONCLUSTERED INDEX [OrderID] ON [dbo].[tblKartrisOrdersPromotions]
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [OP_OrderID]    Script Date: 20/12/2019 10:25:49 ******/
CREATE NONCLUSTERED INDEX [OP_OrderID] ON [dbo].[tblKartrisOrderPaymentLink]
(
	[OP_OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/* Add delay of a second after creating user, before updating for guest account */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spKartrisUsers_Add]
(
		   @U_EmailAddress nvarchar(100),
		   @U_Password nvarchar(64),
		   @U_SaltValue nvarchar(64),
		   @U_GDPR_SignupIP nvarchar(50),
		   @U_GDPR_IsGuest bit
)
AS
DECLARE @U_ID INT
	SET NOCOUNT OFF;

	-- If is a guest checkout, we're
	-- going to append |GUEST| to the end
	-- of the email. This should ensure it
	-- is unique if there is already an 
	-- account with the same email.
	If @U_GDPR_IsGuest = 1
	BEGIN
		SET @U_EmailAddress = @U_EmailAddress + '|GUEST|'
	END

	INSERT INTO [tblKartrisUsers]
		   ([U_EmailAddress]
		   ,[U_Password]
		   ,[U_LanguageID]
			,[U_CustomerGroupID]
			,[U_DefShippingAddressID]
			,[U_DefBillingAddressID]
			,[U_CustomerDiscount]
			,[U_SaltValue]
			,[U_GDPR_SignupIP]
			,[U_GDPR_IsGuest])
	 VALUES
		   (@U_EmailAddress,
			@U_Password,
			1,0,0,0,0,
			@U_SaltValue,
			@U_GDPR_SignupIP,
			@U_GDPR_IsGuest);
	SET @U_ID = SCOPE_IDENTITY();

	-- Let's update the new record's email address to add the
	-- db ID. This ensures that multiple guest records for a
	-- single email can be created, without violating the need
	-- for unique addresses.
	If @U_GDPR_IsGuest = 1
	BEGIN
		WAITFOR DELAY '00:00:01'; -- one second delay, should ensure record is there before we update
		UPDATE tblKartrisUsers SET U_EmailAddress = U_EmailAddress + Convert(NVARCHAR(50), @U_ID)
		WHERE U_ID=@U_ID;
	END

	SELECT @U_ID;

GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='3.0001', CFG_VersionAdded=3.0001 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO


