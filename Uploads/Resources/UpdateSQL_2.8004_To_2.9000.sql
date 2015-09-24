/****** 
v2.9000 
Fixes spKartrisProducts_GetAttributeValue where P_ID was set as
a smallint, meaning that on the comparison table, products with
ID of more than 32,767 showed no attributes. Products DAL also
updated.

Updates some config settings with information in the description
that they are now deprecated.
******/

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetAttributeValue]    Script Date: 2015-05-16 13:06:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: 
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisProducts_GetAttributeValue]
	(
	@P_ID int,
	@ATTRIB_ID int,
	@LANG_ID tinyint,
	@ATTRIBV_Value nvarchar(50) OUT
	)
AS
SELECT @ATTRIBV_Value = ATTRIBV_Value 
FROM vKartrisTypeAttributeValues 
WHERE vKartrisTypeAttributeValues.ATTRIBV_AttributeID = @ATTRIB_ID
	AND vKartrisTypeAttributeValues.ATTRIBV_ProductID = @P_ID
	AND vKartrisTypeAttributeValues.LANG_ID = @LANG_ID

/****** Object:  StoredProcedure [dbo].[spKartrisMediaLinks_GetByParent]    Script Date: 2015-06-04 18:21:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	Updated to fix sorting
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisMediaLinks_GetByParent]
(
	@ParentID as bigint, 
	@ParentType as nvarchar(1)
)
AS
BEGIN
SET NOCOUNT ON;
SELECT     tblKartrisMediaLinks.ML_ID, tblKartrisMediaLinks.ML_ParentID, tblKartrisMediaLinks.ML_ParentType, tblKartrisMediaLinks.ML_EmbedSource, 
					  tblKartrisMediaLinks.ML_MediaTypeID, tblKartrisMediaLinks.ML_Height, tblKartrisMediaLinks.ML_Width, 
					  tblKartrisMediaLinks.ML_isDownloadable, tblKartrisMediaLinks.ML_Parameters, tblKartrisMediaTypes.MT_DefaultHeight, 
					  tblKartrisMediaTypes.MT_DefaultWidth, tblKartrisMediaTypes.MT_DefaultParameters, tblKartrisMediaTypes.MT_DefaultisDownloadable, 
					  tblKartrisMediaTypes.MT_Extension,tblKartrisMediaTypes.MT_Embed, tblKartrisMediaTypes.MT_Inline, tblKartrisMediaLinks.ML_Live
FROM         tblKartrisMediaLinks LEFT OUTER JOIN
					  tblKartrisMediaTypes ON tblKartrisMediaLinks.ML_MediaTypeID = tblKartrisMediaTypes.MT_ID
WHERE     (tblKartrisMediaLinks.ML_ParentID = @ParentID) AND (tblKartrisMediaLinks.ML_ParentType = @ParentType) AND (tblKartrisMediaLinks.ML_Live = 1)
ORDER BY ML_SortOrder
END

GO

SET IDENTITY_INSERT [dbo].[tblKartrisMediaTypes] ON
INSERT [dbo].[tblKartrisMediaTypes] ([MT_ID], [MT_Extension], [MT_DefaultHeight], [MT_DefaultWidth], [MT_DefaultParameters], [MT_DefaultisDownloadable], [MT_Embed], [MT_Inline]) VALUES (8, N'urlnewtab', 10, 10, NULL, 0, 1, 0)
INSERT [dbo].[tblKartrisMediaTypes] ([MT_ID], [MT_Extension], [MT_DefaultHeight], [MT_DefaultWidth], [MT_DefaultParameters], [MT_DefaultisDownloadable], [MT_Embed], [MT_Inline]) VALUES (9, N'urlpopup', 480, 640, NULL, 0, 1, 0)
INSERT [dbo].[tblKartrisMediaTypes] ([MT_ID], [MT_Extension], [MT_DefaultHeight], [MT_DefaultWidth], [MT_DefaultParameters], [MT_DefaultisDownloadable], [MT_Embed], [MT_Inline]) VALUES (10, N'zip', 10, 10, NULL, 1, 0, 0)
GO
SET IDENTITY_INSERT [dbo].[tblKartrisMediaTypes] OFF
GO

-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	Fix missing fields in product
-- export for Data Tool
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisDB_ExportProductRelatedData]
(
	@LanguageID as int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		SELECT * 
		FROM
			((SELECT '###_DUMMYDATA_###' AS Cat5_Name1,	'DO NOT MODIFY OR DELETE THIS LINE. THIS SHOULD HELP ADDRESS THE ISSUES WITH THE OLEDB DRIVER LIMITATION. BY ADDING THIS LINE WE ARE LETTING THE DRIVER KNOW THE CORRECT DATA TYPE OF EACH FIELD.  THIS IS BETTER THAN MODIFYING THE REGISTRY TO SET A HIGHER ROWSCAN VALUE.' AS Cat5_Desc1,	'CAT5_IMAGEFIELD' AS cat5_Image,	'CAT4_NAME' AS Cat4_Name1,	'################################################################################################################################################################################################################################################################' AS Cat4_Desc1,	'CAT4_IMAGEFIELD' AS cat4_Image,	'CAT3_NAME' AS Cat3_Name1,	'################################################################################################################################################################################################################################################################' AS Cat3_Desc1,	'CAT3_IMAGEFIELD' AS cat3_Image,	'CAT2_NAME' AS Cat2_Name1,	'################################################################################################################################################################################################################################################################' AS Cat2_Desc1,	'CAT2_IMAGEFIELD' AS cat2_Image,	'CAT1_NAME' AS Cat1_Name1,	'################################################################################################################################################################################################################################################################' AS Cat1_Desc1,	'CAT1_IMAGEFIELD' AS cat1_Image,	'P_NAME1' AS P_Name1,	'################################################################################################################################################################################################################################################################' AS P_Desc1,	'P_IMAGEFIELD' AS P_Image,	'P_STRAPLINE1' AS P_StrapLine1,	'V_NAME1' AS V_Name1,	'################################################################################################################################################################################################################################################################' AS V_Desc1,	'V_IMAGEFIELD' AS V_Image,	'V_CODENUMBER' AS V_CodeNumber,	'V_TYPE' AS V_Type, '0' AS V_Price,	'0' AS V_Quantity,	'0' AS V_Weight,	'0' AS V_RRP,	'0' AS T_Taxrate, '0' AS T_Taxrate2, 'V_TaxExtra' As V_TaxExtra,	'SUPPLIER' AS Supplier,	'###_END_OF_DUMMYDATA_###' AS P_Attribute1,	'' AS P_Attribute2,	'' AS P_Attribute3)
			UNION
			(
			SELECT  dbo.vKartrisTypeCategories.CAT_Name AS Cat5_Name1, dbo.vKartrisTypeCategories.CAT_Desc AS Cat5_Desc1, '' AS Cat5_Image, 
				  dbo.vKartrisCategoryHierarchy.CAT_Name AS Cat4_Name1, dbo.vKartrisCategoryHierarchy.CAT_Desc AS Cat4_Desc1, '' AS Cat4_Image, 
				  vKartrisCategoryHierarchy_1.CAT_Name AS Cat3_Name1, vKartrisCategoryHierarchy_1.CAT_Desc AS Cat3_Desc1, '' AS Cat3_Image, 
				  vKartrisCategoryHierarchy_2.CAT_Name AS Cat2_Name1, vKartrisCategoryHierarchy_2.CAT_Desc AS Cat2_Desc1, '' AS Cat2_Image, 
				  vKartrisCategoryHierarchy_3.CAT_Name AS Cat1_Name1, vKartrisCategoryHierarchy_3.CAT_Desc AS Cat1_Desc1, '' AS Cat1_Image, 
				  dbo.vKartrisTypeProducts.P_Name AS P_Name1, dbo.vKartrisTypeProducts.P_Desc AS P_Desc1, '' AS P_Image, 
				  dbo.vKartrisTypeProducts.P_StrapLine AS P_Strapline1, dbo.vKartrisTypeVersions.V_Name AS V_Name1, dbo.vKartrisTypeVersions.V_Desc AS V_Desc1, 
				  '' AS V_Image, dbo.vKartrisTypeVersions.V_CodeNumber, dbo.vKartrisTypeVersions.V_Type, dbo.vKartrisTypeVersions.V_Price, dbo.vKartrisTypeVersions.V_Quantity, 
				  dbo.vKartrisTypeVersions.V_Weight, dbo.vKartrisTypeVersions.V_RRP, dbo.tblKartrisTaxRates.T_Taxrate, ISNULL(dbo.vKartrisTypeVersions.V_Tax2, 0), dbo.vKartrisTypeVersions.V_TaxExtra, dbo.tblKartrisSuppliers.SUP_Name AS Supplier, 
				  '' AS P_Attribute1, '' AS P_Attribute2, '' AS P_Attribute3
			FROM dbo.tblKartrisTaxRates RIGHT OUTER JOIN
				  dbo.vKartrisTypeVersions INNER JOIN
				  dbo.vKartrisTypeProducts ON dbo.vKartrisTypeVersions.V_ProductID = dbo.vKartrisTypeProducts.P_ID AND 
				  dbo.vKartrisTypeVersions.LANG_ID = dbo.vKartrisTypeProducts.LANG_ID ON dbo.tblKartrisTaxRates.T_ID = dbo.vKartrisTypeVersions.V_Tax LEFT OUTER JOIN
				  dbo.tblKartrisSuppliers ON dbo.vKartrisTypeProducts.P_SupplierID = dbo.tblKartrisSuppliers.SUP_ID LEFT OUTER JOIN
				  dbo.vKartrisTypeCategories INNER JOIN
				  dbo.tblKartrisProductCategoryLink ON dbo.vKartrisTypeCategories.CAT_ID = dbo.tblKartrisProductCategoryLink.PCAT_CategoryID LEFT OUTER JOIN
				  dbo.vKartrisCategoryHierarchy LEFT OUTER JOIN
				  dbo.vKartrisCategoryHierarchy AS vKartrisCategoryHierarchy_3 RIGHT OUTER JOIN
				  dbo.vKartrisCategoryHierarchy AS vKartrisCategoryHierarchy_2 ON vKartrisCategoryHierarchy_3.LANG_ID = vKartrisCategoryHierarchy_2.LANG_ID AND 
				  vKartrisCategoryHierarchy_3.CH_ChildID = vKartrisCategoryHierarchy_2.CAT_ID RIGHT OUTER JOIN
				  dbo.vKartrisCategoryHierarchy AS vKartrisCategoryHierarchy_1 ON vKartrisCategoryHierarchy_2.LANG_ID = vKartrisCategoryHierarchy_1.LANG_ID AND 
				  vKartrisCategoryHierarchy_2.CH_ChildID = vKartrisCategoryHierarchy_1.CAT_ID ON 
				  dbo.vKartrisCategoryHierarchy.LANG_ID = vKartrisCategoryHierarchy_1.LANG_ID AND 
				  dbo.vKartrisCategoryHierarchy.CAT_ID = vKartrisCategoryHierarchy_1.CH_ChildID ON 
				  dbo.vKartrisTypeCategories.LANG_ID = dbo.vKartrisCategoryHierarchy.LANG_ID AND 
				  dbo.vKartrisTypeCategories.CAT_ID = dbo.vKartrisCategoryHierarchy.CH_ChildID ON 
				  dbo.vKartrisTypeProducts.P_ID = dbo.tblKartrisProductCategoryLink.PCAT_ProductID
			WHERE     (dbo.vKartrisTypeProducts.LANG_ID = @LanguageID) AND (dbo.vKartrisTypeProducts.P_Type <> 'o')
			)) ProductData
	ORDER BY Cat5_Name1, P_Name1
END

/****** Let's update some config setting descriptions, if they're deprecated ******/
UPDATE tblKartrisConfig SET CFG_Description='[DEPRECATED] - Category menu type now fixed by choice of user control in skin template' WHERE CFG_Name='frontend.display.categorymenu.type';
GO

DELETE FROM tblKartrisConfig WHERE CFG_Name='general.sessions.usecookies' --this one should be removed if present, not used for ages
GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.9000', CFG_VersionAdded=2.9000 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO
