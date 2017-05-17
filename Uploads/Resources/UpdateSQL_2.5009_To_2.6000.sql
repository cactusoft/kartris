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
GO

/****** Make Payment References Unique ******/
-- On occasion we have seen payments logged
-- twice. Adding this constraint should stop
-- that happening.
ALTER TABLE tblKartrisPayments
ADD CONSTRAINT Payment_ReferenceNo UNIQUE (Payment_ReferenceNo); 
GO

/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetByProductID]    Script Date: 04/19/2014 16:04:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Fixes issue with NULL values, 'simple'
-- tax mode settings
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisVersions_GetByProductID]
(
	@P_ID as int, 
	@LANG_ID as tinyint,
	@CGroupID as smallint
)
AS
BEGIN
SET NOCOUNT ON;
	
	DECLARE @OrderBy as nvarchar(50), @OrderDirection as char(1);
	SELECT @OrderBy = P_OrderVersionsBy, @OrderDirection = P_VersionsSortDirection
	FROM tblKartrisProducts WHERE P_ID = @P_ID;

	IF @OrderBy IS NULL OR @OrderBy = '' OR @OrderBy = 'd'
	BEGIN
		 SELECT @OrderBy = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = 'frontend.versions.display.sortdefault';
	END

	IF @OrderDirection IS NULL OR @OrderDirection = ''
	BEGIN
		 SELECT @OrderDirection = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = 'frontend.versions.display.sortdirection';
	END

	BEGIN
		SELECT     vKartrisTypeVersions.V_ID, tblKartrisTaxRates.T_Taxrate, vKartrisTypeVersions.V_Price, vKartrisTypeVersions.V_Weight, vKartrisTypeVersions.V_RRP, 
					  vKartrisTypeVersions.V_Tax, tblKartrisTaxRates.T_Taxrate AS Expr1, '0' AS CalculatedTax, vKartrisTypeVersions.V_ProductID, vKartrisTypeVersions.V_CodeNumber, 
					  vKartrisTypeVersions.V_ExtraCodeNumber, vKartrisTypeVersions.V_Quantity, vKartrisTypeVersions.V_QuantityWarnLevel, vKartrisTypeVersions.V_Price AS OrderByBit, 
					  vKartrisTypeVersions.V_Name, vKartrisTypeVersions.V_Desc, MIN(tblKartrisQuantityDiscounts.QD_Price) AS QuantityDiscount, vKartrisTypeVersions.V_OrderByValue, 
					  vKartrisTypeVersions.V_CustomizationType, vKartrisTypeVersions.V_CustomizationDesc, vKartrisTypeVersions.V_CustomizationCost
		FROM         vKartrisTypeVersions LEFT OUTER JOIN
							  tblKartrisTaxRates ON vKartrisTypeVersions.V_Tax = tblKartrisTaxRates.T_ID LEFT OUTER JOIN
							  tblKartrisQuantityDiscounts ON vKartrisTypeVersions.V_ID = tblKartrisQuantityDiscounts.QD_VersionID
		WHERE     (vKartrisTypeVersions.LANG_ID = @LANG_ID) AND (vKartrisTypeVersions.V_ProductID = @P_ID) AND (vKartrisTypeVersions.V_Live = 1)
				AND (vKartrisTypeVersions.V_CustomerGroupID IS NULL OR vKartrisTypeVersions.V_CustomerGroupID = @CGroupID)
		GROUP BY vKartrisTypeVersions.V_ID, tblKartrisTaxRates.T_Taxrate, vKartrisTypeVersions.V_Price, vKartrisTypeVersions.V_Weight, vKartrisTypeVersions.V_RRP, 
							  vKartrisTypeVersions.V_Tax, vKartrisTypeVersions.V_ProductID, vKartrisTypeVersions.V_CodeNumber, vKartrisTypeVersions.V_ExtraCodeNumber,
							  vKartrisTypeVersions.V_Quantity, vKartrisTypeVersions.V_QuantityWarnLevel, vKartrisTypeVersions.V_Name, vKartrisTypeVersions.V_Desc, 
							  vKartrisTypeVersions.V_OrderByValue, vKartrisTypeVersions.V_CustomizationType, vKartrisTypeVersions.V_CustomizationDesc, 
							  vKartrisTypeVersions.V_CustomizationCost
		HAVING      (vKartrisTypeVersions.V_Name IS NOT NULL)
		ORDER BY	CASE
					WHEN (@OrderBy = 'V_Name' AND @OrderDirection = 'A') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Name ASC))
					WHEN (@OrderBy = 'V_Name' AND @OrderDirection = 'D') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Name DESC))
					WHEN (@OrderBy = 'V_ID' AND @OrderDirection = 'A') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_ID ASC))
					WHEN (@OrderBy = 'V_ID' AND @OrderDirection = 'D') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_ID DESC))
					WHEN (@OrderBy = 'V_OrderByValue' AND @OrderDirection = 'A') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_OrderByValue ASC))
					WHEN (@OrderBy = 'V_OrderByValue' AND @OrderDirection = 'D') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_OrderByValue DESC))
					WHEN (@OrderDirection = 'A') THEN (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Price ASC))
					ELSE (RANK() OVER(ORDER BY vKartrisTypeVersions.V_Price DESC))
					END
	END			
END

/****** Object:  StoredProcedure [dbo].[_spKartrisDB_GetTaskList]    Script Date: 04/30/2014 14:11:03 ******/
-- out of stock should show items with negative stock as well as zero
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
	
	SELECT @NoStockWarnings = Count(DISTINCT V_ID) FROM dbo.vKartrisProductsVersions WHERE V_QuantityWarnLevel >= V_Quantity AND V_QuantityWarnLevel <> 0;
	SELECT @NoOutOfStock = Count(DISTINCT V_ID) FROM dbo.vKartrisProductsVersions WHERE V_Quantity <= 0 AND V_QuantityWarnLevel <> 0;

	SELECT @NoReviewsWaiting = Count(REV_ID) FROM dbo.tblKartrisReviews WHERE REV_Live = 'a';
	SELECT @NoAffiliatesWaiting  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_IsAffiliate = 'True' AND U_AffiliateCommission = 0;
	SELECT @NoCustomersWaitingRefunds  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_CustomerBalance > 0;
	SELECT @NoCustomersInArrears  = Count(U_ID) FROM dbo.tblKartrisUsers WHERE U_CustomerBalance < 0;
END


-- Remove deprecated us state tax config setting
-- This is now handled by the taxregime setting in the 
-- web.config
DELETE from tblKartrisConfig WHERE CFG_Name = 'general.tax.usmultistatetax'

-- Remove shipping system; we now have a combined system based
-- on bands, where you can specify real-time system at band level
DELETE from tblKartrisConfig WHERE CFG_Name = 'frontend.checkout.shipping.system'

-- Shipping tax band is set from the shipping section, for
-- each shipping method
DELETE from tblKartrisConfig WHERE CFG_Name = 'frontend.checkout.shipping.taxband'

GO
