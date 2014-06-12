/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetByProductID]    Script Date: 2014-06-07 20:55:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Fixes issue with NULL values, 'simple'
-- tax mode settings
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisVersions_GetByProductID]
(
	@P_ID as int, 
	@LANG_ID as tinyint,
	@CGroupID as smallint
)
AS
BEGIN
SET NOCOUNT ON;
	
	DECLARE @OrderBy as nvarchar(50), @OrderDirection as char(1);
	SELECT @OrderBy = P_OrderVersionsBy, @OrderDirection = P_VersionsSortDirection
	FROM tblKartrisProducts WHERE P_ID = @P_ID;

	IF @OrderBy IS NULL OR @OrderBy = '' OR @OrderBy = 'd'
	BEGIN
		 SELECT @OrderBy = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = 'frontend.versions.display.sortdefault';
	END

	IF @OrderDirection IS NULL OR @OrderDirection = ''
	BEGIN
		 SELECT @OrderDirection = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = 'frontend.versions.display.sortdirection';
	END

	BEGIN
		SELECT     vKartrisTypeVersions.V_ID, tblKartrisTaxRates.T_Taxrate, vKartrisTypeVersions.V_Price, vKartrisTypeVersions.V_Weight, vKartrisTypeVersions.V_RRP, 
					  vKartrisTypeVersions.V_Tax, tblKartrisTaxRates.T_Taxrate AS Expr1, '0' AS CalculatedTax, vKartrisTypeVersions.V_ProductID, vKartrisTypeVersions.V_CodeNumber, 
					  vKartrisTypeVersions.V_ExtraCodeNumber, vKartrisTypeVersions.V_Quantity, vKartrisTypeVersions.V_QuantityWarnLevel, vKartrisTypeVersions.V_Price AS OrderByBit, 
					  vKartrisTypeVersions.V_Name, vKartrisTypeVersions.V_Desc, MIN(tblKartrisQuantityDiscounts.QD_Price) AS QuantityDiscount, vKartrisTypeVersions.V_OrderByValue, 
					  vKartrisTypeVersions.V_CustomizationType, vKartrisTypeVersions.V_CustomizationDesc, vKartrisTypeVersions.V_CustomizationCost
		FROM         vKartrisTypeVersions LEFT OUTER JOIN
							  tblKartrisTaxRates ON vKartrisTypeVersions.V_Tax = tblKartrisTaxRates.T_ID LEFT OUTER JOIN
							  tblKartrisQuantityDiscounts ON vKartrisTypeVersions.V_ID = tblKartrisQuantityDiscounts.QD_VersionID
		WHERE     (vKartrisTypeVersions.LANG_ID = @LANG_ID) AND (vKartrisTypeVersions.V_ProductID = @P_ID) AND (vKartrisTypeVersions.V_Live = 1)
				AND (vKartrisTypeVersions.V_CustomerGroupID IS NULL OR vKartrisTypeVersions.V_CustomerGroupID = @CGroupID)
				AND vKartrisTypeVersions.V_Type <> 's'
		GROUP BY vKartrisTypeVersions.V_ID, tblKartrisTaxRates.T_Taxrate, vKartrisTypeVersions.V_Price, vKartrisTypeVersions.V_Weight, vKartrisTypeVersions.V_RRP, 
							  vKartrisTypeVersions.V_Tax, vKartrisTypeVersions.V_ProductID, vKartrisTypeVersions.V_CodeNumber, vKartrisTypeVersions.V_ExtraCodeNumber,
							  vKartrisTypeVersions.V_Quantity, vKartrisTypeVersions.V_QuantityWarnLevel, vKartrisTypeVersions.V_Name, vKartrisTypeVersions.V_Desc, 
							  vKartrisTypeVersions.V_OrderByValue, vKartrisTypeVersions.V_CustomizationType, vKartrisTypeVersions.V_CustomizationDesc, 
							  vKartrisTypeVersions.V_CustomizationCost
		HAVING      (vKartrisTypeVersions.V_Name IS NOT NULL)
		ORDER BY	CASE
					WHEN (@OrderBy = 'V_Name' AND @OrderDirection = 'A') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Name ASC))
					WHEN (@OrderBy = 'V_Name' AND @OrderDirection = 'D') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Name DESC))
					WHEN (@OrderBy = 'V_ID' AND @OrderDirection = 'A') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_ID ASC))
					WHEN (@OrderBy = 'V_ID' AND @OrderDirection = 'D') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_ID DESC))
					WHEN (@OrderBy = 'V_OrderByValue' AND @OrderDirection = 'A') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_OrderByValue ASC))
					WHEN (@OrderBy = 'V_OrderByValue' AND @OrderDirection = 'D') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_OrderByValue DESC))
					WHEN (@OrderDirection = 'A') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Price ASC))
					ELSE (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Price DESC))
					END
	END			
END
/****** Object:  UserDefinedFunction [dbo].[fnKartrisVersions_GetBaseVersionDownloadType]    Script Date: 2014-06-07 17:28:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisVersions_GetBaseVersionDownloadType] 
(
	-- Add the parameters for the function here
	@V_ID as bigint
)
RETURNS nvarchar(50)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(50);
	DECLARE @P_ID int


	-- Add the T-SQL statements to compute the return value here
	SELECT @P_ID = V_ProductID FROM tblKartrisVersions WHERE V_ID = @V_ID;

	SELECT @Result = V_DownloadType FROM tblKartrisVersions WHERE V_ProductID = @P_ID AND V_Type='b'
	-- Return the result of the function
	RETURN @Result

END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasketValues_GetItems]    Script Date: 2014-06-07 15:16:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Joseph
-- Create date: 2008/4/8
-- Description:	
-- Remarks:	Optimization Medz - 2010/7/26
-- Re-Optimized: By Mohammad - 2011/10/13 - Combination Prices
-- Modified: By Mohammad - 2012/1/1 - Remove join with base version, so to fix the SKU for combination version
-- Modified: By Paul - 2014/6/7 - Added reference to new function to pull BaseVersion's download type
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisBasketValues_GetItems] (
	@intLanguageID int,
	@intSessionID int
)
AS
BEGIN

SET NOCOUNT ON;

WITH tblBasketValues as
	(	SELECT BV_ID,BV_VersionID,BV_Quantity,BV_CustomText 
		FROM tblKartrisBasketValues 
		WHERE BV_ParentType='b' and BV_ParentID=@intSessionID
	)
	SELECT DISTINCT P_ID As 'ProductID', P_Type As 'ProductType', V_Type As 'VersionType', T_TaxRate As 'TaxRate', T_TaxRate2 As 'TaxRate2',
		dbo.fnKartrisBasket_GetItemWeight(BV_ID, V_ID, P_ID) As 'Weight', V_RRP As 'RRP', P_Name As 'ProductName', V_ID, tblBasketValues.BV_ID,
		V_Name As 'VersionName', V_CodeNumber As 'CodeNumber', V_Price As 'Price', 
		tblBasketValues.BV_Quantity As 'Quantity', V_QuantityWarnLevel As 'QtyWarnLevel', V_Quantity,
		V_DownloadType, isnull(BV_CustomText,'') As 'CustomText',
		dbo.fnKartrisBasketOptionValues_GetOptionsTotalPrice(P_ID,BV_VersionID,@intSessionID,tblBasketValues.BV_ID) AS OptionsPrice,
		dbo.fnKartrisBasketOptionValues_GetCombinationPrice(P_ID,tblBasketValues.BV_ID) AS CombinationPrice,
		dbo.fnKartrisVersions_GetBaseVersionDownloadType(V_ID) AS BaseVersion_DownloadType,
		V_CustomizationType, V_CustomizationDesc, V_CustomizationCost, tblBasketValues.BV_VersionID 
	--FROM tblBasketValues INNER JOIN vKartrisProductsVersions ON dbo.fnKartris_GetBaseVersionID(BV_VersionID) = V_ID
	FROM tblBasketValues INNER JOIN vKartrisProductsVersions ON BV_VersionID = V_ID
	WHERE LANG_ID = @intLanguageID
	ORDER BY BV_ID
END

/****** Object: Create new language string.  Script Date: 2014-06-07 15:16:20 ******/
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_StockTrackingOptionsClarification', N'*Only applies if combinations created; normal options products cannot be stock-tracked', NULL, 1, N'*Only applies if combinations created; normal options products cannot be stock-tracked', NULL, N'_Version',1);

/****** Object:  StoredProcedure [dbo].[spKartrisDB_Search]    Script Date: 2014-06-12 10:17:55 ******/
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
/****** Object:  UserDefinedFunction [dbo].[fnTbl_SplitStrings]    Script Date: 2014-06-12 10:28:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- MODIFIED 2014/06/12 Paul, nvarchar support
-- =============================================
ALTER FUNCTION [dbo].[fnTbl_SplitStrings]
(	
	@List NVarchar(max))
RETURNS @ParsedList 
table(_ID NVarchar(500)) AS BEGIN
	DECLARE @_ID Nvarchar(500), @Pos int    
	SET @List = LTRIM(RTRIM(@List))+ ','    
	SET @Pos = CHARINDEX(',', @List, 1)    
	IF REPLACE(@List, ',', '') <> '' BEGIN        
		WHILE @Pos > 0 BEGIN                
			SET @_ID = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))                
			IF @_ID <> '' BEGIN                        
				INSERT INTO @ParsedList (_ID)                         
				VALUES (@_ID)              
			END                
			SET @List = RIGHT(@List, LEN(@List) - @Pos)                
			SET @Pos = CHARINDEX(',', @List, 1)        
		END    
	END     
	RETURN
END
