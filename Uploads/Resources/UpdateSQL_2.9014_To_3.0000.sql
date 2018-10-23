/*
Kartris v3.0.0.0
Multi-site support
*/

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
ALTER PROCEDURE [dbo].[_spKartrisCategories_Treeview]
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


-- 2. Modify SPROC that inserts the customer record on front end with extra
-- parameter, so we can choose whether to create guest accounts or not

/****** Object:  StoredProcedure [dbo].[spKartrisUsers_Add]    Script Date: 23/10/2018 11:21:32 ******/
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
	SELECT @U_ID;
GO

-- 3. Modify the login and password reset/lookup sprocs so they don't
-- find guest checkout accounts. This way, guest accounts cannot be 
-- logged into, or the password recovered, so they essentially don't
-- exist for the purpose of front end usage, other than to make an order.

/****** Object:  StoredProcedure [dbo].[spKartrisUsers_Validate]    Script Date: 23/10/2018 11:26:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisUsers_Validate]
(
	@EmailAddress varchar(100),
	@Password varchar(64)
)
AS
SET NOCOUNT OFF;
SELECT        TOP 1 U_ID
FROM            tblKartrisUsers
WHERE        (U_EmailAddress = @EmailAddress AND U_Password = @Password AND U_GDPR_IsGuest = 0)

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

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='3.0000', CFG_VersionAdded=3.0000 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO
