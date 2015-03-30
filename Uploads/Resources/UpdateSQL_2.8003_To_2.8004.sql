/****** 
v2.8004 
Fixes spKartrisProducts_GetTopList, the LANG and P IDs were round the wrong way
In back end, sort shipping zones by OrderBy value
******/

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetTopList]    Script Date: 7/21/2014 10:14:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Medz
-- Create date: 02/12/2008 13:52:43
-- Last Modified: Mohammad - July 2014
-- Description:	Replaces spKartris_Prod_TopList
-- Remarks:	Optimization (Medz) - 04-07-2010
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
GO

/****** Object:  UserDefinedFunction [dbo].[fnKartrisProducts_GetName]    Script Date: 01/23/2013 21:59:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [dbo].[fnKartrisProducts_GetName] 
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
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisShippingZones_Get]    Script Date: 2015-03-26 14:49:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[_spKartrisShippingZones_Get]
(
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT        SZ_ID, LANG_ID, SZ_Name, SZ_Live, SZ_OrderByValue
FROM            vKartrisTypeShippingZones
WHERE        (LANG_ID = @LANG_ID)
ORDER BY SZ_OrderByValue
GO

/****** Allow turning off back end homepage graphs on big sites where this can cause timeouts ******/
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES (N'backend.homepage.graphs', N'ON', N's', N'b', 'ON|OFF', N'Hides the data summary graphs on the back end home page, suggested on large sites where the queries may time out and put unnecessary load on site.', 2.8004, N'ON', 0)
GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.8004', CFG_VersionAdded=2.8004 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO
