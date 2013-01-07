-- =============================================
-- KARTRIS UPDATE SCRIPT
-- From 1.3003 to 1.3004
-- =============================================


/****** Object:  StoredProcedure [dbo].[_spKartrisCoupons_GetGroups]    Script Date: 06/05/2011 17:24:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisCoupons_GetGroups]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT DISTINCT  COUNT(CP_ID) AS Qty, 
			CAST(YEAR(CP_CreatedTime) as nvarchar(4)) + '/' + CAST(MONTH(CP_CreatedTime) as nvarchar(2)) 
			+ '/' + CAST( DAY (CP_CreatedTime) as nvarchar(2)) as CreatedTime, 
			YEAR(CP_CreatedTime), MONTH(CP_CreatedTime), DAY (CP_CreatedTime)
	FROM         tblKartrisCoupons
	GROUP BY YEAR(CP_CreatedTime), MONTH(CP_CreatedTime), DAY (CP_CreatedTime)
	ORDER By YEAR(CP_CreatedTime) DESC, MONTH(CP_CreatedTime) DESC, DAY(CP_CreatedTime) DESC
	
END
