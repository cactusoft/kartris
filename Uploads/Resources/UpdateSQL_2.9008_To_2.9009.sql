
/*** We need a max price function. This may already be present for
customers running the powerpack. Therefore we have to delete this if present
but catch/ignore the error if not present, then we should be good to create
it ***/
BEGIN TRY
	DROP FUNCTION dbo.fnKartrisProduct_GetMaxPrice
END TRY
BEGIN CATCH
	-- skip
END CATCH
GO

/****** Object:  UserDefinedFunction [dbo].[fnKartrisProduct_GetMaxPrice]    Script Date: 03/05/2017 12:27:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisProduct_GetMaxPrice] 
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
	DECLARE @VersionPrice decimal(18,4);
	DECLARE @OptionsPrice decimal(18,4);

	-- Get version price
	SELECT @VersionPrice = Max(V_Price) 
	FROM tblKartrisVersions INNER JOIN [dbo].[tblKartrisTaxRates]
			ON [V_Tax] = [T_ID]
	WHERE V_ProductID = @V_ProductID AND V_Live = 1 AND tblKartrisVersions.V_CustomerGroupID IS NULL;

	-- Get options price
	SELECT @OptionsPrice = Sum(T.MaxPriceChange) FROM
	(SELECT P_OPT_ProductID, OPTG_ID, Max(P_OPT_PriceChange) As MaxPriceChange FROM dbo.tblKartrisOptionGroups INNER JOIN
						 dbo.tblKartrisOptions ON dbo.tblKartrisOptionGroups.OPTG_ID = dbo.tblKartrisOptions.OPT_OptionGroupID INNER JOIN
						 dbo.tblKartrisProductOptionGroupLink ON dbo.tblKartrisOptionGroups.OPTG_ID = dbo.tblKartrisProductOptionGroupLink.P_OPTG_OptionGroupID INNER JOIN
						 dbo.tblKartrisProductOptionLink ON dbo.tblKartrisOptions.OPT_ID = dbo.tblKartrisProductOptionLink.P_OPT_OptionID 
	WHERE P_OPT_ProductID = @V_ProductID
	GROUP BY P_OPT_ProductID, OPTG_ID) As T

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

/*** Now we need to alter the rich snippets sproc so it pulls out the extra name and desc 
and gets correct max price ***/

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetRichSnippetProperties]    Script Date: 03/05/2017 11:32:45 ******/
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
			@P_Rev as char(1), @Rev_Avg as real, @Rev_Total as int;

	SELECT Top(1) @P_Category = vKartrisTypeCategories.CAT_Name
	FROM  vKartrisTypeCategories INNER JOIN tblKartrisProductCategoryLink 
			ON vKartrisTypeCategories.CAT_ID = tblKartrisProductCategoryLink.PCAT_CategoryID
	WHERE (vKartrisTypeCategories.LANG_ID = @LANG_ID) AND (tblKartrisProductCategoryLink.PCAT_ProductID = @P_ID)

	SELECT @P_Name = [P_Name], @P_Desc = [P_Desc], @P_Type = [P_Type], @P_Rev = [P_Reviews]
	FROM [dbo].[vKartrisTypeProducts]
	WHERE [P_ID] = @P_ID;

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
			@P_Rev As P_Review, @Rev_Avg As P_AverageReview, @Rev_Total As P_TotalReview
END
GO

