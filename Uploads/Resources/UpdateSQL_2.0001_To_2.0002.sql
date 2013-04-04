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