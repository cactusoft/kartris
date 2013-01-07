/****** Object:  StoredProcedure [dbo].[_spKartrisDB_ExportOrders]    Script Date: 05/22/2012 16:37:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
	
	SET @Cmd = 'SELECT     tblKartrisOrders.O_ID, tblKartrisOrders.O_CustomerID, tblKartrisUsers.U_EmailAddress, tblKartrisUsers.U_AccountHolderName, tblKartrisOrders.O_ShippingPrice, 
						   tblKartrisOrders.O_ShippingTax, '
	
	IF @IncludeDetails = 1	BEGIN SET @Cmd = @Cmd + 'tblKartrisOrders.O_Details, ' END

	SET @Cmd = @Cmd + 'tblKartrisOrders.O_DiscountPercentage, tblKartrisOrders.O_AffiliatePercentage, tblKartrisOrders.O_TotalPrice, 
						  tblKartrisOrders.O_Date, tblKartrisOrders.O_PurchaseOrderNo, tblKartrisOrders.O_SecurityID, tblKartrisOrders.O_Sent, tblKartrisOrders.O_Invoiced, 
						  tblKartrisOrders.O_Shipped, tblKartrisOrders.O_Paid,tblKartrisOrders.O_Status, tblKartrisOrders.O_LastModified, tblKartrisOrders.O_WishListID, 
						  tblKartrisOrders.O_CouponCode, tblKartrisOrders.O_CouponDiscountTotal, tblKartrisOrders.O_PricesIncTax, tblKartrisOrders.O_TaxDue, 
						  tblKartrisOrders.O_PaymentGateWay, tblKartrisOrders.O_ReferenceCode, tblKartrisLanguages.LANG_BackName, tblKartrisCurrencies.CUR_Symbol, 
						  tblKartrisOrders.O_TotalPriceGateway, tblKartrisOrders.O_AffiliatePaymentID, tblKartrisOrders.O_AffiliateTotalPrice, tblKartrisOrders.O_SendOrderUpdateEmail
	FROM         tblKartrisOrders INNER JOIN
						  tblKartrisUsers ON tblKartrisOrders.O_CustomerID = tblKartrisUsers.U_ID INNER JOIN
						  tblKartrisLanguages ON tblKartrisOrders.O_LanguageID = tblKartrisLanguages.LANG_ID INNER JOIN
						  tblKartrisCurrencies ON tblKartrisOrders.O_CurrencyID = tblKartrisCurrencies.CUR_ID
	WHERE 1 = 1 '
	
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
ALTER PROCEDURE [dbo].[_spKartrisDeletedItems_Delete]
(
	@ID as bigint,
	@Type as char(1)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF @ID <> 0 AND @ID IN (SELECT DELETED_ID FROM dbo.tblKartrisDeletedItems WHERE Deleted_Type = @Type) BEGIN
		;
		DISABLE TRIGGER trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
		DELETE FROM dbo.tblKartrisDeletedItems WHERE Deleted_ID = @ID AND Deleted_Type = @Type;
		ENABLE TRIGGER trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
	END
END