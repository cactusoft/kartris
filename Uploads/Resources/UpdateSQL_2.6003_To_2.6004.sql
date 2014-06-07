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