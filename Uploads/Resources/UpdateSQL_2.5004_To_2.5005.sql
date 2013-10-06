/****** Object:  Table [dbo].[tblKartrisLinnworksOrders]    Script Date: 9/9/2013 3:29:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblKartrisLinnworksOrders](
	[LWO_OrderID] [int] NOT NULL,
	[LWO_LinnworksGuid] [nvarchar](50) NULL,
	[LWO_DataCreated] [smalldatetime] NULL,
 CONSTRAINT [PK_tblKartrisLinnworksOrders] PRIMARY KEY CLUSTERED 
(
	[LWO_OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES (N'general.linnworks.token', N'', N's', N's', N'AUTO GUID TOKEN', N'[DO NOT UPDATE MANUALLY] 
Encrypted token for Linnworks Web Services. Go to the Linnworks Integration page if you want to change this.

[Miscellaneous] -> [Linnworks Integration].', 2.5005, NULL, 0);
GO
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'BackMenu_Linnworks', N'Linnworks Integration', NULL, 2.5005, N'Linnworks Integration', NULL, N'_Kartris', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_Available', N'Available', NULL, 2.5005, N'Available', NULL, N'_Kartris', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_DateSent', N'Date Sent', NULL, 2.5005, N'Date Sent', NULL, N'_Kartris', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_InOrderBook', N'In Order Book', NULL, 2.5005, N'In Order Book', NULL, N'_Linnworks', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_InvalidToken', N'The saved token is not valid. Please, provide your Linnworks details to generate a new token.', NULL, 2.5005, N'The saved token is not valid. Please, provide your Linnworks details to generate a new token.', NULL, N'_Linnworks', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_Level', N'Level', NULL, 2.5005, N'Level', NULL, N'_Kartris', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_LinnworksOrders', N'Linnworks Orders', NULL, 2.5005, N'Linnworks Orders', NULL, N'_Linnworks', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_LinnworksStockLevel', N'Linnworks Stock Level', NULL, 2.5005, N'Linnworks Stock Level', NULL, N'_Linnworks', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_NoSavedToken', N'There is no saved token. Please, provide your Linnworks details to generate a new token.', NULL, 2.5005, N'There is no saved token. Please, provide your Linnworks details to generate a new token.', NULL, N'_Linnworks', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_OnOrder', N'On Order', NULL, 2.5005, N'On Order', NULL, N'_Linnworks', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_PendingOrders', N'Pending/Paid Orders', NULL, 2.5005, N'Pending/Paid Orders', NULL, N'_Linnworks', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_SelectNone', N'Select None', NULL, 2.5005, N'Select None', NULL, N'_Kartris', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_SendToLinnworks', N'Send To Linnworks', NULL, 2.5005, N'Send To Linnworks', NULL, N'_Linnworks', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_StockSyncDisabled', N'Stock synchronization has been disabled. Please send all pending orders to Linnworks to be able to syncronize the stock levels.', NULL, 2.5005, N'Stock synchronization has been disabled. Please send all pending orders to Linnworks to be able to syncronize the stock levels.', NULL, N'_Linnworks', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_SyncSelected', N'Synchronize Selected', NULL, 2.5005, N'Synchronize Selected', NULL, N'_Linnworks', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'PageTitle_LinnworksIntegration', N'Linnworks Integration', NULL, 2.5005, N'Linnworks Integration', NULL, N'_Linnworks', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_Linnworks', N'Linnworks', NULL, 2.5005, N'Linnworks', NULL, N'_Linnworks', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_OrdersToSend', N'Orders To Send:', NULL, 2.5004, N'Orders To Send:', NULL, N'_Linnworks', 1);
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetLinnworksPending]    Script Date: 9/9/2013 3:29:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===================================================
-- Author:		Medz
-- Create date: 
-- Description:	
-- ===================================================
CREATE PROCEDURE [dbo].[_spKartrisOrders_GetLinnworksPending]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT        tblKartrisOrders.*,
	substring(O_BillingAddress,0,charindex(char(13)+char(10),O_BillingAddress)) as O_BillingName
FROM            tblKartrisOrders
WHERE        (O_Paid = 1) AND (O_Cancelled IS NULL or O_Cancelled = 0)
AND O_ID NOT IN (SELECT [LWO_OrderID] FROM [dbo].[tblKartrisLinnworksOrders])
END

GO

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

/****** Object:  StoredProcedure [dbo].[_spKartrisLinnworksOrders_Get]    Script Date: 9/9/2013 3:29:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===================================================
-- Author:		Medz
-- Create date: 
-- Description:	
-- ===================================================
CREATE PROCEDURE [dbo].[_spKartrisLinnworksOrders_Get]
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
                         tblKartrisOrders.O_Data, tblKartrisOrders.O_Comments, tblKartrisOrders.O_Cancelled, SUBSTRING(tblKartrisOrders.O_BillingAddress, 0, 
                         CHARINDEX(CHAR(13) + CHAR(10), tblKartrisOrders.O_BillingAddress)) AS O_BillingName, tblKartrisLinnworksOrders.LWO_OrderID, 
                         tblKartrisLinnworksOrders.LWO_LinnworksGuid, tblKartrisLinnworksOrders.LWO_DataCreated
FROM            tblKartrisOrders INNER JOIN
                         tblKartrisLinnworksOrders ON tblKartrisOrders.O_ID = tblKartrisLinnworksOrders.LWO_OrderID
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

/****** Object:  StoredProcedure [dbo].[_spKartrisLinnworksOrders_Add]    Script Date: 9/9/2013 3:29:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLinnworksOrders_Add]
(
	@OrderID int,
	@Guid as nvarchar(50),
	@DateCreated as smalldatetime,
	@RowsAffected as int OUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[tblKartrisLinnworksOrders]
	VALUES(@OrderID, @Guid, @DateCreated);

	SET @RowsAffected = @@ROWCOUNT;

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
	@NoCustomersInArrears as int OUTPUT,
	@NoOfLinnworksOrdersToBeSent as int OUTPUT
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

	SELECT @NoOfLinnworksOrdersToBeSent = Count(O_ID) FROM tblKartrisOrders WHERE (O_Paid = 1) AND (O_Cancelled IS NULL or O_Cancelled = 0) AND O_ID NOT IN (SELECT [LWO_OrderID] FROM [dbo].[tblKartrisLinnworksOrders])
END

GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetTileAppData]    Script Date: 09/24/2013 20:40:57 ******/
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
                      tblKartrisCurrencies.CUR_ISOCode
FROM         tblKartrisOrders LEFT OUTER JOIN
                      tblKartrisCurrencies ON tblKartrisOrders.O_CurrencyID = tblKartrisCurrencies.CUR_ID LEFT OUTER JOIN
                      tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
WHERE     (tblKartrisOrders.O_Sent = COALESCE (@O_Sent, tblKartrisOrders.O_Sent)) AND (tblKartrisOrders.O_Invoiced = COALESCE (@O_Invoiced, tblKartrisOrders.O_Invoiced)) AND 
                      (tblKartrisOrders.O_Paid = COALESCE (@O_Paid, tblKartrisOrders.O_Paid)) AND (tblKartrisOrders.O_Shipped = COALESCE (@O_Shipped, tblKartrisOrders.O_Shipped)) AND 
                      (tblKartrisOrders.O_Cancelled = COALESCE (@O_Cancelled, tblKartrisOrders.O_Cancelled)) AND (tblKartrisOrders.O_Date >= COALESCE (@DateRangeStart, tblKartrisOrders.O_Date)) AND 
                      (tblKartrisOrders.O_Date <= COALESCE (@DateRangeEnd, tblKartrisOrders.O_Date))
		
	END
		
END