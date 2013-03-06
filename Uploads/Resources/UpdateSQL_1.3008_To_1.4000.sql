-- ################  Structural Changes Started   ################
-- ***********************************************
-- ****** Title: Table 'Media Types' - New Field 'MT_Inline'
-- ***********************************************
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tblKartrisMediaTypes ADD
	MT_Inline bit NULL
GO
ALTER TABLE dbo.tblKartrisMediaTypes SET (LOCK_ESCALATION = TABLE)
GO
COMMIT;

-- ***********************************************
-- ****** Title: Table 'Versions' - New Fields:'V_Tax2', 'V_TaxExtra' - DataType Change: 'V_Quantity', 'V_QuantityWarnLevel'
-- ***********************************************

BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tblKartrisVersions
	DROP CONSTRAINT FK_tblKartrisVersions_tblKartrisTaxRates
GO
ALTER TABLE dbo.tblKartrisTaxRates SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tblKartrisVersions
	DROP CONSTRAINT FK_tblKartrisVersions_tblKartrisProducts
GO
ALTER TABLE dbo.tblKartrisProducts SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tblKartrisVersions
	DROP CONSTRAINT DF__tblKartris__V_Pro__1CF15040
GO
ALTER TABLE dbo.tblKartrisVersions
	DROP CONSTRAINT DF__tblKartris__V_Pri__1DE57479
GO
ALTER TABLE dbo.tblKartrisVersions
	DROP CONSTRAINT DF__tblKartris__V_Tax__1ED998B2
GO
ALTER TABLE dbo.tblKartrisVersions
	DROP CONSTRAINT DF__tblKartris__V_Wei__1FCDBCEB
GO
ALTER TABLE dbo.tblKartrisVersions
	DROP CONSTRAINT DF__tblKartris__V_Del__20C1E124
GO
ALTER TABLE dbo.tblKartrisVersions
	DROP CONSTRAINT DF__tblKartris__V_Qua__21B6055D
GO
ALTER TABLE dbo.tblKartrisVersions
	DROP CONSTRAINT DF__tblKartris__V_Qua__22AA2996
GO
ALTER TABLE dbo.tblKartrisVersions
	DROP CONSTRAINT DF_tblKartrisVersions_V_Live
GO
ALTER TABLE dbo.tblKartrisVersions
	DROP CONSTRAINT DF__tblKartris__V_Ord__239E4DCF
GO
ALTER TABLE dbo.tblKartrisVersions
	DROP CONSTRAINT DF__tblKartris__V_RRP__24927208
GO
ALTER TABLE dbo.tblKartrisVersions
	DROP CONSTRAINT DF__tblKartris__V_Cus__25869641
GO
CREATE TABLE dbo.Tmp_tblKartrisVersions
	(
	V_ID bigint NOT NULL IDENTITY (1, 1),
	V_CodeNumber nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	V_ProductID int NULL,
	V_Price real NULL,
	V_Tax tinyint NULL,
	V_Weight real NOT NULL,
	V_DeliveryTime tinyint NOT NULL,
	V_Quantity real NOT NULL,
	V_QuantityWarnLevel real NOT NULL,
	V_Live bit NOT NULL,
	V_DownLoadInfo nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	V_DownloadType nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	V_OrderByValue smallint NOT NULL,
	V_RRP real NOT NULL,
	V_Type char(1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	V_CustomerGroupID smallint NULL,
	V_CustomizationType char(1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	V_CustomizationDesc nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	V_CustomizationCost real NOT NULL,
	V_Tax2 tinyint NULL,
	V_TaxExtra nvarchar(25) NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_tblKartrisVersions SET (LOCK_ESCALATION = TABLE)
GO
DECLARE @v sql_variant 
SET @v = N'n:NONE, i:Image, t:Text'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_tblKartrisVersions', N'COLUMN', N'V_CustomizationType'
GO
ALTER TABLE dbo.Tmp_tblKartrisVersions ADD CONSTRAINT
	DF__tblKartris__V_Pro__1CF15040 DEFAULT ((0)) FOR V_ProductID
GO
ALTER TABLE dbo.Tmp_tblKartrisVersions ADD CONSTRAINT
	DF__tblKartris__V_Pri__1DE57479 DEFAULT ((0)) FOR V_Price
GO
ALTER TABLE dbo.Tmp_tblKartrisVersions ADD CONSTRAINT
	DF__tblKartris__V_Tax__1ED998B2 DEFAULT ((0)) FOR V_Tax
GO
ALTER TABLE dbo.Tmp_tblKartrisVersions ADD CONSTRAINT
	DF__tblKartris__V_Wei__1FCDBCEB DEFAULT ((0)) FOR V_Weight
GO
ALTER TABLE dbo.Tmp_tblKartrisVersions ADD CONSTRAINT
	DF__tblKartris__V_Del__20C1E124 DEFAULT ((0)) FOR V_DeliveryTime
GO
ALTER TABLE dbo.Tmp_tblKartrisVersions ADD CONSTRAINT
	DF__tblKartris__V_Qua__21B6055D DEFAULT ((0)) FOR V_Quantity
GO
ALTER TABLE dbo.Tmp_tblKartrisVersions ADD CONSTRAINT
	DF__tblKartris__V_Qua__22AA2996 DEFAULT ((0)) FOR V_QuantityWarnLevel
GO
ALTER TABLE dbo.Tmp_tblKartrisVersions ADD CONSTRAINT
	DF_tblKartrisVersions_V_Live DEFAULT ((0)) FOR V_Live
GO
ALTER TABLE dbo.Tmp_tblKartrisVersions ADD CONSTRAINT
	DF__tblKartris__V_Ord__239E4DCF DEFAULT ((0)) FOR V_OrderByValue
GO
ALTER TABLE dbo.Tmp_tblKartrisVersions ADD CONSTRAINT
	DF__tblKartris__V_RRP__24927208 DEFAULT ((0)) FOR V_RRP
GO
ALTER TABLE dbo.Tmp_tblKartrisVersions ADD CONSTRAINT
	DF__tblKartris__V_Cus__25869641 DEFAULT ((0)) FOR V_CustomerGroupID
GO
SET IDENTITY_INSERT dbo.Tmp_tblKartrisVersions ON
GO
IF EXISTS(SELECT * FROM dbo.tblKartrisVersions)
	 EXEC('INSERT INTO dbo.Tmp_tblKartrisVersions (V_ID, V_CodeNumber, V_ProductID, V_Price, V_Tax, V_Weight, V_DeliveryTime, V_Quantity, V_QuantityWarnLevel, V_Live, V_DownLoadInfo, V_DownloadType, V_OrderByValue, V_RRP, V_Type, V_CustomerGroupID, V_CustomizationType, V_CustomizationDesc, V_CustomizationCost)
		SELECT V_ID, V_CodeNumber, V_ProductID, V_Price, V_Tax, V_Weight, V_DeliveryTime, CONVERT(real, V_Quantity), CONVERT(real, V_QuantityWarnLevel), V_Live, V_DownLoadInfo, V_DownloadType, V_OrderByValue, V_RRP, V_Type, V_CustomerGroupID, V_CustomizationType, V_CustomizationDesc, V_CustomizationCost FROM dbo.tblKartrisVersions WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_tblKartrisVersions OFF
GO
ALTER TABLE dbo.tblKartrisCustomerGroupPrices
	DROP CONSTRAINT FK_tblKartrisCustomerGroupPrices_tblKartrisVersions
GO
ALTER TABLE dbo.tblKartrisVersionOptionLink
	DROP CONSTRAINT FK_tblKartrisVersionOptionLink_tblKartrisVersions
GO
DROP TABLE dbo.tblKartrisVersions
GO
EXECUTE sp_rename N'dbo.Tmp_tblKartrisVersions', N'tblKartrisVersions', 'OBJECT' 
GO
ALTER TABLE dbo.tblKartrisVersions ADD CONSTRAINT
	Versions_PK PRIMARY KEY NONCLUSTERED 
	(
	V_ID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
CREATE UNIQUE CLUSTERED INDEX idxV_CodeNumber_ID ON dbo.tblKartrisVersions
	(
	V_CodeNumber,
	V_ID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX V_ID ON dbo.tblKartrisVersions
	(
	V_ID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX V_ProductID ON dbo.tblKartrisVersions
	(
	V_ProductID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE dbo.tblKartrisVersions ADD CONSTRAINT
	CK_Versions_RRP CHECK (([V_RRP]>=(0)))
GO
DECLARE @v sql_variant 
SET @v = N'V_RRP should be positive value'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'tblKartrisVersions', N'CONSTRAINT', N'CK_Versions_RRP'
GO
ALTER TABLE dbo.tblKartrisVersions ADD CONSTRAINT
	CK_Versions_Tax CHECK (([V_Tax]>(0)))
GO
DECLARE @v sql_variant 
SET @v = N'V_Tax should be larger than zero'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'tblKartrisVersions', N'CONSTRAINT', N'CK_Versions_Tax'
GO
ALTER TABLE dbo.tblKartrisVersions ADD CONSTRAINT
	CK_Versions_Type CHECK (([V_Type]='v' OR [V_Type]='o' OR [V_Type]='b' OR [V_Type]='c' OR [V_Type]='s'))
GO
ALTER TABLE dbo.tblKartrisVersions ADD CONSTRAINT
	CK_Versions_Weight CHECK (([V_Weight]>=(0)))
GO
DECLARE @v sql_variant 
SET @v = N'V_Weight should be larger than zero'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'tblKartrisVersions', N'CONSTRAINT', N'CK_Versions_Weight'
GO
ALTER TABLE dbo.tblKartrisVersions ADD CONSTRAINT
	FK_tblKartrisVersions_tblKartrisProducts FOREIGN KEY
	(
	V_ProductID
	) REFERENCES dbo.tblKartrisProducts
	(
	P_ID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.tblKartrisVersions ADD CONSTRAINT
	FK_tblKartrisVersions_tblKartrisTaxRates FOREIGN KEY
	(
	V_Tax
	) REFERENCES dbo.tblKartrisTaxRates
	(
	T_ID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[trigKartrisVersions_OrderValue]
   ON  dbo.tblKartrisVersions
   AFTER INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @V_ID as bigint, @V_ProductID as int, @V_OrderByValue as smallint, @V_Type as char(1);
	SELECT @V_ID = V_ID, @V_ProductID = V_ProductID, @V_OrderByValue = V_OrderByValue, @V_Type = V_Type
	FROM INSERTED;
	
	IF (@V_OrderByValue is NULL OR @V_OrderByValue = 0)
	BEGIN
		IF @V_Type <> 'c'
		BEGIN 
			DECLARE @MaxOrder as int;
			SELECT @MaxOrder = Max(V_OrderByValue) FROM dbo.tblKartrisVersions WHERE V_ProductID = @V_ProductID;
			IF @MaxOrder is NULL BEGIN SET @MaxOrder = 0 END;
			UPDATE dbo.tblKartrisVersions
			SET V_OrderByValue = @MaxOrder + 1
			WHERE V_ID = @V_ID;
		END
		ELSE
		BEGIN
			UPDATE dbo.tblKartrisVersions
			SET V_OrderByValue = 20
			WHERE V_ID = @V_ID;
		END
	END
END
GO
CREATE	TRIGGER [dbo].[trigKartrisVersions_DML] ON dbo.tblKartrisVersions  FOR INSERT, UPDATE, DELETE AS BEGIN Rollback Transaction Print '*****************************************************' Print '*****************************************************' Print '***** ERROR:Operation Not Allowed by User ******'Print '*****************************************************' Print '*****************************************************'  END
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tblKartrisVersionOptionLink ADD CONSTRAINT
	FK_tblKartrisVersionOptionLink_tblKartrisVersions FOREIGN KEY
	(
	V_OPT_VersionID
	) REFERENCES dbo.tblKartrisVersions
	(
	V_ID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.tblKartrisVersionOptionLink SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tblKartrisCustomerGroupPrices ADD CONSTRAINT
	FK_tblKartrisCustomerGroupPrices_tblKartrisVersions FOREIGN KEY
	(
	CGP_VersionID
	) REFERENCES dbo.tblKartrisVersions
	(
	V_ID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.tblKartrisCustomerGroupPrices SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


-- ***********************************************
-- ****** Title: Table 'Destinations' - New Fields 'D_Tax2', 'D_TaxExtra'
-- ***********************************************


BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tblKartrisDestination ADD
	D_Tax2 real NULL,
	D_TaxExtra nvarchar(25) NULL
GO
ALTER TABLE dbo.tblKartrisDestination SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


-- ***********************************************
-- ****** Title: Table 'Shipping Methods' - New Field 'SM_Tax2'
-- ***********************************************


BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tblKartrisShippingMethods ADD
	SM_Tax2 tinyint NULL
GO
ALTER TABLE dbo.tblKartrisShippingMethods SET (LOCK_ESCALATION = TABLE)
GO
COMMIT

-- ***********************************************
-- ****** Title: Table 'Orders' - New Field 'O_Comments'
-- ***********************************************

BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tblKartrisOrders ADD
	O_Comments nvarchar(MAX) NULL
GO
ALTER TABLE dbo.tblKartrisOrders SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
-- ***********************************************
-- ****** Title: Table 'Quantity Discounts' - DataType Change 'QD_Quantity'
-- ***********************************************
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tblKartrisQuantityDiscounts
	DROP CONSTRAINT DF__tblKartris__QD_Ve__1EA48E88
GO
ALTER TABLE dbo.tblKartrisQuantityDiscounts
	DROP CONSTRAINT DF__tblKartris__QD_Qu__1F98B2C1
GO
ALTER TABLE dbo.tblKartrisQuantityDiscounts
	DROP CONSTRAINT DF__tblKartris__QD_Pr__208CD6FA
GO
CREATE TABLE dbo.Tmp_tblKartrisQuantityDiscounts
	(
	QD_VersionID bigint NOT NULL,
	QD_Quantity real NOT NULL,
	QD_Price real NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_tblKartrisQuantityDiscounts SET (LOCK_ESCALATION = TABLE)
GO
ALTER TABLE dbo.Tmp_tblKartrisQuantityDiscounts ADD CONSTRAINT
	DF__tblKartris__QD_Ve__1EA48E88 DEFAULT ((0)) FOR QD_VersionID
GO
ALTER TABLE dbo.Tmp_tblKartrisQuantityDiscounts ADD CONSTRAINT
	DF__tblKartris__QD_Qu__1F98B2C1 DEFAULT ((0)) FOR QD_Quantity
GO
ALTER TABLE dbo.Tmp_tblKartrisQuantityDiscounts ADD CONSTRAINT
	DF__tblKartris__QD_Pr__208CD6FA DEFAULT ((0)) FOR QD_Price
GO
IF EXISTS(SELECT * FROM dbo.tblKartrisQuantityDiscounts)
	 EXEC('INSERT INTO dbo.Tmp_tblKartrisQuantityDiscounts (QD_VersionID, QD_Quantity, QD_Price)
		SELECT QD_VersionID, CONVERT(real, QD_Quantity), QD_Price FROM dbo.tblKartrisQuantityDiscounts WITH (HOLDLOCK TABLOCKX)')
GO
DROP TABLE dbo.tblKartrisQuantityDiscounts
GO
EXECUTE sp_rename N'dbo.Tmp_tblKartrisQuantityDiscounts', N'tblKartrisQuantityDiscounts', 'OBJECT' 
GO
ALTER TABLE dbo.tblKartrisQuantityDiscounts ADD CONSTRAINT
	PK_tblKartrisQuantityDiscounts PRIMARY KEY CLUSTERED 
	(
	QD_VersionID,
	QD_Quantity
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX QD_VersionID ON dbo.tblKartrisQuantityDiscounts
	(
	QD_VersionID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE	TRIGGER [dbo].[trigKartrisQuantityDiscounts_DML] ON dbo.tblKartrisQuantityDiscounts  FOR INSERT, UPDATE, DELETE AS BEGIN Rollback Transaction Print '*****************************************************' Print '*****************************************************' Print '***** ERROR:Operation Not Allowed by User ******'Print '*****************************************************' Print '*****************************************************'  END
GO
COMMIT
-- ***********************************************
-- ****** Title: Object Config Installation
-- ***********************************************
/****** Object:  Table [dbo].[tblKartrisObjectConfig]    Script Date: 09/04/2011 17:55:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tblKartrisObjectConfig](
	[OC_ID] [smallint] IDENTITY(1,1) NOT NULL,
	[OC_Name] [nvarchar](100) NOT NULL,
	[OC_ObjectType] [nvarchar](50) NULL,
	[OC_DataType] [char](1) NULL,
	[OC_DefaultValue] [nvarchar](max) NULL,
	[OC_Description] [nvarchar](255) NULL,
	[OC_MultilineValue] [bit] NULL,
	[OC_VersionAdded] [real] NULL,
 CONSTRAINT [PK_tblKartrisObjectConfig] PRIMARY KEY CLUSTERED 
(
	[OC_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_tblKartrisObjectConfig] UNIQUE NONCLUSTERED 
(
	[OC_Name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[tblKartrisObjectConfigValue]    Script Date: 09/04/2011 17:55:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblKartrisObjectConfigValue](
	[OCV_ObjectConfigID] [smallint] NOT NULL,
	[OCV_ParentID] [bigint] NOT NULL,
	[OCV_Value] [nvarchar](max) NULL,
 CONSTRAINT [PK_tblKartrisObjectConfigValue] PRIMARY KEY CLUSTERED 
(
	[OCV_ObjectConfigID] ASC,
	[OCV_ParentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Trigger [dbo].[trigKartrisObjectConfig_DML]    Script Date: 09/04/2011 17:57:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE	TRIGGER [dbo].[trigKartrisObjectConfig_DML] ON [dbo].[tblKartrisObjectConfig]  
FOR INSERT, UPDATE, DELETE AS BEGIN Rollback Transaction 
Print '*****************************************************' 
Print '*****************************************************' 
Print '***** ERROR:Operation Not Allowed by User ******'
Print '*****************************************************' 
Print '*****************************************************'  
END

GO

/****** Object:  Trigger [dbo].[trigKartrisObjectConfigValue_DML]    Script Date: 09/04/2011 17:58:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE	TRIGGER [dbo].[trigKartrisObjectConfigValue_DML] ON [dbo].[tblKartrisObjectConfigValue]  
FOR INSERT, UPDATE, DELETE AS BEGIN Rollback Transaction 
Print '*****************************************************' 
Print '*****************************************************' 
Print '***** ERROR:Operation Not Allowed by User ******'
Print '*****************************************************' 
Print '*****************************************************'  
END

GO
-- ***********************************************
-- ****** Title: Table: Promotion Strings - New Field 'PS_LanguageStringName'
-- ***********************************************
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_tblKartrisPromotionStrings
	(
	PS_ID tinyint NOT NULL,
	PS_LanguageStringName nvarchar(255) NULL,
	PS_PartNo char(1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	PS_Type char(1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	PS_Item char(1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	PS_Order tinyint NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_tblKartrisPromotionStrings SET (LOCK_ESCALATION = TABLE)
GO
IF EXISTS(SELECT * FROM dbo.tblKartrisPromotionStrings)
	 EXEC('INSERT INTO dbo.Tmp_tblKartrisPromotionStrings (PS_ID, PS_PartNo, PS_Type, PS_Item, PS_Order)
		SELECT PS_ID, PS_PartNo, PS_Type, PS_Item, PS_Order FROM dbo.tblKartrisPromotionStrings WITH (HOLDLOCK TABLOCKX)')
GO
DROP TABLE dbo.tblKartrisPromotionStrings
GO
EXECUTE sp_rename N'dbo.Tmp_tblKartrisPromotionStrings', N'tblKartrisPromotionStrings', 'OBJECT' 
GO
ALTER TABLE dbo.tblKartrisPromotionStrings ADD CONSTRAINT
	PK_tblKartrisPromotionStrings PRIMARY KEY CLUSTERED 
	(
	PS_ID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
CREATE	TRIGGER [dbo].[trigKartrisPromotionStrings_DML] ON dbo.tblKartrisPromotionStrings  FOR INSERT, UPDATE, DELETE AS BEGIN Rollback Transaction Print '*****************************************************' Print '*****************************************************' Print '***** ERROR:Operation Not Allowed by User ******'Print '*****************************************************' Print '*****************************************************'  END
GO
COMMIT

GO

-- ***********************************************
-- ****** Title: Table: Admin Related Tables - New Field 'ART_TableOrderContents'
-- ***********************************************

BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_tblKartrisAdminRelatedTables
	(
	ART_TableName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	ART_TableOrderProducts tinyint NULL,
	ART_TableOrderOrders tinyint NULL,
	ART_TableOrderSessions tinyint NULL,
	ART_TableOrderContents tinyint NULL,
	ART_TableStartingIdentity int NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_tblKartrisAdminRelatedTables SET (LOCK_ESCALATION = TABLE)
GO
IF EXISTS(SELECT * FROM dbo.tblKartrisAdminRelatedTables)
	 EXEC('INSERT INTO dbo.Tmp_tblKartrisAdminRelatedTables (ART_TableName, ART_TableOrderProducts, ART_TableOrderOrders, ART_TableOrderSessions, ART_TableStartingIdentity)
		SELECT ART_TableName, ART_TableOrderProducts, ART_TableOrderOrders, ART_TableOrderSessions, ART_TableStartingIdentity FROM dbo.tblKartrisAdminRelatedTables WITH (HOLDLOCK TABLOCKX)')
GO
DROP TABLE dbo.tblKartrisAdminRelatedTables
GO
EXECUTE sp_rename N'dbo.Tmp_tblKartrisAdminRelatedTables', N'tblKartrisAdminRelatedTables', 'OBJECT' 
GO
ALTER TABLE dbo.tblKartrisAdminRelatedTables ADD CONSTRAINT
	PK_tblKartrisAdminOrdersRelatedTables PRIMARY KEY CLUSTERED 
	(
	ART_TableName
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
CREATE	TRIGGER [dbo].[trigKartrisAdminRelatedTables_DML] ON dbo.tblKartrisAdminRelatedTables  FOR INSERT, UPDATE, DELETE AS BEGIN Rollback Transaction Print '*****************************************************' Print '*****************************************************' Print '***** ERROR:Operation Not Allowed by User ******'Print '*****************************************************' Print '*****************************************************'  END
GO
COMMIT

GO
-- ################  Structural Changes Ended   ################

-- ################  Stored Procedures/Functions/Views Reset Started   ################

DECLARE @ObjectName varchar(500), @ObjectType as varchar(2)
DECLARE curDrop CURSOR 
FOR SELECT [name],[type] FROM sys.objects WHERE [type] IN ('P','TF','FN','V') order by [name]
OPEN curDrop

FETCH NEXT FROM curDrop INTO @ObjectName, @ObjectType
WHILE @@fetch_status = 0
BEGIN
	IF @ObjectType = 'P' BEGIN
		-- Excludes FTS search sproces from being deleted
		IF @ObjectName NOT IN ('_spKartrisDB_AdminSearchFTS','spKartrisDB_SearchFTS') BEGIN
			EXEC('DROP PROCEDURE ' + @ObjectName);
		END
	END
	IF @ObjectType = 'TF' or @ObjectType = 'FN' BEGIN
			EXEC('DROP FUNCTION ' + @ObjectName);
	END
	IF @ObjectType = 'V' BEGIN
		EXEC('DROP VIEW ' + @ObjectName);
	END
	FETCH NEXT FROM curDrop INTO @ObjectName, @ObjectType
END
CLOSE curDrop
DEALLOCATE curDrop
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisDB_ExportOrders]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_ExportOrders]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDB_ExportOrders]
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
	
	SET @Cmd = ''SELECT     tblKartrisOrders.O_ID, tblKartrisOrders.O_CustomerID, tblKartrisUsers.U_EmailAddress, tblKartrisUsers.U_AccountHolderName, tblKartrisOrders.O_ShippingPrice, 
						   tblKartrisOrders.O_ShippingTax, ''
	
	IF @IncludeDetails = 1	BEGIN SET @Cmd = @Cmd + ''tblKartrisOrders.O_Details, '' END

	SET @Cmd = @Cmd + ''tblKartrisOrders.O_DiscountPercentage, tblKartrisOrders.O_AffiliatePercentage, tblKartrisOrders.O_TotalPrice, 
						  tblKartrisOrders.O_Date, tblKartrisOrders.O_PurchaseOrderNo, tblKartrisOrders.O_SecurityID, tblKartrisOrders.O_Sent, tblKartrisOrders.O_Invoiced, 
						  tblKartrisOrders.O_Shipped, tblKartrisOrders.O_Paid,tblKartrisOrders.O_Status, tblKartrisOrders.O_LastModified, tblKartrisOrders.O_WishListID, 
						  tblKartrisOrders.O_CouponCode, tblKartrisOrders.O_CouponDiscountTotal, tblKartrisOrders.O_PricesIncTax, tblKartrisOrders.O_TaxDue, 
						  tblKartrisOrders.O_PaymentGateWay, tblKartrisOrders.O_ReferenceCode, tblKartrisLanguages.LANG_BackName, tblKartrisCurrencies.CUR_Symbol, 
						  tblKartrisOrders.O_TotalPriceGateway, tblKartrisOrders.O_AffiliatePaymentID, tblKartrisOrders.O_AffiliateTotalPrice, tblKartrisOrders.O_SendOrderUpdateEmail
	FROM         tblKartrisOrders INNER JOIN
						  tblKartrisUsers ON tblKartrisOrders.O_CustomerID = tblKartrisUsers.U_ID INNER JOIN
						  tblKartrisLanguages ON tblKartrisOrders.O_LanguageID = tblKartrisLanguages.LANG_ID INNER JOIN
						  tblKartrisCurrencies ON tblKartrisOrders.O_CurrencyID = tblKartrisCurrencies.CUR_ID
	WHERE 1 = 1 ''
	
	IF (@StartDate IS NOT NULL) AND (@EndDate IS NOT NULL)
	BEGIN
		SET @Cmd = @Cmd + '' AND O_Date BETWEEN CAST('''''' + @StartDate + '''''' as DateTime) AND CAST(''''''  + @EndDate + '''''' as DateTime)''
	END
	IF @IncludeIncomplete = 0
	BEGIN
		SET @Cmd = @Cmd + '' AND O_Paid = 1 ''
	END

	SET @Cmd = @Cmd + '' ORDER BY O_Date''
	
	EXECUTE(@Cmd);
	
	
END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_ExecuteQuery]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_ExecuteQuery]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDB_ExecuteQuery]
(	
	@QueryText as nvarchar(MAX)
)
AS
BEGIN
	Execute(@QueryText);
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_EnableTrigger]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_EnableTrigger]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDB_EnableTrigger]
(
	@TriggerName as sysname, 
	@TableName as sysname,
	@Status as smallint out
)
AS
BEGIN
	
	DECLARE @SQL as nvarchar(250);
	SET @SQL = ''ENABLE Trigger trigKartris'' + @TriggerName + '' ON tblKartris'' + @TableName;
	EXECUTE(@SQL)
		
	SELECT @Status = 1 - OBJECTPROPERTY(OBJECT_ID(''trigKartris'' + @TriggerName), ''ExecIsTriggerDisabled'')
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_EnableAllTriggers]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_EnableAllTriggers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDB_EnableAllTriggers]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;

	DECLARE @AllTriggers as nvarchar(MAX);
	SET @AllTriggers = ''Addresses_DML,AdminRelatedTables_DML,AffiliateLog_DML,AffiliatePayments_DML,Attributes_DML,AttributeValues_DML,Categories_DML,CategoryHierarchy_DML,ClonedOrders_DML,Config_DML,Coupons_DML,CreditCards_DML,Currencies_DML,CustomerGroupPrices_DML,CustomerGroups_DML,DeletedItems_DML,Destination_DML,InvoiceRows_DML,KnowledgeBase_DML,LanguageElements_DML,Languages_D,Languages_DML,Languages_U,LanguageStrings_DML,Logins_DML,MediaLinks_DML,MediaTypes_DML,News_DML,ObjectConfig_DML,ObjectConfigValue_DML,OptionGroups_DML,Options_DML,OrderPaymentLink_DML,Orders_DML,OrdersPromotions_DML,Pages_DML,Payments_DML,ProductCategoryLink_DML,ProductOptionGroupLink_DML,ProductOptionLink_DML,Products_DML,PromotionParts_DML,Promotions_DML,PromotionStrings_DML,QuantityDiscounts_DML,RelatedProducts_DML,Reviews_DML,SavedBaskets_DML,SavedExports_DML,SearchStatistics_DML,ShippingMethods_DML,ShippingRates_DML,ShippingZones_DML,Statistics_DML,Suppliers_DML,SupportTicketMessages_DML,SupportTickets_DML,SupportTicketTypes_DML,TaxRates_DML,Users_DML,VersionOptionLink_DML,Versions_DML,WishLists_DML''
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @TrigName as nvarchar(100);
	DECLARE @TabName as nvarchar(100);
	SET @SIndx = 0;

	WHILE @SIndx <= LEN(@AllTriggers)
	BEGIN
		SET @CIndx = CHARINDEX('','', @AllTriggers, @SIndx);
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@AllTriggers)+1 END
		SET @TrigName = SUBSTRING(@AllTriggers, @SIndx, @CIndx - @SIndx);
		SET @TabName = SUBSTRING(@TrigName, 0, CHARINDEX(''_'', @TrigName));
		SET @SIndx = @CIndx + 1;
		DECLARE @SQL as nvarchar(250);
		SET @SQL = ''ENABLE Trigger trigKartris'' + @TrigName + '' ON tblKartris'' + @TabName;
		EXECUTE(@SQL);
	END

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_DisableTrigger]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_DisableTrigger]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDB_DisableTrigger]
(
	@TriggerName as sysname, 
	@TableName as sysname,
	@Status as smallint out
)
AS
BEGIN
	
	DECLARE @SQL as nvarchar(250);
	SET @SQL = ''DISABLE Trigger trigKartris'' + @TriggerName + '' ON tblKartris'' + @TableName;
	EXECUTE (@SQL);

	SELECT @Status = 1 - OBJECTPROPERTY(OBJECT_ID(''trigKartris'' + @TriggerName), ''ExecIsTriggerDisabled'')
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_DisableAllTriggers]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_DisableAllTriggers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDB_DisableAllTriggers]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;

	DECLARE @AllTriggers as nvarchar(MAX);
	SET @AllTriggers = ''Addresses_DML,AdminRelatedTables_DML,AffiliateLog_DML,AffiliatePayments_DML,Attributes_DML,AttributeValues_DML,Categories_DML,CategoryHierarchy_DML,ClonedOrders_DML,Config_DML,Coupons_DML,CreditCards_DML,Currencies_DML,CustomerGroupPrices_DML,CustomerGroups_DML,DeletedItems_DML,Destination_DML,InvoiceRows_DML,KnowledgeBase_DML,LanguageElements_DML,Languages_D,Languages_DML,Languages_U,LanguageStrings_DML,Logins_DML,MediaLinks_DML,MediaTypes_DML,News_DML,ObjectConfig_DML,ObjectConfigValue_DML,OptionGroups_DML,Options_DML,OrderPaymentLink_DML,Orders_DML,OrdersPromotions_DML,Pages_DML,Payments_DML,ProductCategoryLink_DML,ProductOptionGroupLink_DML,ProductOptionLink_DML,Products_DML,PromotionParts_DML,Promotions_DML,PromotionStrings_DML,QuantityDiscounts_DML,RelatedProducts_DML,Reviews_DML,SavedBaskets_DML,SavedExports_DML,SearchStatistics_DML,ShippingMethods_DML,ShippingRates_DML,ShippingZones_DML,Statistics_DML,Suppliers_DML,SupportTicketMessages_DML,SupportTickets_DML,SupportTicketTypes_DML,TaxRates_DML,Users_DML,VersionOptionLink_DML,Versions_DML,WishLists_DML''
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @TrigName as nvarchar(100);
	DECLARE @TabName as nvarchar(100);
	SET @SIndx = 0;

	WHILE @SIndx <= LEN(@AllTriggers)
	BEGIN
		SET @CIndx = CHARINDEX('','', @AllTriggers, @SIndx);
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@AllTriggers)+1 END
		SET @TrigName = SUBSTRING(@AllTriggers, @SIndx, @CIndx - @SIndx);
		SET @TabName = SUBSTRING(@TrigName, 0, CHARINDEX(''_'', @TrigName));
		SET @SIndx = @CIndx + 1;
		DECLARE @SQL as nvarchar(250);
		SET @SQL = ''DISABLE Trigger trigKartris'' + @TrigName + '' ON tblKartris'' + @TabName;
		EXECUTE(@SQL);
	END

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_CreateBackup]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_CreateBackup]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDB_CreateBackup]
(
	@BackupPath as nvarchar(200)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @DBName as nvarchar(50)
	SET @DBName = DB_NAME();
	BACKUP DATABASE @DBName
	TO DISK = @BackupPath;

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_GetInformation]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_GetInformation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDB_GetInformation]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT  DB_NAME() as ''DatabaseName'', name as ''FileName'',  ''FILE TYPE'' as FileType, 
			size/128 as ''FileSize'', CAST(FILEPROPERTY(name, ''SpaceUsed'') AS int)/128.0 AS ''UsedSize'',
			physical_name as ''FileLocation''
	FROM sys.database_files
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_GetFTSInfo]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_GetFTSInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDB_GetFTSInfo]
(
	@kartrisCatalogExist bit OUT,
	@kartrisFTSEnabled bit OUT,
	@kartrisFTSLanguages nvarchar(MAX) OUT,
	@FTSSupported bit OUT
)
AS
BEGIN
		SET NOCOUNT ON;
		SET @kartrisFTSLanguages = '''';
		SELECT @kartrisCatalogExist = count(1) FROM sys.fulltext_catalogs WHERE name = ''kartrisCatalog'';
		select @kartrisFTSEnabled = DatabaseProperty(db_name(), ''IsFulltextEnabled'');
		
		DECLARE @FTSLanguagesCounter as int
		SET @FTSLanguagesCounter = 0;
		DECLARE FTSLanguagesCursor CURSOR FOR
		SELECT name FROM sys.fulltext_languages ORDER BY name;
		DECLARE @LangName as nvarchar(50);
		
		OPEN FTSLanguagesCursor
		FETCH NEXT FROM FTSLanguagesCursor
		INTO @LangName;
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @kartrisFTSLanguages = @kartrisFTSLanguages + @LangName + ''##''
			SET @FTSLanguagesCounter = @FTSLanguagesCounter + 1
			FETCH NEXT FROM FTSLanguagesCursor
			INTO @LangName;
		END
		CLOSE FTSLanguagesCursor
		DEALLOCATE FTSLanguagesCursor
		
		SET @FTSSupported = 1;		
		IF @kartrisCatalogExist = 0 AND @FTSLanguagesCounter = 0
		BEGIN
			SET @FTSSupported = 0;
			CREATE FULLTEXT CATALOG kartris_testCatalog;
			SELECT @kartrisCatalogExist = count(1) FROM sys.fulltext_catalogs WHERE name = ''kartris_testCatalog'';
			IF @kartrisCatalogExist = 1
			BEGIN
				SET @FTSSupported = 1;
				DROP FULLTEXT CATALOG kartris_testCatalog;
			END
			SET @kartrisCatalogExist = 0;
		END	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_StopFTS]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_StopFTS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDB_StopFTS]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF EXISTS (SELECT * FROM sys.fulltext_catalogs WHERE name = ''kartrisCatalog'')
	BEGIN	
			EXEC sp_fulltext_column    ''tblKartrisLanguageElements'', ''LE_Value'', ''drop'';
			EXEC sp_fulltext_table     ''tblKartrisLanguageElements'', ''drop'';
		
			EXEC sp_fulltext_column    ''tblKartrisAddresses'', ''ADR_Name'', ''drop'';		
			EXEC sp_fulltext_table     ''tblKartrisAddresses'', ''drop'';
		
			EXEC sp_fulltext_column    ''tblKartrisUsers'', ''U_EmailAddress'', ''drop'';
			EXEC sp_fulltext_table     ''tblKartrisUsers'', ''drop'';
		
			EXEC sp_fulltext_column    ''dbo.tblKartrisOrders'', ''O_PurchaseOrderNo'', ''drop'';
			EXEC sp_fulltext_table     ''dbo.tblKartrisOrders'', ''drop'';

			EXEC sp_fulltext_column    ''tblKartrisConfig'', ''CFG_Name'', ''drop'';		
			EXEC sp_fulltext_table     ''tblKartrisConfig'', ''drop'';
		
			EXEC sp_fulltext_column    ''tblKartrisLanguageStrings'', ''LS_Name'', ''drop'';
			EXEC sp_fulltext_column    ''tblKartrisLanguageStrings'', ''LS_Value'', ''drop'';
			EXEC sp_fulltext_table     ''tblKartrisLanguageStrings'', ''drop'';
		
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[spKartrisDB_SearchFTS]'') AND type in (N''P'', N''PC''))
			DROP PROCEDURE [dbo].[spKartrisDB_SearchFTS]
	
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[_spKartrisDB_AdminSearchFTS]'') AND type in (N''P'', N''PC''))
			DROP PROCEDURE [dbo].[_spKartrisDB_AdminSearchFTS]

			DROP FULLTEXT CATALOG kartrisCatalog;
			EXEC sp_fulltext_database ''disable'';				
					
	END
	
END





' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_SetupFTS]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_SetupFTS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDB_SetupFTS]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	EXEC sp_fulltext_database ''enable'';

	DECLARE @kartrisCatalogExist as int;
	SET @kartrisCatalogExist = 0;
	SELECT @kartrisCatalogExist = count(1) FROM sys.fulltext_catalogs WHERE name = ''kartrisCatalog'';
	IF @kartrisCatalogExist = 0 BEGIN CREATE FULLTEXT CATALOG kartrisCatalog END;
	
	EXEC sp_fulltext_table     ''dbo.tblKartrisLanguageElements'', ''create'', ''kartrisCatalog'', ''keyLE_ID''
	EXEC sp_fulltext_column    ''dbo.tblKartrisLanguageElements'', ''LE_Value'', ''add''
	EXEC sp_fulltext_table     ''dbo.tblKartrisLanguageElements'',''activate''

	EXEC sp_fulltext_table     ''dbo.tblKartrisAddresses'', ''create'', ''kartrisCatalog'', ''PK_tblKartrisAddresses''
	EXEC sp_fulltext_column    ''dbo.tblKartrisAddresses'', ''ADR_Name'', ''add''
	EXEC sp_fulltext_table     ''dbo.tblKartrisAddresses'',''activate''

	EXEC sp_fulltext_table     ''dbo.tblKartrisUsers'', ''create'', ''kartrisCatalog'', ''aaaaatblKartrisCustomers_PK''
	EXEC sp_fulltext_column    ''dbo.tblKartrisUsers'', ''U_EmailAddress'', ''add''
	EXEC sp_fulltext_table     ''dbo.tblKartrisUsers'',''activate''

	EXEC sp_fulltext_table     ''dbo.tblKartrisOrders'', ''create'', ''kartrisCatalog'', ''aaaaatblKartrisOrders_PK''
	EXEC sp_fulltext_column    ''dbo.tblKartrisOrders'', ''O_PurchaseOrderNo'', ''add''
	EXEC sp_fulltext_table     ''dbo.tblKartrisOrders'',''activate''

	EXEC sp_fulltext_table     ''dbo.tblKartrisConfig'', ''create'', ''kartrisCatalog'', ''PK_tblKartrisConfig''
	EXEC sp_fulltext_column    ''dbo.tblKartrisConfig'', ''CFG_Name'', ''add''
	EXEC sp_fulltext_table     ''dbo.tblKartrisConfig'',''activate''

	EXEC sp_fulltext_table     ''dbo.tblKartrisLanguageStrings'', ''create'', ''kartrisCatalog'', ''LS_ID''
	EXEC sp_fulltext_column    ''dbo.tblKartrisLanguageStrings'', ''LS_Name'', ''add''
	EXEC sp_fulltext_column    ''dbo.tblKartrisLanguageStrings'', ''LS_Value'', ''add''
	EXEC sp_fulltext_table     ''dbo.tblKartrisLanguageStrings'',''activate''

	ALTER FULLTEXT INDEX ON dbo.tblKartrisLanguageElements SET CHANGE_TRACKING AUTO;
	ALTER FULLTEXT INDEX ON dbo.tblKartrisAddresses SET CHANGE_TRACKING AUTO;
	ALTER FULLTEXT INDEX ON dbo.tblKartrisUsers SET CHANGE_TRACKING AUTO;
	ALTER FULLTEXT INDEX ON dbo.tblKartrisOrders SET CHANGE_TRACKING AUTO;
	ALTER FULLTEXT INDEX ON dbo.tblKartrisConfig SET CHANGE_TRACKING AUTO;
	ALTER FULLTEXT INDEX ON dbo.tblKartrisLanguageStrings SET CHANGE_TRACKING AUTO;

	EXEC sp_fulltext_catalog   ''kartrisCatalog'', ''start_full''	
  

	IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[spKartrisDB_SearchFTS]'') AND type in (N''P'', N''PC''))
BEGIN
EXEC dbo.sp_executesql @statement = N''-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[spKartrisDB_SearchFTS]
(	
	@SearchText as nvarchar(500),
	@keyWordsList as nvarchar(500),
	@LANG_ID as tinyint,
	@PageIndex as smallint,
	@RowsPerPage as tinyint,
	@TotalResultProducts as int OUTPUT,
	@MinPrice as real,
	@MaxPrice as real,
	@Method as nvarchar(10),
	@CustomerGroupID as smallint
)
AS
BEGIN
	SET NOCOUNT ON;
	
	-----------------------
	-- Variable Declaration
	-----------------------
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @Keyword as nvarchar(150);
	DECLARE @Counter as int;
	
	DECLARE @NoOfVersions as bigint;
	SELECT @NoOfVersions = Count(1)	FROM tblKartrisVersions;
	
	-- Include Products and Attributes if no. of versions > 100,000
	-- Include Versions, Products and Attributes if no. of versions <= 100,000
	DECLARE @DataToSearch as nvarchar(100);
	IF @NoOfVersions > 100000 BEGIN
		SET @DataToSearch = ''''(LE_TypeID IN (2,14) AND LE_FieldID IN (1,2,5))''''
	END ELSE BEGIN
		SET @DataToSearch = ''''(LE_TypeID IN (1,2,14) AND LE_FieldID IN (1,2,5))''''
	END
		
	DECLARE @ExactCriteriaNoNoise as nvarchar(500);
	SET @ExactCriteriaNoNoise = Replace(@keyWordsList, '''','''', '''' '''');
	
	IF @Method = ''''exact'''' BEGIN
		-- Searching value of LanguageElements - Add results to search helper (LIKE Operator)
		EXECUTE(''''
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, '''''''''''' + @KeyWord + ''''''''''''
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = '''' + @LANG_ID +'''' AND '''' + @DataToSearch + ''''
					AND (	(Contains(LE_Value, ''''''''"'''' + @SearchText + ''''"''''''''))
						 OR	(Contains(LE_Value, ''''''''"'''' + @ExactCriteriaNoNoise + ''''"''''''''))
						)'''');
						
		-- Searching version code of Versions - Add results to search helper				
		EXECUTE(''''
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, '''''''''''' + @ExactCriteriaNoNoise + ''''''''''''
		FROM         tblKartrisVersions
		WHERE     (V_Live = 1) AND (V_CodeNumber LIKE '''''''''''' + @SearchText + ''''%'''''''')'''' );	
	END ELSE BEGIN
		-- Loop through out the list of keywords and search each keyword
		SET @SIndx = 0; SET @Counter = 0;
		WHILE @SIndx <= LEN(@keyWordsList) BEGIN
			SET @Counter = @Counter + 1;	-- keywords counter
			SET @CIndx = CHARINDEX('''','''', @keyWordsList, @SIndx)	-- Next keyword starting index (1-Based Index)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+ 1 END	-- If no more keywords, set next starting index to not exist
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			
			SET @SIndx = @CIndx + 1;	-- The next starting index
				
			
			-- Searching value of LanguageElements - Add results to search helper (LIKE Operator)
			EXECUTE(''''
			INSERT INTO tblKartrisSearchHelper
			SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
						dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, '''''''''''' + @KeyWord + ''''''''''''
			FROM       tblKartrisLanguageElements 
			WHERE	LE_LanguageID = '''' + @LANG_ID +'''' AND '''' + @DataToSearch + '''' AND (Contains(LE_Value, '''''''''''' + @KeyWord + '''''''''''')) '''');
				
			-- Searching version code of Versions - Add results to search helper				
			EXECUTE(''''
			INSERT INTO tblKartrisSearchHelper
			SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, '''''''''''' + @KeyWord + ''''''''''''
			FROM         tblKartrisVersions
			WHERE     (V_Live = 1) AND (V_CodeNumber LIKE '''''''''''' + @Keyword + ''''%'''''''')'''' );
		END
	END
	

	-- (Advanced Search) Exclude products that are not between the price range
	IF @MinPrice <> -1 AND @MaxPrice <> -1 BEGIN
		UPDATE tblKartrisSearchHelper
		SET SH_Price = dbo.fnKartrisProduct_GetMinPriceWithCG(SH_ProductID, @CustomerGroupID)
		WHERE SH_SessionID = @@SPID;
		DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID = @@SPID AND SH_Price NOT BETWEEN @MinPrice AND @MaxPrice;
	END

	-- Exclude products in which their categories are not live
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID
		AND SH_ProductID NOT IN (SELECT distinct tblKartrisProductCategoryLink.PCAT_ProductID
								 FROM	tblKartrisCategories INNER JOIN tblKartrisProductCategoryLink 
										ON tblKartrisCategories.CAT_ID = tblKartrisProductCategoryLink.PCAT_CategoryID
								 WHERE  tblKartrisCategories.CAT_Live = 1)

	-- Exclude products that are Not Live or that are not belongs to customer group
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID AND SH_ProductID IN (SELECT P_ID 
													 FROM dbo.tblKartrisProducts 
													 WHERE P_Live = 0 
														OR (P_CustomerGroupID IS NOT NULL AND P_CustomerGroupID <> @CustomerGroupID)); 
	
	-- Exclude products that are not resulted from non-searchable attributes
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID AND SH_TypeID = 14 
			AND SH_ParentID IN (SELECT tblKartrisAttributeValues.ATTRIBV_ID
							FROM tblKartrisAttributes INNER JOIN tblKartrisAttributeValues 
							ON tblKartrisAttributes.ATTRIB_ID = tblKartrisAttributeValues.ATTRIBV_AttributeID
							WHERE   tblKartrisAttributes.ATTRIB_ShowSearch = 0);

	
	-- Update the scores of the products with exact match			
	IF @Counter > 1 BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (400) 
		WHERE SH_SessionID = @@SPID AND ((SH_TextValue like ''''%'''' + @ExactCriteriaNoNoise + ''''%'''') OR (SH_TextValue like ''''%'''' + @SearchText + ''''%''''));
	END
	
	-- Update the scores according to number of versions
	IF @NoOfVersions > 100000 BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30) WHERE SH_SessionID = @@SPID AND SH_FieldID = 2;
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (200) WHERE SH_SessionID = @@SPID AND SH_FieldID IN (1, 5);
	END	ELSE BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30 * SH_TypeID) WHERE SH_SessionID = @@SPID AND SH_TypeID IN (1, 2);
	END
	
	-- Set the starting and ending row numbers
	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;	

	-- Search method ''''ANY'''' - Default Search and ''''EXACT'''' - Advanced Search
	IF @Method = ''''any'''' OR @Method = ''''exact'''' BEGIN
		SELECT @TotalResultProducts =  Count(DISTINCT SH_ProductID) FROM tblKartrisSearchHelper WHERE SH_SessionID = @@SPID;
	
		WITH SearchResult as
		(
			SELECT ROW_NUMBER() OVER (ORDER BY TotalScore DESC) as Row, 
					ProductID, TotalScore
			FROM (	SELECT 
						CASE 
						WHEN T1.SH_ProductID IS NULL THEN T2.SH_ProductID
						ELSE T1.SH_ProductID
						END AS ProductID,
						CASE 
						WHEN Score1 IS NULL THEN Score2
						WHEN Score2 IS NULL THEN Score1
						ELSE (Score1 + Score2) 
						END AS TotalScore
					FROM (
							SELECT SH_SessionID, SH_ProductID, Sum(SH_Score) as Score1
							FROM tblKartrisSearchHelper 
							WHERE SH_TypeID = 2 OR SH_TypeID = 14
							GROUP BY SH_SessionID, SH_ProductID
							HAVING SH_SessionID = @@SPID
						) T1 
						FULL OUTER JOIN 
						(
							SELECT SH_SessionID, SH_ProductID, Max(SH_Score) as Score2
							FROM tblKartrisSearchHelper 
							WHERE SH_TypeID = 1
							Group BY SH_SessionID, SH_ProductID
							HAVING SH_SessionID = @@SPID
						) T2 
						ON T1.SH_ProductID = T2.SH_ProductID
				) T3
		)
		SELECT Row, P_ID, P_Name, dbo.fnKartrisDB_TruncateDescription(P_Desc) as P_Desc, 
				dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID, @CustomerGroupID) as MinPrice, TotalScore
		FROM SearchResult INNER JOIN dbo.vKartrisTypeProducts ON SearchResult.ProductID = dbo.vKartrisTypeProducts.P_ID
		WHERE vKartrisTypeProducts.LANG_ID = @LANG_ID AND ROW BETWEEN @StartRowNumber AND @EndRowNumber
		GROUP BY Row, P_ID, P_Name, P_Desc, TotalScore
		ORDER BY TotalScore DESC
	END
	
	-- Search method ''''ALL'''' - Advanced Search
	IF @Method = ''''all'''' BEGIN
	
		DECLARE @SortedSearchKeywords as nvarchar(max);
		SELECT @SortedSearchKeywords = COALESCE(@SortedSearchKeywords + '''','''', '''''''') + T._ID
		FROM (SELECT TOP(500) _ID FROM dbo.fnTbl_SplitStrings(@keyWordsList) ORDER BY _ID) AS T;

		SELECT @TotalResultProducts =  Count(DISTINCT SH_ProductID) FROM tblKartrisSearchHelper 
		WHERE SH_SessionID = @@SPID AND @SortedSearchKeywords = dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, SH_ProductID);
		
		WITH SearchResult as
		(
			SELECT ROW_NUMBER() OVER (ORDER BY TotalScore DESC) as Row, 
					ProductID, TotalScore
			FROM (	SELECT 
						CASE 
						WHEN T1.SH_ProductID IS NULL THEN T2.SH_ProductID
						ELSE T1.SH_ProductID
						END AS ProductID,
						CASE 
						WHEN Score1 IS NULL THEN Score2
						WHEN Score2 IS NULL THEN Score1
						ELSE (Score1 + Score2) 
						END AS TotalScore
					FROM (
							SELECT SH_SessionID, SH_ProductID, Sum(SH_Score) as Score1
							FROM tblKartrisSearchHelper 
							WHERE SH_TypeID = 2 OR SH_TypeID = 14
							GROUP BY SH_SessionID, SH_ProductID
							HAVING SH_SessionID = @@SPID AND @SortedSearchKeywords = dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, SH_ProductID)
						) T1 
						FULL OUTER JOIN 
						(
							SELECT SH_SessionID, SH_ProductID, Max(SH_Score) as Score2
							FROM tblKartrisSearchHelper 
							WHERE SH_TypeID = 1
							Group BY SH_SessionID, SH_ProductID
							HAVING SH_SessionID = @@SPID AND @SortedSearchKeywords = dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, SH_ProductID)
						) T2 
						ON T1.SH_ProductID = T2.SH_ProductID
				) T3
		)
		SELECT Row, P_ID, P_Name, dbo.fnKartrisDB_TruncateDescription(P_Desc) as P_Desc, 
				dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID, @CustomerGroupID) as MinPrice, TotalScore, 
				dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID,P_ID) AS KeywordList
		FROM SearchResult INNER JOIN dbo.vKartrisTypeProducts ON SearchResult.ProductID = dbo.vKartrisTypeProducts.P_ID
		WHERE vKartrisTypeProducts.LANG_ID = @LANG_ID AND ROW BETWEEN @StartRowNumber AND @EndRowNumber
		GROUP BY Row, P_ID, P_Name, P_Desc, TotalScore
		ORDER BY TotalScore DESC
		
	END
	
	-- Clear the result of the current search
	DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID=@@SPID;
	
END'' 
END
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[_spKartrisDB_AdminSearchFTS]'') AND type in (N''P'', N''PC''))
BEGIN
EXEC dbo.sp_executesql @statement = N''
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDB_AdminSearchFTS]
(	
	@searchLocation as nvarchar(25),
	@keyWordsList as nvarchar(100),
	@LANG_ID as tinyint,
	@PageIndex as smallint,
	@RowsPerPage as tinyint,
	@TotalResult as int OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @KeyWord as nvarchar(30);
	SET @SIndx = 0;
	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;

	DECLARE @TypeNo as tinyint;
	SET @TypeNo = 0;
	IF @searchLocation = ''''products'''' BEGIN SET @TypeNo = 2 END
	IF @searchLocation = ''''categories'''' BEGIN SET @TypeNo = 3 END
	
	--================ PRODUCTS/CATEGORIES ==================
	IF @searchLocation = ''''products'''' OR @searchLocation = ''''categories''''
	BEGIN
			CREATE TABLE #_ProdCatSearchTbl(ItemID nvarchar(255), ItemValue nvarchar(MAX))
			WHILE @SIndx <= LEN(@keyWordsList)
			BEGIN
				
				SET @CIndx = CHARINDEX('''','''', @keyWordsList, @SIndx)
				IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
				SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
				SET @SIndx = @CIndx + 1;
				INSERT INTO #_ProdCatSearchTbl (ItemID,ItemValue)
				SELECT     CAST(LE_ParentID as nvarchar(255)), LE_Value
				FROM		tblKartrisLanguageElements
				WHERE     (LE_LanguageID = @LANG_ID) AND (LE_TypeID = @TypeNo) AND (LE_FieldID = 1) AND Contains(LE_Value, @KeyWord);
			END

			SELECT @TotalResult =  Count(ItemID) FROM #_ProdCatSearchTbl;

			SELECT     ItemID, ItemValue
			FROM         #_ProdCatSearchTbl
			
			DROP TABLE #_ProdCatSearchTbl;
		END

	--================ VERSIONS ==================
	IF @searchLocation = ''''versions''''
	BEGIN
		CREATE TABLE #_VersionSearchTbl(VersionID nvarchar(255), VersionName nvarchar(MAX), VersionCode nvarchar(25), ProductID nvarchar(255))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX('''','''', @keyWordsList, @SIndx)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			SET @SIndx = @CIndx + 1;
			INSERT INTO #_VersionSearchTbl (VersionID, VersionName, VersionCode, ProductID)
			SELECT     CAST(LE_ParentID as nvarchar(255)), LE_Value, dbo.fnKartrisVersions_GetCodeNumber(LE_ParentID),
						CAST(dbo.fnKartrisVersions_GetProductID(LE_ParentID) as nvarchar(255))
			FROM		tblKartrisLanguageElements
			WHERE     (LE_LanguageID = @LANG_ID) AND (LE_TypeID = 1) AND (LE_FieldID = 1) AND contains(LE_Value, @KeyWord);

			-- SEARCH FOR THE CODE NUMBER
			INSERT INTO #_VersionSearchTbl (VersionID, VersionName, VersionCode, ProductID)
			SELECT     CAST(LE_ParentID as nvarchar(255)), LE_Value, dbo.fnKartrisVersions_GetCodeNumber(LE_ParentID),
						CAST(dbo.fnKartrisVersions_GetProductID(LE_ParentID) as nvarchar(255))
			FROM		tblKartrisLanguageElements
			WHERE     (LE_LanguageID = @LANG_ID) AND (LE_TypeID = 1) AND (LE_FieldID = 1) 
					AND LE_ParentID IN (SELECT V_ID FROM tblKartrisVersions WHERE V_CodeNumber LIKE @KeyWord + ''''%'''');

		END

		SELECT @TotalResult =  Count(VersionID) FROM #_VersionSearchTbl;
		
		SELECT     VersionID, VersionName, VersionCode, ProductID
		FROM         #_VersionSearchTbl
		DROP TABLE #_VersionSearchTbl;
	END

	--================ CUSTOMERS ==================
	IF @searchLocation = ''''customers''''
	BEGIN
			
			CREATE TABLE #_CustomerSearchTbl(CustomerID nvarchar(255), CustomerName nvarchar(50), CustomerEmail nvarchar(100))
			WHILE @SIndx <= LEN(@keyWordsList)
			BEGIN
				
				SET @CIndx = CHARINDEX('''','''', @keyWordsList, @SIndx)
				IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
				SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
				SET @SIndx = @CIndx + 1;

				INSERT INTO #_CustomerSearchTbl (CustomerID, CustomerName, CustomerEmail)
				SELECT     tblKartrisUsers.U_ID, tblKartrisAddresses.ADR_Name, tblKartrisUsers.U_EmailAddress
				FROM         tblKartrisAddresses RIGHT OUTER JOIN
									  tblKartrisUsers ON tblKartrisAddresses.ADR_ID = tblKartrisUsers.U_DefBillingAddressID
				WHERE     Contains(tblKartrisAddresses.ADR_Name, @KeyWord ) OR
						Contains(tblKartrisUsers.U_EmailAddress, @KeyWord );

			END

			SELECT @TotalResult =  Count(CustomerID) FROM #_CustomerSearchTbl;

			SELECT     CustomerID, CustomerName, CustomerEmail
			FROM         #_CustomerSearchTbl
			
			DROP TABLE #_CustomerSearchTbl;
		END

		--================ ORDERS ==================
		IF @searchLocation = ''''orders''''
		BEGIN
			CREATE TABLE #_OrdersSearchTbl(OrderID int, PurchaseOrderNumber nvarchar(50))
			WHILE @SIndx <= LEN(@keyWordsList)
			BEGIN
				
				SET @CIndx = CHARINDEX('''','''', @keyWordsList, @SIndx)
				IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
				SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
				SET @SIndx = @CIndx + 1;

				INSERT INTO #_OrdersSearchTbl (OrderID, PurchaseOrderNumber)
				SELECT     tblKartrisOrders.O_ID, tblKartrisOrders.O_PurchaseOrderNo
				FROM         tblKartrisOrders 
				WHERE     Contains(tblKartrisOrders.O_PurchaseOrderNo,@KeyWord);

				BEGIN TRY
					INSERT INTO #_OrdersSearchTbl (OrderID, PurchaseOrderNumber)
					SELECT     tblKartrisOrders.O_ID, tblKartrisOrders.O_PurchaseOrderNo
					FROM         tblKartrisOrders 
					WHERE     (tblKartrisOrders.O_ID = @KeyWord);
				END TRY
				BEGIN CATCH
				END CATCH

			END

			SELECT @TotalResult =  Count(OrderID) FROM #_OrdersSearchTbl;


			SELECT     OrderID, PurchaseOrderNumber
			FROM         #_OrdersSearchTbl
			
			DROP TABLE #_OrdersSearchTbl;
		END

	--================ CONFIG ==================
	IF @searchLocation = ''''config''''
	BEGIN
			
		CREATE TABLE #_ConfigSearchTbl(ConfigName nvarchar(100), ConfigValue nvarchar(255))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX('''','''', @keyWordsList, @SIndx)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			SET @SIndx = @CIndx + 1;

			INSERT INTO #_ConfigSearchTbl (ConfigName, ConfigValue)
			SELECT     tblKartrisConfig.CFG_Name, tblKartrisConfig.CFG_Value
			FROM         tblKartrisConfig 
			WHERE     Contains(tblKartrisConfig.CFG_Name,@KeyWord);

		END

		SELECT @TotalResult =  Count(ConfigName) FROM #_ConfigSearchTbl;

		SELECT     ConfigName, ConfigValue
		FROM         #_ConfigSearchTbl
		
		DROP TABLE #_ConfigSearchTbl;
	END

	--================ LS ==================
	IF @searchLocation = ''''site''''
	BEGIN
			
		CREATE TABLE #_LSSearchTbl(LSFB char(1), LSLang tinyint, LSName nvarchar(255), LSValue nvarchar(MAX), LSClass nvarchar(50))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX('''','''', @keyWordsList, @SIndx)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			SET @SIndx = @CIndx + 1;

			INSERT INTO #_LSSearchTbl (LSFB, LSLang, LSName, LSValue, LSClass)
			SELECT     tblKartrisLanguageStrings.LS_FrontBack, tblKartrisLanguageStrings.LS_LangID,
						tblKartrisLanguageStrings.LS_Name, tblKartrisLanguageStrings.LS_Value, tblKartrisLanguageStrings.LS_ClassName
			FROM         tblKartrisLanguageStrings 
			WHERE     tblKartrisLanguageStrings.LS_LangID = @LANG_ID AND
					(Contains(tblKartrisLanguageStrings.LS_Name, @KeyWord) OR
						Contains(tblKartrisLanguageStrings.LS_Value, @KeyWord));

		END

		SELECT @TotalResult =  Count(LSName) FROM #_LSSearchTbl;

		SELECT     LSFB, LSLang, LSName, LSValue, LSClass
		FROM         #_LSSearchTbl
		
		DROP TABLE #_LSSearchTbl;
	END
	
	--============== Custom Pages =======================
	IF @searchLocation = ''''pages''''
	BEGIN
		CREATE TABLE #_CustomPagesSearchTbl(PageID smallint, PageName nvarchar(50))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX('''','''', @keyWordsList, @SIndx)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			SET @SIndx = @CIndx + 1;
			
			INSERT INTO #_CustomPagesSearchTbl (PageID, PageName)
			SELECT DISTINCT LE_ParentID, PAGE_Name
			FROM dbo.tblKartrisLanguageElements INNER JOIN dbo.tblKartrisPages
				ON tblKartrisLanguageElements.LE_ParentID = tblKartrisPages.PAGE_ID
			WHERE (LE_LanguageID = @LANG_ID) AND (LE_TypeID = 8) AND Contains(LE_Value, @KeyWord);
			
		END

		SELECT @TotalResult =  Count(DISTINCT PageID) FROM #_CustomPagesSearchTbl;
		

		SELECT  DISTINCT PageID, PageName
		FROM         #_CustomPagesSearchTbl
		DROP TABLE #_CustomPagesSearchTbl;
	END

END
''
END
		
END




' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_GetTriggers]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_GetTriggers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDB_GetTriggers]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @AllTriggers as nvarchar(MAX);
	SET @AllTriggers = ''Addresses_DML,AffiliateLog_DML,AffiliatePayments_DML,Attributes_DML,AttributeValues_DML,Categories_DML,CategoryHierarchy_DML,ClonedOrders_DML,Config_DML,Coupons_DML,CreditCards_DML,Currencies_DML,CustomerGroupPrices_DML,CustomerGroups_DML,DeletedItems_DML,Destination_DML,InvoiceRows_DML,KnowledgeBase_DML,LanguageElements_DML,Languages_D,Languages_DML,Languages_U,LanguageStrings_DML,Logins_DML,MediaLinks_DML,MediaTypes_DML,News_DML,ObjectConfig_DML,ObjectConfigValue_DML,OptionGroups_DML,Options_DML,OrderPaymentLink_DML,Orders_DML,OrdersPromotions_DML,Pages_DML,Payments_DML,ProductCategoryLink_DML,ProductOptionGroupLink_DML,ProductOptionLink_DML,Products_DML,PromotionParts_DML,Promotions_DML,PromotionStrings_DML,QuantityDiscounts_DML,RelatedProducts_DML,Reviews_DML,SavedBaskets_DML,SavedExports_DML,SearchStatistics_DML,ShippingMethods_DML,ShippingRates_DML,ShippingZones_DML,Statistics_DML,Suppliers_DML,SupportTicketMessages_DML,SupportTickets_DML,SupportTicketTypes_DML,TaxRates_DML,Users_DML,VersionOptionLink_DML,Versions_DML,WishLists_DML''
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @TrigName as nvarchar(100);
	DECLARE @TabName as nvarchar(100);
	SET @SIndx = 0;

	CREATE TABLE #TempTbl(TableName nvarchar(100), TriggerName nvarchar(100), IsTriggerEnabled bit);

		WHILE @SIndx <= LEN(@AllTriggers)
		BEGIN
			
			SET @CIndx = CHARINDEX('','', @AllTriggers, @SIndx);
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@AllTriggers)+1 END
			SET @TrigName = SUBSTRING(@AllTriggers, @SIndx, @CIndx - @SIndx);
			SET @TabName = SUBSTRING(@TrigName, 0, CHARINDEX(''_'', @TrigName));
			SET @SIndx = @CIndx + 1;
			INSERT INTO #TempTbl VALUES(@TabName, @TrigName, 1 - OBJECTPROPERTY(OBJECT_ID(''trigKartris'' + @TrigName), ''ExecIsTriggerDisabled''))
	  
		END
	SELECT * FROM #TempTbl;

	DROP TABLE #TempTbl;
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSupportTickets_Search]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSupportTickets_Search]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSupportTickets_Search]
(
	@Keyword as nvarchar(100),
	@LangID as smallint,
	@AssignedID as smallint,
	@TypeID as smallint,
	@Status as char(1)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Cmd as nvarchar(MAX);
	SET @Cmd =
	''SELECT DISTINCT 
					  tblKartrisSupportTickets.TIC_ID, tblKartrisSupportTickets.TIC_DateOpened, tblKartrisSupportTickets.TIC_DateClosed, tblKartrisSupportTickets.TIC_Subject, 
					  tblKartrisSupportTickets.TIC_UserID, tblKartrisSupportTickets.TIC_LoginID, tblKartrisSupportTickets.TIC_SupportTicketTypeID, tblKartrisSupportTickets.TIC_Status, 
					  tblKartrisLogins.LOGIN_Username, tblKartrisUsers.U_EmailAddress, MAX(tblKartrisSupportTicketMessages.STM_DateCreated) AS LastMessageDate, 
					  tblKartrisSupportTicketTypes.STT_Name, tblKartrisUsers.U_LanguageID, dbo.fnKartrisSupportTicketMessages_IsAwaitingReply(tblKartrisSupportTickets.TIC_ID) As TIC_AwaitingResponse
	FROM         tblKartrisSupportTickets INNER JOIN
						  tblKartrisSupportTicketMessages ON tblKartrisSupportTickets.TIC_ID = tblKartrisSupportTicketMessages.STM_TicketID INNER JOIN
						  tblKartrisUsers ON tblKartrisSupportTickets.TIC_UserID = tblKartrisUsers.U_ID LEFT OUTER JOIN
						  tblKartrisSupportTicketTypes ON tblKartrisSupportTickets.TIC_SupportTicketTypeID = tblKartrisSupportTicketTypes.STT_ID LEFT OUTER JOIN
						  tblKartrisLogins ON tblKartrisSupportTickets.TIC_LoginID = tblKartrisLogins.LOGIN_ID
	WHERE 
	GROUP BY tblKartrisSupportTickets.TIC_ID, tblKartrisSupportTickets.TIC_DateOpened, tblKartrisSupportTickets.TIC_DateClosed, tblKartrisSupportTickets.TIC_Subject, 
						  tblKartrisSupportTickets.TIC_UserID, tblKartrisSupportTickets.TIC_LoginID, tblKartrisSupportTickets.TIC_SupportTicketTypeID, tblKartrisSupportTickets.TIC_Status, 
						  tblKartrisLogins.LOGIN_Username, tblKartrisUsers.U_EmailAddress, tblKartrisSupportTicketTypes.STT_Name, tblKartrisUsers.U_LanguageID,
							dbo.fnKartrisSupportTicketMessages_IsAwaitingReply(tblKartrisSupportTickets.TIC_ID) 
	HAVING (tblKartrisUsers.U_LanguageID = '' + CAST(@LangID as nvarchar(2)) + '') ''
	IF (@Keyword <> '''') AND (@Keyword IS NOT NULL)
	BEGIN
		SET @Cmd = Replace(@Cmd, ''WHERE '','' WHERE (tblKartrisSupportTicketMessages.STM_Text LIKE ''''%'' + @Keyword + ''%'''' OR
								tblKartrisSupportTickets.TIC_Subject LIKE ''''%'' + @Keyword + ''%'''') '')
	END
	ELSE
	BEGIN
		SET @Cmd = Replace(@Cmd, ''WHERE '','' '')
	END
	IF (@AssignedID <> -1)
	BEGIN
		SET @Cmd = @Cmd + '' AND  (tblKartrisSupportTickets.TIC_LoginID='' + CAST(@AssignedID as nvarchar(10)) + '') ''
	END
	IF (@TypeID <> -1)
	BEGIN
		SET @Cmd = @Cmd + '' AND  (tblKartrisSupportTickets.TIC_SupportTicketTypeID='' + CAST(@TypeID as nvarchar(10)) + '') ''
	END
	IF (@Status <> ''a'')
	BEGIN
		IF (@Status = ''w'')
		BEGIN
			SET @Cmd = @Cmd + '' AND  (tblKartrisSupportTickets.TIC_ID IN 
										(SELECT  DISTINCT tblKartrisSupportTicketMessages.STM_TicketID
										 FROM    tblKartrisSupportTicketMessages INNER JOIN tblKartrisSupportTickets 
											ON tblKartrisSupportTicketMessages.STM_TicketID = tblKartrisSupportTickets.TIC_ID
										 WHERE   dbo.fnKartrisSupportTicketMessages_IsAwaitingReply(tblKartrisSupportTicketMessages.STM_TicketID) = 1 ''
			IF (@AssignedID <> -1)
			BEGIN
				SET @Cmd = @Cmd + '' AND  (tblKartrisSupportTickets.TIC_LoginID='' + CAST(@AssignedID as nvarchar(10)) + '') ''
			END	
						
			SET @Cmd = @Cmd + '' ))''
		END
		ELSE
		BEGIN
			SET @Cmd = @Cmd + '' AND  (tblKartrisSupportTickets.TIC_Status='''''' + @Status + '''''') ''
		END
	END

	Print @Cmd;
	EXECUTE(@Cmd);

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisDB_GetFieldLength]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisDB_GetFieldLength]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisDB_GetFieldLength](@tblName as varchar(60), @FieldName as varchar(60))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT COL_LENGTH(@tblName, @FieldName)/2 ;

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[sp__foreachtable]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp__foreachtable]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE proc [dbo].[sp__foreachtable]

/***	Built from the Microsoft original sp__msForEachTable
****
****	Use at your own risk
***/

  @command1 nvarchar(2000), @replacechar nchar(1) = N''?'',
  @command2 nvarchar(2000) = null,
  @command3 nvarchar(2000) = null,
  @whereand nvarchar(2000) = null,
  @precommand nvarchar(2000) = null,
  @postcommand nvarchar(2000) = null

as
  /* This proc returns one or more rows for each table (optionally,
  matching @where), with each table defaulting to its own result set */
  /* @precommand and @postcommand may be used to force a single
  result set via a temp table. */

  /* Preprocessor won''t replace within quotes so have to use str(). */
  declare @mscat nvarchar(12)
  select @mscat = ltrim(str(convert(int, 0x0002)))

  if (@precommand is not null)
	  exec(@precommand)

  /* Create the select */

  exec(N''declare hCForEach cursor global for select (object_name(id))
	  from dbo.sysobjects o '' + N'' where
	  OBJECTPROPERTY(o.id, N''''IsUserTable'''') = 1 '' + N'' and
	  o.category & '' + @mscat + N'' = 0 '' + @whereand)

  declare @retval int
  select @retval = @@error
  if (@retval = 0)
	  exec @retval = sp_MSforeach_worker @command1, @replacechar, @command2, @command3

  if (@retval = 0 and @postcommand is not null)
	  exec(@postcommand)

  return @retval

' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnTbl_SplitStrings]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTbl_SplitStrings]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[fnTbl_SplitStrings]
(	
	@List varchar(max))
RETURNS @ParsedList 
table(_ID varchar(20)) AS BEGIN
	DECLARE @_ID varchar(20), @Pos int    
	SET @List = LTRIM(RTRIM(@List))+ '',''    
	SET @Pos = CHARINDEX('','', @List, 1)    
	IF REPLACE(@List, '','', '''') <> '''' BEGIN        
		WHILE @Pos > 0 BEGIN                
			SET @_ID = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))                
			IF @_ID <> '''' BEGIN                        
				INSERT INTO @ParsedList (_ID)                         
				VALUES (@_ID)              
			END                
			SET @List = RIGHT(@List, LEN(@List) - @Pos)                
			SET @Pos = CHARINDEX('','', @List, 1)        
		END    
	END     
	RETURN
END' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnTbl_SplitNumbers]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTbl_SplitNumbers]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[fnTbl_SplitNumbers]
(	
	@List varchar(max))
RETURNS @ParsedList 
table(_ID int) AS BEGIN
	DECLARE @_ID varchar(10), @Pos int    
	SET @List = LTRIM(RTRIM(@List))+ '',''    
	SET @Pos = CHARINDEX('','', @List, 1)    
	IF REPLACE(@List, '','', '''') <> '''' BEGIN        
		WHILE @Pos > 0 BEGIN                
			SET @_ID = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))                
			IF @_ID <> '''' BEGIN                        
				INSERT INTO @ParsedList (_ID)                         
				VALUES (CAST(@_ID AS int)) --Use Appropriate conversion                
			END                
			SET @List = RIGHT(@List, LEN(@List) - @Pos)                
			SET @Pos = CHARINDEX('','', @List, 1)        
		END    
	END     
	RETURN
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisLanguageElements_GetView]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisLanguageElements_GetView]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisLanguageElements_GetView]
AS
	SET NOCOUNT OFF;
SELECT * FROM [vLanguageElements];


' 
END
GO
/****** Object:  View [dbo].[vKartrisLanguageElementTypesFields]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisLanguageElementTypesFields]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisLanguageElementTypesFields]
AS
SELECT     dbo.tblKartrisLanguageElementTypeFields.LET_ID, dbo.tblKartrisLanguageElementTypes.LET_Name, dbo.tblKartrisLanguageElementTypeFields.LEFN_ID, 
					  dbo.tblKartrisLanguageElementFieldNames.LEFN_Name, dbo.tblKartrisLanguageElementFieldNames.LEFN_DisplayText, 
					  dbo.tblKartrisLanguageElementFieldNames.LEFN_CssClass, dbo.tblKartrisLanguageElementTypeFields.LEFN_IsMandatory, 
					  dbo.tblKartrisLanguageElementFieldNames.LEFN_IsMultiLine, dbo.tblKartrisLanguageElementFieldNames.LEFN_UseHTMLEditor
FROM         dbo.tblKartrisLanguageElementTypeFields INNER JOIN
					  dbo.tblKartrisLanguageElementFieldNames ON dbo.tblKartrisLanguageElementTypeFields.LEFN_ID = dbo.tblKartrisLanguageElementFieldNames.LEFN_ID INNER JOIN
					  dbo.tblKartrisLanguageElementTypes ON dbo.tblKartrisLanguageElementTypeFields.LET_ID = dbo.tblKartrisLanguageElementTypes.LET_ID
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisLanguageElementTypesFields', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[22] 4[24] 2[8] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguageElementTypeFields"
			Begin Extent = 
			   Top = 20
			   Left = 244
			   Bottom = 122
			   Right = 528
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElementFieldNames"
			Begin Extent = 
			   Top = 0
			   Left = 647
			   Bottom = 127
			   Right = 954
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElementTypes"
			Begin Extent = 
			   Top = 6
			   Left = 38
			   Bottom = 93
			   Right = 198
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 10
		 Width = 284
		 Width = 1500
		 Width = 2100
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1755
		 Width = 2025
		 Width = 1500
		 Width = 1665
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 8640
		 Alias = 900
		 Table = 1170
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisLanguageElementTypesFields'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisLanguageElementTypesFields', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisLanguageElementTypesFields'
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_GetCustomerDiscount]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_GetCustomerDiscount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 20/May/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_GetCustomerDiscount] (
	@CustomerID int
) AS
BEGIN
	SET NOCOUNT ON;

	declare @CG_Discount int
	declare @U_CustomerDiscount float
	declare @Discount float


	select @CG_Discount=isnull(CG.CG_Discount,0),@U_CustomerDiscount=U.U_CustomerDiscount from tblKartrisUsers U
	left join tblKartrisCustomerGroups CG on U.U_CustomerGroupID=CG.CG_ID and CG.CG_Live=1
	where U_ID=@CustomerID

	IF @U_CustomerDiscount = 0 BEGIN
		SET @Discount = @CG_Discount;
	END
	ELSE	BEGIN
		SET @Discount = @U_CustomerDiscount;
	END

	select isnull(@Discount,0) as ''Discount''

END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_GetCustomer]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_GetCustomer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 07/Apr/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_GetCustomer] ( 
	@UserID int=0,
	@Email  nvarchar(200)='''',
	@Password nvarchar(200)=''''
) AS
BEGIN
	SET NOCOUNT ON;

	If @UserID=0 
	Begin
		select * from tblKartrisUsers
		where U_EmailAddress=@Email and U_Password=@Password
	End
	Else
	Begin
		select * from tblKartrisUsers
		where U_ID=@UserID
	End
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_GetCouponCode]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_GetCouponCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 01/May/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_GetCouponCode] (
	@CouponCode as varchar(200)
) AS
BEGIN

	SET NOCOUNT ON
	
	SELECT * FROM tblKartrisCoupons
	WHERE CP_CouponCode=@CouponCode

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisAttributes_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisAttributes_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisAttributes_Get]
AS
	SET NOCOUNT ON;
SELECT        tblKartrisAttributes.*
FROM            tblKartrisAttributes

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisAddresses_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisAddresses_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get all user stored addresses
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisAddresses_Get]
(
	@ADR_ID int
)
AS
SET NOCOUNT OFF;
SELECT        *
FROM            tblKartrisAddresses
WHERE        (ADR_ID = @ADR_ID)


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCustomer_GetAffiliateData]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCustomer_GetAffiliateData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Joseph
-- Create date: 20/July/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisCustomer_GetAffiliateData] (
	@Type as smallint,
	@AffiliateID int,
	@Month as smallint=0,
	@Year as smallint=0
) AS
BEGIN
	SET NOCOUNT ON;

	If @Type=1
	Begin
		select sum(round(O_AffiliateTotalPrice+0.00000001,2)) as OrderAmount, year(O_Date) as TheYear, month(O_Date) as TheMonth from tblKartrisUsers U
		inner join tblKartrisOrders O on U.U_ID=O.O_CustomerID
		where U.U_AffiliateID=@AffiliateID and O.O_AffiliatePercentage>0 and O.O_Sent=1 and O.O_Paid=1
		group by U_AffiliateID, year(O_Date), month(O_Date), O_Sent
		order by Year(O_Date) desc, Month(O_Date) desc
	End

	If @Type=2
	Begin
		select count(AFLG_ID) as HitCount, year(AFLG_DateTime) as TheYear, month(AFLG_DateTime) as TheMonth from tblKartrisAffiliateLog AL
		inner join tblKartrisUsers U on AL.AFLG_AffiliateID=U.U_ID
		where U.U_ID=@AffiliateID
		group by year(AFLG_DateTime), month(AFLG_DateTime) 
		order by year(AFLG_DateTime) desc, month(AFLG_DateTime) desc
	End

	If @Type=3 -- monthly (Commission)
	Begin
		declare @OrderTotal float
		declare @Commission float
		declare @Hits float

		select @OrderTotal=isnull(sum(round(O_AffiliateTotalPrice+0.00000001,2)),0),
			@Commission=isnull(sum(round(O_AffiliateTotalPrice * (O_AffiliatePercentage/100) + 0.00000001,2)),0) 
		from tblKartrisUsers U inner join tblKartrisOrders O on U.U_ID=O.O_CustomerID
		where U.U_AffiliateID=@AffiliateID and O.O_AffiliatePercentage>0 and O.O_Sent=1 and O.O_Paid=1
			and year(O_Date)=@Year and month(O_Date)=@Month

		select @Hits=count(AFLG_ID) from tblKartrisAffiliateLog AL
			inner join tblKartrisUsers U on AL.AFLG_AffiliateID=U.U_ID
		where U_ID=@AffiliateID and month(AFLG_DateTime)=@Month and year(AFLG_DateTime)=@Year

		select @OrderTotal as OrderTotal, @Commission as Commission, @Hits as Hits
	End

	If @Type=4 -- monthly (Sales from Affiliate Link)
	Begin
		select sum(round(O_AffiliateTotalPrice,2)) as OrderTotal,
			sum(round(O_AffiliateTotalPrice * (O_AffiliatePercentage/100) + 0.00000001,2)) as Commission ,
			O_AffiliatePercentage,O_Date,O_AffiliatePaymentID from tblKartrisUsers
		inner join tblKartrisOrders ON tblKartrisUsers.U_ID = tblKartrisOrders.O_CustomerID
		where U_AffiliateID = @AffiliateID
			and O_AffiliatePercentage>0 and O_Sent=1 and O_Paid=1 
			and year(O_Date)=@Year and month(O_Date)=@Month 
		group by O_AffiliateTotalPrice,O_AffiliatePercentage,O_Date,O_AffiliatePaymentID,O_ID
		order by O_ID
	End

	If @Type=5 -- balance (Payment Made)	
	Begin	
		select AFP_ID, AFP_DateTime,count(O_ID) as TotalOrders, 
			sum(round(O_AffiliateTotalPrice * (O_AffiliatePercentage/100) + 0.00000001 ,2)) as TotalPayment from tblKartrisAffiliatePayments AP
		inner join tblKartrisOrders O on O.O_AffiliatePaymentID=AP.AFP_ID
		inner join tblKartrisUsers U on AP.AFP_AffiliateID=U.U_ID
		where AFP_AffiliateID=@AffiliateID and O_Sent=1 and O_Paid=1
		group by AFP_ID, AFP_DateTime
	End

	If @Type=6 -- balance (Unpaid Sales)
	Begin
		select SUM(ROUND(O_AffiliateTotalPrice * (O_AffiliatePercentage/100) + 0.00000001 ,2)) as Commission,
			O_ID,O_AffiliatePercentage,O_Date,USR1.U_ID,USR1.U_EmailAddress,USR1.U_AccountHolderName from tblKartrisUsers USR
		inner join tblKartrisOrders O on O.O_CustomerID=USR.U_ID
		inner join tblKartrisUsers USR1 on USR1.U_ID=USR.U_AffiliateID
		where O_Sent=1 and O_AffiliatePercentage>0 and O_AffiliatePaymentID=0 and O_Paid=1
			and USR1.U_ID=@AffiliateID
		group by O_ID,O_AffiliatePercentage,O_Date,USR1.U_ID,USR1.U_EmailAddress,USR1.U_AccountHolderName
		order by O_ID asc
	End

END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCustomer_ConfirmMail]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCustomer_ConfirmMail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 19/Aug/08
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisCustomer_ConfirmMail](
	@U_ID int,
	@Password nvarchar(100),
	@ConfirmDate datetime,
	@ConfirmIP nvarchar(20)
)AS

BEGIN
	SET NOCOUNT ON;
	
	declare @UserID int
	
	select @UserID=U_ID from tblKartrisUsers where U_ID=@U_ID and U_ML_RandomKey=@Password

	If @UserID is not null 
	Begin
Disable Trigger trigKartrisUsers_DML ON tblKartrisUsers;	
		update tblKartrisUsers 
			set U_ML_SendMail=1, 
			U_ML_ConfirmationDateTime = @ConfirmDate,
			U_ML_ConfirmationIP = @ConfirmIP
		where U_ID = @U_ID;
Enable Trigger trigKartrisUsers_DML ON tblKartrisUsers;	
	End

	select isnull(@UserID,0) as UserID

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCustomer_AffiliateLog]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCustomer_AffiliateLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 18/Jan/09
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisCustomer_AffiliateLog] ( 
	@AffiliateID as integer,
	@Referer as nvarchar(255),
	@IP as nvarchar(30),
	@RequestedItem as nvarchar(255),
	@NowOffset datetime
) AS
BEGIN
	SET NOCOUNT ON;
Disable Trigger trigKartrisAffiliateLog_DML ON tblKartrisAffiliateLog;	
	insert into tblKartrisAffiliateLog (AFLG_AffiliateID,AFLG_Referer,AFLG_IP,AFLG_RequestedItem,AFLG_DateTime)
	values (@AffiliateID,@Referer,@IP,@RequestedItem,@NowOffset);
Enable Trigger trigKartrisAffiliateLog_DML ON tblKartrisAffiliateLog;	


END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasketValues_UpdateQuantity]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasketValues_UpdateQuantity]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 29/Apr/08
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasketValues_UpdateQuantity] (
	@BV_ID int,
	@BV_Quantity float
)
AS
BEGIN
	SET NOCOUNT ON;

	Update tblKartrisBasketValues 
	set BV_Quantity=@BV_Quantity
	where BV_ID=@BV_ID;

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasketValues_Update]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasketValues_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisBasketValues_Update]
(
	@BV_ParentType char(1),
	@BV_ParentID bigint,
	@BV_VersionID bigint,
	@BV_Quantity float,
	@BV_CustomText nvarchar(MAX),
	@BV_DateTimeAdded smalldatetime,
	@BV_LastUpdated smalldatetime,
	@Original_BV_ID bigint,
	@BV_ID bigint
)
AS
	SET NOCOUNT OFF;

--Disable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	
	UPDATE [tblKartrisBasketValues] SET [BV_ParentType] = @BV_ParentType, [BV_ParentID] = @BV_ParentID, [BV_VersionID] = @BV_VersionID, [BV_Quantity] = @BV_Quantity, [BV_CustomText] = @BV_CustomText, [BV_DateTimeAdded] = @BV_DateTimeAdded, [BV_LastUpdated] = @BV_LastUpdated WHERE (([BV_ID] = @Original_BV_ID));
--Enable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	

	
SELECT BV_ID, BV_ParentType, BV_ParentID, BV_VersionID, BV_Quantity, BV_CustomText, BV_DateTimeAdded, BV_LastUpdated FROM tblKartrisBasketValues WHERE (BV_ID = @BV_ID)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasketValues_SaveCustomText]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasketValues_SaveCustomText]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 22/Oct/08
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasketValues_SaveCustomText] (
	@BV_ID as int,
	@CustomText as nvarchar(2000)
) AS
BEGIN
	SET NOCOUNT ON;

--Disable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	

	update tblKartrisBasketValues
	set BV_CustomText=@CustomText
	where BV_ID=@BV_ID;

--Enable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCustomer_GetInvoice]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCustomer_GetInvoice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		<Joseph>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisCustomer_GetInvoice] ( 
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
	End

END




' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasketValues_Delete]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasketValues_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisBasketValues_Delete]
(
	@Original_BV_ID bigint
)
AS
	SET NOCOUNT OFF;
--Disable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	
	DELETE FROM [tblKartrisBasketValues] WHERE (([BV_ID] = @Original_BV_ID));
--Enable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasketValues_AddQuantityToItem]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasketValues_AddQuantityToItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisBasketValues_AddQuantityToItem]
(
	@BV_QuantityToAdd float,
	@BV_ID bigint
)
AS
	SET NOCOUNT OFF;
	UPDATE       tblKartrisBasketValues
	SET                BV_Quantity = BV_Quantity + @BV_QuantityToAdd
	WHERE        (BV_ID = @BV_ID);

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasketValues_Add]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasketValues_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisBasketValues_Add]
(
	@BV_ParentType char(1),
	@BV_ParentID bigint,
	@BV_VersionID bigint,
	@BV_Quantity float,
	@BV_CustomText nvarchar(MAX),
	@BV_DateTimeAdded smalldatetime,
	@BV_LastUpdated smalldatetime,
	@BV_CreatedID bigint output
)
AS
	SET NOCOUNT OFF;
	INSERT INTO [tblKartrisBasketValues] ([BV_ParentType], [BV_ParentID], [BV_VersionID], [BV_Quantity], [BV_CustomText], [BV_DateTimeAdded], [BV_LastUpdated]) VALUES (@BV_ParentType, @BV_ParentID, @BV_VersionID, @BV_Quantity, @BV_CustomText, @BV_DateTimeAdded, @BV_LastUpdated);
	
	SELECT @BV_CreatedID = SCOPE_IDENTITY();


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_GetSavedBasket]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_GetSavedBasket]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_GetSavedBasket] ( 
	@intType smallint,
	@CustomerID int,
	@PageIndexStart int=0,
	@PageIndexEnd int=0
) 
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @cnt bigint

	If @intType=0
	Begin
		SELECT @cnt=count(SBSKT_ID) from (
			SELECT distinct SB.* from tblKartrisSavedBaskets SB
			inner join tblKartrisBasketValues BV on SB.SBSKT_ID=BV.BV_ParentID and BV.BV_ParentType=''s''
			where SB.SBSKT_UserID=@CustomerID
		) A
		select isnull(@cnt,0) ''TotalRec''
	End
	Else
	Begin
		SELECT * from (
		SELECT ROW_NUMBER() OVER (ORDER BY SBSKT_ID desc) ''RowNum'', A.* from (
			SELECT distinct SB.* from tblKartrisSavedBaskets SB
			inner join tblKartrisBasketValues BV on SB.SBSKT_ID=BV.BV_ParentID and BV.BV_ParentType=''s''
			where SB.SBSKT_UserID=@CustomerID) A
		) B
		WHERE RowNum>=@PageIndexStart AND RowNum<=@PageIndexEnd
	End
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_GetQtyDiscount]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_GetQtyDiscount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 02/June/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_GetQtyDiscount](
	@VersionID int,
	@Quantity float
)AS
BEGIN

	SET NOCOUNT ON;

	select top 1 * from tblKartrisQuantityDiscounts
	where QD_VersionID=@VersionID and QD_Quantity<=@Quantity order by QD_Quantity desc

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasketValues_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasketValues_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisBasketValues_Get]
AS
	SET NOCOUNT ON;
SELECT        tblKartrisBasketValues.*
FROM            tblKartrisBasketValues

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_GetCustomerOrders]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_GetCustomerOrders]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 22/March/2009
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_GetCustomerOrders] ( 
	@intType smallint,
	@CustomerID int,
	@PageIndexStart int=0,
	@PageIndexEnd int=0
) 
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @cnt bigint

	If @intType=0
	Begin
		select @cnt=count(O_ID) from tblKartrisOrders O 
			inner join tblKartrisCurrencies C on O.O_CurrencyID=C.CUR_ID
		where O_Sent=1 and O_CustomerID=@CustomerID
		select isnull(@cnt,0)''TotalRec''
	End	
	Else
	Begin
		select * from (
			select ROW_NUMBER() OVER (ORDER BY O_Date desc) as RowNum,O_ID,O_Date,O_LastModified,O_TotalPrice,O_PromotionDiscountTotal,O_CouponDiscountTotal,O_DiscountPercentage,O_ShippingPrice,O_OrderHandlingCharge,O_OrderHandlingChargeTax,O_CurrencyID,O_Sent,CUR_Symbol,CUR_RoundNumbers from tblKartrisOrders O
			inner join tblKartrisCurrencies C on O.O_CurrencyID=C.CUR_ID
			where O_Sent=1 and O_CustomerID=@CustomerID
		) ORD 
		WHERE RowNum>=@PageIndexStart AND RowNum<=@PageIndexEnd 
	End

END


' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisDB_TruncateDescription]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisDB_TruncateDescription]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisDB_TruncateDescription] 
(
	@Desc as nvarchar(MAX)
)
RETURNS nvarchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(MAX);
	
	DECLARE @NoOfChar as int;

	SELECT @NoOfChar = CAST(CFG_Value as int)
	FROM tblKartrisConfig
	WHERE CFG_Name = ''frontend.products.display.truncatedescription''


	IF LEN(@Desc) > @NoOfChar
	BEGIN
		SET @Result = LEFT(@Desc, @NoOfChar) + ''...''
	END
	ELSE
	BEGIN
		SET @Result = @Desc
	END
	
	-- Return the result of the function
	RETURN @Result

END
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisConfig_GetValue]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisConfig_GetValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisConfig_GetValue] 
(
	@ConfigName as nvarchar(100)
)
RETURNS nvarchar(255)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(255);
	
	SELECT @Result = CFG_Value
	FROM tblKartrisConfig
	WHERE CFG_Name = @ConfigName;

	-- Return the result of the function
	RETURN @Result

END
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisConfig_GetDefaultLanguage]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisConfig_GetDefaultLanguage]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisConfig_GetDefaultLanguage] 
()
RETURNS tinyint
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result tinyint;
	
	SELECT @Result = CAST(CFG_Value as tinyint)
	FROM tblKartrisConfig
	WHERE CFG_Name = ''frontend.languages.default''

	-- Return the result of the function
	RETURN @Result

END
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartris_GetRemainingWishlist]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartris_GetRemainingWishlist]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 6/May/09
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartris_GetRemainingWishlist] (
	@CustomerID int,
	@VersionID int,
	@CustomText nvarchar(MAX)
)
RETURNS int
AS
BEGIN
	
	DECLARE @Result int

	select @Result=BV_Quantity from tblKartrisBasketValues 
	where BV_ParentType=''r'' and BV_ParentID=@CustomerID and BV_VersionID=@VersionID and BV_CustomText=@CustomText

	RETURN @Result

END
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisSearchHelper_GetKeywordsListByProduct]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisSearchHelper_GetKeywordsListByProduct]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisSearchHelper_GetKeywordsListByProduct]
(
	@SessionID as bigint,
	@ProductID as int
)
RETURNS nvarchar(max)
AS
BEGIN
	DECLARE @KeywordList as nvarchar(max)
	SELECT @KeywordList = COALESCE(@KeywordList + '','', '''') + T.SH_Keyword
	FROM (	SELECT DISTINCT TOP(500) SH_Keyword
			FROM dbo.tblKartrisSearchHelper
			WHERE SH_SessionID = @SessionID AND SH_ProductID = @ProductID
			ORDER BY SH_Keyword) AS T;

	RETURN @KeywordList
END
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisSupportTicketMessages_IsAwaitingReplyFromUser]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisSupportTicketMessages_IsAwaitingReplyFromUser]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisSupportTicketMessages_IsAwaitingReplyFromUser]
(
	@TIC_ID as bigint
)
RETURNS bit
AS
BEGIN

	DECLARE @Status as char(1);
	SELECT @Status = TIC_Status
	FROM dbo.tblKartrisSupportTickets
	WHERE TIC_ID = @TIC_ID;

	IF @Status = ''c'' BEGIN RETURN 0 END

	-- Declare the return variable here
	DECLARE @LastMessageID as bigint;

	SELECT  @LastMessageID =  MAX(tblKartrisSupportTicketMessages.STM_ID)
	FROM         tblKartrisSupportTicketMessages INNER JOIN
					  tblKartrisSupportTickets ON tblKartrisSupportTicketMessages.STM_TicketID = tblKartrisSupportTickets.TIC_ID
	WHERE tblKartrisSupportTicketMessages.STM_TicketID = @TIC_ID;

	DECLARE @LoginID as smallint;
	SELECT @LoginID = STM_LoginID
	FROM dbo.tblKartrisSupportTicketMessages
	WHERE STM_ID = @LastMessageID;

	
	IF @LoginID = 0
	BEGIN
		RETURN 0;
	END
	
	RETURN 1;
END' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisSupportTicketMessages_IsAwaitingReply]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisSupportTicketMessages_IsAwaitingReply]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisSupportTicketMessages_IsAwaitingReply]
(
	@TIC_ID as bigint
)
RETURNS bit
AS
BEGIN

	DECLARE @Status as char(1);
	SELECT @Status = TIC_Status
	FROM dbo.tblKartrisSupportTickets
	WHERE TIC_ID = @TIC_ID;

	IF @Status = ''c'' BEGIN RETURN 0 END

	-- Declare the return variable here
	DECLARE @LastMessageID as bigint;

	SELECT  @LastMessageID =  MAX(tblKartrisSupportTicketMessages.STM_ID)
	FROM         tblKartrisSupportTicketMessages INNER JOIN
					  tblKartrisSupportTickets ON tblKartrisSupportTicketMessages.STM_TicketID = tblKartrisSupportTickets.TIC_ID
	WHERE tblKartrisSupportTicketMessages.STM_TicketID = @TIC_ID;

	DECLARE @LoginID as smallint;
	SELECT @LoginID = STM_LoginID
	FROM dbo.tblKartrisSupportTicketMessages
	WHERE STM_ID = @LastMessageID;

	
	IF @LoginID = 0
	BEGIN
		RETURN 1;
	END
	
	RETURN 0;
END
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisLanguageStrings_GetValue]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisLanguageStrings_GetValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisLanguageStrings_GetValue] 
(
	@LANG_ID tinyint,
	@LS_FrontBack char(1),
	@LS_Name nvarchar(MAX),
	@LS_ClassName as nvarchar(50)
)
RETURNS nvarchar(MAX)
AS
BEGIN
	DECLARE @Result nvarchar(MAX)

	SELECT @Result = LS_Value
	FROM dbo.tblKartrisLanguageStrings
	WHERE LS_LangID = @LANG_ID AND LS_FrontBack = @LS_FrontBack 
			AND LS_Name = @LS_Name AND LS_ClassName = @LS_ClassName

	RETURN @Result

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisObjectConfig_GetValue]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisObjectConfig_GetValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisObjectConfig_GetValue]
(
	@ConfigName as nvarchar(100),
	@ParentID as bigint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Count as int;
	
	SELECT     @Count = Count(1)
	FROM         tblKartrisObjectConfigValue INNER JOIN
						  tblKartrisObjectConfig ON tblKartrisObjectConfigValue.OCV_ObjectConfigID = tblKartrisObjectConfig.OC_ID
	WHERE     (tblKartrisObjectConfig.OC_Name = @ConfigName) AND (tblKartrisObjectConfigValue.OCV_ParentID = @ParentID)
	
	IF @Count = 1 BEGIN
		SELECT  tblKartrisObjectConfigValue.OCV_Value
		FROM    tblKartrisObjectConfigValue INNER JOIN
				tblKartrisObjectConfig ON tblKartrisObjectConfigValue.OCV_ObjectConfigID = tblKartrisObjectConfig.OC_ID
		WHERE   (tblKartrisObjectConfig.OC_Name = @ConfigName) AND (tblKartrisObjectConfigValue.OCV_ParentID = @ParentID)
	END ELSE BEGIN
		SELECT OC_DefaultValue FROM tblKartrisObjectConfig WHERE tblKartrisObjectConfig.OC_Name = @ConfigName
	END
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisMediaLinks_GetByParent]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisMediaLinks_GetByParent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get Media Links of a product or version
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisMediaLinks_GetByParent]
(
	@ParentID as bigint, 
	@ParentType as nvarchar(1)
)
AS
BEGIN
SET NOCOUNT ON;
SELECT     tblKartrisMediaLinks.ML_ID, tblKartrisMediaLinks.ML_ParentID, tblKartrisMediaLinks.ML_ParentType, tblKartrisMediaLinks.ML_EmbedSource, 
					  tblKartrisMediaLinks.ML_MediaTypeID, tblKartrisMediaLinks.ML_Height, tblKartrisMediaLinks.ML_Width, 
					  tblKartrisMediaLinks.ML_isDownloadable, tblKartrisMediaLinks.ML_Parameters, tblKartrisMediaTypes.MT_DefaultHeight, 
					  tblKartrisMediaTypes.MT_DefaultWidth, tblKartrisMediaTypes.MT_DefaultParameters, tblKartrisMediaTypes.MT_DefaultisDownloadable, 
					  tblKartrisMediaTypes.MT_Extension,tblKartrisMediaTypes.MT_Embed, tblKartrisMediaTypes.MT_Inline, tblKartrisMediaLinks.ML_Live
FROM         tblKartrisMediaLinks LEFT OUTER JOIN
					  tblKartrisMediaTypes ON tblKartrisMediaLinks.ML_MediaTypeID = tblKartrisMediaTypes.MT_ID
WHERE     (tblKartrisMediaLinks.ML_ParentID = @ParentID) AND (tblKartrisMediaLinks.ML_ParentType = @ParentType) AND (tblKartrisMediaLinks.ML_Live = 1)
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisLogins_GetSupportTicketsList]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisLogins_GetSupportTicketsList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisLogins_GetSupportTicketsList]
AS
SET NOCOUNT OFF;
SELECT     LOGIN_ID, LOGIN_Username, LOGIN_EmailAddress
FROM         tblKartrisLogins
WHERE     (LOGIN_Tickets = 1 AND LOGIN_Live = 1)



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisLanguageStrings_GetByVirtualPath]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisLanguageStrings_GetByVirtualPath]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisLanguageStrings_GetByVirtualPath](@LanguageID as tinyint, @VirtualPath as nvarchar(50))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	 
	SELECT LS_ID, LS_Name, LS_Value, LS_Description, LS_LANGID
	FROM tblKartrisLanguageStrings
	WHERE LS_LANGID = @LanguageID AND LS_VirtualPath = @VirtualPath
		

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisLanguageStrings_GetByLanguageID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisLanguageStrings_GetByLanguageID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisLanguageStrings_GetByLanguageID](@LanguageID as tinyint)
AS
	SET NOCOUNT ON;
SELECT * FROM tblKartrisLanguageStrings WHERE LS_LANGID = @LanguageID


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisLanguageStrings_GetByClassName]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisLanguageStrings_GetByClassName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisLanguageStrings_GetByClassName](@LanguageID as tinyint, @ClassName as nvarchar(50))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	 
	SELECT LS_ID, LS_Name, LS_Value, LS_Description, LS_LANGID
	FROM tblKartrisLanguageStrings
	WHERE LS_LANGID = @LanguageID AND LS_ClassName = @ClassName
		

END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisLanguages_GetLanguageIDByCulture_s]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisLanguages_GetLanguageIDByCulture_s]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisLanguages_GetLanguageIDByCulture_s]
(
	@LANG_Culture nvarchar(50)
)
AS
	SET NOCOUNT ON;
SELECT LANG_ID FROM tblKartrisLanguages WHERE LANG_Culture = @LANG_Culture


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisLanguages_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisLanguages_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisLanguages_Get]
AS
	SET NOCOUNT ON;
SELECT * FROM tblKartrisLanguages 
WHERE LANG_LiveFront = 1

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisOrders_InvoiceRowsAdd]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisOrders_InvoiceRowsAdd]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisOrders_InvoiceRowsAdd]
(
		   @IR_OrderNumberID int,
		   @IR_VersionCode nvarchar(50),
		   @IR_VersionName nvarchar(1000),
		   @IR_Quantity float,
		   @IR_PricePerItem real,
		   @IR_TaxPerItem real,
		   @IR_OptionsText nvarchar(MAX)
)
AS
BEGIN
	DECLARE @IR_ID INT
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

Disable Trigger trigKartrisInvoiceRows_DML ON tblKartrisInvoiceRows;	

	INSERT INTO [tblKartrisInvoiceRows]
		   ([IR_OrderNumberID]
		   ,[IR_VersionCode]
		   ,[IR_VersionName]
		   ,[IR_Quantity]
		   ,[IR_PricePerItem]
		   ,[IR_TaxPerItem]
		   ,[IR_OptionsText])
	 VALUES
		   (@IR_OrderNumberID,
		   @IR_VersionCode,
		   @IR_VersionName,
		   @IR_Quantity,
		   @IR_PricePerItem,
		   @IR_TaxPerItem,
		   @IR_OptionsText);
	SET @IR_ID = SCOPE_IDENTITY();
	SELECT @IR_ID;

Enable Trigger trigKartrisInvoiceRows_DML ON tblKartrisInvoiceRows;	
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisOrders_GetQBQueue]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisOrders_GetQBQueue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisOrders_GetQBQueue]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT   distinct tblKartrisOrders.O_ID,tblKartrisUsers.U_QBListID, tblKartrisOrders.O_CustomerID,tblKartrisUsers.U_EmailAddress,
			tblKartrisOrders.O_BillingAddress,tblKartrisOrders.O_ShippingAddress
FROM         tblKartrisAddresses LEFT OUTER JOIN
					  tblKartrisUsers ON tblKartrisAddresses.ADR_UserID = tblKartrisUsers.U_ID RIGHT OUTER JOIN
					  tblKartrisOrders ON tblKartrisUsers.U_ID = tblKartrisOrders.O_CustomerID
WHERE     (tblKartrisOrders.O_Sent = 1) AND (tblKartrisOrders.O_Paid = 1) AND (tblKartrisOrders.O_SentToQB = 0 OR tblKartrisOrders.O_SentToQB IS NULL )
ORDER BY tblKartrisOrders.O_ID DESC;
END




' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisOrders_GetCardTypeList]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisOrders_GetCardTypeList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisOrders_GetCardTypeList]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT CR_NAME FROM tblKartrisCreditCards WHERE CR_ACCEPTED = 1;
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisOrders_GetByStatus_OtherMethod]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisOrders_GetByStatus_OtherMethod]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisOrders_GetByStatus_OtherMethod]
(
	@O_Sent bit = NULL,
	@O_Invoiced bit = NULL,
	@O_Paid bit = NULL,
	@O_Shipped bit = NULL,
	@O_AffiliatePaymentID int = NULL,
	@O_DateRangeStart smalldatetime = NULL,
	@O_DateRangeEnd smalldatetime = NULL
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     tblKartrisOrders.O_ID, tblKartrisOrders.O_Date, tblKartrisOrders.O_TotalPrice, tblKartrisAddresses.ADR_Name, tblKartrisOrders.O_CustomerID
FROM         tblKartrisAddresses LEFT OUTER JOIN
					  tblKartrisUsers ON tblKartrisAddresses.ADR_UserID = tblKartrisUsers.U_ID RIGHT OUTER JOIN
					  tblKartrisOrders ON tblKartrisUsers.U_ID = tblKartrisOrders.O_CustomerID
WHERE     (tblKartrisOrders.O_Sent = COALESCE (@O_Sent, tblKartrisOrders.O_Sent)) AND (tblKartrisOrders.O_Invoiced = COALESCE (@O_Invoiced, 
					  tblKartrisOrders.O_Invoiced)) AND (tblKartrisOrders.O_Paid = COALESCE (@O_Paid, tblKartrisOrders.O_Paid)) AND 
					  (tblKartrisOrders.O_Shipped = COALESCE (@O_Shipped, tblKartrisOrders.O_Shipped)) AND 
					  (tblKartrisOrders.O_AffiliatePaymentID = COALESCE (@O_AffiliatePaymentID, tblKartrisOrders.O_AffiliatePaymentID)) AND 
					  (tblKartrisOrders.O_Date >= COALESCE (@O_DateRangeStart, DATEADD(day, - 1, tblKartrisOrders.O_Date))) AND 
					  (tblKartrisOrders.O_Date <= COALESCE (@O_DateRangeEnd, @O_DateRangeStart, DATEADD(day, 1, tblKartrisOrders.O_Date)))
ORDER BY tblKartrisOrders.O_ID DESC;
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisOrders_GetAffiliateCommission]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisOrders_GetAffiliateCommission]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: 08/April/2009
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisOrders_GetAffiliateCommission] (
	
	@AffiliateID int
) AS
BEGIN
	SET NOCOUNT ON;
	SELECT U_AffiliateCommission FROM tblKartrisUsers WHERE U_ID = @AffiliateID
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisOrders_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisOrders_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisOrders_Get]
(
		   @O_ID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * FROM tblKartrisOrders WHERE O_ID = @O_ID;
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisOrders_DataUpdate]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisOrders_DataUpdate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [dbo].[spKartrisOrders_DataUpdate]
(
	@O_ID int,
	@O_Data nvarchar(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	Disable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	
	
	UPDATE [tblKartrisOrders] SET [O_Data] = @O_Data
		WHERE [O_ID] = @O_ID;
	
	Enable Trigger trigKartrisOrders_DML ON tblKartrisOrders;		

	SELECT @O_ID;
END	




' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisOrders_CouponUsed]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisOrders_CouponUsed]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisOrders_CouponUsed]
(
	@CouponCode as nvarchar(25)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Disable Trigger trigKartrisCoupons_DML ON tblKartrisCoupons;
	UPDATE dbo.tblKartrisCoupons
	SET CP_Used = 1
	WHERE CP_CouponCode = @CouponCode;
Enable Trigger trigKartrisCoupons_DML ON tblKartrisCoupons;	
	SELECT @CouponCode;

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCustomer_UpdateMailingList]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCustomer_UpdateMailingList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 17/Aug/08
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisCustomer_UpdateMailingList] (
	@EmailAddress nvarchar (100),
	@SignupDateTime datetime,
	@SignupIP nvarchar(20),
	@SignupRandomKey nvarchar(100),
	@MailFormat nvarchar(5),
	@LanguageID tinyint
) AS
BEGIN
	SET NOCOUNT ON;

Disable Trigger trigKartrisUsers_DML ON tblKartrisUsers;
	if exists(select U_EmailAddress from tblKartrisUsers where U_EmailAddress=@EmailAddress)
	Begin
		update tblKartrisUsers
			set U_ML_SignupDateTime = @SignupDateTime,
			U_ML_SignupIP = @SignupIP,
			U_ML_RandomKey = @SignupRandomKey,
			U_ML_Format = @MailFormat,
			U_LanguageID = @LanguageID
		where U_EmailAddress = @EmailAddress
	End
	Else
	Begin
		insert into tblKartrisUsers (U_EmailAddress, U_Password, U_ML_SignupDateTime, U_ML_SignupIP, U_ML_RandomKey, U_ML_Format, U_LanguageID)
		values (@EmailAddress,@SignupRandomKey,@SignupDateTime,@SignupIP,@SignupRandomKey,@MailFormat,@LanguageID);
	End;
Enable Trigger trigKartrisUsers_DML ON tblKartrisUsers;

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCustomer_UpdateMailFormat]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCustomer_UpdateMailFormat]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 30/July/08
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisCustomer_UpdateMailFormat] (
	@LanguageID int,
	@UserID int,
	@MailFormat nvarchar(1)
) AS
BEGIN
	SET NOCOUNT ON;

Disable Trigger trigKartrisUsers_DML ON tblKartrisUsers;

	If @MailFormat=''n''
	Begin
		update tblKartrisUsers set U_ML_SendMail=0, U_LanguageID=@LanguageID
		where U_ID=@UserID
	End

	If @MailFormat=''t''
	Begin
		update tblKartrisUsers set U_ML_SendMail=1, U_ML_Format=''t'', U_LanguageID=@LanguageID
		where U_ID=@UserID
	End

	If @MailFormat=''h''
	Begin
		update tblKartrisUsers set U_ML_SendMail=1, U_ML_Format=''h'', U_LanguageID=@LanguageID
		where U_ID=@UserID
	End;
Enable Trigger trigKartrisUsers_DML ON tblKartrisUsers;

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCustomer_UpdateAffiliate]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCustomer_UpdateAffiliate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 16/July/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisCustomer_UpdateAffiliate]( 
	@Type as smallint,
	@UserID as integer,
	@AffiliateCommission float=0,
	@AffiliateID int=0
) AS
BEGIN
	SET NOCOUNT ON;

Disable Trigger trigKartrisUsers_DML ON tblKartrisUsers;
	If @Type=1 -- affiliate status
	Begin
		update tblKartrisUsers set U_IsAffiliate=1 where U_ID=@UserID
	End;

	If @Type=2 -- affiliate commission
	Begin
		update tblKartrisUsers set U_AffiliateCommission=@AffiliateCommission where U_ID=@UserID
	End;

	If @Type=3 -- affiliate affliate id
	Begin
		update tblKartrisUsers set U_AffiliateID = @AffiliateID 
			where U_ID=@UserID and (isnull(U_AffiliateID,0)=0 or U_AffiliateID=@AffiliateID)
	End;

Enable Trigger trigKartrisUsers_DML ON tblKartrisUsers;



END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisOrders_Add]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisOrders_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisOrders_Add]
(
		   @O_CustomerID int,
		   @O_Details nvarchar(MAX),
		   @O_ShippingPrice real,
		   @O_ShippingTax real,
		   @O_DiscountPercentage real,
		   @O_AffiliatePercentage real,
		   @O_TotalPrice real,
		   @O_Date smalldatetime,
		   @O_PurchaseOrderNo nvarchar(50),
		   @O_SecurityID int,
		   @O_Sent bit,
		   @O_Invoiced bit,
		   @O_Shipped bit,
		   @O_Paid bit,
		   @O_Status nvarchar(MAX),
		   @O_LastModified smalldatetime,
		   @O_WishListID int,
		   @O_CouponCode nvarchar(25),
		   @O_CouponDiscountTotal real,
		   @O_PricesIncTax bit,
		   @O_TaxDue real,
		   @O_PaymentGateWay nvarchar(20),
		   @O_ReferenceCode nvarchar(100),
		   @O_LanguageID tinyint,
		   @O_CurrencyID tinyint,
		   @O_TotalPriceGateway real,
		   @O_CurrencyIDGateway tinyint,
		   @O_AffiliatePaymentID int,
		   @O_AffiliateTotalPrice real,
		   @O_SendOrderUpdateEmail bit,
		   @O_OrderHandlingCharge real,
		   @O_OrderHandlingChargeTax real,
		   @O_CurrencyRate real,
		   @O_ShippingMethod nvarchar(255),
		   @O_BillingAddress nvarchar(255),
		   @O_ShippingAddress nvarchar(255),
		   @O_PromotionDiscountTotal real,
		   @O_PromotionDescription nvarchar(255),
		   @O_Comments nvarchar(MAX)
)
AS
BEGIN
	DECLARE @O_ID INT
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

Disable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	
	INSERT INTO [tblKartrisOrders]
		   ([O_CustomerID]
		   ,[O_Details]
		   ,[O_ShippingPrice]
		   ,[O_ShippingTax]
		   ,[O_DiscountPercentage]
		   ,[O_AffiliatePercentage]
		   ,[O_TotalPrice]
		   ,[O_Date]
		   ,[O_PurchaseOrderNo]
		   ,[O_SecurityID]
		   ,[O_Sent]
		   ,[O_Invoiced]
		   ,[O_Shipped]
		   ,[O_Paid]
		   ,[O_Status]
		   ,[O_LastModified]
		   ,[O_WishListID]
		   ,[O_CouponCode]
		   ,[O_CouponDiscountTotal]
		   ,[O_PricesIncTax]
		   ,[O_TaxDue]
		   ,[O_PaymentGateWay]
		   ,[O_ReferenceCode]
		   ,[O_LanguageID]
		   ,[O_CurrencyID]
		   ,[O_TotalPriceGateway]
		   ,[O_CurrencyIDGateway]
		   ,[O_AffiliatePaymentID]
		   ,[O_AffiliateTotalPrice]
		   ,[O_SendOrderUpdateEmail]
		   ,[O_OrderHandlingCharge]
		   ,[O_OrderHandlingChargeTax]
		   ,[O_CurrencyRate]
		   ,[O_ShippingMethod]
		   ,[O_BillingAddress]
		   ,[O_ShippingAddress]
		   ,[O_PromotionDiscountTotal]
		   ,[O_PromotionDescription]
		   ,[O_Comments])
	 VALUES
		   (@O_CustomerID,
		   @O_Details,
		   @O_ShippingPrice,
		   @O_ShippingTax,
		   @O_DiscountPercentage,
		   @O_AffiliatePercentage,
		   @O_TotalPrice,
		   @O_Date,
		   @O_PurchaseOrderNo,
		   @O_SecurityID,
		   @O_Sent,
		   @O_Invoiced,
		   @O_Shipped,
		   @O_Paid,
		   @O_Status,
		   @O_LastModified,
		   @O_WishListID,
		   @O_CouponCode,
		   @O_CouponDiscountTotal,
		   @O_PricesIncTax,
		   @O_TaxDue,
		   @O_PaymentGateWay,
		   @O_ReferenceCode,
		   @O_LanguageID,
		   @O_CurrencyID,
		   @O_TotalPriceGateway,
		   @O_CurrencyIDGateway,
		   @O_AffiliatePaymentID,
		   @O_AffiliateTotalPrice,
		   @O_SendOrderUpdateEmail,
		   @O_OrderHandlingCharge,
		   @O_OrderHandlingChargeTax,
		   @O_CurrencyRate,
		   @O_ShippingMethod,
		   @O_BillingAddress,
		   @O_ShippingAddress,
		   @O_PromotionDiscountTotal,
		   @O_PromotionDescription,
		   @O_Comments)

	SET @O_ID = SCOPE_IDENTITY();
	SELECT @O_ID;
Enable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	
END




' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisOrderPaymentsLink_Add]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisOrderPaymentsLink_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisOrderPaymentsLink_Add]
(
		   @OP_PaymentID int,
		   @OP_OrderID int
)
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

Disable Trigger trigKartrisOrderPaymentLink_DML ON tblKartrisOrderPaymentLink;	
	INSERT INTO [tblKartrisOrderPaymentLink]
		   ([OP_PaymentID]
		   ,[OP_OrderID]
		   ,[OP_OrderCanceled])
	 VALUES
		   (@OP_PaymentID,@OP_OrderID,0)

	SELECT @OP_PaymentID;
Enable Trigger trigKartrisOrderPaymentLink_DML ON tblKartrisOrderPaymentLink;	
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisOrders_UpdateQBSent]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisOrders_UpdateQBSent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisOrders_UpdateQBSent]
(
	@O_ID int
)
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;
Disable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	
	UPDATE tblKartrisOrders SET O_SentToQB = 1
		WHERE O_ID = @O_ID;
	Select @O_ID;
Enable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	





' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisPayments_Add]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisPayments_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisPayments_Add]
(
		   @Payment_CustomerID int,
		   @Payment_Date smalldatetime,
		   @Payment_Amount real,
		   @Payment_CurrencyID tinyint,
		   @Payment_ReferenceNo nvarchar(100),
		   @Payment_GateWay nvarchar(20),
		   @Payment_CurrencyRate real
)
AS
BEGIN
	DECLARE @Payment_ID INT
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

Disable Trigger trigKartrisPayments_DML ON tblKartrisPayments;	
	INSERT INTO [tblKartrisPayments]
		   ([Payment_CustomerID]
		   ,[Payment_Date]
		   ,[Payment_Amount]
		   ,[Payment_CurrencyID]
		   ,[Payment_ReferenceNo]
		   ,[Payment_Gateway]
		   ,[Payment_CurrencyRate]
		   )
	 VALUES
		   (@Payment_CustomerID,
		   @Payment_Date,
		   @Payment_Amount,
		   @Payment_CurrencyID,
		   @Payment_ReferenceNo,
		   @Payment_GateWay,
		   @Payment_CurrencyRate)

	SET @Payment_ID = SCOPE_IDENTITY();
	SELECT @Payment_ID;
Enable Trigger trigKartrisPayments_DML ON tblKartrisPayments;	
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisPromotions_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisPromotions_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisPromotions_Get]
AS
	SET NOCOUNT ON;
	SELECT        tblKartrisPromotions.*
	FROM            tblKartrisPromotions 
	WHERE		PROM_Live = 1
	ORDER BY PROM_Live, PROM_ID DESC

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSessions_Add]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSessions_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author: Joseph
-- Create date: 17/Feb/08
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisSessions_Add]
(
	@SESS_Code nvarchar(20),
	@SESS_IP nvarchar(16),
	@SESS_DateCreated datetime,
	@SESS_DateLastUpdated datetime,
	@SESS_Expiry int
)
AS

	DECLARE @intSESS_ID INT

	SET NOCOUNT OFF;

--Disable Trigger trigKartrisSessions_DML ON tblKartrisSessions;	
	INSERT INTO [tblKartrisSessions] ([SESS_Code], [SESS_IP], [SESS_DateCreated], [SESS_DateLastUpdated], [SESS_Expiry]) 
	VALUES (@SESS_Code, @SESS_IP, @SESS_DateCreated, @SESS_DateLastUpdated, @SESS_Expiry);
--Enable Trigger trigKartrisSessions_DML ON tblKartrisSessions;	

--SELECT SCOPE_IDENTITY()''SESS_ID''

	SET @intSESS_ID = SCOPE_IDENTITY();

--Disable Trigger trigKartrisSessions_DML ON tblKartrisSessions;	
	UPDATE [tblKartrisSessions] SET SESS_Code=SESS_Code + cast(@intSESS_ID as varchar(10))
	WHERE SESS_Code=@SESS_Code;
--Enable Trigger trigKartrisSessions_DML ON tblKartrisSessions;	

	SELECT @intSESS_ID ''SESS_ID'';


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSearchStatistics_ReportSearch]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSearchStatistics_ReportSearch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisSearchStatistics_ReportSearch]
(	
	@KeyWordsList as nvarchar(500),
	@CurrentYear as smallint,
	@CurrentMonth as tinyint,
	@CurrentDay as tinyint,
	@CurrentDate as datetime
)
AS
BEGIN
SET NOCOUNT ON;
	
	SET NOCOUNT ON;
	DISABLE TRIGGER [dbo].[trigKartrisSearchStatistics_DML] ON [dbo].[tblKartrisSearchStatistics]
	-----------------------
	-- Variable Declaration
	-----------------------
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @Keyword as nvarchar(150);
	DECLARE @Counter as int;
	
	SET @SIndx = 0;
	SET @Counter = 0;
	WHILE @SIndx <= LEN(@KeyWordsList)
	BEGIN
		
		-- Loop through out the keyword''''s list
		SET @Counter = @Counter + 1;	-- keywords counter
		SET @CIndx = CHARINDEX('','', @KeyWordsList, @SIndx)	-- Next keyword starting index (1-Based Index)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@KeyWordsList)+ 1 END	-- If no more keywords, set next starting index to not exist
		SET @KeyWord = SUBSTRING(@KeyWordsList, @SIndx, @CIndx - @SIndx)
		
		SET @SIndx = @CIndx + 1;	-- The next starting index
			
		UPDATE dbo.tblKartrisSearchStatistics
		SET SS_Searches = SS_Searches + 1
		WHERE SS_Keyword = @KeyWord AND SS_Year = @CurrentYear 
			AND SS_Month = @CurrentMonth AND SS_Day = @CurrentDay;

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO dbo.tblKartrisSearchStatistics
			VALUES(@KeyWord, @CurrentDate, @CurrentYear, @CurrentMonth, @CurrentDay, 1);
		END
				
	END;
	ENABLE TRIGGER [dbo].[trigKartrisSearchStatistics_DML] ON [dbo].[tblKartrisSearchStatistics]
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSessions_GetSessionID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSessions_GetSessionID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:	Joseph	
-- Create date: 17/Feb/08
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisSessions_GetSessionID](
	@SESS_Code varchar(255)
)
AS
	
SET NOCOUNT ON;

SELECT SESS_ID FROM tblKartrisSessions 
WHERE SESS_Code = @SESS_Code 

SET NOCOUNT OFF

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSessions_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSessions_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisSessions_Get]
AS
	
SET NOCOUNT ON;

SELECT * from tblKartrisSessions

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSessions_UpdateDate]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSessions_UpdateDate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisSessions_UpdateDate]
(
	@SESS_DateLastUpdated datetime,
	@SESS_ID bigint
)
AS

SET NOCOUNT OFF;
--Disable Trigger trigKartrisSessions_DML ON tblKartrisSessions;	
	UPDATE tblKartrisSessions 
	SET SESS_DateLastUpdated=@SESS_DateLastUpdated
	WHERE SESS_ID = @SESS_ID;
--Enable Trigger trigKartrisSessions_DML ON tblKartrisSessions;	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisWishLists_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisWishLists_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Joseph
-- Create date: 13/May/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisWishLists_Get] (
	@WL_ID bigint=0,
	@UserID bigint=0
) AS
BEGIN
	SET NOCOUNT ON;

	If @WL_ID=0
	Begin
		select distinct WL.* from tblKartrisWishLists WL
		--inner join tblKartrisBasketValues BV on WL.WL_ID=BV.BV_ParentID and BV.BV_ParentType=''w''
		where WL_UserID=@UserID 
		order by WL_ID desc
	End
	Else
	Begin
		select isnull(U.U_AccountHolderName,'''')''U_AccountHolderName'', U_EmailAddress,WL.* from tblKartrisWishLists WL
		left join tblKartrisUsers U on WL.WL_UserID=U.U_ID
		where WL_ID=@WL_ID
	End

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisStatistics_Add]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisStatistics_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisStatistics_Add]
(
	@Type as char(1),
	@ParentID as bigint,
	@ItemID as bigint,
	@IP as nvarchar(50),
	@NowOffset as datetime
)
AS
BEGIN
Disable Trigger trigKartrisStatistics_DML ON tblKartrisStatistics;	
	INSERT INTO dbo.tblKartrisStatistics
	VALUES (@Type, @ParentID, @ItemID, @NowOffset, @IP);
Enable Trigger trigKartrisStatistics_DML ON tblKartrisStatistics;	
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSupportTickets_AddCustomerReply]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSupportTickets_AddCustomerReply]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisSupportTickets_AddCustomerReply]
(
	@TIC_ID as bigint,
	@NowOffset as datetime,
	@STM_Text as nvarchar(MAX),
	@STM_NewID as bigint OUTPUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DISABLE TRIGGER trigKartrisSupportTicketMessages_DML ON tblKartrisSupportTicketMessages;
	INSERT INTO dbo.tblKartrisSupportTicketMessages
	VALUES	(@TIC_ID, 0, @NowOffset, @STM_Text);
ENABLE TRIGGER trigKartrisSupportTicketMessages_DML ON tblKartrisSupportTicketMessages;
	
	SELECT @STM_NewID = SCOPE_IDENTITY();
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSupportTickets_Add]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSupportTickets_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisSupportTickets_Add]
(
	@OpenedDate as datetime,
	@TicketType as int,
	@Subject as nvarchar(100),
	@Text as nvarchar(MAX),
	@U_ID as int,
	@TIC_NewID as bigint OUTPUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DISABLE TRIGGER trigKartrisSupportTickets_DML ON tblKartrisSupportTickets;
	INSERT INTO dbo.tblKartrisSupportTickets
	VALUES (@OpenedDate, NULL, @Subject, @U_ID, 0, @TicketType, ''o'',0);
ENABLE TRIGGER trigKartrisSupportTickets_DML ON tblKartrisSupportTickets;

	SELECT @TIC_NewID  = SCOPE_IDENTITY();
	
	IF @TIC_NewID IS NOT NULL
	BEGIN
	DISABLE TRIGGER trigKartrisSupportTicketMessages_DML ON tblKartrisSupportTicketMessages;
		INSERT INTO dbo.tblKartrisSupportTicketMessages
		VALUES	(@TIC_NewID, 0, @OpenedDate, @Text);
	ENABLE TRIGGER trigKartrisSupportTicketMessages_DML ON tblKartrisSupportTicketMessages;
	END
	
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSupportTicketMessages_GetLastByOwner]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSupportTicketMessages_GetLastByOwner]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisSupportTicketMessages_GetLastByOwner]
(
	@TIC_ID as bigint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT   top(1) tblKartrisSupportTicketMessages.STM_TicketID, tblKartrisSupportTicketMessages.STM_ID, tblKartrisSupportTicketMessages.STM_LoginID AS AssignedID, 
					  tblKartrisLogins.LOGIN_Username AS AssignedName, tblKartrisSupportTicketMessages.STM_DateCreated, tblKartrisSupportTicketMessages.STM_Text
	FROM         tblKartrisLogins RIGHT OUTER JOIN
						  tblKartrisSupportTicketMessages ON tblKartrisLogins.LOGIN_ID = tblKartrisSupportTicketMessages.STM_LoginID
	WHERE     (tblKartrisSupportTicketMessages.STM_TicketID = @TIC_ID AND tblKartrisSupportTicketMessages.STM_LoginID > 0) order by tblKartrisSupportTicketMessages.STM_ID DESC
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisUsers_Validate]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisUsers_Validate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisUsers_Validate]
(
	@EmailAddress varchar(100),
	@Password varchar(64)
)
AS
SET NOCOUNT OFF;
SELECT        TOP 1 U_ID
FROM            tblKartrisUsers
WHERE        (U_EmailAddress = @EmailAddress AND U_Password = @Password )

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisUsers_UpdateQBListID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisUsers_UpdateQBListID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisUsers_UpdateQBListID]
(
		@U_ID int,
		@U_QBListID nvarchar(50)
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisUsers_DML ON tblKartrisUsers;

	UPDATE [tblKartrisUsers] SET 
			[U_QBListID] = @U_QBListID
			WHERE U_ID = @U_ID ;
	SELECT @U_ID;
Enable Trigger trigKartrisUsers_DML ON tblKartrisUsers;



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisUsers_UpdateNameAndEUVAT]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisUsers_UpdateNameAndEUVAT]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisUsers_UpdateNameAndEUVAT]
(
		@U_ID int,
		@U_AccountHolderName nvarchar(50),
		@U_CardholderEUVATNum nvarchar(15)
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisUsers_DML ON tblKartrisUsers;

	UPDATE [tblKartrisUsers] SET 
			[U_AccountHolderName] = @U_AccountHolderName,
			[U_CardholderEUVATNum] = @U_CardholderEUVATNum
			WHERE U_ID = @U_ID ;
	SELECT @U_ID;
Enable Trigger trigKartrisUsers_DML ON tblKartrisUsers;


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisUsers_UpdateCustomerBalance]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisUsers_UpdateCustomerBalance]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisUsers_UpdateCustomerBalance]
(
		   @CustomerID int,
		   @U_CustomerBalance real
)
AS
	SET NOCOUNT OFF;

Disable Trigger trigKartrisUsers_DML ON tblKartrisUsers;	
	UPDATE [tblKartrisUsers] SET
			[U_CustomerBalance] = @U_CustomerBalance
			WHERE U_ID = @CustomerID;
	SELECT @CustomerID;
Enable Trigger trigKartrisUsers_DML ON tblKartrisUsers;	' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisUsers_ResetPassword]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisUsers_ResetPassword]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisUsers_ResetPassword]
(
		   @U_ID int,
		   @U_NewPassword nvarchar(64),
		   @U_TempPasswordExpiry as datetime
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisUsers_DML ON tblKartrisUsers;
	UPDATE [tblKartrisUsers] SET 
			[U_TempPassword] = @U_NewPassword,
			[U_TempPasswordExpiry] = @U_TempPasswordExpiry
			WHERE U_ID = @U_ID;
	SELECT @U_ID;
Enable Trigger trigKartrisUsers_DML ON tblKartrisUsers;

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisUsers_GetNameAndEUVAT]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisUsers_GetNameAndEUVAT]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisUsers_GetNameAndEUVAT]
(
		@U_ID int
)
AS
	SET NOCOUNT OFF;
SELECT TOP 1 (ISNULL(U_AccountHolderName,'''') + ''|||'' +
				ISNULL(U_CardholderEUVATNum,'''')) as NameAndEUVAT
FROM            tblKartrisUsers
WHERE        (U_ID = @U_ID)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisUsers_GetEmailByID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisUsers_GetEmailByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisUsers_GetEmailByID]
(
	@U_ID int
)
AS
SET NOCOUNT OFF;
SELECT        TOP 1 
			U_EmailAddress
FROM            tblKartrisUsers
WHERE        (U_ID = @U_ID)


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisUsers_GetDetails]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisUsers_GetDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisUsers_GetDetails]
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
WHERE        (U_EmailAddress = @EmailAddress)


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisUsers_GetAddressByID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisUsers_GetAddressByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get all user stored addresses
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisUsers_GetAddressByID]
(
	@U_ID int
)
AS
SET NOCOUNT OFF;
SELECT        *
FROM            tblKartrisAddresses
WHERE        (ADR_UserID = @U_ID)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisUsers_DeleteAddress]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisUsers_DeleteAddress]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisUsers_DeleteAddress]
(
		   @ADR_ID int,@ADR_UserID int
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisAddresses_DML ON tblKartrisAddresses;
	DELETE FROM [tblKartrisAddresses]
		   WHERE [ADR_ID] = @ADR_ID AND ADR_UserID = @ADR_UserID;
Enable Trigger trigKartrisAddresses_DML ON tblKartrisAddresses;

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisUsers_ChangePasswordfromRecovery]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisUsers_ChangePasswordfromRecovery]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisUsers_ChangePasswordfromRecovery]
(
		   @U_ID int,
			@U_NewPassword nvarchar(64)
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisUsers_DML ON tblKartrisUsers;
	UPDATE [tblKartrisUsers] SET 
			[U_Password] = @U_NewPassword,
			[U_TempPassword] = ''''
			WHERE U_ID = @U_ID;
	SELECT @U_ID;
Enable Trigger trigKartrisUsers_DML ON tblKartrisUsers;

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisUsers_ChangePassword]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisUsers_ChangePassword]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisUsers_ChangePassword]
(
		@U_ID int,
		@U_Password nvarchar(64),
		@U_NewPassword nvarchar(64)
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisUsers_DML ON tblKartrisUsers;

	UPDATE [tblKartrisUsers] SET 
			[U_Password] = @U_NewPassword,
			[U_TempPassword] = ''''
			WHERE U_ID = @U_ID AND U_Password = @U_Password;
			
	SELECT @U_ID;
Enable Trigger trigKartrisUsers_DML ON tblKartrisUsers;

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisUsers_AddUpdateAddress]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisUsers_AddUpdateAddress]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisUsers_AddUpdateAddress]
(
		   @ADR_UserID int,
		   @ADR_Label nvarchar(50),
		   @ADR_Name nvarchar(50),
		   @ADR_Company nvarchar(100),
		   @ADR_StreetAddress nvarchar(50),
		   @ADR_TownCity nvarchar(50),
		   @ADR_County nvarchar(50),
		   @ADR_PostCode nvarchar(20),
		   @ADR_Country int,
		   @ADR_Telephone nvarchar(50),
		   @ADR_Type nvarchar(1),
		   @ADR_MakeDefault bit,
		   @ADR_ID int
)
AS
	SET NOCOUNT OFF;

Disable Trigger trigKartrisAddresses_DML ON tblKartrisAddresses;	

	BEGIN TRANSACTION
	IF @ADR_ID = 0
		BEGIN
			INSERT INTO [tblKartrisAddresses]
					   ([ADR_UserID]
					   ,[ADR_Label]
					   ,[ADR_Name]
					   ,[ADR_Company]
					   ,[ADR_StreetAddress]
					   ,[ADR_TownCity]
					   ,[ADR_County]
					   ,[ADR_PostCode]
					   ,[ADR_Country]
					   ,[ADR_Telephone]
					   ,[ADR_Type])
				 VALUES
					   (@ADR_UserID, @ADR_Label, @ADR_Name, @ADR_Company,
					   @ADR_StreetAddress, @ADR_TownCity, @ADR_County,
					   @ADR_PostCode, @ADR_Country, @ADR_Telephone, @ADR_Type);

			SET @ADR_ID = SCOPE_IDENTITY();
		END
	ELSE
		BEGIN
			UPDATE [tblKartrisAddresses] SET
					   
					   [ADR_Label] = @ADR_Label
					   ,[ADR_Name] = @ADR_Name
					   ,[ADR_Company] = @ADR_Company
					   ,[ADR_StreetAddress] = @ADR_StreetAddress
					   ,[ADR_TownCity] = @ADR_TownCity
					   ,[ADR_County] = @ADR_County
					   ,[ADR_PostCode] = @ADR_PostCode
					   ,[ADR_Country] = @ADR_Country
					   ,[ADR_Telephone] = @ADR_Telephone
					   ,[ADR_Type] = @ADR_Type
					WHERE [ADR_ID] = @ADR_ID AND [ADR_UserID] = @ADR_UserID;
		END;
Enable Trigger trigKartrisAddresses_DML ON tblKartrisAddresses;	

	IF @@ERROR <> 0
	 BEGIN
		-- Rollback the transaction
		ROLLBACK

		-- Raise an error and return
		RAISERROR (''Error in inserting record in Address Table.'', 16, 1)
		RETURN
	 END

	--If make default is set then modify Users table
	IF @ADR_MakeDefault = 1
	BEGIN
Disable Trigger trigKartrisUsers_DML ON tblKartrisUsers;
		IF @ADR_Type = ''b''
			BEGIN
				UPDATE [tblKartrisUsers] SET [U_DefBillingAddressID] = @ADR_ID WHERE [U_ID] = @ADR_UserID;
			END
		IF @ADR_Type = ''s''
			BEGIN
				UPDATE [tblKartrisUsers] SET [U_DefShippingAddressID] = @ADR_ID WHERE [U_ID] = @ADR_UserID;
			END
		IF @ADR_Type = ''u''
			BEGIN
				UPDATE [tblKartrisUsers] SET [U_DefBillingAddressID] = @ADR_ID, [U_DefShippingAddressID] = @ADR_ID WHERE [U_ID] = @ADR_UserID;
			END;
Enable Trigger trigKartrisUsers_DML ON tblKartrisUsers;
	END


	IF @@ERROR <> 0
	 BEGIN
		-- Rollback the transaction
		ROLLBACK

		-- Raise an error and return
		RAISERROR (''Error in updating the Users Default Address.'', 16, 1)
		RETURN
	 END

	--         Commit the transaction....
	COMMIT

	SELECT @ADR_ID;



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisUsers_Add_ML]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisUsers_Add_ML]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisUsers_Add_ML]
(
		   @U_EmailAddress nvarchar(100),
		   @U_Password nvarchar(64),
		   @U_IsAffiliate bit,
		   @U_LanguageID int,
		   @U_ML_SignupDateTime datetime,
		   @U_ML_SignupIP nvarchar(20),
		   @U_ML_RandomKey nvarchar(20),
		   @U_ML_Format nvarchar(1),
		   @U_ML_SendMail bit
)
AS
	DECLARE @U_ID INT
	SET NOCOUNT OFF;
Disable Trigger trigKartrisUsers_DML ON tblKartrisUsers;
	INSERT INTO [tblKartrisUsers]
		   ([U_EmailAddress]
		   ,[U_Password]
		   ,[U_IsAffiliate]
		   ,[U_LanguageID]
		   ,[U_ML_SignupDateTime]
		   ,[U_ML_SignupIP]
		   ,[U_ML_RandomKey]
		   ,[U_ML_Format]
		   ,[U_ML_SendMail])
	 VALUES
		   (@U_EmailAddress,
			@U_Password,
			@U_IsAffiliate,
			@U_LanguageID,
			@U_ML_SignupDateTime,
			@U_ML_SignupIP,
			@U_ML_RandomKey,
			@U_ML_Format,
			@U_ML_SendMail);
	SET @U_ID = SCOPE_IDENTITY();
	SELECT @U_ID;
Enable Trigger trigKartrisUsers_DML ON tblKartrisUsers;

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisUsers_Add]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisUsers_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisUsers_Add]
(
		   @U_EmailAddress nvarchar(100),
		   @U_Password nvarchar(64)
)
AS
DECLARE @U_ID INT
	SET NOCOUNT OFF;

Disable Trigger trigKartrisUsers_DML ON tblKartrisUsers;
	INSERT INTO [tblKartrisUsers]
		   ([U_EmailAddress]
		   ,[U_Password]
		   ,[U_LanguageID]
			,[U_CustomerGroupID]
			,[U_DefShippingAddressID]
			,[U_DefBillingAddressID]
			,[U_CustomerDiscount])
	 VALUES
		   (@U_EmailAddress,
			@U_Password,
			1,0,0,0,0);
	SET @U_ID = SCOPE_IDENTITY();
	SELECT @U_ID;

Enable Trigger trigKartrisUsers_DML ON tblKartrisUsers;

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisTaxRates_GetClosestRate]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisTaxRates_GetClosestRate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: 08/April/2010
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisTaxRates_GetClosestRate] ( 
	@computedTaxRate real
) AS
BEGIN
	SET NOCOUNT ON;
	select TOP 1 T_TaxRate from tblKartrisTaxRates ORDER BY ABS(T_TaxRate - @computedTaxRate), T_ID ASC
END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisTaxRates_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisTaxRates_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: 16/July/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisTaxRates_Get] ( 
	@T_ID tinyint
) AS
BEGIN
	SET NOCOUNT ON;
	select T_TaxRate from tblKartrisTaxRates
	where T_ID=@T_ID

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSupportTickets_GetDetailsByID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSupportTickets_GetDetailsByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Modified:	Medz (12/01/10) - to include U_ID parameter
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisSupportTickets_GetDetailsByID]
(
	@TIC_ID as bigint,
	@U_ID as int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     tblKartrisSupportTickets.TIC_ID, tblKartrisSupportTickets.TIC_DateOpened, tblKartrisSupportTickets.TIC_DateClosed, tblKartrisSupportTickets.TIC_Subject, 
					  tblKartrisSupportTickets.TIC_Status, tblKartrisSupportTicketMessages.STM_ID, tblKartrisSupportTicketMessages.STM_LoginID, 
					  tblKartrisSupportTicketMessages.STM_DateCreated, tblKartrisSupportTicketMessages.STM_Text, tblKartrisSupportTickets.TIC_LoginID AS AssignedID
FROM         tblKartrisSupportTickets INNER JOIN
					  tblKartrisSupportTicketMessages ON tblKartrisSupportTickets.TIC_ID = tblKartrisSupportTicketMessages.STM_TicketID
WHERE     (tblKartrisSupportTickets.TIC_ID = @TIC_ID) AND (tblKartrisSupportTickets.TIC_UserID = @U_ID)
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisUsers_AddAffiliatePayments]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisUsers_AddAffiliatePayments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 23/Apr/08
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisUsers_AddAffiliatePayments] ( 
	@AffiliateID int,
	@NowOffset datetime
) AS
BEGIN

	SET NOCOUNT ON;

	declare @AFP_ID int;

Disable Trigger trigKartrisAffiliatePayments_DML ON tblKartrisAffiliatePayments;	
	INSERT INTO tblKartrisAffiliatePayments (AFP_DateTime, AFP_AffiliateID) 
	VALUES (@NowOffset,@AffiliateID);
Enable Trigger trigKartrisAffiliatePayments_DML ON tblKartrisAffiliatePayments

	SET @AFP_ID=SCOPE_IDENTITY()

	select @AFP_ID AS AFP_ID

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisUsers_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisUsers_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisUsers_Add]
(
			@U_AccountHolderName nvarchar(50),
		   @U_EmailAddress nvarchar(100),
		   @U_Password nvarchar(64),
			@U_LanguageID tinyint,
			@U_CustomerGroupID tinyint,
			@U_CustomerDiscount real,
			@U_Approved bit,
			@U_IsAffiliate bit,
			@U_AffiliateCommission real,
			@U_SupportEndDate datetime,
			@U_Notes nvarchar(MAX)
)
AS
DECLARE @U_ID INT
	SET NOCOUNT OFF;

Disable Trigger trigKartrisUsers_DML ON tblKartrisUsers;	
	INSERT INTO [tblKartrisUsers]
		   ([U_AccountHolderName] ,[U_EmailAddress] ,[U_Password] ,[U_LanguageID] ,[U_CustomerGroupID]
			,[U_DefShippingAddressID]
			,[U_DefBillingAddressID]
			,[U_CustomerDiscount] ,[U_Approved] ,[U_IsAffiliate]
			,[U_AffiliateCommission]
			,[U_ML_Format]
			,[U_SupportEndDate]
			,[U_Notes]
			)
	 VALUES
		   (@U_AccountHolderName, @U_EmailAddress, @U_Password, @U_LanguageID, @U_CustomerGroupID,
			0,
			0,
			@U_CustomerDiscount, @U_Approved, @U_IsAffiliate,
			@U_AffiliateCommission,
			''t'',
			@U_SupportEndDate,
			@U_Notes);
	SET @U_ID = SCOPE_IDENTITY();
	SELECT @U_ID;
Enable Trigger trigKartrisUsers_DML ON tblKartrisUsers;	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisTaxRates_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisTaxRates_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[_spKartrisTaxRates_Update]
(
	@T_Taxrate real,
	@T_ID tinyint,
	@T_QBRefCode nvarchar(50)
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisTaxRates_DML ON tblKartrisTaxRates;	
	UPDATE [tblKartrisTaxRates] 
	SET [T_Taxrate] = @T_Taxrate, [T_QBRefCode] = @T_QBRefCode 
	WHERE (([T_ID] = @T_ID));
Enable Trigger trigKartrisTaxRates_DML ON tblKartrisTaxRates;	



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisTaxRates_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisTaxRates_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[_spKartrisTaxRates_Get]
AS
	SET NOCOUNT ON;
	SELECT	T_ID, T_Taxrate, 
			''['' + CAST(T_ID AS nvarchar(3)) + '']''
			+ '' - '' + CAST(T_Taxrate AS nvarchar(10)) + ''%'' AS T_TaxRateString, T_QBRefCode
	FROM	tblKartrisTaxRates


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSupportTicketTypes_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSupportTicketTypes_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSupportTicketTypes_Update]
(
	@ID as int,
	@Type as nvarchar(50),
	@Level as char(1)	
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DISABLE TRIGGER trigKartrisSupportTicketTypes_DML ON dbo.tblKartrisSupportTicketTypes;

	UPDATE dbo.tblKartrisSupportTicketTypes
	SET STT_Name = @Type, STT_Level = @Level
	WHERE STT_ID = @ID;

ENABLE TRIGGER trigKartrisSupportTicketTypes_DML ON dbo.tblKartrisSupportTicketTypes;
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSupportTicketTypes_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSupportTicketTypes_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSupportTicketTypes_Get]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     tblKartrisSupportTicketTypes.*
FROM         tblKartrisSupportTicketTypes
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSupportTicketTypes_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSupportTicketTypes_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSupportTicketTypes_Delete]
(
	@ID as int,
	@NewTypeID as int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DISABLE TRIGGER trigKartrisSupportTicketTypes_DML ON dbo.tblKartrisSupportTicketTypes;
DISABLE TRIGGER trigKartrisSupportTickets_DML ON dbo.tblKartrisSupportTickets;
	
	UPDATE dbo.tblKartrisSupportTickets
	SET TIC_SupportTicketTypeID = @NewTypeID
	WHERE TIC_SupportTicketTypeID = @ID;

	DELETE FROM dbo.tblKartrisSupportTicketTypes
	WHERE STT_ID = @ID;

ENABLE TRIGGER trigKartrisSupportTickets_DML ON dbo.tblKartrisSupportTickets;
ENABLE TRIGGER trigKartrisSupportTicketTypes_DML ON dbo.tblKartrisSupportTicketTypes;
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSupportTicketTypes_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSupportTicketTypes_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSupportTicketTypes_Add]
(
	@Type as nvarchar(50),
	@Level as char(1),
	@New_ID as int OUTPUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DISABLE TRIGGER trigKartrisSupportTicketTypes_DML ON dbo.tblKartrisSupportTicketTypes;

	INSERT INTO dbo.tblKartrisSupportTicketTypes
	VALUES (@Type, @Level);

	SELECT @New_ID = SCOPE_IDENTITY();

ENABLE TRIGGER trigKartrisSupportTicketTypes_DML ON dbo.tblKartrisSupportTicketTypes;
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSupportTickets_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSupportTickets_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSupportTickets_Update]
(
	@TIC_ID as bigint,
	@LOGIN_ID as smallint,
	@NowOffset as datetime,
	@TIC_Status as char,
	@TIC_TimeSpent as int,
	@STT_ID as smallint
)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @TIC_Status <> ''c'' BEGIN SET @NowOffset = NULL END;
		
DISABLE TRIGGER trigKartrisSupportTickets_DML ON tblKartrisSupportTickets;
	UPDATE    tblKartrisSupportTickets
	SET TIC_LoginID = @LOGIN_ID, TIC_SupportTicketTypeID = @STT_ID, TIC_Status = @TIC_Status,
		TIC_DateClosed = @NowOffset, TIC_TimeSpent = @TIC_TimeSpent
	WHERE TIC_ID = @TIC_ID;
ENABLE TRIGGER trigKartrisSupportTickets_DML ON tblKartrisSupportTickets;
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSupportTickets_GetDetailsByID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSupportTickets_GetDetailsByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSupportTickets_GetDetailsByID]
(
	@TIC_ID as bigint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     tblKartrisSupportTickets.TIC_ID, tblKartrisSupportTickets.TIC_DateOpened, tblKartrisSupportTickets.TIC_DateClosed, tblKartrisSupportTickets.TIC_Subject, 
					  tblKartrisSupportTickets.TIC_UserID, tblKartrisSupportTickets.TIC_LoginID, tblKartrisSupportTickets.TIC_SupportTicketTypeID, tblKartrisSupportTicketTypes.STT_Name, 
					  tblKartrisSupportTickets.TIC_Status, tblKartrisSupportTickets.TIC_TimeSpent
FROM         tblKartrisSupportTickets LEFT OUTER JOIN
					  tblKartrisSupportTicketTypes ON tblKartrisSupportTickets.TIC_SupportTicketTypeID = tblKartrisSupportTicketTypes.STT_ID
WHERE     (tblKartrisSupportTickets.TIC_ID = @TIC_ID)
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSupportTickets_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSupportTickets_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSupportTickets_Get]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     TIC_ID, TIC_DateOpened, TIC_DateClosed, TIC_Subject, TIC_UserID, TIC_LoginID, TIC_SupportTicketTypeID, TIC_Status, TIC_TimeSpent
	FROM         tblKartrisSupportTickets
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSupportTickets_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSupportTickets_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSupportTickets_Delete]
(
	@TIC_ID as bigint
)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DISABLE TRIGGER trigKartrisSupportTicketMessages_DML ON tblKartrisSupportTicketMessages;
	DELETE FROM dbo.tblKartrisSupportTicketMessages
	WHERE STM_TicketID = @TIC_ID;
ENABLE TRIGGER trigKartrisSupportTicketMessages_DML ON tblKartrisSupportTicketMessages;

DISABLE TRIGGER trigKartrisSupportTickets_DML ON tblKartrisSupportTickets;
	DELETE FROM dbo.tblKartrisSupportTickets
	WHERE TIC_ID = @TIC_ID;
ENABLE TRIGGER trigKartrisSupportTickets_DML ON tblKartrisSupportTickets;
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSupportTickets_AddOwnerReply]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSupportTickets_AddOwnerReply]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSupportTickets_AddOwnerReply]
(
	@TIC_ID as bigint,
	@LOGIN_ID as smallint,
	@NowOffset as datetime,
	@STM_Text as nvarchar(MAX),
	@TIC_TimeSpent as int,
	@STM_NewID as bigint OUTPUT
)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DISABLE TRIGGER trigKartrisSupportTicketMessages_DML ON tblKartrisSupportTicketMessages;
	INSERT INTO dbo.tblKartrisSupportTicketMessages
	VALUES(@TIC_ID, @LOGIN_ID, @NowOffset, @STM_Text);
ENABLE TRIGGER trigKartrisSupportTicketMessages_DML ON tblKartrisSupportTicketMessages;

	SELECT @STM_NewID = SCOPE_IDENTITY();

DISABLE TRIGGER trigKartrisSupportTickets_DML ON tblKartrisSupportTickets;
	UPDATE    tblKartrisSupportTickets
	SET TIC_LoginID = @LOGIN_ID, TIC_TimeSpent = TIC_TimeSpent + @TIC_TimeSpent
	WHERE TIC_ID = @TIC_ID;
ENABLE TRIGGER trigKartrisSupportTickets_DML ON tblKartrisSupportTickets;
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSupportTicketMessages_GetLastByCustomer]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSupportTicketMessages_GetLastByCustomer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSupportTicketMessages_GetLastByCustomer]
(
	@TIC_ID as bigint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT   top(1) tblKartrisSupportTicketMessages.STM_TicketID, tblKartrisSupportTicketMessages.STM_ID, tblKartrisSupportTicketMessages.STM_LoginID AS AssignedID, 
					  tblKartrisLogins.LOGIN_Username AS AssignedName, tblKartrisSupportTicketMessages.STM_DateCreated, tblKartrisSupportTicketMessages.STM_Text
	FROM         tblKartrisLogins RIGHT OUTER JOIN
						  tblKartrisSupportTicketMessages ON tblKartrisLogins.LOGIN_ID = tblKartrisSupportTicketMessages.STM_LoginID
	WHERE     (tblKartrisSupportTicketMessages.STM_TicketID = @TIC_ID AND tblKartrisSupportTicketMessages.STM_LoginID = 0) order by tblKartrisSupportTicketMessages.STM_ID DESC
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSupportTicketMessages_GetByTicketID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSupportTicketMessages_GetByTicketID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSupportTicketMessages_GetByTicketID]
(
	@TIC_ID as bigint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     tblKartrisSupportTicketMessages.STM_TicketID, tblKartrisSupportTicketMessages.STM_ID, tblKartrisSupportTicketMessages.STM_LoginID AS AssignedID, 
					  tblKartrisLogins.LOGIN_Username AS AssignedName, tblKartrisSupportTicketMessages.STM_DateCreated, tblKartrisSupportTicketMessages.STM_Text
	FROM         tblKartrisLogins RIGHT OUTER JOIN
						  tblKartrisSupportTicketMessages ON tblKartrisLogins.LOGIN_ID = tblKartrisSupportTicketMessages.STM_LoginID
	WHERE     (tblKartrisSupportTicketMessages.STM_TicketID = @TIC_ID)
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSuppliers_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSuppliers_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisSuppliers_Update]
(
	@SUP_ID as smallint,
	@SUP_Name as nvarchar(50),
	@SUP_Live as bit
)
AS
	SET NOCOUNT ON;
Disable Trigger trigKartrisSuppliers_DML ON tblKartrisSuppliers;	
	UPDATE dbo.tblKartrisSuppliers
	SET SUP_Name = @SUP_Name, SUP_Live = @SUP_Live
	WHERE SUP_ID = @SUP_ID;
Enable Trigger trigKartrisSuppliers_DML ON tblKartrisSuppliers;	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSuppliers_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSuppliers_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisSuppliers_Get]
AS
	SET NOCOUNT ON;
	SELECT  *
	FROM	dbo.tblKartrisSuppliers

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSuppliers_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSuppliers_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisSuppliers_Add]
(
	@SUP_Name as nvarchar(50),
	@SUP_Live as bit,
	@NewSUP_ID as smallint out
)
AS
	SET NOCOUNT ON;
Disable Trigger trigKartrisSuppliers_DML ON tblKartrisSuppliers;	
	INSERT INTO dbo.tblKartrisSuppliers
	VALUES (@SUP_Name, @SUP_Live);

	SELECT @NewSUP_ID = SCOPE_IDENTITY();
Enable Trigger trigKartrisSuppliers_DML ON tblKartrisSuppliers;	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisStatistics_GetProductYearSummary]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisStatistics_GetProductYearSummary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisStatistics_GetProductYearSummary] (@NowOffset as datetime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT   Count(ST_ItemID) as NoOfHits, MONTH(ST_Date) as TheMonth, Year(ST_Date) as TheYear, (MONTH(ST_Date) + (year(ST_Date) * 100)) As MonthYear
	FROM         tblKartrisStatistics
	WHERE     (ST_Type = ''P'') AND DateDiff(month, ST_Date, @NowOffset) <= 11 
	Group By  MONTH(ST_Date), Year(ST_Date)
END




' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisStatistics_GetOrdersTurnover]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisStatistics_GetOrdersTurnover]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisStatistics_GetOrdersTurnover]
(
	@StartDate as datetime,
	@EndDate as datetime
)
AS
BEGIN

	SELECT Year(O_Date) as [Year], Month(O_Date) as [Month], Day(O_Date) as [Day], Count(1) as Orders, Sum(O_TotalPrice / O_CurrencyRate) as TotalValue
	FROM dbo.tblKartrisOrders
	WHERE O_Date BETWEEN @StartDate AND @EndDate AND O_Paid = 1
	Group BY Year(O_Date), Month(O_Date), Day(O_Date)
	ORDER BY Year(O_Date), Month(O_Date), Day(O_Date)

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisStatistics_GetCategoryYearSummary]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisStatistics_GetCategoryYearSummary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisStatistics_GetCategoryYearSummary] (@NowOffset as datetime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT Count(ST_ItemID) as NoOfHits, MONTH(ST_Date) as TheMonth, Year(ST_Date) as TheYear, (MONTH(ST_Date) + (year(ST_Date) * 100)) As MonthYear
	FROM         tblKartrisStatistics
	WHERE     (ST_Type = ''C'') AND DateDiff(month, ST_Date, @NowOffset) <= 11 
	Group By  MONTH(ST_Date), Year(ST_Date)
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingMethods_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingMethods_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Update Shipping Method
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisShippingMethods_Update]
(
	@SM_ID as tinyint,
	@SM_Live as bit,
	@SM_OrderByValue as tinyint,
	@SM_Tax as tinyint,
	@SM_Tax2 as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
Disable Trigger trigKartrisShippingMethods_DML ON tblKartrisShippingMethods;	
	UPDATE dbo.tblKartrisShippingMethods
	SET SM_Live = @SM_Live, SM_OrderByValue = @SM_OrderByValue, SM_Tax = @SM_Tax, SM_Tax2 = @SM_Tax2
	WHERE SM_ID = @SM_ID;
Enable Trigger trigKartrisShippingMethods_DML ON tblKartrisShippingMethods;	

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisStatistics_GetAverageVisitsSummary]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisStatistics_GetAverageVisitsSummary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisStatistics_GetAverageVisitsSummary]
(
	@CurrentDate as datetime
)
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @Last24Hours as datetime; SET @Last24Hours = DateAdd(Hour, -24, @CurrentDate);
	DECLARE @LastWeek as datetime; SET @LastWeek = DateAdd(Week, -1, @CurrentDate);
	DECLARE @LastMonth as datetime; SET @LastMonth = DateAdd(Month, -1, @CurrentDate);
	DECLARE @LastYear as datetime; SET @LastYear = DateAdd(Year, -1, @CurrentDate);

	DECLARE @Last24HoursVisits as int, @LastWeekVisits as int, @LastMonthVisits as int, @LastYearVisits as int;

	SELECT @Last24HoursVisits = Count(1)
	FROM dbo.tblKartrisStatistics
	WHERE ST_Date BETWEEN @Last24Hours AND @CurrentDate

	SELECT @LastWeekVisits = Count(1)/7
	FROM dbo.tblKartrisStatistics
	WHERE ST_Date BETWEEN @LastWeek AND @CurrentDate

	SELECT @LastMonthVisits = Count(1)/30
	FROM dbo.tblKartrisStatistics
	WHERE ST_Date BETWEEN @LastMonth AND @CurrentDate

	SELECT @LastYearVisits = Count(1)/360
	FROM dbo.tblKartrisStatistics
	WHERE ST_Date BETWEEN @LastYear AND @CurrentDate

	SELECT @Last24HoursVisits as Last24Hours, @LastWeekVisits as LastWeek, @LastMonthVisits as LastMonth, @LastYearVisits as LastYear
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisStatistics_GetAverageOrdersSummary]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisStatistics_GetAverageOrdersSummary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisStatistics_GetAverageOrdersSummary]
(
	@CurrentDate as datetime
)
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @Last24Hours as datetime; SET @Last24Hours = DateAdd(Hour, -24, @CurrentDate);
	DECLARE @LastWeek as datetime; SET @LastWeek = DateAdd(Week, -1, @CurrentDate);
	DECLARE @LastMonth as datetime; SET @LastMonth = DateAdd(Month, -1, @CurrentDate);
	DECLARE @LastYear as datetime; SET @LastYear = DateAdd(Year, -1, @CurrentDate);

	DECLARE @Last24HoursOrders as int, @LastWeekOrders as int, @LastMonthOrders as int, @LastYearOrders as int;
	DECLARE @Last24HoursTurnover as real, @LastWeekTurnover as real, @LastMonthTurnover as real, @LastYearTurnover as real;

	SELECT @Last24HoursOrders = Count(1), @Last24HoursTurnover = Sum(O_TotalPrice / O_CurrencyRate)
	FROM dbo.tblKartrisOrders
	WHERE O_Date BETWEEN @Last24Hours AND @CurrentDate AND O_Paid = 1

	SELECT @LastWeekOrders = Count(1), @LastWeekTurnover = Sum(O_TotalPrice / O_CurrencyRate)/7 
	FROM dbo.tblKartrisOrders
	WHERE O_Date BETWEEN @LastWeek AND @CurrentDate AND O_Paid = 1

	SELECT @LastMonthOrders = Count(1), @LastMonthTurnover = Sum(O_TotalPrice / O_CurrencyRate)/30
	FROM dbo.tblKartrisOrders
	WHERE O_Date BETWEEN @LastMonth AND @CurrentDate AND O_Paid = 1

	SELECT @LastYearOrders = Count(1), @LastYearTurnover = Sum(O_TotalPrice / O_CurrencyRate)/360
	FROM dbo.tblKartrisOrders
	WHERE O_Date BETWEEN @LastYear AND @CurrentDate AND O_Paid = 1


	SELECT @Last24HoursOrders as Last24HoursOrders, @LastWeekOrders as LastWeekOrders
			, @LastMonthOrders as LastMonthOrders, @LastYearOrders as LastYearOrders
			, @Last24HoursTurnover as Last24HoursTurnover, @LastWeekTurnover as LastWeekTurnover
			, @LastMonthTurnover as LastMonthTurnover, @LastYearTurnover as LastYearTurnover;
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisStatistics_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisStatistics_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisStatistics_Get]
AS
	SET NOCOUNT ON;
SELECT        tblKartrisStatistics.*
FROM            tblKartrisStatistics

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingZones_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingZones_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Update Shipping Zone
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisShippingZones_Update]
(
	@SZ_ID as tinyint,
	@SZ_Live as bit,
	@SZ_OrderByValue as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
Disable Trigger trigKartrisShippingZones_DML ON tblKartrisShippingZones;	
	UPDATE dbo.tblKartrisShippingZones
	SET SZ_Live = @SZ_Live, SZ_OrderByValue = @SZ_OrderByValue
	WHERE SZ_ID = @SZ_ID;
Enable Trigger trigKartrisShippingZones_DML ON tblKartrisShippingZones;	

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingZones_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingZones_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Create New Shipping Zone
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisShippingZones_Add]
(
	@SZ_Live as bit,
	@SZ_OrderByValue as tinyint,
	@SZ_NewID as tinyint OUT
)
AS
BEGIN
	SET NOCOUNT ON;
Disable Trigger trigKartrisShippingZones_DML ON tblKartrisShippingZones;	
	INSERT INTO dbo.tblKartrisShippingZones
	VALUES (@SZ_Live, @SZ_OrderByValue);

	SELECT @SZ_NewID = SCOPE_IDENTITY();
Enable Trigger trigKartrisShippingZones_DML ON tblKartrisShippingZones;	

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisUsers_UpdateAffiliateOrders]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisUsers_UpdateAffiliateOrders]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 23/Apr/08
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisUsers_UpdateAffiliateOrders] (
	@intType as int,	
	@AffiliatePaymentID int,
	@OrderID int
) AS
BEGIN

	If @intType=1 -- update affiliate orders
	Begin
		Disable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	
			UPDATE tblKartrisOrders SET O_AffiliatePaymentID = @AffiliatePaymentID WHERE O_ID = @OrderID;
		Enable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	
	End

	If @intType=2 -- delete affiliate payments and reset orders
	Begin
		Disable Trigger trigKartrisAffiliatePayments_DML ON tblKartrisAffiliatePayments;
			DELETE FROM tblKartrisAffiliatePayments WHERE AFP_ID = @AffiliatePaymentID;
		Enable Trigger trigKartrisAffiliatePayments_DML ON tblKartrisAffiliatePayments;	

		Disable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	
			UPDATE tblKartrisOrders SET O_AffiliatePaymentID = 0 WHERE O_AffiliatePaymentID = @AffiliatePaymentID;
		Enable Trigger trigKartrisOrders_DML ON tblKartrisOrders;
	End

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisUsers_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisUsers_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisUsers_Update]
(
		   @U_ID int,
			@U_AccountHolderName nvarchar(50),
		   @U_EmailAddress nvarchar(100),
		   @U_Password nvarchar(64),
			@U_LanguageID tinyint,
			@U_CustomerGroupID tinyint,
			@U_CustomerDiscount real,
			@U_Approved bit,
			@U_IsAffiliate bit,
			@U_AffiliateCommission real,
			@U_SupportEndDate datetime,
			@U_Notes nvarchar(MAX)
)
AS
	IF @U_Password = ''''
		BEGIN
			SET @U_Password = NULL;
		END;
	IF @U_AccountHolderName = ''''
		BEGIN
			SET @U_AccountHolderName = NULL;
		END;
		
	IF @U_Notes = ''''
		BEGIN
			SET @U_Notes = NULL;
		END;
	SET NOCOUNT OFF;

Disable Trigger trigKartrisUsers_DML ON tblKartrisUsers;	
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
			[U_Notes] = COALESCE (@U_Notes, U_Notes)
			WHERE U_ID = @U_ID;
	SELECT @U_ID;
Enable Trigger trigKartrisUsers_DML ON tblKartrisUsers;	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisUsers_ListBySearchTermCount]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisUsers_ListBySearchTermCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisUsers_ListBySearchTermCount]
(
	@SearchTerm nvarchar(100),
	@isAffiliate bit,
	@isMailingList bit,
	@CustomerGroupID int,
	@isAffiliateApproved bit
)
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	


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
		SET @SearchTerm = ''?''
	END;

IF @SearchTerm IS NULL OR @SearchTerm = ''?'' OR @SearchTerm = ''''
BEGIN
	SELECT      count(1)
	FROM         tblKartrisUsers 
	WHERE   (U_IsAffiliate = COALESCE (@isAffiliate, U_IsAffiliate))
			AND (U_ML_SendMail = COALESCE (@isMailingList, U_ML_SendMail))
			AND (U_CustomerGroupiD = COALESCE (@CustomerGroupID, U_CustomerGroupiD)
			AND (U_AffiliateCommission = COALESCE (@intAffiliateCommision, U_AffiliateCommission)))

END
ELSE
BEGIN
	SELECT      count(1)
FROM         tblKartrisAddresses RIGHT OUTER JOIN
					  tblKartrisUsers ON tblKartrisAddresses.ADR_ID = tblKartrisUsers.U_DefBillingAddressID
		WHERE     ((tblKartrisUsers.U_AccountHolderName LIKE ''%'' + @SearchTerm + ''%'') OR
								(tblKartrisAddresses.ADR_Name LIKE ''%'' + @SearchTerm + ''%'') OR 
							  (tblKartrisAddresses.ADR_Company LIKE ''%'' + @SearchTerm + ''%'') OR
							  (tblKartrisUsers.U_EmailAddress LIKE ''%'' + @SearchTerm + ''%'') OR
							  (tblKartrisAddresses.ADR_StreetAddress LIKE ''%'' + @SearchTerm + ''%'') OR
							  (tblKartrisAddresses.ADR_TownCity LIKE ''%'' + @SearchTerm + ''%'') OR
							  (tblKartrisAddresses.ADR_County LIKE ''%'' + @SearchTerm + ''%'') OR
							  (tblKartrisAddresses.ADR_PostCode LIKE ''%'' + @SearchTerm + ''%''))
END
END





' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisUsers_ListBySearchTerm]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisUsers_ListBySearchTerm]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisUsers_ListBySearchTerm]
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
		SET @SearchTerm = ''?''
	END;

IF @SearchTerm IS NULL OR @SearchTerm = ''?'' OR @SearchTerm = ''''
BEGIN

WITH UsersList AS
	(
SELECT      ROW_NUMBER() OVER (ORDER BY U_ID DESC) AS Row,tblKartrisUsers.U_ID, tblKartrisUsers.U_AccountHolderName, tblKartrisUsers.U_EmailAddress, tblKartrisAddresses.ADR_Name,U_IsAffiliate,U_AffiliateCommission, U_CustomerBalance
FROM         tblKartrisAddresses RIGHT OUTER JOIN
					  tblKartrisUsers ON tblKartrisAddresses.ADR_ID = tblKartrisUsers.U_DefBillingAddressID
WHERE     (U_IsAffiliate = COALESCE (@isAffiliate, U_IsAffiliate))
			AND (U_ML_SendMail = COALESCE (@isMailingList, U_ML_SendMail))
			AND (U_CustomerGroupiD = COALESCE (@CustomerGroupID, U_CustomerGroupiD)
			AND (U_AffiliateCommission = COALESCE (@intAffiliateCommision, U_AffiliateCommission)))
)
SELECT *
	FROM UsersList
	WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber;
	
END
ELSE
BEGIN
WITH UsersList AS
	(
	SELECT      ROW_NUMBER() OVER (ORDER BY U_ID DESC) AS Row,tblKartrisUsers.U_ID, tblKartrisUsers.U_AccountHolderName, tblKartrisUsers.U_EmailAddress, tblKartrisAddresses.ADR_Name,U_IsAffiliate,U_AffiliateCommission, U_CustomerBalance
	FROM         tblKartrisAddresses RIGHT OUTER JOIN
						  tblKartrisUsers ON tblKartrisAddresses.ADR_ID = tblKartrisUsers.U_DefBillingAddressID
	WHERE     ((tblKartrisUsers.U_AccountHolderName LIKE ''%'' + @SearchTerm + ''%'') OR
						(tblKartrisAddresses.ADR_Name LIKE ''%'' + @SearchTerm + ''%'') OR 
						(tblKartrisAddresses.ADR_Company LIKE ''%'' + @SearchTerm + ''%'') OR
						(tblKartrisUsers.U_EmailAddress LIKE ''%'' + @SearchTerm + ''%'') OR
						(tblKartrisAddresses.ADR_StreetAddress LIKE ''%'' + @SearchTerm + ''%'') OR
						(tblKartrisAddresses.ADR_TownCity LIKE ''%'' + @SearchTerm + ''%'') OR
						(tblKartrisAddresses.ADR_County LIKE ''%'' + @SearchTerm + ''%'') OR
						(tblKartrisAddresses.ADR_PostCode LIKE ''%'' + @SearchTerm + ''%''))
	)
	SELECT *
		FROM UsersList
		WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber;
END
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisUsers_GetTicketsDetailsByID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisUsers_GetTicketsDetailsByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisUsers_GetTicketsDetailsByID]
(
	@U_ID as int
)
AS
SET NOCOUNT OFF;

DECLARE @WholeTickets as bigint;
SELECT @WholeTickets = Count(TIC_ID)
FROM dbo.tblKartrisSupportTickets;

DECLARE @WholeMessages as bigint;
SELECT @WholeMessages = Count(STM_ID)
FROM dbo.tblKartrisSupportTicketMessages;

DECLARE @WholeTime as bigint;
SELECT @WholeTime = Sum(TIC_TimeSpent)
FROM dbo.tblKartrisSupportTickets;

SELECT     tblKartrisUsers.U_ID AS UserID, tblKartrisUsers.U_EmailAddress, COUNT(tblKartrisSupportTickets.TIC_ID) AS UserTickets, tblMessages.UserMessages, 
					  SUM(tblKartrisSupportTickets.TIC_TimeSpent) AS UserTime, @WholeTickets AS TotalTickets, @WholeMessages AS TotalMessages, @WholeTime AS TotalTime
FROM         tblKartrisSupportTickets LEFT OUTER JOIN
					  tblKartrisUsers ON tblKartrisSupportTickets.TIC_UserID = tblKartrisUsers.U_ID INNER JOIN
						  (SELECT     tblKartrisUsers_1.U_ID, COUNT(tblKartrisSupportTicketMessages.STM_ID) AS UserMessages
							 FROM         tblKartrisSupportTickets AS tblKartrisSupportTickets_1 INNER JOIN
												   tblKartrisSupportTicketMessages ON tblKartrisSupportTickets_1.TIC_ID = tblKartrisSupportTicketMessages.STM_TicketID LEFT OUTER JOIN
												   tblKartrisUsers AS tblKartrisUsers_1 ON tblKartrisSupportTickets_1.TIC_UserID = tblKartrisUsers_1.U_ID
							 GROUP BY tblKartrisUsers_1.U_ID) AS tblMessages ON tblMessages.U_ID = tblKartrisUsers.U_ID
GROUP BY tblKartrisUsers.U_ID, tblKartrisUsers.U_EmailAddress, tblMessages.UserMessages
HAVING tblKartrisUsers.U_ID = @U_ID




' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisUsers_GetTicketsDetails]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisUsers_GetTicketsDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisUsers_GetTicketsDetails]
AS
SET NOCOUNT OFF;

DECLARE @WholeTickets as bigint;
SELECT @WholeTickets = Count(TIC_ID)
FROM dbo.tblKartrisSupportTickets;

DECLARE @WholeMessages as bigint;
SELECT @WholeMessages = Count(STM_ID)
FROM dbo.tblKartrisSupportTicketMessages;

DECLARE @WholeTime as bigint;
SELECT @WholeTime = Sum(TIC_TimeSpent)
FROM dbo.tblKartrisSupportTickets;

SELECT     tblKartrisUsers.U_ID AS UserID, tblKartrisUsers.U_EmailAddress, COUNT(tblKartrisSupportTickets.TIC_ID) AS UserTickets, tblMessages.UserMessages, 
					  SUM(tblKartrisSupportTickets.TIC_TimeSpent) AS UserTime, @WholeTickets AS TotalTickets, @WholeMessages AS TotalMessages, @WholeTime AS TotalTime
FROM         tblKartrisSupportTickets LEFT OUTER JOIN
					  tblKartrisUsers ON tblKartrisSupportTickets.TIC_UserID = tblKartrisUsers.U_ID INNER JOIN
						  (SELECT     tblKartrisUsers_1.U_ID, COUNT(tblKartrisSupportTicketMessages.STM_ID) AS UserMessages
							 FROM         tblKartrisSupportTickets AS tblKartrisSupportTickets_1 INNER JOIN
												   tblKartrisSupportTicketMessages ON tblKartrisSupportTickets_1.TIC_ID = tblKartrisSupportTicketMessages.STM_TicketID LEFT OUTER JOIN
												   tblKartrisUsers AS tblKartrisUsers_1 ON tblKartrisSupportTickets_1.TIC_UserID = tblKartrisUsers_1.U_ID
							 GROUP BY tblKartrisUsers_1.U_ID) AS tblMessages ON tblMessages.U_ID = tblKartrisUsers.U_ID
GROUP BY tblKartrisUsers.U_ID, tblKartrisUsers.U_EmailAddress, tblMessages.UserMessages




' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisUsers_GetDetails]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisUsers_GetDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisUsers_GetDetails]
(
	@U_ID int
)
AS
SET NOCOUNT OFF;
SELECT        TOP 1 
				*
				
FROM            tblKartrisUsers
WHERE        (U_ID = @U_ID)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisUsers_GetAffiliateReport]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisUsers_GetAffiliateReport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Joseph
-- Create date: 26/Apr/08
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisUsers_GetAffiliateReport] ( 
	@intType tinyint,
	@ReportMonth as int,
	@ReportYear as int,
	@ReportStartDate as datetime,
	@Paid as bit=0,
	@AffiliateID as int=0,
	@PageIndexStart int=1,
	@PageIndexEnd int=1000
) AS
BEGIN
	SET NOCOUNT ON;

	If @intType=1 -- hits for month and year
	Begin
		select count(AFLG_ID) as Hits, U_ID,U_EmailAddress from tblKartrisAffiliateLog AL
		inner join tblKartrisUsers USR on AL.AFLG_AffiliateID=USR.U_ID
		where month(AFLG_DateTime)=@ReportMonth and year(AFLG_DateTime)=@ReportYear
		group by U_ID,U_EmailAddress
		order by U_EmailAddress
	End

	If @intType=2 -- hits for the last year
	Begin	
		select count(AFLG_ID) as Hits, year(AFLG_DateTime) as TheYear, month(AFLG_DateTime) as TheMonth from tblKartrisAffiliateLog AL
		where AFLG_DateTime >= @ReportStartDate
		group by year(AFLG_DateTime), month(AFLG_DateTime)
		order by year(AFLG_DateTime) DESC, month(AFLG_DateTime) DESC
	End

	If @intType=3 -- sales for month and year
	Begin
		select sum(ROUND(O_AffiliateTotalPrice + 0.00000001,2)) AS OrderAmount,USR.U_AffiliateID,USR1.U_EmailAddress from tblKartrisUsers AS USR
		inner join tblKartrisOrders as ORD on USR.U_ID = ORD.O_CustomerID 
		inner join tblKartrisUsers as USR1 on USR1.U_ID = USR.U_AffiliateID
		where O_Sent=1 and O_AffiliatePercentage>0
			and month(O_Date)=@ReportMonth and year(O_Date)=@ReportYear and isnull(O_Paid,0)=@Paid
		group by USR.U_AffiliateID,USR1.U_EmailAddress,USR1.U_ID
	End

	If @intType=4 -- sales for the last year
	Begin
		select SUM(ROUND(O_AffiliateTotalPrice + 0.00000001,2)) AS OrderAmount, YEAR(O_Date) AS TheYear, MONTH(O_Date) AS TheMonth FROM tblKartrisUsers as USR
		inner join tblKartrisOrders as ORD on USR.U_ID = ORD.O_CustomerID --and USR.U_ID=USR.U_AffiliateID
		where O_Sent=1 and O_AffiliatePercentage>0 and isnull(O_Paid,0)=@Paid
			and O_Date>=@ReportStartDate
		GROUP BY Month(O_Date), Year(O_Date) 
		ORDER BY Year(O_Date) DESC, Month(O_Date) DESC 
	End

	If @intType=5 -- individual affiliate summary report
	Begin	
		declare @Clicks int
		select @Clicks=count(AFLG_ID) from tblKartrisAffiliateLog as AL
		inner join tblKartrisUsers as USR on USR.U_ID=AL.AFLG_AffiliateID
		WHERE U_ID=@AffiliateID  AND MONTH(AFLG_DateTime)=@ReportMonth AND YEAR(AFLG_DateTime)=@ReportYear

		declare @OrderTotal float
		declare @Commission float
		declare @EmailAddress nvarchar(100)
		select @OrderTotal=sum(Round(O_AffiliateTotalPrice,2)),@Commission=sum(Round(O_AffiliateTotalPrice * (O_AffiliatePercentage/100) + 0.00000001 ,2)), @EmailAddress=USR1.U_EmailAddress from tblKartrisUsers as USR 
		inner join tblKartrisOrders as ORD on USR.U_ID = ORD.O_CustomerID --and USR.U_ID=USR.U_AffiliateID
		inner join tblKartrisUsers as USR1 on USR1.U_ID = USR.U_AffiliateID
		where O_Sent=1 and O_AffiliatePercentage>0 and USR.U_AffiliateID=@AffiliateID
			and month(O_Date)=@ReportMonth and year(O_Date)=@ReportYear and O_Paid=@Paid
		GROUP BY USR.U_AffiliateID, USR1.U_EmailAddress, Month(O_Date), Year(O_Date)

		If isnull(@EmailAddress,'''')=''''
		Begin
			select @EmailAddress=U_EmailAddress from tblKartrisUsers where U_ID=@AffiliateID
		End
	
		select isnull(@EmailAddress,'''') as U_EmailAddress,isnull(@OrderTotal,0) as OrderTotal, isnull(@Commission,0) as Commission, @Clicks as Clicks
	End

	If @intType=6 -- individual affiliate raw data hits
	Begin	
		select * from (
		select ROW_NUMBER() OVER (ORDER BY AFLG_DateTime) as RowNum, AFLG_DateTime, AFLG_IP, AFLG_Referer from tblKartrisAffiliateLog
		WHERE AFLG_AffiliateID=@AffiliateID AND MONTH(AFLG_DateTime)=@ReportMonth AND YEAR(AFLG_DateTime)=@ReportYear
		) A
		where RowNum between @PageIndexStart and @PageIndexEnd
		order by RowNum ASC
	End

	If @intType=7 -- individual affiliate raw data sales
	Begin	
		select * from (
		select ROW_NUMBER() OVER (ORDER BY O_ID) as RowNum,* from (
			select SUM(ROUND(O_AffiliateTotalPrice,2)) AS OrderTotal, SUM(ROUND(O_AffiliateTotalPrice * (O_AffiliatePercentage/100) + 0.00000001 ,2)) AS Commission, 
				O_AffiliatePercentage,O_Date,U_ID,U_AccountHolderName,U_EmailAddress,O_ID from tblKartrisUsers as USR 
			inner join tblKartrisOrders as ORD on ORD.O_CustomerID=USR.U_ID
			where U_AffiliateID=@AffiliateID and O_AffiliatePercentage>0
				and year(O_Date)=@ReportYear and month(O_Date)=@ReportMonth and O_Sent=1 and O_Paid=@Paid
			group by O_ID,O_AffiliatePercentage,O_Date,U_ID,U_AccountHolderName,U_EmailAddress,O_ID) A
		) B
		where RowNum between @PageIndexStart and @PageIndexEnd
		order by RowNum ASC
	End

END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisUsers_GetAffiliateCommission]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisUsers_GetAffiliateCommission]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 21/Apr/09
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisUsers_GetAffiliateCommission] (
	@intType int,
	@UserID int,
	@Paid bit=1,
	@PageIndexStart int=1,
	@PageIndexEnd int=1000
) AS

BEGIN
	SET NOCOUNT ON;
	
	If @intType=0 -- summary of commission
	Begin
		declare @PaidCommission float
		declare @UnpaidCommission float
		declare @EmailAddress nvarchar(100)	
		
		-- paid
		select @PaidCommission=sum(ROUND(O_AffiliateTotalPrice * (O_AffiliatePercentage/100) + 0.00000001 ,2)), @EmailAddress=USR1.U_EmailAddress from tblKartrisUsers USR
		inner join tblKartrisOrders ORD on ORD.O_CustomerID = USR.U_ID
		inner join tblKartrisUsers USR1 on USR1.U_ID=USR.U_AffiliateID
		where USR.U_AffiliateID = @UserID and O_Sent=1 and O_AffiliatePaymentID <> 0 and O_Paid=@Paid
		group by USR1.U_EmailAddress		

		-- unpaid
		select @UnpaidCommission=sum(ROUND(O_AffiliateTotalPrice * (O_AffiliatePercentage/100) + 0.00000001 ,2)), @EmailAddress=USR1.U_EmailAddress from tblKartrisUsers USR
		inner join tblKartrisOrders ORD on ORD.O_CustomerID = USR.U_ID
		inner join tblKartrisUsers USR1 on USR1.U_ID=USR.U_AffiliateID
		where USR.U_AffiliateID = @UserID and O_Sent=1 and O_AffiliatePaymentID = 0 and O_Paid=@Paid
		group by USR1.U_EmailAddress

		select @EmailAddress=U_EmailAddress from tblKartrisUsers where U_ID=@UserID

		select isnull(@EmailAddress,'''') as EmailAddress, isnull(@PaidCommission,0) as PaidCommission, isnull(@UnpaidCommission,0) as UnpaidCommission
	End

	Else If @intType=1 -- details of Unpaid commission
	Begin
		select * from (
			select U_ID,O_ID,ROW_NUMBER() OVER (ORDER BY ORD.O_Date) as RowNum, O_Date,sum(round(O_AffiliateTotalPrice * (O_AffiliatePercentage/100) + 0.00000001 ,2)) AS Commission,O_AffiliatePercentage from tblKartrisUsers as USR
			inner join tblKartrisOrders  as ORD on ORD.O_CustomerID = USR.U_ID
			where U_AffiliateID = @UserID and O_Sent=1 and O_AffiliatePercentage>0 and O_AffiliatePaymentID=0 and O_Paid=@Paid
			group by U_ID,ORD.O_ID, ORD.O_Date,ORD.O_AffiliatePercentage
		) A
		where RowNum between @PageIndexStart and @PageIndexEnd
		order by RowNum ASC
	End

	Else -- details of payments (paid commission)
	Begin
		select * from (
			select ROW_NUMBER() OVER (ORDER BY AFP_DateTime) as RowNum, AFP_ID, AFP_DateTime, count(O_ID) AS TotalOrders, sum(ROUND(O_AffiliateTotalPrice * (O_AffiliatePercentage/100) + 0.00000001 ,2)) AS TotalPayment FROM tblKartrisOrders as ORD
			INNER JOIN tblKartrisAffiliatePayments as AP ON ORD.O_AffiliatePaymentID = AP.AFP_ID
			INNER JOIN tblKartrisUsers AS USR ON AP.AFP_AffiliateID = USR.U_ID 
			WHERE U_ID = @UserID AND O_Sent = 1 AND O_Paid = @Paid
			GROUP BY AFP_ID, AFP_DateTime 
		) A
		where RowNum between @PageIndexStart and @PageIndexEnd
		order by RowNum ASC
	End

End
	
	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPages_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPages_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPages_Add]
(
	@Page_Name as nvarchar(50),
	@Page_ParentID as smallint,
	@Page_Live as bit,
	@NowOffset as datetime,
	@Page_NewID as smallint OUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Disable Trigger trigKartrisPages_DML ON tblKartrisPages;	
	-- Insert statements for procedure here
	INSERT INTO tblKartrisPages VALUES(@Page_Name, @Page_ParentID, @NowOffset, @NowOffset, @Page_Live);
	SELECT @Page_NewID = SCOPE_IDENTITY();
Enable Trigger trigKartrisPages_DML ON tblKartrisPages;	
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_UpdateStatus]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOrders_UpdateStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisOrders_UpdateStatus]
(
	@O_ID int,
	@O_Sent bit,
	@O_Paid bit,
	@O_Shipped bit,
	@O_Invoiced bit,
	@O_LastModified smalldatetime,
	@O_Status nvarchar(MAX),
	@O_Notes nvarchar(MAX)
)
AS
	IF @O_Status = ''''
	BEGIN
		SET @O_Status = NULL;
	END
	
	IF @O_Notes = ''''
	BEGIN
		SET @O_Notes = NULL;
	END
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;
Disable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	
	UPDATE tblKartrisOrders SET O_Sent = @O_Sent,
								O_Paid = @O_Paid, 
								O_Shipped = @O_Shipped,
								O_Invoiced = @O_Invoiced, 
								O_Status = COALESCE(@O_Status,O_Status), 
								O_LastModified = @O_LastModified,
								O_Notes = COALESCE(@O_Notes,O_Notes)
		WHERE O_ID = @O_ID;
	Select @O_ID;
Enable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	




' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_ToPurgeOrdersList]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOrders_ToPurgeOrdersList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisOrders_ToPurgeOrdersList]
(
	
	@O_PurgeDate smalldatetime = NULL
)
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		SELECT O_ID FROM tblKartrisOrders WHERE O_Date <= @O_PurgeDate AND O_Sent = 0;
END




' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_CloneAndCancel]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOrders_CloneAndCancel]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisOrders_CloneAndCancel]
(
			@O_ID int,
			@O_Details nvarchar(MAX),
			@O_BillingAddress nvarchar(255),
		   @O_ShippingAddress nvarchar(255),
			@O_Sent bit,
		   @O_Invoiced bit,
		   @O_Shipped bit,
		   @O_Paid bit,
			@O_ShippingPrice real,
		   @O_ShippingTax real,
		   @O_TotalPrice real,
		   @O_LastModified smalldatetime,
		   @O_CouponCode nvarchar(25),
		   @O_CouponDiscountTotal real,
		   @O_TaxDue real,
		   @O_TotalPriceGateway real,
		   @O_OrderHandlingCharge real,
		   @O_OrderHandlingChargeTax real,
		   @O_ShippingMethod nvarchar(255),
		   @O_Notes nvarchar(MAX),
		   @BackendUserID int,
		   @O_PurchaseOrderNo nvarchar(50),
		   @O_PromotionDiscountTotal real,
		   @O_PromotionDescription nvarchar(255),
			@O_AffiliateTotalPrice real,
			@O_SendOrderUpdateEmail bit,
			@O_PricesIncTax real,
			@O_CurrencyRate real
)
AS
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;
DECLARE @NewOrderID as int;
DECLARE @strCreatedFrom as nvarchar(MAX);
DECLARE @strCancelled as nvarchar(MAX);

SET @strCreatedFrom = (SELECT [LS_Value] FROM [dbo].[tblKartrisLanguageStrings]
						WHERE [LS_Name] = ''ContentText_OrderCancelCreatedFrom'' AND [LS_LangID] = 1);
SET @strCancelled = (SELECT [LS_Value] FROM [dbo].[tblKartrisLanguageStrings]
						WHERE [LS_Name] = ''ContentText_OrderCancelReferTo'' AND [LS_LangID] = 1);

Disable Trigger trigKartrisOrders_DML ON tblKartrisOrders;
	INSERT INTO [dbo].[tblKartrisOrders]
		   ([O_CustomerID]
		   ,[O_Details]
		   ,[O_ShippingPrice]
		   ,[O_ShippingTax]
		   ,[O_DiscountPercentage]
		   ,[O_AffiliatePercentage]
		   ,[O_TotalPrice]
		   ,[O_Date]
		   ,[O_PurchaseOrderNo]
		   ,[O_SecurityID]
		   ,[O_Sent]
		   ,[O_Invoiced]
		   ,[O_Shipped]
		   ,[O_Paid]
		   ,[O_Status]
		   ,[O_LastModified]
		   ,[O_WishListID]
		   ,[O_CouponCode]
		   ,[O_CouponDiscountTotal]
		   ,[O_PricesIncTax]
		   ,[O_TaxDue]
		   ,[O_PaymentGateWay]
		   ,[O_ReferenceCode]
		   ,[O_LanguageID]
		   ,[O_CurrencyID]
		   ,[O_TotalPriceGateway]
		   ,[O_CurrencyIDGateway]
		   ,[O_AffiliatePaymentID]
		   ,[O_AffiliateTotalPrice]
		   ,[O_SendOrderUpdateEmail]
		   ,[O_OrderHandlingCharge]
		   ,[O_OrderHandlingChargeTax]
		   ,[O_CurrencyRate]
		   ,[O_ShippingMethod]
		   ,[O_BillingAddress]
		   ,[O_ShippingAddress]
		   ,[O_PromotionDiscountTotal]
		   ,[O_PromotionDescription]
		   ,[O_SentToQB]
		   ,[O_Notes])
	 SELECT [O_CustomerID]
	  ,@O_Details
	  ,@O_ShippingPrice
	  ,@O_ShippingTax
	  ,[O_DiscountPercentage]
	  ,[O_AffiliatePercentage]
	  ,@O_TotalPrice
	  ,@O_LastModified
	  ,@O_PurchaseOrderNo
	  ,[O_SecurityID]
	  ,@O_Sent
	  ,@O_Invoiced
	  ,@O_Shipped
	  ,@O_Paid
	  ,''''
	  ,@O_LastModified
	  ,[O_WishListID]
	  ,@O_CouponCode
	  ,@O_CouponDiscountTotal
	  ,@O_PricesIncTax
	  ,@O_TaxDue
	  ,[O_PaymentGateWay]
	  ,''''
	  ,[O_LanguageID]
	  ,[O_CurrencyID]
	  ,@O_TotalPriceGateway
	  ,[O_CurrencyIDGateway]
	  ,[O_AffiliatePaymentID]
	  ,@O_AffiliateTotalPrice
	  ,@O_SendOrderUpdateEmail
	  ,@O_OrderHandlingCharge
	  ,@O_OrderHandlingChargeTax
	  ,@O_CurrencyRate
	  ,@O_ShippingMethod
	  ,@O_BillingAddress
	  ,@O_ShippingAddress
	  ,@O_PromotionDiscountTotal
	  ,@O_PromotionDescription
	  ,0
	  ,@O_Notes + char(13)+char(10) + @strCreatedFrom + convert(nvarchar(24),@O_ID)
	FROM [dbo].[tblKartrisOrders] WHERE O_ID = @O_ID

	SET @NewOrderID = scope_identity()

	UPDATE tblKartrisOrders SET O_Paid = 0,
								O_LastModified = @O_LastModified,
								O_Notes = COALESCE(O_Notes,'''')  + char(13)+char(10) + 
								@strCancelled +
								convert(nvarchar(24),@NewOrderID)
								WHERE O_ID = @O_ID;
Enable Trigger trigKartrisOrders_DML ON tblKartrisOrders;
DISABLE TRIGGER [dbo].[trigKartrisOrderPaymentLink_DML] ON [dbo].[tblKartrisOrderPaymentLink];
	UPDATE [dbo].[tblKartrisOrderPaymentLink]
   SET [OP_OrderCanceled] = 1
 WHERE OP_OrderID = @O_ID;
ENABLE TRIGGER [dbo].[trigKartrisOrderPaymentLink_DML] ON [dbo].[tblKartrisOrderPaymentLink];
DISABLE	TRIGGER [dbo].[trigKartrisClonedOrders_DML] ON [dbo].[tblKartrisClonedOrders];
INSERT INTO [dbo].[tblKartrisClonedOrders]
		   ([CO_OrderID]
		   ,[CO_ParentOrderID]
		   ,[CO_CloneDate]
		   ,[CO_LoginID])
	 VALUES
		   (@NewOrderID,
		   @O_ID,
		   @O_LastModified,
		   @BackendUserID);
ENABLE	TRIGGER [dbo].[trigKartrisClonedOrders_DML] ON [dbo].[tblKartrisClonedOrders];
SELECT @NewOrderID;' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingMethods_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingMethods_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Create New Shipping Method
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisShippingMethods_Add]
(
	@SM_Live as bit,
	@SM_OrderByValue as tinyint,
	@SM_Tax as tinyint,
	@SM_Tax2 as tinyint,
	@SM_NewID as tinyint OUT
)
AS
BEGIN
	SET NOCOUNT ON;
Disable Trigger trigKartrisShippingMethods_DML ON tblKartrisShippingMethods;	
	INSERT INTO dbo.tblKartrisShippingMethods
	VALUES (@SM_Live, @SM_OrderByValue, @SM_Tax, @SM_Tax2);

	SELECT @SM_NewID = SCOPE_IDENTITY();
Enable Trigger trigKartrisShippingMethods_DML ON tblKartrisShippingMethods;	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSearchStatistics_GetTopSearches]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSearchStatistics_GetTopSearches]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSearchStatistics_GetTopSearches]
(
	@StartDate as datetime,
	@EndDate as datetime,
	@NoOfKeywords as int
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT Top(@NoOfKeywords) SS_Keyword, Sum(SS_Searches) As TotalSearches
	FROM dbo.tblKartrisSearchStatistics
	WHERE SS_Date BETWEEN @StartDate AND @EndDate
	Group BY SS_Keyword
	ORDER BY Sum(SS_Searches) DESC

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSearchStatistics_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSearchStatistics_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSearchStatistics_Get]
AS
BEGIN
SET NOCOUNT ON;
	
	SET NOCOUNT ON;
	
	SELECT * FROM dbo.tblKartrisSearchStatistics
	
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSavedExports_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSavedExports_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSavedExports_Update]
(
	@Name as nvarchar(50),
	@DateModified as datetime,
	@Details as nvarchar(MAX),
	@FieldDelimiter as int,
	@StringDelimiter as int,
	@ExportID as bigint 
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DISABLE TRIGGER trigKartrisSavedExports_DML ON dbo.tblKartrisSavedExports
	UPDATE dbo.tblKartrisSavedExports
	SET EXPORT_Name = @Name, EXPORT_LastModified = @DateModified, EXPORT_Details = @Details, 
		EXPORT_FieldDelimiter = @FieldDelimiter, EXPORT_StringDelimiter = @StringDelimiter
	WHERE EXPORT_ID = @ExportID;
	ENABLE TRIGGER trigKartrisSavedExports_DML ON dbo.tblKartrisSavedExports;
	
	
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSavedExports_GetByID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSavedExports_GetByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSavedExports_GetByID]
(
	@ExportID as bigint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * FROM dbo.tblKartrisSavedExports	
	WHERE EXPORT_ID = @ExportID;
	
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSavedExports_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSavedExports_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSavedExports_Get]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * FROM dbo.tblKartrisSavedExports	
	
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSavedExports_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSavedExports_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSavedExports_Delete]
(
	@ExportID as bigint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DISABLE TRIGGER trigKartrisSavedExports_DML ON dbo.tblKartrisSavedExports
	DELETE FROM dbo.tblKartrisSavedExports
	WHERE EXPORT_ID = @ExportID;
	ENABLE TRIGGER trigKartrisSavedExports_DML ON dbo.tblKartrisSavedExports;
	
	
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSavedExports_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSavedExports_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSavedExports_Add]
(
	@Name as nvarchar(50),
	@DateCreated as datetime,
	@Details as nvarchar(MAX),
	@FieldDelimiter as int,
	@StringDelimiter as int,
	@New_ID as bigint OUTPUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DISABLE TRIGGER trigKartrisSavedExports_DML ON dbo.tblKartrisSavedExports
	INSERT INTO dbo.tblKartrisSavedExports
	VALUES(@Name,@DateCreated,@DateCreated,@Details,@FieldDelimiter,@StringDelimiter);
	SELECT @New_ID = SCOPE_IDENTITY();
	ENABLE TRIGGER trigKartrisSavedExports_DML ON dbo.tblKartrisSavedExports;
	
	
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPromotions_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPromotions_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisPromotions_Add]
(	
	@PROM_StartDate smalldatetime,
	@PROM_EndDate smalldatetime,
	@PROM_Live bit,
	@PROM_OrderByValue smallint,
	@PROM_MaxQuantity tinyint,
	@NewPROM_ID int OUT
)
AS
	SET NOCOUNT OFF;
	
Disable Trigger trigKartrisPromotions_DML ON tblKartrisPromotions;	
	INSERT INTO [tblKartrisPromotions] ([PROM_StartDate], [PROM_EndDate], [PROM_Live], [PROM_OrderByValue], [PROM_MaxQuantity]) 
	VALUES (@PROM_StartDate, @PROM_EndDate, @PROM_Live, @PROM_OrderByValue, @PROM_MaxQuantity);
	
	SELECT @NewPROM_ID = SCOPE_IDENTITY();
Enable Trigger trigKartrisPromotions_DML ON tblKartrisPromotions;	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPromotions_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPromotions_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisPromotions_Get]
AS
	SET NOCOUNT ON;
	SELECT        tblKartrisPromotions.*
	FROM            tblKartrisPromotions 
	ORDER BY PROM_StartDate DESC --, PROM_Live DESC, PROM_ID DESC

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPromotions_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPromotions_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisPromotions_Update]
(
	@PROM_ID smallint,
	@PROM_StartDate smalldatetime,
	@PROM_EndDate smalldatetime,
	@PROM_Live bit,
	@PROM_OrderByValue smallint,
	@PROM_MaxQuantity tinyint
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisPromotions_DML ON tblKartrisPromotions;	
	UPDATE	[tblKartrisPromotions] 
	SET		[PROM_StartDate] = @PROM_StartDate, [PROM_EndDate] = @PROM_EndDate, [PROM_Live] = @PROM_Live, 
			[PROM_OrderByValue] = @PROM_OrderByValue, [PROM_MaxQuantity] = @PROM_MaxQuantity 
	WHERE	(([PROM_ID] = @PROM_ID));
Enable Trigger trigKartrisPromotions_DML ON tblKartrisPromotions;	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPromotions_GetByID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPromotions_GetByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisPromotions_GetByID]
(
	@PROM_ID int
)
AS
	SET NOCOUNT ON;
	SELECT        tblKartrisPromotions.*
	FROM            tblKartrisPromotions 
	WHERE	PROM_ID = @PROM_ID
	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisQuantityDiscounts_GetByVersion]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisQuantityDiscounts_GetByVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisQuantityDiscounts_GetByVersion]
(
	@VersionID bigint
)
AS
	SET NOCOUNT ON;
SELECT QD_Quantity, QD_Price 
FROM tblKartrisQuantityDiscounts
WHERE QD_VersionID = @VersionID
ORDER BY QD_Quantity

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisQuantityDiscounts_DeleteByVersion]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisQuantityDiscounts_DeleteByVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisQuantityDiscounts_DeleteByVersion]
(
	@VersionID bigint
)
AS
	SET NOCOUNT ON;
Disable Trigger trigKartrisQuantityDiscounts_DML ON tblKartrisQuantityDiscounts;	
	DELETE FROM tblKartrisQuantityDiscounts
	WHERE QD_VersionID = @VersionID;
Enable Trigger trigKartrisQuantityDiscounts_DML ON tblKartrisQuantityDiscounts;	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisQuantityDiscounts_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisQuantityDiscounts_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisQuantityDiscounts_Add]
(
	@VersionID bigint,
	@Quantity as real,
	@Price as real
)
AS
	SET NOCOUNT ON;
Disable Trigger trigKartrisQuantityDiscounts_DML ON tblKartrisQuantityDiscounts;	
	INSERT INTO tblKartrisQuantityDiscounts
	VALUES(@VersionID, @Quantity, @Price);
Enable Trigger trigKartrisQuantityDiscounts_DML ON tblKartrisQuantityDiscounts;	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCustomerGroups_Update]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCustomerGroups_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisCustomerGroups_Update]
(
	@CG_ID as smallint,
	@CG_Discount as real,
	@CG_Live as bit	
)
AS
BEGIN
	SET NOCOUNT ON;
Disable Trigger trigKartrisCustomerGroups_DML ON tblKartrisCustomerGroups;
	UPDATE dbo.tblKartrisCustomerGroups
	SET CG_Discount = @CG_Discount, CG_Live = @CG_Live
	WHERE CG_ID = @CG_ID;
Enable Trigger trigKartrisCustomerGroups_DML ON tblKartrisCustomerGroups;

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisKnowledgeBase_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisKnowledgeBase_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisKnowledgeBase_Add]
(
	@NowOffset_Created as smalldatetime,
	@NowOffset_Updated as smalldatetime,
	@KB_Live as bit,
	@KB_NewID as int OUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Disable Trigger trigKartrisKnowledgeBase_DML ON tblKartrisKnowledgeBase;
	-- Insert statements for procedure here
	INSERT INTO dbo.tblKartrisKnowledgeBase VALUES(@NowOffset_Created, @NowOffset_Updated, @KB_Live);
	SELECT @KB_NewID = SCOPE_IDENTITY();
Enable Trigger trigKartrisKnowledgeBase_DML ON tblKartrisKnowledgeBase;
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDeletedItems_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDeletedItems_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisDeletedItems_Get]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * 
	FROM tblKartrisDeletedItems
	ORDER BY Deleted_Type DESC; -- To remove the versions and then products
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDeletedItems_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDeletedItems_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisDeletedItems_Delete]
(
	@ID as bigint,
	@Type as char(1)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF @ID <> 0 AND @ID IN (SELECT DELETED_ID FROM dbo.tblKartrisDeletedItems WHERE Deleted_Type = @Type) BEGIN
		DISABLE TRIGGER trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
		DELETE FROM dbo.tblKartrisDeletedItems WHERE Deleted_ID = @ID AND Deleted_Type = @Type;
		ENABLE TRIGGER trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
	END
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCustomerGroups_Add]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCustomerGroups_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisCustomerGroups_Add]
(
	@CG_Discount as real,
	@CG_Live as bit,
	@NewCG_ID as smallint OUT
)
AS
BEGIN
	SET NOCOUNT ON;

Disable Trigger trigKartrisCustomerGroups_DML ON tblKartrisCustomerGroups;
	INSERT INTO dbo.tblKartrisCustomerGroups
	VALUES(@CG_Discount, @CG_Live);

	SELECT @NewCG_ID = SCOPE_IDENTITY();

Enable Trigger trigKartrisCustomerGroups_DML ON tblKartrisCustomerGroups;
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCurrencies_UpdateRates]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCurrencies_UpdateRates]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCurrencies_UpdateRates]
(
	@CUR_ExchangeRate real,
	@Original_CUR_ID tinyint
)
AS
	SET NOCOUNT OFF;

Disable Trigger trigKartrisCurrencies_DML ON tblKartrisCurrencies;
	UPDATE [tblKartrisCurrencies] 
	SET [CUR_ExchangeRate] = @CUR_ExchangeRate
	WHERE (([CUR_ID] = @Original_CUR_ID));
Enable Trigger trigKartrisCurrencies_DML ON tblKartrisCurrencies;

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCurrencies_Update]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCurrencies_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCurrencies_Update]
(
	@CUR_Symbol nvarchar(5),
	@CUR_ISOCode nvarchar(10),
	@CUR_ISOCodeNumeric smallint,
	@CUR_ExchangeRate real,
	@CUR_HasDecimals bit,
	@CUR_Live bit,
	@CUR_Format nvarchar(20),
	@CUR_IsoFormat nvarchar(20),
	@CUR_DecimalPoint char(1),
	@CUR_RoundNumbers tinyint,
	@Original_CUR_ID tinyint
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisCurrencies_DML ON tblKartrisCurrencies; 
UPDATE [tblKartrisCurrencies] 
SET [CUR_Symbol] = @CUR_Symbol, [CUR_ISOCode] = @CUR_ISOCode, [CUR_ISOCodeNumeric] = @CUR_ISOCodeNumeric, 
	[CUR_ExchangeRate] = @CUR_ExchangeRate, [CUR_HasDecimals] = @CUR_HasDecimals, [CUR_Live] = @CUR_Live, 
	[CUR_Format] = @CUR_Format, [CUR_IsoFormat] = @CUR_IsoFormat, [CUR_DecimalPoint] = @CUR_DecimalPoint, 
	[CUR_RoundNumbers]= @CUR_RoundNumbers
WHERE (([CUR_ID] = @Original_CUR_ID));
Enable Trigger trigKartrisCurrencies_DML ON tblKartrisCurrencies;

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCurrencies_Get]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCurrencies_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCurrencies_Get]
AS
	SET NOCOUNT ON;
SELECT * FROM tblKartrisCurrencies

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCurrencies_Add]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCurrencies_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisCurrencies_Add]
(
	@CUR_Symbol nvarchar(5),
	@CUR_ISOCode nvarchar(10),
	@CUR_ISOCodeNumeric smallint,
	@CUR_ExchangeRate real,
	@CUR_HasDecimals bit,
	@CUR_Live bit,
	@CUR_Format nvarchar(20),
	@CUR_IsoFormat nvarchar(20),
	@CUR_DecimalPoint char(1),
	@CUR_RoundNumbers tinyint,
	@CUR_NewID as tinyint OUTPUT
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisCurrencies_DML ON tblKartrisCurrencies;
	INSERT INTO [tblKartrisCurrencies] 
	([CUR_Symbol], [CUR_ISOCode], [CUR_ISOCodeNumeric], [CUR_ExchangeRate], [CUR_HasDecimals], [CUR_Live], 
	[CUR_Format], [CUR_IsoFormat], [CUR_DecimalPoint], [CUR_RoundNumbers]) 
	VALUES (@CUR_Symbol, @CUR_ISOCode, @CUR_ISOCodeNumeric, @CUR_ExchangeRate, @CUR_HasDecimals, @CUR_Live, 
	@CUR_Format, @CUR_IsoFormat, @CUR_DecimalPoint, @CUR_RoundNumbers);
	
	SELECT @CUR_NewID = SCOPE_IDENTITY();
Enable Trigger trigKartrisCurrencies_DML ON tblKartrisCurrencies;


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCoupons_UpdateStatus]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCoupons_UpdateStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCoupons_UpdateStatus]
(
	@CouponID as smallint,
	@Enabled as bit
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
Disable Trigger trigKartrisCoupons_DML ON tblKartrisCoupons;
	UPDATE dbo.tblKartrisCoupons 
	SET CP_Enabled = @Enabled
	WHERE CP_ID = @CouponID;
Enable Trigger trigKartrisCoupons_DML ON tblKartrisCoupons;
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCoupons_Update]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCoupons_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCoupons_Update]
(
	@CouponID as smallint,
	@Reusable as bit,
	@StartDate as smalldatetime,
	@EndDate as smalldatetime,
	@DiscountValue as real,
	@DiscountType as char(1),
	@Live as bit
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
Disable Trigger trigKartrisCoupons_DML ON tblKartrisCoupons;
	UPDATE dbo.tblKartrisCoupons
	SET CP_Reusable = @Reusable, CP_StartDate = @StartDate, CP_EndDate = @EndDate, 
		CP_DiscountValue = @DiscountValue, CP_DiscountType = @DiscountType, CP_Enabled = @Live
	WHERE CP_ID = @CouponID;
Enable Trigger trigKartrisCoupons_DML ON tblKartrisCoupons;



	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCoupons_SearchByCode]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCoupons_SearchByCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCoupons_SearchByCode]
(
	@CouponCode as nvarchar(25)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT CP_ID, CP_CouponCode, CP_Reusable, CP_Used, CP_CreatedTime, CONVERT(nvarchar, CP_StartDate, 6) as StartDate,
		CONVERT(nvarchar, CP_EndDate, 6) as EndDate, CP_DiscountValue, CP_DiscountType, CP_Enabled
	FROM    tblKartrisCoupons
	WHERE  CP_CouponCode LIKE ''%'' + @CouponCode + ''%''
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCoupons_GetGroups]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCoupons_GetGroups]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCoupons_GetGroups]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT DISTINCT  COUNT(CP_ID) AS Qty, 
			CAST(YEAR(CP_CreatedTime) as nvarchar(4)) + ''/'' + CAST(MONTH(CP_CreatedTime) as nvarchar(2)) 
			+ ''/'' + CAST( DAY (CP_CreatedTime) as nvarchar(2)) as CreatedTime, 
			YEAR(CP_CreatedTime), MONTH(CP_CreatedTime), DAY (CP_CreatedTime)
	FROM         tblKartrisCoupons
	GROUP BY YEAR(CP_CreatedTime), MONTH(CP_CreatedTime), DAY (CP_CreatedTime)
	ORDER By YEAR(CP_CreatedTime) DESC, MONTH(CP_CreatedTime) DESC, DAY(CP_CreatedTime) DESC
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCoupons_GetByID]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCoupons_GetByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCoupons_GetByID]
(
	@CouponID as smallint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT *
	FROM    tblKartrisCoupons
	WHERE CP_ID = @CouponID
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCoupons_GetByDateTime]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCoupons_GetByDateTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCoupons_GetByDateTime]
(
	@Year as int,
	@Month as int,
	@Day as int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT CP_ID, CP_CouponCode, CP_Reusable, CP_Used, CP_CreatedTime, CONVERT(nvarchar, CP_StartDate, 6) as StartDate,
		CONVERT(nvarchar, CP_EndDate, 6) as EndDate, CP_DiscountValue, CP_DiscountType, CP_Enabled
	FROM         tblKartrisCoupons
	WHERE YEAR(CP_CreatedTime) = @Year AND  MONTH(CP_CreatedTime) = @Month 
			AND  DAY(CP_CreatedTime) = @Day
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCoupons_GetByCouponCode]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCoupons_GetByCouponCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCoupons_GetByCouponCode]
(
	@CouponCode as nvarchar(25)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT CP_ID
	FROM    tblKartrisCoupons
	WHERE CP_CouponCode = @CouponCode
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCoupons_Delete]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCoupons_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCoupons_Delete]
(
	@CouponID as smallint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
Disable Trigger trigKartrisCoupons_DML ON tblKartrisCoupons;
	DELETE
	FROM    tblKartrisCoupons
	WHERE CP_ID = @CouponID;
Enable Trigger trigKartrisCoupons_DML ON tblKartrisCoupons;
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCoupons_Add]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCoupons_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCoupons_Add]
(
	@CouponCode as nvarchar(25),
	@Reusable as bit,
	@StartDate as smalldatetime,
	@EndDate as smalldatetime,
	@DiscountValue as real,
	@DiscountType as char(1),
	@CouponCodeIsFixed as bit,
	@NowOffset as datetime
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
Disable Trigger trigKartrisCoupons_DML ON tblKartrisCoupons;
	INSERT INTO dbo.tblKartrisCoupons
	VALUES	(@CouponCode, @Reusable, 0, @NowOffset, @StartDate, @EndDate, @DiscountValue, @DiscountType, 1);

	IF @CouponCodeIsFixed = 0
	BEGIN
		UPDATE dbo.tblKartrisCoupons 
		SET CP_CouponCode = @CouponCode + CAST(SCOPE_IDENTITY() as nvarchar(5))
		WHERE CP_ID = SCOPE_IDENTITY();
	END;

Enable Trigger trigKartrisCoupons_DML ON tblKartrisCoupons;


	
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisConfig_UpdateConfigValue]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisConfig_UpdateConfigValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ===========================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get name value pairs for config settings cache
-- ===========================================================
CREATE PROCEDURE [dbo].[_spKartrisConfig_UpdateConfigValue]
(
	@CFG_Name as nvarchar(100),
	@CFG_Value as nvarchar(255)
)
AS
SET NOCOUNT ON;

DISABLE Trigger trigKartrisConfig_DML ON tblKartrisConfig;
	UPDATE	dbo.tblKartrisConfig 
	SET		CFG_Value = @CFG_Value
	WHERE	CFG_Name = @CFG_Name;
ENABLE Trigger trigKartrisConfig_DML ON tblKartrisConfig;

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisConfig_Update]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisConfig_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisConfig_Update]
(
	@CFG_Value nvarchar(255),
	@CFG_DataType char(1),
	@CFG_DisplayType char(1),
	@CFG_DisplayInfo nvarchar(255),
	@CFG_Description nvarchar(255),
	@CFG_VersionAdded real,
	@CFG_DefaultValue nvarchar(255),
	@CFG_Important bit,
	@Original_CFG_Name nvarchar(100)
)
AS
	SET NOCOUNT OFF;
DISABLE Trigger trigKartrisConfig_DML ON tblKartrisConfig;

	UPDATE [tblKartrisConfig] 
	SET [CFG_Value] = @CFG_Value, [CFG_DataType] = @CFG_DataType, [CFG_DisplayType] = @CFG_DisplayType, 
		[CFG_DisplayInfo] = @CFG_DisplayInfo,
		[CFG_Description] = @CFG_Description, [CFG_VersionAdded] = @CFG_VersionAdded, [CFG_DefaultValue] = @CFG_DefaultValue, [CFG_Important] = @CFG_Important
	WHERE (([CFG_Name] = @Original_CFG_Name));
	
ENABLE Trigger trigKartrisConfig_DML ON tblKartrisConfig;

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisConfig_Search]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisConfig_Search]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	BACK END USE
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisConfig_Search]
(
	@ConfigKey as nvarchar(100),
	@ImportantConfig as bit
)
AS
	SET NOCOUNT ON;
	IF @ImportantConfig = 1
	BEGIN
		SELECT        *
		FROM            tblKartrisConfig
		WHERE        (CFG_Name LIKE ''%'' + @ConfigKey + ''%'') AND CFG_Important = 1
	END
	ELSE
	BEGIN
		SELECT        *
		FROM            tblKartrisConfig
		WHERE        (CFG_Name LIKE ''%'' + @ConfigKey + ''%'')
	END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisConfig_GetImportant]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisConfig_GetImportant]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisConfig_GetImportant]
AS
	SET NOCOUNT ON;
SELECT        *
FROM            tblKartrisConfig
WHERE        (CFG_Important = 1)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisConfig_GetforCache]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisConfig_GetforCache]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ===========================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get name value pairs for config settings cache
-- ===========================================================
CREATE PROCEDURE [dbo].[_spKartrisConfig_GetforCache]
AS
	SET NOCOUNT ON;
SELECT        CFG_Name, CFG_Value
FROM            tblKartrisConfig

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisConfig_GetDesc]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisConfig_GetDesc]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ===========================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get name value pairs for config settings cache
-- ===========================================================
CREATE PROCEDURE [dbo].[_spKartrisConfig_GetDesc]
(
	@CFG_Name as nvarchar(100)
)
AS
	SET NOCOUNT ON;
	SELECT	CFG_Description
	FROM	tblKartrisConfig
	WHERE	CFG_Name = @CFG_Name

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisConfig_GetByName]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisConfig_GetByName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisConfig_GetByName](@CFG_Name nvarchar(100))
AS
	SET NOCOUNT ON;
SELECT        *
FROM            tblKartrisConfig
WHERE        (CFG_Name = @CFG_Name)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisConfig_Add]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisConfig_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisConfig_Add]
(
	@CFG_Name nvarchar(100),
	@CFG_Value nvarchar(255),
	@CFG_DataType char(1),
	@CFG_DisplayType char(1),
	@CFG_DisplayInfo nvarchar(255),
	@CFG_Description nvarchar(255),
	@CFG_VersionAdded real,
	@CFG_DefaultValue nvarchar(255),
	@CFG_Important bit
)
AS
	SET NOCOUNT OFF;

DISABLE Trigger trigKartrisConfig_DML ON tblKartrisConfig;
	
	INSERT INTO [tblKartrisConfig] ([CFG_Name], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) 
	VALUES (@CFG_Name, @CFG_Value, @CFG_DataType, @CFG_DisplayType, @CFG_DisplayInfo, @CFG_Description, @CFG_VersionAdded, @CFG_DefaultValue, @CFG_Important);

ENABLE Trigger trigKartrisConfig_DML ON tblKartrisConfig;

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisAttributes_Add]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisAttributes_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisAttributes_Add]
(
	@Type char(1),
	@Live bit,
	@FastEntry bit,
	@ShowFrontend bit,
	@ShowSearch bit,
	@OrderByValue tinyint,
	@Compare char(1),
	@Special bit,
	@NewAttribute_ID tinyint OUT
)
AS
	SET NOCOUNT OFF;

Disable Trigger trigKartrisAttributes_DML ON tblKartrisAttributes;

	INSERT INTO tblKartrisAttributes
	VALUES 
	(@Type, @Live, @FastEntry, @ShowFrontend, @ShowSearch, 
		@OrderByValue, @Compare, @Special);

		
	SELECT @NewAttribute_ID = SCOPE_IDENTITY();
	
Enable Trigger trigKartrisAttributes_DML ON tblKartrisAttributes;



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisAdminRelatedTables_GetByType]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisAdminRelatedTables_GetByType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
 CREATE PROCEDURE [dbo].[_spKartrisAdminRelatedTables_GetByType]
(
	@DataType as char(1)
)

AS
BEGIN

	IF @DataType = ''P''
	BEGIN
		SELECT *, substring(ART_TableName, 11, Len(ART_TableName)) as ShortName
		FROM    tblKartrisAdminRelatedTables
		WHERE		ART_TableOrderProducts IS NOT NULL
		ORDER BY	ART_TableOrderProducts
	END
	IF @DataType = ''O''
	BEGIN
		SELECT *, substring(ART_TableName, 11, Len(ART_TableName)) as ShortName
		FROM    tblKartrisAdminRelatedTables
		WHERE		ART_TableOrderOrders IS NOT NULL
		ORDER BY	ART_TableOrderOrders
	END
	IF @DataType = ''S''
	BEGIN
		SELECT *, substring(ART_TableName, 11, Len(ART_TableName)) as ShortName
		FROM    tblKartrisAdminRelatedTables
		WHERE		ART_TableOrderSessions IS NOT NULL
		ORDER BY	ART_TableOrderSessions
	END
	IF @DataType = ''C''
	BEGIN
		SELECT *, substring(ART_TableName, 11, Len(ART_TableName)) as ShortName
		FROM    tblKartrisAdminRelatedTables
		WHERE		ART_TableOrderContents IS NOT NULL
		ORDER BY	ART_TableOrderContents
	END
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisAdminRelatedTables_Clear]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisAdminRelatedTables_Clear]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
 CREATE PROCEDURE [dbo].[_spKartrisAdminRelatedTables_Clear]
(	
	@DataType as char(1),
	@UserName as nvarchar(100),
	@Password as nvarchar(50),
	@IPAddress as nvarchar(255),
	@Output as nvarchar(MAX) output,
	@Succeeded as bit output
)
AS
BEGIN
	
	DECLARE @Logins as int;
	SELECT	@Logins = Count(tblKartrisLogins.LOGIN_ID)
	FROM	tblKartrisLogins
	WHERE	(tblKartrisLogins.LOGIN_Username = @UserName 
				AND tblKartrisLogins.LOGIN_Password = @Password 
				AND tblKartrisLogins.LOGIN_LIVE = 1);

	IF @Logins <> 1
	BEGIN 
		SET @Output = ''<br/>-------------------------------------------------------------------------<br/>'';
		SET @Output = @Output + ''ERROR: Operation Terminated ..!! Invalid-login <br/> '';
		SET @Output = @Output + ''-------------------------------------------------------------------------<br/><br/>'';
		SET @Succeeded = 0;
		GOTO spExit 
	END

	DECLARE @tblName as nvarchar(250), @trigName as nvarchar(250), 
			@spName as nvarchar(250), @startingIdentity as int,
			@sqlStmt as nvarchar(1000), @Counter as integer,
			@languageTableTypeID as tinyint;

----**********************************************
----**********************************************
----		1.	Disable the DB Triggers
----**********************************************
----**********************************************
	
	PRINT ''--------------------------------------------------------------'';
	PRINT ''=> Disable Triggers (execution started ...)'';
	PRINT ''--------------------------------------------------------------'';
		EXEC dbo._spKartrisDB_DisableAllTriggers;
	PRINT ''(execution finished ...)'';
	PRINT ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'';
	PRINT CAST(@Counter as nvarchar(10)) + '' Objects Affected.'';
	PRINT '''';
	
----************************************************************************************
----************************************************************************************
----		2.	Cleaning Product Related Tables And Reseeding the Identity if exist.
----************************************************************************************
----************************************************************************************

	PRINT ''--------------------------------------------------------------'';
	PRINT ''=> Cleaning records (Products Related)  (execution started ...)'';
	PRINT ''--------------------------------------------------------------'';

	IF @DataType = ''P''
	BEGIN
		DECLARE crsrKartrisRelatedTables CURSOR FOR
		SELECT ART_TableName, ART_TableStartingIdentity
		FROM    tblKartrisAdminRelatedTables
		WHERE		ART_TableOrderProducts IS NOT NULL
		ORDER BY	ART_TableOrderProducts
	END
	IF @DataType = ''O''
	BEGIN
		DECLARE crsrKartrisRelatedTables CURSOR FOR
		SELECT ART_TableName, ART_TableStartingIdentity
		FROM    tblKartrisAdminRelatedTables
		WHERE		ART_TableOrderOrders IS NOT NULL
		ORDER BY	ART_TableOrderOrders
	END
	IF @DataType = ''S''
	BEGIN
		DECLARE crsrKartrisRelatedTables CURSOR FOR
		SELECT ART_TableName, ART_TableStartingIdentity
		FROM    tblKartrisAdminRelatedTables
		WHERE		ART_TableOrderSessions IS NOT NULL
		ORDER BY	ART_TableOrderSessions
	END
	IF @DataType = ''C''
	BEGIN
		DECLARE crsrKartrisRelatedTables CURSOR FOR
		SELECT ART_TableName, ART_TableStartingIdentity
		FROM    tblKartrisAdminRelatedTables
		WHERE		ART_TableOrderContents IS NOT NULL
		ORDER BY	ART_TableOrderContents
	END
	
	OPEN crsrKartrisRelatedTables
	FETCH NEXT FROM crsrKartrisRelatedTables
	INTO @tblName, @startingIdentity;
	
	SET @Output = ''<br/>'';
	SET @Counter = 0;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Counter = @Counter + 1;		
		SET @sqlStmt = ''DELETE FROM '' + @tblName
		IF @tblName = ''tblKartrisCategories'' 
		BEGIN
			SET @sqlStmt = @sqlStmt + '' WHERE CAT_ID <> 0''
		END
		EXECUTE(@sqlStmt)
		
		SELECT @languageTableTypeID = LET_ID 
		FROM tblKartrisLanguageElementTypes
		WHERE LET_Name = @tblName;

		SET @sqlStmt = ''DELETE FROM tblKartrisLanguageElements WHERE LE_TypeID='' 
						+ CAST(@languageTableTypeID as nvarchar(5)) + '';''
		BEGIN TRY
			EXECUTE(@sqlStmt);
		END TRY
		BEGIN CATCH
		END CATCH

		SET @Output = @Output + ''	-->  '' + @tblName + '' cleared successfully.<br/>'';
		IF @startingIdentity  IS NOT NULL
		BEGIN 
			SET @sqlStmt = ''DBCC CHECKIDENT ('''''' + @tblName + '''''', RESEED, '' + CAST(@startingIdentity As nvarchar(5)) + '');''
			EXECUTE(@sqlStmt);
			PRINT ''		Table: '' + @tblName + '' reseeded successfully to '' + CAST(@startingIdentity As nvarchar(5));
		END

		PRINT ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'';
		FETCH NEXT FROM crsrKartrisRelatedTables
		INTO @tblName, @startingIdentity;
	END
	
	CLOSE crsrKartrisRelatedTables
	DEALLOCATE crsrKartrisRelatedTables;	
	PRINT ''(execution finished ...)'';
	PRINT ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'';
	PRINT CAST(@Counter as nvarchar(10)) + '' Objects Affected.'';
	PRINT '''';

	SET @Output = @Output + ''-------------------------------------------------------------------------<br/>'';
	SET @Output = @Output + CAST(@Counter as nvarchar(10)) + '' tables affected.<br/>'';
	SET @Output = @Output + ''-------------------------------------------------------------------------<br/>'';
	
----**********************************************
----**********************************************
----		3.	Enable the DB Triggers
----**********************************************
----**********************************************
	PRINT ''--------------------------------------------------------------'';
	PRINT ''=> Enable Triggers (execution started ...)'';
	PRINT ''--------------------------------------------------------------'';
		EXEC dbo._spKartrisDB_EnableAllTriggers;
	PRINT ''(execution finished ...)'';
	PRINT ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'';
	PRINT CAST(@Counter as nvarchar(10)) + '' Objects Affected.'';
	PRINT '''';

	SET @Succeeded = 1;	

spExit:
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisAdminLog_Search]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisAdminLog_Search]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
 CREATE PROCEDURE [dbo].[_spKartrisAdminLog_Search]
(	
	@Keyword as nvarchar(100),
	@Type as nvarchar(50),
	@From as datetime,
	@To as datetime
)
AS
BEGIN
	
DECLARE @SDate as nvarchar(11);
SET @SDate = CONVERT(VARCHAR(11), @From, 106);
SET @From = CAST(@SDate as datetime)

DECLARE @EDate as nvarchar(20);
SET @EDate = CONVERT(VARCHAR(11), @To, 106) + '' 11:59 PM'';
SET @To = CAST(@EDate as datetime)

	Print ''From'' + Cast(@From as nvarchar(50));
	Print ''To: '' + Cast(@To as nvarchar(50));

	SELECT *, SubString(AL_Query, 0, CHARINDEX(''##'', AL_Query)) as ShortQuery FROM dbo.tblKartrisAdminLog
	WHERE ((AL_Description like ''%'' + @Keyword + ''%'') 
			OR (AL_Query like ''%'' + @Keyword + ''%'') 
			OR (AL_LoginName like ''%'' + @Keyword + ''%''))
		AND (AL_Type like @Type + ''%'') 
		AND (AL_DateStamp BETWEEN @From AND @To)
	ORDER BY AL_DateStamp DESC

END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisAdminLog_PurgeOldData]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisAdminLog_PurgeOldData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
 CREATE PROCEDURE [dbo].[_spKartrisAdminLog_PurgeOldData]
(
	@PurgeDate as datetime
)
AS
BEGIN
	
DECLARE @SDate as nvarchar(11);
SET @SDate = CONVERT(VARCHAR(11), ''1/1/2008'', 106);
DECLARE @From as datetime;
SET @From = CAST(@SDate as datetime)

DECLARE @EDate as nvarchar(20);
SET @EDate = CONVERT(VARCHAR(11), @PurgeDate, 106) + '' 11:59 PM'';
SET @PurgeDate = CAST(@EDate as datetime)

	Print ''From:'' + Cast(@From as nvarchar(50));
	Print ''To  :'' + Cast(@PurgeDate as nvarchar(50));

Disable Trigger trigKartrisAdminLog_DML ON tblKartrisAdminLog;
	DELETE FROM dbo.tblKartrisAdminLog
	WHERE AL_DateStamp BETWEEN @From AND @PurgeDate;
Enable Trigger trigKartrisAdminLog_DML ON tblKartrisAdminLog;


END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisAdminLog_GetByID]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisAdminLog_GetByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisAdminLog_GetByID]
(	
	@LogID as int	
)
AS
BEGIN
	
	SELECT * FROM tblKartrisAdminLog WHERE AL_ID = @LogID;

END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisAdminLog_AddNewAdminLog]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisAdminLog_AddNewAdminLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisAdminLog_AddNewAdminLog]
(	
	@LoginName as nvarchar(100),
	@Type as nvarchar(50),
	@Desc as nvarchar(255),
	@Query as nvarchar(MAX),
	@RelatedID as nvarchar(255),
	@IP as nvarchar(50),
	@NowOffset as datetime
)
AS
BEGIN
	
Disable Trigger trigKartrisAdminLog_DML ON tblKartrisAdminLog;

	INSERT INTO tblKartrisAdminLog
	VALUES (@NowOffset, @LoginName, @Type, @Desc, @Query, @RelatedID, @IP);

Enable Trigger trigKartrisAdminLog_DML ON tblKartrisAdminLog;
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisAttributes_Update]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisAttributes_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisAttributes_Update]
(
	@Type char(1),
	@Live bit,
	@FastEntry bit,
	@ShowFrontend bit,
	@ShowSearch bit,
	@OrderByValue tinyint,
	@Compare char(1),
	@Special bit,
	@Original_AttributeID tinyint	
)
AS
	SET NOCOUNT OFF;

Disable Trigger trigKartrisAttributes_DML ON tblKartrisAttributes;

	UPDATE [tblKartrisAttributes] 
	SET [ATTRIB_Type] = @Type, [ATTRIB_Live] = @Live, [ATTRIB_FastEntry] = @FastEntry, 
		[ATTRIB_ShowFrontend] = @ShowFrontend, [ATTRIB_ShowSearch] = @ShowSearch, 
		[ATTRIB_OrderByValue] = @OrderByValue, [ATTRIB_Compare] = @Compare, 
		[ATTRIB_Special] = @Special 
	WHERE ([ATTRIB_ID] = @Original_AttributeID);

Enable Trigger trigKartrisAttributes_DML ON tblKartrisAttributes;
	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisAttributes_GetByID]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisAttributes_GetByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisAttributes_GetByID]
(
	@AttributeID as tinyint
)
AS
	SET NOCOUNT ON;
SELECT     ATTRIB_ID, ATTRIB_Type, ATTRIB_Live, ATTRIB_FastEntry, ATTRIB_ShowFrontend, ATTRIB_ShowSearch, ATTRIB_OrderByValue, ATTRIB_Compare, 
					  ATTRIB_Special
FROM         tblKartrisAttributes
WHERE     (ATTRIB_ID = @AttributeID)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOptionGroups_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOptionGroups_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisOptionGroups_Update]
(
	@OPTG_BackendName nvarchar(50),
	@OPTG_OptionDisplayType char(1),
	@OPTG_DefOrderByValue tinyint,
	@Original_OPTG_ID smallint
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisOptionGroups_DML ON tblKartrisOptionGroups;
	UPDATE	[tblKartrisOptionGroups] 
	SET		[OPTG_BackendName] = @OPTG_BackendName, [OPTG_OptionDisplayType] = @OPTG_OptionDisplayType, 
			[OPTG_DefOrderByValue] = @OPTG_DefOrderByValue 
	WHERE	(([OPTG_ID] = @Original_OPTG_ID));
Enable Trigger trigKartrisOptionGroups_DML ON tblKartrisOptionGroups;

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOptionGroups_GetGroupPage]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOptionGroups_GetGroupPage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisOptionGroups_GetGroupPage]
(		@PageIndex as tinyint, -- 0 Based index
		@RowsPerPage as smallint,
		@TotalGroups as int OUT
)
AS
	SET NOCOUNT ON;

	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;
	
	SELECT @TotalGroups = Count(1)
	FROM tblKartrisOptionGroups;
	
	With Grps AS
	(
		SELECT	ROW_NUMBER() OVER (ORDER BY OPTG_BackendName ASC) AS Row, 
				OPTG_ID, OPTG_BackendName, OPTG_OptionDisplayType, OPTG_DefOrderByValue
		FROM	tblKartrisOptionGroups
		
	)
	
	

	SELECT *
	FROM Grps
	WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber
	ORDER BY Row ASC;



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOptionGroups_GetByGrpID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOptionGroups_GetByGrpID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisOptionGroups_GetByGrpID]
(
	@OPTG_ID smallint
)
AS
	SET NOCOUNT ON;
SELECT        OPTG_ID, OPTG_BackendName, OPTG_OptionDisplayType, OPTG_DefOrderByValue
FROM            tblKartrisOptionGroups
WHERE OPTG_ID = @OPTG_ID


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOptionGroups_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOptionGroups_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisOptionGroups_Get]
AS
	SET NOCOUNT ON;
SELECT        OPTG_ID, OPTG_BackendName, OPTG_OptionDisplayType, OPTG_DefOrderByValue
FROM            tblKartrisOptionGroups
ORDER BY OPTG_DefOrderByValue

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOptionGroups_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOptionGroups_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisOptionGroups_Add]
(
	@OPTG_BackendName nvarchar(50),
	@OPTG_OptionDisplayType char(1),
	@OPTG_DefOrderByValue tinyint,
	@NewID smallint OUT
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisOptionGroups_DML ON tblKartrisOptionGroups;
	INSERT INTO [tblKartrisOptionGroups] ([OPTG_BackendName], [OPTG_OptionDisplayType], [OPTG_DefOrderByValue]) 
	VALUES (@OPTG_BackendName, @OPTG_OptionDisplayType, @OPTG_DefOrderByValue);
	SELECT @NewID = SCOPE_IDENTITY();
Disable Trigger trigKartrisOptionGroups_DML ON tblKartrisOptionGroups;
	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisObjectConfig_SetValue]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisObjectConfig_SetValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisObjectConfig_SetValue]
(
	@ParentID as bigint,
	@ConfigID as int,
	@ConfigValue as nvarchar(max)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @DefaultValue as nvarchar(max);
	SELECT  @DefaultValue = OC_DefaultValue
	FROM    tblKartrisObjectConfig
	WHERE   (tblKartrisObjectConfig.OC_ID = @ConfigID);
	
	DECLARE @Count as int;
	SELECT     @Count = Count(1)
	FROM         tblKartrisObjectConfigValue
	WHERE     (tblKartrisObjectConfigValue.OCV_ObjectConfigID = @ConfigID) AND (tblKartrisObjectConfigValue.OCV_ParentID = @ParentID);
	
	DISABLE TRIGGER trigKartrisObjectConfigValue_DML ON dbo.tblKartrisObjectConfigValue;
	IF @Count = 1 BEGIN
		UPDATE  tblKartrisObjectConfigValue
		SET OCV_Value = @ConfigValue
		WHERE   (dbo.tblKartrisObjectConfigValue.OCV_ObjectConfigID = @ConfigID) AND (tblKartrisObjectConfigValue.OCV_ParentID = @ParentID)
	END ELSE BEGIN
		INSERT INTO dbo.tblKartrisObjectConfigValue
		VALUES (@ConfigID, @ParentID, @ConfigValue);
	END;
	
	-- Clear un-needed records (NULLs and Value is equal to default)
	DELETE FROM dbo.tblKartrisObjectConfigValue 
	WHERE (OCV_Value IS NULL) OR (OCV_Value = @DefaultValue AND OCV_ObjectConfigID = @ConfigID);
		
	ENABLE TRIGGER trigKartrisObjectConfigValue_DML ON dbo.tblKartrisObjectConfigValue;
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisObjectConfig_GetValue]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisObjectConfig_GetValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisObjectConfig_GetValue]
(
	@ConfigName as nvarchar(100),
	@ParentID as bigint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Count as int;
	
	SELECT     @Count = Count(1)
	FROM         tblKartrisObjectConfigValue INNER JOIN
						  tblKartrisObjectConfig ON tblKartrisObjectConfigValue.OCV_ObjectConfigID = tblKartrisObjectConfig.OC_ID
	WHERE     (tblKartrisObjectConfig.OC_Name = @ConfigName) AND (tblKartrisObjectConfigValue.OCV_ParentID = @ParentID)
	
	IF @Count = 1 BEGIN
		SELECT  tblKartrisObjectConfigValue.OCV_Value
		FROM    tblKartrisObjectConfigValue INNER JOIN
				tblKartrisObjectConfig ON tblKartrisObjectConfigValue.OCV_ObjectConfigID = tblKartrisObjectConfig.OC_ID
		WHERE   (tblKartrisObjectConfig.OC_Name = @ConfigName) AND (tblKartrisObjectConfigValue.OCV_ParentID = @ParentID)
	END ELSE BEGIN
		SELECT OC_DefaultValue FROM tblKartrisObjectConfig WHERE tblKartrisObjectConfig.OC_Name = @ConfigName
	END
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisObjectConfig_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisObjectConfig_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisObjectConfig_Get]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     *
	FROM        tblKartrisObjectConfig
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisNews_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisNews_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisNews_Update]
(
	@N_ID as int,
	@N_DateCreated as datetime,
	@NowOffset as datetime   
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Disable Trigger trigKartrisNews_DML ON tblKartrisNews;
	-- Insert statements for procedure here
	UPDATE tblKartrisNews
	SET N_LastUpdated = @NowOffset, N_DateCreated = @N_DateCreated
	WHERE N_ID = @N_ID;
Enable Trigger trigKartrisNews_DML ON tblKartrisNews;
	
END 

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetParentOrderID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOrders_GetParentOrderID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ===================================================
-- Author:		Medz
-- Create date: 
-- Description:	
-- ===================================================
CREATE PROCEDURE [dbo].[_spKartrisOrders_GetParentOrderID]
(
	@O_ID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT TOP(1) [CO_ParentOrderID] FROM [dbo].[tblKartrisClonedOrders] WHERE [CO_OrderID] = @O_ID ORDER BY [CO_ParentOrderID] DESC;
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetInvoiceRows]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOrders_GetInvoiceRows]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisOrders_GetInvoiceRows]
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
	  ,[IR_OptionsText] FROM tblKartrisInvoiceRows WHERE IR_OrderNumberID = @OrderID;
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetGateways]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOrders_GetGateways]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisOrders_GetGateways]
AS
	SET NOCOUNT ON;
SELECT DISTINCT O_PaymentGateway FROM tblKartrisOrders

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetCustomerTotal]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOrders_GetCustomerTotal]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisOrders_GetCustomerTotal]
(
	@CustomerID as int
)
AS
BEGIN

	SELECT Sum(O_TotalPrice / O_CurrencyRate) as TotalValue
	FROM dbo.tblKartrisOrders LEFT OUTER JOIN
					  tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
	WHERE CO_OrderID IS NULL AND O_DATA IS NOT NULL AND O_CustomerID = @CustomerID AND O_Sent = 1

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetChildOrderID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOrders_GetChildOrderID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ===================================================
-- Author:		Medz
-- Create date: 
-- Description:	
-- ===================================================
CREATE PROCEDURE [dbo].[_spKartrisOrders_GetChildOrderID]
(
	@O_ID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT TOP(1) [CO_OrderID] FROM [dbo].[tblKartrisClonedOrders] WHERE [CO_ParentOrderID] = @O_ID ORDER BY [CO_OrderID] DESC;
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetByStatusCount]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOrders_GetByStatusCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisOrders_GetByStatusCount]
(
	@Callmode varchar(10),
	@O_AffiliatePaymentID int = NULL,
	@O_DateRangeStart smalldatetime = NULL,
	@O_DateRangeEnd smalldatetime = NULL,
	@O_Gateway varchar(10) = NULL,
	@O_GatewayID varchar(30) = NULL
)
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	DECLARE @O_Sent bit;
	DECLARE @O_Invoiced bit;
	DECLARE @O_Paid bit;
	DECLARE @O_Shipped bit ;
	DECLARE @O_CustomerID int;

	IF @Callmode = ''RECENT''
	BEGIN
		SET @O_Sent = 1;
	END
	
	ELSE IF @Callmode = ''INVOICE''
	BEGIN
		SET @O_Sent = 1;
		SET @O_Paid = 0;
		SET @O_Invoiced = 0;
	END
	
	ELSE IF @Callmode = ''DISPATCH''
	BEGIN
		SET @O_Sent = 1; 
		SET @O_Paid = 1;
		SET @O_Shipped = 0;
	END

	ELSE IF @Callmode = ''COMPLETE''
	BEGIN
		SET @O_Paid = 1;
		SET @O_Shipped = 1;
	END
	
	ELSE IF @Callmode = ''PAYMENT''
	BEGIN
		SET @O_Sent = 1; 
		SET @O_Paid = 0; 
		SET @O_Invoiced = 1;
	END
	
	ELSE IF @Callmode = ''UNFINISHED''
	BEGIN
		SET @O_Sent = 0;
	END
	
	IF @Callmode <> ''CUSTOMER''
	BEGIN
		SET @O_CustomerID = NULL;
	END	
	ELSE
		BEGIN
			SET @O_CustomerID = @O_GatewayID;
		END

	IF @Callmode <> ''AFFILIATE''
	BEGIN
		SET @O_AffiliatePaymentID = NULL;
	END

	IF @Callmode <> ''BYDATE''
		BEGIN
			SET @O_DateRangeStart = NULL;
			SET @O_DateRangeEnd = NULL;
		END
	ELSE
		BEGIN
			SET @O_Sent = 1;
		END

	IF @Callmode <> ''GATEWAY''
		BEGIN
			SET @O_Gateway = NULL;
			IF @Callmode <> ''SEARCH''
				BEGIN
					SET @O_GatewayID = NULL;
				END
		END;


	IF @Callmode = ''RECENT'' OR @Callmode = ''INVOICE'' OR @Callmode = ''DISPATCH'' OR @Callmode = ''COMPLETE'' OR @Callmode = ''PAYMENT'' OR @Callmode = ''UNFINISHED''
		BEGIN
			SELECT count(1) 
			FROM         tblKartrisOrders LEFT OUTER JOIN
					  tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
			WHERE     (O_Sent = COALESCE (@O_Sent, O_Sent)) AND (O_Invoiced = COALESCE (@O_Invoiced, O_Invoiced)) AND (O_Paid = COALESCE (@O_Paid, O_Paid)) AND 
								  (O_Shipped = COALESCE (@O_Shipped, O_Shipped)) 
		END
	ELSE
		IF @Callmode = ''SEARCH''
			BEGIN
				SELECT count(1) 
				FROM         tblKartrisOrders LEFT OUTER JOIN
					  tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
				WHERE     (O_BillingAddress LIKE ''%'' + @O_GatewayID + ''%'') OR (O_ShippingAddress LIKE ''%'' + @O_GatewayID + ''%'')
			END
		ELSE
			BEGIN
				SELECT count(1) 
				FROM         tblKartrisOrders LEFT OUTER JOIN
					  tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
				WHERE     (O_Sent = COALESCE (@O_Sent, O_Sent)) AND (O_AffiliatePaymentID = COALESCE (@O_AffiliatePaymentID, O_AffiliatePaymentID)) AND 
									  (O_Date >= COALESCE (@O_DateRangeStart, O_Date)) AND (O_Date <= COALESCE (@O_DateRangeEnd, O_Date)) AND (O_PaymentGateWay = COALESCE (@O_Gateway, O_PaymentGateWay)) 
										AND (O_ReferenceCode = COALESCE (@O_GatewayID, O_ReferenceCode)) AND (O_CustomerID = COALESCE (@O_CustomerID, O_CustomerID))
			END
END






' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetByStatus]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOrders_GetByStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisOrders_GetByStatus]
(
	@Callmode varchar(10),
	@O_AffiliatePaymentID int = NULL,
	@O_DateRangeStart smalldatetime = NULL,
	@O_DateRangeEnd smalldatetime = NULL,
	@O_Gateway varchar(10) = NULL,
	@O_GatewayID varchar(30) = NULL,
	@PageIndex as tinyint, -- 0 Based index
	@Limit smallint = 50
)
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @Limit) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @Limit - 1;

	DECLARE @O_Sent bit;
	DECLARE @O_Invoiced bit;
	DECLARE @O_Paid bit;
	DECLARE @O_Shipped bit ;
	DECLARE @O_CustomerID int;

	IF @Callmode = ''RECENT''
	BEGIN
		SET @O_Sent = 1;
	END
	
	ELSE IF @Callmode = ''INVOICE''
	BEGIN
		SET @O_Sent = 1;
		SET @O_Paid = 0;
		SET @O_Invoiced = 0;
	END
	
	ELSE IF @Callmode = ''DISPATCH''
	BEGIN
		SET @O_Sent = 1; 
		SET @O_Paid = 1;
		SET @O_Shipped = 0;
	END

	ELSE IF @Callmode = ''COMPLETE''
	BEGIN
		SET @O_Paid = 1;
		SET @O_Shipped = 1;
	END
	
	ELSE IF @Callmode = ''PAYMENT''
	BEGIN
		SET @O_Sent = 1; 
		SET @O_Paid = 0; 
		SET @O_Invoiced = 1;
	END
	
	ELSE IF @Callmode = ''UNFINISHED''
	BEGIN
		SET @O_Sent = 0;
	END
	
	IF @Callmode <> ''CUSTOMER''
	BEGIN
		SET @O_CustomerID = NULL;
	END	
	ELSE
		BEGIN
			SET @O_CustomerID = @O_GatewayID;
		END

	IF @Callmode <> ''AFFILIATE''
	BEGIN
		SET @O_AffiliatePaymentID = NULL;
	END

	IF @Callmode <> ''BYDATE''
		BEGIN
			SET @O_DateRangeStart = NULL;
			SET @O_DateRangeEnd = NULL;
		END
	ELSE
		BEGIN
			SET @O_Sent = 1;
		END

	IF @Callmode <> ''GATEWAY''
		BEGIN
			SET @O_Gateway = NULL;
			IF @Callmode <> ''SEARCH''
				BEGIN
					SET @O_GatewayID = NULL;
				END
		END;

	
	IF @Callmode = ''RECENT'' OR @Callmode = ''INVOICE'' OR @Callmode = ''DISPATCH'' OR @Callmode = ''COMPLETE'' OR @Callmode = ''PAYMENT'' OR @Callmode = ''UNFINISHED''
		BEGIN
			WITH OrdersList AS
			(
			SELECT     ROW_NUMBER() OVER (ORDER BY O_ID DESC) AS Row,O_ID, O_Date, O_TotalPrice, O_CustomerID, O_Sent, O_Invoiced, O_Shipped, O_Paid, O_CurrencyID, O_Status,
						substring(O_BillingAddress,0,charindex(char(13)+char(10),O_BillingAddress)) as O_BillingName,O_LanguageID, tblKartrisClonedOrders.CO_OrderID
			FROM         tblKartrisOrders LEFT OUTER JOIN
					  tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
			WHERE     (O_Sent = COALESCE (@O_Sent, O_Sent)) AND (O_Invoiced = COALESCE (@O_Invoiced, O_Invoiced)) AND (O_Paid = COALESCE (@O_Paid, O_Paid)) AND 
								  (O_Shipped = COALESCE (@O_Shipped, O_Shipped))
			)
			SELECT *
			FROM OrdersList
			WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber;
		END
	ELSE
		IF @Callmode = ''SEARCH''
			BEGIN
				WITH OrdersList AS
			(
			SELECT ROW_NUMBER() OVER (ORDER BY O_ID DESC) AS Row,O_ID, O_Date, O_TotalPrice, O_CustomerID, O_Sent, O_Invoiced, O_Shipped, O_Paid, O_CurrencyID, O_Status,
						substring(O_BillingAddress,0,charindex(char(13)+char(10),O_BillingAddress)) as O_BillingName,O_LanguageID, tblKartrisClonedOrders.CO_OrderID
				FROM         tblKartrisOrders LEFT OUTER JOIN
					  tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
				WHERE     (O_BillingAddress LIKE ''%'' + @O_GatewayID + ''%'') OR (O_ShippingAddress LIKE ''%'' + @O_GatewayID + ''%'')
			)
			SELECT *
				FROM OrdersList
				WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber;
			END
		ELSE
		BEGIN
			WITH OrdersList AS
			(
			SELECT     ROW_NUMBER() OVER (ORDER BY O_ID DESC) AS Row,O_ID, O_Date, O_TotalPrice, O_CustomerID, O_Sent, O_Invoiced, O_Shipped, O_Paid, O_CurrencyID, O_Status,
						substring(O_BillingAddress,0,charindex(char(13)+char(10),O_BillingAddress)) as O_BillingName,O_LanguageID, tblKartrisClonedOrders.CO_OrderID
			FROM         tblKartrisOrders LEFT OUTER JOIN
					  tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
			WHERE     (O_Sent = COALESCE (@O_Sent, O_Sent)) AND (O_AffiliatePaymentID = COALESCE (@O_AffiliatePaymentID, O_AffiliatePaymentID)) AND 
								  (O_Date >= COALESCE (@O_DateRangeStart, O_Date)) AND (O_Date <= COALESCE (@O_DateRangeEnd, O_Date)) AND (O_PaymentGateWay = COALESCE (@O_Gateway, O_PaymentGateWay)) 
									AND (O_ReferenceCode = COALESCE (@O_GatewayID, O_ReferenceCode)) AND (O_CustomerID = COALESCE (@O_CustomerID, O_CustomerID))
			)
			SELECT *
				FROM OrdersList
				WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber;
		END
		


	
END





' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPayments_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPayments_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: 31-10-2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPayments_Update]
(
		   @Payment_ID int,
		   @Payment_CustomerID int,
		   @Payment_Date smalldatetime,
		   @Payment_Amount real,
		   @Payment_CurrencyID tinyint,
		   @Payment_ReferenceNo nvarchar(100),
		   @Payment_GateWay nvarchar(20),
		   @Payment_CurrencyRate real
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

Disable Trigger trigKartrisPayments_DML ON tblKartrisPayments;
	UPDATE [tblKartrisPayments] SET [Payment_CustomerID] = @Payment_CustomerID
								   ,[Payment_Date] =  @Payment_Date
								   ,[Payment_Amount] = @Payment_Amount
								   ,[Payment_CurrencyID] = @Payment_CurrencyID
								   ,[Payment_ReferenceNo] =@Payment_ReferenceNo
								   ,[Payment_Gateway] = @Payment_Gateway
								   ,[Payment_CurrencyRate] = @Payment_CurrencyRate
		WHERE Payment_ID = @Payment_ID;
	Select @Payment_ID;
Enable Trigger trigKartrisPayments_DML ON tblKartrisPayments;	
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPayments_GetUserTotal]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPayments_GetUserTotal]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPayments_GetUserTotal]
(
	@CustomerID as int
)
AS
BEGIN

	SELECT Sum(Payment_Amount / Payment_CurrencyRate) as TotalValue
	FROM dbo.tblKartrisPayments WHERE Payment_CustomerID = @CustomerID
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPayments_GetLinkedOrders]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPayments_GetLinkedOrders]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPayments_GetLinkedOrders]
(
		   @Payment_ID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     tblKartrisOrderPaymentLink.*, tblKartrisOrders.O_TotalPrice, 
					  tblKartrisOrders.O_CurrencyID
FROM         tblKartrisOrderPaymentLink LEFT OUTER JOIN
					  tblKartrisOrders ON tblKartrisOrderPaymentLink.OP_OrderID = tblKartrisOrders.O_ID
WHERE     (tblKartrisOrderPaymentLink.OP_PaymentID = @Payment_ID)
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPayments_GetFilteredList_s]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPayments_GetFilteredList_s]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: 31-10-2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPayments_GetFilteredList_s]
(
		   @FilterType as nvarchar(1),
		   @Payment_Gateway nvarchar(20),
		   @Payment_Date smalldatetime
		   )
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF @FilterType = ''a''
	BEGIN
		SELECT count(1) FROM [tblKartrisPayments]
	END
	
	ELSE IF @FilterType = ''d''
	BEGIN
		SELECT count(1) FROM [tblKartrisPayments] WHERE Payment_Date = @Payment_Date 
	END
	
	ELSE IF @FilterType = ''g''
	BEGIN
		SELECT count(1) FROM [tblKartrisPayments] WHERE Payment_Gateway = @Payment_Gateway
	END				
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPayments_GetFilteredList]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPayments_GetFilteredList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: 31-10-2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPayments_GetFilteredList]
(
		   @FilterType as nvarchar(1),
		   @Payment_Gateway nvarchar(20),
		   @Payment_Date smalldatetime,
		   @PageIndex as tinyint, -- 0 Based index
		   @Limit smallint = 50
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @Limit) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @Limit - 1;

	IF @FilterType = ''a''
	BEGIN
		WITH PaymentsList AS (SELECT ROW_NUMBER() OVER (ORDER BY Payment_ID DESC) AS SortRow,tblKartrisPayments.*,
		tblKartrisUsers.U_AccountHolderName FROM tblKartrisPayments LEFT OUTER JOIN tblKartrisUsers ON 
		tblKartrisPayments.Payment_CustomerID = tblKartrisUsers.U_ID)
		SELECT * FROM PaymentsList WHERE SortRow BETWEEN @StartRowNumber AND @EndRowNumber;
	END
	
	ELSE IF @FilterType = ''d''
	BEGIN
		WITH PaymentsList AS (SELECT ROW_NUMBER() OVER (ORDER BY Payment_ID DESC) AS SortRow,tblKartrisPayments.*,
		tblKartrisUsers.U_AccountHolderName FROM tblKartrisPayments LEFT OUTER JOIN tblKartrisUsers ON 
		tblKartrisPayments.Payment_CustomerID = tblKartrisUsers.U_ID
		--WHERE Payment_Date >= @Payment_DateRangeStart AND Payment_Date <= @Payment_DateRangeEnd)
		WHERE Payment_Date = @Payment_Date)
		SELECT * FROM PaymentsList WHERE SortRow BETWEEN @StartRowNumber AND @EndRowNumber;
	END
	
	ELSE IF @FilterType = ''g''
	BEGIN
		WITH PaymentsList AS (SELECT ROW_NUMBER() OVER (ORDER BY Payment_ID DESC) AS SortRow,tblKartrisPayments.*,
		tblKartrisUsers.U_AccountHolderName FROM tblKartrisPayments LEFT OUTER JOIN tblKartrisUsers ON 
		tblKartrisPayments.Payment_CustomerID = tblKartrisUsers.U_ID WHERE Payment_Gateway = @Payment_Gateway)
		SELECT * FROM PaymentsList WHERE SortRow BETWEEN @StartRowNumber AND @EndRowNumber;
	END				
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPayments_GetCustomerTotal]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPayments_GetCustomerTotal]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPayments_GetCustomerTotal]
(
	@CustomerID as int
)
AS
BEGIN

	SELECT Sum(Payment_Amount / Payment_CurrencyRate) as TotalValue
	FROM dbo.tblKartrisPayments WHERE Payment_CustomerID = @CustomerID
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPayments_GetByCustomerID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPayments_GetByCustomerID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPayments_GetByCustomerID]
(
		   @Payment_CustomerID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * FROM tblKartrisPayments WHERE Payment_CustomerID = @Payment_CustomerID ORDER BY Payment_ID DESC;
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPayments_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPayments_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPayments_Get]
(
		   @Payment_ID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * FROM tblKartrisPayments WHERE Payment_ID = @Payment_ID;
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPayments_DeleteLinkedOrders]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPayments_DeleteLinkedOrders]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPayments_DeleteLinkedOrders]
(
		   @OP_PaymentID int
)
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

Disable Trigger trigKartrisOrderPaymentLink_DML ON tblKartrisOrderPaymentLink;	
	DELETE FROM [tblKartrisOrderPaymentLink] WHERE [OP_PaymentID] = @OP_PaymentID
	SELECT @OP_PaymentID;
Enable Trigger trigKartrisOrderPaymentLink_DML ON tblKartrisOrderPaymentLink;	
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPayments_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPayments_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPayments_Delete]
(
		   @Payment_ID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

	Disable Trigger trigKartrisPayments_DML ON tblKartrisPayments;	
		DELETE FROM [tblKartrisPayments] WHERE Payment_ID = @Payment_ID;
	Enable Trigger trigKartrisPayments_DML ON tblKartrisPayments;

	DISABLE TRIGGER [dbo].[trigKartrisOrderPaymentLink_DML] ON [dbo].[tblKartrisOrderPaymentLink];	
		DELETE FROM dbo.tblKartrisOrderPaymentLink WHERE OP_PaymentID = @Payment_ID;
	ENABLE TRIGGER [dbo].[trigKartrisOrderPaymentLink_DML] ON [dbo].[tblKartrisOrderPaymentLink];	

	SELECT @Payment_ID;

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPayments_AddLinkedOrder]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPayments_AddLinkedOrder]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPayments_AddLinkedOrder]
(
		   @OP_PaymentID int,
		   @OP_OrderID int,
		   @OP_OrderCanceled bit
)
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

Disable Trigger trigKartrisOrderPaymentLink_DML ON tblKartrisOrderPaymentLink;	
	INSERT INTO [tblKartrisOrderPaymentLink]
		   ([OP_PaymentID]
		   ,[OP_OrderID]
		   ,[OP_OrderCanceled])
	 VALUES
		   (@OP_PaymentID,@OP_OrderID,@OP_OrderCanceled)

	SELECT @OP_PaymentID;
Enable Trigger trigKartrisOrderPaymentLink_DML ON tblKartrisOrderPaymentLink;	
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPayments_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPayments_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: 31-10-2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPayments_Add]
(
		   @Payment_CustomerID int,
		   @Payment_Date smalldatetime,
		   @Payment_Amount real,
		   @Payment_CurrencyID tinyint,
		   @Payment_ReferenceNo nvarchar(100),
		   @Payment_GateWay nvarchar(20),
		   @Payment_CurrencyRate real
)
AS
BEGIN
	DECLARE @Payment_ID INT
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

Disable Trigger trigKartrisPayments_DML ON tblKartrisPayments;	
	INSERT INTO [tblKartrisPayments]
		   ([Payment_CustomerID]
		   ,[Payment_Date]
		   ,[Payment_Amount]
		   ,[Payment_CurrencyID]
		   ,[Payment_ReferenceNo]
		   ,[Payment_Gateway]
		   ,[Payment_CurrencyRate]
		   )
	 VALUES
		   (@Payment_CustomerID,
		   @Payment_Date,
		   @Payment_Amount,
		   @Payment_CurrencyID,
		   @Payment_ReferenceNo,
		   @Payment_GateWay,
		   @Payment_CurrencyRate)

	SET @Payment_ID = SCOPE_IDENTITY();
	SELECT @Payment_ID;
Enable Trigger trigKartrisPayments_DML ON tblKartrisPayments;	
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPages_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPages_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPages_Update]
(
	@Page_ID as smallint,
	@Page_Name as nvarchar(50),
	@Page_ParentID as smallint,
	@Page_Live as bit,
	@NowOffset as datetime
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Disable Trigger trigKartrisPages_DML ON tblKartrisPages;
	-- Insert statements for procedure here
	UPDATE tblKartrisPages 
	SET Page_Name = @Page_Name, Page_ParentID = @Page_ParentID, Page_LastUpdated = @NowOffset, Page_Live = @Page_Live
	WHERE Page_ID = @Page_ID;
Enable Trigger trigKartrisPages_DML ON tblKartrisPages;
	
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPages_GetNames]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPages_GetNames]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPages_GetNames]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	SELECT Page_ID, Page_Name
	FROM dbo.tblKartrisPages;	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisKnowledgeBase_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisKnowledgeBase_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisKnowledgeBase_Update]
(
	@KB_ID as int,
	@KB_Live as bit,
	@NowOffset_Created as smalldatetime,
	@NowOffset_Updated as smalldatetime
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Disable Trigger trigKartrisKnowledgeBase_DML ON tblKartrisKnowledgeBase;
	-- Insert statements for procedure here
	UPDATE tblKartrisKnowledgeBase 
	SET KB_DateCreated = @NowOffset_Created, KB_LastUpdated = @NowOffset_Updated, KB_Live = @KB_Live
	WHERE KB_ID = @KB_ID;
Enable Trigger trigKartrisKnowledgeBase_DML ON tblKartrisKnowledgeBase;
	
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLanguageElementTypeFields_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLanguageElementTypeFields_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisLanguageElementTypeFields_Get]

AS
	SET NOCOUNT ON;
SELECT     tblKartrisLanguageElementTypeFields.LET_ID, tblKartrisLanguageElementTypes.LET_Name, tblKartrisLanguageElementTypeFields.LEFN_ID, 
					  tblKartrisLanguageElementFieldNames.LEFN_Name, tblKartrisLanguageElementFieldNames.LEFN_DisplayText, 
					  tblKartrisLanguageElementFieldNames.LEFN_CssClass, tblKartrisLanguageElementTypeFields.LEFN_IsMandatory, 
					  tblKartrisLanguageElementFieldNames.LEFN_IsMultiLine, tblKartrisLanguageElementFieldNames.LEFN_UseHTMLEditor, 
					  tblKartrisLanguageElementFieldNames.LEFN_SearchEngineInput
FROM         tblKartrisLanguageElementTypeFields INNER JOIN
					  tblKartrisLanguageElementFieldNames ON tblKartrisLanguageElementTypeFields.LEFN_ID = tblKartrisLanguageElementFieldNames.LEFN_ID INNER JOIN
					  tblKartrisLanguageElementTypes ON tblKartrisLanguageElementTypeFields.LET_ID = tblKartrisLanguageElementTypes.LET_ID

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLanguageStrings_Translate]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLanguageStrings_Translate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLanguageStrings_Translate]
(
	@LanguageID tinyint,
	@FrontBack nvarchar(1),
	@Name nvarchar(255),
	@Value nvarchar(MAX),
	@Description nvarchar(255)
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisLanguageStrings_DML ON tblKartrisLanguageStrings;
	UPDATE [tblKartrisLanguageStrings] 
	SET [LS_Value] = @Value, [LS_Description] = @Description
	WHERE [LS_LANGID] = @LanguageID AND [LS_FrontBack] = @FrontBack AND [LS_Name] = @Name ;
Enable Trigger trigKartrisLanguageStrings_DML ON tblKartrisLanguageStrings;

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLanguageStrings_SearchForUpdate]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLanguageStrings_SearchForUpdate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	BACK END USE
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLanguageStrings_SearchForUpdate]
(
	@SearchBy as nvarchar(10),
	@Key as nvarchar(100),
	@FrontBack as nvarchar(1),
	@DefaultLANG_ID as tinyint,
	@LANG_ID as tinyint
)
AS
	SET NOCOUNT ON;

	IF @SearchBy = ''Name''
	BEGIN
		SELECT     tblKartrisLanguageStrings.LS_FrontBack, tblKartrisLanguageStrings.LS_ClassName, tblKartrisLanguageStrings.LS_Name, tblKartrisLanguageStrings.LS_Value, 
					  tblKartrisLanguageStrings.LS_Description, tblKartrisLanguageStrings_1.LS_Value AS Value, tblKartrisLanguageStrings_1.LS_Description AS [Desc]
		FROM         tblKartrisLanguageStrings LEFT OUTER JOIN
					  tblKartrisLanguageStrings AS tblKartrisLanguageStrings_1 ON tblKartrisLanguageStrings.LS_FrontBack = tblKartrisLanguageStrings_1.LS_FrontBack AND 
					  tblKartrisLanguageStrings.LS_Name = tblKartrisLanguageStrings_1.LS_Name AND 
					  tblKartrisLanguageStrings.LS_ClassName = tblKartrisLanguageStrings_1.LS_ClassName
		WHERE   (tblKartrisLanguageStrings.LS_LANGID = @DefaultLANG_ID) AND (tblKartrisLanguageStrings.LS_FrontBack LIKE ''%'' + @FrontBack + ''%'' ) AND (tblKartrisLanguageStrings.LS_Name LIKE ''%'' + @Key + ''%'')
				AND (tblKartrisLanguageStrings.LS_ClassName IS NOT NULL) AND (tblKartrisLanguageStrings_1.LS_LangID = @LANG_ID)
	END
	
	IF @SearchBy = ''Value''
	BEGIN
		SELECT     tblKartrisLanguageStrings.LS_FrontBack, tblKartrisLanguageStrings.LS_ClassName, tblKartrisLanguageStrings.LS_Name, tblKartrisLanguageStrings.LS_Value, 
					  tblKartrisLanguageStrings.LS_Description, tblKartrisLanguageStrings_1.LS_Value AS Value, tblKartrisLanguageStrings_1.LS_Description AS [Desc]
		FROM         tblKartrisLanguageStrings LEFT OUTER JOIN
					  tblKartrisLanguageStrings AS tblKartrisLanguageStrings_1 ON tblKartrisLanguageStrings.LS_FrontBack = tblKartrisLanguageStrings_1.LS_FrontBack AND 
					  tblKartrisLanguageStrings.LS_Name = tblKartrisLanguageStrings_1.LS_Name AND 
					  tblKartrisLanguageStrings.LS_ClassName = tblKartrisLanguageStrings_1.LS_ClassName
		WHERE   (tblKartrisLanguageStrings.LS_LANGID = @DefaultLANG_ID) AND (tblKartrisLanguageStrings.LS_FrontBack LIKE ''%'' + @FrontBack + ''%'' ) AND (tblKartrisLanguageStrings.LS_Value LIKE ''%'' + @Key + ''%'')
				AND (tblKartrisLanguageStrings.LS_ClassName IS NOT NULL) AND (tblKartrisLanguageStrings_1.LS_LangID = @LANG_ID)
	END
	
	IF @SearchBy = ''ClassName''
	BEGIN
		SELECT     tblKartrisLanguageStrings.LS_FrontBack, tblKartrisLanguageStrings.LS_ClassName, tblKartrisLanguageStrings.LS_Name, tblKartrisLanguageStrings.LS_Value, 
					  tblKartrisLanguageStrings.LS_Description, tblKartrisLanguageStrings_1.LS_Value AS Value, tblKartrisLanguageStrings_1.LS_Description AS [Desc]
		FROM         tblKartrisLanguageStrings LEFT OUTER JOIN
					  tblKartrisLanguageStrings AS tblKartrisLanguageStrings_1 ON tblKartrisLanguageStrings.LS_FrontBack = tblKartrisLanguageStrings_1.LS_FrontBack AND 
					  tblKartrisLanguageStrings.LS_Name = tblKartrisLanguageStrings_1.LS_Name AND 
					  tblKartrisLanguageStrings.LS_ClassName = tblKartrisLanguageStrings_1.LS_ClassName
		WHERE   (tblKartrisLanguageStrings.LS_LANGID = @DefaultLANG_ID) AND (tblKartrisLanguageStrings.LS_FrontBack LIKE ''%'' + @FrontBack + ''%'' ) AND (tblKartrisLanguageStrings.LS_ClassName LIKE ''%'' + @Key + ''%'')
				AND (tblKartrisLanguageStrings.LS_ClassName IS NOT NULL) AND (tblKartrisLanguageStrings_1.LS_LangID = @LANG_ID)
	END
	
	IF @SearchBy = ''''
	BEGIN
		SELECT     tblKartrisLanguageStrings.LS_FrontBack, tblKartrisLanguageStrings.LS_ClassName, tblKartrisLanguageStrings.LS_Name, tblKartrisLanguageStrings.LS_Value, 
					  tblKartrisLanguageStrings.LS_Description, tblKartrisLanguageStrings_1.LS_Value AS Value, tblKartrisLanguageStrings_1.LS_Description AS [Desc]
		FROM         tblKartrisLanguageStrings LEFT OUTER JOIN
					  tblKartrisLanguageStrings AS tblKartrisLanguageStrings_1 ON tblKartrisLanguageStrings.LS_FrontBack = tblKartrisLanguageStrings_1.LS_FrontBack AND 
					  tblKartrisLanguageStrings.LS_Name = tblKartrisLanguageStrings_1.LS_Name
		WHERE   (tblKartrisLanguageStrings.LS_LANGID = @DefaultLANG_ID) AND (tblKartrisLanguageStrings.LS_FrontBack LIKE ''%'' + @FrontBack + ''%'' )
				AND ((tblKartrisLanguageStrings.LS_Name LIKE ''%'' + @Key + ''%'') OR (tblKartrisLanguageStrings.LS_Value LIKE ''%'' + @Key + ''%'') OR (tblKartrisLanguageStrings.LS_ClassName LIKE ''%'' + @Key + ''%''))
				AND (tblKartrisLanguageStrings_1.LS_LangID = @LANG_ID)
	END

	

--USE [KartrisSQL]
--GO
--/****** Object:  StoredProcedure [dbo].[_spKartrisLanguageStrings_SearchForUpdate]    Script Date: 08/17/2009 10:15:17 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--
---- =============================================
---- Author:		Mohammad
---- Create date: <Create Date,,>
---- Description:	BACK END USE
---- =============================================
--ALTER PROCEDURE [dbo].[_spKartrisLanguageStrings_SearchForUpdate]
--(
--	@SearchBy as nvarchar(10),
--	@Key as nvarchar(100),
--	@FrontBack as nvarchar(1),
--	@DefaultLANG_ID as tinyint,
--	@LANG_ID as tinyint
--)
--AS
--	SET NOCOUNT ON;
--
--	IF @SearchBy = ''Name''
--	BEGIN
--		SELECT     tblKartrisLanguageStrings.LS_FrontBack, tblKartrisLanguageStrings.LS_ClassName, tblKartrisLanguageStrings.LS_Name, tblKartrisLanguageStrings.LS_Value, 
--                      tblKartrisLanguageStrings.LS_Description, tblKartrisLanguageStrings_1.LS_Value AS Value, tblKartrisLanguageStrings_1.LS_Description AS [Desc]
--		FROM         tblKartrisLanguageStrings LEFT OUTER JOIN
--                      tblKartrisLanguageStrings AS tblKartrisLanguageStrings_1 ON tblKartrisLanguageStrings.LS_FrontBack = tblKartrisLanguageStrings_1.LS_FrontBack AND 
--                      tblKartrisLanguageStrings.LS_Name = tblKartrisLanguageStrings_1.LS_Name AND 
--                      tblKartrisLanguageStrings.LS_ClassName = tblKartrisLanguageStrings_1.LS_ClassName
--		WHERE   (tblKartrisLanguageStrings.LS_LANGID = @DefaultLANG_ID) AND (tblKartrisLanguageStrings.LS_FrontBack LIKE ''%'' + @FrontBack + ''%'' ) AND (tblKartrisLanguageStrings.LS_Name LIKE ''%'' + @Key + ''%'')
--				AND (tblKartrisLanguageStrings.LS_ClassName IS NOT NULL) AND (tblKartrisLanguageStrings_1.LS_LangID = @LANG_ID) AND (tblKartrisLanguageStrings.LS_VirtualPath <> ''Install.aspx'')
--	END
--	
--	IF @SearchBy = ''Value''
--	BEGIN
--		SELECT     tblKartrisLanguageStrings.LS_FrontBack, tblKartrisLanguageStrings.LS_ClassName, tblKartrisLanguageStrings.LS_Name, tblKartrisLanguageStrings.LS_Value, 
--                      tblKartrisLanguageStrings.LS_Description, tblKartrisLanguageStrings_1.LS_Value AS Value, tblKartrisLanguageStrings_1.LS_Description AS [Desc]
--		FROM         tblKartrisLanguageStrings LEFT OUTER JOIN
--                      tblKartrisLanguageStrings AS tblKartrisLanguageStrings_1 ON tblKartrisLanguageStrings.LS_FrontBack = tblKartrisLanguageStrings_1.LS_FrontBack AND 
--                      tblKartrisLanguageStrings.LS_Name = tblKartrisLanguageStrings_1.LS_Name AND 
--                      tblKartrisLanguageStrings.LS_ClassName = tblKartrisLanguageStrings_1.LS_ClassName
--		WHERE   (tblKartrisLanguageStrings.LS_LANGID = @DefaultLANG_ID) AND (tblKartrisLanguageStrings.LS_FrontBack LIKE ''%'' + @FrontBack + ''%'' ) AND (tblKartrisLanguageStrings.LS_Value LIKE ''%'' + @Key + ''%'')
--				AND (tblKartrisLanguageStrings.LS_ClassName IS NOT NULL) AND (tblKartrisLanguageStrings_1.LS_LangID = @LANG_ID) AND (tblKartrisLanguageStrings.LS_VirtualPath <> ''Install.aspx'')
--	END
--	
--	IF @SearchBy = ''ClassName''
--	BEGIN
--		SELECT     tblKartrisLanguageStrings.LS_FrontBack, tblKartrisLanguageStrings.LS_ClassName, tblKartrisLanguageStrings.LS_Name, tblKartrisLanguageStrings.LS_Value, 
--                      tblKartrisLanguageStrings.LS_Description, tblKartrisLanguageStrings_1.LS_Value AS Value, tblKartrisLanguageStrings_1.LS_Description AS [Desc]
--		FROM         tblKartrisLanguageStrings LEFT OUTER JOIN
--                      tblKartrisLanguageStrings AS tblKartrisLanguageStrings_1 ON tblKartrisLanguageStrings.LS_FrontBack = tblKartrisLanguageStrings_1.LS_FrontBack AND 
--                      tblKartrisLanguageStrings.LS_Name = tblKartrisLanguageStrings_1.LS_Name AND 
--                      tblKartrisLanguageStrings.LS_ClassName = tblKartrisLanguageStrings_1.LS_ClassName
--		WHERE   (tblKartrisLanguageStrings.LS_LANGID = @DefaultLANG_ID) AND (tblKartrisLanguageStrings.LS_FrontBack LIKE ''%'' + @FrontBack + ''%'' ) AND (tblKartrisLanguageStrings.LS_ClassName LIKE ''%'' + @Key + ''%'')
--				AND (tblKartrisLanguageStrings.LS_ClassName IS NOT NULL) AND (tblKartrisLanguageStrings_1.LS_LangID = @LANG_ID)
--	END
--	
--	IF @SearchBy = ''''
--	BEGIN
--		SELECT     tblKartrisLanguageStrings.LS_FrontBack, tblKartrisLanguageStrings.LS_ClassName, tblKartrisLanguageStrings.LS_Name, tblKartrisLanguageStrings.LS_Value, 
--                      tblKartrisLanguageStrings.LS_Description, tblKartrisLanguageStrings_1.LS_Value AS Value, tblKartrisLanguageStrings_1.LS_Description AS [Desc]
--		FROM         tblKartrisLanguageStrings LEFT OUTER JOIN
--                      tblKartrisLanguageStrings AS tblKartrisLanguageStrings_1 ON tblKartrisLanguageStrings.LS_FrontBack = tblKartrisLanguageStrings_1.LS_FrontBack AND 
--                      tblKartrisLanguageStrings.LS_Name = tblKartrisLanguageStrings_1.LS_Name AND 
--                      tblKartrisLanguageStrings.LS_ClassName = tblKartrisLanguageStrings_1.LS_ClassName
--		WHERE   (tblKartrisLanguageStrings.LS_LANGID = @DefaultLANG_ID) AND (tblKartrisLanguageStrings.LS_FrontBack LIKE ''%'' + @FrontBack + ''%'' )
--				AND ((tblKartrisLanguageStrings.LS_Name LIKE ''%'' + @Key + ''%'') OR (tblKartrisLanguageStrings.LS_Value LIKE ''%'' + @Key + ''%'') OR (tblKartrisLanguageStrings.LS_ClassName LIKE ''%'' + @Key + ''%''))
--				AND (tblKartrisLanguageStrings.LS_ClassName IS NOT NULL) AND (tblKartrisLanguageStrings_1.LS_LangID = @LANG_ID) AND (tblKartrisLanguageStrings.LS_VirtualPath <> ''Install.aspx'')
--	END
--
--	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLanguageStrings_Search]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLanguageStrings_Search]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	BACK END USE
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLanguageStrings_Search]
(
	@SearchBy as nvarchar(10),
	@Key as nvarchar(100),
	@LANG_ID as tinyint,
	@FrontBack as nvarchar(1)
)
AS
	SET NOCOUNT ON;

	IF @SearchBy = ''Name''
	BEGIN
		SELECT  *
		FROM    tblKartrisLanguageStrings
		WHERE   (LS_LANGID = @LANG_ID) AND (LS_FrontBack LIKE ''%'' + @FrontBack + ''%'' ) AND (LS_Name LIKE ''%'' + @Key + ''%'') --AND (tblKartrisLanguageStrings.LS_VirtualPath <> ''Install.aspx'')
	END
	
	IF @SearchBy = ''Value''
	BEGIN
		SELECT  *
		FROM    tblKartrisLanguageStrings
		WHERE   (LS_LANGID = @LANG_ID) AND (LS_FrontBack LIKE ''%'' + @FrontBack + ''%'' ) AND (LS_Value LIKE ''%'' + @Key + ''%'')-- AND (tblKartrisLanguageStrings.LS_VirtualPath <> ''Install.aspx'')
	END
	
	IF @SearchBy = ''ClassName''
	BEGIN
		SELECT  *
		FROM    tblKartrisLanguageStrings
		WHERE   (LS_LANGID = @LANG_ID) AND (LS_FrontBack LIKE ''%'' + @FrontBack + ''%'' ) AND (LS_ClassName LIKE ''%'' + @Key + ''%'')
	END
	
	IF @SearchBy = ''''
	BEGIN
		SELECT  *
		FROM    tblKartrisLanguageStrings
		WHERE   (LS_LANGID = @LANG_ID) AND (LS_FrontBack LIKE ''%'' + @FrontBack + ''%'' )
				AND ((LS_Name LIKE ''%'' + @Key + ''%'') OR (LS_Value LIKE ''%'' + @Key + ''%'') OR (LS_ClassName LIKE ''%'' + @Key + ''%'')) --AND (tblKartrisLanguageStrings.LS_VirtualPath <> ''Install.aspx'')
	END




' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLanguageStrings_GetTotalsPerLanguage]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLanguageStrings_GetTotalsPerLanguage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLanguageStrings_GetTotalsPerLanguage]
AS
BEGIN
	SET NOCOUNT OFF;

	SELECT    LS_LangID  as ID, tblKartrisLanguages.LANG_BackName as Name, COUNT(1) AS Total
	FROM        dbo.tblKartrisLanguageStrings  INNER JOIN
					  tblKartrisLanguages ON LS_LangID = tblKartrisLanguages.LANG_ID
	GROUP BY LS_LangID, tblKartrisLanguages.LANG_BackName
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLanguageStrings_GetByID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLanguageStrings_GetByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisLanguageStrings_GetByID]
(
	@LS_FrontBack char(1),
	@LS_LANGID tinyint,
	@LS_Name nvarchar(255)
)
AS
	SET NOCOUNT ON;
SELECT        tblKartrisLanguages.LANG_BackName, tblKartrisLanguageStrings.LS_FrontBack, tblKartrisLanguageStrings.LS_Name, tblKartrisLanguageStrings.LS_Value, 
						 tblKartrisLanguageStrings.LS_Description, tblKartrisLanguageStrings.LS_VersionAdded, tblKartrisLanguageStrings.LS_DefaultValue, 
						 tblKartrisLanguageStrings.LS_VirtualPath, tblKartrisLanguageStrings.LS_ClassName, tblKartrisLanguageStrings.LS_LANGID, 
						 tblKartrisLanguageStrings.LS_ID
FROM            tblKartrisLanguageStrings INNER JOIN
						 tblKartrisLanguages ON tblKartrisLanguageStrings.LS_LANGID = tblKartrisLanguages.LANG_ID
WHERE        (tblKartrisLanguageStrings.LS_FrontBack = @LS_FrontBack) AND (tblKartrisLanguageStrings.LS_LANGID = @LS_LANGID) AND 
						 (tblKartrisLanguageStrings.LS_Name = @LS_Name)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLanguageStrings_FixMissingStrings]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLanguageStrings_FixMissingStrings]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLanguageStrings_FixMissingStrings]
(
	@SourceLanguage as tinyint,
	@DistinationLanguage as tinyint
)
AS
BEGIN

	SET NOCOUNT OFF;

	DISABLE Trigger trigKartrisLanguageStrings_DML ON dbo.tblKartrisLanguageStrings;
	INSERT INTO dbo.tblKartrisLanguageStrings
	SELECT LS_FrontBack, LS_Name, NULL, NULL, LS_VersionAdded, NULL, LS_VirtualPath, LS_ClassName, @DistinationLanguage
	FROM dbo.tblKartrisLanguageStrings
	WHERE (LS_LangID = @SourceLanguage) AND 
			LS_FrontBack + LS_Name NOT IN 
				(  SELECT  tblKartrisLanguageStrings.LS_FrontBack + tblKartrisLanguageStrings.LS_Name
					FROM    tblKartrisLanguageStrings INNER JOIN
							  tblKartrisLanguageStrings AS tblKartrisLanguageStrings_1 ON 
							  tblKartrisLanguageStrings.LS_FrontBack = tblKartrisLanguageStrings_1.LS_FrontBack AND 
							  tblKartrisLanguageStrings.LS_Name = tblKartrisLanguageStrings_1.LS_Name
					WHERE tblKartrisLanguageStrings.LS_LangID = @SourceLanguage AND tblKartrisLanguageStrings_1.LS_LangID = @DistinationLanguage
				 );
	ENABLE Trigger trigKartrisLanguageStrings_DML ON dbo.tblKartrisLanguageStrings;
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLanguageStrings_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLanguageStrings_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLanguageStrings_Add]
(
	@LS_LangID tinyint,
	@LS_FrontBack nvarchar(1),
	@LS_Name nvarchar(255),
	@LS_Value nvarchar(MAX),
	@LS_Description nvarchar(255),
	@LS_VersionAdded real,
	@LS_DefaultValue nvarchar(MAX),
	@LS_VirtualPath nvarchar(50),
	@LS_ClassName nvarchar(50)
)
AS
	SET NOCOUNT OFF;

Disable Trigger trigKartrisLanguageStrings_DML ON tblKartrisLanguageStrings;
	INSERT INTO [tblKartrisLanguageStrings] 
	([LS_LangID], [LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName]) 
	VALUES 
	(@LS_LangID, @LS_FrontBack, @LS_Name, @LS_Value, @LS_Description, @LS_VersionAdded, @LS_DefaultValue, @LS_VirtualPath, @LS_ClassName);


	IF SCOPE_IDENTITY() IS NOT NULL
	BEGIN
		DECLARE @LanguageID as tinyint;
		DECLARE langCursor CURSOR FOR 
		SELECT LANG_ID FROM dbo.tblKartrisLanguages WHERE LANG_ID <> @LS_LangID;

		OPEN langCursor
		FETCH NEXT FROM langCursor
		INTO @LanguageID;
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			INSERT INTO dbo.tblKartrisLanguageStrings
			VALUES (@LS_FrontBack, @LS_Name, NULL, NULL, @LS_VersionAdded, NULL, @LS_VirtualPath, @LS_ClassName, @LanguageID);
			
			FETCH NEXT FROM langCursor
			INTO @LanguageID;
		END

		CLOSE langCursor
		DEALLOCATE langCursor;
	END;
Enable Trigger trigKartrisLanguageStrings_DML ON tblKartrisLanguageStrings;



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLanguages_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLanguages_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLanguages_Update]
(
	@Original_LANG_ID tinyint,
	@LANG_BackName nvarchar(50),
	@LANG_FrontName nvarchar(50),
	@LANG_SkinLocation nvarchar(50),
	@LANG_LiveFront bit,
	@LANG_LiveBack bit,
	@LANG_EmailFrom nvarchar(255),
	@LANG_EmailTo nvarchar(255),
	@LANG_EmailToContact nvarchar(255),
	@LANG_DateFormat nvarchar(50),
	@LANG_DateAndTimeFormat nvarchar(50),
	@LANG_Culture nvarchar(50),
	@LANG_UICulture nvarchar(50),
	@LANG_Master nvarchar(50),
	@LANG_Theme nvarchar(50)
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisLanguages_U ON tblKartrisLanguages;
Disable Trigger trigKartrisLanguages_DML ON tblKartrisLanguages;
Disable Trigger trigKartrisLanguages_D ON tblKartrisLanguages;
	UPDATE [tblKartrisLanguages] 
	SET [LANG_BackName] = @LANG_BackName, [LANG_FrontName] = @LANG_FrontName, [LANG_SkinLocation] = @LANG_SkinLocation, [LANG_LiveFront] = @LANG_LiveFront, [LANG_LiveBack] = @LANG_LiveBack, [LANG_EmailFrom] = @LANG_EmailFrom, [LANG_EmailTo] = @LANG_EmailTo, [LANG_EmailToContact] = @LANG_EmailToContact, [LANG_DateFormat] = @LANG_DateFormat, [LANG_DateAndTimeFormat] = @LANG_DateAndTimeFormat, [LANG_Culture] = @LANG_Culture, [LANG_UICulture] = @LANG_UICulture, [LANG_Master] = @LANG_Master, [LANG_Theme] = @LANG_Theme
	WHERE (([LANG_ID] = @Original_LANG_ID));
Enable Trigger trigKartrisLanguages_U ON tblKartrisLanguages;
Enable Trigger trigKartrisLanguages_DML ON tblKartrisLanguages;
Enable Trigger trigKartrisLanguages_D ON tblKartrisLanguages;

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLanguages_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLanguages_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLanguages_Get]
AS
	SET NOCOUNT ON;
SELECT * FROM tblKartrisLanguages;


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisMediaLinks_ChangeSortValue]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisMediaLinks_ChangeSortValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[_spKartrisMediaLinks_ChangeSortValue]
(
	@MediaID as int,
	@ParentID as bigint,
	@ParentType as char,
	@Direction as char
)
AS
BEGIN
	SET NOCOUNT OFF;
	
	DECLARE @MediaOrder as int;
	SELECT @MediaOrder = ML_SortOrder
	FROM  dbo.tblKartrisMediaLinks
	WHERE ML_ID = @MediaID;

	DECLARE @SwitchMediaID as int, @SwitchOrder as int;
	IF @Direction = ''u''
	BEGIN
		SELECT @SwitchOrder = MAX(ML_SortOrder) 
		FROM  dbo.tblKartrisMediaLinks
		WHERE ML_ParentID = @ParentID AND ML_ParentType = @ParentType AND ML_SortOrder < @MediaOrder;

		SELECT TOP(1) @SwitchMediaID = ML_ID
		FROM  dbo.tblKartrisMediaLinks
		WHERE ML_ParentID = @ParentID AND ML_ParentType = @ParentType AND ML_SortOrder = @SwitchOrder;		
	END
	ELSE
	BEGIN
		SELECT @SwitchOrder = MIN(ML_SortOrder) 
		FROM  dbo.tblKartrisMediaLinks
		WHERE ML_ParentID = @ParentID AND ML_ParentType = @ParentType AND ML_SortOrder > @MediaOrder;

		SELECT TOP(1) @SwitchMediaID = ML_ID
		FROM  dbo.tblKartrisMediaLinks
		WHERE ML_ParentID = @ParentID AND ML_ParentType = @ParentType AND ML_SortOrder = @SwitchOrder;
	END;

Disable Trigger trigKartrisMediaLinks_DML ON tblKartrisMediaLinks;
	UPDATE dbo.tblKartrisMediaLinks
	SET ML_SortOrder = @SwitchOrder
	WHERE ML_ID = @MediaID; 

	UPDATE dbo.tblKartrisMediaLinks
	SET ML_SortOrder = @MediaOrder
	WHERE ML_ID = @SwitchMediaID;
Enable Trigger trigKartrisMediaLinks_DML ON tblKartrisMediaLinks;
		
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisMediaLinks_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisMediaLinks_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisMediaLinks_Add]
(
	@ParentID as bigint,
	@ParentType as nvarchar(1),
	@EmbedSource as nvarchar(1000),
	@MediaTypeID as smallint,
	@Height as int,
	@Width as int,
	@Downloadable as bit,
	@Parameters as nvarchar(1000),
	@Live as bit,
	@NewML_ID as int out
)
AS
BEGIN
SET NOCOUNT ON;
		
		Disable Trigger trigKartrisMediaLinks_DML ON tblKartrisMediaLinks;
		DECLARE @MaxOrder as int;
		SELECT @MaxOrder = Max(ML_SortOrder) FROM dbo.tblKartrisMediaLinks WHERE ML_ParentID = @ParentID AND ML_ParentType = @ParentType;
		IF @MaxOrder is NULL BEGIN SET @MaxOrder = 0 END
					
		INSERT INTO dbo.tblKartrisMediaLinks
		VALUES (@ParentID,@ParentType,@MaxOrder + 1,@EmbedSource,@MediaTypeID,
				@Height,@Width,@Downloadable,@Parameters,@Live);
				
		SELECT @NewML_ID = SCOPE_IDENTITY();
		
		Enable Trigger trigKartrisMediaLinks_DML ON tblKartrisMediaLinks;
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLogins_Validate]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLogins_Validate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLogins_Validate]
(
	@UserName varchar(100),
	@Password varchar(50)
)
AS
SET NOCOUNT OFF;
SELECT        TOP 1 LOGIN_ID
FROM            tblKartrisLogins
WHERE        (LOGIN_Username = @UserName AND LOGIN_Password = @Password AND LOGIN_LIVE = 1)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLogins_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLogins_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLogins_Update]
(
	  @LOGIN_ID int,
	  @LOGIN_Username nvarchar(100),
	  @LOGIN_Password nvarchar(100),
	  @LOGIN_Live bit,
	  @LOGIN_Orders bit,
	  @LOGIN_Products bit,
	  @LOGIN_Config bit,
	  @LOGIN_Protected bit,
	  @LOGIN_LanguageID smallint,
	  @LOGIN_EmailAddress nvarchar(50),
	  @LOGIN_Tickets bit
)
AS
IF @LOGIN_Password = ''''
		BEGIN
			SET @LOGIN_Password = NULL;
		END;
	SET NOCOUNT OFF;

Disable Trigger trigKartrisLogins_DML ON tblKartrisLogins;
	UPDATE [tblKartrisLogins] SET 
		  [LOGIN_Username] = @LOGIN_Username
		  ,[LOGIN_Password] = COALESCE (@LOGIN_Password, LOGIN_Password)
		  ,[LOGIN_Live] = @LOGIN_Live
		  ,[LOGIN_Orders] = @LOGIN_Orders
		  ,[LOGIN_Products] = @LOGIN_Products
		  ,[LOGIN_Config] = @LOGIN_Config
		  ,[LOGIN_Protected] = @LOGIN_Protected
		  ,[LOGIN_LanguageID] = @LOGIN_LanguageID
		  ,[LOGIN_EmailAddress] = @LOGIN_EmailAddress
		  ,[LOGIN_Tickets] = @LOGIN_Tickets
		WHERE LOGIN_ID = @LOGIN_ID;
	SELECT @LOGIN_ID;
Enable Trigger trigKartrisLogins_DML ON tblKartrisLogins;




' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLogins_GetSupportTicketsList]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLogins_GetSupportTicketsList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLogins_GetSupportTicketsList]
AS
SET NOCOUNT OFF;
SELECT     LOGIN_ID, LOGIN_Username, LOGIN_EmailAddress
FROM         tblKartrisLogins
WHERE     (LOGIN_Tickets = 1 AND LOGIN_Live = 1)



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLogins_GetList]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLogins_GetList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLogins_GetList]
AS
SET NOCOUNT OFF;
SELECT        [LOGIN_ID]
	  ,[LOGIN_Username]
	  ,[LOGIN_Password]
	  ,[LOGIN_Live]
	  ,[LOGIN_Orders]
	  ,[LOGIN_Products]
	  ,[LOGIN_Config]
	  ,[LOGIN_Protected]
	  ,[LOGIN_LanguageID]
	  ,[LOGIN_EmailAddress]
	  ,[LOGIN_Tickets]
FROM            tblKartrisLogins


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLogins_GetIDbyName]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLogins_GetIDbyName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLogins_GetIDbyName]
(
	@Username nvarchar(100)
)
AS
SET NOCOUNT OFF;
SELECT        TOP 1 
				[LOGIN_ID]
FROM            tblKartrisLogins
WHERE        (LOGIN_Username = @Username)



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLogins_GetDetails]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLogins_GetDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLogins_GetDetails]
(
	@Username nvarchar(100)
)
AS
SET NOCOUNT OFF;
SELECT        TOP 1 
				[LOGIN_ID]
	  ,[LOGIN_Username]
	  ,[LOGIN_Password]
	  ,[LOGIN_Live]
	  ,[LOGIN_Orders]
	  ,[LOGIN_Products]
	  ,[LOGIN_Config]
	  ,[LOGIN_Protected]
	  ,[LOGIN_LanguageID]
	  ,[LOGIN_EmailAddress]
	  ,[LOGIN_Tickets]
				
FROM            tblKartrisLogins
WHERE        (LOGIN_Username = @Username)


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLogins_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLogins_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLogins_Delete]
(
	  @LOGIN_ID int
)
AS
	SET NOCOUNT OFF;

Disable Trigger trigKartrisLogins_DML ON tblKartrisLogins;
	DELETE FROM [tblKartrisLogins]
		WHERE LOGIN_ID = @LOGIN_ID;
	SELECT @LOGIN_ID;
Enable Trigger trigKartrisLogins_DML ON tblKartrisLogins;

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLogins_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLogins_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLogins_Add]
(
	  @LOGIN_Username nvarchar(100),
	  @LOGIN_Password nvarchar(100),
	  @LOGIN_Live bit,
	  @LOGIN_Orders bit,
	  @LOGIN_Products bit,
	  @LOGIN_Config bit,
	  @LOGIN_Protected bit,
	  @LOGIN_LanguageID smallint,
	  @LOGIN_EmailAddress nvarchar(50),
	  @LOGIN_Tickets bit
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisLogins_DML ON tblKartrisLogins;
	INSERT INTO [tblKartrisLogins] (
		  [LOGIN_Username]
		  ,[LOGIN_Password]
		  ,[LOGIN_Live]
		  ,[LOGIN_Orders]
		  ,[LOGIN_Products]
		  ,[LOGIN_Config]
		  ,[LOGIN_Protected]
		  ,[LOGIN_LanguageID]
		  ,[LOGIN_EmailAddress]
		  ,[LOGIN_Tickets])
	VALUES (
		  @LOGIN_Username ,
		  @LOGIN_Password ,
		  @LOGIN_Live ,
		  @LOGIN_Orders,
		  @LOGIN_Products ,
		  @LOGIN_Config ,
		  @LOGIN_Protected ,
		  @LOGIN_LanguageID ,
		  @LOGIN_EmailAddress ,
		  @LOGIN_Tickets);
	SELECT SCOPE_IDENTITY();
Enable Trigger trigKartrisLogins_DML ON tblKartrisLogins;




' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisNews_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisNews_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisNews_Add]
(
	@NowOffset as datetime,
	@N_NewID as int OUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Disable Trigger trigKartrisNews_DML ON tblKartrisNews;
	-- Insert statements for procedure here
	INSERT INTO tblKartrisNews VALUES(@NowOffset, @NowOffset);
	SELECT @N_NewID = SCOPE_IDENTITY();
Enable Trigger trigKartrisNews_DML ON tblKartrisNews;

END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisMediaTypes_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisMediaTypes_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisMediaTypes_Update]
(
	@MT_ID as int,
	@DefaultHeight as int,
	@DefaultWidth as int,
	@DefaultParameters as nvarchar(1000),
	@Downloadable as bit,
	@Embed as bit,
	@Inline as bit	
)
AS
BEGIN
SET NOCOUNT ON;
		
		Disable Trigger trigKartrisMediaTypes_DML ON tblKartrisMediaTypes;
					
		UPDATE dbo.tblKartrisMediaTypes
		SET MT_DefaultHeight = @DefaultHeight, MT_DefaultWidth = @DefaultWidth,
			MT_DefaultParameters = @DefaultParameters, 
			MT_DefaultisDownloadable = @Downloadable, 
			MT_Embed = @Embed,
			MT_Inline = @Inline
		WHERE MT_ID = @MT_ID;
				
		
		Enable Trigger trigKartrisMediaTypes_DML ON tblKartrisMediaTypes;
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisMediaTypes_GetByID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisMediaTypes_GetByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisMediaTypes_GetByID]
(
	@MediaType_ID as smallint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * FROM dbo.tblKartrisMediaTypes WHERE MT_ID = @MediaType_ID;
END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisMediaTypes_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisMediaTypes_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisMediaTypes_Get]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * FROM dbo.tblKartrisMediaTypes
END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisMediaTypes_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisMediaTypes_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisMediaTypes_Delete]
(
	@MT_ID as int	
)
AS
BEGIN
SET NOCOUNT ON;
		
		Disable Trigger trigKartrisMediaTypes_DML ON tblKartrisMediaTypes;
					
		DELETE FROM dbo.tblKartrisMediaTypes
		WHERE MT_ID = @MT_ID;
		
		Enable Trigger trigKartrisMediaTypes_DML ON tblKartrisMediaTypes;
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisMediaTypes_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisMediaTypes_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisMediaTypes_Add]
(
	@Extension as nvarchar(20),
	@DefaultHeight as int,
	@DefaultWidth as int,
	@DefaultParameters as nvarchar(1000),
	@Downloadable as bit,
	@Embed as bit,
	@Inline as bit,
	@NewMT_ID as int out
)
AS
BEGIN
SET NOCOUNT ON;
		
		Disable Trigger trigKartrisMediaTypes_DML ON tblKartrisMediaTypes;
					
		INSERT INTO dbo.tblKartrisMediaTypes
		VALUES (@Extension, @DefaultHeight, @DefaultWidth,
				@DefaultParameters, @Downloadable, @Embed, @Inline);
				
		SELECT @NewMT_ID = SCOPE_IDENTITY();
		
		Enable Trigger trigKartrisMediaTypes_DML ON tblKartrisMediaTypes;
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisMediaLinks_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisMediaLinks_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisMediaLinks_Update]
(
	@ML_ID as int,
	@EmbedSource as nvarchar(2000),
	@MediaTypeID as smallint,
	@Height as int,
	@Width as int,
	@Downloadable as bit,
	@Parameters as nvarchar(1000),
	@Live as bit
)
AS
BEGIN
SET NOCOUNT ON;
		
		Disable Trigger trigKartrisMediaLinks_DML ON tblKartrisMediaLinks;
		
		UPDATE dbo.tblKartrisMediaLinks
		SET ML_EmbedSource = @EmbedSource,ML_MediaTypeID = @MediaTypeID,
			ML_Height = @Height,ML_Width = @Width,ML_isDownloadable = @Downloadable,
			ML_Parameters = @Parameters,ML_Live = @Live
		WHERE ML_ID = @ML_ID;
				
		Enable Trigger trigKartrisMediaLinks_DML ON tblKartrisMediaLinks;
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisMediaLinks_GetByParent]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisMediaLinks_GetByParent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisMediaLinks_GetByParent]
(
	@ParentID as bigint, 
	@ParentType as nvarchar(1)
)
AS
BEGIN
SET NOCOUNT ON;
SELECT     tblKartrisMediaLinks.ML_ID, tblKartrisMediaLinks.ML_ParentID, tblKartrisMediaLinks.ML_ParentType, tblKartrisMediaLinks.ML_EmbedSource, 
					  tblKartrisMediaLinks.ML_MediaTypeID, tblKartrisMediaLinks.ML_Height, tblKartrisMediaLinks.ML_Width, tblKartrisMediaLinks.ML_isDownloadable, 
					  tblKartrisMediaLinks.ML_Parameters, tblKartrisMediaTypes.MT_DefaultHeight, tblKartrisMediaTypes.MT_DefaultWidth, 
					  tblKartrisMediaTypes.MT_DefaultParameters, tblKartrisMediaTypes.MT_DefaultisDownloadable, tblKartrisMediaTypes.MT_Extension, 
					  tblKartrisMediaTypes.MT_Embed, tblKartrisMediaTypes.MT_Inline, tblKartrisMediaLinks.ML_Live
FROM         tblKartrisMediaLinks LEFT OUTER JOIN
					  tblKartrisMediaTypes ON tblKartrisMediaLinks.ML_MediaTypeID = tblKartrisMediaTypes.MT_ID
WHERE     (tblKartrisMediaLinks.ML_ParentID = @ParentID) AND (tblKartrisMediaLinks.ML_ParentType = @ParentType)
ORDER BY tblKartrisMediaLinks.ML_SortOrder

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisMediaLinks_GetByID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisMediaLinks_GetByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisMediaLinks_GetByID]
(
	@MediaLinkID as int
)
AS
BEGIN
SET NOCOUNT ON;
		SELECT     tblKartrisMediaLinks.ML_ID, tblKartrisMediaLinks.ML_ParentID, tblKartrisMediaLinks.ML_ParentType, tblKartrisMediaLinks.ML_SortOrder, 
					  tblKartrisMediaLinks.ML_EmbedSource, tblKartrisMediaLinks.ML_MediaTypeID, tblKartrisMediaLinks.ML_Height, tblKartrisMediaLinks.ML_Width, 
					  tblKartrisMediaLinks.ML_isDownloadable, tblKartrisMediaLinks.ML_Parameters, tblKartrisMediaLinks.ML_Live, tblKartrisMediaTypes.MT_Extension
FROM         tblKartrisMediaLinks INNER JOIN
					  tblKartrisMediaTypes ON tblKartrisMediaLinks.ML_MediaTypeID = tblKartrisMediaTypes.MT_ID
WHERE     (tblKartrisMediaLinks.ML_ID = @MediaLinkID)
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisMediaLinks_DeleteByParent]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisMediaLinks_DeleteByParent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisMediaLinks_DeleteByParent]
(
	@ParentID as bigint,
	@ParentType as nvarchar(1)
)
AS
BEGIN
SET NOCOUNT ON;
		
	DECLARE @Timeoffset as int;
	set @Timeoffset = CAST(dbo.fnKartrisConfig_GetValue(''general.timeoffset'') as int);
	
	Disable Trigger trigKartrisMediaLinks_DML ON tblKartrisMediaLinks;
	Disable Trigger trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
	
	DECLARE mediaCursor CURSOR FOR 
	SELECT ML_ID
	FROM dbo.tblKartrisMediaLinks
	WHERE ML_ParentID = @ParentID and ML_ParentType = @ParentType;
		
	DECLARE @ML_ID as bigint;
	
	OPEN mediaCursor
	FETCH NEXT FROM mediaCursor
	INTO @ML_ID;

	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		DELETE FROM dbo.tblKartrisMediaLinks
		WHERE ML_ID = @ML_ID;
		IF @ML_ID <> 0 AND @ML_ID NOT IN (SELECT DELETED_ID FROM dbo.tblKartrisDeletedItems WHERE Deleted_Type = ''m'') BEGIN
			INSERT INTO dbo.tblKartrisDeletedItems VALUES(@ML_ID, ''m'', NULL, DateAdd(hour, @Timeoffset, GetDate()));
		END
		FETCH NEXT FROM mediaCursor
		INTO @ML_ID;
	END

	CLOSE mediaCursor
	DEALLOCATE mediaCursor;	
	
	Enable Trigger trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
	Enable Trigger trigKartrisMediaLinks_DML ON tblKartrisMediaLinks;
		
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisMediaLinks_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisMediaLinks_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisMediaLinks_Delete]
(
	@ML_ID as int
)
AS
BEGIN
SET NOCOUNT ON;
		
		Disable Trigger trigKartrisMediaLinks_DML ON tblKartrisMediaLinks;
		DELETE FROM dbo.tblKartrisMediaLinks
		WHERE ML_ID = @ML_ID;
		Enable Trigger trigKartrisMediaLinks_DML ON tblKartrisMediaLinks;
		
		IF @@RowCount = 1 BEGIN
			IF @ML_ID <> 0 AND @ML_ID NOT IN (SELECT DELETED_ID FROM dbo.tblKartrisDeletedItems WHERE Deleted_Type = ''m'') BEGIN
				DISABLE Trigger trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
				DECLARE @Timeoffset as int;
				set @Timeoffset = CAST(dbo.fnKartrisConfig_GetValue(''general.timeoffset'') as int);
				INSERT INTO dbo.tblKartrisDeletedItems VALUES(@ML_ID, ''m'', NULL, DateAdd(hour, @Timeoffset, GetDate()));
				ENABLE Trigger trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
			END
		END
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLanguageStrings_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLanguageStrings_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLanguageStrings_Update]
(
	@Original_LS_LanguageID tinyint,
	@Original_LS_FrontBack nvarchar(1),
	@Original_LS_Name nvarchar(255),
	@LS_Value nvarchar(MAX),
	@LS_Description nvarchar(255),
	@LS_DefaultValue nvarchar(MAX),
	@LS_VirtualPath nvarchar(50),
	@LS_ClassName nvarchar(50)
)
AS
	SET NOCOUNT OFF;

Disable Trigger trigKartrisLanguageStrings_DML ON tblKartrisLanguageStrings;
	UPDATE [tblKartrisLanguageStrings] 
	SET [LS_Value] = @LS_Value, [LS_Description] = @LS_Description, 
	[LS_DefaultValue] = @LS_DefaultValue, [LS_VirtualPath] = @LS_VirtualPath, [LS_ClassName] = @LS_ClassName 
	WHERE [LS_LANGID] = @Original_LS_LanguageID AND [LS_FrontBack] = @Original_LS_FrontBack AND [LS_Name] = @Original_LS_Name;

	IF @Original_LS_LanguageID = dbo.fnKartrisConfig_GetDefaultLanguage()
	BEGIN
		DECLARE @LanguageID as tinyint;
		DECLARE langCursor CURSOR FOR 
		SELECT LANG_ID  FROM dbo.tblKartrisLanguages WHERE LANG_ID <> @Original_LS_LanguageID;

		OPEN langCursor
		FETCH NEXT FROM langCursor
		INTO @LanguageID;
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			UPDATE dbo.tblKartrisLanguageStrings
			SET LS_ClassName = @LS_ClassName, LS_VirtualPath = @LS_VirtualPath
			WHERE LS_FrontBack = @Original_LS_FrontBack AND LS_Name = @Original_LS_Name AND LS_LangID = @LanguageID;
			
			FETCH NEXT FROM langCursor
			INTO @LanguageID;
		END

		CLOSE langCursor
		DEALLOCATE langCursor;
	END;
Enable Trigger trigKartrisLanguageStrings_DML ON tblKartrisLanguageStrings;


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLanguages_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLanguages_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLanguages_Add]
(
	@LANG_BackName nvarchar(50),
	@LANG_FrontName nvarchar(50),
	@LANG_SkinLocation nvarchar(50),
	@LANG_LiveFront bit,
	@LANG_LiveBack bit,
	@LANG_EmailFrom nvarchar(255),
	@LANG_EmailTo nvarchar(255),
	@LANG_EmailToContact nvarchar(255),
	@LANG_DateFormat nvarchar(50),
	@LANG_DateAndTimeFormat nvarchar(50),
	@LANG_Culture nvarchar(50),
	@LANG_UICulture nvarchar(50),
	@LANG_Master nvarchar(50),
	@LANG_Theme nvarchar(50)
)
AS
	SET NOCOUNT OFF;

Disable Trigger trigKartrisLanguages_DML ON tblKartrisLanguages;
	INSERT INTO [tblKartrisLanguages] ([LANG_BackName], [LANG_FrontName], [LANG_SkinLocation], [LANG_LiveFront], [LANG_LiveBack], [LANG_EmailFrom], [LANG_EmailTo], [LANG_EmailToContact], [LANG_DateFormat], [LANG_DateAndTimeFormat], [LANG_Culture], [LANG_UICulture], [LANG_Master], [LANG_Theme]) 
	VALUES (@LANG_BackName, @LANG_FrontName, @LANG_SkinLocation, @LANG_LiveFront, @LANG_LiveBack, @LANG_EmailFrom, @LANG_EmailTo, @LANG_EmailToContact, @LANG_DateFormat, @LANG_DateAndTimeFormat, @LANG_Culture, @LANG_UICulture, @LANG_Master, @LANG_Theme);
Enable Trigger trigKartrisLanguages_DML ON tblKartrisLanguages;
	
	IF SCOPE_IDENTITY() IS NOT NULL
	BEGIN
		DECLARE @NewLanguageID as tinyint;
		SET @NewLanguageID = SCOPE_IDENTITY();
				
		-- ==========================================================================
		-- The following code will create new records in the language strings table
		--		for the new language.
		
		CREATE TABLE #TempLanguageString
			(LS_FrontBack char(1), LS_Name nvarchar(255), LS_VirtualPath nvarchar(50), LS_ClassName nvarchar(50));
			
		INSERT INTO #TempLanguageString
		SELECT LS_FrontBack, LS_Name, LS_VirtualPath, LS_ClassName	
		FROM dbo.tblKartrisLanguageStrings	
		WHERE LS_LangID = dbo.fnKartrisConfig_GetDefaultLanguage();
		
		DECLARE @FB as char(1), @Name as nvarchar(255), @Path as nvarchar(50), @Class as nvarchar(50)

		DECLARE langCursor CURSOR FOR 
		SELECT LS_FrontBack, LS_Name, LS_VirtualPath, LS_ClassName	
		FROM #TempLanguageString;

Disable Trigger trigKartrisLanguageStrings_DML ON tblKartrisLanguageStrings;
		OPEN langCursor
		FETCH NEXT FROM langCursor INTO @FB, @Name, @Path, @Class;
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO dbo.tblKartrisLanguageStrings
			VALUES (@FB, @Name, NULL, NULL, 1, NULL, @Path, @Class, @NewLanguageID);
			
			FETCH NEXT FROM langCursor INTO @FB, @Name, @Path, @Class;
		END
		CLOSE langCursor
		DEALLOCATE langCursor;
Enable Trigger trigKartrisLanguageStrings_DML ON tblKartrisLanguageStrings;

		DROP TABLE #TempLanguageString;
		-- ____________________________________________________________________________
		
		-- ==========================================================================
		-- The following code will create new records in the language elements table
		--		for the new language.
		
		CREATE TABLE #TempLanguageElements
			(LE_TypeID tinyint, LE_FieldID tinyint, LE_ParentID bigint)
			
		INSERT INTO #TempLanguageElements
		SELECT LE_TypeID, LE_FieldID, LE_ParentID 
		FROM dbo.tblKartrisLanguageElements WHERE LE_LanguageID = dbo.fnKartrisConfig_GetDefaultLanguage();
		
		DECLARE @TypeID as tinyint, @FieldID as tinyint, @ParentID as bigint;
	
		DECLARE leCursor CURSOR FOR 
		SELECT LE_TypeID, LE_FieldID, LE_ParentID 
		FROM #TempLanguageElements;

Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;
		OPEN leCursor
		FETCH NEXT FROM leCursor INTO @TypeID, @FieldID, @ParentID;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			INSERT INTO dbo.tblKartrisLanguageElements
			VALUES (@NewLanguageID, @TypeID, @FieldID, @ParentID, NULL);
			
			FETCH NEXT FROM leCursor INTO @TypeID, @FieldID, @ParentID;
		END
		CLOSE leCursor;
		DEALLOCATE leCursor;
Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;

		DROP TABLE #TempLanguageElements;
		
		-- ____________________________________________________________________________
	END
		



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLanguageElements_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLanguageElements_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLanguageElements_Update]
(
	@LE_LanguageID tinyint,
	@LE_TypeID tinyint,
	@LE_FieldID tinyint,
	@LE_ParentID bigint,
	@LE_Value nvarchar(MAX)
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;
	UPDATE [tblKartrisLanguageElements]
	SET LE_Value = @LE_Value
	WHERE [LE_LanguageID] = @LE_LanguageID AND [LE_TypeID]= @LE_TypeID 
		AND [LE_FieldID]= @LE_FieldID AND [LE_ParentID] = @LE_ParentID;
Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLanguageElements_GetTotalsPerLanguage]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLanguageElements_GetTotalsPerLanguage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLanguageElements_GetTotalsPerLanguage]
AS
BEGIN
	SET NOCOUNT OFF;

	SELECT     tblKartrisLanguageElements.LE_LanguageID as ID, tblKartrisLanguages.LANG_BackName as Name, COUNT(1) AS Total
	FROM         tblKartrisLanguageElements INNER JOIN
					  tblKartrisLanguages ON tblKartrisLanguageElements.LE_LanguageID = tblKartrisLanguages.LANG_ID
	GROUP BY tblKartrisLanguageElements.LE_LanguageID, tblKartrisLanguages.LANG_BackName
END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLanguageElements_GetByTypeAndParent]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLanguageElements_GetByTypeAndParent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLanguageElements_GetByTypeAndParent]
(
	@LE_TypeID tinyint,
	@LE_ParentID bigint
)
AS
	SET NOCOUNT OFF;
SELECT *
FROM [tblKartrisLanguageElements]
WHERE [LE_TypeID]= @LE_TypeID AND [LE_ParentID] = @LE_ParentID


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLanguageElements_FixMissingElements]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLanguageElements_FixMissingElements]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLanguageElements_FixMissingElements]
(
	@SourceLanguage as tinyint,
	@DistinationLanguage as tinyint
)
AS
BEGIN

	SET NOCOUNT OFF;

	Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;
	INSERT INTO dbo.tblKartrisLanguageElements
	SELECT @DistinationLanguage, LE_TypeID, LE_FieldID, LE_ParentID, NULL
	FROM dbo.tblKartrisLanguageElements
	WHERE (tblKartrisLanguageElements.LE_LanguageID = @SourceLanguage) AND 
			LE_ID NOT IN (  SELECT  tblKartrisLanguageElements.LE_ID
							FROM    tblKartrisLanguageElements INNER JOIN
									  tblKartrisLanguageElements AS tblKartrisLanguageElements_1 ON tblKartrisLanguageElements.LE_TypeID = tblKartrisLanguageElements_1.LE_TypeID AND 
									  tblKartrisLanguageElements.LE_FieldID = tblKartrisLanguageElements_1.LE_FieldID AND 
									  tblKartrisLanguageElements.LE_ParentID = tblKartrisLanguageElements_1.LE_ParentID
							WHERE     (tblKartrisLanguageElements.LE_LanguageID = @SourceLanguage) AND (tblKartrisLanguageElements_1.LE_LanguageID = @DistinationLanguage));
	Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisLanguageElements_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLanguageElements_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisLanguageElements_Add]
(
	@LE_LanguageID tinyint,
	@LE_TypeID tinyint,
	@LE_FieldID tinyint,
	@LE_ParentID bigint,
	@LE_Value nvarchar(MAX)
)
AS
	SET NOCOUNT OFF;
--DISABLE TRIGGER trigKartrisLanguageElementFieldNames_IUD ON tblKartrisLanguageElementFieldNames;

Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;
	INSERT INTO [tblKartrisLanguageElements] ([LE_LanguageID], [LE_TypeID], [LE_FieldID], [LE_ParentID], [LE_Value])
	VALUES (@LE_LanguageID, @LE_TypeID, @LE_FieldID, @LE_ParentID, @LE_Value);
Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;

--ENABLE TRIGGER trigKartrisLanguageElementFieldNames_IUD ON tblKartrisLanguageElementFieldNames;


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisKnowledgeBase_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisKnowledgeBase_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisKnowledgeBase_Delete]
(
	@KB_ID as int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;
	DELETE FROM dbo.tblKartrisLanguageElements
	WHERE LE_TypeID = 17 AND LE_ParentID = @KB_ID;
Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;

Disable Trigger trigKartrisKnowledgeBase_DML ON dbo.tblKartrisKnowledgeBase;	
	DELETE FROM dbo.tblKartrisKnowledgeBase
	WHERE KB_ID = @KB_ID;
Enable Trigger trigKartrisKnowledgeBase_DML ON dbo.tblKartrisKnowledgeBase;	
	

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategories_Update]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategories_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCategories_Update]
(
	@CAT_ID int,
	@CAT_Live BIT,
	@CAT_ProductDisplayType CHAR(1),
	@CAT_SubCatDisplayType CHAR(1),
	@CAT_OrderProductsBy nvarchar(50),
	@CAT_ProductsSortDirection as char(1),
	@CAT_CustomerGroupID smallint,
	@CAT_OrderCategoriesBy as nvarchar(50),
	@CAT_CategoriesSortDirection as char(1)
)
AS
BEGIN
	SET NOCOUNT OFF;
Disable Trigger trigKartrisCategories_DML ON tblKartrisCategories;
	UPDATE [tblKartrisCategories]
	SET CAT_Live = @CAT_Live, CAT_ProductDisplayType = @CAT_ProductDisplayType, 
		CAT_SubCatDisplayType = @CAT_SubCatDisplayType, CAT_OrderProductsBy = @CAT_OrderProductsBy,
		CAT_ProductsSortDirection = @CAT_ProductsSortDirection, CAT_CustomerGroupID = @CAT_CustomerGroupID,
		CAT_OrderCategoriesBy = @CAT_OrderCategoriesBy, CAT_CategoriesSortDirection = @CAT_CategoriesSortDirection
	WHERE CAT_ID = @CAT_ID;
Enable Trigger trigKartrisCategories_DML ON tblKartrisCategories;

END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCurrencies_Delete]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCurrencies_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCurrencies_Delete]
(
	@Original_CUR_ID tinyint
)
AS
	SET NOCOUNT OFF;

Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;
	DELETE FROM dbo.tblKartrisLanguageElements WHERE LE_TypeID = 13 AND LE_ParentID = @Original_CUR_ID;
Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;

Disable Trigger trigKartrisCurrencies_DML ON tblKartrisCurrencies;
	DELETE FROM [tblKartrisCurrencies] WHERE (([CUR_ID] = @Original_CUR_ID));
Enable Trigger trigKartrisCurrencies_DML ON tblKartrisCurrencies;


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategories_Add]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategories_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCategories_Add]
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

Disable Trigger trigKartrisCategories_DML ON tblKartrisCategories;
	INSERT INTO tblKartrisCategories
	VALUES (@CAT_Live, @CAT_ProductDisplayType, @CAT_SubCatDisplayType,
			@CAT_OrderProductsBy, @CAT_ProductsSortDirection, @CAT_CustomerGroupID, 
			@CAT_OrderCategoriesBy, @CAT_CategoriesSortDirection);
	
	SELECT @NewCAT_ID = SCOPE_IDENTITY();
	
Enable Trigger trigKartrisCategories_DML ON tblKartrisCategories;
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_TicketsCounterSummary]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_TicketsCounterSummary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDB_TicketsCounterSummary]
(	
	@NoUnassignedTickets as int OUTPUT,
	@NoOfAwatingTickets as int OUTPUT,
	@LoginID as int
)
AS
BEGIN
	SELECT @NoUnassignedTickets = Count(TIC_ID) FROM dbo.tblKartrisSupportTickets WHERE TIC_LoginID = 0;
	DECLARE @LastMessageID as bigint;
	
	SELECT  @NoOfAwatingTickets = COUNT(DISTINCT tblKartrisSupportTicketMessages.STM_TicketID)
	FROM         tblKartrisSupportTicketMessages INNER JOIN
						  tblKartrisSupportTickets ON tblKartrisSupportTicketMessages.STM_TicketID = tblKartrisSupportTickets.TIC_ID
	WHERE     (tblKartrisSupportTickets.TIC_Status <> ''c'') AND
		dbo.fnKartrisSupportTicketMessages_IsAwaitingReply(tblKartrisSupportTicketMessages.STM_TicketID) = 1
		AND   (tblKartrisSupportTickets.TIC_LoginID = @LoginID);	


END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDestinations_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDestinations_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get Shipping Methods - by Destination and Boundary
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisDestinations_Update]
(
	@D_ID as smallint,
	@D_ShippingZoneID as tinyint,
	@D_Tax as real,
	@D_Tax2 as real,
	@D_ISOCode as char(2),
	@D_ISOCode3Letter as char(3),
	@D_ISOCodeNumeric as smallint,
	@D_Region as nvarchar(30),
	@D_Live as bit,
	@D_TaxExtra as nvarchar(25)
)
AS
BEGIN
	SET NOCOUNT ON;

Disable Trigger trigKartrisDestination_DML ON tblKartrisDestination;
	UPDATE dbo.tblKartrisDestination
	SET D_ShippingZoneID = @D_ShippingZoneID, D_Tax = @D_Tax, D_Tax2 = @D_Tax2, D_ISOCode = @D_ISOCode,
		D_ISOCode3Letter = @D_ISOCode3Letter, D_ISOCodeNumeric = @D_ISOCodeNumeric, D_Region = @D_Region, D_TaxExtra = @D_TaxExtra, D_Live = @D_Live
	WHERE D_ID = @D_ID;
Enable Trigger trigKartrisDestination_DML ON tblKartrisDestination;
	

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDestinations_GetTotalDestinationsByZone]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDestinations_GetTotalDestinationsByZone]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get All Destinations list
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDestinations_GetTotalDestinationsByZone]
(
	@D_ShippingZoneID as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT	Count(1) AS TotalDestinations
	FROM	tblKartrisDestination
	WHERE	D_ShippingZoneID = @D_ShippingZoneID
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDestinations_GetISOForFilter]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDestinations_GetISOForFilter]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get the ISO Codes with more than 1 record
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisDestinations_GetISOForFilter]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT D_ISOCode
	FROM (	SELECT	DISTINCT D_ISOCode, COUNT(1) AS NoOfRecords
			FROM	tblKartrisDestination
			GROUP BY D_ISOCode) as Tbl
	WHERE NoOfRecords > 1
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategories_GetByID]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategories_GetByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCategories_GetByID]
(
	@CAT_ID as int
)
AS
	SET NOCOUNT ON;
SELECT  tblKartrisCategories.*
FROM    tblKartrisCategories
WHERE	CAT_ID = @CAT_ID

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPromotionStrings_GetByType]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPromotionStrings_GetByType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisPromotionStrings_GetByType]
(
	@PartNo char(1),
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
	SELECT     PS_ID, PS_PartNo, PS_Type, PS_Item, 
				dbo.fnKartrisLanguageStrings_GetValue(@LANG_ID, ''f'', PS_LanguageStringName, N''Promotions'') AS PS_Text, PS_Order
	FROM         tblKartrisPromotionStrings
	WHERE     (PS_PartNo = @PartNo)
	ORDER BY PS_Order

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPromotionStrings_GetByID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPromotionStrings_GetByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisPromotionStrings_GetByID]
(
	@PS_ID tinyint,
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
	SELECT  PS_ID, PS_PartNo, PS_Type, PS_Item, 
			dbo.fnKartrisLanguageStrings_GetValue(@LANG_ID, ''f'', PS_LanguageStringName, N''Promotions'') AS PS_Text, 
			PS_Order
	FROM    tblKartrisPromotionStrings
	WHERE   (PS_ID = @PS_ID)
	ORDER BY PS_PartNo, PS_Order

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingMethods_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingMethods_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get Shipping Methods - by Destination and Boundary
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisShippingMethods_Delete]
(
	@SM_ID as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;

Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;	
		DELETE FROM dbo.tblKartrisLanguageElements
		WHERE     (LE_TypeID = 9)	-- For shipping methods
		AND (LE_ParentID = @SM_ID);	-- shipping method id
Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;	

Disable Trigger trigKartrisShippingRates_DML ON tblKartrisShippingRates;	
		DELETE FROM dbo.tblKartrisShippingRates
		WHERE S_ShippingMethodID = @SM_ID;
Enable Trigger trigKartrisShippingRates_DML ON tblKartrisShippingRates;	

Disable Trigger trigKartrisShippingMethods_DML ON tblKartrisShippingMethods;	
		DELETE  FROM dbo.tblKartrisShippingMethods
		WHERE SM_ID = @SM_ID;
Enable Trigger trigKartrisShippingMethods_DML ON tblKartrisShippingMethods;	

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPages_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPages_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPages_Delete]
(
	@Page_ID as smallint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;
	DELETE FROM dbo.tblKartrisLanguageElements
	WHERE LE_TypeID = 8 AND LE_ParentID = @Page_ID;
Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;

Disable Trigger trigKartrisPages_DML ON tblKartrisPages;	
	UPDATE tblKartrisPages
	SET Page_ParentID = 0
	WHERE Page_ParentID = @Page_ID;

	DELETE FROM tblKartrisPages
	WHERE Page_ID = @Page_ID;
Enable Trigger trigKartrisPages_DML ON tblKartrisPages;	
	

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPromotions_DeleteByParent]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPromotions_DeleteByParent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPromotions_DeleteByParent]
(
	@ParentID as bigint,
	@ParentType as nvarchar(1)
)
AS
BEGIN
SET NOCOUNT ON;
		
	DECLARE @Timeoffset as int;
	set @Timeoffset = CAST(dbo.fnKartrisConfig_GetValue(''general.timeoffset'') as int);
	
	DECLARE promoCursor CURSOR FOR 
	SELECT PROM_ID
	FROM dbo.tblKartrisPromotionParts
	WHERE PP_ItemID = @ParentID and PP_ItemType = @ParentType;
		
	DECLARE @Promo_ID as bigint;
	DECLARE @PromotionsToDelete as varchar(max);
	SET @PromotionsToDelete = ''0'';
	
	OPEN promoCursor
	FETCH NEXT FROM promoCursor
	INTO @Promo_ID;

	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		SET @PromotionsToDelete = @PromotionsToDelete + '','' + CAST(@Promo_ID as nvarchar(10));
		
		IF @Promo_ID <> 0 AND @Promo_ID NOT IN (SELECT Deleted_ID FROM dbo.tblKartrisDeletedItems WHERE Deleted_Type = ''r'') BEGIN
			DISABLE Trigger trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
			INSERT INTO dbo.tblKartrisDeletedItems VALUES(@Promo_ID, ''r'', NULL, DateAdd(hour, @Timeoffset, GetDate()));
			Enable Trigger trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
		END
		FETCH NEXT FROM promoCursor
		INTO @Promo_ID;
	END

	CLOSE promoCursor
	DEALLOCATE promoCursor;	
	
	Disable Trigger trigKartrisPromotionParts_DML ON dbo.tblKartrisPromotionParts;
	DELETE FROM dbo.tblKartrisPromotionParts
	WHERE PP_ItemID = @ParentID and PP_ItemType = @ParentType;
	Enable Trigger trigKartrisPromotionParts_DML ON dbo.tblKartrisPromotionParts;
	
	Disable Trigger trigKartrisPromotions_DML ON dbo.tblKartrisPromotions;
	DELETE FROM dbo.tblKartrisPromotions
	WHERE PROM_ID IN (SELECT * FROM dbo.fnTbl_SplitNumbers(@PromotionsToDelete));
	Enable Trigger trigKartrisPromotions_DML ON dbo.tblKartrisPromotions;
		
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPromotionParts_GetByPromotionID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPromotionParts_GetByPromotionID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisPromotionParts_GetByPromotionID]
(
	@PromotionID int,
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
	SELECT   tblKartrisPromotionParts.PROM_ID, tblKartrisPromotionStrings.PS_ID, tblKartrisPromotionStrings.PS_PartNo, 
			 dbo.fnKartrisLanguageStrings_GetValue(@LANG_ID, ''f'', PS_LanguageStringName, ''Promotions'') AS PS_Text, 
			 tblKartrisPromotionParts.PP_ItemID, tblKartrisPromotionParts.PP_Value, 
			 tblKartrisPromotionStrings.PS_Item, tblKartrisPromotionStrings.PS_Type, tblKartrisPromotionParts.PP_ID
	FROM     tblKartrisPromotionParts INNER JOIN
			 tblKartrisPromotionStrings ON tblKartrisPromotionParts.PP_PartNo = tblKartrisPromotionStrings.PS_PartNo AND 
			 tblKartrisPromotionParts.PP_ItemType = tblKartrisPromotionStrings.PS_Item AND tblKartrisPromotionParts.PP_Type = tblKartrisPromotionStrings.PS_Type
	WHERE    (tblKartrisPromotionParts.PROM_ID = @PromotionID)
	ORDER BY tblKartrisPromotionStrings.PS_PartNo, tblKartrisPromotionParts.PP_ID



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPromotionParts_GetByPartsPromotionID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPromotionParts_GetByPartsPromotionID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisPromotionParts_GetByPartsPromotionID]
(
	@PartNo char(1),
	@PromotionID int,
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT     tblKartrisPromotionParts.PROM_ID, tblKartrisPromotionStrings.PS_ID, tblKartrisPromotionStrings.PS_PartNo, 
				dbo.fnKartrisLanguageStrings_GetValue(@LANG_ID, ''f'', PS_LanguageStringName, ''Promotions'') AS PS_Text, 
				tblKartrisPromotionParts.PP_ItemID, tblKartrisPromotionParts.PP_Value, 
				tblKartrisPromotionStrings.PS_Item, tblKartrisPromotionStrings.PS_Type
	FROM    tblKartrisPromotionParts INNER JOIN
		  tblKartrisPromotionStrings ON tblKartrisPromotionParts.PP_PartNo = tblKartrisPromotionStrings.PS_PartNo 
		  AND tblKartrisPromotionParts.PP_ItemType = tblKartrisPromotionStrings.PS_Item 
		  AND tblKartrisPromotionParts.PP_Type = tblKartrisPromotionStrings.PS_Type
	WHERE   (tblKartrisPromotionParts.PROM_ID = @PromotionID) AND (tblKartrisPromotionStrings.PS_PartNo = @PartNo)



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPromotionParts_DeleteByPromotionID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPromotionParts_DeleteByPromotionID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisPromotionParts_DeleteByPromotionID]
(
	@PromotionID int
)
AS
	SET NOCOUNT ON;
Disable Trigger trigKartrisPromotionParts_DML ON tblKartrisPromotionParts;	
	DELETE
	FROM	tblKartrisPromotionParts
	WHERE	tblKartrisPromotionParts.PROM_ID = @PromotionID ;
Enable Trigger trigKartrisPromotionParts_DML ON tblKartrisPromotionParts;	




' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPromotionParts_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPromotionParts_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPromotionParts_Add]
(	@PROM_ID as int,
	@PP_PartNo as char(1),
	@PP_ItemType as char(1),
	@PP_ItemID as bigint,
	@PP_Type as char(1),
	@PP_Value as real
)
AS
	SET NOCOUNT ON;

Disable Trigger trigKartrisPromotionParts_DML ON tblKartrisPromotionParts;	
	INSERT INTO tblKartrisPromotionParts
	VALUES (@PROM_ID, @PP_PartNo, @PP_ItemType, @PP_ItemID, @PP_Type, @PP_Value);
Enable Trigger trigKartrisPromotionParts_DML ON tblKartrisPromotionParts;	
	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_UpdateAsFeatured]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_UpdateAsFeatured]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_UpdateAsFeatured]
(	
	@ProductID as int,
	@Featured as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;

	
Disable Trigger trigKartrisProducts_DML ON tblKartrisProducts;	
	UPDATE dbo.tblKartrisProducts
	SET P_Featured = @Featured
	WHERE P_ID = @ProductID;
Enable Trigger trigKartrisProducts_DML ON tblKartrisProducts;	

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOptions_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOptions_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisOptions_Update]
(
	@OPT_OptionGroupID smallint,
	@OPT_CheckBoxValue bit,
	@OPT_DefPriceChange real,
	@OPT_DefWeightChange real,
	@OPT_DefOrderByValue smallint,
	@Original_OPT_ID int
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisOptions_DML ON tblKartrisOptions;
	UPDATE	[tblKartrisOptions] 
	SET		[OPT_OptionGroupID] = @OPT_OptionGroupID, [OPT_CheckBoxValue] = @OPT_CheckBoxValue, 
			[OPT_DefPriceChange] = @OPT_DefPriceChange, [OPT_DefWeightChange] = @OPT_DefWeightChange, 
			[OPT_DefOrderByValue] = @OPT_DefOrderByValue 
	WHERE	(([OPT_ID] = @Original_OPT_ID));
Enable Trigger trigKartrisOptions_DML ON tblKartrisOptions;
	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_Add](
								@P_Live as bit, 
								@P_Featured as tinyint,
								@P_OrderVersionsBy as nvarchar(50),
								@P_VersionsSortDirection as char(1),
								@P_VersionDisplayType as char(1),
								@P_Reviews as char(1),
								@P_SupplierID as smallint,
								@P_Type as char(1),
								@P_CustomerGroupID as smallint,
								@NowOffset as datetime,
								@NewP_ID as int OUT
								)
AS
BEGIN
	
	SET NOCOUNT ON;

Disable Trigger trigKartrisProducts_DML ON tblKartrisProducts;	
	INSERT INTO tblKartrisProducts
	VALUES (@P_Live, @P_Featured, @P_OrderVersionsBy, @P_VersionsSortDirection, @P_VersionDisplayType, @P_Reviews,
			@P_SupplierID, @P_Type, @P_CustomerGroupID, NULL, @NowOffset, NULL);

	SELECT @NewP_ID = SCOPE_IDENTITY();
	
Enable Trigger trigKartrisProducts_DML ON tblKartrisProducts;	
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOptions_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOptions_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisOptions_Add]
(
	@OPT_OptionGroupID smallint,
	@OPT_CheckBoxValue bit,
	@OPT_DefPriceChange real,
	@OPT_DefWeightChange real,
	@OPT_DefOrderByValue smallint,
	@NewID int OUT
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisOptions_DML ON tblKartrisOptions;
	INSERT INTO [tblKartrisOptions] 
			([OPT_OptionGroupID], [OPT_CheckBoxValue], [OPT_DefPriceChange], [OPT_DefWeightChange], [OPT_DefOrderByValue]) 
	VALUES	(@OPT_OptionGroupID, @OPT_CheckBoxValue, @OPT_DefPriceChange, @OPT_DefWeightChange, @OPT_DefOrderByValue);
	SET @NewID = SCOPE_IDENTITY();
Enable Trigger trigKartrisOptions_DML ON tblKartrisOptions;
	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisNews_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisNews_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisNews_Delete]
(
	@N_ID as int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;
	DELETE FROM dbo.tblKartrisLanguageElements
	WHERE LE_TypeID = 16 AND LE_ParentID = @N_ID;
Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;

Disable Trigger trigKartrisNews_DML ON tblKartrisNews;
	DELETE FROM tblKartrisNews 
	WHERE N_ID = @N_ID;
Enable Trigger trigKartrisNews_DML ON tblKartrisNews;

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_DeleteFeaturedProducts]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_DeleteFeaturedProducts]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_DeleteFeaturedProducts]
AS
BEGIN
	SET NOCOUNT ON;

	
Disable Trigger trigKartrisProducts_DML ON tblKartrisProducts;	
	UPDATE dbo.tblKartrisProducts
	SET P_Featured = 0;
Enable Trigger trigKartrisProducts_DML ON tblKartrisProducts;	

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_GetByProductID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_GetByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ===================================================
-- Author:		Medz
-- Create date: 02/12/2008 13:53:30
-- Description:	Replaces the [spKartris_PROD_Select]
-- ===================================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_GetByProductID]
(
	@P_ID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT *
	FROM   tblKartrisProducts
	WHERE  (P_ID = @P_ID)
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_GetCustomerGroup]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_GetCustomerGroup]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_GetCustomerGroup]
			(
			@P_ID as int,
			@P_CustomerGroup as char(1) OUTPUT
			)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     @P_CustomerGroup = P_CustomerGroupID
	FROM         tblKartrisProducts                       
	WHERE     P_ID = @P_ID
	-- Insert statements for procedure here

	
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_GetProductType_s]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_GetProductType_s]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Get the total no. of Products in Category "used for ItemPager"
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_GetProductType_s]
			(
			@P_ID as int,
			@P_Type as char(1) OUTPUT
			)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     @P_Type = P_Type
	FROM         tblKartrisProducts 
					  
	WHERE     P_ID = @P_ID
	-- Insert statements for procedure here

	
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_GetNameByProductID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_GetNameByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisProducts_GetNameByProductID]
(
	@P_ID int,
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
	SELECT        LE_Value AS P_Name
	FROM          dbo.tblKartrisLanguageElements
	WHERE         LE_LanguageID = @LANG_ID AND LE_TypeID = 2 AND LE_FieldID = 1 AND LE_ParentID = @P_ID

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetNameByVersionID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_GetNameByVersionID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisVersions_GetNameByVersionID]
(
	@V_ID int,
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
	SELECT        LE_Value AS V_Name
	FROM          dbo.tblKartrisLanguageElements
	WHERE         LE_LanguageID = @LANG_ID AND LE_TypeID = 1 AND LE_FieldID = 1 AND LE_ParentID = @V_ID

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisSupportTickets_GetSummary]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisSupportTickets_GetSummary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisSupportTickets_GetSummary]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     tblKartrisSupportTickets.TIC_ID, tblKartrisSupportTickets.TIC_DateOpened, tblKartrisSupportTickets.TIC_DateClosed, tblKartrisSupportTickets.TIC_Subject, 
					  tblKartrisSupportTickets.TIC_UserID, tblKartrisSupportTickets.TIC_LoginID, tblKartrisSupportTickets.TIC_SupportTicketTypeID, tblKartrisSupportTickets.TIC_Status, 
					  tblKartrisLogins.LOGIN_Username, tblKartrisUsers.U_EmailAddress, MAX(tblKartrisSupportTicketMessages.STM_DateCreated) AS LastMessageDate, 
					  tblKartrisSupportTicketTypes.STT_Name, dbo.fnKartrisSupportTicketMessages_IsAwaitingReply(tblKartrisSupportTickets.TIC_ID) As TIC_AwaitingResponse
FROM         tblKartrisSupportTickets INNER JOIN
					  tblKartrisSupportTicketMessages ON tblKartrisSupportTickets.TIC_ID = tblKartrisSupportTicketMessages.STM_TicketID INNER JOIN
					  tblKartrisUsers ON tblKartrisSupportTickets.TIC_UserID = tblKartrisUsers.U_ID LEFT OUTER JOIN
					  tblKartrisSupportTicketTypes ON tblKartrisSupportTickets.TIC_SupportTicketTypeID = tblKartrisSupportTicketTypes.STT_ID LEFT OUTER JOIN
					  tblKartrisLogins ON tblKartrisSupportTickets.TIC_LoginID = tblKartrisLogins.LOGIN_ID
GROUP BY tblKartrisSupportTickets.TIC_ID, tblKartrisSupportTickets.TIC_DateOpened, tblKartrisSupportTickets.TIC_DateClosed, tblKartrisSupportTickets.TIC_Subject, 
					  tblKartrisSupportTickets.TIC_UserID, tblKartrisSupportTickets.TIC_LoginID, tblKartrisSupportTickets.TIC_SupportTicketTypeID, tblKartrisSupportTickets.TIC_Status, 
					  tblKartrisLogins.LOGIN_Username, tblKartrisUsers.U_EmailAddress, tblKartrisSupportTicketTypes.STT_Name, dbo.fnKartrisSupportTicketMessages_IsAwaitingReply(tblKartrisSupportTickets.TIC_ID)
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingRates_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingRates_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisShippingRates_Update]
(
	@S_ID as tinyint,
	@NewRate as real,
	@S_ShippingGateways as nvarchar(255)
)
AS
	SET NOCOUNT ON;
Disable Trigger trigKartrisShippingRates_DML ON tblKartrisShippingRates;	
	UPDATE	tblKartrisShippingRates
	SET		S_ShippingRate = @NewRate, S_ShippingGateways = @S_ShippingGateways
	WHERE	S_ID = @S_ID;
Enable Trigger trigKartrisShippingRates_DML ON tblKartrisShippingRates;	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingRates_GetZonesByMethod]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingRates_GetZonesByMethod]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get Shipping Methods - by Destination and Boundary
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisShippingRates_GetZonesByMethod]
(
	@SM_ID as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT	DISTINCT S_ShippingZoneID
	FROM dbo.tblKartrisShippingRates
	WHERE S_ShippingMethodID = @SM_ID
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingRates_GetByShippingMethod]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingRates_GetByShippingMethod]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get Shipping Methods - by Destination and Boundary
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisShippingRates_GetByShippingMethod]
(
	@SM_ID as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT	S_ID, S_ShippingMethodID, S_ShippingZoneID, 
			CAST(S_Boundary AS Decimal(9, 2)) as S_Boundary, 
			CAST(S_ShippingRate as Decimal(9, 2)) as S_ShippingRate
	FROM dbo.tblKartrisShippingRates
	WHERE S_ShippingMethodID = @SM_ID
	ORDER BY S_ShippingZoneID, S_Boundary, S_ShippingRate

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingRates_GetByMethodAndZone]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingRates_GetByMethodAndZone]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get Shipping Methods - by Destination and Boundary
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisShippingRates_GetByMethodAndZone]
(
	@SM_ID as tinyint,
	@SZ_ID as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT     tblKartrisShippingRates.S_ID, tblKartrisShippingRates.S_ShippingMethodID, tblKartrisShippingRates.S_ShippingZoneID, 
					  CAST(tblKartrisShippingRates.S_Boundary AS Decimal(9, 2)) AS S_Boundary, CAST(tblKartrisShippingRates.S_ShippingRate AS Decimal(9, 2)) 
					  AS S_ShippingRate, tblKartrisCurrencies.CUR_ISOCode, tblKartrisCurrencies.CUR_Symbol, tblKartrisShippingRates.S_ShippingGateways
FROM         tblKartrisShippingRates CROSS JOIN
					  tblKartrisCurrencies
WHERE     (tblKartrisShippingRates.S_ShippingMethodID = @SM_ID) AND (tblKartrisShippingRates.S_ShippingZoneID = @SZ_ID) AND 
					  (tblKartrisCurrencies.CUR_ExchangeRate = 1)
ORDER BY tblKartrisShippingRates.S_ShippingZoneID, S_Boundary, S_ShippingRate

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingRates_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingRates_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisShippingRates_Get]
AS
	SET NOCOUNT ON;
SELECT        tblKartrisShippingRates.*
FROM            tblKartrisShippingRates

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingRates_DeleteByMethodAndZone]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingRates_DeleteByMethodAndZone]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisShippingRates_DeleteByMethodAndZone]
(
	@SM_ID as tinyint,
	@SZ_ID as tinyint
)
AS
	SET NOCOUNT ON;
Disable Trigger trigKartrisShippingRates_DML ON tblKartrisShippingRates;	
	DELETE FROM tblKartrisShippingRates
	WHERE S_ShippingMethodID = @SM_ID AND S_ShippingZoneID = @SZ_ID;
Enable Trigger trigKartrisShippingRates_DML ON tblKartrisShippingRates;	
	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingRates_DeleteByID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingRates_DeleteByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisShippingRates_DeleteByID]
(
	@S_ID as tinyint
)
AS
	SET NOCOUNT ON;
Disable Trigger trigKartrisShippingRates_DML ON tblKartrisShippingRates;	
	DELETE FROM tblKartrisShippingRates
	WHERE S_ID = @S_ID;
Enable Trigger trigKartrisShippingRates_DML ON tblKartrisShippingRates;	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingRates_Copy]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingRates_Copy]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisShippingRates_Copy]
(
	@SM_ID as tinyint,
	@FromZone as tinyint,
	@ToZone as tinyint
)
AS
	SET NOCOUNT ON;

Disable Trigger trigKartrisShippingRates_DML ON tblKartrisShippingRates;	
	INSERT INTO tblKartrisShippingRates
					  (S_ShippingMethodID, S_ShippingZoneID, S_Boundary, S_ShippingRate)
	SELECT     S_ShippingMethodID, @ToZone, S_Boundary, S_ShippingRate
	FROM         tblKartrisShippingRates AS tblKartrisShippingRates_1
	WHERE     (S_ShippingMethodID = @SM_ID) AND (S_ShippingZoneID = @FromZone);
Enable Trigger trigKartrisShippingRates_DML ON tblKartrisShippingRates;	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingRates_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingRates_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisShippingRates_Add]
(
	@SM_ID as tinyint,
	@SZ_ID as tinyint,
	@S_Boundary as real,
	@S_Rate as real,
	@S_ShippingGateways as nvarchar(255)
)
AS
	SET NOCOUNT ON;
Disable Trigger trigKartrisShippingRates_DML ON tblKartrisShippingRates;	
	INSERT	INTO	tblKartrisShippingRates
	VALUES(@SM_ID, @SZ_ID, @S_Boundary, @S_Rate, @S_ShippingGateways);
Enable Trigger trigKartrisShippingRates_DML ON tblKartrisShippingRates;	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingZones_GetNameByZoneID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingZones_GetNameByZoneID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisShippingZones_GetNameByZoneID]
(
	@SZ_ID int,
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
	SELECT        LE_Value AS ZoneName
	FROM          dbo.tblKartrisLanguageElements
	WHERE         LE_LanguageID = @LANG_ID AND LE_TypeID = 10 AND LE_FieldID = 1 AND LE_ParentID = @SZ_ID

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingMethods_GetNameByMethodID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingMethods_GetNameByMethodID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisShippingMethods_GetNameByMethodID]
(
	@SM_ID int,
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
	SELECT        LE_Value AS MethodName
	FROM          dbo.tblKartrisLanguageElements
	WHERE         LE_LanguageID = @LANG_ID AND LE_TypeID = 9 AND LE_FieldID = 1 AND LE_ParentID = @SM_ID

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSupportTickets_GetByUserID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSupportTickets_GetByUserID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisSupportTickets_GetByUserID]
(
	@U_ID as int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     TIC_ID, TIC_DateOpened, TIC_DateClosed, TIC_Subject, 
			dbo.fnKartrisSupportTicketMessages_IsAwaitingReplyFromUser(TIC_ID) as TIC_AwaitingReplay
	FROM         tblKartrisSupportTickets
	WHERE     (TIC_UserID = @U_ID)
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSessionValues_Update]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSessionValues_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisSessionValues_Update]
(
	--@SESSV_ID int,
	@SESSV_SessionID int,
	@SESSV_Name varchar(255),
	@SESSV_Value nvarchar(255),
	@SESSV_Expiry int
)
AS

SET NOCOUNT OFF;

/**
UPDATE tblKartrisSessionValues 
SET SESSV_Value=@SESSV_Value,
	SESSV_Expiry=@SESSV_Expiry
WHERE SESSV_ID = @SESSV_ID
**/

--Disable Trigger trigKartrisSessionValues_DML ON tblKartrisSessionValues;	
	UPDATE tblKartrisSessionValues 
	SET SESSV_Value=@SESSV_Value,
		SESSV_Expiry=@SESSV_Expiry
	WHERE SESSV_SessionID = @SESSV_SessionID
	AND SESSV_Name = @SESSV_Name;
--Enable Trigger trigKartrisSessionValues_DML ON tblKartrisSessionValues;	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSessionValues_Insert]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSessionValues_Insert]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisSessionValues_Insert]
(
	@SESSV_SessionID int,
	@SESSV_Name nvarchar(255),
	@SESSV_Value nvarchar(255),
	@SESSV_Expiry int
)
AS

SET NOCOUNT OFF;

--Disable Trigger trigKartrisSessionValues_DML ON tblKartrisSessionValues;	
	INSERT INTO tblKartrisSessionValues (SESSV_SessionID, SESSV_Name, SESSV_Value, SESSV_Expiry) 
	VALUES (@SESSV_SessionID, @SESSV_Name, @SESSV_Value,@SESSV_Expiry);
--Enable Trigger trigKartrisSessionValues_DML ON tblKartrisSessionValues;	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSessionValues_GetValue]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSessionValues_GetValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisSessionValues_GetValue]
	@SESSV_SessionID AS INT,
	@SESSV_Name AS VARCHAR(255)
AS
	
SET NOCOUNT ON;


SELECT SESSV_Value FROM tblKartrisSessionValues
WHERE SESSV_SessionID=@SESSV_SessionID
AND SESSV_Name=@SESSV_Name

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSessionValues_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSessionValues_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisSessionValues_Get]

AS
	
SET NOCOUNT ON;

SELECT * FROM tblKartrisSessionValues


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSessionValues_Delete]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSessionValues_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisSessionValues_Delete]
(
	@SESSV_SessionID int,
	@SESSV_Name VARCHAR(255)
)
AS
	
SET NOCOUNT OFF;
--Disable Trigger trigKartrisSessionValues_DML ON tblKartrisSessionValues;	
	DELETE FROM tblKartrisSessionValues
	WHERE
	SESSV_SessionID = @SESSV_SessionID
	AND SESSV_Name = @SESSV_Name;
--Enable Trigger trigKartrisSessionValues_DML ON tblKartrisSessionValues;	



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSessionValues_Count]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSessionValues_Count]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 7/Apr/08
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisSessionValues_Count]
	@SESSV_SessionID INT,
	@SESSV_Name VARCHAR(255)
AS
BEGIN

SET NOCOUNT ON;

DECLARE @RecordCount INT

SELECT @RecordCount=count(SESSV_SessionID) FROM tblKartrisSessionValues
WHERE SESSV_SessionID=@SESSV_SessionID AND SESSV_Name=@SESSV_Name

SELECT @RecordCount ''RecordCount''

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSessionValues_Add]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSessionValues_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 18/Aug/2009
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisSessionValues_Add]( 
	@SESSV_SessionID int,
	@SESSV_Name nvarchar(255),
	@SESSV_Value nvarchar(255),
	@SESSV_Expiry int
)AS

BEGIN
	SET NOCOUNT ON;
	
	Declare @cnt int	

	SELECT @cnt=count(SESSV_SessionID) FROM tblKartrisSessionValues
	WHERE SESSV_SessionID=@SESSV_SessionID AND SESSV_Name=@SESSV_Name;

--Disable Trigger trigKartrisSessionValues_DML ON tblKartrisSessionValues;	
	If @cnt>0
	Begin -- update session value
		UPDATE tblKartrisSessionValues 
			SET SESSV_Value=@SESSV_Value,SESSV_Expiry=@SESSV_Expiry	
		WHERE SESSV_SessionID = @SESSV_SessionID AND SESSV_Name = @SESSV_Name;	
	End
	Else -- insert session value
	Begin
		INSERT INTO tblKartrisSessionValues (SESSV_SessionID, SESSV_Name, SESSV_Value, SESSV_Expiry) 
		VALUES (@SESSV_SessionID, @SESSV_Name, @SESSV_Value,@SESSV_Expiry);	
	End;
--Enable Trigger trigKartrisSessionValues_DML ON tblKartrisSessionValues

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSessions_GetSessionValues]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSessions_GetSessionValues]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 9/Feb/08
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisSessions_GetSessionValues] (
	@SESS_ID bigint,
	@SESS_Code nvarchar(100),
	@NowOffset datetime
) AS
BEGIN
	SET NOCOUNT ON;

   select SESS_Code,SESS_DateLastUpdated,SV.* from tblKartrisSessions S
	left join tblKartrisSessionValues SV on S.SESS_ID=SV.SESSV_SessionID
	where SESS_ID=@SESS_ID and SESS_Code=@SESS_Code
	and dateadd(minute,SESS_Expiry,SESS_DateLastUpdated)>=@NowOffset

END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisOrdersPromotions_Add]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisOrdersPromotions_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisOrdersPromotions_Add]
(
	@OrderID as int,
	@PromotionID as int
)
AS
BEGIN
	SET NOCOUNT ON;
Disable Trigger trigKartrisOrdersPromotions_DML ON tblKartrisOrdersPromotions

	INSERT INTO dbo.tblKartrisOrdersPromotions
	VALUES(@OrderID, @PromotionID);

Enable Trigger trigKartrisOrdersPromotions_DML ON tblKartrisOrdersPromotions
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisOptions_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisOptions_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisOptions_Get]
AS
	SET NOCOUNT ON;
SELECT        tblKartrisOptions.*
FROM            tblKartrisOptions

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisLanguageElements_GetElementValue_s]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisLanguageElements_GetElementValue_s]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisLanguageElements_GetElementValue_s]
(
	@LE_LanguageID tinyint,
	@LE_TypeID tinyint,
	@LE_FieldID tinyint,
	@LE_ParentID bigint
)
AS
	SET NOCOUNT OFF;
SELECT LE_Value
FROM [tblKartrisLanguageElements]
WHERE [LE_LanguageID] = @LE_LanguageID AND [LE_TypeID]= @LE_TypeID 
	AND [LE_FieldID]= @LE_FieldID AND [LE_ParentID] = @LE_ParentID;


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisLanguageElements_GetByLanguageID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisLanguageElements_GetByLanguageID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisLanguageElements_GetByLanguageID]
(
	@LanguageID tinyint
)
AS
	SET NOCOUNT ON;
SELECT * FROM tblKartrisLanguageElements WHERE LE_LanguageID = @LanguageID


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisLanguageElements_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisLanguageElements_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisLanguageElements_Get]
AS
	SET NOCOUNT OFF;
SELECT * FROM [tblKartrisLanguageElements];


' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisLanguageElement_GetItemValue]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisLanguageElement_GetItemValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisLanguageElement_GetItemValue] 
(
	-- Add the parameters for the function here
	@LE_LANGID as tinyint,
	@LE_TypeID as tinyint,
	@LE_FieldID as tinyint,
	@LE_ParentID as int
)
RETURNS nvarchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(MAX);
	SET @Result = '''';
	
	SELECT @Result = LE_Value
	FROM tblKartrisLanguageElements 
	WHERE LE_LanguageID = @LE_LANGID AND
			LE_TypeID = @LE_TypeID AND
			LE_FieldID = @LE_FieldID AND
			LE_ParentID = @LE_ParentID;

	
	-- Return the result of the function
	RETURN @Result

END

' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartris_GetShippingMethod]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartris_GetShippingMethod]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 26/Aug/08
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnKartris_GetShippingMethod] (
	@ShippingMethodID int,
	@LanguageID int
)
RETURNS nvarchar(100)
AS
BEGIN
	DECLARE @Result nvarchar(100)
		
	select @Result=LE_Value from tblKartrisLanguageElementTypes LET
	inner join tblKartrisLanguageElements LE on LET.LET_ID=LE.LE_TypeID and LE_ParentID=@ShippingMethodId and LE_FieldID=1
	where LET.LET_Name=''tblKartrisShippingMethods'' and LE_LanguageID=@LanguageID

	RETURN @Result

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingZones_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingZones_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	DELETE Shipping Zone
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisShippingZones_Delete]
(
	@ZoneID as tinyint,
	@AssignedZoneID as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;


	--1. Assign Zones
	IF @AssignedZoneID <> 0
	BEGIN
Disable Trigger trigKartrisDestination_DML ON tblKartrisDestination;	
		UPDATE dbo.tblKartrisDestination
		SET D_ShippingZoneID = @AssignedZoneID
		WHERE D_ShippingZoneID = @ZoneID;
Enable Trigger trigKartrisDestination_DML ON tblKartrisDestination;	
	END;

	--2. Delete Zone''s Rates
Disable Trigger trigKartrisShippingRates_DML ON tblKartrisShippingRates;	
	DELETE FROM tblKartrisShippingRates
	WHERE S_ShippingZoneID = @ZoneID;
Enable Trigger trigKartrisShippingRates_DML ON tblKartrisShippingRates;	

	--3. Delete The LanguageElements
Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;	
	DELETE FROM dbo.tblKartrisLanguageElements
	WHERE LE_TypeID = 10 AND LE_ParentID = @ZoneID;
Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;	

	--4. Delete the Zone itself
Disable Trigger trigKartrisShippingZones_DML ON tblKartrisShippingZones;	
	DELETE FROM dbo.tblKartrisShippingZones
	WHERE SZ_ID = @ZoneID;
Enable Trigger trigKartrisShippingZones_DML ON tblKartrisShippingZones;	

END


' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartris_GetCountryString]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartris_GetCountryString]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 25/Aug/08
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnKartris_GetCountryString] (
	@DestinationID int,
	@LanguageID int
)
RETURNS nvarchar(100)
AS
BEGIN

	DECLARE @Result nvarchar(100)
		
	select @Result=LE_Value from tblKartrisLanguageElementTypes LET
	inner join tblKartrisLanguageElements LE on LET.LET_ID=LE.LE_TypeID and LE_ParentID=199
	where LET.LET_Name=''tblKartrisDestination'' and LE_LanguageID=1

	RETURN @Result
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_GetOrderHandlingCharge]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_GetOrderHandlingCharge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 19/June/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_GetOrderHandlingCharge] ( 
	@ShippingCountryID integer,
	@TaxBand float
) AS
BEGIN
	SET NOCOUNT ON;

	select * from tblKartrisDestination,tblKartrisTaxRates
	where D_ID=@ShippingCountryID and T_ID=@TaxBand

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCategories_GetByLanguageID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCategories_GetByLanguageID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisCategories_GetByLanguageID](@LanguageID as tinyint)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	SELECT  CAT_ID, tblKartrisLanguageElements.LE_Value AS CAT_Name, 
			tblKartrisLanguageElements_temp.LE_Value AS CAT_Desc, 
			CAT_Live, CAT_ProductDisplayType, CAT_SubCatDisplayType,CAT_OrderProductsBy, 
			CAT_CustomerGroupID
	FROM    tblKartrisCategories INNER JOIN
			tblKartrisLanguageElements ON CAT_ID = tblKartrisLanguageElements.LE_ParentID INNER JOIN
			tblKartrisLanguageElements AS tblKartrisLanguageElements_temp ON CAT_ID = tblKartrisLanguageElements_temp.LE_ParentID AND 
			tblKartrisLanguageElements.LE_ParentID = tblKartrisLanguageElements_temp.LE_ParentID AND 
			tblKartrisLanguageElements.LE_LanguageID = tblKartrisLanguageElements_temp.LE_LanguageID AND 
			tblKartrisLanguageElements.LE_TypeID = tblKartrisLanguageElements_temp.LE_TypeID
	WHERE	(tblKartrisLanguageElements.LE_LanguageID = @LanguageID)
			AND (tblKartrisLanguageElements.LE_FieldID = 1) 
			AND (tblKartrisLanguageElements_temp.LE_FieldID = 2) 
			AND (tblKartrisLanguageElements.LE_TypeID = 3)
END


' 
END
GO
/****** Object:  View [dbo].[vKartrisTypeAttributes]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisTypeAttributes]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisTypeAttributes]
AS
SELECT     dbo.tblKartrisAttributes.ATTRIB_ID, dbo.tblKartrisLanguageElements.LE_LanguageID AS LANG_ID, dbo.tblKartrisLanguageElements.LE_Value AS ATTRIB_Name, 
					  dbo.tblKartrisAttributes.ATTRIB_Type, dbo.tblKartrisAttributes.ATTRIB_Live, dbo.tblKartrisAttributes.ATTRIB_FastEntry, dbo.tblKartrisAttributes.ATTRIB_ShowFrontend, 
					  dbo.tblKartrisAttributes.ATTRIB_ShowSearch, dbo.tblKartrisAttributes.ATTRIB_OrderByValue, dbo.tblKartrisAttributes.ATTRIB_Compare, 
					  dbo.tblKartrisAttributes.ATTRIB_Special
FROM         dbo.tblKartrisLanguageElements INNER JOIN
					  dbo.tblKartrisAttributes ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisAttributes.ATTRIB_ID
WHERE     (dbo.tblKartrisLanguageElements.LE_TypeID = 4) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND 
					  (dbo.tblKartrisLanguageElements.LE_Value IS NOT NULL)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeAttributes', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[41] 4[20] 2[12] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 6
			   Left = 277
			   Bottom = 140
			   Right = 460
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisAttributes"
			Begin Extent = 
			   Top = 6
			   Left = 38
			   Bottom = 199
			   Right = 239
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 13
		 Width = 284
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 1440
		 Alias = 2445
		 Table = 2070
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeAttributes'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeAttributes', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeAttributes'
GO
/****** Object:  View [dbo].[vKartrisLanguageElementsNames]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisLanguageElementsNames]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisLanguageElementsNames]
AS
SELECT     TOP (100) PERCENT dbo.tblKartrisLanguageElementTypes.LET_Name AS [Table], dbo.tblKartrisLanguageElements.LE_ParentID AS [Record ID], 
					  dbo.tblKartrisLanguageElementFieldNames.LEFN_Name AS [Field Related Name], dbo.tblKartrisLanguages.LANG_FrontName AS Language, 
					  dbo.tblKartrisLanguageElements.LE_Value AS Value
FROM         dbo.tblKartrisLanguageElements INNER JOIN
					  dbo.tblKartrisLanguages ON dbo.tblKartrisLanguageElements.LE_LanguageID = dbo.tblKartrisLanguages.LANG_ID INNER JOIN
					  dbo.tblKartrisLanguageElementTypes ON dbo.tblKartrisLanguageElements.LE_TypeID = dbo.tblKartrisLanguageElementTypes.LET_ID INNER JOIN
					  dbo.tblKartrisLanguageElementFieldNames ON dbo.tblKartrisLanguageElements.LE_FieldID = dbo.tblKartrisLanguageElementFieldNames.LEFN_ID
WHERE     (dbo.tblKartrisLanguageElements.LE_Value IS NOT NULL)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisLanguageElementsNames', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[42] 4[26] 2[10] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 6
			   Left = 38
			   Bottom = 149
			   Right = 202
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguages"
			Begin Extent = 
			   Top = 6
			   Left = 636
			   Bottom = 178
			   Right = 855
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElementTypes"
			Begin Extent = 
			   Top = 102
			   Left = 237
			   Bottom = 208
			   Right = 481
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElementFieldNames"
			Begin Extent = 
			   Top = 0
			   Left = 352
			   Bottom = 94
			   Right = 615
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 9
		 Width = 284
		 Width = 2070
		 Width = 1260
		 Width = 1740
		 Width = 1500
		 Width = 2430
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 2115
		 Alias = 1950
		 Table = 1170
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisLanguageElementsNames'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisLanguageElementsNames', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'= 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisLanguageElementsNames'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisLanguageElementsNames', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisLanguageElementsNames'
GO
/****** Object:  View [dbo].[vKartrisLanguageElements]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisLanguageElements]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisLanguageElements]
AS
SELECT     TOP (100) PERCENT LE_LanguageID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value
FROM         dbo.tblKartrisLanguageElements
WHERE     (LE_Value IS NOT NULL)

'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisLanguageElements', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[29] 4[31] 2[10] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 5
			   Left = 204
			   Bottom = 138
			   Right = 368
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 9
		 Width = 284
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1455
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 1440
		 Alias = 900
		 Table = 1170
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisLanguageElements'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisLanguageElements', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisLanguageElements'
GO
/****** Object:  View [dbo].[vKartrisTypeShippingZones]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisTypeShippingZones]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisTypeShippingZones]
AS
SELECT     dbo.tblKartrisShippingZones.SZ_ID, dbo.tblKartrisLanguageElements.LE_LanguageID AS LANG_ID, dbo.tblKartrisLanguageElements.LE_Value AS SZ_Name, 
					  dbo.tblKartrisShippingZones.SZ_Live, dbo.tblKartrisShippingZones.SZ_OrderByValue
FROM         dbo.tblKartrisLanguageElements INNER JOIN
					  dbo.tblKartrisShippingZones ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisShippingZones.SZ_ID
WHERE     (dbo.tblKartrisLanguageElements.LE_TypeID = 10) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND 
					  (dbo.tblKartrisLanguageElements.LE_Value IS NOT NULL)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeShippingZones', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[40] 4[20] 2[20] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 6
			   Left = 295
			   Bottom = 123
			   Right = 459
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisShippingZones"
			Begin Extent = 
			   Top = 15
			   Left = 521
			   Bottom = 117
			   Right = 694
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 9
		 Width = 284
		 Width = 1500
		 Width = 1500
		 Width = 2400
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 1440
		 Alias = 900
		 Table = 2760
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeShippingZones'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeShippingZones', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeShippingZones'
GO
/****** Object:  View [dbo].[vKartrisTypeShippingMethods]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisTypeShippingMethods]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisTypeShippingMethods]
AS
SELECT     dbo.tblKartrisShippingMethods.SM_ID, dbo.tblKartrisLanguages.LANG_ID, dbo.tblKartrisLanguageElements.LE_Value AS SM_Name, 
					  tblKartrisLanguageElements_1.LE_Value AS SM_Desc, dbo.tblKartrisShippingMethods.SM_Live, dbo.tblKartrisShippingMethods.SM_OrderByValue, 
					  dbo.tblKartrisShippingMethods.SM_Tax, dbo.tblKartrisShippingMethods.SM_Tax2
FROM         dbo.tblKartrisLanguages INNER JOIN
					  dbo.tblKartrisLanguageElements ON dbo.tblKartrisLanguages.LANG_ID = dbo.tblKartrisLanguageElements.LE_LanguageID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_1 ON 
					  dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_1.LE_LanguageID INNER JOIN
					  dbo.tblKartrisShippingMethods ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisShippingMethods.SM_ID AND 
					  tblKartrisLanguageElements_1.LE_ParentID = dbo.tblKartrisShippingMethods.SM_ID
WHERE     (dbo.tblKartrisLanguageElements.LE_TypeID = 9) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (dbo.tblKartrisLanguageElements.LE_Value IS NOT NULL)
					   AND (tblKartrisLanguageElements_1.LE_TypeID = 9) AND (tblKartrisLanguageElements_1.LE_FieldID = 2) OR
					  (dbo.tblKartrisLanguageElements.LE_TypeID = 9) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_TypeID = 9) AND 
					  (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (tblKartrisLanguageElements_1.LE_Value IS NOT NULL)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeShippingMethods', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[41] 4[26] 2[14] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguages"
			Begin Extent = 
			   Top = 6
			   Left = 38
			   Bottom = 123
			   Right = 257
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 6
			   Left = 295
			   Bottom = 123
			   Right = 459
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements_1"
			Begin Extent = 
			   Top = 157
			   Left = 289
			   Bottom = 274
			   Right = 453
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisShippingMethods"
			Begin Extent = 
			   Top = 6
			   Left = 497
			   Bottom = 134
			   Right = 672
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 9
		 Width = 284
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 1440
		 Alias = 900
		 Table = 2700
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
	' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeShippingMethods'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeShippingMethods', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'     Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeShippingMethods'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeShippingMethods', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeShippingMethods'
GO
/****** Object:  View [dbo].[vKartrisTypePromotions]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisTypePromotions]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisTypePromotions]
AS
SELECT     dbo.tblKartrisPromotions.PROM_ID, dbo.tblKartrisLanguageElements.LE_LanguageID AS LANG_ID, dbo.tblKartrisLanguageElements.LE_Value AS PROM_Name, 
					  dbo.tblKartrisPromotions.PROM_StartDate, dbo.tblKartrisPromotions.PROM_EndDate, dbo.tblKartrisPromotions.PROM_Live, 
					  dbo.tblKartrisPromotions.PROM_OrderByValue, dbo.tblKartrisPromotions.PROM_MaxQuantity
FROM         dbo.tblKartrisLanguageElements INNER JOIN
					  dbo.tblKartrisPromotions ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisPromotions.PROM_ID
WHERE     (dbo.tblKartrisLanguageElements.LE_TypeID = 7) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND 
					  (dbo.tblKartrisLanguageElements.LE_Value IS NOT NULL)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypePromotions', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[41] 4[26] 2[14] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 6
			   Left = 38
			   Bottom = 149
			   Right = 202
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisPromotions"
			Begin Extent = 
			   Top = 6
			   Left = 240
			   Bottom = 247
			   Right = 430
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 15
		 Width = 284
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 4140
		 Alias = 900
		 Table = 1170
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypePromotions'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypePromotions', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypePromotions'
GO
/****** Object:  View [dbo].[vKartrisTypeProducts]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisTypeProducts]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisTypeProducts]
AS
SELECT     dbo.tblKartrisProducts.P_ID, dbo.tblKartrisLanguages.LANG_ID, dbo.tblKartrisLanguageElements.LE_Value AS P_Name, 
					  tblKartrisLanguageElements_1.LE_Value AS P_Desc, tblKartrisLanguageElements_2.LE_Value AS P_StrapLine, 
					  tblKartrisLanguageElements_3.LE_Value AS P_PageTitle, dbo.tblKartrisProducts.P_Live, dbo.tblKartrisProducts.P_Featured, 
					  dbo.tblKartrisProducts.P_OrderVersionsBy, dbo.tblKartrisProducts.P_VersionsSortDirection, dbo.tblKartrisProducts.P_VersionDisplayType, 
					  dbo.tblKartrisProducts.P_Reviews, dbo.tblKartrisProducts.P_SupplierID, dbo.tblKartrisProducts.P_Type, dbo.tblKartrisProducts.P_CustomerGroupID, 
					  dbo.tblKartrisProducts.P_AverageRating, dbo.tblKartrisProducts.P_DateCreated, dbo.tblKartrisProducts.P_LastModified
FROM         dbo.tblKartrisLanguageElements INNER JOIN
					  dbo.tblKartrisLanguages ON dbo.tblKartrisLanguageElements.LE_LanguageID = dbo.tblKartrisLanguages.LANG_ID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_1 ON 
					  dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_1.LE_LanguageID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_2 ON 
					  dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_2.LE_LanguageID INNER JOIN
					  dbo.tblKartrisProducts ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisProducts.P_ID AND 
					  tblKartrisLanguageElements_1.LE_ParentID = dbo.tblKartrisProducts.P_ID AND tblKartrisLanguageElements_2.LE_ParentID = dbo.tblKartrisProducts.P_ID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_3 ON dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_3.LE_LanguageID AND 
					  dbo.tblKartrisProducts.P_ID = tblKartrisLanguageElements_3.LE_ParentID
WHERE     (dbo.tblKartrisLanguageElements.LE_TypeID = 2) AND (tblKartrisLanguageElements_1.LE_TypeID = 2) AND (tblKartrisLanguageElements_2.LE_TypeID = 2) AND 
					  (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (tblKartrisLanguageElements_2.LE_FieldID = 7) AND 
					  (NOT (dbo.tblKartrisLanguageElements.LE_Value IS NULL)) AND (tblKartrisLanguageElements_3.LE_TypeID = 2) AND 
					  (tblKartrisLanguageElements_3.LE_FieldID = 3) OR
					  (dbo.tblKartrisLanguageElements.LE_TypeID = 2) AND (tblKartrisLanguageElements_1.LE_TypeID = 2) AND (tblKartrisLanguageElements_2.LE_TypeID = 2) AND 
					  (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (tblKartrisLanguageElements_2.LE_FieldID = 7) AND 
					  (NOT (tblKartrisLanguageElements_1.LE_Value IS NULL)) AND (tblKartrisLanguageElements_3.LE_TypeID = 2) AND 
					  (tblKartrisLanguageElements_3.LE_FieldID = 3) OR
					  (dbo.tblKartrisLanguageElements.LE_TypeID = 2) AND (tblKartrisLanguageElements_1.LE_TypeID = 2) AND (tblKartrisLanguageElements_2.LE_TypeID = 2) AND 
					  (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (tblKartrisLanguageElements_2.LE_FieldID = 7) AND 
					  (NOT (tblKartrisLanguageElements_2.LE_Value IS NULL)) AND (tblKartrisLanguageElements_3.LE_TypeID = 2) AND 
					  (tblKartrisLanguageElements_3.LE_FieldID = 3) OR
					  (dbo.tblKartrisLanguageElements.LE_TypeID = 2) AND (tblKartrisLanguageElements_1.LE_TypeID = 2) AND (tblKartrisLanguageElements_2.LE_TypeID = 2) AND 
					  (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (tblKartrisLanguageElements_2.LE_FieldID = 7) AND 
					  (NOT (tblKartrisLanguageElements_3.LE_Value IS NULL)) AND (tblKartrisLanguageElements_3.LE_TypeID = 2) AND (tblKartrisLanguageElements_3.LE_FieldID = 3)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeProducts', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[45] 4[19] 2[18] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1[41] 4[21] 3) )"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 1
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 6
			   Left = 38
			   Bottom = 136
			   Right = 251
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguages"
			Begin Extent = 
			   Top = 8
			   Left = 530
			   Bottom = 125
			   Right = 749
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements_1"
			Begin Extent = 
			   Top = 153
			   Left = 82
			   Bottom = 288
			   Right = 310
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements_2"
			Begin Extent = 
			   Top = 116
			   Left = 841
			   Bottom = 253
			   Right = 1068
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisProducts"
			Begin Extent = 
			   Top = 128
			   Left = 534
			   Bottom = 252
			   Right = 728
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements_3"
			Begin Extent = 
			   Top = 268
			   Left = 831
			   Bottom = 402
			   Right = 1057
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
	  PaneHidden = 
   End
   Begin DataPane = 
	  Begin ParameterDe' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeProducts'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeProducts', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'faults = ""
	  End
	  Begin ColumnWidths = 21
		 Width = 284
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 2340
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 12
		 Column = 5055
		 Alias = 1335
		 Table = 2775
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeProducts'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeProducts', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeProducts'
GO
/****** Object:  View [dbo].[vKartrisTypePages]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisTypePages]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisTypePages]
AS
SELECT     dbo.tblKartrisPages.PAGE_ID, dbo.tblKartrisPages.PAGE_Name, dbo.tblKartrisPages.PAGE_ParentID, dbo.tblKartrisLanguages.LANG_ID, 
					  dbo.tblKartrisLanguageElements.LE_Value AS PAGE_Title, tblKartrisLanguageElements_1.LE_Value AS PAGE_MetaDescription, 
					  tblKartrisLanguageElements_2.LE_Value AS PAGE_MetaKeywords, tblKartrisLanguageElements_3.LE_Value AS PAGE_Text, dbo.tblKartrisPages.PAGE_DateCreated, 
					  dbo.tblKartrisPages.PAGE_LastUpdated, dbo.tblKartrisPages.PAGE_Live
FROM         dbo.tblKartrisLanguageElements INNER JOIN
					  dbo.tblKartrisLanguages ON dbo.tblKartrisLanguageElements.LE_LanguageID = dbo.tblKartrisLanguages.LANG_ID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_1 ON 
					  dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_1.LE_LanguageID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_3 ON 
					  dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_3.LE_LanguageID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_2 ON 
					  dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_2.LE_LanguageID INNER JOIN
					  dbo.tblKartrisPages ON tblKartrisLanguageElements_3.LE_ParentID = dbo.tblKartrisPages.PAGE_ID AND 
					  dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisPages.PAGE_ID AND tblKartrisLanguageElements_2.LE_ParentID = dbo.tblKartrisPages.PAGE_ID AND 
					  tblKartrisLanguageElements_1.LE_ParentID = dbo.tblKartrisPages.PAGE_ID
WHERE     (dbo.tblKartrisLanguageElements.LE_TypeID = 8) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 3) AND 
					  (dbo.tblKartrisLanguageElements.LE_Value IS NOT NULL) AND (tblKartrisLanguageElements_1.LE_TypeID = 8) AND (tblKartrisLanguageElements_1.LE_FieldID = 4) 
					  AND (tblKartrisLanguageElements_2.LE_TypeID = 8) AND (tblKartrisLanguageElements_2.LE_FieldID = 5) AND (tblKartrisLanguageElements_3.LE_TypeID = 8) AND 
					  (tblKartrisLanguageElements_3.LE_FieldID = 6) OR
					  (dbo.tblKartrisLanguageElements.LE_TypeID = 8) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 3) AND (tblKartrisLanguageElements_1.LE_TypeID = 8) AND 
					  (tblKartrisLanguageElements_1.LE_FieldID = 4) AND (tblKartrisLanguageElements_2.LE_TypeID = 8) AND (tblKartrisLanguageElements_2.LE_FieldID = 5) AND 
					  (tblKartrisLanguageElements_3.LE_TypeID = 8) AND (tblKartrisLanguageElements_3.LE_FieldID = 6) AND (tblKartrisLanguageElements_1.LE_Value IS NOT NULL) OR
					  (dbo.tblKartrisLanguageElements.LE_TypeID = 8) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 3) AND (tblKartrisLanguageElements_1.LE_TypeID = 8) AND 
					  (tblKartrisLanguageElements_1.LE_FieldID = 4) AND (tblKartrisLanguageElements_2.LE_TypeID = 8) AND (tblKartrisLanguageElements_2.LE_FieldID = 5) AND 
					  (tblKartrisLanguageElements_3.LE_TypeID = 8) AND (tblKartrisLanguageElements_3.LE_FieldID = 6) AND (tblKartrisLanguageElements_2.LE_Value IS NOT NULL) OR
					  (dbo.tblKartrisLanguageElements.LE_TypeID = 8) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 3) AND (tblKartrisLanguageElements_1.LE_TypeID = 8) AND 
					  (tblKartrisLanguageElements_1.LE_FieldID = 4) AND (tblKartrisLanguageElements_2.LE_TypeID = 8) AND (tblKartrisLanguageElements_2.LE_FieldID = 5) AND 
					  (tblKartrisLanguageElements_3.LE_TypeID = 8) AND (tblKartrisLanguageElements_3.LE_FieldID = 6) AND (tblKartrisLanguageElements_3.LE_Value IS NOT NULL)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypePages', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[41] 4[28] 2[13] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 80
			   Left = 317
			   Bottom = 211
			   Right = 542
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguages"
			Begin Extent = 
			   Top = 16
			   Left = 37
			   Bottom = 133
			   Right = 256
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements_1"
			Begin Extent = 
			   Top = 211
			   Left = 316
			   Bottom = 341
			   Right = 541
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements_3"
			Begin Extent = 
			   Top = 0
			   Left = 589
			   Bottom = 138
			   Right = 843
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements_2"
			Begin Extent = 
			   Top = 190
			   Left = 41
			   Bottom = 324
			   Right = 269
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisPages"
			Begin Extent = 
			   Top = 144
			   Left = 873
			   Bottom = 279
			   Right = 1069
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypePages'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypePages', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'      Begin ColumnWidths = 12
		 Width = 284
		 Width = 1500
		 Width = 1260
		 Width = 2085
		 Width = 2310
		 Width = 2175
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 12
		 Column = 1440
		 Alias = 1845
		 Table = 2535
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypePages'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypePages', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypePages'
GO
/****** Object:  View [dbo].[vKartrisTypeOptions]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisTypeOptions]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisTypeOptions]
AS
SELECT     dbo.tblKartrisOptions.OPT_ID, dbo.tblKartrisLanguageElements.LE_LanguageID AS LANG_ID, dbo.tblKartrisLanguageElements.LE_Value AS OPT_Name, 
					  dbo.tblKartrisOptions.OPT_OptionGroupID, dbo.tblKartrisOptions.OPT_CheckBoxValue, dbo.tblKartrisOptions.OPT_DefPriceChange, 
					  dbo.tblKartrisOptions.OPT_DefWeightChange, dbo.tblKartrisOptions.OPT_DefOrderByValue
FROM         dbo.tblKartrisLanguageElements INNER JOIN
					  dbo.tblKartrisOptions ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisOptions.OPT_ID
WHERE     (dbo.tblKartrisLanguageElements.LE_TypeID = 5) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND 
					  (dbo.tblKartrisLanguageElements.LE_Value IS NOT NULL)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeOptions', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[41] 4[25] 2[15] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 6
			   Left = 295
			   Bottom = 123
			   Right = 459
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisOptions"
			Begin Extent = 
			   Top = 4
			   Left = 522
			   Bottom = 163
			   Right = 725
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 10
		 Width = 284
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 1440
		 Alias = 1770
		 Table = 1170
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeOptions'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeOptions', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeOptions'
GO
/****** Object:  View [dbo].[vKartrisTypeOptionGroups]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisTypeOptionGroups]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisTypeOptionGroups]
AS
SELECT     dbo.tblKartrisOptionGroups.OPTG_ID, dbo.tblKartrisLanguages.LANG_ID, dbo.tblKartrisLanguageElements.LE_Value AS OPTG_Name, 
					  tblKartrisLanguageElements_1.LE_Value AS OPTG_Desc, dbo.tblKartrisOptionGroups.OPTG_BackendName, dbo.tblKartrisOptionGroups.OPTG_OptionDisplayType, 
					  dbo.tblKartrisOptionGroups.OPTG_DefOrderByValue
FROM         dbo.tblKartrisLanguages INNER JOIN
					  dbo.tblKartrisLanguageElements ON dbo.tblKartrisLanguages.LANG_ID = dbo.tblKartrisLanguageElements.LE_LanguageID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_1 ON 
					  dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_1.LE_LanguageID INNER JOIN
					  dbo.tblKartrisOptionGroups ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisOptionGroups.OPTG_ID AND 
					  tblKartrisLanguageElements_1.LE_ParentID = dbo.tblKartrisOptionGroups.OPTG_ID
WHERE     (dbo.tblKartrisLanguageElements.LE_TypeID = 6) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND 
					  (dbo.tblKartrisLanguageElements.LE_Value IS NOT NULL) AND (tblKartrisLanguageElements_1.LE_TypeID = 6) AND 
					  (tblKartrisLanguageElements_1.LE_FieldID = 2) OR
					  (dbo.tblKartrisLanguageElements.LE_TypeID = 6) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_TypeID = 6) AND 
					  (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (tblKartrisLanguageElements_1.LE_Value IS NOT NULL)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeOptionGroups', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[41] 4[23] 2[18] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguages"
			Begin Extent = 
			   Top = 6
			   Left = 38
			   Bottom = 123
			   Right = 257
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 4
			   Left = 330
			   Bottom = 121
			   Right = 494
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements_1"
			Begin Extent = 
			   Top = 149
			   Left = 321
			   Bottom = 284
			   Right = 485
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisOptionGroups"
			Begin Extent = 
			   Top = 6
			   Left = 699
			   Bottom = 173
			   Right = 911
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 9
		 Width = 284
		 Width = 1095
		 Width = 1020
		 Width = 1500
		 Width = 1665
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 1440
		 Alias = 2205
		 Table = 2640
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
	  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeOptionGroups'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeOptionGroups', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'   Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeOptionGroups'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeOptionGroups', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeOptionGroups'
GO
/****** Object:  View [dbo].[vKartrisTypeNews]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisTypeNews]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisTypeNews]
AS
SELECT     dbo.tblKartrisNews.N_ID, dbo.tblKartrisLanguages.LANG_ID, dbo.tblKartrisLanguageElements.LE_Value AS N_Name, 
					  tblKartrisLanguageElements_1.LE_Value AS N_Text, tblKartrisLanguageElements_2.LE_Value AS N_StrapLine, dbo.tblKartrisNews.N_DateCreated, 
					  dbo.tblKartrisNews.N_LastUpdated
FROM         dbo.tblKartrisLanguageElements INNER JOIN
					  dbo.tblKartrisLanguages ON dbo.tblKartrisLanguageElements.LE_LanguageID = dbo.tblKartrisLanguages.LANG_ID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_1 ON 
					  dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_1.LE_LanguageID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_2 ON 
					  dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_2.LE_LanguageID INNER JOIN
					  dbo.tblKartrisNews ON tblKartrisLanguageElements_1.LE_ParentID = dbo.tblKartrisNews.N_ID AND 
					  dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisNews.N_ID AND tblKartrisLanguageElements_2.LE_ParentID = dbo.tblKartrisNews.N_ID
WHERE     (dbo.tblKartrisLanguageElements.LE_TypeID = 16) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_TypeID = 16) AND 
					  (tblKartrisLanguageElements_1.LE_FieldID = 6) AND (NOT (dbo.tblKartrisLanguageElements.LE_Value IS NULL)) AND 
					  (tblKartrisLanguageElements_2.LE_TypeID = 16) AND (tblKartrisLanguageElements_2.LE_FieldID = 7) OR
					  (dbo.tblKartrisLanguageElements.LE_TypeID = 16) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_TypeID = 16) AND 
					  (tblKartrisLanguageElements_1.LE_FieldID = 6) AND (tblKartrisLanguageElements_2.LE_TypeID = 16) AND (tblKartrisLanguageElements_2.LE_FieldID = 7) AND 
					  (NOT (tblKartrisLanguageElements_1.LE_Value IS NULL)) OR
					  (dbo.tblKartrisLanguageElements.LE_TypeID = 16) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_TypeID = 16) AND 
					  (tblKartrisLanguageElements_1.LE_FieldID = 6) AND (tblKartrisLanguageElements_2.LE_TypeID = 16) AND (tblKartrisLanguageElements_2.LE_FieldID = 7) AND 
					  (NOT (tblKartrisLanguageElements_2.LE_Value IS NULL))
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeNews', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[33] 4[28] 2[20] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 6
			   Left = 286
			   Bottom = 149
			   Right = 450
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguages"
			Begin Extent = 
			   Top = 6
			   Left = 488
			   Bottom = 123
			   Right = 707
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements_1"
			Begin Extent = 
			   Top = 6
			   Left = 745
			   Bottom = 136
			   Right = 909
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements_2"
			Begin Extent = 
			   Top = 6
			   Left = 38
			   Bottom = 123
			   Right = 202
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisNews"
			Begin Extent = 
			   Top = 157
			   Left = 423
			   Bottom = 265
			   Right = 586
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 9
		 Width = 284
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Be' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeNews'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeNews', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'gin ColumnWidths = 11
		 Column = 2145
		 Alias = 2085
		 Table = 2640
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeNews'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeNews', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeNews'
GO
/****** Object:  View [dbo].[vKartrisTypeKnowledgeBase]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisTypeKnowledgeBase]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisTypeKnowledgeBase]
AS
SELECT     dbo.tblKartrisKnowledgeBase.KB_ID, dbo.tblKartrisLanguages.LANG_ID, tblKartrisLanguageElements_4.LE_Value AS KB_Name, 
					  dbo.tblKartrisLanguageElements.LE_Value AS KB_PageTitle, tblKartrisLanguageElements_1.LE_Value AS KB_MetaDescription, 
					  tblKartrisLanguageElements_2.LE_Value AS KB_MetaKeywords, tblKartrisLanguageElements_3.LE_Value AS KB_Text, dbo.tblKartrisKnowledgeBase.KB_DateCreated,
					   dbo.tblKartrisKnowledgeBase.KB_LastUpdated, dbo.tblKartrisKnowledgeBase.KB_Live
FROM         dbo.tblKartrisLanguageElements INNER JOIN
					  dbo.tblKartrisLanguages ON dbo.tblKartrisLanguageElements.LE_LanguageID = dbo.tblKartrisLanguages.LANG_ID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_1 ON 
					  dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_1.LE_LanguageID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_3 ON 
					  dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_3.LE_LanguageID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_2 ON 
					  dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_2.LE_LanguageID INNER JOIN
					  dbo.tblKartrisKnowledgeBase ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisKnowledgeBase.KB_ID AND 
					  tblKartrisLanguageElements_1.LE_ParentID = dbo.tblKartrisKnowledgeBase.KB_ID AND 
					  tblKartrisLanguageElements_3.LE_ParentID = dbo.tblKartrisKnowledgeBase.KB_ID AND 
					  tblKartrisLanguageElements_2.LE_ParentID = dbo.tblKartrisKnowledgeBase.KB_ID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_4 ON dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_4.LE_LanguageID AND 
					  dbo.tblKartrisKnowledgeBase.KB_ID = tblKartrisLanguageElements_4.LE_ParentID
WHERE     (dbo.tblKartrisLanguageElements.LE_TypeID = 17) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 3) AND 
					  (dbo.tblKartrisLanguageElements.LE_Value IS NOT NULL) AND (tblKartrisLanguageElements_1.LE_TypeID = 17) AND (tblKartrisLanguageElements_1.LE_FieldID = 4) 
					  AND (tblKartrisLanguageElements_2.LE_TypeID = 17) AND (tblKartrisLanguageElements_2.LE_FieldID = 5) AND (tblKartrisLanguageElements_3.LE_TypeID = 17) AND 
					  (tblKartrisLanguageElements_3.LE_FieldID = 6) AND (tblKartrisLanguageElements_4.LE_TypeID = 17) AND (tblKartrisLanguageElements_4.LE_FieldID = 1) OR
					  (dbo.tblKartrisLanguageElements.LE_TypeID = 17) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 3) AND (tblKartrisLanguageElements_1.LE_TypeID = 17) AND 
					  (tblKartrisLanguageElements_1.LE_FieldID = 4) AND (tblKartrisLanguageElements_2.LE_TypeID = 17) AND (tblKartrisLanguageElements_2.LE_FieldID = 5) AND 
					  (tblKartrisLanguageElements_3.LE_TypeID = 17) AND (tblKartrisLanguageElements_3.LE_FieldID = 6) AND (tblKartrisLanguageElements_4.LE_TypeID = 17) AND 
					  (tblKartrisLanguageElements_4.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_Value IS NOT NULL) OR
					  (dbo.tblKartrisLanguageElements.LE_TypeID = 17) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 3) AND (tblKartrisLanguageElements_1.LE_TypeID = 17) AND 
					  (tblKartrisLanguageElements_1.LE_FieldID = 4) AND (tblKartrisLanguageElements_2.LE_TypeID = 17) AND (tblKartrisLanguageElements_2.LE_FieldID = 5) AND 
					  (tblKartrisLanguageElements_3.LE_TypeID = 17) AND (tblKartrisLanguageElements_3.LE_FieldID = 6) AND (tblKartrisLanguageElements_4.LE_TypeID = 17) AND 
					  (tblKartrisLanguageElements_4.LE_FieldID = 1) AND (tblKartrisLanguageElements_2.LE_Value IS NOT NULL) OR
					  (dbo.tblKartrisLanguageElements.LE_TypeID = 17) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 3) AND (tblKartrisLanguageElements_1.LE_TypeID = 17) AND 
					  (tblKartrisLanguageElements_1.LE_FieldID = 4) AND (tblKartrisLanguageElements_2.LE_TypeID = 17) AND (tblKartrisLanguageElements_2.LE_FieldID = 5) AND 
					  (tblKartrisLanguageElements_3.LE_TypeID = 17) AND (tblKartrisLanguageElements_3.LE_FieldID = 6) AND (tblKartrisLanguageElements_4.LE_TypeID = 17) AND 
					  (tblKartrisLanguageElements_4.LE_FieldID = 1) AND (tblKartrisLanguageElements_3.LE_Value IS NOT NULL) OR
					  (dbo.tblKartrisLanguageElements.LE_TypeID = 17) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 3) AND (tblKartrisLanguageElements_1.LE_TypeID = 17) AND 
					  (tblKartrisLanguageElements_1.LE_FieldID = 4) AND (tblKartrisLanguageElements_2.LE_TypeID = 17) AND (tblKartrisLanguageElements_2.LE_FieldID = 5) AND 
					  (tblKartrisLanguageElements_3.LE_TypeID = 17) AND (tblKartrisLanguageElements_3.LE_FieldID = 6) AND (tblKartrisLanguageElements_4.LE_TypeID = 17) AND 
					  (tblKartrisLanguageElements_4.LE_FieldID = 1) AND (tblKartrisLanguageElements_4.LE_Value IS NOT NULL)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeKnowledgeBase', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[25] 4[51] 2[10] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 6
			   Left = 38
			   Bottom = 123
			   Right = 202
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguages"
			Begin Extent = 
			   Top = 5
			   Left = 271
			   Bottom = 101
			   Right = 490
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements_1"
			Begin Extent = 
			   Top = 6
			   Left = 497
			   Bottom = 123
			   Right = 661
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements_3"
			Begin Extent = 
			   Top = 6
			   Left = 699
			   Bottom = 123
			   Right = 863
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements_2"
			Begin Extent = 
			   Top = 2
			   Left = 908
			   Bottom = 119
			   Right = 1128
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisKnowledgeBase"
			Begin Extent = 
			   Top = 202
			   Left = 305
			   Bottom = 319
			   Right = 476
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements_4"
			Begin Extent = 
			   Top = 163
	' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeKnowledgeBase'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeKnowledgeBase', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'           Left = 28
			   Bottom = 287
			   Right = 192
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 13
		 Width = 284
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 2850
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 13
		 Column = 4440
		 Alias = 2385
		 Table = 2505
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeKnowledgeBase'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeKnowledgeBase', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeKnowledgeBase'
GO
/****** Object:  View [dbo].[vKartrisTypeDestinations]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisTypeDestinations]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisTypeDestinations]
AS
SELECT     dbo.tblKartrisDestination.D_ID, dbo.tblKartrisLanguageElements.LE_LanguageID AS LANG_ID, dbo.tblKartrisLanguageElements.LE_Value AS D_Name, 
					  dbo.tblKartrisDestination.D_ShippingZoneID, dbo.tblKartrisDestination.D_Tax, dbo.tblKartrisDestination.D_ISOCode, dbo.tblKartrisDestination.D_ISOCode3Letter, 
					  dbo.tblKartrisDestination.D_ISOCodeNumeric, dbo.tblKartrisDestination.D_Region, dbo.tblKartrisDestination.D_Live, dbo.tblKartrisDestination.D_Tax2, 
					  dbo.tblKartrisDestination.D_TaxExtra
FROM         dbo.tblKartrisLanguageElements INNER JOIN
					  dbo.tblKartrisDestination ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisDestination.D_ID
WHERE     (dbo.tblKartrisLanguageElements.LE_TypeID = 11) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND 
					  (dbo.tblKartrisLanguageElements.LE_Value IS NOT NULL)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeDestinations', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[28] 4[33] 2[20] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 6
			   Left = 38
			   Bottom = 123
			   Right = 202
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisDestination"
			Begin Extent = 
			   Top = 6
			   Left = 240
			   Bottom = 178
			   Right = 423
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 9
		 Width = 284
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 1440
		 Alias = 900
		 Table = 1170
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeDestinations'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeDestinations', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeDestinations'
GO
/****** Object:  View [dbo].[vKartrisTypeCustomerGroups]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisTypeCustomerGroups]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisTypeCustomerGroups]
AS
SELECT     dbo.tblKartrisCustomerGroups.CG_ID, dbo.tblKartrisLanguageElements.LE_LanguageID AS LANG_ID, dbo.tblKartrisLanguageElements.LE_Value AS CG_Name, 
					  dbo.tblKartrisCustomerGroups.CG_Discount, dbo.tblKartrisCustomerGroups.CG_Live
FROM         dbo.tblKartrisLanguageElements INNER JOIN
					  dbo.tblKartrisCustomerGroups ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisCustomerGroups.CG_ID
WHERE     (dbo.tblKartrisLanguageElements.LE_TypeID = 12) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND 
					  (dbo.tblKartrisLanguageElements.LE_Value IS NOT NULL)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeCustomerGroups', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[40] 4[20] 2[20] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 6
			   Left = 38
			   Bottom = 123
			   Right = 202
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisCustomerGroups"
			Begin Extent = 
			   Top = 6
			   Left = 240
			   Bottom = 108
			   Right = 400
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 9
		 Width = 284
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 1440
		 Alias = 900
		 Table = 1170
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeCustomerGroups'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeCustomerGroups', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeCustomerGroups'
GO
/****** Object:  View [dbo].[vKartrisTypeCurrencies]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisTypeCurrencies]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisTypeCurrencies]
AS
SELECT     dbo.tblKartrisCurrencies.CUR_ID, dbo.tblKartrisLanguageElements.LE_LanguageID AS LANG_ID, dbo.tblKartrisLanguageElements.LE_Value AS CUR_Name, 
					  dbo.tblKartrisCurrencies.CUR_Symbol, dbo.tblKartrisCurrencies.CUR_ISOCode, dbo.tblKartrisCurrencies.CUR_ISOCodeNumeric, 
					  dbo.tblKartrisCurrencies.CUR_ExchangeRate, dbo.tblKartrisCurrencies.CUR_HasDecimals, dbo.tblKartrisCurrencies.CUR_Live, dbo.tblKartrisCurrencies.CUR_Format, 
					  dbo.tblKartrisCurrencies.CUR_IsoFormat, dbo.tblKartrisCurrencies.CUR_DecimalPoint
FROM         dbo.tblKartrisLanguageElements INNER JOIN
					  dbo.tblKartrisCurrencies ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisCurrencies.CUR_ID
WHERE     (dbo.tblKartrisLanguageElements.LE_TypeID = 13) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND 
					  (dbo.tblKartrisLanguageElements.LE_Value IS NOT NULL)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeCurrencies', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[40] 4[20] 2[20] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 6
			   Left = 38
			   Bottom = 123
			   Right = 202
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisCurrencies"
			Begin Extent = 
			   Top = 6
			   Left = 450
			   Bottom = 218
			   Right = 635
			End
			DisplayFlags = 280
			TopColumn = 6
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 13
		 Width = 284
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 1440
		 Alias = 900
		 Table = 1170
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeCurrencies'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeCurrencies', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeCurrencies'
GO
/****** Object:  View [dbo].[vKartrisTypeCategories]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisTypeCategories]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisTypeCategories]
AS
SELECT     TOP (100) PERCENT dbo.tblKartrisCategories.CAT_ID, dbo.tblKartrisLanguages.LANG_ID, dbo.tblKartrisLanguageElements.LE_Value AS CAT_Name, 
					  tblKartrisLanguageElements_1.LE_Value AS CAT_Desc, tblKartrisLanguageElements_2.LE_Value AS CAT_PageTitle, dbo.tblKartrisCategories.CAT_Live, 
					  dbo.tblKartrisCategories.CAT_ProductDisplayType, dbo.tblKartrisCategories.CAT_SubCatDisplayType, dbo.tblKartrisCategories.CAT_OrderProductsBy, 
					  dbo.tblKartrisCategories.CAT_ProductsSortDirection, dbo.tblKartrisCategories.CAT_CustomerGroupID
FROM         dbo.tblKartrisCategories INNER JOIN
					  dbo.tblKartrisLanguageElements ON dbo.tblKartrisCategories.CAT_ID = dbo.tblKartrisLanguageElements.LE_ParentID INNER JOIN
					  dbo.tblKartrisLanguages ON dbo.tblKartrisLanguageElements.LE_LanguageID = dbo.tblKartrisLanguages.LANG_ID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_1 ON dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_1.LE_LanguageID AND 
					  dbo.tblKartrisCategories.CAT_ID = tblKartrisLanguageElements_1.LE_ParentID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_2 ON dbo.tblKartrisLanguages.LANG_ID = tblKartrisLanguageElements_2.LE_LanguageID AND 
					  dbo.tblKartrisCategories.CAT_ID = tblKartrisLanguageElements_2.LE_ParentID
WHERE     (dbo.tblKartrisLanguageElements.LE_TypeID = 3) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_TypeID = 3) AND 
					  (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (dbo.tblKartrisLanguageElements.LE_Value IS NOT NULL) AND (tblKartrisLanguageElements_2.LE_TypeID = 3) 
					  AND (tblKartrisLanguageElements_2.LE_FieldID = 3) OR
					  (dbo.tblKartrisLanguageElements.LE_TypeID = 3) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_TypeID = 3) AND 
					  (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (tblKartrisLanguageElements_1.LE_Value IS NOT NULL) AND (tblKartrisLanguageElements_2.LE_TypeID = 3) 
					  AND (tblKartrisLanguageElements_2.LE_FieldID = 3) OR
					  (dbo.tblKartrisLanguageElements.LE_TypeID = 3) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_TypeID = 3) AND 
					  (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (tblKartrisLanguageElements_2.LE_Value IS NOT NULL) AND (tblKartrisLanguageElements_2.LE_TypeID = 3) 
					  AND (tblKartrisLanguageElements_2.LE_FieldID = 3)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeCategories', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[40] 4[20] 2[20] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1[36] 4[44] 3) )"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 1
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisCategories"
			Begin Extent = 
			   Top = 102
			   Left = 304
			   Bottom = 250
			   Right = 514
			End
			DisplayFlags = 280
			TopColumn = 2
		 End
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 17
			   Left = 21
			   Bottom = 153
			   Right = 236
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguages"
			Begin Extent = 
			   Top = 0
			   Left = 302
			   Bottom = 101
			   Right = 521
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements_1"
			Begin Extent = 
			   Top = 0
			   Left = 587
			   Bottom = 136
			   Right = 751
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguageElements_2"
			Begin Extent = 
			   Top = 158
			   Left = 686
			   Bottom = 295
			   Right = 900
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
	  PaneHidden = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 14
		 Width = 284
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 3345
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeCategories'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeCategories', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'         Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 3750
		 Alias = 1620
		 Table = 3120
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeCategories'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeCategories', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeCategories'
GO
/****** Object:  View [dbo].[vKartrisTypeVersions]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisTypeVersions]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisTypeVersions]
AS
SELECT     TOP (100) PERCENT dbo.tblKartrisVersions.V_ID, dbo.tblKartrisLanguages.LANG_ID, dbo.tblKartrisLanguageElements.LE_Value AS V_Name, 
					  tblKartrisLanguageElements_1.LE_Value AS V_Desc, dbo.tblKartrisVersions.V_CodeNumber, dbo.tblKartrisVersions.V_ProductID, dbo.tblKartrisVersions.V_Price, 
					  dbo.tblKartrisVersions.V_Tax, dbo.tblKartrisVersions.V_Weight, dbo.tblKartrisVersions.V_DeliveryTime, dbo.tblKartrisVersions.V_Quantity, 
					  dbo.tblKartrisVersions.V_QuantityWarnLevel, dbo.tblKartrisVersions.V_Live, dbo.tblKartrisVersions.V_DownLoadInfo, dbo.tblKartrisVersions.V_DownloadType, 
					  dbo.tblKartrisVersions.V_OrderByValue, dbo.tblKartrisVersions.V_RRP, dbo.tblKartrisVersions.V_Type, dbo.tblKartrisVersions.V_CustomerGroupID, 
					  dbo.tblKartrisVersions.V_CustomizationType, dbo.tblKartrisVersions.V_CustomizationDesc, dbo.tblKartrisVersions.V_CustomizationCost, 
					  dbo.tblKartrisVersions.V_Tax2, dbo.tblKartrisVersions.V_TaxExtra
FROM         dbo.tblKartrisLanguageElements INNER JOIN
					  dbo.tblKartrisVersions ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisVersions.V_ID INNER JOIN
					  dbo.tblKartrisLanguageElements AS tblKartrisLanguageElements_1 ON dbo.tblKartrisVersions.V_ID = tblKartrisLanguageElements_1.LE_ParentID INNER JOIN
					  dbo.tblKartrisLanguages ON dbo.tblKartrisLanguageElements.LE_LanguageID = dbo.tblKartrisLanguages.LANG_ID AND 
					  tblKartrisLanguageElements_1.LE_LanguageID = dbo.tblKartrisLanguages.LANG_ID
WHERE     (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (dbo.tblKartrisLanguageElements.LE_Value IS NOT NULL) 
					  AND (dbo.tblKartrisLanguageElements.LE_TypeID = 1) AND (tblKartrisLanguageElements_1.LE_TypeID = 1) OR
					  (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisLanguageElements_1.LE_FieldID = 2) AND (dbo.tblKartrisLanguageElements.LE_TypeID = 1) AND 
					  (tblKartrisLanguageElements_1.LE_TypeID = 1) AND (tblKartrisLanguageElements_1.LE_Value IS NOT NULL)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeVersions', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[22] 4[43] 2[6] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1[50] 4[25] 3) )"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1[50] 2[25] 3) )"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4[30] 2[27] 3) )"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1[31] 3) )"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4[50] 3) )"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3) )"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 6
			   Left = 45
			   Bottom = 147
			   Right = 209
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisVersions"
			Begin Extent = 
			   Top = 112
			   Left = 352
			   Bottom = 229
			   Right = 546
			End
			DisplayFlags = 280
			TopColumn = 15
		 End
		 Begin Table = "tblKartrisLanguageElements_1"
			Begin Extent = 
			   Top = 6
			   Left = 662
			   Bottom = 147
			   Right = 826
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisLanguages"
			Begin Extent = 
			   Top = 0
			   Left = 336
			   Bottom = 117
			   Right = 555
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 21
		 Width = 284
		 Width = 1560
		 Width = 1620
		 Width = 2775
		 Width = 2460
		 Width = 2055
		 Width = 1500
		 Width = 2370
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeVersions'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeVersions', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' ColumnWidths = 11
		 Column = 2400
		 Alias = 1605
		 Table = 2460
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 900
		 SortOrder = 975
		 GroupBy = 1350
		 Filter = 1200
		 Or = 1485
		 Or = 1170
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeVersions'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeVersions', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeVersions'
GO
/****** Object:  View [dbo].[vKartrisTypeAttributeValues]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisTypeAttributeValues]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisTypeAttributeValues]
AS
SELECT     dbo.tblKartrisAttributeValues.ATTRIBV_ID, dbo.tblKartrisLanguageElements.LE_LanguageID AS LANG_ID, 
					  dbo.tblKartrisLanguageElements.LE_Value AS ATTRIBV_Value, dbo.tblKartrisAttributeValues.ATTRIBV_ProductID, 
					  dbo.tblKartrisAttributeValues.ATTRIBV_AttributeID
FROM         dbo.tblKartrisLanguageElements INNER JOIN
					  dbo.tblKartrisAttributeValues ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisAttributeValues.ATTRIBV_ID
WHERE     (dbo.tblKartrisLanguageElements.LE_TypeID = 14) AND (dbo.tblKartrisLanguageElements.LE_FieldID = 1) AND 
					  (dbo.tblKartrisLanguageElements.LE_Value IS NOT NULL)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeAttributeValues', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[40] 4[20] 2[20] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisLanguageElements"
			Begin Extent = 
			   Top = 6
			   Left = 38
			   Bottom = 138
			   Right = 224
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "tblKartrisAttributeValues"
			Begin Extent = 
			   Top = 6
			   Left = 262
			   Bottom = 120
			   Right = 453
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 9
		 Width = 284
		 Width = 1500
		 Width = 1500
		 Width = 2430
		 Width = 1890
		 Width = 1875
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 1440
		 Alias = 1530
		 Table = 1170
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeAttributeValues'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisTypeAttributeValues', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisTypeAttributeValues'
GO
/****** Object:  View [dbo].[vKartrisCategoryHierarchy]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisCategoryHierarchy]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisCategoryHierarchy]
AS
SELECT  dbo.tblKartrisCategoryHierarchy.CH_ChildID, dbo.vKartrisTypeCategories.LANG_ID, 
		dbo.vKartrisTypeCategories.CAT_ID, dbo.vKartrisTypeCategories.CAT_Name, 
		dbo.vKartrisTypeCategories.CAT_Desc
FROM    dbo.tblKartrisCategoryHierarchy RIGHT OUTER JOIN dbo.vKartrisTypeCategories 
		ON dbo.tblKartrisCategoryHierarchy.CH_ParentID = dbo.vKartrisTypeCategories.CAT_ID
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisCategoryHierarchy', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[40] 4[20] 2[20] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisCategoryHierarchy"
			Begin Extent = 
			   Top = 6
			   Left = 38
			   Bottom = 108
			   Right = 198
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "vKartrisTypeCategories"
			Begin Extent = 
			   Top = 6
			   Left = 236
			   Bottom = 123
			   Right = 455
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 1440
		 Alias = 900
		 Table = 1170
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisCategoryHierarchy'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisCategoryHierarchy', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisCategoryHierarchy'
GO
/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetOptions]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisVersions_GetOptions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	replaces [spKartris_VER_GetVersionOptions]
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisVersions_GetOptions](@P_ID as int, @LANG_ID as tinyint)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT     vKartrisTypeOptionGroups.OPTG_ID, vKartrisTypeOptionGroups.OPTG_Name, vKartrisTypeOptionGroups.OPTG_Desc, 
					  vKartrisTypeOptionGroups.OPTG_OptionDisplayType, tblKartrisProductOptionGroupLink.P_OPTG_MustSelected
FROM         vKartrisTypeOptionGroups INNER JOIN
					  tblKartrisProductOptionGroupLink ON vKartrisTypeOptionGroups.OPTG_ID = tblKartrisProductOptionGroupLink.P_OPTG_OptionGroupID
WHERE     (vKartrisTypeOptionGroups.LANG_ID = @LANG_ID) AND (tblKartrisProductOptionGroupLink.P_OPTG_ProductID = @P_ID)
ORDER BY vKartrisTypeOptionGroups.OPTG_DefOrderByValue
END


' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisVersions_GetProductID]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisVersions_GetProductID]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisVersions_GetProductID] 
(
	-- Add the parameters for the function here
	@V_ID as bigint
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result int;

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = V_ProductID FROM tblKartrisVersions WHERE V_ID = @V_ID;

	-- Return the result of the function
	RETURN @Result

END
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisVersions_GetCodeNumber]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisVersions_GetCodeNumber]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisVersions_GetCodeNumber] 
(
	-- Add the parameters for the function here
	@V_ID as bigint
)
RETURNS nvarchar(25)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(25);

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = V_CodeNumber FROM tblKartrisVersions WHERE V_ID = @V_ID;

	-- Return the result of the function
	RETURN @Result

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_GetCategoryID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_GetCategoryID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 15/June/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_GetCategoryID] (
	@ProductID int
) AS
BEGIN
	SET NOCOUNT ON;

	SELECT PCAT_CategoryID,PCAT_OrderNo FROM tblKartrisProductCategoryLink
	WHERE PCAT_ProductID = @ProductID

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_DeleteSavedBasket]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_DeleteSavedBasket]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 12/May/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_DeleteSavedBasket] (
	@BasketID bigint	
) AS
BEGIN
	
	SET NOCOUNT ON;

Disable Trigger trigKartrisSavedBaskets_DML ON tblKartrisSavedBaskets;	
	DELETE tblKartrisSavedBaskets 
	WHERE SBSKT_ID=@BasketID;
Enable Trigger trigKartrisSavedBaskets_DML ON tblKartrisSavedBaskets;	

--Disable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
	DELETE tblKartrisBasketOptionValues
	WHERE BSKTOPT_BasketValueID in (SELECT BV_ID FROM tblKartrisBasketValues WHERE BV_ParentID=@BasketID and BV_ParentType=''s'');
--Enable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	

--Disable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	
	DELETE tblKartrisBasketValues
	WHERE BV_ParentID=@BasketID and BV_ParentType=''s'';
--Enable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	

END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCategoryHierarchy_GetByLanguageID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCategoryHierarchy_GetByLanguageID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- ======================================================
-- Author:		Medz
-- Create date: 02/14/2008 12:22:45
-- Description:	generate the category menu hierarchy
-- ======================================================
CREATE PROCEDURE [dbo].[spKartrisCategoryHierarchy_GetByLanguageID]
	(@LANG_ID tinyint,
	@SortByName bit)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	If @SortByName = 1
		BEGIN
			SELECT     tblKartrisCategoryHierarchy.CH_ChildID AS CAT_ID, tblKartrisCategoryHierarchy.CH_ParentID AS ParentID, vKartrisTypeCategories.CAT_Name AS Title, 
							  vKartrisTypeCategories.CAT_CustomerGroupID
			FROM         vKartrisTypeCategories INNER JOIN
								  tblKartrisCategoryHierarchy ON vKartrisTypeCategories.CAT_ID = tblKartrisCategoryHierarchy.CH_ChildID
			WHERE     (vKartrisTypeCategories.LANG_ID = @LANG_ID) AND (vKartrisTypeCategories.CAT_Live = 1)
			ORDER BY vKartrisTypeCategories.CAT_Name
		END
	ELSE
		BEGIN
		 SELECT     tblKartrisCategoryHierarchy.CH_ChildID AS CAT_ID, tblKartrisCategoryHierarchy.CH_ParentID AS ParentID, vKartrisTypeCategories.CAT_Name AS Title, 
							  vKartrisTypeCategories.CAT_CustomerGroupID
			FROM         vKartrisTypeCategories INNER JOIN
								  tblKartrisCategoryHierarchy ON vKartrisTypeCategories.CAT_ID = tblKartrisCategoryHierarchy.CH_ChildID
			WHERE     (vKartrisTypeCategories.LANG_ID = @LANG_ID) AND (vKartrisTypeCategories.CAT_Live = 1)
			ORDER BY tblKartrisCategoryHierarchy.CH_OrderNo;
		END
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCategoryHierarchy_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCategoryHierarchy_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisCategoryHierarchy_Get]
AS
	SET NOCOUNT ON;
SELECT        tblKartrisCategoryHierarchy.*
FROM            tblKartrisCategoryHierarchy

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCategories_GetTotalByParentID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCategories_GetTotalByParentID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Get the total no. of Products in Category "used for ItemPager"
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisCategories_GetTotalByParentID]
			(
			@LANG_ID as tinyint,
			@ParentID as int,
			@CGroupID as smallint,
			@TotalCategories as int OUTPUT
			)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT  @TotalCategories = COUNT(vKartrisTypeCategories.CAT_ID)
		FROM    tblKartrisCategoryHierarchy INNER JOIN
				vKartrisTypeCategories ON tblKartrisCategoryHierarchy.CH_ChildID = vKartrisTypeCategories.CAT_ID INNER JOIN
				tblKartrisCategories ON tblKartrisCategoryHierarchy.CH_ParentID = tblKartrisCategories.CAT_ID
		WHERE   (tblKartrisCategoryHierarchy.CH_ParentID = @ParentID) 
					AND (vKartrisTypeCategories.LANG_ID = @LANG_ID) AND (vKartrisTypeCategories.CAT_Live = 1)
					AND (vKartrisTypeCategories.CAT_CustomerGroupID IS NULL OR vKartrisTypeCategories.CAT_CustomerGroupID = @CGroupID)
	
	
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCategories_GetPageByParentID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCategories_GetPageByParentID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisCategories_GetPageByParentID]
	(
	@LANG_ID as tinyint, 
	@ParentID as int,
	@PageIndex as tinyint, -- 0 Based index
	@RowsPerPage as smallint,
	@CGroupID as smallint
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;

	DECLARE @OrderBy as nvarchar(50), @OrderDirection as char(1)

	SELECT @OrderBy = CAT_OrderCategoriesBy, @OrderDirection = CAT_CategoriesSortDirection
	FROM dbo.tblKartrisCategories
	WHERE CAT_ID = @ParentID;

	IF @OrderBy is NULL OR @OrderBy = ''d''
	BEGIN 
		SELECT @OrderBy = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = ''frontend.categories.display.sortdefault'';
	END;
	IF @OrderDirection is NULL OR @OrderDirection = '''' BEGIN 
		SELECT @OrderDirection = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = ''frontend.categories.display.sortdirection'';
	END;

	IF @ParentID = 0 
	BEGIN
		 SET @OrderBy = ''CH_OrderNo'';
		 SET @OrderDirection = ''A'';
	END;
	
	WITH CategoryList AS
	(
		SELECT	CASE 
				WHEN (@OrderBy = ''CAT_ID'' AND @OrderDirection = ''A'') THEN	ROW_NUMBER() OVER (ORDER BY tblKartrisCategories.CAT_ID ASC) 
				WHEN (@OrderBy = ''CAT_ID'' AND @OrderDirection = ''D'') THEN	ROW_NUMBER() OVER (ORDER BY tblKartrisCategories.CAT_ID DESC) 
				WHEN (@OrderBy = ''CAT_Name'' AND @OrderDirection = ''A'') THEN ROW_NUMBER() OVER (ORDER BY CAT_Name ASC) 
				WHEN (@OrderBy = ''CAT_Name'' AND @OrderDirection = ''D'') THEN ROW_NUMBER() OVER (ORDER BY CAT_Name DESC) 
				WHEN (@OrderBy = ''CH_OrderNo'' AND @OrderDirection = ''A'') THEN ROW_NUMBER() OVER (ORDER BY CH_OrderNo ASC) 
				WHEN (@OrderBy = ''CH_OrderNo'' AND @OrderDirection = ''D'') THEN ROW_NUMBER() OVER (ORDER BY CH_OrderNo DESC) 
				END AS Row,
				vKartrisTypeCategories.CAT_ID, vKartrisTypeCategories.CAT_Name, vKartrisTypeCategories.CAT_Desc, 
				tblKartrisCategories.CAT_ProductDisplayType AS Parent_ProductDisplay, 
				tblKartrisCategories.CAT_SubCatDisplayType AS Parent_SubCategoryDisplay
		FROM    tblKartrisCategoryHierarchy INNER JOIN
				vKartrisTypeCategories ON tblKartrisCategoryHierarchy.CH_ChildID = vKartrisTypeCategories.CAT_ID INNER JOIN
				tblKartrisCategories ON tblKartrisCategoryHierarchy.CH_ParentID = tblKartrisCategories.CAT_ID
		WHERE   (tblKartrisCategoryHierarchy.CH_ParentID = @ParentID) AND (vKartrisTypeCategories.LANG_ID = @LANG_ID) 
					AND (vKartrisTypeCategories.CAT_Live = 1) 
					AND (vKartrisTypeCategories.CAT_CustomerGroupID IS NULL OR vKartrisTypeCategories.CAT_CustomerGroupID = @CGroupID)
		
	)

	SELECT *
	FROM CategoryList
	WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber
	ORDER BY Row ASC;

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCategories_GetNameByCategoryID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCategories_GetNameByCategoryID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- ========================================================
-- Author:		Medz
-- Create date: 04/13/2008 11:53:30
-- Description:	Get the category name for the SEO Friendly Links.
-- ========================================================
CREATE PROCEDURE [dbo].[spKartrisCategories_GetNameByCategoryID]
(
	@CAT_ID int,
	@LANG_ID tinyint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT CAT_Name
	FROM   vKartrisTypeCategories
	WHERE  (CAT_ID = @CAT_ID) AND (LANG_ID = @LANG_ID) AND (CAT_Live = 1)
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCategories_GetByProductID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCategories_GetByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisCategories_GetByProductID]
(
	@P_ID int,
	@LANG_ID tinyint	
)
AS
	SET NOCOUNT ON;
SELECT     vKartrisTypeCategories.CAT_ID, vKartrisTypeCategories.CAT_Name
FROM         vKartrisTypeCategories INNER JOIN
					  tblKartrisProductCategoryLink ON vKartrisTypeCategories.CAT_ID = tblKartrisProductCategoryLink.PCAT_CategoryID
WHERE     (vKartrisTypeCategories.LANG_ID = @LANG_ID) AND (tblKartrisProductCategoryLink.PCAT_ProductID = @P_ID)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCategories_GetByParentID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCategories_GetByParentID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisCategories_GetByParentID](@LanguageID as tinyint, @ParentCategoryID as int)
AS
BEGIN
	SET NOCOUNT ON;

SELECT     vKartrisTypeCategories.CAT_ID, vKartrisTypeCategories.CAT_Name, vKartrisTypeCategories.CAT_Desc
FROM         tblKartrisCategoryHierarchy INNER JOIN
					  vKartrisTypeCategories ON tblKartrisCategoryHierarchy.CH_ChildID = vKartrisTypeCategories.CAT_ID
WHERE     (tblKartrisCategoryHierarchy.CH_ParentID = @ParentCategoryID) AND (vKartrisTypeCategories.LANG_ID = @LanguageID) AND (vKartrisTypeCategories.CAT_Live = 1)
ORDER BY tblKartrisCategoryHierarchy.CH_OrderNo
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCustomer_GetDownloadableProducts]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCustomer_GetDownloadableProducts]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: 05/May/09
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisCustomer_GetDownloadableProducts] ( 
	@U_ID int,
	@MustBeShipped bit,
	@AvailableUpTo smalldatetime
) AS
BEGIN
	SET NOCOUNT ON;

	IF @MustBeShipped = 0
		BEGIN
			SET @MustBeShipped = NULL;
		END

	SELECT O_CustomerID, O_Date, IR_VersionCode, IR_VersionName, V_ID, V_DownLoadInfo, V_DownloadType 
	FROM 
		(tblKartrisVersions INNER JOIN tblKartrisInvoiceRows ON tblKartrisVersions.V_CodeNumber = tblKartrisInvoiceRows.IR_VersionCode) 
			INNER JOIN tblKartrisOrders ON tblKartrisInvoiceRows.IR_OrderNumberID = tblKartrisOrders.O_ID 
	WHERE 
			O_CustomerID = @U_ID AND O_Sent = 1 AND
			O_Shipped = COALESCE(@MustBeShipped,O_Shipped) AND
			O_Date >= @AvailableUpTo AND
			 V_DownLoadType <> ''n'' AND V_DownloadType <> ''f'' AND V_DownloadInfo <> ''''
END





' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCategories_GetByID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCategories_GetByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[spKartrisCategories_GetByID]
(
	@CAT_ID int,
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT        vKartrisTypeCategories.*
FROM            vKartrisTypeCategories
WHERE        (CAT_ID = @CAT_ID) AND (LANG_ID = @LANG_ID)


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasketOptionValues_Update]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasketOptionValues_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisBasketOptionValues_Update]
(
	@BSKTOPT_BasketValueID bigint,
	@BSKTOPT_OptionID smallint,
	@Original_BSKTOPT_ID bigint,
	@BSKTOPT_ID bigint
)
AS
	SET NOCOUNT OFF;
--Disable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
	UPDATE [tblKartrisBasketOptionValues] SET [BSKTOPT_BasketValueID] = @BSKTOPT_BasketValueID, [BSKTOPT_OptionID] = @BSKTOPT_OptionID WHERE (([BSKTOPT_ID] = @Original_BSKTOPT_ID));
--Enable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	

	
SELECT BSKTOPT_ID, BSKTOPT_BasketValueID, BSKTOPT_OptionID FROM tblKartrisBasketOptionValues WHERE (BSKTOPT_ID = @BSKTOPT_ID)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasketOptionValues_GetMiniBasketOptions]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasketOptionValues_GetMiniBasketOptions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisBasketOptionValues_GetMiniBasketOptions]
(
	@BV_ID bigint
)
AS
	SET NOCOUNT OFF;
SELECT     tblKartrisBasketValues.BV_ID, tblKartrisBasketValues.BV_VersionID, 
					  tblKartrisBasketOptionValues.BSKTOPT_ID, tblKartrisBasketOptionValues.BSKTOPT_OptionID
FROM         tblKartrisBasketValues INNER JOIN
					  tblKartrisBasketOptionValues ON tblKartrisBasketValues.BV_ID = tblKartrisBasketOptionValues.BSKTOPT_BasketValueID
WHERE     (tblKartrisBasketValues.BV_ID = @BV_ID)
ORDER BY BSKTOPT_OptionID

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasketOptionValues_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasketOptionValues_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisBasketOptionValues_Get]
AS
	SET NOCOUNT ON;
SELECT        tblKartrisBasketOptionValues.*
FROM            tblKartrisBasketOptionValues

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasketOptionValues_Delete]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasketOptionValues_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisBasketOptionValues_Delete]
(
	@Original_BSKTOPT_ID bigint
)
AS
	SET NOCOUNT OFF;
--Disable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
	DELETE FROM [tblKartrisBasketOptionValues] WHERE (([BSKTOPT_ID] = @Original_BSKTOPT_ID));
--Enable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasketOptionValues_Add]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasketOptionValues_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisBasketOptionValues_Add]
(
	@BSKTOPT_BasketValueID bigint,
	@BSKTOPT_OptionID smallint
)
AS
	SET NOCOUNT OFF;
--Disable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
	INSERT INTO [tblKartrisBasketOptionValues] ([BSKTOPT_BasketValueID], [BSKTOPT_OptionID]) VALUES (@BSKTOPT_BasketValueID, @BSKTOPT_OptionID);
--Enable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
	SELECT BSKTOPT_ID, BSKTOPT_BasketValueID, BSKTOPT_OptionID FROM tblKartrisBasketOptionValues WHERE (BSKTOPT_ID = SCOPE_IDENTITY());




' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_SaveBasket]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_SaveBasket]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 12/May/2008
-- Update date: 11/June/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_SaveBasket] ( 
	@CustomerID INT,
	@BasketName NVARCHAR(200),
	@BasketID BIGINT,
	@NowOffset datetime
) AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @SavedBasketID BIGINT;
	DECLARE @newBV_ID BIGINT;

Disable Trigger trigKartrisSavedBaskets_DML ON tblKartrisSavedBaskets;	
--Disable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
--Disable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	

	INSERT INTO tblKartrisSavedBaskets (SBSKT_UserID,SBSKT_Name,SBSKT_DateTimeAdded)
	VALUES (@CustomerID,@BasketName,@NowOffset);
	
	SET @SavedBasketID=SCOPE_IDENTITY() ;

	DECLARE @BV_ID INT
	DECLARE @BV_VersionID INT
	DECLARE @BV_Quantity FLOAT
	DECLARE @BV_CustomText nvarchar(2000)

	DECLARE Basket_cursor CURSOR FOR 
	SELECT BV_ID,BV_VersionID,BV_Quantity,BV_CustomText FROM tblKartrisBasketValues WHERE BV_ParentID=@BasketID AND BV_ParentType=''b'';

	OPEN Basket_cursor
	FETCH NEXT FROM Basket_cursor INTO @BV_ID,@BV_VersionID,@BV_Quantity,@BV_CustomText
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO tblKartrisBasketValues(BV_ParentType,BV_ParentID,BV_VersionID,BV_Quantity,BV_CustomText,BV_DateTimeAdded)
		VALUES (''s'',@SavedBasketID,@BV_VersionID,@BV_Quantity,@BV_CustomText,@NowOffset)

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

Enable Trigger trigKartrisSavedBaskets_DML ON tblKartrisSavedBaskets;
--Enable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
--Enable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	

END




' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_LoadWishlists]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_LoadWishlists]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 20/May/2008
-- Modified date: 25/June/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_LoadWishlists] ( 
	@WishlistsID bigint,
	@BasketID bigint,
	@NowOffset datetime
) AS
BEGIN
	SET NOCOUNT ON;

	/**
	delete tblKartrisBasketValues
	where BV_ParentType=''b'' and BV_ParentID=@BasketID

	insert into tblKartrisBasketValues (BV_ParentType,BV_ParentID,BV_VersionID,BV_Quantity,BV_DateTimeAdded)
	
	select ''b'' as BV_ParentType,@BasketID as BV_ParentID,BV_VersionID,BV_Quantity,getdate() as BV_DateTimeAdded from tblKartrisBasketValues
	where BV_ParentType=''w'' and BV_ParentID=@WishlistsID
	**/

	DECLARE @BV_ID BIGINT
	DECLARE @BV_VersionID BIGINT
	DECLARE @BV_Quantity FLOAT
	DECLARE @BV_CustomText NVARCHAR(2000)
	DECLARE @newBV_ID BIGINT;

--Disable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
--Disable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	

	DELETE FROM tblKartrisBasketOptionValues
	WHERE BSKTOPT_BasketValueID IN (SELECT BV_ID FROM tblKartrisBasketValues WHERE BV_ParentID=@BasketID and BV_ParentType=''b'')

	DELETE tblKartrisBasketValues
	WHERE BV_ParentType=''b'' AND BV_ParentID=@BasketID

	DECLARE Basket_cursor CURSOR FOR 
	SELECT BV_ID,BV_VersionID,BV_Quantity,BV_CustomText FROM tblKartrisBasketValues WHERE BV_ParentID=@WishlistsID and BV_ParentType=''w''

	OPEN Basket_cursor
	FETCH NEXT FROM Basket_cursor INTO @BV_ID,@BV_VersionID,@BV_Quantity,@BV_CustomText
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO tblKartrisBasketValues (BV_ParentType,BV_ParentID,BV_VersionID,BV_Quantity,BV_CustomText,BV_DateTimeAdded)
		SELECT ''b'' as BV_ParentType,@BasketID as BV_ParentID,@BV_VersionID,@BV_Quantity,@BV_CustomText,@NowOffset FROM tblKartrisBasketValues 
		WHERE BV_ID=@BV_ID

		SET @newBV_ID=SCOPE_IDENTITY() 

		IF EXISTS (SELECT * FROM tblKartrisBasketOptionValues WHERE BSKTOPT_BasketValueID=@BV_ID) 
		BEGIN
			--PRINT cast(@BV_ID as varchar(20)) + '' exist''
			INSERT INTO tblKartrisBasketOptionValues (BSKTOPT_BasketValueID,BSKTOPT_OptionID)
			SELECT @newBV_ID,BSKTOPT_OptionID FROM tblKartrisBasketOptionValues WHERE BSKTOPT_BasketValueID=@BV_ID
		END

		FETCH NEXT FROM Basket_cursor INTO @BV_ID,@BV_VersionID,@BV_Quantity,@BV_CustomText
	END

	CLOSE Basket_cursor
	DEALLOCATE Basket_cursor;

--Enable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
--Enable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	

END


	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_LoadSavedBasket]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_LoadSavedBasket]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 13/May/2008
-- Update date: 11/June/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_LoadSavedBasket] ( 
	@BasketSavedID BIGINT,
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

--Disable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
--Disable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	

	DELETE FROM tblKartrisBasketOptionValues
	WHERE BSKTOPT_BasketValueID IN (SELECT BV_ID FROM tblKartrisBasketValues WHERE BV_ParentID=@BasketID and BV_ParentType=''b'')

	DELETE tblKartrisBasketValues
	WHERE BV_ParentType=''b'' AND BV_ParentID=@BasketID

	DECLARE Basket_cursor CURSOR FOR 
	SELECT BV_ID,BV_VersionID,BV_Quantity,BV_CustomText FROM tblKartrisBasketValues WHERE BV_ParentID=@BasketSavedID and BV_ParentType=''s''

	OPEN Basket_cursor
	FETCH NEXT FROM Basket_cursor INTO @BV_ID,@BV_VersionID,@BV_Quantity,@BV_CustomText
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		INSERT INTO tblKartrisBasketValues (BV_ParentType,BV_ParentID,BV_VersionID,BV_Quantity,BV_CustomText,BV_DateTimeAdded)
			SELECT ''b'' as BV_ParentType,@BasketID as BV_ParentID,@BV_VersionID,@BV_Quantity,@BV_CustomText,@NowOffset FROM tblKartrisBasketValues 
			WHERE BV_ID=@BV_ID

		SET @newBV_ID=SCOPE_IDENTITY() 

		IF EXISTS (SELECT * FROM tblKartrisBasketOptionValues WHERE BSKTOPT_BasketValueID=@BV_ID) 
		BEGIN
			--PRINT cast(@BV_ID as varchar(20)) + '' exist''
			INSERT INTO tblKartrisBasketOptionValues (BSKTOPT_BasketValueID,BSKTOPT_OptionID)
				SELECT @newBV_ID,BSKTOPT_OptionID FROM tblKartrisBasketOptionValues WHERE BSKTOPT_BasketValueID=@BV_ID
		END

		FETCH NEXT FROM Basket_cursor INTO @BV_ID,@BV_VersionID,@BV_Quantity,@BV_CustomText
	END

	CLOSE Basket_cursor
	DEALLOCATE Basket_cursor;

--Enable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
--Enable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	


END











' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_GetWishList]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_GetWishList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [dbo].[spKartrisBasket_GetWishList](
	@intType smallint,
	@CustomerID int,
	@PageIndexStart int=1,
	@PageIndexEnd int=1000,
	@WishListID int=0,
	@Email nvarchar(100)='''',
	@Password nvarchar(100)='''',
	@Language tinyint=1
) 
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @cnt bigint

	If @intType=0
	Begin -- get wishlist total
		select @cnt=count(WL_ID) from tblKartrisWishLists
			where WL_UserID=@CustomerID
		select isnull(@cnt,0)''TotalRec''
	End	
	Else If @intType=1
	Begin -- get wishlist data
		select * from (
			select ROW_NUMBER() OVER (ORDER BY WL_ID desc) as RowNum,WL_ID,WL_Name,WL_DateTimeAdded from tblKartrisWishLists
			where WL_UserID=@CustomerID ) as A	
		where RowNum>=@PageIndexStart AND RowNum<=@PageIndexEnd 
	End
	Else If @intType=2
	Begin -- get wishlist by wishlist id and customer id
		select * from tblKartrisWishLists WL
		left join tblKartrisUsers U on WL.WL_UserID=U.U_ID
		left join tblKartrisAddresses ADR on U.U_ID=ADR.ADR_UserID
		where WL_ID=@WishListID and U.U_ID=@CustomerID
	End
	Else If @intType=3
	Begin
		select WL.*,ADR_Name,USR.* from tblKartrisUsers as USR
		inner join tblKartrisWishlists as WL on WL.WL_UserID=USR.U_ID
		left join tblKartrisAddresses ADR on ADR.ADR_UserID=USR.U_ID
		where U_EmailAddress=@Email and WL_PublicPassword=@Password
	End
	Else If @intType=4
	Begin
		select WL.WL_UserID,WL.WL_ID,V_ProductID,BV_ID,BV.BV_VersionID,isnull(dbo.fnKartris_GetRemainingWishlist(BV_ParentID,BV_VersionID,BV_CustomText),BV_Quantity) as WishlistQty,BV.BV_Quantity,BV.BV_CustomText,LE.LE_Value ''VersionCode'',B.LE_Value ''VersionName'' from tblKartrisWishlists as WL
		inner join tblKartrisBasketValues as BV on WL.WL_ID=BV.BV_ParentID and WL_UserID=@CustomerID and WL_ID=@WishListID and BV_ParentType=''w''
		inner join tblKartrisVersions as V on V.V_ID=BV.BV_VersionID
		inner join tblKartrisLanguageElements as LE on LE.LE_ParentID=BV.BV_VersionID
		inner join tblKartrisLanguageElementTypes as LET on LET.LET_ID=LE.LE_TypeID and LET_Name=''tblKartrisVersions''
		inner join tblKartrisLanguageElementFieldNames as LEFN on LEFN.LEFN_ID=LE.LE_FieldID and LEFN.LEFN_Name=''Name''
		left join (
			select LE_ParentID,LE_Value from tblKartrisLanguageElements LE
			inner join tblKartrisLanguageElementFieldNames LEFN on LEFN.LEFN_ID=LE.LE_FieldID and LEFN.LEFN_Name=''Name''
			inner join tblKartrisLanguageElementTypes LET on LET.LET_ID=LE.LE_TypeID and LET_Name=''tblKartrisProducts''
			where LE_LanguageID=1) B
		on V.V_ProductID=B.LE_ParentID
		where LE_LanguageID=@Language
		order by BV_ID
	End
	Else
	Begin -- get wishlist by wishlist id
		select * from tblKartrisWishLists WL
		left join tblKartrisUsers U on WL.WL_UserID=U.U_ID
		where WL_ID=@WishListID
	End

END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_GetShippingMethod]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_GetShippingMethod]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 19/June/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_GetShippingMethod] ( 
	@LanguageID int,
	@ShippingID int,
	@DestinationID int,
	@T_ID int=0
) AS
BEGIN
	SET NOCOUNT ON;

	declare @ShippingName nvarchar(200)
	declare @ShippingDesc nvarchar(200)
	declare @Tax float
	declare @TaxRate float

	select @ShippingName=SM_Name, @ShippingDesc=SM_Desc from dbo.vKartrisTypeShippingMethods
	where LANG_ID=@LanguageID and SM_ID=@ShippingID

	select @Tax=D_Tax from dbo.vKartrisTypeDestinations
	where LANG_ID=1 and D_ID=@DestinationID

	select @TaxRate=T_TaxRate from tblKartrisTaxRates
	where T_ID=@T_ID

	select isnull(@ShippingName,'''') ''ShippingName'',isnull(@ShippingDesc,'''') ''ShippingDesc'', isnull(@Tax,0) ''Tax'', isnull(@TaxRate,0) ''TaxRate''

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasketValues_DeleteItems]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasketValues_DeleteItems]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 20/Apr/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasketValues_DeleteItems](
	@intType int, 
	@intID int
)
AS

--Disable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
--Disable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	

if @intType=1 -- delete all basket items
begin

	delete from tblKartrisBasketOptionValues
	where BSKTOPT_BasketValueID in (
		select BV_ID from tblKartrisBasketValues
		where BV_ParentID=@intID and BV_ParentType=''b'')

	delete from tblKartrisBasketValues
	where BV_ParentType=''b'' and BV_ParentID=@intID 
end;

if @intType=2 -- delete basket item only
begin

	delete tblKartrisBasketOptionValues where 
	BSKTOPT_BasketValueID=@intID

	delete from tblKartrisBasketValues
	where BV_ParentType=''b'' and BV_ID=@intID
end;

--Enable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
--Enable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_GetOptionText]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_GetOptionText]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 02/June/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_GetOptionText](
	@LanguageID int,
	@BasketItemID int
)AS
BEGIN
	SET NOCOUNT ON;

	select BSKTOPT_OptionID,OPTG_OptionDisplayType,OPTG_BackendName,LE_Value from tblKartrisBasketOptionValues BOV
		inner join tblKartrisLanguageElements LE on BOV.BSKTOPT_OptionID=LE.LE_ParentID
		inner join tblKartrisLanguageElementTypes LET on LE.LE_TypeID=LET.LET_ID
		inner join tblKartrisOptions O on BOV.BSKTOPT_OptionID=O.OPT_ID
		inner join tblKartrisOptionGroups OG on O.OPT_OptionGroupID=OG.OPTG_ID
	where BSKTOPT_BasketValueID=@BasketItemID and LE_LanguageID=@LanguageID and LET_Name=''tblKartrisOptions''
	order by BSKTOPT_ID


END





' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisCategories_GetName]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisCategories_GetName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisCategories_GetName] 
(
	-- Add the parameters for the function here
	@CAT_ID as int,
	@LANG_ID as tinyint
)
RETURNS nvarchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(MAX);

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = CAT_Name FROM vKartrisTypeCategories WHERE CAT_ID = @CAT_ID AND LANG_ID = @LANG_ID ;

	-- Return the result of the function
	RETURN @Result

END
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisBasketOptionValues_GetOptionsTotalPrice]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisBasketOptionValues_GetOptionsTotalPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisBasketOptionValues_GetOptionsTotalPrice] 
(
	@ProductID as int,
	@VersionID as bigint,
	@BV_ParentID as bigint,
	@BV_ID as bigint	
)
RETURNS real
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result real;

	SELECT  @Result = SUM(tblKartrisProductOptionLink.P_OPT_PriceChange)
	FROM         tblKartrisBasketOptionValues RIGHT OUTER JOIN
						  tblKartrisProductOptionLink ON tblKartrisBasketOptionValues.BSKTOPT_OptionID = tblKartrisProductOptionLink.P_OPT_OptionID RIGHT OUTER JOIN
						  tblKartrisBasketValues ON tblKartrisBasketOptionValues.BSKTOPT_BasketValueID = tblKartrisBasketValues.BV_ID
	GROUP BY tblKartrisBasketOptionValues.BSKTOPT_BasketValueID, tblKartrisBasketValues.BV_ParentID, tblKartrisBasketValues.BV_VersionID, 
						  tblKartrisProductOptionLink.P_OPT_ProductID
	HAVING      (tblKartrisBasketOptionValues.BSKTOPT_BasketValueID = @BV_ID) AND (tblKartrisBasketValues.BV_ParentID = @BV_ParentID) AND 
						  (tblKartrisBasketValues.BV_VersionID = @VersionID) AND (tblKartrisProductOptionLink.P_OPT_ProductID = @ProductID)

	IF @Result is NULL
	BEGIN
		SET @Result = 0;
	END
	-- Return the result of the function
	RETURN @Result

END
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartris_GetBaseVersionID]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartris_GetBaseVersionID]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 18-Feb-2009
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartris_GetBaseVersionID](
	@V_ID bigint
)
RETURNS bigint
AS
BEGIN

	DECLARE @Result bigint

	declare @V_Type nvarchar(1)
	declare @V_ProductID bigint

	SELECT  @V_Type=V_Type, @V_ProductID=V_ProductID FROM tblKartrisVersions WHERE V_ID = @V_ID
	
	If @V_Type <> ''v''
	Begin
		SELECT  @Result=V_ID FROM tblKartrisVersions 
		WHERE V_Type=''b'' and V_ProductID=@V_ProductID
	End
	Else
	Begin
		SELECT  @Result=V_ID FROM tblKartrisVersions WHERE V_ID = @V_ID
	End

	RETURN isnull(@Result,0) 

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_UpdateStockLevel]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_UpdateStockLevel]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_UpdateStockLevel]
(
	@V_ID as bigint,
	@V_Quantity as real,
	@V_QuantityWarnLevel as real
)
								
AS
BEGIN
	
	SET NOCOUNT ON;

Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	UPDATE tblKartrisVersions
	SET V_Quantity = @V_Quantity, V_QuantityWarnLevel = @V_QuantityWarnLevel
	WHERE V_ID = @V_ID;
Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_UpdatePriceList]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_UpdatePriceList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_UpdatePriceList]
(
	@PriceList as nvarchar(max),
	@LineNumber as bigint out
)								
AS
BEGIN
	
	SET NOCOUNT ON;
	SET @LineNumber = 0;
	--SET @PriceList = REPLACE(@PriceList, char(13), ''#'');
	SET @PriceList = REPLACE(@PriceList, char(10), '''');

	DECLARE @ParsedList as table(Line varchar(20))
	DECLARE @Line varchar(20), @Pos int    
	SET @PriceList = LTRIM(RTRIM(@PriceList))+ ''#''    
	SET @Pos = CHARINDEX(''#'', @PriceList, 1)    
	IF REPLACE(@PriceList, ''#'', '''') <> '''' BEGIN        
		WHILE @Pos > 0 BEGIN                
			SET @Line = LTRIM(RTRIM(LEFT(@PriceList, @Pos - 1)))                
			IF @Line <> '''' BEGIN INSERT INTO @ParsedList (Line) VALUES (@Line);	END                
			SET @PriceList = RIGHT(@PriceList, LEN(@PriceList) - @Pos)                
			SET @Pos = CHARINDEX(''#'', @PriceList, 1)        
		END    
	END
;
Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	DECLARE @NewValues as nvarchar(50);
	DECLARE crsrPriceList CURSOR FOR
	select * from @ParsedList;

	OPEN crsrPriceList
	FETCH NEXT FROM crsrPriceList
	INTO @NewValues

	DECLARE @VersionCode as nvarchar(25), @Price as real;
	DECLARE @CommaPosition as int;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @LineNumber = @LineNumber + 1;
		SET @CommaPosition = CHARINDEX('','', @NewValues, 1);
		
		SET @VersionCode = LTRIM(RTRIM(LEFT(@NewValues, @CommaPosition - 1)))
		SET @Price = CAST(LTRIM(RTRIM( RIGHT(@NewValues, LEN(@NewValues) - @CommaPosition))) As real)
		
		UPDATE dbo.tblKartrisVersions
		SET V_Price = @Price WHERE V_CodeNumber = @VersionCode;
		
		FETCH NEXT FROM crsrPriceList
		INTO @NewValues
	END
	
	CLOSE crsrPriceList
	DEALLOCATE crsrPriceList;
	
Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;
	

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_UpdateDownloadInfo]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_UpdateDownloadInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_UpdateDownloadInfo]
(
	@V_ID as bigint,
	@V_DownLoadInfo as nvarchar(255)	
)
								
AS
BEGIN
	
	SET NOCOUNT ON;

Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	UPDATE tblKartrisVersions
	SET V_DownLoadInfo = @V_DownLoadInfo
	WHERE V_ID = @V_ID;
Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	

END


' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisBasket_GetItemWeight]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisBasket_GetItemWeight]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisBasket_GetItemWeight]
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

	DECLARE @ProductType as char(1);
	
	SELECT @ProductType = P_Type
	FROM tblKartrisProducts 
	WHERE P_ID = @ProductID;
	
	IF @ProductType IN (''s'',''m'') BEGIN
		SELECT @Weight = V_Weight
		FROM tblKartrisVersions
		WHERE V_ID = @VersionID;
	END ELSE BEGIN
		DECLARE @OptionsList as nvarchar(max);
		SELECT @OptionsList = COALESCE(@OptionsList + '','', '''') + CAST(T.BSKTOPT_OptionID As nvarchar(10))
		FROM (SELECT BSKTOPT_OptionID FROM dbo.tblKartrisBasketOptionValues WHERE  BSKTOPT_BasketValueID = @BasketValueID) AS T;
		
		SELECT @Weight = SUM(P_OPT_WeightChange)
		FROM dbo.tblKartrisProductOptionLink
		WHERE P_OPT_ProductID = @ProductID AND P_OPT_OptionID IN (SELECT * FROM dbo.fnTbl_SplitNumbers(@OptionsList));
		
		-- If weight = 0, then no weight change for the options, we need to use the base version.
		IF @Weight = 0 BEGIN
			SELECT @Weight = V_Weight FROM tblKartrisVersions WHERE V_ID = @VersionID;
		END
	END
	
	-- Return the result of the function
	RETURN @Weight;

END
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisAttributeValues_GetProductID]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisAttributeValues_GetProductID]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisAttributeValues_GetProductID] 
(
	-- Add the parameters for the function here
	@ATTRIBV_ID as int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result int;

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = ATTRIBV_ProductID FROM tblKartrisAttributeValues WHERE ATTRIBV_ID = @ATTRIBV_ID;

	-- Return the result of the function
	RETURN @Result

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_UpdateCombinationVersion]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_UpdateCombinationVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Updates a specific combination version
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_UpdateCombinationVersion]
(
	@ID as bigint,
	@Name as nvarchar(50), 
	@CodeNumber as nvarchar(50),
	@Price as real,
	@StockQty as real,
	@QtyWarnLevel as real,
	@Live as bit
)
AS
BEGIN
	SET NOCOUNT ON;

Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	UPDATE tblKartrisVersions
	SET V_CodeNumber = @CodeNumber, V_Price = @Price, V_Quantity = @StockQty, V_QuantityWarnLevel = @QtyWarnLevel, V_Live = @Live
	WHERE V_ID = @ID;
Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	

Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;	
	UPDATE tblKartrisLanguageElements
	SET LE_Value = @Name
	WHERE LE_TypeID = 1 AND LE_FieldID = 1 AND LE_ParentID = @ID;
Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;	

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_UpdateCombinationsFromBasicInfo]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_UpdateCombinationsFromBasicInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Updates a specific combination version
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_UpdateCombinationsFromBasicInfo]
(
	@ProductID as int,
	@Price as real, 
	@Tax as tinyint,
	@Tax2 as tinyint,
	@TaxExtra as nvarchar(50),
	@Weight as real,
	@RRP as real
)
AS
BEGIN
	SET NOCOUNT ON;

Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	UPDATE tblKartrisVersions
	SET V_Price = @Price, V_Tax = @Tax, V_Weight = @Weight, V_RRP = @RRP, V_Tax2 = @Tax2, V_TaxExtra = @TaxExtra
	WHERE V_ProductID = @ProductID AND (V_Type = ''c'' OR V_Type = ''s'');
Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	

	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_Update]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_Update]
(
	@V_ID as bigint,
	@V_CodeNumber as nvarchar(25),
	@V_ProductID as int,
	@V_Price as real,
	@V_Tax as tinyint,
	@V_Weight as real,
	@V_DeliveryTime as tinyint,
	@V_Quantity as real,
	@V_QuantityWarnLevel as real,
	@V_Live as bit,
	@V_DownLoadInfo as nvarchar(255),
	@V_DownloadType as nvarchar(50),
	@V_RRP as real,
	@V_Type as char(1),
	@V_CustomerGroupID as smallint,
	@V_CustomizationType as char(1),
	@V_CustomizationDesc as nvarchar(255),
	@V_CustomizationCost as real,
	@V_Tax2 as tinyint,
	@V_TaxExtra as nvarchar(255)
)
								
AS
BEGIN
	
	SET NOCOUNT ON;

Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	UPDATE tblKartrisVersions
	SET V_CodeNumber = @V_CodeNumber, V_ProductID = @V_ProductID, V_Price = @V_Price, V_Tax = @V_Tax, V_Weight = @V_Weight, 
		V_DeliveryTime = @V_DeliveryTime, V_Quantity = @V_Quantity, V_QuantityWarnLevel = @V_QuantityWarnLevel, 
		V_Live = @V_Live, V_DownLoadInfo = @V_DownLoadInfo, V_DownloadType = @V_DownloadType,
		V_RRP = @V_RRP, V_Type = @V_Type, V_CustomerGroupID = @V_CustomerGroupID, V_CustomizationType = @V_CustomizationType,
		V_CustomizationDesc = @V_CustomizationDesc, V_CustomizationCost = @V_CustomizationCost, 
		V_Tax2 = @V_Tax2, V_TaxExtra = @V_TaxExtra
	WHERE V_ID = @V_ID;
Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_SuspendProductVersions]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_SuspendProductVersions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Used in the OptionsBLL in the "_SuspendProductVersions" Function.
--					Transactional Usage.
-- Back/Front : Back-End
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_SuspendProductVersions](@P_ID as int)
AS
BEGIN
	SET NOCOUNT ON;
Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	UPDATE		tblKartrisVersions
	SET			V_Type = ''s''
	WHERE		(V_ProductID = @P_ID) AND (V_Type = ''c'');
Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_SetBaseByProduct]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_SetBaseByProduct]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisVersions_SetBaseByProduct]
(
	@ProductID as int
)								
AS
BEGIN
	
	SET NOCOUNT ON;
Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	UPDATE tblKartrisVersions
	SET  V_Type = ''b''
	WHERE V_ProductID = @ProductID;
Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	

END

' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisSuppliers_GetNameByVersionCode]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisSuppliers_GetNameByVersionCode]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Mohammad
-- Create date: 4-Mar-2012
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisSuppliers_GetNameByVersionCode](
	@VersionCode as nvarchar(25)
)
RETURNS nvarchar(50)
AS
BEGIN

	DECLARE @Result nvarchar(50);

	SELECT   @Result = tblKartrisSuppliers.SUP_Name
	FROM         tblKartrisVersions INNER JOIN
						  tblKartrisProducts ON tblKartrisVersions.V_ProductID = tblKartrisProducts.P_ID INNER JOIN
						  tblKartrisSuppliers ON tblKartrisProducts.P_SupplierID = tblKartrisSuppliers.SUP_ID
	WHERE     (tblKartrisVersions.V_CodeNumber = @VersionCode)

	RETURN @Result

END' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisProduct_GetMinPrice]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisProduct_GetMinPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisProduct_GetMinPrice] 
(
	-- Add the parameters for the function here
	@V_ProductID as int
	
)
RETURNS real
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result real;

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = Min(V_Price) FROM tblKartrisVersions WHERE V_ProductID = @V_ProductID AND V_Live = 1 AND tblKartrisVersions.V_CustomerGroupID IS NULL;
	
	DECLARE @QD_MinPrice as real;
	SELECT @QD_MinPrice = Min(QD_Price)
	FROM dbo.tblKartrisQuantityDiscounts INNER JOIN tblKartrisVersions 
		ON tblKartrisQuantityDiscounts.QD_VersionID = tblKartrisVersions.V_ID
	WHERE tblKartrisVersions.V_Live = 1 AND tblKartrisVersions.V_ProductID = @V_ProductID AND tblKartrisVersions.V_CustomerGroupID IS NULL;

	IF @QD_MinPrice <> 0 AND @QD_MinPrice IS NOT NULL AND @QD_MinPrice < @Result
	BEGIN
		SET @Result = @QD_MinPrice
	END

	IF @Result IS NULL
	BEGIN
		SET @Result = 0;
	END
	-- Return the result of the function
	RETURN @Result

END
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisLanguageElement_GetProductID]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisLanguageElement_GetProductID]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisLanguageElement_GetProductID] 
(
	-- Add the parameters for the function here
	@LE_TypeID as tinyint,
	@LE_ParentID as int
	
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result int;
	SET @Result = 0;
	
	IF @LE_TypeID = 1	BEGIN SELECT @Result = V_ProductID FROM tblKartrisVersions WHERE V_ID = @LE_ParentID; END
	IF @LE_TypeID = 2	BEGIN SET @Result = @LE_ParentID; END
	IF @LE_TypeID = 14	BEGIN SELECT @Result = ATTRIBV_ProductID FROM tblKartrisAttributeValues WHERE ATTRIBV_ID = @LE_ParentID; END
	
	-- Return the result of the function
	RETURN @Result

END
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisProducts_GetName]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisProducts_GetName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisProducts_GetName] 
(
	-- Add the parameters for the function here
	@P_ID as int,
	@LANG_ID as tinyint
)
RETURNS nvarchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(MAX);

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = P_Name FROM vKartrisTypeProducts WHERE P_ID = @P_ID AND LANG_ID = @LANG_ID ;

	-- Return the result of the function
	RETURN @Result

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisKnowledgebase_Search]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisKnowledgebase_Search]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisKnowledgebase_Search]
(	@keyWordsList as nvarchar(500),
	@LANG_ID as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
	
	-----------------------
	-- Variable Declaration
	-----------------------
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @Keyword as nvarchar(150);
	DECLARE @Counter as int;
	DECLARE @CurrentScore as int;

	-- Creating a temporary table to hold/modify the needed data
	CREATE TABLE #TempSearchScoreTbl(TypeID tinyint, FieldID tinyint, ParentID bigint, TextValue nvarchar(MAX), Score int)

	SET @SIndx = 0;
	SET @Counter = 0;
	WHILE @SIndx <= LEN(@keyWordsList)
	BEGIN
		
		-- Loop through out the keyword''s list
		SET @Counter = @Counter + 1;	-- keywords counter
		SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)	-- Next keyword starting index (1-Based Index)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+ 1 END	-- If no more keywords, set next starting index to not exist
		SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
		
		SET @SIndx = @CIndx + 1;	-- The next starting index
				
		-- For each keyword Occurance
		SET @CurrentScore = 0;
		
		-- For the first match .. "The Exact Phrase"
		IF @Counter = 1 BEGIN SET @CurrentScore = 0 END
		
		INSERT INTO #TempSearchScoreTbl (TypeID,FieldID,ParentID,TextValue, Score)
		SELECT     LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, @CurrentScore
		FROM       tblKartrisLanguageElements
		WHERE     (LE_LanguageID = @LANG_ID) AND
				  ((LE_TypeID = 17) AND (LE_FieldID = 1 OR LE_FieldID = 3 OR LE_FieldID = 4 OR LE_FieldID = 5 OR LE_FieldID = 6))  -- Search in Products (Name, Desc ..)
					AND LE_Value LIKE ''%'' + @KeyWord + ''%'';
	END

	UPDATE #TempSearchScoreTbl 	SET Score = Score + 200	WHERE FieldID = 1;
	UPDATE #TempSearchScoreTbl 	SET Score = Score + 100	WHERE FieldID = 6;
	UPDATE #TempSearchScoreTbl 	SET Score = Score + 50	WHERE FieldID = 3;
	UPDATE #TempSearchScoreTbl 	SET Score = Score + 30	WHERE FieldID = 5;
	UPDATE #TempSearchScoreTbl 	SET Score = Score + 20	WHERE FieldID = 4;

	DECLARE keywordCursor CURSOR FOR 
	SELECT TypeID, ParentID, TextValue, Score
	FROM #TempSearchScoreTbl
		
	DECLARE @Type as tinyint;
	DECLARE @Parent as bigint;
	DECLARE @TextValue as nvarchar(MAX);
	DECLARE @Score as int;

	OPEN keywordCursor
	FETCH NEXT FROM keywordCursor
	INTO @Type, @Parent, @TextValue, @Score;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SET @SIndx = 0;
		
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList) + 1 END
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			SET @SIndx = @CIndx + 1;
			SET @Counter = 0;
			DECLARE @Start as int;
			DECLARE @CharIndx as int;
			SET @Start = 0;
			
			WHILE @Start <= LEN(@TextValue)
			BEGIN
				SET @Counter = @Counter + 1;
				SET @CharIndx = CHARINDEX(@KeyWord, @TextValue, @Start)
				IF @CharIndx = 0 
				BEGIN 
					SET @CharIndx = LEN(@TextValue) + 1 
				END
				ELSE
				BEGIN
					DECLARE @ScoreDegree as int;
					SET @ScoreDegree = 1;
					IF @Counter = 1 BEGIN SET @ScoreDegree = 10 END
					UPDATE #TempSearchScoreTbl 
					SET Score = Score + @ScoreDegree 
					WHERE TextValue LIKE ''%'' + @keyWord + ''%'' AND TextValue = @TextValue;
				END
				SET @Start = @CharIndx + 1;
			END
		END		
	
		FETCH NEXT FROM keywordCursor
		INTO @Type, @Parent, @TextValue, @Score;
	END

	CLOSE keywordCursor
	DEALLOCATE keywordCursor;

	
	SELECT KB_ID, KB_Name, dbo.fnKartrisDB_TruncateDescription(KB_Text) as KB_Text, TotalScore 
	FROM dbo.vKartrisTypeKnowledgeBase 
		INNER JOIN (SELECT ParentID, Sum(Score) as TotalScore
					FROM #TempSearchScoreTbl
					Group By ParentID) Result 
					ON Result.ParentID = vKartrisTypeKnowledgeBase.KB_ID
	WHERE LANG_ID = @LANG_ID AND KB_Live = 1
	ORDER BY TotalScore DESC;

	DROP TABLE #TempSearchScoreTbl;

END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisKnowledgeBase_GetTitleByID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisKnowledgeBase_GetTitleByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisKnowledgeBase_GetTitleByID]
(
	@LangID as tinyint,
	@KB_ID as int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	SELECT KB_PageTitle
	FROM dbo.vKartrisTypeKnowledgeBase
	WHERE LANG_ID = @LangID AND KB_ID = @KB_ID AND KB_Live = 1

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisKnowledgeBase_GetByID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisKnowledgeBase_GetByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisKnowledgeBase_GetByID]
(
	@LangID as tinyint,
	@KB_ID as int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	SELECT *
	FROM dbo.vKartrisTypeKnowledgeBase
	WHERE LANG_ID = @LangID AND KB_ID = @KB_ID AND KB_Live = 1

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisKnowledgeBase_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisKnowledgeBase_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisKnowledgeBase_Get]
(
	@LangID as tinyint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	SELECT *
	FROM dbo.vKartrisTypeKnowledgeBase
	WHERE LANG_ID = @LangID AND KB_Live = 1

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisDestinations_GetbyIsoCode]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisDestinations_GetbyIsoCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get All Destinations list
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisDestinations_GetbyIsoCode](@D_IsoCode as char(2),@LANG_ID as tinyint)

AS
BEGIN
	SET NOCOUNT ON;
	SELECT		D_ID,D_Name,D_IsoCode,D_ID,D_Tax,D_Tax2, D_TaxExtra, D_ShippingZoneID
	FROM         vKartrisTypeDestinations
	WHERE      D_IsoCode = @D_IsoCode AND LANG_ID = @LANG_ID
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisDestinations_GetAll]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisDestinations_GetAll]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get All Destinations list
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisDestinations_GetAll]
(
	@LANG_ID as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT		D_ID,D_Name,D_IsoCode,D_Tax, D_Tax2, D_TaxExtra, D_ShippingZoneID
	FROM         vKartrisTypeDestinations WHERE D_Live = ''true'' AND LANG_ID = @LANG_ID ORDER BY D_Name ASC
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisDestinations_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisDestinations_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get All Destinations list
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisDestinations_Get](@D_ID as int,@LANG_ID as tinyint)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT		D_ID,D_Name,D_IsoCode,D_Tax, D_Tax2, D_TaxExtra, D_ShippingZoneID, D_Live
	FROM         vKartrisTypeDestinations
	WHERE      D_ID = @D_ID AND LANG_ID = @LANG_ID
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisOrders_CallbackUpdate]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisOrders_CallbackUpdate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [dbo].[spKartrisOrders_CallbackUpdate]
(
	@O_ID int,
	@O_ReferenceCode nvarchar(100),
	@O_LastModified smalldatetime,
	@O_Sent bit,
	@O_Invoiced bit,
	@O_Paid bit,
	@O_Status nvarchar(MAX),
	@O_WLID int
)
AS
BEGIN
	SET NOCOUNT ON;

		Disable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	
		UPDATE [tblKartrisOrders] SET 
		[O_ReferenceCode] = @O_ReferenceCode, 
		[O_LastModified] = @O_LastModified, 
		[O_Sent] = @O_Sent, 
		[O_Invoiced] = @O_Invoiced, 
		[O_Paid] = @O_Paid,
		[O_Status] = @O_Status
		WHERE [O_ID] = @O_ID;
		Enable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	

			DECLARE @V_Codenumber nvarchar(25)
			DECLARE @IR_Quantity int
			DECLARE @V_ID int
			DECLARE tnames_cursor CURSOR
		FOR
	-- check if return stock flag is on
		SELECT     tblKartrisInvoiceRows.IR_VersionCode, tblKartrisInvoiceRows.IR_Quantity
		FROM         tblKartrisOrders INNER JOIN
							  tblKartrisInvoiceRows ON tblKartrisOrders.O_ID = tblKartrisInvoiceRows.IR_OrderNumberID
		WHERE     (tblKartrisOrders.O_ID = @O_ID)
		
		OPEN tnames_cursor
		--loop through the invoicerows records and return the stocks back to individual versions
		FETCH NEXT FROM tnames_cursor INTO @V_Codenumber,@IR_Quantity
		WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			IF (@@FETCH_STATUS <> -2)
			BEGIN 
				Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
				--Process version stocks
				UPDATE tblKartrisVersions SET V_Quantity= V_Quantity - @IR_Quantity WHERE V_CodeNumber=@V_Codenumber AND V_QuantityWarnLevel<>0;
				SELECT @V_ID = V_ID FROM tblKartrisVersions WHERE V_CodeNumber = @V_Codenumber;
				Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
				--Process version stocks
				IF (@O_WLID > 0)
				BEGIN
					--Disable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	
					UPDATE tblKartrisBasketValues SET BV_Quantity= BV_Quantity - @IR_Quantity 
						WHERE BV_VersionID=@V_ID AND BV_ParentID = @O_WLID AND BV_ParentType = ''r'';
					--Enable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	
				END
			END
			FETCH NEXT FROM tnames_cursor INTO @V_Codenumber,@IR_Quantity
		END
		CLOSE tnames_cursor
		DEALLOCATE tnames_cursor ;
	

	
	SELECT @O_ID;
END	




' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProductOptionLink_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProductOptionLink_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisProductOptionLink_Get]
AS
	SET NOCOUNT ON;
SELECT        tblKartrisProductOptionLink.*
FROM            tblKartrisProductOptionLink

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProductOptionGroupLink_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProductOptionGroupLink_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisProductOptionGroupLink_Get]
AS
	SET NOCOUNT ON;
SELECT        tblKartrisProductOptionGroupLink.*
FROM            tblKartrisProductOptionGroupLink

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProductCategoryLink_GetCategoriesByProductID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProductCategoryLink_GetCategoriesByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisProductCategoryLink_GetCategoriesByProductID]
(
	@PCAT_ProductID int
)
AS
	SET NOCOUNT OFF;

SELECT     PCAT_CategoryID
FROM         tblKartrisProductCategoryLink
WHERE     (PCAT_ProductID = @PCAT_ProductID)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProductCategoryLink_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProductCategoryLink_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisProductCategoryLink_Get]
AS
	SET NOCOUNT ON;
SELECT        tblKartrisProductCategoryLink.*
FROM            tblKartrisProductCategoryLink

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisOrders_UpdateByReferenceCode]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisOrders_UpdateByReferenceCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [dbo].[spKartrisOrders_UpdateByReferenceCode]
(
	@O_ReferenceCode nvarchar(100),
	@O_LastModified smalldatetime,
	@O_Sent bit,
	@O_Invoiced bit,
	@O_Paid bit,
	@O_Status nvarchar(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	IF (@O_Paid = 1)
	BEGIN
Disable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	
		UPDATE [tblKartrisOrders] SET 
		[O_LastModified] = @O_LastModified, 
		[O_Sent] = @O_Sent, 
		[O_Invoiced] = @O_Invoiced, 
		[O_Paid] = @O_Paid,
		[O_Status] = @O_Status
		WHERE [O_ReferenceCode] = @O_ReferenceCode;
Enable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	

		DECLARE @O_WLID int
		Select  @O_WLID = [O_WishListID] from [tblKartrisOrders] WHERE [O_ReferenceCode] = @O_ReferenceCode;

		DECLARE @V_ID int
		DECLARE @IR_Quantity int
		
		DECLARE tnames_cursor CURSOR
			
		FOR
	-- check if return stock flag is on
		SELECT V_ID,IR_Quantity FROM 
				((tblKartrisOrders INNER JOIN tblKartrisInvoiceRows ON tblKartrisOrders.O_ID = tblKartrisInvoiceRows.IR_OrderNumberID) 
				INNER JOIN tblKartrisVersions ON tblKartrisInvoiceRows.IR_VersionCode=tblKartrisVersions.V_CodeNumber) 
		WHERE [O_ReferenceCode] = @O_ReferenceCode AND V_QuantityWarnLevel<>0
		
		OPEN tnames_cursor
		--loop through the invoicerows records and return the stocks back to individual versions
		FETCH NEXT FROM tnames_cursor INTO @V_ID,@IR_Quantity
		WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			IF (@@FETCH_STATUS <> -2)
			BEGIN 
Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
				--Process version stocks
				UPDATE tblKartrisVersions SET V_Quantity= V_Quantity - @IR_Quantity WHERE V_ID=@V_ID;
Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
				--Process version stocks
				IF (@O_WLID > 0)
				BEGIN
--Disable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	
					UPDATE tblKartrisBasketValues SET BV_Quantity= BV_Quantity - @IR_Quantity 
						WHERE BV_VersionID=@V_ID AND BV_ParentID = @O_WLID AND BV_ParentType = ''w'';
--Enable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	
				END
			END
			FETCH NEXT FROM tnames_cursor INTO @V_ID,@IR_Quantity
		END
		CLOSE tnames_cursor
		DEALLOCATE tnames_cursor ;
	END

	
	SELECT @O_ReferenceCode;
END	




' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetRelatedProducts]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetRelatedProducts]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisProducts_GetRelatedProducts](@P_ID as int, @LANG_ID as tinyint)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT     vKartrisTypeProducts.P_ID, vKartrisTypeProducts.P_Name
	FROM         tblKartrisRelatedProducts INNER JOIN
						  vKartrisTypeProducts ON tblKartrisRelatedProducts.RP_ChildID = vKartrisTypeProducts.P_ID
	WHERE     (vKartrisTypeProducts.LANG_ID = @LANG_ID) AND (RP_ParentID = @P_ID);

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetPeopleWhoBoughtThis]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetPeopleWhoBoughtThis]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Remarks: Optimized by Mohammad
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisProducts_GetPeopleWhoBoughtThis](
			@P_ID as int, 
			@LANG_ID as tinyint, 
			@numPeopleWhoBoughtThis as int, 
			@Type as bit)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @LANG_COUNT tinyint;
	SET @LANG_COUNT = (SELECT COUNT(1) FROM tblKartrisLanguages);
	
	IF @Type = 1 
		BEGIN
			IF @LANG_COUNT = 1 
				BEGIN
					WITH PeopleWhoBoughtThisList AS
					(
					SELECT TOP (@numPeopleWhoBoughtThis) AlsoProducts.P_ID, AlsoProducts.P_Name, Count(AlsoProducts.P_ID) AS TotalMatches,1 AS LANG_ID 
					FROM (((tblKartrisVersions INNER JOIN tblKartrisInvoiceRows ON tblKartrisVersions.V_CodeNumber = tblKartrisInvoiceRows.IR_VersionCode) 
					INNER JOIN (SELECT TOP(10000) O_ID, O_CustomerID FROM tblKartrisOrders WHERE O_Sent = 1 or O_Paid = 1 ORDER BY O_ID DESC) As RecentOrders ON tblKartrisInvoiceRows.IR_OrderNumberID = RecentOrders.O_ID) 
					INNER JOIN tblKartrisInvoiceRows AS AlsoInvoiceRows ON RecentOrders.O_ID = AlsoInvoiceRows.IR_OrderNumberID) 
					INNER JOIN (tblKartrisVersions AS AlsoVersions 
					INNER JOIN vKartrisTypeProducts AS AlsoProducts ON AlsoVersions.V_ProductID = AlsoProducts.P_ID) 
					ON AlsoInvoiceRows.IR_VersionCode = AlsoVersions.V_CodeNumber
					WHERE tblKartrisVersions.V_ProductID = @P_ID AND AlsoVersions.V_ProductID <> @P_ID AND AlsoProducts.P_Name <> '''' AND P_Live = 1 
							

					GROUP BY AlsoProducts.P_ID, AlsoProducts.P_Name
					)
					SELECT *
					FROM PeopleWhoBoughtThisList ORDER BY TotalMatches DESC;
				END
			ELSE
				BEGIN
					WITH PeopleWhoBoughtThisList AS
					(
					SELECT TOP (@numPeopleWhoBoughtThis) AlsoProducts.P_ID, AlsoProducts.P_Name, Count(AlsoProducts.P_ID) AS TotalMatches,AlsoProducts.LANG_ID 
					FROM (((tblKartrisVersions INNER JOIN tblKartrisInvoiceRows ON tblKartrisVersions.V_CodeNumber = tblKartrisInvoiceRows.IR_VersionCode) 
					INNER JOIN (SELECT TOP(10000) O_ID, O_CustomerID FROM tblKartrisOrders WHERE O_Sent = 1 or O_Paid = 1 ORDER BY O_ID DESC) As RecentOrders ON tblKartrisInvoiceRows.IR_OrderNumberID = RecentOrders.O_ID) 
					INNER JOIN tblKartrisInvoiceRows AS AlsoInvoiceRows ON RecentOrders.O_ID = AlsoInvoiceRows.IR_OrderNumberID) 
					INNER JOIN (tblKartrisVersions AS AlsoVersions 
					INNER JOIN vKartrisTypeProducts AS AlsoProducts ON AlsoVersions.V_ProductID = AlsoProducts.P_ID) 
					ON AlsoInvoiceRows.IR_VersionCode = AlsoVersions.V_CodeNumber
					WHERE tblKartrisVersions.V_ProductID = @P_ID AND AlsoVersions.V_ProductID <> @P_ID AND AlsoProducts.P_Name <> '''' AND P_Live = 1 
							

					GROUP BY AlsoProducts.P_ID, AlsoProducts.P_Name, AlsoProducts.LANG_ID
					)
					SELECT *
					FROM PeopleWhoBoughtThisList ORDER BY TotalMatches DESC;
				END
		END
	ELSE
		BEGIN
			IF @LANG_COUNT = 1 
				BEGIN
					WITH PeopleWhoBoughtThisList AS
					(
					SELECT     TOP (@numPeopleWhoBoughtThis) AlsoProducts.P_ID, AlsoProducts.P_Name, COUNT(1) AS TotalMatches, 1 AS LANG_ID
					FROM         tblKartrisInvoiceRows AS AlsoInvoiceRows INNER JOIN
										  tblKartrisVersions AS AlsoVersions INNER JOIN
										  vKartrisTypeProducts AS AlsoProducts ON AlsoVersions.V_ProductID = AlsoProducts.P_ID ON 
										  AlsoInvoiceRows.IR_VersionCode = AlsoVersions.V_CodeNumber INNER JOIN
										  (SELECT TOP(10000) O_ID, O_CustomerID FROM tblKartrisOrders WHERE O_Sent = 1 or O_Paid = 1 ORDER BY O_ID DESC) AS AlsoOrderNumbers 
										  INNER JOIN tblKartrisVersions INNER JOIN
										  tblKartrisInvoiceRows ON tblKartrisVersions.V_CodeNumber = tblKartrisInvoiceRows.IR_VersionCode INNER JOIN
										  (SELECT TOP(10000) O_ID, O_CustomerID FROM tblKartrisOrders WHERE O_Sent = 1 or O_Paid = 1 ORDER BY O_ID DESC) As RecentOrders  
										  ON tblKartrisInvoiceRows.IR_OrderNumberID = RecentOrders.O_ID INNER JOIN
										  tblKartrisUsers ON RecentOrders.O_CustomerID = tblKartrisUsers.U_ID ON AlsoOrderNumbers.O_CustomerID = tblKartrisUsers.U_ID ON 
										  AlsoInvoiceRows.IR_OrderNumberID = AlsoOrderNumbers.O_ID
					WHERE     (tblKartrisVersions.V_ProductID = @P_ID) AND (AlsoVersions.V_ProductID <> @P_ID) AND (AlsoProducts.P_Name <> '''') AND (AlsoProducts.P_Live = 1) 
					GROUP BY AlsoProducts.P_ID, AlsoProducts.P_Name
					)
					SELECT *
					FROM PeopleWhoBoughtThisList ORDER BY TotalMatches DESC;
				END
			ELSE
				BEGIN
					WITH PeopleWhoBoughtThisList AS
					(
					SELECT     TOP (@numPeopleWhoBoughtThis) AlsoProducts.P_ID, AlsoProducts.P_Name, COUNT(1) AS TotalMatches, AlsoProducts.LANG_ID
					FROM         tblKartrisInvoiceRows AS AlsoInvoiceRows INNER JOIN
										  tblKartrisVersions AS AlsoVersions INNER JOIN
										  vKartrisTypeProducts AS AlsoProducts ON AlsoVersions.V_ProductID = AlsoProducts.P_ID ON 
										  AlsoInvoiceRows.IR_VersionCode = AlsoVersions.V_CodeNumber INNER JOIN
										  (SELECT TOP(10000) O_ID, O_CustomerID FROM tblKartrisOrders WHERE O_Sent = 1 or O_Paid = 1 ORDER BY O_ID DESC) AS AlsoOrderNumbers INNER JOIN
										  tblKartrisVersions INNER JOIN
										  tblKartrisInvoiceRows ON tblKartrisVersions.V_CodeNumber = tblKartrisInvoiceRows.IR_VersionCode INNER JOIN
										  (SELECT TOP(10000) O_ID, O_CustomerID FROM tblKartrisOrders WHERE O_Sent = 1 or O_Paid = 1 ORDER BY O_ID DESC) As RecentOrders 
										  ON tblKartrisInvoiceRows.IR_OrderNumberID = RecentOrders.O_ID INNER JOIN
										  tblKartrisUsers ON RecentOrders.O_CustomerID = tblKartrisUsers.U_ID ON AlsoOrderNumbers.O_CustomerID = tblKartrisUsers.U_ID ON 
										  AlsoInvoiceRows.IR_OrderNumberID = AlsoOrderNumbers.O_ID
					WHERE     (tblKartrisVersions.V_ProductID = @P_ID) AND (AlsoVersions.V_ProductID <> @P_ID) AND (AlsoProducts.P_Name <> '''') AND (AlsoProducts.P_Live = 1) 
					GROUP BY AlsoProducts.P_ID, AlsoProducts.P_Name, AlsoProducts.LANG_ID
					)
					SELECT *
					FROM PeopleWhoBoughtThisList
					WHERE LANG_ID = @LANG_ID ORDER BY TotalMatches DESC;
				END
		END
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetParentCategories]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetParentCategories]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisProducts_GetParentCategories]
(
	@LANG_ID tinyint,
	@P_ID int
)
AS
	SET NOCOUNT ON;
SELECT        vKartrisTypeCategories.CAT_ID, vKartrisTypeCategories.CAT_Name
FROM            vKartrisTypeCategories INNER JOIN
						 tblKartrisProductCategoryLink ON vKartrisTypeCategories.CAT_ID = tblKartrisProductCategoryLink.PCAT_CategoryID
WHERE        (vKartrisTypeCategories.LANG_ID = @LANG_ID) AND (tblKartrisProductCategoryLink.PCAT_ProductID = @P_ID)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetNewestProducts]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetNewestProducts]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: 
-- Description:	
-- Remarks: Optimization (Medz) - Modified to use product views instead and to lessen use of GetName function - 14-07-2010
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisProducts_GetNewestProducts]
	(
	@LANG_ID tinyint
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--	SELECT     TOP (10) tblKartrisProducts.P_ID, dbo.fnKartrisProducts_GetName(tblKartrisProducts.P_ID, @LANG_ID) AS P_Name, tblKartrisProducts.P_DateCreated, 
--                      @LANG_ID AS LANG_ID
--	FROM         tblKartrisProducts
--	WHERE     (tblKartrisProducts.P_Live = 1) AND (NOT (dbo.fnKartrisProducts_GetName(tblKartrisProducts.P_ID, @LANG_ID) IS NULL)) AND 
--				(tblKartrisProducts.P_CustomerGroupID IS NULL) AND tblKartrisProducts.P_ID IN (SELECT DISTINCT V_ProductID FROM tblKartrisVersions)
--	ORDER BY P_DateCreated DESC, P_ID DESC

	SELECT  DISTINCT TOP(10)  vKartrisTypeProducts.P_ID, vKartrisTypeProducts.P_Name, vKartrisTypeProducts.P_DateCreated, vKartrisTypeProducts.LANG_ID
FROM         vKartrisTypeProducts LEFT OUTER JOIN
					  tblKartrisVersions ON vKartrisTypeProducts.P_ID = tblKartrisVersions.V_ProductID
WHERE     (vKartrisTypeProducts.P_Live = 1) AND (vKartrisTypeProducts.P_Name IS NOT NULL) AND (vKartrisTypeProducts.P_CustomerGroupID IS NULL)
ORDER BY vKartrisTypeProducts.P_DateCreated DESC, vKartrisTypeProducts.P_ID DESC

END' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetNameByProductID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetNameByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- ========================================================
-- Author:		Medz
-- Create date: 03/19/2008 17:45:30
-- Description:	Get the product name for the SiteMap trail.
-- ========================================================
CREATE PROCEDURE [dbo].[spKartrisProducts_GetNameByProductID]
(
	@P_ID int,
	@LANG_ID tinyint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT P_Name
	FROM   vKartrisTypeProducts
	WHERE  (P_ID = @P_ID) AND (LANG_ID = @LANG_ID) AND (P_Live = 1)
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetTotalByCatID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetTotalByCatID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Get the total no. of Products in Category "used for ItemPager"
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisProducts_GetTotalByCatID]
			(
			@LANG_ID as tinyint,
			@CAT_ID as int,	
			@CGroupID as smallint,
			@TotalProducts as int OUTPUT
			)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		SELECT	@TotalProducts = Count(DISTINCT vKartrisTypeProducts.P_ID)
		FROM    tblKartrisProductCategoryLink INNER JOIN
			  vKartrisTypeProducts ON tblKartrisProductCategoryLink.PCAT_ProductID = vKartrisTypeProducts.P_ID INNER JOIN
			  tblKartrisVersions ON vKartrisTypeProducts.P_ID = tblKartrisVersions.V_ProductID LEFT OUTER JOIN
			  tblKartrisTaxRates ON tblKartrisTaxRates.T_ID = tblKartrisVersions.V_Tax
		WHERE   (tblKartrisVersions.V_Live = 1) AND (tblKartrisVersions.V_Type = ''b'' OR tblKartrisVersions.V_Type = ''v'' ) 
				AND (vKartrisTypeProducts.LANG_ID = @LANG_ID) AND (vKartrisTypeProducts.P_Live = 1) 
				AND (tblKartrisProductCategoryLink.PCAT_CategoryID = @CAT_ID) 
				AND (vKartrisTypeProducts.P_CustomerGroupID IS NULL OR vKartrisTypeProducts.P_CustomerGroupID = @CGroupID)
		
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisPages_GetByName]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisPages_GetByName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisPages_GetByName]
(
	@LangID as tinyint,
	@PageName as nvarchar(50)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	SELECT *
	FROM dbo.vKartrisTypePages
	WHERE LANG_ID = @LangID AND PAGE_Name = @PageName AND PAGE_Live = 1

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisSessions_DeleteExpired]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisSessions_DeleteExpired]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 09/Sept/08
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisSessions_DeleteExpired] (
	@NowOffset datetime
)
AS
BEGIN
	SET NOCOUNT ON;

BEGIN TRANSACTION;

-- delete basket option values of all session expired
--Disable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
	delete from tblKartrisBasketOptionValues 
	where BSKTOPT_BasketValueID in (
		select BV_ID from tblKartrisBasketValues
		where BV_ParentType=''b'' and BV_ParentID in (
			select SESS_ID from tblKartrisSessions
			where dateadd(minute,sess_expiry,sess_datelastupdated) < @NowOffset
		)
	);
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK
		RETURN
	END;


	delete from tblKartrisBasketOptionValues 
	where BSKTOPT_BasketValueID in (
		select BV_ID from tblKartrisBasketValues
		where BV_ParentType=''b'' and BV_ParentID not in (
			select SESS_ID from tblKartrisSessions
		)
	);

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK
		RETURN
	END;
--Enable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	

-- delete basket values of all session expired
--Disable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	
	delete from tblKartrisBasketValues
	where BV_ParentType=''b'' and BV_ParentID in (
		select SESS_ID from tblKartrisSessions
		where dateadd(minute,sess_expiry,sess_datelastupdated) < @NowOffset
	);
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK
		RETURN
	END;

	/**
	delete from tblKartrisBasketValues
	where BV_ParentType = ''b'' and BV_ParentID not in (
		select SESS_ID from tblKartrisSessions
	);
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK
		RETURN
	END;
	**/
--Enable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	



-- delete session values of all session expired
--Disable Trigger trigKartrisSessionValues_DML ON tblKartrisSessionValues;	
	delete from tblKartrisSessionValues
	where SESSV_SessionID in (
		select SESS_ID from tblKartrisSessions
		where dateadd(minute,sess_expiry,sess_datelastupdated) < @NowOffset
	);
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK
		RETURN
	END;
--Enable Trigger trigKartrisSessionValues_DML ON tblKartrisSessionValues;	

-- delete all session expired
--Disable Trigger trigKartrisSessions_DML ON tblKartrisSessions;	
	delete from tblKartrisSessions
	where dateadd(minute,sess_expiry,sess_datelastupdated) < @NowOffset;
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK
		RETURN
	END;
--Enable Trigger trigKartrisSessions_DML ON tblKartrisSessions;	

COMMIT

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisReviews_GetByProductID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisReviews_GetByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisReviews_GetByProductID]
(
	@ProductID int,
	@LanguageID tinyint
)
AS
	SET NOCOUNT ON;
SELECT     tblKartrisReviews.REV_ID, tblKartrisReviews.REV_ProductID, tblKartrisReviews.REV_LanguageID, tblKartrisReviews.REV_CustomerID, tblKartrisReviews.REV_Title, 
					  tblKartrisReviews.REV_Text, tblKartrisReviews.REV_Rating, tblKartrisReviews.REV_Name, tblKartrisReviews.REV_Email, tblKartrisReviews.REV_Location, 
					  tblKartrisReviews.REV_DateCreated, tblKartrisReviews.REV_DateLastUpdated, tblKartrisReviews.REV_Live, vKartrisTypeProducts.P_Name
FROM         tblKartrisReviews INNER JOIN
					  vKartrisTypeProducts ON tblKartrisReviews.REV_ProductID = vKartrisTypeProducts.P_ID AND 
					  tblKartrisReviews.REV_LanguageID = vKartrisTypeProducts.LANG_ID
WHERE     (tblKartrisReviews.REV_ProductID = @ProductID) AND 
			(tblKartrisReviews.REV_LanguageID = @LanguageID) AND
				(tblKartrisReviews.REV_Live = ''y'')
ORDER BY tblKartrisReviews.REV_DateLastUpdated DESC

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisReviews_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisReviews_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisReviews_Get]
AS
	SET NOCOUNT ON;
SELECT        tblKartrisReviews.*
FROM            tblKartrisReviews

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetCustomization]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisVersions_GetCustomization]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 18-Feb-2009
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisVersions_GetCustomization](
	@V_ID as bigint
) AS
BEGIN
	
	SET NOCOUNT ON;

	declare @V_Type nvarchar(1)
	declare @V_ProductID bigint
	
	SELECT  @V_Type=V_Type, @V_ProductID=V_ProductID FROM tblKartrisVersions WHERE V_ID = @V_ID
	
	If @V_Type <> ''v''
	Begin
		SELECT  V_CustomizationType, V_CustomizationDesc, V_CustomizationCost FROM tblKartrisVersions 
		WHERE V_Type=''b'' and V_ProductID=@V_ProductID
	End
	Else
	Begin
		SELECT  V_CustomizationType, V_CustomizationDesc, V_CustomizationCost FROM tblKartrisVersions WHERE V_ID = @V_ID
	End

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisShippingMethods_GetByName]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisShippingMethods_GetByName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get Shipping Method - by Destination , Boundary and Name
-- ===============================================================
CREATE PROCEDURE [dbo].[spKartrisShippingMethods_GetByName](@D_ID as int,@Boundary as dec,@SM_Name as char,@LANG_ID as int)
AS
BEGIN
	SET NOCOUNT ON;
SELECT S_ShippingRate, SM_ID, SM_Name, SM_Desc, S_ShippingGateways, SM_Tax, SM_Tax2 FROM (tblKartrisDestination 
	INNER JOIN tblKartrisShippingRates ON tblKartrisDestination.D_ShippingZoneID = tblKartrisShippingRates.S_ShippingZoneID) 
	INNER JOIN vKartrisTypeShippingMethods ON vKartrisTypeShippingMethods.SM_ID = tblKartrisShippingRates.S_ShippingMethodID 
	
	WHERE SM_Live = ''true'' AND S_Boundary>= @Boundary  AND D_ID = @D_ID AND LANG_ID = @LANG_ID AND SM_Name = @SM_Name
	
	ORDER BY SM_OrderByValue ASC, SM_ID ASC, S_Boundary ASC

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisShippingMethods_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisShippingMethods_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get Shipping Methods - by Destination and Boundary
-- ===============================================================
CREATE PROCEDURE [dbo].[spKartrisShippingMethods_Get](@D_ID as int,@Boundary as real,@LANG_ID as int)
AS
BEGIN
	SET NOCOUNT ON;
SELECT S_ShippingRate, SM_ID, SM_Name, SM_Desc, S_ShippingGateways, SM_Tax, SM_Tax2 FROM (tblKartrisDestination 
	INNER JOIN tblKartrisShippingRates ON tblKartrisDestination.D_ShippingZoneID = tblKartrisShippingRates.S_ShippingZoneID) 
	INNER JOIN vKartrisTypeShippingMethods ON vKartrisTypeShippingMethods.SM_ID = tblKartrisShippingRates.S_ShippingMethodID 
	
	WHERE SM_Live = ''true'' AND S_Boundary>= @Boundary  AND D_ID = @D_ID AND LANG_ID = @LANG_ID
	
	ORDER BY SM_OrderByValue ASC, SM_ID ASC, S_Boundary ASC

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetBasicVersionByProductID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisVersions_GetBasicVersionByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisVersions_GetBasicVersionByProductID](@ProductID as bigint)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT     V_ID, V_CodeNumber, V_ProductID, V_Price, V_Tax, V_Weight, V_Quantity, V_QuantityWarnLevel, V_RRP, V_Type
FROM         tblKartrisVersions
WHERE     (V_ProductID = @ProductID) AND (V_Live = 1) AND ((V_Type = ''b'') OR (V_Type = ''o''));
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisWishLists_Delete]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisWishLists_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-------------

CREATE PROCEDURE [dbo].[spKartrisWishLists_Delete] (
	@WishListsID bigint
) AS
BEGIN
	SET NOCOUNT ON;

Disable Trigger trigKartrisWishLists_DML ON tblKartrisWishLists;
--Disable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
--Disable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	

	DELETE tblKartrisWishLists 
	WHERE WL_ID=@WishListsID;

	DELETE tblKartrisBasketOptionValues
	WHERE BSKTOPT_BasketValueID in (SELECT BV_ID FROM tblKartrisBasketValues WHERE BV_ParentID=@WishListsID and BV_ParentType=''w'');

	DELETE tblKartrisBasketValues
	WHERE BV_ParentID=@WishListsID and BV_ParentType=''w'';

	DELETE tblKartrisBasketOptionValues
	WHERE BSKTOPT_BasketValueID in (SELECT BV_ID FROM tblKartrisBasketValues WHERE BV_ParentID=@WishListsID and BV_ParentType=''r'');

	DELETE tblKartrisBasketValues
	WHERE BV_ParentID=@WishListsID and BV_ParentType=''r'';

Enable Trigger trigKartrisWishLists_DML ON tblKartrisWishLists;
--Enable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
--Enable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	

END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisWishLists_Add]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisWishLists_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
----------------

CREATE PROCEDURE [dbo].[spKartrisWishLists_Add] (
	@WL_ID bigint,
	@BasketID int,
	@WL_UserID int,
	@WL_Name nvarchar(200),
	@WL_PublicPassword nvarchar(200),
	@WL_Message nvarchar(2000),
	@NowOffset datetime
) AS
BEGIN
	SET NOCOUNT ON;

Disable Trigger trigKartrisWishLists_DML ON tblKartrisWishLists;
--Disable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
--Disable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	


	If @WL_ID=0
	Begin
		insert into tblKartrisWishLists (WL_UserID,WL_Name,WL_PublicPassword,WL_Message,WL_DateTimeAdded)
		values (@WL_UserID,@WL_Name,@WL_PublicPassword,@WL_Message,@NowOffset)

		declare @NewWL_ID int
		set @NewWL_ID=SCOPE_IDENTITY() ;

		DECLARE @newBV_ID BIGINT;


	DECLARE @BV_ID INT
	DECLARE @BV_VersionID INT
	DECLARE @BV_Quantity real
	DECLARE @BV_CustomText nvarchar(2000)

	DECLARE Basket_cursor CURSOR FOR 
	SELECT BV_ID,BV_VersionID,BV_Quantity,BV_CustomText FROM tblKartrisBasketValues WHERE BV_ParentID=@BasketID AND BV_ParentType=''b'';

	OPEN Basket_cursor
	FETCH NEXT FROM Basket_cursor INTO @BV_ID,@BV_VersionID,@BV_Quantity,@BV_CustomText
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- wishlish
		insert into tblKartrisBasketValues (BV_ParentType,BV_ParentID,BV_VersionID,BV_Quantity,BV_CustomText,BV_DateTimeAdded)
		VALUES (''w'',@NewWL_ID,@BV_VersionID,@BV_Quantity,@BV_CustomText,@NowOffset)
	
		SET @newBV_ID=SCOPE_IDENTITY() 

		IF EXISTS (SELECT * FROM tblKartrisBasketOptionValues WHERE BSKTOPT_BasketValueID=@BV_ID) 
		BEGIN
			INSERT INTO tblKartrisBasketOptionValues
			SELECT @newBV_ID,BSKTOPT_OptionID FROM tblKartrisBasketOptionValues WHERE BSKTOPT_BasketValueID=@BV_ID
		END

		-- wishlist remaining
		INSERT INTO tblKartrisBasketValues(BV_ParentType,BV_ParentID,BV_VersionID,BV_Quantity,BV_CustomText,BV_DateTimeAdded)
		VALUES (''r'',@NewWL_ID,@BV_VersionID,@BV_Quantity,@BV_CustomText,@NowOffset)

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

	End

	-- update wishlist
	Else
	Begin
		Update 	tblKartrisWishLists
		set WL_Name=@WL_Name, WL_PublicPassword=@WL_PublicPassword, WL_Message=@WL_Message, WL_LastUpdated=@NowOffset
		where WL_ID=@WL_ID	
	End;

Enable Trigger trigKartrisWishLists_DML ON tblKartrisWishLists;
--Enable Trigger trigKartrisBasketOptionValues_DML ON tblKartrisBasketOptionValues;	
--Enable Trigger trigKartrisBasketValues_DML ON tblKartrisBasketValues;	

END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetQBTaxRefCode]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisVersions_GetQBTaxRefCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisVersions_GetQBTaxRefCode]
(
	@V_CodeNumber nvarchar(50)
)
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

	SELECT     tblKartrisTaxRates.T_QBRefCode
FROM         tblKartrisVersions INNER JOIN
					  tblKartrisTaxRates ON tblKartrisVersions.V_Tax = tblKartrisTaxRates.T_ID
WHERE     (tblKartrisVersions.V_CodeNumber = @V_CodeNumber)






' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetProductID_s]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisVersions_GetProductID_s]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Get the total no. of Products in Category "used for ItemPager"
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisVersions_GetProductID_s]
			(
			@V_ID as bigint,
			@Return_Value as int OUTPUT
			)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT     @Return_Value = V_ProductID
FROM         tblKartrisVersions
WHERE     (V_ID = @V_ID)
	-- Insert statements for procedure here

	
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetOptionValues]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisVersions_GetOptionValues]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	replaces [spKartris_VER_GetVersionOptionValues]
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisVersions_GetOptionValues](@P_ID as int, @OPT_OptionGroupID as tinyint, @LANG_ID as tinyint)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT		vKartrisTypeOptions.OPT_ID, vKartrisTypeOptions.OPT_Name, vKartrisTypeOptions.OPT_CheckBoxValue, 
				tblKartrisProductOptionLink.P_OPT_PriceChange, tblKartrisProductOptionLink.P_OPT_Selected
	FROM         vKartrisTypeOptions INNER JOIN tblKartrisProductOptionLink 
				ON vKartrisTypeOptions.OPT_ID = tblKartrisProductOptionLink.P_OPT_OptionID
	WHERE      (vKartrisTypeOptions.LANG_ID = @LANG_ID) 
				AND (vKartrisTypeOptions.OPT_OptionGroupID = @OPT_OptionGroupID) 
				AND (tblKartrisProductOptionLink.P_OPT_ProductID = @P_ID)
	ORDER BY    tblKartrisProductOptionLink.P_OPT_OrderByValue
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisStatistics_GetProductStatsDetailsByDate]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisStatistics_GetProductStatsDetailsByDate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisStatistics_GetProductStatsDetailsByDate]
(
	@ProductID as int,
	@Month as int,
	@Year as int,
	@LANG_ID as tinyint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     COUNT(ST_ID) AS NoOfHits, 
	ST_ItemParentID AS CategoryID, dbo.fnKartrisLanguageElement_GetItemValue(@LANG_ID, 3, 1, ST_ItemParentID) AS CategoryName
	FROM         tblKartrisStatistics
	WHERE     (ST_Type = ''P'') AND (ST_ItemID = @ProductID) AND
				(MONTH(ST_Date) = @Month) AND (YEAR(ST_Date) = @Year)
	GROUP BY ST_ItemID, ST_ItemParentID
	ORDER BY NoOfHits DESC

END





' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisStatistics_GetProductStatsByDate]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisStatistics_GetProductStatsByDate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisStatistics_GetProductStatsByDate]
(
	@Month as int,
	@Year as int,
	@LANG_ID as tinyint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     COUNT(ST_ID) AS NoOfHits, ST_ItemID AS ProductID,	
			dbo.fnKartrisLanguageElement_GetItemValue(@LANG_ID, 2, 1, ST_ItemID) AS ProductName
	FROM         tblKartrisStatistics
	WHERE     (ST_Type = ''P'') AND (MONTH(ST_Date) = @Month) AND (YEAR(ST_Date) = @Year)
	GROUP BY ST_ItemID
	ORDER BY NoOfHits DESC
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisStatistics_GetCategoryStatsByDate]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisStatistics_GetCategoryStatsByDate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisStatistics_GetCategoryStatsByDate]
(
	@Month as int,
	@Year as int,
	@LANG_ID as tinyint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     COUNT(ST_ID) AS NoOfHits, ST_ItemID AS CategoryID,	
			dbo.fnKartrisLanguageElement_GetItemValue(@LANG_ID, 3, 1, ST_ItemID) AS CategoryName
	FROM         tblKartrisStatistics
	WHERE     (ST_Type = ''C'') AND (MONTH(ST_Date) = @Month) AND (YEAR(ST_Date) = @Year)
	GROUP BY ST_ItemID
	ORDER BY NoOfHits DESC
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingMethods_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingMethods_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get Shipping Methods - by Destination and Boundary
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisShippingMethods_Get]
(
	@LANG_ID as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT *
	FROM dbo.vKartrisTypeShippingMethods

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisShippingZones_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisShippingZones_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisShippingZones_Get]
(
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT        SZ_ID, LANG_ID, SZ_Name, SZ_Live, SZ_OrderByValue
FROM            vKartrisTypeShippingZones
WHERE        (LANG_ID = @LANG_ID)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_SearchVersionsByCode]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_SearchVersionsByCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_SearchVersionsByCode]
(
	@Key as nvarchar(50)
)
AS
	SET NOCOUNT ON;
SELECT        V_ID, V_CodeNumber
FROM            dbo.tblKartrisVersions
WHERE        V_Type <> ''s'' AND V_CodeNumber LIKE ''%'' + @Key + ''%''

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_MarkupPrices]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_MarkupPrices]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: 26th, June 2011
-- Description:	Mark up/down versions'' prices
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_MarkupPrices]
(
	@List as nvarchar(max),
	@Target as nvarchar(5)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DISABLE TRIGGER trigKartrisVersions_DML ON dbo.tblKartrisVersions;
	DISABLE	TRIGGER trigKartrisQuantityDiscounts_DML ON dbo.tblKartrisQuantityDiscounts;
	DECLARE @Pos int, @Pos2 int, @Pos3 int, @Item nvarchar(max), @ID nvarchar(50),@QTY nvarchar(10), @Price nvarchar(50)
	SET @List = LTRIM(RTRIM(@List))+ '';''    
	SET @Pos = CHARINDEX('';'', @List, 1)    
	IF REPLACE(@List, '';'', '''') <> '''' BEGIN        
		WHILE @Pos > 0 BEGIN 
			SET @Item = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))                
			IF @Item <> '''' BEGIN
				SET @Pos2 = CHARINDEX(''#'', @Item, 1)
				IF @Pos2 > 0 BEGIN
					SET @ID = LTRIM(RTRIM(LEFT(@Item, @Pos2 - 1)))
					SET @Price = REPLACE(@Item, @ID + ''#'', '''')
					--PRINT ''ID:'' + @ID + ''    Price:'' + @Price;					
					IF LOWER(@Target) = ''price'' BEGIN
						UPDATE dbo.tblKartrisVersions
						SET V_Price = CAST(@Price as real)
						WHERE V_ID = CAST(@ID as bigint);
					END
					IF LOWER(@Target) = ''rrp'' BEGIN
						UPDATE dbo.tblKartrisVersions
						SET V_RRP = CAST(@Price as real)
						WHERE V_ID = CAST(@ID as bigint);
					END
					IF LOWER(@Target) = ''qd'' BEGIN
						SET @Pos3 = CHARINDEX('','', @ID, 1)
						SET @QTY = LTRIM(RTRIM(SUBSTRING(@ID,@Pos3+1,10)))
						print @QTY
						SET @ID = LTRIM(RTRIM(REPLACE(@ID, '','' + @QTY,'''')))
						print @ID
						UPDATE dbo.tblKartrisQuantityDiscounts
						SET QD_Price = CAST(@Price as real)
						WHERE QD_VersionID = CAST(@ID as bigint) AND QD_Quantity= CAST(@QTY as real);
					END
				END
			END                
			SET @List = RIGHT(@List, LEN(@List) - @Pos)                
			SET @Pos = CHARINDEX('';'', @List, 1)        
		END    
	END;
	ENABLE TRIGGER trigKartrisVersions_DML ON dbo.tblKartrisVersions;
	ENABLE TRIGGER trigKartrisQuantityDiscounts_DML ON dbo.tblKartrisQuantityDiscounts;
	
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetTotalByProductID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_GetTotalByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	replaces [spKartris_VER_SelectByP_ID]
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_GetTotalByProductID](@P_ID as int)
AS
BEGIN

	SELECT Count(V_ID) AS TotalVersions
	FROM dbo.tblKartrisVersions
	WHERE V_ProductID = @P_ID;
				
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetSingleVersionByProductID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_GetSingleVersionByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_GetSingleVersionByProductID](@ProductID as bigint)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT     V_ID, V_CodeNumber, V_ProductID, V_Price, V_Tax, V_Weight, V_Quantity, V_QuantityWarnLevel, V_RRP, V_Type
	FROM         tblKartrisVersions
	WHERE     (V_ProductID = @ProductID) AND (V_Type = ''v'');
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetRowsByProductID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_GetRowsByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_GetRowsByProductID](@P_ID as int)
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SELECT     V_ID, V_CodeNumber, V_ProductID, V_Price, V_Tax, V_Weight, V_DeliveryTime, V_Quantity, V_QuantityWarnLevel, V_Live, V_DownLoadInfo, V_DownloadType, 
					  V_OrderByValue, V_RRP, V_Type, V_CustomerGroupID, V_CustomizationType, V_CustomizationDesc, V_CustomizationCost
	FROM         tblKartrisVersions
	WHERE     (tblKartrisVersions.V_ProductID = @P_ID) 
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetCombinationByProductID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_GetCombinationByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_GetCombinationByProductID](@P_ID as int)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT		tblKartrisVersions.V_ProductID, tblKartrisVersions.V_ID, tblKartrisLanguageElements.LE_Value AS V_Name, 
				tblKartrisVersions.V_CodeNumber, tblKartrisVersions.V_Price, tblKartrisVersions.V_Tax, 
				tblKartrisVersions.V_Weight, tblKartrisVersions.V_Quantity, tblKartrisVersions.V_QuantityWarnLevel, 
				tblKartrisVersions.V_Type, tblKartrisVersions.V_Live
	FROM		tblKartrisVersions INNER JOIN tblKartrisLanguageElements 
				ON tblKartrisVersions.V_ID = tblKartrisLanguageElements.LE_ParentID
	WHERE     (tblKartrisVersions.V_ProductID = @P_ID) 
				AND (tblKartrisLanguageElements.LE_Value IS NOT NULL) 
				AND (tblKartrisLanguageElements.LE_TypeID = 1) 
				AND (tblKartrisLanguageElements.LE_FieldID = 1) 
				AND (tblKartrisLanguageElements.LE_LanguageID = 1)
				AND (tblKartrisVersions.V_Type = ''c'')
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetByID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_GetByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_GetByID](@V_ID as bigint)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT * FROM tblKartrisVersions WHERE V_ID = @V_ID;
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetByCodeNumber]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_GetByCodeNumber]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Checking if the code number is already in use.
-- Back/Front : Back-End
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_GetByCodeNumber]
(
	@V_CodeNumber as nvarchar(50),
	@Execluded_ProductID as int,
	@Excluded_V_ID as bigint
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT V_ID 
	FROM tblKartrisVersions 
	WHERE (V_ID <> @Excluded_V_ID) AND (V_ProductID <> @Execluded_ProductID) AND (V_CodeNumber = @V_CodeNumber);
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisUsers_DeleteOrders]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisUsers_DeleteOrders]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Deletes an Order
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisUsers_DeleteOrders]
(
	@U_ID as int,
	@O_DeleteReturnStock bit
)
AS
BEGIN
	SET NOCOUNT ON;
	
IF (@O_DeleteReturnStock = 1) 
	BEGIN
		Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;
					DECLARE @O_Sent bit
					DECLARE @V_Codenumber nvarchar(25)
					DECLARE @IR_Quantity int
					DECLARE tnames_cursor CURSOR
				FOR
			-- check if return stock flag is on
				SELECT   tblKartrisOrders.O_Sent ,tblKartrisInvoiceRows.IR_VersionCode, tblKartrisInvoiceRows.IR_Quantity
				FROM         tblKartrisOrders INNER JOIN
									  tblKartrisInvoiceRows ON tblKartrisOrders.O_ID = tblKartrisInvoiceRows.IR_OrderNumberID
				WHERE     (tblKartrisOrders.O_CustomerID = @U_ID)

				
				OPEN tnames_cursor
				--loop through the invoicerows records and return the stocks back to individual versions
				FETCH NEXT FROM tnames_cursor INTO @O_Sent, @V_Codenumber,@IR_Quantity
				WHILE (@@FETCH_STATUS <> -1)
				BEGIN
					IF (@@FETCH_STATUS <> -2)
					BEGIN 
						IF (@O_Sent = 1)
						BEGIN
							UPDATE tblKartrisVersions SET V_Quantity= V_Quantity + @IR_Quantity WHERE V_CodeNumber=@V_Codenumber AND V_QuantityWarnLevel<>0;
						END
					END
					FETCH NEXT FROM tnames_cursor INTO @O_Sent, @V_Codenumber,@IR_Quantity
				END
				CLOSE tnames_cursor
				DEALLOCATE tnames_cursor ;
		Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;
	END;

	
Disable Trigger trigKartrisInvoiceRows_DML ON tblKartrisInvoiceRows;
		--delete the order invoicerows
DELETE FROM tblKartrisInvoiceRows
FROM         tblKartrisInvoiceRows LEFT OUTER JOIN
					  tblKartrisOrders ON tblKartrisInvoiceRows.IR_OrderNumberID = tblKartrisOrders.O_ID
WHERE     (tblKartrisOrders.O_CustomerID = @U_ID);

Enable Trigger trigKartrisInvoiceRows_DML ON tblKartrisInvoiceRows;

Disable Trigger trigKartrisOrdersPromotions_DML ON tblKartrisOrdersPromotions;
		--delete the order promotion records
		DELETE FROM tblKartrisOrdersPromotions
FROM         tblKartrisOrdersPromotions INNER JOIN
					  tblKartrisOrders ON tblKartrisOrdersPromotions.OrderID = tblKartrisOrders.O_ID
WHERE     (tblKartrisOrders.O_CustomerID = @U_ID);
Enable Trigger trigKartrisOrdersPromotions_DML ON tblKartrisOrdersPromotions;
	
Disable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	
		--delete the main order record
		DELETE  FROM dbo.tblKartrisOrders
		WHERE O_CustomerID = @U_ID;
Enable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	
	
END





' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_ChangeSortValue]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_ChangeSortValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisVersions_ChangeSortValue]
(
	@VersionID as bigint,
	@ProductID as int,
	@Direction as char
)
AS
BEGIN
	SET NOCOUNT OFF;
	
	
	DECLARE @VersionOrder as int;
	SELECT @VersionOrder = V_OrderByValue
	FROM  dbo.tblKartrisVersions
	WHERE V_ProductID = @ProductID AND V_ID = @VersionID;

	
	DECLARE @SwitchVersionID as bigint, @SwitchOrder as int;
	IF @Direction = ''u''
	BEGIN
		SELECT @SwitchOrder = MAX(V_OrderByValue) 
		FROM  dbo.tblKartrisVersions
		WHERE V_ProductID = @ProductID AND V_OrderByValue < @VersionOrder;

		SELECT TOP(1) @SwitchVersionID = V_ID
		FROM  dbo.tblKartrisVersions
		WHERE V_ProductID = @ProductID AND V_OrderByValue = @SwitchOrder;		
	END
	ELSE
	BEGIN
		SELECT @SwitchOrder = MIN(V_OrderByValue) 
		FROM dbo.tblKartrisVersions
		WHERE V_ProductID = @ProductID AND V_OrderByValue > @VersionOrder;

		SELECT TOP(1) @SwitchVersionID = V_ID
		FROM dbo.tblKartrisVersions
		WHERE V_ProductID = @ProductID AND V_OrderByValue = @SwitchOrder;
	END;

Disable Trigger trigKartrisVersions_DML ON dbo.tblKartrisVersions
	UPDATE dbo.tblKartrisVersions
	SET V_OrderByValue = @SwitchOrder
	WHERE V_ProductID = @ProductID AND V_ID = @VersionID; 

	UPDATE dbo.tblKartrisVersions
	SET V_OrderByValue = @VersionOrder
	WHERE V_ProductID = @ProductID AND V_ID = @SwitchVersionID;
Enable Trigger trigKartrisVersions_DML ON dbo.tblKartrisVersions
		
END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_AddAsSingle]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_AddAsSingle]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_AddAsSingle]
(
	@V_CodeNumber as nvarchar(25),
	@V_ProductID as int,
	@V_CustomerGroupID as smallint,
	@V_NewID as bigint OUT
)
								
AS
BEGIN
	
	SET NOCOUNT ON;

Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	INSERT INTO tblKartrisVersions
	VALUES (@V_CodeNumber, @V_ProductID, NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, 10, 0, ''v'', @V_CustomerGroupID, ''n'', NULL, 0, NULL, NULL);
			
	SELECT @V_NewID = SCOPE_IDENTITY();
Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_AddAsCombination]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_AddAsCombination]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_AddAsCombination]
(
	@V_CodeNumber as nvarchar(25),
	@V_ProductID as int,
	@V_Price as real,
	@V_Tax as tinyint,
	@V_Tax2 as tinyint,
	@V_TaxExtra as nvarchar(50),
	@V_Weight as real,
	@V_Quantity as real,
	@V_QuantityWarnLevel as real,
	@V_RRP as real,
	@V_Type as char(1),
	@V_NewID as bigint OUT
)
								
AS
BEGIN
	
	SET NOCOUNT ON;

Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	INSERT INTO tblKartrisVersions
	VALUES (@V_CodeNumber, @V_ProductID, @V_Price, @V_Tax, @V_Weight, 0, @V_Quantity, @V_QuantityWarnLevel, 
			1, NULL, NULL, 20, @V_RRP, @V_Type, NULL, ''n'', NULL, 0, @V_Tax2, @V_TaxExtra);
			
	SELECT @V_NewID = SCOPE_IDENTITY();
Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_Add]
(
	@V_CodeNumber as nvarchar(25),
	@V_ProductID as int,
	@V_Price as real,
	@V_Tax as tinyint,
	@V_Tax2 as tinyint,
	@V_TaxExtra as nvarchar(255),
	@V_Weight as real,
	@V_DeliveryTime as tinyint,
	@V_Quantity as real,
	@V_QuantityWarnLevel as real,
	@V_Live as bit,
	@V_DownLoadInfo as nvarchar(255),
	@V_DownloadType as nvarchar(50),
	@V_RRP as real,
	@V_Type as char(1),
	@V_CustomerGroupID as smallint,
	@V_CustomizationType as char(1),
	@V_CustomizationDesc as nvarchar(255),
	@V_CustomizationCost as real,
	@V_NewID as bigint OUT
)
								
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @MaxOrder as int;
	SELECT @MaxOrder = Max(V_OrderByValue) FROM dbo.tblKartrisVersions WHERE V_ProductID = @V_ProductID;
	IF @MaxOrder is NULL BEGIN SET @MaxOrder = 0 END;

Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	INSERT INTO tblKartrisVersions
	VALUES (@V_CodeNumber, @V_ProductID, @V_Price, @V_Tax, @V_Weight, @V_DeliveryTime, @V_Quantity, @V_QuantityWarnLevel, 
			@V_Live, @V_DownLoadInfo, @V_DownloadType, @MaxOrder + 1, @V_RRP, @V_Type, @V_CustomerGroupID, @V_CustomizationType,
			@V_CustomizationDesc, @V_CustomizationCost, @V_Tax2, @V_TaxExtra);
			
	SELECT @V_NewID = SCOPE_IDENTITY();
Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetBasicVersionByProductID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_GetBasicVersionByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_GetBasicVersionByProductID](@ProductID as bigint)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT     V_ID, V_CodeNumber, V_ProductID, V_Price, V_Tax, V_Weight, V_Quantity, V_QuantityWarnLevel, V_RRP, V_Type
FROM         tblKartrisVersions
WHERE     (V_ProductID = @ProductID) AND ((V_Type = ''b'') OR (V_Type = ''o''));
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_SearchProductsByName]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_SearchProductsByName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_SearchProductsByName]
(
	@Key as nvarchar(50),
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT        P_ID, P_Name
FROM            vKartrisTypeProducts
WHERE        (LANG_ID = @LANG_ID) AND P_Name LIKE @Key + ''%''

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_GetTotalByCatID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_GetTotalByCatID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Get the total no. of Products in Category "used for ItemPager"
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_GetTotalByCatID]
			(
			@LANG_ID as tinyint,
			@CAT_ID as int,
			@Return_Value as int OUTPUT
			)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     @Return_Value = COUNT(vKartrisTypeProducts.P_ID)
	FROM         vKartrisTypeProducts INNER JOIN
					  tblKartrisProductCategoryLink ON vKartrisTypeProducts.P_ID = tblKartrisProductCategoryLink.PCAT_ProductID
	WHERE     (vKartrisTypeProducts.LANG_ID = @LANG_ID) 
				AND (tblKartrisProductCategoryLink.PCAT_CategoryID = @CAT_ID);
	-- Insert statements for procedure here

	
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_GetStatus]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_GetStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ===================================================
-- Author:		Mohammad
-- Create date: 
-- Description:	
-- ===================================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_GetStatus]
(
	@P_ID int,
	@ProductLive as bit OUT,
	@ProductType as nvarchar(1) OUT,
	@NoOfLiveVersions as int OUT,
	@NoOfLiveCategories as int OUT,
	@ProductCustomerGroup as smallint OUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Check if the product is live, Type, CustomerGroup
	SELECT @ProductLive = P_Live, @ProductType = P_Type, @ProductCustomerGroup = P_CustomerGroupID
	FROM   tblKartrisProducts
	WHERE  (P_ID = @P_ID);

	-- No Of Live Versions
	IF @ProductType = ''o''
	BEGIN
		-- Get no. of live base/combinations
		SELECT @NoOfLiveVersions = Count(1)
		FROM dbo.tblKartrisVersions
		WHERE V_ProductID = @P_ID AND V_Type = ''b'' AND V_Live = 1;
	END
	ELSE
	BEGIN
		SELECT @NoOfLiveVersions = Count(1)
		FROM dbo.tblKartrisVersions
		WHERE V_ProductID = @P_ID AND V_Type = ''v'' AND V_Live = 1;
	END

	-- No of live categories
	SELECT     @NoOfLiveCategories = Count(tblKartrisCategories.CAT_ID)
	FROM         tblKartrisCategories INNER JOIN tblKartrisProductCategoryLink 
		ON tblKartrisCategories.CAT_ID = tblKartrisProductCategoryLink.PCAT_CategoryID
	WHERE PCAT_ProductID = @P_ID AND CAT_Live = 1
		

	

	
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_GetRowsBetweenByCatID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_GetRowsBetweenByCatID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_GetRowsBetweenByCatID]
(
	@LANG_ID as tinyint,
	@CAT_ID as int,
	@PageIndex as tinyint, -- 0 Based index
	@RowsPerPage as smallint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	-- Insert statements for procedure here

	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;
	
	DECLARE @OrderBy as nvarchar(50), @OrderDirection as char(1)
	SELECT @OrderBy = CAT_OrderProductsBy, @OrderDirection = CAT_ProductsSortDirection
	FROM dbo.tblKartrisCategories
	WHERE CAT_ID = @CAT_ID;

	IF @OrderBy is NULL OR @OrderBy = ''d''
	BEGIN 
		SELECT @OrderBy = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = ''frontend.products.display.sortdefault'';
	END;
	IF @OrderDirection is NULL OR @OrderDirection = '''' BEGIN 
		SELECT @OrderDirection = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = ''frontend.products.display.sortdirection'';
	END;

	DECLARE @SortByValue as bit;
	SET @SortByValue = 0;
	IF @OrderBy = ''PCAT_OrderNo'' BEGIN SET @SortByValue = 1 END;

	With ProductList AS 
	(
		SELECT	CASE 
				WHEN (@OrderBy = ''P_ID'' AND @OrderDirection = ''A'') THEN	ROW_NUMBER() OVER (ORDER BY P_ID ASC) 
				WHEN (@OrderBy = ''P_ID'' AND @OrderDirection = ''D'') THEN	ROW_NUMBER() OVER (ORDER BY P_ID DESC) 
				WHEN (@OrderBy = ''P_Name'' AND @OrderDirection = ''A'') THEN ROW_NUMBER() OVER (ORDER BY P_Name ASC) 
				WHEN (@OrderBy = ''P_Name'' AND @OrderDirection = ''D'') THEN ROW_NUMBER() OVER (ORDER BY P_Name DESC) 
				WHEN (@OrderBy = ''P_DateCreated'' AND @OrderDirection = ''A'') THEN ROW_NUMBER() OVER (ORDER BY P_DateCreated ASC) 
				WHEN (@OrderBy = ''P_DateCreated'' AND @OrderDirection = ''D'') THEN ROW_NUMBER() OVER (ORDER BY P_DateCreated DESC) 
				WHEN (@OrderBy = ''P_LastModified'' AND @OrderDirection = ''A'') THEN ROW_NUMBER() OVER (ORDER BY P_LastModified ASC) 
				WHEN (@OrderBy = ''P_LastModified'' AND @OrderDirection = ''D'') THEN ROW_NUMBER() OVER (ORDER BY P_LastModified DESC) 
				WHEN (@OrderBy = ''PCAT_OrderNo'' AND @OrderDirection = ''A'') THEN ROW_NUMBER() OVER (ORDER BY PCAT_OrderNo ASC) 
				WHEN (@OrderBy = ''PCAT_OrderNo'' AND @OrderDirection = ''D'') THEN ROW_NUMBER() OVER (ORDER BY PCAT_OrderNo DESC) 
				END AS Row,
				vKartrisTypeProducts.P_ID, vKartrisTypeProducts.P_Name, dbo.fnKartrisDB_TruncateDescription(vKartrisTypeProducts.P_Desc) AS P_Desc, vKartrisTypeProducts.P_StrapLine,
				vKartrisTypeProducts.P_VersionDisplayType, vKartrisTypeProducts.P_DateCreated, vKartrisTypeProducts.P_LastModified, 
				tblKartrisProductCategoryLink.PCAT_OrderNo, vKartrisTypeProducts.P_Type, @SortByValue AS SortByValue, vKartrisTypeProducts.P_Live
		FROM    tblKartrisProductCategoryLink INNER JOIN
				vKartrisTypeProducts ON tblKartrisProductCategoryLink.PCAT_ProductID = vKartrisTypeProducts.P_ID 
		WHERE   (vKartrisTypeProducts.LANG_ID = @LANG_ID) AND (tblKartrisProductCategoryLink.PCAT_CategoryID = @CAT_ID)
		GROUP BY vKartrisTypeProducts.P_Name, vKartrisTypeProducts.P_Desc, vKartrisTypeProducts.P_StrapLine, vKartrisTypeProducts.P_ID,
					vKartrisTypeProducts.P_VersionDisplayType, vKartrisTypeProducts.P_DateCreated, vKartrisTypeProducts.P_LastModified, 
				tblKartrisProductCategoryLink.PCAT_OrderNo, vKartrisTypeProducts.P_Type, vKartrisTypeProducts.P_Live
		
	)

	SELECT *
	FROM ProductList
	WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber
	ORDER BY Row ASC
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_GetFeaturedProducts]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_GetFeaturedProducts]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammd
-- =============================================

CREATE PROCEDURE [dbo].[_spKartrisProducts_GetFeaturedProducts]
(
	@LANG_ID as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;


	SELECT     P_ID As ProductID, P_Name as ProductName, P_Featured as ProductPriority
	FROM         dbo.vKartrisTypeProducts
	WHERE     (P_Featured <> 0) AND (LANG_ID = @LANG_ID)
	ORDER BY P_Featured DESC

END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_GetBySupplier]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_GetBySupplier]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ===================================================
-- Author:		Medz
-- Create date: 02/12/2008 13:53:30
-- Description:	Replaces the [spKartris_PROD_Select]
-- ===================================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_GetBySupplier]
(
	@LANG_ID tinyint,
	@SupplierID as smallint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT P_ID, P_Name
	FROM   vKartrisTypeProducts
	WHERE  (LANG_ID = @LANG_ID) AND (P_SupplierID = @SupplierID)
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_Get]
(
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT        vKartrisTypeProducts.P_ID, vKartrisTypeProducts.P_Name
FROM            vKartrisTypeProducts
WHERE        (LANG_ID = @LANG_ID)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProductOptionLink_GetByProductIDGroupID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProductOptionLink_GetByProductIDGroupID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisProductOptionLink_GetByProductIDGroupID]
(
	@ProductID int,
	@GroupID as int,
	@LANGID as tinyint
)
AS
	SET NOCOUNT ON;
SELECT		tblKartrisProductOptionLink.P_OPT_OptionID as OPT_ID, vKartrisTypeOptions.OPT_Name, 
			vKartrisTypeOptions.LANG_ID, CAST(tblKartrisProductOptionLink.P_OPT_OptionID as nvarchar) as ID_List
FROM        tblKartrisProductOptionLink INNER JOIN vKartrisTypeOptions 
			ON tblKartrisProductOptionLink.P_OPT_OptionID = vKartrisTypeOptions.OPT_ID
WHERE		(tblKartrisProductOptionLink.P_OPT_ProductID = @ProductID) 
			AND (vKartrisTypeOptions.OPT_OptionGroupID = @GroupID)
			AND (vKartrisTypeOptions.LANG_ID = @LANGID)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProductOptionLink_GetByProductID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProductOptionLink_GetByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisProductOptionLink_GetByProductID]
(
	@ProductID int
)
AS
	SET NOCOUNT ON;
SELECT        P_OPT_OptionID, P_OPT_ProductID, P_OPT_OrderByValue, P_OPT_PriceChange, P_OPT_WeightChange, P_OPT_Selected
FROM            tblKartrisProductOptionLink
WHERE        (P_OPT_ProductID = @ProductID)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProductOptionLink_DeleteByProductID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProductOptionLink_DeleteByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisProductOptionLink_DeleteByProductID]
(
	@ProductID int
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisProductOptionLink_DML ON tblKartrisProductOptionLink;	
	DELETE FROM [tblKartrisProductOptionLink] 
	WHERE ([P_OPT_ProductID] = @ProductID);
Enable Trigger trigKartrisProductOptionLink_DML ON tblKartrisProductOptionLink;	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProductOptionLink_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProductOptionLink_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisProductOptionLink_Add]
(
	@OptionID as int,
	@ProductID int,
	@OrderBy as tinyint,
	@PriceChange as real,
	@WeightChange as real,
	@Selected as bit
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisProductOptionLink_DML ON tblKartrisProductOptionLink;	
	INSERT INTO [tblKartrisProductOptionLink] 
	VALUES (@OptionID, @ProductID, @OrderBy, @PriceChange, @WeightChange, @Selected);
Enable Trigger trigKartrisProductOptionLink_DML ON tblKartrisProductOptionLink;	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProductOptionGroupLink_GetByProductID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProductOptionGroupLink_GetByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisProductOptionGroupLink_GetByProductID]
(
	@ProductID int
)
AS
	SET NOCOUNT ON;
SELECT        P_OPTG_ProductID, P_OPTG_OptionGroupID, P_OPTG_OrderByValue, P_OPTG_MustSelected
FROM            tblKartrisProductOptionGroupLink
WHERE        (P_OPTG_ProductID = @ProductID)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProductOptionGroupLink_DeleteByProductID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProductOptionGroupLink_DeleteByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisProductOptionGroupLink_DeleteByProductID]
(
	@ProductID int
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisProductOptionGroupLink_DML ON tblKartrisProductOptionGroupLink;
	DELETE FROM [tblKartrisProductOptionGroupLink] 
	WHERE ([P_OPTG_ProductID] = @ProductID);
Enable Trigger trigKartrisProductOptionGroupLink_DML ON tblKartrisProductOptionGroupLink;	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProductOptionGroupLink_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProductOptionGroupLink_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisProductOptionGroupLink_Add]
(
	@ProductID int,
	@GroupID as smallint,
	@OrderBy as tinyint,
	@MustSelect as bit
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisProductOptionGroupLink_DML ON tblKartrisProductOptionGroupLink;	
	INSERT INTO [tblKartrisProductOptionGroupLink] 
	VALUES (@ProductID, @GroupID, @OrderBy, @MustSelect);
Enable Trigger trigKartrisProductOptionGroupLink_DML ON tblKartrisProductOptionGroupLink;	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProductCategoryLink_DeleteByProduct]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProductCategoryLink_DeleteByProduct]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisProductCategoryLink_DeleteByProduct]
(
	@ProductID int
)
AS
BEGIN
	SET NOCOUNT OFF;
Disable Trigger trigKartrisProductCategoryLink_DML ON tblKartrisProductCategoryLink;	
	DELETE FROM [tblKartrisProductCategoryLink] 
	WHERE [PCAT_ProductID] = @ProductID;
Enable Trigger trigKartrisProductCategoryLink_DML ON tblKartrisProductCategoryLink;	
END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProductCategoryLink_ChangeSortValue]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProductCategoryLink_ChangeSortValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisProductCategoryLink_ChangeSortValue]
(
	@ProductID as int,
	@CatID as int,
	@Direction as char
)
AS
BEGIN
	SET NOCOUNT OFF;
	
Disable Trigger trigKartrisProductCategoryLink_DML ON dbo.tblKartrisProductCategoryLink;
		
	DECLARE @ProductOrder as int;
	SELECT @ProductOrder = PCAT_OrderNo
	FROM  dbo.tblKartrisProductCategoryLink
	WHERE PCAT_ProductID = @ProductID AND PCAT_CategoryID = @CatID;

	-- *********************************************************
	-- Need to check if there are siblings with same sort order
	--  if yes, we need to reset those values
	DECLARE @DuplicateOrders as int;
	SELECT @DuplicateOrders = COUNT(1)
	FROM dbo.tblKartrisProductCategoryLink
	WHERE PCAT_OrderNo = @ProductOrder AND PCAT_CategoryID = @CatID;
	
	IF (SELECT COUNT(1)	FROM dbo.tblKartrisProductCategoryLink WHERE PCAT_OrderNo = @ProductOrder AND PCAT_CategoryID = @CatID) > 1 BEGIN
		DECLARE @MaxNo as int;
		SELECT @MaxNo = MAX(PCAT_OrderNo) 
		FROM dbo.tblKartrisProductCategoryLink 
		WHERE PCAT_CategoryID = @CatID AND PCAT_ProductID <> @ProductID;
		
		WHILE (SELECT COUNT(1)	FROM dbo.tblKartrisProductCategoryLink WHERE PCAT_OrderNo = @ProductOrder AND PCAT_CategoryID = @CatID) > 1
		BEGIN
			UPDATE TOP(1) dbo.tblKartrisProductCategoryLink
			SET PCAT_OrderNo = @MaxNo + 1
			WHERE PCAT_CategoryID = @CatID AND PCAT_OrderNo = @ProductOrder AND PCAT_ProductID <> @ProductID;
			SET @MaxNo = @MaxNo + 1;
		END
	END
	-- *********************************************************

	DECLARE @SwitchProductID as int, @SwitchOrder as int;
	IF @Direction = ''u''
	BEGIN
		SELECT @SwitchOrder = MAX(PCAT_OrderNo) 
		FROM dbo.tblKartrisProductCategoryLink 
		WHERE PCAT_CategoryID = @CatID AND PCAT_OrderNo < @ProductOrder;

		SELECT TOP(1) @SwitchProductID = PCAT_ProductID
		FROM  dbo.tblKartrisProductCategoryLink
		WHERE PCAT_CategoryID = @CatID AND PCAT_OrderNo = @SwitchOrder;		
	END
	ELSE
	BEGIN
		SELECT @SwitchOrder = MIN(PCAT_OrderNo) 
		FROM dbo.tblKartrisProductCategoryLink 
		WHERE PCAT_CategoryID = @CatID AND PCAT_OrderNo > @ProductOrder;

		SELECT TOP(1) @SwitchProductID = PCAT_ProductID
		FROM dbo.tblKartrisProductCategoryLink
		WHERE PCAT_CategoryID = @CatID AND PCAT_OrderNo = @SwitchOrder;
	END;

UPDATE dbo.tblKartrisProductCategoryLink
	SET PCAT_OrderNo = @SwitchOrder
	WHERE PCAT_CategoryID = @CatID AND PCAT_ProductID = @ProductID; 

	UPDATE dbo.tblKartrisProductCategoryLink
	SET PCAT_OrderNo = @ProductOrder
	WHERE PCAT_CategoryID = @CatID AND PCAT_ProductID = @SwitchProductID;
Enable Trigger trigKartrisProductCategoryLink_DML ON dbo.tblKartrisProductCategoryLink;
		
END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProductCategoryLink_AddParentList]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProductCategoryLink_AddParentList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisProductCategoryLink_AddParentList]
(
	@ProductID int,
	@ParentList as nvarchar(MAX)
)
AS
BEGIN
Disable Trigger trigKartrisProductCategoryLink_DML ON tblKartrisProductCategoryLink;		

	DELETE FROM dbo.tblKartrisProductCategoryLink	
	WHERE PCAT_ProductID = @ProductID 
		AND PCAT_CategoryID NOT IN (SELECT * FROM dbo.fnTbl_SplitNumbers(@ParentList));

	IF LEN(@ParentList) = 0	BEGIN RETURN END
	
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @ParentID as int;

	DECLARE @MaxOrder as int;

	DECLARE @Records as int;

	SET @SIndx = 0;
	WHILE @SIndx <= LEN(@ParentList)
	BEGIN
		SET @Records = 0;
		-- Loop through out the parent''s list
		SET @CIndx = CHARINDEX('','', @ParentList, @SIndx)	-- Next keyword starting index (1-Based Index)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@ParentList)+ 1 END	-- If no more keywords, set next starting index to not exist
		SET @ParentID = CAST(SUBSTRING(@ParentList, @SIndx, @CIndx - @SIndx) AS int)
		
		SELECT @Records = Count(1) 
		FROM dbo.tblKartrisProductCategoryLink
		WHERE PCAT_ProductID = @ProductID AND PCAT_CategoryID = @ParentID;

		IF @Records = 0
		BEGIN
			SELECT @MaxOrder = Max(PCAT_OrderNo) FROM dbo.tblKartrisProductCategoryLink WHERE PCAT_CategoryID = @ParentID;
			IF @MaxOrder is NULL BEGIN SET @MaxOrder = 0 END
			INSERT INTO [tblKartrisProductCategoryLink]
			VALUES (@ProductID, @ParentID, @MaxOrder + 1); 
		END
		
		SET @SIndx = @CIndx + 1;
	END;
Enable Trigger trigKartrisProductCategoryLink_DML ON tblKartrisProductCategoryLink;	
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOptions_GetByGroupID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOptions_GetByGroupID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisOptions_GetByGroupID]
(
	@LANG_ID tinyint,
	@OptionGroupID tinyint
)
AS
	SET NOCOUNT ON;
SELECT     vKartrisTypeOptions.OPT_ID, vKartrisTypeOptions.LANG_ID, vKartrisTypeOptions.OPT_Name, vKartrisTypeOptions.OPT_OptionGroupID, 
					  vKartrisTypeOptions.OPT_CheckBoxValue, vKartrisTypeOptions.OPT_DefPriceChange, vKartrisTypeOptions.OPT_DefWeightChange, 
					  vKartrisTypeOptions.OPT_DefOrderByValue, tblKartrisOptionGroups.OPTG_OptionDisplayType
FROM         vKartrisTypeOptions INNER JOIN
					  tblKartrisOptionGroups ON vKartrisTypeOptions.OPT_OptionGroupID = tblKartrisOptionGroups.OPTG_ID
WHERE     (vKartrisTypeOptions.LANG_ID = @LANG_ID) AND (vKartrisTypeOptions.OPT_OptionGroupID = @OptionGroupID)
ORDER BY vKartrisTypeOptions.OPT_Name

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisReviews_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisReviews_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[_spKartrisReviews_Update]
(
	@LanguageID tinyint,
	@CustomerID int,
	@Title nvarchar(60),
	@Text nvarchar(MAX),
	@Rating tinyint,
	@Name nvarchar(30),
	@Email nvarchar(75),
	@Location nvarchar(30),
	@Live char(1),
	@Original_ID smallint,
	@NowOffset as datetime
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisReviews_DML ON tblKartrisReviews;	
UPDATE [tblKartrisReviews] 
SET [REV_LanguageID] = @LanguageID, [REV_CustomerID] = @CustomerID, 
	[REV_Title] = @Title, [REV_Text] = @Text, [REV_Rating] = @Rating, 
	[REV_Name] = @Name, [REV_Email] = @Email, [REV_Location] = @Location, 
	[REV_DateLastUpdated] = @NowOffset, [REV_Live] = @Live 
WHERE (([REV_ID] = @Original_ID));
Enable Trigger trigKartrisReviews_DML ON tblKartrisReviews;	
	


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisReviews_GetByProductID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisReviews_GetByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisReviews_GetByProductID]
(
	@ProductID int,
	@LanguageID tinyint
)
AS
	SET NOCOUNT ON;
SELECT     tblKartrisReviews.REV_ID, tblKartrisReviews.REV_ProductID, tblKartrisReviews.REV_LanguageID, tblKartrisReviews.REV_CustomerID, tblKartrisReviews.REV_Title, 
					  tblKartrisReviews.REV_Text, tblKartrisReviews.REV_Rating, tblKartrisReviews.REV_Name, tblKartrisReviews.REV_Email, tblKartrisReviews.REV_Location, 
					  tblKartrisReviews.REV_DateCreated, tblKartrisReviews.REV_DateLastUpdated, tblKartrisReviews.REV_Live, vKartrisTypeProducts.P_Name
FROM         tblKartrisReviews INNER JOIN
					  vKartrisTypeProducts ON tblKartrisReviews.REV_ProductID = vKartrisTypeProducts.P_ID AND 
					  tblKartrisReviews.REV_LanguageID = vKartrisTypeProducts.LANG_ID
WHERE     (tblKartrisReviews.REV_ProductID = @ProductID) AND (tblKartrisReviews.REV_LanguageID = @LanguageID)
ORDER BY tblKartrisReviews.REV_DateLastUpdated DESC

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisReviews_GetByLanguage]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisReviews_GetByLanguage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisReviews_GetByLanguage]
(
	@LanguageID tinyint
)
AS
	SET NOCOUNT ON;
SELECT     tblKartrisReviews.REV_ID, tblKartrisReviews.REV_ProductID, tblKartrisReviews.REV_LanguageID, tblKartrisReviews.REV_CustomerID, tblKartrisReviews.REV_Title, 
					  tblKartrisReviews.REV_Text, tblKartrisReviews.REV_Rating, tblKartrisReviews.REV_Name, tblKartrisReviews.REV_Email, tblKartrisReviews.REV_Location, 
					  tblKartrisReviews.REV_DateCreated, tblKartrisReviews.REV_DateLastUpdated, tblKartrisReviews.REV_Live, vKartrisTypeProducts.P_Name
FROM         tblKartrisReviews INNER JOIN
					  vKartrisTypeProducts ON tblKartrisReviews.REV_ProductID = vKartrisTypeProducts.P_ID AND 
					  tblKartrisReviews.REV_LanguageID = vKartrisTypeProducts.LANG_ID
WHERE     (tblKartrisReviews.REV_LanguageID = @LanguageID)
ORDER BY tblKartrisReviews.REV_DateLastUpdated DESC

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisReviews_GetByID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisReviews_GetByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisReviews_GetByID]
(
	@ReviewID smallint
)
AS
	SET NOCOUNT ON;
SELECT     tblKartrisReviews.*
FROM         tblKartrisReviews 
WHERE     (tblKartrisReviews.REV_ID = @ReviewID) 

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisReviews_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisReviews_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisReviews_Get]
AS
	SET NOCOUNT ON;
SELECT     tblKartrisReviews.*
FROM         tblKartrisReviews

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisReviews_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisReviews_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisReviews_Delete]
(
	@Original_ID smallint
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisReviews_DML ON tblKartrisReviews;	
	DELETE FROM [tblKartrisReviews] WHERE (([REV_ID] = @Original_ID));
Enable Trigger trigKartrisReviews_DML ON tblKartrisReviews;	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisReviews_Add]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisReviews_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[_spKartrisReviews_Add]
(
	@ProductID int,
	@LanguageID tinyint,
	@CustomerID int,
	@Title nvarchar(60),
	@Text nvarchar(MAX),
	@Rating tinyint,
	@Name nvarchar(30),
	@Email nvarchar(75),
	@Location nvarchar(30),
	@Live CHAR(1),
	@NowOffset as datetime
)
AS
	SET NOCOUNT OFF;
Disable Trigger trigKartrisReviews_DML ON tblKartrisReviews;	
	INSERT INTO [tblKartrisReviews] 
	([REV_ProductID], [REV_LanguageID], [REV_CustomerID], [REV_Title], [REV_Text], [REV_Rating], [REV_Name], [REV_Email], [REV_Location], [REV_DateCreated], [REV_DateLastUpdated], [REV_Live]) 
	VALUES 
	(@ProductID, @LanguageID, @CustomerID, @Title, @Text, @Rating, @Name, @Email, @Location, @NowOffset, @NowOffset, @Live);
Enable Trigger trigKartrisReviews_DML ON tblKartrisReviews;		



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisRelatedProducts_GetByParentID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisRelatedProducts_GetByParentID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ========================================================
-- Author:		Mohammad
-- Create date: 
-- Description:	
-- ========================================================
CREATE PROCEDURE [dbo].[_spKartrisRelatedProducts_GetByParentID]
(
	@ParentID int
)
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT	tblKartrisRelatedProducts.RP_ParentID, tblKartrisRelatedProducts.RP_ChildID
	FROM    tblKartrisRelatedProducts 
	WHERE	RP_ParentID = @ParentID;
END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisRelatedProducts_DeleteByParentID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisRelatedProducts_DeleteByParentID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ========================================================
-- Author:		Mohammad
-- Create date: 
-- Description:	
-- ========================================================
CREATE PROCEDURE [dbo].[_spKartrisRelatedProducts_DeleteByParentID]
(
	@ParentID int
)
AS
BEGIN
	
	SET NOCOUNT ON;
Disable Trigger trigKartrisRelatedProducts_DML ON tblKartrisRelatedProducts;	
	DELETE FROM    tblKartrisRelatedProducts 
	WHERE	RP_ParentID = @ParentID;
Enable Trigger trigKartrisRelatedProducts_DML ON tblKartrisRelatedProducts;	
END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisRelatedProducts_AddChildList]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisRelatedProducts_AddChildList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisRelatedProducts_AddChildList]
(
	@ParentID as int,
	@ChildList as nvarchar(MAX)
)
AS
BEGIN
	SET NOCOUNT OFF;
	
	IF LEN(@ChildList) = 0	BEGIN RETURN END

	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @ChildID as int;
Disable Trigger trigKartrisRelatedProducts_DML ON tblKartrisRelatedProducts;	
	SET @SIndx = 0;
	WHILE @SIndx <= LEN(@ChildList)
	BEGIN

		-- Loop through out the parent''s list
		SET @CIndx = CHARINDEX('','', @ChildList, @SIndx)	-- Next keyword starting index (1-Based Index)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@ChildList)+ 1 END	-- If no more keywords, set next starting index to not exist
		SET @ChildID = CAST(SUBSTRING(@ChildList, @SIndx, @CIndx - @SIndx) AS int)
		INSERT INTO tblKartrisRelatedProducts
		VALUES (@ParentID, @ChildID); 
		SET @SIndx = @CIndx + 1;
	END;
Enable Trigger trigKartrisRelatedProducts_DML ON tblKartrisRelatedProducts;	
END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_GetTaskList]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_GetTaskList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Modified by:		Medz 02/11/09
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
 CREATE PROCEDURE [dbo].[_spKartrisDB_GetTaskList]
(	
	@NoOrdersToInvoice as int OUTPUT,
	@NoOrdersNeedPayment as int OUTPUT,
	@NoOrdersToDispatch as int OUTPUT,
	@NoStockWarnings as int OUTPUT,
	@NoOutOfStock as int OUTPUT,
	@NoReviewsWaiting as int OUTPUT,
	@NoAffiliatesWaiting as int OUTPUT,
	@NoCustomersWaitingRefunds as int OUTPUT,
	@NoCustomersInArrears as int OUTPUT
)
AS
BEGIN
	SELECT @NoOrdersToInvoice = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Invoiced = ''False'' AND O_Paid = ''False'' AND O_Sent = ''True'';
	SELECT @NoOrdersNeedPayment = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Paid = ''False'' AND O_Invoiced = ''True'' AND O_Sent = ''True'';
	SELECT @NoOrdersToDispatch = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Sent = ''True'' AND O_Paid = ''True'' AND O_Shipped = ''False'';
	
	SELECT @NoStockWarnings = Count(V_ID) FROM dbo.tblKartrisVersions WHERE V_QuantityWarnLevel >= V_Quantity AND V_QuantityWarnLevel <> 0;
	SELECT @NoOutOfStock = Count(V_ID) FROM dbo.tblKartrisVersions WHERE V_Quantity = 0 AND V_QuantityWarnLevel <> 0;

	SELECT @NoReviewsWaiting = Count(REV_ID) FROM dbo.tblKartrisReviews WHERE REV_Live = ''a'';
	SELECT @NoAffiliatesWaiting  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_IsAffiliate = ''True'' AND U_AffiliateCommission = 0;
	SELECT @NoCustomersWaitingRefunds  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_CustomerBalance > 0;
	SELECT @NoCustomersInArrears  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_CustomerBalance < 0;
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCustomerGroups_GetForCache]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCustomerGroups_GetForCache]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisCustomerGroups_GetForCache]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT        vKartrisTypeCustomerGroups.*
	FROM            vKartrisTypeCustomerGroups
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCustomerGroups_Get]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCustomerGroups_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisCustomerGroups_Get]
(
	@LANG_ID as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT        vKartrisTypeCustomerGroups.*
	FROM            vKartrisTypeCustomerGroups
	WHERE        (LANG_ID = @LANG_ID) AND CG_Live = 1
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategories_Get]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategories_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCategories_Get]
(
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT        vKartrisTypeCategories.*
FROM            vKartrisTypeCategories
WHERE        (CAT_ID <> 0) AND (LANG_ID = @LANG_ID)  

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDestinations_GetByZone]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDestinations_GetByZone]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get All Destinations list
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDestinations_GetByZone]
(
	@D_ShippingZoneID as tinyint,
	@LANG_ID as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT	*
	FROM	vKartrisTypeDestinations
	WHERE	D_ShippingZoneID = @D_ShippingZoneID AND LANG_ID = @LANG_ID
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDestinations_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDestinations_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Get Shipping Methods - by Destination and Boundary
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisDestinations_Get]
(
	@LANG_ID as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT *
	FROM dbo.vKartrisTypeDestinations
	WHERE LANG_ID = @LANG_ID;

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisAttributeValues_GetByProductID]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisAttributeValues_GetByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisAttributeValues_GetByProductID]
(
	@ProductID as int
)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT ATTRIBV_ID, ATTRIBV_AttributeID
	FROM dbo.tblKartrisAttributeValues
	WHERE ATTRIBV_ProductID = @ProductID;

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisAttributeValues_DeleteByProductID]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisAttributeValues_DeleteByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisAttributeValues_DeleteByProductID]
(
	@ProductID as int
)
AS
BEGIN
	
	SET NOCOUNT ON;

Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;
	DELETE 
	FROM	tblKartrisLanguageElements
	FROM    tblKartrisAttributeValues	INNER JOIN	tblKartrisLanguageElements ON 
			tblKartrisAttributeValues.ATTRIBV_ID = tblKartrisLanguageElements.LE_ParentID
	WHERE   (tblKartrisAttributeValues.ATTRIBV_ProductID = @ProductID) AND (tblKartrisLanguageElements.LE_TypeID = 14);
Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;

Disable Trigger trigKartrisAttributeValues_DML ON tblKartrisAttributeValues;
	DELETE
	FROM dbo.tblKartrisAttributeValues
	WHERE ATTRIBV_ProductID = @ProductID;
Enable Trigger trigKartrisAttributeValues_DML ON tblKartrisAttributeValues;

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisAttributeValues_Add]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisAttributeValues_Add]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisAttributeValues_Add]
(
	@ProductID as int,
	@AttributeID as tinyint,
	@NewAttributeValue_ID as int OUT
)
AS
BEGIN
	
	SET NOCOUNT ON;

Disable Trigger trigKartrisAttributeValues_DML ON tblKartrisAttributeValues;

	INSERT INTO dbo.tblKartrisAttributeValues
	VALUES (@ProductID, @AttributeID);

	SELECT @NewAttributeValue_ID = SCOPE_IDENTITY();
	
Enable Trigger trigKartrisAttributeValues_DML ON tblKartrisAttributeValues;

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategoryHierarchy_GetTotalSubcategories_s]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategoryHierarchy_GetTotalSubcategories_s]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisCategoryHierarchy_GetTotalSubcategories_s]
(
	@ParentID as int,
	@TotalSubcategories as int OUT
)
AS
	SET NOCOUNT ON;
	
	SELECT @TotalSubcategories = Count(1)
	FROM         tblKartrisCategoryHierarchy 
	WHERE     (tblKartrisCategoryHierarchy.CH_ParentID = @ParentID)

	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategoryHierarchy_GetSubcategories]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategoryHierarchy_GetSubcategories]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisCategoryHierarchy_GetSubcategories]
(
	@CategoryID as int
)
AS
BEGIN
	SET NOCOUNT ON;

		
	SELECT CH_ParentID, CH_ChildID
	FROM dbo.tblKartrisCategoryHierarchy
	WHERE CH_ParentID = @CategoryID;
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategoryHierarchy_GetParentsByID]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategoryHierarchy_GetParentsByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisCategoryHierarchy_GetParentsByID]
(
	@LANG_ID as tinyint,
	@ChildID as int
)
AS
	SET NOCOUNT ON;
SELECT tblKartrisCategoryHierarchy.CH_ChildID AS CAT_ID, tblKartrisCategoryHierarchy.CH_ParentID AS ParentID, tblKartrisLanguageElements.LE_Value AS ParentName
FROM         tblKartrisCategoryHierarchy LEFT OUTER JOIN
					  tblKartrisLanguageElements ON tblKartrisCategoryHierarchy.CH_ParentID = tblKartrisLanguageElements.LE_ParentID
WHERE     (tblKartrisLanguageElements.LE_LanguageID = @LANG_ID) AND (tblKartrisLanguageElements.LE_TypeID = 3) 
		AND (tblKartrisLanguageElements.LE_FieldID = 1) AND (tblKartrisCategoryHierarchy.CH_ChildID = @ChildID)
		AND (tblKartrisCategoryHierarchy.CH_ParentID <> 0)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategoryHierarchy_GetOtherParents]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategoryHierarchy_GetOtherParents]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisCategoryHierarchy_GetOtherParents]
(
	@CategoryID as int,
	@ExecludedParentID as int
)
AS
BEGIN
	SET NOCOUNT ON;

	
	SELECT CH_ParentID, CH_ChildID
	FROM dbo.tblKartrisCategoryHierarchy
	WHERE CH_ParentID <> @ExecludedParentID AND CH_ChildID = @CategoryID;
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategoryHierarchy_GetByLanguageID]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategoryHierarchy_GetByLanguageID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ======================================================
-- Author:		Mohammad
-- Create date: 02/14/2008 12:22:45
-- Description:	generate the category menu hierarchy (Same as the one that Medz created except Live = 1)
-- ======================================================
CREATE PROCEDURE [dbo].[_spKartrisCategoryHierarchy_GetByLanguageID]
	(@LANG_ID tinyint)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     tblKartrisCategoryHierarchy.CH_ChildID AS CAT_ID, tblKartrisCategoryHierarchy.CH_ParentID AS ParentID, vKartrisTypeCategories.CAT_Name AS Title, 
					  vKartrisTypeCategories.CAT_Desc AS Description
	FROM         vKartrisTypeCategories INNER JOIN
						  tblKartrisCategoryHierarchy ON vKartrisTypeCategories.CAT_ID = tblKartrisCategoryHierarchy.CH_ChildID
	WHERE     (vKartrisTypeCategories.LANG_ID = @LANG_ID)
	ORDER BY tblKartrisCategoryHierarchy.CH_OrderNo
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategoryHierarchy_DeleteLink]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategoryHierarchy_DeleteLink]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisCategoryHierarchy_DeleteLink]
(
	@ChildID int,
	@ParentID int
)
AS
BEGIN
	
	SET NOCOUNT OFF;
Disable Trigger trigKartrisCategoryHierarchy_DML ON tblKartrisCategoryHierarchy;
	DELETE FROM tblKartrisCategoryHierarchy WHERE ([CH_ChildID] = @ChildID AND [CH_ParentID] = @ParentID);
Enable Trigger trigKartrisCategoryHierarchy_DML ON tblKartrisCategoryHierarchy;

END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategoryHierarchy_DeleteByChild]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategoryHierarchy_DeleteByChild]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisCategoryHierarchy_DeleteByChild]
(
	@ChildID int
)
AS
BEGIN
	
	SET NOCOUNT OFF;
Disable Trigger trigKartrisCategoryHierarchy_DML ON tblKartrisCategoryHierarchy;
	DELETE FROM tblKartrisCategoryHierarchy WHERE ([CH_ChildID] = @ChildID);
Enable Trigger trigKartrisCategoryHierarchy_DML ON tblKartrisCategoryHierarchy;

END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategoryHierarchy_ChangeSortValue]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategoryHierarchy_ChangeSortValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisCategoryHierarchy_ChangeSortValue]
(
	@ParentID as int,
	@CatID as int,
	@Direction as char
)
AS
BEGIN
	SET NOCOUNT OFF;
	
Disable Trigger trigKartrisCategoryHierarchy_DML ON tblKartrisCategoryHierarchy;
		
	DECLARE @CatOrder as int;
	SELECT @CatOrder = CH_OrderNo 
	FROM dbo.tblKartrisCategoryHierarchy 
	WHERE CH_ParentID = @ParentID AND CH_ChildID = @CatID;

	-- *********************************************************
	-- Need to check if there are siblings with same sort order
	--  if yes, we need to reset those values
	DECLARE @DuplicateOrders as int;
	SELECT @DuplicateOrders = COUNT(1)
	FROM dbo.tblKartrisCategoryHierarchy
	WHERE CH_OrderNo = @CatOrder AND CH_ParentID = @ParentID;
	
	IF (SELECT COUNT(1)	FROM dbo.tblKartrisCategoryHierarchy WHERE CH_OrderNo = @CatOrder AND CH_ParentID = @ParentID) > 1 BEGIN
		DECLARE @MaxNo as int;
		SELECT @MaxNo = MAX(CH_OrderNo) 
		FROM dbo.tblKartrisCategoryHierarchy  
		WHERE CH_ParentID = @ParentID AND CH_ChildID <> @CatID;
		
		WHILE (SELECT COUNT(1)	FROM dbo.tblKartrisCategoryHierarchy WHERE CH_OrderNo = @CatOrder AND CH_ParentID = @ParentID) > 1
		BEGIN
			UPDATE TOP(1) dbo.tblKartrisCategoryHierarchy
			SET CH_OrderNo = @MaxNo + 1
			WHERE CH_ParentID = @ParentID AND CH_OrderNo = @CatOrder AND CH_ChildID <> @CatID;
			SET @MaxNo = @MaxNo + 1;
		END
	END
	-- *********************************************************

	DECLARE @SwitchCatID as int, @SwitchOrder as int;
	IF @Direction = ''u''
	BEGIN
		SELECT @SwitchOrder = MAX(CH_OrderNo) 
		FROM dbo.tblKartrisCategoryHierarchy 
		WHERE CH_ParentID = @ParentID AND CH_OrderNo < @CatOrder;

		SELECT TOP(1) @SwitchCatID = CH_ChildID
		FROM dbo.tblKartrisCategoryHierarchy 
		WHERE CH_ParentID = @ParentID AND CH_OrderNo = @SwitchOrder;		
	END
	ELSE
	BEGIN
		SELECT @SwitchOrder = Min(CH_OrderNo) 
		FROM dbo.tblKartrisCategoryHierarchy 
		WHERE CH_ParentID = @ParentID AND CH_OrderNo > @CatOrder;

		SELECT TOP(1) @SwitchCatID = CH_ChildID
		FROM dbo.tblKartrisCategoryHierarchy 
		WHERE CH_ParentID = @ParentID AND CH_OrderNo = @SwitchOrder;
	END;

UPDATE [tblKartrisCategoryHierarchy]
	SET CH_OrderNo = @SwitchOrder
	WHERE CH_ParentID = @ParentID AND CH_ChildID = @CatID; 

	UPDATE [tblKartrisCategoryHierarchy]
	SET CH_OrderNo = @CatOrder
	WHERE CH_ParentID = @ParentID AND CH_ChildID = @SwitchCatID;
Enable Trigger trigKartrisCategoryHierarchy_DML ON tblKartrisCategoryHierarchy;
		
END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategoryHierarchy_AddParentList]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategoryHierarchy_AddParentList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisCategoryHierarchy_AddParentList]
(
	@ParentList as nvarchar(MAX),
	@ChildID int
)
AS
BEGIN
	SET NOCOUNT OFF;
	
	IF LEN(@ParentList) = 0	BEGIN RETURN END
	
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @ParentID as int;

	DECLARE @MaxOrder as int;
Disable Trigger trigKartrisCategoryHierarchy_DML ON tblKartrisCategoryHierarchy;
	SET @SIndx = 0;
	WHILE @SIndx <= LEN(@ParentList)
	BEGIN

		-- Loop through out the parent''s list
		SET @CIndx = CHARINDEX('','', @ParentList, @SIndx)	-- Next keyword starting index (1-Based Index)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@ParentList)+ 1 END	-- If no more keywords, set next starting index to not exist
		SET @ParentID = CAST(SUBSTRING(@ParentList, @SIndx, @CIndx - @SIndx) AS int)
		SELECT @MaxOrder = Max(CH_OrderNo) FROM dbo.tblKartrisCategoryHierarchy WHERE CH_ParentID = @ParentID;
		IF @MaxOrder is NULL BEGIN SET @MaxOrder = 0 END
		INSERT INTO [tblKartrisCategoryHierarchy]
		VALUES (@ParentID, @ChildID, @MaxOrder + 1); 
		SET @SIndx = @CIndx + 1;
	END;
Enable Trigger trigKartrisCategoryHierarchy_DML ON tblKartrisCategoryHierarchy;
		

--	DELETE FROM [tblKartrisProductCategoryLink] 
--	WHERE [PCAT_ProductID] = @ProductID;
END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategories_SearchCategoriesByName]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategories_SearchCategoriesByName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCategories_SearchCategoriesByName]
(
	@Key nvarchar(50),
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT        CAT_ID, CAT_Name
FROM            vKartrisTypeCategories
WHERE        (CAT_ID <> 0) AND (LANG_ID = @LANG_ID) AND (CAT_Name LIKE @Key + ''%'')

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategories_GetWithProductsOnly]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategories_GetWithProductsOnly]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCategories_GetWithProductsOnly]
(
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT   DISTINCT  vKartrisTypeCategories.CAT_ID, vKartrisTypeCategories.CAT_Name
FROM         vKartrisTypeCategories INNER JOIN
					  tblKartrisProductCategoryLink ON vKartrisTypeCategories.CAT_ID = tblKartrisProductCategoryLink.PCAT_CategoryID
WHERE     (vKartrisTypeCategories.CAT_ID <> 0) AND (vKartrisTypeCategories.LANG_ID = @LANG_ID)
ORDER BY vKartrisTypeCategories.CAT_Name
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategories_GetTotalByParentID]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategories_GetTotalByParentID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Get the total no. of Products in Category "used for ItemPager"
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCategories_GetTotalByParentID]
			(
			@LANG_ID as tinyint,
			@ParentID as int,
			@TotalCategories as int OUTPUT
			)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT  @TotalCategories = COUNT(vKartrisTypeCategories.CAT_ID)
		FROM    tblKartrisCategoryHierarchy INNER JOIN
				vKartrisTypeCategories ON tblKartrisCategoryHierarchy.CH_ChildID = vKartrisTypeCategories.CAT_ID INNER JOIN
				tblKartrisCategories ON tblKartrisCategoryHierarchy.CH_ParentID = tblKartrisCategories.CAT_ID
		WHERE   (tblKartrisCategoryHierarchy.CH_ParentID = @ParentID) AND (vKartrisTypeCategories.LANG_ID = @LANG_ID)

	
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategories_GetTotalByLanguageID]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategories_GetTotalByLanguageID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisCategories_GetTotalByLanguageID]
(
	@LANG_ID as tinyint,
	@NoOfCategories as int OUTPUT
)
AS
	SET NOCOUNT ON;
SELECT     @NoOfCategories = COUNT(CAT_Name)
FROM         vKartrisTypeCategories
WHERE     (LANG_ID = @LANG_ID) AND (NOT (CAT_Name IS NULL)) AND (CAT_ID <> 0)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategories_GetStatus]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategories_GetStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ===================================================
-- Author:		Mohammad
-- Create date: 
-- Description:	
-- ===================================================
CREATE PROCEDURE [dbo].[_spKartrisCategories_GetStatus]
(
	@CAT_ID int,
	@CategoryLive as bit OUT,
	@NoOfLiveParents as int OUT,
	@CategoryCustomerGroup as smallint OUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Check if the product is live, Type, CustomerGroup
	SELECT @CategoryLive = CAT_Live, @CategoryCustomerGroup = CAT_CustomerGroupID
	FROM   dbo.tblKartrisCategories
	WHERE  (CAT_ID = @CAT_ID);

	-- No of live parents
	SELECT     @NoOfLiveParents = Count(1)
	FROM         tblKartrisCategories INNER JOIN tblKartrisCategoryHierarchy 
				ON tblKartrisCategories.CAT_ID = tblKartrisCategoryHierarchy.CH_ParentID
	WHERE     (tblKartrisCategoryHierarchy.CH_ChildID = @CAT_ID) AND (tblKartrisCategories.CAT_Live = 1)
		

	

	
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategories_GetPageByParentID]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategories_GetPageByParentID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCategories_GetPageByParentID]
(
	@LANG_ID as tinyint, 
	@ParentID as int,
	@PageIndex as tinyint, -- 0 Based index
	@RowsPerPage as smallint
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;

	DECLARE @OrderBy as nvarchar(50), @OrderDirection as char(1)

	SELECT @OrderBy = CAT_OrderCategoriesBy, @OrderDirection = CAT_CategoriesSortDirection
	FROM dbo.tblKartrisCategories
	WHERE CAT_ID = @ParentID;

	IF @OrderBy is NULL OR @OrderBy = ''d''
	BEGIN 
		SELECT @OrderBy = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = ''frontend.categories.display.sortdefault'';
	END;
	IF @OrderDirection is NULL OR @OrderDirection = '''' BEGIN 
		SELECT @OrderDirection = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = ''frontend.categories.display.sortdirection'';
	END;

	DECLARE @SortByValue as bit;
	SET @SortByValue = 0;
	IF @OrderBy = ''CH_OrderNo'' BEGIN SET @SortByValue = 1 END;
	
	IF @ParentID = 0 
	BEGIN
		 SET @SortByValue = 1;
		 SET @OrderBy = ''CH_OrderNo'';
	END;
	
	WITH CategoryList AS
	(
		SELECT	CASE 
				WHEN (@OrderBy = ''CAT_ID'' AND @OrderDirection = ''A'') THEN	ROW_NUMBER() OVER (ORDER BY tblKartrisCategories.CAT_ID ASC) 
				WHEN (@OrderBy = ''CAT_ID'' AND @OrderDirection = ''D'') THEN	ROW_NUMBER() OVER (ORDER BY tblKartrisCategories.CAT_ID DESC) 
				WHEN (@OrderBy = ''CAT_Name'' AND @OrderDirection = ''A'') THEN ROW_NUMBER() OVER (ORDER BY CAT_Name ASC) 
				WHEN (@OrderBy = ''CAT_Name'' AND @OrderDirection = ''D'') THEN ROW_NUMBER() OVER (ORDER BY CAT_Name DESC) 
				WHEN (@OrderBy = ''CH_OrderNo'' AND @OrderDirection = ''A'') THEN ROW_NUMBER() OVER (ORDER BY CH_OrderNo ASC) 
				WHEN (@OrderBy = ''CH_OrderNo'' AND @OrderDirection = ''D'') THEN ROW_NUMBER() OVER (ORDER BY CH_OrderNo DESC) 
				END AS Row,
				vKartrisTypeCategories.CAT_ID, vKartrisTypeCategories.CAT_Name, vKartrisTypeCategories.CAT_Desc, tblKartrisCategories.CAT_ProductDisplayType AS Parent_ProductDisplay, 
				tblKartrisCategories.CAT_SubCatDisplayType AS Parent_SubCategoryDisplay, @SortByValue AS SortByValue, vKartrisTypeCategories.CAT_Live
		FROM    tblKartrisCategoryHierarchy INNER JOIN
				vKartrisTypeCategories ON tblKartrisCategoryHierarchy.CH_ChildID = vKartrisTypeCategories.CAT_ID INNER JOIN
				tblKartrisCategories ON tblKartrisCategoryHierarchy.CH_ParentID = tblKartrisCategories.CAT_ID
		WHERE   (tblKartrisCategoryHierarchy.CH_ParentID = @ParentID) AND (vKartrisTypeCategories.LANG_ID = @LANG_ID)
		
	)

	SELECT *
	FROM CategoryList
	WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber
	ORDER BY Row ASC;

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategories_GetNameByCategoryID]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategories_GetNameByCategoryID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- ========================================================
-- Author:		Medz
-- Create date: 04/13/2008 11:53:30
-- Description:	Get the category name for the SEO Friendly Links.
-- ========================================================
CREATE PROCEDURE [dbo].[_spKartrisCategories_GetNameByCategoryID]
(
	@CAT_ID int,
	@LANG_ID tinyint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT CAT_Name
	FROM   vKartrisTypeCategories
	WHERE  (CAT_ID = @CAT_ID) AND (LANG_ID = @LANG_ID)
END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisAttributes_Delete]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisAttributes_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisAttributes_Delete]
(
	@AttributeID as tinyint
)
AS
BEGIN
	SET NOCOUNT ON;

	Disable Trigger trigKartrisLanguageElements_DML ON dbo.tblKartrisLanguageElements;
		DELETE FROM dbo.tblKartrisLanguageElements 
		WHERE (LE_TypeID = 14 AND LE_ParentID IN (SELECT ATTRIBV_ID FROM dbo.tblKartrisAttributeValues WHERE ATTRIBV_AttributeID = @AttributeID))
			OR (LE_TypeID = 4 AND LE_ParentID = @AttributeID);
	Enable Trigger trigKartrisLanguageElements_DML ON dbo.tblKartrisLanguageElements;
	
	Disable Trigger	trigKartrisAttributeValues_DML ON dbo.tblKartrisAttributeValues;
		DELETE FROM dbo.tblKartrisAttributeValues WHERE ATTRIBV_AttributeID = @AttributeID;
	Enable Trigger trigKartrisAttributeValues_DML ON dbo.tblKartrisAttributeValues;

	Disable Trigger trigKartrisAttributes_DML ON dbo.tblKartrisAttributes;
		DELETE FROM tblKartrisAttributes WHERE ATTRIB_ID = @AttributeID;
	Enable Trigger trigKartrisAttributes_DML ON dbo.tblKartrisAttributes;
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisKnowledgeBase_GetByID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisKnowledgeBase_GetByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisKnowledgeBase_GetByID]
(
	@LANG_ID as tinyint,
	@KB_ID as int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	SELECT *
	FROM dbo.vKartrisTypeKnowledgeBase
	WHERE LANG_ID = @LANG_ID AND KB_ID = @KB_ID

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisKnowledgeBase_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisKnowledgeBase_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisKnowledgeBase_Get]
(
	@LANG_ID as tinyint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	SELECT * 
	FROM dbo.vKartrisTypeKnowledgeBase
	WHERE LANG_ID = @LANG_ID
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisAttributes_GetByLanguage]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisAttributes_GetByLanguage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisAttributes_GetByLanguage]
(
	@LANG_ID as tinyint
)
AS
	SET NOCOUNT ON;
SELECT        vKartrisTypeAttributes.*
FROM            vKartrisTypeAttributes
WHERE ( LANG_ID = @LANG_ID)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPages_GetByID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPages_GetByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPages_GetByID]
(
	@LANG_ID as tinyint,
	@Page_ID as smallint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	SELECT *
	FROM dbo.vKartrisTypePages
	WHERE LANG_ID = @LANG_ID AND Page_ID = @Page_ID

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPages_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPages_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPages_Get]
(
	@LANG_ID as tinyint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	SELECT * 
	FROM dbo.vKartrisTypePages
	WHERE LANG_ID = @LANG_ID
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOrders_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Deletes an Order
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisOrders_Delete]
(
	@O_ID as int,
	@O_DeleteReturnStock as bit
)
AS
BEGIN
	SET NOCOUNT ON;
	IF (@O_DeleteReturnStock = 1)
	BEGIN

Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;
			DECLARE @V_Codenumber nvarchar(25)
			DECLARE @IR_Quantity real
			DECLARE tnames_cursor CURSOR
		FOR
	-- check if return stock flag is on
		SELECT     tblKartrisInvoiceRows.IR_VersionCode, tblKartrisInvoiceRows.IR_Quantity
		FROM         tblKartrisOrders INNER JOIN
							  tblKartrisInvoiceRows ON tblKartrisOrders.O_ID = tblKartrisInvoiceRows.IR_OrderNumberID
		WHERE     (tblKartrisOrders.O_ID = @O_ID)

		
		OPEN tnames_cursor
		--loop through the invoicerows records and return the stocks back to individual versions
		FETCH NEXT FROM tnames_cursor INTO @V_Codenumber,@IR_Quantity
		WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			IF (@@FETCH_STATUS <> -2)
			BEGIN 
				UPDATE tblKartrisVersions SET V_Quantity= V_Quantity + @IR_Quantity WHERE V_CodeNumber=@V_Codenumber AND V_QuantityWarnLevel<>0;
			END
			FETCH NEXT FROM tnames_cursor INTO @V_Codenumber,@IR_Quantity
		END
		CLOSE tnames_cursor
		DEALLOCATE tnames_cursor ;
Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;
	END
;
Disable Trigger trigKartrisInvoiceRows_DML ON tblKartrisInvoiceRows;
		--delete the order invoicerows
		DELETE FROM dbo.tblKartrisInvoiceRows
		WHERE IR_OrderNumberID = @O_ID;
Enable Trigger trigKartrisInvoiceRows_DML ON tblKartrisInvoiceRows;

Disable Trigger trigKartrisOrdersPromotions_DML ON tblKartrisOrdersPromotions;
		--delete the order promotion records
		DELETE  FROM dbo.tblKartrisOrdersPromotions
		WHERE OrderID = @O_ID;
		SELECT @O_ID;
Enable Trigger trigKartrisOrdersPromotions_DML ON tblKartrisOrdersPromotions;

DISABLE TRIGGER trigKartrisOrderPaymentLink_DML ON tblKartrisOrderPaymentLink;	
	DELETE FROM dbo.tblKartrisOrderPaymentLink WHERE OP_OrderID = @O_ID;
ENABLE TRIGGER trigKartrisOrderPaymentLink_DML ON tblKartrisOrderPaymentLink;

Disable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	
		--delete the main order record
		DELETE  FROM dbo.tblKartrisOrders
		WHERE O_ID = @O_ID;
		SELECT @O_ID;
Enable Trigger trigKartrisOrders_DML ON tblKartrisOrders;	
	
END




' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisNews_GetForCache]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisNews_GetForCache]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisNews_GetForCache]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	SELECT * 
	FROM dbo.vKartrisTypeNews
	ORDER BY N_DateCreated DESC, N_ID ASC
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOptionGroups_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOptionGroups_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisOptionGroups_Delete]
(
	@OPTG_ID smallint
)
AS
BEGIN
	SET NOCOUNT ON;

	Disable Trigger trigKartrisVersionOptionLink_DML ON dbo.tblKartrisVersionOptionLink;
		DELETE FROM dbo.tblKartrisVersionOptionLink
		WHERE V_OPT_OptionID IN (SELECT OPT_ID FROM dbo.tblKartrisOptions WHERE OPT_OptionGroupID = @OPTG_ID);
	Enable Trigger trigKartrisVersionOptionLink_DML ON dbo.tblKartrisVersionOptionLink;

	Disable Trigger trigKartrisProductOptionLink_DML ON dbo.tblKartrisProductOptionLink;
		DELETE FROM dbo.tblKartrisProductOptionLink
		WHERE P_OPT_OptionID IN (SELECT OPT_ID FROM dbo.tblKartrisOptions WHERE OPT_OptionGroupID = @OPTG_ID);
	Enable Trigger trigKartrisProductOptionLink_DML ON dbo.tblKartrisProductOptionLink;

	Disable Trigger trigKartrisProductOptionGroupLink_DML ON dbo.tblKartrisProductOptionGroupLink;
		DELETE FROM dbo.tblKartrisProductOptionGroupLink
		WHERE P_OPTG_OptionGroupID = @OPTG_ID;
	Enable Trigger trigKartrisProductOptionGroupLink_DML ON dbo.tblKartrisProductOptionGroupLink;

		DELETE FROM dbo.tblKartrisBasketOptionValues
		WHERE BSKTOPT_OptionID IN (SELECT OPT_ID FROM dbo.tblKartrisOptions WHERE OPT_OptionGroupID = @OPTG_ID);

	Disable Trigger trigKartrisLanguageElements_DML ON dbo.tblKartrisLanguageElements;
		DELETE FROM dbo.tblKartrisLanguageElements 
		WHERE (LE_TypeID = 5 AND LE_ParentID IN (SELECT OPT_ID FROM dbo.tblKartrisOptions WHERE OPT_OptionGroupID = @OPTG_ID))
			OR (LE_TypeID = 6 AND LE_ParentID = @OPTG_ID);
	Enable Trigger trigKartrisLanguageElements_DML ON dbo.tblKartrisLanguageElements;

	Disable Trigger trigKartrisOptions_DML ON dbo.tblKartrisOptions;
		DELETE FROM dbo.tblKartrisOptions WHERE OPT_OptionGroupID = @OPTG_ID;
	Enable Trigger trigKartrisOptions_DML ON dbo.tblKartrisOptions;

	Disable Trigger trigKartrisOptionGroups_DML ON tblKartrisOptionGroups;
		DELETE FROM	tblKartrisOptionGroups	WHERE OPTG_ID = @OPTG_ID;
	Enable Trigger trigKartrisOptionGroups_DML ON tblKartrisOptionGroups;
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisAttributes_GetSpecialByProductID]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisAttributes_GetSpecialByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisAttributes_GetSpecialByProductID]
	(
		@P_ID int,
		@LANG_ID tinyint
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     vKartrisTypeAttributes.ATTRIB_Name, vKartrisTypeAttributeValues.ATTRIBV_Value
	FROM         vKartrisTypeAttributeValues INNER JOIN
						  vKartrisTypeAttributes ON vKartrisTypeAttributeValues.ATTRIBV_AttributeID = vKartrisTypeAttributes.ATTRIB_ID AND 
						  vKartrisTypeAttributeValues.LANG_ID = vKartrisTypeAttributes.LANG_ID
	WHERE     (vKartrisTypeAttributes.ATTRIB_Live = 1) AND (vKartrisTypeAttributeValues.ATTRIBV_ProductID = @P_ID) AND (vKartrisTypeAttributeValues.LANG_ID = @LANG_ID) 
						  AND (vKartrisTypeAttributes.ATTRIB_Special = 1)
	ORDER BY vKartrisTypeAttributes.ATTRIB_Name DESC
END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_AdminSearch]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_AdminSearch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
 CREATE PROCEDURE [dbo].[_spKartrisDB_AdminSearch]
(	
	@searchLocation as nvarchar(25),
	@keyWordsList as nvarchar(100),
	@LANG_ID as tinyint,
	@PageIndex as tinyint, -- 0 Based index
	@RowsPerPage as tinyint,
	@TotalResult as int OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @KeyWord as nvarchar(30);
	SET @SIndx = 0;
	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;

	DECLARE @TypeNo as tinyint;
	SET @TypeNo = 0;
	IF @searchLocation = ''products'' BEGIN SET @TypeNo = 2 END
	IF @searchLocation = ''categories'' BEGIN SET @TypeNo = 3 END
	
	--================ PRODUCTS/CATEGORIES ==================
	IF @searchLocation = ''products'' OR @searchLocation = ''categories''
	BEGIN
			CREATE TABLE #_ProdCatSearchTbl(ItemID nvarchar(255), ItemValue nvarchar(MAX))
			WHILE @SIndx <= LEN(@keyWordsList)
			BEGIN
				
				SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)
				IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
				SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
				SET @SIndx = @CIndx + 1;
				INSERT INTO #_ProdCatSearchTbl (ItemID,ItemValue)
				SELECT     CAST(LE_ParentID as nvarchar(255)), LE_Value
				FROM		tblKartrisLanguageElements
				WHERE     (LE_LanguageID = @LANG_ID) AND (LE_TypeID = @TypeNo) AND (LE_FieldID = 1) AND LE_Value LIKE ''%'' + @KeyWord + ''%'';
			END

			SELECT @TotalResult =  Count(ItemID) FROM #_ProdCatSearchTbl;

--			With SearchResult AS
--			(
--				SELECT     ROW_NUMBER() OVER (ORDER BY ItemValue ASC) AS Row, ItemID, ItemValue
--				FROM         #_ProdCatSearchTbl
--			)
--			
--			SELECT *
--			FROM SearchResult
--			WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber
			SELECT     ItemID, ItemValue
			FROM         #_ProdCatSearchTbl
			
			DROP TABLE #_ProdCatSearchTbl;
		END

	--================ VERSIONS ==================
	IF @searchLocation = ''versions''
	BEGIN
		CREATE TABLE #_VersionSearchTbl(VersionID nvarchar(255), VersionName nvarchar(MAX), VersionCode nvarchar(25), ProductID nvarchar(255))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			SET @SIndx = @CIndx + 1;
			INSERT INTO #_VersionSearchTbl (VersionID, VersionName, VersionCode, ProductID)
			SELECT     CAST(LE_ParentID as nvarchar(255)), LE_Value, dbo.fnKartrisVersions_GetCodeNumber(LE_ParentID),
						CAST(dbo.fnKartrisVersions_GetProductID(LE_ParentID) as nvarchar(255))
			FROM		tblKartrisLanguageElements
			WHERE     (LE_LanguageID = @LANG_ID) AND (LE_TypeID = 1) AND (LE_FieldID = 1) AND LE_Value LIKE ''%'' + @KeyWord + ''%'';

			-- SEARCH FOR THE CODE NUMBER
			INSERT INTO #_VersionSearchTbl (VersionID, VersionName, VersionCode, ProductID)
			SELECT     CAST(LE_ParentID as nvarchar(255)), LE_Value, dbo.fnKartrisVersions_GetCodeNumber(LE_ParentID),
						CAST(dbo.fnKartrisVersions_GetProductID(LE_ParentID) as nvarchar(255))
			FROM		tblKartrisLanguageElements
			WHERE     (LE_LanguageID = @LANG_ID) AND (LE_TypeID = 1) AND (LE_FieldID = 1) 
					AND LE_ParentID IN (SELECT V_ID FROM tblKartrisVersions WHERE V_CodeNumber Like ''%'' + @KeyWord + ''%'');

		END

		SELECT @TotalResult =  Count(VersionID) FROM #_VersionSearchTbl;
		
--		With SearchResult AS
--		(
--			SELECT     ROW_NUMBER() OVER (ORDER BY VersionName ASC) AS Row, VersionID, VersionName, VersionCode, ProductID
--			FROM         #_VersionSearchTbl
--		)
--		
--		SELECT *
--		FROM SearchResult
--		WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber
		SELECT     VersionID, VersionName, VersionCode, ProductID
		FROM         #_VersionSearchTbl
		DROP TABLE #_VersionSearchTbl;
	END

	--================ CUSTOMERS ==================
	IF @searchLocation = ''customers''
	BEGIN
			
			CREATE TABLE #_CustomerSearchTbl(CustomerID nvarchar(255), CustomerName nvarchar(50), CustomerEmail nvarchar(100))
			WHILE @SIndx <= LEN(@keyWordsList)
			BEGIN
				
				SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)
				IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
				SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
				SET @SIndx = @CIndx + 1;

				INSERT INTO #_CustomerSearchTbl (CustomerID, CustomerName, CustomerEmail)
				SELECT     tblKartrisUsers.U_ID, tblKartrisAddresses.ADR_Name, tblKartrisUsers.U_EmailAddress
				FROM         tblKartrisAddresses RIGHT OUTER JOIN
									  tblKartrisUsers ON tblKartrisAddresses.ADR_ID = tblKartrisUsers.U_DefBillingAddressID
				WHERE     (tblKartrisAddresses.ADR_Name LIKE ''%'' + @KeyWord + ''%'') OR
						(tblKartrisUsers.U_EmailAddress LIKE ''%'' + @KeyWord + ''%'');

			END

			SELECT @TotalResult =  Count(CustomerID) FROM #_CustomerSearchTbl;

--			With SearchResult AS
--			(
--				SELECT     ROW_NUMBER() OVER (ORDER BY CustomerName ASC) AS Row, CustomerID, CustomerName, CustomerEmail
--				FROM         #_CustomerSearchTbl
--			)
--			
--			SELECT *
--			FROM SearchResult
--			WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber
			
			SELECT     CustomerID, CustomerName, CustomerEmail
			FROM         #_CustomerSearchTbl
			
			DROP TABLE #_CustomerSearchTbl;
		END

		--================ ORDERS ==================
		IF @searchLocation = ''orders''
		BEGIN
			CREATE TABLE #_OrdersSearchTbl(OrderID int, PurchaseOrderNumber nvarchar(50))
			WHILE @SIndx <= LEN(@keyWordsList)
			BEGIN
				
				SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)
				IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
				SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
				SET @SIndx = @CIndx + 1;

				INSERT INTO #_OrdersSearchTbl (OrderID, PurchaseOrderNumber)
				SELECT     tblKartrisOrders.O_ID, tblKartrisOrders.O_PurchaseOrderNo
				FROM         tblKartrisOrders 
				WHERE     (tblKartrisOrders.O_PurchaseOrderNo LIKE ''%'' + @KeyWord + ''%'');

				BEGIN TRY
					INSERT INTO #_OrdersSearchTbl (OrderID, PurchaseOrderNumber)
					SELECT     tblKartrisOrders.O_ID, tblKartrisOrders.O_PurchaseOrderNo
					FROM         tblKartrisOrders 
					WHERE     (tblKartrisOrders.O_ID = @KeyWord);
				END TRY
				BEGIN CATCH
				END CATCH

			END

			SELECT @TotalResult =  Count(OrderID) FROM #_OrdersSearchTbl;


			SELECT     OrderID, PurchaseOrderNumber
			FROM         #_OrdersSearchTbl
			
			DROP TABLE #_OrdersSearchTbl;
		END

	--================ CONFIG ==================
	IF @searchLocation = ''config''
	BEGIN
			
		CREATE TABLE #_ConfigSearchTbl(ConfigName nvarchar(100), ConfigValue nvarchar(255))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			SET @SIndx = @CIndx + 1;

			INSERT INTO #_ConfigSearchTbl (ConfigName, ConfigValue)
			SELECT     tblKartrisConfig.CFG_Name, tblKartrisConfig.CFG_Value
			FROM         tblKartrisConfig 
			WHERE     (tblKartrisConfig.CFG_Name LIKE ''%'' + @KeyWord + ''%'') 
					OR (tblKartrisConfig.CFG_Value LIKE ''%'' + @KeyWord + ''%'') ;

		END

		SELECT @TotalResult =  Count(ConfigName) FROM #_ConfigSearchTbl;

--		With SearchResult AS
--		(
--			SELECT     ROW_NUMBER() OVER (ORDER BY ConfigName ASC) AS Row, ConfigName, ConfigValue
--			FROM         #_ConfigSearchTbl
--		)
--		
--		SELECT *
--		FROM SearchResult
--		WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber
		SELECT     ConfigName, ConfigValue
		FROM         #_ConfigSearchTbl
		
		DROP TABLE #_ConfigSearchTbl;
	END

	--================ LS ==================
	IF @searchLocation = ''site''
	BEGIN
			
		CREATE TABLE #_LSSearchTbl(LSFB char(1), LSLang tinyint, LSName nvarchar(255), LSValue nvarchar(MAX), LSClass nvarchar(50))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			SET @SIndx = @CIndx + 1;

			INSERT INTO #_LSSearchTbl (LSFB, LSLang, LSName, LSValue, LSClass)
			SELECT     tblKartrisLanguageStrings.LS_FrontBack, tblKartrisLanguageStrings.LS_LangID,
						tblKartrisLanguageStrings.LS_Name, tblKartrisLanguageStrings.LS_Value, tblKartrisLanguageStrings.LS_ClassName
			FROM         tblKartrisLanguageStrings 
			WHERE     tblKartrisLanguageStrings.LS_LangID = @LANG_ID AND((tblKartrisLanguageStrings.LS_Name LIKE ''%'' + @KeyWord + ''%'') OR
						(tblKartrisLanguageStrings.LS_Value LIKE ''%'' + @KeyWord + ''%''));

		END

		SELECT @TotalResult =  Count(LSName) FROM #_LSSearchTbl;

--		With SearchResult AS
--		(
--			SELECT     ROW_NUMBER() OVER (ORDER BY LSName ASC) AS Row, LSFB, LSName, LSValue
--			FROM         #_LSSearchTbl
--		)
--		
--		SELECT *
--		FROM SearchResult
--		WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber
		SELECT     LSFB, LSLang, LSName, LSValue, LSClass
		FROM         #_LSSearchTbl
		
		DROP TABLE #_LSSearchTbl;
	END


	--============== Custom Pages =======================
	IF @searchLocation = ''pages''
	BEGIN
		CREATE TABLE #_CustomPagesSearchTbl(PageID smallint, PageName nvarchar(50))
		WHILE @SIndx <= LEN(@keyWordsList)
		BEGIN
			
			SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+1 END
			SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
			SET @SIndx = @CIndx + 1;
			
			INSERT INTO #_CustomPagesSearchTbl (PageID, PageName)
			SELECT DISTINCT LE_ParentID, PAGE_Name
			FROM dbo.tblKartrisLanguageElements INNER JOIN dbo.tblKartrisPages
				ON tblKartrisLanguageElements.LE_ParentID = tblKartrisPages.PAGE_ID
			WHERE (LE_LanguageID = @LANG_ID) AND (LE_TypeID = 8) AND (LE_Value LIKE ''%'' + @KeyWord + ''%'');
			
		END

		SELECT @TotalResult =  Count(DISTINCT PageID) FROM #_CustomPagesSearchTbl;
		

		SELECT  DISTINCT PageID, PageName
		FROM         #_CustomPagesSearchTbl
		DROP TABLE #_CustomPagesSearchTbl;
	END
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_ExportProductRelatedData]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisDB_ExportProductRelatedData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisDB_ExportProductRelatedData]
(
	@LanguageID as int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		SELECT * 
		FROM
			((SELECT ''###_DUMMYDATA_###'' AS Cat5_Name1,	''DO NOT MODIFY OR DELETE THIS LINE. THIS SHOULD HELP ADDRESS THE ISSUES WITH THE OLEDB DRIVER LIMITATION. BY ADDING THIS LINE WE ARE LETTING THE DRIVER KNOW THE CORRECT DATA TYPE OF EACH FIELD.  THIS IS BETTER THAN MODIFYING THE REGISTRY TO SET A HIGHER ROWSCAN VALUE.'' AS Cat5_Desc1,	''CAT5_IMAGEFIELD'' AS cat5_Image,	''CAT4_NAME'' AS Cat4_Name1,	''################################################################################################################################################################################################################################################################'' AS Cat4_Desc1,	''CAT4_IMAGEFIELD'' AS cat4_Image,	''CAT3_NAME'' AS Cat3_Name1,	''################################################################################################################################################################################################################################################################'' AS Cat3_Desc1,	''CAT3_IMAGEFIELD'' AS cat3_Image,	''CAT2_NAME'' AS Cat2_Name1,	''################################################################################################################################################################################################################################################################'' AS Cat2_Desc1,	''CAT2_IMAGEFIELD'' AS cat2_Image,	''CAT1_NAME'' AS Cat1_Name1,	''################################################################################################################################################################################################################################################################'' AS Cat1_Desc1,	''CAT1_IMAGEFIELD'' AS cat1_Image,	''P_NAME1'' AS P_Name1,	''################################################################################################################################################################################################################################################################'' AS P_Desc1,	''P_IMAGEFIELD'' AS P_Image,	''P_STRAPLINE1'' AS P_StrapLine1,	''V_NAME1'' AS V_Name1,	''################################################################################################################################################################################################################################################################'' AS V_Desc1,	''V_IMAGEFIELD'' AS V_Image,	''V_CODENUMBER'' AS V_CodeNumber,	''0'' AS V_Price,	''0'' AS V_Quantity,	''0'' AS V_Weight,	''0'' AS V_RRP,	''0'' AS T_Taxrate,	''SUPPLIER'' AS Supplier,	''###_END_OF_DUMMYDATA_###'' AS P_Attribute1,	'''' AS P_Attribute2,	'''' AS P_Attribute3)
			UNION
			(
			SELECT  dbo.vKartrisTypeCategories.CAT_Name AS Cat5_Name1, dbo.vKartrisTypeCategories.CAT_Desc AS Cat5_Desc1, '''' AS Cat5_Image, 
				  dbo.vKartrisCategoryHierarchy.CAT_Name AS Cat4_Name1, dbo.vKartrisCategoryHierarchy.CAT_Desc AS Cat4_Desc1, '''' AS Cat4_Image, 
				  vKartrisCategoryHierarchy_1.CAT_Name AS Cat3_Name1, vKartrisCategoryHierarchy_1.CAT_Desc AS Cat3_Desc1, '''' AS Cat3_Image, 
				  vKartrisCategoryHierarchy_2.CAT_Name AS Cat2_Name1, vKartrisCategoryHierarchy_2.CAT_Desc AS Cat2_Desc1, '''' AS Cat2_Image, 
				  vKartrisCategoryHierarchy_3.CAT_Name AS Cat1_Name1, vKartrisCategoryHierarchy_3.CAT_Desc AS Cat1_Desc1, '''' AS Cat1_Image, 
				  dbo.vKartrisTypeProducts.P_Name AS P_Name1, dbo.vKartrisTypeProducts.P_Desc AS P_Desc1, '''' AS P_Image, 
				  dbo.vKartrisTypeProducts.P_StrapLine AS P_Strapline1, dbo.vKartrisTypeVersions.V_Name AS V_Name1, dbo.vKartrisTypeVersions.V_Desc AS V_Desc1, 
				  '''' AS V_Image, dbo.vKartrisTypeVersions.V_CodeNumber, dbo.vKartrisTypeVersions.V_Price, dbo.vKartrisTypeVersions.V_Quantity, 
				  dbo.vKartrisTypeVersions.V_Weight, dbo.vKartrisTypeVersions.V_RRP, dbo.tblKartrisTaxRates.T_Taxrate, dbo.tblKartrisSuppliers.SUP_Name AS Supplier, 
				  '''' AS P_Attribute1, '''' AS P_Attribute2, '''' AS P_Attribute3
			FROM dbo.tblKartrisTaxRates RIGHT OUTER JOIN
				  dbo.vKartrisTypeVersions INNER JOIN
				  dbo.vKartrisTypeProducts ON dbo.vKartrisTypeVersions.V_ProductID = dbo.vKartrisTypeProducts.P_ID AND 
				  dbo.vKartrisTypeVersions.LANG_ID = dbo.vKartrisTypeProducts.LANG_ID ON dbo.tblKartrisTaxRates.T_ID = dbo.vKartrisTypeVersions.V_Tax LEFT OUTER JOIN
				  dbo.tblKartrisSuppliers ON dbo.vKartrisTypeProducts.P_SupplierID = dbo.tblKartrisSuppliers.SUP_ID LEFT OUTER JOIN
				  dbo.vKartrisTypeCategories INNER JOIN
				  dbo.tblKartrisProductCategoryLink ON dbo.vKartrisTypeCategories.CAT_ID = dbo.tblKartrisProductCategoryLink.PCAT_CategoryID LEFT OUTER JOIN
				  dbo.vKartrisCategoryHierarchy LEFT OUTER JOIN
				  dbo.vKartrisCategoryHierarchy AS vKartrisCategoryHierarchy_3 RIGHT OUTER JOIN
				  dbo.vKartrisCategoryHierarchy AS vKartrisCategoryHierarchy_2 ON vKartrisCategoryHierarchy_3.LANG_ID = vKartrisCategoryHierarchy_2.LANG_ID AND 
				  vKartrisCategoryHierarchy_3.CH_ChildID = vKartrisCategoryHierarchy_2.CAT_ID RIGHT OUTER JOIN
				  dbo.vKartrisCategoryHierarchy AS vKartrisCategoryHierarchy_1 ON vKartrisCategoryHierarchy_2.LANG_ID = vKartrisCategoryHierarchy_1.LANG_ID AND 
				  vKartrisCategoryHierarchy_2.CH_ChildID = vKartrisCategoryHierarchy_1.CAT_ID ON 
				  dbo.vKartrisCategoryHierarchy.LANG_ID = vKartrisCategoryHierarchy_1.LANG_ID AND 
				  dbo.vKartrisCategoryHierarchy.CAT_ID = vKartrisCategoryHierarchy_1.CH_ChildID ON 
				  dbo.vKartrisTypeCategories.LANG_ID = dbo.vKartrisCategoryHierarchy.LANG_ID AND 
				  dbo.vKartrisTypeCategories.CAT_ID = dbo.vKartrisCategoryHierarchy.CH_ChildID ON 
				  dbo.vKartrisTypeProducts.P_ID = dbo.tblKartrisProductCategoryLink.PCAT_ProductID
			WHERE     (dbo.vKartrisTypeProducts.LANG_ID = @LanguageID) AND (dbo.vKartrisTypeProducts.P_Type <> ''o'')
			)) ProductData
	ORDER BY Cat5_Name1, P_Name1
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisQuantityDiscounts_GetByVersionIDs]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisQuantityDiscounts_GetByVersionIDs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisQuantityDiscounts_GetByVersionIDs]
(
	@VersionIDList as nvarchar(max),
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
	
	
SELECT     dbo.fnKartrisProducts_GetName(vKartrisTypeVersions.V_ProductID, @LANG_ID) AS P_Name, tblKartrisQuantityDiscounts.QD_VersionID AS V_ID, 
					  tblKartrisQuantityDiscounts.QD_Quantity, tblKartrisQuantityDiscounts.QD_Price, vKartrisTypeVersions.V_Name
FROM         tblKartrisQuantityDiscounts LEFT OUTER JOIN
					  vKartrisTypeVersions ON tblKartrisQuantityDiscounts.QD_VersionID = vKartrisTypeVersions.V_ID
WHERE     (vKartrisTypeVersions.LANG_ID = @LANG_ID) AND (tblKartrisQuantityDiscounts.QD_VersionID IN
						  (SELECT     _ID
							FROM          dbo.fnTbl_SplitNumbers(@VersionIDList) AS fnTbl_SplitNumbers_1))
ORDER BY tblKartrisQuantityDiscounts.QD_VersionID

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_Update]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_Update](
								@P_ID as int,
								@P_Live as bit, 
								@P_Featured as tinyint,
								@P_OrderVersionsBy as nvarchar(50),
								@P_VersionsSortDirection as char(1),
								@P_VersionDisplayType as char(1),
								@P_Reviews as char(1),
								@P_SupplierID as smallint,
								@P_Type as char(1),
								@P_CustomerGroupID as smallint,
								@NowOffset as datetime 
								)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @OldType as char(1);
	SELECT @OldType = P_Type FROM dbo.tblKartrisProducts WHERE P_ID = @P_ID;
	IF @OldType <> @P_Type BEGIN
		IF @OldType = ''o'' BEGIN
			EXEC	[dbo].[_spKartrisProductOptionGroupLink_DeleteByProductID]	
			@ProductID = @P_ID;
			EXEC	[dbo].[_spKartrisProductOptionLink_DeleteByProductID]
			@ProductID = @P_ID;
		END
	END;
Disable Trigger trigKartrisProducts_DML ON tblKartrisProducts;	
	UPDATE tblKartrisProducts
	SET P_Live = @P_Live, P_Featured = @P_Featured, P_OrderVersionsBy = @P_OrderVersionsBy,
		P_VersionsSortDirection  = @P_VersionsSortDirection,
		P_VersionDisplayType = @P_VersionDisplayType, P_Reviews = @P_Reviews, P_SupplierID = @P_SupplierID, 
		P_Type = @P_Type, P_CustomerGroupID = @P_CustomerGroupID, P_LastModified = @NowOffset
	WHERE P_ID = @P_ID;
Enable Trigger trigKartrisProducts_DML ON tblKartrisProducts;	
		
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_PurgeOrders]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOrders_PurgeOrders]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisOrders_PurgeOrders]
(
	
	@O_PurgeDate smalldatetime = NULL
)
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		DECLARE @O_ID int
		DECLARE @RC int
		DECLARE tnames_cursor CURSOR
		FOR
	
		SELECT O_ID FROM tblKartrisOrders WHERE O_Date <= @O_PurgeDate
		
		OPEN tnames_cursor
		--loop through the orders table and return the ID
		FETCH NEXT FROM tnames_cursor INTO @O_ID
		WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			IF (@@FETCH_STATUS <> -2)
			BEGIN 
				EXECUTE @RC = [_spKartrisOrders_Delete] @O_ID,0
			END
			FETCH NEXT FROM tnames_cursor INTO @O_ID
		END
		CLOSE tnames_cursor
		DEALLOCATE tnames_cursor ;
	SELECT @O_PurgeDate;
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisOptions_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisOptions_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisOptions_Delete]
(
	@OPT_ID int
)
AS
BEGIN
	SET NOCOUNT ON;

	Disable Trigger trigKartrisVersionOptionLink_DML ON dbo.tblKartrisVersionOptionLink;
		DELETE FROM dbo.tblKartrisVersionOptionLink	WHERE V_OPT_OptionID = @OPT_ID;
	Enable Trigger trigKartrisVersionOptionLink_DML ON dbo.tblKartrisVersionOptionLink;

	Disable Trigger trigKartrisProductOptionLink_DML ON dbo.tblKartrisProductOptionLink;
		DELETE FROM dbo.tblKartrisProductOptionLink	WHERE P_OPT_OptionID = @OPT_ID;
	Enable Trigger trigKartrisProductOptionLink_DML ON dbo.tblKartrisProductOptionLink;

		DELETE FROM dbo.tblKartrisBasketOptionValues WHERE BSKTOPT_OptionID = @OPT_ID;

	Disable Trigger trigKartrisLanguageElements_DML ON dbo.tblKartrisLanguageElements;
		DELETE FROM dbo.tblKartrisLanguageElements WHERE LE_TypeID = 5 and LE_ParentID = @OPT_ID;
	Enable Trigger trigKartrisLanguageElements_DML ON dbo.tblKartrisLanguageElements;

	Disable Trigger trigKartrisOptions_DML ON dbo.tblKartrisOptions;
		DELETE FROM dbo.tblKartrisOptions WHERE OPT_ID = @OPT_ID;
	Enable Trigger trigKartrisOptions_DML ON dbo.tblKartrisOptions;
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_Get]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_Get]
(
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT        vKartrisTypeVersions.V_ID, vKartrisTypeVersions.V_Name
FROM            vKartrisTypeVersions
WHERE        (LANG_ID = @LANG_ID) AND V_Type <> ''c'' AND V_Type <> ''s''

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_DeleteSuspendedVersions]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_DeleteSuspendedVersions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_DeleteSuspendedVersions](@P_ID as bigint)
AS
BEGIN
	SET NOCOUNT ON;
	
	-- 1. Delete Related Data From VersionOptionLink
Disable Trigger trigKartrisVersionOptionLink_DML ON tblKartrisVersionOptionLink;	
	DELETE FROM tblKartrisVersionOptionLink
	FROM        tblKartrisVersionOptionLink INNER JOIN
				tblKartrisVersions ON tblKartrisVersionOptionLink.V_OPT_VersionID = tblKartrisVersions.V_ID
	WHERE		(tblKartrisVersions.V_ProductID = @P_ID) AND (tblKartrisVersions.V_Type = ''s'');
Enable Trigger trigKartrisVersionOptionLink_DML ON tblKartrisVersionOptionLink;	

	-- 2. Delete Related Data From LanguageElements
Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;	
	DELETE FROM tblKartrisLanguageElements
	FROM        tblKartrisLanguageElements INNER JOIN
				tblKartrisLanguageElementTypes ON tblKartrisLanguageElements.LE_TypeID = tblKartrisLanguageElementTypes.LET_ID INNER JOIN
				tblKartrisVersions ON tblKartrisLanguageElements.LE_ParentID = tblKartrisVersions.V_ID
	WHERE		(tblKartrisLanguageElementTypes.LET_Name = ''tblKartrisVersions'') AND (tblKartrisVersions.V_ProductID = @P_ID) AND (tblKartrisVersions.V_Type = ''s'');
Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;	

Disable Trigger trigKartrisCustomerGroupPrices_DML ON dbo.tblKartrisCustomerGroupPrices
	DELETE FROM tblKartrisCustomerGroupPrices
	FROM        tblKartrisCustomerGroupPrices INNER JOIN
				tblKartrisVersions ON tblKartrisCustomerGroupPrices.CGP_VersionID = tblKartrisVersions.V_ID
	WHERE		(tblKartrisVersions.V_ProductID = @P_ID) AND (tblKartrisVersions.V_Type = ''s'');
Enable Trigger trigKartrisCustomerGroupPrices_DML ON dbo.tblKartrisCustomerGroupPrices;

Disable Trigger trigKartrisQuantityDiscounts_DML ON dbo.tblKartrisQuantityDiscounts
	DELETE FROM tblKartrisQuantityDiscounts
	FROM        tblKartrisQuantityDiscounts INNER JOIN
				tblKartrisVersions ON tblKartrisQuantityDiscounts.QD_VersionID = tblKartrisVersions.V_ID
	WHERE		(tblKartrisVersions.V_ProductID = @P_ID) AND (tblKartrisVersions.V_Type = ''s'');
Enable Trigger trigKartrisQuantityDiscounts_DML ON dbo.tblKartrisQuantityDiscounts;

	-- 3. Delete Suspended Versions From Versions
Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	DELETE FROM tblKartrisVersions
	WHERE (tblKartrisVersions.V_ProductID = @P_ID) AND (tblKartrisVersions.V_Type = ''s'');
Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	

END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_DeleteByProduct]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_DeleteByProduct]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_DeleteByProduct](@P_ID as int, @DownloadFiles as nvarchar(MAX) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON;
	SET @DownloadFiles = '''';
Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;
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
			@ParentType = ''v'';
			
	EXEC [dbo].[_spKartrisPromotions_DeleteByParent] 
			@ParentID = @V_ID, 
			@ParentType = ''v'';
			
Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;	
	DELETE FROM tblKartrisLanguageElements
	WHERE     (LE_TypeID = 1)	-- For Versions
	AND (LE_ParentID = @V_ID);	-- VersionID
Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;	

Disable Trigger trigKartrisVersionOptionLink_DML ON tblKartrisVersionOptionLink;	
	DELETE FROM dbo.tblKartrisVersionOptionLink
	WHERE V_OPT_VersionID = @V_ID;
Enable Trigger trigKartrisVersionOptionLink_DML ON tblKartrisVersionOptionLink;	

Disable Trigger trigKartrisCustomerGroupPrices_DML ON dbo.tblKartrisCustomerGroupPrices
	DELETE FROM dbo.tblKartrisCustomerGroupPrices
	WHERE CGP_VersionID = @V_ID;
Enable Trigger trigKartrisCustomerGroupPrices_DML ON dbo.tblKartrisCustomerGroupPrices;

Disable Trigger trigKartrisQuantityDiscounts_DML ON dbo.tblKartrisQuantityDiscounts
	DELETE FROM dbo.tblKartrisQuantityDiscounts
	WHERE QD_VersionID = @V_ID;
Enable Trigger trigKartrisQuantityDiscounts_DML ON dbo.tblKartrisQuantityDiscounts;

	SELECT @DownloadFiles = V_DownLoadInfo + ''##'' + @DownloadFiles
	FROM dbo.tblKartrisVersions
	WHERE V_ID = @V_ID AND V_DownloadType = ''u'';

	DELETE FROM dbo.tblKartrisVersions
	WHERE V_ID = @V_ID;
	
	IF @V_ID <> 0 AND @V_ID NOT IN (SELECT DELETED_ID FROM dbo.tblKartrisDeletedItems WHERE Deleted_Type = ''v'') BEGIN
		DISABLE Trigger trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
			DECLARE @Timeoffset as int;
			set @Timeoffset = CAST(dbo.fnKartrisConfig_GetValue(''general.timeoffset'') as int);
			INSERT INTO dbo.tblKartrisDeletedItems VALUES(@V_ID, ''v'', @P_ID, DateAdd(hour, @Timeoffset, GetDate()));
		ENABLE Trigger trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
	END
		FETCH NEXT FROM versionCursor
		INTO @V_ID;

	END

	CLOSE versionCursor
	DEALLOCATE versionCursor;
	
Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;		
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_Delete](@V_ID as bigint, @DownloadFile as nvarchar(MAX) out)
AS
BEGIN
	SET NOCOUNT ON;
EXEC [dbo].[_spKartrisMediaLinks_DeleteByParent] 
			@ParentID = @V_ID, 
			@ParentType = ''v'';
			
	EXEC [dbo].[_spKartrisPromotions_DeleteByParent] 
			@ParentID = @V_ID, 
			@ParentType = ''v'';
			
Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;
	SELECT @DownloadFile = V_DownLoadInfo
	FROM dbo.tblKartrisVersions
	WHERE V_ID = @V_ID AND V_DownloadType = ''u'';
	
	DELETE FROM tblKartrisLanguageElements
	WHERE     (LE_TypeID = 1)	-- For Versions
	AND (LE_ParentID = @V_ID);	-- VersionID
Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;	

Disable Trigger trigKartrisVersionOptionLink_DML ON tblKartrisVersionOptionLink;	
	DELETE FROM dbo.tblKartrisVersionOptionLink
	WHERE V_OPT_VersionID = @V_ID;
Enable Trigger trigKartrisVersionOptionLink_DML ON tblKartrisVersionOptionLink;	

Disable Trigger trigKartrisCustomerGroupPrices_DML ON dbo.tblKartrisCustomerGroupPrices
	DELETE FROM dbo.tblKartrisCustomerGroupPrices
	WHERE CGP_VersionID = @V_ID;
Enable Trigger trigKartrisCustomerGroupPrices_DML ON dbo.tblKartrisCustomerGroupPrices;

Disable Trigger trigKartrisQuantityDiscounts_DML ON dbo.tblKartrisQuantityDiscounts
	DELETE FROM dbo.tblKartrisQuantityDiscounts
	WHERE QD_VersionID = @V_ID;
Enable Trigger trigKartrisQuantityDiscounts_DML ON dbo.tblKartrisQuantityDiscounts;

IF @V_ID <> 0 AND @V_ID NOT IN (SELECT DELETED_ID FROM dbo.tblKartrisDeletedItems WHERE Deleted_Type = ''v'') BEGIN
	DISABLE Trigger trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
		DECLARE @Timeoffset as int;
		set @Timeoffset = CAST(dbo.fnKartrisConfig_GetValue(''general.timeoffset'') as int);
		INSERT INTO dbo.tblKartrisDeletedItems VALUES(@V_ID, ''v'', dbo.fnKartrisVersions_GetProductID(@V_ID), DateAdd(hour, @Timeoffset, GetDate()));
	ENABLE Trigger trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
END
;
Disable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	DELETE FROM dbo.tblKartrisVersions
	WHERE V_ID = @V_ID;
Enable Trigger trigKartrisVersions_DML ON tblKartrisVersions;	
	

END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersionOptionLink_GetByProductID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersionOptionLink_GetByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersionOptionLink_GetByProductID](@P_ID as int)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT     tblKartrisVersions.V_ProductID, tblKartrisVersions.V_ID, 
				tblKartrisVersionOptionLink.V_OPT_OptionID, tblKartrisVersions.V_Type
FROM         tblKartrisVersions INNER JOIN
					  tblKartrisVersionOptionLink ON tblKartrisVersions.V_ID = tblKartrisVersionOptionLink.V_OPT_VersionID
WHERE     (tblKartrisVersions.V_ProductID = @P_ID)
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersionOptionLink_AddOptionsList]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersionOptionLink_AddOptionsList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisVersionOptionLink_AddOptionsList]
(
	@VersionID bigint,
	@OptionList nvarchar(MAX)
)
AS
	SET NOCOUNT OFF;
	
	IF LEN(@OptionList) = 0	BEGIN RETURN END
	
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @OptionID as int;

Disable Trigger trigKartrisVersionOptionLink_DML ON tblKartrisVersionOptionLink;	
	SET @SIndx = 0;
	WHILE @SIndx <= LEN(@OptionList)
	BEGIN

		-- Loop through out the parent''s list
		SET @CIndx = CHARINDEX('','', @OptionList, @SIndx)	-- Next keyword starting index (1-Based Index)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@OptionList)+ 1 END	-- If no more keywords, set next starting index to not exist
		SET @OptionID = CAST(SUBSTRING(@OptionList, @SIndx, @CIndx - @SIndx) AS int)
		INSERT INTO tblKartrisVersionOptionLink
		VALUES (@VersionID, @OptionID); 
		SET @SIndx = @CIndx + 1;
	END;
Enable Trigger trigKartrisVersionOptionLink_DML ON tblKartrisVersionOptionLink;	

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisUsers_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisUsers_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- ==============================================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	Deletes an Order
-- ===============================================================
CREATE PROCEDURE [dbo].[_spKartrisUsers_Delete]
(
	@U_ID as int,
	@U_OrderDeleteReturnStock as bit
)
AS
BEGIN
	SET NOCOUNT ON;


	--	DECLARE @OrderID int
	--	DECLARE @O_Sent bit
	--	DECLARE tnames_cursor CURSOR
	--FOR
		
	--SELECT O_ID, O_Sent FROM tblKartrisOrders WHERE O_CustomerID= @U_ID
	
	--OPEN tnames_cursor
	--loop through the order records and delete them one by one
	--FETCH NEXT FROM tnames_cursor INTO @OrderID, @O_Sent
	--WHILE (@@FETCH_STATUS <> -1)
	--BEGIN
	--	IF (@@FETCH_STATUS <> -2)
	--	BEGIN 
			EXEC	[dbo].[_spKartrisUsers_DeleteOrders]
				@U_ID = @U_ID,
				@O_DeleteReturnStock = @U_OrderDeleteReturnStock;

	--	END
	--	FETCH NEXT FROM tnames_cursor INTO @OrderID, @O_Sent
	--END
	--CLOSE tnames_cursor
	--DEALLOCATE tnames_cursor ;

Disable Trigger trigKartrisAddresses_DML ON tblKartrisAddresses;	
		--delete the customer addresses
		DELETE FROM dbo.tblKartrisAddresses
		WHERE ADR_UserID = @U_ID	;
Enable Trigger trigKartrisAddresses_DML ON tblKartrisAddresses;	

Disable Trigger trigKartrisUsers_DML ON tblKartrisUsers;	
		--delete the customer record
		DELETE FROM dbo.tblKartrisUsers
		WHERE U_ID = @U_ID	;
Enable Trigger trigKartrisUsers_DML ON tblKartrisUsers;	
END




' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetLinksInfo]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_GetLinksInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisVersions_GetLinksInfo]
(
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
	SELECT     V_ID, V_Name, V_DownLoadInfo, V_ProductID
FROM         vKartrisTypeVersions
WHERE     (V_DownloadType = N''l'') AND (LANG_ID = @LANG_ID)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetDownloadableInfo]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_GetDownloadableInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[_spKartrisVersions_GetDownloadableInfo]
(
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
	SELECT     V_ID, V_Name, V_CodeNumber, V_DownLoadInfo, V_ProductID
FROM         vKartrisTypeVersions
WHERE     (V_DownloadType = N''u'') AND (LANG_ID = @LANG_ID)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetCustomerGroupPrices]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_GetCustomerGroupPrices]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 1/Nov/2009
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_GetCustomerGroupPrices] ( 
	@LanguageID int,	
	@VersionID int
) AS
BEGIN

	SET NOCOUNT ON;

	SELECT CG.CG_ID,CG_Name,CG.CG_Live,CG.CG_Discount,ISNULL(CGP_ID,0)''CGP_ID'',
	ISNULL(CGP_Price,0)''CGP_Price'',ISNULL(CGP_VersionID,0)''CGP_VersionID'' FROM vKartrisTypeCustomerGroups vCG
	INNER JOIN tblKartrisCustomerGroups CG ON vCG.CG_ID = CG.CG_ID
	LEFT JOIN (SELECT * FROM tblKartrisCustomerGroupPrices WHERE CGP_VersionID=@VersionID) A
	ON CG.CG_ID = A.CGP_CustomerGroupID
	WHERE LANG_ID = @LanguageID

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetByCategoryList]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_GetByCategoryList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_GetByCategoryList]
(
	@LANG_ID tinyint,
	@FromPrice float,
	@ToPrice float,
	@CategoryList nvarchar(max)
)
AS
	SET NOCOUNT ON;
	IF @CategoryList = ''0'' BEGIN
		SELECT DISTINCT dbo.fnKartrisProducts_GetName(V_ProductID, @LANG_ID) as P_Name, V_ID, V_Name, V_CodeNumber, V_Price, V_RRP
		FROM dbo.vKartrisTypeVersions
		WHERE LANG_ID = @LANG_ID AND V_Type IN (''v'',''b'',''c'') AND V_Price BETWEEN @FromPrice AND @ToPrice
		ORDER BY P_Name, V_CodeNumber
	END ELSE BEGIN
		SELECT DISTINCT dbo.fnKartrisProducts_GetName(V_ProductID, @LANG_ID) as P_Name, V_ID, V_Name, V_CodeNumber, V_Price, V_RRP
		FROM dbo.vKartrisTypeVersions
		WHERE V_ProductID IN(SELECT DISTINCT PCAT_ProductID	
							 FROM dbo.tblKartrisProductCategoryLink
							 WHERE PCAT_CategoryID IN ( SELECT * FROM dbo.fnTbl_SplitNumbers(@CategoryList))) 
			AND LANG_ID = @LANG_ID AND V_Type IN (''v'',''b'',''c'') AND V_Price BETWEEN @FromPrice AND @ToPrice
		ORDER BY P_Name, V_CodeNumber
	END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetByProductID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_GetByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- BACK/FRONT : Back-End (Not Necessary to be V_Live=True)
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_GetByProductID](@P_ID as int, @LANG_ID as tinyint)
AS
BEGIN

	DECLARE @OrderBy as nvarchar(50);
	SELECT @OrderBy = P_OrderVersionsBy FROM tblKartrisProducts WHERE P_ID = @P_ID;
	IF @OrderBy IS NULL OR @OrderBy = '''' OR @OrderBy = ''d''
	BEGIN
		 SELECT @OrderBy = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = ''frontend.versions.display.sortdefault'';
	END

	DECLARE @SortByValue as bit;
	SET @SortByValue = 0;
	IF @OrderBy = ''V_OrderByValue'' BEGIN SET @SortByValue = 1 END;

	SET NOCOUNT ON;
	SELECT     vKartrisTypeVersions.V_ID, tblKartrisTaxRates.T_Taxrate, vKartrisTypeVersions.V_Price, vKartrisTypeVersions.V_Weight, vKartrisTypeVersions.V_RRP, 
					  vKartrisTypeVersions.V_Tax, tblKartrisTaxRates.T_Taxrate AS Expr1, ''0'' AS CalculatedTax, vKartrisTypeVersions.V_ProductID, vKartrisTypeVersions.V_CodeNumber, 
					  vKartrisTypeVersions.V_Quantity, vKartrisTypeVersions.V_QuantityWarnLevel, vKartrisTypeVersions.V_Price AS OrderByBit, vKartrisTypeVersions.V_Name, 
					  vKartrisTypeVersions.V_Desc, MIN(tblKartrisQuantityDiscounts.QD_Price) AS QuantityDiscount, vKartrisTypeVersions.V_OrderByValue, vKartrisTypeVersions.V_Type, 
					  vKartrisTypeVersions.V_CustomizationType, vKartrisTypeVersions.V_CustomizationDesc, vKartrisTypeVersions.V_CustomizationCost, @SortByValue AS SortByValue
FROM         vKartrisTypeVersions LEFT OUTER JOIN
					  tblKartrisTaxRates ON vKartrisTypeVersions.V_Tax = tblKartrisTaxRates.T_ID LEFT OUTER JOIN
					  tblKartrisQuantityDiscounts ON vKartrisTypeVersions.V_ID = tblKartrisQuantityDiscounts.QD_VersionID
WHERE     (vKartrisTypeVersions.LANG_ID = @LANG_ID) AND (vKartrisTypeVersions.V_ProductID = @P_ID) AND (vKartrisTypeVersions.V_Type <> ''s'')
GROUP BY vKartrisTypeVersions.V_ID, tblKartrisTaxRates.T_Taxrate, vKartrisTypeVersions.V_Price, vKartrisTypeVersions.V_Weight, vKartrisTypeVersions.V_RRP, 
					  vKartrisTypeVersions.V_Tax, vKartrisTypeVersions.V_ProductID, vKartrisTypeVersions.V_CodeNumber, vKartrisTypeVersions.V_Quantity, 
					  vKartrisTypeVersions.V_QuantityWarnLevel, vKartrisTypeVersions.V_Name, vKartrisTypeVersions.V_Desc, vKartrisTypeVersions.V_OrderByValue, 
					  vKartrisTypeVersions.V_Type, vKartrisTypeVersions.V_CustomizationType, vKartrisTypeVersions.V_CustomizationDesc, 
					  vKartrisTypeVersions.V_CustomizationCost

--ORDER BY vKartrisTypeVersions.V_Type, vKartrisTypeVersions.V_Name, vKartrisTypeVersions.V_CodeNumber
	ORDER BY	CASE
				WHEN @OrderBy = ''V_Name'' THEN  (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Name))
				WHEN @OrderBy = ''V_Price'' THEN vKartrisTypeVersions.V_Price
				WHEN @OrderBy = ''V_OrderByValue'' THEN vKartrisTypeVersions.V_OrderByValue
				ELSE vKartrisTypeVersions.V_Price
				END
				
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetSuspendedByID]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_GetSuspendedByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_GetSuspendedByID](@V_ID as bigint, @LANG_ID as tinyint)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT     V_ID, V_Name, V_CodeNumber, V_Price, V_Quantity, V_QuantityWarnLevel, V_Type, LANG_ID
	FROM         vKartrisTypeVersions
	WHERE     (V_ID = @V_ID) AND (LANG_ID = @LANG_ID)
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetOptionsStockQuantity]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisVersions_GetOptionsStockQuantity]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisVersions_GetOptionsStockQuantity]
(
	@P_ID as int,
	@OptionList as nvarchar(500),
	@Qty as real OUT
)
AS
BEGIN
	DECLARE @NoOfCombinations as int;
	SELECT	@NoOfCombinations = Count(V_ID)
	FROM    tblKartrisVersions 
	WHERE   (tblKartrisVersions.V_ProductID = @P_ID) 
			AND (tblKartrisVersions.V_Type = ''c'') 
			AND (tblKartrisVersions.V_Live = 1);
	IF @NoOfCombinations = 0
	BEGIN
		SET @Qty = 100;
		GoTo No_Combinations_Exist;
	END
	
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @OptionID as nvarchar(4);
	DECLARE @Counter as int;

	DECLARE @VersionID AS bigint;
	DECLARE ProductVersionsCursor CURSOR FOR
	SELECT	V_ID
	FROM    tblKartrisVersions 
	WHERE   (tblKartrisVersions.V_ProductID = @P_ID) 
			AND (tblKartrisVersions.V_Type = ''c'') 
			AND (tblKartrisVersions.V_Live = 1)

	OPEN ProductVersionsCursor
	FETCH NEXT FROM ProductVersionsCursor
	INTO @VersionID;

	DECLARE @WantedVersionID as bigint;
	SET @WantedVersionID = 0;

	DECLARE @No as tinyint;
	SET @No = 0;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT ''Version'' + Cast(@VersionID as nvarchar);
		SET @SIndx = 0;
		SET @Counter = 0;
		WHILE @SIndx <= LEN(@OptionList)
		BEGIN

			-- Loop through out the keyword''s list
			SET @Counter = @Counter + 1;	-- keywords counter
			SET @CIndx = CHARINDEX('','', @OptionList, @SIndx)	-- Next keyword starting index (1-Based Index)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@OptionList)+ 1 END	-- If no more keywords, set next starting index to not exist
			SET @OptionID = SUBSTRING(@OptionList, @SIndx, @CIndx - @SIndx)
			PRINT ''Key:'' + @OptionID;
			
			SELECT @No = Count(1)
			FROM tblKartrisVersionOptionLink
			WHERE V_OPT_OptionID = CAST(@OptionID AS BIGINT) AND V_OPT_VersionID = @VersionID;
			PRINT ''No:'' + Cast(@No as nvarchar) + '' ON option:'' + @OptionID + '' AND version:'' + CAST(@VersionID AS nvarchar);

			IF @No = 0
			BEGIN
				BREAK;
			END

			SET @SIndx = @CIndx + 1;	-- The next starting index
		END

		IF @No <> 0
		BEGIN
			DECLARE @NoOfRecords as int;
			SET @NoOfRecords = 0;

			SELECT	@NoOfRecords = Count(1)
			FROM	tblKartrisVersionOptionLink 
			WHERE tblKartrisVersionOptionLink.V_OPT_VersionID = @VersionID;

			IF @NoOfRecords = @Counter
			BEGIN			
				SET @WantedVersionID = @VersionID;
				BREAK;
			END
		END	
		
		FETCH NEXT FROM ProductVersionsCursor
		INTO @VersionID;	
	END

	CLOSE ProductVersionsCursor
	DEALLOCATE ProductVersionsCursor;

	SELECT	@Qty = tblKartrisVersions.V_Quantity
	FROM    tblKartrisVersions 
	WHERE   V_ID = @WantedVersionID;
		

	No_Combinations_Exist:
		
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisStatistics_GetRecentlyViewedProducts]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisStatistics_GetRecentlyViewedProducts]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Paul
-- Create date: <Create Date, ,>
-- Description:	NOT USED - Session variable is used instead
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisStatistics_GetRecentlyViewedProducts]
(
	@LanguageID as tinyint
)
AS
	SET NOCOUNT ON;

	CREATE TABLE #TempRecentlyViewedProducts(S_ID bigint, S_ItemID int)

	INSERT INTO #TempRecentlyViewedProducts
	
	-- Format the query
	SELECT ST_ID, ST_ItemID
	FROM tblKartrisStatistics INNER JOIN tblKartrisProducts ON ST_ItemID = P_ID
	WHERE ST_Type = ''P'' AND P_Live = 1
	ORDER BY ST_Date DESC;

	SELECT DISTINCT TOP(5) S_ItemID AS ProductID, dbo.fnKartrisProducts_GetName(S_ItemID, @LanguageID) AS ProductName
	FROM #TempRecentlyViewedProducts;

	DROP TABLE #TempRecentlyViewedProducts;


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisVersionOptionLink_Get]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisVersionOptionLink_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisVersionOptionLink_Get]
AS
	SET NOCOUNT ON;
SELECT        tblKartrisVersionOptionLink.*
FROM            tblKartrisVersionOptionLink

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetByProductID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisVersions_GetByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	replaces [spKartris_VER_SelectByP_ID]
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisVersions_GetByProductID]
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

	IF @OrderBy IS NULL OR @OrderBy = '''' OR @OrderBy = ''d''
	BEGIN
		 SELECT @OrderBy = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = ''frontend.versions.display.sortdefault'';
	END

	IF @OrderDirection IS NULL OR @OrderDirection = ''''
	BEGIN
		 SELECT @OrderDirection = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = ''frontend.versions.display.sortdirection'';
	END

	DECLARE @USMultistateisused as char(1);
	SELECT @USMultistateisused = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = ''general.tax.usmultistatetax'';

	IF @USMultistateisused = ''n'' -- TaxRates shouldn''t be NULL
	BEGIN
		SELECT     vKartrisTypeVersions.V_ID, tblKartrisTaxRates.T_Taxrate, vKartrisTypeVersions.V_Price, vKartrisTypeVersions.V_Weight, vKartrisTypeVersions.V_RRP, 
					  vKartrisTypeVersions.V_Tax, tblKartrisTaxRates.T_Taxrate AS Expr1, ''0'' AS CalculatedTax, vKartrisTypeVersions.V_ProductID, vKartrisTypeVersions.V_CodeNumber, 
					  vKartrisTypeVersions.V_Quantity, vKartrisTypeVersions.V_QuantityWarnLevel, vKartrisTypeVersions.V_Price AS OrderByBit, vKartrisTypeVersions.V_Name, 
					  vKartrisTypeVersions.V_Desc, MIN(tblKartrisQuantityDiscounts.QD_Price) AS QuantityDiscount, vKartrisTypeVersions.V_OrderByValue, 
					  vKartrisTypeVersions.V_CustomizationType, vKartrisTypeVersions.V_CustomizationDesc, vKartrisTypeVersions.V_CustomizationCost
		FROM         vKartrisTypeVersions INNER JOIN
							  tblKartrisTaxRates ON vKartrisTypeVersions.V_Tax = tblKartrisTaxRates.T_ID LEFT OUTER JOIN
							  tblKartrisQuantityDiscounts ON vKartrisTypeVersions.V_ID = tblKartrisQuantityDiscounts.QD_VersionID
		WHERE     (vKartrisTypeVersions.LANG_ID = @LANG_ID) AND (vKartrisTypeVersions.V_ProductID = @P_ID) AND (vKartrisTypeVersions.V_Live = 1)
				AND (vKartrisTypeVersions.V_CustomerGroupID IS NULL OR vKartrisTypeVersions.V_CustomerGroupID = @CGroupID)
		GROUP BY vKartrisTypeVersions.V_ID, tblKartrisTaxRates.T_Taxrate, vKartrisTypeVersions.V_Price, vKartrisTypeVersions.V_Weight, vKartrisTypeVersions.V_RRP, 
							  vKartrisTypeVersions.V_Tax, vKartrisTypeVersions.V_ProductID, vKartrisTypeVersions.V_CodeNumber, vKartrisTypeVersions.V_Quantity, 
							  vKartrisTypeVersions.V_QuantityWarnLevel, vKartrisTypeVersions.V_Name, vKartrisTypeVersions.V_Desc, vKartrisTypeVersions.V_OrderByValue, 
							  vKartrisTypeVersions.V_CustomizationType, vKartrisTypeVersions.V_CustomizationDesc, vKartrisTypeVersions.V_CustomizationCost
		HAVING      (vKartrisTypeVersions.V_Name IS NOT NULL)
		ORDER BY	CASE
					WHEN (@OrderBy = ''V_Name'' AND @OrderDirection = ''A'') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Name ASC))
					WHEN (@OrderBy = ''V_Name'' AND @OrderDirection = ''D'') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Name DESC))
					WHEN (@OrderBy = ''V_ID'' AND @OrderDirection = ''A'') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_ID ASC))
					WHEN (@OrderBy = ''V_ID'' AND @OrderDirection = ''D'') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_ID DESC))
					WHEN (@OrderBy = ''V_OrderByValue'' AND @OrderDirection = ''A'') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_OrderByValue ASC))
					WHEN (@OrderBy = ''V_OrderByValue'' AND @OrderDirection = ''D'') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_OrderByValue DESC))
					WHEN (@OrderDirection = ''A'') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Price ASC))
					ELSE (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Price DESC))
					END
	END
	ELSE	-- Versions'' TaxRate could be NULL.
	BEGIN
		SELECT     vKartrisTypeVersions.V_ID, tblKartrisTaxRates.T_Taxrate, vKartrisTypeVersions.V_Price, vKartrisTypeVersions.V_Weight, vKartrisTypeVersions.V_RRP, 
					  vKartrisTypeVersions.V_Tax, tblKartrisTaxRates.T_Taxrate AS Expr1, ''0'' AS CalculatedTax, vKartrisTypeVersions.V_ProductID, vKartrisTypeVersions.V_CodeNumber, 
					  vKartrisTypeVersions.V_Quantity, vKartrisTypeVersions.V_QuantityWarnLevel, vKartrisTypeVersions.V_Price AS OrderByBit, vKartrisTypeVersions.V_Name, 
					  vKartrisTypeVersions.V_Desc, MIN(tblKartrisQuantityDiscounts.QD_Price) AS QuantityDiscount, vKartrisTypeVersions.V_OrderByValue, 
					  vKartrisTypeVersions.V_CustomizationType, vKartrisTypeVersions.V_CustomizationDesc, vKartrisTypeVersions.V_CustomizationCost
		FROM         vKartrisTypeVersions LEFT OUTER JOIN
							  tblKartrisTaxRates ON vKartrisTypeVersions.V_Tax = tblKartrisTaxRates.T_ID LEFT OUTER JOIN
							  tblKartrisQuantityDiscounts ON vKartrisTypeVersions.V_ID = tblKartrisQuantityDiscounts.QD_VersionID
		WHERE     (vKartrisTypeVersions.LANG_ID = @LANG_ID) AND (vKartrisTypeVersions.V_ProductID = @P_ID) AND (vKartrisTypeVersions.V_Live = 1)
				AND (vKartrisTypeVersions.V_CustomerGroupID IS NULL OR vKartrisTypeVersions.V_CustomerGroupID = @CGroupID)
		GROUP BY vKartrisTypeVersions.V_ID, tblKartrisTaxRates.T_Taxrate, vKartrisTypeVersions.V_Price, vKartrisTypeVersions.V_Weight, vKartrisTypeVersions.V_RRP, 
							  vKartrisTypeVersions.V_Tax, vKartrisTypeVersions.V_ProductID, vKartrisTypeVersions.V_CodeNumber, vKartrisTypeVersions.V_Quantity, 
							  vKartrisTypeVersions.V_QuantityWarnLevel, vKartrisTypeVersions.V_Name, vKartrisTypeVersions.V_Desc, vKartrisTypeVersions.V_OrderByValue, 
							  vKartrisTypeVersions.V_CustomizationType, vKartrisTypeVersions.V_CustomizationDesc, vKartrisTypeVersions.V_CustomizationCost
		HAVING      (vKartrisTypeVersions.V_Name IS NOT NULL)
		ORDER BY	CASE
					WHEN (@OrderBy = ''V_Name'' AND @OrderDirection = ''A'') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Name ASC))
					WHEN (@OrderBy = ''V_Name'' AND @OrderDirection = ''D'') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Name DESC))
					WHEN (@OrderBy = ''V_ID'' AND @OrderDirection = ''A'') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_ID ASC))
					WHEN (@OrderBy = ''V_ID'' AND @OrderDirection = ''D'') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_ID DESC))
					WHEN (@OrderBy = ''V_OrderByValue'' AND @OrderDirection = ''A'') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_OrderByValue ASC))
					WHEN (@OrderBy = ''V_OrderByValue'' AND @OrderDirection = ''D'') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_OrderByValue DESC))
					WHEN (@OrderDirection = ''A'') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Price ASC))
					ELSE (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Price DESC))
					END
	END
	
				
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetByLanguageID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisVersions_GetByLanguageID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisVersions_GetByLanguageID](@LANG_ID as tinyint)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT * FROM vKartrisTypeVersions WHERE LANG_ID = @LANG_ID;
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisQuantityDiscounts_GetByProduct]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisQuantityDiscounts_GetByProduct]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisQuantityDiscounts_GetByProduct]
(
	@ProductID as int,
	@LangID as tinyint
)
AS
	SET NOCOUNT ON;
SELECT     tblKartrisQuantityDiscounts.QD_Quantity, tblKartrisQuantityDiscounts.QD_Price, vKartrisTypeVersions.V_Name, vKartrisTypeVersions.V_CodeNumber
FROM         tblKartrisQuantityDiscounts INNER JOIN
					  vKartrisTypeVersions ON tblKartrisQuantityDiscounts.QD_VersionID = vKartrisTypeVersions.V_ID
WHERE     (vKartrisTypeVersions.V_ProductID = @ProductID) AND (vKartrisTypeVersions.LANG_ID = @LangID) AND (vKartrisTypeVersions.V_Live = 1)

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetAttributeValue]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetAttributeValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisProducts_GetAttributeValue]
	(
	@P_ID smallint,
	@ATTRIB_ID int,
	@LANG_ID tinyint,
	@ATTRIBV_Value nvarchar(50) OUT
	)
AS
SELECT @ATTRIBV_Value = ATTRIBV_Value 
FROM vKartrisTypeAttributeValues 
WHERE vKartrisTypeAttributeValues.ATTRIBV_AttributeID = @ATTRIB_ID
	AND vKartrisTypeAttributeValues.ATTRIBV_ProductID = @P_ID
	AND vKartrisTypeAttributeValues.LANG_ID = @LANG_ID

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetAttributesbyProductID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetAttributesbyProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Create date: 02/12/2008 12:09:34
-- Description:	Replaces the [spKartris_PROD_Attributes]
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisProducts_GetAttributesbyProductID]
	(
	@P_ID int,
	@LANG_ID tinyint
	)
AS
	SELECT * FROM vKartrisTypeAttributes
INNER JOIN vKartrisTypeAttributeValues ON vKartrisTypeAttributes.ATTRIB_ID = vKartrisTypeAttributeValues.ATTRIBV_AttributeID
WHERE vKartrisTypeAttributes.ATTRIB_Name <> ''''
AND vKartrisTypeAttributeValues.ATTRIBV_Value <> ''''
AND vKartrisTypeAttributes.ATTRIB_Live = 1
AND vKartrisTypeAttributeValues.ATTRIBV_ProductID = @P_ID
AND vKartrisTypeAttributes.LANG_ID = @LANG_ID
ORDER BY vKartrisTypeAttributes.ATTRIB_OrderByValue



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetTopList]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetTopList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Medz
-- Create date: 02/12/2008 13:52:43
-- Description:	Replaces spKartris_Prod_TopList
-- Remarks:	Optimization (Medz) - 04-07-2010
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisProducts_GetTopList]
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
--	SELECT     TOP (50) SUM(tblKartrisVersionSalesStats.VSS_Quantity) AS ProductHits, 
--					vKartrisProductsVersions.P_ID, vKartrisProductsVersions.P_Name, @LANG_ID as LANG_ID
--	FROM         vKartrisProductsVersions LEFT OUTER JOIN
--						  tblKartrisVersionSalesStats ON vKartrisProductsVersions.V_ID = tblKartrisVersionSalesStats.VSS_ID
--	WHERE     (NOT (vKartrisProductsVersions.P_Name IS NULL)) AND (vKartrisProductsVersions.P_Live = 1) 
--							AND (vKartrisProductsVersions.CAT_Live = 1) 
--							AND (vKartrisProductsVersions.V_Live = 1) 
--							AND (vKartrisProductsVersions.LANG_ID = @LANG_ID) 
--							AND (vKartrisProductsVersions.P_CustomerGroupID IS NULL)
--	GROUP BY vKartrisProductsVersions.P_ID, vKartrisProductsVersions.P_Name
--	ORDER BY ProductHits DESC
--SELECT     TOP (@Limit) vKartrisProductsVersions.P_ID, vKartrisProductsVersions.P_Name, @LANG_ID AS LANG_ID, SUM(tblKartrisInvoiceRows.IR_Quantity) 
--                      AS ProductHits
--FROM         tblKartrisOrders RIGHT OUTER JOIN
--                      tblKartrisInvoiceRows ON tblKartrisOrders.O_ID = tblKartrisInvoiceRows.IR_OrderNumberID LEFT OUTER JOIN
--                      vKartrisProductsVersions ON tblKartrisInvoiceRows.IR_VersionCode = vKartrisProductsVersions.V_CodeNumber
--WHERE     (NOT (vKartrisProductsVersions.P_Name IS NULL)) AND (vKartrisProductsVersions.LANG_ID = @LANG_ID) AND 
--                      (vKartrisProductsVersions.P_CustomerGroupID IS NULL) AND (tblKartrisOrders.O_Paid = 1) AND (tblKartrisOrders.O_Date >= @StartDate)
--GROUP BY vKartrisProductsVersions.P_ID, vKartrisProductsVersions.P_Name
--ORDER BY ProductHits DESC

WITH tblNewestOrders as
	(
		SELECT     tblKartrisInvoiceRows.IR_VersionCode AS IR_VersionCode, SUM(tblKartrisInvoiceRows.IR_Quantity) AS IR_Quantity
				FROM         tblKartrisInvoiceRows LEFT OUTER JOIN
									  tblKartrisOrders ON tblKartrisInvoiceRows.IR_OrderNumberID = tblKartrisOrders.O_ID
				WHERE     (tblKartrisOrders.O_Paid = 1) AND (tblKartrisOrders.O_Date >= @StartDate)
GROUP BY tblKartrisInvoiceRows.IR_VersionCode
			)
	SELECT TOP (@Limit) tblKartrisVersions.V_ProductID as P_ID,dbo.fnKartrisProducts_GetName(tblKartrisVersions.V_ProductID, @LANG_ID) AS P_Name,@LANG_ID as LANG_ID, SUM(tblNewestOrders.IR_Quantity) as ProductHits
	FROM tblNewestOrders INNER JOIN dbo.tblKartrisVersions ON tblNewestOrders.IR_VersionCode = dbo.tblKartrisVersions.V_CodeNumber
	WHERE V_Live = 1
GROUP BY tblKartrisVersions.V_ProductID
	ORDER BY ProductHits DESC

END' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisCustomer_GetOrderDetails]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisCustomer_GetOrderDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 21/Aug/08
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisCustomer_GetOrderDetails] ( 
	@O_ID int
) AS
BEGIN
	SET NOCOUNT ON;

	select *, [dbo].[fnKartrisSuppliers_GetNameByVersionCode](IR_VersionCode) As SupplierName 
	from tblKartrisCurrencies C
	inner join tblKartrisOrders O on C.CUR_ID=O.O_CurrencyID
	inner join tblKartrisInvoiceRows IR on O.O_ID=IR.IR_OrderNumberID
	inner join tblKartrisUsers U on O.O_CustomerID=U.U_ID
	inner join tblKartrisLanguages L on O.O_LanguageID=L.LANG_ID
	where O_ID=@O_ID

END




' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisProduct_GetMinPriceWithCG]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisProduct_GetMinPriceWithCG]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisProduct_GetMinPriceWithCG] 
(
	-- Add the parameters for the function here
	@V_ProductID as int,
	@CG_ID as smallint
	
)
RETURNS real
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result real;

	IF @CG_ID = 0 OR @CG_ID IS NULL BEGIN
		SET @Result = dbo.fnKartrisProduct_GetMinPrice(@V_ProductID);
	END	
	ELSE BEGIN
		-- Add the T-SQL statements to compute the return value here
		SELECT @Result = Min(V_Price) FROM tblKartrisVersions 
		WHERE V_ProductID = @V_ProductID AND V_Live = 1
			AND (tblKartrisVersions.V_CustomerGroupID IS NULL OR tblKartrisVersions.V_CustomerGroupID = @CG_ID);
		
		DECLARE @QD_MinPrice as real;
		SELECT @QD_MinPrice = Min(QD_Price)
		FROM dbo.tblKartrisQuantityDiscounts INNER JOIN tblKartrisVersions 
			ON tblKartrisQuantityDiscounts.QD_VersionID = tblKartrisVersions.V_ID
		WHERE tblKartrisVersions.V_Live = 1 AND tblKartrisVersions.V_ProductID = @V_ProductID 
			AND (tblKartrisVersions.V_CustomerGroupID IS NULL OR tblKartrisVersions.V_CustomerGroupID = @CG_ID);

		IF @QD_MinPrice <> 0 AND @QD_MinPrice IS NOT NULL AND @QD_MinPrice < @Result
		BEGIN
			SET @Result = @QD_MinPrice
		END
	END

	IF @Result IS NULL
	BEGIN
		SET @Result = 0;
	END
	-- Return the result of the function
	RETURN @Result

END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_SearchVersionsByName]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_SearchVersionsByName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_SearchVersionsByName]
(
	@Key as nvarchar(50),
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT        V_ID, V_Name
FROM            vKartrisTypeVersions
WHERE        (LANG_ID = @LANG_ID) AND V_Type <> ''c'' AND V_Type <> ''s'' AND V_Name LIKE ''%'' + @Key + ''%''

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_UpdateCustomerGroupPrices]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_UpdateCustomerGroupPrices]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 1/Nov/2009
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_UpdateCustomerGroupPrices] ( 
	@CustomerGroupID int,
	@VersionID int,
	@Price float,
	@CustomerGroupPriceID int	
) AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @cnt as int
	SELECT @cnt = COUNT(CGP_ID) FROM tblKartrisCustomerGroupPrices
	WHERE CGP_CustomerGroupID = @CustomerGroupID and CGP_VersionID = @VersionID;

DISABLE TRIGGER trigKartrisCustomerGroupPrices_DML ON tblKartrisCustomerGroupPrices
	IF @cnt = 0
	BEGIN -- insert data
		INSERT INTO tblKartrisCustomerGroupPrices (CGP_CustomerGroupID,CGP_VersionID,CGP_Price)
			VALUES (@CustomerGroupID,@VersionID,@Price)
	END
	ELSE
	BEGIN -- update record
		UPDATE tblKartrisCustomerGroupPrices
			SET CGP_Price = @Price WHERE CGP_ID = @CustomerGroupPriceID
	END;
ENABLE TRIGGER trigKartrisCustomerGroupPrices_DML ON tblKartrisCustomerGroupPrices


END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_GetCustomerGroupPrice]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_GetCustomerGroupPrice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 28/Oct/2009
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_GetCustomerGroupPrice] (
	@CustomerID int,
	@VersionID bigint
) AS
BEGIN
	SET NOCOUNT ON;

	select CGP_Price,U_CustomerDiscount from tblKartrisUsers USR
	inner join tblKartrisCustomerGroups CG on USR.U_CustomerGroupID = CG.CG_ID
	inner join tblKartrisCustomerGroupPrices CGP on CGP.CGP_CustomerGroupID = CG.CG_ID
	where U_ID = @CustomerID and CG_Live=1 and CGP_VersionID = @VersionID

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisAttributes_GetSummaryByProductID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisAttributes_GetSummaryByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisAttributes_GetSummaryByProductID]
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
ORDER BY vKartrisTypeAttributes.ATTRIB_Name DESC
END


' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisVersions_GetName]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisVersions_GetName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisVersions_GetName] 
(
	-- Add the parameters for the function here
	@V_ID as bigint,
	@LANG_ID as tinyint
)
RETURNS nvarchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(MAX);

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = V_Name FROM vKartrisTypeVersions WHERE V_ID = @V_ID AND LANG_ID = @LANG_ID ;

	-- Return the result of the function
	RETURN @Result

END
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisVersions_GetSortedOptionsByVersion]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisVersions_GetSortedOptionsByVersion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisVersions_GetSortedOptionsByVersion]
(
	@VersionID as bigint
)
RETURNS nvarchar(max)
AS
BEGIN
	DECLARE @Options as nvarchar(max)
	SELECT @Options = COALESCE(@Options + '','', '''') + CAST(T.V_OPT_OptionID as nvarchar(10))
	FROM (	SELECT DISTINCT Top(5000) V_OPT_OptionID
			FROM dbo.tblKartrisVersionOptionLink
			WHERE V_OPT_VersionID = @VersionID
			ORDER BY V_OPT_OptionID) AS T;

	RETURN @Options
END
' 
END
GO
/****** Object:  View [dbo].[vKartrisProductsVersions]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisProductsVersions]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisProductsVersions]
AS
SELECT     dbo.vKartrisTypeProducts.P_ID, dbo.vKartrisTypeProducts.P_OrderVersionsBy, dbo.vKartrisTypeProducts.P_VersionsSortDirection, 
					  dbo.vKartrisTypeProducts.P_VersionDisplayType, dbo.vKartrisTypeProducts.P_Type, tblKartrisTaxRates_1.T_Taxrate, 
					  dbo.tblKartrisProductCategoryLink.PCAT_CategoryID AS CAT_ID, dbo.vKartrisTypeProducts.LANG_ID, dbo.vKartrisTypeProducts.P_Live, 
					  dbo.tblKartrisCategories.CAT_Live, dbo.vKartrisTypeVersions.V_Live, dbo.vKartrisTypeVersions.V_ID, dbo.vKartrisTypeVersions.V_Name, 
					  dbo.vKartrisTypeVersions.V_Desc, dbo.vKartrisTypeVersions.V_CodeNumber, dbo.vKartrisTypeVersions.V_Price, dbo.vKartrisTypeVersions.V_Tax, 
					  dbo.vKartrisTypeVersions.V_Weight, dbo.vKartrisTypeVersions.V_DeliveryTime, dbo.vKartrisTypeVersions.V_Quantity, 
					  dbo.vKartrisTypeVersions.V_QuantityWarnLevel, dbo.vKartrisTypeVersions.V_DownLoadInfo, dbo.vKartrisTypeVersions.V_DownloadType, 
					  dbo.vKartrisTypeVersions.V_RRP, dbo.vKartrisTypeVersions.V_OrderByValue, dbo.vKartrisTypeVersions.V_Type, dbo.vKartrisTypeVersions.V_CustomerGroupID, 
					  dbo.vKartrisTypeProducts.P_Name, dbo.vKartrisTypeProducts.P_Desc, dbo.vKartrisTypeProducts.P_StrapLine, dbo.vKartrisTypeProducts.P_PageTitle, 
					  dbo.vKartrisTypeProducts.P_Featured, dbo.vKartrisTypeProducts.P_SupplierID, dbo.vKartrisTypeProducts.P_CustomerGroupID, dbo.vKartrisTypeProducts.P_Reviews, 
					  dbo.vKartrisTypeProducts.P_AverageRating, dbo.vKartrisTypeProducts.P_DateCreated, dbo.vKartrisTypeVersions.V_CustomizationType, 
					  dbo.vKartrisTypeVersions.V_CustomizationDesc, dbo.vKartrisTypeVersions.V_CustomizationCost, dbo.tblKartrisTaxRates.T_Taxrate AS T_TaxRate2
FROM         dbo.tblKartrisCategories INNER JOIN
					  dbo.vKartrisTypeProducts INNER JOIN
					  dbo.tblKartrisProductCategoryLink ON dbo.vKartrisTypeProducts.P_ID = dbo.tblKartrisProductCategoryLink.PCAT_ProductID ON 
					  dbo.tblKartrisCategories.CAT_ID = dbo.tblKartrisProductCategoryLink.PCAT_CategoryID INNER JOIN
					  dbo.vKartrisTypeVersions ON dbo.vKartrisTypeProducts.P_ID = dbo.vKartrisTypeVersions.V_ProductID AND 
					  dbo.vKartrisTypeProducts.LANG_ID = dbo.vKartrisTypeVersions.LANG_ID LEFT OUTER JOIN
					  dbo.tblKartrisTaxRates ON dbo.vKartrisTypeVersions.V_Tax2 = dbo.tblKartrisTaxRates.T_ID LEFT OUTER JOIN
					  dbo.tblKartrisTaxRates AS tblKartrisTaxRates_1 ON dbo.vKartrisTypeVersions.V_Tax = tblKartrisTaxRates_1.T_ID
WHERE     (dbo.vKartrisTypeProducts.P_Live = 1) AND (dbo.tblKartrisCategories.CAT_Live = 1) AND (dbo.vKartrisTypeVersions.V_Live = 1)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisProductsVersions', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[37] 4[36] 2[6] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisCategories"
			Begin Extent = 
			   Top = 147
			   Left = 531
			   Bottom = 250
			   Right = 741
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "vKartrisTypeProducts"
			Begin Extent = 
			   Top = 6
			   Left = 38
			   Bottom = 282
			   Right = 232
			End
			DisplayFlags = 280
			TopColumn = 2
		 End
		 Begin Table = "tblKartrisProductCategoryLink"
			Begin Extent = 
			   Top = 155
			   Left = 283
			   Bottom = 265
			   Right = 460
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
		 Begin Table = "vKartrisTypeVersions"
			Begin Extent = 
			   Top = 6
			   Left = 787
			   Bottom = 266
			   Right = 981
			End
			DisplayFlags = 280
			TopColumn = 9
		 End
		 Begin Table = "tblKartrisTaxRates"
			Begin Extent = 
			   Top = 10
			   Left = 562
			   Bottom = 97
			   Right = 722
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
	  Begin ColumnWidths = 28
		 Width = 284
		 Width = 975
		 Width = 2175
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisProductsVersions'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisProductsVersions', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' = 870
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
		 Width = 1500
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 4560
		 Alias = 1035
		 Table = 1170
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisProductsVersions'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisProductsVersions', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisProductsVersions'
GO
/****** Object:  View [dbo].[vKartrisCombinationPrices]    Script Date: 05/15/2012 16:32:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vKartrisCombinationPrices]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vKartrisCombinationPrices]
AS
SELECT     V_ProductID, V_ID, V_CodeNumber, V_Price, dbo.fnKartrisVersions_GetSortedOptionsByVersion(V_ID) AS V_OptionsIDs
FROM         dbo.tblKartrisVersions
WHERE     (V_Type = ''c'')
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisCombinationPrices', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
	  Begin PaneConfiguration = 0
		 NumPanes = 4
		 Configuration = "(H (1[41] 4[20] 2[14] 3) )"
	  End
	  Begin PaneConfiguration = 1
		 NumPanes = 3
		 Configuration = "(H (1 [50] 4 [25] 3))"
	  End
	  Begin PaneConfiguration = 2
		 NumPanes = 3
		 Configuration = "(H (1 [50] 2 [25] 3))"
	  End
	  Begin PaneConfiguration = 3
		 NumPanes = 3
		 Configuration = "(H (4 [30] 2 [40] 3))"
	  End
	  Begin PaneConfiguration = 4
		 NumPanes = 2
		 Configuration = "(H (1 [56] 3))"
	  End
	  Begin PaneConfiguration = 5
		 NumPanes = 2
		 Configuration = "(H (2 [66] 3))"
	  End
	  Begin PaneConfiguration = 6
		 NumPanes = 2
		 Configuration = "(H (4 [50] 3))"
	  End
	  Begin PaneConfiguration = 7
		 NumPanes = 1
		 Configuration = "(V (3))"
	  End
	  Begin PaneConfiguration = 8
		 NumPanes = 3
		 Configuration = "(H (1[56] 4[18] 2) )"
	  End
	  Begin PaneConfiguration = 9
		 NumPanes = 2
		 Configuration = "(H (1 [75] 4))"
	  End
	  Begin PaneConfiguration = 10
		 NumPanes = 2
		 Configuration = "(H (1[66] 2) )"
	  End
	  Begin PaneConfiguration = 11
		 NumPanes = 2
		 Configuration = "(H (4 [60] 2))"
	  End
	  Begin PaneConfiguration = 12
		 NumPanes = 1
		 Configuration = "(H (1) )"
	  End
	  Begin PaneConfiguration = 13
		 NumPanes = 1
		 Configuration = "(V (4))"
	  End
	  Begin PaneConfiguration = 14
		 NumPanes = 1
		 Configuration = "(V (2))"
	  End
	  ActivePaneConfig = 0
   End
   Begin DiagramPane = 
	  Begin Origin = 
		 Top = 0
		 Left = 0
	  End
	  Begin Tables = 
		 Begin Table = "tblKartrisVersions"
			Begin Extent = 
			   Top = 6
			   Left = 38
			   Bottom = 203
			   Right = 266
			End
			DisplayFlags = 280
			TopColumn = 0
		 End
	  End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
	  Begin ParameterDefaults = ""
	  End
   End
   Begin CriteriaPane = 
	  Begin ColumnWidths = 11
		 Column = 5130
		 Alias = 2910
		 Table = 1170
		 Output = 720
		 Append = 1400
		 NewValue = 1170
		 SortType = 1350
		 SortOrder = 1410
		 GroupBy = 1350
		 Filter = 1350
		 Or = 1350
		 Or = 1350
		 Or = 1350
	  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisCombinationPrices'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vKartrisCombinationPrices', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisCombinationPrices'
GO
/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetMinPriceByProductList]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisVersions_GetMinPriceByProductList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Used in the Compare.aspx Page
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisVersions_GetMinPriceByProductList](@LANG_ID as tinyint, @P_List as nvarchar(100), @CG_ID as smallint)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	SET @SIndx = 0;

	CREATE TABLE #TempTbl(ProductID int)


	WHILE @SIndx <= LEN(@P_List)
	BEGIN
		
		SET @CIndx = CHARINDEX('','', @P_List, @SIndx)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@P_List)+1 END
		INSERT INTO #TempTbl VALUES (CAST(SUBSTRING(@P_List, @SIndx, @CIndx - @SIndx) as int));
		SET @SIndx = @CIndx + 1;

	END

	SELECT     distinct P_ID, P_Name, dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID,@CG_ID) as P_Price
	FROM         vKartrisProductsVersions
	WHERE     (LANG_ID = @LANG_ID) AND (P_ID  IN (SELECT     ProductID
											FROM         [#TempTbl])) 
	GROUP BY P_ID, P_Name

	DROP TABLE #TempTbl;

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetMinPriceByProductID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisVersions_GetMinPriceByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Used in the Compare.aspx Page
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisVersions_GetMinPriceByProductID](@LANG_ID as tinyint, @P_ID as int, @CG_ID as smallint)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	SELECT     distinct P_ID, P_Name, dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID, @CG_ID) as P_Price
	FROM         vKartrisProductsVersions
	WHERE     (LANG_ID = @LANG_ID) AND (P_ID = @P_ID)
	GROUP BY P_ID, P_Name

END


' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisVersions_GetProductName]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisVersions_GetProductName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisVersions_GetProductName] 
(
	-- Add the parameters for the function here
	@V_ID as bigint,
	@LANG_ID as tinyint
)
RETURNS nvarchar(20)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(20);

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = P_Name FROM vKartrisProductsVersions WHERE V_ID = @V_ID AND LANG_ID = @LANG_ID ;

	-- Return the result of the function
	RETURN @Result

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisDB_GetAttributesToCompare]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisDB_GetAttributesToCompare]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisDB_GetAttributesToCompare]
(	@P_List as nvarchar(100),
	@LANG_ID as tinyint,
	@CG_ID as smallint
)
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @P_List nvarchar(50);
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	--SET @P_List = ''113,1,114,94, 90'';
	SET @SIndx = 0;

	CREATE TABLE #TempTbl(ProductID int)


	WHILE @SIndx <= LEN(@P_List)
	BEGIN
		
		SET @CIndx = CHARINDEX('','', @P_List, @SIndx)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@P_List)+1 END
		--Print ''SIndx:'' + CAST(@SIndx as nvarchar(10)) + '', CIndx:'' + CAST(@CIndx as nvarchar(10)) + ''-'' + SUBSTRING(@P_List, @SIndx, @CIndx - @SIndx);
		INSERT INTO #TempTbl VALUES (CAST(SUBSTRING(@P_List, @SIndx, @CIndx - @SIndx) as int));
		SET @SIndx = @CIndx + 1;

	END

	SELECT DISTINCT vKartrisProductsVersions.P_ID, vKartrisProductsVersions.P_Name, 
			dbo.fnKartrisProduct_GetMinPriceWithCG(vKartrisProductsVersions.P_ID, @CG_ID) as P_Price, vKartrisTypeAttributes.ATTRIB_ID 
		  , vKartrisTypeAttributes.ATTRIB_Name, vKartrisTypeAttributeValues.ATTRIBV_Value, 
		  vKartrisTypeAttributes.ATTRIB_Compare
	FROM         vKartrisTypeAttributes INNER JOIN
						  vKartrisTypeAttributeValues ON vKartrisTypeAttributes.ATTRIB_ID = vKartrisTypeAttributeValues.ATTRIBV_AttributeID RIGHT OUTER JOIN
						  vKartrisProductsVersions ON vKartrisTypeAttributeValues.ATTRIBV_ProductID = vKartrisProductsVersions.P_ID
	WHERE     (vKartrisProductsVersions.LANG_ID = @LANG_ID) AND (vKartrisProductsVersions.P_ID IN
							  (SELECT     ProductID
								FROM         [#TempTbl])) AND (vKartrisTypeAttributes.ATTRIB_Compare <> ''n'' OR
								vKartrisTypeAttributes.ATTRIB_Compare IS NULL)
	--GROUP BY vKartrisProductsVersions.P_ID, vKartrisProductsVersions.P_Name, vKartrisTypeAttributes.ATTRIB_ID,
	--		 vKartrisTypeAttributes.ATTRIB_Name, vKartrisTypeAttributeValues.ATTRIBV_Value, 
	--					  vKartrisTypeAttributes.ATTRIB_Compare




	DROP TABLE #TempTbl;

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisDB_Search]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisDB_Search]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisDB_Search]
(	
	@SearchText as nvarchar(500),
	@keyWordsList as nvarchar(500),
	@LANG_ID as tinyint,
	@PageIndex as tinyint, -- 0 Based index
	@RowsPerPage as tinyint,
	@TotalResultProducts as int OUTPUT,
	@MinPrice as real,
	@MaxPrice as real,
	@Method as nvarchar(10),
	@CustomerGroupID as smallint
)
AS
BEGIN
SET NOCOUNT ON;
	
	SET NOCOUNT ON;
	
	-----------------------
	-- Variable Declaration
	-----------------------
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @Keyword as nvarchar(150);
	DECLARE @Counter as int;
	
	DECLARE @NoOfVersions as bigint;
	SELECT @NoOfVersions = Count(1)	FROM tblKartrisVersions;
	
	-- Include Products and Attributes if no. of versions > 10,000
	-- Include Versions, Products and Attributes if no. of versions <= 10,000
	DECLARE @DataToSearch as nvarchar(100);
	IF @NoOfVersions > 10000 BEGIN
		SET @DataToSearch = ''(LE_TypeID IN (2,14) AND LE_FieldID IN (1,2,5))''
	END ELSE BEGIN
		SET @DataToSearch = ''(LE_TypeID IN (1,2,14) AND LE_FieldID IN (1,2,5))''
	END
		
	DECLARE @ExactCriteriaNoNoise as nvarchar(500);
	SET @ExactCriteriaNoNoise = Replace(@keyWordsList, '','', '' '');
	
	IF @Method = ''exact'' BEGIN	
		-- Searching value of LanguageElements - Add results to search helper (LIKE Operator)
		EXECUTE(''
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, '''''' + @KeyWord + ''''''
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = '' + @LANG_ID +'' AND '' + @DataToSearch + ''
					AND (	(LE_Value like ''''% '' + @SearchText + '' %'''')
						OR	(LE_Value like '''''' + @SearchText + '' %'''')
						OR	(LE_Value like ''''% '' + @SearchText + '''''')
						OR	(LE_Value = '''''' + @SearchText + '''''')
						)'');
						
		-- Searching version code of Versions - Add results to search helper				
		EXECUTE(''
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, '''''' + @SearchText + ''''''
		FROM         tblKartrisVersions
		WHERE     (V_Live = 1) AND (V_CodeNumber LIKE '''''' + @SearchText + ''%'''')'' );	
	END ELSE BEGIN
		-- Loop through out the list of keywords and search each keyword
		SET @SIndx = 0;	SET @Counter = 0;
		WHILE @SIndx <= LEN(@keyWordsList)	BEGIN
		SET @Counter = @Counter + 1;	-- keywords counter
		SET @CIndx = CHARINDEX('','', @keyWordsList, @SIndx)	-- Next keyword starting index (1-Based Index)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@keyWordsList)+ 1 END	-- If no more keywords, set next starting index to not exist
		SET @KeyWord = SUBSTRING(@keyWordsList, @SIndx, @CIndx - @SIndx)
		
		-- The next starting index
		SET @SIndx = @CIndx + 1;
			
		-- Searching value of LanguageElements - Add results to search helper (LIKE Operator)
		EXECUTE(''
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, 
					dbo.fnKartrisLanguageElement_GetProductID(LE_TypeID, LE_ParentID) , 0, 100/LE_FieldID, '''''' + @KeyWord + ''''''
		FROM       tblKartrisLanguageElements 
		WHERE	LE_LanguageID = '' + @LANG_ID +'' AND '' + @DataToSearch + ''
					AND (	(LE_Value like ''''% '' + @KeyWord + '' %'''')
						OR	(LE_Value like '''''' + @KeyWord + '' %'''')
						OR	(LE_Value like ''''% '' + @KeyWord + '''''')
						OR	(LE_Value = '''''' + @KeyWord + '''''')
						)'');
						
		-- Searching version code of Versions - Add results to search helper				
		EXECUTE(''
		INSERT INTO tblKartrisSearchHelper
		SELECT TOP(1000) @@SPID, 1, NULL, V_ID, NULL, V_ProductID, V_Price, 0, '''''' + @KeyWord + ''''''
		FROM         tblKartrisVersions
		WHERE     (V_Live = 1) AND (V_CodeNumber LIKE '''''' + @Keyword + ''%'''')'' );	
	END 
	END
	
	-- (Advanced Search) Exclude products that are not between the price range
	IF @MinPrice <> -1 AND @MaxPrice <> -1	BEGIN
		UPDATE tblKartrisSearchHelper
		SET SH_Price = dbo.fnKartrisProduct_GetMinPriceWithCG(SH_ProductID, @CustomerGroupID)
		WHERE SH_SessionID = @@SPID;
		DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID = @@SPID AND SH_Price NOT BETWEEN @MinPrice AND @MaxPrice;
	END

	-- Exclude products in which their categories are not live
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID
		AND SH_ProductID NOT IN (SELECT distinct tblKartrisProductCategoryLink.PCAT_ProductID
								 FROM	tblKartrisCategories INNER JOIN tblKartrisProductCategoryLink 
										ON tblKartrisCategories.CAT_ID = tblKartrisProductCategoryLink.PCAT_CategoryID
								 WHERE  tblKartrisCategories.CAT_Live = 1)

	-- Exclude products that are Not Live or that are not belongs to customer group
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID 
		AND SH_ProductID IN (	SELECT P_ID 
								FROM dbo.tblKartrisProducts 
								WHERE P_Live = 0 OR (P_CustomerGroupID IS NOT NULL AND P_CustomerGroupID <> @CustomerGroupID)); 
	
	-- Exclude products that are not resulted from non-searchable attributes
	DELETE FROM tblKartrisSearchHelper
	WHERE SH_SessionID = @@SPID AND SH_TypeID = 14 
			AND SH_ParentID IN (SELECT tblKartrisAttributeValues.ATTRIBV_ID
							FROM tblKartrisAttributes INNER JOIN tblKartrisAttributeValues 
							ON tblKartrisAttributes.ATTRIB_ID = tblKartrisAttributeValues.ATTRIBV_AttributeID
							WHERE   tblKartrisAttributes.ATTRIB_ShowSearch = 0);
					
	-- Update the scores of the products with exact match			
	IF @Counter > 1	BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (400) 
		WHERE SH_SessionID = @@SPID AND ((SH_TextValue like ''%'' + @ExactCriteriaNoNoise + ''%'') OR (SH_TextValue like ''%'' + @SearchText + ''%''));
	END
	
	-- Update the scores according to number of versions
	IF @NoOfVersions > 10000 BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30) WHERE SH_SessionID = @@SPID AND SH_FieldID = 2;
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (200) WHERE SH_SessionID = @@SPID AND SH_FieldID IN (1, 5);
	END	ELSE BEGIN
		UPDATE tblKartrisSearchHelper SET SH_Score = SH_Score + (30 * SH_TypeID) WHERE SH_SessionID = @@SPID AND SH_TypeID IN (1, 2);
	END
	
	-- Set the starting and ending row numbers
	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;	

	-- Search method ''ANY'' - Default Search and ''EXACT'' - Advanced Search
	IF @Method = ''any'' OR @Method = ''exact'' BEGIN
		SELECT @TotalResultProducts =  Count(DISTINCT SH_ProductID) FROM tblKartrisSearchHelper WHERE SH_SessionID = @@SPID;
		
		WITH SearchResult as
		(
			SELECT ROW_NUMBER() OVER (ORDER BY TotalScore DESC) as Row, 
					ProductID, TotalScore
			FROM (	SELECT 
						CASE 
						WHEN T1.SH_ProductID IS NULL THEN T2.SH_ProductID
						ELSE T1.SH_ProductID
						END AS ProductID,
						CASE 
						WHEN Score1 IS NULL THEN Score2
						WHEN Score2 IS NULL THEN Score1
						ELSE (Score1 + Score2) 
						END AS TotalScore
					FROM (
							SELECT SH_SessionID, SH_ProductID, Sum(SH_Score) as Score1
							FROM tblKartrisSearchHelper 
							WHERE SH_TypeID = 2 OR SH_TypeID = 14
							GROUP BY SH_SessionID, SH_ProductID
							HAVING SH_SessionID = @@SPID
						) T1 
						FULL OUTER JOIN 
						(
							SELECT SH_SessionID, SH_ProductID, Max(SH_Score) as Score2
							FROM tblKartrisSearchHelper 
							WHERE SH_TypeID = 1
							Group BY SH_SessionID, SH_ProductID
							HAVING SH_SessionID = @@SPID
						) T2 
						ON T1.SH_ProductID = T2.SH_ProductID
				) T3
		)
		SELECT Row, P_ID, P_Name, dbo.fnKartrisDB_TruncateDescription(P_Desc) as P_Desc, 
				dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID, @CustomerGroupID) as MinPrice, TotalScore, 
				dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, P_ID) AS KeywordList
		FROM SearchResult INNER JOIN dbo.vKartrisTypeProducts ON SearchResult.ProductID = dbo.vKartrisTypeProducts.P_ID
		WHERE vKartrisTypeProducts.LANG_ID = @LANG_ID AND ROW BETWEEN @StartRowNumber AND @EndRowNumber
		GROUP BY Row, P_ID, P_Name, P_Desc, TotalScore
		ORDER BY TotalScore DESC
	END
	
	-- Search method ''ALL'' - Advanced Search
	IF @Method = ''all'' BEGIN
	
		DECLARE @SortedSearchKeywords as nvarchar(max);
		SELECT @SortedSearchKeywords = COALESCE(@SortedSearchKeywords + '','', '''') + T._ID
		FROM (SELECT TOP(500) _ID FROM dbo.fnTbl_SplitStrings(@keyWordsList) ORDER BY _ID) AS T;

		SELECT @TotalResultProducts =  Count(DISTINCT SH_ProductID) FROM tblKartrisSearchHelper 
		WHERE SH_SessionID = @@SPID AND @SortedSearchKeywords = dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, SH_ProductID);
		
		WITH SearchResult as
		(
			SELECT ROW_NUMBER() OVER (ORDER BY TotalScore DESC) as Row, 
					ProductID, TotalScore
			FROM (	SELECT 
						CASE 
						WHEN T1.SH_ProductID IS NULL THEN T2.SH_ProductID
						ELSE T1.SH_ProductID
						END AS ProductID,
						CASE 
						WHEN Score1 IS NULL THEN Score2
						WHEN Score2 IS NULL THEN Score1
						ELSE (Score1 + Score2) 
						END AS TotalScore
					FROM (
							SELECT SH_SessionID, SH_ProductID, Sum(SH_Score) as Score1
							FROM tblKartrisSearchHelper 
							WHERE SH_TypeID = 2 OR SH_TypeID = 14
							GROUP BY SH_SessionID, SH_ProductID
							HAVING SH_SessionID = @@SPID AND @SortedSearchKeywords = dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, SH_ProductID)
						) T1 
						FULL OUTER JOIN 
						(
							SELECT SH_SessionID, SH_ProductID, Max(SH_Score) as Score2
							FROM tblKartrisSearchHelper 
							WHERE SH_TypeID = 1
							Group BY SH_SessionID, SH_ProductID
							HAVING SH_SessionID = @@SPID AND @SortedSearchKeywords = dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID, SH_ProductID)
						) T2 
						ON T1.SH_ProductID = T2.SH_ProductID
				) T3
		)
		SELECT Row, P_ID, P_Name, dbo.fnKartrisDB_TruncateDescription(P_Desc) as P_Desc, 
				dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID, @CustomerGroupID) as MinPrice, TotalScore, 
				dbo.fnKartrisSearchHelper_GetKeywordsListByProduct(@@SPID,P_ID) AS KeywordList
		FROM SearchResult INNER JOIN dbo.vKartrisTypeProducts ON SearchResult.ProductID = dbo.vKartrisTypeProducts.P_ID
		WHERE vKartrisTypeProducts.LANG_ID = @LANG_ID AND ROW BETWEEN @StartRowNumber AND @EndRowNumber
		GROUP BY Row, P_ID, P_Name, P_Desc, TotalScore
		ORDER BY TotalScore DESC
		
	END
	
	-- Clear the result of the current search
	DELETE FROM tblKartrisSearchHelper WHERE SH_SessionID=@@SPID;
	
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetMinPriceWithCG]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetMinPriceWithCG]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisProducts_GetMinPriceWithCG](@P_ID as int, @CG_ID as smallint, @MinPrice as real OUTPUT)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	SELECT  @MinPrice = dbo.fnKartrisProduct_GetMinPriceWithCG(@P_ID, @CG_ID);

END' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetMinPriceByProductID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetMinPriceByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisProducts_GetMinPriceByProductID](@LANG_ID as tinyint, @P_ID as int, @CG_ID as smallint)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	SELECT     distinct P_ID, P_Name, dbo.fnKartrisProduct_GetMinPriceWithCG(P_ID, @CG_ID) as P_Price
	FROM         dbo.vKartrisTypeProducts
	WHERE     (LANG_ID = @LANG_ID) AND (P_ID = @P_ID)
	GROUP BY P_ID, P_Name

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetFeaturedProducts]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetFeaturedProducts]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Medz
-- Reworked:	Paul
-- Create date: 02/10/2008 13:23:42
-- Description:	Replaces the [spKartris_PROD_Specials]
-- =============================================

CREATE PROCEDURE [dbo].[spKartrisProducts_GetFeaturedProducts]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SELECT     P_ID, LANG_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType, P_Type, dbo.fnKartrisProduct_GetMinPrice(P_ID) AS MinPrice, P_Name, P_Desc, P_StrapLine, P_PageTitle, P_Reviews, 
					  P_Featured, P_CustomerGroupID, MIN(T_Taxrate) AS MinTax
	FROM         vKartrisProductsVersions
	WHERE     (P_Featured <> 0) AND (P_CustomerGroupID IS NULL) AND (V_Live = 1) AND (CAT_Live = 1) AND (P_Live = 1)
	GROUP BY P_ID, LANG_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType, P_Type, P_Name, P_Desc, P_StrapLine, P_Featured, P_CustomerGroupID, P_Reviews, P_PageTitle
	ORDER BY P_Featured DESC

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetByProductID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- ===================================================
-- Author:		Medz
-- Create date: 02/12/2008 13:53:30
-- Description:	Replaces the [spKartris_PROD_Select]
-- ===================================================
CREATE PROCEDURE [dbo].[spKartrisProducts_GetByProductID]
(
	@P_ID int,
	@LANG_ID tinyint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT     P_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType, P_Type, MIN(V_Price) AS MinPrice, P_Name, P_Desc, P_StrapLine, P_PageTitle, P_Reviews, 
					  P_Featured, P_CustomerGroupID, MIN(T_Taxrate) AS MinTax
FROM         vKartrisProductsVersions
WHERE     (P_ID = @P_ID) AND (LANG_ID = @LANG_ID) AND (V_Live = 1) AND (V_Type = ''b'' OR V_Type = ''v'' ) AND (CAT_Live = 1) AND (P_Live = 1)
GROUP BY P_ID, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType, P_Type, P_Name, P_Desc, P_StrapLine, P_Featured, P_CustomerGroupID, LANG_ID, P_Reviews, P_PageTitle
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasketValues_GetBasketItems]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasketValues_GetBasketItems]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spKartrisBasketValues_GetBasketItems]
(
	@Session_ID bigint,
	@LANG_ID tinyint
)
AS
	SET NOCOUNT OFF;
SELECT DISTINCT 
					  A.LANG_ID, tblKartrisBasketValues.BV_ParentType, tblKartrisBasketValues.BV_ParentID, tblKartrisBasketValues.BV_ID, tblKartrisBasketValues.BV_VersionID, 
					  tblKartrisBasketValues.BV_Quantity, A.P_ID, A.P_Name, A.V_Name, A.V_Price * tblKartrisBasketValues.BV_Quantity AS TotalPrice, 
					  COUNT(tblKartrisBasketOptionValues.BSKTOPT_OptionID) AS NoOfOptions, tblKartrisBasketValues.BV_CustomText, 
					  dbo.fnKartrisBasketOptionValues_GetOptionsTotalPrice(A.P_ID,tblKartrisBasketValues.BV_VersionID,tblKartrisBasketValues.BV_ParentID,tblKartrisBasketValues.BV_ID) AS OptionsPrice
FROM         tblKartrisBasketValues INNER JOIN
						  (SELECT DISTINCT LANG_ID, V_ID, P_ID, P_Name, V_Name, V_Price
							FROM          vKartrisProductsVersions) AS A ON tblKartrisBasketValues.BV_VersionID = A.V_ID LEFT OUTER JOIN
					  tblKartrisBasketOptionValues ON tblKartrisBasketValues.BV_ID = tblKartrisBasketOptionValues.BSKTOPT_BasketValueID
GROUP BY A.LANG_ID, tblKartrisBasketValues.BV_ParentType, tblKartrisBasketValues.BV_ParentID, tblKartrisBasketValues.BV_ID, tblKartrisBasketValues.BV_VersionID, 
					  tblKartrisBasketValues.BV_Quantity, A.P_ID, A.P_Name, A.V_Name, A.V_Price * tblKartrisBasketValues.BV_Quantity, tblKartrisBasketValues.BV_CustomText
HAVING      (tblKartrisBasketValues.BV_ParentType = ''b'') AND (tblKartrisBasketValues.BV_ParentID = @Session_ID) AND (A.LANG_ID = @LANG_ID)
ORDER BY tblKartrisBasketValues.BV_ID



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetSummaryByCatID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetSummaryByCatID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Replaces the [spKartris_PROD_Select]
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisProducts_GetSummaryByCatID](@CAT_ID as int, @LANG_ID as tinyint)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	SELECT     P_ID, P_Name, dbo.fnKartrisDB_TruncateDescription(P_Desc) as P_Desc, P_StrapLine, P_OrderVersionsBy, P_VersionsSortDirection,
				 P_VersionDisplayType, P_Featured, P_Type, dbo.fnKartrisProduct_GetMinPrice(P_ID) AS MinPrice, MIN(T_Taxrate) AS MinTaxRate
	FROM         vKartrisProductsVersions
	WHERE     (CAT_ID = @CAT_ID) AND (LANG_ID = @LANG_ID) AND (V_Live = 1) 
	GROUP BY P_ID, P_Name, P_Desc, P_StrapLine, P_OrderVersionsBy, P_VersionsSortDirection, P_VersionDisplayType,
				P_Featured, P_Type
	ORDER BY P_Featured DESC, P_ID DESC
	   
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetSpecials]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetSpecials]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Medz
-- Create date: 02/10/2008 13:23:42
-- Description:	Replaces the [spKartris_PROD_Specials]
-- =============================================

CREATE PROCEDURE [dbo].[spKartrisProducts_GetSpecials]
(
	@LANG_ID tinyint
)
AS
BEGIN
	SELECT     P_ID, P_OrderVersionsBy, P_VersionDisplayType, P_Type, dbo.fnKartrisProduct_GetMinPrice(P_ID) AS MinPrice, P_Name, P_Desc, P_StrapLine, MIN(T_Taxrate) AS MinTax
	FROM         vKartrisProductsVersions
	WHERE     (LANG_ID = @LANG_ID) AND (V_Live = 1) AND (P_Live = 1)
	GROUP BY P_ID, P_OrderVersionsBy, P_VersionDisplayType, P_Type, P_Name, P_Desc, P_StrapLine, P_Featured
	HAVING      (P_Featured = 1)
END

' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetRowsBetweenByCatID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisProducts_GetRowsBetweenByCatID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Replaces "spKartris_PROD_SelectByCAT"
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisProducts_GetRowsBetweenByCatID]
	(
	@LANG_ID as tinyint,
	@CAT_ID as int,
	@PageIndex as tinyint, -- 0 Based index
	@RowsPerPage as smallint,
	@CGroupID as smallint
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	-- Insert statements for procedure here

	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;
	
	DECLARE @OrderBy as nvarchar(50), @OrderDirection as char(1)
	SELECT @OrderBy = CAT_OrderProductsBy, @OrderDirection = CAT_ProductsSortDirection
	FROM dbo.tblKartrisCategories
	WHERE CAT_ID = @CAT_ID;

	IF @OrderBy is NULL OR @OrderBy = ''d''
	BEGIN 
		SELECT @OrderBy = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = ''frontend.products.display.sortdefault'';
	END;
	IF @OrderDirection is NULL OR @OrderDirection = '''' BEGIN 
		SELECT @OrderDirection = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = ''frontend.products.display.sortdirection'';
	END;
	
		With ProductList AS 
		(
			SELECT	CASE 
					WHEN (@OrderBy = ''P_ID'' AND @OrderDirection = ''A'') THEN	ROW_NUMBER() OVER (ORDER BY P_ID ASC) 
					WHEN (@OrderBy = ''P_ID'' AND @OrderDirection = ''D'') THEN	ROW_NUMBER() OVER (ORDER BY P_ID DESC) 
					WHEN (@OrderBy = ''P_Name'' AND @OrderDirection = ''A'') THEN ROW_NUMBER() OVER (ORDER BY P_Name ASC) 
					WHEN (@OrderBy = ''P_Name'' AND @OrderDirection = ''D'') THEN ROW_NUMBER() OVER (ORDER BY P_Name DESC) 
					WHEN (@OrderBy = ''P_DateCreated'' AND @OrderDirection = ''A'') THEN ROW_NUMBER() OVER (ORDER BY P_DateCreated ASC) 
					WHEN (@OrderBy = ''P_DateCreated'' AND @OrderDirection = ''D'') THEN ROW_NUMBER() OVER (ORDER BY P_DateCreated DESC) 
					WHEN (@OrderBy = ''P_LastModified'' AND @OrderDirection = ''A'') THEN ROW_NUMBER() OVER (ORDER BY P_LastModified ASC) 
					WHEN (@OrderBy = ''P_LastModified'' AND @OrderDirection = ''D'') THEN ROW_NUMBER() OVER (ORDER BY P_LastModified DESC) 
					WHEN (@OrderBy = ''PCAT_OrderNo'' AND @OrderDirection = ''A'') THEN ROW_NUMBER() OVER (ORDER BY PCAT_OrderNo ASC) 
					WHEN (@OrderBy = ''PCAT_OrderNo'' AND @OrderDirection = ''D'') THEN ROW_NUMBER() OVER (ORDER BY PCAT_OrderNo DESC) 
					END AS Row,
					vKartrisTypeProducts.P_ID, dbo.fnKartrisProduct_GetMinPriceWithCG(vKartrisTypeProducts.P_ID, @CGroupID) AS MinPrice, MIN(tblKartrisTaxRates.T_Taxrate) AS MinTaxRate, vKartrisTypeProducts.P_Name, 
										  dbo.fnKartrisDB_TruncateDescription(vKartrisTypeProducts.P_Desc) AS P_Desc, vKartrisTypeProducts.P_StrapLine, vKartrisTypeProducts.P_VersionDisplayType, 
										  vKartrisTypeProducts.P_DateCreated, vKartrisTypeProducts.P_LastModified, tblKartrisProductCategoryLink.PCAT_OrderNo
					FROM         tblKartrisProductCategoryLink INNER JOIN
										  vKartrisTypeProducts ON tblKartrisProductCategoryLink.PCAT_ProductID = vKartrisTypeProducts.P_ID INNER JOIN
										  tblKartrisVersions ON vKartrisTypeProducts.P_ID = tblKartrisVersions.V_ProductID LEFT OUTER JOIN
										  tblKartrisTaxRates ON tblKartrisTaxRates.T_ID = tblKartrisVersions.V_Tax
					WHERE     (tblKartrisVersions.V_Live = 1) AND (tblKartrisVersions.V_Type = ''b'' OR tblKartrisVersions.V_Type = ''v'' ) AND (vKartrisTypeProducts.LANG_ID = @LANG_ID) AND (vKartrisTypeProducts.P_Live = 1) AND 
										  (tblKartrisProductCategoryLink.PCAT_CategoryID = @CAT_ID) AND (vKartrisTypeProducts.P_CustomerGroupID IS NULL OR
										  vKartrisTypeProducts.P_CustomerGroupID = @CGroupID)
					GROUP BY vKartrisTypeProducts.P_Name, vKartrisTypeProducts.P_Desc, vKartrisTypeProducts.P_StrapLine, vKartrisTypeProducts.P_ID, 
										  vKartrisTypeProducts.P_VersionDisplayType, vKartrisTypeProducts.P_DateCreated, vKartrisTypeProducts.P_LastModified, 
										  tblKartrisProductCategoryLink.PCAT_OrderNo
			
		)

		SELECT *
		FROM ProductList
		WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber
		ORDER BY Row ASC
	
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetStockLevel]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisVersions_GetStockLevel]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_GetStockLevel]
(
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT        V_ID, V_Name, V_CodeNumber, V_Quantity, V_QuantityWarnLevel, P_SupplierID, P_ID
FROM           dbo.vKartrisProductsVersions
WHERE        (LANG_ID = @LANG_ID) AND (V_Quantity <= V_QuantityWarnLevel) AND (V_QuantityWarnLevel <> 0)
ORDER BY V_Quantity , V_QuantityWarnLevel 

' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_Delete]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	replaces [spKartris_VER_GetBaseVersion]
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_Delete](@ProductID as bigint)
AS
BEGIN
	SET NOCOUNT ON;

	EXEC [dbo].[_spKartrisVersions_DeleteByProduct] 
			@P_ID = @ProductID,
			@DownloadFiles='''';	

EXEC [dbo].[_spKartrisMediaLinks_DeleteByParent] 
			@ParentID = @ProductID, 
			@ParentType = ''p'';
			
	EXEC [dbo].[_spKartrisPromotions_DeleteByParent] 
			@ParentID = @ProductID, 
			@ParentType = ''p'';
	
Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;		
	DELETE FROM tblKartrisLanguageElements
	WHERE     (LE_TypeID = 2) AND (LE_ParentID = @ProductID);
Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;		

Disable Trigger trigKartrisProductCategoryLink_DML ON tblKartrisProductCategoryLink;	
	DELETE FROM tblKartrisProductCategoryLink
	WHERE     (PCAT_ProductID = @ProductID);
Enable Trigger trigKartrisProductCategoryLink_DML ON tblKartrisProductCategoryLink;	

Disable Trigger trigKartrisProductOptionGroupLink_DML ON tblKartrisProductOptionGroupLink;	
	DELETE FROM tblKartrisProductOptionGroupLink
	WHERE     (P_OPTG_ProductID = @ProductID);
Enable Trigger trigKartrisProductOptionGroupLink_DML ON tblKartrisProductOptionGroupLink;	
	
Disable Trigger trigKartrisProductOptionLink_DML ON tblKartrisProductOptionLink;	
	DELETE FROM tblKartrisProductOptionLink
	WHERE     (P_OPT_ProductID = @ProductID);
Enable Trigger trigKartrisProductOptionLink_DML ON tblKartrisProductOptionLink;	

Disable Trigger trigKartrisRelatedProducts_DML ON tblKartrisRelatedProducts;	
	DELETE FROM tblKartrisRelatedProducts
	WHERE     (RP_ParentID = @ProductID) OR (RP_ChildID = @ProductID);
Enable Trigger trigKartrisRelatedProducts_DML ON tblKartrisRelatedProducts;	

Disable Trigger trigKartrisReviews_DML ON tblKartrisReviews;	
	DELETE FROM tblKartrisReviews
	WHERE	(REV_ProductID = @ProductID);
Enable Trigger trigKartrisReviews_DML ON tblKartrisReviews;

Disable Trigger trigKartrisAttributeValues_DML ON dbo.tblKartrisAttributeValues;	
	DELETE FROM dbo.tblKartrisAttributeValues
	WHERE	(ATTRIBV_ProductID = @ProductID);
Enable Trigger trigKartrisAttributeValues_DML ON dbo.tblKartrisAttributeValues;	

Disable Trigger trigKartrisProducts_DML ON tblKartrisProducts;	
	DELETE FROM dbo.tblKartrisProducts
	WHERE P_ID = @ProductID;
Enable Trigger trigKartrisProducts_DML ON tblKartrisProducts;	

IF @ProductID <> 0 AND @ProductID NOT IN (SELECT DELETED_ID FROM dbo.tblKartrisDeletedItems WHERE Deleted_Type = ''p'') BEGIN
	DISABLE Trigger trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
		DECLARE @Timeoffset as int;
		set @Timeoffset = CAST(dbo.fnKartrisConfig_GetValue(''general.timeoffset'') as int);
		INSERT INTO dbo.tblKartrisDeletedItems VALUES(@ProductID, ''p'', NULL, DateAdd(hour, @Timeoffset, GetDate()));
	ENABLE Trigger trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;	
END

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisPromotions_GetAllDetails]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisPromotions_GetAllDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisPromotions_GetAllDetails](@LANG_ID as tinyint)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT	tblKartrisPromotions.PROM_ID, tblKartrisPromotions.PROM_StartDate, tblKartrisPromotions.PROM_EndDate, 
			tblKartrisPromotionParts.PP_PartNo, tblKartrisPromotionParts.PP_Type, tblKartrisPromotionParts.PP_Value, 
			tblKartrisPromotionParts.PP_ItemType, tblKartrisPromotionParts.PP_ItemID, tblKartrisPromotions.PROM_Live, 
			PP_ItemName =	CASE tblKartrisPromotionParts.PP_ItemType
							WHEN ''v'' THEN		dbo.fnKartrisVersions_GetProductName(PP_ItemID, @LANG_ID) 
											+ '' ('' + dbo.fnKartrisVersions_GetName(PP_ItemID, @LANG_ID) + '')''
							WHEN ''p'' THEN		dbo.fnKartrisProducts_GetName(PP_ItemID, @LANG_ID)
							WHEN ''c'' THEN 	dbo.fnKartrisCategories_GetName(PP_ItemID, @LANG_ID)
							ELSE ''Name NOT Found .. !!''
						END
	FROM	tblKartrisPromotionParts INNER JOIN tblKartrisPromotions ON tblKartrisPromotionParts.PROM_ID = tblKartrisPromotions.PROM_ID 
	WHERE	tblKartrisPromotions.PROM_ID 
			IN 
			(
				SELECT	distinct tblKartrisPromotions.PROM_ID
				FROM	tblKartrisPromotionParts INNER JOIN
						tblKartrisPromotions ON tblKartrisPromotionParts.PROM_ID = tblKartrisPromotions.PROM_ID
						
			)
	ORDER BY PROM_ID, PP_PartNo ASC	
   
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_DeleteByCategory]    Script Date: 05/15/2012 16:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisProducts_DeleteByCategory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisProducts_DeleteByCategory](@CategoryID as int)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE productCursor CURSOR FOR 
	SELECT PCAT_ProductID
	FROM dbo.tblKartrisProductCategoryLink
	WHERE PCAT_CategoryID = @CategoryID
		
	DECLARE @ChildProductID as bigint;
	
	OPEN productCursor
	FETCH NEXT FROM productCursor
	INTO @ChildProductID;

	DECLARE @ProductList as nvarchar(250);
	SET @ProductList = '''';

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @ProductList = @ProductList + CAST(@ChildProductID as nvarchar(5)) +  '','';
		
		FETCH NEXT FROM productCursor
		INTO @ChildProductID;

	END

	CLOSE productCursor
	DEALLOCATE productCursor;

	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @ProductIDToDelete as nvarchar(5);
	DECLARE @Counter as int;
	DECLARE @CurrentScore as int;

	SET @SIndx = 0;
	SET @Counter = 0;
	WHILE @SIndx <= LEN(@ProductList)
	BEGIN
		
		SET @Counter = @Counter + 1;
		SET @CIndx = CHARINDEX('','', @ProductList, @SIndx)	-- Next keyword starting index (1-Based Index)
		IF @CIndx = 0 BEGIN SET @CIndx = LEN(@ProductList)+ 1 END	-- If no more keywords, set next starting index to not exist
		SET @ProductIDToDelete = SUBSTRING(@ProductList, @SIndx, @CIndx - @SIndx)
		SET @SIndx = @CIndx + 1;	-- The next starting index
		DECLARE @Product as bigint;
		SET @Product = CAST(@ProductIDToDelete as bigint);
		Disable Trigger trigKartrisProductCategoryLink_DML ON tblKartrisProductCategoryLink;	
			-- delete the link with the selected product
			DELETE FROM tblKartrisProductCategoryLink
			WHERE     (PCAT_CategoryID = @CategoryID) AND (PCAT_ProductID = @Product);
		Enable Trigger trigKartrisProductCategoryLink_DML ON tblKartrisProductCategoryLink;	
		
		DECLARE @NoOfOtherParentCategories as int;
		SET @NoOfOtherParentCategories = 0;
		SELECT @NoOfOtherParentCategories = Count(1)
		FROM dbo.tblKartrisProductCategoryLink
		WHERE (PCAT_ProductID = @Product) AND (PCAT_CategoryID <> @CategoryID)
		
		-- if no other parent categories.
		IF @NoOfOtherParentCategories = 0 
		BEGIN
			EXEC [dbo].[_spKartrisProducts_Delete] 
			@ProductID = @Product;
		END
		-- delete the products, since no other related categories.
		
		
		
	END
	
	
END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetCombinationVersionID_s]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisVersions_GetCombinationVersionID_s]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisVersions_GetCombinationVersionID_s]
(
	@ProductID as int,
	@OptionsList as nvarchar(1000),
	@Return_Value as bigint OUTPUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- need to sort the options list to match the already sorted options
	--@OptionsList
	DECLARE @SortedOptions as nvarchar(max);
	SELECT @SortedOptions = COALESCE(@SortedOptions + '','', '''') + CAST(T._ID as nvarchar(10))
	FROM (	SELECT DISTINCT Top(5000) _ID
			FROM dbo.fnTbl_SplitNumbers(@OptionsList)
			ORDER BY _ID) AS T;

	SELECT @Return_Value = V_ID
	FROM dbo.vKartrisCombinationPrices
	WHERE V_ProductID = @ProductID AND V_OptionsIDs = @SortedOptions;
	
	IF @Return_Value IS NULL BEGIN
		SELECT @Return_Value = V_ID
		FROM tblKartrisVersions
		WHERE V_ProductID = @ProductID AND V_Type = ''b'';
	END
	
	IF @Return_Value IS NULL BEGIN
		SET @Return_Value = 0;
	END
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetCombinationPrice_s]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisVersions_GetCombinationPrice_s]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisVersions_GetCombinationPrice_s]
(
	@ProductID as int,
	@OptionsList as nvarchar(1000),
	@Return_Value as real OUTPUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- need to sort the options'' list to match the already sorted options
	--@OptionsList
	DECLARE @SortedOptions as nvarchar(max);
	SELECT @SortedOptions = COALESCE(@SortedOptions + '','', '''') + CAST(T._ID as nvarchar(10))
	FROM (	SELECT DISTINCT Top(5000) _ID
			FROM dbo.fnTbl_SplitNumbers(@OptionsList)
			ORDER BY _ID) AS T;

	SELECT @Return_Value = V_Price
	FROM dbo.vKartrisCombinationPrices
	WHERE V_ProductID = @ProductID AND V_OptionsIDs = @SortedOptions;
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisPromotions_GetByProductID]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisPromotions_GetByProductID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisPromotions_GetByProductID](@P_ID int, @LANG_ID as tinyint, @NowOffset as datetime, @CP_PromotionID as int)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT	tblKartrisPromotions.PROM_ID, tblKartrisPromotions.PROM_StartDate, tblKartrisPromotions.PROM_EndDate, tblKartrisPromotionParts.PP_PartNo, 
			tblKartrisPromotionParts.PP_Type, tblKartrisPromotionParts.PP_Value, tblKartrisPromotionParts.PP_ItemType, tblKartrisPromotionParts.PP_ItemID, 
			PP_ItemName =	CASE tblKartrisPromotionParts.PP_ItemType
							WHEN ''v'' THEN		dbo.fnKartrisVersions_GetProductName(PP_ItemID, @LANG_ID) 
											+ '' ('' + dbo.fnKartrisVersions_GetName(PP_ItemID, @LANG_ID) + '')''
							WHEN ''p'' THEN		dbo.fnKartrisProducts_GetName(PP_ItemID, @LANG_ID)
							WHEN ''c'' THEN 	dbo.fnKartrisCategories_GetName(PP_ItemID, @LANG_ID)
							ELSE ''Name NOT Found .. !!''
						END
	FROM	tblKartrisPromotionParts INNER JOIN tblKartrisPromotions ON tblKartrisPromotionParts.PROM_ID = tblKartrisPromotions.PROM_ID 
	WHERE	tblKartrisPromotions.PROM_ID 
			IN 
			(
				SELECT	distinct tblKartrisPromotions.PROM_ID
				FROM	tblKartrisPromotionParts INNER JOIN
						tblKartrisPromotions ON tblKartrisPromotionParts.PROM_ID = tblKartrisPromotions.PROM_ID
				WHERE   (@NowOffset BETWEEN tblKartrisPromotions.PROM_StartDate AND tblKartrisPromotions.PROM_EndDate) 
						AND (tblKartrisPromotions.PROM_Live = 1 OR (tblKartrisPromotions.PROM_ID = @CP_PromotionID AND tblKartrisPromotions.PROM_Live = 0))
						AND (		(PP_ItemType = ''p'' AND PP_ItemID = @P_ID) 
								OR	(PP_ItemType = ''v'' AND PP_ItemID IN (SELECT V_ID FROM tblKartrisVersions WHERE V_ProductID = @P_ID)) 
								OR	(PP_ItemType = ''c'' AND PP_ItemID IN (SELECT PCAT_CategoryID FROM tblKartrisProductCategoryLink WHERE PCAT_ProductID = @P_ID))
							)
			)
	ORDER BY PROM_ID, PP_PartNo ASC	
   
END



' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisPromotions_GetAllDetails]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisPromotions_GetAllDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisPromotions_GetAllDetails](@LANG_ID as tinyint,@NowOffset as datetime,@CP_PromotionID as int)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT	tblKartrisPromotions.PROM_ID, tblKartrisPromotions.PROM_MaxQuantity, tblKartrisPromotions.PROM_StartDate, tblKartrisPromotions.PROM_EndDate, tblKartrisPromotionParts.PP_PartNo, 
			tblKartrisPromotionParts.PP_Type, tblKartrisPromotionParts.PP_Value, tblKartrisPromotionParts.PP_ItemType, tblKartrisPromotionParts.PP_ItemID, 
			PP_ItemName =	CASE tblKartrisPromotionParts.PP_ItemType
							WHEN ''v'' THEN		dbo.fnKartrisVersions_GetProductName(PP_ItemID, @LANG_ID) 
											+ '' ('' + dbo.fnKartrisVersions_GetName(PP_ItemID, @LANG_ID) + '')''
							WHEN ''p'' THEN		dbo.fnKartrisProducts_GetName(PP_ItemID, @LANG_ID)
							WHEN ''c'' THEN 	dbo.fnKartrisCategories_GetName(PP_ItemID, @LANG_ID)
							ELSE ''Name NOT Found .. !!''
						END
	FROM	tblKartrisPromotionParts INNER JOIN tblKartrisPromotions ON tblKartrisPromotionParts.PROM_ID = tblKartrisPromotions.PROM_ID 
	WHERE	tblKartrisPromotions.PROM_ID 
			IN 
			(
				SELECT DISTINCT vKartrisTypePromotions.PROM_ID
				FROM         tblKartrisPromotionParts INNER JOIN
									  vKartrisTypePromotions ON tblKartrisPromotionParts.PROM_ID = vKartrisTypePromotions.PROM_ID
				WHERE     (@NowOffset BETWEEN vKartrisTypePromotions.PROM_StartDate AND vKartrisTypePromotions.PROM_EndDate) AND (vKartrisTypePromotions.PROM_Live = 1 OR (vKartrisTypePromotions.PROM_ID = @CP_PromotionID AND vKartrisTypePromotions.PROM_Live = 0)) AND 
									  (vKartrisTypePromotions.LANG_ID = @LANG_ID)
						
			)
	ORDER BY PROM_ID, PP_PartNo ASC	
   
END



' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnKartrisBasketOptionValues_GetCombinationPrice]    Script Date: 05/15/2012 16:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnKartrisBasketOptionValues_GetCombinationPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	Used in spKartrisBasketValues_GetMiniBasket
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisBasketOptionValues_GetCombinationPrice] 
(
	@ProductID as int,
	@BV_ID as bigint	
)
RETURNS real
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result real;

	DECLARE @SortedOptions as nvarchar(max);
	SELECT @SortedOptions = COALESCE(@SortedOptions + '','', '''') + CAST(T.BSKTOPT_OptionID as nvarchar(10))
	FROM (SELECT  DISTINCT TOP(1000) BSKTOPT_OptionID
		  FROM    tblKartrisBasketOptionValues
		  WHERE   BSKTOPT_BasketValueID = @BV_ID
		  ORDER BY BSKTOPT_OptionID) AS T;
			
	SELECT @Result = V_Price
	FROM dbo.vKartrisCombinationPrices
	WHERE V_ProductID = @ProductID AND V_OptionsIDs = @SortedOptions;

	IF @Result is NULL	BEGIN
		SET @Result = 0;
	END
	-- Return the result of the function
	RETURN @Result

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_GetPromotions]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasket_GetPromotions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Joseph
-- Create date: 26/May/2008
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_GetPromotions] (
	@intLanguageID int
) AS
BEGIN

	SET NOCOUNT ON;

	select *,PP_ItemName =CASE PP_ItemType
							WHEN ''v'' THEN		dbo.fnKartrisVersions_GetProductName(PP_ItemID, @intLanguageID) 
											+ '' ('' + dbo.fnKartrisVersions_GetName(PP_ItemID, @intLanguageID) + '')''
							WHEN ''p'' THEN		dbo.fnKartrisProducts_GetName(PP_ItemID, @intLanguageID)
							WHEN ''c'' THEN 	dbo.fnKartrisCategories_GetName(PP_ItemID, @intLanguageID)
							ELSE ''Name NOT Found .. !!''
						  END
	from (
		select PP_ItemID as V_ID,* from tblKartrisPromotionParts 
			where PP_PartNo=''a'' and PP_ItemType=''v''
		union
		select V.V_ID,PP.* from tblKartrisPromotionParts PP
			inner join tblKartrisVersions V on PP.PP_ItemID=V.V_ProductID
			where PP.PP_PartNo=''a'' and PP_ItemType=''p''
		union
		select distinct V.V_ID,PP.* from tblKartrisPromotionParts PP
			inner join tblKartrisProductCategoryLink PCL on PP.PP_ItemID=PCL.PCAT_CategoryID
			inner join tblKartrisVersions V on PCL.PCAT_ProductID=V.V_ProductID
			where PP.PP_PartNo=''a'' and PP_ItemType=''c''
	) J
	inner join tblKartrisPromotions P on P.PROM_ID=J.PROM_ID

END


' 
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasketValues_GetItems]    Script Date: 05/15/2012 16:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spKartrisBasketValues_GetItems]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		Joseph
-- Create date: 8/Apr/08
-- Description:	
-- Remarks:	Optimization Medz - 26/07/2010
-- Re-Optimized: By Mohammad - 13/10/2011 - Combination Prices
-- Re-Modified: By Mohammad - 1/1/2012 - Remove join with base version, so to fix the SKU for combination version
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasketValues_GetItems] (
	@intLanguageID int,
	@intSessionID int
)
AS
BEGIN

SET NOCOUNT ON;

WITH tblBasketValues as
	(	SELECT BV_ID,BV_VersionID,BV_Quantity,BV_CustomText 
		FROM tblKartrisBasketValues 
		WHERE BV_ParentType=''b'' and BV_ParentID=@intSessionID
	)
	SELECT DISTINCT P_ID As ''ProductID'', P_Type As ''ProductType'', T_TaxRate As ''TaxRate'', T_TaxRate2 As ''TaxRate2'',
		dbo.fnKartrisBasket_GetItemWeight(BV_ID, V_ID, P_ID) As ''Weight'', V_RRP As ''RRP'', P_Name As ''ProductName'', V_ID, tblBasketValues.BV_ID,
		V_Name As ''VersionName'', V_CodeNumber As ''CodeNumber'', V_Price As ''Price'', 
		tblBasketValues.BV_Quantity As ''Quantity'', V_QuantityWarnLevel As ''QtyWarnLevel'', V_Quantity,
		V_DownloadType, isnull(BV_CustomText,'''') As ''CustomText'',
		dbo.fnKartrisBasketOptionValues_GetOptionsTotalPrice(P_ID,BV_VersionID,@intSessionID,tblBasketValues.BV_ID) AS OptionsPrice,
		dbo.fnKartrisBasketOptionValues_GetCombinationPrice(P_ID,tblBasketValues.BV_ID) AS CombinationPrice,
		V_CustomizationType, V_CustomizationDesc, V_CustomizationCost, tblBasketValues.BV_VersionID 
	--FROM tblBasketValues INNER JOIN vKartrisProductsVersions ON dbo.fnKartris_GetBaseVersionID(BV_VersionID) = V_ID
	FROM tblBasketValues INNER JOIN vKartrisProductsVersions ON BV_VersionID = V_ID
	WHERE LANG_ID = @intLanguageID
	ORDER BY BV_ID

END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisCategories_Delete]    Script Date: 05/15/2012 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisCategories_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohammad
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisCategories_Delete]
(
	@CAT_ID as int 
)
AS
BEGIN
	
	SET NOCOUNT ON;

	IF @CAT_ID = 0
	BEGIN
		RAISERROR(''Can not delete this category.'', 16, 0);
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
		Disable Trigger trigKartrisCategoryHierarchy_DML ON tblKartrisCategoryHierarchy;
		DELETE FROM tblKartrisCategoryHierarchy
		WHERE  (CH_ChildID = @CAT_ID);
		Enable Trigger trigKartrisCategoryHierarchy_DML ON tblKartrisCategoryHierarchy;

		-- delete related products
		EXEC [dbo].[_spKartrisProducts_DeleteByCategory] 
			@CategoryID = @CAT_ID;
			
		EXEC [dbo].[_spKartrisPromotions_DeleteByParent] 
			@ParentID = @CAT_ID, 
			@ParentType = ''c'';

		-- delete the language elements of the category
		Disable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;
		DELETE FROM tblKartrisLanguageElements
		WHERE     (LE_ParentID = @CAT_ID) AND (LE_TypeID = 3);
		Enable Trigger trigKartrisLanguageElements_DML ON tblKartrisLanguageElements;

		-- delete the record from the category table
		Disable Trigger trigKartrisCategories_DML ON tblKartrisCategories;
		DELETE FROM tblKartrisCategories
		WHERE     (CAT_ID = @CAT_ID);
		Enable Trigger trigKartrisCategories_DML ON tblKartrisCategories;
		
		IF @CAT_ID <> 0 AND @CAT_ID NOT IN (SELECT DELETED_ID FROM dbo.tblKartrisDeletedItems WHERE Deleted_Type = ''c'') BEGIN
			DISABLE Trigger trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
				DECLARE @Timeoffset as int;
				set @Timeoffset = CAST(dbo.fnKartrisConfig_GetValue(''general.timeoffset'') as int);
				INSERT INTO dbo.tblKartrisDeletedItems VALUES(@CAT_ID, ''c'', NULL, DateAdd(hour, @Timeoffset, GetDate()));
			ENABLE Trigger trigKartrisDeletedItems_DML ON dbo.tblKartrisDeletedItems;
		END
	END
	ELSE
	BEGIN
		RAISERROR(''Can not delete a category that has subcategories.'', 16, 0);
	END
	
Exit_sp:
END


' 
END
GO


-- ################  Stored Procedures/Functions/Views Reset Ended   ################



-- ################  Records Additions/Modifications Started   ################

EXEC [dbo].[_spKartrisDB_DisableAllTriggers];
GO

-- Delete DEPRECATED Configs
DELETE FROM [dbo].[tblKartrisConfig] WHERE CFG_Name = 'frontend.basket.allowdecimalqty';
DELETE FROM [dbo].[tblKartrisConfig] WHERE CFG_Name = 'frontend.versions.display.zerocallforprices';
-- DELETE FROM [dbo].[tblKartrisConfig] WHERE CFG_Name = 'frontend.basket.addtobasketdisplay'; -- KEEP THIS AS A DEFAULT
GO

-- Update Configs 'general.kartrisinfo.versionadded' to 1.4
DECLARE @Count as int;
SELECT @Count = COUNT(0) FROM [dbo].[tblKartrisConfig] WHERE [CFG_Name]= N'general.kartrisinfo.versionadded';
IF @Count = 0 BEGIN
	INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CactuShopName_DEPRECATED], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES (N'general.kartrisinfo.versionadded', N'', N'1.4', N's', N's', N'kartris version', N'', 1.4, N'1.3007', 0);
END ELSE BEGIN
	UPDATE [dbo].[tblKartrisConfig] SET [CFG_Value] = '1.4', [CFG_VersionAdded] = 1.4 WHERE [CFG_Name]= N'general.kartrisinfo.versionadded';
END
GO

-- New 1.4 Config Settings
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CactuShopName_DEPRECATED], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES (N'frontend.minibasket.shippingestimate', NULL, N'y', N's', N'b', N'y|n', N'whether to show estimate shipping in the mini basket or not.', 1.4, N'y', 0)
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CactuShopName_DEPRECATED], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES (N'frontend.basket.shippingestimate', NULL, N'y', N's', N'b', N'y|n', N'whether to show estimate shipping in the basket or not.', 1.4, N'y', 0)
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CactuShopName_DEPRECATED], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES (N'frontend.orders.showcommentsoninvoice', N'', N'y', N's', N's', N'y|n', N'Whether to show the customer comments in the order invoice', 1.4, N'y', 0)
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CactuShopName_DEPRECATED], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES (N'frontend.checkout.orderhandlingchargetaxband2', N'', N'0', N'n', N'n', N'', N'Determines the second tax rate applied to the order handling charge. To set or disable the order handling charge, see the orderhandlingcharge config setting.', 1.4, N'0', 0);
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CactuShopName_DEPRECATED], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES (N'frontend.display.images.watermarktext', N'', N'', N's', N't', N'', N'The watermark text to appear in images. To use your shop url set it to [webshopurl]. To disable watermark leave the value blank.', 1.4, N'', 0);
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CactuShopName_DEPRECATED], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES (N'frontend.optiongroups.showdescription', N'', N'y', N's', N's', N'y|n', N'Whether to show the description for option groups in front end or not.', 1.4, N'y', 0)
GO

-- Video Support for HTML5
INSERT [dbo].[tblKartrisMediaTypes] ([MT_Extension], [MT_DefaultHeight], [MT_DefaultWidth], [MT_DefaultParameters], [MT_DefaultisDownloadable], [MT_Embed], [MT_Inline]) VALUES (N'html5video', 480, 640, NULL, 0, 0, 0)
GO

-- Object Config records
INSERT [dbo].[tblKartrisObjectConfig] ([OC_Name], [OC_ObjectType], [OC_DataType], [OC_DefaultValue], [OC_Description], [OC_MultilineValue], [OC_VersionAdded]) VALUES (N'K:product.callforprice', N'Product', N'b', N'0', N'display ''call for price'' and hide ''add'' button.', 0, 1.4)
INSERT [dbo].[tblKartrisObjectConfig] ([OC_Name], [OC_ObjectType], [OC_DataType], [OC_DefaultValue], [OC_Description], [OC_MultilineValue], [OC_VersionAdded]) VALUES (N'K:product.addtobasketqty', N'Product', N's', N'', N'add-to-basket quantity field type (dropdown, textbox or none).', 0, 1.4)
INSERT [dbo].[tblKartrisObjectConfig] ([OC_Name], [OC_ObjectType], [OC_DataType], [OC_DefaultValue], [OC_Description], [OC_MultilineValue], [OC_VersionAdded]) VALUES (N'K:product.unitsize', N'Product', N'n', N'1', N'The unit size in which the item is sold.', 0, 1.4)
INSERT [dbo].[tblKartrisObjectConfig] ([OC_Name], [OC_ObjectType], [OC_DataType], [OC_DefaultValue], [OC_Description], [OC_MultilineValue], [OC_VersionAdded]) VALUES (N'K:product.usecombinationprice', N'Product', N'b', N'0', N'use combination price instead of options prices.', 0, 1.4)
GO

-- LS: Media related
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_Inline', N'Inline?', NULL, 1.4, N'Inline?', NULL, N'_Media', 1);

-- LS: Product combination related
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'ContentText_NoValidCombinations', N'Please make a selection for all options above', NULL, 1.4, N'Please make a selection for all options above', NULL, N'Options', 1);

-- LS: Object Config related
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_ObjectConfig', N'Object Config', NULL, 1.4, N'Object Config', NULL, N'_Kartris', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'ContentText_OrderMultiplesOfUnitsize', N'This item must be ordered in multiples of [unitsize]', N'Popup message appears when trying to add an in-valid quantity (not multiple of UnitSize) to basket.', 1.4, N'This item must be ordered in multiples of [unitsize]', NULL, N'ObjectConfig', 1);

-- LS: Update to basket related
UPDATE [dbo].[tblKartrisLanguageStrings] SET LS_Value = 'Adding item(s) to basket...', LS_DefaultValue = 'Adding item(s) to basket...' WHERE LS_Name = 'ContentText_ItemsAdded' AND LS_LangID = 1;
UPDATE [dbo].[tblKartrisLanguageStrings] SET LS_Value = 'Updating item(s) to basket...', LS_DefaultValue = 'Updating item(s) to basket...' WHERE LS_Name = 'ContentText_ItemsUpdated' AND LS_LangID = 1;

-- LS: Update (typo name)
UPDATE [dbo].[tblKartrisLanguageStrings] SET LS_Name = 'ContentText_ExcludedSearchKeywords' WHERE LS_Name = 'ContentText_ExecludedSearchKeywords';
-- LS: Update (email update)
UPDATE [dbo].[tblKartrisLanguageStrings] SET [LS_Value] = N'The status for your one of your orders has been updated.
=====================
[order_status]
====================='
WHERE [LS_Name] = N'EmailText_OrderStatusUpdated' And LS_LangID = 1;

-- LS: Payments related
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'PageTitle_PaymentsRecent', N'Recent', NULL, 1.4, N'', NULL, N'_Payments', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_PaymentsRecentText', N'most recent successfully placed payments', NULL, 1.4, N'most recent successfully placed payments', NULL, N'_Payments', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_EnterPaymentDate', N'(enter date in same format as used below or a payment ID)', NULL, 1.4, N'(enter date in same format as used below or a payment ID)', NULL, N'_Payments', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_PaymentDetails', N'Payment Details', NULL, 1.4, N'Payment Details', NULL, N'_Payments', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'PageTitle_EditPayment', N'Edit Payment', NULL, 1.4, N'Edit Payment', NULL, N'_Payments', 1);

-- LS: Charting related
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_Chart', N'Chart', NULL, 1.4, N'Chart', NULL, N'_Statistics', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_Days', N'Days', NULL, 1.4, N'Days', NULL, N'_Statistics', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_DisplayPeriod', N'Display Period', NULL, 1.4, N'Display Period', NULL, N'_Statistics', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_DisplayRecords', N'Display Records', NULL, 1.4, N'Display Records', NULL, N'_Statistics', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_DisplayType', N'Display Type', NULL, 1.4, N'Display Type', NULL, N'_Statistics', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_Months', N'Months', NULL, 1.4, N'Months', NULL, N'_Statistics', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_Table', N'Table', NULL, 1.4, N'Table', NULL, N'_Statistics', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_Terms', N'Terms', NULL, 1.4, N'Terms', NULL, N'_Statistics', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_TotalSearches', N'Total Searches', NULL, 1.4, N'Total Searches', NULL, N'_Statistics', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_TotalTurnover', N'Total Turnover', NULL, 1.4, N'Total Turnover', NULL, N'_Statistics', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_Turnover', N'Turnover', NULL, 1.4, N'Turnover', NULL, N'_Statistics', 1)

-- LS: Markup prices related
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'BackMenu_MarkupPrices', N'Mark Up Prices', NULL, 1.4, N'Mark Up Prices', NULL, N'_Kartris', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_AllCategories', N'All Categories', NULL, 1.4, N'All Categories', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_AllVersions', N'all versions in', NULL, 1.4, N'all versions in', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_From', N'from', NULL, 1.4, N'from', NULL, N'_Kartris', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_InCategory', N'In Category', NULL, 1.4, N'In Category', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_LeaveBlankPrices', N'Leave blank for all prices', NULL, 1.4, N'Leave blank for all prices', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_MarkDown', N'Mark down', NULL, 1.4, N'Mark down', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_MarkUp', N'Mark up', NULL, 1.4, N'Mark up', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_MarkupCategoriesNotSelected', N'No checkboxes were selected! Please check at least one category or select all categories to mark up.', NULL, 1.4, N'No checkboxes were selected! Please check at least one category or select all categories to mark up.', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_MarkupConfirmText', N'Follow are versions that fit your criteria, with the current price and what the new price will be. If you wish to exclude any from the markup, simply uncheck that checkbox.<br /><br />

Please note - there will not be any more confirmation screens!', NULL, 1.4, N'Follow are versions that fit your criteria, with the current price and what the new price will be. If you wish to exclude any from the markup, simply uncheck that checkbox.<br /><br />

Please note - there will not be any more confirmation screens!', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_MarkupNoneSelected', N'No checkboxes were selected! Please check at least one version to mark up.', NULL, 1.4, N'No checkboxes were selected! Please check at least one version to mark up.', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_MarkupPricesDesc1', N'By using this function, you can mark up or down prices in a specific category or across the whole catalogue, in a set price range. You can change prices by a set value or by a percentage of the old value.', NULL, 1.4, N'By using this function, you can mark up or down prices in a specific category or across the whole catalogue, in a set price range. You can change prices by a set value or by a percentage of the old value.', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_MarkupPricesDesc2', N'After configuring the markup and hitting submit, you will see a confirmation screen of which versions will be altered, and what the new value will be. After confirming this, the changes will be made.', NULL, 1.4, N'After configuring the markup and hitting submit, you will see a confirmation screen of which versions will be altered, and what the new value will be. After confirming this, the changes will be made.', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_NewPrice', N'New Price', NULL, 1.4, N'New Price', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_NewRRP', N'New RRP', NULL, 1.4, N'New RRP', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_NoPricesMarkup', N'No versions match your markup criteria.', NULL, 1.4, N'No versions match your markup criteria.', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_PriceMarkupBy', N'By', NULL, 1.4, N'By', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_PriceModification', N'Price Modification', NULL, 1.4, N'Price Modification', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_PriceRange', N'Price Range', NULL, 1.4, N'Price Range', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_PriceRangeAnd', N' and ', NULL, 1.4, N' and ', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_PriceRangeBetween', N'Between', NULL, 1.4, N'Between', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_SelectedCategories', N'Selected Categories', NULL, 1.4, N'Selected Categories', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'PageTitle_MarkupPrices', N'Markup Prices', NULL, 1.4, N'Markup Prices', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_Version', N'Version', NULL, 1.4, N'Version', NULL, N'_Kartris', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_VersionsAbove', N'versions above', NULL, 1.4, N'versions above', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_VersionsBelow', N'versions below', NULL, 1.4, N'versions below', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_VersionsBetween', N'versions between', NULL, 1.4, N'versions between', NULL, N'_MarkupPrices', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_VersionsToMarkUp', N'Versions to mark up', NULL, 1.4, N'Versions to mark up', NULL, N'_MarkupPrices', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_ImportPriceList', N'Import Price List', NULL, 1.4, N'Import Price List', NULL, N'_MarkupPrices', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_ImportPriceListInfo', N'Here you can import price lists to update the database. Should be entered in this format:<br />
versioncode1, price1<br />
versioncode2, price2<br />
versioncode3, price3<br />
etc...', NULL, 1.4, N'Here you can import price lists to update the database. Should be entered in this format:<br />
versioncode1, price1<br />
versioncode2, price2<br />
versioncode3, price3<br />
etc...', NULL, N'_MarkupPrices', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_PriceListDetails', N'Price List Details', NULL, 1.4, N'Price List Details', NULL, N'_MarkupPrices', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_UploadFromFile', N'Upload From File', NULL, 1.4, N'Upload From File', NULL, N'_MarkupPrices', 1);

-- LS: Promotions related
DELETE FROM [dbo].[tblKartrisLanguageStrings] WHERE LS_Name IN ('ContentText_PromotionTextBuyPart1','ContentText_PromotionTextSpendPart1','ContentText_PromotionTextGetItemFreePart2', 'ContentText_PromotionTextGetPriceOffPart2','ContentText_PromotionTextGetPercentOffPart2','ContentText_PromotionTextCatBuyPart', 'ContentText_PromotionTextCatItems','ContentText_PromotionTextOfItems');
INSERT [dbo].[tblKartrisLanguageStrings] VALUES (N'f', N'ContentText_PromotionTextBuyVersion', N'Buy [X] of version [V]', NULL, 1.4, NULL, NULL, N'Promotions', 1);
INSERT [dbo].[tblKartrisLanguageStrings] VALUES (N'f', N'ContentText_PromotionTextBuyCategory', N'Buy [X] of items from category [C]', NULL, 1.4, NULL, NULL, N'Promotions', 1);
INSERT [dbo].[tblKartrisLanguageStrings] VALUES (N'f', N'ContentText_PromotionTextBuyProduct', N'Buy [X] of [P]', NULL, 1.4, NULL, NULL, N'Promotions', 1);
INSERT [dbo].[tblKartrisLanguageStrings] VALUES (N'f', N'ContentText_PromotionTextSpend', N'Spend [£][X]', NULL, 1.4, NULL, NULL, N'Promotions', 1);
INSERT [dbo].[tblKartrisLanguageStrings] VALUES (N'f', N'ContentText_PromotionTextGetVersionFree', N'get [X] of [V] for free', NULL, 1.4, NULL, NULL, N'Promotions', 1);
INSERT [dbo].[tblKartrisLanguageStrings] VALUES (N'f', N'ContentText_PromotionTextGetVersionOff', N'get [X]% off [V]', NULL, 1.4, NULL, NULL, N'Promotions', 1);
INSERT [dbo].[tblKartrisLanguageStrings] VALUES (N'f', N'ContentText_PromotionTextGetOff', N'get [£][X] off', NULL, 1.4, NULL, NULL, N'Promotions', 1);
INSERT [dbo].[tblKartrisLanguageStrings] VALUES (N'f', N'ContentText_PromotionTextGetProductFree', N'get [X] of [P]', NULL, 1.4, NULL, NULL, N'Promotions', 1);
INSERT [dbo].[tblKartrisLanguageStrings] VALUES (N'f', N'ContentText_PromotionTextGetProductOff', N'get [X]% off [P]', NULL, 1.4, NULL, NULL, N'Promotions', 1);
INSERT [dbo].[tblKartrisLanguageStrings] VALUES (N'f', N'ContentText_PromotionTextGetCategoryOff', N'get [X]% off from category [C]', NULL, 1.4, NULL, NULL, N'Promotions', 1);
GO

-- LS: Estimate Shipping
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'ContentText_EstimateShipping', N'Estimate Shipping', NULL, 1.4, N'Estimate Shipping', NULL, N'Basket', 1);
GO

-- LS: Regional Setup Wizard Related
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'PageTitle_RegionalSetupWizard', N'Regional Setup Wizard', NULL, 1.4, N'Regional Setup Wizard', NULL, N'_RegionalWizard', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'FormLabel_TaxRegime', N'Tax Regime:', NULL, 1.4, N'Tax Regime:', NULL, N'_RegionalWizard', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_TaxWizBaseCurrencyQuestion', N'What is the base currency you work in?', NULL, 1.4, N'What is the base currency you work in?', NULL, N'_RegionalWizard', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_TaxWizEUVATRegisteredQuestion', N'Is your business VAT-Registered?', NULL, 1.4, N'Is your business VAT-Registered?', NULL, N'_RegionalWizard', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_TaxWizEUBaseCountryQuestion', N'What country is your store based in?', NULL, 1.4, N'What country is your store based in?', NULL, N'_RegionalWizard', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_TaxWizEUVATRateQuestion', N'What is the primary VAT rate in this country?', NULL, 1.4, N'What is the primary VAT rate in this country?', NULL, N'_RegionalWizard', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_TaxWizUSBaseStateQuestion', N'What state is your business based in?', NULL, 1.4, N'What state is your business based in?', NULL, N'_RegionalWizard', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_TaxWizUSStateTaxRateQuestion', N'What is the sales tax rate in this state?', NULL, 1.4, N'What is the sales tax rate in this state?', NULL, N'_RegionalWizard', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_TaxWizCanadaBaseProviceQuestion', N'What province or territory is your business based in?', NULL, 1.4, N'What province or territory is your business based in?', NULL, N'_RegionalWizard', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_TaxWizCanadaConfirmTaxRates', N'Confirm the various tax rates below', NULL, 1.4, N'Confirm the various tax rates below', NULL, N'_RegionalWizard', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_TaxWizCanadaGST', N'GST', NULL, 1.4, N'GST', NULL, N'_RegionalWizard', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_TaxWizCanadaPST', N'PST', NULL, 1.4, N'PST', NULL, N'_RegionalWizard', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_TaxWizCanadaPSTChargedOnGST', N'PST charged on GST?', NULL, 1.4, N'PST charged on GST?', NULL, N'_RegionalWizard', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_TaxWizSimpleBaseCountryQuestion', N'What country is your business based in?', NULL, 1.4, N'What country is your business based in?', NULL, N'_RegionalWizard', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_TaxWizSimpleTaxRateQuestion', N'What is the tax rate in this country?', NULL, 1.4, N'What is the tax rate in this country?', NULL, N'_RegionalWizard', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_TazWizConfigRecommend', N'We recommend the following settings:', NULL, 1.4, N'We recommend the following settings:', NULL, N'_RegionalWizard', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_Confirm', N'Confirm', NULL, 1.4, N'Confirm', NULL, N'_Kartris', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'Step5_TaxRegime_Text', N'Tax Regime', NULL, 1.4, NULL, N'Install.aspx', NULL, 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'Step5_litTaxRegimeDesc_Text', N'This will set the tax handling in the web.config of your store. You can change this later if necessary by editing the web.config.', NULL, 1.4, NULL, N'Install.aspx', N'', 1);
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_Promotion', N'Promotion', N'Used in the coupon type drop down list, so it will allow to assign a promotion id to be activated by the coupon.', 1.4, N'Promotion', NULL, N'_Coupons', 1);
GO

-- PromotionStrings records
DELETE FROM [dbo].[tblKartrisPromotionStrings];
INSERT [dbo].[tblKartrisPromotionStrings] ([PS_ID], [PS_LanguageStringName], [PS_PartNo], [PS_Type], [PS_Item], [PS_Order]) VALUES (1, N'ContentText_PromotionTextBuyVersion',	N'a', N'q', N'v', 1)
INSERT [dbo].[tblKartrisPromotionStrings] ([PS_ID], [PS_LanguageStringName], [PS_PartNo], [PS_Type], [PS_Item], [PS_Order]) VALUES (2, N'ContentText_PromotionTextBuyCategory', N'a', N'q', N'c', 2)
INSERT [dbo].[tblKartrisPromotionStrings] ([PS_ID], [PS_LanguageStringName], [PS_PartNo], [PS_Type], [PS_Item], [PS_Order]) VALUES (3, N'ContentText_PromotionTextBuyProduct',	N'a', N'q', N'p', 3)
INSERT [dbo].[tblKartrisPromotionStrings] ([PS_ID], [PS_LanguageStringName], [PS_PartNo], [PS_Type], [PS_Item], [PS_Order]) VALUES (4, N'ContentText_PromotionTextSpend', N'a', N'v', N'a', 4)
INSERT [dbo].[tblKartrisPromotionStrings] ([PS_ID], [PS_LanguageStringName], [PS_PartNo], [PS_Type], [PS_Item], [PS_Order]) VALUES (5, N'ContentText_PromotionTextGetVersionFree',	N'b', N'q', N'v', 1)
INSERT [dbo].[tblKartrisPromotionStrings] ([PS_ID], [PS_LanguageStringName], [PS_PartNo], [PS_Type], [PS_Item], [PS_Order]) VALUES (6, N'ContentText_PromotionTextGetVersionOff', N'b', N'p', N'v', 2)
INSERT [dbo].[tblKartrisPromotionStrings] ([PS_ID], [PS_LanguageStringName], [PS_PartNo], [PS_Type], [PS_Item], [PS_Order]) VALUES (7, N'ContentText_PromotionTextGetOff', N'b', N'v', N'a', 3)
INSERT [dbo].[tblKartrisPromotionStrings] ([PS_ID], [PS_LanguageStringName], [PS_PartNo], [PS_Type], [PS_Item], [PS_Order]) VALUES (8, N'ContentText_PromotionTextGetProductFree',	N'b', N'q', N'p', 4)
INSERT [dbo].[tblKartrisPromotionStrings] ([PS_ID], [PS_LanguageStringName], [PS_PartNo], [PS_Type], [PS_Item], [PS_Order]) VALUES (9, N'ContentText_PromotionTextGetProductOff', N'b', N'p', N'p', 5)
INSERT [dbo].[tblKartrisPromotionStrings] ([PS_ID], [PS_LanguageStringName], [PS_PartNo], [PS_Type], [PS_Item], [PS_Order]) VALUES (10, N'ContentText_PromotionTextGetCategoryOff', N'b', N'p', N'c', 6)
GO

-- AdminRelatedTables records
DISABLE TRIGGER trigKartrisAdminRelatedTables_DML ON dbo.tblKartrisAdminRelatedTables;
DELETE FROM [dbo].[tblKartrisAdminRelatedTables];
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisAddresses', NULL, 19, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisAffiliateLog', NULL, 12, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisAffiliatePayments', NULL, 11, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisAttributes', 14, NULL, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisAttributeValues', 7, NULL, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisBasketOptionValues', 8, 15, 3, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisBasketValues', 15, 16, 4, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisCategories', 23, NULL, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisCategoryHierarchy', 6, NULL, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisClonedOrders', NULL, 7, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisCoupons', NULL, 17, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisCustomerGroupPrices', 19, 2, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisCustomerGroups', NULL, 3, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisInvoiceRows', NULL, 5, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisKnowledgebase', NULL, NULL, NULL, 3, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisMediaLinks', 20, NULL, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisNews', NULL, NULL, NULL, 1, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisObjectConfigValue', 28, NULL, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisOptionGroups', 17, NULL, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisOptions', 16, NULL, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisOrderPaymentLink', NULL, 8, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisOrders', NULL, 10, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisOrdersPromotions', 10, 6, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisPages', NULL, NULL, NULL, 2, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisPayments', NULL, 9, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisProductCategoryLink', 2, NULL, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisProductOptionGroupLink', 3, NULL, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisProductOptionLink', 4, NULL, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisProducts', 22, NULL, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisPromotionParts', 9, NULL, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisPromotions', 13, NULL, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisQuantityDiscounts', 18, NULL, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisRelatedProducts', 5, NULL, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisReviews', 12, NULL, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisSavedBaskets', 25, 13, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisSearchStatistics', 27, NULL, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisSessions', NULL, 4, 2, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisSessionValues', NULL, 1, 1, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisStatistics', 11, NULL, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisSuppliers', 24, NULL, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisSupportTicketMessages', NULL, 20, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisSupportTickets', NULL, 21, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisUsers', NULL, 18, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisVersionOptionLink', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisVersions', 21, NULL, NULL, NULL, 0)
INSERT [dbo].[tblKartrisAdminRelatedTables] ([ART_TableName], [ART_TableOrderProducts], [ART_TableOrderOrders], [ART_TableOrderSessions], [ART_TableOrderContents], [ART_TableStartingIdentity]) VALUES (N'tblKartrisWishLists', 26, 14, NULL, NULL, 0);
ENABLE TRIGGER trigKartrisAdminRelatedTables_DML ON dbo.tblKartrisAdminRelatedTables;
GO

EXEC [dbo].[_spKartrisDB_EnableAllTriggers];
GO
-- ################  Records Additions/Modifications Ended   ################


-- ################ Loop through all languages to fix missing language strings ################
DECLARE @LanguageID as tinyint;
	DECLARE langCursor CURSOR FOR 
	SELECT LANG_ID FROM dbo.tblKartrisLanguages WHERE LANG_ID <> 1;
	OPEN langCursor	FETCH NEXT FROM langCursor	INTO @LanguageID;
	WHILE @@FETCH_STATUS = 0 BEGIN
		EXEC [dbo].[_spKartrisLanguageStrings_FixMissingStrings] @SourceLanguage = 1, @DistinationLanguage = @LanguageID;

		FETCH NEXT FROM langCursor INTO @LanguageID;
	END
	CLOSE langCursor	
	DEALLOCATE langCursor;
	
GO