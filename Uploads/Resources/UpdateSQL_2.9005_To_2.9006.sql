/****** Object:  UserDefinedFunction [dbo].[fnKartrisBasket_GetItemWeight]    Script Date: 17/06/2016 19:40:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [dbo].[fnKartrisBasket_GetItemWeight]
(
	@BasketValueID as bigint,
	@VersionID as bigint,
	@ProductID as int
)
RETURNS real
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Weight as real;
	DECLARE @WeightBase as real;

	DECLARE @ProductType as char(1);
	
	SELECT @ProductType = P_Type
	FROM tblKartrisProducts 
	WHERE P_ID = @ProductID;
	
	IF @ProductType IN ('s','m') BEGIN
		SELECT @Weight = V_Weight
		FROM tblKartrisVersions
		WHERE V_ID = @VersionID;
	END ELSE BEGIN
		DECLARE @OptionsList as nvarchar(max);
		SELECT @OptionsList = COALESCE(@OptionsList + ',', '') + CAST(T.BSKTOPT_OptionID As nvarchar(10))
		FROM (SELECT BSKTOPT_OptionID FROM dbo.tblKartrisBasketOptionValues WHERE  BSKTOPT_BasketValueID = @BasketValueID) AS T;
		
		SELECT @Weight = SUM(P_OPT_WeightChange)
		FROM dbo.tblKartrisProductOptionLink
		WHERE P_OPT_ProductID = @ProductID AND P_OPT_OptionID IN (SELECT * FROM dbo.fnTbl_SplitNumbers(@OptionsList));
		
		-- If weight = 0, then no weight change for the options, we need to use the base version.
		IF @Weight = 0 BEGIN
			SELECT @Weight = V_Weight FROM tblKartrisVersions WHERE V_ID = @VersionID;
			END
		ELSE
			-- Get weight of options and weight of base version, add together
			BEGIN
				SELECT @WeightBase = V_Weight FROM tblKartrisVersions WHERE V_ID = @VersionID;
				SET @Weight = @Weight + @WeightBase;
			END
	END
	
	-- Return the result of the function
	RETURN @Weight;

END
GO

/****** FIX DATA TOOL EXPORT SO ATTRIBUTES FORMAT MATCHES DATA TOOL REQUIREMENT ******/

/****** Object:  StoredProcedure [dbo].[_spKartrisDB_ExportProductRelatedData]    Script Date: 30/06/2016 16:22:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	<Description,,>
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

	-- Put products from View into temp table
	SELECT * INTO #TempProducts FROM dbo.vKartrisTypeProducts WHERE LANG_ID = @LanguageID;
	-- apply index
	CREATE CLUSTERED INDEX IDX_P_ID ON #TempProducts(P_ID);
	CREATE INDEX IDX_LANG_ID ON #TempProducts(LANG_ID);

	-- Put versions from View into temp table
	SELECT * INTO #TempVersions FROM dbo.vKartrisTypeVersions WHERE LANG_ID = @LanguageID;
	-- apply indexes
	CREATE CLUSTERED INDEX IDX_V_ID ON #TempVersions(V_ID);
	CREATE INDEX IDX_V_ProductID ON #TempVersions(V_ProductID);
	CREATE INDEX IDX_LANG_ID ON #TempVersions(LANG_ID);

	-- Put categories from View into temp table
	SELECT * INTO #TempCategories FROM dbo.vKartrisTypeCategories WHERE LANG_ID = @LanguageID;
	-- apply indexes
	CREATE CLUSTERED INDEX IDX_CAT_ID ON #TempCategories(CAT_ID);
	CREATE INDEX IDX_LANG_ID ON #TempCategories(LANG_ID);

	-- Put category hierarchy from View into temp table
	SELECT * INTO #TempCategoryHierarchy FROM dbo.vKartrisCategoryHierarchy WHERE LANG_ID = @LanguageID;
	-- apply indexes
	CREATE CLUSTERED INDEX IDX_CH_CAT_ID ON #TempCategoryHierarchy(CAT_ID);
	CREATE INDEX IDX_CH_ChildID ON #TempCategoryHierarchy(CH_ChildID);
	CREATE INDEX IDX_LANG_ID ON #TempCategoryHierarchy(LANG_ID);

	-- Put attributes from View into temp table
	SELECT * INTO #TempAttributes FROM dbo.vKartrisTypeAttributes WHERE LANG_ID = @LanguageID;
	-- apply indexes
	CREATE CLUSTERED INDEX IDX_ATTRIB_ID ON #TempAttributes(ATTRIB_ID);
	CREATE INDEX IDX_LANG_ID ON #TempAttributes(LANG_ID);

	-- Put attributes from View into temp table
	SELECT * INTO #TempAttributeValues FROM dbo.vKartrisTypeAttributeValues WHERE LANG_ID = @LanguageID;
	-- apply indexes
	CREATE CLUSTERED INDEX IDX_ATTRIBV_ID ON #TempAttributeValues(ATTRIBV_ID);
	CREATE INDEX IDX_ATTRIB_ID ON #TempAttributeValues(ATTRIBV_AttributeID);
	CREATE INDEX IDX_LANG_ID ON #TempAttributeValues(LANG_ID);

SELECT * INTO #TempProductData
		FROM
			((SELECT 'CAT1_NAME' AS Cat5_Name1,	'DO NOT MODIFY OR DELETE THIS LINE. THIS SHOULD HELP ADDRESS THE ISSUES WITH THE OLEDB DRIVER LIMITATION. BY ADDING THIS LINE WE ARE LETTING THE DRIVER KNOW THE CORRECT DATA TYPE OF EACH FIELD.  THIS IS BETTER THAN MODIFYING THE REGISTRY TO SET A HIGHER ROWSCAN VALUE.' AS Cat5_Desc1, 'CAT1_IMAGE' AS Cat5_Image, 'CAT2_NAME' AS Cat4_Name1, '################################################################################################################################################################################################################################################################' AS Cat4_Desc1, 'CAT2_IMAGE' AS Cat4_Image, 'CAT3_NAME' AS Cat3_Name1, '################################################################################################################################################################################################################################################################' AS Cat3_Desc1, 'CAT3_IMAGE' AS Cat3_Image, 'CAT4_NAME' AS Cat2_Name1, '################################################################################################################################################################################################################################################################' AS Cat2_Desc1, 'CAT4_IMAGE' AS Cat2_Image,	'CAT5_NAME' AS Cat1_Name1, '################################################################################################################################################################################################################################################################' AS Cat1_Desc1, 'CAT5_IMAGE' AS Cat1_Image, 'P_NAME1' AS P_Name1, '################################################################################################################################################################################################################################################################' AS P_Desc1, 'P_IMAGEFIELD' AS P_Image, 'P_STRAPLINE1' AS P_StrapLine1, 'V_NAME1' AS V_Name1, '################################################################################################################################################################################################################################################################' AS V_Desc1, 'V_IMAGEFIELD' AS V_Image, 'V_CODENUMBER' AS V_CodeNumber, 'V_TYPE' AS V_Type, '0' AS V_Price, '0' AS V_Quantity, '0' AS V_Weight, '0' AS V_RRP, '0' AS T_Taxrate, '0' AS T_Taxrate2, 'V_TAXEXTRA' As V_TaxExtra, 'SUPPLIER' AS Supplier, 'ATTRIBUTES' AS Attributes, 'OPTIONS' AS Options)
			UNION
			(
			SELECT  COALESCE(#TempCategories.CAT_Name, '') AS Cat5_Name1, COALESCE(#TempCategories.CAT_Desc,'') AS Cat5_Desc1, '' AS Cat5_Image, 
				  COALESCE(#TempCategoryHierarchy.CAT_Name, '') AS Cat4_Name1, COALESCE(#TempCategoryHierarchy.CAT_Desc, '') AS Cat4_Desc1, '' AS Cat4_Image, 
				  COALESCE(vKartrisCategoryHierarchy_1.CAT_Name, '') AS Cat3_Name1, COALESCE(vKartrisCategoryHierarchy_1.CAT_Desc, '') AS Cat3_Desc1, '' AS Cat3_Image, 
				  COALESCE(vKartrisCategoryHierarchy_2.CAT_Name, '') AS Cat2_Name1, COALESCE(vKartrisCategoryHierarchy_2.CAT_Desc, '') AS Cat2_Desc1, '' AS Cat2_Image, 
				  COALESCE(vKartrisCategoryHierarchy_3.CAT_Name, '') AS Cat1_Name1, COALESCE(vKartrisCategoryHierarchy_3.CAT_Desc, '') AS Cat1_Desc1, '' AS Cat1_Image, 
				  #TempProducts.P_Name AS P_Name1, #TempProducts.P_Desc AS P_Desc1, '' AS P_Image, 
				  #TempProducts.P_StrapLine AS P_Strapline1, #TempVersions.V_Name AS V_Name1, #TempVersions.V_Desc AS V_Desc1, 
				  '' AS V_Image, #TempVersions.V_CodeNumber, #TempVersions.V_Type, #TempVersions.V_Price, #TempVersions.V_Quantity, 
				  #TempVersions.V_Weight, #TempVersions.V_RRP, dbo.tblKartrisTaxRates.T_Taxrate, COALESCE(#TempVersions.V_Tax2, 0), #TempVersions.V_TaxExtra, dbo.tblKartrisSuppliers.SUP_Name AS Supplier, 
				  COALESCE(STUFF((SELECT ' || ' +    CONVERT(NVARCHAR(max), #TempAttributes.ATTRIB_Name),
						' {{' + CONVERT(NVARCHAR(max), #TempAttributeValues.ATTRIBV_Value) + '}}'
FROM #TempAttributeValues INNER JOIN
					  #TempAttributes ON #TempAttributeValues.ATTRIBV_AttributeID = #TempAttributes.ATTRIB_ID AND 
					  #TempAttributeValues.LANG_ID = #TempAttributes.LANG_ID
WHERE (#TempAttributes.ATTRIB_Live = 1) AND (#TempAttributes.ATTRIB_ShowFrontend = 1) AND (#TempAttributeValues.ATTRIBV_ProductID = #TempProducts.P_ID) 
ORDER BY #TempAttributes.ATTRIB_OrderByValue
                            FOR xml path('')
                        )
                        , 1
                        , 4
                        , ''), '') AS Attributes, '' AS Options
			FROM dbo.tblKartrisTaxRates RIGHT OUTER JOIN
				  #TempVersions INNER JOIN
				  #TempProducts ON #TempVersions.V_ProductID = #TempProducts.P_ID AND 
				  #TempVersions.LANG_ID = #TempProducts.LANG_ID ON dbo.tblKartrisTaxRates.T_ID = #TempVersions.V_Tax LEFT OUTER JOIN
				  dbo.tblKartrisSuppliers ON #TempProducts.P_SupplierID = dbo.tblKartrisSuppliers.SUP_ID LEFT OUTER JOIN
				  dbo.#TempCategories INNER JOIN
				  dbo.tblKartrisProductCategoryLink ON #TempCategories.CAT_ID = dbo.tblKartrisProductCategoryLink.PCAT_CategoryID LEFT OUTER JOIN
				  #TempCategoryHierarchy LEFT OUTER JOIN
				  #TempCategoryHierarchy AS vKartrisCategoryHierarchy_3 RIGHT OUTER JOIN
				  #TempCategoryHierarchy AS vKartrisCategoryHierarchy_2 ON vKartrisCategoryHierarchy_3.LANG_ID = vKartrisCategoryHierarchy_2.LANG_ID AND 
				  vKartrisCategoryHierarchy_3.CH_ChildID = vKartrisCategoryHierarchy_2.CAT_ID RIGHT OUTER JOIN
				  #TempCategoryHierarchy AS vKartrisCategoryHierarchy_1 ON vKartrisCategoryHierarchy_2.LANG_ID = vKartrisCategoryHierarchy_1.LANG_ID AND 
				  vKartrisCategoryHierarchy_2.CH_ChildID = vKartrisCategoryHierarchy_1.CAT_ID ON 
				  #TempCategoryHierarchy.LANG_ID = vKartrisCategoryHierarchy_1.LANG_ID AND 
				  #TempCategoryHierarchy.CAT_ID = vKartrisCategoryHierarchy_1.CH_ChildID ON 
				  #TempCategories.LANG_ID = #TempCategoryHierarchy.LANG_ID AND 
				  #TempCategories.CAT_ID = #TempCategoryHierarchy.CH_ChildID ON 
				  #TempProducts.P_ID = dbo.tblKartrisProductCategoryLink.PCAT_ProductID
			WHERE  (#TempProducts.P_Type <> 'o')
			)) ProductData
	ORDER BY Cat5_Name1, P_Name1
--SELECT * FROM #TempProductData 

SELECT * FROM (
(SELECT Cat5_Name1, Cat5_Desc1, '' As Cat5_Image, '' As Cat4_Name1, '' As Cat4_Desc1, '' As Cat4_Image, '' As Cat3_Name1, '' As Cat3_Desc1, '' As Cat3_Image, '' As Cat2_Name1, '' As Cat2_Desc1, '' As Cat2_Image, '' As Cat1_Name1, '' As Cat1_Desc1, '' As Cat1_Image, P_Name1, P_Desc1, P_Image, P_StrapLine1, V_Name1, V_Desc1, V_Image, V_CodeNumber, V_Type, V_Price, V_Quantity, V_Weight, V_RRP, T_Taxrate, T_Taxrate2, V_TaxExtra, Supplier, Attributes, '' As Options FROM #TempProductData WHERE Coalesce(Cat5_Name1, '')<>'' AND Coalesce(Cat4_Name1, '')='' AND Coalesce(Cat3_Name1, '')='' AND Coalesce(Cat2_Name1, '')='' AND Coalesce(Cat1_Name1, '')='')
UNION
(SELECT Cat4_Name1, Cat4_Desc1, '', Cat5_Name1, Cat5_Desc1, '', '', '', '', '', '', '', '', '', '', P_Name1, P_Desc1, P_Image, P_StrapLine1, V_Name1, V_Desc1, V_Image, V_CodeNumber, V_Type, V_Price, V_Quantity, V_Weight, V_RRP, T_Taxrate, T_Taxrate2, V_TaxExtra, Supplier, Attributes, '' As Options FROM #TempProductData WHERE Coalesce(Cat5_Name1, '')<>'' AND Coalesce(Cat4_Name1, '')<>'' AND Coalesce(Cat3_Name1, '')='' AND Coalesce(Cat2_Name1, '')='' AND Coalesce(Cat1_Name1, '')='')
UNION
(SELECT Cat3_Name1, Cat3_Desc1, '', Cat4_Name1, Cat4_Desc1, '', Cat5_Name1, Cat5_Desc1, '', '', '', '', '', '', '', P_Name1, P_Desc1, P_Image, P_StrapLine1, V_Name1, V_Desc1, V_Image, V_CodeNumber, V_Type, V_Price, V_Quantity, V_Weight, V_RRP, T_Taxrate, T_Taxrate2, V_TaxExtra, Supplier, Attributes, '' As Options FROM #TempProductData WHERE Coalesce(Cat5_Name1, '')<>'' AND Coalesce(Cat4_Name1, '')<>'' AND Coalesce(Cat3_Name1, '')<>'' AND Coalesce(Cat2_Name1, '')='' AND Coalesce(Cat1_Name1, '')='')
UNION
(SELECT Cat2_Name1, Cat2_Desc1, '', Cat3_Name1, Cat3_Desc1, '', Cat4_Name1, Cat4_Desc1, '', Cat5_Name1, Cat5_Desc1, '', '', '', '', P_Name1, P_Desc1, P_Image, P_StrapLine1, V_Name1, V_Desc1, V_Image, V_CodeNumber, V_Type, V_Price, V_Quantity, V_Weight, V_RRP, T_Taxrate, T_Taxrate2, V_TaxExtra, Supplier, Attributes, '' As Options FROM #TempProductData WHERE Coalesce(Cat5_Name1, '')<>'' AND Coalesce(Cat4_Name1, '')<>'' AND Coalesce(Cat3_Name1, '')<>'' AND Coalesce(Cat2_Name1, '')<>'' AND Coalesce(Cat1_Name1, '')='')
UNION
(SELECT Cat1_Name1, Cat1_Desc1, Cat1_Image, Cat2_Name1, Cat2_Desc1, Cat2_Image, Cat3_Name1, Cat3_Desc1, Cat3_Image, Cat4_Name1, Cat4_Desc1, Cat4_Image, Cat5_Name1, Cat5_Desc1, Cat5_Image, P_Name1, P_Desc1, P_Image, P_StrapLine1, V_Name1, V_Desc1, V_Image, V_CodeNumber, V_Type, V_Price, V_Quantity, V_Weight, V_RRP, T_Taxrate, T_Taxrate2, V_TaxExtra, Supplier, Attributes, '' As Options FROM #TempProductData WHERE Coalesce(Cat5_Name1, '')<>'' AND Coalesce(Cat4_Name1, '')<>'' AND Coalesce(Cat3_Name1, '')<>'' AND Coalesce(Cat2_Name1, '')<>'' AND Coalesce(Cat1_Name1, '')<>'')
) As OutputProducts

END
GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.9006', CFG_VersionAdded=2.9006 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO



















