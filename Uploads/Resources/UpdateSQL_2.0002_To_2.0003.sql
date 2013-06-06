﻿
ALTER VIEW [dbo].[vKartrisProductsVersions]
AS
SELECT     dbo.vKartrisTypeProducts.P_ID, dbo.vKartrisTypeProducts.P_OrderVersionsBy, dbo.vKartrisTypeProducts.P_VersionsSortDirection, 
					  dbo.vKartrisTypeProducts.P_VersionDisplayType, dbo.vKartrisTypeProducts.P_Type, tblKartrisTaxRates_1.T_Taxrate, 
					  dbo.tblKartrisProductCategoryLink.PCAT_CategoryID AS CAT_ID, dbo.vKartrisTypeProducts.LANG_ID, dbo.vKartrisTypeProducts.P_Live, 
					  dbo.tblKartrisCategories.CAT_Live, dbo.vKartrisTypeVersions.V_Live, dbo.vKartrisTypeVersions.V_ID, dbo.vKartrisTypeVersions.V_Name, 
					  dbo.vKartrisTypeVersions.V_Desc, dbo.vKartrisTypeVersions.V_CodeNumber, dbo.vKartrisTypeVersions.V_Price, dbo.vKartrisTypeVersions.V_Tax, 
					  dbo.vKartrisTypeVersions.V_Weight, dbo.vKartrisTypeVersions.V_DeliveryTime, dbo.vKartrisTypeVersions.V_Quantity, 
					  dbo.vKartrisTypeVersions.V_QuantityWarnLevel, dbo.vKartrisTypeVersions.V_DownLoadInfo, dbo.vKartrisTypeVersions.V_DownloadType, 
					  dbo.vKartrisTypeVersions.V_RRP, dbo.vKartrisTypeVersions.V_OrderByValue, dbo.vKartrisTypeVersions.V_Type, dbo.vKartrisTypeVersions.V_CustomerGroupID, 
					  dbo.vKartrisTypeProducts.P_Name, dbo.vKartrisTypeProducts.P_Desc, dbo.vKartrisTypeProducts.P_StrapLine, dbo.vKartrisTypeProducts.P_PageTitle, 
					  dbo.vKartrisTypeProducts.P_Featured, dbo.vKartrisTypeProducts.P_SupplierID, dbo.vKartrisTypeProducts.P_CustomerGroupID, dbo.vKartrisTypeProducts.P_Reviews, 
					  dbo.vKartrisTypeProducts.P_AverageRating, dbo.vKartrisTypeProducts.P_DateCreated, dbo.vKartrisTypeVersions.V_CustomizationType, 
					  dbo.vKartrisTypeVersions.V_CustomizationDesc, dbo.vKartrisTypeVersions.V_CustomizationCost, dbo.tblKartrisTaxRates.T_Taxrate AS T_TaxRate2, dbo.tblKartrisCategories.CAT_CustomerGroupID 
FROM         dbo.tblKartrisCategories INNER JOIN
					  dbo.vKartrisTypeProducts INNER JOIN
					  dbo.tblKartrisProductCategoryLink ON dbo.vKartrisTypeProducts.P_ID = dbo.tblKartrisProductCategoryLink.PCAT_ProductID ON 
					  dbo.tblKartrisCategories.CAT_ID = dbo.tblKartrisProductCategoryLink.PCAT_CategoryID INNER JOIN
					  dbo.vKartrisTypeVersions ON dbo.vKartrisTypeProducts.P_ID = dbo.vKartrisTypeVersions.V_ProductID AND 
					  dbo.vKartrisTypeProducts.LANG_ID = dbo.vKartrisTypeVersions.LANG_ID LEFT OUTER JOIN
					  dbo.tblKartrisTaxRates ON dbo.vKartrisTypeVersions.V_Tax2 = dbo.tblKartrisTaxRates.T_ID LEFT OUTER JOIN
					  dbo.tblKartrisTaxRates AS tblKartrisTaxRates_1 ON dbo.vKartrisTypeVersions.V_Tax = tblKartrisTaxRates_1.T_ID
WHERE     (dbo.vKartrisTypeProducts.P_Live = 1) AND (dbo.tblKartrisCategories.CAT_Live = 1) AND (dbo.vKartrisTypeVersions.V_Live = 1)
GO

ALTER PROCEDURE [dbo].[_spKartrisDB_SetupFTS]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	EXEC sp_fulltext_database 'enable';

	DECLARE @kartrisCatalogExist as int;
	SET @kartrisCatalogExist = 0;
	SELECT @kartrisCatalogExist = count(1) FROM sys.fulltext_catalogs WHERE name = 'kartrisCatalog';
	IF @kartrisCatalogExist = 0 BEGIN CREATE FULLTEXT CATALOG kartrisCatalog END;
	
	EXEC sp_fulltext_table     'dbo.tblKartrisLanguageElements', 'create', 'kartrisCatalog', 'keyLE_ID'
	EXEC sp_fulltext_column    'dbo.tblKartrisLanguageElements', 'LE_Value', 'add'
	EXEC sp_fulltext_table     'dbo.tblKartrisLanguageElements','activate'

	EXEC sp_fulltext_table     'dbo.tblKartrisAddresses', 'create', 'kartrisCatalog', 'PK_tblKartrisAddresses'
	EXEC sp_fulltext_column    'dbo.tblKartrisAddresses', 'ADR_Name', 'add'
	EXEC sp_fulltext_table     'dbo.tblKartrisAddresses','activate'

	EXEC sp_fulltext_table     'dbo.tblKartrisUsers', 'create', 'kartrisCatalog', 'aaaaatblKartrisCustomers_PK'
	EXEC sp_fulltext_column    'dbo.tblKartrisUsers', 'U_EmailAddress', 'add'
	EXEC sp_fulltext_table     'dbo.tblKartrisUsers','activate'

	EXEC sp_fulltext_table     'dbo.tblKartrisOrders', 'create', 'kartrisCatalog', 'aaaaatblKartrisOrders_PK'
	EXEC sp_fulltext_column    'dbo.tblKartrisOrders', 'O_PurchaseOrderNo', 'add'
	EXEC sp_fulltext_table     'dbo.tblKartrisOrders','activate'

	EXEC sp_fulltext_table     'dbo.tblKartrisConfig', 'create', 'kartrisCatalog', 'PK_tblKartrisConfig'
	EXEC sp_fulltext_column    'dbo.tblKartrisConfig', 'CFG_Name', 'add'
	EXEC sp_fulltext_table     'dbo.tblKartrisConfig','activate'

	EXEC sp_fulltext_table     'dbo.tblKartrisLanguageStrings', 'create', 'kartrisCatalog', 'LS_ID'
	EXEC sp_fulltext_column    'dbo.tblKartrisLanguageStrings', 'LS_Name', 'add'
	EXEC sp_fulltext_column    'dbo.tblKartrisLanguageStrings', 'LS_Value', 'add'
	EXEC sp_fulltext_table     'dbo.tblKartrisLanguageStrings','activate'

	ALTER FULLTEXT INDEX ON dbo.tblKartrisLanguageElements SET CHANGE_TRACKING AUTO;
	ALTER FULLTEXT INDEX ON dbo.tblKartrisAddresses SET CHANGE_TRACKING AUTO;
	ALTER FULLTEXT INDEX ON dbo.tblKartrisUsers SET CHANGE_TRACKING AUTO;
	ALTER FULLTEXT INDEX ON dbo.tblKartrisOrders SET CHANGE_TRACKING AUTO;
	ALTER FULLTEXT INDEX ON dbo.tblKartrisConfig SET CHANGE_TRACKING AUTO;
	ALTER FULLTEXT INDEX ON dbo.tblKartrisLanguageStrings SET CHANGE_TRACKING AUTO;

	EXEC sp_fulltext_catalog   'kartrisCatalog', 'start_full'	
  

	IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisDB_SearchFTS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[spKartrisDB_SearchFTS]
(	
	@SearchText as nvarchar(500),
	@keyWordsList as nvarchar(500),
	@LANG_ID as tinyint,
	@PageIndex as smallint,
	@RowsPerPage as tinyint,
	@TotalResultProducts as int OUTPUT,
	@MinPrice as real,
	@MaxPrice as real,
	@Method as nvarchar(10),
	@CustomerGroupID as smallint
)
AS
BEGIN
	SET NOCOUNT ON;
	
	IF @CustomerGroupID IS NULL BEGIN SET @CustomerGroupID = 0 END
	
	-----------------------
	-- Variable Declaration
	-----------------------
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @Keyword as nvarchar(150);
	DECLARE @Counter as int;
	
	DECLARE @NoOfVersions as bigint;
	SELECT @NoOfVersions = Count(1)	FROM tblKartrisVersions;
	
	-- Include Products and Attributes if no. of versions > 100,000
	-- Include Versions, Products and Attributes if no. of versions <= 100,000
	DECLARE @DataToSearch as nvarchar(100);
	IF @NoOfVersions > 100000 BEGIN
		SET @DataToSearch = ''(LE_TypeID IN (2,14) AND LE_FieldID IN (1,2,5))''
	END ELSE BEGIN
		SET @DataToSearch = ''(LE_TypeID IN (1,2,14) AND LE_FieldID IN (1,2,5))''
	END
		
	DECLARE @ExactCriteriaNoNoise as nvarchar(500);
	SET @ExactCriteriaNoNoise = Replace(@keyWordsList, '','', '' '');
	
	IF @Method = ''exact'' BEGIN
		-- Searching value of LanguageElements - Add results to search helper (LIKE Operator)
		EXECUTE(''
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, '''''' + @KeyWord + ''''''
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = '' + @LANG_ID +'' AND '' + @DataToSearch + ''
					AND (	(Contains(LE_Value, ''''"'' + @SearchText + ''"''''))
						 OR	(Contains(LE_Value, ''''"'' + @ExactCriteriaNoNoise + ''"''''))
						)'');
						
		-- Searching version code of Versions - Add results to search helper				
		EXECUTE(''
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, '''''' + @ExactCriteriaNoNoise + ''''''
		FROM         tblKartrisVersions LEFT OUTER JOIN dbo.vKartrisObjectConfigValues 
			ON V_ID = OCV_ParentID AND OC_Name = ''''K:version.extrasku''''
		WHERE     (V_Live = 1) AND (V_CodeNumber LIKE '''''' + @SearchText + ''%'''' OR OCV_Value LIKE '''''' + @SearchText + ''%'''')'' );	
	END ELSE BEGIN
		-- Loop through out the list of keywords and search each keyword
		SET @SIndx = 0; SET @Counter = 0;
		WHILE @SIndx <= LEN(@keyWordsList) BEGIN
			SET @Counter = @Counter + 1;	-- keywords counter
			SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)	-- Next keyword starting index (1-Based Index)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+ 1 END	-- If no more keywords, set next starting index to not exist
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			
			SET @SIndx = @CIndx + 1;	-- The next starting index
				
			
			-- Searching value of LanguageElements - Add results to search helper (LIKE Operator)
			EXECUTE(''
			INSERT INTO tblKartrisSearchHelper
			SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
						dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, '''''' + @KeyWord + ''''''
			FROM       tblKartrisLanguageElements 
			WHERE	LE_LanguageID = '' + @LANG_ID +'' AND '' + @DataToSearch + '' AND (Contains(LE_Value, '''''' + @KeyWord + '''''')) '');
				
			-- Searching version code of Versions - Add results to search helper				
			EXECUTE(''
			INSERT INTO tblKartrisSearchHelper
			SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, '''''' + @KeyWord + ''''''
			FROM         tblKartrisVersions LEFT OUTER JOIN dbo.vKartrisObjectConfigValues 
				ON V_ID = OCV_ParentID AND OC_Name = ''''K:version.extrasku''''
			WHERE     (V_Live = 1) AND (V_CodeNumber LIKE '''''' + @KeyWord + ''%'''' OR OCV_Value LIKE '''''' + @Keyword + ''%'''')'' );
		END
	END
	

	-- (Advanced Search) Exclude products that are not between the price range
	IF @MinPrice <> -1 AND @MaxPrice <> -1 BEGIN
		UPDATE tblKartrisSearchHelper
		SET SH_Price = dbo.fnKartrisProduct_GetMinPriceWithCG(SH_ProductID, @CustomerGroupID)
		WHERE SH_SessionID = @@SPID;
		DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID = @@SPID AND SH_Price NOT BETWEEN @MinPrice AND @MaxPrice;
	END

	-- Exclude products in which their categories are not live
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID
		AND SH_ProductID NOT IN (SELECT distinct tblKartrisProductCategoryLink.PCAT_ProductID
								 FROM	tblKartrisCategories INNER JOIN tblKartrisProductCategoryLink 
										ON tblKartrisCategories.CAT_ID = tblKartrisProductCategoryLink.PCAT_CategoryID
								 WHERE  tblKartrisCategories.CAT_Live = 1)

	-- Exclude products that are Not Live or that are not belongs to customer group
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID 
		AND SH_ProductID IN (	SELECT P_ID 
								FROM dbo.tblKartrisProducts 
								WHERE P_Live = 0 OR (P_CustomerGroupID IS NOT NULL AND P_CustomerGroupID <> @CustomerGroupID)); 

	-- Exclude products that has no Live versions or that are not belongs to customer group
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID 
		AND SH_ProductID NOT IN (SELECT V_ProductID 
								 FROM dbo.tblKartrisVersions INNER JOIN dbo.tblKartrisProducts ON V_ProductID = P_ID
								 WHERE V_Live = 1 AND (V_CustomerGroupID IS NULL OR V_CustomerGroupID = @CustomerGroupID)); 

	-- Exclude products that are not resulted from non-searchable attributes
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID AND SH_TypeID = 14 
			AND SH_ParentID IN (SELECT tblKartrisAttributeValues.ATTRIBV_ID
							FROM tblKartrisAttributes INNER JOIN tblKartrisAttributeValues 
							ON tblKartrisAttributes.ATTRIB_ID = tblKartrisAttributeValues.ATTRIBV_AttributeID
							WHERE   tblKartrisAttributes.ATTRIB_ShowSearch = 0);

	
	-- Update the scores of the products with exact match			
	IF @Counter > 1 BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (400) 
		WHERE SH_SessionID = @@SPID AND ((SH_TextValue like ''%'' + @ExactCriteriaNoNoise + ''%'') OR (SH_TextValue like ''%'' + @SearchText + ''%''));
	END
	
	-- Update the scores according to number of versions
	IF @NoOfVersions > 100000 BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30) WHERE SH_SessionID = @@SPID AND SH_FieldID = 2;
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (200) WHERE SH_SessionID = @@SPID AND SH_FieldID IN (1, 5);
	END	ELSE BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30 * SH_TypeID) WHERE SH_SessionID = @@SPID AND SH_TypeID IN (1, 2);
	END
	
	-- Set the starting and ending row numbers
	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;	

	-- Search method ''ANY'' - Default Search and ''EXACT'' - Advanced Search
	IF @Method = ''any'' OR @Method = ''exact'' BEGIN
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
	END
	
	-- Search method ''ALL'' - Advanced Search
	IF @Method = ''all'' BEGIN
	
		DECLARE @SortedSearchKeywords as nvarchar(max);
		SELECT @SortedSearchKeywords = COALESCE(@SortedSearchKeywords + '','', '''') + T._ID
		FROM (SELECT TOP(500) _ID FROM dbo.fnTbl_SplitStrings(@keyWordsList) ORDER BY _ID) AS T;

		SELECT @TotalResultProducts =  Count(DISTINCT SH_ProductID) FROM tblKartrisSearchHelper 
		WHERE SH_SessionID = @@SPID AND @SortedSearchKeywords = dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, SH_ProductID);
		
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
							HAVING SH_SessionID = @@SPID AND @SortedSearchKeywords = dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, SH_ProductID)
						) T1 
						FULL OUTER JOIN 
						(
							SELECT SH_SessionID, SH_ProductID, Max(SH_Score) as Score2
							FROM tblKartrisSearchHelper 
							WHERE SH_TypeID = 1
							Group BY SH_SessionID, SH_ProductID
							HAVING SH_SessionID = @@SPID AND @SortedSearchKeywords = dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, SH_ProductID)
						) T2 
						ON T1.SH_ProductID = T2.SH_ProductID
				) T3
		)
		SELECT Row, P_ID, P_Name, dbo.fnKartrisDB_TruncateDescription(P_Desc) as P_Desc, 
				dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID, @CustomerGroupID) as MinPrice, TotalScore, 
				dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID,P_ID) AS KeywordList
		FROM SearchResult INNER JOIN dbo.vKartrisTypeProducts ON SearchResult.ProductID = dbo.vKartrisTypeProducts.P_ID
		WHERE vKartrisTypeProducts.LANG_ID = @LANG_ID AND ROW BETWEEN @StartRowNumber AND @EndRowNumber
		GROUP BY Row, P_ID, P_Name, P_Desc, TotalScore
		ORDER BY TotalScore DESC
		
	END
	
	-- Clear the result of the current search
	DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID=@@SPID;
	
END' 
END
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_AdminSearchFTS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
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
	@PageIndex as smallint,
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
	IF @searchLocation = ''products'' BEGIN SET @TypeNo = 2 END
	IF @searchLocation = ''categories'' BEGIN SET @TypeNo = 3 END
	
	--================ PRODUCTS/CATEGORIES ==================
	IF @searchLocation = ''products'' OR @searchLocation = ''categories''
	BEGIN
			CREATE TABLE #_ProdCatSearchTbl(ItemID nvarchar(255), ItemValue nvarchar(MAX))
			WHILE @SIndx <= LEN(@keyWordsList)
			BEGIN
				
				SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)
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
	IF @searchLocation = ''versions''
	BEGIN
		CREATE TABLE #_VersionSearchTbl(VersionID nvarchar(255), VersionName nvarchar(MAX), VersionCode nvarchar(25), ProductID nvarchar(255))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)
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
					AND LE_ParentID 
						IN (SELECT V_ID 
							FROM tblKartrisVersions LEFT OUTER JOIN dbo.vKartrisObjectConfigValues 
								ON V_ID = OCV_ParentID AND OC_Name = ''K:version.extrasku''
							WHERE V_CodeNumber Like ''%'' + @KeyWord + ''%'' OR OCV_Value LIKE ''%'' + @Keyword + ''%'');

		END

		SELECT @TotalResult =  Count(VersionID) FROM #_VersionSearchTbl;
		
		SELECT     VersionID, VersionName, VersionCode, ProductID
		FROM         #_VersionSearchTbl
		DROP TABLE #_VersionSearchTbl;
	END

	--================ CUSTOMERS ==================
	IF @searchLocation = ''customers''
	BEGIN
			
			CREATE TABLE #_CustomerSearchTbl(CustomerID nvarchar(255), CustomerName nvarchar(50), CustomerEmail nvarchar(100))
			WHILE @SIndx <= LEN(@keyWordsList)
			BEGIN
				
				SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)
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
		IF @searchLocation = ''orders''
		BEGIN
			CREATE TABLE #_OrdersSearchTbl(OrderID int, PurchaseOrderNumber nvarchar(50))
			WHILE @SIndx <= LEN(@keyWordsList)
			BEGIN
				
				SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)
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
	IF @searchLocation = ''config''
	BEGIN
			
		CREATE TABLE #_ConfigSearchTbl(ConfigName nvarchar(100), ConfigValue nvarchar(255))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)
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
	IF @searchLocation = ''site''
	BEGIN
			
		CREATE TABLE #_LSSearchTbl(LSFB char(1), LSLang tinyint, LSName nvarchar(255), LSValue nvarchar(MAX), LSClass nvarchar(50))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)
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
	
	--============== Custom Pages =======================
	IF @searchLocation = ''pages''
	BEGIN
		CREATE TABLE #_CustomPagesSearchTbl(PageID smallint, PageName nvarchar(50))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			SET @SIndx = @CIndx + 1;
			
			INSERT INTO #_CustomPagesSearchTbl (PageID, PageName)
			SELECT DISTINCT LE_ParentID, PAGE_Name
			FROM dbo.tblKartrisLanguageElements INNER JOIN dbo.tblKartrisPages
				ON tblKartrisLanguageElements.LE_ParentID = tblKartrisPages.PAGE_ID
			WHERE (LE_LanguageID = @LANG_ID) AND (LE_TypeID = 8) AND Contains(LE_Value, @KeyWord);
			
		END

		SELECT @TotalResult =  Count(DISTINCT PageID) FROM #_CustomPagesSearchTbl;
		

		SELECT  DISTINCT PageID, PageName
		FROM         #_CustomPagesSearchTbl
		DROP TABLE #_CustomPagesSearchTbl;
	END

END
'
END
		
END
GO

ALTER PROCEDURE [dbo].[spKartrisDB_Search]
(	
	@SearchText as nvarchar(500),
	@keyWordsList as nvarchar(500),
	@LANG_ID as tinyint,
	@PageIndex as tinyint, -- 0 Based index
	@RowsPerPage as tinyint,
	@TotalResultProducts as int OUTPUT,
	@MinPrice as real,
	@MaxPrice as real,
	@Method as nvarchar(10),
	@CustomerGroupID as smallint
)
AS
BEGIN
SET NOCOUNT ON;
	
	SET NOCOUNT ON;
	
	IF @CustomerGroupID IS NULL BEGIN SET @CustomerGroupID = 0 END
	
	-----------------------
	-- Variable Declaration
	-----------------------
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @Keyword as nvarchar(150);
	DECLARE @Counter as int;
	
	DECLARE @NoOfVersions as bigint;
	SELECT @NoOfVersions = Count(1)	FROM tblKartrisVersions;
	
	-- Include Products and Attributes if no. of versions > 10,000
	-- Include Versions, Products and Attributes if no. of versions <= 10,000
	DECLARE @DataToSearch as nvarchar(100);
	IF @NoOfVersions > 10000 BEGIN
		SET @DataToSearch = '(LE_TypeID IN (2,14) AND LE_FieldID IN (1,2,5))'
	END ELSE BEGIN
		SET @DataToSearch = '(LE_TypeID IN (1,2,14) AND LE_FieldID IN (1,2,5))'
	END
		
	DECLARE @ExactCriteriaNoNoise as nvarchar(500);
	SET @ExactCriteriaNoNoise = Replace(@keyWordsList, ',', ' ');
	
	IF @Method = 'exact' BEGIN	
		-- Searching value of LanguageElements - Add results to search helper (LIKE Operator)
		EXECUTE('
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, ''' + @KeyWord + '''
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = ' + @LANG_ID +' AND ' + @DataToSearch + '
					AND (	(LE_Value like ''% ' + @SearchText + ' %'')
						OR	(LE_Value like ''' + @SearchText + ' %'')
						OR	(LE_Value like ''% ' + @SearchText + ''')
						OR	(LE_Value = ''' + @SearchText + ''')
						)');
						
		-- Searching version code of Versions - Add results to search helper				
		EXECUTE('
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, ''' + @SearchText + '''
		FROM         tblKartrisVersions LEFT OUTER JOIN dbo.vKartrisObjectConfigValues 
			ON V_ID = OCV_ParentID AND OC_Name = ''K:version.extrasku''
		WHERE     (V_Live = 1) AND (V_CodeNumber LIKE ''' + @SearchText + '%'' OR OCV_Value LIKE ''' + @SearchText + '%'' )' );		
	END ELSE BEGIN
		-- Loop through out the list of keywords and search each keyword
		SET @SIndx = 0;	SET @Counter = 0;
		WHILE @SIndx <= LEN(@keyWordsList)	BEGIN
		SET @Counter = @Counter + 1;	-- keywords counter
		SET @CIndx = CHARINDEX(',', @keyWordsList, @SIndx)	-- Next keyword starting index (1-Based Index)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+ 1 END	-- If no more keywords, set next starting index to not exist
		SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
		
		-- The next starting index
		SET @SIndx = @CIndx + 1;
			
		-- Searching value of LanguageElements - Add results to search helper (LIKE Operator)
		EXECUTE('
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, ''' + @KeyWord + '''
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = ' + @LANG_ID +' AND ' + @DataToSearch + '
					AND (	(LE_Value like ''% ' + @KeyWord + ' %'')
						OR	(LE_Value like ''' + @KeyWord + ' %'')
						OR	(LE_Value like ''% ' + @KeyWord + ''')
						OR	(LE_Value = ''' + @KeyWord + ''')
						)');
						
		-- Searching version code of Versions - Add results to search helper				
		EXECUTE('
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, ''' + @KeyWord + '''
		FROM         tblKartrisVersions LEFT OUTER JOIN dbo.vKartrisObjectConfigValues 
			ON V_ID = OCV_ParentID AND OC_Name = ''K:version.extrasku''
		WHERE     (V_Live = 1) AND (V_CodeNumber LIKE ''' + @Keyword + '%'' OR OCV_Value LIKE ''' + @Keyword + '%'' )' );	
	END 
	END
	
	-- (Advanced Search) Exclude products that are not between the price range
	IF @MinPrice <> -1 AND @MaxPrice <> -1	BEGIN
		UPDATE tblKartrisSearchHelper
		SET SH_Price = dbo.fnKartrisProduct_GetMinPriceWithCG(SH_ProductID, @CustomerGroupID)
		WHERE SH_SessionID = @@SPID;
		DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID = @@SPID AND SH_Price NOT BETWEEN @MinPrice AND @MaxPrice;
	END

	-- Exclude products in which their categories are not live
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID
		AND SH_ProductID NOT IN (SELECT distinct tblKartrisProductCategoryLink.PCAT_ProductID
								 FROM	tblKartrisCategories INNER JOIN tblKartrisProductCategoryLink 
										ON tblKartrisCategories.CAT_ID = tblKartrisProductCategoryLink.PCAT_CategoryID
								 WHERE  tblKartrisCategories.CAT_Live = 1)

	-- Exclude products that are Not Live or that are not belongs to customer group
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID 
		AND SH_ProductID IN (	SELECT P_ID 
								FROM dbo.tblKartrisProducts 
								WHERE P_Live = 0 OR (P_CustomerGroupID IS NOT NULL AND P_CustomerGroupID <> @CustomerGroupID)); 

	-- Exclude products that has no Live versions or that are not belongs to customer group
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID 
		AND SH_ProductID NOT IN (SELECT V_ProductID 
								 FROM dbo.tblKartrisVersions INNER JOIN dbo.tblKartrisProducts ON V_ProductID = P_ID
								 WHERE V_Live = 1 AND (V_CustomerGroupID IS NULL OR V_CustomerGroupID = @CustomerGroupID)); 
	
	-- Exclude products that are not resulted from non-searchable attributes
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID AND SH_TypeID = 14 
			AND SH_ParentID IN (SELECT tblKartrisAttributeValues.ATTRIBV_ID
							FROM tblKartrisAttributes INNER JOIN tblKartrisAttributeValues 
							ON tblKartrisAttributes.ATTRIB_ID = tblKartrisAttributeValues.ATTRIBV_AttributeID
							WHERE   tblKartrisAttributes.ATTRIB_ShowSearch = 0);
					
	-- Update the scores of the products with exact match			
	IF @Counter > 1	BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (400) 
		WHERE SH_SessionID = @@SPID AND ((SH_TextValue like '%' + @ExactCriteriaNoNoise + '%') OR (SH_TextValue like '%' + @SearchText + '%'));
	END
	
	-- Update the scores according to number of versions
	IF @NoOfVersions > 10000 BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30) WHERE SH_SessionID = @@SPID AND SH_FieldID = 2;
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (200) WHERE SH_SessionID = @@SPID AND SH_FieldID IN (1, 5);
	END	ELSE BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30 * SH_TypeID) WHERE SH_SessionID = @@SPID AND SH_TypeID IN (1, 2);
	END
	
	-- Set the starting and ending row numbers
	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;	

	-- Search method 'ANY' - Default Search and 'EXACT' - Advanced Search
	IF @Method = 'any' OR @Method = 'exact' BEGIN
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
				dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID, @CustomerGroupID) as MinPrice, TotalScore, 
				dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, P_ID) AS KeywordList
		FROM SearchResult INNER JOIN dbo.vKartrisTypeProducts ON SearchResult.ProductID = dbo.vKartrisTypeProducts.P_ID
		WHERE vKartrisTypeProducts.LANG_ID = @LANG_ID AND ROW BETWEEN @StartRowNumber AND @EndRowNumber
		GROUP BY Row, P_ID, P_Name, P_Desc, TotalScore
		ORDER BY TotalScore DESC
	END
	
	-- Search method 'ALL' - Advanced Search
	IF @Method = 'all' BEGIN
	
		DECLARE @SortedSearchKeywords as nvarchar(max);
		SELECT @SortedSearchKeywords = COALESCE(@SortedSearchKeywords + ',', '') + T._ID
		FROM (SELECT TOP(500) _ID FROM dbo.fnTbl_SplitStrings(@keyWordsList) ORDER BY _ID) AS T;

		SELECT @TotalResultProducts =  Count(DISTINCT SH_ProductID) FROM tblKartrisSearchHelper 
		WHERE SH_SessionID = @@SPID AND @SortedSearchKeywords = dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, SH_ProductID);
		
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
							HAVING SH_SessionID = @@SPID AND @SortedSearchKeywords = dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, SH_ProductID)
						) T1 
						FULL OUTER JOIN 
						(
							SELECT SH_SessionID, SH_ProductID, Max(SH_Score) as Score2
							FROM tblKartrisSearchHelper 
							WHERE SH_TypeID = 1
							Group BY SH_SessionID, SH_ProductID
							HAVING SH_SessionID = @@SPID AND @SortedSearchKeywords = dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, SH_ProductID)
						) T2 
						ON T1.SH_ProductID = T2.SH_ProductID
				) T3
		)
		SELECT Row, P_ID, P_Name, dbo.fnKartrisDB_TruncateDescription(P_Desc) as P_Desc, 
				dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID, @CustomerGroupID) as MinPrice, TotalScore, 
				dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID,P_ID) AS KeywordList
		FROM SearchResult INNER JOIN dbo.vKartrisTypeProducts ON SearchResult.ProductID = dbo.vKartrisTypeProducts.P_ID
		WHERE vKartrisTypeProducts.LANG_ID = @LANG_ID AND ROW BETWEEN @StartRowNumber AND @EndRowNumber
		GROUP BY Row, P_ID, P_Name, P_Desc, TotalScore
		ORDER BY TotalScore DESC
		
	END
	
	-- Clear the result of the current search
	DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID=@@SPID;
	
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisDB_SearchFTS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

ALTER PROCEDURE [dbo].[spKartrisDB_SearchFTS]
(	
	@SearchText as nvarchar(500),
	@keyWordsList as nvarchar(500),
	@LANG_ID as tinyint,
	@PageIndex as smallint,
	@RowsPerPage as tinyint,
	@TotalResultProducts as int OUTPUT,
	@MinPrice as real,
	@MaxPrice as real,
	@Method as nvarchar(10),
	@CustomerGroupID as smallint
)
AS
BEGIN
	SET NOCOUNT ON;
	
	IF @CustomerGroupID IS NULL BEGIN SET @CustomerGroupID = 0 END
	
	-----------------------
	-- Variable Declaration
	-----------------------
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @Keyword as nvarchar(150);
	DECLARE @Counter as int;
	
	DECLARE @NoOfVersions as bigint;
	SELECT @NoOfVersions = Count(1)	FROM tblKartrisVersions;
	
	-- Include Products and Attributes if no. of versions > 100,000
	-- Include Versions, Products and Attributes if no. of versions <= 100,000
	DECLARE @DataToSearch as nvarchar(100);
	IF @NoOfVersions > 100000 BEGIN
		SET @DataToSearch = ''(LE_TypeID IN (2,14) AND LE_FieldID IN (1,2,5))''
	END ELSE BEGIN
		SET @DataToSearch = ''(LE_TypeID IN (1,2,14) AND LE_FieldID IN (1,2,5))''
	END
		
	DECLARE @ExactCriteriaNoNoise as nvarchar(500);
	SET @ExactCriteriaNoNoise = Replace(@keyWordsList, '','', '' '');
	
	IF @Method = ''exact'' BEGIN
		-- Searching value of LanguageElements - Add results to search helper (LIKE Operator)
		EXECUTE(''
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, '''''' + @KeyWord + ''''''
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = '' + @LANG_ID +'' AND '' + @DataToSearch + ''
					AND (	(Contains(LE_Value, ''''"'' + @SearchText + ''"''''))
						 OR	(Contains(LE_Value, ''''"'' + @ExactCriteriaNoNoise + ''"''''))
						)'');
						
		-- Searching version code of Versions - Add results to search helper				
		EXECUTE(''
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, '''''' + @ExactCriteriaNoNoise + ''''''
		FROM         tblKartrisVersions LEFT OUTER JOIN dbo.vKartrisObjectConfigValues 
			ON V_ID = OCV_ParentID AND OC_Name = ''''K:version.extrasku''''
		WHERE     (V_Live = 1) AND (V_CodeNumber LIKE '''''' + @SearchText + ''%'''' OR OCV_Value LIKE '''''' + @SearchText + ''%'''')'' );	
	END ELSE BEGIN
		-- Loop through out the list of keywords and search each keyword
		SET @SIndx = 0; SET @Counter = 0;
		WHILE @SIndx <= LEN(@keyWordsList) BEGIN
			SET @Counter = @Counter + 1;	-- keywords counter
			SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)	-- Next keyword starting index (1-Based Index)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+ 1 END	-- If no more keywords, set next starting index to not exist
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			
			SET @SIndx = @CIndx + 1;	-- The next starting index
				
			
			-- Searching value of LanguageElements - Add results to search helper (LIKE Operator)
			EXECUTE(''
			INSERT INTO tblKartrisSearchHelper
			SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
						dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, '''''' + @KeyWord + ''''''
			FROM       tblKartrisLanguageElements 
			WHERE	LE_LanguageID = '' + @LANG_ID +'' AND '' + @DataToSearch + '' AND (Contains(LE_Value, '''''' + @KeyWord + '''''')) '');
				
			-- Searching version code of Versions - Add results to search helper				
			EXECUTE(''
			INSERT INTO tblKartrisSearchHelper
			SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, '''''' + @KeyWord + ''''''
			FROM         tblKartrisVersions LEFT OUTER JOIN dbo.vKartrisObjectConfigValues 
				ON V_ID = OCV_ParentID AND OC_Name = ''''K:version.extrasku''''
			WHERE     (V_Live = 1) AND (V_CodeNumber LIKE '''''' + @KeyWord + ''%'''' OR OCV_Value LIKE '''''' + @Keyword + ''%'''')'' );
		END
	END
	

	-- (Advanced Search) Exclude products that are not between the price range
	IF @MinPrice <> -1 AND @MaxPrice <> -1 BEGIN
		UPDATE tblKartrisSearchHelper
		SET SH_Price = dbo.fnKartrisProduct_GetMinPriceWithCG(SH_ProductID, @CustomerGroupID)
		WHERE SH_SessionID = @@SPID;
		DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID = @@SPID AND SH_Price NOT BETWEEN @MinPrice AND @MaxPrice;
	END

	-- Exclude products in which their categories are not live
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID
		AND SH_ProductID NOT IN (SELECT distinct tblKartrisProductCategoryLink.PCAT_ProductID
								 FROM	tblKartrisCategories INNER JOIN tblKartrisProductCategoryLink 
										ON tblKartrisCategories.CAT_ID = tblKartrisProductCategoryLink.PCAT_CategoryID
								 WHERE  tblKartrisCategories.CAT_Live = 1)

	-- Exclude products that are Not Live or that are not belongs to customer group
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID 
		AND SH_ProductID IN (	SELECT P_ID 
								FROM dbo.tblKartrisProducts 
								WHERE P_Live = 0 OR (P_CustomerGroupID IS NOT NULL AND P_CustomerGroupID <> @CustomerGroupID)); 

	-- Exclude products that has no Live versions or that are not belongs to customer group
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID 
		AND SH_ProductID NOT IN (SELECT V_ProductID 
								 FROM dbo.tblKartrisVersions INNER JOIN dbo.tblKartrisProducts ON V_ProductID = P_ID
								 WHERE V_Live = 1 AND (V_CustomerGroupID IS NULL OR V_CustomerGroupID = @CustomerGroupID)); 

	-- Exclude products that are not resulted from non-searchable attributes
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID AND SH_TypeID = 14 
			AND SH_ParentID IN (SELECT tblKartrisAttributeValues.ATTRIBV_ID
							FROM tblKartrisAttributes INNER JOIN tblKartrisAttributeValues 
							ON tblKartrisAttributes.ATTRIB_ID = tblKartrisAttributeValues.ATTRIBV_AttributeID
							WHERE   tblKartrisAttributes.ATTRIB_ShowSearch = 0);

	
	-- Update the scores of the products with exact match			
	IF @Counter > 1 BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (400) 
		WHERE SH_SessionID = @@SPID AND ((SH_TextValue like ''%'' + @ExactCriteriaNoNoise + ''%'') OR (SH_TextValue like ''%'' + @SearchText + ''%''));
	END
	
	-- Update the scores according to number of versions
	IF @NoOfVersions > 100000 BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30) WHERE SH_SessionID = @@SPID AND SH_FieldID = 2;
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (200) WHERE SH_SessionID = @@SPID AND SH_FieldID IN (1, 5);
	END	ELSE BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30 * SH_TypeID) WHERE SH_SessionID = @@SPID AND SH_TypeID IN (1, 2);
	END
	
	-- Set the starting and ending row numbers
	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;	

	-- Search method ''ANY'' - Default Search and ''EXACT'' - Advanced Search
	IF @Method = ''any'' OR @Method = ''exact'' BEGIN
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
	END
	
	-- Search method ''ALL'' - Advanced Search
	IF @Method = ''all'' BEGIN
	
		DECLARE @SortedSearchKeywords as nvarchar(max);
		SELECT @SortedSearchKeywords = COALESCE(@SortedSearchKeywords + '','', '''') + T._ID
		FROM (SELECT TOP(500) _ID FROM dbo.fnTbl_SplitStrings(@keyWordsList) ORDER BY _ID) AS T;

		SELECT @TotalResultProducts =  Count(DISTINCT SH_ProductID) FROM tblKartrisSearchHelper 
		WHERE SH_SessionID = @@SPID AND @SortedSearchKeywords = dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, SH_ProductID);
		
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
							HAVING SH_SessionID = @@SPID AND @SortedSearchKeywords = dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, SH_ProductID)
						) T1 
						FULL OUTER JOIN 
						(
							SELECT SH_SessionID, SH_ProductID, Max(SH_Score) as Score2
							FROM tblKartrisSearchHelper 
							WHERE SH_TypeID = 1
							Group BY SH_SessionID, SH_ProductID
							HAVING SH_SessionID = @@SPID AND @SortedSearchKeywords = dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, SH_ProductID)
						) T2 
						ON T1.SH_ProductID = T2.SH_ProductID
				) T3
		)
		SELECT Row, P_ID, P_Name, dbo.fnKartrisDB_TruncateDescription(P_Desc) as P_Desc, 
				dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID, @CustomerGroupID) as MinPrice, TotalScore, 
				dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID,P_ID) AS KeywordList
		FROM SearchResult INNER JOIN dbo.vKartrisTypeProducts ON SearchResult.ProductID = dbo.vKartrisTypeProducts.P_ID
		WHERE vKartrisTypeProducts.LANG_ID = @LANG_ID AND ROW BETWEEN @StartRowNumber AND @EndRowNumber
		GROUP BY Row, P_ID, P_Name, P_Desc, TotalScore
		ORDER BY TotalScore DESC
		
	END
	
	-- Clear the result of the current search
	DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID=@@SPID;
	
END' 
END
GO

ALTER PROCEDURE [dbo].[spKartrisProducts_GetFeaturedProducts]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SELECT     P_ID, LANG_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType, P_Type, dbo.fnKartrisProduct_GetMinPrice(P_ID) AS MinPrice, P_Name, P_Desc, P_StrapLine, P_PageTitle, P_Reviews, 
					  P_Featured, P_CustomerGroupID, MIN(T_Taxrate) AS MinTax
	FROM         vKartrisProductsVersions
	WHERE     (P_Featured <> 0) AND (P_CustomerGroupID IS NULL) AND (V_Live = 1) AND (CAT_Live = 1) AND (P_Live = 1)
	GROUP BY P_ID, LANG_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType, P_Type, P_Name, P_Desc, P_StrapLine, P_Featured, P_CustomerGroupID, P_Reviews, P_PageTitle
	ORDER BY P_Featured DESC

END
GO

ALTER PROCEDURE [dbo].[spKartrisProducts_GetNewestProducts]
	(
	@LANG_ID tinyint
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT  DISTINCT TOP(10)  P_ID, P_Name, P_DateCreated, LANG_ID
	FROM    vKartrisProductsVersions
	WHERE  P_CustomerGroupID IS NULL AND CAT_CustomerGroupID IS NULL AND V_CustomerGroupID IS NULL AND P_Name IS NOT NULL
	ORDER BY P_DateCreated DESC, P_ID DESC

END
GO

ALTER PROCEDURE [dbo].[spKartrisProducts_GetTopList]
	(
	@Limit int,
	@LANG_ID tinyint,
	@StartDate datetime
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	WITH tblTopList AS
	(
		SELECT  tblKartrisInvoiceRows.IR_VersionCode AS IR_VersionCode, SUM(tblKartrisInvoiceRows.IR_Quantity) AS IR_Quantity
		FROM    tblKartrisInvoiceRows LEFT OUTER JOIN tblKartrisOrders ON tblKartrisInvoiceRows.IR_OrderNumberID = tblKartrisOrders.O_ID
		WHERE   (tblKartrisOrders.O_Paid = 1) AND (tblKartrisOrders.O_Date >= @StartDate)
		GROUP BY tblKartrisInvoiceRows.IR_VersionCode
	)
	SELECT TOP (@Limit) vKartrisProductsVersions.P_ID, vKartrisProductsVersions.P_Name, @LANG_ID as LANG_ID, SUM(tblTopList.IR_Quantity) as ProductHits
	FROM tblTopList INNER JOIN dbo.vKartrisProductsVersions ON tblTopList.IR_VersionCode = dbo.vKartrisProductsVersions.V_CodeNumber
	WHERE	vKartrisProductsVersions.V_CustomerGroupID IS NULL AND vKartrisProductsVersions.P_CustomerGroupID IS NULL 
		AND vKartrisProductsVersions.CAT_CustomerGroupID IS NULL AND vKartrisProductsVersions.P_Name IS NOT NULL AND vKartrisProductsVersions.CAT_Live = 1
	GROUP BY vKartrisProductsVersions.P_ID, vKartrisProductsVersions.P_Name
	ORDER BY ProductHits DESC

END
GO

ALTER PROCEDURE [dbo].[spKartrisProducts_GetRelatedProducts]
(
	@P_ID as int, 
	@LANG_ID as tinyint,
	@CG_ID as smallint
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT     vKartrisTypeProducts.P_ID, vKartrisTypeProducts.P_Name
	FROM         tblKartrisRelatedProducts INNER JOIN
						  vKartrisTypeProducts ON tblKartrisRelatedProducts.RP_ChildID = vKartrisTypeProducts.P_ID
	WHERE     (vKartrisTypeProducts.LANG_ID = @LANG_ID) AND (RP_ParentID = @P_ID) AND
				dbo.fnKartrisProduct_IsReadyToLive(vKartrisTypeProducts.P_ID) = 1
				AND (vKartrisTypeProducts.P_CustomerGroupID IS NULL OR vKartrisTypeProducts.P_CustomerGroupID = @CG_ID);

END
GO

-- ****** New language strings
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'ContentText_NavMenu', N'Navigation Menu', 'Title on the nav menu that shows in small responsive mode', 2.0003, N'Navigation Menu', NULL, N'Kartris', 1)
GO
UPDATE [dbo].[tblKartrisShippingRates] SET [S_Boundary] = 999999 WHERE [S_Boundary] = 999999999999999;
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingRates_GetByMethodAndZone]    Script Date: 6/5/2013 7:19:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get Shipping Methods - by Destination and Boundary
-- ===============================================================
ALTER PROCEDURE [dbo].[_spKartrisShippingRates_GetByMethodAndZone]
(
	@SM_ID as tinyint,
	@SZ_ID as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT     tblKartrisShippingRates.S_ID, tblKartrisShippingRates.S_ShippingMethodID, tblKartrisShippingRates.S_ShippingZoneID, 
					  CAST(tblKartrisShippingRates.S_Boundary AS Decimal(17, 2)) AS S_Boundary, CAST(tblKartrisShippingRates.S_ShippingRate AS Decimal(9, 2)) 
					  AS S_ShippingRate, tblKartrisCurrencies.CUR_ISOCode, tblKartrisCurrencies.CUR_Symbol, tblKartrisShippingRates.S_ShippingGateways
FROM         tblKartrisShippingRates CROSS JOIN
					  tblKartrisCurrencies
WHERE     (tblKartrisShippingRates.S_ShippingMethodID = @SM_ID) AND (tblKartrisShippingRates.S_ShippingZoneID = @SZ_ID) AND 
					  (tblKartrisCurrencies.CUR_ExchangeRate = 1)
ORDER BY tblKartrisShippingRates.S_ShippingZoneID, S_Boundary, S_ShippingRate

END
GO
