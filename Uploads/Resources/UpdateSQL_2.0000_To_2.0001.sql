-- ****** New language strings
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'PageTitle_GeneralFiles', N'General Files', NULL, 2.0001, N'General Files', NULL, N'_Kartris', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'BackMenu_GeneralFiles', N'General Files', NULL, 2.0001, N'General Files', NULL, N'_Kartris', 1)

-- ****** Loop through all languages to fix missing language strings 
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

-- ****** Drop FK between Products and Customer Groups
ALTER TABLE [dbo].[tblKartrisProducts] DROP CONSTRAINT [FK_tblKartrisProducts_tblKartrisCustomerGroups]
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisLogins_GetList]    Script Date: 2/27/2013 5:38:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_spKartrisLogins_GetList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
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
	  ,[LOGIN_PushNotifications]
FROM            tblKartrisLogins
' 
END
GO
