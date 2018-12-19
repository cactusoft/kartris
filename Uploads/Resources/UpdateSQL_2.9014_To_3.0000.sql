/*
Kartris v3.0.0.0
Multi-site support
*/

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetNewestProducts]    Script Date: 25/10/2018 10:39:03 ******/
-- start with this fix, it ensures we return distinct
-- products on the newest products control. Old version
-- would duplicate products if you updated multiple
-- versions.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: 25/10/2018
-- Description:	Gets newest products
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
	
	SELECT DISTINCT products.P_ID, products.P_Name, dbo.fnKartrisProduct_GetMinPrice(products.P_ID) As MinPrice, products.P_DateCreated, @LANG_ID LANG_ID
	FROM (
		SELECT DISTINCT TOP (10) tblKartrisProducts.P_ID, tblKartrisLanguageElements.LE_Value AS P_Name, tblKartrisProducts.P_DateCreated, @LANG_ID LANG_ID
		FROM    tblKartrisProducts INNER JOIN
				  tblKartrisLanguageElements ON tblKartrisProducts.P_ID = tblKartrisLanguageElements.LE_ParentID
		WHERE   (tblKartrisProducts.P_Live=1) AND (tblKartrisProducts.P_CustomerGroupID IS NULL) AND
			   (tblKartrisLanguageElements.LE_LanguageID = @LANG_ID) AND (tblKartrisLanguageElements.LE_TypeID = 2) AND (tblKartrisLanguageElements.LE_FieldID = 1) AND 
			  (NOT (tblKartrisLanguageElements.LE_Value IS NULL))
		ORDER BY tblKartrisProducts.P_ID DESC
	) as products
	INNER JOIN tblKartrisVersions ON products.P_ID = tblKartrisVersions.V_ProductID INNER JOIN
			  tblKartrisProductCategoryLink ON products.P_ID = tblKartrisProductCategoryLink.PCAT_ProductID INNER JOIN
			  tblKartrisCategories ON tblKartrisProductCategoryLink.PCAT_CategoryID = tblKartrisCategories.CAT_ID
	WHERE (tblKartrisCategories.CAT_CustomerGroupID IS NULL) AND (tblKartrisVersions.V_CustomerGroupID IS NULL) 
	ORDER BY products.P_ID DESC
END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_UpdateCombinationVersion]    Script Date: 20/11/2018 12:23:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: 20/11/2018
-- Description:	Updates a combination version
-- Modified in Kartris v3 to force as type 'c',
-- so when saving a suspended combination, it 
-- automatically updates it to live again.
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_UpdateCombinationVersion]
(
	@ID as bigint,
	@Name as nvarchar(50), 
	@CodeNumber as nvarchar(50),
	@Price as real,
	@StockQty as real,
	@QtyWarnLevel as real,
	@Live as bit,
	@V_BulkUpdateTimeStamp as datetime = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE tblKartrisVersions
	SET V_CodeNumber = @CodeNumber, V_Price = @Price, V_Quantity = @StockQty, V_QuantityWarnLevel = @QtyWarnLevel, V_Live = @Live,
	V_BulkUpdateTimeStamp = Coalesce(@V_BulkUpdateTimeStamp, GetDate()),
	V_Type = 'c'
	WHERE V_ID = @ID;

	UPDATE tblKartrisLanguageElements
	SET LE_Value = @Name

	WHERE LE_TypeID = 1 AND LE_FieldID = 1 AND LE_ParentID = @ID;
END
GO

/****** Object:  Table [dbo].[tblKartrisSubSites]    Script Date: 28/09/2018 14:27:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblKartrisSubSites](
	[SUB_ID] [smallint] IDENTITY(1,1) NOT NULL,
	[SUB_Name] [nvarchar](255) NULL,
	[SUB_Domain] [nvarchar](255) NULL,
	[SUB_BaseCategoryID] [bigint] NULL,
	[SUB_Skin] [nvarchar](255) NULL,
	[SUB_Notes] [nvarchar](max) NULL,
	[SUB_Live] [bit] NULL,
 CONSTRAINT [PK_tblKartrisSubSites] PRIMARY KEY CLUSTERED 
(
	[SUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- Add new field to Categories, tells us if a category is a place holder for a sub site root. In
-- that case, we're not going to show it on the main site front end navigation menu
ALTER TABLE tblKartrisCategories
ADD CAT_SubSiteBaseRecord bit NULL DEFAULT(0); 
GO

-- Let's set all existing categories to 0, since existing data we're upgrading won't
-- have any subsite records
UPDATE tblKartrisCategories SET CAT_SubSiteBaseRecord = 0;
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisSubSite_GetByID]    Script Date: 01/10/2018 11:29:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	Gets a single sub site by ID
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSubSite_GetByID](@SUB_ID as smallint)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SubSites.*, CAT_Name
	FROM tblKartrisSubSites SubSites
	INNER JOIN vKartrisTypeCategories Cat ON Cat.CAT_ID = SUB_BaseCategoryID AND LANG_ID = 1
	WHERE     (SubSites.SUB_ID = @SUB_ID)	

END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisSubSites_Get]    Script Date: 01/10/2018 11:30:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Joni
-- Create date: <Create Date,,>
-- Description:	Gets subsites
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSubSites_Get]
AS
	SET NOCOUNT ON;
	
	SELECT  SubSites.*, CAT_Name
	FROM	dbo.tblKartrisSubSites SubSites
	INNER JOIN vKartrisTypeCategories Cat ON Cat.CAT_ID = SUB_BaseCategoryID AND LANG_ID = 1
	ORDER BY SUB_ID

GO

-- =============================================
-- Author:		Joni
-- Create date: <Create Date,,>
-- Description:	Add new subsite
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSubSite_Add]
(
			@SS_Name nvarchar(255),
			@SS_Domain nvarchar(255),
			@SS_BaseCategoryID bigint,
			@SS_Skin nvarchar(255),
			@SS_Notes nvarchar(max),
			@SS_Live bit
)
AS
DECLARE @SS_ID INT
	SET NOCOUNT OFF;

	
	INSERT INTO [tblKartrisSubSites]
		   (
			[SUB_Name],
			[SUB_Domain],
			[SUB_BaseCategoryID],
			[SUB_Skin],
			[SUB_Notes],
			[SUB_Live]
			)
	 VALUES
		   (@SS_Name, @SS_Domain, @SS_BaseCategoryID, @SS_Skin, @SS_Notes, @SS_Live);
	SET @SS_ID = SCOPE_IDENTITY();
	SELECT @SS_ID;

GO

-- =============================================
-- Author:		Joni
-- Create date: <Create Date,,>
-- Description:	Update existing subsite
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSubSite_Update]
(
			@SS_ID int,
			@SS_Name nvarchar(255),
			@SS_Domain nvarchar(255),
			@SS_BaseCategoryID bigint,
			@SS_Skin nvarchar(255),
			@SS_Notes nvarchar(max),
			@SS_Live bit
)
AS

	
	UPDATE [tblKartrisSubSites]
	SET SUB_Name = @SS_Name,
		SUB_Domain = @SS_Domain,
		SUB_BaseCategoryID = @SS_BaseCategoryID,
		SUB_Skin = @SS_Skin,
		SUB_Notes = @SS_Notes,
		SUB_Live = @SS_Live
	WHERE SUB_ID = @SS_ID;

GO

/****** Object:  StoredProcedure [dbo].[_spKartrisCategories_Treeview]    Script Date: 15/10/2018 10:47:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	Modified for Kartris v3, if top
-- level (0) then will try to append sub sites
-- as extra records.
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCategories_Treeview]
(
	@LANG_ID as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @OrderBy as nvarchar(50), @OrderDirection as char(1)

	SELECT @OrderBy = CAT_OrderCategoriesBy, @OrderDirection = CAT_CategoriesSortDirection
	FROM dbo.tblKartrisCategories
	WHERE CAT_ID = 0;

	IF @OrderBy is NULL OR @OrderBy = 'd'
	BEGIN 
		SELECT @OrderBy = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = 'frontend.categories.display.sortdefault';
	END;
	IF @OrderDirection is NULL OR @OrderDirection = '' BEGIN 
		SELECT @OrderDirection = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = 'frontend.categories.display.sortdirection';
	END;

	DECLARE @SortByValue as bit;
	SET @SortByValue = 0;
	IF @OrderBy = 'CH_OrderNo' BEGIN SET @SortByValue = 1 END;
	
	BEGIN
		 SET @SortByValue = 1;
		 SET @OrderBy = 'CH_OrderNo';
	END;
	
	WITH CategoryList AS
	(
		SELECT	CASE 
				WHEN (@OrderBy = 'CAT_ID' AND @OrderDirection = 'A') THEN	ROW_NUMBER() OVER (ORDER BY tblKartrisCategories.CAT_ID ASC) 
				WHEN (@OrderBy = 'CAT_ID' AND @OrderDirection = 'D') THEN	ROW_NUMBER() OVER (ORDER BY tblKartrisCategories.CAT_ID DESC) 
				WHEN (@OrderBy = 'CAT_Name' AND @OrderDirection = 'A') THEN ROW_NUMBER() OVER (ORDER BY CAT_Name ASC) 
				WHEN (@OrderBy = 'CAT_Name' AND @OrderDirection = 'D') THEN ROW_NUMBER() OVER (ORDER BY CAT_Name DESC) 
				WHEN (@OrderBy = 'CH_OrderNo' AND @OrderDirection = 'A') THEN ROW_NUMBER() OVER (ORDER BY CH_OrderNo ASC) 
				WHEN (@OrderBy = 'CH_OrderNo' AND @OrderDirection = 'D') THEN ROW_NUMBER() OVER (ORDER BY CH_OrderNo DESC) 
				END AS Row,
				vKartrisTypeCategories.CAT_ID,
				vKartrisTypeCategories.CAT_Name,
				vKartrisTypeCategories.CAT_Desc, 
				vKartrisTypeCategories.CAT_Live,
				0 As SUB_ID,
				'' As SUB_Name
		FROM    tblKartrisCategoryHierarchy INNER JOIN
				vKartrisTypeCategories ON tblKartrisCategoryHierarchy.CH_ChildID = vKartrisTypeCategories.CAT_ID INNER JOIN
				tblKartrisCategories ON tblKartrisCategoryHierarchy.CH_ParentID = tblKartrisCategories.CAT_ID
		WHERE   (tblKartrisCategoryHierarchy.CH_ParentID = 0) AND (vKartrisTypeCategories.LANG_ID = @LANG_ID)
		
	)

	SELECT *
	FROM CategoryList UNION ALL
	-- subsites below
	(
		SELECT	0 AS Row,
				vKartrisTypeCategories.CAT_ID, tblKartrisSubSites.SUB_Domain, vKartrisTypeCategories.CAT_Desc, 
				vKartrisTypeCategories.CAT_Live, SUB_ID, SUB_Name
		FROM    
				vKartrisTypeCategories 
				INNER JOIN tblKartrisSubSites ON tblKartrisSubSites.SUB_BaseCategoryID = vKartrisTypeCategories.CAT_ID
		WHERE   (vKartrisTypeCategories.LANG_ID = @LANG_ID) AND SUB_Live = 1
	)
	ORDER BY SUB_ID, Row ASC;

END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisCategoryHierarchy_GetByLanguageID]    Script Date: 20/10/2018 22:05:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================
-- Author:		Paul
-- Create date: 2018/10/20
-- Description:	generate the category menu hierarchy and
-- including subsites
-- ======================================================
ALTER PROCEDURE [dbo].[_spKartrisCategoryHierarchy_GetByLanguageID]
	(@LANG_ID tinyint)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	WITH CategoryList AS
	(
		SELECT
				tblKartrisCategoryHierarchy.CH_ChildID AS CAT_ID,
				tblKartrisCategoryHierarchy.CH_ParentID AS ParentID,
				vKartrisTypeCategories.CAT_Name AS Title, 
				vKartrisTypeCategories.CAT_Desc AS Description,
				0 As SUB_ID,
				tblKartrisCategoryHierarchy.CH_OrderNo AS CH_OrderNo
		FROM vKartrisTypeCategories INNER JOIN
						  tblKartrisCategoryHierarchy ON vKartrisTypeCategories.CAT_ID = tblKartrisCategoryHierarchy.CH_ChildID
		WHERE (vKartrisTypeCategories.LANG_ID = @LANG_ID)
	)

	SELECT *
	FROM CategoryList UNION ALL
	-- subsites below
	(
		SELECT
				tblKartrisCategoryHierarchy.CH_ChildID AS CAT_ID,
				tblKartrisCategoryHierarchy.CH_ParentID AS ParentID,
				SUB_Domain AS Title, 
				vKartrisTypeCategories.CAT_Desc AS Description,
				SUB_ID,
				tblKartrisCategoryHierarchy.CH_OrderNo AS CH_OrderNo
		FROM    
				vKartrisTypeCategories 
				INNER JOIN tblKartrisSubSites ON tblKartrisSubSites.SUB_BaseCategoryID = vKartrisTypeCategories.CAT_ID
				INNER JOIN
						  tblKartrisCategoryHierarchy ON vKartrisTypeCategories.CAT_ID = tblKartrisCategoryHierarchy.CH_ChildID
		WHERE   (vKartrisTypeCategories.LANG_ID = @LANG_ID) AND SUB_Live = 1
	)
	ORDER BY SUB_ID, CH_OrderNo;
END
GO

/****** GUEST CHECKOUT MODS ******/
-- In the past we've tended not to see the point of guest checkout, when
-- the justification was 'quicker'. We need all the same info to process
-- an order: email, name, street address, phone, etc., so the only time
-- saving would be in not choosing a password, and Kartris can be set
-- already to create a random password. But with GDPR, there is a good
-- argument for a guest checkout being a way to avoid having your personal
-- details remain on the web site for longer than just the time to process
-- an order. Therefore, we're going to add a way to let users choose a 
-- guest checkout option, this will technically still create an account, 
-- but in a way that can be deleted/anonymized once the order is processed.

-- 1. We need to add a boolean flag to customer records as to whether they
-- are GUEST or not
ALTER TABLE tblKartrisUsers
ADD U_GDPR_IsGuest bit NOT NULL
CONSTRAINT U_GDPR_IsGuest_0 DEFAULT 0
WITH VALUES

GO

-- 2. Modify SPROC that inserts the customer record on front end with extra
-- parameter, so we can choose whether to create guest accounts or not

/****** Object:  StoredProcedure [dbo].[spKartrisUsers_Add]    Script Date: 30/10/2018 10:55:36 ******/
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
		UPDATE tblKartrisUsers SET U_EmailAddress = U_EmailAddress + Convert(NVARCHAR(50), @U_ID)
		WHERE U_ID=@U_ID;
	END

	SELECT @U_ID;

GO

-- 3. Update back end customer update routine so it adds the guest detail
-- to end of email (which the form removes in back end when viewing
-- a customer), and customer list to include IsGuest field
/****** Object:  StoredProcedure [dbo].[_spKartrisUsers_Update]    Script Date: 30/10/2018 12:08:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
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

	-- If this is a guest checkout, the email will have
	-- been cleaned in the form. Therefore, we need to
	-- restore it to the GUEST format, otherwise we could
	-- break the unique requirement and have other problems.
	DECLARE @CheckIsGuest bit
	SELECT @CheckIsGuest = U_GDPR_IsGuest FROM  tblKartrisUsers WHERE U_ID=@U_ID

	-- Now let's adjust email, if necessary
	If @CheckIsGuest = 1
	BEGIN
		SET @U_EmailAddress = @U_EmailAddress + '|GUEST|' + Convert(NVARCHAR(50), @U_ID)
	END
	
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
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisUsers_ListBySearchTerm]    Script Date: 31/10/2018 11:58:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	Handles guest checkouts now
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisUsers_ListBySearchTerm]
(
	@SearchTerm nvarchar(100),
	@isAffiliate bit,
	@isMailingList bit,
	@CustomerGroupID int,
	@isAffiliateApproved bit,
	@PageIndex as tinyint, -- 0 Based index
	@PageSize smallint = 50
)
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @PageSize) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @PageSize - 1;
	DECLARE @CurrentDate as datetime;

DECLARE @intAffiliateCommision int

IF @isAffiliate = 0
	BEGIN
		SET @isAffiliate = NULL
		SET @isAffiliateApproved = 0
	END

IF @isAffiliateApproved = 0
	BEGIN		
		SET @intAffiliateCommision = NULL
	END	
ELSE
	BEGIN		
		SET @intAffiliateCommision = 0
	END	

IF @isMailingList = 0
	BEGIN
		SET @isMailingList = NULL 
	END

IF @CustomerGroupID = 0
	BEGIN
		SET @CustomerGroupID = NULL 
	END
ELSE
	BEGIN
		SET @SearchTerm = '?'
	END;

IF @SearchTerm IS NULL OR @SearchTerm = '?' OR @SearchTerm = ''
BEGIN

WITH UsersList AS
	(
SELECT      ROW_NUMBER() OVER (ORDER BY U_ID DESC) AS Row,tblKartrisUsers.U_ID, tblKartrisUsers.U_AccountHolderName, tblKartrisUsers.U_EmailAddress, tblKartrisAddresses.ADR_Name,U_IsAffiliate,U_AffiliateCommission, U_CustomerBalance, U_CustomerGroupID, U_LanguageID, U_GDPR_IsGuest
FROM         tblKartrisAddresses RIGHT OUTER JOIN
					  tblKartrisUsers ON tblKartrisAddresses.ADR_ID = tblKartrisUsers.U_DefBillingAddressID
WHERE     (U_IsAffiliate = COALESCE (@isAffiliate, U_IsAffiliate))
			AND (U_ML_SendMail = COALESCE (@isMailingList, U_ML_SendMail))
			AND (U_CustomerGroupiD = COALESCE (@CustomerGroupID, U_CustomerGroupiD))
			AND (U_AffiliateCommission = COALESCE (@intAffiliateCommision, U_AffiliateCommission))
			AND tblKartrisUsers.U_EmailAddress NOT LIKE 'GDPR Anonymized | %'
)
SELECT *
	FROM UsersList
	WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber;
	
END
ELSE
BEGIN
	WITH UsersList AS
	(
	SELECT      ROW_NUMBER() OVER (ORDER BY U_ID DESC) AS Row,tblKartrisUsers.U_ID, tblKartrisUsers.U_AccountHolderName, tblKartrisUsers.U_EmailAddress, tblKartrisAddresses.ADR_Name,U_IsAffiliate,U_AffiliateCommission, U_CustomerBalance, U_CustomerGroupID, U_LanguageID, U_GDPR_IsGuest
	FROM         tblKartrisAddresses RIGHT OUTER JOIN
						  tblKartrisUsers ON tblKartrisAddresses.ADR_ID = tblKartrisUsers.U_DefBillingAddressID
	WHERE     ((tblKartrisUsers.U_AccountHolderName LIKE '%' + @SearchTerm + '%') OR
						(tblKartrisAddresses.ADR_Name LIKE '%' + @SearchTerm + '%') OR 
						(tblKartrisAddresses.ADR_Company LIKE '%' + @SearchTerm + '%') OR
						(tblKartrisUsers.U_EmailAddress LIKE '%' + @SearchTerm + '%') OR
						(tblKartrisAddresses.ADR_StreetAddress LIKE '%' + @SearchTerm + '%') OR
						(tblKartrisAddresses.ADR_TownCity LIKE '%' + @SearchTerm + '%') OR
						(tblKartrisAddresses.ADR_County LIKE '%' + @SearchTerm + '%') OR
						(tblKartrisAddresses.ADR_PostCode LIKE '%' + @SearchTerm + '%'))
	)
	SELECT *
		FROM UsersList
		WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber;

END

END
GO


-- 4. Modify the lookup sprocs so they don't
-- find guest checkout accounts. This way, guest accounts cannot be 
-- logged into, or the password recovered, so they essentially don't
-- exist for the purpose of front end usage, other than to make an order.

/****** Object:  StoredProcedure [dbo].[spKartrisUsers_GetDetails]    Script Date: 23/10/2018 11:36:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisUsers_GetDetails]
(
	@EmailAddress nvarchar(100)
)
AS
SET NOCOUNT OFF;
SELECT        TOP 1 
				U_ID,
				U_AccountHolderName,
				U_CustomerDiscount,
				U_DefBillingAddressID,
				U_DefShippingAddressID,
				U_AffiliateID,
				U_Approved,
				U_IsAffiliate,
				U_AffiliateCommission,
				U_LanguageID,
				U_CustomerGroupID,
				U_TempPassword,
				U_TempPasswordExpiry,
				U_SupportEndDate,
				U_CustomerBalance
				
FROM            tblKartrisUsers
WHERE        (U_EmailAddress = @EmailAddress AND U_GDPR_IsGuest = 0)

GO

/****** new config settings ******/
INSERT INTO [tblKartrisConfig] (CFG_Name,CFG_Value,CFG_DataType,CFG_DisplayType,CFG_DisplayInfo,CFG_Description,CFG_VersionAdded,CFG_DefaultValue,CFG_Important)
VALUES (N'general.gdpr.guestcheckout.enabled', N'y', N's', N'b', 'y|n',N'Whether guest checkout is enabled',3.000, N'y', 0);

INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important])
VALUES (N'general.gdpr.purgeguestaccounts', N'30', N's', N'b', N'number of days', N'Number of days until guest accounts are purged', 3, N'30', 0)

GO

/*** New language strings  ***/
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES
(N'f', N'ContentText_GuestCheckout', N'Guest Checkout', NULL, 3.000, N'Guest Checkout', NULL, N'GDPR',1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES
(N'f', N'ContentText_GuestCheckoutDesc', N'Checkout without creating an account', NULL, 3.000, N'Checkout without creating an account', NULL, N'GDPR',1);
GO

-- back end
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES
(N'b', N'ContentText_GuestAccounts', N'Guest Accounts', NULL, 3.000, N'Guest Accounts', NULL, N'_GDPR',1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES
(N'b', N'ContentText_GuestAccountsDesc', N'The following guest accounts can now be anonymized', NULL, 3.000, N'The following guest accounts can now be anonymized', NULL, N'_GDPR',1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES
(N'b', N'ContentText_PurgeGuestAccountsTask', N'Purge Guest Accounts', NULL, 3.000, N'Purge Guest Accounts', NULL, N'_GDPR',1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES
(N'b', N'ContentText_GuestCheckout', N'Guest Checkout', NULL, 3.000, N'Guest Checkout', NULL, N'_GDPR',1);
GO

-- Anonymizing
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES
(N'b', N'BackMenu_AnonymizationList', N'Pending Anonymization', NULL, 3.000, N'Pending Anonymization', NULL, N'_GDPR',1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES
(N'b', N'FormButton_Anonymize', N'Anonymize', NULL, 3.000, N'Anonymize', NULL, N'_GDPR',1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES
(N'b', N'ContentText_AnonymizeTask', N'To Anonymize: ', NULL, 3.000, N'To Anonymize: ', NULL, N'_GDPR',1);
GO

-- 5. Code to anonymize guest accounts

/****** Anonymize by email address ******/
CREATE PROCEDURE [dbo].[_spKartrisUsers_AnonymizeByEmail]
(
		   @U_EmailAddress nvarchar(100)
)
AS
BEGIN
DECLARE @U_ID INT
	SET NOCOUNT OFF;

	DECLARE @days_purgeguestaccounts AS INT;
	SELECT @days_purgeguestaccounts = CFG_Value FROM tblKartrisConfig
	WHERE CFG_Name = 'general.gdpr.purgeguestaccounts'

	SELECT @U_ID = U_ID 
	FROM tblKartrisUsers
	FULL OUTER JOIN tblKartrisOrders 
		ON O_CustomerID = U_ID
	WHERE U_EmailAddress = @U_EmailAddress
	AND U_GDPR_IsGuest = 1
	AND DATEDIFF(day, O_LastModified,GETDATE()) > @days_purgeguestaccounts
		AND U_EmailAddress NOT LIKE 'GDPR Anonymized | %'
		AND (O_Shipped = 1 OR O_Cancelled = 1 OR O_Paid = 0)

	UPDATE tblKartrisAddresses 
	SET [ADR_Label] = 'GDPR Anonymized'
	  ,[ADR_Name] = 'GDPR Anonymized'
	  ,[ADR_Company] = 'GDPR Anonymized'
	  ,[ADR_StreetAddress] = 'GDPR Anonymized'
	  ,[ADR_TownCity] = 'GDPR Anonymized'
	  ,[ADR_County] = 'GDPR Anonymized'
	  ,[ADR_PostCode] = 'GDPR Anonymized'
	  ,[ADR_Country] = 0
	  ,[ADR_Telephone] = 'GDPR Anonymized'
	WHERE ADR_UserID = @U_ID

	UPDATE tblKartrisUsers
	SET 
		U_EmailAddress = 'GDPR Anonymized | ' + Convert(varchar(50),@U_ID)
		,U_Telephone = 'GDPR Anonymized'
		,U_AccountHolderName = 'GDPR Anonymized'
	WHERE U_ID = @U_ID
	AND U_GDPR_IsGuest = 1

	declare @xmlOrder xml, @xmlRest xml
	declare @lastBit nvarchar(10), @xmlDataStr nvarchar(max)
	SELECT @xmlOrder = SUBSTRING(O_Data , 1, CASE CHARINDEX('|||',  O_Data )
			WHEN 0
				THEN LEN( O_Data )
			ELSE CHARINDEX('|||',  O_Data ) - 1
			END)
			,@xmlRest = SUBSTRING(O_Data , CHARINDEX('|||',  O_Data ) + 3, LEN( O_Data ) - CHARINDEX('|||',  O_Data ) - 6)
			,@lastBit = RIGHT(O_Data,3)
	FROM tblKartrisOrders
	WHERE O_CustomerID = @U_ID

	IF @xmlOrder IS NOT NULL BEGIN
		SET @xmlOrder.modify('delete /objOrder/Billing//text()')
		SET @xmlOrder.modify('delete /objOrder/CustomerEmail//text()')

		SET @xmlDataStr = CAST(@xmlOrder as nvarchar(max)) + '|||' + CAST(@xmlRest as nvarchar(max)) + '|||' + @lastBit

		UPDATE tblKartrisOrders
		SET 
			O_BillingAddress = 'GDPR Anonymized'
			,O_ShippingAddress = 'GDPR Anonymized'
			,O_Data = @xmlDataStr
			,O_Details = 'GDPR Anonymized'
		WHERE O_CustomerID = @U_ID
	END 

END

GO

/****** Anonymize all ******/
CREATE PROCEDURE [dbo].[_spKartrisUsers_AnonymizeAll]
AS
BEGIN
	SET NOCOUNT OFF;

	DECLARE @days_purgeguestaccounts AS INT;
	SELECT @days_purgeguestaccounts = CFG_Value FROM tblKartrisConfig
	WHERE CFG_Name = 'general.gdpr.purgeguestaccounts'

	DECLARE cur_emails CURSOR FOR 
	SELECT U_EmailAddress 
	FROM tblKartrisUsers
	FULL OUTER JOIN tblKartrisOrders 
		ON O_CustomerID = U_ID
	WHERE U_GDPR_IsGuest = 1
	AND DATEDIFF(day, O_LastModified,GETDATE()) > @days_purgeguestaccounts
		AND U_EmailAddress NOT LIKE 'GDPR Anonymized | %'
		AND (O_Shipped = 1 OR O_Cancelled = 1 OR O_Paid = 0)

	DECLARE @u_email as nvarchar(100)
	OPEN cur_emails  
	FETCH NEXT FROM cur_emails INTO @u_email  

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		  EXEC _spKartrisUsers_AnonymizeByEmail @U_EmailAddress = @u_email

		  FETCH NEXT FROM cur_emails INTO @u_email 
	END 

	CLOSE cur_emails  
	DEALLOCATE cur_emails 

END

GO

/****** Get guests ******/
CREATE PROCEDURE [dbo].[_spKartrisUsers_GetGuests]
AS
SET NOCOUNT OFF;

DECLARE @days_purgeguestaccounts AS INT;
SELECT @days_purgeguestaccounts = CFG_Value FROM tblKartrisConfig
WHERE CFG_Name = 'general.gdpr.purgeguestaccounts'


SELECT *				
FROM tblKartrisUsers
FULL OUTER JOIN tblKartrisOrders 
ON O_CustomerID = U_ID
WHERE U_GDPR_IsGuest = 1
AND DATEDIFF(day, O_LastModified,GETDATE()) > @days_purgeguestaccounts
AND (O_Shipped = 1 OR O_Cancelled = 1 OR O_Paid = 0)
AND U_EmailAddress NOT LIKE 'GDPR Anonymized | %'

GO

/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetOptionsStockQuantity]    Script Date: 09/11/2018 17:01:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul/Mohammad
-- Create date: <Create Date,,>
-- Description:	Updated so returns base version
-- stock level if not combinatoins product
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisVersions_GetOptionsStockQuantity]
(
	@P_ID as int,
	@OptionList as nvarchar(1000),
	@Qty as real OUT
)
AS
BEGIN
	DECLARE @NoOfCombinations as int;
	SELECT	@NoOfCombinations = Count(V_ID)
	FROM    tblKartrisVersions 
	WHERE   (tblKartrisVersions.V_ProductID = @P_ID) 
			AND (tblKartrisVersions.V_Type = 'c') 
			AND (tblKartrisVersions.V_Live = 1);
	IF @NoOfCombinations = 0
	BEGIN
		-- Get stock quanity of the base version, should be only one
		SELECT @Qty = V_Quantity FROM tblKartrisVersions WHERE V_ProductID = @P_ID AND V_Type='b';
	END
	ELSE
	BEGIN
		-- need to sort the options' list to match the already sorted options
		--@OptionsList
		DECLARE @SortedOptions as nvarchar(max);
		SELECT @SortedOptions = COALESCE(@SortedOptions + ',', '') + CAST(T._ID as nvarchar(10))
		FROM (	SELECT DISTINCT Top(5000) _ID
				FROM dbo.fnTbl_SplitNumbers(@OptionList)
				ORDER BY _ID) AS T;

		SELECT @Qty = V_Quantity
		FROM dbo.vKartrisCombinationPrices
		WHERE V_ProductID = @P_ID AND V_OptionsIDs = @SortedOptions;
	END

END

GO


/****** Purge guest accounts mod ******/
ALTER VIEW [dbo].[vKartrisVersionsStock]
AS
SELECT        V_ID, V_Quantity, V_QuantityWarnLevel, V_Type, HasCombinations
FROM            (SELECT        dbo.tblKartrisVersions.V_ID, dbo.tblKartrisVersions.V_Quantity, dbo.tblKartrisVersions.V_QuantityWarnLevel, dbo.tblKartrisVersions.V_Type, CASE WHEN EXISTS
														(SELECT        TOP 1 1
														  FROM            tblKartrisVersions MyTableCheck
														  WHERE        MyTableCheck.V_ProductID = tblKartrisVersions.V_ProductID AND MyTableCheck.V_Type = 'c') THEN 1 ELSE 0 END AS HasCombinations
						  FROM            dbo.tblKartrisCategories INNER JOIN
													dbo.tblKartrisProductCategoryLink ON dbo.tblKartrisCategories.CAT_ID = dbo.tblKartrisProductCategoryLink.PCAT_CategoryID INNER JOIN
													dbo.tblKartrisProducts ON dbo.tblKartrisProductCategoryLink.PCAT_ProductID = dbo.tblKartrisProducts.P_ID INNER JOIN
													dbo.tblKartrisVersions ON dbo.tblKartrisProducts.P_ID = dbo.tblKartrisVersions.V_ProductID
						  WHERE        (dbo.tblKartrisCategories.CAT_Live = 1) AND (dbo.tblKartrisProducts.P_Live = 1) AND (dbo.tblKartrisVersions.V_Live = 1)) AS viewVersions
GROUP BY V_ID, V_Quantity, V_QuantityWarnLevel, V_Type, HasCombinations
GO

/****** Update task list ******/
ALTER PROCEDURE [dbo].[_spKartrisDB_GetTaskList]
(	
	@NoOrdersToInvoice as int OUTPUT,
	@NoOrdersNeedPayment as int OUTPUT,
	@NoOrdersToDispatch as int OUTPUT,
	@NoStockWarnings as int OUTPUT,
	@NoOutOfStock as int OUTPUT,
	--@NoEndOfLine as int OUTPUT,
	@NoReviewsWaiting as int OUTPUT,
	@NoAffiliatesWaiting as int OUTPUT,
	@NoCustomersWaitingRefunds as int OUTPUT,
	@NoCustomersInArrears as int OUTPUT,
	@NoCustomersToAnonymize as int OUTPUT
)
AS
BEGIN
	SELECT @NoOrdersToInvoice = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Invoiced = 'False' AND O_Paid = 'False' AND O_Sent = 'True' AND O_Cancelled = 'False';
	SELECT @NoOrdersNeedPayment = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Paid = 'False' AND O_Invoiced = 'True' AND O_Sent = 'True' AND O_Cancelled = 'False';
	SELECT @NoOrdersToDispatch = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Sent = 'True' AND O_Paid = 'True' AND O_Shipped = 'False' AND O_Cancelled = 'False';
	
	SELECT @NoStockWarnings = Count(V_ID) FROM dbo.vKartrisVersionsStock WHERE V_QuantityWarnLevel >= V_Quantity AND V_QuantityWarnLevel <> 0 AND NOT (HasCombinations = 1 AND V_Type = 'b') 
		AND [dbo].[fnKartrisObjectConfig_GetValueByParent]('K:version.endofline', V_ID) IS NULL;
	SELECT @NoOutOfStock = Count(V_ID) FROM dbo.vKartrisVersionsStock WHERE V_Quantity = 0 AND V_QuantityWarnLevel <> 0  AND NOT (HasCombinations = 1 AND V_Type = 'b') 
		AND [dbo].[fnKartrisObjectConfig_GetValueByParent]('K:version.endofline', V_ID) IS NULL;
	
	--SELECT @NoEndOfLine = Count(V_ID) 
	--FROM dbo.tblKartrisVersions INNER JOIN dbo.tblKartrisProducts ON V_ProductID = P_ID 
	--WHERE (V_Quantity = 0) AND (V_QuantityWarnLevel <> 0) AND P_Live = 1 AND V_Live = 1 
	--	AND [dbo].[fnKartrisObjectConfig_GetValueByParent]('K:version.endofline', V_ID) = 1;

	SELECT @NoReviewsWaiting = Count(REV_ID) FROM dbo.tblKartrisReviews WHERE REV_Live = 'a';
	SELECT @NoAffiliatesWaiting  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_IsAffiliate = 'True' AND U_AffiliateCommission = 0;
	SELECT @NoCustomersWaitingRefunds  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_CustomerBalance > 0;
	SELECT @NoCustomersInArrears  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_CustomerBalance < 0;
	
	DECLARE @days_purgeguestaccounts AS INT;
	SELECT @days_purgeguestaccounts = CFG_Value FROM tblKartrisConfig
	WHERE CFG_Name = 'general.gdpr.purgeguestaccounts'
	SELECT @NoCustomersToAnonymize  = Count(U_ID) FROM tblKartrisUsers 
		FULL OUTER JOIN tblKartrisOrders 
		ON O_CustomerID = U_ID
		WHERE U_GDPR_IsGuest = 1
		AND DATEDIFF(day, O_LastModified,GETDATE()) > @days_purgeguestaccounts
		AND U_EmailAddress NOT LIKE 'GDPR Anonymized | %'
		AND (O_Shipped = 1 OR O_Cancelled = 1 OR O_Paid = 0)

END

GO

/****** Fix to exclude combinations base versions from showing up to be added to basket in back end, in stock tracking, etc. ******/
ALTER VIEW [dbo].[vKartrisCategoryProductsVersionsLink]
AS
SELECT        P_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType, P_Type, T_Taxrate, CAT_ID, P_Live, CAT_Live, V_Live, V_ID, V_CodeNumber, V_Price, V_Tax, V_Weight, V_DeliveryTime, V_Quantity, 
						 V_QuantityWarnLevel, V_DownLoadInfo, V_DownloadType, V_RRP, V_OrderByValue, V_Type, V_CustomerGroupID, P_Featured, P_SupplierID, P_CustomerGroupID, P_Reviews, P_AverageRating, P_DateCreated, 
						 V_CustomizationType, V_CustomizationDesc, V_CustomizationCost, T_TaxRate2, CAT_CustomerGroupID, HasCombinations
FROM            (SELECT        dbo.tblKartrisProducts.P_ID, dbo.tblKartrisProducts.P_OrderVersionsBy, dbo.tblKartrisProducts.P_VersionsSortDirection, dbo.tblKartrisProducts.P_VersionDisplayType, dbo.tblKartrisProducts.P_Type, 
													tblKartrisTaxRates_1.T_Taxrate, dbo.tblKartrisProductCategoryLink.PCAT_CategoryID AS CAT_ID, dbo.tblKartrisProducts.P_Live, dbo.tblKartrisCategories.CAT_Live, dbo.tblKartrisVersions.V_Live, 
													dbo.tblKartrisVersions.V_ID, dbo.tblKartrisVersions.V_CodeNumber, dbo.tblKartrisVersions.V_Price, dbo.tblKartrisVersions.V_Tax, dbo.tblKartrisVersions.V_Weight, dbo.tblKartrisVersions.V_DeliveryTime, 
													dbo.tblKartrisVersions.V_Quantity, dbo.tblKartrisVersions.V_QuantityWarnLevel, dbo.tblKartrisVersions.V_DownLoadInfo, dbo.tblKartrisVersions.V_DownloadType, dbo.tblKartrisVersions.V_RRP, 
													dbo.tblKartrisVersions.V_OrderByValue, dbo.tblKartrisVersions.V_Type, dbo.tblKartrisVersions.V_CustomerGroupID, dbo.tblKartrisProducts.P_Featured, dbo.tblKartrisProducts.P_SupplierID, 
													dbo.tblKartrisProducts.P_CustomerGroupID, dbo.tblKartrisProducts.P_Reviews, dbo.tblKartrisProducts.P_AverageRating, dbo.tblKartrisProducts.P_DateCreated, dbo.tblKartrisVersions.V_CustomizationType, 
													dbo.tblKartrisVersions.V_CustomizationDesc, dbo.tblKartrisVersions.V_CustomizationCost, dbo.tblKartrisTaxRates.T_Taxrate AS T_TaxRate2, dbo.tblKartrisCategories.CAT_CustomerGroupID, 
													CASE WHEN EXISTS
														(SELECT        TOP 1 1
														  FROM            tblKartrisVersions MyTableCheck
														  WHERE        MyTableCheck.V_ProductID = tblKartrisVersions.V_ProductID AND MyTableCheck.V_Type = 'c') THEN 1 ELSE 0 END AS HasCombinations
						  FROM            dbo.tblKartrisCategories INNER JOIN
													dbo.tblKartrisProductCategoryLink ON dbo.tblKartrisCategories.CAT_ID = dbo.tblKartrisProductCategoryLink.PCAT_CategoryID INNER JOIN
													dbo.tblKartrisProducts ON dbo.tblKartrisProductCategoryLink.PCAT_ProductID = dbo.tblKartrisProducts.P_ID LEFT OUTER JOIN
													dbo.tblKartrisVersions LEFT OUTER JOIN
													dbo.tblKartrisTaxRates AS tblKartrisTaxRates_1 ON dbo.tblKartrisVersions.V_Tax = tblKartrisTaxRates_1.T_ID LEFT OUTER JOIN
													dbo.tblKartrisTaxRates ON dbo.tblKartrisVersions.V_Tax2 = dbo.tblKartrisTaxRates.T_ID ON dbo.tblKartrisProducts.P_ID = dbo.tblKartrisVersions.V_ProductID
						  WHERE        (dbo.tblKartrisCategories.CAT_Live = 1) AND (dbo.tblKartrisVersions.V_Live = 1) AND (dbo.tblKartrisProducts.P_Live = 1)) AS viewCategories
GROUP BY P_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType, P_Type, T_Taxrate, CAT_ID, P_Live, CAT_Live, V_Live, V_ID, V_CodeNumber, V_Price, V_Tax, V_Weight, V_DeliveryTime, V_Quantity, 
						 V_QuantityWarnLevel, V_DownLoadInfo, V_DownloadType, V_RRP, V_OrderByValue, V_Type, V_CustomerGroupID, P_Featured, P_SupplierID, P_CustomerGroupID, P_Reviews, P_AverageRating, P_DateCreated, 
						 V_CustomizationType, V_CustomizationDesc, V_CustomizationCost, T_TaxRate2, CAT_CustomerGroupID, HasCombinations
GO

/****** Fix to exclude combinations base versions showing in stock level ******/
ALTER PROCEDURE [dbo].[_spKartrisVersions_GetStockLevel]
(
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT DISTINCT V_ID, [dbo].[fnKartrisVersions_GetName](V_ID, @LANG_ID) As V_Name, V_CodeNumber, 
			V_Quantity, V_QuantityWarnLevel, P_SupplierID, P_ID
FROM           dbo.vKartrisCategoryProductsVersionsLink
WHERE       (V_Quantity <= V_QuantityWarnLevel) AND (V_QuantityWarnLevel <> 0) AND NOT (HasCombinations = 1 AND V_Type = 'b')  
ORDER BY V_Quantity , V_QuantityWarnLevel

GO

/****** New sproc to exclude combinations base version from search ******/
CREATE PROCEDURE [dbo].[_spKartrisVersions_SearchVersionsByCodeExcludeBase]
(
	@Key as nvarchar(50)
)
AS
	SET NOCOUNT ON;
SELECT * FROM ( SELECT V_ID, V_CodeNumber, V_Type, CASE WHEN EXISTS
																				  (SELECT        TOP 1 1
																					FROM            tblKartrisVersions MyTableCheck
																					WHERE        MyTableCheck.V_ProductID = tblKartrisVersions.V_ProductID AND MyTableCheck.V_Type = 'c') THEN 1 ELSE 0 END AS HasCombinations

FROM            dbo.tblKartrisVersions
WHERE        V_Type <> 's' AND V_CodeNumber LIKE '%' + @Key + '%'
) as viewVersions
WHERE NOT (HasCombinations = 1 AND V_Type = 'b')
GROUP BY  V_ID, V_CodeNumber, V_Type, HasCombinations


GO

/****** Object:  StoredProcedure [dbo].[_spKartrisCategories_Add]    Script Date: 18/12/2018 16:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: 
-- Description:	Update now specifies the field
-- names in the insert
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisCategories_Add]
(
	@CAT_Live as bit, 
	@CAT_ProductDisplayType as char(1),
	@CAT_SubCatDisplayType as char(1), 
	@CAT_OrderProductsBy as nvarchar(50),
	@CAT_ProductsSortDirection as char(1),
	@CAT_CustomerGroupID as smallint,
	@CAT_OrderCategoriesBy as nvarchar(50),
	@CAT_CategoriesSortDirection as char(1),
	@NewCAT_ID as int OUT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	INSERT INTO tblKartrisCategories ([CAT_Live], [CAT_ProductDisplayType], 
	[CAT_SubCatDisplayType],[CAT_OrderProductsBy],[CAT_ProductsSortDirection]
	,[CAT_CustomerGroupID],[CAT_OrderCategoriesBy],[CAT_CategoriesSortDirection])
	VALUES (@CAT_Live, @CAT_ProductDisplayType, @CAT_SubCatDisplayType,
			@CAT_OrderProductsBy, @CAT_ProductsSortDirection, @CAT_CustomerGroupID, 
			@CAT_OrderCategoriesBy, @CAT_CategoriesSortDirection);
	
	SELECT @NewCAT_ID = SCOPE_IDENTITY();
	
END
GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='3.0000', CFG_VersionAdded=3.0000 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO









