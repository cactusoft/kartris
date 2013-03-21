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
