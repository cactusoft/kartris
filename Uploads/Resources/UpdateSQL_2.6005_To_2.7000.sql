/****** Object:  StoredProcedure [dbo].[_spKartrisDB_GetTaskList]    Script Date: 2014-08-18 18:15:58 ******/
-- removed linnworks 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
	
	SELECT @NoStockWarnings = Count(DISTINCT V_ID) FROM dbo.vKartrisProductsVersions WHERE V_QuantityWarnLevel >= V_Quantity AND V_QuantityWarnLevel <> 0;
	SELECT @NoOutOfStock = Count(DISTINCT V_ID) FROM dbo.vKartrisProductsVersions WHERE V_Quantity <= 0 AND V_QuantityWarnLevel <> 0;

	SELECT @NoReviewsWaiting = Count(REV_ID) FROM dbo.tblKartrisReviews WHERE REV_Live = 'a';
	SELECT @NoAffiliatesWaiting  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_IsAffiliate = 'True' AND U_AffiliateCommission = 0;
	SELECT @NoCustomersWaitingRefunds  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_CustomerBalance > 0;
	SELECT @NoCustomersInArrears  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_CustomerBalance < 0;
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnTbl_SplitStrings]    Script Date: 8/19/2014 6:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER FUNCTION [dbo].[fnTbl_SplitStrings]
(	
	@List varchar(max))
RETURNS @ParsedList 
table(_ID varchar(500)) AS BEGIN
	DECLARE @_ID varchar(500), @Pos int    
	SET @List = LTRIM(RTRIM(@List))+ ','    
	SET @Pos = CHARINDEX(',', @List, 1)    
	IF REPLACE(@List, ',', '') <> '' BEGIN        
		WHILE @Pos > 0 BEGIN                
			SET @_ID = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))                
			IF @_ID <> '' BEGIN                        
				INSERT INTO @ParsedList (_ID)                         
				VALUES (Replace(@_ID, '[;]',','))             
			END                
			SET @List = RIGHT(@List, LEN(@List) - @Pos)                
			SET @Pos = CHARINDEX(',', @List, 1)        
		END    
	END     
	RETURN
END
GO