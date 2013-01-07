-- ############ config table #####################
DISABLE TRIGGER trigKartrisConfig_DML ON [dbo].[tblKartrisConfig]
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CactuShopName_DEPRECATED], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES (N'frontend.minibasket.compactversion', NULL, N'n', N's', N'b', NULL, N'This setting sets the minibasket to a single one line summary that occupies minimal screen space on each page - useful for showing the basket in the header as is a fixed size.', 1.1, N'n', 0)
DELETE FROM [dbo].[tblKartrisConfig] WHERE [CFG_Name] = 'frontend.users.customerdiscount';
ENABLE TRIGGER trigKartrisConfig_DML ON [dbo].[tblKartrisConfig];

-- ############ language strings table #####################
DISABLE TRIGGER trigKartrisLanguageStrings_DML ON [dbo].[tblKartrisLanguageStrings];
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_SupportExpiresMessage', N'Your premium support expires on [date].', NULL, 1, N'Your premium support expires on [date].', NULL, N'Tickets', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'ContentText_SupportExpiredMessage', N'Your premium support expired on [date].', NULL, 1, N'Your premium support expired on [date].', NULL, N'Tickets', 1)
ENABLE TRIGGER trigKartrisLanguageStrings_DML ON [dbo].[tblKartrisLanguageStrings];

-- ############ Support Ticket Types #####################
DISABLE TRIGGER trigKartrisSupportTicketTypes_DML ON dbo.tblKartrisSupportTicketTypes;
DELETE FROM dbo.tblKartrisSupportTicketTypes;
GO
ALTER TABLE dbo.tblKartrisSupportTicketTypes ADD [STT_Level] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
SET IDENTITY_INSERT [dbo].[tblKartrisSupportTicketTypes] ON
INSERT [dbo].[tblKartrisSupportTicketTypes] ([STT_ID], [STT_Name], [STT_Level]) VALUES (1, N'Sales Enquiry', N's')
INSERT [dbo].[tblKartrisSupportTicketTypes] ([STT_ID], [STT_Name], [STT_Level]) VALUES (2, N'Product Return', N's')
INSERT [dbo].[tblKartrisSupportTicketTypes] ([STT_ID], [STT_Name], [STT_Level]) VALUES (3, N'Premium Technical Support', N'p')
INSERT [dbo].[tblKartrisSupportTicketTypes] ([STT_ID], [STT_Name], [STT_Level]) VALUES (4, N'Suggestion', N's')
SET IDENTITY_INSERT [dbo].[tblKartrisSupportTicketTypes] OFF
GO;
ENABLE TRIGGER trigKartrisSupportTicketTypes_DML ON dbo.tblKartrisSupportTicketTypes;
-- ############ Users Table #####################
ALTER TABLE dbo.tblKartrisUsers ADD [U_SupportEndDate] [datetime] NULL;
GO
-- ############ fields renaming #####################
sp_RENAME 'tblKartrisSupportTicketMessages.TIC_ID', 'STM_TicketID' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSupportTicketMessages.LOGIN_ID', 'STM_LoginID' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSupportTickets.U_ID', 'TIC_UserID' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSupportTickets.Login_ID', 'TIC_LoginID' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSupportTickets.STT_ID', 'TIC_SupportTicketTypeID' , 'COLUMN'
GO

sp_RENAME 'tblKartrisSearchHelper.SearchHelperID', 'SH_ID' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSearchHelper.SessionID', 'SH_SessionID' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSearchHelper.TypeID', 'SH_TypeID' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSearchHelper.FieldID', 'SH_FieldID' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSearchHelper.ParentID', 'SH_ParentID' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSearchHelper.TextValue', 'SH_TextValue' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSearchHelper.ProductID', 'SH_ProductID' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSearchHelper.Price', 'SH_Price' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSearchHelper.Score', 'SH_Score' , 'COLUMN'
GO

sp_RENAME 'tblKartrisSavedExports.Export_ID', 'EXPORT_ID' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSavedExports.Export_Name', 'EXPORT_Name' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSavedExports.Export_DateCreated', 'EXPORT_DateCreated' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSavedExports.Export_LastModified', 'EXPORT_LastModified' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSavedExports.Export_Details', 'EXPORT_Details' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSavedExports.Export_FieldDelimiter', 'EXPORT_FieldDelimiter' , 'COLUMN'
GO
sp_RENAME 'tblKartrisSavedExports.Export_StringDelimiter', 'EXPORT_StringDelimiter' , 'COLUMN'
GO

sp_RENAME 'tblKartrisAdminRelatedTables.TableName', 'ART_TableName' , 'COLUMN'
GO
sp_RENAME 'tblKartrisAdminRelatedTables.TableOrder_Products', 'ART_TableOrderProducts' , 'COLUMN'
GO
sp_RENAME 'tblKartrisAdminRelatedTables.TableOrder_Orders', 'ART_TableOrderOrders' , 'COLUMN'
GO
sp_RENAME 'tblKartrisAdminRelatedTables.TableOrder_Sessions', 'ART_TableOrderSessions' , 'COLUMN'
GO
sp_RENAME 'tblKartrisAdminRelatedTables.TableStartingIdentity', 'ART_TableStartingIdentity' , 'COLUMN'
GO

sp_RENAME 'tblKartrisBasketOptionValues.BSKOPT_BasketValueID', 'BSKTOPT_BasketValueID' , 'COLUMN'
GO;
