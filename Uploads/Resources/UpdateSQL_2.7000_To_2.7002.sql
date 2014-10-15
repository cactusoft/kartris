

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