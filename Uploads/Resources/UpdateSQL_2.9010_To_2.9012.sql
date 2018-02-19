
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

/*** New language strings  ***/
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'FormLabel_GDPRConfirmText', N'Please confirm you have read, understand and accept our privacy policy and terms and conditions', NULL, 2.9012, N'', NULL, N'Kartris',1);

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

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.9012', CFG_VersionAdded=2.9012 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO

