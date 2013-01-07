-- =============================================
-- KARTRIS UPDATE SCRIPT
-- From 1.3007 to 1.3008
-- =============================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION fnKartrisBasket_GetItemWeight
(
	@BasketValueID as bigint,
	@VersionID as bigint,
	@ProductID as int
)
RETURNS real
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Weight as real;

	DECLARE @ProductType as char(1);
	
	SELECT @ProductType = P_Type
	FROM tblKartrisProducts 
	WHERE P_ID = @ProductID;
	
	IF @ProductType IN ('s','m') BEGIN
		SELECT @Weight = V_Weight
		FROM tblKartrisVersions
		WHERE V_ID = @VersionID;
	END ELSE BEGIN
		DECLARE @OptionsList as nvarchar(max);
		SELECT @OptionsList = COALESCE(@OptionsList + ',', '') + CAST(T.BSKTOPT_OptionID As nvarchar(10))
		FROM (SELECT BSKTOPT_OptionID FROM dbo.tblKartrisBasketOptionValues WHERE  BSKTOPT_BasketValueID = @BasketValueID) AS T;
		
		SELECT @Weight = SUM(P_OPT_WeightChange)
		FROM dbo.tblKartrisProductOptionLink
		WHERE P_OPT_ProductID = @ProductID AND P_OPT_OptionID IN (SELECT * FROM dbo.fnTbl_SplitNumbers(@OptionsList));
		
		-- If weight = 0, then no weight change for the options, we need to use the base version.
		IF @Weight = 0 BEGIN
			SELECT @Weight = V_Weight FROM tblKartrisVersions WHERE V_ID = @VersionID;
		END
	END
	
	-- Return the result of the function
	RETURN @Weight;

END
GO
-- =============================================
-- Author:		Joseph
-- Create date: 8/Apr/08
-- Description:	
-- Remarks:	Optimization Medz - 26/07/2010
-- Re-Optimized: Mohammad 10th, June 2011(Rem:vKartrisProductsVersions slowing down the query)
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisBasketValues_GetItems] (
	@intLanguageID int,
	@intSessionID int
)
AS
BEGIN

SET NOCOUNT ON;
WITH tblBasketValues AS 
	(	SELECT BV_ID, BV_VersionID, BV_Quantity, BV_CustomText
        FROM   tblKartrisBasketValues
        WHERE  (BV_ParentType = 'b') AND (BV_ParentID = @intSessionID)
    )
    SELECT DISTINCT 
         tblKartrisProducts.P_ID AS ProductID, tblKartrisProducts.P_Type AS ProductType, tblKartrisTaxRates.T_Taxrate AS TaxRate,
         dbo.fnKartrisBasket_GetItemWeight(BV_ID, V_ID, P_ID) As Weight, tblKartrisVersions.V_RRP AS RRP, 
         dbo.fnKartrisProducts_GetName(tblKartrisProducts.P_ID, @intLanguageID) AS ProductName, 
         tblKartrisVersions.V_ID, tblBasketValues_1.BV_ID, dbo.fnKartrisVersions_GetName(BV_VersionID, @intLanguageID) AS VersionName,
         tblKartrisVersions.V_CodeNumber AS CodeNumber, tblKartrisVersions.V_Price AS Price, tblBasketValues_1.BV_Quantity AS Quantity, 
         tblKartrisVersions.V_QuantityWarnLevel AS QtyWarnLevel, tblKartrisVersions.V_Quantity, tblKartrisVersions.V_DownloadType, 
         ISNULL(tblBasketValues_1.BV_CustomText, '') AS CustomText, 
         dbo.fnKartrisBasketOptionValues_GetTotalPriceByParentAndBasketValue(@intSessionID, tblBasketValues_1.BV_ID) AS OptionsPrice, 
         tblKartrisVersions.V_CustomizationType, tblKartrisVersions.V_CustomizationDesc, tblKartrisVersions.V_CustomizationCost, tblBasketValues_1.BV_VersionID
     FROM	tblKartrisVersions INNER JOIN tblKartrisProducts ON tblKartrisVersions.V_ProductID = tblKartrisProducts.P_ID 
			INNER JOIN tblKartrisTaxRates ON tblKartrisVersions.V_Tax = tblKartrisTaxRates.T_ID 
			INNER JOIN tblBasketValues AS tblBasketValues_1 ON tblKartrisVersions.V_ID = tblBasketValues_1.BV_VersionID
     ORDER BY tblBasketValues_1.BV_ID

END
GO
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
	SET @AllTriggers = ''Addresses_DML,AdminRelatedTables_DML,AffiliateLog_DML,AffiliatePayments_DML,Attributes_DML,AttributeValues_DML,Categories_DML,CategoryHierarchy_DML,ClonedOrders_DML,Config_DML,Coupons_DML,CreditCards_DML,Currencies_DML,CustomerGroupPrices_DML,CustomerGroups_DML,DeletedItems_DML,Destination_DML,InvoiceRows_DML,KnowledgeBase_DML,LanguageElements_DML,Languages_D,Languages_DML,Languages_U,LanguageStrings_DML,Logins_DML,MediaLinks_DML,MediaTypes_DML,News_DML,OptionGroups_DML,Options_DML,OrderPaymentLink_DML,Orders_DML,OrdersPromotions_DML,Pages_DML,Payments_DML,ProductCategoryLink_DML,ProductOptionGroupLink_DML,ProductOptionLink_DML,Products_DML,PromotionParts_DML,Promotions_DML,PromotionStrings_DML,QuantityDiscounts_DML,RelatedProducts_DML,Reviews_DML,SavedBaskets_DML,SavedExports_DML,SearchStatistics_DML,ShippingMethods_DML,ShippingRates_DML,ShippingZones_DML,Statistics_DML,Suppliers_DML,SupportTicketMessages_DML,SupportTickets_DML,SupportTicketTypes_DML,TaxRates_DML,Users_DML,VersionOptionLink_DML,Versions_DML,WishLists_DML''
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
GO
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
	SET @AllTriggers = ''Addresses_DML,AdminRelatedTables_DML,AffiliateLog_DML,AffiliatePayments_DML,Attributes_DML,AttributeValues_DML,Categories_DML,CategoryHierarchy_DML,ClonedOrders_DML,Config_DML,Coupons_DML,CreditCards_DML,Currencies_DML,CustomerGroupPrices_DML,CustomerGroups_DML,DeletedItems_DML,Destination_DML,InvoiceRows_DML,KnowledgeBase_DML,LanguageElements_DML,Languages_D,Languages_DML,Languages_U,LanguageStrings_DML,Logins_DML,MediaLinks_DML,MediaTypes_DML,News_DML,OptionGroups_DML,Options_DML,OrderPaymentLink_DML,Orders_DML,OrdersPromotions_DML,Pages_DML,Payments_DML,ProductCategoryLink_DML,ProductOptionGroupLink_DML,ProductOptionLink_DML,Products_DML,PromotionParts_DML,Promotions_DML,PromotionStrings_DML,QuantityDiscounts_DML,RelatedProducts_DML,Reviews_DML,SavedBaskets_DML,SavedExports_DML,SearchStatistics_DML,ShippingMethods_DML,ShippingRates_DML,ShippingZones_DML,Statistics_DML,Suppliers_DML,SupportTicketMessages_DML,SupportTickets_DML,SupportTicketTypes_DML,TaxRates_DML,Users_DML,VersionOptionLink_DML,Versions_DML,WishLists_DML''
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
GO
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisMediaLinks_DeleteByParent]
(
	@ParentID as bigint,
	@ParentType as nvarchar(1)
)
AS
BEGIN
SET NOCOUNT ON;
		
	DECLARE @Timeoffset as int;
	set @Timeoffset = CAST(dbo.fnKartrisConfig_GetValue(''general.timeoffset'') as int);
	
	Disable Trigger trigKartrisMediaLinks_DML ON tblKartrisMediaLinks;
	Disable Trigger trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
	
	DECLARE mediaCursor CURSOR FOR 
	SELECT ML_ID
	FROM dbo.tblKartrisMediaLinks
	WHERE ML_ParentID = @ParentID and ML_ParentType = @ParentType;
		
	DECLARE @ML_ID as bigint;
	
	OPEN mediaCursor
	FETCH NEXT FROM mediaCursor
	INTO @ML_ID;

	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		DELETE FROM dbo.tblKartrisMediaLinks
		WHERE ML_ID = @ML_ID;
		IF @ML_ID <> 0 AND @ML_ID NOT IN (SELECT DELETED_ID FROM dbo.tblKartrisDeletedItems WHERE Deleted_Type = ''m'') BEGIN
			INSERT INTO dbo.tblKartrisDeletedItems VALUES(@ML_ID, ''m'', NULL, DateAdd(hour, @Timeoffset, GetDate()));
		END
		FETCH NEXT FROM mediaCursor
		INTO @ML_ID;
	END

	CLOSE mediaCursor
	DEALLOCATE mediaCursor;	
	
	Enable Trigger trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
	Enable Trigger trigKartrisMediaLinks_DML ON tblKartrisMediaLinks;
		
