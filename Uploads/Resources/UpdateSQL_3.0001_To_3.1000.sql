﻿/****** Object:  StoredProcedure [dbo].[_spKartrisDB_ExportOrders]    Script Date: 17/10/2019 11:00:52 ******/
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
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetByStatusCount]    Script Date: 20/01/2021 09:39:19 ******/
-- no longer include cancelled orders in DISPATCH count
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisOrders_GetByStatusCount]
(
	@Callmode varchar(10),
	@O_AffiliatePaymentID int = NULL,
	@O_DateRangeStart smalldatetime = NULL,
	@O_DateRangeEnd smalldatetime = NULL,
	@O_Gateway varchar(10) = NULL,
	@O_GatewayID varchar(30) = NULL
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
	DECLARE @O_CustomerID int;
	DECLARE @O_Cancelled bit ;
	
	IF @Callmode <> 'CUSTOMER'
	BEGIN
		SET @O_CustomerID = NULL;
	END	
	ELSE
		BEGIN
			SET @O_CustomerID = @O_GatewayID;
			SET @O_Sent = 1;
		END

	IF @Callmode <> 'AFFILIATE'
	BEGIN
		SET @O_AffiliatePaymentID = NULL;
	END

	IF @Callmode <> 'BYDATE'
		BEGIN
			SET @O_DateRangeStart = NULL;
			SET @O_DateRangeEnd = NULL;
		END
	ELSE
		BEGIN
			SET @O_Sent = 1;
		END

	IF @Callmode <> 'GATEWAY'
		BEGIN
			SET @O_Gateway = NULL;
			IF @Callmode <> 'SEARCH'
				BEGIN
					SET @O_GatewayID = NULL;
				END
		END;


	IF @Callmode = 'RECENT' OR @Callmode = 'INVOICE' OR @Callmode = 'DISPATCH' OR @Callmode = 'COMPLETE' OR @Callmode = 'PAYMENT' OR @Callmode = 'UNFINISHED' OR @Callmode = 'CANCELLED'
		BEGIN
		  IF @Callmode = 'RECENT'
			BEGIN
			  SELECT count(1) 
			  FROM         tblKartrisOrders LEFT OUTER JOIN
					tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
			  WHERE (O_Sent = 1)
			END

		  IF @Callmode = 'INVOICE'
			BEGIN
			  SELECT count(1) 
			  FROM         tblKartrisOrders LEFT OUTER JOIN
					tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
			  WHERE (O_Sent = 1) AND (O_Paid = 1) AND (O_Shipped = 0)
			END
		  IF @Callmode = 'DISPATCH'
			BEGIN
			  SELECT count(1) 
			  FROM         tblKartrisOrders LEFT OUTER JOIN
					tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
			  WHERE (O_Sent = 1) AND (O_Invoiced = 0) AND (O_Paid = 0) AND (O_Cancelled = 0)
			END
		  IF @Callmode = 'COMPLETE'
			BEGIN
			  SELECT count(1) 
			  FROM         tblKartrisOrders LEFT OUTER JOIN
					tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
			  WHERE (O_Paid = 1) AND (O_Shipped = 1)
			END
		  IF @Callmode = 'PAYMENT'
			BEGIN
			  SELECT count(1) 
			  FROM         tblKartrisOrders LEFT OUTER JOIN
					tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
			  WHERE (O_Sent = 1) AND (O_Invoiced = 1) AND (O_Paid = 0)
			END
		  IF @Callmode = 'UNFINISHED'
			BEGIN
			  SELECT count(1) 
			  FROM         tblKartrisOrders LEFT OUTER JOIN
					tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
			  WHERE (O_Sent = 0)
			END
		  IF @Callmode = 'CANCELLED'
			BEGIN
			  SELECT count(1) 
			  FROM         tblKartrisOrders LEFT OUTER JOIN
					tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
			  WHERE (O_Cancelled = 1)
			END
		  END
		ELSE
		IF @Callmode = 'SEARCH'
			BEGIN
				SELECT count(1) 
				FROM         tblKartrisOrders LEFT OUTER JOIN
					  tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
				WHERE     (O_BillingAddress LIKE '%' + @O_GatewayID + '%') OR (O_ShippingAddress LIKE '%' + @O_GatewayID + '%')
			END
		ELSE
			BEGIN
				SELECT count(1) 
				FROM         tblKartrisOrders LEFT OUTER JOIN
					  tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
				WHERE     (O_Sent = COALESCE (@O_Sent, O_Sent)) AND (O_AffiliatePaymentID = COALESCE (@O_AffiliatePaymentID, O_AffiliatePaymentID)) AND 
									  (O_Date >= COALESCE (@O_DateRangeStart, O_Date)) AND (O_Date <= COALESCE (@O_DateRangeEnd, O_Date)) AND (O_PaymentGateWay = COALESCE (@O_Gateway, O_PaymentGateWay)) 
										AND (O_ReferenceCode = COALESCE (@O_GatewayID, O_ReferenceCode)) AND (O_CustomerID = COALESCE (@O_CustomerID, O_CustomerID))
			END
END

GO

/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetByStatus]    Script Date: 20/01/2021 09:39:24 ******/
-- no longer include cancelled orders in DISPATCH
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisOrders_GetByStatus]
(
	@Callmode varchar(10),
	@O_AffiliatePaymentID int = NULL,
	@O_DateRangeStart smalldatetime = NULL,
	@O_DateRangeEnd smalldatetime = NULL,
	@O_Gateway varchar(10) = NULL,
	@O_GatewayID varchar(30) = NULL,
	@PageIndex as tinyint, -- 0 Based index
	@Limit smallint = 50
)
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @Limit) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @Limit - 1;

	DECLARE @O_Sent bit;
	DECLARE @O_Invoiced bit;
	DECLARE @O_Paid bit;
	DECLARE @O_Shipped bit ;
	DECLARE @O_CustomerID int;
	DECLARE @O_Cancelled bit ;

	IF @Callmode <> 'CUSTOMER'
	BEGIN
		SET @O_CustomerID = NULL;
	END	
	ELSE
		BEGIN
			SET @O_CustomerID = @O_GatewayID;
			SET @O_Sent = 1;
		END

	IF @Callmode <> 'AFFILIATE'
	BEGIN
		SET @O_AffiliatePaymentID = NULL;
	END

	IF @Callmode <> 'BYDATE'
		BEGIN
			SET @O_DateRangeStart = NULL;
			SET @O_DateRangeEnd = NULL;
		END
	ELSE
		BEGIN
			SET @O_Sent = 1;
		END

	IF @Callmode <> 'GATEWAY'
		BEGIN
			SET @O_Gateway = NULL;
			IF @Callmode <> 'SEARCH'
				BEGIN
					SET @O_GatewayID = NULL;
				END
		END;

	
		IF @Callmode = 'RECENT' OR @Callmode = 'INVOICE' OR @Callmode = 'DISPATCH' OR @Callmode = 'COMPLETE' OR @Callmode = 'PAYMENT' OR @Callmode = 'UNFINISHED' OR @Callmode = 'CANCELLED'
	BEGIN
	  IF @Callmode = 'RECENT'
		BEGIN
		  WITH OrdersList AS
		  (
		  SELECT     ROW_NUMBER() OVER (ORDER BY O_ID DESC) AS Row,O_ID, O_Date, O_TotalPrice, O_CustomerID, O_Sent, O_Invoiced, O_Shipped, O_Paid, O_Cancelled, O_CurrencyID, O_Status,
				substring(O_BillingAddress,0,charindex(char(13)+char(10),O_BillingAddress)) as O_BillingName,O_LanguageID, tblKartrisClonedOrders.CO_OrderID
		  FROM         tblKartrisOrders LEFT OUTER JOIN
				tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
		  WHERE     (O_Sent = 1)
		  )
		  SELECT *
		  FROM OrdersList
		  WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber;
		END
	  IF @Callmode = 'INVOICE'
		BEGIN
		  WITH OrdersList AS
		  (
		  SELECT     ROW_NUMBER() OVER (ORDER BY O_ID DESC) AS Row,O_ID, O_Date, O_TotalPrice, O_CustomerID, O_Sent, O_Invoiced, O_Shipped, O_Paid, O_Cancelled, O_CurrencyID, O_Status,
				substring(O_BillingAddress,0,charindex(char(13)+char(10),O_BillingAddress)) as O_BillingName,O_LanguageID, tblKartrisClonedOrders.CO_OrderID
		  FROM         tblKartrisOrders LEFT OUTER JOIN
				tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
		  WHERE     (O_Sent = 1) AND (O_Invoiced = 0) AND (O_Paid = 0)
		  )
		  SELECT *
		  FROM OrdersList
		  WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber;
		END
	  IF @Callmode = 'DISPATCH'
		BEGIN
		  WITH OrdersList AS
		  (
		  SELECT     ROW_NUMBER() OVER (ORDER BY O_ID DESC) AS Row,O_ID, O_Date, O_TotalPrice, O_CustomerID, O_Sent, O_Invoiced, O_Shipped, O_Paid, O_Cancelled, O_CurrencyID, O_Status,
				substring(O_BillingAddress,0,charindex(char(13)+char(10),O_BillingAddress)) as O_BillingName,O_LanguageID, tblKartrisClonedOrders.CO_OrderID
		  FROM         tblKartrisOrders LEFT OUTER JOIN
				tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
		  WHERE     (O_Sent = 1) AND (O_Paid = 1) AND (O_Shipped = 0) AND (O_Cancelled = 0)
		  )
		  SELECT *
		  FROM OrdersList
		  WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber;
		END
	  IF @Callmode = 'COMPLETE'
		BEGIN
		  WITH OrdersList AS
		  (
		  SELECT     ROW_NUMBER() OVER (ORDER BY O_ID DESC) AS Row,O_ID, O_Date, O_TotalPrice, O_CustomerID, O_Sent, O_Invoiced, O_Shipped, O_Paid, O_Cancelled, O_CurrencyID, O_Status,
				substring(O_BillingAddress,0,charindex(char(13)+char(10),O_BillingAddress)) as O_BillingName,O_LanguageID, tblKartrisClonedOrders.CO_OrderID
		  FROM         tblKartrisOrders LEFT OUTER JOIN
				tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
		  WHERE     (O_Paid = 1) AND (O_Shipped = 1)
		  )
		  SELECT *
		  FROM OrdersList
		  WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber;
		END
	  IF @Callmode = 'PAYMENT'
		BEGIN
		  WITH OrdersList AS
		  (
		  SELECT     ROW_NUMBER() OVER (ORDER BY O_ID DESC) AS Row,O_ID, O_Date, O_TotalPrice, O_CustomerID, O_Sent, O_Invoiced, O_Shipped, O_Paid, O_Cancelled, O_CurrencyID, O_Status,
				substring(O_BillingAddress,0,charindex(char(13)+char(10),O_BillingAddress)) as O_BillingName,O_LanguageID, tblKartrisClonedOrders.CO_OrderID
		  FROM         tblKartrisOrders LEFT OUTER JOIN
				tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
		  WHERE     (O_Sent = 1) AND (O_Invoiced = 1) AND (O_Paid = 0)
		  )
		  SELECT *
		  FROM OrdersList
		  WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber;
		END
	  IF @Callmode = 'UNFINISHED'
		BEGIN
		  WITH OrdersList AS
		  (
		  SELECT     ROW_NUMBER() OVER (ORDER BY O_ID DESC) AS Row,O_ID, O_Date, O_TotalPrice, O_CustomerID, O_Sent, O_Invoiced, O_Shipped, O_Paid, O_Cancelled, O_CurrencyID, O_Status,
				substring(O_BillingAddress,0,charindex(char(13)+char(10),O_BillingAddress)) as O_BillingName,O_LanguageID, tblKartrisClonedOrders.CO_OrderID
		  FROM         tblKartrisOrders LEFT OUTER JOIN
				tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
		  WHERE     (O_Sent = 0)
		  )
		  SELECT *
		  FROM OrdersList
		  WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber;
		END
	  IF @Callmode = 'CANCELLED'
		BEGIN
		  WITH OrdersList AS
		  (
		  SELECT     ROW_NUMBER() OVER (ORDER BY O_ID DESC) AS Row,O_ID, O_Date, O_TotalPrice, O_CustomerID, O_Sent, O_Invoiced, O_Shipped, O_Paid, O_Cancelled, O_CurrencyID, O_Status,
				substring(O_BillingAddress,0,charindex(char(13)+char(10),O_BillingAddress)) as O_BillingName,O_LanguageID, tblKartrisClonedOrders.CO_OrderID
		  FROM         tblKartrisOrders LEFT OUTER JOIN
				tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
		  WHERE     (O_Cancelled = 1)
		  )
		  SELECT *
		  FROM OrdersList
		  WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber;
		END
	  END
	ELSE
		IF @Callmode = 'SEARCH'
			BEGIN
				WITH OrdersList AS
			(
			SELECT ROW_NUMBER() OVER (ORDER BY O_ID DESC) AS Row,O_ID, O_Date, O_TotalPrice, O_CustomerID, O_Sent, O_Invoiced, O_Shipped, O_Paid, O_Cancelled, O_CurrencyID, O_Status,
						substring(O_BillingAddress,0,charindex(char(13)+char(10),O_BillingAddress)) as O_BillingName,O_LanguageID, tblKartrisClonedOrders.CO_OrderID
				FROM         tblKartrisOrders LEFT OUTER JOIN
					  tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
				WHERE     (O_BillingAddress LIKE '%' + @O_GatewayID + '%') OR (O_ShippingAddress LIKE '%' + @O_GatewayID + '%')
			)
			SELECT *
				FROM OrdersList
				WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber;
			END
		ELSE
		BEGIN
			WITH OrdersList AS
			(
			SELECT     ROW_NUMBER() OVER (ORDER BY O_ID DESC) AS Row,O_ID, O_Date, O_TotalPrice, O_CustomerID, O_Sent, O_Invoiced, O_Shipped, O_Paid, O_Cancelled, O_CurrencyID, O_Status,
						substring(O_BillingAddress,0,charindex(char(13)+char(10),O_BillingAddress)) as O_BillingName,O_LanguageID, tblKartrisClonedOrders.CO_OrderID
			FROM         tblKartrisOrders LEFT OUTER JOIN
					  tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
			WHERE     (O_Sent = COALESCE (@O_Sent, O_Sent)) AND (O_AffiliatePaymentID = COALESCE (@O_AffiliatePaymentID, O_AffiliatePaymentID)) AND 
								  (O_Date >= COALESCE (@O_DateRangeStart, O_Date)) AND (O_Date <= COALESCE (@O_DateRangeEnd, O_Date)) AND (O_PaymentGateWay = COALESCE (@O_Gateway, O_PaymentGateWay)) 
									AND (O_ReferenceCode = COALESCE (@O_GatewayID, O_ReferenceCode)) AND (O_CustomerID = COALESCE (@O_CustomerID, O_CustomerID))
			)
			SELECT *
				FROM OrdersList
				WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber;
		END

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

/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_CloneRecords]    Script Date: 06/05/2017 07:59:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	This is used when cloning
-- products... it does not clone the actual
-- product, it produces all the other associated
-- records such as versions, related products,
-- attributes, quantity discounts, customer
-- group prices and object config settings for
-- products and versions.
-- Updated 2020/01/30 to make sure final part
-- which clones the version language elements
-- puts both sets of version IDs into temp
-- tables in same order.
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisProducts_CloneRecords](
								@P_ID_OLD as int,
								@P_ID_NEW as int
								)
AS
BEGIN
	
	SET NOCOUNT ON;

-- CREATE VERSIONS	
INSERT INTO tblKartrisVersions
	 (V_CodeNumber, V_ProductID, V_Price, V_Tax, V_Weight, V_DeliveryTime, V_Quantity, V_QuantityWarnLevel, V_Live, V_DownLoadInfo, V_DownloadType, V_OrderByValue, V_RRP, V_Type, 
		V_CustomerGroupID, V_CustomizationType, V_CustomizationDesc, V_CustomizationCost, V_Tax2, V_TaxExtra)
SELECT dbo.fnKartrisVersions_CreateCloneName(V_CodeNumber), @P_ID_NEW, V_Price, V_Tax, V_Weight, V_DeliveryTime, V_Quantity, V_QuantityWarnLevel, V_Live, V_DownLoadInfo, V_DownloadType, V_OrderByValue, V_RRP, V_Type, 
		V_CustomerGroupID, V_CustomizationType, V_CustomizationDesc, V_CustomizationCost, V_Tax2, V_TaxExtra
FROM tblKartrisVersions WHERE V_ProductID=@P_ID_OLD ORDER BY V_ID

-- CREATE RELATED PRODUCTS
INSERT INTO tblKartrisRelatedProducts(RP_ParentID, RP_ChildID)
SELECT @P_ID_NEW, RP_ChildID
FROM tblKartrisRelatedProducts
WHERE (RP_ParentID = @P_ID_OLD)

-- CREATE OBJECT CONFIG SETTINGS - PRODUCTS
INSERT INTO tblKartrisObjectConfigValue(OCV_ObjectConfigID, OCV_ParentID, OCV_Value)
SELECT OCV_ObjectConfigID, @P_ID_NEW, OCV_Value
FROM tblKartrisObjectConfigValue INNER JOIN tblKartrisObjectConfig ON OCV_ObjectConfigID=OC_ID
WHERE (OCV_ParentID = @P_ID_OLD) AND OC_ObjectType='Product'

-- CREATE ATTRIBUTE VALUES
INSERT INTO tblKartrisAttributeValues(ATTRIBV_ProductID, ATTRIBV_AttributeID)
SELECT @P_ID_NEW, ATTRIBV_AttributeID
FROM tblKartrisAttributeValues
WHERE (ATTRIBV_ProductID = @P_ID_OLD)

-- COUNT ATTRIBUTES CREATED, LOOP THROUGH THEM
-- AND CREATE LANGUAGE ELEMENTS
-- in-memory temp versions table to hold distinct ATTRIBV_ID
DECLARE @i int
DECLARE @ATTRIBV_ID_OLD int
DECLARE @ATTRIBV_ID_NEW int

-- create and populate table with original product's attributes
DECLARE @tblKartrisAttributeValues_MEMORY_OLD TABLE (
	idx smallint Primary Key IDENTITY(1,1), ATTRIBV_ID int)
INSERT INTO @tblKartrisAttributeValues_MEMORY_OLD(ATTRIBV_ID)
SELECT DISTINCT ATTRIBV_ID FROM tblKartrisAttributeValues WHERE ATTRIBV_ProductID=@P_ID_OLD

-- create and populate table with new product's versions
DECLARE @tblKartrisAttributeValues_MEMORY_NEW TABLE (
	idx smallint Primary Key IDENTITY(1,1), ATTRIBV_ID int)
INSERT INTO @tblKartrisAttributeValues_MEMORY_NEW(ATTRIBV_ID)
SELECT DISTINCT ATTRIBV_ID FROM tblKartrisAttributeValues WHERE ATTRIBV_ProductID=@P_ID_NEW

DECLARE @numrows int
SET @i = 1

-- number of attributes, should be same in both tables but we just check NEW
SET @numrows = (SELECT COUNT(ATTRIBV_ProductID) FROM tblKartrisAttributeValues WHERE ATTRIBV_ProductID=@P_ID_NEW)
IF @numrows > 0
	WHILE (@i <= (SELECT MAX(idx) FROM @tblKartrisAttributeValues_MEMORY_NEW))
	BEGIN
		-- get the next version's ID, both old and new
		SET @ATTRIBV_ID_OLD = (SELECT ATTRIBV_ID FROM @tblKartrisAttributeValues_MEMORY_OLD WHERE idx= @i)
		SET @ATTRIBV_ID_NEW = (SELECT ATTRIBV_ID FROM @tblKartrisAttributeValues_MEMORY_NEW WHERE idx= @i)

		-- insert new language elements for this version ID
		INSERT INTO tblKartrisLanguageElements
		(LE_LanguageID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value)
		SELECT LE_LanguageID, LE_TypeID, LE_FieldID, @ATTRIBV_ID_NEW, LE_Value
		FROM tblKartrisLanguageElements
		WHERE (LE_ParentID = @ATTRIBV_ID_OLD) AND (LE_TypeID = 14)

		-- increment counter for next version
		SET @i = @i + 1
	END

	
-- COUNT VERSIONS CREATED, LOOP THROUGH THEM
-- AND CREATE LANGUAGE ELEMENTS
-- in-memory temp versions table to hold distinct V_ID
DECLARE @V_ID_OLD int
DECLARE @V_ID_NEW int

-- create and populate table with original product's versions
DECLARE @tblKartrisVersions_MEMORY_OLD TABLE (
	idx smallint Primary Key IDENTITY(1,1), V_ID int)
INSERT INTO @tblKartrisVersions_MEMORY_OLD(V_ID)
SELECT DISTINCT V_ID FROM tblKartrisVersions WHERE V_ProductID=@P_ID_OLD ORDER BY V_ID

-- create and populate table with new product's versions
DECLARE @tblKartrisVersions_MEMORY_NEW TABLE (
	idx smallint Primary Key IDENTITY(1,1), V_ID int)
INSERT INTO @tblKartrisVersions_MEMORY_NEW(V_ID)
SELECT DISTINCT V_ID FROM tblKartrisVersions WHERE V_ProductID=@P_ID_NEW ORDER BY V_ID

SET @i = 1

-- number of versions, should be same in both tables but we just check NEW
SET @numrows = (SELECT COUNT(V_ID) FROM tblKartrisVersions WHERE V_ProductID=@P_ID_NEW)
IF @numrows > 0
	WHILE (@i <= (SELECT MAX(idx) FROM @tblKartrisVersions_MEMORY_NEW))
	BEGIN
		-- get the next version's ID, both old and new
		SET @V_ID_OLD = (SELECT V_ID FROM @tblKartrisVersions_MEMORY_OLD WHERE idx= @i)
		SET @V_ID_NEW = (SELECT V_ID FROM @tblKartrisVersions_MEMORY_NEW WHERE idx= @i)

		-- insert new language elements for this version ID
		INSERT INTO tblKartrisLanguageElements
		(LE_LanguageID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value)
		SELECT LE_LanguageID, LE_TypeID, LE_FieldID, @V_ID_NEW, LE_Value
		FROM tblKartrisLanguageElements
		WHERE (LE_ParentID = @V_ID_OLD) AND (LE_TypeID = 1)

		-- insert new object config settings for this version
		INSERT INTO tblKartrisObjectConfigValue(OCV_ObjectConfigID, OCV_ParentID, OCV_Value)
		SELECT OCV_ObjectConfigID, @V_ID_NEW, OCV_Value
		FROM tblKartrisObjectConfigValue INNER JOIN tblKartrisObjectConfig ON OCV_ObjectConfigID=OC_ID
		WHERE (OCV_ParentID = @V_ID_OLD) AND OC_ObjectType='Version'

		-- insert customer group prices
		INSERT INTO tblKartrisCustomerGroupPrices
		(CGP_CustomerGroupID, CGP_VersionID, CGP_Price)
		SELECT CGP_CustomerGroupID, @V_ID_NEW, CGP_Price
		FROM tblKartrisCustomerGroupPrices
		WHERE (CGP_VersionID = @V_ID_OLD)

		-- insert quantity discounts
		INSERT INTO tblKartrisQuantityDiscounts
		(QD_VersionID, QD_Quantity, QD_Price)
		SELECT @V_ID_NEW, QD_Quantity, QD_Price
		FROM tblKartrisQuantityDiscounts
		WHERE (QD_VersionID = @V_ID_OLD)

		-- increment counter for next version
		SET @i = @i + 1
	END
END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_SearchProductsByName]    Script Date: 20/05/2020 12:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisProducts_SearchProductsByName]
(
	@Key as nvarchar(50),
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT        TOP(50) P_ID, P_Name
FROM            vKartrisTypeProductsLite
WHERE        (LANG_ID = @LANG_ID) AND P_Name LIKE @Key + '%'

GO


/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_UpdateCustomerGroupPriceList]    Script Date: 13/01/2021 11:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_UpdateCustomerGroupPriceList]
(
	@CG_ID as bigint,
	@CGP_VersionID as bigint,
	@CGP_Price as DECIMAL(18,4)
)								
AS
BEGIN
	
	SET NOCOUNT ON;

	if EXISTS(SELECT CGP_VersionID FROM dbo.tblKartrisCustomerGroupPrices WHERE CGP_VersionID = @CGP_VersionID AND CGP_CustomerGroupID = @CG_ID)
		BEGIN
			UPDATE dbo.tblKartrisCustomerGroupPrices
			SET CGP_Price = @CGP_Price WHERE CGP_VersionID = @CGP_VersionID AND CGP_CustomerGroupID = @CG_ID;
		END
	ELSE
	  BEGIN
		INSERT INTO dbo.tblKartrisCustomerGroupPrices (CGP_CustomerGroupID, CGP_VersionID, CGP_Price) VALUES (@CG_ID, @CGP_VersionID, @CGP_Price);
	  END



END

GO

/****** Object:  StoredProcedure [dbo].[spKartrisObjectConfig_SetValue]    Script Date: 09/02/2021 09:23:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	Front end, update object config
-- value by object config name.
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisObjectConfig_SetValue]
(
	@ParentID as bigint,
	@ConfigName as nvarchar(50),
	@ConfigValue as nvarchar(max)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ConfigID as int;
	SELECT  @ConfigID = OC_ID
	FROM    tblKartrisObjectConfig
	WHERE   (tblKartrisObjectConfig.OC_Name = @ConfigName);
	
	DECLARE @DefaultValue as nvarchar(max);
	SELECT  @DefaultValue = OC_DefaultValue
	FROM    tblKartrisObjectConfig
	WHERE   (tblKartrisObjectConfig.OC_ID = @ConfigID);
	
	DECLARE @Count as int;
	SELECT     @Count = Count(1)
	FROM         tblKartrisObjectConfigValue
	WHERE     (tblKartrisObjectConfigValue.OCV_ObjectConfigID = @ConfigID) AND (tblKartrisObjectConfigValue.OCV_ParentID = @ParentID);
	
	
	IF @Count = 1 BEGIN
		UPDATE  tblKartrisObjectConfigValue
		SET OCV_Value = @ConfigValue
		WHERE   (dbo.tblKartrisObjectConfigValue.OCV_ObjectConfigID = @ConfigID) AND (tblKartrisObjectConfigValue.OCV_ParentID = @ParentID)
	END ELSE BEGIN
		INSERT INTO dbo.tblKartrisObjectConfigValue
		VALUES (@ConfigID, @ParentID, @ConfigValue);
	END;
	
	-- Clear un-needed records (NULLs and Value is equal to default)
	DELETE FROM dbo.tblKartrisObjectConfigValue 
	WHERE (OCV_Value IS NULL) OR (OCV_Value = @DefaultValue AND OCV_ObjectConfigID = @ConfigID);
		
	
END
GO

/*** DELETE FLASH MEDIA TYPES  ***/
DELETE FROM [dbo].[tblKartrisMediaTypes] WHERE MT_ID =1 OR MT_ID=4
GO

/*** New language strings  ***/
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES
(N'f', N'ContentText_AccountBalance', N'Account Balance', NULL, 3.1000, N'Account Balance', NULL, N'Kartris',1);

INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES
(N'f', N'ContentText_EORI', N'EORI Number (if available)', NULL, 3.1000, N'EORI Number (if available)', NULL, N'Kartris',1);

GO

/*** OBJECT CONFIG  ***/
SET IDENTITY_INSERT [dbo].[tblKartrisObjectConfig] ON
INSERT [dbo].[tblKartrisObjectConfig] ([OC_ID], [OC_Name], [OC_ObjectType], [OC_DataType], [OC_DefaultValue], [OC_Description], [OC_MultilineValue], [OC_VersionAdded]) VALUES (11, N'K:user.eori', N'User', N's', N'', N'EORI number', 0, 3.0001)
INSERT [dbo].[tblKartrisObjectConfig] ([OC_ID], [OC_Name], [OC_ObjectType], [OC_DataType], [OC_DefaultValue], [OC_Description], [OC_MultilineValue], [OC_VersionAdded]) VALUES (12, N'K:product.commoditycode', N'Product', N's', N'', N'Commodity code (for EU imports)', 0, 3.0001)
SET IDENTITY_INSERT [dbo].[tblKartrisObjectConfig] OFF

/****** New config setting, lets countries like Portugal turn EU VAT field on for all orders in EU, even domestic ones ******/
INSERT INTO [tblKartrisConfig]
(CFG_Name,CFG_Value,CFG_DataType,CFG_DisplayType,CFG_DisplayInfo,CFG_Description,CFG_VersionAdded,CFG_DefaultValue,CFG_Important)
VALUES
(N'general.tax.domesticshowfield', N'n', N's', N'b', 'y|n',N'Whether to show the VAT field at checkout for domestic orders within EU',3.0001, N'n', 0);
GO

/****** New config setting, brexit related, turn on extended invoice info ******/
INSERT INTO [tblKartrisConfig]
(CFG_Name,CFG_Value,CFG_DataType,CFG_DisplayType,CFG_DisplayInfo,CFG_Description,CFG_VersionAdded,CFG_DefaultValue,CFG_Important)
VALUES
(N'general.orders.extendedinvoiceinfo', N'n', N's', N's', 'y|n',N'Extended item info on invoice',3.1000, N'n', 0);
GO

/* Change config setting */
UPDATE tblKartrisConfig SET CFG_DisplayInfo = 'n|e|s|t|c', CFG_Description='The display type for the featured products (front page specials) - [n]ormal/[e]xtended/[s]hortened/[t]abular/[c]arousel' WHERE CFG_Name='frontend.featuredproducts.display.default';
GO

/* Change language strings */
UPDATE tblKartrisLanguageStrings SET LS_ClassName = 'Login', LS_VirtualPath = '' WHERE LS_Name = 'SubTitle_ChangeCustomerCode';
UPDATE tblKartrisLanguageStrings SET LS_ClassName = 'Login', LS_VirtualPath = '' WHERE LS_Name = 'FormLabel_ExistingCustomerCode';
UPDATE tblKartrisLanguageStrings SET LS_ClassName = 'Login', LS_VirtualPath = '' WHERE LS_Name = 'FormLabel_NewCustomerCode';
UPDATE tblKartrisLanguageStrings SET LS_ClassName = 'Login', LS_VirtualPath = '' WHERE LS_Name = 'FormLabel_NewCustomerCodeRepeat';
UPDATE tblKartrisLanguageStrings SET LS_ClassName = 'Login', LS_VirtualPath = '' WHERE LS_Name = 'ContentText_CustomerCodesDifferent';

GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='3.1000', CFG_VersionAdded=3.1000 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO


