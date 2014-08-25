/****** UPDATE general.security.ssl config setting to include new 'always' option ******/
UPDATE tblKartrisConfig
SET CFG_DisplayType = 'l', CFG_DisplayInfo = 'y|n|a', CFG_Description = 'y = SSL on for essential pages, n = SSL off, a = SSL always on for all pages'
WHERE (CFG_Name = 'general.security.ssl')

/****** Object:  View [dbo].[vKartrisCategoryProductsVersionsLink]    Script Date: 7/21/2014 11:55:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vKartrisCategoryProductsVersionsLink]
AS
SELECT        dbo.tblKartrisProducts.P_ID, dbo.tblKartrisProducts.P_OrderVersionsBy, dbo.tblKartrisProducts.P_VersionsSortDirection, 
						 dbo.tblKartrisProducts.P_VersionDisplayType, dbo.tblKartrisProducts.P_Type, tblKartrisTaxRates_1.T_Taxrate, 
						 dbo.tblKartrisProductCategoryLink.PCAT_CategoryID AS CAT_ID, dbo.tblKartrisProducts.P_Live, dbo.tblKartrisCategories.CAT_Live, 
						 dbo.tblKartrisVersions.V_Live, dbo.tblKartrisVersions.V_ID, dbo.tblKartrisVersions.V_CodeNumber, dbo.tblKartrisVersions.V_Price, 
						 dbo.tblKartrisVersions.V_Tax, dbo.tblKartrisVersions.V_Weight, dbo.tblKartrisVersions.V_DeliveryTime, dbo.tblKartrisVersions.V_Quantity, 
						 dbo.tblKartrisVersions.V_QuantityWarnLevel, dbo.tblKartrisVersions.V_DownLoadInfo, dbo.tblKartrisVersions.V_DownloadType, 
						 dbo.tblKartrisVersions.V_RRP, dbo.tblKartrisVersions.V_OrderByValue, dbo.tblKartrisVersions.V_Type, dbo.tblKartrisVersions.V_CustomerGroupID, 
						 dbo.tblKartrisProducts.P_Featured, dbo.tblKartrisProducts.P_SupplierID, dbo.tblKartrisProducts.P_CustomerGroupID, dbo.tblKartrisProducts.P_Reviews, 
						 dbo.tblKartrisProducts.P_AverageRating, dbo.tblKartrisProducts.P_DateCreated, dbo.tblKartrisVersions.V_CustomizationType, 
						 dbo.tblKartrisVersions.V_CustomizationDesc, dbo.tblKartrisVersions.V_CustomizationCost, dbo.tblKartrisTaxRates.T_Taxrate AS T_TaxRate2, 
						 dbo.tblKartrisCategories.CAT_CustomerGroupID
FROM            dbo.tblKartrisCategories INNER JOIN
						 dbo.tblKartrisProductCategoryLink ON dbo.tblKartrisCategories.CAT_ID = dbo.tblKartrisProductCategoryLink.PCAT_CategoryID INNER JOIN
						 dbo.tblKartrisProducts ON dbo.tblKartrisProductCategoryLink.PCAT_ProductID = dbo.tblKartrisProducts.P_ID LEFT OUTER JOIN
						 dbo.tblKartrisVersions LEFT OUTER JOIN
						 dbo.tblKartrisTaxRates AS tblKartrisTaxRates_1 ON dbo.tblKartrisVersions.V_Tax = tblKartrisTaxRates_1.T_ID LEFT OUTER JOIN
						 dbo.tblKartrisTaxRates ON dbo.tblKartrisVersions.V_Tax2 = dbo.tblKartrisTaxRates.T_ID ON 
						 dbo.tblKartrisProducts.P_ID = dbo.tblKartrisVersions.V_ProductID
WHERE        (dbo.tblKartrisCategories.CAT_Live = 1) AND (dbo.tblKartrisVersions.V_Live = 1) AND (dbo.tblKartrisProducts.P_Live = 1)

GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[41] 4[21] 2[21] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1[50] 4[25] 3) )"
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
		 Configuration = "(H (1[63] 4) )"
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
	  ActivePaneConfig = 9
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisCategories"
			Begin Extent = 
			   Top = 263
			   Left = 70
			   Bottom = 393
			   Right = 258
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisProductCategoryLink"
			Begin Extent = 
			   Top = 0
			   Left = 366
			   Bottom = 113
			   Right = 549
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisProducts"
			Begin Extent = 
			   Top = 17
			   Left = 768
			   Bottom = 147
			   Right = 982
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisVersions"
			Begin Extent = 
			   Top = 140
			   Left = 654
			   Bottom = 305
			   Right = 858
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisTaxRates_1"
			Begin Extent = 
			   Top = 60
			   Left = 430
			   Bottom = 173
			   Right = 600
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisTaxRates"
			Begin Extent = 
			   Top = 46
			   Left = 29
			   Bottom = 159
			   Right = 199
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
	  PaneHidden = 
   End
   Begin DataPane = 
	  PaneHidden = 
	  Begin ParameterDefaults' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisCategoryProductsVersionsLink'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' = ""
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 2955
		 Alias = 900
		 Table = 2610
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisCategoryProductsVersionsLink'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisCategoryProductsVersionsLink'
GO



/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetStockLevel]    Script Date: 7/21/2014 10:14:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Mohammad
-- Last Modified: Mohammad - July 2014
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_GetStockLevel]
(
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT DISTINCT V_ID, [dbo].[fnKartrisVersions_GetName](V_ID, @LANG_ID) As V_Name, V_CodeNumber, 
			V_Quantity, V_QuantityWarnLevel, P_SupplierID, P_ID
FROM           dbo.vKartrisCategoryProductsVersionsLink
WHERE       (V_Quantity <= V_QuantityWarnLevel) AND (V_QuantityWarnLevel <> 0)
ORDER BY V_Quantity , V_QuantityWarnLevel

GO

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetByProductID]    Script Date: 7/21/2014 10:14:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===================================================
-- Author:		Medz
-- Create date: 02/12/2008 13:53:30
-- Last Modified: Mohammad - July 2014
-- Description:	Replaces the [spKartris_PROD_Select]
-- ===================================================
ALTER PROCEDURE [dbo].[spKartrisProducts_GetByProductID]
(
	@P_ID int,
	@LANG_ID tinyint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	WITH Products AS
	(
		SELECT     P_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType, P_Type, MIN(V_Price) AS MinPrice, 
				P_Reviews, P_Featured, P_CustomerGroupID, MIN(T_Taxrate) AS MinTax
		FROM         vKartrisCategoryProductsVersionsLink
		WHERE     (P_ID = @P_ID) AND (V_Type = 'b' OR V_Type = 'v' )
		GROUP BY P_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType, P_Type, P_Featured, P_CustomerGroupID, P_Reviews
	)
	SELECT Products.*, P_Name, P_Desc, P_StrapLine, P_PageTitle
	FROM Products INNER JOIN [dbo].[vKartrisTypeProducts] ON Products.P_ID = vKartrisTypeProducts.P_ID
	WHERE LANG_ID = @LANG_ID
END

GO

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetFeaturedProducts]    Script Date: 7/21/2014 10:14:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Medz
-- Reworked:	Paul
-- Last Modified: Mohammad - July 2014
-- Create date: 02/10/2008 13:23:42
-- Description:	Replaces the [spKartris_PROD_Specials]
-- =============================================

ALTER PROCEDURE [dbo].[spKartrisProducts_GetFeaturedProducts]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	WITH FeaturedProducts AS
	(
		SELECT     P_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType, P_Type, 
					dbo.fnKartrisProduct_GetMinPrice(P_ID) AS MinPrice, P_Reviews, 
						  P_Featured, P_CustomerGroupID, MIN(T_Taxrate) AS MinTax
		FROM         vKartrisCategoryProductsVersionsLink
		WHERE     (P_Featured <> 0) AND (P_CustomerGroupID IS NULL)
		GROUP BY P_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType, P_Type, P_CustomerGroupID, P_Reviews, P_Featured
		
	)
	SELECT FeaturedProducts.*, LANG_ID, P_Name, P_Desc, P_StrapLine, P_PageTitle
	FROM FeaturedProducts INNER JOIN [dbo].[vKartrisTypeProducts] ON FeaturedProducts.P_ID = vKartrisTypeProducts.P_ID
	ORDER BY P_Featured DESC

END

GO

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetSpecials]    Script Date: 7/21/2014 10:14:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Medz
-- Create date: 02/10/2008 13:23:42
-- Last Modified: Mohammad - July 2014
-- Description:	Replaces the [spKartris_PROD_Specials]
-- =============================================

ALTER PROCEDURE [dbo].[spKartrisProducts_GetSpecials]
(
	@LANG_ID tinyint
)
AS
BEGIN
	WITH SpecialProducts AS
	(
		SELECT     P_ID, P_OrderVersionsBy, P_VersionDisplayType, P_Type, dbo.fnKartrisProduct_GetMinPrice(P_ID) AS MinPrice, MIN(T_Taxrate) AS MinTax
		FROM         vKartrisCategoryProductsVersionsLink
		GROUP BY P_ID, P_OrderVersionsBy, P_VersionDisplayType, P_Type,  P_Featured
		HAVING      (P_Featured = 1)
	)
	SELECT SpecialProducts.*, P_Name, P_Desc, P_StrapLine, P_PageTitle
	FROM SpecialProducts INNER JOIN [dbo].[vKartrisTypeProducts] ON SpecialProducts.P_ID = vKartrisTypeProducts.P_ID
	WHERE     (LANG_ID = @LANG_ID)
END

GO

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetSummaryByCatID]    Script Date: 7/21/2014 10:14:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Mohammad
-- Last Modified: Mohammad - July 2014
-- Description:	Replaces the [spKartris_PROD_Select]
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisProducts_GetSummaryByCatID](@CAT_ID as int, @LANG_ID as tinyint)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	WITH CategoryProducts AS
	(
		SELECT     P_ID,  P_OrderVersionsBy, P_VersionsSortDirection,
					 P_VersionDisplayType, P_Featured, P_Type, dbo.fnKartrisProduct_GetMinPrice(P_ID) AS MinPrice, MIN(T_Taxrate) AS MinTaxRate
		FROM         vKartrisCategoryProductsVersionsLink
		WHERE     CAT_ID = @CAT_ID
		GROUP BY P_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType,
					P_Featured, P_Type
	)
	SELECT CategoryProducts.*, P_Name, dbo.fnKartrisDB_TruncateDescription(P_Desc) as P_Desc, P_StrapLine, P_PageTitle
	FROM CategoryProducts INNER JOIN [dbo].[vKartrisTypeProducts] ON CategoryProducts.P_ID = vKartrisTypeProducts.P_ID
	WHERE LANG_ID = @LANG_ID
	ORDER BY P_Featured, P_ID DESC
	   
END

GO

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetTopList]    Script Date: 7/21/2014 10:14:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Medz
-- Create date: 02/12/2008 13:52:43
-- Last Modified: Mohammad - July 2014
-- Description:	Replaces spKartris_Prod_TopList
-- Remarks:	Optimization (Medz) - 04-07-2010
-- =============================================
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
	SELECT TOP (@Limit) vKartrisCategoryProductsVersionsLink.P_ID, [dbo].[fnKartrisProducts_GetName](@LANG_ID, vKartrisCategoryProductsVersionsLink.P_ID) AS P_Name, 
				@LANG_ID as LANG_ID, SUM(tblTopList.IR_Quantity) as ProductHits
	FROM tblTopList INNER JOIN dbo.vKartrisCategoryProductsVersionsLink ON tblTopList.IR_VersionCode = dbo.vKartrisCategoryProductsVersionsLink.V_CodeNumber
	WHERE	vKartrisCategoryProductsVersionsLink.V_CustomerGroupID IS NULL 
		AND vKartrisCategoryProductsVersionsLink.P_CustomerGroupID IS NULL 
		AND vKartrisCategoryProductsVersionsLink.CAT_CustomerGroupID IS NULL
	GROUP BY vKartrisCategoryProductsVersionsLink.P_ID, [dbo].[fnKartrisProducts_GetName](@LANG_ID, vKartrisCategoryProductsVersionsLink.P_ID)
	ORDER BY ProductHits DESC

END

GO

/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetMinPriceByProductID]    Script Date: 7/21/2014 10:14:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Mohammad
-- Last Modified: Mohammad - July 2014
-- Description:	Used in the Compare.aspx Page
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisVersions_GetMinPriceByProductID](@LANG_ID as tinyint, @P_ID as int, @CG_ID as smallint)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	SELECT     distinct P_ID, P_Name, dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID, @CG_ID) as P_Price
	FROM         vKartrisTypeProducts
	WHERE     (LANG_ID = @LANG_ID) AND (P_ID = @P_ID)
	GROUP BY P_ID, P_Name

END

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