END'
GO
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Remarks: Optimized by Mohammad
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisProducts_GetPeopleWhoBoughtThis](
			@P_ID as int, 
			@LANG_ID as tinyint, 
			@numPeopleWhoBoughtThis as int, 
			@Type as bit)
AS
BEGIN
	SET NOCOUNT ON;
	IF @Type = 1 
		BEGIN
			WITH PeopleWhoBoughtThisList AS
			(
			SELECT TOP (@numPeopleWhoBoughtThis) AlsoProducts.P_ID, AlsoProducts.P_Name, Count(AlsoProducts.P_ID) AS TotalMatches,AlsoProducts.LANG_ID 
			FROM (((tblKartrisVersions INNER JOIN tblKartrisInvoiceRows ON tblKartrisVersions.V_CodeNumber = tblKartrisInvoiceRows.IR_VersionCode) 
			INNER JOIN (SELECT TOP(10000) O_ID, O_CustomerID FROM tblKartrisOrders WHERE O_Sent = 1 or O_Paid = 1 ORDER BY O_ID DESC) As RecentOrders ON tblKartrisInvoiceRows.IR_OrderNumberID = RecentOrders.O_ID) 
			INNER JOIN tblKartrisInvoiceRows AS AlsoInvoiceRows ON RecentOrders.O_ID = AlsoInvoiceRows.IR_OrderNumberID) 
			INNER JOIN (tblKartrisVersions AS AlsoVersions 
			INNER JOIN vKartrisTypeProducts AS AlsoProducts ON AlsoVersions.V_ProductID = AlsoProducts.P_ID) 
			ON AlsoInvoiceRows.IR_VersionCode = AlsoVersions.V_CodeNumber
			WHERE tblKartrisVersions.V_ProductID = @P_ID AND AlsoVersions.V_ProductID <> @P_ID AND AlsoProducts.P_Name <> '''' AND P_Live = 1 
					

			GROUP BY AlsoProducts.P_ID, AlsoProducts.P_Name, AlsoProducts.LANG_ID
			)
			SELECT *
			FROM PeopleWhoBoughtThisList
			WHERE LANG_ID = @LANG_ID ORDER BY TotalMatches DESC;
		END
	ELSE
		BEGIN
			WITH PeopleWhoBoughtThisList AS
			(
			SELECT     TOP (@numPeopleWhoBoughtThis) AlsoProducts.P_ID, AlsoProducts.P_Name, COUNT(1) AS TotalMatches, AlsoProducts.LANG_ID
			FROM         tblKartrisInvoiceRows AS AlsoInvoiceRows INNER JOIN
								  tblKartrisVersions AS AlsoVersions INNER JOIN
								  vKartrisTypeProducts AS AlsoProducts ON AlsoVersions.V_ProductID = AlsoProducts.P_ID ON 
								  AlsoInvoiceRows.IR_VersionCode = AlsoVersions.V_CodeNumber INNER JOIN
								  (SELECT TOP(10000) O_ID, O_CustomerID FROM tblKartrisOrders WHERE O_Sent = 1 or O_Paid = 1 ORDER BY O_ID DESC) AS AlsoOrderNumbers INNER JOIN
								  tblKartrisVersions INNER JOIN
								  tblKartrisInvoiceRows ON tblKartrisVersions.V_CodeNumber = tblKartrisInvoiceRows.IR_VersionCode INNER JOIN
								  (SELECT TOP(10000) O_ID, O_CustomerID FROM tblKartrisOrders WHERE O_Sent = 1 or O_Paid = 1 ORDER BY O_ID DESC) As RecentOrders ON tblKartrisInvoiceRows.IR_OrderNumberID = RecentOrders.O_ID INNER JOIN
								  tblKartrisUsers ON RecentOrders.O_CustomerID = tblKartrisUsers.U_ID ON AlsoOrderNumbers.O_CustomerID = tblKartrisUsers.U_ID ON 
								  AlsoInvoiceRows.IR_OrderNumberID = AlsoOrderNumbers.O_ID
			WHERE     (tblKartrisVersions.V_ProductID = @P_ID) AND (AlsoVersions.V_ProductID <> @P_ID) AND (AlsoProducts.P_Name <> '''') AND (AlsoProducts.P_Live = 1) 
			GROUP BY AlsoProducts.P_ID, AlsoProducts.P_Name, AlsoProducts.LANG_ID
			)
			SELECT *
			FROM PeopleWhoBoughtThisList
			WHERE LANG_ID = @LANG_ID ORDER BY TotalMatches DESC;
		END
END
' 
GO