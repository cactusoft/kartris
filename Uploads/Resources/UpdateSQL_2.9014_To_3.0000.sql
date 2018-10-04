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

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='3.0000', CFG_VersionAdded=3.0000 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO
