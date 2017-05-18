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

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetNewestProducts]    Script Date: 09/11/2016 15:11:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: 
-- Description:	
-- Remarks: Optimization (Medz) - Modified to use product views instead and to lessen use of GetName function - 14-07-2010
-- Remarks2: Further Optimization (Mohammad) - Remove usage of product versions view and use the Language Elements directly - 15-11-2013
-- Remarks3: Added P_Live=1 to where clause, so only live products show
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
	
	SELECT DISTINCT TOP (10) tblKartrisProducts.P_ID, tblKartrisLanguageElements.LE_Value AS P_Name, tblKartrisProducts.P_DateCreated, @LANG_ID LANG_ID
	FROM    tblKartrisProducts INNER JOIN
			  tblKartrisVersions ON tblKartrisProducts.P_ID = tblKartrisVersions.V_ProductID INNER JOIN
			  tblKartrisProductCategoryLink ON tblKartrisProducts.P_ID = tblKartrisProductCategoryLink.PCAT_ProductID INNER JOIN
			  tblKartrisCategories ON tblKartrisProductCategoryLink.PCAT_CategoryID = tblKartrisCategories.CAT_ID INNER JOIN
			  tblKartrisLanguageElements ON tblKartrisProducts.P_ID = tblKartrisLanguageElements.LE_ParentID
	WHERE   (tblKartrisProducts.P_Live=1) AND (tblKartrisProducts.P_CustomerGroupID IS NULL) AND (tblKartrisCategories.CAT_CustomerGroupID IS NULL) AND (tblKartrisVersions.V_CustomerGroupID IS NULL) AND
		   (tblKartrisLanguageElements.LE_LanguageID = @LANG_ID) AND (tblKartrisLanguageElements.LE_TypeID = 2) AND (tblKartrisLanguageElements.LE_FieldID = 1) AND 
		  (NOT (tblKartrisLanguageElements.LE_Value IS NULL))
	ORDER BY tblKartrisProducts.P_DateCreated DESC, tblKartrisProducts.P_ID DESC

END
GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.9007', CFG_VersionAdded=2.9007 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO




















