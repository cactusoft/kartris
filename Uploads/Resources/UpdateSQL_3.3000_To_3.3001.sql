
/*** Fix naming issue missed in v3.3000 ***/
EXEC sp_rename '[dbo].[tblKartrisProductCategoryLink].[PC_CategoryID]', 'PCAT_CategoryID'
EXEC sp_rename '[dbo].[tblKartrisProductCategoryLink].[PC_ProductID]', 'PCAT_ProductID'

GO

/* FIX ADVANCED SEARCHES THAT INCLUDE PRICING TO FIX ZERO RESULTS ISSUE */

/****** Object:  StoredProcedure [dbo].[spKartrisDB_Search]    Script Date: 03/06/2022 14:18:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Update: Paul - Jun 2022
-- Use PSI_MinPrice
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisDB_Search]
(	
	@SearchText as nvarchar(500),
	@keyWordsList as nvarchar(500),
	@LANG_ID as tinyint,
	@PageIndex as tinyint, -- 0 Based index
	@RowsPerPage as tinyint,
	@TotalResultProducts as int OUTPUT,
	@MinPrice as decimal(18,4),
	@MaxPrice as decimal(18,4),
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
		SET SH_Price = (SELECT PSI_MinPrice FROM tblKartrisProductSearchIndex WHERE PSI_ProductID=SH_ProductID AND SH_SessionID = @@SPID)
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
				PSI_MinPrice as MinPrice, TotalScore, 
				dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, P_ID) AS KeywordList
		FROM SearchResult INNER JOIN dbo.vKartrisTypeProducts ON SearchResult.ProductID = dbo.vKartrisTypeProducts.P_ID
		WHERE vKartrisTypeProducts.LANG_ID = @LANG_ID AND ROW BETWEEN @StartRowNumber AND @EndRowNumber
		GROUP BY Row, P_ID, P_Name, P_Desc, PSI_MinPrice, TotalScore
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
				PSI_MinPrice as MinPrice, TotalScore, 
				dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID,P_ID) AS KeywordList
		FROM SearchResult INNER JOIN dbo.vKartrisTypeProducts ON SearchResult.ProductID = dbo.vKartrisTypeProducts.P_ID
		WHERE vKartrisTypeProducts.LANG_ID = @LANG_ID AND ROW BETWEEN @StartRowNumber AND @EndRowNumber
		GROUP BY Row, P_ID, P_Name, P_Desc, PSI_MinPrice, TotalScore
		ORDER BY TotalScore DESC
		
	END
	
	-- Clear the result of the current search
	DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID=@@SPID;
	
END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisDB_SetupFTS]    Script Date: 01/23/2013 21:59:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Update: Paul - Jun 2022
-- Use PSI_MinPrice
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
	
	EXEC sp_fulltext_table     'dbo.tblKartrisLanguageElements', 'create', 'kartrisCatalog', 'LE_ID'
	EXEC sp_fulltext_column    'dbo.tblKartrisLanguageElements', 'LE_Value', 'add'
	EXEC sp_fulltext_table     'dbo.tblKartrisLanguageElements','activate'

	EXEC sp_fulltext_table     'dbo.tblKartrisAddresses', 'create', 'kartrisCatalog', 'PK_tblKartrisAddresses'
	EXEC sp_fulltext_column    'dbo.tblKartrisAddresses', 'ADR_Name', 'add'
	EXEC sp_fulltext_table     'dbo.tblKartrisAddresses','activate'

	EXEC sp_fulltext_table     'dbo.tblKartrisUsers', 'create', 'kartrisCatalog', 'PK_tblKartrisUsers'
	EXEC sp_fulltext_column    'dbo.tblKartrisUsers', 'U_EmailAddress', 'add'
	EXEC sp_fulltext_table     'dbo.tblKartrisUsers','activate'

	EXEC sp_fulltext_table     'dbo.tblKartrisOrders', 'create', 'kartrisCatalog', 'PK_tblKartrisOrders'
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
	@MinPrice as decimal(18,4),
	@MaxPrice as decimal(18,4),
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
	IF @MinPrice <> -1 AND @MaxPrice <> -1	BEGIN
		UPDATE tblKartrisSearchHelper
		SET SH_Price = (SELECT PSI_MinPrice FROM tblKartrisProductSearchIndex WHERE PSI_ProductID=SH_ProductID AND SH_SessionID = @@SPID)
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
				PSI_MinPrice as MinPrice, TotalScore
		FROM SearchResult INNER JOIN dbo.vKartrisTypeProducts ON SearchResult.ProductID = dbo.vKartrisTypeProducts.P_ID
		WHERE vKartrisTypeProducts.LANG_ID = @LANG_ID AND ROW BETWEEN @StartRowNumber AND @EndRowNumber
		GROUP BY Row, P_ID, P_Name, P_Desc, PSI_MinPrice, TotalScore
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
				PSI_MinPrice as MinPrice, TotalScore, 
				dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID,P_ID) AS KeywordList
		FROM SearchResult INNER JOIN dbo.vKartrisTypeProducts ON SearchResult.ProductID = dbo.vKartrisTypeProducts.P_ID
		WHERE vKartrisTypeProducts.LANG_ID = @LANG_ID AND ROW BETWEEN @StartRowNumber AND @EndRowNumber
		GROUP BY Row, P_ID, P_Name, P_Desc, PSI_MinPrice, TotalScore
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

/****** New callforprice setting at version level ******/
SET IDENTITY_INSERT [dbo].[tblKartrisObjectConfig] ON 

INSERT [dbo].[tblKartrisObjectConfig] ([OC_ID], [OC_Name], [OC_ObjectType], [OC_DataType], [OC_DefaultValue], [OC_Description], [OC_MultilineValue], [OC_VersionAdded]) VALUES (13, N'K:version.callforprice', N'Version', N'b', N'0', N'display ''call for price'' and hide ''add'' button at version level.', 0, 3.3001)

SET IDENTITY_INSERT [dbo].[tblKartrisObjectConfig] OFF
GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='3.3001', CFG_VersionAdded=3.3001 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO

PRINT '-------------------------------------------------------'
PRINT 'That''s all folks! Looks like we reached the end....'
PRINT '-------------------------------------------------------'
