/****** 
v2.8003 
This script primarily sorts an issue with Attributes, where the attribute ID
was a tinyint, so no more than 255 attributes could be created. It is now an
Int. The DAL, BLL and attributes controls have also been updated to use 
Integer instead of Byte types.
******/

/****** Drop Various constraints linked to ATTRIB_ID ******/
ALTER TABLE [dbo].[tblKartrisAttributeValues] DROP CONSTRAINT [FK_tblKartrisAttributeValues_tblKartrisAttributes]
GO
ALTER TABLE [dbo].[tblKartrisAttributes] DROP CONSTRAINT [CK_AttributesPreventZeroID]
GO
DROP INDEX [idxAttrib_ID] ON [dbo].[tblKartrisAttributes] WITH ( ONLINE = OFF )
GO
ALTER TABLE [dbo].[tblKartrisAttributes] DROP CONSTRAINT [aaaaatblKartrisAttributes_PK]
GO
DROP INDEX [PROP_ID] ON [dbo].[tblKartrisAttributes]
GO
ALTER TABLE [dbo].[tblKartrisAttributeValues] DROP CONSTRAINT [DF__tblKartris__ATTRI__236943A5]
GO
DROP INDEX [PROPV_PropertyID] ON [dbo].[tblKartrisAttributeValues]
GO

