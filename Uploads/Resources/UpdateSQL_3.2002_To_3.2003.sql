

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='3.2003', CFG_VersionAdded=3.2003 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetSummaryByCatID]    Script Date: 13/05/2022 12:23:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Paul
-- Last Modified: May 2022
-- Description:	Speed doubled, use productslite
-- table, drop unnecessary fields
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
	SELECT CategoryProducts.*, P_Name
	FROM CategoryProducts INNER JOIN [dbo].[vKartrisTypeProductsLite] ON CategoryProducts.P_ID = vKartrisTypeProductsLite.P_ID
	WHERE LANG_ID = @LANG_ID
	ORDER BY P_Featured, P_ID DESC
	   
END

GO

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetRowsBetweenByCatID]    Script Date: 18/05/2022 10:30:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	Update uses lite products view
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

	IF @OrderBy is NULL OR @OrderBy = 'd'
	BEGIN 
		SELECT @OrderBy = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = 'frontend.products.display.sortdefault';
	END;
	IF @OrderDirection is NULL OR @OrderDirection = '' BEGIN 
		SELECT @OrderDirection = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = 'frontend.products.display.sortdirection';
	END;
	
		With ProductList AS 
		(
			SELECT	CASE 
					WHEN (@OrderBy = 'P_ID' AND @OrderDirection = 'A') THEN	ROW_NUMBER() OVER (ORDER BY P_ID ASC) 
					WHEN (@OrderBy = 'P_ID' AND @OrderDirection = 'D') THEN	ROW_NUMBER() OVER (ORDER BY P_ID DESC) 
					WHEN (@OrderBy = 'P_Name' AND @OrderDirection = 'A') THEN ROW_NUMBER() OVER (ORDER BY P_Name ASC) 
					WHEN (@OrderBy = 'P_Name' AND @OrderDirection = 'D') THEN ROW_NUMBER() OVER (ORDER BY P_Name DESC) 
					WHEN (@OrderBy = 'P_DateCreated' AND @OrderDirection = 'A') THEN ROW_NUMBER() OVER (ORDER BY P_DateCreated ASC) 
					WHEN (@OrderBy = 'P_DateCreated' AND @OrderDirection = 'D') THEN ROW_NUMBER() OVER (ORDER BY P_DateCreated DESC) 
					WHEN (@OrderBy = 'P_LastModified' AND @OrderDirection = 'A') THEN ROW_NUMBER() OVER (ORDER BY P_LastModified ASC) 
					WHEN (@OrderBy = 'P_LastModified' AND @OrderDirection = 'D') THEN ROW_NUMBER() OVER (ORDER BY P_LastModified DESC) 
					WHEN (@OrderBy = 'PCAT_OrderNo' AND @OrderDirection = 'A') THEN ROW_NUMBER() OVER (ORDER BY PCAT_OrderNo ASC) 
					WHEN (@OrderBy = 'PCAT_OrderNo' AND @OrderDirection = 'D') THEN ROW_NUMBER() OVER (ORDER BY PCAT_OrderNo DESC) 
					END AS Row,
					vKartrisTypeProductsLite.P_ID, MIN(tblKartrisTaxRates.T_Taxrate) AS MinTaxRate, vKartrisTypeProductsLite.P_Name, 
										  vKartrisTypeProductsLite.P_VersionDisplayType, 
										  vKartrisTypeProductsLite.P_DateCreated, vKartrisTypeProductsLite.P_LastModified, tblKartrisProductCategoryLink.PCAT_OrderNo
					FROM         tblKartrisProductCategoryLink INNER JOIN
										  vKartrisTypeProductsLite ON tblKartrisProductCategoryLink.PCAT_ProductID = vKartrisTypeProductsLite.P_ID INNER JOIN
										  tblKartrisVersions ON vKartrisTypeProductsLite.P_ID = tblKartrisVersions.V_ProductID LEFT OUTER JOIN
										  tblKartrisTaxRates ON tblKartrisTaxRates.T_ID = tblKartrisVersions.V_Tax
					WHERE     (tblKartrisVersions.V_Live = 1) AND (tblKartrisVersions.V_Type = 'b' OR tblKartrisVersions.V_Type = 'v' ) AND (vKartrisTypeProductsLite.LANG_ID = @LANG_ID) AND (vKartrisTypeProductsLite.P_Live = 1) AND 
										  (tblKartrisProductCategoryLink.PCAT_CategoryID = @CAT_ID) AND (vKartrisTypeProductsLite.P_CustomerGroupID IS NULL OR
										  vKartrisTypeProductsLite.P_CustomerGroupID = @CGroupID)
					GROUP BY vKartrisTypeProductsLite.P_Name, vKartrisTypeProductsLite.P_ID, 
										  vKartrisTypeProductsLite.P_VersionDisplayType, vKartrisTypeProductsLite.P_DateCreated, vKartrisTypeProductsLite.P_LastModified, 
										  tblKartrisProductCategoryLink.PCAT_OrderNo
			
		)

		SELECT *,
	dbo.fnKartrisProduct_GetMinPriceWithCG(ProductList.P_ID, @CGroupID) AS MinPrice, 
	dbo.fnKartrisDB_TruncateDescription(dbo.fnKartrisLanguageElement_GetItemValue(@LANG_ID, 2, 2, ProductList.P_ID)) AS P_Desc,
	dbo.fnKartrisLanguageElement_GetItemValue(@LANG_ID, 2, 7, ProductList.P_ID) AS P_Strapline
		FROM ProductList
		WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber
		ORDER BY Row ASC
	
END
GO

