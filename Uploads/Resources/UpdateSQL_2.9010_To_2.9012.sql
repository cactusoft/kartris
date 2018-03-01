
/*** Adding some fields to Users table for GDPR opt in recording  ***/
ALTER TABLE tblKartrisUsers
ADD U_GDPR_OptIn datetime, U_GDPR_SignupIP nvarchar(50); 
GO

-- default value of optin date to now
ALTER TABLE tblKartrisUsers ADD CONSTRAINT
idx_U_GDPR_OptIn DEFAULT GETDATE() FOR U_GDPR_OptIn
GO

/*** Increase some field sizes for IPs to support IPv6  ***/
ALTER TABLE tblKartrisUsers
ALTER COLUMN U_ML_SignupIP nvarchar(50); 

ALTER TABLE tblKartrisUsers
ALTER COLUMN U_ML_ConfirmationIP nvarchar(50); 

ALTER TABLE tblKartrisUsers
ALTER COLUMN U_ML_ConfirmationIP nvarchar(50); 

ALTER TABLE tblKartrisSessions
ALTER COLUMN SESS_IP nvarchar(50); 

ALTER TABLE tblKartrisAffiliateLog
ALTER COLUMN AFLG_IP nvarchar(50); 
GO

/****** Object:  StoredProcedure [dbo].[spKartrisUsers_Add] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spKartrisUsers_Add]
(
		   @U_EmailAddress nvarchar(100),
		   @U_Password nvarchar(64),
		   @U_SaltValue nvarchar(64),
		   @U_GDPR_SignupIP nvarchar(50)
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
			,[U_GDPR_SignupIP])
	 VALUES
		   (@U_EmailAddress,
			@U_Password,
			1,0,0,0,0,@U_SaltValue,
			@U_GDPR_SignupIP);
	SET @U_ID = SCOPE_IDENTITY();
	SELECT @U_ID;
GO

/*** New language strings  ***/
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'FormLabel_GDPRConfirmText', N'Please confirm you have read, understand and accept our privacy policy and terms and conditions', NULL, 2.9012, N'', NULL, N'GDPR',1);

GO

/****** new GDPR functionality ******/
INSERT INTO [tblKartrisConfig]
(CFG_Name,CFG_Value,CFG_DataType,CFG_DisplayType,CFG_DisplayInfo,CFG_Description,CFG_VersionAdded,CFG_DefaultValue,CFG_Important)
VALUES
(N'general.gdpr.enabled', N'y', N's', N'b',	'y|n',N'Whether to include the GDPR explicit approval opt-in for new customers',2.9012, N'y', 0);

GO

/****** change position of admin back end link on front end of site ******/
INSERT INTO [tblKartrisConfig]
(CFG_Name,CFG_Value,CFG_DataType,CFG_DisplayType,CFG_DisplayInfo,CFG_Description,CFG_VersionAdded,CFG_DefaultValue,CFG_Important)
VALUES
(N'frontend.adminlinkposition', N'top', N's', N'b',	'top|bottom',N'Position for front end admin link. Bottom moves it down a little in case it clashes with hamburger or other navigation.',2.9012, N'top', 0);

GO

/****** create new addresses view, this will help exporting data for GDPR ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vKartrisAddresses]
AS
SELECT DISTINCT 
						 dbo.tblKartrisAddresses.ADR_ID, dbo.tblKartrisAddresses.ADR_UserID, dbo.tblKartrisAddresses.ADR_Label, dbo.tblKartrisAddresses.ADR_Name, dbo.tblKartrisAddresses.ADR_Company, 
						 dbo.tblKartrisAddresses.ADR_StreetAddress, dbo.tblKartrisAddresses.ADR_TownCity, dbo.tblKartrisAddresses.ADR_County, dbo.tblKartrisAddresses.ADR_PostCode, dbo.tblKartrisAddresses.ADR_Telephone, 
						 dbo.tblKartrisLanguageElements.LE_Value, dbo.tblKartrisLanguageElements.LE_TypeID, dbo.tblKartrisLanguageElements.LE_LanguageID
FROM            dbo.tblKartrisLanguageElements INNER JOIN
						 dbo.tblKartrisLanguageElementFieldNames ON dbo.tblKartrisLanguageElements.LE_FieldID = dbo.tblKartrisLanguageElementFieldNames.LEFN_ID INNER JOIN
						 dbo.tblKartrisLanguageElementTypeFields ON dbo.tblKartrisLanguageElementFieldNames.LEFN_ID = dbo.tblKartrisLanguageElementTypeFields.LEFN_ID INNER JOIN
						 dbo.tblKartrisLanguageElementTypes ON dbo.tblKartrisLanguageElements.LE_TypeID = dbo.tblKartrisLanguageElementTypes.LET_ID INNER JOIN
						 dbo.tblKartrisAddresses INNER JOIN
						 dbo.tblKartrisDestination ON dbo.tblKartrisAddresses.ADR_Country = dbo.tblKartrisDestination.D_ID ON dbo.tblKartrisLanguageElements.LE_ParentID = dbo.tblKartrisDestination.D_ID
WHERE        (dbo.tblKartrisLanguageElements.LE_TypeID = 11) AND (dbo.tblKartrisLanguageElements.LE_LanguageID = 1)
GO

/****** new sproc to find addresses by user ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[_spKartrisGDPR_GetAddressesByUserID]
(
	@UserID as int
)
AS
	SET NOCOUNT ON;
SELECT     * 
FROM         vKartrisAddresses
WHERE     (ADR_UserID = @UserID)
GO

/****** GDPR export: new sproc to find orders by user ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[_spKartrisGDPR_GetOrdersByUserID]
(
	@UserID as int
)
AS
	SET NOCOUNT ON;
SELECT     * 
FROM         tblKartrisOrders
WHERE     (O_CustomerID = @UserID)
ORDER BY O_ID
GO

/****** GDPR export: new sproc to find reviews by user ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[_spKartrisGDPR_GetReviewsByUserID]
(
	@UserID as int
)
AS
	SET NOCOUNT ON;
SELECT     * 
FROM         tblKartrisReviews
WHERE     (REV_CustomerID = @UserID)
ORDER BY REV_ID
GO

/****** GDPR export: new sproc to find wishlists by user ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[_spKartrisGDPR_GetWishListsByUserID]
(
	@UserID as int
)
AS
	SET NOCOUNT ON;
SELECT     * 
FROM         tblKartrisWishLists
WHERE     (WL_UserID = @UserID)
ORDER BY WL_ID
GO

/****** GDPR export: new sproc to find support tickets by user ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[_spKartrisGDPR_GetSupportTicketsByUserID]
(
	@UserID as int
)
AS
	SET NOCOUNT ON;
SELECT     * 
FROM         tblKartrisSupportTickets
WHERE     (TIC_UserID = @UserID)
ORDER BY TIC_ID
GO

/****** GDPR: new view for saved baskets ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vKartrisTypeSavedBasketItems]
AS
SELECT        dbo.tblKartrisBasketValues.BV_VersionID, dbo.vKartrisTypeVersions.V_Name, dbo.vKartrisTypeVersions.V_CodeNumber, dbo.tblKartrisBasketValues.BV_Quantity, dbo.tblKartrisBasketValues.BV_CustomText, 
						 dbo.tblKartrisBasketValues.BV_DateTimeAdded, dbo.tblKartrisBasketValues.BV_LastUpdated, dbo.tblKartrisBasketValues.BV_ParentID, dbo.tblKartrisBasketValues.BV_ParentType, dbo.tblKartrisBasketValues.BV_ID
FROM            dbo.tblKartrisBasketValues INNER JOIN
						 dbo.vKartrisTypeVersions ON dbo.tblKartrisBasketValues.BV_VersionID = dbo.vKartrisTypeVersions.V_ID
WHERE        (dbo.tblKartrisBasketValues.BV_ParentType = 's')
GO

/****** GDPR export: new sproc to find saved baskets ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[_spKartrisGDPR_GetSavedBasketsByUserID]
(
	@UserID as int
)
AS
	SET NOCOUNT ON;
SELECT     * 
FROM         tblKartrisSavedBaskets
WHERE     (SBSKT_UserID = @UserID)
ORDER BY SBSKT_ID
GO

/****** GDPR export: saved basket items ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[_spKartrisGDPR_GetSavedBasketValuesByUserID]
(
	@SavedBasketID as int
)
AS
	SET NOCOUNT ON;
SELECT     * 
FROM         vKartrisTypeSavedBasketItems
WHERE     (BV_ParentID = @SavedBasketID)
ORDER BY BV_ID
GO

/*** New language strings  ***/
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_GDPRExport', N'GDPR Export', NULL, 2.9012, N'', NULL, N'_GDPR',1);
GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.9012', CFG_VersionAdded=2.9012 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO

