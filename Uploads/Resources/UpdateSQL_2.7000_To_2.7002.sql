

-- =============================================
-- Author:		Mohammad
-- Description:	Updated by Paul, change field
-- in ORDER BY clause
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisAttributes_GetSummaryByProductID]
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
ORDER BY vKartrisTypeAttributes.ATTRIB_OrderByValue
END
GO

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetTopList]    Script Date: 2014-10-09 10:17:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Medz
-- Create date: 02/12/2008 13:52:43
-- Last Modified: Paul - Oct 2014
-- Description:	Replaces spKartris_Prod_TopList
-- Remarks:	Switched Prod ID and Lang ID in 
-- [fnKartrisProducts_GetName] call
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisProducts_GetTopList]
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
	WITH tblTopList AS
	(
		SELECT  tblKartrisInvoiceRows.IR_VersionCode AS IR_VersionCode, SUM(tblKartrisInvoiceRows.IR_Quantity) AS IR_Quantity
		FROM    tblKartrisInvoiceRows LEFT OUTER JOIN tblKartrisOrders ON tblKartrisInvoiceRows.IR_OrderNumberID = tblKartrisOrders.O_ID
		WHERE   (tblKartrisOrders.O_Paid = 1) AND (tblKartrisOrders.O_Date >= @StartDate)
		GROUP BY tblKartrisInvoiceRows.IR_VersionCode
	)
	SELECT TOP (@Limit) vKartrisCategoryProductsVersionsLink.P_ID, [dbo].[fnKartrisProducts_GetName](vKartrisCategoryProductsVersionsLink.P_ID, @LANG_ID) AS P_Name, 
				@LANG_ID as LANG_ID, SUM(tblTopList.IR_Quantity) as ProductHits
	FROM tblTopList INNER JOIN dbo.vKartrisCategoryProductsVersionsLink ON tblTopList.IR_VersionCode = dbo.vKartrisCategoryProductsVersionsLink.V_CodeNumber
	WHERE	vKartrisCategoryProductsVersionsLink.V_CustomerGroupID IS NULL 
		AND vKartrisCategoryProductsVersionsLink.P_CustomerGroupID IS NULL 
		AND vKartrisCategoryProductsVersionsLink.CAT_CustomerGroupID IS NULL
	GROUP BY vKartrisCategoryProductsVersionsLink.P_ID, [dbo].[fnKartrisProducts_GetName](vKartrisCategoryProductsVersionsLink.P_ID, @LANG_ID)
	ORDER BY ProductHits DESC

END
