/****** Object:  Table [dbo].[tblKartrisPayments]    Script Date: 01/02/2011 13:13:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblKartrisPayments]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tblKartrisPayments](
	[Payment_ID] [int] IDENTITY(1,1) NOT NULL,
	[Payment_CustomerID] [int] NULL,
	[Payment_Date] [smalldatetime] NULL,
	[Payment_Amount] [real] NULL,
	[Payment_CurrencyID] [tinyint] NULL,
	[Payment_ReferenceNo] [nvarchar](50) NULL,
	[Payment_Gateway] [nvarchar](20) NULL,
 CONSTRAINT [PK_tblKartrisPayments] PRIMARY KEY CLUSTERED 
(
	[Payment_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[tblKartrisOrderPaymentLink]    Script Date: 01/02/2011 13:13:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblKartrisOrderPaymentLink]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tblKartrisOrderPaymentLink](
	[OP_PaymentID] [int] NOT NULL,
	[OP_OrderID] [int] NOT NULL,
	[OP_OrderCanceled] [bit] NULL,
 CONSTRAINT [PK_tblKartrisOrdersPaymentsLink] PRIMARY KEY CLUSTERED 
(
	[OP_PaymentID] ASC,
	[OP_OrderID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[tblKartrisClonedOrders]    Script Date: 01/02/2011 13:13:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblKartrisClonedOrders]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tblKartrisClonedOrders](
	[CO_OrderID] [int] NOT NULL,
	[CO_ParentOrderID] [int] NULL,
	[CO_CloneDate] [smalldatetime] NULL,
	[CO_LoginID] [smallint] NULL,
 CONSTRAINT [PK_tblKartrisClonedOrders] PRIMARY KEY CLUSTERED 
(
	[CO_OrderID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Trigger [trigKartrisPayments_DML]    Script Date: 01/02/2011 13:13:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trigKartrisPayments_DML]'))
EXEC dbo.sp_executesql @statement = N'CREATE	TRIGGER [dbo].[trigKartrisPayments_DML] ON [dbo].[tblKartrisPayments]  FOR INSERT, UPDATE, DELETE AS BEGIN Rollback Transaction Print ''*****************************************************'' Print ''*****************************************************'' Print ''***** ERROR:Operation Not Allowed by User ******''Print ''*****************************************************'' Print ''*****************************************************''  END
'
GO
/****** Object:  Trigger [trigKartrisOrderPaymentLink_DML]    Script Date: 01/02/2011 13:13:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trigKartrisOrderPaymentLink_DML]'))
EXEC dbo.sp_executesql @statement = N'CREATE	TRIGGER [dbo].[trigKartrisOrderPaymentLink_DML] ON [dbo].[tblKartrisOrderPaymentLink]  FOR INSERT, UPDATE, DELETE AS BEGIN Rollback Transaction Print ''*****************************************************'' Print ''*****************************************************'' Print ''***** ERROR:Operation Not Allowed by User ******''Print ''*****************************************************'' Print ''*****************************************************''  END
'
GO
/****** Object:  Trigger [trigKartrisClonedOrders_DML]    Script Date: 01/02/2011 13:13:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trigKartrisClonedOrders_DML]'))
EXEC dbo.sp_executesql @statement = N'CREATE	TRIGGER [dbo].[trigKartrisClonedOrders_DML] ON [dbo].[tblKartrisClonedOrders]  FOR INSERT, UPDATE, DELETE AS BEGIN Rollback Transaction Print ''*****************************************************'' Print ''*****************************************************'' Print ''***** ERROR:Operation Not Allowed by User ******''Print ''*****************************************************'' Print ''*****************************************************''  END
'
GO
;
disable trigger trigKartrisAdminRelatedTables_DML on dbo.tblKartrisAdminRelatedTables;
DELETE FROM dbo.tblKartrisAdminRelatedTables;
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisAddresses', NULL, 19, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisAffiliateLog', NULL, 12, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisAffiliatePayments', NULL, 11, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisAttributes', 14, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisAttributeValues', 7, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisBasketOptionValues', 8, 15, 3, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisBasketValues', 15, 16, 4, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisCategories', 23, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisCategoryHierarchy', 6, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisClonedOrders', NULL, 7, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisCoupons', NULL, 17, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisCustomerGroupPrices', 19, 2, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisCustomerGroups', NULL, 3, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisInvoiceRows', NULL, 5, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisKnowledgeBase', NULL, 20, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisMediaLinks', 20, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisOptionGroups', 17, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisOptions', 16, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisOrderPaymentLink', NULL, 8, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisOrders', NULL, 10, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisOrdersPromotions', 10, 6, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisPayments', NULL, 9, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisProductCategoryLink', 2, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisProductOptionGroupLink', 3, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisProductOptionLink', 4, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisProducts', 22, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisPromotionParts', 9, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisPromotions', 13, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisQuantityDiscounts', 18, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisRelatedProducts', 5, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisReviews', 12, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisSavedBaskets', 25, 13, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisSearchStatistics', 27, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisSessions', NULL, 4, 2, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisSessionValues', NULL, 1, 1, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisStatistics', 11, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisSuppliers', 24, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisSupportTicketMessages', NULL, 21, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisSupportTickets', NULL, 22, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisUsers', NULL, 18, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisVersionOptionLink', 1, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisVersions', 21, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisWishLists', 26, 14, NULL, 0)
Enable trigger trigKartrisAdminRelatedTables_DML on dbo.tblKartrisAdminRelatedTables;
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_GetTriggers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisDB_GetTriggers]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @AllTriggers as nvarchar(MAX);
	SET @AllTriggers = ''Addresses_DML,AffiliateLog_DML,AffiliatePayments_DML,Attributes_DML,AttributeValues_DML,Categories_DML,CategoryHierarchy_DML,ClonedOrders_DML,Config_DML,Coupons_DML,CreditCards_DML,Currencies_DML,CustomerGroupPrices_DML,CustomerGroups_DML,DeletedItems_DML,Destination_DML,InvoiceRows_DML,KnowledgeBase_DML,LanguageElements_DML,Languages_D,Languages_DML,Languages_U,LanguageStrings_DML,Logins_DML,MediaLinks_DML,MediaTypes_DML,News_DML,OptionGroups_DML,Options_DML,OrderPaymentLink_DML,Orders_DML,OrdersPromotions_DML,Pages_DML,Payments_DML,ProductCategoryLink_DML,ProductOptionGroupLink_DML,ProductOptionLink_DML,Products_DML,PromotionParts_DML,Promotions_DML,PromotionStrings_DML,QuantityDiscounts_DML,RelatedProducts_DML,Reviews_DML,SavedBaskets_DML,SavedExports_DML,SearchStatistics_DML,ShippingMethods_DML,ShippingRates_DML,ShippingZones_DML,Statistics_DML,Suppliers_DML,SupportTicketMessages_DML,SupportTickets_DML,SupportTicketTypes_DML,TaxRates_DML,Users_DML,VersionOptionLink_DML,Versions_DML,WishLists_DML''
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @TrigName as nvarchar(100);
	DECLARE @TabName as nvarchar(100);
	SET @SIndx = 0;

	CREATE TABLE #TempTbl(TableName nvarchar(100), TriggerName nvarchar(100), IsTriggerEnabled bit);

		WHILE @SIndx <= LEN(@AllTriggers)
		BEGIN
			
			SET @CIndx = CHARINDEX('','', @AllTriggers, @SIndx);
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@AllTriggers)+1 END
			SET @TrigName = SUBSTRING(@AllTriggers, @SIndx, @CIndx - @SIndx);
			SET @TabName = SUBSTRING(@TrigName, 0, CHARINDEX(''_'', @TrigName));
			SET @SIndx = @CIndx + 1;
			INSERT INTO #TempTbl VALUES(@TabName, @TrigName, 1 - OBJECTPROPERTY(OBJECT_ID(''trigKartris'' + @TrigName), ''ExecIsTriggerDisabled''))
	  
		END
	SELECT * FROM #TempTbl;

	DROP TABLE #TempTbl;
--SELECT	SUBSTRING(tblTable.name, 11, 50) as TableName,
--		SUBSTRING(tblTrig.name, 12, 50) as TriggerName, 
--		1 - OBJECTPROPERTY(OBJECT_ID(tblTrig.name), ''ExecIsTriggerDisabled'') as IsTriggerEnabled
--		
--FROM	sysobjects tblTrig INNER JOIN 
--		sysobjects tblTable 
--		ON	tblTrig.parent_obj = tblTable.id 
--			AND tblTrig.type = ''TR''
--ORDER BY 1, 2

END



' 
END
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_EnableAllTriggers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisDB_EnableAllTriggers]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;

    DECLARE @AllTriggers as nvarchar(MAX);
	SET @AllTriggers = ''Addresses_DML,AdminRelatedTables_DML,AffiliateLog_DML,AffiliatePayments_DML,Attributes_DML,AttributeValues_DML,Categories_DML,CategoryHierarchy_DML,ClonedOrders_DML,Config_DML,Coupons_DML,CreditCards_DML,Currencies_DML,CustomerGroupPrices_DML,CustomerGroups_DML,DeletedItems_DML,Destination_DML,InvoiceRows_DML,KnowledgeBase_DML,LanguageElementFieldNames_DML,LanguageElementFieldNames_IUD,LanguageElements_DML,LanguageElementTypeFields_DML,LanguageElementTypes_DML,LanguageElementTypes_IUD,Languages_D,Languages_DML,Languages_U,LanguageStrings_DML,Logins_DML,MediaLinks_DML,MediaTypes_DML,News_DML,OptionGroups_DML,Options_DML,OrderPaymentLink_DML,Orders_DML,OrdersPromotions_DML,Pages_DML,Payments_DML,ProductCategoryLink_DML,ProductOptionGroupLink_DML,ProductOptionLink_DML,Products_DML,PromotionParts_DML,Promotions_DML,PromotionStrings_DML,QuantityDiscounts_DML,RelatedProducts_DML,Reviews_DML,SavedBaskets_DML,SavedExports_DML,SearchStatistics_DML,ShippingMethods_DML,ShippingRates_DML,ShippingZones_DML,Statistics_DML,Suppliers_DML,SupportTicketMessages_DML,SupportTickets_DML,SupportTicketTypes_DML,TaxRates_DML,Users_DML,VersionOptionLink_DML,Versions_DML,WishLists_DML''
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @TrigName as nvarchar(100);
	DECLARE @TabName as nvarchar(100);
	SET @SIndx = 0;

	WHILE @SIndx <= LEN(@AllTriggers)
	BEGIN
		SET @CIndx = CHARINDEX('','', @AllTriggers, @SIndx);
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@AllTriggers)+1 END
		SET @TrigName = SUBSTRING(@AllTriggers, @SIndx, @CIndx - @SIndx);
		SET @TabName = SUBSTRING(@TrigName, 0, CHARINDEX(''_'', @TrigName));
		SET @SIndx = @CIndx + 1;
		DECLARE @SQL as nvarchar(250);
		SET @SQL = ''ENABLE Trigger trigKartris'' + @TrigName + '' ON tblKartris'' + @TabName;
		EXECUTE(@SQL);
	END

END


' 
END

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_DisableAllTriggers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisDB_DisableAllTriggers]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;

    DECLARE @AllTriggers as nvarchar(MAX);
	SET @AllTriggers = ''Addresses_DML,AffiliateLog_DML,AffiliatePayments_DML,Attributes_DML,AttributeValues_DML,Categories_DML,CategoryHierarchy_DML,ClonedOrders_DML,Config_DML,Coupons_DML,CreditCards_DML,Currencies_DML,CustomerGroupPrices_DML,CustomerGroups_DML,DeletedItems_DML,Destination_DML,InvoiceRows_DML,KnowledgeBase_DML,LanguageElements_DML,Languages_D,Languages_DML,Languages_U,LanguageStrings_DML,Logins_DML,MediaLinks_DML,MediaTypes_DML,News_DML,OptionGroups_DML,Options_DML,OrderPaymentLink_DML,Orders_DML,OrdersPromotions_DML,Pages_DML,Payments_DML,ProductCategoryLink_DML,ProductOptionGroupLink_DML,ProductOptionLink_DML,Products_DML,PromotionParts_DML,Promotions_DML,PromotionStrings_DML,QuantityDiscounts_DML,RelatedProducts_DML,Reviews_DML,SavedBaskets_DML,SavedExports_DML,SearchStatistics_DML,ShippingMethods_DML,ShippingRates_DML,ShippingZones_DML,Statistics_DML,Suppliers_DML,SupportTicketMessages_DML,SupportTickets_DML,SupportTicketTypes_DML,TaxRates_DML,Users_DML,VersionOptionLink_DML,Versions_DML,WishLists_DML''
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @TrigName as nvarchar(100);
	DECLARE @TabName as nvarchar(100);
	SET @SIndx = 0;

	WHILE @SIndx <= LEN(@AllTriggers)
	BEGIN
		SET @CIndx = CHARINDEX('','', @AllTriggers, @SIndx);
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@AllTriggers)+1 END
		SET @TrigName = SUBSTRING(@AllTriggers, @SIndx, @CIndx - @SIndx);
		SET @TabName = SUBSTRING(@TrigName, 0, CHARINDEX(''_'', @TrigName));
		SET @SIndx = @CIndx + 1;
		DECLARE @SQL as nvarchar(250);
		SET @SQL = ''DISABLE Trigger trigKartris'' + @TrigName + '' ON tblKartris'' + @TabName;
		EXECUTE(@SQL);
	END

END


' 
END