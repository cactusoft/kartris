
/****** Object:  Index [CO_ParentOrderID]    Script Date: 25/11/2021 20:18:48 ******/
CREATE UNIQUE NONCLUSTERED INDEX [CO_ParentOrderID] ON [dbo].[tblKartrisClonedOrders]
(
	[CO_ParentOrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

/****** Object:  StoredProcedure [dbo].[spKartrisBasket_DeleteSavedBasketByNameAndUserID]    Script Date: 2022-03-10 10:07:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: 10/Mar/2022
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisBasket_DeleteSavedBasketByNameAndUserID] (
	@UserID bigint,
	@SBSKT_Name nvarchar(200)
) AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @SBSKT_ID as int;

	SELECT @SBSKT_ID = SBSKT_ID FROM tblKartrisSavedBaskets WHERE SBSKT_Name='AUTOSAVE' AND SBSKT_UserID=@UserID;
	
	DELETE tblKartrisSavedBaskets 
	WHERE SBSKT_ID=@SBSKT_ID;
	

--	
	DELETE tblKartrisBasketOptionValues
	WHERE BSKTOPT_BasketValueID in (SELECT BV_ID FROM tblKartrisBasketValues WHERE BV_ParentID=@SBSKT_ID and BV_ParentType='s');
--	

--	
	DELETE tblKartrisBasketValues
	WHERE BV_ParentID=@SBSKT_ID and BV_ParentType='s';
--	

END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_DetailsUpdate]    Script Date: 17/01/2022 11:09:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[_spKartrisOrders_DetailsUpdate]
(
	@O_ID int,
	@O_Details nvarchar(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
		
	
	UPDATE [tblKartrisOrders] SET [O_Details] = @O_Details
		WHERE [O_ID] = @O_ID;

	SELECT @O_ID;
END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisOrders_GetCustomerTotal]    Script Date: 28/01/2022 10:39:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisOrders_GetCustomerTotal]
(
	@CustomerID as int
)
AS
BEGIN

	SELECT Sum(O_TotalPrice / O_CurrencyRate) as TotalValue
	FROM dbo.tblKartrisOrders LEFT OUTER JOIN
					  tblKartrisClonedOrders ON tblKartrisOrders.O_ID = tblKartrisClonedOrders.CO_ParentOrderID
	WHERE CO_OrderID IS NULL AND O_CustomerID = @CustomerID AND O_Sent = 1 AND O_Cancelled<>1

END
GO

/* Change the OrderNo field in category-product link, smallint too small when have large number (32768+) products in a category */
ALTER TABLE tblKartrisProductCategoryLink ALTER COLUMN PCAT_OrderNo int

/* Fix to customer balance, which is currency */
ALTER TABLE [dbo].[tblKartrisUsers] ALTER COLUMN U_CustomerBalance DECIMAL(18,4) NULL

/****** New config setting, google tag manager v3.2001 ******/
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'ContentText_StockNotificationAdded', N'Thanks! You will be notified by email when the item is back in stock.', NULL, 3.2002, N'', NULL, N'StockNotification',1)
GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='3.2002', CFG_VersionAdded=3.2002 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO


