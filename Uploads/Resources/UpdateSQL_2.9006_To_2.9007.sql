/****** Object:  StoredProcedure [dbo].[_spKartrisFeeds_GetItems]    Script Date: 20/10/2016 16:18:29 ******/
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
CREATE PROCEDURE [dbo].[_spKartrisFeeds_GetItems]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		SELECT 't' as RecordType, PAGE_ID As ItemID, '' as LANG_Culture, PAGE_Name FROM vKartrisTypePages WHERE PAGE_Live=1
		UNION
		SELECT 'c' as RecordType, CAT_ID As ItemID, LANG_Culture, CAT_Name FROM vKartrisTypeCategories INNER JOIN tblKartrisLanguages ON vKartrisTypeCategories.LANG_ID=tblKartrisLanguages.LANG_ID WHERE CAT_Live=1 AND LANG_LiveFront=1
		UNION
		SELECT 'p' as RecordType, P_ID As ItemID, LANG_Culture, P_Name FROM vKartrisTypeProducts  INNER JOIN tblKartrisLanguages ON vKartrisTypeProducts.LANG_ID=tblKartrisLanguages.LANG_ID WHERE P_Live=1 AND LANG_LiveFront=1
		UNION
		SELECT 'n' as RecordType, N_ID As ItemID, (SELECT LANG_Culture FROM tblKartrisLanguages WHERE tblKartrisLanguages.LANG_ID=vKartrisTypeNews.LANG_ID) AS LANG_Culture, N_Name FROM vKartrisTypeNews
END
GO

/****** Object:  Index [ADR_UserID]    Script Date: 23/10/2016 16:02:53 ******/
CREATE NONCLUSTERED INDEX [ADR_UserID] ON [dbo].[tblKartrisAddresses]
(
	[ADR_UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO




















