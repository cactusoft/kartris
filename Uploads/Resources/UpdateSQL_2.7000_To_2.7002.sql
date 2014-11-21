

-- =============================================
-- Author:		Mohammad
-- Description:	Updated by Paul, change field
-- in ORDER BY clause
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisAttributes_GetSummaryByProductID]
	(
		@P_ID int,
		@LANG_ID tinyint
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 SELECT     vKartrisTypeAttributes.ATTRIB_ID, vKartrisTypeAttributes.ATTRIB_Name, vKartrisTypeAttributeValues.ATTRIBV_Value,
			vKartrisTypeAttributeValues.ATTRIBV_ProductID, vKartrisTypeAttributes.ATTRIB_Compare
FROM         vKartrisTypeAttributeValues INNER JOIN
					  vKartrisTypeAttributes ON vKartrisTypeAttributeValues.ATTRIBV_AttributeID = vKartrisTypeAttributes.ATTRIB_ID AND 
					  vKartrisTypeAttributeValues.LANG_ID = vKartrisTypeAttributes.LANG_ID
WHERE     (vKartrisTypeAttributes.ATTRIB_Live = 1) AND (vKartrisTypeAttributes.ATTRIB_ShowFrontend = 1) AND (vKartrisTypeAttributeValues.ATTRIBV_ProductID = @P_ID) AND
					   (vKartrisTypeAttributeValues.LANG_ID = @LANG_ID)
ORDER BY vKartrisTypeAttributes.ATTRIB_OrderByValue
END
GO

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetTopList]    Script Date: 2014-10-09 10:17:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Medz
-- Create date: 02/12/2008 13:52:43
-- Last Modified: Paul - Oct 2014
-- Description:	Replaces spKartris_Prod_TopList
-- Remarks:	Switched Prod ID and Lang ID in 
-- [fnKartrisProducts_GetName] call
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisProducts_GetTopList]
	(
	@Limit int,
	@LANG_ID tinyint,
	@StartDate datetime
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	WITH tblTopList AS
	(
		SELECT  tblKartrisInvoiceRows.IR_VersionCode AS IR_VersionCode, SUM(tblKartrisInvoiceRows.IR_Quantity) AS IR_Quantity
		FROM    tblKartrisInvoiceRows LEFT OUTER JOIN tblKartrisOrders ON tblKartrisInvoiceRows.IR_OrderNumberID = tblKartrisOrders.O_ID
		WHERE   (tblKartrisOrders.O_Paid = 1) AND (tblKartrisOrders.O_Date >= @StartDate)
		GROUP BY tblKartrisInvoiceRows.IR_VersionCode
	)
	SELECT TOP (@Limit) vKartrisCategoryProductsVersionsLink.P_ID, [dbo].[fnKartrisProducts_GetName](vKartrisCategoryProductsVersionsLink.P_ID, @LANG_ID) AS P_Name, 
				@LANG_ID as LANG_ID, SUM(tblTopList.IR_Quantity) as ProductHits
	FROM tblTopList INNER JOIN dbo.vKartrisCategoryProductsVersionsLink ON tblTopList.IR_VersionCode = dbo.vKartrisCategoryProductsVersionsLink.V_CodeNumber
	WHERE	vKartrisCategoryProductsVersionsLink.V_CustomerGroupID IS NULL 
		AND vKartrisCategoryProductsVersionsLink.P_CustomerGroupID IS NULL 
		AND vKartrisCategoryProductsVersionsLink.CAT_CustomerGroupID IS NULL
	GROUP BY vKartrisCategoryProductsVersionsLink.P_ID, [dbo].[fnKartrisProducts_GetName](vKartrisCategoryProductsVersionsLink.P_ID, @LANG_ID)
	ORDER BY ProductHits DESC

END

/****** Object:  StoredProcedure [dbo].[_spKartrisUsers_Add]    Script Date: 2014-10-15 10:31:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Medz
-- Last Modified: Paul - Oct 2014
-- Description:	Add users
-- Remarks:	Updated CustomerGroup to Int
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisUsers_Add]
(
			@U_AccountHolderName nvarchar(50),
		   @U_EmailAddress nvarchar(100),
		   @U_Password nvarchar(64),
			@U_LanguageID tinyint,
			@U_CustomerGroupID int,
			@U_CustomerDiscount real,
			@U_Approved bit,
			@U_IsAffiliate bit,
			@U_AffiliateCommission real,
			@U_SupportEndDate datetime,
			@U_Notes nvarchar(MAX),
			@U_SaltValue nvarchar(64)
)
AS
DECLARE @U_ID INT
	SET NOCOUNT OFF;

	
	INSERT INTO [tblKartrisUsers]
		   ([U_AccountHolderName] ,[U_EmailAddress] ,[U_Password] ,[U_LanguageID] ,[U_CustomerGroupID]
			,[U_DefShippingAddressID]
			,[U_DefBillingAddressID]
			,[U_CustomerDiscount] ,[U_Approved] ,[U_IsAffiliate]
			,[U_AffiliateCommission]
			,[U_ML_Format]
			,[U_SupportEndDate]
			,[U_Notes]
			,[U_SaltValue]
			)
	 VALUES
		   (@U_AccountHolderName, @U_EmailAddress, @U_Password, @U_LanguageID, @U_CustomerGroupID,
			0,
			0,
			@U_CustomerDiscount, @U_Approved, @U_IsAffiliate,
			@U_AffiliateCommission,
			't',
			@U_SupportEndDate,
			@U_Notes,
			@U_SaltValue);
	SET @U_ID = SCOPE_IDENTITY();
	SELECT @U_ID;

	/****** Object:  StoredProcedure [dbo].[_spKartrisUsers_Update]    Script Date: 2014-10-15 10:33:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Medz
-- Last Modified: Paul - Oct 2014
-- Description:	Update users
-- Remarks:	Updated CustomerGroup to Int
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisUsers_Update]
(
		   @U_ID int,
			@U_AccountHolderName nvarchar(50),
		   @U_EmailAddress nvarchar(100),
		   @U_Password nvarchar(64),
			@U_LanguageID tinyint,
			@U_CustomerGroupID int,
			@U_CustomerDiscount real,
			@U_Approved bit,
			@U_IsAffiliate bit,
			@U_AffiliateCommission real,
			@U_SupportEndDate datetime,
			@U_Notes nvarchar(MAX),
			@U_SaltValue nvarchar(64)
)
AS
	IF @U_Password = ''
		BEGIN
			SET @U_Password = NULL;
			SET @U_SaltValue = NULL;
		END;
	IF @U_AccountHolderName = ''
		BEGIN
			SET @U_AccountHolderName = NULL;
		END;
		
	IF @U_Notes = ''
		BEGIN
			SET @U_Notes = NULL;
		END;
	SET NOCOUNT OFF;

	
	UPDATE [tblKartrisUsers] SET
			[U_AccountHolderName] = COALESCE (@U_AccountHolderName, U_AccountHolderName),
			[U_EmailAddress] = @U_EmailAddress ,
			[U_Password] = COALESCE (@U_Password, U_Password),
			[U_LanguageID] = @U_LanguageID ,
			[U_CustomerGroupID] = @U_CustomerGroupID , 
			[U_CustomerDiscount] = @U_CustomerDiscount , 
			[U_Approved] = @U_Approved ,
			[U_IsAffiliate] = @U_IsAffiliate ,
			[U_AffiliateCommission] = @U_AffiliateCommission,
			[U_SupportEndDate] = @U_SupportEndDate,
			[U_Notes] = COALESCE (@U_Notes, U_Notes),
			[U_SaltValue] = COALESCE (@U_SaltValue, U_SaltValue)
			WHERE U_ID = @U_ID;
	SELECT @U_ID;

/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetByProductID]    Script Date: 2014-11-21 15:24:15 ******/
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
				AND vKartrisTypeVersions.V_Type<>'s'
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
					WHEN (@OrderBy = 'V_Quantity' AND @OrderDirection = 'A') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Quantity ASC))
					WHEN (@OrderBy = 'V_Quantity' AND @OrderDirection = 'D') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Quantity DESC))
					WHEN (@OrderDirection = 'A') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Price ASC))
					ELSE (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Price DESC))
					END
	END			
END
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetByProductID]    Script Date: 01/23/2013 21:59:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- BACK/FRONT : Back-End (Not Necessary to be V_Live=True)
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_GetByProductID](@P_ID as int, @LANG_ID as tinyint)
AS
BEGIN

	DECLARE @OrderBy as nvarchar(50);
	SELECT @OrderBy = P_OrderVersionsBy FROM tblKartrisProducts WHERE P_ID = @P_ID;
	IF @OrderBy IS NULL OR @OrderBy = '' OR @OrderBy = 'd'
	BEGIN
		 SELECT @OrderBy = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = 'frontend.versions.display.sortdefault';
	END

	DECLARE @SortByValue as bit;
	SET @SortByValue = 0;
	IF @OrderBy = 'V_OrderByValue' BEGIN SET @SortByValue = 1 END;

	SET NOCOUNT ON;
	SELECT     vKartrisTypeVersions.V_ID, tblKartrisTaxRates.T_Taxrate, vKartrisTypeVersions.V_Price, vKartrisTypeVersions.V_Weight, vKartrisTypeVersions.V_RRP, 
					  vKartrisTypeVersions.V_Tax, tblKartrisTaxRates.T_Taxrate AS Expr1, '0' AS CalculatedTax, vKartrisTypeVersions.V_ProductID, vKartrisTypeVersions.V_CodeNumber, 
					  vKartrisTypeVersions.V_Quantity, vKartrisTypeVersions.V_QuantityWarnLevel, vKartrisTypeVersions.V_Price AS OrderByBit, vKartrisTypeVersions.V_Name, 
					  vKartrisTypeVersions.V_Desc, MIN(tblKartrisQuantityDiscounts.QD_Price) AS QuantityDiscount, vKartrisTypeVersions.V_OrderByValue, vKartrisTypeVersions.V_Type, 
					  vKartrisTypeVersions.V_CustomizationType, vKartrisTypeVersions.V_CustomizationDesc, vKartrisTypeVersions.V_CustomizationCost, @SortByValue AS SortByValue
FROM         vKartrisTypeVersions LEFT OUTER JOIN
					  tblKartrisTaxRates ON vKartrisTypeVersions.V_Tax = tblKartrisTaxRates.T_ID LEFT OUTER JOIN
					  tblKartrisQuantityDiscounts ON vKartrisTypeVersions.V_ID = tblKartrisQuantityDiscounts.QD_VersionID
WHERE     (vKartrisTypeVersions.LANG_ID = @LANG_ID) AND (vKartrisTypeVersions.V_ProductID = @P_ID) AND (vKartrisTypeVersions.V_Type <> 's')
GROUP BY vKartrisTypeVersions.V_ID, tblKartrisTaxRates.T_Taxrate, vKartrisTypeVersions.V_Price, vKartrisTypeVersions.V_Weight, vKartrisTypeVersions.V_RRP, 
					  vKartrisTypeVersions.V_Tax, vKartrisTypeVersions.V_ProductID, vKartrisTypeVersions.V_CodeNumber, vKartrisTypeVersions.V_Quantity, 
					  vKartrisTypeVersions.V_QuantityWarnLevel, vKartrisTypeVersions.V_Name, vKartrisTypeVersions.V_Desc, vKartrisTypeVersions.V_OrderByValue, 
					  vKartrisTypeVersions.V_Type, vKartrisTypeVersions.V_CustomizationType, vKartrisTypeVersions.V_CustomizationDesc, 
					  vKartrisTypeVersions.V_CustomizationCost

--ORDER BY vKartrisTypeVersions.V_Type, vKartrisTypeVersions.V_Name, vKartrisTypeVersions.V_CodeNumber
	ORDER BY	CASE
				WHEN @OrderBy = 'V_Name' THEN  (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Name))
				WHEN @OrderBy = 'V_Price' THEN vKartrisTypeVersions.V_Price
				WHEN @OrderBy = 'V_OrderByValue' THEN vKartrisTypeVersions.V_OrderByValue
				WHEN @OrderBy = 'V_Quantity' THEN vKartrisTypeVersions.V_Quantity
				ELSE vKartrisTypeVersions.V_Price
				END
				
END
GO

/****** change contraint to allow "-" for default sort direction ***********/
ALTER TABLE [dbo].[tblKartrisProducts] DROP CONSTRAINT [CK_Products_VersionsSortDirection]
GO

ALTER TABLE [dbo].[tblKartrisProducts]  WITH CHECK ADD  CONSTRAINT [CK_Products_VersionsSortDirection] CHECK  (([P_VersionsSortDirection]='-' OR [P_VersionsSortDirection]='a' OR [P_VersionsSortDirection]='d'))
GO

ALTER TABLE [dbo].[tblKartrisProducts] CHECK CONSTRAINT [CK_Products_VersionsSortDirection]
GO

/****** Object:  Default [DF_tblKartrisProducts_P_VersionsSortDirection]    Script Date: 11/21/2014 21:59:08 ******/
ALTER TABLE [dbo].[tblKartrisProducts] DROP CONSTRAINT [DF_tblKartrisProducts_P_VersionsSortDirection]
GO

ALTER TABLE [dbo].[tblKartrisProducts] ADD  CONSTRAINT [DF_tblKartrisProducts_P_VersionsSortDirection]  DEFAULT ('-') FOR [P_VersionsSortDirection]
GO