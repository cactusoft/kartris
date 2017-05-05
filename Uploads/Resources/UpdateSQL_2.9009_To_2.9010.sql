
/*** Bit of a minor fix to the feeds here. If only one language, we
don't want the culture included in the URLs. So we've modded this to
return blanks for the culture if only one live language, then the feed
code has been modified to cut the culture from URLs if it's blank  ***/

/****** Object:  StoredProcedure [dbo].[_spKartrisFeeds_GetItems]    Script Date: 05/05/2017 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================
-- Author:		Paul
-- Create date: 20/10/2016 13:53:30
-- Description:	Pulls pages, cats and prods for
-- google sitemap file
-- ===================================================
ALTER PROCEDURE [dbo].[_spKartrisFeeds_GetItems]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Count number of live languages
	DECLARE @LanguageCount as tinyint
	SET @LanguageCount = (SELECT COUNT(LANG_ID) From tblKartrisLanguages WHERE LANG_LiveFront = 1) 

	IF @LanguageCount > 1
	BEGIN 
		SELECT 't' as RecordType, PAGE_ID As ItemID, '' as LANG_Culture, PAGE_Name FROM vKartrisTypePages WHERE PAGE_Live=1
		UNION
		SELECT 'c' as RecordType, CAT_ID As ItemID, LANG_Culture, CAT_Name FROM vKartrisTypeCategories INNER JOIN tblKartrisLanguages ON vKartrisTypeCategories.LANG_ID=tblKartrisLanguages.LANG_ID WHERE CAT_Live=1 AND LANG_LiveFront=1
		UNION
		SELECT 'p' as RecordType, P_ID As ItemID, LANG_Culture, P_Name FROM vKartrisTypeProducts  INNER JOIN tblKartrisLanguages ON vKartrisTypeProducts.LANG_ID=tblKartrisLanguages.LANG_ID WHERE P_Live=1 AND LANG_LiveFront=1
		UNION
		SELECT 'n' as RecordType, N_ID As ItemID, (SELECT LANG_Culture FROM tblKartrisLanguages WHERE tblKartrisLanguages.LANG_ID=vKartrisTypeNews.LANG_ID) AS LANG_Culture, N_Name FROM vKartrisTypeNews
	END
	ELSE
	BEGIN 
		SELECT 't' as RecordType, PAGE_ID As ItemID, '' as LANG_Culture, PAGE_Name FROM vKartrisTypePages WHERE PAGE_Live=1
		UNION
		SELECT 'c' as RecordType, CAT_ID As ItemID, '' as LANG_Culture, CAT_Name FROM vKartrisTypeCategories INNER JOIN tblKartrisLanguages ON vKartrisTypeCategories.LANG_ID=tblKartrisLanguages.LANG_ID WHERE CAT_Live=1 AND LANG_LiveFront=1
		UNION
		SELECT 'p' as RecordType, P_ID As ItemID, '' as LANG_Culture, P_Name FROM vKartrisTypeProducts  INNER JOIN tblKartrisLanguages ON vKartrisTypeProducts.LANG_ID=tblKartrisLanguages.LANG_ID WHERE P_Live=1 AND LANG_LiveFront=1
		UNION
		SELECT 'n' as RecordType, N_ID As ItemID, '' AS LANG_Culture, N_Name FROM vKartrisTypeNews
	END
END
GO
