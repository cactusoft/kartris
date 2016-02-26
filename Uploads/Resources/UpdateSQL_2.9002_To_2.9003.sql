--Insert Language Strings - Jóni Silva - 11/01/2016 BEGIN
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_ImportCustomerGroupPrices', N'Import Customer Group Prices', NULL, 2.9003, N'', NULL, N'_MarkupPrices',1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_ImportCustomerGroupPricesInfo', N'This is custom functionality, use the CustomerGroupPrices data export to obtain a file in suitable format', NULL, 2.9003, N'This is custom functionality, use the CustomerGroupPrices data export to obtain a file in suitable format', NULL, N'_MarkupPrices',1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_ImportQuantityDiscounts', N'Import Quantity Discounts', NULL, 2.9003, N'Import Quantity Discounts', NULL, N'_MarkupPrices',1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_ImportQuantityDiscountsInfo', N'This is custom functionality, use the QuantityDiscounts data export to obtain a file in suitable format', NULL, 2.9003, N'', NULL, N'_MarkupPrices',1)
--Insert Language Strings - Jóni Silva - 11/01/2016 END
--Update Language Strings - Jóni Silva - 12/01/2016 BEGIN
UPDATE tblKartrisLanguageStrings
SET LS_Value = 'Here you can import price lists to update the database. Should be entered in this format:<br />
versioncode1, price1, rrp1<br />
versioncode2, price2, rrp2<br />
versioncode3, price3, rrp3<br />
etc...',
	LS_DefaultValue = 'Here you can import price lists to update the database. Should be entered in this format:<br />
versioncode1, price1, rrp1<br />
versioncode2, price2, rrp2<br />
versioncode3, price3, rrp3<br />
etc...'
WHERE LS_Name = 'ContentText_ImportPriceListInfo';
--Update Language Strings - Jóni Silva - 12/01/2016 END
--Added Exports - Jóni Silva - 12/01/2016 END
INSERT INTO [dbo].[tblKartrisSavedExports] ([EXPORT_Name], [EXPORT_DateCreated], [EXPORT_LastModified], [EXPORT_Details], [EXPORT_FieldDelimiter], [EXPORT_StringDelimiter]) VALUES (N'CustomerGroupPrices', CAST('2016-01-08 15:51:17.577' AS DateTime), CAST('2016-01-08 15:51:17.577' AS DateTime), N'SELECT        vKartrisTypeCustomerGroups.CG_Name, vKartrisTypeCustomerGroups.CG_ID, tblKartrisCustomerGroupPrices.CGP_VersionID, tblKartrisCustomerGroupPrices.CGP_Price FROM            vKartrisTypeCustomerGroups INNER JOIN dbo.tblKartrisCustomerGroupPrices ON vKartrisTypeCustomerGroups.CG_ID = dbo.tblKartrisCustomerGroupPrices.CGP_CustomerGroupID ORDER BY CG_ID, CGP_VersionID, CGP_Price', 44, 39);
INSERT INTO [dbo].[tblKartrisSavedExports] ([EXPORT_Name], [EXPORT_DateCreated], [EXPORT_LastModified], [EXPORT_Details], [EXPORT_FieldDelimiter], [EXPORT_StringDelimiter]) VALUES (N'QuantityDiscounts', CAST('2016-01-08 15:52:08.037' AS DateTime), CAST('2016-01-08 15:52:08.037' AS DateTime), N'SELECT QD_VersionID, QD_Quantity, QD_Price From tblKartrisQuantityDiscounts ORDER BY QD_VersionID', 44, 39);
INSERT INTO [dbo].[tblKartrisSavedExports] ([EXPORT_Name], [EXPORT_DateCreated], [EXPORT_LastModified], [EXPORT_Details], [EXPORT_FieldDelimiter], [EXPORT_StringDelimiter]) VALUES (N'PriceList', CAST('2016-01-12 15:35:29.923' AS DateTime), CAST('2016-01-12 15:35:29.923' AS DateTime), N'SELECT vKartrisTypeVersions.V_CodeNumber, vKartrisTypeVersions.V_Price, vKartrisTypeVersions.V_RRP FROM vKartrisTypeVersions ORDER BY V_CodeNumber', 44, 39);
--Added Exports - Jóni Silva - 12/01/2016 END

/****** 
v2.9003 
Introduces the "Customer-Group-Prices-Bulk-Update" feature
******/

/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_UpdateCustomerGroupPriceList]    Script Date: 2014-06-11 10:54:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisVersions_UpdateCustomerGroupPriceList]
(
	@CG_ID as bigint,
	@CGP_VersionID as bigint,
	@CGP_Price as real
)								
AS
BEGIN
	
	SET NOCOUNT ON;


	UPDATE dbo.tblKartrisCustomerGroupPrices
	SET CGP_Price = @CGP_Price WHERE CGP_VersionID = @CGP_VersionID AND CGP_CustomerGroupID = @CG_ID;

