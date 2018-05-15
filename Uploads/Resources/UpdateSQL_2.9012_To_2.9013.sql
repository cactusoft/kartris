

/****** new GDPR functionality ******/
INSERT INTO [tblKartrisConfig]
(CFG_Name,CFG_Value,CFG_DataType,CFG_DisplayType,CFG_DisplayInfo,CFG_Description,CFG_VersionAdded,CFG_DefaultValue,CFG_Important)
VALUES
(N'general.gdpr.mailinglistbcc', N'', N's', N't', '', N'An email address to BCC mailing list confirmations to as proof of GDPR terms',2.9013, N'', 0);

GO

/****** Improve orders listing speed in back end ******/

/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetByStatus]    Script Date: 12/04/2018 15:23:04 ******/
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
		  WHERE     (O_Sent = 1) AND (O_Paid = 1) AND (O_Shipped = 0)
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
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetByStatusCount]    Script Date: 12/04/2018 16:05:21 ******/
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
			  WHERE (O_Sent = 1) AND (O_Invoiced = 0) AND (O_Paid = 0)
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


/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.9013', CFG_VersionAdded=2.9013 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO
