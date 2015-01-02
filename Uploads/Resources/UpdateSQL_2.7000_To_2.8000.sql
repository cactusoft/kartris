

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

/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_Delete]    Script Date: 2014-11-23 21:54:14 ******/
--Modified to delete the object config settings for versions
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_Delete](@V_ID as bigint, @DownloadFile as nvarchar(MAX) out)
AS
BEGIN
	SET NOCOUNT ON;
EXEC [dbo].[_spKartrisMediaLinks_DeleteByParent] 
			@ParentID = @V_ID, 
			@ParentType = 'v';
			
	EXEC [dbo].[_spKartrisPromotions_DeleteByParent] 
			@ParentID = @V_ID, 
			@ParentType = 'v';
			

	SELECT @DownloadFile = V_DownLoadInfo
	FROM dbo.tblKartrisVersions
	WHERE V_ID = @V_ID AND V_DownloadType = 'u';
	
	DELETE FROM tblKartrisLanguageElements
	WHERE     (LE_TypeID = 1)	-- For Versions
	AND (LE_ParentID = @V_ID);	-- VersionID
	

	
	DELETE FROM dbo.tblKartrisVersionOptionLink
	WHERE V_OPT_VersionID = @V_ID;
	
	DELETE FROM dbo.tblKartrisCustomerGroupPrices
	WHERE CGP_VersionID = @V_ID;

	DELETE FROM dbo.tblKartrisQuantityDiscounts
	WHERE QD_VersionID = @V_ID;

	DELETE FROM dbo.tblKartrisObjectConfigValue
	WHERE OCV_ObjectConfigID = 6 AND OCV_ParentID = @V_ID;

IF @V_ID <> 0 AND @V_ID NOT IN (SELECT DELETED_ID FROM dbo.tblKartrisDeletedItems WHERE Deleted_Type = 'v') BEGIN
	
		DECLARE @Timeoffset as int;
		set @Timeoffset = CAST(dbo.fnKartrisConfig_GetValue('general.timeoffset') as int);
		INSERT INTO dbo.tblKartrisDeletedItems VALUES(@V_ID, 'v', dbo.fnKartrisVersions_GetProductID(@V_ID), DateAdd(hour, @Timeoffset, GetDate()));
	
END
;
	
	DELETE FROM dbo.tblKartrisVersions
	WHERE V_ID = @V_ID;
	
	

END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_DeleteByProduct]    Script Date: 2014-11-23 21:54:38 ******/
--Modified to delete the object config settings for versions
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_DeleteByProduct](@P_ID as int, @DownloadFiles as nvarchar(MAX) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON;
	SET @DownloadFiles = '';

	DECLARE versionCursor CURSOR FOR 
	SELECT V_ID
	FROM dbo.tblKartrisVersions
	WHERE V_ProductID = @P_ID
		
	DECLARE @V_ID as bigint;
	
	OPEN versionCursor
	FETCH NEXT FROM versionCursor
	INTO @V_ID;

	WHILE @@FETCH_STATUS = 0
	BEGIN

	EXEC [dbo].[_spKartrisMediaLinks_DeleteByParent] 
			@ParentID = @V_ID, 
			@ParentType = 'v';
			
	EXEC [dbo].[_spKartrisPromotions_DeleteByParent] 
			@ParentID = @V_ID, 
			@ParentType = 'v';
			
	
	DELETE FROM tblKartrisLanguageElements
	WHERE     (LE_TypeID = 1)	-- For Versions
	AND (LE_ParentID = @V_ID);	-- VersionID
	

	
	DELETE FROM dbo.tblKartrisVersionOptionLink
	WHERE V_OPT_VersionID = @V_ID;
	
	DELETE FROM dbo.tblKartrisCustomerGroupPrices
	WHERE CGP_VersionID = @V_ID;

	DELETE FROM dbo.tblKartrisQuantityDiscounts
	WHERE QD_VersionID = @V_ID;

	DELETE FROM dbo.tblKartrisObjectConfigValue
	WHERE OCV_ObjectConfigID = 6 AND OCV_ParentID = @V_ID;

	SELECT @DownloadFiles = V_DownLoadInfo + '##' + @DownloadFiles
	FROM dbo.tblKartrisVersions
	WHERE V_ID = @V_ID AND V_DownloadType = 'u';

	DELETE FROM dbo.tblKartrisVersions
	WHERE V_ID = @V_ID;
	
	IF @V_ID <> 0 AND @V_ID NOT IN (SELECT DELETED_ID FROM dbo.tblKartrisDeletedItems WHERE Deleted_Type = 'v') BEGIN
		
			DECLARE @Timeoffset as int;
			set @Timeoffset = CAST(dbo.fnKartrisConfig_GetValue('general.timeoffset') as int);
			INSERT INTO dbo.tblKartrisDeletedItems VALUES(@V_ID, 'v', @P_ID, DateAdd(hour, @Timeoffset, GetDate()));
		
	END
		FETCH NEXT FROM versionCursor
		INTO @V_ID;

	END

	CLOSE versionCursor
	DEALLOCATE versionCursor;
	
		
END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_DeleteSuspendedVersions]    Script Date: 2014-11-23 21:55:03 ******/
--Modified to delete the object config settings for versions
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_DeleteSuspendedVersions](@P_ID as bigint)
AS
BEGIN
	SET NOCOUNT ON;
	
	-- 1. Delete Related Data From VersionOptionLink
	
	DELETE FROM tblKartrisVersionOptionLink
	FROM        tblKartrisVersionOptionLink INNER JOIN
				tblKartrisVersions ON tblKartrisVersionOptionLink.V_OPT_VersionID = tblKartrisVersions.V_ID
	WHERE		(tblKartrisVersions.V_ProductID = @P_ID) AND (tblKartrisVersions.V_Type = 's');
	

	-- 2. Delete Related Data From LanguageElements
	
	DELETE FROM tblKartrisLanguageElements
	FROM        tblKartrisLanguageElements INNER JOIN
				tblKartrisLanguageElementTypes ON tblKartrisLanguageElements.LE_TypeID = tblKartrisLanguageElementTypes.LET_ID INNER JOIN
				tblKartrisVersions ON tblKartrisLanguageElements.LE_ParentID = tblKartrisVersions.V_ID
	WHERE		(tblKartrisLanguageElementTypes.LET_Name = 'tblKartrisVersions') AND (tblKartrisVersions.V_ProductID = @P_ID) AND (tblKartrisVersions.V_Type = 's');
	
	DELETE FROM tblKartrisCustomerGroupPrices
	FROM        tblKartrisCustomerGroupPrices INNER JOIN
				tblKartrisVersions ON tblKartrisCustomerGroupPrices.CGP_VersionID = tblKartrisVersions.V_ID
	WHERE		(tblKartrisVersions.V_ProductID = @P_ID) AND (tblKartrisVersions.V_Type = 's');

	DELETE FROM tblKartrisQuantityDiscounts
	FROM        tblKartrisQuantityDiscounts INNER JOIN
				tblKartrisVersions ON tblKartrisQuantityDiscounts.QD_VersionID = tblKartrisVersions.V_ID
	WHERE		(tblKartrisVersions.V_ProductID = @P_ID) AND (tblKartrisVersions.V_Type = 's');

	DELETE FROM tblKartrisObjectConfigValue
	FROM        tblKartrisObjectConfig INNER JOIN
				tblKartrisObjectConfigValue ON tblKartrisObjectConfigValue.OCV_ObjectConfigID = tblKartrisObjectConfig.OC_ID
				 INNER JOIN
				tblKartrisVersions ON tblKartrisObjectConfigValue.OCV_ParentID = tblKartrisVersions.V_ID
	WHERE		(tblKartrisVersions.V_ProductID = @P_ID) AND (tblKartrisVersions.V_Type = 's') AND tblKartrisObjectConfig.OC_Name LIKE 'K:version.%';

	-- 3. Delete Suspended Versions From Versions
	
	DELETE FROM tblKartrisVersions
	WHERE (tblKartrisVersions.V_ProductID = @P_ID) AND (tblKartrisVersions.V_Type = 's');
	

END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_DeleteByProduct]    Script Date: 12/29/2014 12:35:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Now deletes object configs
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_DeleteByProduct](@P_ID as int, @DownloadFiles as nvarchar(MAX) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON;
	SET @DownloadFiles = '';

	DECLARE versionCursor CURSOR FOR 
	SELECT V_ID
	FROM dbo.tblKartrisVersions
	WHERE V_ProductID = @P_ID
		
	DECLARE @V_ID as bigint;
	
	OPEN versionCursor
	FETCH NEXT FROM versionCursor
	INTO @V_ID;

	WHILE @@FETCH_STATUS = 0
	BEGIN

	EXEC [dbo].[_spKartrisMediaLinks_DeleteByParent] 
			@ParentID = @V_ID, 
			@ParentType = 'v';
			
	EXEC [dbo].[_spKartrisPromotions_DeleteByParent] 
			@ParentID = @V_ID, 
			@ParentType = 'v';	
	
	DELETE FROM tblKartrisLanguageElements
	WHERE     (LE_TypeID = 1)	-- For Versions
	AND (LE_ParentID = @V_ID);	-- VersionID
	
	DELETE FROM dbo.tblKartrisVersionOptionLink
	WHERE V_OPT_VersionID = @V_ID;
	
	DELETE FROM dbo.tblKartrisCustomerGroupPrices
	WHERE CGP_VersionID = @V_ID;

	DELETE FROM dbo.tblKartrisQuantityDiscounts
	WHERE QD_VersionID = @V_ID;

	SELECT @DownloadFiles = V_DownLoadInfo + '##' + @DownloadFiles
	FROM dbo.tblKartrisVersions
	WHERE V_ID = @V_ID AND V_DownloadType = 'u';

	DELETE tblKartrisObjectConfigValue
	FROM tblKartrisObjectConfig INNER JOIN tblKartrisObjectConfigValue ON tblKartrisObjectConfig.OC_ID = tblKartrisObjectConfigValue.OCV_ObjectConfigID
	WHERE (tblKartrisObjectConfigValue.OCV_ParentID = @V_ID) AND (tblKartrisObjectConfig.OC_ObjectType = 'Version');

	DELETE FROM dbo.tblKartrisVersions
	WHERE V_ID = @V_ID;
	
	IF @V_ID <> 0 AND @V_ID NOT IN (SELECT DELETED_ID FROM dbo.tblKartrisDeletedItems WHERE Deleted_Type = 'v') BEGIN
		
			DECLARE @Timeoffset as int;
			set @Timeoffset = CAST(dbo.fnKartrisConfig_GetValue('general.timeoffset') as int);
			INSERT INTO dbo.tblKartrisDeletedItems VALUES(@V_ID, 'v', @P_ID, DateAdd(hour, @Timeoffset, GetDate()));
		
	END
		FETCH NEXT FROM versionCursor
		INTO @V_ID;

	END

	CLOSE versionCursor
	DEALLOCATE versionCursor;
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_Delete]    Script Date: 12/29/2014 12:35:11  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Now deletes object configs
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_Delete](@V_ID as bigint, @DownloadFile as nvarchar(MAX) out)
AS
BEGIN
	SET NOCOUNT ON;
EXEC [dbo].[_spKartrisMediaLinks_DeleteByParent] 
			@ParentID = @V_ID, 
			@ParentType = 'v';
			
	EXEC [dbo].[_spKartrisPromotions_DeleteByParent] 
			@ParentID = @V_ID, 
			@ParentType = 'v';
			
	SELECT @DownloadFile = V_DownLoadInfo
	FROM dbo.tblKartrisVersions
	WHERE V_ID = @V_ID AND V_DownloadType = 'u';
	
	DELETE FROM tblKartrisLanguageElements
	WHERE     (LE_TypeID = 1)	-- For Versions
	AND (LE_ParentID = @V_ID);	-- VersionID
	
	DELETE FROM dbo.tblKartrisVersionOptionLink
	WHERE V_OPT_VersionID = @V_ID;
	
	DELETE FROM dbo.tblKartrisCustomerGroupPrices
	WHERE CGP_VersionID = @V_ID;

	DELETE FROM dbo.tblKartrisQuantityDiscounts
	WHERE QD_VersionID = @V_ID;

	DELETE tblKartrisObjectConfigValue
	FROM tblKartrisObjectConfig INNER JOIN tblKartrisObjectConfigValue ON tblKartrisObjectConfig.OC_ID = tblKartrisObjectConfigValue.OCV_ObjectConfigID
	WHERE (tblKartrisObjectConfigValue.OCV_ParentID = @V_ID) AND (tblKartrisObjectConfig.OC_ObjectType = 'Version');

IF @V_ID <> 0 AND @V_ID NOT IN (SELECT DELETED_ID FROM dbo.tblKartrisDeletedItems WHERE Deleted_Type = 'v') BEGIN
	
		DECLARE @Timeoffset as int;
		set @Timeoffset = CAST(dbo.fnKartrisConfig_GetValue('general.timeoffset') as int);
		INSERT INTO dbo.tblKartrisDeletedItems VALUES(@V_ID, 'v', dbo.fnKartrisVersions_GetProductID(@V_ID), DateAdd(hour, @Timeoffset, GetDate()));
	
END
;
	
	DELETE FROM dbo.tblKartrisVersions
	WHERE V_ID = @V_ID;
END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_Delete]    Script Date: 01/23/2013 21:59:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	replaces [spKartris_VER_GetBaseVersion]
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisProducts_Delete](@ProductID as bigint)
AS
BEGIN
	SET NOCOUNT ON;

	EXEC [dbo].[_spKartrisVersions_DeleteByProduct] 
			@P_ID = @ProductID,
			@DownloadFiles='';	

EXEC [dbo].[_spKartrisMediaLinks_DeleteByParent] 
			@ParentID = @ProductID, 
			@ParentType = 'p';
			
	EXEC [dbo].[_spKartrisPromotions_DeleteByParent] 
			@ParentID = @ProductID, 
			@ParentType = 'p';
	
	DELETE FROM tblKartrisLanguageElements
	WHERE     (LE_TypeID = 2) AND (LE_ParentID = @ProductID);
		
	DELETE FROM tblKartrisProductCategoryLink
	WHERE     (PCAT_ProductID = @ProductID);
	
	DELETE FROM tblKartrisProductOptionGroupLink
	WHERE     (P_OPTG_ProductID = @ProductID);

	DELETE FROM tblKartrisProductOptionLink
	WHERE     (P_OPT_ProductID = @ProductID);
	
	DELETE FROM tblKartrisRelatedProducts
	WHERE     (RP_ParentID = @ProductID) OR (RP_ChildID = @ProductID);
	
	DELETE FROM tblKartrisReviews
	WHERE	(REV_ProductID = @ProductID);

	DELETE FROM dbo.tblKartrisAttributeValues
	WHERE	(ATTRIBV_ProductID = @ProductID);
	
	DELETE FROM dbo.tblKartrisProducts
	WHERE P_ID = @ProductID;
	
	DELETE tblKartrisObjectConfigValue
	FROM tblKartrisObjectConfig INNER JOIN tblKartrisObjectConfigValue ON tblKartrisObjectConfig.OC_ID = tblKartrisObjectConfigValue.OCV_ObjectConfigID
	WHERE (tblKartrisObjectConfigValue.OCV_ParentID = @ProductID) AND (tblKartrisObjectConfig.OC_ObjectType = 'Product');

IF @ProductID <> 0 AND @ProductID NOT IN (SELECT DELETED_ID FROM dbo.tblKartrisDeletedItems WHERE Deleted_Type = 'p') BEGIN
	
		DECLARE @Timeoffset as int;
		set @Timeoffset = CAST(dbo.fnKartrisConfig_GetValue('general.timeoffset') as int);
		INSERT INTO dbo.tblKartrisDeletedItems VALUES(@ProductID, 'p', NULL, DateAdd(hour, @Timeoffset, GetDate()));
		
END

END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisCategories_Delete]    Script Date: 01/23/2013 21:59:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: 
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisCategories_Delete]
(
	@CAT_ID as int 
)
AS
BEGIN
	
	SET NOCOUNT ON;

	IF @CAT_ID = 0
	BEGIN
		RAISERROR('Can not delete this category.', 16, 0);
		GOTO Exit_sp;
	END

	SELECT * FROM tblKartrisCategories WHERE CAT_ID = @CAT_ID;

	DECLARE @NoOfChildCategories as int;
	SET @NoOfChildCategories = 0;
	SELECT @NoOfChildCategories = Count(1)
	FROM tblKartrisCategoryHierarchy
	WHERE CH_ParentID = @CAT_ID;
	

	IF @NoOfChildCategories = 0
	BEGIN
		
		-- delete category hierarchical data as a child
		DELETE FROM tblKartrisCategoryHierarchy
		WHERE  (CH_ChildID = @CAT_ID);
		
		-- delete related products
		EXEC [dbo].[_spKartrisProducts_DeleteByCategory] 
			@CategoryID = @CAT_ID;
			
		EXEC [dbo].[_spKartrisPromotions_DeleteByParent] 
			@ParentID = @CAT_ID, 
			@ParentType = 'c';

		-- delete the language elements of the category
		DELETE FROM tblKartrisLanguageElements
		WHERE     (LE_ParentID = @CAT_ID) AND (LE_TypeID = 3);

		-- delete the object config settings for this cat
		DELETE tblKartrisObjectConfigValue
		FROM tblKartrisObjectConfig INNER JOIN tblKartrisObjectConfigValue ON tblKartrisObjectConfig.OC_ID = tblKartrisObjectConfigValue.OCV_ObjectConfigID
		WHERE (tblKartrisObjectConfigValue.OCV_ParentID = @CAT_ID) AND (tblKartrisObjectConfig.OC_ObjectType = 'Category');
		
		-- delete the record from the category table
		DELETE FROM tblKartrisCategories
		WHERE     (CAT_ID = @CAT_ID);
		
		
		IF @CAT_ID <> 0 AND @CAT_ID NOT IN (SELECT DELETED_ID FROM dbo.tblKartrisDeletedItems WHERE Deleted_Type = 'c') BEGIN
			
				DECLARE @Timeoffset as int;
				set @Timeoffset = CAST(dbo.fnKartrisConfig_GetValue('general.timeoffset') as int);
				INSERT INTO dbo.tblKartrisDeletedItems VALUES(@CAT_ID, 'c', NULL, DateAdd(hour, @Timeoffset, GetDate()));
			
		END
	END
	ELSE
	BEGIN
		RAISERROR('Can not delete a category that has subcategories.', 16, 0);
	END
	
Exit_sp:
END
GO

/****** We changed frontend.display.showtax to include 'c' for just checkout. This
is basically what 'n' used to do, but now 'n' hides tax display everywhere. So we need to
update the description and options for this config setting for all installs, and then
reset value to 'c' if was previously 'n' so behaviour does not change for the user
due to upgrade  ******/

UPDATE tblKartrisConfig SET CFG_DisplayType='l',CFG_DisplayInfo='y|n|c', CFG_Description='n = don''t show tax, y = show tax, c = only show tax at checkout' WHERE CFG_Name='frontend.display.showtax';

UPDATE tblKartrisConfig SET CFG_Value='c' WHERE (CFG_Value='n' AND CFG_Name='frontend.display.showtax');

/****** Create table for new print shipping label feature ******/
CREATE TABLE dbo.tblKartrisLabelFormats(
							LBF_ID INT PRIMARY KEY IDENTITY,
							LBF_LabelName VARCHAR(20) NOT NULL UNIQUE,
							LBF_LabelDescription VARCHAR(1024) NOT NULL DEFAULT '',
							LBF_PageWidth FLOAT NOT NULL DEFAULT 210.0 CHECK (LBF_PageWidth > 0),
							LBF_PageHeight FLOAT NOT NULL DEFAULT 297.0 CHECK (LBF_PageHeight > 0),
							LBF_TopMargin FLOAT NOT NULL DEFAULT 0.0 CHECK (LBF_TopMargin >= 0.0),
							LBF_LeftMargin FLOAT NOT NULL DEFAULT 0.0 CHECK (LBF_LeftMargin >= 0.0),
							LBF_LabelWidth FLOAT NOT NULL CHECK (LBF_LabelWidth > 0.0),
							LBF_LabelHeight FLOAT NOT NULL CHECK (LBF_LabelHeight > 0.0),
							LBF_LabelPaddingTop FLOAT NOT NULL DEFAULT 0.0 CHECK (LBF_LabelPaddingTop >= 0.0),
							LBF_LabelPaddingBottom FLOAT NOT NULL DEFAULT 0.0 CHECK (LBF_LabelPaddingBottom >= 0.0),
							LBF_LabelPaddingLeft FLOAT NOT NULL DEFAULT 0.0 CHECK (LBF_LabelPaddingLeft >= 0.0),
							LBF_LabelPaddingRight FLOAT NOT NULL DEFAULT 0.0 CHECK (LBF_LabelPaddingRight >= 0.0),
							LBF_VerticalPitch FLOAT NOT NULL CHECK (LBF_VerticalPitch > 0.0),
							LBF_HorizontalPitch FLOAT NOT NULL CHECK (LBF_HorizontalPitch > 0.0),
							LBF_LabelColumnCount INT NOT NULL CHECK (LBF_LabelColumnCount > 0),
							LBF_LabelRowCount INT NOT NULL CHECK (LBF_LabelRowCount > 0)
							)
GO
-- Below is some sample data that has been proven to work well.
INSERT INTO dbo.tblKartrisLabelFormats(LBF_LabelName, LBF_LabelDescription, LBF_PageWidth,
				LBF_PageHeight, LBF_TopMargin, LBF_LeftMargin, LBF_LabelWidth, LBF_LabelHeight, LBF_LabelPaddingTop,
				LBF_LabelPaddingBottom, LBF_LabelPaddingLeft, LBF_LabelPaddingRight, LBF_VerticalPitch,
				LBF_HorizontalPitch, LBF_LabelColumnCount, LBF_LabelRowCount)
SELECT 'L7163','A4 Sheet of 99.1 x 38.1mm address labels', 210.0, 297.0, 15.1, 4.7, 99.1,
		38.1, 5.0, 0.0, 8.0, 0.0, 38.1, 101.6, 2, 7
UNION ALL
SELECT 'L7169','A4 Sheet of 99.1 x 139mm BlockOut (tm) address labels',210.0,297.0,9.5,4.6,
		99.1, 139.0, 5.0, 0.0, 8.0, 0.0, 139.0, 101.6, 2, 2

/****** set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.8000', CFG_VersionAdded=2.8 WHERE CFG_Name='general.kartrisinfo.versionadded';


