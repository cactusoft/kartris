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

/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetOptionsStockQuantity]    Script Date: 2015-11-10 17:35:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul/Mohammad
-- Create date: <Create Date,,>
-- Description:	Updated so returns base version
-- stock level if not combinatoins product
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisVersions_GetOptionsStockQuantity]
(
	@P_ID as int,
	@OptionList as nvarchar(500),
	@Qty as real OUT
)
AS
BEGIN
	DECLARE @NoOfCombinations as int;
	SELECT	@NoOfCombinations = Count(V_ID)
	FROM    tblKartrisVersions 
	WHERE   (tblKartrisVersions.V_ProductID = @P_ID) 
			AND (tblKartrisVersions.V_Type = 'c') 
			AND (tblKartrisVersions.V_Live = 1);
	IF @NoOfCombinations = 0
	BEGIN
		SET @Qty = 100;
		GoTo No_Combinations_Exist;
	END
	
	DECLARE @SIndx as int;
	DECLARE @CIndx as int;
	DECLARE @OptionID as nvarchar(4);
	DECLARE @Counter as int;

	DECLARE @VersionID AS bigint;
	DECLARE ProductVersionsCursor CURSOR FOR
	SELECT	V_ID
	FROM    tblKartrisVersions 
	WHERE   (tblKartrisVersions.V_ProductID = @P_ID) 
			AND (tblKartrisVersions.V_Type = 'c') 
			AND (tblKartrisVersions.V_Live = 1)

	OPEN ProductVersionsCursor
	FETCH NEXT FROM ProductVersionsCursor
	INTO @VersionID;

	DECLARE @WantedVersionID as bigint;
	SET @WantedVersionID = 0;

	DECLARE @No as tinyint;
	SET @No = 0;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Version' + Cast(@VersionID as nvarchar);
		SET @SIndx = 0;
		SET @Counter = 0;
		WHILE @SIndx <= LEN(@OptionList)
		BEGIN

			-- Loop through out the keyword's list
			SET @Counter = @Counter + 1;	-- keywords counter
			SET @CIndx = CHARINDEX(',', @OptionList, @SIndx)	-- Next keyword starting index (1-Based Index)
			IF @CIndx = 0 BEGIN SET @CIndx = LEN(@OptionList)+ 1 END	-- If no more keywords, set next starting index to not exist
			SET @OptionID = SUBSTRING(@OptionList, @SIndx, @CIndx - @SIndx)
			PRINT 'Key:' + @OptionID;
			
			SELECT @No = Count(1)
			FROM tblKartrisVersionOptionLink
			WHERE V_OPT_OptionID = CAST(@OptionID AS BIGINT) AND V_OPT_VersionID = @VersionID;
			PRINT 'No:' + Cast(@No as nvarchar) + ' ON option:' + @OptionID + ' AND version:' + CAST(@VersionID AS nvarchar);

			IF @No = 0
			BEGIN
				BREAK;
			END

			SET @SIndx = @CIndx + 1;	-- The next starting index
		END

		IF @No <> 0
		BEGIN
			DECLARE @NoOfRecords as int;
			SET @NoOfRecords = 0;

			SELECT	@NoOfRecords = Count(1)
			FROM	tblKartrisVersionOptionLink 
			WHERE tblKartrisVersionOptionLink.V_OPT_VersionID = @VersionID;

			IF @NoOfRecords = @Counter
			BEGIN			
				SET @WantedVersionID = @VersionID;
				BREAK;
			END
		END	
		
		FETCH NEXT FROM ProductVersionsCursor
		INTO @VersionID;	
	END

	CLOSE ProductVersionsCursor
	DEALLOCATE ProductVersionsCursor;

	SELECT	@Qty = tblKartrisVersions.V_Quantity
	FROM    tblKartrisVersions 
	WHERE   V_ID = @WantedVersionID;
		

	No_Combinations_Exist:
	-- Get stock quanity of the base version, should be only one
	SELECT @Qty = V_Quantity FROM tblKartrisVersions WHERE V_ProductID = @P_ID
END

GO

/* New Config settings for postcodes4u data lookup */
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES
 (N'general.services.postcodes4u.username', N'', N's', N't', NULL, N'Your account username for postcodes4u. Leave blank to disable this feature.', 2.9002, N'', 0)
GO

INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES
 (N'general.services.postcodes4u.key', N'', N's', N't', NULL, N'Product key for your postcodes4u account.', 2.9002, N'', 0)
GO
