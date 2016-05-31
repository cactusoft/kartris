/****** Object:  StoredProcedure [dbo].[_spKartrisDB_GetTaskList]    Script Date: 19/05/2016 16:27:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisDB_GetTaskList]
(	
	@NoOrdersToInvoice as int OUTPUT,
	@NoOrdersNeedPayment as int OUTPUT,
	@NoOrdersToDispatch as int OUTPUT,
	@NoStockWarnings as int OUTPUT,
	@NoOutOfStock as int OUTPUT,
	@NoReviewsWaiting as int OUTPUT,
	@NoAffiliatesWaiting as int OUTPUT,
	@NoCustomersWaitingRefunds as int OUTPUT,
	@NoCustomersInArrears as int OUTPUT
)
AS
BEGIN

	SELECT @NoOrdersToInvoice = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Invoiced = 'False' AND O_Paid = 'False' AND O_Sent = 'True' AND O_Cancelled = 'False';
	SELECT @NoOrdersNeedPayment = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Paid = 'False' AND O_Invoiced = 'True' AND O_Sent = 'True' AND O_Cancelled = 'False';
	SELECT @NoOrdersToDispatch = Count(O_ID) FROM dbo.tblKartrisOrders WHERE O_Sent = 'True' AND O_Paid = 'True' AND O_Shipped = 'False' AND O_Cancelled = 'False';
	SELECT @NoStockWarnings = Count(DISTINCT V_ID) FROM dbo.vKartrisProductsVersions WHERE V_QuantityWarnLevel >= V_Quantity AND V_QuantityWarnLevel <> 0 OPTION (FORCE ORDER);
	SELECT @NoOutOfStock = Count(DISTINCT V_ID) FROM dbo.vKartrisProductsVersions WHERE V_Quantity <= 0 AND V_QuantityWarnLevel <> 0 OPTION (FORCE ORDER);
	SELECT @NoReviewsWaiting = Count(REV_ID) FROM dbo.tblKartrisReviews WHERE REV_Live = 'a';
	SELECT @NoAffiliatesWaiting  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_IsAffiliate = 'True' AND U_AffiliateCommission = 0;
	SELECT @NoCustomersWaitingRefunds  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_CustomerBalance > 0;
	SELECT @NoCustomersInArrears  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_CustomerBalance < 0;
END
GO






/****** Clarification needs updating due to recent options improvements ******/
UPDATE tblKartrisLanguageStrings SET [LS_Value] = '*Applies to combinations, if combinations product.' WHERE [LS_Name] = 'ContentText_StockTrackingOptionsClarification' AND [LS_LangID] = 1
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_Update]    Script Date: 31/05/2016 08:06:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_Update]
(
	@V_ID as bigint,
	@V_CodeNumber as nvarchar(25),
	@V_ProductID as int,
	@V_Price as DECIMAL(18,4),
	@V_Tax as tinyint,
	@V_Weight as real,
	@V_DeliveryTime as tinyint,
	@V_Quantity as real,
	@V_QuantityWarnLevel as real,
	@V_Live as bit,
	@V_DownLoadInfo as nvarchar(255),
	@V_DownloadType as nvarchar(50),
	@V_RRP as DECIMAL(18,4),
	@V_Type as char(1),
	@V_CustomerGroupID as smallint,
	@V_CustomizationType as char(1),
	@V_CustomizationDesc as nvarchar(255),
	@V_CustomizationCost as DECIMAL(18,4),
	@V_Tax2 as tinyint,
	@V_TaxExtra as nvarchar(255),
	@V_BulkUpdateTimeStamp as datetime = NULL
)
								
AS
BEGIN
	
	SET NOCOUNT ON;

	UPDATE tblKartrisVersions
	SET V_CodeNumber = @V_CodeNumber, V_ProductID = @V_ProductID, V_Price = @V_Price, V_Tax = @V_Tax, V_Weight = @V_Weight, 
		V_DeliveryTime = @V_DeliveryTime, V_Quantity = @V_Quantity, V_QuantityWarnLevel = @V_QuantityWarnLevel, 
		V_Live = @V_Live, V_DownLoadInfo = @V_DownLoadInfo, V_DownloadType = @V_DownloadType,
		V_RRP = @V_RRP, V_Type = @V_Type, V_CustomerGroupID = @V_CustomerGroupID, V_CustomizationType = @V_CustomizationType,
		V_CustomizationDesc = @V_CustomizationDesc, V_CustomizationCost = @V_CustomizationCost, 
		V_Tax2 = @V_Tax2, V_TaxExtra = @V_TaxExtra,
		V_BulkUpdateTimeStamp = Coalesce(@V_BulkUpdateTimeStamp, GetDate())
	WHERE V_ID = @V_ID;
	
	IF @V_Type = 'b' BEGIN
		UPDATE tblKartrisVersions
		SET V_DownLoadInfo = @V_DownLoadInfo, V_DownloadType = @V_DownloadType
		WHERE V_ProductID = @V_ProductID AND V_Type = 'c';
	END

END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_UpdateCombinationVersion]    Script Date: 31/05/2016 08:06:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Updates a specific combination version
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_UpdateCombinationVersion]
(
	@ID as bigint,
	@Name as nvarchar(50), 
	@CodeNumber as nvarchar(50),
	@Price as real,
	@StockQty as real,
	@QtyWarnLevel as real,
	@Live as bit,
	@V_BulkUpdateTimeStamp as datetime = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE tblKartrisVersions
	SET V_CodeNumber = @CodeNumber, V_Price = @Price, V_Quantity = @StockQty, V_QuantityWarnLevel = @QtyWarnLevel, V_Live = @Live,
	V_BulkUpdateTimeStamp = Coalesce(@V_BulkUpdateTimeStamp, GetDate())
	WHERE V_ID = @ID;

	
	UPDATE tblKartrisLanguageElements
	SET LE_Value = @Name
	WHERE LE_TypeID = 1 AND LE_FieldID = 1 AND LE_ParentID = @ID;
END
GO

/****** Object:  Table [dbo].[tblKartrisStockNotifications]    Script Date: 30/05/2016 10:12:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tblKartrisStockNotifications](
	[SNR_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SNR_UserEmail] [nvarchar](255) NOT NULL,
	[SNR_VersionID] [bigint] NOT NULL,
	[SNR_PageLink] [nvarchar](255) NOT NULL,
	[SNR_ProductName] [nvarchar](255) NOT NULL,
	[SNR_DateCreated] [datetime] NOT NULL,
	[SNR_Status] [varchar](1) NOT NULL CONSTRAINT [DF_tblKartrisStockNotifications_SNR_Status]  DEFAULT ('w'),
	[SNR_DateSettled] [datetime] NULL,
	[SNR_UserIP] [varchar](50) NOT NULL,
	[SNR_LanguageID] [tinyint] NOT NULL,
 CONSTRAINT [PK_tblKartrisStockNotifications] PRIMARY KEY CLUSTERED 
(
	[SNR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Index [SNR_VersionID_Status]    Script Date: 26/05/2016 13:04:22 ******/
CREATE NONCLUSTERED INDEX [SNR_VersionID_Status] ON [dbo].[tblKartrisStockNotifications]
(
	[SNR_VersionID] ASC,
	[SNR_Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [SNR_UserEmail]    Script Date: 26/05/2016 13:04:48 ******/
CREATE NONCLUSTERED INDEX [SNR_UserEmail] ON [dbo].[tblKartrisStockNotifications]
(
	[SNR_UserEmail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  StoredProcedure [dbo].[spKartrisStockNotification_Add]    Script Date: 27/05/2016 10:05:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisStockNotification_Add]
(
	@UserEmail as nvarchar(255),
	@VersionID as bigint,
	@PageLink as nvarchar(255),
	@ProductName as nvarchar(255),
	@OpenedDate as datetime,
	@UserIP as varchar(50),
	@LanguageID as tinyint,
	@newSNR_ID as bigint OUTPUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO tblKartrisStockNotifications (SNR_UserEmail, SNR_VersionID, SNR_PageLink, SNR_ProductName, SNR_DateCreated, SNR_UserIP, SNR_LanguageID)
	VALUES (@UserEmail, @VersionID, @PageLink, @ProductName, @OpenedDate, @UserIP, @LanguageID);

	SELECT @newSNR_ID  = SCOPE_IDENTITY();
	
END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisStockNotifications_Search]    Script Date: 28/05/2016 18:28:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisStockNotifications_Search]
(
	@VersionID as bigint,
	@strStatus as varchar(1)
)
AS
BEGIN
	SELECT SNR_ID, SNR_UserEmail, SNR_VersionID, SNR_PageLink, SNR_ProductName, SNR_DateCreated, SNR_LanguageID
	  FROM tblKartrisStockNotifications WHERE SNR_VersionID=@VersionID AND SNR_Status=@strStatus
END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisStockNotification_Update]    Script Date: 30/05/2016 10:38:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisStockNotification_Update]
(
	@SNR_ID as bigint,
	@DateSettled as datetime,
	@strStatus as varchar(1)
)
AS
BEGIN
	UPDATE tblKartrisStockNotifications SET SNR_DateSettled=@DateSettled, SNR_Status=@strStatus
	  WHERE SNR_ID=@SNR_ID
END
GO

/****** NEW CONFIG SETTING TO TURN ON STOCK NOTIFICATION FEATURES ******/
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES
 (N'general.stocknotification.enabled', N'y', N's', N't', N'y|n', N'Allow customers to request notifications when out of stock item is back in stock', 2.9005, N'y', 0)
GO

/****** NEW CONFIG SETTING: DATE THAT CHECK FOR STOCK NOTIFICATIONS LAST RUN ******/
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES
 (N'hidden.stocknotification.lastrun', N'1900/1/1', N's', N't', N'', N'The stores the time of last bulk check on stock notifications.', 2.9005, N'1900/1/1', 0)
GO

/* These haven't been used for ages, get rid of them */
DELETE FROM tblKartrisConfig WHERE CFG_Name='hidden.currency.lastupdated';
DELETE FROM tblKartrisConfig WHERE CFG_Name='hidden.lastupdated';
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisStockNotifications_GetVersions]    Script Date: 31/05/2016 11:32:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date,,>
-- Description:	This sproc finds versions with
-- bulktimestamp value of a date (not null) that
-- is bigger than 1901/1/1. These will be 
-- versions that were imported by the data tool
-- or otherwise via _spKartrisVersions_Update
-- outside of the Kartris back end (ones done
-- via back end will run a check and send for
-- notifications where relevant anyway).
-- =============================================
CREATE PROCEDURE [dbo].[_spKartrisStockNotifications_GetVersions]

AS
BEGIN
	SELECT V_ID,
	Coalesce(V_BulkUpdateTimeStamp, '1900/1/1') As BulkUpdateTimeStamp,
	V_Live,
	V_Quantity,
	V_QuantityWarnLevel
	FROM tblKartrisVersions WHERE
	Coalesce(V_BulkUpdateTimeStamp, '1900/1/1')>'1901/1/1' AND V_QuantityWarnLevel>0 AND V_Quantity>0 AND V_Live=1 
END
GO

/****** 2.9005 'Nofity me' and stock warnings ******/
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'ContentText_NotifyMe', N'Notify me', NULL, 2.9005, N'Notify me', NULL, N'StockNotification',1);
GO
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'ContentText_NotifyMeDetails', N'Enter your email address and we''ll send you a notification when [productname] is back in stock.', NULL, 2.9005, N'Enter your email address and we''ll send you a notification when [productname] is back in stock.', NULL, N'StockNotification',1);
GO
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_StockNotification', N'Back in stock', 'Subject line of stock notification emails', 2.9005, N'Back in stock', NULL, N'_StockNotification',1);
GO
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_StockNotifications', N'Stock Notifications', 'Task list heading for stock notifications', 2.9005, N'Stock Notifications', NULL, N'_StockNotification',1);
GO
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_LastRun', N'Last Run: ', 'Task list last run text for stock notifications', 2.9005, N'Last run: ', NULL, N'_StockNotification',1);
GO
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_VersionsAwaitingCheck', N'Awaiting Check: ', '', 2.9005, N'Awaiting Check: ', NULL, N'_StockNotification',1);
GO
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_RunNotificationsCheck', N'Run Notifications Check', '', 2.9005, N'Run Notifications Check', NULL, N'_StockNotification',1);
GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.9005', CFG_VersionAdded=2.9005 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO



















