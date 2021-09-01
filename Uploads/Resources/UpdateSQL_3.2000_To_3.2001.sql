
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetByStatusCount]    Script Date: 30/08/2021 10:42:49 ******/
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

	SET @O_Cancelled = 0;

	IF @Callmode = 'RECENT'
	BEGIN
		SET @O_Sent = 1;
	END
	
	ELSE IF @Callmode = 'INVOICE'
	BEGIN
		SET @O_Sent = 1;
		SET @O_Paid = 0;
		SET @O_Invoiced = 0;
	END
	
	ELSE IF @Callmode = 'DISPATCH'
	BEGIN
		SET @O_Sent = 1; 
		SET @O_Paid = 1;
		SET @O_Shipped = 0;
	END

	ELSE IF @Callmode = 'COMPLETE'
	BEGIN
		SET @O_Paid = 1;
		SET @O_Shipped = 1;
	END
	
	ELSE IF @Callmode = 'PAYMENT'
	BEGIN
		SET @O_Sent = 1; 
		SET @O_Paid = 0; 
		SET @O_Invoiced = 1;
	END
	
	ELSE IF @Callmode = 'UNFINISHED'
	BEGIN
		SET @O_Sent = 0;
	END

	ELSE IF @Callmode = 'CANCELLED'
	BEGIN
		SET @O_Cancelled = 1;
	END
	
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
			WITH OrdersList AS
			(
				SELECT     O_ID
				FROM         tblKartrisOrders LEFT OUTER JOIN
						  tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
				WHERE     (O_Sent = COALESCE (@O_Sent, O_Sent)) AND (O_Invoiced = COALESCE (@O_Invoiced, O_Invoiced)) AND (O_Paid = COALESCE (@O_Paid, O_Paid)) AND 
									  (O_Shipped = COALESCE (@O_Shipped, O_Shipped)) AND (O_Cancelled = COALESCE (@O_Cancelled, O_Cancelled))
			)
			SELECT Count(1)
			FROM OrdersList
		END
	ELSE
		IF @Callmode = 'SEARCH'
			BEGIN
				WITH OrdersList AS
			(
				SELECT     O_ID
				FROM         tblKartrisOrders LEFT OUTER JOIN
					  tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
				WHERE     (O_BillingAddress LIKE '%' + @O_GatewayID + '%') OR (O_ShippingAddress LIKE '%' + @O_GatewayID + '%')
			)
			SELECT Count(1)
			FROM OrdersList
			END
		ELSE
		BEGIN
			WITH OrdersList AS
			(
				SELECT     O_ID
				FROM         tblKartrisOrders LEFT OUTER JOIN
						  tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
				WHERE     (O_Sent = COALESCE (@O_Sent, O_Sent)) AND (O_AffiliatePaymentID = COALESCE (@O_AffiliatePaymentID, O_AffiliatePaymentID)) AND 
									  (O_Date >= COALESCE (@O_DateRangeStart, O_Date)) AND (O_Date <= COALESCE (@O_DateRangeEnd, O_Date)) AND (O_PaymentGateWay = COALESCE (@O_Gateway, O_PaymentGateWay)) 
										AND (O_ReferenceCode = COALESCE (@O_GatewayID, O_ReferenceCode)) AND (O_CustomerID = COALESCE (@O_CustomerID, O_CustomerID))
			)
			SELECT Count(1)
			FROM OrdersList
		END
		
END
GO

/****** Object:  StoredProcedure [dbo].[spKartrisBasket_GetCustomerOrders]    Script Date: 31/08/2021 18:10:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: 31/08/2021
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisBasket_GetCustomerOrders] ( 
	@intType smallint,
	@CustomerID int,
	@PageIndexStart int=0,
	@PageIndexEnd int=0
) 
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @cnt bigint

	If @intType=0
	Begin
		select @cnt=count(O_ID) from tblKartrisOrders O 
			inner join tblKartrisCurrencies C on O.O_CurrencyID=C.CUR_ID
		where O_Sent=1 and O_Cancelled=0 and O_CustomerID=@CustomerID
		select isnull(@cnt,0)'TotalRec'
	End	
	Else
	Begin
		select * from (
			select ROW_NUMBER() OVER (ORDER BY O_Date desc) as RowNum,O_ID,O_Date,O_LastModified,O_TotalPrice,O_PromotionDiscountTotal,O_CouponDiscountTotal,O_DiscountPercentage,O_ShippingPrice,O_OrderHandlingCharge,O_OrderHandlingChargeTax,O_CurrencyID,O_Sent,O_Invoiced,O_Paid,CUR_Symbol,CUR_RoundNumbers from tblKartrisOrders O
			inner join tblKartrisCurrencies C on O.O_CurrencyID=C.CUR_ID
			where O_Sent=1 and O_Cancelled=0 and O_CustomerID=@CustomerID
		) ORD 
		WHERE RowNum>=@PageIndexStart AND RowNum<=@PageIndexEnd 
	End

END
GO

/* Small change to Google analytics config setting, this is so we can add further Google services under same branch. Neater. */
UPDATE tblKartrisConfig SET CFG_Name='general.google.analytics.webpropertyid' WHERE CFG_Name='general.googleanalytics.webpropertyid'

/****** New config setting, google tag manager ******/
INSERT INTO [tblKartrisConfig]
(CFG_Name,CFG_Value,CFG_DataType,CFG_DisplayType,CFG_DisplayInfo,CFG_Description,CFG_VersionAdded,CFG_DefaultValue,CFG_Important)
VALUES
(N'general.google.tagmanager.webpropertyid', N'', N's', N's', '',N'The web property ID of the site in Google Tag Manager ',3.2001, N'GTM-9XXXXXX', 0);
GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='3.2001', CFG_VersionAdded=3.2001 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO


