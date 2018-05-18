
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


/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.9014', CFG_VersionAdded=2.9014 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO
