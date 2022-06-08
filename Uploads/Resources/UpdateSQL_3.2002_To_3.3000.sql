
/****** Object:  Index [SH_Price]    Script Date: 03/06/2022 14:23:45 ******/
BEGIN TRY
DROP INDEX [SH_Price] ON [dbo].[tblKartrisSearchHelper]
END TRY
BEGIN CATCH
-- just ignore this
END CATCH
GO

ALTER TABLE dbo.tblKartrisSearchHelper 
ALTER COLUMN SH_Price decimal(18, 4);
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


/****** Let's clean up the products table indexes ******/
-- remove fks
ALTER TABLE [dbo].[tblKartrisVersions] DROP CONSTRAINT [FK_tblKartrisVersions_tblKartrisProducts]
ALTER TABLE [dbo].[tblKartrisReviews] DROP CONSTRAINT [FK_tblKartrisReviews_tblKartrisProducts]
ALTER TABLE [dbo].[tblKartrisRelatedProducts] DROP CONSTRAINT [FK_tblKartrisRelatedProducts_tblKartrisProducts]
ALTER TABLE [dbo].[tblKartrisRelatedProducts] DROP CONSTRAINT [FK_tblKartrisRelatedProducts_tblKartrisProducts1]
ALTER TABLE [dbo].[tblKartrisProductOptionLink] DROP CONSTRAINT [FK_tblKartrisProductOptionLink_tblKartrisProducts]
ALTER TABLE [dbo].[tblKartrisProductOptionGroupLink] DROP CONSTRAINT [FK_tblKartrisProductOptionGroupLink_tblKartrisProducts]
ALTER TABLE [dbo].[tblKartrisProductCategoryLink] DROP CONSTRAINT [FK_tblKartrisProductCategoryLink_tblKartrisProducts]
ALTER TABLE [dbo].[tblKartrisAttributeValues] DROP CONSTRAINT [FK_tblKartrisAttributeValues_tblKartrisProducts]
GO

-- Drop products constraint/key from [tblKartrisAttributeProductOptions]
DECLARE @ObjectName NVARCHAR(100)
SELECT @ObjectName = name from sys.objects where object_id in 
(   select fk.constraint_object_id from sys.foreign_key_columns as fk
    where fk.referenced_object_id = 
        (select object_id from sys.tables where name = 'tblKartrisProducts')
)
EXEC('ALTER TABLE [dbo].[tblKartrisAttributeProductOptions] DROP CONSTRAINT ' + @ObjectName)


-- drop products pk
ALTER TABLE [dbo].[tblKartrisProducts] DROP CONSTRAINT [aaaaatblKartrisProducts_PK]
GO

-- drop unnecessary indexes on products
DROP INDEX [idxP_ID] ON [dbo].[tblKartrisProducts] WITH ( ONLINE = OFF )
DROP INDEX [P_ID] ON [dbo].[tblKartrisProducts]
GO

-- add primary key and other new indexes
ALTER TABLE [dbo].[tblKartrisProducts] ADD  CONSTRAINT [PK_tblKartrisProducts] PRIMARY KEY CLUSTERED 
(
	[P_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sp_rename '[dbo].[tblKartrisProducts].[V_CustomerGroupID]', 'P_CustomerGroupID'
CREATE NONCLUSTERED INDEX [P_Live] ON [dbo].[tblKartrisProducts]
(
	[P_Live] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [P_Featured] ON [dbo].[tblKartrisProducts]
(
	[P_Featured] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


-- Add fks back
ALTER TABLE [dbo].[tblKartrisVersions]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisVersions_tblKartrisProducts] FOREIGN KEY([V_ProductID])
REFERENCES [dbo].[tblKartrisProducts] ([P_ID])
GO
ALTER TABLE [dbo].[tblKartrisVersions] CHECK CONSTRAINT [FK_tblKartrisVersions_tblKartrisProducts]
GO

ALTER TABLE [dbo].[tblKartrisReviews]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisReviews_tblKartrisProducts] FOREIGN KEY([REV_ProductID])
REFERENCES [dbo].[tblKartrisProducts] ([P_ID])
GO
ALTER TABLE [dbo].[tblKartrisReviews] CHECK CONSTRAINT [FK_tblKartrisReviews_tblKartrisProducts]
GO

ALTER TABLE [dbo].[tblKartrisRelatedProducts]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisRelatedProducts_tblKartrisProducts] FOREIGN KEY([RP_ParentID])
REFERENCES [dbo].[tblKartrisProducts] ([P_ID])
GO
ALTER TABLE [dbo].[tblKartrisRelatedProducts] CHECK CONSTRAINT [FK_tblKartrisRelatedProducts_tblKartrisProducts]
GO

ALTER TABLE [dbo].[tblKartrisProductOptionLink]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisProductOptionLink_tblKartrisProducts] FOREIGN KEY([P_OPT_ProductID])
REFERENCES [dbo].[tblKartrisProducts] ([P_ID])
GO
ALTER TABLE [dbo].[tblKartrisProductOptionLink] CHECK CONSTRAINT [FK_tblKartrisProductOptionLink_tblKartrisProducts]
GO

ALTER TABLE [dbo].[tblKartrisProductOptionGroupLink]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisProductOptionGroupLink_tblKartrisProducts] FOREIGN KEY([P_OPTG_ProductID])
REFERENCES [dbo].[tblKartrisProducts] ([P_ID])
GO
ALTER TABLE [dbo].[tblKartrisProductOptionGroupLink] CHECK CONSTRAINT [FK_tblKartrisProductOptionGroupLink_tblKartrisProducts]
GO

ALTER TABLE [dbo].[tblKartrisProductCategoryLink]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisProductCategoryLink_tblKartrisProducts] FOREIGN KEY([PCAT_ProductID])
REFERENCES [dbo].[tblKartrisProducts] ([P_ID])
GO
ALTER TABLE [dbo].[tblKartrisProductCategoryLink] CHECK CONSTRAINT [FK_tblKartrisProductCategoryLink_tblKartrisProducts]
GO

ALTER TABLE [dbo].[tblKartrisAttributeValues]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisAttributeValues_tblKartrisProducts] FOREIGN KEY([ATTRIBV_ProductID])
REFERENCES [dbo].[tblKartrisProducts] ([P_ID])
GO
ALTER TABLE [dbo].[tblKartrisAttributeValues] CHECK CONSTRAINT [FK_tblKartrisAttributeValues_tblKartrisProducts]
GO

ALTER TABLE [dbo].[tblKartrisAttributeProductOptions]  WITH CHECK ADD FOREIGN KEY([ATTRIBPO_ProductId])
REFERENCES [dbo].[tblKartrisProducts] ([P_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

/****** Clean up tblKartrisAdminLog indexes ******/
ALTER TABLE [dbo].[tblKartrisAdminLog] DROP CONSTRAINT [aaaaatblKartrisAdminLog_PK]
DROP INDEX [idxAL_ID] ON [dbo].[tblKartrisAdminLog] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisAdminLog] ADD  CONSTRAINT [PK_tblKartrisAdminLog] PRIMARY KEY CLUSTERED 
(
	[AL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisAdminRelatedTables indexes ******/
EXEC sp_rename '[dbo].[tblKartrisAdminRelatedTables].[PK_tblKartrisAdminOrdersRelatedTables]', 'PK_tblKartrisAdminRelatedTables'
GO

/****** Clean up tblKartrisAffiliateLog indexes ******/
ALTER TABLE [dbo].[tblKartrisAffiliateLog] DROP CONSTRAINT [aaaaatblKartrisAffiliateLog_PK]
DROP INDEX [AFLOG_ID] ON [dbo].[tblKartrisAffiliateLog]
DROP INDEX [idxAFLG_ID] ON [dbo].[tblKartrisAffiliateLog] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisAffiliateLog] ADD  CONSTRAINT [PK_tblKartrisAffiliateLog] PRIMARY KEY CLUSTERED 
(
	[AFLG_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [AFLG_DateTime] ON [dbo].[tblKartrisAffiliateLog]
(
	[AFLG_DateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisAffiliatePayments indexes ******/
ALTER TABLE [dbo].[tblKartrisAffiliatePayments] DROP CONSTRAINT [aaaaatblKartrisAffiliatePayments_PK]
DROP INDEX [idxAFP_ID] ON [dbo].[tblKartrisAffiliatePayments] WITH ( ONLINE = OFF )
DROP INDEX [AFP_ID] ON [dbo].[tblKartrisAffiliatePayments]
GO
ALTER TABLE [dbo].[tblKartrisAffiliatePayments] ADD  CONSTRAINT [PK_tblKartrisAffiliatePayments] PRIMARY KEY CLUSTERED 
(
	[AFP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisAttributeOptions indexes ******/
DECLARE @ObjectName2 NVARCHAR(100)
SELECT @ObjectName2 = name from sys.objects where object_id in 
(   select fk.constraint_object_id from sys.foreign_key_columns as fk
    where fk.referenced_object_id = 
        (select object_id from sys.tables where name = 'tblKartrisAttributeOptions')
)
EXEC('ALTER TABLE [dbo].[tblKartrisAttributeProductOptions] DROP CONSTRAINT ' + @ObjectName2)

DECLARE @ObjectName3 NVARCHAR(100)
SELECT @ObjectName3 =  name FROM sysobjects WHERE xtype = 'PK' AND parent_obj = OBJECT_ID('tblKartrisAttributeOptions')
EXEC('ALTER TABLE [dbo].[tblKartrisAttributeOptions] DROP CONSTRAINT ' + @ObjectName3)
GO

ALTER TABLE [dbo].[tblKartrisAttributeOptions] ADD  CONSTRAINT [PK_tblKartrisAttributeOptions] PRIMARY KEY CLUSTERED 
(
	[ATTRIBO_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblKartrisAttributeProductOptions]  WITH CHECK ADD FOREIGN KEY([ATTRIBPO_AttributeOptionID])
REFERENCES [dbo].[tblKartrisAttributeOptions] ([ATTRIBO_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

/****** Clean up tblKartrisAttributeProductOptions indexes ******/
DECLARE @ObjectName4 NVARCHAR(100)
SELECT @ObjectName4 =  name FROM sysobjects WHERE xtype = 'PK' AND parent_obj = OBJECT_ID('tblKartrisAttributeProductOptions')
EXEC('ALTER TABLE [dbo].[tblKartrisAttributeProductOptions] DROP CONSTRAINT ' + @ObjectName4)
GO

ALTER TABLE [dbo].[tblKartrisAttributeProductOptions] ADD  CONSTRAINT [PK_tblKartrisAttributeProductOptions] PRIMARY KEY CLUSTERED 
(
	[ATTRIBPO_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisAttributes indexes ******/
DECLARE @ObjectName5 NVARCHAR(100)
SELECT @ObjectName5 = name from sys.objects where object_id in 
(   select fk.constraint_object_id from sys.foreign_key_columns as fk
    where fk.referenced_object_id = 
        (select object_id from sys.tables where name = 'tblKartrisAttributes')
) and right(name,2)<>'es'
EXEC('ALTER TABLE [dbo].[tblKartrisAttributeOptions] DROP CONSTRAINT ' + @ObjectName5)

ALTER TABLE [dbo].[tblKartrisAttributeValues] DROP CONSTRAINT [FK_tblKartrisAttributeValues_tblKartrisAttributes]
GO
ALTER TABLE [dbo].[tblKartrisAttributes] DROP CONSTRAINT [aaaaatblKartrisAttributes_PK]
DROP INDEX [idxAttrib_ID] ON [dbo].[tblKartrisAttributes] WITH ( ONLINE = OFF )
DROP INDEX [PROP_ID] ON [dbo].[tblKartrisAttributes]
GO
ALTER TABLE [dbo].[tblKartrisAttributes] ADD  CONSTRAINT [PK_tblKartrisAttributes] PRIMARY KEY CLUSTERED 
(
	[ATTRIB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblKartrisAttributeValues]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisAttributeValues_tblKartrisAttributes] FOREIGN KEY([ATTRIBV_AttributeID])
REFERENCES [dbo].[tblKartrisAttributes] ([ATTRIB_ID])
GO
ALTER TABLE [dbo].[tblKartrisAttributeValues] CHECK CONSTRAINT [FK_tblKartrisAttributeValues_tblKartrisAttributes]
GO

ALTER TABLE [dbo].[tblKartrisAttributeOptions]  WITH CHECK ADD FOREIGN KEY([ATTRIBO_AttributeID])
REFERENCES [dbo].[tblKartrisAttributes] ([ATTRIB_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
CREATE NONCLUSTERED INDEX [ATTRIB_ShowFrontend] ON [dbo].[tblKartrisAttributes]
(
	[ATTRIB_ShowFrontend] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisAttributeValues indexes ******/
DROP INDEX [PROPV_PropertyID] ON [dbo].[tblKartrisAttributeValues]
GO
CREATE NONCLUSTERED INDEX [ATTRIBV_AttributeID] ON [dbo].[tblKartrisAttributeValues]
(
	[ATTRIBV_AttributeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ATTRIBV_ProductID] ON [dbo].[tblKartrisAttributeValues]
(
	[ATTRIBV_ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisBasketValues indexes ******/
CREATE NONCLUSTERED INDEX [BV_VersionID] ON [dbo].[tblKartrisBasketValues]
(
	[BV_VersionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [BV_ParentID] ON [dbo].[tblKartrisBasketValues]
(
	[BV_ParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisCategories indexes ******/
ALTER TABLE [dbo].[tblKartrisProductCategoryLink] DROP CONSTRAINT [FK_tblKartrisProductCategoryLink_tblKartrisCategories]
ALTER TABLE [dbo].[tblKartrisCategoryHierarchy] DROP CONSTRAINT [FK_tblKartrisCategoryHierarchy_tblKartrisCategories]
ALTER TABLE [dbo].[tblKartrisCategoryHierarchy] DROP CONSTRAINT [FK_tblKartrisCategoryHierarchy_tblKartrisCategories1]

ALTER TABLE [dbo].[tblKartrisCategories] DROP CONSTRAINT [aaaaatblKartrisCategories_PK]
GO

ALTER TABLE [dbo].[tblKartrisProductCategoryLink]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisProductCategoryLink_tblKartrisCategories] FOREIGN KEY([PCAT_CategoryID])
REFERENCES [dbo].[tblKartrisCategories] ([CAT_ID])
GO

ALTER TABLE [dbo].[tblKartrisProductCategoryLink] CHECK CONSTRAINT [FK_tblKartrisProductCategoryLink_tblKartrisCategories]
GO
ALTER TABLE [dbo].[tblKartrisCategoryHierarchy]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisCategoryHierarchy_tblKartrisCategories] FOREIGN KEY([CH_ParentID])
REFERENCES [dbo].[tblKartrisCategories] ([CAT_ID])
GO
ALTER TABLE [dbo].[tblKartrisCategoryHierarchy] CHECK CONSTRAINT [FK_tblKartrisCategoryHierarchy_tblKartrisCategories]
GO

DROP INDEX [V_CustomerGroupID] ON [dbo].[tblKartrisCategories]
GO

CREATE NONCLUSTERED INDEX [CAT_CustomerGroupID] ON [dbo].[tblKartrisCategories]
(
	[CAT_CustomerGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

EXEC sp_rename '[dbo].[tblKartrisCategories].[idxCAT_ID]', 'PK_tblKartrisCategories'

ALTER TABLE [dbo].[tblKartrisProductCategoryLink] DROP CONSTRAINT [FK_tblKartrisProductCategoryLink_tblKartrisCategories]
GO

ALTER TABLE [dbo].[tblKartrisCategoryHierarchy] DROP CONSTRAINT [FK_tblKartrisCategoryHierarchy_tblKartrisCategories]
GO

DROP INDEX [PK_tblKartrisCategories] ON [dbo].[tblKartrisCategories] WITH ( ONLINE = OFF )
GO

ALTER TABLE [dbo].[tblKartrisCategories] ADD  CONSTRAINT [PK_tblKartrisCategories] PRIMARY KEY CLUSTERED 
(
	[CAT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


ALTER TABLE [dbo].[tblKartrisCategoryHierarchy]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisCategoryHierarchy_tblKartrisCategories] FOREIGN KEY([CH_ParentID])
REFERENCES [dbo].[tblKartrisCategories] ([CAT_ID])
GO
ALTER TABLE [dbo].[tblKartrisCategoryHierarchy] CHECK CONSTRAINT [FK_tblKartrisCategoryHierarchy_tblKartrisCategories]
GO

ALTER TABLE [dbo].[tblKartrisProductCategoryLink]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisProductCategoryLink_tblKartrisCategories] FOREIGN KEY([PCAT_CategoryID])
REFERENCES [dbo].[tblKartrisCategories] ([CAT_ID])
GO
ALTER TABLE [dbo].[tblKartrisProductCategoryLink] CHECK CONSTRAINT [FK_tblKartrisProductCategoryLink_tblKartrisCategories]
GO

CREATE NONCLUSTERED INDEX [CAT_Live] ON [dbo].[tblKartrisCategories]
(
	[CAT_Live] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisCategoryHierarchy indexes ******/
DROP INDEX [CH_ParentCategoryID] ON [dbo].[tblKartrisCategoryHierarchy]
GO
CREATE NONCLUSTERED INDEX [CH_ChildID] ON [dbo].[tblKartrisCategoryHierarchy]
(
	[CH_ChildID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [CH_ParentID] ON [dbo].[tblKartrisCategoryHierarchy]
(
	[CH_ParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisCoupons indexes ******/
ALTER TABLE [dbo].[tblKartrisCoupons] DROP CONSTRAINT [aaaaatblKartrisCoupons_PK]
GO
DROP INDEX [CP_ID] ON [dbo].[tblKartrisCoupons]
GO
DROP INDEX [idxCP_CouponCode] ON [dbo].[tblKartrisCoupons] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisCoupons] DROP CONSTRAINT [IX_tblKartrisCoupons]
GO
ALTER TABLE [dbo].[tblKartrisCoupons] ADD  CONSTRAINT [PK_tblKartrisCoupons] PRIMARY KEY CLUSTERED 
(
	[CP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [CP_CouponCode] ON [dbo].[tblKartrisCoupons]
(
	[CP_CouponCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisCreditCards indexes ******/
ALTER TABLE [dbo].[tblKartrisCreditCards] DROP CONSTRAINT [aaaaatblKartrisCreditCards_PK]
GO
DROP INDEX [C_ID] ON [dbo].[tblKartrisCreditCards]
GO
DROP INDEX [idxCR_ID] ON [dbo].[tblKartrisCreditCards] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisCreditCards] ADD  CONSTRAINT [PK_tblKartrisCreditCards] PRIMARY KEY CLUSTERED 
(
	[CR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisCurrencies indexes ******/
ALTER TABLE [dbo].[tblKartrisCurrencies] DROP CONSTRAINT [aaaaatblKartrisCurrencies_PK]
GO
DROP INDEX [CUR_ID] ON [dbo].[tblKartrisCurrencies]
GO
DROP INDEX [CUR_IsoCode] ON [dbo].[tblKartrisCurrencies]
GO
DROP INDEX [idxCUR_ID] ON [dbo].[tblKartrisCurrencies] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisCurrencies] DROP CONSTRAINT [ISOCode_unique]
GO
ALTER TABLE [dbo].[tblKartrisCurrencies] ADD  CONSTRAINT [PK_tblKartrisCurrencies] PRIMARY KEY CLUSTERED 
(
	[CUR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [CUR_ISOCode] ON [dbo].[tblKartrisCurrencies]
(
	[CUR_ISOCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [CUR_Live] ON [dbo].[tblKartrisCurrencies]
(
	[CUR_Live] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisCustomerGroupPrices indexes ******/
ALTER TABLE [dbo].[tblKartrisCustomerGroupPrices] DROP CONSTRAINT [aaaaatblKartrisCustomerGroupPrices_PK]
GO
DROP INDEX [CGP_ID] ON [dbo].[tblKartrisCustomerGroupPrices]
GO
DROP INDEX [idxCGP_ID] ON [dbo].[tblKartrisCustomerGroupPrices] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisCustomerGroupPrices] ADD  CONSTRAINT [PK_tblKartrisCustomerGroupPrices] PRIMARY KEY CLUSTERED 
(
	[CGP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisCustomerGroups indexes ******/
ALTER TABLE [dbo].[tblKartrisProducts] DROP CONSTRAINT [FK_tblKartrisProducts_tblKartrisCustomerGroups]
GO
ALTER TABLE [dbo].[tblKartrisCustomerGroupPrices] DROP CONSTRAINT [FK_tblKartrisCustomerGroupPrices_tblKartrisCustomerGroups]
GO
ALTER TABLE [dbo].[tblKartrisCategories] DROP CONSTRAINT [FK_tblKartrisCategories_tblKartrisCustomerGroups]
GO

ALTER TABLE [dbo].[tblKartrisCustomerGroups] DROP CONSTRAINT [aaaaatblKartrisCustomerGroups_PK]
GO
DROP INDEX [CG_ID] ON [dbo].[tblKartrisCustomerGroups]
GO
DROP INDEX [idx_CG_ID] ON [dbo].[tblKartrisCustomerGroups] WITH ( ONLINE = OFF )
GO

ALTER TABLE [dbo].[tblKartrisCustomerGroups] ADD  CONSTRAINT [PK_tblKartrisCustomerGroups] PRIMARY KEY CLUSTERED 
(
	[CG_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [CG_Live] ON [dbo].[tblKartrisCustomerGroups]
(
	[CG_Live] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblKartrisCategories]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisCategories_tblKartrisCustomerGroups] FOREIGN KEY([CAT_CustomerGroupID])
REFERENCES [dbo].[tblKartrisCustomerGroups] ([CG_ID])
GO
ALTER TABLE [dbo].[tblKartrisCategories] CHECK CONSTRAINT [FK_tblKartrisCategories_tblKartrisCustomerGroups]
GO
ALTER TABLE [dbo].[tblKartrisCustomerGroupPrices]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisCustomerGroupPrices_tblKartrisCustomerGroups] FOREIGN KEY([CGP_CustomerGroupID])
REFERENCES [dbo].[tblKartrisCustomerGroups] ([CG_ID])
GO
ALTER TABLE [dbo].[tblKartrisCustomerGroupPrices] CHECK CONSTRAINT [FK_tblKartrisCustomerGroupPrices_tblKartrisCustomerGroups]
GO
ALTER TABLE [dbo].[tblKartrisProducts]  WITH NOCHECK ADD  CONSTRAINT [FK_tblKartrisProducts_tblKartrisCustomerGroups] FOREIGN KEY([P_CustomerGroupID])
REFERENCES [dbo].[tblKartrisCustomerGroups] ([CG_ID])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[tblKartrisProducts] CHECK CONSTRAINT [FK_tblKartrisProducts_tblKartrisCustomerGroups]
GO

/****** Clean up tblKartrisDeletedItems indexes ******/
DROP INDEX [idxDeleted_ID_Type] ON [dbo].[tblKartrisDeletedItems] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisDeletedItems] ADD  CONSTRAINT [PK_tblKartrisDeletedItems] PRIMARY KEY CLUSTERED 
(
	[Deleted_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Deleted_DateTime] ON [dbo].[tblKartrisDeletedItems]
(
	[Deleted_DateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisDestinations indexes ******/
DROP INDEX [D_ID] ON [dbo].[tblKartrisDestination]
GO

/****** Clean up tblKartrisInvoiceRows indexes ******/
ALTER TABLE [dbo].[tblKartrisInvoiceRows] DROP CONSTRAINT [aaaaatblKartrisInvoiceRows_PK]
GO
DROP INDEX [idxIR_ID] ON [dbo].[tblKartrisInvoiceRows] WITH ( ONLINE = OFF )
GO
DROP INDEX [OI_ID] ON [dbo].[tblKartrisInvoiceRows]
GO
DROP INDEX [OI_VersionID] ON [dbo].[tblKartrisInvoiceRows]
GO
DROP INDEX [OI_VersionCode] ON [dbo].[tblKartrisInvoiceRows]
GO
ALTER TABLE [dbo].[tblKartrisInvoiceRows] ADD  CONSTRAINT [PK_tblKartrisInvoiceRows] PRIMARY KEY CLUSTERED 
(
	[IR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IR_OrderNumberID] ON [dbo].[tblKartrisInvoiceRows]
(
	[IR_OrderNumberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IR_VersionCode] ON [dbo].[tblKartrisInvoiceRows]
(
	[IR_VersionCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisLabelFormats indexes ******/
DECLARE @ObjectName6 NVARCHAR(100)
SELECT @ObjectName6 =  name FROM sysobjects WHERE xtype = 'PK' AND parent_obj = OBJECT_ID('tblKartrisLabelFormats')
EXEC('ALTER TABLE [dbo].[tblKartrisLabelFormats] DROP CONSTRAINT ' + @ObjectName6)
GO
ALTER TABLE [dbo].[tblKartrisLabelFormats] ADD  CONSTRAINT [PK_tblKartrisLabelFormats] PRIMARY KEY CLUSTERED 
(
	[LBF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisLanguageElements indexes ******/
EXEC sp_rename '[dbo].[tblKartrisLanguageElements].[keyLE_ID]', 'LE_ID'
GO

/****** Clean up tblKartrisLanguageElementTypes indexes ******/
EXEC sp_rename '[dbo].[tblKartrisLanguageElementTypes].[PK_tblKartrisTableNames]', 'PK_tblKartrisLanguageElementTypes'
GO

/****** Clean up tblKartrisLanguages indexes ******/
DROP INDEX [LANG_ID] ON [dbo].[tblKartrisLanguages]
GO

/****** Clean up tblKartrisLanguageStrings indexes ******/
EXEC sp_rename '[dbo].[tblKartrisLanguageStrings].[_dta_index_tblKartrisLanguageStrings_5_1090818948__K8_K9_2_3_4_7_10]', 'LS_ClassName_LangID'
GO

/****** Clean up tblKartrisLogins indexes ******/
ALTER TABLE [dbo].[tblKartrisLogins] DROP CONSTRAINT [aaaaatblKartrisLogins_PK]
DROP INDEX [idxLOGIN_ID] ON [dbo].[tblKartrisLogins] WITH ( ONLINE = OFF )
DROP INDEX [LOGIN_ID] ON [dbo].[tblKartrisLogins]
GO
ALTER TABLE [dbo].[tblKartrisLogins] ADD  CONSTRAINT [PK_tblKartrisLogins] PRIMARY KEY CLUSTERED 
(
	[LOGIN_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [LOGIN_Username] ON [dbo].[tblKartrisLogins]
(
	[LOGIN_Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [LOGIN_Live] ON [dbo].[tblKartrisLogins]
(
	[LOGIN_Live] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisMediaLinks indexes ******/
CREATE NONCLUSTERED INDEX [ML_Live] ON [dbo].[tblKartrisMediaLinks]
(
	[ML_Live] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ML_ParentID] ON [dbo].[tblKartrisMediaLinks]
(
	[ML_ParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisNews indexes ******/
DROP INDEX [idxN_ID] ON [dbo].[tblKartrisNews] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisNews] DROP CONSTRAINT [aaaaatblKartrisNews_PK]
GO
ALTER TABLE [dbo].[tblKartrisNews] ADD  CONSTRAINT [PK_tblKartrisNews] PRIMARY KEY CLUSTERED 
(
	[N_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisObjectConfig indexes ******/
ALTER TABLE [dbo].[tblKartrisObjectConfig] DROP CONSTRAINT [PK_tblKartrisObjectConfig]
GO
DROP INDEX [idxOC_Name] ON [dbo].[tblKartrisObjectConfig] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisObjectConfig] ADD  CONSTRAINT [PK_tblKartrisObjectConfig] PRIMARY KEY CLUSTERED 
(
	[OC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [OC_Name] ON [dbo].[tblKartrisObjectConfig]
(
	[OC_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisObjectConfigValue indexes ******/
ALTER TABLE [dbo].[tblKartrisObjectConfigValue] DROP CONSTRAINT [PK_tblKartrisObjectConfigValue]
GO
DROP INDEX [idxObjectConfigID_ParentID] ON [dbo].[tblKartrisObjectConfigValue] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisObjectConfigValue] ADD  CONSTRAINT [PK_tblKartrisObjectConfigValue] PRIMARY KEY CLUSTERED 
(
	[OCV_ObjectConfigID] ASC,
	[OCV_ParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisOptionGroups indexes ******/
DROP INDEX [idxOPTG_ID] ON [dbo].[tblKartrisOptionGroups] WITH ( ONLINE = OFF )
GO
DROP INDEX [Indx_DefOrderByValue] ON [dbo].[tblKartrisOptionGroups]
GO
DROP INDEX [OPT_ID] ON [dbo].[tblKartrisOptionGroups]
GO
DROP INDEX [OPTG_BackendID] ON [dbo].[tblKartrisOptionGroups]
GO

ALTER TABLE [dbo].[tblKartrisOptions] DROP CONSTRAINT [FK_tblKartrisOptions_tblKartrisOptionGroups]
GO
ALTER TABLE [dbo].[tblKartrisProductOptionGroupLink] DROP CONSTRAINT [FK_tblKartrisProductOptionGroupLink_tblKartrisOptionGroups]
GO
ALTER TABLE [dbo].[tblKartrisOptionGroups] DROP CONSTRAINT [aaaaatblKartrisOptionGroups_PK]
GO

ALTER TABLE [dbo].[tblKartrisOptionGroups] ADD  CONSTRAINT [PK_tblKartrisOptionGroups] PRIMARY KEY CLUSTERED 
(
	[OPTG_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblKartrisProductOptionGroupLink]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisProductOptionGroupLink_tblKartrisOptionGroups] FOREIGN KEY([P_OPTG_OptionGroupID])
REFERENCES [dbo].[tblKartrisOptionGroups] ([OPTG_ID])
GO
ALTER TABLE [dbo].[tblKartrisProductOptionGroupLink] CHECK CONSTRAINT [FK_tblKartrisProductOptionGroupLink_tblKartrisOptionGroups]
GO
ALTER TABLE [dbo].[tblKartrisOptions]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisOptions_tblKartrisOptionGroups] FOREIGN KEY([OPT_OptionGroupID])
REFERENCES [dbo].[tblKartrisOptionGroups] ([OPTG_ID])
GO
ALTER TABLE [dbo].[tblKartrisOptions] CHECK CONSTRAINT [FK_tblKartrisOptions_tblKartrisOptionGroups]
GO
CREATE NONCLUSTERED INDEX [OPTG_DefOrderByValue] ON [dbo].[tblKartrisOptionGroups]
(
	[OPTG_DefOrderByValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisOptions indexes ******/
ALTER TABLE [dbo].[tblKartrisVersionOptionLink] DROP CONSTRAINT [FK_tblKartrisVersionOptionLink_tblKartrisOptions]
GO
ALTER TABLE [dbo].[tblKartrisProductOptionLink] DROP CONSTRAINT [FK_tblKartrisProductOptionLink_tblKartrisOptions]
GO
ALTER TABLE [dbo].[tblKartrisBasketOptionValues] DROP CONSTRAINT [FK_tblKartrisBasketOptionValues_tblKartrisOptions]
GO

ALTER TABLE [dbo].[tblKartrisOptions] DROP CONSTRAINT [aaaaatblKartrisOptions_PK]
GO
DROP INDEX [idxOPT_ID] ON [dbo].[tblKartrisOptions] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisOptions] ADD  CONSTRAINT [PK_tblKartrisOptions] PRIMARY KEY CLUSTERED 
(
	[OPT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblKartrisVersionOptionLink]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisVersionOptionLink_tblKartrisOptions] FOREIGN KEY([V_OPT_OptionID])
REFERENCES [dbo].[tblKartrisOptions] ([OPT_ID])
GO
ALTER TABLE [dbo].[tblKartrisVersionOptionLink] CHECK CONSTRAINT [FK_tblKartrisVersionOptionLink_tblKartrisOptions]
GO
ALTER TABLE [dbo].[tblKartrisProductOptionLink]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisProductOptionLink_tblKartrisOptions] FOREIGN KEY([P_OPT_OptionID])
REFERENCES [dbo].[tblKartrisOptions] ([OPT_ID])
GO
ALTER TABLE [dbo].[tblKartrisProductOptionLink] CHECK CONSTRAINT [FK_tblKartrisProductOptionLink_tblKartrisOptions]
GO
ALTER TABLE [dbo].[tblKartrisBasketOptionValues]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisBasketOptionValues_tblKartrisOptions] FOREIGN KEY([BSKTOPT_OptionID])
REFERENCES [dbo].[tblKartrisOptions] ([OPT_ID])
GO
ALTER TABLE [dbo].[tblKartrisBasketOptionValues] CHECK CONSTRAINT [FK_tblKartrisBasketOptionValues_tblKartrisOptions]
GO
DROP INDEX [OPT_ID] ON [dbo].[tblKartrisOptions]
GO

/****** Clean up tblKartrisOrders indexes ******/
DROP INDEX [_dta_index_tblKartrisOrders_c_5_1322487790__K1D_K2_K25_K26] ON [dbo].[tblKartrisOrders] WITH ( ONLINE = OFF )
GO
DROP INDEX [_dta_index_tblKartrisOrders_5_1322487790__K1D_2_8_9_12_13_14_15_25_26_36] ON [dbo].[tblKartrisOrders]
GO
DROP INDEX [CN_ID] ON [dbo].[tblKartrisOrders]
GO
EXEC sp_rename '[dbo].[tblKartrisOrders].[ON_AffiliatePaid]', 'O_AffiliatePaymentID'
EXEC sp_rename '[dbo].[tblKartrisOrders].[ON_CardholderID]', 'O_CustomerID'
EXEC sp_rename '[dbo].[tblKartrisOrders].[ON_CouponCode]', 'O_CouponCode'
EXEC sp_rename '[dbo].[tblKartrisOrders].[ON_CurrencyDefaultID]', 'O_CurrencyIDGateway'
EXEC sp_rename '[dbo].[tblKartrisOrders].[ON_LanguageID]', 'O_LanguageID'
EXEC sp_rename '[dbo].[tblKartrisOrders].[ON_ReferenceCode]', 'O_ReferenceCode'
GO
EXEC sp_rename '[dbo].[tblKartrisOrders].[idxOrderDate]', 'O_Date'
GO
DROP INDEX [idxOrderStatus] ON [dbo].[tblKartrisOrders]
GO
CREATE NONCLUSTERED INDEX [O_Sent] ON [dbo].[tblKartrisOrders]
(
	[O_Sent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [O_Invoiced] ON [dbo].[tblKartrisOrders]
(
	[O_Invoiced] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [O_Shipped] ON [dbo].[tblKartrisOrders]
(
	[O_Shipped] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [O_Paid] ON [dbo].[tblKartrisOrders]
(
	[O_Paid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [O_Cancelled] ON [dbo].[tblKartrisOrders]
(
	[O_Cancelled] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblKartrisOrdersPromotions] DROP CONSTRAINT [FK_tblKartrisOrdersPromotions_tblKartrisOrders]
GO
ALTER TABLE [dbo].[tblKartrisOrders] DROP CONSTRAINT [aaaaatblKartrisOrders_PK]
GO
ALTER TABLE [dbo].[tblKartrisOrders] ADD  CONSTRAINT [PK_tblKartrisOrders] PRIMARY KEY CLUSTERED 
(
	[O_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblKartrisOrdersPromotions]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisOrdersPromotions_tblKartrisOrders] FOREIGN KEY([OrderID])
REFERENCES [dbo].[tblKartrisOrders] ([O_ID])
GO
ALTER TABLE [dbo].[tblKartrisOrdersPromotions] CHECK CONSTRAINT [FK_tblKartrisOrdersPromotions_tblKartrisOrders]
GO

/****** Clean up tblKartrisPages indexes ******/
ALTER TABLE [dbo].[tblKartrisPages] DROP CONSTRAINT [aaaaatblKartrisPages_PK]
DROP INDEX [idxPAGE_ID] ON [dbo].[tblKartrisPages] WITH ( ONLINE = OFF )
DROP INDEX [IX_tblKartrisPages] ON [dbo].[tblKartrisPages]
DROP INDEX [PAGE_ID] ON [dbo].[tblKartrisPages]
GO
ALTER TABLE [dbo].[tblKartrisPages] ADD  CONSTRAINT [PK_tblKartrisPages] PRIMARY KEY CLUSTERED 
(
	[PAGE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PAGE_Name] ON [dbo].[tblKartrisPages]
(
	[PAGE_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisPromotionParts indexes ******/
CREATE NONCLUSTERED INDEX [PROM_ID] ON [dbo].[tblKartrisPromotionParts]
(
	[PROM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisPromotions indexes ******/
EXEC sp_rename '[dbo].[tblKartrisPromotions].[PK_tblKartrisPromotions2]', 'PK_tblKartrisPromotions'
GO

/****** Clean up tblKartrisReviews indexes ******/
ALTER TABLE [dbo].[tblKartrisReviews] DROP CONSTRAINT [aaaaatblKartrisReviews_PK]
GO
DROP INDEX [idxREV_ID] ON [dbo].[tblKartrisReviews] WITH ( ONLINE = OFF )
DROP INDEX [REV_ID] ON [dbo].[tblKartrisReviews]
GO
ALTER TABLE [dbo].[tblKartrisReviews] ADD  CONSTRAINT [PK_tblKartrisReviews] PRIMARY KEY CLUSTERED 
(
	[REV_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisSavedBaskets indexes ******/
ALTER TABLE [dbo].[tblKartrisSavedBaskets] DROP CONSTRAINT [aaaaatblKartrisSaveBasket_PK]
GO
DROP INDEX [BSKT_ID] ON [dbo].[tblKartrisSavedBaskets]
DROP INDEX [BSKT_CustomerID] ON [dbo].[tblKartrisSavedBaskets]
DROP INDEX [idxSBSKT_ID] ON [dbo].[tblKartrisSavedBaskets] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisSavedBaskets] ADD  CONSTRAINT [PK_tblKartrisSavedBaskets] PRIMARY KEY CLUSTERED 
(
	[SBSKT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SBSKT_UserID] ON [dbo].[tblKartrisSavedBaskets]
(
	[SBSKT_UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SBSKT_Name] ON [dbo].[tblKartrisSavedBaskets]
(
	[SBSKT_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisSavedExports indexes ******/
ALTER TABLE [dbo].[tblKartrisSavedExports] DROP CONSTRAINT [aaaaatblKartrisSavedExports_PK]
GO
DROP INDEX [EXPORT_ID] ON [dbo].[tblKartrisSavedExports]
DROP INDEX [idxEXPORT_ID] ON [dbo].[tblKartrisSavedExports] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisSavedExports] ADD  CONSTRAINT [PK_tblKartrisSavedExports] PRIMARY KEY CLUSTERED 
(
	[EXPORT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisSearchHelper indexes ******/
ALTER TABLE [dbo].[tblKartrisSearchHelper] DROP CONSTRAINT [PK_tblKartrisSearchHelper]
GO
DROP INDEX [IX_SearchHelper_TotalScore] ON [dbo].[tblKartrisSearchHelper]
DROP INDEX [idxSH_Session_Product_Field_ID] ON [dbo].[tblKartrisSearchHelper] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisSearchHelper] ADD  CONSTRAINT [PK_tblKartrisSearchHelper] PRIMARY KEY CLUSTERED 
(
	[SH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SH_SessionID] ON [dbo].[tblKartrisSearchHelper]
(
	[SH_SessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SH_TypeID] ON [dbo].[tblKartrisSearchHelper]
(
	[SH_TypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SH_FieldID] ON [dbo].[tblKartrisSearchHelper]
(
	[SH_FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SH_ParentID] ON [dbo].[tblKartrisSearchHelper]
(
	[SH_ParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SH_ProductID] ON [dbo].[tblKartrisSearchHelper]
(
	[SH_ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SH_Score] ON [dbo].[tblKartrisSearchHelper]
(
	[SH_Score] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

BEGIN TRY
CREATE NONCLUSTERED INDEX [SH_Price] ON [dbo].[tblKartrisSearchHelper]
(
	[SH_Price] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END TRY
BEGIN CATCH
-- just ignore this
END CATCH
GO

/****** Clean up tblKartrisSearchStatistics indexes ******/
CREATE NONCLUSTERED INDEX [SS_Date_Year_Month_Day] ON [dbo].[tblKartrisSearchStatistics]
(
	[SS_Date] ASC,
	[SS_Year] ASC,
	[SS_Month] ASC,
	[SS_Day] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisSessions indexes ******/
ALTER TABLE [dbo].[tblKartrisSessionValues] DROP CONSTRAINT [FK_tblKartrisSessionValues_tblKartrisSessions]
GO

ALTER TABLE [dbo].[tblKartrisSessions] DROP CONSTRAINT [aaaaatblKartrisSessions_PK]
GO
ALTER TABLE [dbo].[tblKartrisSessions] ADD  CONSTRAINT [PK_tblKartrisSessions] PRIMARY KEY CLUSTERED 
(
	[SESS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblKartrisSessionValues]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisSessionValues_tblKartrisSessions] FOREIGN KEY([SESSV_SessionID])
REFERENCES [dbo].[tblKartrisSessions] ([SESS_ID])
GO
ALTER TABLE [dbo].[tblKartrisSessionValues] CHECK CONSTRAINT [FK_tblKartrisSessionValues_tblKartrisSessions]
GO

/****** Clean up tblKartrisShippingMethods indexes ******/
DROP INDEX [SM_ID] ON [dbo].[tblKartrisShippingMethods]
GO
DROP INDEX [idxSM_ID] ON [dbo].[tblKartrisShippingMethods] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisShippingRates] DROP CONSTRAINT [FK_tblKartrisShippingRates_tblKartrisShippingMethods]
GO

ALTER TABLE [dbo].[tblKartrisShippingMethods] DROP CONSTRAINT [aaaaatblKartrisShippingMethods_PK]
GO
ALTER TABLE [dbo].[tblKartrisShippingMethods] ADD  CONSTRAINT [PK_tblKartrisShippingMethods] PRIMARY KEY CLUSTERED 
(
	[SM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblKartrisShippingRates]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisShippingRates_tblKartrisShippingMethods] FOREIGN KEY([S_ShippingMethodID])
REFERENCES [dbo].[tblKartrisShippingMethods] ([SM_ID])
GO
ALTER TABLE [dbo].[tblKartrisShippingRates] CHECK CONSTRAINT [FK_tblKartrisShippingRates_tblKartrisShippingMethods]
GO

/****** Clean up tblKartrisShippingMethods indexes ******/
DROP INDEX [idxS_ID] ON [dbo].[tblKartrisShippingRates] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisShippingRates] DROP CONSTRAINT [aaaaatblKartrisShippingRates_PK]
GO
ALTER TABLE [dbo].[tblKartrisShippingRates] ADD  CONSTRAINT [PK_tblKartrisShippingRates] PRIMARY KEY CLUSTERED 
(
	[S_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sp_rename '[dbo].[tblKartrisShippingRates].[uniqe_ShippingRates]', 'S_ShippingMethodID_ShippingZoneID_Boundary'
GO

/****** Clean up tblKartrisShippingZones indexes ******/
DROP INDEX [idxSZ_ID] ON [dbo].[tblKartrisShippingZones] WITH ( ONLINE = OFF )
GO

ALTER TABLE [dbo].[tblKartrisDestination] DROP CONSTRAINT [FK_tblKartrisDestination_tblKartrisShippingZones]
GO
ALTER TABLE [dbo].[tblKartrisShippingRates] DROP CONSTRAINT [FK_tblKartrisShippingRates_tblKartrisShippingZones]
GO

ALTER TABLE [dbo].[tblKartrisShippingZones] DROP CONSTRAINT [aaaaatblKartrisShippingZones_PK]
GO
ALTER TABLE [dbo].[tblKartrisShippingZones] ADD  CONSTRAINT [PK_tblKartrisShippingZones] PRIMARY KEY CLUSTERED 
(
	[SZ_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblKartrisShippingRates]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisShippingRates_tblKartrisShippingZones] FOREIGN KEY([S_ShippingZoneID])
REFERENCES [dbo].[tblKartrisShippingZones] ([SZ_ID])
GO
ALTER TABLE [dbo].[tblKartrisShippingRates] CHECK CONSTRAINT [FK_tblKartrisShippingRates_tblKartrisShippingZones]
GO
ALTER TABLE [dbo].[tblKartrisDestination]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisDestination_tblKartrisShippingZones] FOREIGN KEY([D_ShippingZoneID])
REFERENCES [dbo].[tblKartrisShippingZones] ([SZ_ID])
GO
ALTER TABLE [dbo].[tblKartrisDestination] CHECK CONSTRAINT [FK_tblKartrisDestination_tblKartrisShippingZones]
GO

/****** Clean up tblKartrisStatistics indexes ******/
ALTER TABLE [dbo].[tblKartrisStatistics] DROP CONSTRAINT [aaaaatblKartrisProductStats_PK]
GO
ALTER TABLE [dbo].[tblKartrisStatistics] ADD  CONSTRAINT [PK_tblKartrisStatistics] PRIMARY KEY CLUSTERED 
(
	[ST_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ST_ItemParentID] ON [dbo].[tblKartrisStatistics]
(
	[ST_ItemParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisSuppliers indexes ******/
DROP INDEX [SUP_ID] ON [dbo].[tblKartrisSuppliers]
GO
DROP INDEX [idxSUP_ID] ON [dbo].[tblKartrisSuppliers] WITH ( ONLINE = OFF )
GO

ALTER TABLE [dbo].[tblKartrisProducts] DROP CONSTRAINT [FK_tblKartrisProducts_tblKartrisSuppliers]
GO

ALTER TABLE [dbo].[tblKartrisSuppliers] DROP CONSTRAINT [aaaaatblKartrisSuppliers_PK]
GO
ALTER TABLE [dbo].[tblKartrisSuppliers] ADD  CONSTRAINT [PK_tblKartrisSuppliers] PRIMARY KEY CLUSTERED 
(
	[SUP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblKartrisProducts]  WITH NOCHECK ADD  CONSTRAINT [FK_tblKartrisProducts_tblKartrisSuppliers] FOREIGN KEY([P_SupplierID])
REFERENCES [dbo].[tblKartrisSuppliers] ([SUP_ID])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[tblKartrisProducts] CHECK CONSTRAINT [FK_tblKartrisProducts_tblKartrisSuppliers]
GO

/****** Clean up tblKartrisSupportTicketMessages indexes ******/
EXEC sp_rename '[dbo].[tblKartrisSupportTicketMessages].[STM_Various]', 'STM_TicketID_LoginID_STM_DateCreated'
GO

/****** Clean up tblKartrisSupportTickets indexes ******/
DROP INDEX [TIC_VariousFields] ON [dbo].[tblKartrisSupportTickets]
GO
CREATE NONCLUSTERED INDEX [TIC_LoginID] ON [dbo].[tblKartrisSupportTickets]
(
	[TIC_LoginID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TIC_Status] ON [dbo].[tblKartrisSupportTickets]
(
	[TIC_Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TIC_UserID] ON [dbo].[tblKartrisSupportTickets]
(
	[TIC_UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TIC_DateOpened_DateClosed] ON [dbo].[tblKartrisSupportTickets]
(
	[TIC_DateOpened] ASC,
	[TIC_DateClosed] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisTaxRates indexes ******/
DROP INDEX [T_ID] ON [dbo].[tblKartrisTaxRates]
GO
DROP INDEX [idxT_ID] ON [dbo].[tblKartrisTaxRates] WITH ( ONLINE = OFF )
GO

ALTER TABLE [dbo].[tblKartrisVersions] DROP CONSTRAINT [FK_tblKartrisVersions_tblKartrisTaxRates]
GO

ALTER TABLE [dbo].[tblKartrisTaxRates] DROP CONSTRAINT [aaaaatblKartrisTaxRates_PK]
GO
ALTER TABLE [dbo].[tblKartrisTaxRates] ADD  CONSTRAINT [PK_tblKartrisTaxRates] PRIMARY KEY CLUSTERED 
(
	[T_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblKartrisVersions]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisVersions_tblKartrisTaxRates] FOREIGN KEY([V_Tax])
REFERENCES [dbo].[tblKartrisTaxRates] ([T_ID])
GO
ALTER TABLE [dbo].[tblKartrisVersions] CHECK CONSTRAINT [FK_tblKartrisVersions_tblKartrisTaxRates]
GO

/****** Clean up tblKartrisUsers indexes ******/
BEGIN TRY
DROP INDEX [idxU_ID] ON [dbo].[tblKartrisUsers] WITH ( ONLINE = OFF )
END TRY
BEGIN CATCH
-- just ignore this
END CATCH
BEGIN TRY
EXEC sp_rename '[dbo].[tblKartrisUsers].[C_CustomerGroupiD]', 'U_CustomerGroupiD'
END TRY
BEGIN CATCH
-- just ignore this
END CATCH
BEGIN TRY
EXEC sp_rename '[dbo].[tblKartrisUsers].[C_LanguageID]', 'U_LanguageID'
END TRY
BEGIN CATCH
-- just ignore this
END CATCH
BEGIN TRY
EXEC sp_rename '[dbo].[tblKartrisUsers].[CD_AffiliateID]', 'U_AffiliateID'
END TRY
BEGIN CATCH
-- just ignore this
END CATCH
BEGIN TRY
DROP INDEX [CD_ID] ON [dbo].[tblKartrisUsers]
END TRY
BEGIN CATCH
-- just ignore this
END CATCH
BEGIN TRY
DROP INDEX [CD_CardholderEUVATNum] ON [dbo].[tblKartrisUsers]
END TRY
BEGIN CATCH
-- just ignore this
END CATCH
BEGIN TRY
ALTER TABLE [dbo].[tblKartrisUsers] DROP CONSTRAINT [aaaaatblKartrisCustomers_PK]
END TRY
BEGIN CATCH
-- just ignore this
END CATCH
BEGIN TRY
ALTER TABLE [dbo].[tblKartrisUsers] DROP CONSTRAINT [U_ID]
END TRY
BEGIN CATCH
-- just ignore this
END CATCH
GO

ALTER TABLE [dbo].[tblKartrisUsers] ADD  CONSTRAINT [PK_tblKartrisUsers] PRIMARY KEY CLUSTERED 
(
	[U_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisVersions indexes ******/
DROP INDEX [idxV_CodeNumber_ID] ON [dbo].[tblKartrisVersions] WITH ( ONLINE = OFF )
GO
DROP INDEX [V_CodeNumber_UNIQUE] ON [dbo].[tblKartrisVersions]
GO
DROP INDEX [V_ID] ON [dbo].[tblKartrisVersions]
GO
ALTER TABLE [dbo].[tblKartrisCustomerGroupPrices] DROP CONSTRAINT [FK_tblKartrisCustomerGroupPrices_tblKartrisVersions]
GO

ALTER TABLE [dbo].[tblKartrisVersionOptionLink] DROP CONSTRAINT [FK_tblKartrisVersionOptionLink_tblKartrisVersions]
GO

ALTER TABLE [dbo].[tblKartrisVersions] DROP CONSTRAINT [Versions_PK]
GO
ALTER TABLE [dbo].[tblKartrisVersions] ADD  CONSTRAINT [PK_tblKartrisVersions] PRIMARY KEY CLUSTERED 
(
	[V_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblKartrisVersionOptionLink]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisVersionOptionLink_tblKartrisVersions] FOREIGN KEY([V_OPT_VersionID])
REFERENCES [dbo].[tblKartrisVersions] ([V_ID])
GO
ALTER TABLE [dbo].[tblKartrisVersionOptionLink] CHECK CONSTRAINT [FK_tblKartrisVersionOptionLink_tblKartrisVersions]
GO

ALTER TABLE [dbo].[tblKartrisCustomerGroupPrices]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisCustomerGroupPrices_tblKartrisVersions] FOREIGN KEY([CGP_VersionID])
REFERENCES [dbo].[tblKartrisVersions] ([V_ID])
GO
ALTER TABLE [dbo].[tblKartrisCustomerGroupPrices] CHECK CONSTRAINT [FK_tblKartrisCustomerGroupPrices_tblKartrisVersions]
GO

CREATE NONCLUSTERED INDEX [V_Quantity_QuantityWarnLevel] ON [dbo].[tblKartrisVersions]
(
	[V_Quantity] ASC,
	[V_QuantityWarnLevel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [V_Live] ON [dbo].[tblKartrisVersions]
(
	[V_Live] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [V_Tax] ON [dbo].[tblKartrisVersions]
(
	[V_Tax] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [V_Price] ON [dbo].[tblKartrisVersions]
(
	[V_Price] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [V_OrderByValue] ON [dbo].[tblKartrisVersions]
(
	[V_OrderByValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Clean up tblKartrisWishLists indexes ******/
EXEC sp_rename '[dbo].[tblKartrisWishLists].[WL_CustomerID]', 'WL_UserID'
GO
DROP INDEX [idxWL_ID] ON [dbo].[tblKartrisWishLists] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisWishLists] DROP CONSTRAINT [aaaaatblKartrisWishList_PK]
GO
ALTER TABLE [dbo].[tblKartrisWishLists] ADD  CONSTRAINT [PK_tblKartrisWishLists] PRIMARY KEY CLUSTERED 
(
	[WL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Change SH_Price field to decimal ******/
DROP INDEX [SH_Price] ON [dbo].[tblKartrisSearchHelper]
GO

ALTER TABLE dbo.tblKartrisSearchHelper 
ALTER COLUMN SH_Price decimal(18, 4);
GO

CREATE NONCLUSTERED INDEX [SH_Price] ON [dbo].[tblKartrisSearchHelper]
(
	[SH_Price] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tblKartrisProductSearchIndex]    Script Date: 02/06/2022 10:34:14 ******/
-- NEW TABLE! 
-- For performance, we try to maintain an index of min and max price for each product in
-- this table. A trigger will try to calculation this and update the index whenever a version
-- is added, deleted or updated.
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblKartrisProductSearchIndex](
	[PSI_ProductID] [int] NOT NULL,
	[PSI_MinPrice] [decimal](18, 4) NULL,
	[PSI_MaxPrice] [decimal](18, 4) NULL,
	[PSI_LastUpdated] [datetime] NULL,
 CONSTRAINT [PK_tblKartrisProductSearchIndex] PRIMARY KEY CLUSTERED 
(
	[PSI_ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [PSI_LastUpdated] ON [dbo].[tblKartrisProductSearchIndex]
(
	[PSI_LastUpdated] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [PSI_MaxPrice] ON [dbo].[tblKartrisProductSearchIndex]
(
	[PSI_MaxPrice] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [PSI_MinPrice] ON [dbo].[tblKartrisProductSearchIndex]
(
	[PSI_MinPrice] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  UserDefinedFunction [dbo].[fnKartrisProduct_GetMaxPrice]    Script Date: 03/06/2022 12:54:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Updated: Paul - Jun 2022
-- Use just highest version price if not an 
-- options product because has combinations
-- =============================================
ALTER FUNCTION [dbo].[fnKartrisProduct_GetMaxPrice] 
(
	-- Add the parameters for the function here
	@V_ProductID as int
	
)
RETURNS real
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result decimal(18,4);

	-- Declare version and option parts of price
	DECLARE @VersionPrice decimal(18,4) = 0;
	DECLARE @OptionsPrice decimal(18,4) = 0;

	-- Get version price
	SELECT @VersionPrice = Max(V_Price) 
	FROM tblKartrisVersions INNER JOIN [dbo].[tblKartrisTaxRates]
			ON [V_Tax] = [T_ID]
	WHERE V_ProductID = @V_ProductID AND V_Live = 1 AND tblKartrisVersions.V_CustomerGroupID IS NULL;

	-- If options product (no combinations) then total up option modifiers
	DECLARE @NumberOfCombinations int;
	SELECT @NumberOfCombinations = (SELECT COUNT(1) FROM dbo.tblKartrisVersions WHERE V_ProductID = @V_ProductID AND V_Type='c' AND V_Live=1)
	IF @NumberOfCombinations = 0 
	BEGIN
		-- Get options price
		SELECT @OptionsPrice = Sum(T.MaxPriceChange) FROM
		(SELECT P_OPT_ProductID, OPTG_ID, Max(P_OPT_PriceChange) As MaxPriceChange FROM dbo.tblKartrisOptionGroups INNER JOIN
							 dbo.tblKartrisOptions ON dbo.tblKartrisOptionGroups.OPTG_ID = dbo.tblKartrisOptions.OPT_OptionGroupID INNER JOIN
							 dbo.tblKartrisProductOptionGroupLink ON dbo.tblKartrisOptionGroups.OPTG_ID = dbo.tblKartrisProductOptionGroupLink.P_OPTG_OptionGroupID INNER JOIN
							 dbo.tblKartrisProductOptionLink ON dbo.tblKartrisOptions.OPT_ID = dbo.tblKartrisProductOptionLink.P_OPT_OptionID 
		WHERE P_OPT_ProductID = @V_ProductID
		GROUP BY P_OPT_ProductID, OPTG_ID) As T
	END

	IF @VersionPrice IS NULL
	BEGIN
		SET @VersionPrice = 0;
	END
	IF @OptionsPrice IS NULL
	BEGIN
		SET @OptionsPrice = 0;
	END

	SET @Result = @VersionPrice + @OptionsPrice

	-- Return the result of the function
	RETURN @Result

END
GO

/****** Object:  UserDefinedFunction [dbo].[fnKartrisProduct_GetMinPrice]    Script Date: 03/06/2022 12:51:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Updated: Paul - Jun 2022
-- Need to take account of options that could
-- reduce price below version min
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
	DECLARE @Result decimal(18,4) = 0;

	-- Declare version and option parts of price
	DECLARE @VersionPrice decimal(18,4) = 0;
	DECLARE @OptionsPrice decimal(18,4) = 0;

	-- versions/qty discounts
	SELECT @VersionPrice = Min(V_Price) FROM tblKartrisVersions WHERE V_ProductID = @V_ProductID AND V_Live = 1 AND tblKartrisVersions.V_CustomerGroupID IS NULL;
	
	DECLARE @QD_MinPrice as real;
	SELECT @QD_MinPrice = Min(QD_Price)
	FROM dbo.tblKartrisQuantityDiscounts INNER JOIN tblKartrisVersions 
		ON tblKartrisQuantityDiscounts.QD_VersionID = tblKartrisVersions.V_ID
	WHERE tblKartrisVersions.V_Live = 1 AND tblKartrisVersions.V_ProductID = @V_ProductID AND tblKartrisVersions.V_CustomerGroupID IS NULL;

	IF @QD_MinPrice <> 0 AND @QD_MinPrice IS NOT NULL AND @QD_MinPrice < @VersionPrice
	BEGIN
		SET @VersionPrice = @QD_MinPrice
	END

	-- If not combination product, we have to find lowest option modifier
	DECLARE @NumberOfCombinations int;
	SELECT @NumberOfCombinations = (SELECT COUNT(1) FROM dbo.tblKartrisVersions WHERE V_ProductID = @V_ProductID AND V_Type='c' AND V_Live=1)
	IF @NumberOfCombinations = 0 
	BEGIN
		-- Get options price
		SELECT @OptionsPrice = Sum(T.MinPriceChange) FROM
		(SELECT P_OPT_ProductID, OPTG_ID, Min(P_OPT_PriceChange) As MinPriceChange FROM dbo.tblKartrisOptionGroups INNER JOIN
							 dbo.tblKartrisOptions ON dbo.tblKartrisOptionGroups.OPTG_ID = dbo.tblKartrisOptions.OPT_OptionGroupID INNER JOIN
							 dbo.tblKartrisProductOptionGroupLink ON dbo.tblKartrisOptionGroups.OPTG_ID = dbo.tblKartrisProductOptionGroupLink.P_OPTG_OptionGroupID INNER JOIN
							 dbo.tblKartrisProductOptionLink ON dbo.tblKartrisOptions.OPT_ID = dbo.tblKartrisProductOptionLink.P_OPT_OptionID 
		WHERE P_OPT_ProductID = @V_ProductID
		GROUP BY P_OPT_ProductID, OPTG_ID) As T
	END

	IF @VersionPrice IS NULL
	BEGIN
		SET @VersionPrice = 0;
	END
	IF @OptionsPrice IS NULL
	BEGIN
		SET @OptionsPrice = 0;
	END

	SET @Result = @VersionPrice + @OptionsPrice

	-- Return the result of the function
	RETURN @Result

END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_RecalculateMinMaxPrice]    Script Date: 02/06/2022 14:31:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: 02 Jun 2022
-- Description:	Used to update the product
-- search index table records
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_RecalculateMinMaxPrice]
(	
	@P_ID as integer
)
AS
BEGIN
	IF exists(SELECT 1 FROM dbo.tblKartrisProductSearchIndex Where PSI_ProductID = @P_ID)
	-- UPDATE EXISTING RECORD
	  BEGIN
		UPDATE tblKartrisProductSearchIndex SET PSI_LastUpdated = GetDate(),
		PSI_MaxPrice = dbo.fnKartrisProduct_GetMaxPrice(@P_ID),
		PSI_MinPrice = dbo.fnKartrisProduct_GetMinPrice(@P_ID)	
		WHERE PSI_ProductID = @P_ID
	   END
	ELSE
	-- INSERT NEW RECORD
	  BEGIN
		INSERT INTO tblKartrisProductSearchIndex (PSI_ProductID,
		PSI_LastUpdated,
		PSI_MaxPrice,
		PSI_MinPrice)
		VALUES (@P_ID,
		GetDate(),
		dbo.fnKartrisProduct_GetMaxPrice(@P_ID),
		dbo.fnKartrisProduct_GetMinPrice(@P_ID))
	   END
END
GO

/****** Triggers to refresh min/max price for product ******/
-- UPDATING EXISTING VERSION
CREATE TRIGGER [dbo].[updateVersions]
ON [dbo].[tblKartrisVersions]
FOR UPDATE 
AS
IF UPDATE(V_Price) 
BEGIN
	DECLARE @P_ID int
	DECLARE @Count int = 0
	SELECT @Count = Count(1) FROM INSERTED -- May not be any records
	IF (@Count > 0) 
	BEGIN
		SELECT @P_ID = V_ProductID FROM INSERTED
		EXEC dbo._spKartrisProducts_RecalculateMinMaxPrice @P_ID
	END
END
GO

ALTER TABLE [dbo].[tblKartrisVersions] ENABLE TRIGGER [updateVersions]
GO

-- INSERTING NEW VERSION
CREATE TRIGGER [dbo].[insertVersions]
ON [dbo].[tblKartrisVersions]
AFTER INSERT 
AS
BEGIN
	DECLARE @P_ID int
	DECLARE @Count int = 0
	SELECT @Count = Count(1) FROM INSERTED -- May not be any records
	IF (@Count > 0) 
	BEGIN
		SELECT @P_ID = V_ProductID FROM INSERTED
		EXEC dbo._spKartrisProducts_RecalculateMinMaxPrice @P_ID
	END
END
GO

ALTER TABLE [dbo].[tblKartrisVersions] ENABLE TRIGGER [insertVersions]
GO
    
-- DELETING VERSION
CREATE TRIGGER [dbo].[deleteVersions]
ON [dbo].[tblKartrisVersions]
AFTER DELETE
AS
BEGIN
	DECLARE @P_ID int
	DECLARE @Count int = 0
	SELECT @Count = Count(1) FROM DELETED -- May not be any records
	IF (@Count > 0) 
	BEGIN
		SELECT @P_ID = V_ProductID FROM DELETED
		EXEC dbo._spKartrisProducts_RecalculateMinMaxPrice @P_ID
	END
END
GO

ALTER TABLE [dbo].[tblKartrisVersions] ENABLE TRIGGER [deleteVersions]
GO

-- INSERTING NEW QTY DISCOUNT
CREATE TRIGGER [dbo].[insertQuantityDiscounts]
ON [dbo].[tblKartrisQuantityDiscounts]
AFTER INSERT 
AS
BEGIN
	DECLARE @P_ID int
	DECLARE @V_ID int
	DECLARE @Count int = 0
	SELECT @Count = Count(1) FROM INSERTED -- May not be any records
	IF (@Count > 0)
	BEGIN
		SELECT @V_ID = QD_VersionID FROM INSERTED
		SELECT @P_ID = V_ProductID FROM tblKartrisVersions WHERE V_ID = @V_ID
		EXEC dbo._spKartrisProducts_RecalculateMinMaxPrice @P_ID
	END
END
GO

ALTER TABLE [dbo].[tblKartrisQuantityDiscounts] ENABLE TRIGGER [insertQuantityDiscounts]
GO
    
-- DELETING QTY DISCOUNT
CREATE TRIGGER [dbo].[deleteQuantityDiscounts]
ON [dbo].[tblKartrisQuantityDiscounts]
AFTER DELETE
AS
BEGIN
	DECLARE @P_ID int
	DECLARE @V_ID int
	DECLARE @Count int = 0
	SELECT @Count = Count(1) FROM DELETED -- May not be any records
	IF (@Count > 0) 
	BEGIN
		SELECT @V_ID = QD_VersionID FROM DELETED
		SELECT @P_ID = V_ProductID FROM tblKartrisVersions WHERE V_ID = @V_ID
		EXEC dbo._spKartrisProducts_RecalculateMinMaxPrice @P_ID
	END
END
GO

ALTER TABLE [dbo].[tblKartrisQuantityDiscounts] ENABLE TRIGGER [deleteQuantityDiscounts]
GO

-- DELETING PRODUCT
-- If a product is deleted, we should clear up the corresponding
-- search index record to keep things tidy. Nobody wants to create
-- orphans!
CREATE TRIGGER [dbo].[deleteProducts]
ON [dbo].[tblKartrisProducts]
AFTER DELETE
AS
BEGIN
	DECLARE @P_ID int
	DECLARE @Count int = 0
	SELECT @Count = Count(1) FROM DELETED -- May not be any records
	IF (@Count > 0)
	BEGIN
		SELECT @P_ID = P_ID FROM DELETED
		DELETE FROM tblKartrisProductSearchIndex WHERE PSI_ProductID = @P_ID
	END
END
GO

ALTER TABLE [dbo].[tblKartrisProducts] ENABLE TRIGGER [deleteProducts]
GO

/****** Fill the Product Search Index with data ******/
-- When we upgrade, we need to go through and create the search index for
-- all existing products. This could take a long time, but has to be done
-- so we know we have the data for other places to use.

-- Declare & init (2008 syntax)
DECLARE @P_ID INT = 0

-- Iterate over all customers
WHILE (1 = 1) 
BEGIN  

  -- Get next customerId
  SELECT TOP 1 @P_ID = P_ID
  FROM tblKartrisProducts
  WHERE P_ID > @P_ID 
  ORDER BY P_ID

  -- Exit loop if no more customers
  IF @@ROWCOUNT = 0 BREAK;

  -- call your sproc
  EXEC dbo._spKartrisProducts_RecalculateMinMaxPrice @P_ID

END
GO

/****** Object:  View [dbo].[vKartrisTypeProductsLiteWithPrices]    Script Date: 03/06/2022 12:20:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vKartrisTypeProductsLiteWithPrices]
WITH SCHEMABINDING 
AS
SELECT        dbo.tblKartrisProducts.P_ID, dbo.tblKartrisLanguages.LANG_ID, CAST(dbo.tblKartrisLanguageElements.LE_Value AS NVARCHAR(255)) AS P_Name, dbo.tblKartrisProducts.P_Featured, dbo.tblKartrisProducts.P_Type, 
                         dbo.tblKartrisProducts.P_CustomerGroupID, dbo.tblKartrisProducts.P_AverageRating, dbo.tblKartrisProductSearchIndex.PSI_MinPrice, dbo.tblKartrisProductSearchIndex.PSI_MaxPrice, dbo.tblKartrisProducts.P_SupplierID
FROM            dbo.tblKartrisLanguageElements INNER JOIN
                         dbo.tblKartrisLanguages ON dbo.tblKartrisLanguageElements.LE_LanguageID = dbo.tblKartrisLanguages.LANG_ID INNER JOIN
                         dbo.tblKartrisProducts ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisProducts.P_ID INNER JOIN
                         dbo.tblKartrisProductSearchIndex ON dbo.tblKartrisProducts.P_ID = dbo.tblKartrisProductSearchIndex.PSI_ProductID
WHERE        (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (NOT (dbo.tblKartrisLanguageElements.LE_Value IS NULL)) AND (dbo.tblKartrisLanguageElements.LE_TypeID = 2) AND (dbo.tblKartrisProducts.P_Live = 1)
GO

/****** Object:  View [dbo].[vKartrisCategoryProductsVersionsLink]    Script Date: 7/21/2014 11:55:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vKartrisCategoryProductsVersionsLink]
AS
SELECT        P_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType, P_Type, T_Taxrate, CAT_ID, P_Live, CAT_Live, V_Live, V_ID, V_CodeNumber, V_Price, V_Tax, V_Weight, V_DeliveryTime, V_Quantity, 
						 V_QuantityWarnLevel, V_DownLoadInfo, V_DownloadType, V_RRP, V_OrderByValue, V_Type, V_CustomerGroupID, P_Featured, P_SupplierID, P_CustomerGroupID, P_Reviews, P_AverageRating, P_DateCreated, 
						 V_CustomizationType, V_CustomizationDesc, V_CustomizationCost, T_TaxRate2, CAT_CustomerGroupID, HasCombinations, PSI_MinPrice, PSI_MaxPrice
FROM            (SELECT        dbo.tblKartrisProducts.P_ID, dbo.tblKartrisProducts.P_OrderVersionsBy, dbo.tblKartrisProducts.P_VersionsSortDirection, dbo.tblKartrisProducts.P_VersionDisplayType, dbo.tblKartrisProducts.P_Type, 
													tblKartrisTaxRates_1.T_Taxrate, dbo.tblKartrisProductCategoryLink.PCAT_CategoryID AS CAT_ID, dbo.tblKartrisProducts.P_Live, dbo.tblKartrisCategories.CAT_Live, dbo.tblKartrisVersions.V_Live, 
													dbo.tblKartrisVersions.V_ID, dbo.tblKartrisVersions.V_CodeNumber, dbo.tblKartrisVersions.V_Price, dbo.tblKartrisVersions.V_Tax, dbo.tblKartrisVersions.V_Weight, dbo.tblKartrisVersions.V_DeliveryTime, 
													dbo.tblKartrisVersions.V_Quantity, dbo.tblKartrisVersions.V_QuantityWarnLevel, dbo.tblKartrisVersions.V_DownLoadInfo, dbo.tblKartrisVersions.V_DownloadType, dbo.tblKartrisVersions.V_RRP, 
													dbo.tblKartrisVersions.V_OrderByValue, dbo.tblKartrisVersions.V_Type, dbo.tblKartrisVersions.V_CustomerGroupID, dbo.tblKartrisProducts.P_Featured, dbo.tblKartrisProducts.P_SupplierID, 
													dbo.tblKartrisProducts.P_CustomerGroupID, dbo.tblKartrisProducts.P_Reviews, dbo.tblKartrisProducts.P_AverageRating, dbo.tblKartrisProducts.P_DateCreated, dbo.tblKartrisVersions.V_CustomizationType, 
													dbo.tblKartrisVersions.V_CustomizationDesc, dbo.tblKartrisVersions.V_CustomizationCost, dbo.tblKartrisTaxRates.T_Taxrate AS T_TaxRate2, dbo.tblKartrisCategories.CAT_CustomerGroupID, 
													CASE WHEN EXISTS
														(SELECT        TOP 1 1
														  FROM            tblKartrisVersions MyTableCheck
														  WHERE        MyTableCheck.V_ProductID = tblKartrisVersions.V_ProductID AND MyTableCheck.V_Type = 'c') THEN 1 ELSE 0 END AS HasCombinations,
														  dbo.tblKartrisProductSearchIndex.PSI_MinPrice, dbo.tblKartrisProductSearchIndex.PSI_MaxPrice
FROM            dbo.tblKartrisCategories INNER JOIN
                         dbo.tblKartrisProductCategoryLink ON dbo.tblKartrisCategories.CAT_ID = dbo.tblKartrisProductCategoryLink.PCAT_CategoryID INNER JOIN
                         dbo.tblKartrisProducts ON dbo.tblKartrisProductCategoryLink.PCAT_ProductID = dbo.tblKartrisProducts.P_ID INNER JOIN
                         dbo.tblKartrisProductSearchIndex ON dbo.tblKartrisProducts.P_ID = dbo.tblKartrisProductSearchIndex.PSI_ProductID LEFT OUTER JOIN
                         dbo.tblKartrisVersions LEFT OUTER JOIN
                         dbo.tblKartrisTaxRates AS tblKartrisTaxRates_1 ON dbo.tblKartrisVersions.V_Tax = tblKartrisTaxRates_1.T_ID LEFT OUTER JOIN
                         dbo.tblKartrisTaxRates ON dbo.tblKartrisVersions.V_Tax2 = dbo.tblKartrisTaxRates.T_ID ON dbo.tblKartrisProducts.P_ID = dbo.tblKartrisVersions.V_ProductID
						  WHERE        (dbo.tblKartrisCategories.CAT_Live = 1) AND (dbo.tblKartrisVersions.V_Live = 1) AND (dbo.tblKartrisProducts.P_Live = 1)) AS viewCategories
GROUP BY P_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType, P_Type, T_Taxrate, CAT_ID, P_Live, CAT_Live, V_Live, V_ID, V_CodeNumber, V_Price, V_Tax, V_Weight, V_DeliveryTime, V_Quantity, 
						 V_QuantityWarnLevel, V_DownLoadInfo, V_DownloadType, V_RRP, V_OrderByValue, V_Type, V_CustomerGroupID, P_Featured, P_SupplierID, P_CustomerGroupID, P_Reviews, P_AverageRating, P_DateCreated, 
						 V_CustomizationType, V_CustomizationDesc, V_CustomizationCost, T_TaxRate2, CAT_CustomerGroupID, HasCombinations, PSI_MinPrice, PSI_MaxPrice
GO

/****** Object:  View [dbo].[vKartrisVersionsStock]    Script Date: 06/06/2022 12:45:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vKartrisVersionsStock]
AS
SELECT        V_ID, V_Quantity, V_QuantityWarnLevel, V_Type, HasCombinations
FROM            (SELECT        dbo.tblKartrisVersions.V_ID, dbo.tblKartrisVersions.V_Quantity, dbo.tblKartrisVersions.V_QuantityWarnLevel, dbo.tblKartrisVersions.V_Type, CASE WHEN EXISTS
														(SELECT        TOP 1 1
														  FROM            tblKartrisVersions MyTableCheck
														  WHERE        MyTableCheck.V_ProductID = tblKartrisVersions.V_ProductID AND MyTableCheck.V_Type = 'c') THEN 1 ELSE 0 END AS HasCombinations
						  FROM            dbo.tblKartrisCategories INNER JOIN
													dbo.tblKartrisProductCategoryLink ON dbo.tblKartrisCategories.CAT_ID = dbo.tblKartrisProductCategoryLink.PCAT_CategoryID INNER JOIN
													dbo.tblKartrisProducts ON dbo.tblKartrisProductCategoryLink.PCAT_ProductID = dbo.tblKartrisProducts.P_ID INNER JOIN
													dbo.tblKartrisVersions ON dbo.tblKartrisProducts.P_ID = dbo.tblKartrisVersions.V_ProductID
						  WHERE        (dbo.tblKartrisCategories.CAT_Live = 1) AND (dbo.tblKartrisProducts.P_Live = 1) AND (dbo.tblKartrisVersions.V_Live = 1)) AS viewVersions
GROUP BY V_ID, V_Quantity, V_QuantityWarnLevel, V_Type, HasCombinations
GO

/****** Object:  View [dbo].[vKartrisTypeProducts]    Script Date: 03/06/2022 16:10:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vKartrisTypeProducts]
AS
SELECT        dbo.tblKartrisProducts.P_ID, dbo.tblKartrisLanguages.LANG_ID, dbo.tblKartrisLanguageElements.LE_Value AS P_Name, tblKartrisLanguageElements_1.LE_Value AS P_Desc, 
                         tblKartrisLanguageElements_2.LE_Value AS P_StrapLine, tblKartrisLanguageElements_3.LE_Value AS P_PageTitle, dbo.tblKartrisProducts.P_Live, dbo.tblKartrisProducts.P_Featured, dbo.tblKartrisProducts.P_OrderVersionsBy, 
                         dbo.tblKartrisProducts.P_VersionsSortDirection, dbo.tblKartrisProducts.P_VersionDisplayType, dbo.tblKartrisProducts.P_Reviews, dbo.tblKartrisProducts.P_SupplierID, dbo.tblKartrisProducts.P_Type, 
                         dbo.tblKartrisProducts.P_CustomerGroupID, dbo.tblKartrisProducts.P_AverageRating, dbo.tblKartrisProducts.P_DateCreated, dbo.tblKartrisProducts.P_LastModified, dbo.tblKartrisProductSearchIndex.PSI_MinPrice, 
                         dbo.tblKartrisProductSearchIndex.PSI_MaxPrice
FROM            dbo.tblKartrisLanguageElements INNER JOIN
                         dbo.tblKartrisLanguages ON dbo.tblKartrisLanguageElements.LE_LanguageID = dbo.tblKartrisLanguages.LANG_ID INNER JOIN
                         dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_1 ON dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_1.LE_LanguageID INNER JOIN
                         dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_2 ON dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_2.LE_LanguageID INNER JOIN
                         dbo.tblKartrisProducts ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisProducts.P_ID AND tblKartrisLanguageElements_1.LE_ParentID = dbo.tblKartrisProducts.P_ID AND 
                         tblKartrisLanguageElements_2.LE_ParentID = dbo.tblKartrisProducts.P_ID INNER JOIN
                         dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_3 ON dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_3.LE_LanguageID AND 
                         dbo.tblKartrisProducts.P_ID = tblKartrisLanguageElements_3.LE_ParentID INNER JOIN
                         dbo.tblKartrisProductSearchIndex ON dbo.tblKartrisProducts.P_ID = dbo.tblKartrisProductSearchIndex.PSI_ProductID
WHERE        (dbo.tblKartrisLanguageElements.LE_TypeID = 2) AND (tblKartrisLanguageElements_1.LE_TypeID = 2) AND (tblKartrisLanguageElements_2.LE_TypeID = 2) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND 
                         (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (tblKartrisLanguageElements_2.LE_FieldID = 7) AND (NOT (dbo.tblKartrisLanguageElements.LE_Value IS NULL)) AND (tblKartrisLanguageElements_3.LE_TypeID = 2) AND 
                         (tblKartrisLanguageElements_3.LE_FieldID = 3) OR
                         (dbo.tblKartrisLanguageElements.LE_TypeID = 2) AND (tblKartrisLanguageElements_1.LE_TypeID = 2) AND (tblKartrisLanguageElements_2.LE_TypeID = 2) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND 
                         (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (tblKartrisLanguageElements_2.LE_FieldID = 7) AND (tblKartrisLanguageElements_3.LE_TypeID = 2) AND (tblKartrisLanguageElements_3.LE_FieldID = 3) AND 
                         (NOT (tblKartrisLanguageElements_1.LE_Value IS NULL)) OR
                         (dbo.tblKartrisLanguageElements.LE_TypeID = 2) AND (tblKartrisLanguageElements_1.LE_TypeID = 2) AND (tblKartrisLanguageElements_2.LE_TypeID = 2) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND 
                         (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (tblKartrisLanguageElements_2.LE_FieldID = 7) AND (tblKartrisLanguageElements_3.LE_TypeID = 2) AND (tblKartrisLanguageElements_3.LE_FieldID = 3) AND 
                         (NOT (tblKartrisLanguageElements_2.LE_Value IS NULL)) OR
                         (dbo.tblKartrisLanguageElements.LE_TypeID = 2) AND (tblKartrisLanguageElements_1.LE_TypeID = 2) AND (tblKartrisLanguageElements_2.LE_TypeID = 2) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND 
                         (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (tblKartrisLanguageElements_2.LE_FieldID = 7) AND (tblKartrisLanguageElements_3.LE_TypeID = 2) AND (tblKartrisLanguageElements_3.LE_FieldID = 3) AND 
                         (NOT (tblKartrisLanguageElements_3.LE_Value IS NULL))
GO

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
		--UPDATE tblKartrisSearchHelper
		--SET SH_Price = dbo.fnKartrisProduct_GetMinPriceWithCG(SH_ProductID, @CustomerGroupID)
		--WHERE SH_SessionID = @@SPID;
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
	IF @MinPrice <> -1 AND @MaxPrice <> -1 BEGIN
		--UPDATE tblKartrisSearchHelper
		--SET SH_Price = dbo.fnKartrisProduct_GetMinPriceWithCG(SH_ProductID, @CustomerGroupID)
		--WHERE SH_SessionID = @@SPID;
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

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetNewestProducts]    Script Date: 01/23/2013 21:59:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Mohammad/Paul/Joni
-- Uses product search index table to get min
-- price more efficiently
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisProducts_GetNewestProducts]
	(
	@LANG_ID tinyint
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT DISTINCT products.P_ID, products.P_Name, products.PSI_MinPrice As MinPrice, LANG_ID
	FROM (
		SELECT DISTINCT TOP (10) P_ID, P_Name, PSI_MinPrice, LANG_ID
		FROM    dbo.vKartrisTypeProductsLiteWithPrices
		WHERE   (P_CustomerGroupID IS NULL) AND
			   (LANG_ID = @LANG_ID)
		ORDER BY P_ID DESC
	) as products
	INNER JOIN tblKartrisVersions ON products.P_ID = tblKartrisVersions.V_ProductID INNER JOIN
			  tblKartrisProductCategoryLink ON products.P_ID = tblKartrisProductCategoryLink.PCAT_ProductID INNER JOIN
			  tblKartrisCategories ON tblKartrisProductCategoryLink.PCAT_CategoryID = tblKartrisCategories.CAT_ID
	WHERE (tblKartrisCategories.CAT_CustomerGroupID IS NULL) AND (tblKartrisVersions.V_CustomerGroupID IS NULL) 
	ORDER BY products.P_ID DESC

END
GO

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetFeaturedProducts]    Script Date: 03/06/2022 12:25:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Medz
-- Last Modified: Paul - Jun 2022
-- Uses product search index table to get min
-- price more efficiently
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
					PSI_MinPrice as MinPrice, P_Reviews, 
						  P_Featured, P_CustomerGroupID, MIN(T_Taxrate) AS MinTax
		FROM         vKartrisCategoryProductsVersionsLink
		WHERE     (P_Featured <> 0) AND (P_CustomerGroupID IS NULL)
		GROUP BY P_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType, P_Type, PSI_MinPrice, P_CustomerGroupID, P_Reviews, P_Featured
		
	)
	SELECT FeaturedProducts.*, LANG_ID, P_Name, P_Desc, P_StrapLine, P_PageTitle
	FROM FeaturedProducts INNER JOIN [dbo].[vKartrisTypeProducts] ON FeaturedProducts.P_ID = vKartrisTypeProducts.P_ID
	ORDER BY P_Featured DESC

END
GO

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetByProductID]    Script Date: 03/06/2022 12:33:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===================================================
-- Author:		Medz
-- Last Modified: Paul - Jun 2022
-- Uses product search index table to get min
-- price more efficiently
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
		SELECT     P_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType, P_Type, PSI_MinPrice AS MinPrice, 
				P_Reviews, P_Featured, P_CustomerGroupID, MIN(T_Taxrate) AS MinTax
		FROM         vKartrisCategoryProductsVersionsLink
		WHERE     (P_ID = @P_ID) AND (V_Type = 'b' OR V_Type = 'v' )
		GROUP BY P_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType, P_Type, PSI_MinPrice, P_Featured, P_CustomerGroupID, P_Reviews
	)
	SELECT Products.*, P_Name, P_Desc, P_StrapLine, P_PageTitle
	FROM Products INNER JOIN [dbo].[vKartrisTypeProducts] ON Products.P_ID = vKartrisTypeProducts.P_ID
	WHERE LANG_ID = @LANG_ID
END
GO

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetSpecials]    Script Date: 03/06/2022 12:37:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Medz
-- Last Modified: Paul - Jun 2022
-- Uses product search index table to get min
-- price more efficiently
-- =============================================

ALTER PROCEDURE [dbo].[spKartrisProducts_GetSpecials]
(
	@LANG_ID tinyint
)
AS
BEGIN
	WITH SpecialProducts AS
	(
		SELECT     P_ID, P_OrderVersionsBy, P_VersionDisplayType, P_Type, PSI_MinPrice AS MinPrice, MIN(T_Taxrate) AS MinTax
		FROM         vKartrisCategoryProductsVersionsLink
		GROUP BY P_ID, P_OrderVersionsBy, P_VersionDisplayType, P_Type, PSI_MinPrice, P_Featured
		HAVING      (P_Featured = 1)
	)
	SELECT SpecialProducts.*, P_Name, P_Desc, P_StrapLine, P_PageTitle
	FROM SpecialProducts INNER JOIN [dbo].[vKartrisTypeProducts] ON SpecialProducts.P_ID = vKartrisTypeProducts.P_ID
	WHERE     (LANG_ID = @LANG_ID)
END
GO

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetRichSnippetProperties]    Script Date: 03/06/2022 12:39:24 ******/
-- Use decimal values for money
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[spKartrisProducts_GetRichSnippetProperties]
(
	@P_ID as integer,
	@LANG_ID as tinyint
)
AS
BEGIN
	DECLARE @P_Name as nvarchar(max), @P_Desc as nvarchar(max), 
			@P_Category as nvarchar(max), @P_SKU as nvarchar(25), @P_Type as char(1),
			@P_Price as decimal(18,4), @P_MinPrice as decimal(18,4), @P_MaxPrice as decimal(18,4), 
			@P_StockQuantity as decimal(18,4), @P_WarnLevel as decimal(18,4),
			@P_Rev as char(1), @Rev_Avg as real, @Rev_Total as int,
			@P_CallForPrice as int;
	
	SET @P_CallForPrice = (SELECT TOP (1) [OCV_Value] FROM [dbo].[tblKartrisObjectConfigValue] WHERE OCV_ParentID = @P_ID AND OCV_ObjectConfigID = 1)
	IF @P_CallForPrice != 1
	BEGIN
		SET @P_CallForPrice = 0
	END


	SELECT Top(1) @P_Category = vKartrisTypeCategories.CAT_Name
	FROM  vKartrisTypeCategories INNER JOIN tblKartrisProductCategoryLink 
			ON vKartrisTypeCategories.CAT_ID = tblKartrisProductCategoryLink.PCAT_CategoryID
	WHERE (vKartrisTypeCategories.LANG_ID = @LANG_ID) AND (tblKartrisProductCategoryLink.PCAT_ProductID = @P_ID)

	SELECT @P_Name = [P_Name], @P_Desc = [P_Desc], @P_Type = [P_Type], @P_Rev = [P_Reviews]
	FROM [dbo].[vKartrisTypeProducts]
	WHERE [P_ID] = @P_ID AND [LANG_ID] = @LANG_ID;

	IF @P_Rev = 'y' BEGIN
		SELECT @Rev_Total = Count(1), @Rev_Avg = AVG([REV_Rating])
		FROM [dbo].[tblKartrisReviews]
		WHERE [REV_ProductID] = @P_ID AND [REV_Live] = 'y'
	END

	IF @P_Type = 's' BEGIN
		SELECT Top(1) @P_SKU = [V_CodeNumber], @P_Price = [V_Price], 
			@P_StockQuantity = [V_Quantity], @P_WarnLevel = [V_QuantityWarnLevel]
		FROM [dbo].[tblKartrisVersions]
		WHERE [V_ProductID] = @P_ID AND [V_Live] = 1;
	END 
	IF @P_Type = 'm' BEGIN
		SELECT Top(1) @P_SKU = [V_CodeNumber], 
			@P_StockQuantity = [V_Quantity], @P_WarnLevel = [V_QuantityWarnLevel]
		FROM [dbo].[tblKartrisVersions]
		WHERE [V_ProductID] = @P_ID AND [V_Live] = 1;
		SELECT @P_MinPrice = [dbo].[fnKartrisProduct_GetMinPrice](@P_ID);
		SELECT @P_MaxPrice = [dbo].[fnKartrisProduct_GetMaxPrice](@P_ID);
	END 
	IF @P_Type = 'o' BEGIN
		SELECT Top(1) @P_SKU = [V_CodeNumber], 
			@P_StockQuantity = [V_Quantity], @P_WarnLevel = [V_QuantityWarnLevel]
		FROM [dbo].[tblKartrisVersions]
		WHERE [V_ProductID] = @P_ID AND [V_Type] = 'b' AND [V_Live] = 1;
		
		SELECT @P_MinPrice = [dbo].[fnKartrisProduct_GetMinPrice](@P_ID);
		SELECT @P_MaxPrice = [dbo].[fnKartrisProduct_GetMaxPrice](@P_ID);
	END

	SELECT @P_Name As P_Name, @P_Desc As P_Desc,
			@P_Category As P_Category, @P_SKU As P_SKU, @P_Type As P_Type,
			@P_Price As P_Price, @P_MinPrice As P_MinPrice, @P_MaxPrice As P_MaxPrice, 
			@P_StockQuantity As P_Quanity, @P_WarnLevel As P_WarnLevel,
			@P_Rev As P_Review, @Rev_Avg As P_AverageReview, @Rev_Total As P_TotalReview,
			@P_CallForPrice As P_CallForPrice
END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisProductOptionLink_Add]    Script Date: 03/06/2022 13:40:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[_spKartrisProductOptionLink_Add]
(
	@OptionID as int,
	@ProductID int,
	@OrderBy as smallint,
	@PriceChange as real,
	@WeightChange as real,
	@Selected as bit
)
AS
	SET NOCOUNT OFF;
	
	INSERT INTO [tblKartrisProductOptionLink] 
	VALUES (@OptionID, @ProductID, @OrderBy, @PriceChange, @WeightChange, @Selected);

	EXEC dbo._spKartrisProducts_RecalculateMinMaxPrice @ProductID 
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisProductOptionLink_DeleteByProductID]    Script Date: 03/06/2022 13:41:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[_spKartrisProductOptionLink_DeleteByProductID]
(
	@ProductID int
)
AS
	SET NOCOUNT OFF;
	
	DELETE FROM [tblKartrisProductOptionLink] 
	WHERE ([P_OPT_ProductID] = @ProductID);

	EXEC dbo._spKartrisProducts_RecalculateMinMaxPrice @ProductID 
GO

/* If FTS is active, we try to clear and then recreate the catalogue */
DECLARE @strIsFTSActive as varchar(1) = 'n'
SELECT @strIsFTSActive = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = 'general.fts.enabled'
If @strIsFTSActive = 'y'
BEGIN
	EXEC _spKartrisDB_StopFTS
	EXEC _spKartrisDB_SetupFTS
END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_RebuildPriceIndex]    Script Date: 08/06/2022 08:30:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Description:	Refresh product price index
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_RebuildPriceIndex]

AS

-- Declare & init (2008 syntax)
DECLARE @P_ID INT = 0

-- Keep going through products
WHILE (1 = 1) 
BEGIN  

  -- Get next product ID
  SELECT TOP 1 @P_ID = P_ID
  FROM tblKartrisProducts
  WHERE P_ID > @P_ID 
  ORDER BY P_ID

  -- Exit loop if no more products
  IF @@ROWCOUNT = 0 BREAK;

  -- call your sproc
  EXEC dbo._spKartrisProducts_RecalculateMinMaxPrice @P_ID

END
GO

/****** Fill the Product Search Index with data ******/
-- When we upgrade, we need to go through and create the search index for
-- all existing products. This could take a long time, but has to be done
-- so we know we have the data for other places to use.
EXEC _spKartrisProducts_RebuildPriceIndex
GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='3.3000', CFG_VersionAdded=3.3000 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO

PRINT '-------------------------------------------------------'
PRINT 'That''s all folks! Looks like we reached the end....'
PRINT '-------------------------------------------------------'
