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