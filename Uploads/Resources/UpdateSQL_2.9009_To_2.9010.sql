
/*** Bit of a minor fix to the feeds here. If only one language, we
don't want the culture included in the URLs. So we've modded this to
return blanks for the culture if only one live language, then the feed
code has been modified to cut the culture from URLs if it's blank  ***/

/****** Object:  StoredProcedure [dbo].[_spKartrisFeeds_GetItems]    Script Date: 05/05/2017 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================
-- Author:		Paul
-- Create date: 20/10/2016 13:53:30
-- Description:	Pulls pages, cats and prods for
-- google sitemap file
-- ===================================================
ALTER PROCEDURE [dbo].[_spKartrisFeeds_GetItems]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Count number of live languages
	DECLARE @LanguageCount as tinyint
	SET @LanguageCount = (SELECT COUNT(LANG_ID) From tblKartrisLanguages WHERE LANG_LiveFront = 1) 

	IF @LanguageCount > 1
	BEGIN 
		SELECT 't' as RecordType, PAGE_ID As ItemID, '' as LANG_Culture, PAGE_Name FROM vKartrisTypePages WHERE PAGE_Live=1
		UNION
		SELECT 'c' as RecordType, CAT_ID As ItemID, LANG_Culture, CAT_Name FROM vKartrisTypeCategories INNER JOIN tblKartrisLanguages ON vKartrisTypeCategories.LANG_ID=tblKartrisLanguages.LANG_ID WHERE CAT_Live=1 AND LANG_LiveFront=1
		UNION
		SELECT 'p' as RecordType, P_ID As ItemID, LANG_Culture, P_Name FROM vKartrisTypeProducts  INNER JOIN tblKartrisLanguages ON vKartrisTypeProducts.LANG_ID=tblKartrisLanguages.LANG_ID WHERE P_Live=1 AND LANG_LiveFront=1
		UNION
		SELECT 'n' as RecordType, N_ID As ItemID, (SELECT LANG_Culture FROM tblKartrisLanguages WHERE tblKartrisLanguages.LANG_ID=vKartrisTypeNews.LANG_ID) AS LANG_Culture, N_Name FROM vKartrisTypeNews
	END
	ELSE
	BEGIN 
		SELECT 't' as RecordType, PAGE_ID As ItemID, '' as LANG_Culture, PAGE_Name FROM vKartrisTypePages WHERE PAGE_Live=1
		UNION
		SELECT 'c' as RecordType, CAT_ID As ItemID, '' as LANG_Culture, CAT_Name FROM vKartrisTypeCategories INNER JOIN tblKartrisLanguages ON vKartrisTypeCategories.LANG_ID=tblKartrisLanguages.LANG_ID WHERE CAT_Live=1 AND LANG_LiveFront=1
		UNION
		SELECT 'p' as RecordType, P_ID As ItemID, '' as LANG_Culture, P_Name FROM vKartrisTypeProducts  INNER JOIN tblKartrisLanguages ON vKartrisTypeProducts.LANG_ID=tblKartrisLanguages.LANG_ID WHERE P_Live=1 AND LANG_LiveFront=1
		UNION
		SELECT 'n' as RecordType, N_ID As ItemID, '' AS LANG_Culture, N_Name FROM vKartrisTypeNews
	END
END
GO

/*** This improves the auto-SKU given to new versions created when cloning
the parent product. Previously, we appended [clone-ID] (where ID was the db
ID of the product. But this can result in SKUs that are too long, generate
an SQL error (truncated data) and so the cloned product ends up without any
versions. The new method uses a function to create a new name, bit like how
DOS filenames used to work, e.g.

mysku
musku~1
musku~1~1 etc.

However, if the SKU is 25 chars long
myskumyskumyskumyskumys~1
myskumyskumyskumyskumys~2
myskumyskumyskumyskumys~3
etc.

This should ensure SKUs longer than 25 chars are never created ***/

/****** Object:  UserDefinedFunction [dbo].[fnKartrisVersions_CreateCloneName]    Script Date: 06/05/2017 07:34:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisVersions_CreateCloneName] 
(
	-- Add the parameters for the function here
	@V_CodeNumber as nvarchar(25)
	
)
RETURNS nvarchar(25)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(25);
	DECLARE @Counter as int;
	DECLARE @LengthOfSKU as tinyint;
	DECLARE @LengthOfSuffix as tinyint;
	DECLARE @Exists as bit;

	-- We want to create a new V_CodeNumber that resembles
	-- the original as closely as possible, but is unique.
	-- We can add "~1" to the end, but need to make sure
	-- (a) we don't exceed 25 chars and (b) that we check
	-- the SKU does not already exist. If it does, we go
	-- to ~2 and so on until we get a SKU that doesn't
	-- already exist.
	SET @LengthOfSKU = LEN(@V_CodeNumber);
	SET @Exists = 1;
	SET @Counter = 0;

	-- Keep trying until we find an SKU that is not
	-- yet used
	WHILE @Exists = 1

	BEGIN
		SET @Counter = @Counter + 1;
		SET @LengthOfSuffix = LEN('~' + CAST(@Counter AS nvarchar));
		SET @Result = LEFT(@V_CodeNumber, 25 - @LengthOfSuffix) + '~' + CAST(@Counter AS nvarchar);
		SET @Exists = (SELECT COUNT(V_CodeNumber) FROM tblKartrisVersions WHERE V_CodeNumber = @Result);
	END
	
	-- Return the result of the function
	RETURN @Result

END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_CloneRecords]    Script Date: 06/05/2017 07:59:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	This is used when cloning
-- products... it does not clone the actual
-- product, it produces all the other associated
-- records such as versions, related products,
-- attributes, quantity discounts, customer
-- group prices and object config settings for
-- products and versions
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisProducts_CloneRecords](
								@P_ID_OLD as int,
								@P_ID_NEW as int
								)
AS
BEGIN
	
	SET NOCOUNT ON;

-- CREATE VERSIONS	
INSERT INTO tblKartrisVersions
	 (V_CodeNumber, V_ProductID, V_Price, V_Tax, V_Weight, V_DeliveryTime, V_Quantity, V_QuantityWarnLevel, V_Live, V_DownLoadInfo, V_DownloadType, V_OrderByValue, V_RRP, V_Type, 
		V_CustomerGroupID, V_CustomizationType, V_CustomizationDesc, V_CustomizationCost, V_Tax2, V_TaxExtra)
SELECT dbo.fnKartrisVersions_CreateCloneName(V_CodeNumber), @P_ID_NEW, V_Price, V_Tax, V_Weight, V_DeliveryTime, V_Quantity, V_QuantityWarnLevel, V_Live, V_DownLoadInfo, V_DownloadType, V_OrderByValue, V_RRP, V_Type, 
		V_CustomerGroupID, V_CustomizationType, V_CustomizationDesc, V_CustomizationCost, V_Tax2, V_TaxExtra
FROM tblKartrisVersions WHERE V_ProductID=@P_ID_OLD

-- CREATE RELATED PRODUCTS
INSERT INTO tblKartrisRelatedProducts(RP_ParentID, RP_ChildID)
SELECT @P_ID_NEW, RP_ChildID
FROM tblKartrisRelatedProducts
WHERE (RP_ParentID = @P_ID_OLD)

-- CREATE OBJECT CONFIG SETTINGS - PRODUCTS
INSERT INTO tblKartrisObjectConfigValue(OCV_ObjectConfigID, OCV_ParentID, OCV_Value)
SELECT OCV_ObjectConfigID, @P_ID_NEW, OCV_Value
FROM tblKartrisObjectConfigValue INNER JOIN tblKartrisObjectConfig ON OCV_ObjectConfigID=OC_ID
WHERE (OCV_ParentID = @P_ID_OLD) AND OC_ObjectType='Product'

-- CREATE ATTRIBUTE VALUES
INSERT INTO tblKartrisAttributeValues(ATTRIBV_ProductID, ATTRIBV_AttributeID)
SELECT @P_ID_NEW, ATTRIBV_AttributeID
FROM tblKartrisAttributeValues
WHERE (ATTRIBV_ProductID = @P_ID_OLD)

-- COUNT ATTRIBUTES CREATED, LOOP THROUGH THEM
-- AND CREATE LANGUAGE ELEMENTS
-- in-memory temp versions table to hold distinct ATTRIBV_ID
DECLARE @i int
DECLARE @ATTRIBV_ID_OLD int
DECLARE @ATTRIBV_ID_NEW int

-- create and populate table with original product's attributes
DECLARE @tblKartrisAttributeValues_MEMORY_OLD TABLE (
	idx smallint Primary Key IDENTITY(1,1), ATTRIBV_ID int)
INSERT INTO @tblKartrisAttributeValues_MEMORY_OLD(ATTRIBV_ID)
SELECT DISTINCT ATTRIBV_ID FROM tblKartrisAttributeValues WHERE ATTRIBV_ProductID=@P_ID_OLD

-- create and populate table with new product's versions
DECLARE @tblKartrisAttributeValues_MEMORY_NEW TABLE (
	idx smallint Primary Key IDENTITY(1,1), ATTRIBV_ID int)
INSERT INTO @tblKartrisAttributeValues_MEMORY_NEW(ATTRIBV_ID)
SELECT DISTINCT ATTRIBV_ID FROM tblKartrisAttributeValues WHERE ATTRIBV_ProductID=@P_ID_NEW

DECLARE @numrows int
SET @i = 1

-- number of attributes, should be same in both tables but we just check NEW
SET @numrows = (SELECT COUNT(ATTRIBV_ProductID) FROM tblKartrisAttributeValues WHERE ATTRIBV_ProductID=@P_ID_NEW)
IF @numrows > 0
	WHILE (@i <= (SELECT MAX(idx) FROM @tblKartrisAttributeValues_MEMORY_NEW))
	BEGIN
		-- get the next version's ID, both old and new
		SET @ATTRIBV_ID_OLD = (SELECT ATTRIBV_ID FROM @tblKartrisAttributeValues_MEMORY_OLD WHERE idx= @i)
		SET @ATTRIBV_ID_NEW = (SELECT ATTRIBV_ID FROM @tblKartrisAttributeValues_MEMORY_NEW WHERE idx= @i)

		-- insert new language elements for this version ID
		INSERT INTO tblKartrisLanguageElements
		(LE_LanguageID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value)
		SELECT LE_LanguageID, LE_TypeID, LE_FieldID, @ATTRIBV_ID_NEW, LE_Value
		FROM tblKartrisLanguageElements
		WHERE (LE_ParentID = @ATTRIBV_ID_OLD) AND (LE_TypeID = 14)

		-- increment counter for next version
		SET @i = @i + 1
	END

	
-- COUNT VERSIONS CREATED, LOOP THROUGH THEM
-- AND CREATE LANGUAGE ELEMENTS
-- in-memory temp versions table to hold distinct V_ID
DECLARE @V_ID_OLD int
DECLARE @V_ID_NEW int

-- create and populate table with original product's versions
DECLARE @tblKartrisVersions_MEMORY_OLD TABLE (
	idx smallint Primary Key IDENTITY(1,1), V_ID int)
INSERT INTO @tblKartrisVersions_MEMORY_OLD(V_ID)
SELECT DISTINCT V_ID FROM tblKartrisVersions WHERE V_ProductID=@P_ID_OLD

-- create and populate table with new product's versions
DECLARE @tblKartrisVersions_MEMORY_NEW TABLE (
	idx smallint Primary Key IDENTITY(1,1), V_ID int)
INSERT INTO @tblKartrisVersions_MEMORY_NEW(V_ID)
SELECT DISTINCT V_ID FROM tblKartrisVersions WHERE V_ProductID=@P_ID_NEW

SET @i = 1

-- number of versions, should be same in both tables but we just check NEW
SET @numrows = (SELECT COUNT(V_ID) FROM tblKartrisVersions WHERE V_ProductID=@P_ID_NEW)
IF @numrows > 0
	WHILE (@i <= (SELECT MAX(idx) FROM @tblKartrisVersions_MEMORY_NEW))
	BEGIN
		-- get the next version's ID, both old and new
		SET @V_ID_OLD = (SELECT V_ID FROM @tblKartrisVersions_MEMORY_OLD WHERE idx= @i)
		SET @V_ID_NEW = (SELECT V_ID FROM @tblKartrisVersions_MEMORY_NEW WHERE idx= @i)

		-- insert new language elements for this version ID
		INSERT INTO tblKartrisLanguageElements
		(LE_LanguageID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value)
		SELECT LE_LanguageID, LE_TypeID, LE_FieldID, @V_ID_NEW, LE_Value
		FROM tblKartrisLanguageElements
		WHERE (LE_ParentID = @V_ID_OLD) AND (LE_TypeID = 1)

		-- insert new object config settings for this version
		INSERT INTO tblKartrisObjectConfigValue(OCV_ObjectConfigID, OCV_ParentID, OCV_Value)
		SELECT OCV_ObjectConfigID, @V_ID_NEW, OCV_Value
		FROM tblKartrisObjectConfigValue INNER JOIN tblKartrisObjectConfig ON OCV_ObjectConfigID=OC_ID
		WHERE (OCV_ParentID = @V_ID_OLD) AND OC_ObjectType='Version'

		-- insert customer group prices
		INSERT INTO tblKartrisCustomerGroupPrices
		(CGP_CustomerGroupID, CGP_VersionID, CGP_Price)
		SELECT CGP_CustomerGroupID, @V_ID_NEW, CGP_Price
		FROM tblKartrisCustomerGroupPrices
		WHERE (CGP_VersionID = @V_ID_OLD)

		-- insert quantity discounts
		INSERT INTO tblKartrisQuantityDiscounts
		(QD_VersionID, QD_Quantity, QD_Price)
		SELECT @V_ID_NEW, QD_Quantity, QD_Price
		FROM tblKartrisQuantityDiscounts
		WHERE (QD_VersionID = @V_ID_OLD)

		-- increment counter for next version
		SET @i = @i + 1
	END
END
GO

/****** Object:  Index [V_CodeNumber_UNIQUE]    Script Date: 06/05/2017 09:01:43 ******/
CREATE UNIQUE NONCLUSTERED INDEX [V_CodeNumber_UNIQUE] ON [dbo].[tblKartrisVersions]
(
	[V_CodeNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/* Fixes issue where product data name and desc pulled in wrong language if there are multiple languages */
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetRichSnippetProperties]    Script Date: 18/05/2017 11:30:52 ******/
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
			@P_Rev As P_Review, @Rev_Avg As P_AverageReview, @Rev_Total As P_TotalReview
END
GO

/****** New object config, product level - exclude item from customer discount ******/
SET IDENTITY_INSERT [dbo].[tblKartrisObjectConfig] ON
INSERT [dbo].[tblKartrisObjectConfig] ([OC_ID], [OC_Name], [OC_ObjectType], [OC_DataType], [OC_DefaultValue], [OC_Description], [OC_MultilineValue], [OC_VersionAdded]) VALUES (8, N'K:product.excustomerdiscount', N'Product', N'b', N'0', N'Exclude designated products from customer discount.', 0, 2.9010)
SET IDENTITY_INSERT [dbo].[tblKartrisObjectConfig] OFF
GO

INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'ContentText_SomeItemsExcludedFromDiscount', N'Items marked with ** are excluded from the customer discount', NULL, 2.9010, N'Items marked with ** are excluded from the customer discount', NULL, N'Basket',1);
GO

ALTER TABLE [dbo].[tblKartrisInvoiceRows]
ADD [IR_ExcludeFromCustomerDiscount] bit NOT NULL DEFAULT(0)
GO

/****** Object:  StoredProcedure [dbo].[spKartrisOrders_InvoiceRowsAdd]    Script Date: 25/05/2017 16:57:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisOrders_InvoiceRowsAdd]
(
		   @IR_OrderNumberID int,
		   @IR_VersionCode nvarchar(50),
		   @IR_VersionName nvarchar(1000),
		   @IR_Quantity float,
		   @IR_PricePerItem real,
		   @IR_TaxPerItem real,
		   @IR_OptionsText nvarchar(MAX),
		   @IR_ExcludeFromCustomerDiscount bit
)
AS
BEGIN
	DECLARE @IR_ID INT
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

	

	INSERT INTO [tblKartrisInvoiceRows]
		   ([IR_OrderNumberID]
		   ,[IR_VersionCode]
		   ,[IR_VersionName]
		   ,[IR_Quantity]
		   ,[IR_PricePerItem]
		   ,[IR_TaxPerItem]
		   ,[IR_OptionsText]
		   ,[IR_ExcludeFromCustomerDiscount])
	 VALUES
		   (@IR_OrderNumberID,
		   @IR_VersionCode,
		   @IR_VersionName,
		   @IR_Quantity,
		   @IR_PricePerItem,
		   @IR_TaxPerItem,
		   @IR_OptionsText,
		   @IR_ExcludeFromCustomerDiscount);
	SET @IR_ID = SCOPE_IDENTITY();
	SELECT @IR_ID;

END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetInvoiceRows]    Script Date: 01/23/2013 21:59:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisOrders_GetInvoiceRows]
(
		   @OrderID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IR_VersionCode]
	  ,[IR_VersionName]
	  ,[IR_Quantity]
	  ,[IR_PricePerItem]
	  ,[IR_TaxPerItem]
	  ,[IR_OptionsText]
	  ,[IR_ExcludeFromCustomerDiscount] FROM tblKartrisInvoiceRows WHERE IR_OrderNumberID = @OrderID
	  ORDER BY [IR_ExcludeFromCustomerDiscount];
END
GO

/****** Object:  StoredProcedure [dbo].[spKartrisCustomer_GetInvoice]    Script Date: 26/05/2017 14:40:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Joseph>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisCustomer_GetInvoice] ( 
	@O_ID integer,
	@U_ID integer,
	@intType integer=0
) AS
BEGIN
	SET NOCOUNT ON;

	If @intType=0 -- summary/address only
		Begin	
			SELECT     O.O_BillingAddress, O.O_ShippingAddress, O.O_PurchaseOrderNo, U.U_CardholderEUVATNum, O.O_Date, O.O_CurrencyID, O.O_CurrencyIDGateway, 
								  O.O_TotalPriceGateway, O.O_LanguageID, O.O_Comments
			FROM         tblKartrisUsers AS U INNER JOIN
								  tblKartrisOrders AS O ON O.O_CustomerID = U.U_ID INNER JOIN
								  tblKartrisLanguages AS L ON O.O_LanguageID = L.LANG_ID
			WHERE     (O.O_ID = @O_ID) AND (U.U_ID = @U_ID)
		End

	Else
		Begin -- invoice rows
			SELECT    *
			FROM         tblKartrisInvoiceRows AS IR INNER JOIN
								  tblKartrisOrders AS O ON IR.IR_OrderNumberID = O.O_ID INNER JOIN
								  tblKartrisUsers AS U ON O.O_CustomerID = U.U_ID LEFT OUTER JOIN
								  tblKartrisCoupons AS C ON C.CP_CouponCode = O.O_CouponCode
			WHERE     (O.O_ID = @O_ID) AND (U.U_ID = @U_ID)
			ORDER BY IR_ExcludeFromCustomerDiscount;
		End
END
GO

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetNewestProducts]    Script Date: 25/05/2017 15:09:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: 
-- Description:	
-- Remarks: Updated by Paul, 2017/05/25
-- include MinPrice
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
	
	SELECT DISTINCT TOP (10) tblKartrisProducts.P_ID, tblKartrisLanguageElements.LE_Value AS P_Name, dbo.fnKartrisProduct_GetMinPrice(P_ID) As MinPrice, tblKartrisProducts.P_DateCreated, @LANG_ID LANG_ID
	FROM    tblKartrisProducts INNER JOIN
			  tblKartrisVersions ON tblKartrisProducts.P_ID = tblKartrisVersions.V_ProductID INNER JOIN
			  tblKartrisProductCategoryLink ON tblKartrisProducts.P_ID = tblKartrisProductCategoryLink.PCAT_ProductID INNER JOIN
			  tblKartrisCategories ON tblKartrisProductCategoryLink.PCAT_CategoryID = tblKartrisCategories.CAT_ID INNER JOIN
			  tblKartrisLanguageElements ON tblKartrisProducts.P_ID = tblKartrisLanguageElements.LE_ParentID
	WHERE   (tblKartrisProducts.P_Live=1) AND (tblKartrisProducts.P_CustomerGroupID IS NULL) AND (tblKartrisCategories.CAT_CustomerGroupID IS NULL) AND (tblKartrisVersions.V_CustomerGroupID IS NULL) AND
		   (tblKartrisLanguageElements.LE_LanguageID = @LANG_ID) AND (tblKartrisLanguageElements.LE_TypeID = 2) AND (tblKartrisLanguageElements.LE_FieldID = 1) AND 
		  (NOT (tblKartrisLanguageElements.LE_Value IS NULL))
	ORDER BY tblKartrisProducts.P_DateCreated DESC, tblKartrisProducts.P_ID DESC

END
GO


/****** New Mailchimp config settings ******/
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES
 (N'general.mailchimp.apiurl', N'https://XXX.api.mailchimp.com/3.0/', N's', N't', N'', N'MailChimp API URL. Note that XXX should be replaced with the datacentre of your MailChimp account, e.g. us4', 2.9010, N'https://XXX.api.mailchimp.com/3.0/', 0);
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES
 (N'general.mailchimp.apikey', N'xxxxxxxxxxxxxxxxxxxx', N's', N't', N'', N'The API key you created in your MailChimp account', 2.9010, N'', 0);
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES
 (N'general.mailchimp.enabled', N'n', N's', N'b', N'y|n', N'Whether MailChimp ecommerce integration is enabled or not', 2.9010, N'n', 0);
INSERT INTO [tblKartrisConfig]
(CFG_Name,CFG_Value,CFG_DataType,CFG_DisplayType,CFG_DisplayInfo,CFG_Description,CFG_VersionAdded,CFG_DefaultValue,CFG_Important)
VALUES
(N'general.mailchimp.storeid', N'', N's', N't',	'',N'You can choose a MailChimp store ID e.g. ''MyKartris''',2.9010, N'', 0);
INSERT INTO [tblKartrisConfig]
(CFG_Name,CFG_Value,CFG_DataType,CFG_DisplayType,CFG_DisplayInfo,CFG_Description,CFG_VersionAdded,CFG_DefaultValue,CFG_Important)
VALUES
(N'general.mailchimp.listid', N'', N's', N't',	'',N'MailChimp Subscribers List ID. This list is created in the MailChimp website. MailChimp>Lists>Select Your List>Settings>List name and defaults>ListID should appear in the screen',2.9010, N'', 0);

GO

/****** Updating save basket so autosaves and recovers if logged in, logging in ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Joseph / Paul
-- Create date: 12/May/2008
-- Update date: 21/Jun/2017
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisBasket_SaveBasket] ( 
	@CustomerID INT,
	@BasketName NVARCHAR(200),
	@BasketID BIGINT,
	@NowOffset datetime
) AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @SavedBasketID BIGINT;
	DECLARE @newBV_ID BIGINT;

	
	-- 2017/06/21 Update to allow basket to be saved in
	-- background when a user is logged in, or has just
	-- ordered and a new account was created. This way,
	-- the user will see their basket contents later if
	-- they login on another device.	
	-- We will give such baskets the name "AUTOSAVE",
	-- so we know what to look for and can filter it out
	-- of saved basket display if we want to.

	-- Because there might be an AUTOSAVE basket for this
	-- user already, we're going to first try to delete
	-- any baskets of that name for this user.

	BEGIN TRY  
		-- Lookup basket ID
		SELECT @SavedBasketID = SBSKT_ID FROM tblKartrisSavedBaskets WHERE SBSKT_Name='AUTOSAVE' AND SBSKT_UserID=@CustomerID;

		-- Delete this basket
		EXEC dbo.spKartrisBasket_DeleteSavedBasket @SavedBasketID;
	END TRY  
	BEGIN CATCH  
		 -- NEVER MIND, no basket exists, no problem
	END CATCH  

	INSERT INTO tblKartrisSavedBaskets (SBSKT_UserID,SBSKT_Name,SBSKT_DateTimeAdded)
	VALUES (@CustomerID,@BasketName,@NowOffset);
	
	SET @SavedBasketID=SCOPE_IDENTITY() ;

	DECLARE @BV_ID INT
	DECLARE @BV_VersionID INT
	DECLARE @BV_Quantity FLOAT
	DECLARE @BV_CustomText nvarchar(2000)

	DECLARE Basket_cursor CURSOR FOR 
	SELECT BV_ID,BV_VersionID,BV_Quantity,BV_CustomText FROM tblKartrisBasketValues WHERE BV_ParentID=@BasketID AND BV_ParentType='b';

	OPEN Basket_cursor
	FETCH NEXT FROM Basket_cursor INTO @BV_ID,@BV_VersionID,@BV_Quantity,@BV_CustomText
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO tblKartrisBasketValues(BV_ParentType,BV_ParentID,BV_VersionID,BV_Quantity,BV_CustomText,BV_DateTimeAdded)
		VALUES ('s',@SavedBasketID,@BV_VersionID,@BV_Quantity,@BV_CustomText,@NowOffset)

		SET @newBV_ID=SCOPE_IDENTITY() 

		IF EXISTS (SELECT * FROM tblKartrisBasketOptionValues WHERE BSKTOPT_BasketValueID=@BV_ID) 
		BEGIN
			INSERT INTO tblKartrisBasketOptionValues
			SELECT @newBV_ID,BSKTOPT_OptionID FROM tblKartrisBasketOptionValues WHERE BSKTOPT_BasketValueID=@BV_ID
		END

		FETCH NEXT FROM Basket_cursor INTO @BV_ID,@BV_VersionID,@BV_Quantity,@BV_CustomText
	End

	CLOSE Basket_cursor
	DEALLOCATE Basket_cursor;

END
GO

/****** Object:  StoredProcedure [dbo].[spKartrisBasket_LoadAutosaveBasket]    Script Date: 26/06/2017 13:08:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: 23/Jun/2017
-- Description:	Loads AUTOSAVE basket for
-- specified customer
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_LoadAutosaveBasket] ( 
	@CustomerID BIGINT,
	@BasketID BIGINT,
	@NowOffset datetime
) AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @BV_ID BIGINT
	DECLARE @BV_VersionID BIGINT
	DECLARe @BV_Quantity FLOAT
	DECLARE @newBV_ID BIGINT
	DECLARE @BV_CustomText nvarchar(2000);

	DECLARE @BasketSavedID BIGINT = -1;

	BEGIN TRY  
		-- Find the @BasketSavedID value, then rest can work the same
		SELECT @BasketSavedID = SBSKT_ID FROM tblKartrisSavedBaskets WHERE SBSKT_Name='AUTOSAVE' AND SBSKT_UserID=@CustomerID;

		DECLARE Basket_cursor CURSOR FOR 
		SELECT BV_ID,BV_VersionID,BV_Quantity,BV_CustomText FROM tblKartrisBasketValues WHERE BV_ParentID=@BasketSavedID and BV_ParentType='s'

		OPEN Basket_cursor
		FETCH NEXT FROM Basket_cursor INTO @BV_ID,@BV_VersionID,@BV_Quantity,@BV_CustomText
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			INSERT INTO tblKartrisBasketValues (BV_ParentType,BV_ParentID,BV_VersionID,BV_Quantity,BV_CustomText,BV_DateTimeAdded)
				SELECT 'b' as BV_ParentType,@BasketID as BV_ParentID,@BV_VersionID,@BV_Quantity,@BV_CustomText,@NowOffset FROM tblKartrisBasketValues 
				WHERE BV_ID=@BV_ID

			SET @newBV_ID=SCOPE_IDENTITY() 

			IF EXISTS (SELECT * FROM tblKartrisBasketOptionValues WHERE BSKTOPT_BasketValueID=@BV_ID) 
			BEGIN
				--PRINT cast(@BV_ID as varchar(20)) + ' exist'
				INSERT INTO tblKartrisBasketOptionValues (BSKTOPT_BasketValueID,BSKTOPT_OptionID)
					SELECT @newBV_ID,BSKTOPT_OptionID FROM tblKartrisBasketOptionValues WHERE BSKTOPT_BasketValueID=@BV_ID
			END

			FETCH NEXT FROM Basket_cursor INTO @BV_ID,@BV_VersionID,@BV_Quantity,@BV_CustomText
		END

		CLOSE Basket_cursor
		DEALLOCATE Basket_cursor; 
	END TRY  
	BEGIN CATCH  
		 -- we really don't need to do anything if this fails 
	END CATCH  
END
GO 

/* clean up some unused config settings */
DELETE FROM [dbo].[tblKartrisConfig] WHERE [CFG_Name]=N'general.useURLname';
DELETE FROM [dbo].[tblKartrisConfig] WHERE [CFG_Name]=N'general.linnworks.token';

GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.9010', CFG_VersionAdded=2.9010 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO

