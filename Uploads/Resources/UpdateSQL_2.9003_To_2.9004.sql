--Insert Language Strings - Jóni Silva - 18/02/2016 BEGIN
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_InvoiceHeader', N' ', NULL, 2.9004, N'', NULL, N'Invoice',1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_InvoiceFooter', N' ', NULL, 2.9004, N'', NULL, N'Invoice',1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_PrintInvoices', N'Print Invoices', NULL, 2.9004, N'', NULL, N'_Orders',1)

GO

/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetMinPriceByProductList]    Script Date: 7/21/2014 10:14:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Mohammad
-- Last Modified: Mohammad - July 2014
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
		
		SET @CIndx = CHARINDEX(',', @P_List, @SIndx)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@P_List)+1 END
		INSERT INTO #TempTbl VALUES (CAST(SUBSTRING(@P_List, @SIndx, @CIndx - @SIndx) as int));
		SET @SIndx = @CIndx + 1;

	END

	SELECT     distinct P_ID, P_Name, dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID,@CG_ID) as P_Price
	FROM         vKartrisTypeProducts
	WHERE     (LANG_ID = @LANG_ID) AND (P_ID  IN (SELECT     ProductID
											FROM         [#TempTbl])) 
	GROUP BY P_ID, P_Name

	DROP TABLE #TempTbl;

END

GO

/****** Object:  StoredProcedure [dbo].[_spKartrisDB_SetupFTS]    Script Date: 01/23/2013 21:59:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
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
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, N'''''' + @KeyWord + ''''''
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = '' + @LANG_ID +'' AND '' + @DataToSearch + ''
					AND (	(Contains(LE_Value, N''''"'' + @SearchText + ''"''''))
						 OR	(Contains(LE_Value, N''''"'' + @ExactCriteriaNoNoise + ''"''''))
						)'');
						
		-- Searching version code of Versions - Add results to search helper				
		EXECUTE(''
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, N'''''' + @ExactCriteriaNoNoise + ''''''
		FROM         tblKartrisVersions LEFT OUTER JOIN dbo.vKartrisObjectConfigValues 
			ON V_ID = OCV_ParentID AND OC_Name = ''''K:version.extrasku''''
		WHERE     (V_Live = 1) AND (V_CodeNumber LIKE N'''''' + @SearchText + ''%'''' OR OCV_Value LIKE N'''''' + @SearchText + ''%'''')'' );	
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
						dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, N'''''' + @KeyWord + ''''''
			FROM       tblKartrisLanguageElements 
			WHERE	LE_LanguageID = '' + @LANG_ID +'' AND '' + @DataToSearch + ''
					AND (	(Contains(LE_Value, N''''"'' + @SearchText + ''"''''))
						 OR	(Contains(LE_Value, N''''"'' + @ExactCriteriaNoNoise + ''"''''))
						)'');

			-- Searching value of LanguageElements - Add results to search helper (LIKE Operator)
			EXECUTE(''
			INSERT INTO tblKartrisSearchHelper
			SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
						dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, N'''''' + @KeyWord + ''''''
			FROM       tblKartrisLanguageElements 
			WHERE	LE_LanguageID = '' + @LANG_ID +'' AND '' + @DataToSearch + '' AND (Contains(LE_Value, N'''''' + @KeyWord + '''''')) '');
				
			-- Searching version code of Versions - Add results to search helper				
			EXECUTE(''
			INSERT INTO tblKartrisSearchHelper
			SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, N'''''' + @KeyWord + ''''''
			FROM         tblKartrisVersions LEFT OUTER JOIN dbo.vKartrisObjectConfigValues 
				ON V_ID = OCV_ParentID AND OC_Name = ''''K:version.extrasku''''
			WHERE     (V_Live = 1) AND (V_CodeNumber LIKE N'''''' + @KeyWord + ''%'''' OR OCV_Value LIKE N'''''' + @Keyword + ''%'''')'' );
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
		WHERE SH_SessionID = @@SPID AND ((SH_TextValue like N''%'' + @ExactCriteriaNoNoise + ''%'') OR (SH_TextValue like N''%'' + @SearchText + ''%''));
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
			CREATE TABLE #_ProdCatSearchTbl(ItemID nvarchar(255) COLLATE DATABASE_DEFAULT, ItemValue nvarchar(MAX) COLLATE DATABASE_DEFAULT)
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
		CREATE TABLE #_VersionSearchTbl(VersionID nvarchar(255) COLLATE DATABASE_DEFAULT, VersionName nvarchar(MAX) COLLATE DATABASE_DEFAULT, VersionCode nvarchar(25) COLLATE DATABASE_DEFAULT, ProductID nvarchar(255) COLLATE DATABASE_DEFAULT)
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
							WHERE V_CodeNumber Like N''%'' + @KeyWord + ''%'' OR OCV_Value LIKE N''%'' + @Keyword + ''%'');

		END

		SELECT @TotalResult =  Count(VersionID) FROM #_VersionSearchTbl;
		
		SELECT     VersionID, VersionName, VersionCode, ProductID
		FROM         #_VersionSearchTbl
		DROP TABLE #_VersionSearchTbl;
	END

	--================ CUSTOMERS ==================
	IF @searchLocation = ''customers''
	BEGIN
			
			CREATE TABLE #_CustomerSearchTbl(CustomerID nvarchar(255) COLLATE DATABASE_DEFAULT, CustomerName nvarchar(50) COLLATE DATABASE_DEFAULT, CustomerEmail nvarchar(100) COLLATE DATABASE_DEFAULT)
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
			CREATE TABLE #_OrdersSearchTbl(OrderID int, PurchaseOrderNumber nvarchar(50) COLLATE DATABASE_DEFAULT)
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
			
		CREATE TABLE #_ConfigSearchTbl(ConfigName nvarchar(100) COLLATE DATABASE_DEFAULT, ConfigValue nvarchar(255) COLLATE DATABASE_DEFAULT)
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
			
		CREATE TABLE #_LSSearchTbl(LSFB char(1) COLLATE DATABASE_DEFAULT, LSLang tinyint, LSName nvarchar(255) COLLATE DATABASE_DEFAULT, LSValue nvarchar(MAX) COLLATE DATABASE_DEFAULT, LSClass nvarchar(50) COLLATE DATABASE_DEFAULT)
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
		CREATE TABLE #_CustomPagesSearchTbl(PageID smallint, PageName nvarchar(50) COLLATE DATABASE_DEFAULT)
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

/****** Object:  StoredProcedure [dbo].[spKartrisDB_Search]    Script Date: 2016-03-01 10:17:55 ******/
-- Updated to use nvarchar throughout for non-western charset support
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, N''' + @KeyWord + '''
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = ' + @LANG_ID +' AND ' + @DataToSearch + '
					AND (	(LE_Value LIKE N''% ' + @SearchText + ' %'')
						OR	(LE_Value LIKE N''' + @SearchText + ' %'')
						OR	(LE_Value LIKE N''% ' + @SearchText + ''')
						OR	(LE_Value = N''' + @SearchText + ''')
						)');
						
		-- Searching version code of Versions - Add results to search helper				
		EXECUTE('
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, N''' + @SearchText + '''
		FROM         tblKartrisVersions LEFT OUTER JOIN dbo.vKartrisObjectConfigValues 
			ON V_ID = OCV_ParentID AND OC_Name = ''K:version.extrasku''
		WHERE     (V_Live = 1) AND (V_CodeNumber LIKE N''' + @SearchText + '%'' OR OCV_Value LIKE N''' + @SearchText + '%'' )' );		
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
		
		EXECUTE('
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, N''' + @KeyWord + '''
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = ' + @LANG_ID +' AND ' + @DataToSearch + '
					AND (	(LE_Value LIKE N''% ' + @SearchText + ' %'')
						OR	(LE_Value LIKE N''' + @SearchText + ' %'')
						OR	(LE_Value LIKE N''% ' + @SearchText + ''')
						OR	(LE_Value = N''' + @SearchText + ''')
						)');
							
		-- Searching value of LanguageElements - Add results to search helper (LIKE Operator)
		EXECUTE('
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, ''' + @KeyWord + '''
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = ' + @LANG_ID +' AND ' + @DataToSearch + '
					AND (	(LE_Value LIKE N''% ' + @KeyWord + ' %'')
						OR	(LE_Value LIKE N''' + @KeyWord + ' %'')
						OR	(LE_Value LIKE N''% ' + @KeyWord + ''')
						OR	(LE_Value = N''' + @KeyWord + ''')
						)');
						
		-- Searching version code of Versions - Add results to search helper				
		EXECUTE('
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, N''' + @KeyWord + '''
		FROM         tblKartrisVersions LEFT OUTER JOIN dbo.vKartrisObjectConfigValues 
			ON V_ID = OCV_ParentID AND OC_Name = ''K:version.extrasku''
		WHERE     (V_Live = 1) AND (V_CodeNumber LIKE N''' + @Keyword + '%'' OR OCV_Value LIKE N''' + @Keyword + '%'' )' );	
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
		WHERE SH_SessionID = @@SPID AND ((SH_TextValue LIKE N'%' + @ExactCriteriaNoNoise + '%') OR (SH_TextValue LIKE N'%' + @SearchText + '%'));
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

/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_CloneRecords]    Script Date: 08/03/2016 14:10:36 ******/
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
-- products and versions
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_CloneRecords](
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
SELECT V_CodeNumber + '[clone-' + Cast(@P_ID_NEW as nvarchar(15)) + ']', @P_ID_NEW, V_Price, V_Tax, V_Weight, V_DeliveryTime, V_Quantity, V_QuantityWarnLevel, V_Live, V_DownLoadInfo, V_DownloadType, V_OrderByValue, V_RRP, V_Type, 
		V_CustomerGroupID, V_CustomizationType, V_CustomizationDesc, V_CustomizationCost, V_Tax2, V_TaxExtra
FROM tblKartrisVersions WHERE V_ProductID=@P_ID_OLD

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

-- number of versions, should be same in both tables but we just check NEW
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
SELECT DISTINCT V_ID FROM tblKartrisVersions WHERE V_ProductID=@P_ID_OLD

-- create and populate table with new product's versions
DECLARE @tblKartrisVersions_MEMORY_NEW TABLE (
	idx smallint Primary Key IDENTITY(1,1), V_ID int)
INSERT INTO @tblKartrisVersions_MEMORY_NEW(V_ID)
SELECT DISTINCT V_ID FROM tblKartrisVersions WHERE V_ProductID=@P_ID_NEW

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

/****** Update file upload guidance for stock to include quotes around strings ******/
UPDATE [dbo].[tblKartrisLanguageStrings]  SET  [LS_Value]='Browse an xls or csv file to import stock level.<br />
IMPORTANT: Make sure to have at least the following field titles (SKU, Stock Quantity and Warning Level). For example:<br /><br />
SKU,Name,Stock Quantity,Warning Level<br />
"pcpc-5","PC Power Cable - 5m",500,80<br />
"pcpc-10","PC Power Cable - 10m",500,80<br />
"pcpc-15","PC Power Cable - 15m",500,80<br />' WHERE LS_Name = 'ContentText_BrowseStockLevelImportFile'
GO

/****** Update version price and weight fields to decimal ******/
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblKartrisVersions', @level2type=N'CONSTRAINT',@level2name=N'CK_Versions_RRP'
GO
ALTER TABLE [dbo].[tblKartrisVersions] DROP CONSTRAINT [DF__tblKartris__V_Pri__1DE57479]
ALTER TABLE [dbo].[tblKartrisVersions] DROP CONSTRAINT [CK_Versions_RRP]
ALTER TABLE [dbo].[tblKartrisVersions] DROP CONSTRAINT [DF__tblKartris__V_RRP__24927208]
GO
ALTER TABLE [dbo].[tblKartrisVersions] ALTER COLUMN V_Price DECIMAL(18,4) NULL
ALTER TABLE [dbo].[tblKartrisVersions] ALTER COLUMN V_RRP DECIMAL(18,4) NOT NULL
ALTER TABLE [dbo].[tblKartrisVersions] ALTER COLUMN V_CustomizationCost DECIMAL(18,4) NULL
GO
ALTER TABLE [dbo].[tblKartrisVersions] ADD  CONSTRAINT [DF__tblKartris__V_Pri__1DE57479]  DEFAULT ((0)) FOR [V_Price]
ALTER TABLE [dbo].[tblKartrisVersions]  WITH CHECK ADD  CONSTRAINT [CK_Versions_RRP] CHECK  (([V_RRP]>=(0)))
ALTER TABLE [dbo].[tblKartrisVersions] ADD  CONSTRAINT [DF__tblKartris__V_RRP__24927208]  DEFAULT ((0)) FOR [V_RRP]
GO
ALTER TABLE [dbo].[tblKartrisVersions] CHECK CONSTRAINT [CK_Versions_RRP]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'V_RRP should be positive value' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblKartrisVersions', @level2type=N'CONSTRAINT',@level2name=N'CK_Versions_RRP'
GO

/* remove constraint from options, set to decimal, add constraint back in */
ALTER TABLE [dbo].[tblKartrisOptions] DROP CONSTRAINT [DF__tblKartris__OPT_D__6B24EA82] 
GO
ALTER TABLE [dbo].[tblKartrisOptions] ALTER COLUMN OPT_DefPriceChange DECIMAL(18,4) NULL
GO
ALTER TABLE [dbo].[tblKartrisOptions] ADD CONSTRAINT [DF__tblKartris__OPT_D__6B24EA82]  DEFAULT ((0)) FOR [OPT_DefPriceChange]
GO

/* remove constraint from options-product values, set to decimal, add constraint back in */
ALTER TABLE [dbo].[tblKartrisProductOptionLink] DROP CONSTRAINT [DF__tblKartris__P_OPT__7F60ED59] 
GO
ALTER TABLE [dbo].[tblKartrisProductOptionLink] ALTER COLUMN P_OPT_PriceChange DECIMAL(18,4) NULL
GO
ALTER TABLE [dbo].[tblKartrisProductOptionLink] ADD CONSTRAINT [DF__tblKartris__P_OPT__7F60ED59]  DEFAULT ((0)) FOR [P_OPT_PriceChange]
GO

/* quantity discounts */
ALTER TABLE [dbo].[tblKartrisQuantityDiscounts] DROP CONSTRAINT [DF__tblKartris__QD_Pr__208CD6FA] 
GO
ALTER TABLE [dbo].[tblKartrisQuantityDiscounts] ALTER COLUMN QD_Price DECIMAL(18,4) NOT NULL
GO
ALTER TABLE [dbo].[tblKartrisQuantityDiscounts] ADD CONSTRAINT [DF__tblKartris__QD_Pr__208CD6FA]  DEFAULT ((0)) FOR [QD_Price]
GO

/* promotion parts */
ALTER TABLE [dbo].[tblKartrisPromotionParts] DROP CONSTRAINT [CK_PromotionParts_PromotionValue] 
GO
ALTER TABLE [dbo].[tblKartrisPromotionParts] ALTER COLUMN PP_Value DECIMAL(18,4) NULL
GO
ALTER TABLE [dbo].[tblKartrisPromotionParts]  WITH CHECK ADD CONSTRAINT [CK_PromotionParts_PromotionValue] CHECK (([PP_Value]>(0)))
GO

/* customer group prices */
ALTER TABLE [dbo].[tblKartrisCustomerGroupPrices] DROP CONSTRAINT [DF__tblKartris__CGP_P__4F47C5E3] 
GO
ALTER TABLE [dbo].[tblKartrisCustomerGroupPrices] ALTER COLUMN CGP_Price DECIMAL(18,4) NULL
GO
ALTER TABLE [dbo].[tblKartrisCustomerGroupPrices] ADD  CONSTRAINT [DF__tblKartris__CGP_P__4F47C5E3]  DEFAULT ((0)) FOR [CGP_Price]
GO

/* invoice rows */
ALTER TABLE [dbo].[tblKartrisInvoiceRows] DROP CONSTRAINT [DF__tblKartris__IR_Pr__4BAC3F29]
ALTER TABLE [dbo].[tblKartrisInvoiceRows] DROP CONSTRAINT [DF__tblKartris__IR_Ta__4CA06362]
GO
ALTER TABLE [dbo].[tblKartrisInvoiceRows] ALTER COLUMN IR_PricePerItem DECIMAL(18,4) NULL
ALTER TABLE [dbo].[tblKartrisInvoiceRows] ALTER COLUMN IR_TaxPerItem DECIMAL(18,4) NULL
GO
ALTER TABLE [dbo].[tblKartrisInvoiceRows] ADD CONSTRAINT [DF__tblKartris__IR_Pr__4BAC3F29]  DEFAULT ((0)) FOR [IR_PricePerItem]
ALTER TABLE [dbo].[tblKartrisInvoiceRows] ADD CONSTRAINT [DF__tblKartris__IR_Ta__4CA06362]  DEFAULT ((0)) FOR [IR_TaxPerItem]
GO

/* orders */
ALTER TABLE [dbo].[tblKartrisOrders] DROP CONSTRAINT [DF__tblKartris__O_Shi__2D27B809]
ALTER TABLE [dbo].[tblKartrisOrders] DROP CONSTRAINT [DF__tblKartris__O_Shi__2E1BDC42]
ALTER TABLE [dbo].[tblKartrisOrders] DROP CONSTRAINT [DF__tblKartris__O_Dis__2F10007B]
ALTER TABLE [dbo].[tblKartrisOrders] DROP CONSTRAINT [DF__tblKartris__O_Aff__300424B4]
ALTER TABLE [dbo].[tblKartrisOrders] DROP CONSTRAINT [DF__tblKartris__O_Tot__30F848ED]
ALTER TABLE [dbo].[tblKartrisOrders] DROP CONSTRAINT [DF__tblKartris__O_Cou__33D4B598]
ALTER TABLE [dbo].[tblKartrisOrders] DROP CONSTRAINT [DF__tblKartris__O_Tax__34C8D9D1]
ALTER TABLE [dbo].[tblKartrisOrders] DROP CONSTRAINT [DF__tblKartris__O_Tot__37A5467C]
ALTER TABLE [dbo].[tblKartrisOrders] DROP CONSTRAINT [DF__tblKartris__O_Aff__3A81B327]
ALTER TABLE [dbo].[tblKartrisOrders] DROP CONSTRAINT [DF__tblKartris__O_Ord__3B75D760]
ALTER TABLE [dbo].[tblKartrisOrders] DROP CONSTRAINT [DF__tblKartris__O_Ord__3C69FB99]
ALTER TABLE [dbo].[tblKartrisOrders] DROP CONSTRAINT [DF__tblKartris__O_Cur__3D5E1FD2]
ALTER TABLE [dbo].[tblKartrisOrders] DROP CONSTRAINT [DF__tblKartris__O_Pro__3E52440B]
GO

DROP INDEX [_dta_index_tblKartrisOrders_5_1322487790__K1D_2_8_9_12_13_14_15_25_26_36] ON [dbo].[tblKartrisOrders]
GO

ALTER TABLE [dbo].[tblKartrisOrders] ALTER COLUMN O_ShippingPrice DECIMAL(18,4) NULL
ALTER TABLE [dbo].[tblKartrisOrders] ALTER COLUMN O_ShippingTax DECIMAL(18,4) NULL
ALTER TABLE [dbo].[tblKartrisOrders] ALTER COLUMN O_DiscountPercentage DECIMAL(18,4) NULL
ALTER TABLE [dbo].[tblKartrisOrders] ALTER COLUMN O_AffiliatePercentage DECIMAL(18,4) NULL
ALTER TABLE [dbo].[tblKartrisOrders] ALTER COLUMN O_TotalPrice DECIMAL(18,4) NULL
ALTER TABLE [dbo].[tblKartrisOrders] ALTER COLUMN O_CouponDiscountTotal DECIMAL(18,4) NULL
ALTER TABLE [dbo].[tblKartrisOrders] ALTER COLUMN O_TaxDue DECIMAL(18,4) NULL
ALTER TABLE [dbo].[tblKartrisOrders] ALTER COLUMN O_TotalPriceGateway DECIMAL(18,4) NULL
ALTER TABLE [dbo].[tblKartrisOrders] ALTER COLUMN O_AffiliateTotalPrice DECIMAL(18,4) NULL
ALTER TABLE [dbo].[tblKartrisOrders] ALTER COLUMN O_OrderHandlingCharge DECIMAL(18,4) NULL
ALTER TABLE [dbo].[tblKartrisOrders] ALTER COLUMN O_OrderHandlingChargeTax DECIMAL(18,4) NULL
ALTER TABLE [dbo].[tblKartrisOrders] ALTER COLUMN O_CurrencyRate DECIMAL(18,8) NULL
ALTER TABLE [dbo].[tblKartrisOrders] ALTER COLUMN O_PromotionDiscountTotal DECIMAL(18,4) NULL
GO

ALTER TABLE [dbo].[tblKartrisOrders] ADD  CONSTRAINT [DF__tblKartris__O_Shi__2D27B809]  DEFAULT ((0)) FOR [O_ShippingPrice]
ALTER TABLE [dbo].[tblKartrisOrders] ADD  CONSTRAINT [DF__tblKartris__O_Shi__2E1BDC42]  DEFAULT ((0)) FOR [O_ShippingTax]
ALTER TABLE [dbo].[tblKartrisOrders] ADD  CONSTRAINT [DF__tblKartris__O_Dis__2F10007B]  DEFAULT ((0)) FOR [O_DiscountPercentage]
ALTER TABLE [dbo].[tblKartrisOrders] ADD  CONSTRAINT [DF__tblKartris__O_Aff__300424B4]  DEFAULT ((0)) FOR [O_AffiliatePercentage]
ALTER TABLE [dbo].[tblKartrisOrders] ADD  CONSTRAINT [DF__tblKartris__O_Tot__30F848ED]  DEFAULT ((0)) FOR [O_TotalPrice]
ALTER TABLE [dbo].[tblKartrisOrders] ADD  CONSTRAINT [DF__tblKartris__O_Cou__33D4B598]  DEFAULT ((0)) FOR [O_CouponDiscountTotal]
ALTER TABLE [dbo].[tblKartrisOrders] ADD  CONSTRAINT [DF__tblKartris__O_Tax__34C8D9D1]  DEFAULT ((0)) FOR [O_TaxDue]
ALTER TABLE [dbo].[tblKartrisOrders] ADD  CONSTRAINT [DF__tblKartris__O_Tot__37A5467C]  DEFAULT ((0)) FOR [O_TotalPriceGateway]
ALTER TABLE [dbo].[tblKartrisOrders] ADD  CONSTRAINT [DF__tblKartris__O_Aff__3A81B327]  DEFAULT ((0)) FOR [O_AffiliateTotalPrice]
ALTER TABLE [dbo].[tblKartrisOrders] ADD  CONSTRAINT [DF__tblKartris__O_Ord__3B75D760]  DEFAULT ((0)) FOR [O_OrderHandlingCharge]
ALTER TABLE [dbo].[tblKartrisOrders] ADD  CONSTRAINT [DF__tblKartris__O_Ord__3C69FB99]  DEFAULT ((0)) FOR [O_OrderHandlingChargeTax]
ALTER TABLE [dbo].[tblKartrisOrders] ADD  CONSTRAINT [DF__tblKartris__O_Cur__3D5E1FD2]  DEFAULT ((0)) FOR [O_CurrencyRate]
ALTER TABLE [dbo].[tblKartrisOrders] ADD  CONSTRAINT [DF__tblKartris__O_Pro__3E52440B]  DEFAULT ((0)) FOR [O_PromotionDiscountTotal]
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblKartrisOrders_5_1322487790__K1D_2_8_9_12_13_14_15_25_26_36] ON [dbo].[tblKartrisOrders]
(
	[O_ID] DESC
)
INCLUDE ( 	[O_Sent],
	[O_Shipped],
	[O_TotalPrice],
	[O_LanguageID],
	[O_Paid],
	[O_CustomerID],
	[O_Date],
	[O_Invoiced],
	[O_BillingAddress],
	[O_CurrencyID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/* payments */
ALTER TABLE [dbo].[tblKartrisPayments] ALTER COLUMN Payment_Amount DECIMAL(18,4) NULL
ALTER TABLE [dbo].[tblKartrisPayments] ALTER COLUMN Payment_CurrencyRate DECIMAL(18,8) NULL
GO

/* currencies */
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblKartrisCurrencies', @level2type=N'CONSTRAINT',@level2name=N'CK_Currencies_ExchangeRateValidation'
GO
ALTER TABLE [dbo].[tblKartrisCurrencies] DROP CONSTRAINT [CK_Currencies_ExchangeRateValidation]
ALTER TABLE [dbo].[tblKartrisCurrencies] DROP CONSTRAINT [DF__tblKartris__CUR_E__72C60C4A]
GO
ALTER TABLE [dbo].[tblKartrisCurrencies] ALTER COLUMN CUR_ExchangeRate DECIMAL(18,8) NULL
GO
ALTER TABLE [dbo].[tblKartrisCurrencies]  WITH CHECK ADD  CONSTRAINT [CK_Currencies_ExchangeRateValidation] CHECK  (([CUR_ExchangeRate]>(0) OR [CUR_ExchangeRate]=(0) AND [CUR_Live]=(0)))
ALTER TABLE [dbo].[tblKartrisCurrencies] ADD  CONSTRAINT [DF__tblKartris__CUR_E__72C60C4A]  DEFAULT ((0)) FOR [CUR_ExchangeRate]
GO
ALTER TABLE [dbo].[tblKartrisCurrencies] CHECK CONSTRAINT [CK_Currencies_ExchangeRateValidation]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CUR_ExchangeRate should be a positive number for live currencies' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblKartrisCurrencies', @level2type=N'CONSTRAINT',@level2name=N'CK_Currencies_ExchangeRateValidation'
GO

/* coupons */
ALTER TABLE [dbo].[tblKartrisCoupons] DROP CONSTRAINT [DF__tblKartris__CP_Di__7D439ABD]
GO
ALTER TABLE [dbo].[tblKartrisCoupons] ALTER COLUMN CP_DiscountValue DECIMAL(18,4) NULL
GO
ALTER TABLE [dbo].[tblKartrisCoupons] ADD  CONSTRAINT [DF__tblKartris__CP_Di__7D439ABD]  DEFAULT ((0)) FOR [CP_DiscountValue]
GO

/* tax rates */
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblKartrisTaxRates', @level2type=N'CONSTRAINT',@level2name=N'CK_TaxRates_TaxRate'
GO
ALTER TABLE [dbo].[tblKartrisTaxRates] DROP CONSTRAINT [DF__tblKartris__T_Tax__5165187F]
ALTER TABLE [dbo].[tblKartrisTaxRates] DROP CONSTRAINT [CK_TaxRates_TaxRate]
GO
ALTER TABLE [dbo].[tblKartrisTaxRates] ALTER COLUMN T_Taxrate DECIMAL(18,4) NOT NULL
GO
ALTER TABLE [dbo].[tblKartrisTaxRates] ADD  CONSTRAINT [DF__tblKartris__T_Tax__5165187F]  DEFAULT ((0)) FOR [T_Taxrate]
ALTER TABLE [dbo].[tblKartrisTaxRates]  WITH CHECK ADD  CONSTRAINT [CK_TaxRates_TaxRate] CHECK  (([T_Taxrate]>=(0)))
GO
ALTER TABLE [dbo].[tblKartrisTaxRates] CHECK CONSTRAINT [CK_TaxRates_TaxRate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'T_Taxrate should be larger than zero' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblKartrisTaxRates', @level2type=N'CONSTRAINT',@level2name=N'CK_TaxRates_TaxRate'
GO

/* shipping rates */
ALTER TABLE [dbo].[tblKartrisShippingRates] DROP CONSTRAINT [uniqe_ShippingRates]
ALTER TABLE [dbo].[tblKartrisShippingRates] DROP CONSTRAINT [DF__tblKartris__S_Bou__6754599E]
ALTER TABLE [dbo].[tblKartrisShippingRates] DROP CONSTRAINT [DF__tblKartris__S_Shi__66603565]
GO
ALTER TABLE [dbo].[tblKartrisShippingRates] ALTER COLUMN S_Boundary DECIMAL(22,4) NOT NULL
ALTER TABLE [dbo].[tblKartrisShippingRates] ALTER COLUMN S_ShippingRate DECIMAL(18,4) NOT NULL
GO
ALTER TABLE [dbo].[tblKartrisShippingRates] ADD  CONSTRAINT [DF__tblKartris__S_Bou__6754599E]  DEFAULT ((0)) FOR [S_Boundary]
ALTER TABLE [dbo].[tblKartrisShippingRates] ADD  CONSTRAINT [DF__tblKartris__S_Shi__66603565]  DEFAULT ((0)) FOR [S_ShippingRate]
ALTER TABLE [dbo].[tblKartrisShippingRates] ADD  CONSTRAINT [uniqe_ShippingRates] UNIQUE NONCLUSTERED 
(
	[S_ShippingMethodID] ASC,
	[S_ShippingZoneID] ASC,
	[S_Boundary] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/* destination */
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblKartrisDestination', @level2type=N'CONSTRAINT',@level2name=N'CK_Destination_Tax'
GO
ALTER TABLE [dbo].[tblKartrisDestination] DROP CONSTRAINT [CK_Destination_Tax]
ALTER TABLE [dbo].[tblKartrisDestination] DROP CONSTRAINT [DF__tblKartris__D_Tax__5441852A]
GO
ALTER TABLE [dbo].[tblKartrisDestination] ALTER COLUMN D_Tax DECIMAL(12,8) NULL
ALTER TABLE [dbo].[tblKartrisDestination] ALTER COLUMN D_Tax2 DECIMAL(12,8) NULL
GO
ALTER TABLE [dbo].[tblKartrisDestination] ADD  CONSTRAINT [DF__tblKartris__D_Tax__5441852A]  DEFAULT ((0)) FOR [D_Tax]
ALTER TABLE [dbo].[tblKartrisDestination]  WITH CHECK ADD  CONSTRAINT [CK_Destination_Tax] CHECK  (([D_Tax]>=(0)))
GO
ALTER TABLE [dbo].[tblKartrisDestination] CHECK CONSTRAINT [CK_Destination_Tax]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'D_Tax should be positive' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblKartrisDestination', @level2type=N'CONSTRAINT',@level2name=N'CK_Destination_Tax'
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisTaxRates_Get]    Script Date: 02/05/2016 14:49:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisTaxRates_Get]
AS
	SET NOCOUNT ON;
	SELECT	T_ID, T_Taxrate, 
			'[' + CAST(T_ID AS nvarchar(3)) + ']'
			+ ' - ' + CAST(Cast(T_Taxrate as real) AS nvarchar(10)) + '%' AS T_TaxRateString, T_QBRefCode
	FROM	tblKartrisTaxRates
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCurrencies_Update]    Script Date: 02/05/2016 15:02:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisCurrencies_Update]
(
	@CUR_Symbol nvarchar(5),
	@CUR_ISOCode nvarchar(10),
	@CUR_ISOCodeNumeric nvarchar(10),
	@CUR_ExchangeRate DECIMAL(18,8),
	@CUR_HasDecimals bit,
	@CUR_Live bit,
	@CUR_Format nvarchar(20),
	@CUR_IsoFormat nvarchar(20),
	@CUR_DecimalPoint char(1),
	@CUR_RoundNumbers tinyint,
	@Original_CUR_ID tinyint
)
AS
	SET NOCOUNT OFF;
 
UPDATE [tblKartrisCurrencies] 
SET [CUR_Symbol] = @CUR_Symbol, [CUR_ISOCode] = @CUR_ISOCode, [CUR_ISOCodeNumeric] = @CUR_ISOCodeNumeric, 
	[CUR_ExchangeRate] = @CUR_ExchangeRate, [CUR_HasDecimals] = @CUR_HasDecimals, [CUR_Live] = @CUR_Live, 
	[CUR_Format] = @CUR_Format, [CUR_IsoFormat] = @CUR_IsoFormat, [CUR_DecimalPoint] = @CUR_DecimalPoint, 
	[CUR_RoundNumbers]= @CUR_RoundNumbers
WHERE (([CUR_ID] = @Original_CUR_ID));
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCurrencies_Add]    Script Date: 02/05/2016 15:01:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisCurrencies_Add]
(
	@CUR_Symbol nvarchar(5),
	@CUR_ISOCode nvarchar(10),
	@CUR_ISOCodeNumeric nvarchar(10),
	@CUR_ExchangeRate DECIMAL(18,8),
	@CUR_HasDecimals bit,
	@CUR_Live bit,
	@CUR_Format nvarchar(20),
	@CUR_IsoFormat nvarchar(20),
	@CUR_DecimalPoint char(1),
	@CUR_RoundNumbers tinyint,
	@CUR_NewID as tinyint OUTPUT
)
AS
	SET NOCOUNT OFF;

	DECLARE @MaxOrder as tinyint;
	SELECT @MaxOrder = MAX(CUR_OrderNo) + 1
	FROM [tblKartrisCurrencies];

	INSERT INTO [tblKartrisCurrencies] 
	([CUR_Symbol], [CUR_ISOCode], [CUR_ISOCodeNumeric], [CUR_ExchangeRate], [CUR_HasDecimals], [CUR_Live], 
	[CUR_Format], [CUR_IsoFormat], [CUR_DecimalPoint], [CUR_RoundNumbers], [CUR_OrderNo]) 
	VALUES (@CUR_Symbol, @CUR_ISOCode, @CUR_ISOCodeNumeric, @CUR_ExchangeRate, @CUR_HasDecimals, @CUR_Live, 
	@CUR_Format, @CUR_IsoFormat, @CUR_DecimalPoint, @CUR_RoundNumbers, @MaxOrder);
	
	SELECT @CUR_NewID = SCOPE_IDENTITY();
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingRates_Add]    Script Date: 03/05/2016 10:41:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisShippingRates_Add]
(
	@SM_ID as tinyint,
	@SZ_ID as tinyint,
	@S_Boundary as DECIMAL(22,4),
	@S_Rate as DECIMAL(18,4),
	@S_ShippingGateways as nvarchar(255)
)
AS
	SET NOCOUNT ON;
	
	INSERT	INTO	tblKartrisShippingRates
	VALUES(@SM_ID, @SZ_ID, @S_Boundary, @S_Rate, @S_ShippingGateways)
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingRates_GetByShippingMethod]    Script Date: 03/05/2016 10:44:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get Shipping Methods - by Destination and Boundary
-- ===============================================================
ALTER PROCEDURE [dbo].[_spKartrisShippingRates_GetByShippingMethod]
(
	@SM_ID as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT	S_ID, S_ShippingMethodID, S_ShippingZoneID, 
			CAST(S_Boundary AS Decimal(22,4)) as S_Boundary, 
			CAST(S_ShippingRate as Decimal(18, 4)) as S_ShippingRate
	FROM dbo.tblKartrisShippingRates
	WHERE S_ShippingMethodID = @SM_ID
	ORDER BY S_ShippingZoneID, S_Boundary, S_ShippingRate

END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingRates_Update]    Script Date: 03/05/2016 10:47:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisShippingRates_Update]
(
	@S_ID as int,
	@NewRate as DECIMAL(18,4),
	@S_ShippingGateways as nvarchar(255)
)
AS
	SET NOCOUNT ON;
	
	UPDATE	tblKartrisShippingRates
	SET		S_ShippingRate = @NewRate, S_ShippingGateways = @S_ShippingGateways
	WHERE	S_ID = @S_ID;
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_Update]    Script Date: 03/05/2016 20:59:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_Update]
(
	@V_ID as bigint,
	@V_CodeNumber as nvarchar(25),
	@V_ProductID as int,
	@V_Price as DECIMAL(18,4),
	@V_Tax as tinyint,
	@V_Weight as real,
	@V_DeliveryTime as tinyint,
	@V_Quantity as real,
	@V_QuantityWarnLevel as real,
	@V_Live as bit,
	@V_DownLoadInfo as nvarchar(255),
	@V_DownloadType as nvarchar(50),
	@V_RRP as DECIMAL(18,4),
	@V_Type as char(1),
	@V_CustomerGroupID as smallint,
	@V_CustomizationType as char(1),
	@V_CustomizationDesc as nvarchar(255),
	@V_CustomizationCost as DECIMAL(18,4),
	@V_Tax2 as tinyint,
	@V_TaxExtra as nvarchar(255)
)
								
AS
BEGIN
	
	SET NOCOUNT ON;

	UPDATE tblKartrisVersions
	SET V_CodeNumber = @V_CodeNumber, V_ProductID = @V_ProductID, V_Price = @V_Price, V_Tax = @V_Tax, V_Weight = @V_Weight, 
		V_DeliveryTime = @V_DeliveryTime, V_Quantity = @V_Quantity, V_QuantityWarnLevel = @V_QuantityWarnLevel, 
		V_Live = @V_Live, V_DownLoadInfo = @V_DownLoadInfo, V_DownloadType = @V_DownloadType,
		V_RRP = @V_RRP, V_Type = @V_Type, V_CustomerGroupID = @V_CustomerGroupID, V_CustomizationType = @V_CustomizationType,
		V_CustomizationDesc = @V_CustomizationDesc, V_CustomizationCost = @V_CustomizationCost, 
		V_Tax2 = @V_Tax2, V_TaxExtra = @V_TaxExtra
	WHERE V_ID = @V_ID;
	
	IF @V_Type = 'b' BEGIN
		UPDATE tblKartrisVersions
		SET V_DownLoadInfo = @V_DownLoadInfo, V_DownloadType = @V_DownloadType
		WHERE V_ProductID = @V_ProductID AND V_Type = 'c';
	END

END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_Add]    Script Date: 03/05/2016 21:14:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_Add]
(
	@V_CodeNumber as nvarchar(25),
	@V_ProductID as int,
	@V_Price as DECIMAL(18,4),
	@V_Tax as tinyint,
	@V_Tax2 as tinyint,
	@V_TaxExtra as nvarchar(255),
	@V_Weight as real,
	@V_DeliveryTime as tinyint,
	@V_Quantity as real,
	@V_QuantityWarnLevel as real,
	@V_Live as bit,
	@V_DownLoadInfo as nvarchar(255),
	@V_DownloadType as nvarchar(50),
	@V_RRP as DECIMAL(18,4),
	@V_Type as char(1),
	@V_CustomerGroupID as smallint,
	@V_CustomizationType as char(1),
	@V_CustomizationDesc as nvarchar(255),
	@V_CustomizationCost as DECIMAL(18,4),
	@V_NewID as bigint OUT
)
								
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @MaxOrder as int;
	SELECT @MaxOrder = Max(V_OrderByValue) FROM dbo.tblKartrisVersions WHERE V_ProductID = @V_ProductID;
	IF @MaxOrder is NULL BEGIN SET @MaxOrder = 0 END;

	
	INSERT INTO tblKartrisVersions
	VALUES (@V_CodeNumber, @V_ProductID, @V_Price, @V_Tax, @V_Weight, @V_DeliveryTime, @V_Quantity, @V_QuantityWarnLevel, 
			@V_Live, @V_DownLoadInfo, @V_DownloadType, @MaxOrder + 1, @V_RRP, @V_Type, @V_CustomerGroupID, @V_CustomizationType,
			@V_CustomizationDesc, @V_CustomizationCost, @V_Tax2, @V_TaxExtra);
			
	SELECT @V_NewID = SCOPE_IDENTITY();

END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_AddAsCombination]    Script Date: 01/23/2013 21:59:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_AddAsCombination]
(
	@V_CodeNumber as nvarchar(25),
	@V_ProductID as int,
	@V_Price as DECIMAL(18,4),
	@V_Tax as tinyint,
	@V_Tax2 as tinyint,
	@V_TaxExtra as nvarchar(50),
	@V_Weight as real,
	@V_Quantity as real,
	@V_QuantityWarnLevel as real,
	@V_RRP as DECIMAL(18,4),
	@V_Type as char(1),
	@V_NewID as bigint OUT
)
								
AS
BEGIN
	
	SET NOCOUNT ON;

	
	DECLARE @DownloadInfo as nvarchar(255), @DownloadType as nvarchar(50);
	SELECT @DownloadInfo = [V_DownLoadInfo], @DownloadType = [V_DownloadType]
	FROM [dbo].[tblKartrisVersions]
	WHERE [V_ProductID] = @V_ProductID AND [V_Type] = 'b';

	INSERT INTO tblKartrisVersions
	VALUES (@V_CodeNumber, @V_ProductID, @V_Price, @V_Tax, @V_Weight, 0, @V_Quantity, @V_QuantityWarnLevel, 
			1, @DownloadInfo, @DownloadType, 20, @V_RRP, @V_Type, NULL, 'n', NULL, 0, @V_Tax2, @V_TaxExtra);
			
	SELECT @V_NewID = SCOPE_IDENTITY();
	

END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_MarkupPrices]    Script Date: 03/05/2016 21:18:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: 26th, June 2011
-- Description:	Mark up/down versions' prices
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_MarkupPrices]
(
	@List as nvarchar(max),
	@Target as nvarchar(5)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	
	DECLARE @Pos int, @Pos2 int, @Pos3 int, @Item nvarchar(max), @ID nvarchar(50),@QTY nvarchar(10), @Price nvarchar(50)
	SET @List = LTRIM(RTRIM(@List))+ ';'    
	SET @Pos = CHARINDEX(';', @List, 1)    
	IF REPLACE(@List, ';', '') <> '' BEGIN        
		WHILE @Pos > 0 BEGIN 
			SET @Item = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))                
			IF @Item <> '' BEGIN
				SET @Pos2 = CHARINDEX('#', @Item, 1)
				IF @Pos2 > 0 BEGIN
					SET @ID = LTRIM(RTRIM(LEFT(@Item, @Pos2 - 1)))
					SET @Price = REPLACE(@Item, @ID + '#', '')
					--PRINT 'ID:' + @ID + '    Price:' + @Price;					
					IF LOWER(@Target) = 'price' BEGIN
						UPDATE dbo.tblKartrisVersions
						SET V_Price = CAST(@Price as DECIMAL(18,4))
						WHERE V_ID = CAST(@ID as bigint);
					END
					IF LOWER(@Target) = 'rrp' BEGIN
						UPDATE dbo.tblKartrisVersions
						SET V_RRP = CAST(@Price as DECIMAL(18,4))
						WHERE V_ID = CAST(@ID as bigint);
					END
					IF LOWER(@Target) = 'qd' BEGIN
						SET @Pos3 = CHARINDEX(',', @ID, 1)
						SET @QTY = LTRIM(RTRIM(SUBSTRING(@ID,@Pos3+1,10)))
						print @QTY
						SET @ID = LTRIM(RTRIM(REPLACE(@ID, ',' + @QTY,'')))
						print @ID
						UPDATE dbo.tblKartrisQuantityDiscounts
						SET QD_Price = CAST(@Price as DECIMAL(18,4))
						WHERE QD_VersionID = CAST(@ID as bigint) AND QD_Quantity= CAST(@QTY as real);
					END
				END
			END                
			SET @List = RIGHT(@List, LEN(@List) - @Pos)                
			SET @Pos = CHARINDEX(';', @List, 1)        
		END    
	END;

END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisQuantityDiscounts_Add]    Script Date: 03/05/2016 21:20:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisQuantityDiscounts_Add]
(
	@VersionID bigint,
	@Quantity as real,
	@Price as DECIMAL(18,4)
)
AS
	SET NOCOUNT ON;
	
	INSERT INTO tblKartrisQuantityDiscounts
	VALUES(@VersionID, @Quantity, @Price);
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_UpdateCustomerGroupPrices]    Script Date: 03/05/2016 21:35:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Joseph
-- Create date: 1/Nov/2009
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_UpdateCustomerGroupPrices] ( 
	@CustomerGroupID int,
	@VersionID int,
	@Price DECIMAL(18,4),
	@CustomerGroupPriceID int	
) AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @cnt as int
	SELECT @cnt = COUNT(CGP_ID) FROM tblKartrisCustomerGroupPrices
	WHERE CGP_CustomerGroupID = @CustomerGroupID and CGP_VersionID = @VersionID;

	IF @cnt = 0
	BEGIN -- insert data
		INSERT INTO tblKartrisCustomerGroupPrices (CGP_CustomerGroupID,CGP_VersionID,CGP_Price)
			VALUES (@CustomerGroupID,@VersionID,@Price)
	END
	ELSE
	BEGIN -- update record
		UPDATE tblKartrisCustomerGroupPrices
			SET CGP_Price = @Price WHERE CGP_ID = @CustomerGroupPriceID
	END;
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_UpdateCustomerGroupPriceList]    Script Date: 03/05/2016 21:36:56 ******/
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


	UPDATE dbo.tblKartrisCustomerGroupPrices
	SET CGP_Price = @CGP_Price WHERE CGP_VersionID = @CGP_VersionID AND CGP_CustomerGroupID = @CG_ID;

END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisPromotionParts_Add]    Script Date: 01/23/2013 21:59:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisPromotionParts_Add]
(	@PROM_ID as int,
	@PP_PartNo as char(1),
	@PP_ItemType as char(1),
	@PP_ItemID as bigint,
	@PP_Type as char(1),
	@PP_Value as DECIMAL(18,4)
)
AS
	SET NOCOUNT ON;

	
	INSERT INTO tblKartrisPromotionParts
	VALUES (@PROM_ID, @PP_PartNo, @PP_ItemType, @PP_ItemID, @PP_Type, @PP_Value);
GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.9004', CFG_VersionAdded=2.9004 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO




















