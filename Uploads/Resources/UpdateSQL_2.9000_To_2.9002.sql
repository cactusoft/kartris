/****** 
v2.9002 
Introduces new 'TEST' setting for email
Fixes line length of 20 in price update list
******/

/****** Let's update and add couple of config settings ******/
UPDATE tblKartrisConfig SET CFG_DisplayInfo='on|off|write|test', CFG_Description='"Write" will show emails on screen instead of sending, "test" will send any mails generated to email address set in general.email.testaddress' WHERE CFG_Name='general.email.method';
GO

INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES
 (N'general.email.testaddress', N'', N's', N't', NULL, N'Test email address to send all mail to when general.email.method="test"', 2.9002, N'', 0)
GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.9002', CFG_VersionAdded=2.9002 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_UpdatePriceList]    Script Date: 01/23/2013 21:59:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_UpdatePriceList]
(
	@PriceList as nvarchar(max),
	@LineNumber as bigint out
)								
AS
BEGIN
	
	SET NOCOUNT ON;
	SET @LineNumber = 0;
	--SET @PriceList = REPLACE(@PriceList, char(13), '#');
	SET @PriceList = REPLACE(@PriceList, char(10), '');

	DECLARE @ParsedList as table(Line varchar(200))
	DECLARE @Line varchar(200), @Pos int    
	SET @PriceList = LTRIM(RTRIM(@PriceList))+ '#'    
	SET @Pos = CHARINDEX('#', @PriceList, 1)    
	IF REPLACE(@PriceList, '#', '') <> '' BEGIN        
		WHILE @Pos > 0 BEGIN                
			SET @Line = LTRIM(RTRIM(LEFT(@PriceList, @Pos - 1)))                
			IF @Line <> '' BEGIN INSERT INTO @ParsedList (Line) VALUES (@Line);	END                
			SET @PriceList = RIGHT(@PriceList, LEN(@PriceList) - @Pos)                
			SET @Pos = CHARINDEX('#', @PriceList, 1)        
		END    
	END
;
	
	DECLARE @NewValues as nvarchar(50);
	DECLARE crsrPriceList CURSOR FOR
	select * from @ParsedList;

	OPEN crsrPriceList
	FETCH NEXT FROM crsrPriceList
	INTO @NewValues

	DECLARE @VersionCode as nvarchar(25), @Price as real;
	DECLARE @CommaPosition as int;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @LineNumber = @LineNumber + 1;
		SET @CommaPosition = CHARINDEX(',', @NewValues, 1);
		
		SET @VersionCode = LTRIM(RTRIM(LEFT(@NewValues, @CommaPosition - 1)))
		SET @Price = CAST(LTRIM(RTRIM( RIGHT(@NewValues, LEN(@NewValues) - @CommaPosition))) As real)
		
		UPDATE dbo.tblKartrisVersions
		SET V_Price = @Price WHERE V_CodeNumber = @VersionCode;
		
		FETCH NEXT FROM crsrPriceList
		INTO @NewValues
	END
	
	CLOSE crsrPriceList
	DEALLOCATE crsrPriceList;
END
GO
