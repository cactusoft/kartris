/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_GetByCategoryList]    Script Date: 04/04/2013 16:19:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_GetByCategoryList]
(
	@LANG_ID tinyint,
	@FromPrice float,
	@ToPrice float,
	@CategoryList nvarchar(max)
)
AS
	SET NOCOUNT ON;
	IF @CategoryList = '0' BEGIN
		SELECT DISTINCT dbo.fnKartrisProducts_GetName(V_ProductID, @LANG_ID) as P_Name, V_ID, V_Name, V_CodeNumber, V_Price, V_RRP, dbo.fnKartrisProducts_GetSupplierID(V_ProductID, @LANG_ID) as P_SupplierID
		FROM dbo.vKartrisTypeVersions
		WHERE LANG_ID = @LANG_ID AND V_Type IN ('v','b','c') AND V_Price BETWEEN @FromPrice AND @ToPrice
		ORDER BY P_Name, V_CodeNumber
	END ELSE BEGIN
		SELECT DISTINCT dbo.fnKartrisProducts_GetName(V_ProductID, @LANG_ID) as P_Name, V_ID, V_Name, V_CodeNumber, V_Price, V_RRP, dbo.fnKartrisProducts_GetSupplierID(V_ProductID, @LANG_ID) as P_SupplierID
		FROM dbo.vKartrisTypeVersions
		WHERE V_ProductID IN(SELECT DISTINCT PCAT_ProductID	
							 FROM dbo.tblKartrisProductCategoryLink
							 WHERE PCAT_CategoryID IN ( SELECT * FROM dbo.fnTbl_SplitNumbers(@CategoryList))) 
			AND LANG_ID = @LANG_ID AND V_Type IN ('v','b','c') AND V_Price BETWEEN @FromPrice AND @ToPrice
		ORDER BY P_Name, V_CodeNumber
	END
	
/****** Object:  UserDefinedFunction [dbo].[fnKartrisProducts_GetSupplierID]    Script Date: 04/04/2013 18:44:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Paul
-- Create date: 2013/04/04
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisProducts_GetSupplierID] 
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
	SELECT @Result = P_SupplierID FROM vKartrisTypeProducts WHERE P_ID = @P_ID AND LANG_ID = @LANG_ID ;

	-- Return the result of the function
	RETURN @Result

END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisSuppliers_Get]    Script Date: 04/04/2013 18:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisSuppliers_Get]
AS
	SET NOCOUNT ON;
	SELECT  *
	FROM	dbo.tblKartrisSuppliers
	ORDER BY SUP_Name

/****** Object:  StoredProcedure [dbo].[spKartrisCategories_GetByID]    Script Date: 04/18/2013 13:10:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spKartrisCategories_GetByID]
(
	@CAT_ID int,
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT        vKartrisTypeCategories.*
FROM            vKartrisTypeCategories
WHERE        (CAT_ID = @CAT_ID) AND (LANG_ID = @LANG_ID) AND CAT_Live=1
/****** Object:  StoredProcedure [dbo].[_spKartrisDB_GetTaskList]    Script Date: 04/20/2013 13:04:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Modified by:		Paul 2013/04/20
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
 ALTER PROCEDURE [dbo].[_spKartrisDB_GetTaskList]
(	
	@NoOrdersToInvoice as int OUTPUT,
	@NoOrdersNeedPayment as int OUTPUT,
	@NoOrdersToDispatch as int OUTPUT,
	@NoStockWarnings as int OUTPUT,
	@NoOutOfStock as int OUTPUT,
	@NoReviewsWaiting as int OUTPUT,
	@NoAffiliatesWaiting as int OUTPUT,
	@NoCustomersWaitingRefunds as int OUTPUT,
	@NoCustomersInArrears as int OUTPUT
)
AS
BEGIN
	SELECT @NoOrdersToInvoice = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Invoiced = 'False' AND O_Paid = 'False' AND O_Sent = 'True' AND O_Cancelled = 'False';
	SELECT @NoOrdersNeedPayment = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Paid = 'False' AND O_Invoiced = 'True' AND O_Sent = 'True' AND O_Cancelled = 'False';
	SELECT @NoOrdersToDispatch = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Sent = 'True' AND O_Paid = 'True' AND O_Shipped = 'False' AND O_Cancelled = 'False';
	
	SELECT @NoStockWarnings = Count(V_ID) FROM dbo.vKartrisProductsVersions WHERE V_QuantityWarnLevel >= V_Quantity AND V_QuantityWarnLevel <> 0;
	SELECT @NoOutOfStock = Count(V_ID) FROM dbo.vKartrisProductsVersions WHERE V_Quantity = 0 AND V_QuantityWarnLevel <> 0;

	SELECT @NoReviewsWaiting = Count(REV_ID) FROM dbo.tblKartrisReviews WHERE REV_Live = 'a';
	SELECT @NoAffiliatesWaiting  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_IsAffiliate = 'True' AND U_AffiliateCommission = 0;
	SELECT @NoCustomersWaitingRefunds  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_CustomerBalance > 0;
	SELECT @NoCustomersInArrears  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_CustomerBalance < 0;
END
