/****** 
v2.8005 
Fixes spKartrisProducts_GetAttributeValue where P_ID was set as
a smallint, meaning that on the comparison table, products with
ID of more than 32,767 showed no attributes. Products DAL also
updated.
******/

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetAttributeValue]    Script Date: 2015-05-16 13:06:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: 
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisProducts_GetAttributeValue]
	(
	@P_ID int,
	@ATTRIB_ID int,
	@LANG_ID tinyint,
	@ATTRIBV_Value nvarchar(50) OUT
	)
AS
SELECT @ATTRIBV_Value = ATTRIBV_Value 
FROM vKartrisTypeAttributeValues 
WHERE vKartrisTypeAttributeValues.ATTRIBV_AttributeID = @ATTRIB_ID
	AND vKartrisTypeAttributeValues.ATTRIBV_ProductID = @P_ID
	AND vKartrisTypeAttributeValues.LANG_ID = @LANG_ID

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.8005', CFG_VersionAdded=2.8005 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO
