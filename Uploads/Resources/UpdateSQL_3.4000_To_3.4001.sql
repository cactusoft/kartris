
-- ============================================================================
-- Idempotent Upgrade Script: spKartrisDB_Search & spKartrisDB_SearchFTS
-- Preserves existing EXECUTE permissions via ALTER PROCEDURE
-- ============================================================================

IF OBJECT_ID(N'[dbo].[spKartrisDB_Search]', N'P') IS NULL
BEGIN
    EXEC sys.sp_executesql N'CREATE PROCEDURE [dbo].[spKartrisDB_Search] AS SET NOCOUNT ON;';
END;
GO

ALTER PROCEDURE [dbo].[spKartrisDB_Search]
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
	SET @SearchText = ISNULL(@SearchText, N'');
	SET @keyWordsList = ISNULL(@keyWordsList, N'');
	
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @Keyword as nvarchar(150);
	DECLARE @Counter as int;
	
	DECLARE @NoOfVersions as bigint;
	SELECT @NoOfVersions = Count(1) FROM tblKartrisVersions;
	
	DECLARE @DataToSearch as nvarchar(100);
	IF @NoOfVersions > 100000 BEGIN
		SET @DataToSearch = N'(LE_TypeID IN (2,14) AND LE_FieldID IN (1,2,5))'
	END ELSE BEGIN
		SET @DataToSearch = N'(LE_TypeID IN (1,2,14) AND LE_FieldID IN (1,2,5))'
	END
		
	DECLARE @ExactCriteriaNoNoise as nvarchar(500);
	SET @ExactCriteriaNoNoise = LTRIM(RTRIM(Replace(@keyWordsList, ',', ' ')));

	DECLARE @SearchTextEscaped as nvarchar(1020);
	SET @SearchTextEscaped =
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(@SearchText, N'\', N'\\'),
		N'[', N'\['),
		N'%', N'\%'),
		N'_', N'\_');

	DECLARE @ExactEscaped as nvarchar(1020);
	SET @ExactEscaped =
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(@ExactCriteriaNoNoise, N'\', N'\\'),
		N'[', N'\['),
		N'%', N'\%'),
		N'_', N'\_');

	DECLARE @SearchTextLikeAny as nvarchar(1024) = N'%' + @SearchTextEscaped + N'%';
	DECLARE @SearchTextLikePrefix as nvarchar(1022) = @SearchTextEscaped + N'%';
	DECLARE @ExactLikeAny as nvarchar(1024) = N'%' + @ExactEscaped + N'%';

	DECLARE @sql as nvarchar(max);
	DECLARE @params as nvarchar(max);
	
	IF @Method = 'exact' BEGIN
		SET @sql = N'
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID), 0, 100/LE_FieldID, @KeywordParam
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = @LangIdParam AND ' + @DataToSearch + N'
					AND (	(LE_Value LIKE @SearchLikeAnyParam ESCAPE N''\'')
						 OR	(LE_Value LIKE @ExactLikeAnyParam ESCAPE N''\'')
						)';

		SET @params = N'@LangIdParam tinyint, @SearchLikeAnyParam nvarchar(1024), @ExactLikeAnyParam nvarchar(1024), @KeywordParam nvarchar(500)';

		EXEC sys.sp_executesql
			@stmt = @sql,
			@params = @params,
			@LangIdParam = @LANG_ID,
			@SearchLikeAnyParam = @SearchTextLikeAny,
			@ExactLikeAnyParam = @ExactLikeAny,
			@KeywordParam = @ExactCriteriaNoNoise;
						
		SET @sql = N'
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, @ExactCriteriaParam
		FROM         tblKartrisVersions LEFT OUTER JOIN dbo.vKartrisObjectConfigValues 
			ON V_ID = OCV_ParentID AND OC_Name = N''K:version.extrasku''
		WHERE     (V_Live = 1)
		  AND     (V_CodeNumber LIKE @SearchPrefixParam ESCAPE N''\''
			       OR OCV_Value LIKE @SearchPrefixParam ESCAPE N''\'')';

		SET @params = N'@SearchPrefixParam nvarchar(1022), @ExactCriteriaParam nvarchar(500)';

		EXEC sys.sp_executesql
			@stmt = @sql,
			@params = @params,
			@SearchPrefixParam = @SearchTextLikePrefix,
			@ExactCriteriaParam = @ExactCriteriaNoNoise;
	END ELSE BEGIN
		SET @SIndx = 1; SET @Counter = 0;
		WHILE @SIndx <= LEN(@keyWordsList) BEGIN
			SET @Counter = @Counter + 1;
			SET @CIndx = CHARINDEX(',', @keyWordsList, @SIndx);
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList) + 1 END
			SET @Keyword = LTRIM(RTRIM(SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)));
			SET @SIndx = @CIndx + 1;

			IF @Keyword <> N'' BEGIN
				DECLARE @KeywordEscaped as nvarchar(320);
				SET @KeywordEscaped =
					REPLACE(
					REPLACE(
					REPLACE(
					REPLACE(@Keyword, N'\', N'\\'),
					N'[', N'\['),
					N'%', N'\%'),
					N'_', N'\_');

				DECLARE @KeywordLikeAny as nvarchar(324) = N'%' + @KeywordEscaped + N'%';
				DECLARE @KeywordLikePrefix as nvarchar(322) = @KeywordEscaped + N'%';

				SET @sql = N'
				INSERT INTO tblKartrisSearchHelper
				SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
							dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID), 0, 100/LE_FieldID, @KeywordParam
				FROM       tblKartrisLanguageElements 
				WHERE	LE_LanguageID = @LangIdParam AND ' + @DataToSearch + N'
						AND (	(LE_Value LIKE @SearchLikeAnyParam ESCAPE N''\'')
							 OR	(LE_Value LIKE @ExactLikeAnyParam ESCAPE N''\'')
							)';

				SET @params = N'@LangIdParam tinyint, @SearchLikeAnyParam nvarchar(1024), @ExactLikeAnyParam nvarchar(1024), @KeywordParam nvarchar(150)';

				EXEC sys.sp_executesql
					@stmt = @sql,
					@params = @params,
					@LangIdParam = @LANG_ID,
					@SearchLikeAnyParam = @SearchTextLikeAny,
					@ExactLikeAnyParam = @ExactLikeAny,
					@KeywordParam = @Keyword;

				SET @sql = N'
				INSERT INTO tblKartrisSearchHelper
				SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
							dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID), 0, 100/LE_FieldID, @KeywordParam
				FROM       tblKartrisLanguageElements 
				WHERE	LE_LanguageID = @LangIdParam AND ' + @DataToSearch + N'
						AND (LE_Value LIKE @KeywordLikeAnyParam ESCAPE N''\'')';

				SET @params = N'@LangIdParam tinyint, @KeywordLikeAnyParam nvarchar(324), @KeywordParam nvarchar(150)';

				EXEC sys.sp_executesql
					@stmt = @sql,
					@params = @params,
					@LangIdParam = @LANG_ID,
					@KeywordLikeAnyParam = @KeywordLikeAny,
					@KeywordParam = @Keyword;
					
				SET @sql = N'
				INSERT INTO tblKartrisSearchHelper
				SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, @KeywordParam
				FROM         tblKartrisVersions LEFT OUTER JOIN dbo.vKartrisObjectConfigValues 
					ON V_ID = OCV_ParentID AND OC_Name = N''K:version.extrasku''
				WHERE     (V_Live = 1)
				  AND     (V_CodeNumber LIKE @KeywordLikePrefixParam ESCAPE N''\''
					       OR OCV_Value LIKE @KeywordLikePrefixParam ESCAPE N''\'')';

				SET @params = N'@KeywordLikePrefixParam nvarchar(322), @KeywordParam nvarchar(150)';

				EXEC sys.sp_executesql
					@stmt = @sql,
					@params = @params,
					@KeywordLikePrefixParam = @KeywordLikePrefix,
					@KeywordParam = @Keyword;
			END
		END
	END
	
	IF @MinPrice <> -1 AND @MaxPrice <> -1 BEGIN
		UPDATE tblKartrisSearchHelper
		SET SH_Price = (SELECT PSI_MinPrice FROM tblKartrisProductSearchIndex WHERE PSI_ProductID=SH_ProductID AND SH_SessionID = @@SPID)
		DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID = @@SPID AND SH_Price NOT BETWEEN @MinPrice AND @MaxPrice;
	END

	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID
		AND SH_ProductID NOT IN (SELECT distinct tblKartrisProductCategoryLink.PCAT_ProductID
								 FROM	tblKartrisCategories INNER JOIN tblKartrisProductCategoryLink 
										ON tblKartrisCategories.CAT_ID = tblKartrisProductCategoryLink.PCAT_CategoryID
								 WHERE  tblKartrisCategories.CAT_Live = 1)

	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID 
		AND SH_ProductID IN (	SELECT P_ID 
								FROM dbo.tblKartrisProducts 
								WHERE P_Live = 0 OR (P_CustomerGroupID IS NOT NULL AND P_CustomerGroupID <> @CustomerGroupID)); 

	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID 
		AND SH_ProductID NOT IN (SELECT V_ProductID 
								 FROM dbo.tblKartrisVersions INNER JOIN dbo.tblKartrisProducts ON V_ProductID = P_ID
								 WHERE V_Live = 1 AND (V_CustomerGroupID IS NULL OR V_CustomerGroupID = @CustomerGroupID)); 

	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID AND SH_TypeID = 14 
			AND SH_ParentID IN (SELECT tblKartrisAttributeValues.ATTRIBV_ID
							FROM tblKartrisAttributes INNER JOIN tblKartrisAttributeValues 
							ON tblKartrisAttributes.ATTRIB_ID = tblKartrisAttributeValues.ATTRIBV_AttributeID
							WHERE   tblKartrisAttributes.ATTRIB_ShowSearch = 0);

	IF @Counter > 1 BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (400) 
		WHERE SH_SessionID = @@SPID AND ((SH_TextValue like N'%' + @ExactCriteriaNoNoise + N'%') OR (SH_TextValue like N'%' + @SearchText + N'%'));
	END
	
	IF @NoOfVersions > 100000 BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30) WHERE SH_SessionID = @@SPID AND SH_FieldID = 2;
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (200) WHERE SH_SessionID = @@SPID AND SH_FieldID IN (1, 5);
	END	ELSE BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30 * SH_TypeID) WHERE SH_SessionID = @@SPID AND SH_TypeID IN (1, 2);
	END
	
	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;	

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
				PSI_MinPrice as MinPrice, TotalScore
		FROM SearchResult INNER JOIN dbo.vKartrisTypeProducts ON SearchResult.ProductID = dbo.vKartrisTypeProducts.P_ID
		WHERE vKartrisTypeProducts.LANG_ID = @LANG_ID AND ROW BETWEEN @StartRowNumber AND @EndRowNumber
		GROUP BY Row, P_ID, P_Name, P_Desc, PSI_MinPrice, TotalScore
		ORDER BY TotalScore DESC
	END
	
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
	
	DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID=@@SPID;
END;
GO

IF OBJECT_ID(N'[dbo].[spKartrisDB_SearchFTS]', N'P') IS NULL
BEGIN
    EXEC sys.sp_executesql N'CREATE PROCEDURE [dbo].[spKartrisDB_SearchFTS] AS SET NOCOUNT ON;';
END;
GO

ALTER PROCEDURE [dbo].[spKartrisDB_SearchFTS]
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
	SET @SearchText = ISNULL(@SearchText, N'');
	SET @keyWordsList = ISNULL(@keyWordsList, N'');
	
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @Keyword as nvarchar(150);
	DECLARE @Counter as int;
	
	DECLARE @NoOfVersions as bigint;
	SELECT @NoOfVersions = Count(1) FROM tblKartrisVersions;
	
	DECLARE @DataToSearch as nvarchar(100);
	IF @NoOfVersions > 100000 BEGIN
		SET @DataToSearch = N'(LE_TypeID IN (2,14) AND LE_FieldID IN (1,2,5))'
	END ELSE BEGIN
		SET @DataToSearch = N'(LE_TypeID IN (1,2,14) AND LE_FieldID IN (1,2,5))'
	END
		
	DECLARE @ExactCriteriaNoNoise as nvarchar(500);
	SET @ExactCriteriaNoNoise = LTRIM(RTRIM(Replace(@keyWordsList, ',', ' ')));

	DECLARE @SearchPhraseFTS as nvarchar(1010);
	SET @SearchPhraseFTS = N'"' + REPLACE(@SearchText, N'"', N'""') + N'"';

	DECLARE @ExactPhraseFTS as nvarchar(1010);
	SET @ExactPhraseFTS = N'"' + REPLACE(@ExactCriteriaNoNoise, N'"', N'""') + N'"';

	DECLARE @SearchLikePrefix as nvarchar(1020);
	SET @SearchLikePrefix =
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(@SearchText, N'\', N'\\'),
		N'[', N'\['),
		N'%', N'\%'),
		N'_', N'\_') + N'%';

	DECLARE @sql as nvarchar(max);
	DECLARE @params as nvarchar(max);
	
	IF @Method = 'exact' BEGIN
		SET @sql = N'
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID), 0, 100/LE_FieldID, @KeywordParam
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = @LangIdParam AND ' + @DataToSearch + N'
					AND (	(Contains(LE_Value, @SearchPhraseParam))
						 OR	(Contains(LE_Value, @ExactPhraseParam))
						)';

		SET @params = N'@LangIdParam tinyint, @SearchPhraseParam nvarchar(1010), @ExactPhraseParam nvarchar(1010), @KeywordParam nvarchar(150)';

		EXEC sys.sp_executesql
			@stmt = @sql,
			@params = @params,
			@LangIdParam = @LANG_ID,
			@SearchPhraseParam = @SearchPhraseFTS,
			@ExactPhraseParam = @ExactPhraseFTS,
			@KeywordParam = @ExactCriteriaNoNoise;
						
		SET @sql = N'
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, @ExactCriteriaParam
		FROM         tblKartrisVersions LEFT OUTER JOIN dbo.vKartrisObjectConfigValues 
			ON V_ID = OCV_ParentID AND OC_Name = N''K:version.extrasku''
		WHERE     (V_Live = 1)
		  AND     (V_CodeNumber LIKE @LikePrefixParam ESCAPE N''\''
			       OR OCV_Value LIKE @LikePrefixParam ESCAPE N''\'')';

		SET @params = N'@LikePrefixParam nvarchar(1020), @ExactCriteriaParam nvarchar(500)';

		EXEC sys.sp_executesql
			@stmt = @sql,
			@params = @params,
			@LikePrefixParam = @SearchLikePrefix,
			@ExactCriteriaParam = @ExactCriteriaNoNoise;
	END ELSE BEGIN
		SET @SIndx = 1; SET @Counter = 0;
		WHILE @SIndx <= LEN(@keyWordsList) BEGIN
			SET @Counter = @Counter + 1;
			SET @CIndx = CHARINDEX(',', @keyWordsList, @SIndx);
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList) + 1 END
			SET @Keyword = LTRIM(RTRIM(SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)));
			SET @SIndx = @CIndx + 1;

			IF @Keyword <> N'' BEGIN
				DECLARE @KeywordLikePrefix as nvarchar(320);
				SET @KeywordLikePrefix =
					REPLACE(
					REPLACE(
					REPLACE(
					REPLACE(@Keyword, N'\', N'\\'),
					N'[', N'\['),
					N'%', N'\%'),
					N'_', N'\_') + N'%';

				SET @sql = N'
				INSERT INTO tblKartrisSearchHelper
				SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
							dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID), 0, 100/LE_FieldID, @KeywordParam
				FROM       tblKartrisLanguageElements 
				WHERE	LE_LanguageID = @LangIdParam AND ' + @DataToSearch + N'
						AND (	(Contains(LE_Value, @SearchPhraseParam))
							 OR	(Contains(LE_Value, @ExactPhraseParam))
							)';

				SET @params = N'@LangIdParam tinyint, @SearchPhraseParam nvarchar(1010), @ExactPhraseParam nvarchar(1010), @KeywordParam nvarchar(150)';

				EXEC sys.sp_executesql
					@stmt = @sql,
					@params = @params,
					@LangIdParam = @LANG_ID,
					@SearchPhraseParam = @SearchPhraseFTS,
					@ExactPhraseParam = @ExactPhraseFTS,
					@KeywordParam = @Keyword;

				SET @sql = N'
				INSERT INTO tblKartrisSearchHelper
				SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
							dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID), 0, 100/LE_FieldID, @KeywordParam
				FROM       tblKartrisLanguageElements 
				WHERE	LE_LanguageID = @LangIdParam AND ' + @DataToSearch + N'
						AND (Contains(LE_Value, @KeywordParam))';

				SET @params = N'@LangIdParam tinyint, @KeywordParam nvarchar(150)';

				EXEC sys.sp_executesql
					@stmt = @sql,
					@params = @params,
					@LangIdParam = @LANG_ID,
					@KeywordParam = @Keyword;
					
				SET @sql = N'
				INSERT INTO tblKartrisSearchHelper
				SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, @KeywordParam
				FROM         tblKartrisVersions LEFT OUTER JOIN dbo.vKartrisObjectConfigValues 
					ON V_ID = OCV_ParentID AND OC_Name = N''K:version.extrasku''
				WHERE     (V_Live = 1)
				  AND     (V_CodeNumber LIKE @KeywordLikeParam ESCAPE N''\''
					       OR OCV_Value LIKE @KeywordLikeParam ESCAPE N''\'')';

				SET @params = N'@KeywordLikeParam nvarchar(320), @KeywordParam nvarchar(150)';

				EXEC sys.sp_executesql
					@stmt = @sql,
					@params = @params,
					@KeywordLikeParam = @KeywordLikePrefix,
					@KeywordParam = @Keyword;
			END
		END
	END
	
	IF @MinPrice <> -1 AND @MaxPrice <> -1 BEGIN
		UPDATE tblKartrisSearchHelper
		SET SH_Price = (SELECT PSI_MinPrice FROM tblKartrisProductSearchIndex WHERE PSI_ProductID=SH_ProductID AND SH_SessionID = @@SPID)
		DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID = @@SPID AND SH_Price NOT BETWEEN @MinPrice AND @MaxPrice;
	END

	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID
		AND SH_ProductID NOT IN (SELECT distinct tblKartrisProductCategoryLink.PCAT_ProductID
								 FROM	tblKartrisCategories INNER JOIN tblKartrisProductCategoryLink 
										ON tblKartrisCategories.CAT_ID = tblKartrisProductCategoryLink.PCAT_CategoryID
								 WHERE  tblKartrisCategories.CAT_Live = 1)

	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID 
		AND SH_ProductID IN (	SELECT P_ID 
								FROM dbo.tblKartrisProducts 
								WHERE P_Live = 0 OR (P_CustomerGroupID IS NOT NULL AND P_CustomerGroupID <> @CustomerGroupID)); 

	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID 
		AND SH_ProductID NOT IN (SELECT V_ProductID 
								 FROM dbo.tblKartrisVersions INNER JOIN dbo.tblKartrisProducts ON V_ProductID = P_ID
								 WHERE V_Live = 1 AND (V_CustomerGroupID IS NULL OR V_CustomerGroupID = @CustomerGroupID)); 

	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID AND SH_TypeID = 14 
			AND SH_ParentID IN (SELECT tblKartrisAttributeValues.ATTRIBV_ID
							FROM tblKartrisAttributes INNER JOIN tblKartrisAttributeValues 
							ON tblKartrisAttributes.ATTRIB_ID = tblKartrisAttributeValues.ATTRIBV_AttributeID
							WHERE   tblKartrisAttributes.ATTRIB_ShowSearch = 0);

	IF @Counter > 1 BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (400) 
		WHERE SH_SessionID = @@SPID AND ((SH_TextValue like N'%' + @ExactCriteriaNoNoise + N'%') OR (SH_TextValue like N'%' + @SearchText + N'%'));
	END
	
	IF @NoOfVersions > 100000 BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30) WHERE SH_SessionID = @@SPID AND SH_FieldID = 2;
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (200) WHERE SH_SessionID = @@SPID AND SH_FieldID IN (1, 5);
	END	ELSE BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30 * SH_TypeID) WHERE SH_SessionID = @@SPID AND SH_TypeID IN (1, 2);
	END
	
	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;	

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
				PSI_MinPrice as MinPrice, TotalScore
		FROM SearchResult INNER JOIN dbo.vKartrisTypeProducts ON SearchResult.ProductID = dbo.vKartrisTypeProducts.P_ID
		WHERE vKartrisTypeProducts.LANG_ID = @LANG_ID AND ROW BETWEEN @StartRowNumber AND @EndRowNumber
		GROUP BY Row, P_ID, P_Name, P_Desc, PSI_MinPrice, TotalScore
		ORDER BY TotalScore DESC
	END
	
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
	
	DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID=@@SPID;
END;
GO



/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='3.4001', CFG_VersionAdded=3.4001 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO

PRINT '-------------------------------------------------------'
PRINT 'That''s all folks! Looks like we reached the end....'
PRINT '-------------------------------------------------------'
