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

/****** Object:  StoredProcedure [dbo].[spKartrisMediaLinks_GetByParent]    Script Date: 2015-06-04 18:21:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	Updated to fix sorting
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisMediaLinks_GetByParent]
(
	@ParentID as bigint, 
	@ParentType as nvarchar(1)
)
AS
BEGIN
SET NOCOUNT ON;
SELECT     tblKartrisMediaLinks.ML_ID, tblKartrisMediaLinks.ML_ParentID, tblKartrisMediaLinks.ML_ParentType, tblKartrisMediaLinks.ML_EmbedSource, 
					  tblKartrisMediaLinks.ML_MediaTypeID, tblKartrisMediaLinks.ML_Height, tblKartrisMediaLinks.ML_Width, 
					  tblKartrisMediaLinks.ML_isDownloadable, tblKartrisMediaLinks.ML_Parameters, tblKartrisMediaTypes.MT_DefaultHeight, 
					  tblKartrisMediaTypes.MT_DefaultWidth, tblKartrisMediaTypes.MT_DefaultParameters, tblKartrisMediaTypes.MT_DefaultisDownloadable, 
					  tblKartrisMediaTypes.MT_Extension,tblKartrisMediaTypes.MT_Embed, tblKartrisMediaTypes.MT_Inline, tblKartrisMediaLinks.ML_Live
FROM         tblKartrisMediaLinks LEFT OUTER JOIN
					  tblKartrisMediaTypes ON tblKartrisMediaLinks.ML_MediaTypeID = tblKartrisMediaTypes.MT_ID
WHERE     (tblKartrisMediaLinks.ML_ParentID = @ParentID) AND (tblKartrisMediaLinks.ML_ParentType = @ParentType) AND (tblKartrisMediaLinks.ML_Live = 1)
ORDER BY ML_SortOrder
END

GO

SET IDENTITY_INSERT [dbo].[tblKartrisMediaTypes] ON
INSERT [dbo].[tblKartrisMediaTypes] ([MT_ID], [MT_Extension], [MT_DefaultHeight], [MT_DefaultWidth], [MT_DefaultParameters], [MT_DefaultisDownloadable], [MT_Embed], [MT_Inline]) VALUES (8, N'urlnewtab', 10, 10, NULL, 0, 1, 0)
INSERT [dbo].[tblKartrisMediaTypes] ([MT_ID], [MT_Extension], [MT_DefaultHeight], [MT_DefaultWidth], [MT_DefaultParameters], [MT_DefaultisDownloadable], [MT_Embed], [MT_Inline]) VALUES (9, N'urlpopup', 480, 640, NULL, 0, 1, 0)
INSERT [dbo].[tblKartrisMediaTypes] ([MT_ID], [MT_Extension], [MT_DefaultHeight], [MT_DefaultWidth], [MT_DefaultParameters], [MT_DefaultisDownloadable], [MT_Embed], [MT_Inline]) VALUES (10, N'zip', 10, 10, NULL, 1, 0, 0)
GO
SET IDENTITY_INSERT [dbo].[tblKartrisMediaTypes] OFF

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.8005', CFG_VersionAdded=2.8005 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO
