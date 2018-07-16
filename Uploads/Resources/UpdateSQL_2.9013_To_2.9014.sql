
/*
Update to richsnippets, handle 'call for pricing'
Thanks to Michael Correia @pyramidimaging.com
*/

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetRichSnippetProperties]    Script Date: 5/1/2018 8:12:47 AM ******/
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
			@P_Price as real, @P_MinPrice as real, @P_MaxPrice as real, 
			@P_StockQuantity as real, @P_WarnLevel as real,
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

/****** Fix category sorting issue ******/
/*
Seems some cats go in with NULL, this should hopefully avoid that so if you switch to
manual sorting, there are not NULL values messing things up
*/
ALTER TABLE [dbo].[tblKartrisCategoryHierarchy] ADD  CONSTRAINT [DF_tblKartrisCategoryHierarchy_CH_OrderNo]  DEFAULT ((1)) FOR [CH_OrderNo]
GO

/****** New index on category hierarchy, speed up sorting of cats ******/
CREATE NONCLUSTERED INDEX [CH_OrderNo] ON [dbo].[tblKartrisCategoryHierarchy]
(
	[CH_OrderNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** New indexes on attributes, performance improvement ******/
CREATE NONCLUSTERED INDEX [ATTRIB_OrderByValue] ON [dbo].[tblKartrisAttributes]
(
	[ATTRIB_OrderByValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ATTRIB_Live] ON [dbo].[tblKartrisAttributes]
(
	[ATTRIB_Live] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** New index on product-category link, improve sorting performance ******/
CREATE NONCLUSTERED INDEX [PCAT_OrderNo] ON [dbo].[tblKartrisProductCategoryLink]
(
	[PCAT_OrderNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** GDPR bug fix, kind of ******/
/*
This is a new sproc, it lets us pull out reviews
by either customer ID or email
*/
CREATE PROCEDURE [dbo].[_spKartrisGDPR_GetReviewsByUserIDOrEmail]
(
	@UserID as int,
	@UserEmail as nvarchar(200)
)
AS
	SET NOCOUNT ON;
SELECT     * 
FROM         tblKartrisReviews
WHERE     (REV_CustomerID = @UserID) OR (REV_Email = @UserEmail)
ORDER BY REV_ID

GO

/****** New object config - spectable, similar to the old spectable field in CactuShop ******/
SET IDENTITY_INSERT [dbo].[tblKartrisObjectConfig] ON
INSERT [dbo].[tblKartrisObjectConfig] ([OC_ID], [OC_Name], [OC_ObjectType], [OC_DataType], [OC_DefaultValue], [OC_Description], [OC_MultilineValue], [OC_VersionAdded]) VALUES (9, N'K:product.spectable', N'Product', N's', N'', N'Pre formatted text for specs, tabular data, etc.', 1, 2.9014)
SET IDENTITY_INSERT [dbo].[tblKartrisObjectConfig] OFF

/*** New language string for spectable tab heading  ***/
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'ContentText_SpecTable', N'Specs', NULL, 2.9014, N'', NULL, N'Products',1);

GO

/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_DeleteByCategory]    Script Date: 16/07/2018 14:08:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	Changed to allow product IDs
-- longer than 5 chars
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisProducts_DeleteByCategory](@CategoryID as int)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE productCursor CURSOR FOR 
	SELECT PCAT_ProductID
	FROM dbo.tblKartrisProductCategoryLink
	WHERE PCAT_CategoryID = @CategoryID
		
	DECLARE @ChildProductID as bigint;
	
	OPEN productCursor
	FETCH NEXT FROM productCursor
	INTO @ChildProductID;

	DECLARE @ProductList as nvarchar(max);
	SET @ProductList = '';

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @ProductList = @ProductList + CAST(@ChildProductID as nvarchar(20)) +  ',';
		
		FETCH NEXT FROM productCursor
		INTO @ChildProductID;

	END

	CLOSE productCursor
	DEALLOCATE productCursor;

	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @ProductIDToDelete as nvarchar(20);
	DECLARE @Counter as int;
	DECLARE @CurrentScore as int;

	SET @SIndx = 0;
	SET @Counter = 0;
	WHILE @SIndx <= LEN(@ProductList)
	BEGIN
		
		SET @Counter = @Counter + 1;
		SET @CIndx = CHARINDEX(',', @ProductList, @SIndx)	-- Next keyword starting index (1-Based Index)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@ProductList)+ 1 END	-- If no more keywords, set next starting index to not exist
		SET @ProductIDToDelete = SUBSTRING(@ProductList, @SIndx, @CIndx - @SIndx)
		SET @SIndx = @CIndx + 1;	-- The next starting index
		DECLARE @Product as bigint;
		SET @Product = CAST(@ProductIDToDelete as bigint);
			
			-- delete the link with the selected product
			DELETE FROM tblKartrisProductCategoryLink
			WHERE     (PCAT_CategoryID = @CategoryID) AND (PCAT_ProductID = @Product);
			
		
		DECLARE @NoOfOtherParentCategories as int;
		SET @NoOfOtherParentCategories = 0;
		SELECT @NoOfOtherParentCategories = Count(1)
		FROM dbo.tblKartrisProductCategoryLink
		WHERE (PCAT_ProductID = @Product) AND (PCAT_CategoryID <> @CategoryID)
		
		-- if no other parent categories.
		IF @NoOfOtherParentCategories = 0 
		BEGIN
			EXEC [dbo].[_spKartrisProducts_Delete] 
			@ProductID = @Product;
		END
		-- delete the products, since no other related categories.
		
		
		
	END
	
	
END
GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.9014', CFG_VersionAdded=2.9014 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO
