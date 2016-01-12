--Insert Language Strings - Jóni Silva - 11/01/2016 BEGIN
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_ImportCustomerGroupPrices', N'Import Customer Group Prices', NULL, 2.9003, N'', NULL, N'_MarkupPrices',1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_ImportCustomerGroupPricesInfo', N'This is custom functionality, use the CustomerGroupPrices data export to obtain a file in suitable format', NULL, 2.9003, N'This is custom functionality, use the CustomerGroupPrices data export to obtain a file in suitable format', NULL, N'_MarkupPrices',1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_ImportQuantityDiscounts', N'Import Quantity Discounts', NULL, 2.9003, N'Import Quantity Discounts', NULL, N'_MarkupPrices',1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_ImportQuantityDiscountsInfo', N'This is custom functionality, use the QuantityDiscounts data export to obtain a file in suitable format', NULL, 2.9003, N'', NULL, N'_MarkupPrices',1)
--Insert Language Strings - Jóni Silva - 11/01/2016 END

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
UPDATE [dbo].[tblKartrisConfig] SET [CFG_DisplayType]='on|off|write|test' WHERE [CFG_Name]='general.email.method'
GO
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES (N'general.email.testaddress', N'', N's', N't', NULL, N'Test email address to send all mail to when general.email.method="test"', 2.9003, N'', 0)
GO