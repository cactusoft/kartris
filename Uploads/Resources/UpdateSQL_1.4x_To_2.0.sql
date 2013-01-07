INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CactuShopName_DEPRECATED], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES (N'frontend.versions.display.showextrasku', NULL, N'n', N's', N'b', N'y|n', N'Whether to show the ''extra sku'' on the version display on the front end.', 2, N'n', 0);
INSERT [dbo].[tblKartrisObjectConfig] ([OC_Name], [OC_ObjectType], [OC_DataType], [OC_DefaultValue], [OC_Description], [OC_MultilineValue], [OC_VersionAdded]) VALUES (N'K:version.extrasku', N'Version', N's', NULL, N'Extra code number for versions (store specific).', 0, 2)
GO

/****** Object:  UserDefinedFunction [dbo].[fnKartrisObjectConfig_GetValueByParent]    Script Date: 11/14/2012 14:15:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisObjectConfig_GetValueByParent] 
(
	@ObjectConfig as nvarchar(100),
	@ParentID as bigint
)
RETURNS nvarchar(max)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(max);
	
	SELECT @Result = OCV_Value
	FROM dbo.tblKartrisObjectConfig INNER JOIN dbo.tblKartrisObjectConfigValue 
		ON OC_ID = OCV_ObjectConfigID
	WHERE OC_Name = @ObjectConfig AND OCV_ParentID = @ParentID;

	-- Return the result of the function
	RETURN @Result

END
GO

/****** Object:  View [dbo].[vKartrisObjectConfigValues]    Script Date: 11/14/2012 14:15:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vKartrisObjectConfigValues]
AS
SELECT     dbo.tblKartrisObjectConfig.OC_ObjectType, dbo.tblKartrisObjectConfigValue.OCV_ParentID, dbo.tblKartrisObjectConfig.OC_Name, 
                      dbo.tblKartrisObjectConfigValue.OCV_Value
FROM         dbo.tblKartrisObjectConfig INNER JOIN
                      dbo.tblKartrisObjectConfigValue ON dbo.tblKartrisObjectConfig.OC_ID = dbo.tblKartrisObjectConfigValue.OCV_ObjectConfigID

GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tblKartrisObjectConfig"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 187
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblKartrisObjectConfigValue"
            Begin Extent = 
               Top = 6
               Left = 252
               Bottom = 123
               Right = 442
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1485
         Width = 1380
         Width = 1755
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisObjectConfigValues'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisObjectConfigValues'
GO

/****** Object:  View [dbo].[vKartrisTypeVersions]    Script Date: 11/14/2012 14:24:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[vKartrisTypeVersions]
AS
SELECT     TOP (100) PERCENT dbo.tblKartrisVersions.V_ID, dbo.tblKartrisLanguages.LANG_ID, dbo.tblKartrisLanguageElements.LE_Value AS V_Name, 
					  tblKartrisLanguageElements_1.LE_Value AS V_Desc, dbo.tblKartrisVersions.V_CodeNumber, dbo.fnKartrisObjectConfig_GetValueByParent(N'K:version.extrasku', 
                      dbo.tblKartrisVersions.V_ID) AS V_ExtraCodeNumber, dbo.tblKartrisVersions.V_ProductID, dbo.tblKartrisVersions.V_Price, 
					  dbo.tblKartrisVersions.V_Tax, dbo.tblKartrisVersions.V_Weight, dbo.tblKartrisVersions.V_DeliveryTime, dbo.tblKartrisVersions.V_Quantity, 
					  dbo.tblKartrisVersions.V_QuantityWarnLevel, dbo.tblKartrisVersions.V_Live, dbo.tblKartrisVersions.V_DownLoadInfo, dbo.tblKartrisVersions.V_DownloadType, 
					  dbo.tblKartrisVersions.V_OrderByValue, dbo.tblKartrisVersions.V_RRP, dbo.tblKartrisVersions.V_Type, dbo.tblKartrisVersions.V_CustomerGroupID, 
					  dbo.tblKartrisVersions.V_CustomizationType, dbo.tblKartrisVersions.V_CustomizationDesc, dbo.tblKartrisVersions.V_CustomizationCost, 
					  dbo.tblKartrisVersions.V_Tax2, dbo.tblKartrisVersions.V_TaxExtra
FROM         dbo.tblKartrisLanguageElements INNER JOIN
					  dbo.tblKartrisVersions ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisVersions.V_ID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_1 ON dbo.tblKartrisVersions.V_ID = tblKartrisLanguageElements_1.LE_ParentID INNER JOIN
					  dbo.tblKartrisLanguages ON dbo.tblKartrisLanguageElements.LE_LanguageID = dbo.tblKartrisLanguages.LANG_ID AND 
					  tblKartrisLanguageElements_1.LE_LanguageID = dbo.tblKartrisLanguages.LANG_ID
WHERE     (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (dbo.tblKartrisLanguageElements.LE_Value IS NOT NULL) 
					  AND (dbo.tblKartrisLanguageElements.LE_TypeID = 1) AND (tblKartrisLanguageElements_1.LE_TypeID = 1) OR
					  (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (dbo.tblKartrisLanguageElements.LE_TypeID = 1) AND 
					  (tblKartrisLanguageElements_1.LE_TypeID = 1) AND (tblKartrisLanguageElements_1.LE_Value IS NOT NULL)

GO

/****** Object:  StoredProcedure [dbo].[_spKartrisDB_SetupFTS]    Script Date: 09/07/2012 18:25:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
	SELECT @kartrisCatalogExist = count(1) FROM sys.fulltext_catalogs WHERE name = ''kartrisCatalog'';
	IF @kartrisCatalogExist = 0 BEGIN CREATE FULLTEXT CATALOG kartrisCatalog END;
	
	EXEC sp_fulltext_table     ''dbo.tblKartrisLanguageElements'', ''create'', ''kartrisCatalog'', ''keyLE_ID''
	EXEC sp_fulltext_column    ''dbo.tblKartrisLanguageElements'', ''LE_Value'', ''add''
	EXEC sp_fulltext_table     ''dbo.tblKartrisLanguageElements'',''activate''

	EXEC sp_fulltext_table     ''dbo.tblKartrisAddresses'', ''create'', ''kartrisCatalog'', ''PK_tblKartrisAddresses''
	EXEC sp_fulltext_column    ''dbo.tblKartrisAddresses'', ''ADR_Name'', ''add''
	EXEC sp_fulltext_table     ''dbo.tblKartrisAddresses'',''activate''

	EXEC sp_fulltext_table     ''dbo.tblKartrisUsers'', ''create'', ''kartrisCatalog'', ''aaaaatblKartrisCustomers_PK''
	EXEC sp_fulltext_column    ''dbo.tblKartrisUsers'', ''U_EmailAddress'', ''add''
	EXEC sp_fulltext_table     ''dbo.tblKartrisUsers'',''activate''

	EXEC sp_fulltext_table     ''dbo.tblKartrisOrders'', ''create'', ''kartrisCatalog'', ''aaaaatblKartrisOrders_PK''
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
		SET @DataToSearch = ''''(LE_TypeID IN (2,14) AND LE_FieldID IN (1,2,5))''''
	END ELSE BEGIN
		SET @DataToSearch = ''''(LE_TypeID IN (1,2,14) AND LE_FieldID IN (1,2,5))''''
	END
		
	DECLARE @ExactCriteriaNoNoise as nvarchar(500);
	SET @ExactCriteriaNoNoise = Replace(@keyWordsList, '''','''', '''' '''');
	
	IF @Method = ''''exact'''' BEGIN
		-- Searching value of LanguageElements - Add results to search helper (LIKE Operator)
		EXECUTE(''''
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, '''''''''''' + @KeyWord + ''''''''''''
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = '''' + @LANG_ID +'''' AND '''' + @DataToSearch + ''''
					AND (	(Contains(LE_Value, ''''''''"'''' + @SearchText + ''''"''''''''))
						 OR	(Contains(LE_Value, ''''''''"'''' + @ExactCriteriaNoNoise + ''''"''''''''))
						)'''');
						
		-- Searching version code of Versions - Add results to search helper				
		EXECUTE(''''
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, '''''''''''' + @ExactCriteriaNoNoise + ''''''''''''
		FROM         tblKartrisVersions
		WHERE     (V_Live = 1) AND (V_CodeNumber LIKE '''''''''''' + @SearchText + ''''%'''''''')'''' );	
	END ELSE BEGIN
		-- Loop through out the list of keywords and search each keyword
		SET @SIndx = 0; SET @Counter = 0;
		WHILE @SIndx <= LEN(@keyWordsList) BEGIN
			SET @Counter = @Counter + 1;	-- keywords counter
			SET @CIndx = CHARINDEX('''','''', @keyWordsList, @SIndx)	-- Next keyword starting index (1-Based Index)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+ 1 END	-- If no more keywords, set next starting index to not exist
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			
			SET @SIndx = @CIndx + 1;	-- The next starting index
				
			
			-- Searching value of LanguageElements - Add results to search helper (LIKE Operator)
			EXECUTE(''''
			INSERT INTO tblKartrisSearchHelper
			SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
						dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, '''''''''''' + @KeyWord + ''''''''''''
			FROM       tblKartrisLanguageElements 
			WHERE	LE_LanguageID = '''' + @LANG_ID +'''' AND '''' + @DataToSearch + '''' AND (Contains(LE_Value, '''''''''''' + @KeyWord + '''''''''''')) '''');
				
			-- Searching version code of Versions - Add results to search helper				
			EXECUTE(''''
			INSERT INTO tblKartrisSearchHelper
			SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, '''''''''''' + @KeyWord + ''''''''''''
			FROM         tblKartrisVersions
			WHERE     (V_Live = 1) AND (V_CodeNumber LIKE '''''''''''' + @Keyword + ''''%'''''''')'''' );
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
	WHERE SH_SessionID = @@SPID AND SH_ProductID IN (SELECT P_ID 
													 FROM dbo.tblKartrisProducts 
													 WHERE P_Live = 0 
														OR (P_CustomerGroupID IS NOT NULL AND P_CustomerGroupID <> @CustomerGroupID)); 
	
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
		WHERE SH_SessionID = @@SPID AND ((SH_TextValue like ''''%'''' + @ExactCriteriaNoNoise + ''''%'''') OR (SH_TextValue like ''''%'''' + @SearchText + ''''%''''));
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

	-- Search method ''''ANY'''' - Default Search and ''''EXACT'''' - Advanced Search
	IF @Method = ''''any'''' OR @Method = ''''exact'''' BEGIN
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
	
	-- Search method ''''ALL'''' - Advanced Search
	IF @Method = ''''all'''' BEGIN
	
		DECLARE @SortedSearchKeywords as nvarchar(max);
		SELECT @SortedSearchKeywords = COALESCE(@SortedSearchKeywords + '''','''', '''''''') + T._ID
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
					AND LE_ParentID IN (SELECT V_ID FROM tblKartrisVersions WHERE V_CodeNumber LIKE @KeyWord + ''''%'''');

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
	
	--============== Custom Pages =======================
	IF @searchLocation = ''''pages''''
	BEGIN
		CREATE TABLE #_CustomPagesSearchTbl(PageID smallint, PageName nvarchar(50))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX('''','''', @keyWordsList, @SIndx)
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
''
END
		
END

' 
GO

/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetByProductID]    Script Date: 11/14/2012 14:25:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
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

	DECLARE @USMultistateisused as char(1);
	SELECT @USMultistateisused = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = 'general.tax.usmultistatetax';

	IF @USMultistateisused = 'n' -- TaxRates shouldn't be NULL
	BEGIN
		SELECT     vKartrisTypeVersions.V_ID, tblKartrisTaxRates.T_Taxrate, vKartrisTypeVersions.V_Price, vKartrisTypeVersions.V_Weight, vKartrisTypeVersions.V_RRP, 
					  vKartrisTypeVersions.V_Tax, tblKartrisTaxRates.T_Taxrate AS Expr1, '0' AS CalculatedTax, vKartrisTypeVersions.V_ProductID, vKartrisTypeVersions.V_CodeNumber, 
					  vKartrisTypeVersions.V_ExtraCodeNumber, vKartrisTypeVersions.V_Quantity, vKartrisTypeVersions.V_QuantityWarnLevel, vKartrisTypeVersions.V_Price AS OrderByBit, 
					  vKartrisTypeVersions.V_Name, vKartrisTypeVersions.V_Desc, MIN(tblKartrisQuantityDiscounts.QD_Price) AS QuantityDiscount, vKartrisTypeVersions.V_OrderByValue, 
					  vKartrisTypeVersions.V_CustomizationType, vKartrisTypeVersions.V_CustomizationDesc, vKartrisTypeVersions.V_CustomizationCost
		FROM         vKartrisTypeVersions INNER JOIN
							  tblKartrisTaxRates ON vKartrisTypeVersions.V_Tax = tblKartrisTaxRates.T_ID LEFT OUTER JOIN
							  tblKartrisQuantityDiscounts ON vKartrisTypeVersions.V_ID = tblKartrisQuantityDiscounts.QD_VersionID
		WHERE     (vKartrisTypeVersions.LANG_ID = @LANG_ID) AND (vKartrisTypeVersions.V_ProductID = @P_ID) AND (vKartrisTypeVersions.V_Live = 1)
				AND (vKartrisTypeVersions.V_CustomerGroupID IS NULL OR vKartrisTypeVersions.V_CustomerGroupID = @CGroupID)
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
	ELSE	-- Versions' TaxRate could be NULL.
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

GO

/****** Object:  StoredProcedure [dbo].[spKartrisDB_Search]    Script Date: 11/14/2012 14:27:52 ******/
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

/****** Object:  StoredProcedure [dbo].[_spKartrisDB_AdminSearch]    Script Date: 11/14/2012 14:28:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
 ALTER PROCEDURE [dbo].[_spKartrisDB_AdminSearch]
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
	IF @searchLocation = 'products' BEGIN SET @TypeNo = 2 END
	IF @searchLocation = 'categories' BEGIN SET @TypeNo = 3 END
	
	--================ PRODUCTS/CATEGORIES ==================
	IF @searchLocation = 'products' OR @searchLocation = 'categories'
	BEGIN
			CREATE TABLE #_ProdCatSearchTbl(ItemID nvarchar(255), ItemValue nvarchar(MAX))
			WHILE @SIndx <= LEN(@keyWordsList)
			BEGIN
				
				SET @CIndx = CHARINDEX(',', @keyWordsList, @SIndx)
				IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
				SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
				SET @SIndx = @CIndx + 1;
				INSERT INTO #_ProdCatSearchTbl (ItemID,ItemValue)
				SELECT     CAST(LE_ParentID as nvarchar(255)), LE_Value
				FROM		tblKartrisLanguageElements
				WHERE     (LE_LanguageID = @LANG_ID) AND (LE_TypeID = @TypeNo) AND (LE_FieldID = 1) AND LE_Value LIKE '%' + @KeyWord + '%';
			END

			SELECT @TotalResult =  Count(ItemID) FROM #_ProdCatSearchTbl;

			SELECT     ItemID, ItemValue
			FROM         #_ProdCatSearchTbl
			
			DROP TABLE #_ProdCatSearchTbl;
		END

	--================ VERSIONS ==================
	IF @searchLocation = 'versions'
	BEGIN
		CREATE TABLE #_VersionSearchTbl(VersionID nvarchar(255), VersionName nvarchar(MAX), VersionCode nvarchar(25), ProductID nvarchar(255))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX(',', @keyWordsList, @SIndx)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			SET @SIndx = @CIndx + 1;
			INSERT INTO #_VersionSearchTbl (VersionID, VersionName, VersionCode, ProductID)
			SELECT     CAST(LE_ParentID as nvarchar(255)), LE_Value, dbo.fnKartrisVersions_GetCodeNumber(LE_ParentID),
						CAST(dbo.fnKartrisVersions_GetProductID(LE_ParentID) as nvarchar(255))
			FROM		tblKartrisLanguageElements
			WHERE     (LE_LanguageID = @LANG_ID) AND (LE_TypeID = 1) AND (LE_FieldID = 1) AND LE_Value LIKE '%' + @KeyWord + '%';

			-- SEARCH FOR THE CODE NUMBER
			INSERT INTO #_VersionSearchTbl (VersionID, VersionName, VersionCode, ProductID)
			SELECT     CAST(LE_ParentID as nvarchar(255)), LE_Value, dbo.fnKartrisVersions_GetCodeNumber(LE_ParentID),
						CAST(dbo.fnKartrisVersions_GetProductID(LE_ParentID) as nvarchar(255))
			FROM		tblKartrisLanguageElements
			WHERE     (LE_LanguageID = @LANG_ID) AND (LE_TypeID = 1) AND (LE_FieldID = 1) 
					AND LE_ParentID 
						IN (SELECT V_ID 
							FROM tblKartrisVersions LEFT OUTER JOIN dbo.vKartrisObjectConfigValues 
								ON V_ID = OCV_ParentID AND OC_Name = 'K:version.extrasku'
							WHERE V_CodeNumber Like '%' + @KeyWord + '%' OR OCV_Value LIKE '%' + @Keyword + '%');

		END

		SELECT @TotalResult =  Count(VersionID) FROM #_VersionSearchTbl;
		
		SELECT     VersionID, VersionName, VersionCode, ProductID
		FROM         #_VersionSearchTbl
		DROP TABLE #_VersionSearchTbl;
	END

	--================ CUSTOMERS ==================
	IF @searchLocation = 'customers'
	BEGIN
			
			CREATE TABLE #_CustomerSearchTbl(CustomerID nvarchar(255), CustomerName nvarchar(50), CustomerEmail nvarchar(100))
			WHILE @SIndx <= LEN(@keyWordsList)
			BEGIN
				
				SET @CIndx = CHARINDEX(',', @keyWordsList, @SIndx)
				IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
				SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
				SET @SIndx = @CIndx + 1;

				INSERT INTO #_CustomerSearchTbl (CustomerID, CustomerName, CustomerEmail)
				SELECT     tblKartrisUsers.U_ID, tblKartrisAddresses.ADR_Name, tblKartrisUsers.U_EmailAddress
				FROM         tblKartrisAddresses RIGHT OUTER JOIN
									  tblKartrisUsers ON tblKartrisAddresses.ADR_ID = tblKartrisUsers.U_DefBillingAddressID
				WHERE     (tblKartrisAddresses.ADR_Name LIKE '%' + @KeyWord + '%') OR
						(tblKartrisUsers.U_EmailAddress LIKE '%' + @KeyWord + '%');

			END

			SELECT @TotalResult =  Count(CustomerID) FROM #_CustomerSearchTbl;

			SELECT     CustomerID, CustomerName, CustomerEmail
			FROM         #_CustomerSearchTbl
			
			DROP TABLE #_CustomerSearchTbl;
		END

		--================ ORDERS ==================
		IF @searchLocation = 'orders'
		BEGIN
			CREATE TABLE #_OrdersSearchTbl(OrderID int, PurchaseOrderNumber nvarchar(50))
			WHILE @SIndx <= LEN(@keyWordsList)
			BEGIN
				
				SET @CIndx = CHARINDEX(',', @keyWordsList, @SIndx)
				IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
				SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
				SET @SIndx = @CIndx + 1;

				INSERT INTO #_OrdersSearchTbl (OrderID, PurchaseOrderNumber)
				SELECT     tblKartrisOrders.O_ID, tblKartrisOrders.O_PurchaseOrderNo
				FROM         tblKartrisOrders 
				WHERE     (tblKartrisOrders.O_PurchaseOrderNo LIKE '%' + @KeyWord + '%');

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
	IF @searchLocation = 'config'
	BEGIN
			
		CREATE TABLE #_ConfigSearchTbl(ConfigName nvarchar(100), ConfigValue nvarchar(255))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX(',', @keyWordsList, @SIndx)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			SET @SIndx = @CIndx + 1;

			INSERT INTO #_ConfigSearchTbl (ConfigName, ConfigValue)
			SELECT     tblKartrisConfig.CFG_Name, tblKartrisConfig.CFG_Value
			FROM         tblKartrisConfig 
			WHERE     (tblKartrisConfig.CFG_Name LIKE '%' + @KeyWord + '%') 
					OR (tblKartrisConfig.CFG_Value LIKE '%' + @KeyWord + '%') ;

		END

		SELECT @TotalResult =  Count(ConfigName) FROM #_ConfigSearchTbl;

		SELECT     ConfigName, ConfigValue
		FROM         #_ConfigSearchTbl
		
		DROP TABLE #_ConfigSearchTbl;
	END

	--================ LS ==================
	IF @searchLocation = 'site'
	BEGIN
			
		CREATE TABLE #_LSSearchTbl(LSFB char(1), LSLang tinyint, LSName nvarchar(255), LSValue nvarchar(MAX), LSClass nvarchar(50))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX(',', @keyWordsList, @SIndx)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			SET @SIndx = @CIndx + 1;

			INSERT INTO #_LSSearchTbl (LSFB, LSLang, LSName, LSValue, LSClass)
			SELECT     tblKartrisLanguageStrings.LS_FrontBack, tblKartrisLanguageStrings.LS_LangID,
						tblKartrisLanguageStrings.LS_Name, tblKartrisLanguageStrings.LS_Value, tblKartrisLanguageStrings.LS_ClassName
			FROM         tblKartrisLanguageStrings 
			WHERE     tblKartrisLanguageStrings.LS_LangID = @LANG_ID AND((tblKartrisLanguageStrings.LS_Name LIKE '%' + @KeyWord + '%') OR
						(tblKartrisLanguageStrings.LS_Value LIKE '%' + @KeyWord + '%'));

		END

		SELECT @TotalResult =  Count(LSName) FROM #_LSSearchTbl;
		
		SELECT     LSFB, LSLang, LSName, LSValue, LSClass
		FROM         #_LSSearchTbl
		
		DROP TABLE #_LSSearchTbl;
	END


	--============== Custom Pages =======================
	IF @searchLocation = 'pages'
	BEGIN
		CREATE TABLE #_CustomPagesSearchTbl(PageID smallint, PageName nvarchar(50))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX(',', @keyWordsList, @SIndx)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			SET @SIndx = @CIndx + 1;
			
			INSERT INTO #_CustomPagesSearchTbl (PageID, PageName)
			SELECT DISTINCT LE_ParentID, PAGE_Name
			FROM dbo.tblKartrisLanguageElements INNER JOIN dbo.tblKartrisPages
				ON tblKartrisLanguageElements.LE_ParentID = tblKartrisPages.PAGE_ID
			WHERE (LE_LanguageID = @LANG_ID) AND (LE_TypeID = 8) AND (LE_Value LIKE '%' + @KeyWord + '%');
			
		END

		SELECT @TotalResult =  Count(DISTINCT PageID) FROM #_CustomPagesSearchTbl;
		

		SELECT  DISTINCT PageID, PageName
		FROM         #_CustomPagesSearchTbl
		DROP TABLE #_CustomPagesSearchTbl;
	END
END



GO

/****** Object:  StoredProcedure [dbo].[_spKartrisDB_AdminSearchFTS]    Script Date: 11/14/2012 14:38:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_AdminSearchFTS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisDB_AdminSearchFTS]
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
GO

/****** Object:  StoredProcedure [dbo].[spKartrisDB_SearchFTS]    Script Date: 11/14/2012 14:38:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
	WHERE SH_SessionID = @@SPID AND SH_ProductID IN (SELECT P_ID 
													 FROM dbo.tblKartrisProducts 
													 WHERE P_Live = 0 
														OR (P_CustomerGroupID IS NOT NULL AND P_CustomerGroupID <> @CustomerGroupID)); 
	
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
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tblKartrisCurrencies
	DROP CONSTRAINT DF__tblKartris__CUR_E__72C60C4A
GO
ALTER TABLE dbo.tblKartrisCurrencies
	DROP CONSTRAINT DF_tblKartrisCurrencies_CUR_RoundNumbers
GO
CREATE TABLE dbo.Tmp_tblKartrisCurrencies
	(
	CUR_ID tinyint NOT NULL IDENTITY (1, 1),
	CUR_Symbol nvarchar(5) NOT NULL,
	CUR_ISOCode nvarchar(3) NOT NULL,
	CUR_ISOCodeNumeric nvarchar(3) NULL,
	CUR_ExchangeRate real NULL,
	CUR_HasDecimals bit NOT NULL,
	CUR_Live bit NOT NULL,
	CUR_Format nvarchar(20) NOT NULL,
	CUR_IsoFormat nvarchar(20) NOT NULL,
	CUR_DecimalPoint char(1) NULL,
	CUR_RoundNumbers tinyint NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_tblKartrisCurrencies SET (LOCK_ESCALATION = TABLE)
GO
ALTER TABLE dbo.Tmp_tblKartrisCurrencies ADD CONSTRAINT
	DF__tblKartris__CUR_E__72C60C4A DEFAULT ((0)) FOR CUR_ExchangeRate
GO
ALTER TABLE dbo.Tmp_tblKartrisCurrencies ADD CONSTRAINT
	DF_tblKartrisCurrencies_CUR_RoundNumbers DEFAULT ((0)) FOR CUR_RoundNumbers
GO
SET IDENTITY_INSERT dbo.Tmp_tblKartrisCurrencies ON
GO
IF EXISTS(SELECT * FROM dbo.tblKartrisCurrencies)
	 EXEC('INSERT INTO dbo.Tmp_tblKartrisCurrencies (CUR_ID, CUR_Symbol, CUR_ISOCode, CUR_ISOCodeNumeric, CUR_ExchangeRate, CUR_HasDecimals, CUR_Live, CUR_Format, CUR_IsoFormat, CUR_DecimalPoint, CUR_RoundNumbers)
		SELECT CUR_ID, CUR_Symbol, CUR_ISOCode, CONVERT(nvarchar(3), CUR_ISOCodeNumeric), CUR_ExchangeRate, CUR_HasDecimals, CUR_Live, CUR_Format, CUR_IsoFormat, CUR_DecimalPoint, CUR_RoundNumbers FROM dbo.tblKartrisCurrencies WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_tblKartrisCurrencies OFF
GO
DROP TABLE dbo.tblKartrisCurrencies
GO
EXECUTE sp_rename N'dbo.Tmp_tblKartrisCurrencies', N'tblKartrisCurrencies', 'OBJECT' 
GO
ALTER TABLE dbo.tblKartrisCurrencies ADD CONSTRAINT
	aaaaatblKartrisCurrencies_PK PRIMARY KEY NONCLUSTERED 
	(
	CUR_ID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
CREATE UNIQUE CLUSTERED INDEX idxCUR_ID ON dbo.tblKartrisCurrencies
	(
	CUR_ID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE dbo.tblKartrisCurrencies ADD CONSTRAINT
	Symbol_unique UNIQUE NONCLUSTERED 
	(
	CUR_Symbol
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.tblKartrisCurrencies ADD CONSTRAINT
	ISOCode_unique UNIQUE NONCLUSTERED 
	(
	CUR_ISOCode
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX CUR_ID ON dbo.tblKartrisCurrencies
	(
	CUR_ID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX CUR_IsoCode ON dbo.tblKartrisCurrencies
	(
	CUR_ISOCode
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE dbo.tblKartrisCurrencies ADD CONSTRAINT
	CK_Currencies_DecimalPointValidation CHECK (([CUR_DecimalPoint]='.' OR [CUR_DecimalPoint]=','))
GO
DECLARE @v sql_variant 
SET @v = N'CUR_DecimalPoint column valid values are ''.'' & '','''
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'tblKartrisCurrencies', N'CONSTRAINT', N'CK_Currencies_DecimalPointValidation'
GO
ALTER TABLE dbo.tblKartrisCurrencies ADD CONSTRAINT
	CK_Currencies_ExchangeRateValidation CHECK (([CUR_ExchangeRate]>(0)))
GO
DECLARE @v sql_variant 
SET @v = N'CUR_ExchangeRate should be a positive number'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'tblKartrisCurrencies', N'CONSTRAINT', N'CK_Currencies_ExchangeRateValidation'
GO
ALTER TABLE dbo.tblKartrisCurrencies ADD CONSTRAINT
	CK_Currencies_RoundNumbers CHECK (([CUR_RoundNumbers]>=(0) AND [CUR_RoundNumbers]<=(5)))
GO
DECLARE @v sql_variant 
SET @v = N'CUR_RoundNumbers column validation range between 0 & 5'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'tblKartrisCurrencies', N'CONSTRAINT', N'CK_Currencies_RoundNumbers'
GO
COMMIT
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisCurrencies_Add]    Script Date: 11/19/2012 21:50:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisCurrencies_Add]
(
	@CUR_Symbol nvarchar(5),
	@CUR_ISOCode nvarchar(10),
	@CUR_ISOCodeNumeric nvarchar(10),
	@CUR_ExchangeRate real,
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

	INSERT INTO [tblKartrisCurrencies] 
	([CUR_Symbol], [CUR_ISOCode], [CUR_ISOCodeNumeric], [CUR_ExchangeRate], [CUR_HasDecimals], [CUR_Live], 
	[CUR_Format], [CUR_IsoFormat], [CUR_DecimalPoint], [CUR_RoundNumbers]) 
	VALUES (@CUR_Symbol, @CUR_ISOCode, @CUR_ISOCodeNumeric, @CUR_ExchangeRate, @CUR_HasDecimals, @CUR_Live, 
	@CUR_Format, @CUR_IsoFormat, @CUR_DecimalPoint, @CUR_RoundNumbers);
	
	SELECT @CUR_NewID = SCOPE_IDENTITY();
	
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCurrencies_Update]    Script Date: 11/19/2012 21:51:37 ******/
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
	@CUR_ExchangeRate real,
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
	
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tblKartrisDestination
	DROP CONSTRAINT FK_tblKartrisDestination_tblKartrisShippingZones
GO
ALTER TABLE dbo.tblKartrisShippingZones SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tblKartrisDestination
	DROP CONSTRAINT DF__tblKartris__D_Shi__534D60F1
GO
ALTER TABLE dbo.tblKartrisDestination
	DROP CONSTRAINT DF__tblKartris__D_Tax__5441852A
GO
CREATE TABLE dbo.Tmp_tblKartrisDestination
	(
	D_ID smallint NOT NULL IDENTITY (1, 1),
	D_ShippingZoneID tinyint NULL,
	D_Tax real NULL,
	D_ISOCode char(2) NULL,
	D_ISOCode3Letter char(3) NULL,
	D_ISOCodeNumeric nvarchar(3) NULL,
	D_Region nvarchar(30) NULL,
	D_Live bit NOT NULL,
	D_Tax2 real NULL,
	D_TaxExtra nvarchar(25) NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_tblKartrisDestination SET (LOCK_ESCALATION = TABLE)
GO
ALTER TABLE dbo.Tmp_tblKartrisDestination ADD CONSTRAINT
	DF__tblKartris__D_Shi__534D60F1 DEFAULT ((0)) FOR D_ShippingZoneID
GO
ALTER TABLE dbo.Tmp_tblKartrisDestination ADD CONSTRAINT
	DF__tblKartris__D_Tax__5441852A DEFAULT ((0)) FOR D_Tax
GO
SET IDENTITY_INSERT dbo.Tmp_tblKartrisDestination ON
GO
IF EXISTS(SELECT * FROM dbo.tblKartrisDestination)
	 EXEC('INSERT INTO dbo.Tmp_tblKartrisDestination (D_ID, D_ShippingZoneID, D_Tax, D_ISOCode, D_ISOCode3Letter, D_ISOCodeNumeric, D_Region, D_Live, D_Tax2, D_TaxExtra)
		SELECT D_ID, D_ShippingZoneID, D_Tax, D_ISOCode, D_ISOCode3Letter, CONVERT(nvarchar(3), D_ISOCodeNumeric), D_Region, D_Live, D_Tax2, D_TaxExtra FROM dbo.tblKartrisDestination WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_tblKartrisDestination OFF
GO
DROP TABLE dbo.tblKartrisDestination
GO
EXECUTE sp_rename N'dbo.Tmp_tblKartrisDestination', N'tblKartrisDestination', 'OBJECT' 
GO
ALTER TABLE dbo.tblKartrisDestination ADD CONSTRAINT
	PK_tblKartrisDestination PRIMARY KEY CLUSTERED 
	(
	D_ID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX D_ID ON dbo.tblKartrisDestination
	(
	D_ID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX D_ISOCode ON dbo.tblKartrisDestination
	(
	D_ISOCode
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE dbo.tblKartrisDestination ADD CONSTRAINT
	CK_Destination_Tax CHECK (([D_Tax]>=(0)))
GO
DECLARE @v sql_variant 
SET @v = N'D_Tax should be positive'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'tblKartrisDestination', N'CONSTRAINT', N'CK_Destination_Tax'
GO
ALTER TABLE dbo.tblKartrisDestination ADD CONSTRAINT
	FK_tblKartrisDestination_tblKartrisShippingZones FOREIGN KEY
	(
	D_ShippingZoneID
	) REFERENCES dbo.tblKartrisShippingZones
	(
	SZ_ID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDestinations_Update]    Script Date: 11/19/2012 21:55:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get Shipping Methods - by Destination and Boundary
-- ===============================================================
ALTER PROCEDURE [dbo].[_spKartrisDestinations_Update]
(
	@D_ID as smallint,
	@D_ShippingZoneID as tinyint,
	@D_Tax as real,
	@D_Tax2 as real,
	@D_ISOCode as char(2),
	@D_ISOCode3Letter as char(3),
	@D_ISOCodeNumeric as nvarchar(3),
	@D_Region as nvarchar(30),
	@D_Live as bit,
	@D_TaxExtra as nvarchar(25)
)
AS
BEGIN
	SET NOCOUNT ON;


	UPDATE dbo.tblKartrisDestination
	SET D_ShippingZoneID = @D_ShippingZoneID, D_Tax = @D_Tax, D_Tax2 = @D_Tax2, D_ISOCode = @D_ISOCode,
		D_ISOCode3Letter = @D_ISOCode3Letter, D_ISOCodeNumeric = @D_ISOCodeNumeric, D_Region = @D_Region, D_TaxExtra = @D_TaxExtra, D_Live = @D_Live
	WHERE D_ID = @D_ID;

	

END
GO
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tblKartrisCurrencies
	DROP CONSTRAINT Symbol_unique
GO
ALTER TABLE dbo.tblKartrisCurrencies SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tblKartrisSupportTickets ADD
	TIC_Tags nvarchar(200) NULL
GO
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_SearchTags', N'Search Tags', NULL, 2, N'Search Tags', NULL, N'_Tickets', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_ThisCustomerTickets', N'This customer''s recent tickets', NULL, 2, N'This customer''s recent tickets', NULL, N'_Tickets', 1)
GO
ALTER TABLE dbo.tblKartrisSupportTickets SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisSupportTickets_GetDetailsByID]
(
	@TIC_ID as bigint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     tblKartrisSupportTickets.TIC_ID, tblKartrisSupportTickets.TIC_DateOpened, tblKartrisSupportTickets.TIC_DateClosed, tblKartrisSupportTickets.TIC_Subject, 
					  tblKartrisSupportTickets.TIC_UserID, tblKartrisSupportTickets.TIC_LoginID, tblKartrisSupportTickets.TIC_SupportTicketTypeID, tblKartrisSupportTicketTypes.STT_Name, 
					  tblKartrisSupportTickets.TIC_Status, tblKartrisSupportTickets.TIC_TimeSpent, tblKartrisSupportTickets.TIC_Tags
FROM         tblKartrisSupportTickets LEFT OUTER JOIN
					  tblKartrisSupportTicketTypes ON tblKartrisSupportTickets.TIC_SupportTicketTypeID = tblKartrisSupportTicketTypes.STT_ID
WHERE     (tblKartrisSupportTickets.TIC_ID = @TIC_ID)
END
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisSupportTickets_Update]
(
	@TIC_ID as bigint,
	@LOGIN_ID as smallint,
	@NowOffset as datetime,
	@TIC_Status as char,
	@TIC_TimeSpent as int,
	@TIC_Tags as nvarchar(200),
	@STT_ID as smallint
)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @TIC_Status <> 'c' BEGIN SET @NowOffset = NULL END;
		

	UPDATE    tblKartrisSupportTickets
	SET TIC_LoginID = @LOGIN_ID, TIC_SupportTicketTypeID = @STT_ID, TIC_Status = @TIC_Status,
		TIC_DateClosed = @NowOffset, TIC_TimeSpent = @TIC_TimeSpent, TIC_Tags = @TIC_Tags
	WHERE TIC_ID = @TIC_ID;

END
GO
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

	INSERT INTO dbo.tblKartrisSupportTickets
	VALUES (@OpenedDate, NULL, @Subject, @U_ID, 0, @TicketType, 'o', 0, NULL);


	SELECT @TIC_NewID  = SCOPE_IDENTITY();
	
	IF @TIC_NewID IS NOT NULL
	BEGIN
	
		INSERT INTO dbo.tblKartrisSupportTicketMessages
		VALUES	(@TIC_NewID, 0, @OpenedDate, @Text);
	
	END
	
END
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisSupportTickets_Search]
(
	@Keyword as nvarchar(100),
	@LangID as smallint,
	@AssignedID as smallint,
	@TypeID as smallint,
	@UserID as int,
	@UserEmail as nvarchar(50),
	@Status as char(1)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Cmd as nvarchar(MAX);
	SET @Cmd =
	'SELECT DISTINCT tblKartrisSupportTickets.TIC_ID, tblKartrisSupportTickets.TIC_DateOpened, 
			tblKartrisSupportTickets.TIC_DateClosed, tblKartrisSupportTickets.TIC_Subject, 
			tblKartrisSupportTickets.TIC_UserID, tblKartrisSupportTickets.TIC_LoginID, 
			tblKartrisSupportTickets.TIC_SupportTicketTypeID, tblKartrisSupportTickets.TIC_Status, 
			tblKartrisLogins.LOGIN_Username, tblKartrisUsers.U_EmailAddress, 
			MAX(tblKartrisSupportTicketMessages.STM_DateCreated) AS LastMessageDate, 
			tblKartrisSupportTicketTypes.STT_Name, tblKartrisUsers.U_LanguageID, 
			dbo.fnKartrisSupportTicketMessages_IsAwaitingReply(tblKartrisSupportTickets.TIC_ID) As TIC_AwaitingResponse
	FROM	tblKartrisSupportTickets INNER JOIN
		  tblKartrisSupportTicketMessages ON tblKartrisSupportTickets.TIC_ID = tblKartrisSupportTicketMessages.STM_TicketID INNER JOIN
		  tblKartrisUsers ON tblKartrisSupportTickets.TIC_UserID = tblKartrisUsers.U_ID LEFT OUTER JOIN
		  tblKartrisSupportTicketTypes ON tblKartrisSupportTickets.TIC_SupportTicketTypeID = tblKartrisSupportTicketTypes.STT_ID LEFT OUTER JOIN
		  tblKartrisLogins ON tblKartrisSupportTickets.TIC_LoginID = tblKartrisLogins.LOGIN_ID
	[WHERE]
	GROUP BY tblKartrisSupportTickets.TIC_ID, tblKartrisSupportTickets.TIC_DateOpened, tblKartrisSupportTickets.TIC_DateClosed, tblKartrisSupportTickets.TIC_Subject, 
						  tblKartrisSupportTickets.TIC_UserID, tblKartrisSupportTickets.TIC_LoginID, tblKartrisSupportTickets.TIC_SupportTicketTypeID, tblKartrisSupportTickets.TIC_Status, 
						  tblKartrisLogins.LOGIN_Username, tblKartrisUsers.U_EmailAddress, tblKartrisSupportTicketTypes.STT_Name, tblKartrisUsers.U_LanguageID,
							dbo.fnKartrisSupportTicketMessages_IsAwaitingReply(tblKartrisSupportTickets.TIC_ID) 
	HAVING (tblKartrisUsers.U_LanguageID = ' + CAST(@LangID as nvarchar(2)) + ') '
	
	-- Building the condition
	IF (@Keyword <> '') AND (@Keyword IS NOT NULL)	BEGIN
		SET @Cmd = Replace(@Cmd, '[WHERE]',' WHERE (tblKartrisSupportTickets.TIC_Tags LIKE ''%' + @Keyword + '%'' OR
								tblKartrisSupportTicketMessages.STM_Text LIKE ''%' + @Keyword + '%'' OR
								tblKartrisSupportTickets.TIC_Subject LIKE ''%' + @Keyword + '%'') ')
	END	ELSE BEGIN
		SET @Cmd = Replace(@Cmd, '[WHERE]',' ')
	END
	
	IF (@AssignedID <> -1) BEGIN
		SET @Cmd = @Cmd + ' AND  (tblKartrisSupportTickets.TIC_LoginID=' + CAST(@AssignedID as nvarchar(10)) + ') '
	END
	IF (@TypeID <> -1) BEGIN
		SET @Cmd = @Cmd + ' AND  (tblKartrisSupportTickets.TIC_SupportTicketTypeID=' + CAST(@TypeID as nvarchar(10)) + ') '
	END
	IF (@UserID <> -1) BEGIN
		SET @Cmd = @Cmd + ' AND  (tblKartrisSupportTickets.TIC_UserID=' + CAST(@UserID as nvarchar(10)) + ') '
	END ELSE BEGIN
		IF (@UserEmail <> '') AND (@UserEmail IS NOT NULL)BEGIN
			SET @Cmd = @Cmd + ' AND  (tblKartrisUsers.U_EmailAddress LIKE ''%' + @UserEmail + '%'') '
		END
	END
	IF (@Status <> 'a')	BEGIN
		IF (@Status = 'w') BEGIN
			SET @Cmd = @Cmd + ' AND  (tblKartrisSupportTickets.TIC_ID IN 
										(SELECT  DISTINCT tblKartrisSupportTicketMessages.STM_TicketID
										 FROM    tblKartrisSupportTicketMessages INNER JOIN tblKartrisSupportTickets 
											ON tblKartrisSupportTicketMessages.STM_TicketID = tblKartrisSupportTickets.TIC_ID
										 WHERE   dbo.fnKartrisSupportTicketMessages_IsAwaitingReply(tblKartrisSupportTicketMessages.STM_TicketID) = 1 '
			IF (@AssignedID <> -1) BEGIN
				SET @Cmd = @Cmd + ' AND  (tblKartrisSupportTickets.TIC_LoginID=' + CAST(@AssignedID as nvarchar(10)) + ') '
			END	
						
			SET @Cmd = @Cmd + ' ))'
		END ELSE BEGIN
			SET @Cmd = @Cmd + ' AND  (tblKartrisSupportTickets.TIC_Status=''' + @Status + ''') '
		END
	END

	Print @Cmd;
	EXECUTE(@Cmd);

END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisDB_GetAttributesToCompare]    Script Date: 12/15/2012 14:09:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
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

	SELECT DISTINCT vKartrisProductsVersions.P_ID, vKartrisProductsVersions.P_Name, 
			dbo.fnKartrisProduct_GetMinPriceWithCG(vKartrisProductsVersions.P_ID, @CG_ID) as P_Price, vKartrisTypeAttributes.ATTRIB_ID 
		  , vKartrisTypeAttributes.ATTRIB_Name, vKartrisTypeAttributeValues.ATTRIBV_Value, ATTRIB_OrderByValue,
		  vKartrisTypeAttributes.ATTRIB_Compare
	FROM         vKartrisTypeAttributes INNER JOIN
						  vKartrisTypeAttributeValues ON vKartrisTypeAttributes.ATTRIB_ID = vKartrisTypeAttributeValues.ATTRIBV_AttributeID RIGHT OUTER JOIN
						  vKartrisProductsVersions ON vKartrisTypeAttributeValues.ATTRIBV_ProductID = vKartrisProductsVersions.P_ID
	WHERE     (vKartrisProductsVersions.LANG_ID = @LANG_ID) AND (vKartrisProductsVersions.P_ID IN
							  (SELECT     ProductID
								FROM         [#TempTbl])) AND (vKartrisTypeAttributes.ATTRIB_Compare <> 'n' OR
								vKartrisTypeAttributes.ATTRIB_Compare IS NULL)
	
	DROP TABLE #TempTbl;

END
GO