INSERT [dbo].[tblKartrisObjectConfig] ([OC_Name], [OC_ObjectType], [OC_DataType], [OC_DefaultValue], [OC_Description], [OC_MultilineValue], [OC_VersionAdded]) 
VALUES (N'K:product.showlargeimageinline', N'Product', N'b', N'0', N'Change products images to large view mode instead of being displayed in the image gallery.', 0, 2.5006);
GO
DECLARE @OC_ID as int;
SELECT @OC_ID = OC_ID FROM [dbo].[tblKartrisObjectConfig] WHERE [OC_Name] = N'K:product.showlargeimageinline';

INSERT INTO dbo.tblKartrisObjectConfigValue
SELECT @OC_ID, P_ID, 1
FROM dbo.vKartrisTypeProducts
WHERE P_Desc LIKE '%<overridelargeimagelinktype>';

GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetNewestProducts]    Script Date: 01/23/2013 21:59:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: 
-- Description:	
-- Remarks: Optimization (Medz) - Modified to use product views instead and to lessen use of GetName function - 14-07-2010
-- Remarks2: Further Optimization (Mohammad) - Remove usage of product versions view and use the Language Elements directly - 15-11-2013
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
	
	SELECT DISTINCT TOP (10) tblKartrisProducts.P_ID, tblKartrisLanguageElements.LE_Value AS P_Name, tblKartrisProducts.P_DateCreated, @LANG_ID LANG_ID
	FROM    tblKartrisProducts INNER JOIN
			  tblKartrisVersions ON tblKartrisProducts.P_ID = tblKartrisVersions.V_ProductID INNER JOIN
			  tblKartrisProductCategoryLink ON tblKartrisProducts.P_ID = tblKartrisProductCategoryLink.PCAT_ProductID INNER JOIN
			  tblKartrisCategories ON tblKartrisProductCategoryLink.PCAT_CategoryID = tblKartrisCategories.CAT_ID INNER JOIN
			  tblKartrisLanguageElements ON tblKartrisProducts.P_ID = tblKartrisLanguageElements.LE_ParentID
	WHERE   (tblKartrisProducts.P_CustomerGroupID IS NULL) AND (tblKartrisCategories.CAT_CustomerGroupID IS NULL) AND (tblKartrisVersions.V_CustomerGroupID IS NULL) AND
		   (tblKartrisLanguageElements.LE_LanguageID = @LANG_ID) AND (tblKartrisLanguageElements.LE_TypeID = 2) AND (tblKartrisLanguageElements.LE_FieldID = 1) AND 
		  (NOT (tblKartrisLanguageElements.LE_Value IS NULL))
	ORDER BY tblKartrisProducts.P_DateCreated DESC, tblKartrisProducts.P_ID DESC

END