END

/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_UpdatePriceList]    Script Date: 12-01-2016 12:18:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Joni
-- Alter date: 12-01-2016
-- Description:	Added RPP field to the Update
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

	DECLARE @VersionCode as nvarchar(25), @PriceSubString as nvarchar(25), @Price as real, @RRP as real;
	DECLARE @CommaPosition as int, @RPPCommaPosition as int, @SubstringLength as int;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @LineNumber = @LineNumber + 1;
		SET @CommaPosition = CHARINDEX(',', @NewValues, 1);
		SET @RPPCommaPosition = CHARINDEX(',', @NewValues, @CommaPosition+1);
		SET @VersionCode = LTRIM(RTRIM(LEFT(@NewValues, @CommaPosition - 1)));
		SET @VersionCode = REPLACE(@VersionCode,'''','');
		SET @SubstringLength = (@RPPCommaPosition-@CommaPosition)-1;
		SET @PriceSubString = SUBSTRING(@NewValues, @CommaPosition+1, @SubstringLength);
		SET @Price = CAST(LTRIM(RTRIM(@PriceSubString)) As real);
		
		SET @RRP = CAST(LTRIM(RTRIM( RIGHT(@NewValues, LEN(@NewValues) - @RPPCommaPosition))) as real);

		UPDATE dbo.tblKartrisVersions
		SET V_Price = @Price,
			V_RRP = @RRP
		WHERE V_CodeNumber = @VersionCode;

		FETCH NEXT FROM crsrPriceList
		INTO @NewValues
	END
	
	CLOSE crsrPriceList
	DEALLOCATE crsrPriceList;

END
GO

/****** 
New config setting; this controls adding IDs to the HTML of the
navigation menus created using the menu adaptor which allows
custom styling of specific links
******/
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES (N'frontend.navigationmenu.cssids', N'n', N's', N'b', N'y|n', N'Whether to insert unique IDs into links in the navigation menus using the MenuAdapter.vb', 2.9003, N'n', 0)
GO

/****** 
New test email address functionality. When email method is set
to TEST, all email will be sent to the email address set in
general.email.testaddress
******/
UPDATE [dbo].[tblKartrisConfig] SET [CFG_DisplayInfo]='on|off|write|test' WHERE [CFG_Name]='general.email.method'
GO

/* Fix and improve options /combinations */
/****** Object:  View [dbo].[vKartrisCombinationPrices]    Script Date: 2016-01-21 21:11:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vKartrisCombinationPrices]
AS
SELECT        V_ProductID, V_ID, V_CodeNumber, V_Price, dbo.fnKartrisVersions_GetSortedOptionsByVersion(V_ID) AS V_OptionsIDs, V_Quantity, V_QuantityWarnLevel
FROM            dbo.tblKartrisVersions
WHERE        (V_Type = 'c') AND (V_Live = 1)

GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_GetByProductID]    Script Date: 2016-01-21 16:10:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[_spKartrisProducts_NumberOfCombinations]
(
	@P_ID int
)
AS
BEGIN
	SELECT	Count(V_ID) as Combinations
	FROM    tblKartrisVersions 
	WHERE   (tblKartrisVersions.V_ProductID = @P_ID) 
			AND (tblKartrisVersions.V_Type = 'c') 
			AND (tblKartrisVersions.V_Live = 1)
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetOptionsStockQuantity]    Script Date: 2016-01-21 13:03:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	
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
		-- Get stock quanity of the base version, should be only one
		SELECT @Qty = V_Quantity FROM tblKartrisVersions WHERE V_ProductID = @P_ID AND V_Type='b'
	END
	ELSE
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;

		-- need to sort the options' list to match the already sorted options
		--@OptionsList
		DECLARE @SortedOptions as nvarchar(max);
		SELECT @SortedOptions = COALESCE(@SortedOptions + ',', '') + CAST(T._ID as nvarchar(10))
		FROM (	SELECT DISTINCT Top(5000) _ID
				FROM dbo.fnTbl_SplitNumbers(@OptionList)
				ORDER BY _ID) AS T;

		SELECT @Qty = V_Quantity
		FROM dbo.vKartrisCombinationPrices
		WHERE V_ProductID = @P_ID AND V_OptionsIDs = @SortedOptions;
	END
END
GO

/****** 
Now have more language menu options. In addition to dropdown and image (flags) can
also have short or full culture (for example, EN or en-GB, respectively)
******/
UPDATE [dbo].[tblKartrisConfig] SET [CFG_DisplayInfo]='dropdown|image|linkshort|linkfull' WHERE [CFG_Name]='frontend.languages.display'
GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.9003', CFG_VersionAdded=2.9003 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO