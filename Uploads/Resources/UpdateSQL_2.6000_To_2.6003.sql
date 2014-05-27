/****** Object:  UserDefinedFunction [dbo].[fnTbl_SplitStrings]    Script Date: 01/23/2013 21:59:11 ******/
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
				VALUES (@_ID)              
			END                
			SET @List = RIGHT(@List, LEN(@List) - @Pos)                
			SET @Pos = CHARINDEX(',', @List, 1)        
		END    
	END     
	RETURN
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisQuantityDiscounts_GetByProduct]    Script Date: 2014-05-27 13:24:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spKartrisQuantityDiscounts_GetByProduct]
(
	@ProductID as int,
	@LangID as tinyint
)
AS
	SET NOCOUNT ON;
SELECT     tblKartrisQuantityDiscounts.QD_Quantity, tblKartrisQuantityDiscounts.QD_Price, vKartrisTypeVersions.V_Name, vKartrisTypeVersions.V_CodeNumber, vKartrisTypeVersions.V_ID
FROM         tblKartrisQuantityDiscounts INNER JOIN
					  vKartrisTypeVersions ON tblKartrisQuantityDiscounts.QD_VersionID = vKartrisTypeVersions.V_ID
WHERE     (vKartrisTypeVersions.V_ProductID = @ProductID) AND (vKartrisTypeVersions.LANG_ID = @LangID) AND (vKartrisTypeVersions.V_Live = 1)