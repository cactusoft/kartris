GO
/****** Object:  StoredProcedure [dbo].[spKartrisSearchStatistics_ReportSearch]    Script Date: 04/07/2010 11:06:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSearchStatistics_ReportSearch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spKartrisSearchStatistics_ReportSearch]
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSearchStatistics_Get]    Script Date: 04/07/2010 11:06:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSearchStatistics_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[_spKartrisSearchStatistics_Get]
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisStatistics_GetOrdersTurnover]    Script Date: 04/07/2010 11:06:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisStatistics_GetOrdersTurnover]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[_spKartrisStatistics_GetOrdersTurnover]
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisStatistics_GetAverageVisitsSummary]    Script Date: 04/07/2010 11:06:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisStatistics_GetAverageVisitsSummary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[_spKartrisStatistics_GetAverageVisitsSummary]
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisStatistics_GetAverageOrdersSummary]    Script Date: 04/07/2010 11:06:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisStatistics_GetAverageOrdersSummary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[_spKartrisStatistics_GetAverageOrdersSummary]
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSearchStatistics_GetTopSearches]    Script Date: 04/07/2010 11:06:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSearchStatistics_GetTopSearches]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[_spKartrisSearchStatistics_GetTopSearches]

GO
/****** Object:  Table [dbo].[tblKartrisSearchStatistics]    Script Date: 04/07/2010 11:00:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblKartrisSearchStatistics]') AND type in (N'U'))
DROP TABLE [dbo].[tblKartrisSearchStatistics]

GO
/****** Object:  Table [dbo].[tblKartrisSearchStatistics]    Script Date: 04/07/2010 10:55:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblKartrisSearchStatistics](
	[SS_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SS_Keyword] [nvarchar](150) NULL,
	[SS_Date] [datetime] NULL,
	[SS_Year] [smallint] NULL,
	[SS_Month] [tinyint] NULL,
	[SS_Day] [tinyint] NULL,
	[SS_Searches] [smallint] NULL,
 CONSTRAINT [PK_tblKartrisSearchStatistics] PRIMARY KEY CLUSTERED 
(
	[SS_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
/****** Object:  Trigger [dbo].[trigKartrisSearchStatistics_DML]    Script Date: 04/07/2010 16:31:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trigKartrisSearchStatistics_DML]'))
EXEC dbo.sp_executesql @statement = N'
CREATE TRIGGER [dbo].[trigKartrisSearchStatistics_DML] ON [dbo].[tblKartrisSearchStatistics]  FOR INSERT, UPDATE, DELETE AS BEGIN Rollback Transaction Print ''*****************************************************'' Print ''*****************************************************'' Print ''***** ERROR:Operation Not Allowed by User ******''Print ''*****************************************************'' Print ''*****************************************************''  END'
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSearchStatistics_ReportSearch]    Script Date: 04/07/2010 11:11:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSearchStatistics_ReportSearch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisSearchStatistics_ReportSearch]
(	
	@KeyWordsList as nvarchar(500),
	@CurrentYear as smallint,
	@CurrentMonth as tinyint,
	@CurrentDay as tinyint
)
AS
BEGIN
SET NOCOUNT ON;
	
	SET NOCOUNT ON;
	DISABLE TRIGGER [dbo].[trigKartrisSearchStatistics_DML] ON [dbo].[tblKartrisSearchStatistics]
	-----------------------
	-- Variable Declaration
	-----------------------
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @Keyword as nvarchar(150);
	DECLARE @Counter as int;
	
	SET @SIndx = 0;
	SET @Counter = 0;
	WHILE @SIndx <= LEN(@KeyWordsList)
	BEGIN
		
		-- Loop through out the keyword''''s list
		SET @Counter = @Counter + 1;	-- keywords counter
		SET @CIndx = CHARINDEX('','', @KeyWordsList, @SIndx)	-- Next keyword starting index (1-Based Index)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@KeyWordsList)+ 1 END	-- If no more keywords, set next starting index to not exist
		SET @KeyWord = SUBSTRING(@KeyWordsList, @SIndx, @CIndx - @SIndx)
		
		SET @SIndx = @CIndx + 1;	-- The next starting index
			
		UPDATE dbo.tblKartrisSearchStatistics
		SET SS_Searches = SS_Searches + 1
		WHERE SS_Keyword = @KeyWord AND SS_Year = @CurrentYear 
			AND SS_Month = @CurrentMonth AND SS_Day = @CurrentDay;

		IF @@ROWCOUNT = 0
		BEGIN
			DECLARE @SearchDate as datetime;
			SET @SearchDate = Cast(@CurrentMonth as nvarchar(2)) + ''/'' + 
								Cast(@CurrentDay as nvarchar(2)) + ''/'' + 
									Cast(@CurrentYear as nvarchar(4)) + '' 12:00:00 AM''
			INSERT INTO dbo.tblKartrisSearchStatistics
			VALUES(@KeyWord, @SearchDate, @CurrentYear, @CurrentMonth, @CurrentDay, 1);
		END
				
	END;
	ENABLE TRIGGER [dbo].[trigKartrisSearchStatistics_DML] ON [dbo].[tblKartrisSearchStatistics]
END
'
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSearchStatistics_Get]    Script Date: 04/07/2010 11:14:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSearchStatistics_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSearchStatistics_Get]
AS
BEGIN
SET NOCOUNT ON;
	
	SET NOCOUNT ON;
	
	SELECT * FROM dbo.tblKartrisSearchStatistics
	
END
'
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSearchStatistics_GetTopSearches]    Script Date: 04/07/2010 11:16:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSearchStatistics_GetTopSearches]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSearchStatistics_GetTopSearches]
(
	@StartDate as datetime,
	@EndDate as datetime,
	@NoOfKeywords as int
)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT Top(@NoOfKeywords) SS_Keyword, Sum(SS_Searches) As TotalSearches
	FROM dbo.tblKartrisSearchStatistics
	WHERE SS_Date BETWEEN @StartDate AND @EndDate
	Group BY SS_Keyword
	ORDER BY Sum(SS_Searches) DESC

END
'
END

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
	SET @AllTriggers = ''Addresses_DML,AffiliateLog_DML,AffiliatePayments_DML,Attributes_DML,AttributeValues_DML,BasketOptionValues_DML,BasketValues_DML,Categories_DML,CategoryHierarchy_DML,Config_DML,Coupons_DML,CreditCards_DML,Currencies_DML,CustomerGroupPrices_DML,CustomerGroups_DML,Destination_DML,InvoiceRows_DML,KnowledgeBase_DML,LanguageElements_DML,Languages_D,Languages_DML,Languages_U,LanguageStrings_DML,Logins_DML,News_DML,OptionGroups_DML,Options_DML,Orders_DML,OrdersPromotions_DML,Pages_DML,ProductCategoryLink_DML,ProductOptionGroupLink_DML,ProductOptionLink_DML,Products_DML,PromotionParts_DML,Promotions_DML,PromotionStrings_DML,QuantityDiscounts_DML,RelatedProducts_DML,Reviews_DML,SavedBaskets_DML,SavedExports_DML,SearchStatistics_DML,Sessions_DML,SessionValues_DML,ShippingMethods_DML,ShippingRates_DML,ShippingZones_DML,Statistics_DML,Suppliers_DML,SupportTicketMessages_DML,SupportTickets_DML,SupportTicketTypes_DML,TaxRates_DML,Users_DML,VersionOptionLink_DML,Versions_DML,WishLists_DML''
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
	SET @AllTriggers = ''Addresses_DML,AdminRelatedTables_DML,AffiliateLog_DML,AffiliatePayments_DML,Attributes_DML,AttributeValues_DML,BasketOptionValues_DML,BasketValues_DML,Categories_DML,CategoryHierarchy_DML,Config_DML,Coupons_DML,CreditCards_DML,Currencies_DML,CustomerGroupPrices_DML,CustomerGroups_DML,Destination_DML,InvoiceRows_DML,KnowledgeBase_DML,LanguageElementFieldNames_DML,LanguageElementFieldNames_IUD,LanguageElements_DML,LanguageElementTypeFields_DML,LanguageElementTypes_DML,LanguageElementTypes_IUD,Languages_D,Languages_DML,Languages_U,LanguageStrings_DML,Logins_DML,News_DML,OptionGroups_DML,Options_DML,Orders_DML,OrdersPromotions_DML,Pages_DML,ProductCategoryLink_DML,ProductOptionGroupLink_DML,ProductOptionLink_DML,Products_DML,PromotionParts_DML,Promotions_DML,PromotionStrings_DML,QuantityDiscounts_DML,RelatedProducts_DML,Reviews_DML,SavedBaskets_DML,SavedExports_DML,SearchStatistics_DML,Sessions_DML,SessionValues_DML,ShippingMethods_DML,ShippingRates_DML,ShippingZones_DML,Statistics_DML,Suppliers_DML,SupportTicketMessages_DML,SupportTickets_DML,SupportTicketTypes_DML,TaxRates_DML,Users_DML,VersionOptionLink_DML,Versions_DML,WishLists_DML''
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
	SET @AllTriggers = ''Addresses_DML,AffiliateLog_DML,AffiliatePayments_DML,Attributes_DML,AttributeValues_DML,BasketOptionValues_DML,BasketValues_DML,Categories_DML,CategoryHierarchy_DML,Config_DML,Coupons_DML,CreditCards_DML,Currencies_DML,CustomerGroupPrices_DML,CustomerGroups_DML,Destination_DML,InvoiceRows_DML,KnowledgeBase_DML,LanguageElements_DML,Languages_D,Languages_DML,Languages_U,LanguageStrings_DML,Logins_DML,News_DML,OptionGroups_DML,Options_DML,Orders_DML,OrdersPromotions_DML,Pages_DML,ProductCategoryLink_DML,ProductOptionGroupLink_DML,ProductOptionLink_DML,Products_DML,PromotionParts_DML,Promotions_DML,PromotionStrings_DML,QuantityDiscounts_DML,RelatedProducts_DML,Reviews_DML,SavedBaskets_DML,SavedExports_DML,SearchStatistics_DML,Sessions_DML,SessionValues_DML,ShippingMethods_DML,ShippingRates_DML,ShippingZones_DML,Statistics_DML,Suppliers_DML,SupportTicketMessages_DML,SupportTickets_DML,SupportTicketTypes_DML,TaxRates_DML,Users_DML,VersionOptionLink_DML,Versions_DML,WishLists_DML''
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
;
DISABLE TRIGGER trigKartrisAdminRelatedTables_DML ON dbo.tblKartrisAdminRelatedTables
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrder_Products], [ART_TableOrder_Orders], [ART_TableOrder_Sessions], [ART_TableStartingIdentity]) VALUES (N'tblKartrisSearchStatistics', 26, NULL, NULL, 0);
ENABLE TRIGGER trigKartrisAdminRelatedTables_DML ON dbo.tblKartrisAdminRelatedTables

GO
/****** Object:  StoredProcedure [dbo].[_spKartrisStatistics_GetOrdersTurnover]    Script Date: 04/07/2010 11:19:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisStatistics_GetOrdersTurnover]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisStatistics_GetOrdersTurnover]
(
	@StartDate as datetime,
	@EndDate as datetime
)
AS
BEGIN

	SELECT Year(O_Date) as [Year], Month(O_Date) as [Month], Day(O_Date) as [Day], Count(*) as Orders, Sum(O_TotalPrice * O_CurrencyRate) as TotalValue
	FROM dbo.tblKartrisOrders
	WHERE O_Date BETWEEN @StartDate AND @EndDate
	Group BY Year(O_Date), Month(O_Date), Day(O_Date)
	ORDER BY Year(O_Date), Month(O_Date), Day(O_Date)

END
'
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisStatistics_GetAverageVisitsSummary]    Script Date: 04/07/2010 11:21:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisStatistics_GetAverageVisitsSummary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisStatistics_GetAverageVisitsSummary]
(
	@CurrentDate as datetime
)
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @Last24Hours as datetime; SET @Last24Hours = DateAdd(Hour, -24, @CurrentDate);
	DECLARE @LastWeek as datetime; SET @LastWeek = DateAdd(Week, -1, @CurrentDate);
	DECLARE @LastMonth as datetime; SET @LastMonth = DateAdd(Month, -1, @CurrentDate);
	DECLARE @LastYear as datetime; SET @LastYear = DateAdd(Year, -1, @CurrentDate);

	DECLARE @Last24HoursVisits as int, @LastWeekVisits as int, @LastMonthVisits as int, @LastYearVisits as int;

	SELECT @Last24HoursVisits = Count(*)
	FROM dbo.tblKartrisStatistics
	WHERE ST_Date BETWEEN @Last24Hours AND @CurrentDate

	SELECT @LastWeekVisits = Count(*)/7
	FROM dbo.tblKartrisStatistics
	WHERE ST_Date BETWEEN @LastWeek AND @CurrentDate

	SELECT @LastMonthVisits = Count(*)/30
	FROM dbo.tblKartrisStatistics
	WHERE ST_Date BETWEEN @LastMonth AND @CurrentDate

	SELECT @LastYearVisits = Count(*)/360
	FROM dbo.tblKartrisStatistics
	WHERE ST_Date BETWEEN @LastYear AND @CurrentDate

	SELECT @Last24HoursVisits as Last24Hours, @LastWeekVisits as LastWeek, @LastMonthVisits as LastMonth, @LastYearVisits as LastYear
END
'
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisStatistics_GetAverageOrdersSummary]    Script Date: 04/07/2010 11:23:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisStatistics_GetAverageOrdersSummary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisStatistics_GetAverageOrdersSummary]
(
	@CurrentDate as datetime
)
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @Last24Hours as datetime; SET @Last24Hours = DateAdd(Hour, -24, @CurrentDate);
	DECLARE @LastWeek as datetime; SET @LastWeek = DateAdd(Week, -1, @CurrentDate);
	DECLARE @LastMonth as datetime; SET @LastMonth = DateAdd(Month, -1, @CurrentDate);
	DECLARE @LastYear as datetime; SET @LastYear = DateAdd(Year, -1, @CurrentDate);

	DECLARE @Last24HoursOrders as int, @LastWeekOrders as int, @LastMonthOrders as int, @LastYearOrders as int;
	DECLARE @Last24HoursTurnover as real, @LastWeekTurnover as real, @LastMonthTurnover as real, @LastYearTurnover as real;

	SELECT @Last24HoursOrders = Count(*), @Last24HoursTurnover = Sum(O_TotalPrice * O_CurrencyRate)
	FROM dbo.tblKartrisOrders
	WHERE O_Date BETWEEN @Last24Hours AND @CurrentDate

	SELECT @LastWeekOrders = Count(*), @LastWeekTurnover = Sum(O_TotalPrice * O_CurrencyRate)/7 
	FROM dbo.tblKartrisOrders
	WHERE O_Date BETWEEN @LastWeek AND @CurrentDate

	SELECT @LastMonthOrders = Count(*), @LastMonthTurnover = Sum(O_TotalPrice * O_CurrencyRate)/30
	FROM dbo.tblKartrisOrders
	WHERE O_Date BETWEEN @LastMonth AND @CurrentDate

	SELECT @LastYearOrders = Count(*), @LastYearTurnover = Sum(O_TotalPrice * O_CurrencyRate)/360
	FROM dbo.tblKartrisOrders
	WHERE O_Date BETWEEN @LastYear AND @CurrentDate


	SELECT @Last24HoursOrders as Last24HoursOrders, @LastWeekOrders as LastWeekOrders
			, @LastMonthOrders as LastMonthOrders, @LastYearOrders as LastYearOrders
			, @Last24HoursTurnover as Last24HoursTurnover, @LastWeekTurnover as LastWeekTurnover
			, @LastMonthTurnover as LastMonthTurnover, @LastYearTurnover as LastYearTurnover;
END
'
END
GO

sp_RENAME 'tblKartrisSupportTicketMessages.TIC_ID', 'STM_TicketID' , 'COLUMN'
sp_RENAME 'tblKartrisSupportTicketMessages.LOGIN_ID', 'STM_LoginID' , 'COLUMN'

sp_RENAME 'tblKartrisSupportTickets.U_ID', 'TIC_UserID' , 'COLUMN'
sp_RENAME 'tblKartrisSupportTickets.Login_ID', 'TIC_LoginID' , 'COLUMN'
sp_RENAME 'tblKartrisSupportTickets.STT_ID', 'TIC_SupportTicketTypeID' , 'COLUMN'

sp_RENAME 'tblKartrisSearchHelper.SearchHelperID', 'SH_ID' , 'COLUMN'
sp_RENAME 'tblKartrisSearchHelper.SessionID', 'SH_SessionID' , 'COLUMN'
sp_RENAME 'tblKartrisSearchHelper.TypeID', 'SH_TypeID' , 'COLUMN'
sp_RENAME 'tblKartrisSearchHelper.FieldID', 'SH_FieldID' , 'COLUMN'
sp_RENAME 'tblKartrisSearchHelper.ParentID', 'SH_ParentID' , 'COLUMN'
sp_RENAME 'tblKartrisSearchHelper.TextValue', 'SH_TextValue' , 'COLUMN'
sp_RENAME 'tblKartrisSearchHelper.ProductID', 'SH_ProductID' , 'COLUMN'
sp_RENAME 'tblKartrisSearchHelper.Price', 'SH_Price' , 'COLUMN'
sp_RENAME 'tblKartrisSearchHelper.Score', 'SH_Score' , 'COLUMN'

sp_RENAME 'tblKartrisSavedExports.Export_ID', 'EXPORT_ID' , 'COLUMN'
sp_RENAME 'tblKartrisSavedExports.Export_Name', 'EXPORT_Name' , 'COLUMN'
sp_RENAME 'tblKartrisSavedExports.Export_DateCreated', 'EXPORT_DateCreated' , 'COLUMN'
sp_RENAME 'tblKartrisSavedExports.Export_LastModified', 'EXPORT_LastModified' , 'COLUMN'
sp_RENAME 'tblKartrisSavedExports.Export_Details', 'EXPORT_Details' , 'COLUMN'
sp_RENAME 'tblKartrisSavedExports.Export_FieldDelimiter', 'EXPORT_FieldDelimiter' , 'COLUMN'
sp_RENAME 'tblKartrisSavedExports.Export_StringDelimiter', 'EXPORT_StringDelimiter' , 'COLUMN'

sp_RENAME 'tblKartrisAdminRelatedTables.TableName', 'ART_TableName' , 'COLUMN'
sp_RENAME 'tblKartrisAdminRelatedTables.TableOrder_Products', 'ART_TableOrderProducts' , 'COLUMN'
sp_RENAME 'tblKartrisAdminRelatedTables.TableOrder_Orders', 'ART_TableOrderOrders' , 'COLUMN'
sp_RENAME 'tblKartrisAdminRelatedTables.TableOrder_Sessions', 'ART_TableOrderSessions' , 'COLUMN'
sp_RENAME 'tblKartrisAdminRelatedTables.TableStartingIdentity', 'ART_TableStartingIdentity' , 'COLUMN'

sp_RENAME 'tblKartrisBasketOptionValues.BSKOPT_BasketValueID', 'BSKTOPT_BasketValueID' , 'COLUMN'

GO
/****** Object:  StoredProcedure [dbo].[spKartrisDB_Search]    Script Date: 03/02/2010 13:57:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisDB_Search]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
ALTER PROCEDURE [dbo].[spKartrisDB_Search]
(	@keyWordsList as nvarchar(500),
	@LANG_ID as tinyint,
	@PageIndex as tinyint, -- 0 Based index
	@RowsPerPage as tinyint,
	@TotalResultProducts as int OUTPUT,
	@MinPrice as real,
	@MaxPrice as real,
	@CustomerGroupID as smallint
)
AS
BEGIN
SET NOCOUNT ON;
	
	SET NOCOUNT ON;
	
	-----------------------
	-- Variable Declaration
	-----------------------
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @Keyword as nvarchar(150);
	DECLARE @Counter as int;
	
	DECLARE @NoOfVersions as bigint;
	SELECT @NoOfVersions = Count(1)	FROM tblKartrisVersions;
	
	DECLARE @DataToSearch as nvarchar(100);
	IF @NoOfVersions > 10000
	BEGIN
		SET @DataToSearch = ''(LE_TypeID IN (2,14)) AND (LE_FieldID IN (1,2))''
	END
	ELSE
	BEGIN
		SET @DataToSearch = ''(LE_TypeID IN (1,2,14)) AND (LE_FieldID IN (1))''
	END
	
	SET @SIndx = 0;
	SET @Counter = 0;
	WHILE @SIndx <= LEN(@keyWordsList)
	BEGIN
		
		-- Loop through out the keyword''''''''s list
		SET @Counter = @Counter + 1;	-- keywords counter
		SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)	-- Next keyword starting index (1-Based Index)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+ 1 END	-- If no more keywords, set next starting index to not exist
		SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
		
		SET @SIndx = @CIndx + 1;	-- The next starting index
				
		EXECUTE(''
		INSERT INTO tblKartrisSearchHelper
		SELECT @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = '' + @LANG_ID +'' AND '' + @DataToSearch + ''
					AND ((LE_Value like ''''% '' + @KeyWord + '' %'''')
					OR	(LE_Value like '''''' + @KeyWord + '' %'''')
					OR	(LE_Value like ''''% '' + @KeyWord + ''''''))'');
			
		EXECUTE(''
		INSERT INTO tblKartrisSearchHelper
		SELECT     @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 600
		FROM         tblKartrisVersions
		WHERE     (V_Live = 1) AND (V_CodeNumber ='''''' + @Keyword + '''''')'' );	
						
	END

	IF @MinPrice <> -1 AND @MaxPrice <> -1
	BEGIN
		UPDATE tblKartrisSearchHelper
		SET SH_Price = dbo.fnKartrisProduct_GetMinPriceWithCG(SH_ProductID, @CustomerGroupID)
		WHERE SH_SessionID = @@SPID;
		DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID = @@SPID AND SH_Price NOT BETWEEN @MinPrice AND @MaxPrice;
	END

	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID AND SH_ProductID IN (	SELECT P_ID 
												FROM dbo.tblKartrisProducts 
												WHERE P_Live = 0 
													OR (P_CustomerGroupID IS NOT NULL AND P_CustomerGroupID <> @CustomerGroupID)); 
	
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID AND SH_TypeID = 14 
			AND SH_ParentID IN (SELECT tblKartrisAttributeValues.ATTRIBV_ID
							FROM tblKartrisAttributes INNER JOIN tblKartrisAttributeValues 
							ON tblKartrisAttributes.ATTRIB_ID = tblKartrisAttributeValues.ATTRIBV_AttributeID
							WHERE   tblKartrisAttributes.ATTRIB_ShowSearch = 0);

	
	IF @Counter > 1
	BEGIN
		DECLARE @ExactSearch as nvarchar(500);
		SET @ExactSearch = Replace(@keyWordsList, '','', '' '');
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (400) WHERE SH_SessionID = @@SPID AND SH_TextValue like ''%'' + @ExactSearch + ''%'';
	END
	
	IF @NoOfVersions > 10000
	BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30) WHERE SH_SessionID = @@SPID AND SH_FieldID = 2;
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (200) WHERE SH_SessionID = @@SPID AND SH_FieldID = 1;
	END
	ELSE
	BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30 * SH_TypeID) WHERE SH_SessionID = @@SPID AND SH_TypeID IN (1, 2);
	END
	
	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;	

	SELECT @TotalResultProducts =  Count(DISTINCT SH_ProductID) FROM tblKartrisSearchHelper WHERE SH_SessionID = @@SPID;
	
	WITH SearchResult as
	(
		SELECT ROW_NUMBER() OVER (ORDER BY TotalScore DESC) as Row, 
				ProductID, TotalScore
		FROM (	SELECT 
					CASE 
					WHEN T1.SH_ProductID IS NULL THEN T2.SH_ProductID
					ELSE T1.SH_ProductID
					END AS ProductID,
					CASE 
					WHEN Score1 IS NULL THEN Score2
					WHEN Score2 IS NULL THEN Score1
					ELSE (Score1 + Score2) 
					END AS TotalScore
				FROM (
						SELECT SH_SessionID, SH_ProductID, Sum(SH_Score) as Score1
						FROM tblKartrisSearchHelper 
						WHERE SH_TypeID = 2 OR SH_TypeID = 14
						GROUP BY SH_SessionID, SH_ProductID
						HAVING SH_SessionID = @@SPID
					) T1 
					FULL OUTER JOIN 
					(
						SELECT SH_SessionID, SH_ProductID, Max(SH_Score) as Score2
						FROM tblKartrisSearchHelper 
						WHERE SH_TypeID = 1
						Group BY SH_SessionID, SH_ProductID
						HAVING SH_SessionID = @@SPID
					) T2 
					ON T1.SH_ProductID = T2.SH_ProductID
			) T3
	)
	SELECT Row, P_ID, P_Name, dbo.fnKartrisDB_TruncateDescription(P_Desc) as P_Desc, 
			dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID, @CustomerGroupID) as MinPrice, TotalScore
	FROM SearchResult INNER JOIN dbo.vKartrisTypeProducts ON SearchResult.ProductID = dbo.vKartrisTypeProducts.P_ID
	WHERE vKartrisTypeProducts.LANG_ID = @LANG_ID AND ROW BETWEEN @StartRowNumber AND @EndRowNumber
	GROUP BY Row, P_ID, P_Name, P_Desc, TotalScore
	ORDER BY TotalScore DESC

	DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID=@@SPID;
	
END
' 
END
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_SetupFTS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisDB_SetupFTS]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	EXEC sp_fulltext_database ''enable'';

	DECLARE @kartrisCatalogExist as int;
	SET @kartrisCatalogExist = 0;
	SELECT @kartrisCatalogExist = count(*) FROM sys.fulltext_catalogs WHERE name = ''kartrisCatalog'';
	IF @kartrisCatalogExist = 0 BEGIN CREATE FULLTEXT CATALOG kartrisCatalog END;
	
	EXEC sp_fulltext_table     ''dbo.tblKartrisLanguageElements'', ''create'', ''kartrisCatalog'', ''keyLE_ID''
	EXEC sp_fulltext_column    ''dbo.tblKartrisLanguageElements'', ''LE_Value'', ''add''
	EXEC sp_fulltext_table     ''dbo.tblKartrisLanguageElements'',''activate''

	EXEC sp_fulltext_table     ''dbo.tblKartrisAddresses'', ''create'', ''kartrisCatalog'', ''PK_tblKartrisAddresses''
	EXEC sp_fulltext_column    ''dbo.tblKartrisAddresses'', ''ADR_Name'', ''add''
	EXEC sp_fulltext_table     ''dbo.tblKartrisAddresses'',''activate''

	EXEC sp_fulltext_table     ''dbo.tblKartrisUsers'', ''create'', ''kartrisCatalog'', ''aaaaatblCactuShop1Customers_PK''
	EXEC sp_fulltext_column    ''dbo.tblKartrisUsers'', ''U_EmailAddress'', ''add''
	EXEC sp_fulltext_table     ''dbo.tblKartrisUsers'',''activate''

	EXEC sp_fulltext_table     ''dbo.tblKartrisOrders'', ''create'', ''kartrisCatalog'', ''aaaaatblCactuShop1Orders_PK''
	EXEC sp_fulltext_column    ''dbo.tblKartrisOrders'', ''O_PurchaseOrderNo'', ''add''
	EXEC sp_fulltext_table     ''dbo.tblKartrisOrders'',''activate''

	EXEC sp_fulltext_table     ''dbo.tblKartrisConfig'', ''create'', ''kartrisCatalog'', ''PK_tblKartrisConfig''
	EXEC sp_fulltext_column    ''dbo.tblKartrisConfig'', ''CFG_Name'', ''add''
	EXEC sp_fulltext_table     ''dbo.tblKartrisConfig'',''activate''

	EXEC sp_fulltext_table     ''dbo.tblKartrisLanguageStrings'', ''create'', ''kartrisCatalog'', ''LS_ID''
	EXEC sp_fulltext_column    ''dbo.tblKartrisLanguageStrings'', ''LS_Name'', ''add''
	EXEC sp_fulltext_column    ''dbo.tblKartrisLanguageStrings'', ''LS_Value'', ''add''
	EXEC sp_fulltext_table     ''dbo.tblKartrisLanguageStrings'',''activate''

	ALTER FULLTEXT INDEX ON dbo.tblKartrisLanguageElements SET CHANGE_TRACKING AUTO;
	ALTER FULLTEXT INDEX ON dbo.tblKartrisAddresses SET CHANGE_TRACKING AUTO;
	ALTER FULLTEXT INDEX ON dbo.tblKartrisUsers SET CHANGE_TRACKING AUTO;
	ALTER FULLTEXT INDEX ON dbo.tblKartrisOrders SET CHANGE_TRACKING AUTO;
	ALTER FULLTEXT INDEX ON dbo.tblKartrisConfig SET CHANGE_TRACKING AUTO;
	ALTER FULLTEXT INDEX ON dbo.tblKartrisLanguageStrings SET CHANGE_TRACKING AUTO;
	
	EXEC sp_fulltext_catalog   ''kartrisCatalog'', ''start_full''	
  

	IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[spKartrisDB_SearchFTS]'') AND type in (N''P'', N''PC''))
BEGIN
EXEC dbo.sp_executesql @statement = N''-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[spKartrisDB_SearchFTS]
(	@keyWordsList as nvarchar(500),
	@LANG_ID as tinyint,
	@PageIndex as tinyint, -- 0 Based index
	@RowsPerPage as tinyint,
	@TotalResultProducts as int OUTPUT,
	@MinPrice as real,
	@MaxPrice as real,
	@CustomerGroupID as smallint
)
AS
BEGIN
	SET NOCOUNT ON;
	
	-----------------------
	-- Variable Declaration
	-----------------------
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @Keyword as nvarchar(150);
	DECLARE @Counter as int;
	
	DECLARE @NoOfVersions as bigint;
	SELECT @NoOfVersions = Count(1)	FROM tblKartrisVersions;
	
	DECLARE @DataToSearch as nvarchar(100);
	IF @NoOfVersions > 10000
	BEGIN
		SET @DataToSearch = ''''(LE_TypeID IN (2,14)) AND (LE_FieldID IN (1,2))''''
	END
	ELSE
	BEGIN
		SET @DataToSearch = ''''(LE_TypeID IN (1,2,14)) AND (LE_FieldID IN (1))''''
	END
	
	SET @SIndx = 0;
	SET @Counter = 0;
	WHILE @SIndx <= LEN(@keyWordsList)
	BEGIN
		
		-- Loop through out the keyword''''''''s list
		SET @Counter = @Counter + 1;	-- keywords counter
		SET @CIndx = CHARINDEX('''','''', @keyWordsList, @SIndx)	-- Next keyword starting index (1-Based Index)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+ 1 END	-- If no more keywords, set next starting index to not exist
		SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
		
		SET @SIndx = @CIndx + 1;	-- The next starting index
			
		EXECUTE(''''
		INSERT INTO tblKartrisSearchHelper
		SELECT @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = '''' + @LANG_ID +'''' AND '''' + @DataToSearch + '''' AND (Contains(LE_Value, '''''''''''' + @KeyWord + '''''''''''')) '''');
			
		EXECUTE(''''
		INSERT INTO tblKartrisSearchHelper
		SELECT     @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0
		FROM         tblKartrisVersions
		WHERE     (V_Live = 1) AND (V_CodeNumber ='''''''''''' + @Keyword + '''''''''''')'''' );
				
	END

	IF @MinPrice <> -1 AND @MaxPrice <> -1
	BEGIN
		UPDATE tblKartrisSearchHelper
		SET SH_Price = dbo.fnKartrisProduct_GetMinPriceWithCG(SH_ProductID, @CustomerGroupID)
		WHERE SH_SessionID = @@SPID;
		DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID = @@SPID AND SH_Price NOT BETWEEN @MinPrice AND @MaxPrice;
	END

	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID AND SH_ProductID IN (	SELECT P_ID 
												FROM dbo.tblKartrisProducts 
												WHERE P_Live = 0 
													OR (P_CustomerGroupID IS NOT NULL AND P_CustomerGroupID <> @CustomerGroupID)); 
	
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID AND SH_TypeID = 14 
			AND SH_ParentID IN (SELECT tblKartrisAttributeValues.ATTRIBV_ID
							FROM tblKartrisAttributes INNER JOIN tblKartrisAttributeValues 
							ON tblKartrisAttributes.ATTRIB_ID = tblKartrisAttributeValues.ATTRIBV_AttributeID
							WHERE   tblKartrisAttributes.ATTRIB_ShowSearch = 0);

	
	IF @Counter > 1
	BEGIN
		DECLARE @ExactSearch as nvarchar(500);
		SET @ExactSearch = Replace(@keyWordsList, '''','''', '''' '''');
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (400) WHERE SH_SessionID = @@SPID AND SH_TextValue like ''''%'''' + @ExactSearch + ''''%'''';
	END
	
	IF @NoOfVersions > 10000
	BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30) WHERE SH_SessionID = @@SPID AND SH_FieldID = 2;
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (200) WHERE SH_SessionID = @@SPID AND SH_FieldID = 1;
	END
	ELSE
	BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30 * SH_TypeID) WHERE SH_SessionID = @@SPID AND SH_TypeID IN (1, 2);
	END
	
	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;	

	SELECT @TotalResultProducts =  Count(DISTINCT SH_ProductID) FROM tblKartrisSearchHelper WHERE SH_SessionID = @@SPID;
	
	WITH SearchResult as
	(
		SELECT ROW_NUMBER() OVER (ORDER BY TotalScore DESC) as Row, 
				ProductID, TotalScore
		FROM (	SELECT 
					CASE 
					WHEN T1.SH_ProductID IS NULL THEN T2.SH_ProductID
					ELSE T1.SH_ProductID
					END AS ProductID,
					CASE 
					WHEN Score1 IS NULL THEN Score2
					WHEN Score2 IS NULL THEN Score1
					ELSE (Score1 + Score2) 
					END AS TotalScore
				FROM (
						SELECT SH_SessionID, SH_ProductID, Sum(SH_Score) as Score1
						FROM tblKartrisSearchHelper 
						WHERE SH_TypeID = 2 OR SH_TypeID = 14
						GROUP BY SH_SessionID, SH_ProductID
						HAVING SH_SessionID = @@SPID
					) T1 
					FULL OUTER JOIN 
					(
						SELECT SH_SessionID, SH_ProductID, Max(SH_Score) as Score2
						FROM tblKartrisSearchHelper 
						WHERE SH_TypeID = 1
						Group BY SH_SessionID, SH_ProductID
						HAVING SH_SessionID = @@SPID
					) T2 
					ON T1.SH_ProductID = T2.SH_ProductID
			) T3
	)
	SELECT Row, P_ID, P_Name, dbo.fnKartrisDB_TruncateDescription(P_Desc) as P_Desc, 
			dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID, @CustomerGroupID) as MinPrice, TotalScore
	FROM SearchResult INNER JOIN dbo.vKartrisTypeProducts ON SearchResult.ProductID = dbo.vKartrisTypeProducts.P_ID
	WHERE vKartrisTypeProducts.LANG_ID = @LANG_ID AND ROW BETWEEN @StartRowNumber AND @EndRowNumber
	GROUP BY Row, P_ID, P_Name, P_Desc, TotalScore
	ORDER BY TotalScore DESC

	DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID=@@SPID;
	
END'' 
END
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[_spKartrisDB_AdminSearchFTS]'') AND type in (N''P'', N''PC''))
BEGIN
EXEC dbo.sp_executesql @statement = N''
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDB_AdminSearchFTS]
(	
	@searchLocation as nvarchar(25),
	@keyWordsList as nvarchar(100),
	@LANG_ID as tinyint,
	@PageIndex as tinyint, -- 0 Based index
	@RowsPerPage as tinyint,
	@TotalResult as int OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @KeyWord as nvarchar(30);
	SET @SIndx = 0;
	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;

	DECLARE @TypeNo as tinyint;
	SET @TypeNo = 0;
	IF @searchLocation = ''''products'''' BEGIN SET @TypeNo = 2 END
	IF @searchLocation = ''''categories'''' BEGIN SET @TypeNo = 3 END
	
	--================ PRODUCTS/CATEGORIES ==================
	IF @searchLocation = ''''products'''' OR @searchLocation = ''''categories''''
	BEGIN
			CREATE TABLE #_ProdCatSearchTbl(ItemID nvarchar(255), ItemValue nvarchar(MAX))
			WHILE @SIndx <= LEN(@keyWordsList)
			BEGIN
				
				SET @CIndx = CHARINDEX('''','''', @keyWordsList, @SIndx)
				IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
				SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
				SET @SIndx = @CIndx + 1;
				INSERT INTO #_ProdCatSearchTbl (ItemID,ItemValue)
				SELECT     CAST(LE_ParentID as nvarchar(255)), LE_Value
				FROM		tblKartrisLanguageElements
				WHERE     (LE_LanguageID = @LANG_ID) AND (LE_TypeID = @TypeNo) AND (LE_FieldID = 1) AND Contains(LE_Value, @KeyWord);
			END

			SELECT @TotalResult =  Count(ItemID) FROM #_ProdCatSearchTbl;

			SELECT     ItemID, ItemValue
			FROM         #_ProdCatSearchTbl
			
			DROP TABLE #_ProdCatSearchTbl;
		END

	--================ VERSIONS ==================
	IF @searchLocation = ''''versions''''
	BEGIN
		CREATE TABLE #_VersionSearchTbl(VersionID nvarchar(255), VersionName nvarchar(MAX), VersionCode nvarchar(25), ProductID nvarchar(255))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX('''','''', @keyWordsList, @SIndx)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			SET @SIndx = @CIndx + 1;
			INSERT INTO #_VersionSearchTbl (VersionID, VersionName, VersionCode, ProductID)
			SELECT     CAST(LE_ParentID as nvarchar(255)), LE_Value, dbo.fnKartrisVersions_GetCodeNumber(LE_ParentID),
						CAST(dbo.fnKartrisVersions_GetProductID(LE_ParentID) as nvarchar(255))
			FROM		tblKartrisLanguageElements
			WHERE     (LE_LanguageID = @LANG_ID) AND (LE_TypeID = 1) AND (LE_FieldID = 1) AND contains(LE_Value, @KeyWord);

			-- SEARCH FOR THE CODE NUMBER
			INSERT INTO #_VersionSearchTbl (VersionID, VersionName, VersionCode, ProductID)
			SELECT     CAST(LE_ParentID as nvarchar(255)), LE_Value, dbo.fnKartrisVersions_GetCodeNumber(LE_ParentID),
						CAST(dbo.fnKartrisVersions_GetProductID(LE_ParentID) as nvarchar(255))
			FROM		tblKartrisLanguageElements
			WHERE     (LE_LanguageID = @LANG_ID) AND (LE_TypeID = 1) AND (LE_FieldID = 1) 
					AND LE_ParentID IN (SELECT V_ID FROM tblKartrisVersions WHERE V_CodeNumber = @KeyWord);

		END

		SELECT @TotalResult =  Count(VersionID) FROM #_VersionSearchTbl;
		
		SELECT     VersionID, VersionName, VersionCode, ProductID
		FROM         #_VersionSearchTbl
		DROP TABLE #_VersionSearchTbl;
	END

	--================ CUSTOMERS ==================
	IF @searchLocation = ''''customers''''
	BEGIN
			
			CREATE TABLE #_CustomerSearchTbl(CustomerID nvarchar(255), CustomerName nvarchar(50), CustomerEmail nvarchar(100))
			WHILE @SIndx <= LEN(@keyWordsList)
			BEGIN
				
				SET @CIndx = CHARINDEX('''','''', @keyWordsList, @SIndx)
				IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
				SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
				SET @SIndx = @CIndx + 1;

				INSERT INTO #_CustomerSearchTbl (CustomerID, CustomerName, CustomerEmail)
				SELECT     tblKartrisUsers.U_ID, tblKartrisAddresses.ADR_Name, tblKartrisUsers.U_EmailAddress
				FROM         tblKartrisAddresses RIGHT OUTER JOIN
									  tblKartrisUsers ON tblKartrisAddresses.ADR_ID = tblKartrisUsers.U_DefBillingAddressID
				WHERE     Contains(tblKartrisAddresses.ADR_Name, @KeyWord ) OR
						Contains(tblKartrisUsers.U_EmailAddress, @KeyWord );

			END

			SELECT @TotalResult =  Count(CustomerID) FROM #_CustomerSearchTbl;

			SELECT     CustomerID, CustomerName, CustomerEmail
			FROM         #_CustomerSearchTbl
			
			DROP TABLE #_CustomerSearchTbl;
		END

		--================ ORDERS ==================
		IF @searchLocation = ''''orders''''
		BEGIN
			CREATE TABLE #_OrdersSearchTbl(OrderID int, PurchaseOrderNumber nvarchar(50))
			WHILE @SIndx <= LEN(@keyWordsList)
			BEGIN
				
				SET @CIndx = CHARINDEX('''','''', @keyWordsList, @SIndx)
				IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
				SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
				SET @SIndx = @CIndx + 1;

				INSERT INTO #_OrdersSearchTbl (OrderID, PurchaseOrderNumber)
				SELECT     tblKartrisOrders.O_ID, tblKartrisOrders.O_PurchaseOrderNo
				FROM         tblKartrisOrders 
				WHERE     Contains(tblKartrisOrders.O_PurchaseOrderNo,@KeyWord);

				BEGIN TRY
					INSERT INTO #_OrdersSearchTbl (OrderID, PurchaseOrderNumber)
					SELECT     tblKartrisOrders.O_ID, tblKartrisOrders.O_PurchaseOrderNo
					FROM         tblKartrisOrders 
					WHERE     (tblKartrisOrders.O_ID = @KeyWord);
				END TRY
				BEGIN CATCH
				END CATCH

			END

			SELECT @TotalResult =  Count(OrderID) FROM #_OrdersSearchTbl;


			SELECT     OrderID, PurchaseOrderNumber
			FROM         #_OrdersSearchTbl
			
			DROP TABLE #_OrdersSearchTbl;
		END

	--================ CONFIG ==================
	IF @searchLocation = ''''config''''
	BEGIN
			
		CREATE TABLE #_ConfigSearchTbl(ConfigName nvarchar(100), ConfigValue nvarchar(255))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX('''','''', @keyWordsList, @SIndx)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			SET @SIndx = @CIndx + 1;

			INSERT INTO #_ConfigSearchTbl (ConfigName, ConfigValue)
			SELECT     tblKartrisConfig.CFG_Name, tblKartrisConfig.CFG_Value
			FROM         tblKartrisConfig 
			WHERE     Contains(tblKartrisConfig.CFG_Name,@KeyWord);

		END

		SELECT @TotalResult =  Count(ConfigName) FROM #_ConfigSearchTbl;

		SELECT     ConfigName, ConfigValue
		FROM         #_ConfigSearchTbl
		
		DROP TABLE #_ConfigSearchTbl;
	END

	--================ LS ==================
	IF @searchLocation = ''''site''''
	BEGIN
			
		CREATE TABLE #_LSSearchTbl(LSFB char(1), LSLang tinyint, LSName nvarchar(255), LSValue nvarchar(MAX), LSClass nvarchar(50))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX('''','''', @keyWordsList, @SIndx)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			SET @SIndx = @CIndx + 1;

			INSERT INTO #_LSSearchTbl (LSFB, LSLang, LSName, LSValue, LSClass)
			SELECT     tblKartrisLanguageStrings.LS_FrontBack, tblKartrisLanguageStrings.LS_LangID,
						tblKartrisLanguageStrings.LS_Name, tblKartrisLanguageStrings.LS_Value, tblKartrisLanguageStrings.LS_ClassName
			FROM         tblKartrisLanguageStrings 
			WHERE     tblKartrisLanguageStrings.LS_LangID = @LANG_ID AND
					(Contains(tblKartrisLanguageStrings.LS_Name, @KeyWord) OR
						Contains(tblKartrisLanguageStrings.LS_Value, @KeyWord));

		END

		SELECT @TotalResult =  Count(LSName) FROM #_LSSearchTbl;

		SELECT     LSFB, LSLang, LSName, LSValue, LSClass
		FROM         #_LSSearchTbl
		
		DROP TABLE #_LSSearchTbl;
	END

END
''
END
		
END




' 
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisDB_SearchFTS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

ALTER PROCEDURE [dbo].[spKartrisDB_SearchFTS]
(	@keyWordsList as nvarchar(500),
	@LANG_ID as tinyint,
	@PageIndex as tinyint, -- 0 Based index
	@RowsPerPage as tinyint,
	@TotalResultProducts as int OUTPUT,
	@MinPrice as real,
	@MaxPrice as real,
	@CustomerGroupID as smallint
)
AS
BEGIN
	SET NOCOUNT ON;
	
	-----------------------
	-- Variable Declaration
	-----------------------
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @Keyword as nvarchar(150);
	DECLARE @Counter as int;
	
	DECLARE @NoOfVersions as bigint;
	SELECT @NoOfVersions = Count(1)	FROM tblKartrisVersions;
	
	DECLARE @DataToSearch as nvarchar(100);
	IF @NoOfVersions > 10000
	BEGIN
		SET @DataToSearch = ''(LE_TypeID IN (2,14)) AND (LE_FieldID IN (1,2))''
	END
	ELSE
	BEGIN
		SET @DataToSearch = ''(LE_TypeID IN (1,2,14)) AND (LE_FieldID IN (1))''
	END
	
	SET @SIndx = 0;
	SET @Counter = 0;
	WHILE @SIndx <= LEN(@keyWordsList)
	BEGIN
		
		-- Loop through out the keyword''''''''s list
		SET @Counter = @Counter + 1;	-- keywords counter
		SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)	-- Next keyword starting index (1-Based Index)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+ 1 END	-- If no more keywords, set next starting index to not exist
		SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
		
		SET @SIndx = @CIndx + 1;	-- The next starting index
		
		PRINT ''
		INSERT INTO tblKartrisSearchHelper
		SELECT @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = 1 AND '' + @DataToSearch + '' AND (Contains(LE_Value, '''''' + @KeyWord + '''''')) ''
	
		EXECUTE(''
		INSERT INTO tblKartrisSearchHelper
		SELECT @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = '' + @LANG_ID + '' AND '' + @DataToSearch + '' AND (Contains(LE_Value, '''''' + @KeyWord + '''''')) '');
			
		
		EXECUTE(''
		INSERT INTO tblKartrisSearchHelper
		SELECT     @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0
		FROM         tblKartrisVersions
		WHERE     (V_Live = 1) AND (V_CodeNumber ='''''' + @Keyword + '''''')'' );
				
	END

	IF @MinPrice <> -1 AND @MaxPrice <> -1
	BEGIN
		UPDATE tblKartrisSearchHelper
		SET SH_Price = dbo.fnKartrisProduct_GetMinPriceWithCG(SH_ProductID, @CustomerGroupID)
		WHERE SH_SessionID = @@SPID;
		DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID = @@SPID AND SH_Price NOT BETWEEN @MinPrice AND @MaxPrice;
	END

	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID AND SH_ProductID IN (	SELECT P_ID 
												FROM dbo.tblKartrisProducts 
												WHERE P_Live = 0 
													OR (P_CustomerGroupID IS NOT NULL AND P_CustomerGroupID <> @CustomerGroupID)); 
	
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID AND SH_TypeID = 14 
			AND SH_ParentID IN (SELECT tblKartrisAttributeValues.ATTRIBV_ID
							FROM tblKartrisAttributes INNER JOIN tblKartrisAttributeValues 
							ON tblKartrisAttributes.ATTRIB_ID = tblKartrisAttributeValues.ATTRIBV_AttributeID
							WHERE   tblKartrisAttributes.ATTRIB_ShowSearch = 0);

	
	IF @Counter > 1
	BEGIN
		DECLARE @ExactSearch as nvarchar(500);
		SET @ExactSearch = Replace(@keyWordsList, '','', '' '');
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (400) WHERE SH_SessionID = @@SPID AND SH_TextValue like ''%'' + @ExactSearch + ''%'';
	END
	
	IF @NoOfVersions > 10000
	BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30) WHERE SH_SessionID = @@SPID AND SH_FieldID = 2;
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (200) WHERE SH_SessionID = @@SPID AND SH_FieldID = 1;
	END
	ELSE
	BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30 * SH_TypeID) WHERE SH_SessionID = @@SPID AND SH_TypeID IN (1, 2);
	END
	
	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;	

	SELECT @TotalResultProducts =  Count(DISTINCT SH_ProductID) FROM tblKartrisSearchHelper WHERE SH_SessionID = @@SPID;
	
	WITH SearchResult as
	(
		SELECT ROW_NUMBER() OVER (ORDER BY TotalScore DESC) as Row, 
				ProductID, TotalScore
		FROM (	SELECT 
					CASE 
					WHEN T1.SH_ProductID IS NULL THEN T2.SH_ProductID
					ELSE T1.SH_ProductID
					END AS ProductID,
					CASE 
					WHEN Score1 IS NULL THEN Score2
					WHEN Score2 IS NULL THEN Score1
					ELSE (Score1 + Score2) 
					END AS TotalScore
				FROM (
						SELECT SH_SessionID, SH_ProductID, Sum(SH_Score) as Score1
						FROM tblKartrisSearchHelper 
						WHERE SH_TypeID = 2 OR SH_TypeID = 14
						GROUP BY SH_SessionID, SH_ProductID
						HAVING SH_SessionID = @@SPID
					) T1 
					FULL OUTER JOIN 
					(
						SELECT SH_SessionID, SH_ProductID, Max(SH_Score) as Score2
						FROM tblKartrisSearchHelper 
						WHERE SH_TypeID = 1
						Group BY SH_SessionID, SH_ProductID
						HAVING SH_SessionID = @@SPID
					) T2 
					ON T1.SH_ProductID = T2.SH_ProductID
			) T3
	)
	SELECT Row, P_ID, P_Name, dbo.fnKartrisDB_TruncateDescription(P_Desc) as P_Desc, 
			dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID, @CustomerGroupID) as MinPrice, TotalScore
	FROM SearchResult INNER JOIN dbo.vKartrisTypeProducts ON SearchResult.ProductID = dbo.vKartrisTypeProducts.P_ID
	WHERE vKartrisTypeProducts.LANG_ID = @LANG_ID AND ROW BETWEEN @StartRowNumber AND @EndRowNumber
	GROUP BY Row, P_ID, P_Name, P_Desc, TotalScore
	ORDER BY TotalScore DESC

	DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID=@@SPID;
	
END'
END

GO
/****** Object:  Trigger [trigKartrisSavedExports_DML]    Script Date: 04/13/2010 16:47:18 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trigKartrisSavedExports_DML]'))
DROP TRIGGER [dbo].[trigKartrisSavedExports_DML]
GO
/****** Object:  Table [dbo].[tblKartrisSavedExports]    Script Date: 04/13/2010 16:36:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblKartrisSavedExports]') AND type in (N'U'))
DROP TABLE [dbo].[tblKartrisSavedExports]
GO
/****** Object:  Table [dbo].[tblKartrisSavedExports]    Script Date: 04/13/2010 16:35:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblKartrisSavedExports](
	[EXPORT_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[EXPORT_Name] [nvarchar](50) NULL,
	[EXPORT_DateCreated] [datetime] NULL,
	[EXPORT_LastModified] [datetime] NULL,
	[EXPORT_Details] [nvarchar](max) NULL,
	[EXPORT_FieldDelimiter] [int] NULL,
	[EXPORT_StringDelimiter] [int] NULL,
 CONSTRAINT [aaaaatblCactushop1SavedExports_PK] PRIMARY KEY NONCLUSTERED 
(
	[EXPORT_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [dbo].[trigKartrisSavedExports_DML]    Script Date: 04/13/2010 16:46:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE	TRIGGER [dbo].[trigKartrisSavedExports_DML] ON [dbo].[tblKartrisSavedExports]  FOR INSERT, UPDATE, DELETE AS BEGIN Rollback Transaction Print '*****************************************************' Print '*****************************************************' Print '***** ERROR:Operation Not Allowed by User ******'Print '*****************************************************' Print '*****************************************************'  END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_ExportOrders]    Script Date: 04/13/2010 16:35:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDB_ExportOrders]
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
		SET @Cmd = @Cmd + ' AND O_Date BETWEEN CAST(''' + @StartDate + ''' as DateTime) AND CAST('''  + @EndDate + ''' as DateTime)'
	END
	IF @IncludeIncomplete = 0
	BEGIN
		SET @Cmd = @Cmd + ' AND O_Paid = 1 '
	END

	SET @Cmd = @Cmd + ' ORDER BY O_Date'
	EXECUTE(@Cmd);
	
	
END


GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSavedExports_Add]    Script Date: 04/13/2010 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSavedExports_Add]
(
	@Name as nvarchar(50),
	@DateCreated as datetime,
	@Details as nvarchar(MAX),
	@FieldDelimiter as int,
	@StringDelimiter as int,
	@New_ID as bigint OUTPUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DISABLE TRIGGER trigKartrisSavedExports_DML ON dbo.tblKartrisSavedExports
	INSERT INTO dbo.tblKartrisSavedExports
	VALUES(@Name,@DateCreated,@DateCreated,@Details,@FieldDelimiter,@StringDelimiter);
	SELECT @New_ID = SCOPE_IDENTITY();
	ENABLE TRIGGER trigKartrisSavedExports_DML ON dbo.tblKartrisSavedExports;
	
	
END

GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSavedExports_Delete]    Script Date: 04/13/2010 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSavedExports_Delete]
(
	@ExportID as bigint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DISABLE TRIGGER trigKartrisSavedExports_DML ON dbo.tblKartrisSavedExports
	DELETE FROM dbo.tblKartrisSavedExports
	WHERE EXPORT_ID = @ExportID;
	ENABLE TRIGGER trigKartrisSavedExports_DML ON dbo.tblKartrisSavedExports;
	
	
END

GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSavedExports_Get]    Script Date: 04/13/2010 16:35:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSavedExports_Get]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * FROM dbo.tblKartrisSavedExports	
	
END

GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSavedExports_GetByID]    Script Date: 04/13/2010 16:35:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSavedExports_GetByID]
(
	@ExportID as bigint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * FROM dbo.tblKartrisSavedExports	
	WHERE EXPORT_ID = @ExportID;
	
END

GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSavedExports_Update]    Script Date: 04/13/2010 16:35:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSavedExports_Update]
(
	@Name as nvarchar(50),
	@DateModified as datetime,
	@Details as nvarchar(MAX),
	@FieldDelimiter as int,
	@StringDelimiter as int,
	@ExportID as bigint 
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DISABLE TRIGGER trigKartrisSavedExports_DML ON dbo.tblKartrisSavedExports
	UPDATE dbo.tblKartrisSavedExports
	SET EXPORT_Name = @Name, EXPORT_LastModified = @DateModified, EXPORT_Details = @Details, 
		EXPORT_FieldDelimiter = @FieldDelimiter, EXPORT_StringDelimiter = @StringDelimiter
	WHERE EXPORT_ID = @ExportID;
	ENABLE TRIGGER trigKartrisSavedExports_DML ON dbo.tblKartrisSavedExports;
	
	
END

GO
;
DISABLE TRIGGER trigKartrisConfig_DML ON dbo.tblKartrisConfig;
/****** Object:  Table [dbo].[tblKartrisConfig]    Script Date: 04/14/2010 10:32:03 ******/
INSERT [tblKartrisConfig] ([CFG_Name], [CactuShopName_DEPRECATED], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES (N'general.fts.enabled', NULL, N'n', N's', N'b', N'Warning !! (should not be modified by user) y|n', N'Warning !! (this config should not be modified by user), it will be modified automatically if needed.

indicates if the Full Text Search is enabled', 1.0022, N'n', 0);
ENABLE TRIGGER trigKartrisConfig_DML ON dbo.tblKartrisConfig;
DISABLE TRIGGER trigKartrisLanguageStrings_DML ON dbo.tblKartrisLanguageStrings;
/****** Object:  Table [dbo].[tblKartrisLanguageStrings]    Script Date: 04/14/2010 13:37:43 ******/
SET IDENTITY_INSERT [dbo].[tblKartrisLanguageStrings] ON
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'BackMenu_GenerateFeeds', N'Generate Feeds', NULL, 1, N'Generate Feeds', NULL, N'_Kartris', 1, 32561)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'BackMenu_GenerateFeeds', NULL, NULL, 1, NULL, NULL, N'_Kartris', 3, 32562)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'BackMenu_GenerateFeeds', NULL, NULL, 1, NULL, NULL, N'_Kartris', 6, 32563)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_AverageDailyTotal', N'Average Daily Total', NULL, 1, N'Average Daily Total', NULL, N'_Statistics', 1, 32612)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_AverageDailyTotal', NULL, NULL, 1, NULL, NULL, N'_Statistics', 3, 32613)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_AverageDailyTotal', NULL, NULL, 1, NULL, NULL, N'_Statistics', 6, 32614)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Blank', N'[blank]', NULL, 1, N'[blank]', NULL, N'_Kartris', 1, 32657)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Blank', NULL, NULL, 1, NULL, NULL, N'_Kartris', 3, 32658)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Blank', NULL, NULL, 1, NULL, NULL, N'_Kartris', 6, 32659)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_CustomExport', N'Custom Export', NULL, 1, N'Custom Export', NULL, N'_Export', 1, 32630)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_CustomExport', NULL, NULL, 1, NULL, NULL, N'_Export', 3, 32631)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_CustomExport', NULL, NULL, 1, NULL, NULL, N'_Export', 6, 32632)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_DataExport', N'Data Export', NULL, 1, N'Data Export', NULL, N'_Export', 1, 32618)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_DataExport', NULL, NULL, 1, NULL, NULL, N'_Export', 3, 32619)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_DataExport', NULL, NULL, 1, NULL, NULL, N'_Export', 6, 32620)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_DataExportHeader', N'Here you can export orders in CSV format, or create a custom export using a query. See manual for further details of creating a custom file export of data.', NULL, 1, N'Here you can export orders in CSV format, or create a custom export using a query. See manual for further details of creating a custom file export of data.', NULL, N'_Export', 1, 32651)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_DataExportHeader', NULL, NULL, 1, NULL, NULL, N'_Export', 3, 32652)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_DataExportHeader', NULL, NULL, 1, NULL, NULL, N'_Export', 6, 32653)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Export', N'Export', NULL, 1, N'Export', NULL, N'_Export', 1, 32624)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Export', NULL, NULL, 1, NULL, NULL, N'_Export', 3, 32625)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Export', NULL, NULL, 1, NULL, NULL, N'_Export', 6, 32626)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_ExportFileName', N'File Name', NULL, 1, N'File Name', NULL, N'_Export', 1, 32654)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_ExportFileName', NULL, NULL, 1, NULL, NULL, N'_Export', 3, 32655)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_ExportFileName', NULL, NULL, 1, NULL, NULL, N'_Export', 6, 32656)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_ExportName', N'Export Name', NULL, 1, N'Export Name', NULL, N'_Export', 1, 32621)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_ExportName', NULL, NULL, 1, NULL, NULL, N'_Export', 3, 32622)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_ExportName', NULL, NULL, 1, NULL, NULL, N'_Export', 6, 32623)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_ExportQuery', N'Export Query', NULL, 1, N'Export Query', NULL, N'_Export', 1, 32642)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_ExportQuery', NULL, NULL, 1, NULL, NULL, N'_Export', 3, 32643)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_ExportQuery', NULL, NULL, 1, NULL, NULL, N'_Export', 6, 32644)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_FieldDelimiter', N'Field Delimiter', NULL, 1, N'Field Delimiter', NULL, N'_Export', 1, 32636)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_FieldDelimiter', NULL, NULL, 1, NULL, NULL, N'_Export', 3, 32637)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_FieldDelimiter', NULL, NULL, 1, NULL, NULL, N'_Export', 6, 32638)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Generate', N'generate', NULL, 1, N'generate', NULL, N'_Kartris', 1, 32576)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Generate', NULL, NULL, 1, NULL, NULL, N'_Kartris', 3, 32577)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Generate', NULL, NULL, 1, NULL, NULL, N'_Kartris', 6, 32578)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_GenerateFeedsDesc', N'Generated files will be saved to <i>uploads</i>/temp/filename.', NULL, 1, N'Generated files will be saved to <i>uploads</i>/temp/filename.', NULL, N'_Feeds', 1, 32567)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_GenerateFeedsDesc', NULL, NULL, 1, NULL, NULL, N'_Feeds', 3, 32568)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_GenerateFeedsDesc', NULL, NULL, 1, NULL, NULL, N'_Feeds', 6, 32569)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_GoogleFile', N'Google Base Feed File', NULL, 1, N'Google Base Feed File', NULL, N'_Feeds', 1, 32579)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_GoogleFile', NULL, NULL, 1, NULL, NULL, N'_Feeds', 3, 32580)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_GoogleFile', NULL, NULL, 1, NULL, NULL, N'_Feeds', 6, 32581)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_IncludeDetailsField', N'Include details field', NULL, 1, N'Include details field', NULL, N'_Export', 1, 32645)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_IncludeDetailsField', NULL, NULL, 1, NULL, NULL, N'_Export', 3, 32646)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_IncludeDetailsField', NULL, NULL, 1, NULL, NULL, N'_Export', 6, 32647)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_IncludeIncompleteOrders', N'Include incomplete orders', NULL, 1, N'Include incomplete orders', NULL, N'_Export', 1, 32648)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_IncludeIncompleteOrders', NULL, NULL, 1, NULL, NULL, N'_Export', 3, 32649)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_IncludeIncompleteOrders', NULL, NULL, 1, NULL, NULL, N'_Export', 6, 32650)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Last24Hours', N'Last 24 Hours', NULL, 1, N'Last 24 Hours', NULL, N'_Kartris', 1, 32603)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Last24Hours', NULL, NULL, 1, NULL, NULL, N'_Kartris', 3, 32604)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Last24Hours', NULL, NULL, 1, NULL, NULL, N'_Kartris', 6, 32605)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Last7Days', N'Last 7 Days', NULL, 1, N'Last 7 Days', NULL, N'_Kartris', 1, 32600)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Last7Days', NULL, NULL, 1, NULL, NULL, N'_Kartris', 3, 32601)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Last7Days', NULL, NULL, 1, NULL, NULL, N'_Kartris', 6, 32602)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_LastMonth', N'Last Month', NULL, 1, N'Last Month', NULL, N'_Kartris', 1, 32606)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_LastMonth', NULL, NULL, 1, NULL, NULL, N'_Kartris', 3, 32607)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_LastMonth', NULL, NULL, 1, NULL, NULL, N'_Kartris', 6, 32608)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_LastYear', N'Last Year', NULL, 1, N'Last Year', NULL, N'_Kartris', 1, 32609)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_LastYear', NULL, NULL, 1, NULL, NULL, N'_Kartris', 3, 32610)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_LastYear', NULL, NULL, 1, NULL, NULL, N'_Kartris', 6, 32611)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Orders', N'Orders', NULL, 1, N'Orders', NULL, N'_Statistics', 1, 32591)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Orders', NULL, NULL, 1, NULL, NULL, N'_Statistics', 3, 32592)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Orders', NULL, NULL, 1, NULL, NULL, N'_Statistics', 6, 32593)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_OrdersExport', N'Orders Export', NULL, 1, N'Orders Export', NULL, N'_Export', 1, 32633)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_OrdersExport', NULL, NULL, 1, NULL, NULL, N'_Export', 3, 32634)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_OrdersExport', NULL, NULL, 1, NULL, NULL, N'_Export', 6, 32635)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Period', N'Period', NULL, 1, N'Period', NULL, N'_Kartris', 1, 32597)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Period', NULL, NULL, 1, NULL, NULL, N'_Kartris', 3, 32598)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Period', NULL, NULL, 1, NULL, NULL, N'_Kartris', 6, 32599)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_SavedExports', N'Saved Exports', NULL, 1, N'Saved Exports', NULL, N'_Export', 1, 32627)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_SavedExports', NULL, NULL, 1, NULL, NULL, N'_Export', 3, 32628)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_SavedExports', NULL, NULL, 1, NULL, NULL, N'_Export', 6, 32629)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_SitemapFile', N'Sitemap File', NULL, 1, N'Sitemap File', NULL, N'_Feeds', 1, 32570)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_SitemapFile', NULL, NULL, 1, NULL, NULL, N'_Feeds', 3, 32571)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_SitemapFile', NULL, NULL, 1, NULL, NULL, N'_Feeds', 6, 32572)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_StoreHits', N'Store Hits', NULL, 1, N'Store Hits', NULL, N'_Statistics', 1, 32615)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_StoreHits', NULL, NULL, 1, NULL, NULL, N'_Statistics', 3, 32616)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_StoreHits', NULL, NULL, 1, NULL, NULL, N'_Statistics', 6, 32617)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_StringDelimiter', N'String Delimiter', NULL, 1, N'String Delimiter', NULL, N'_Export', 1, 32639)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_StringDelimiter', NULL, NULL, 1, NULL, NULL, N'_Export', 3, 32640)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_StringDelimiter', NULL, NULL, 1, NULL, NULL, N'_Export', 6, 32641)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Tab', N'[tab]', NULL, 1, N'[tab]', NULL, N'_Export', 1, 32660)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Tab', NULL, NULL, 1, NULL, NULL, N'_Export', 3, 32661)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_Tab', NULL, NULL, 1, NULL, NULL, N'_Export', 6, 32662)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_TopSearchTerms', N'Top Search Terms', NULL, 1, N'Top Search Terms', NULL, N'_Statistics', 1, 32594)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_TopSearchTerms', NULL, NULL, 1, NULL, NULL, N'_Statistics', 3, 32595)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_TopSearchTerms', NULL, NULL, 1, NULL, NULL, N'_Statistics', 6, 32596)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_ViewFile', N'View generated file', NULL, 1, N'View generated file', NULL, N'_Feeds', 1, 32588)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_ViewFile', NULL, NULL, 1, NULL, NULL, N'_Feeds', 3, 32589)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'ContentText_ViewFile', NULL, NULL, 1, NULL, NULL, N'_Feeds', 6, 32590)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'FormLabel_ChangeFrequency', N'Change Frequency: ', NULL, 1, N'Change Frequency: ', NULL, N'_Feeds', 1, 32573)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'FormLabel_ChangeFrequency', NULL, NULL, 1, NULL, NULL, N'_Feeds', 3, 32574)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'FormLabel_ChangeFrequency', NULL, NULL, 1, NULL, NULL, N'_Feeds', 6, 32575)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'FormLabel_Condition', N'Condition: ', NULL, 1, N'Condition: ', NULL, N'_Feeds', 1, 32582)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'FormLabel_Condition', NULL, NULL, 1, NULL, NULL, N'_Feeds', 3, 32583)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'FormLabel_Condition', NULL, NULL, 1, NULL, NULL, N'_Feeds', 6, 32584)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'FormLabel_FeedType', N'Feed Type: ', NULL, 1, N'Feed Type: ', NULL, N'_Feeds', 1, 32585)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'FormLabel_FeedType', NULL, NULL, 1, NULL, NULL, N'_Feeds', 3, 32586)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'FormLabel_FeedType', NULL, NULL, 1, NULL, NULL, N'_Feeds', 6, 32587)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'PageTitle_GenerateFeeds', N'Generate Feeds', NULL, 1, N'Generate Feeds', NULL, N'_Feeds', 1, 32564)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'PageTitle_GenerateFeeds', NULL, NULL, 1, NULL, NULL, N'_Feeds', 3, 32565)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'PageTitle_GenerateFeeds', NULL, NULL, 1, NULL, NULL, N'_Feeds', 6, 32566)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'Step3_UserInstance', N'Use User Instance (SQL Server Express only) - this simplifies setup by using the .MDF database file within the App_Data folder of the web site', NULL, 1, NULL, N'Install.aspx', NULL, 1, 32558)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'Step3_UserInstance', NULL, NULL, 1, NULL, N'Install.aspx', NULL, 3, 32559)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID], [LS_ID]) VALUES (N'b', N'Step3_UserInstance', NULL, NULL, 1, NULL, N'Install.aspx', NULL, 6, 32560)
;
ENABLE TRIGGER trigKartrisLanguageStrings_DML ON dbo.tblKartrisLanguageStrings
SET IDENTITY_INSERT [dbo].[tblKartrisLanguageStrings] OFF
GO
/****** Object:  StoredProcedure [dbo].[spKartrisTaxRates_GetClosestRate]    Script Date: 04/13/2010 14:34:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisTaxRates_GetClosestRate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: 08/April/2010
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisTaxRates_GetClosestRate] ( 
	@computedTaxRate real
) AS
BEGIN
	SET NOCOUNT ON;
    select TOP 1 T_TaxRate from tblKartrisTaxRates ORDER BY ABS(T_TaxRate - @computedTaxRate), T_ID ASC
END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCategoryHierarchy_GetByLanguageID]    Script Date: 05/06/2010 12:08:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCategoryHierarchy_GetByLanguageID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- ======================================================
-- Author:		Medz
-- Create date: 02/14/2008 12:22:45
-- Description:	generate the category menu hierarchy
-- ======================================================
CREATE PROCEDURE [dbo].[spKartrisCategoryHierarchy_GetByLanguageID]
	(@LANG_ID tinyint,
	@SortByName bit)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	If @SortByName = 1
		BEGIN
			SELECT     tblKartrisCategoryHierarchy.CH_ChildID AS CAT_ID, tblKartrisCategoryHierarchy.CH_ParentID AS ParentID, vKartrisTypeCategories.CAT_Name AS Title, 
							  vKartrisTypeCategories.CAT_CustomerGroupID
			FROM         vKartrisTypeCategories INNER JOIN
								  tblKartrisCategoryHierarchy ON vKartrisTypeCategories.CAT_ID = tblKartrisCategoryHierarchy.CH_ChildID
			WHERE     (vKartrisTypeCategories.LANG_ID = @LANG_ID) AND (vKartrisTypeCategories.CAT_Live = 1)
			ORDER BY vKartrisTypeCategories.CAT_Name
		END
	ELSE
		BEGIN
		 SELECT     tblKartrisCategoryHierarchy.CH_ChildID AS CAT_ID, tblKartrisCategoryHierarchy.CH_ParentID AS ParentID, vKartrisTypeCategories.CAT_Name AS Title, 
							  vKartrisTypeCategories.CAT_CustomerGroupID
			FROM         vKartrisTypeCategories INNER JOIN
								  tblKartrisCategoryHierarchy ON vKartrisTypeCategories.CAT_ID = tblKartrisCategoryHierarchy.CH_ChildID
			WHERE     (vKartrisTypeCategories.LANG_ID = @LANG_ID) AND (vKartrisTypeCategories.CAT_Live = 1)
			ORDER BY tblKartrisCategoryHierarchy.CH_OrderNo;
		END
END



' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnTbl_SplitNumbers]    Script Date: 05/20/2010 11:29:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTbl_SplitNumbers]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[fnTbl_SplitNumbers]
(	
	@List varchar(max))
RETURNS @ParsedList 
table(_ID int) AS BEGIN
    DECLARE @_ID varchar(10), @Pos int    
    SET @List = LTRIM(RTRIM(@List))+ '',''    
    SET @Pos = CHARINDEX('','', @List, 1)    
    IF REPLACE(@List, '','', '''') <> '''' BEGIN        
		WHILE @Pos > 0 BEGIN                
			SET @_ID = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))                
			IF @_ID <> '''' BEGIN                        
				INSERT INTO @ParsedList (_ID)                         
				VALUES (CAST(@_ID AS int)) --Use Appropriate conversion                
			END                
			SET @List = RIGHT(@List, LEN(@List) - @Pos)                
			SET @Pos = CHARINDEX('','', @List, 1)        
		END    
	END     
	RETURN
END'
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnTbl_SplitStrings]    Script Date: 05/20/2010 11:29:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTbl_SplitStrings]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[fnTbl_SplitStrings]
(	
	@List varchar(max))
RETURNS @ParsedList 
table(_ID varchar(10)) AS BEGIN
    DECLARE @_ID varchar(10), @Pos int    
    SET @List = LTRIM(RTRIM(@List))+ '',''    
    SET @Pos = CHARINDEX('','', @List, 1)    
    IF REPLACE(@List, '','', '''') <> '''' BEGIN        
		WHILE @Pos > 0 BEGIN                
			SET @_ID = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))                
			IF @_ID <> '''' BEGIN                        
				INSERT INTO @ParsedList (_ID)                         
				VALUES (@_ID)              
			END                
			SET @List = RIGHT(@List, LEN(@List) - @Pos)                
			SET @Pos = CHARINDEX('','', @List, 1)        
		END    
	END     
	RETURN
END'
END
/****** Object:  UserDefinedFunction [dbo].[fnKartrisSupportTicketMessages_IsAwaitingReplyFromUser]    Script Date: 05/26/2010 11:09:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisSupportTicketMessages_IsAwaitingReplyFromUser]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisSupportTicketMessages_IsAwaitingReplyFromUser]
(
	@TIC_ID as bigint
)
RETURNS bit
AS
BEGIN

	DECLARE @Status as char(1);
	SELECT @Status = TIC_Status
	FROM dbo.tblKartrisSupportTickets
	WHERE TIC_ID = @TIC_ID;

	IF @Status = ''c'' BEGIN RETURN 0 END

	-- Declare the return variable here
	DECLARE @LastMessageID as bigint;

	SELECT  @LastMessageID =  MAX(tblKartrisSupportTicketMessages.STM_ID)
	FROM         tblKartrisSupportTicketMessages INNER JOIN
                      tblKartrisSupportTickets ON tblKartrisSupportTicketMessages.STM_TicketID = tblKartrisSupportTickets.TIC_ID
	WHERE tblKartrisSupportTicketMessages.STM_TicketID = @TIC_ID;

	DECLARE @LoginID as smallint;
	SELECT @LoginID = STM_LoginID
	FROM dbo.tblKartrisSupportTicketMessages
	WHERE STM_ID = @LastMessageID;

	
	IF @LoginID = 0
	BEGIN
		RETURN 0;
	END
	
	RETURN 1;
END'
END
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSupportTickets_GetByUserID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisSupportTickets_GetByUserID]
(
	@U_ID as int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     TIC_ID, TIC_DateOpened, TIC_DateClosed, TIC_Subject, 
			dbo.fnKartrisSupportTicketMessages_IsAwaitingReplyFromUser(TIC_ID) as TIC_AwaitingReplay
FROM         tblKartrisSupportTickets
WHERE     (TIC_UserID = @U_ID)
	
END'
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSupportTicketTypes_Update]    Script Date: 05/25/2010 13:37:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSupportTicketTypes_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSupportTicketTypes_Update]
(
	@ID as int,
	@Type as nvarchar(50),
	@Level as char(1)	
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DISABLE TRIGGER trigKartrisSupportTicketTypes_DML ON dbo.tblKartrisSupportTicketTypes;

	UPDATE dbo.tblKartrisSupportTicketTypes
	SET STT_Name = @Type, STT_Level = @Level
	WHERE STT_ID = @ID;

ENABLE TRIGGER trigKartrisSupportTicketTypes_DML ON dbo.tblKartrisSupportTicketTypes;
END
'
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSupportTicketTypes_Add]    Script Date: 05/25/2010 13:35:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSupportTicketTypes_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSupportTicketTypes_Add]
(
	@Type as nvarchar(50),
	@Level as char(1),
	@New_ID as int OUTPUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DISABLE TRIGGER trigKartrisSupportTicketTypes_DML ON dbo.tblKartrisSupportTicketTypes;

	INSERT INTO dbo.tblKartrisSupportTicketTypes
	VALUES (@Type, @Level);

	SELECT @New_ID = SCOPE_IDENTITY();

ENABLE TRIGGER trigKartrisSupportTicketTypes_DML ON dbo.tblKartrisSupportTicketTypes;
END'
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSupportTicketTypes_Delete]    Script Date: 05/25/2010 13:07:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSupportTicketTypes_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSupportTicketTypes_Delete]
(
	@ID as int,
	@NewTypeID as int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DISABLE TRIGGER trigKartrisSupportTicketTypes_DML ON dbo.tblKartrisSupportTicketTypes;
DISABLE TRIGGER trigKartrisSupportTickets_DML ON dbo.tblKartrisSupportTickets;
	
	UPDATE dbo.tblKartrisSupportTickets
	SET TIC_SupportTicketTypeID = @NewTypeID
	WHERE TIC_SupportTicketTypeID = @ID;

	DELETE FROM dbo.tblKartrisSupportTicketTypes
	WHERE STT_ID = @ID;

ENABLE TRIGGER trigKartrisSupportTickets_DML ON dbo.tblKartrisSupportTickets;
ENABLE TRIGGER trigKartrisSupportTicketTypes_DML ON dbo.tblKartrisSupportTicketTypes;
END'
END
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSupportTickets_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisSupportTickets_Add]
(
	@OpenedDate as datetime,
	@TicketType as int,
	@Subject as nvarchar(100),
	@Text as nvarchar(MAX),
	@U_ID as int,
	@TIC_NewID as bigint OUTPUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DISABLE TRIGGER trigKartrisSupportTickets_DML ON tblKartrisSupportTickets;
	INSERT INTO dbo.tblKartrisSupportTickets
	VALUES (@OpenedDate, NULL, @Subject, @U_ID, 0, @TicketType, ''o'',0);
ENABLE TRIGGER trigKartrisSupportTickets_DML ON tblKartrisSupportTickets;

	SELECT @TIC_NewID  = SCOPE_IDENTITY();
	
	IF @TIC_NewID IS NOT NULL
	BEGIN
	DISABLE TRIGGER trigKartrisSupportTicketMessages_DML ON tblKartrisSupportTicketMessages;
		INSERT INTO dbo.tblKartrisSupportTicketMessages
		VALUES	(@TIC_NewID, 0, @OpenedDate, @Text);
	ENABLE TRIGGER trigKartrisSupportTicketMessages_DML ON tblKartrisSupportTicketMessages;
	END
    
END'
END
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_TicketsCounterSummary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisDB_TicketsCounterSummary]
(	
	@NoUnassignedTickets as int OUTPUT,
	@NoOfAwatingTickets as int OUTPUT,
	@LoginID as int
)
AS
BEGIN
	SELECT @NoUnassignedTickets = Count(TIC_ID) FROM dbo.tblKartrisSupportTickets WHERE TIC_LoginID = 0;
	DECLARE @LastMessageID as bigint;
	
	SELECT  @NoOfAwatingTickets = COUNT(DISTINCT tblKartrisSupportTicketMessages.STM_TicketID)
	FROM         tblKartrisSupportTicketMessages INNER JOIN
						  tblKartrisSupportTickets ON tblKartrisSupportTicketMessages.STM_TicketID = tblKartrisSupportTickets.TIC_ID
	WHERE     (tblKartrisSupportTickets.TIC_Status <> ''c'') AND
		dbo.fnKartrisSupportTicketMessages_IsAwaitingReply(tblKartrisSupportTicketMessages.STM_TicketID) = 1
		AND   (tblKartrisSupportTickets.TIC_LoginID = @LoginID);	


END
' 
END
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_GetCustomerDiscount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 20/May/2008
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisBasket_GetCustomerDiscount] (
	@CustomerID int
) AS
BEGIN
	SET NOCOUNT ON;

	declare @CG_Discount int
	declare @U_CustomerDiscount float
	declare @Discount float


	select @CG_Discount=isnull(CG.CG_Discount,0),@U_CustomerDiscount=U.U_CustomerDiscount from tblKartrisUsers U
	left join tblKartrisCustomerGroups CG on U.U_CustomerGroupID=CG.CG_ID and CG.CG_Live=1
	where U_ID=@CustomerID

	IF @U_CustomerDiscount = 0 BEGIN
		SET @Discount = @CG_Discount;
	END
	ELSE	BEGIN
		SET @Discount = @U_CustomerDiscount;
	END

	select isnull(@Discount,0) as ''Discount''

END

' 
END
GO
;
DISABLE TRIGGER trigKartrisConfig_DML ON [dbo].[tblKartrisConfig]
DELETE FROM [dbo].[tblKartrisConfig] WHERE [CFG_Name] = 'frontend.users.customerdiscount';
ENABLE TRIGGER trigKartrisConfig_DML ON [dbo].[tblKartrisConfig];
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_DeleteByProduct]    Script Date: 03/02/2010 13:57:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_DeleteByProduct]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_DeleteByProduct](@P_ID as int, @DownloadFiles as nvarchar(MAX) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON;
	SET @DownloadFiles = '''';
Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;
	DECLARE versionCursor CURSOR FOR 
	SELECT V_ID
	FROM dbo.tblKartrisVersions
	WHERE V_ProductID = @P_ID
		
	DECLARE @V_ID as bigint;
	
	OPEN versionCursor
	FETCH NEXT FROM versionCursor
	INTO @V_ID;

	WHILE @@FETCH_STATUS = 0
	BEGIN

Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;	
	DELETE FROM tblKartrisLanguageElements
	WHERE     (LE_TypeID = 1)	-- For Versions
	AND (LE_ParentID = @V_ID);	-- VersionID
Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;	

Disable Trigger trigKartrisVersionOptionLink_DML ON tblKartrisVersionOptionLink;	
	DELETE FROM dbo.tblKartrisVersionOptionLink
	WHERE V_OPT_VersionID = @V_ID;
Enable Trigger trigKartrisVersionOptionLink_DML ON tblKartrisVersionOptionLink;	

Disable Trigger trigKartrisCustomerGroupPrices_DML ON dbo.tblKartrisCustomerGroupPrices
	DELETE FROM dbo.tblKartrisCustomerGroupPrices
	WHERE CGP_VersionID = @V_ID;
Enable Trigger trigKartrisCustomerGroupPrices_DML ON dbo.tblKartrisCustomerGroupPrices;

Disable Trigger trigKartrisQuantityDiscounts_DML ON dbo.tblKartrisQuantityDiscounts
	DELETE FROM dbo.tblKartrisQuantityDiscounts
	WHERE QD_VersionID = @V_ID;
Enable Trigger trigKartrisQuantityDiscounts_DML ON dbo.tblKartrisQuantityDiscounts;

	SELECT @DownloadFiles = V_DownLoadInfo + ''##'' + @DownloadFiles
	FROM dbo.tblKartrisVersions
	WHERE V_ID = @V_ID AND V_DownloadType = ''u'';

	DELETE FROM dbo.tblKartrisVersions
	WHERE V_ID = @V_ID;

		
		FETCH NEXT FROM versionCursor
		INTO @V_ID;

	END

	CLOSE versionCursor
	DEALLOCATE versionCursor;
	
Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_Update]    Script Date: 03/02/2010 13:57:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisProducts_Update](
								@P_ID as int,
								@P_Live as bit, 
								@P_Featured as tinyint,
								@P_OrderVersionsBy as nvarchar(50),
								@P_VersionsSortDirection as char(1),
								@P_VersionDisplayType as char(1),
								@P_Reviews as char(1),
								@P_SupplierID as smallint,
								@P_Type as char(1),
								@P_CustomerGroupID as smallint,
								@NowOffset as datetime 
								)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @OldType as char(1);
	SELECT @OldType = P_Type FROM dbo.tblKartrisProducts WHERE P_ID = @P_ID;
	IF @OldType <> @P_Type BEGIN
		IF @OldType = 'o' BEGIN
			EXEC	[dbo].[_spKartrisProductOptionGroupLink_DeleteByProductID]	
			@ProductID = @P_ID;
			EXEC	[dbo].[_spKartrisProductOptionLink_DeleteByProductID]
			@ProductID = @P_ID;
		END
	END;
Disable Trigger trigKartrisProducts_DML ON tblKartrisProducts;	
	UPDATE tblKartrisProducts
	SET P_Live = @P_Live, P_Featured = @P_Featured, P_OrderVersionsBy = @P_OrderVersionsBy,
		P_VersionsSortDirection  = @P_VersionsSortDirection,
		P_VersionDisplayType = @P_VersionDisplayType, P_Reviews = @P_Reviews, P_SupplierID = @P_SupplierID, 
		P_Type = @P_Type, P_CustomerGroupID = @P_CustomerGroupID, P_LastModified = @NowOffset
	WHERE P_ID = @P_ID;
Enable Trigger trigKartrisProducts_DML ON tblKartrisProducts;	
		
END



' 
END
/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetMinPriceByProductList]    Script Date: 03/02/2010 13:57:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisVersions_GetMinPriceByProductList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Used in the Compare.aspx Page
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisVersions_GetMinPriceByProductList](@LANG_ID as tinyint, @P_List as nvarchar(100), @CG_ID as smallint)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	SET @SIndx = 0;

	CREATE TABLE #TempTbl(ProductID int)


	WHILE @SIndx <= LEN(@P_List)
	BEGIN
		
		SET @CIndx = CHARINDEX('','', @P_List, @SIndx)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@P_List)+1 END
		INSERT INTO #TempTbl VALUES (CAST(SUBSTRING(@P_List, @SIndx, @CIndx - @SIndx) as int));
		SET @SIndx = @CIndx + 1;

	END

	SELECT     distinct P_ID, P_Name, dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID,@CG_ID) as P_Price
	FROM         vKartrisProductsVersions
	WHERE     (LANG_ID = @LANG_ID) AND (P_ID  IN (SELECT     ProductID
											FROM         [#TempTbl])) 
	GROUP BY P_ID, P_Name

	DROP TABLE #TempTbl;

END


' 
END
/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetMinPriceByProductID]    Script Date: 03/02/2010 13:57:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisVersions_GetMinPriceByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Used in the Compare.aspx Page
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisVersions_GetMinPriceByProductID](@LANG_ID as tinyint, @P_ID as int, @CG_ID as smallint)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	SELECT     distinct P_ID, P_Name, dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID, @CG_ID) as P_Price
	FROM         vKartrisProductsVersions
	WHERE     (LANG_ID = @LANG_ID) AND (P_ID = @P_ID)
	GROUP BY P_ID, P_Name

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisDB_GetAttributesToCompare]    Script Date: 03/02/2010 13:57:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisDB_GetAttributesToCompare]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisDB_GetAttributesToCompare]
(	@P_List as nvarchar(100),
	@LANG_ID as tinyint,
	@CG_ID as smallint
)
AS
BEGIN
	SET NOCOUNT ON;

    --DECLARE @P_List nvarchar(50);
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	--SET @P_List = ''113,1,114,94, 90'';
	SET @SIndx = 0;

	CREATE TABLE #TempTbl(ProductID int)


	WHILE @SIndx <= LEN(@P_List)
	BEGIN
		
		SET @CIndx = CHARINDEX('','', @P_List, @SIndx)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@P_List)+1 END
		--Print ''SIndx:'' + CAST(@SIndx as nvarchar(10)) + '', CIndx:'' + CAST(@CIndx as nvarchar(10)) + ''-'' + SUBSTRING(@P_List, @SIndx, @CIndx - @SIndx);
		INSERT INTO #TempTbl VALUES (CAST(SUBSTRING(@P_List, @SIndx, @CIndx - @SIndx) as int));
		SET @SIndx = @CIndx + 1;

	END

	SELECT DISTINCT vKartrisProductsVersions.P_ID, vKartrisProductsVersions.P_Name, 
			dbo.fnKartrisProduct_GetMinPriceWithCG(vKartrisProductsVersions.P_ID, @CG_ID) as P_Price, vKartrisTypeAttributes.ATTRIB_ID 
		  , vKartrisTypeAttributes.ATTRIB_Name, vKartrisTypeAttributeValues.ATTRIBV_Value, 
		  vKartrisTypeAttributes.ATTRIB_Compare
	FROM         vKartrisTypeAttributes INNER JOIN
						  vKartrisTypeAttributeValues ON vKartrisTypeAttributes.ATTRIB_ID = vKartrisTypeAttributeValues.ATTRIBV_AttributeID RIGHT OUTER JOIN
						  vKartrisProductsVersions ON vKartrisTypeAttributeValues.ATTRIBV_ProductID = vKartrisProductsVersions.P_ID
	WHERE     (vKartrisProductsVersions.LANG_ID = @LANG_ID) AND (vKartrisProductsVersions.P_ID IN
							  (SELECT     ProductID
								FROM         [#TempTbl])) AND (vKartrisTypeAttributes.ATTRIB_Compare <> ''n'' OR
								vKartrisTypeAttributes.ATTRIB_Compare IS NULL)
	--GROUP BY vKartrisProductsVersions.P_ID, vKartrisProductsVersions.P_Name, vKartrisTypeAttributes.ATTRIB_ID,
	--		 vKartrisTypeAttributes.ATTRIB_Name, vKartrisTypeAttributeValues.ATTRIBV_Value, 
	--					  vKartrisTypeAttributes.ATTRIB_Compare




	DROP TABLE #TempTbl;

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetRowsBetweenByCatID]    Script Date: 03/02/2010 13:57:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetRowsBetweenByCatID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Replaces "spKartris_PROD_SelectByCAT"
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisProducts_GetRowsBetweenByCatID]
	(
	@LANG_ID as tinyint,
	@CAT_ID as int,
	@PageIndex as tinyint, -- 0 Based index
	@RowsPerPage as smallint,
	@CGroupID as smallint
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
    -- Insert statements for procedure here

	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;
	
	DECLARE @OrderBy as nvarchar(50), @OrderDirection as char(1)
	SELECT @OrderBy = CAT_OrderProductsBy, @OrderDirection = CAT_ProductsSortDirection
	FROM dbo.tblKartrisCategories
	WHERE CAT_ID = @CAT_ID;

	IF @OrderBy is NULL OR @OrderBy = ''d''
	BEGIN 
		SELECT @OrderBy = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = ''frontend.products.display.sortdefault'';
	END;
	IF @OrderDirection is NULL OR @OrderDirection = '''' BEGIN 
		SELECT @OrderDirection = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = ''frontend.products.display.sortdirection'';
	END;
	
		With ProductList AS 
		(
			SELECT	CASE 
					WHEN (@OrderBy = ''P_ID'' AND @OrderDirection = ''A'') THEN	ROW_NUMBER() OVER (ORDER BY P_ID ASC) 
					WHEN (@OrderBy = ''P_ID'' AND @OrderDirection = ''D'') THEN	ROW_NUMBER() OVER (ORDER BY P_ID DESC) 
					WHEN (@OrderBy = ''P_Name'' AND @OrderDirection = ''A'') THEN ROW_NUMBER() OVER (ORDER BY P_Name ASC) 
					WHEN (@OrderBy = ''P_Name'' AND @OrderDirection = ''D'') THEN ROW_NUMBER() OVER (ORDER BY P_Name DESC) 
					WHEN (@OrderBy = ''P_DateCreated'' AND @OrderDirection = ''A'') THEN ROW_NUMBER() OVER (ORDER BY P_DateCreated ASC) 
					WHEN (@OrderBy = ''P_DateCreated'' AND @OrderDirection = ''D'') THEN ROW_NUMBER() OVER (ORDER BY P_DateCreated DESC) 
					WHEN (@OrderBy = ''P_LastModified'' AND @OrderDirection = ''A'') THEN ROW_NUMBER() OVER (ORDER BY P_LastModified ASC) 
					WHEN (@OrderBy = ''P_LastModified'' AND @OrderDirection = ''D'') THEN ROW_NUMBER() OVER (ORDER BY P_LastModified DESC) 
					WHEN (@OrderBy = ''PCAT_OrderNo'' AND @OrderDirection = ''A'') THEN ROW_NUMBER() OVER (ORDER BY PCAT_OrderNo ASC) 
					WHEN (@OrderBy = ''PCAT_OrderNo'' AND @OrderDirection = ''D'') THEN ROW_NUMBER() OVER (ORDER BY PCAT_OrderNo DESC) 
					END AS Row,
					vKartrisTypeProducts.P_ID, dbo.fnKartrisProduct_GetMinPriceWithCG(vKartrisTypeProducts.P_ID, @CGroupID) AS MinPrice, MIN(tblKartrisTaxRates.T_Taxrate) AS MinTaxRate, vKartrisTypeProducts.P_Name, 
										  dbo.fnKartrisDB_TruncateDescription(vKartrisTypeProducts.P_Desc) AS P_Desc, vKartrisTypeProducts.P_StrapLine, vKartrisTypeProducts.P_VersionDisplayType, 
										  vKartrisTypeProducts.P_DateCreated, vKartrisTypeProducts.P_LastModified, tblKartrisProductCategoryLink.PCAT_OrderNo
					FROM         tblKartrisProductCategoryLink INNER JOIN
										  vKartrisTypeProducts ON tblKartrisProductCategoryLink.PCAT_ProductID = vKartrisTypeProducts.P_ID INNER JOIN
										  tblKartrisVersions ON vKartrisTypeProducts.P_ID = tblKartrisVersions.V_ProductID LEFT OUTER JOIN
										  tblKartrisTaxRates ON tblKartrisTaxRates.T_ID = tblKartrisVersions.V_Tax
					WHERE     (tblKartrisVersions.V_Live = 1) AND (tblKartrisVersions.V_Type = ''b'' OR tblKartrisVersions.V_Type = ''v'' ) AND (vKartrisTypeProducts.LANG_ID = @LANG_ID) AND (vKartrisTypeProducts.P_Live = 1) AND 
										  (tblKartrisProductCategoryLink.PCAT_CategoryID = @CAT_ID) AND (vKartrisTypeProducts.P_CustomerGroupID IS NULL OR
										  vKartrisTypeProducts.P_CustomerGroupID = @CGroupID)
					GROUP BY vKartrisTypeProducts.P_Name, vKartrisTypeProducts.P_Desc, vKartrisTypeProducts.P_StrapLine, vKartrisTypeProducts.P_ID, 
										  vKartrisTypeProducts.P_VersionDisplayType, vKartrisTypeProducts.P_DateCreated, vKartrisTypeProducts.P_LastModified, 
										  tblKartrisProductCategoryLink.PCAT_OrderNo
			
		)

		SELECT *
		FROM ProductList
		WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber
		ORDER BY Row ASC
	
END
' 
END
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetMinPriceByProductID]    Script Date: 03/02/2010 13:57:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetMinPriceByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisProducts_GetMinPriceByProductID](@LANG_ID as tinyint, @P_ID as int, @CG_ID as smallint)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	SELECT     distinct P_ID, P_Name, dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID, @CG_ID) as P_Price
	FROM         dbo.vKartrisTypeProducts
	WHERE     (LANG_ID = @LANG_ID) AND (P_ID = @P_ID)
	GROUP BY P_ID, P_Name

END


' 
END
/****** Object:  UserDefinedFunction [dbo].[fnKartrisProduct_GetMinPrice]    Script Date: 03/02/2010 13:57:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisProduct_GetMinPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [dbo].[fnKartrisProduct_GetMinPrice] 
(
	-- Add the parameters for the function here
	@V_ProductID as int
	
)
RETURNS real
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result real;

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = Min(V_Price) FROM tblKartrisVersions WHERE V_ProductID = @V_ProductID AND V_Live = 1 AND tblKartrisVersions.V_CustomerGroupID IS NULL;
	
	DECLARE @QD_MinPrice as real;
	SELECT @QD_MinPrice = Min(QD_Price)
	FROM dbo.tblKartrisQuantityDiscounts INNER JOIN tblKartrisVersions 
		ON tblKartrisQuantityDiscounts.QD_VersionID = tblKartrisVersions.V_ID
	WHERE tblKartrisVersions.V_Live = 1 AND tblKartrisVersions.V_ProductID = @V_ProductID AND tblKartrisVersions.V_CustomerGroupID IS NULL;

	IF @QD_MinPrice <> 0 AND @QD_MinPrice IS NOT NULL AND @QD_MinPrice < @Result
	BEGIN
		SET @Result = @QD_MinPrice
	END

	IF @Result IS NULL
	BEGIN
		SET @Result = 0;
	END
	-- Return the result of the function
	RETURN @Result

END
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisProduct_GetMinPriceWithCG]    Script Date: 06/03/2010 13:57:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisProduct_GetMinPriceWithCG]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisProduct_GetMinPriceWithCG] 
(
	-- Add the parameters for the function here
	@V_ProductID as int,
	@CG_ID as smallint
	
)
RETURNS real
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result real;

	IF @CG_ID = 0 OR @CG_ID IS NULL BEGIN
		SET @Result = dbo.fnKartrisProduct_GetMinPrice(@V_ProductID);
	END	
	ELSE BEGIN
		-- Add the T-SQL statements to compute the return value here
		SELECT @Result = Min(V_Price) FROM tblKartrisVersions 
		WHERE V_ProductID = @V_ProductID AND V_Live = 1
			AND (tblKartrisVersions.V_CustomerGroupID IS NULL OR tblKartrisVersions.V_CustomerGroupID = @CG_ID);
		
		DECLARE @QD_MinPrice as real;
		SELECT @QD_MinPrice = Min(QD_Price)
		FROM dbo.tblKartrisQuantityDiscounts INNER JOIN tblKartrisVersions 
			ON tblKartrisQuantityDiscounts.QD_VersionID = tblKartrisVersions.V_ID
		WHERE tblKartrisVersions.V_Live = 1 AND tblKartrisVersions.V_ProductID = @V_ProductID 
			AND (tblKartrisVersions.V_CustomerGroupID IS NULL OR tblKartrisVersions.V_CustomerGroupID = @CG_ID);

		IF @QD_MinPrice <> 0 AND @QD_MinPrice IS NOT NULL AND @QD_MinPrice < @Result
		BEGIN
			SET @Result = @QD_MinPrice
		END
	END

	IF @Result IS NULL
	BEGIN
		SET @Result = 0;
	END
	-- Return the result of the function
	RETURN @Result

END

'
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetMinPriceWithCG]    Script Date: 06/03/2010 13:46:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetMinPriceWithCG]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisProducts_GetMinPriceWithCG](@P_ID as int, @CG_ID as smallint, @MinPrice as real OUTPUT)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	SELECT  @MinPrice = dbo.fnKartrisProduct_GetMinPriceWithCG(@P_ID, @CG_ID);

END'
END
GO