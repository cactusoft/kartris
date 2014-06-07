/****** Object:  View [dbo].[vKartrisTypeVersions]    Script Date: 2014-06-07 17:05:20 ******/
-- Modified: By Paul - 2014/6/7 - Added filter <>'s' so we don't pull out suspended combinations
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vKartrisTypeVersions]
AS
SELECT        TOP (100) PERCENT dbo.tblKartrisVersions.V_ID, dbo.tblKartrisLanguages.LANG_ID, dbo.tblKartrisLanguageElements.LE_Value AS V_Name, tblKartrisLanguageElements_1.LE_Value AS V_Desc, 
						 dbo.tblKartrisVersions.V_CodeNumber, dbo.fnKartrisObjectConfig_GetValueByParent(N'K:version.extrasku', dbo.tblKartrisVersions.V_ID) AS V_ExtraCodeNumber, dbo.tblKartrisVersions.V_ProductID, 
						 dbo.tblKartrisVersions.V_Price, dbo.tblKartrisVersions.V_Tax, dbo.tblKartrisVersions.V_Weight, dbo.tblKartrisVersions.V_DeliveryTime, dbo.tblKartrisVersions.V_Quantity, 
						 dbo.tblKartrisVersions.V_QuantityWarnLevel, dbo.tblKartrisVersions.V_Live, dbo.tblKartrisVersions.V_DownLoadInfo, dbo.tblKartrisVersions.V_DownloadType, dbo.tblKartrisVersions.V_OrderByValue, 
						 dbo.tblKartrisVersions.V_RRP, dbo.tblKartrisVersions.V_Type, dbo.tblKartrisVersions.V_CustomerGroupID, dbo.tblKartrisVersions.V_CustomizationType, dbo.tblKartrisVersions.V_CustomizationDesc, 
						 dbo.tblKartrisVersions.V_CustomizationCost, dbo.tblKartrisVersions.V_Tax2, dbo.tblKartrisVersions.V_TaxExtra
FROM            dbo.tblKartrisLanguageElements INNER JOIN
						 dbo.tblKartrisVersions ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisVersions.V_ID INNER JOIN
						 dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_1 ON dbo.tblKartrisVersions.V_ID = tblKartrisLanguageElements_1.LE_ParentID INNER JOIN
						 dbo.tblKartrisLanguages ON dbo.tblKartrisLanguageElements.LE_LanguageID = dbo.tblKartrisLanguages.LANG_ID AND 
						 tblKartrisLanguageElements_1.LE_LanguageID = dbo.tblKartrisLanguages.LANG_ID
WHERE        (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (dbo.tblKartrisLanguageElements.LE_Value IS NOT NULL) AND 
						 (dbo.tblKartrisLanguageElements.LE_TypeID = 1) AND (tblKartrisLanguageElements_1.LE_TypeID = 1) AND (dbo.tblKartrisVersions.V_Type <> 's') OR
						 (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (dbo.tblKartrisLanguageElements.LE_TypeID = 1) AND (tblKartrisLanguageElements_1.LE_TypeID = 1) 
						 AND (tblKartrisLanguageElements_1.LE_Value IS NOT NULL)

GO
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