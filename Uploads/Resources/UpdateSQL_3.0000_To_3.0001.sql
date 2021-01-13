/****** Object:  StoredProcedure [dbo].[_spKartrisDB_ExportOrders]    Script Date: 17/10/2019 11:00:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	Now pulls tax and value from
-- XML basket object saved with order
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisDB_ExportOrders]
(
	@StartDate as nvarchar(100),
	@EndDate as nvarchar(100),
	@IncludeDetails as bit,
	@IncludeIncomplete as bit
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Cmd as nvarchar(MAX);
	
	SET @Cmd = 'SELECT tblKartrisOrders.O_ID,
							tblKartrisOrders.O_CustomerID,
							tblKartrisUsers.U_EmailAddress,
							tblKartrisUsers.U_AccountHolderName, 
							tblKartrisOrders.O_Date 
							'
	
	IF @IncludeDetails = 1	BEGIN

	SET @Cmd = @Cmd +		', Cast(Round((SELECT CASE
								WHEN tblKartrisOrders.O_PricesIncTax = 1
								   THEN
										(SELECT Round(SUM(IR_PricePerItem * IR_Quantity),4) FROM tblKartrisInvoiceRows WHERE IR_OrderNumberID=tblKartrisOrders.O_ID) - (SELECT SUM(IR_TaxPerItem * IR_Quantity) FROM tblKartrisInvoiceRows WHERE IR_OrderNumberID=tblKartrisOrders.O_ID)
								   ELSE
										(SELECT Round(SUM(IR_PricePerItem * IR_Quantity),4) FROM tblKartrisInvoiceRows WHERE IR_OrderNumberID=tblKartrisOrders.O_ID)
							END), 4) As Decimal(18,4)) As ItemsExTax,

							Cast(Round((SELECT Round(SUM(IR_TaxPerItem * IR_Quantity),4) FROM tblKartrisInvoiceRows WHERE IR_OrderNumberID=tblKartrisOrders.O_ID), 4) As Decimal(18,4))
							As ItemsTax,

							Cast(SUBSTRING(O_Data,CHARINDEX(''|||'', O_Data) + 3, CHARINDEX(''</Basket>'', O_Data) - (CHARINDEX(''|||'', O_Data) + 3 - 9)) As XML).value(''(Basket/CouponDiscount/ExTax)[1]'', ''decimal(18,4)'') as CouponDiscountExTax,
						   
							Cast(SUBSTRING(O_Data,CHARINDEX(''|||'', O_Data) + 3, CHARINDEX(''</Basket>'', O_Data) - (CHARINDEX(''|||'', O_Data) + 3 - 9)) As XML).value(''(Basket/CouponDiscount/IncTax)[1]'', ''decimal(18,4)'') -
							Cast(SUBSTRING(O_Data,CHARINDEX(''|||'', O_Data) + 3, CHARINDEX(''</Basket>'', O_Data) - (CHARINDEX(''|||'', O_Data) + 3 - 9)) As XML).value(''(Basket/CouponDiscount/ExTax)[1]'', ''decimal(18,4)'') as CouponDiscountTax,

							Cast(SUBSTRING(O_Data,CHARINDEX(''|||'', O_Data) + 3, CHARINDEX(''</Basket>'', O_Data) - (CHARINDEX(''|||'', O_Data) + 3 - 9)) As XML).value(''(Basket/PromotionDiscount/ExTax)[1]'', ''decimal(18,4)'') as PromotionDiscountExTax,
						   
							Cast(SUBSTRING(O_Data,CHARINDEX(''|||'', O_Data) + 3, CHARINDEX(''</Basket>'', O_Data) - (CHARINDEX(''|||'', O_Data) + 3 - 9)) As XML).value(''(Basket/PromotionDiscount/IncTax)[1]'', ''decimal(18,4)'') -
							Cast(SUBSTRING(O_Data,CHARINDEX(''|||'', O_Data) + 3, CHARINDEX(''</Basket>'', O_Data) - (CHARINDEX(''|||'', O_Data) + 3 - 9)) As XML).value(''(Basket/PromotionDiscount/ExTax)[1]'', ''decimal(18,4)'') as PromotionDiscountTax,

							Cast(SUBSTRING(O_Data,CHARINDEX(''|||'', O_Data) + 3, CHARINDEX(''</Basket>'', O_Data) - (CHARINDEX(''|||'', O_Data) + 3 - 9)) As XML).value(''(Basket/ShippingPrice/ExTax)[1]'', ''decimal(18,4)'') as ShippingPriceExTax,
							Cast(tblKartrisOrders.O_ShippingTax As Decimal(18,4)) As O_ShippingTax, 
							Cast(tblKartrisOrders.O_TotalPrice As Decimal(18,4)) As O_TotalPrice,
							tblKartrisOrders.O_DiscountPercentage, tblKartrisOrders.O_AffiliatePercentage, 
							tblKartrisOrders.O_PurchaseOrderNo, tblKartrisOrders.O_SecurityID, tblKartrisOrders.O_Sent, tblKartrisOrders.O_Invoiced, 
							tblKartrisOrders.O_Shipped, tblKartrisOrders.O_Paid,tblKartrisOrders.O_Status, tblKartrisOrders.O_LastModified, tblKartrisOrders.O_WishListID, 
							tblKartrisOrders.O_CouponCode, tblKartrisOrders.O_CouponDiscountTotal, tblKartrisOrders.O_PricesIncTax, tblKartrisOrders.O_TaxDue, 
							tblKartrisOrders.O_PaymentGateWay, tblKartrisOrders.O_ReferenceCode, tblKartrisLanguages.LANG_BackName, tblKartrisCurrencies.CUR_Symbol, 
							tblKartrisOrders.O_TotalPriceGateway, tblKartrisOrders.O_AffiliatePaymentID, tblKartrisOrders.O_AffiliateTotalPrice, tblKartrisOrders.O_SendOrderUpdateEmail '
	END

	SET @Cmd = @Cmd + ' FROM tblKartrisOrders INNER JOIN
							tblKartrisUsers ON tblKartrisOrders.O_CustomerID = tblKartrisUsers.U_ID INNER JOIN
							tblKartrisLanguages ON tblKartrisOrders.O_LanguageID = tblKartrisLanguages.LANG_ID INNER JOIN
							tblKartrisCurrencies ON tblKartrisOrders.O_CurrencyID = tblKartrisCurrencies.CUR_ID
							WHERE left(O_Data, 5) = ''<?xml'' '
	
	IF (@StartDate IS NOT NULL) AND (@EndDate IS NOT NULL)
	BEGIN
		IF (isnumeric(@StartDate) = 1) AND (isnumeric(@EndDate) = 1)
			BEGIN
				SET @Cmd = @Cmd + ' AND O_ID > (CAST(' + @StartDate + ' as int)-1) AND O_ID < (CAST('  + @EndDate + ' as int)+1)'
			END
		ELSE
			BEGIN
				SET @Cmd = @Cmd + ' AND O_Date BETWEEN CAST(''' + @StartDate + ''' as DateTime) AND CAST('''  + @EndDate + ''' as DateTime)'
			END
		
	END
	IF @IncludeIncomplete = 0 OR @IncludeIncomplete IS NULL
	BEGIN
		SET @Cmd = @Cmd + ' AND O_Paid = 1 '
	END

	SET @Cmd = @Cmd + ' ORDER BY O_Date'
	
	EXECUTE(@Cmd);
	
	
END

GO

/****** Object:  Index [OrderID]    Script Date: 20/12/2019 10:12:50 ******/
CREATE NONCLUSTERED INDEX [OrderID] ON [dbo].[tblKartrisOrdersPromotions]
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [OP_OrderID]    Script Date: 20/12/2019 10:25:49 ******/
CREATE NONCLUSTERED INDEX [OP_OrderID] ON [dbo].[tblKartrisOrderPaymentLink]
(
	[OP_OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/* Add delay of a second after creating user, before updating for guest account */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spKartrisUsers_Add]
(
		   @U_EmailAddress nvarchar(100),
		   @U_Password nvarchar(64),
		   @U_SaltValue nvarchar(64),
		   @U_GDPR_SignupIP nvarchar(50),
		   @U_GDPR_IsGuest bit
)
AS
DECLARE @U_ID INT
	SET NOCOUNT OFF;

	-- If is a guest checkout, we're
	-- going to append |GUEST| to the end
	-- of the email. This should ensure it
	-- is unique if there is already an 
	-- account with the same email.
	If @U_GDPR_IsGuest = 1
	BEGIN
		SET @U_EmailAddress = @U_EmailAddress + '|GUEST|'
	END

	INSERT INTO [tblKartrisUsers]
		   ([U_EmailAddress]
		   ,[U_Password]
		   ,[U_LanguageID]
			,[U_CustomerGroupID]
			,[U_DefShippingAddressID]
			,[U_DefBillingAddressID]
			,[U_CustomerDiscount]
			,[U_SaltValue]
			,[U_GDPR_SignupIP]
			,[U_GDPR_IsGuest])
	 VALUES
		   (@U_EmailAddress,
			@U_Password,
			1,0,0,0,0,
			@U_SaltValue,
			@U_GDPR_SignupIP,
			@U_GDPR_IsGuest);
	SET @U_ID = SCOPE_IDENTITY();

	-- Let's update the new record's email address to add the
	-- db ID. This ensures that multiple guest records for a
	-- single email can be created, without violating the need
	-- for unique addresses.
	If @U_GDPR_IsGuest = 1
	BEGIN
		WAITFOR DELAY '00:00:01'; -- one second delay, should ensure record is there before we update
		UPDATE tblKartrisUsers SET U_EmailAddress = U_EmailAddress + Convert(NVARCHAR(50), @U_ID)
		WHERE U_ID=@U_ID;
	END

	SELECT @U_ID;

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
-- products and versions.
-- Updated 2020/01/30 to make sure final part
-- which clones the version language elements
-- puts both sets of version IDs into temp
-- tables in same order.
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
FROM tblKartrisVersions WHERE V_ProductID=@P_ID_OLD ORDER BY V_ID

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
SELECT DISTINCT V_ID FROM tblKartrisVersions WHERE V_ProductID=@P_ID_OLD ORDER BY V_ID

-- create and populate table with new product's versions
DECLARE @tblKartrisVersions_MEMORY_NEW TABLE (
	idx smallint Primary Key IDENTITY(1,1), V_ID int)
INSERT INTO @tblKartrisVersions_MEMORY_NEW(V_ID)
SELECT DISTINCT V_ID FROM tblKartrisVersions WHERE V_ProductID=@P_ID_NEW ORDER BY V_ID

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

/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_SearchProductsByName]    Script Date: 20/05/2020 12:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisProducts_SearchProductsByName]
(
	@Key as nvarchar(50),
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT        TOP(50) P_ID, P_Name
FROM            vKartrisTypeProductsLite
WHERE        (LANG_ID = @LANG_ID) AND P_Name LIKE @Key + '%'

GO


/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_UpdateCustomerGroupPriceList]    Script Date: 13/01/2021 11:09:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_UpdateCustomerGroupPriceList]
(
	@CG_ID as bigint,
	@CGP_VersionID as bigint,
	@CGP_Price as DECIMAL(18,4)
)								
AS
BEGIN
	
	SET NOCOUNT ON;

	if EXISTS(SELECT CGP_VersionID FROM dbo.tblKartrisCustomerGroupPrices WHERE CGP_VersionID = @CGP_VersionID AND CGP_CustomerGroupID = @CG_ID)
		BEGIN
			UPDATE dbo.tblKartrisCustomerGroupPrices
			SET CGP_Price = @CGP_Price WHERE CGP_VersionID = @CGP_VersionID AND CGP_CustomerGroupID = @CG_ID;
		END
	ELSE
	  BEGIN
		INSERT INTO dbo.tblKartrisCustomerGroupPrices (CGP_CustomerGroupID, CGP_VersionID, CGP_Price) VALUES (@CG_ID, @CGP_VersionID, @CGP_Price);
	  END



END

GO

/*** New language strings  ***/
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES
(N'f', N'ContentText_AccountBalance', N'Account Balance', NULL, 3.0001, N'Account Balance', NULL, N'Kartris',1);

GO

/* Change config setting */
UPDATE tblKartrisConfig SET CFG_DisplayInfo = 'n|e|s|t|c', CFG_Description='The display type for the featured products (front page specials) - [n]ormal/[e]xtended/[s]hortened/[t]abular/[c]arousel' WHERE CFG_Name='frontend.featuredproducts.display.default';
GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='3.0001', CFG_VersionAdded=3.0001 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO


