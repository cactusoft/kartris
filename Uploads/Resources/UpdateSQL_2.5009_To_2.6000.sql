INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'PageTitle_CreateNewOrder', N'Create A New Order', NULL, 2.6000, N'Create A New Order', NULL, N'_Orders', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ErrorText_PasswordsMustMatch', N'Passwords must match!', NULL, 2.6000, N'Passwords must match!', NULL, N'_Orders', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_NewOrderConfirmation', N'Are you sure you want to create this order?', NULL, 2.6000, N'Are you sure you want to create this order?', NULL, N'_Orders', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_PayForThisOrder', N'Pay For This Order', NULL, 2.6000, N'Pay For This Order', NULL, N'_Orders', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'b', N'ContentText_OrderCreatedByAdmin', N'Order created in the backend by admin account - ', NULL, 2.6000, N'Order created in the backend by admin account - ', NULL, N'_Orders', 1)

-- =============================================
-- Author: Paul
-- Create date: <Create Date,,>
-- Description:	New language strings for
-- optional PowerPack
-- =============================================
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'ContentText_RefineSelection', N'Refine Selection', NULL, 2.6100, N'', NULL, N'Filters', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'ContentText_PriceRange', N'Price Range', NULL, 2.6100, N'', NULL, N'Filters', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'ContentText_Custom', N'Custom', NULL, 2.6100, N'', NULL, N'Filters', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'ContentText_Apply', N'Apply', NULL, 2.6100, N'', NULL, N'Filters', 1)
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'ContentText_SortBy', N'Sort By', NULL, 2.6100, N'', NULL, N'Filters', 1)


/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_ChangeSortValue]    Script Date: 04/02/2014 18:15:50 ******/
-- This fixes an issue where versions imported via the Data Tool
-- all have same sort order value, so cannot be manually sorted.
-- We've included reset code similar to that which already exists
-- for products.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisVersions_ChangeSortValue]
(
	@VersionID as bigint,
	@ProductID as int,
	@Direction as char
)
AS
BEGIN
	SET NOCOUNT OFF;
	
	
	DECLARE @VersionOrder as int;
	SELECT @VersionOrder = V_OrderByValue
	FROM  dbo.tblKartrisVersions
	WHERE V_ProductID = @ProductID AND V_ID = @VersionID;

	-- *********************************************************
	-- Need to check if there are siblings with same sort order
	--  if yes, we need to reset those values
	DECLARE @DuplicateOrders as int;
	SELECT @DuplicateOrders = COUNT(1)
	FROM dbo.tblKartrisVersions
	WHERE V_OrderByValue = @VersionOrder AND V_ProductID = @ProductID;
	
	IF (SELECT COUNT(1)	FROM dbo.tblKartrisVersions WHERE V_OrderByValue = @VersionOrder AND V_ProductID = @ProductID) > 1 BEGIN
		DECLARE @MaxNo as int;
		SELECT @MaxNo = MAX(V_OrderByValue) 
		FROM dbo.tblKartrisVersions  
		WHERE V_ProductID = @ProductID;
		
		WHILE (SELECT COUNT(1)	FROM dbo.tblKartrisVersions WHERE V_OrderByValue = @VersionOrder AND V_ProductID = @ProductID) > 1
		BEGIN
			UPDATE TOP(1) dbo.tblKartrisVersions
			SET V_OrderByValue = @MaxNo + 1
			WHERE V_ProductID = @ProductID AND V_OrderByValue = @VersionOrder;
			SET @MaxNo = @MaxNo + 1;
		END
	END
	-- *********************************************************
	
	DECLARE @SwitchVersionID as bigint, @SwitchOrder as int;
	IF @Direction = 'u'
	BEGIN
		SELECT @SwitchOrder = MAX(V_OrderByValue) 
		FROM  dbo.tblKartrisVersions
		WHERE V_ProductID = @ProductID AND V_OrderByValue < @VersionOrder;

		SELECT TOP(1) @SwitchVersionID = V_ID
		FROM  dbo.tblKartrisVersions
		WHERE V_ProductID = @ProductID AND V_OrderByValue = @SwitchOrder;		
	END
	ELSE
	BEGIN
		SELECT @SwitchOrder = MIN(V_OrderByValue) 
		FROM dbo.tblKartrisVersions
		WHERE V_ProductID = @ProductID AND V_OrderByValue > @VersionOrder;

		SELECT TOP(1) @SwitchVersionID = V_ID
		FROM dbo.tblKartrisVersions
		WHERE V_ProductID = @ProductID AND V_OrderByValue = @SwitchOrder;
	END;

	UPDATE dbo.tblKartrisVersions
	SET V_OrderByValue = @SwitchOrder
	WHERE V_ProductID = @ProductID AND V_ID = @VersionID; 

	UPDATE dbo.tblKartrisVersions
	SET V_OrderByValue = @VersionOrder
	WHERE V_ProductID = @ProductID AND V_ID = @SwitchVersionID;
		
END

/****** Make Payment References Unique ******/
-- On occasion we have seen payments logged
-- twice. Adding this constraint should stop
-- that happening.
ALTER TABLE tblKartrisPayments
ADD CONSTRAINT Payment_ReferenceNo UNIQUE (Payment_ReferenceNo); 
GO