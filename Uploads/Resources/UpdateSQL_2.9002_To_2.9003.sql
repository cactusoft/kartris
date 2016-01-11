--Insert Language Strings - Jóni Silva - 11/01/2016 BEGIN
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_ImportCustomerGroupPricesInfo', N'This is custom functionality, use the CustomerGroupPrices data export to<br/>
        obtain a file in suitable format<br />', NULL, 1.4, N'This is custom functionality, use the CustomerGroupPrices data export to<br/>
        obtain a file in suitable format<br />', NULL, N'_MarkupPrices',1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_ImportQuantityDiscounts', N'Import Quantity Discounts', NULL, 1.4, N'Import Quantity Discounts', NULL, N'_MarkupPrices',1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_ImportQuantityDiscountsInfo', N'This is custom functionality, use the QuantityDiscounts data export to<br />
        obtain a file in suitable format<br />', NULL, 1.4, N'This is custom functionality, use the QuantityDiscounts data export to<br />
        obtain a file in suitable format<br />', NULL, N'_MarkupPrices',1)
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