/****** Change ATTRIB_ID and ATTRIBV_ to INT, from tinyint ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[tblKartrisAttributes] ALTER COLUMN [ATTRIB_ID] [int] NOT NULL
GO
SET ANSI_PADDING OFF
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[tblKartrisAttributeValues] ALTER COLUMN [ATTRIBV_AttributeID] [int] NOT NULL
GO

/****** Recreate Various constraints linked to ATTRIB_ID ******/
ALTER TABLE [dbo].[tblKartrisAttributes]  WITH CHECK ADD  CONSTRAINT [CK_AttributesPreventZeroID] CHECK  (([ATTRIB_ID]>(0)))
GO
ALTER TABLE [dbo].[tblKartrisAttributes] CHECK CONSTRAINT [CK_AttributesPreventZeroID]
GO
CREATE UNIQUE CLUSTERED INDEX [idxAttrib_ID] ON [dbo].[tblKartrisAttributes]
(
	[ATTRIB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblKartrisAttributes] ADD  CONSTRAINT [aaaaatblKartrisAttributes_PK] PRIMARY KEY NONCLUSTERED 
(
	[ATTRIB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PROP_ID] ON [dbo].[tblKartrisAttributes]
(
	[ATTRIB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblKartrisAttributeValues] ADD  CONSTRAINT [DF__tblKartris__ATTRI__236943A5]  DEFAULT ((0)) FOR [ATTRIBV_AttributeID]
GO
CREATE NONCLUSTERED INDEX [PROPV_PropertyID] ON [dbo].[tblKartrisAttributeValues]
(
	[ATTRIBV_AttributeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblKartrisAttributeValues]  WITH CHECK ADD  CONSTRAINT [FK_tblKartrisAttributeValues_tblKartrisAttributes] FOREIGN KEY([ATTRIBV_AttributeID])
REFERENCES [dbo].[tblKartrisAttributes] ([ATTRIB_ID])
GO
ALTER TABLE [dbo].[tblKartrisAttributeValues] CHECK CONSTRAINT [FK_tblKartrisAttributeValues_tblKartrisAttributes]
GO


/****** Object:  StoredProcedure [dbo].[_spKartrisAttributes_Add]    Script Date: 2015-03-19 14:47:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisAttributes_Add]
(
	@Type char(1),
	@Live bit,
	@FastEntry bit,
	@ShowFrontend bit,
	@ShowSearch bit,
	@OrderByValue tinyint,
	@Compare char(1),
	@Special bit,
	@NewAttribute_ID int OUT
)
AS
	SET NOCOUNT OFF;
	INSERT INTO tblKartrisAttributes
	VALUES 
	(@Type, @Live, @FastEntry, @ShowFrontend, @ShowSearch, 
		@OrderByValue, @Compare, @Special);

	SELECT @NewAttribute_ID = SCOPE_IDENTITY();

/****** Object:  StoredProcedure [dbo].[_spKartrisAttributes_Delete]    Script Date: 2015-03-19 14:51:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisAttributes_Delete]
(
	@AttributeID as int
)
AS
BEGIN
	SET NOCOUNT ON;

	
		DELETE FROM dbo.tblKartrisLanguageElements 
		WHERE (LE_TypeID = 14 AND LE_ParentID IN (SELECT ATTRIBV_ID FROM dbo.tblKartrisAttributeValues WHERE ATTRIBV_AttributeID = @AttributeID))
			OR (LE_TypeID = 4 AND LE_ParentID = @AttributeID);
	
		DELETE FROM dbo.tblKartrisAttributeValues WHERE ATTRIBV_AttributeID = @AttributeID;
		DELETE FROM tblKartrisAttributes WHERE ATTRIB_ID = @AttributeID;
END

/****** Object:  StoredProcedure [dbo].[_spKartrisAttributes_GetByID]    Script Date: 2015-03-19 14:51:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisAttributes_GetByID]
(
	@AttributeID as int
)
AS
	SET NOCOUNT ON;
SELECT     ATTRIB_ID, ATTRIB_Type, ATTRIB_Live, ATTRIB_FastEntry, ATTRIB_ShowFrontend, ATTRIB_ShowSearch, ATTRIB_OrderByValue, ATTRIB_Compare, 
					  ATTRIB_Special
FROM         tblKartrisAttributes
WHERE     (ATTRIB_ID = @AttributeID)

/****** Object:  StoredProcedure [dbo].[_spKartrisAttributes_Update]    Script Date: 2015-03-19 14:52:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisAttributes_Update]
(
	@Type char(1),
	@Live bit,
	@FastEntry bit,
	@ShowFrontend bit,
	@ShowSearch bit,
	@OrderByValue tinyint,
	@Compare char(1),
	@Special bit,
	@Original_AttributeID int	
)
AS
	SET NOCOUNT OFF;

	UPDATE [tblKartrisAttributes] 
	SET [ATTRIB_Type] = @Type, [ATTRIB_Live] = @Live, [ATTRIB_FastEntry] = @FastEntry, 
		[ATTRIB_ShowFrontend] = @ShowFrontend, [ATTRIB_ShowSearch] = @ShowSearch, 
		[ATTRIB_OrderByValue] = @OrderByValue, [ATTRIB_Compare] = @Compare, 
		[ATTRIB_Special] = @Special 
	WHERE ([ATTRIB_ID] = @Original_AttributeID);

/****** Object:  StoredProcedure [dbo].[_spKartrisAttributeValues_Add]    Script Date: 2015-03-19 14:53:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisAttributeValues_Add]
(
	@ProductID as int,
	@AttributeID as int,
	@NewAttributeValue_ID as int OUT
)
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO dbo.tblKartrisAttributeValues
	VALUES (@ProductID, @AttributeID);
	SELECT @NewAttributeValue_ID = SCOPE_IDENTITY();
END

/****** Object:  StoredProcedure [dbo].[_spKartrisAttributes_GetByLanguage]    Script Date: 2015-03-19 19:58:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisAttributes_GetByLanguage]
(
	@LANG_ID as tinyint
)
AS
	SET NOCOUNT ON;
SELECT        vKartrisTypeAttributes.*
FROM            vKartrisTypeAttributes
WHERE ( LANG_ID = @LANG_ID)
ORDER BY ATTRIB_OrderByValue

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetAttributeValue]    Script Date: 2015-03-20 08:15:57 ******/
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
	@P_ID smallint,
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

/****** set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.8003', CFG_VersionAdded=2.8 WHERE CFG_Name='general.kartrisinfo.versionadded';