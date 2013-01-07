-- =============================================
-- KARTRIS UPDATE SCRIPT
-- From 1.3000 to 1.3003
-- =============================================


--****************************************************************************************************************
-- Drops IR_Quantity constraint
--****************************************************************************************************************
Declare @v_constraintname varchar(max)

set @v_constraintname ='ALTER TABLE tblKartrisInvoiceRows DROP CONSTRAINT '

set @v_constraintname = @v_constraintname + (select c_obj.name as CONSTRAINT_NAME
from sysobjects c_obj
join syscomments com on c_obj.id = com.id
join sysobjects t_obj on c_obj.parent_obj = t_obj.id
join sysconstraints con on c_obj.id = con.constid
join syscolumns col on t_obj.id = col.id
and con.colid = col.colid
where
c_obj.uid = user_id()
and c_obj.xtype = 'D'
and t_obj.name='tblKartrisInvoiceRows' and col.name='IR_Quantity')

exec(@v_constraintname)

GO

--****************************************************************************************************************
-- BEGIN: Changes to support basket decimal quantities
--****************************************************************************************************************
;DISABLE TRIGGER trigKartrisConfig_DML ON dbo.tblKartrisConfig;
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CactuShopName_DEPRECATED], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) 
VALUES (N'frontend.basket.allowdecimalqty', NULL, N'y', N's', N'b', N'y|n', N'This allows to specify the number of decimal places for quantity in the basket.', 1.3001, N'n', 0)
;ENABLE TRIGGER trigKartrisConfig_DML ON dbo.tblKartrisConfig;
GO
ALTER TABLE dbo.tblKartrisBasketValues ALTER COLUMN BV_Quantity FLOAT
GO
ALTER TABLE dbo.tblKartrisInvoiceRows ALTER COLUMN IR_Quantity FLOAT
GO


/****** Object:  StoredProcedure [dbo].[spKartrisBasketValues_Update]    Script Date: 05/01/2011 21:00:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spKartrisBasketValues_Update]
(
	@BV_ParentType char(1),
	@BV_ParentID bigint,
	@BV_VersionID bigint,
	@BV_Quantity float,
	@BV_CustomText nvarchar(MAX),
	@BV_DateTimeAdded smalldatetime,
	@BV_LastUpdated smalldatetime,
	@Original_BV_ID bigint,
	@BV_ID bigint
)
AS
	SET NOCOUNT OFF;

	UPDATE [tblKartrisBasketValues] SET [BV_ParentType] = @BV_ParentType, [BV_ParentID] = @BV_ParentID, [BV_VersionID] = @BV_VersionID, [BV_Quantity] = @BV_Quantity, [BV_CustomText] = @BV_CustomText, [BV_DateTimeAdded] = @BV_DateTimeAdded, [BV_LastUpdated] = @BV_LastUpdated WHERE (([BV_ID] = @Original_BV_ID));

SELECT BV_ID, BV_ParentType, BV_ParentID, BV_VersionID, BV_Quantity, BV_CustomText, BV_DateTimeAdded, BV_LastUpdated FROM tblKartrisBasketValues WHERE (BV_ID = @BV_ID)
GO


/****** Object:  StoredProcedure [dbo].[spKartrisBasketValues_AddQuantityToItem]    Script Date: 05/01/2011 21:00:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spKartrisBasketValues_AddQuantityToItem]
(
	@BV_QuantityToAdd float,
	@BV_ID bigint
)
AS
	SET NOCOUNT OFF;
	UPDATE       tblKartrisBasketValues
	SET                BV_Quantity = BV_Quantity + @BV_QuantityToAdd
	WHERE        (BV_ID = @BV_ID);

GO


/****** Object:  StoredProcedure [dbo].[spKartrisBasketValues_Add]    Script Date: 05/01/2011 20:59:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spKartrisBasketValues_Add]
(
	@BV_ParentType char(1),
	@BV_ParentID bigint,
	@BV_VersionID bigint,
	@BV_Quantity float,
	@BV_CustomText nvarchar(MAX),
	@BV_DateTimeAdded smalldatetime,
	@BV_LastUpdated smalldatetime,
	@BV_CreatedID bigint output
)
AS
	SET NOCOUNT OFF;
	INSERT INTO [tblKartrisBasketValues] ([BV_ParentType], [BV_ParentID], [BV_VersionID], [BV_Quantity], [BV_CustomText], [BV_DateTimeAdded], [BV_LastUpdated]) VALUES (@BV_ParentType, @BV_ParentID, @BV_VersionID, @BV_Quantity, @BV_CustomText, @BV_DateTimeAdded, @BV_LastUpdated);
	
	SELECT @BV_CreatedID = SCOPE_IDENTITY();
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasket_SaveBasket]    Script Date: 05/01/2011 18:25:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Joseph
-- Create date: 12/May/2008
-- Update date: 11/June/2008
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisBasket_SaveBasket] ( 
	@CustomerID INT,
	@BasketName NVARCHAR(200),
	@BasketID BIGINT,
	@NowOffset datetime
) AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @SavedBasketID BIGINT;
	DECLARE @newBV_ID BIGINT;

Disable Trigger trigKartrisSavedBaskets_DML ON tblKartrisSavedBaskets;	

	INSERT INTO tblKartrisSavedBaskets (SBSKT_UserID,SBSKT_Name,SBSKT_DateTimeAdded)
	VALUES (@CustomerID,@BasketName,@NowOffset);
	
	SET @SavedBasketID=SCOPE_IDENTITY() ;

	DECLARE @BV_ID INT
	DECLARE @BV_VersionID INT
	DECLARE @BV_Quantity FLOAT
	DECLARE @BV_CustomText nvarchar(2000)

	DECLARE Basket_cursor CURSOR FOR 
	SELECT BV_ID,BV_VersionID,BV_Quantity,BV_CustomText FROM tblKartrisBasketValues WHERE BV_ParentID=@BasketID AND BV_ParentType='b';

	OPEN Basket_cursor
	FETCH NEXT FROM Basket_cursor INTO @BV_ID,@BV_VersionID,@BV_Quantity,@BV_CustomText
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO tblKartrisBasketValues(BV_ParentType,BV_ParentID,BV_VersionID,BV_Quantity,BV_CustomText,BV_DateTimeAdded)
		VALUES ('s',@SavedBasketID,@BV_VersionID,@BV_Quantity,@BV_CustomText,@NowOffset)

		SET @newBV_ID=SCOPE_IDENTITY() 

		IF EXISTS (SELECT * FROM tblKartrisBasketOptionValues WHERE BSKTOPT_BasketValueID=@BV_ID) 
		BEGIN
			INSERT INTO tblKartrisBasketOptionValues
			SELECT @newBV_ID,BSKTOPT_OptionID FROM tblKartrisBasketOptionValues WHERE BSKTOPT_BasketValueID=@BV_ID
		END

		FETCH NEXT FROM Basket_cursor INTO @BV_ID,@BV_VersionID,@BV_Quantity,@BV_CustomText
	End

	CLOSE Basket_cursor
	DEALLOCATE Basket_cursor;

Enable Trigger trigKartrisSavedBaskets_DML ON tblKartrisSavedBaskets;
END
GO
GO
/****** Object:  StoredProcedure [dbo].[spKartrisBasketValues_UpdateQuantity]    Script Date: 05/01/2011 16:31:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Joseph
-- Create date: 29/Apr/08
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisBasketValues_UpdateQuantity] (
	@BV_ID int,
	@BV_Quantity float
)
AS
BEGIN
	SET NOCOUNT ON;

	Update tblKartrisBasketValues 
	set BV_Quantity=@BV_Quantity
	where BV_ID=@BV_ID;
	
END
GO
/****** Object:  StoredProcedure [dbo].[spKartrisOrders_InvoiceRowsAdd]    Script Date: 05/03/2011 15:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisOrders_InvoiceRowsAdd]
(
           @IR_OrderNumberID int,
           @IR_VersionCode nvarchar(50),
           @IR_VersionName nvarchar(1000),
           @IR_Quantity float,
           @IR_PricePerItem real,
           @IR_TaxPerItem real,
           @IR_OptionsText nvarchar(MAX)
)
AS
BEGIN
	DECLARE @IR_ID INT
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

Disable Trigger trigKartrisInvoiceRows_DML ON tblKartrisInvoiceRows;	

	INSERT INTO [tblKartrisInvoiceRows]
           ([IR_OrderNumberID]
           ,[IR_VersionCode]
           ,[IR_VersionName]
           ,[IR_Quantity]
           ,[IR_PricePerItem]
           ,[IR_TaxPerItem]
           ,[IR_OptionsText])
     VALUES
           (@IR_OrderNumberID,
           @IR_VersionCode,
           @IR_VersionName,
           @IR_Quantity,
           @IR_PricePerItem,
           @IR_TaxPerItem,
           @IR_OptionsText);
	SET @IR_ID = SCOPE_IDENTITY();
	SELECT @IR_ID;

Enable Trigger trigKartrisInvoiceRows_DML ON tblKartrisInvoiceRows;	
END
GO
--****************************************************************************************************************
-- END: Changes to support basket decimal quntities
--****************************************************************************************************************
--****************************************************************************************************************
-- Start: Include Live field to display gray icon in the backend category menu
--****************************************************************************************************************

/****** Object:  StoredProcedure [dbo].[_spKartrisCategories_GetPageByParentID]    Script Date: 05/08/2011 14:31:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisCategories_GetPageByParentID]
(
	@LANG_ID as tinyint, 
	@ParentID as int,
	@PageIndex as tinyint, -- 0 Based index
	@RowsPerPage as smallint
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;

	DECLARE @OrderBy as nvarchar(50), @OrderDirection as char(1)

	SELECT @OrderBy = CAT_OrderCategoriesBy, @OrderDirection = CAT_CategoriesSortDirection
	FROM dbo.tblKartrisCategories
	WHERE CAT_ID = @ParentID;

	IF @OrderBy is NULL OR @OrderBy = 'd'
	BEGIN 
		SELECT @OrderBy = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = 'frontend.categories.display.sortdefault';
	END;
	IF @OrderDirection is NULL OR @OrderDirection = '' BEGIN 
		SELECT @OrderDirection = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = 'frontend.categories.display.sortdirection';
	END;

	DECLARE @SortByValue as bit;
	SET @SortByValue = 0;
	IF @OrderBy = 'CH_OrderNo' BEGIN SET @SortByValue = 1 END;
	
	IF @ParentID = 0 
	BEGIN
		 SET @SortByValue = 1;
		 SET @OrderBy = 'CH_OrderNo';
	END;
	
	WITH CategoryList AS
	(
		SELECT	CASE 
				WHEN (@OrderBy = 'CAT_ID' AND @OrderDirection = 'A') THEN	ROW_NUMBER() OVER (ORDER BY tblKartrisCategories.CAT_ID ASC) 
				WHEN (@OrderBy = 'CAT_ID' AND @OrderDirection = 'D') THEN	ROW_NUMBER() OVER (ORDER BY tblKartrisCategories.CAT_ID DESC) 
				WHEN (@OrderBy = 'CAT_Name' AND @OrderDirection = 'A') THEN ROW_NUMBER() OVER (ORDER BY CAT_Name ASC) 
				WHEN (@OrderBy = 'CAT_Name' AND @OrderDirection = 'D') THEN ROW_NUMBER() OVER (ORDER BY CAT_Name DESC) 
				WHEN (@OrderBy = 'CH_OrderNo' AND @OrderDirection = 'A') THEN ROW_NUMBER() OVER (ORDER BY CH_OrderNo ASC) 
				WHEN (@OrderBy = 'CH_OrderNo' AND @OrderDirection = 'D') THEN ROW_NUMBER() OVER (ORDER BY CH_OrderNo DESC) 
				END AS Row,
				vKartrisTypeCategories.CAT_ID, vKartrisTypeCategories.CAT_Name, vKartrisTypeCategories.CAT_Desc, tblKartrisCategories.CAT_ProductDisplayType AS Parent_ProductDisplay, 
                tblKartrisCategories.CAT_SubCatDisplayType AS Parent_SubCategoryDisplay, @SortByValue AS SortByValue, vKartrisTypeCategories.CAT_Live
		FROM    tblKartrisCategoryHierarchy INNER JOIN
				vKartrisTypeCategories ON tblKartrisCategoryHierarchy.CH_ChildID = vKartrisTypeCategories.CAT_ID INNER JOIN
				tblKartrisCategories ON tblKartrisCategoryHierarchy.CH_ParentID = tblKartrisCategories.CAT_ID
		WHERE   (tblKartrisCategoryHierarchy.CH_ParentID = @ParentID) AND (vKartrisTypeCategories.LANG_ID = @LANG_ID)
		
	)

	SELECT *
	FROM CategoryList
	WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber
	ORDER BY Row ASC;

END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisProducts_GetRowsBetweenByCatID]    Script Date: 05/08/2011 14:32:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisProducts_GetRowsBetweenByCatID]
(
	@LANG_ID as tinyint,
	@CAT_ID as int,
	@PageIndex as tinyint, -- 0 Based index
	@RowsPerPage as smallint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
    -- Insert statements for procedure here

	DECLARE @StartRowNumber as int;
	SET @StartRowNumber = (@PageIndex * @RowsPerPage) + 1;
	DECLARE @EndRowNumber as int;
	SET @EndRowNumber = @StartRowNumber + @RowsPerPage - 1;
	
	DECLARE @OrderBy as nvarchar(50), @OrderDirection as char(1)
	SELECT @OrderBy = CAT_OrderProductsBy, @OrderDirection = CAT_ProductsSortDirection
	FROM dbo.tblKartrisCategories
	WHERE CAT_ID = @CAT_ID;

	IF @OrderBy is NULL OR @OrderBy = 'd'
	BEGIN 
		SELECT @OrderBy = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = 'frontend.products.display.sortdefault';
	END;
	IF @OrderDirection is NULL OR @OrderDirection = '' BEGIN 
		SELECT @OrderDirection = CFG_Value FROM tblKartrisConfig WHERE CFG_Name = 'frontend.products.display.sortdirection';
	END;

	DECLARE @SortByValue as bit;
	SET @SortByValue = 0;
	IF @OrderBy = 'PCAT_OrderNo' BEGIN SET @SortByValue = 1 END;

	With ProductList AS 
	(
		SELECT	CASE 
				WHEN (@OrderBy = 'P_ID' AND @OrderDirection = 'A') THEN	ROW_NUMBER() OVER (ORDER BY P_ID ASC) 
				WHEN (@OrderBy = 'P_ID' AND @OrderDirection = 'D') THEN	ROW_NUMBER() OVER (ORDER BY P_ID DESC) 
				WHEN (@OrderBy = 'P_Name' AND @OrderDirection = 'A') THEN ROW_NUMBER() OVER (ORDER BY P_Name ASC) 
				WHEN (@OrderBy = 'P_Name' AND @OrderDirection = 'D') THEN ROW_NUMBER() OVER (ORDER BY P_Name DESC) 
				WHEN (@OrderBy = 'P_DateCreated' AND @OrderDirection = 'A') THEN ROW_NUMBER() OVER (ORDER BY P_DateCreated ASC) 
				WHEN (@OrderBy = 'P_DateCreated' AND @OrderDirection = 'D') THEN ROW_NUMBER() OVER (ORDER BY P_DateCreated DESC) 
				WHEN (@OrderBy = 'P_LastModified' AND @OrderDirection = 'A') THEN ROW_NUMBER() OVER (ORDER BY P_LastModified ASC) 
				WHEN (@OrderBy = 'P_LastModified' AND @OrderDirection = 'D') THEN ROW_NUMBER() OVER (ORDER BY P_LastModified DESC) 
				WHEN (@OrderBy = 'PCAT_OrderNo' AND @OrderDirection = 'A') THEN ROW_NUMBER() OVER (ORDER BY PCAT_OrderNo ASC) 
				WHEN (@OrderBy = 'PCAT_OrderNo' AND @OrderDirection = 'D') THEN ROW_NUMBER() OVER (ORDER BY PCAT_OrderNo DESC) 
				END AS Row,
				vKartrisTypeProducts.P_ID, vKartrisTypeProducts.P_Name, dbo.fnKartrisDB_TruncateDescription(vKartrisTypeProducts.P_Desc) AS P_Desc, vKartrisTypeProducts.P_StrapLine,
				vKartrisTypeProducts.P_VersionDisplayType, vKartrisTypeProducts.P_DateCreated, vKartrisTypeProducts.P_LastModified, 
				tblKartrisProductCategoryLink.PCAT_OrderNo, vKartrisTypeProducts.P_Type, @SortByValue AS SortByValue, vKartrisTypeProducts.P_Live
		FROM    tblKartrisProductCategoryLink INNER JOIN
				vKartrisTypeProducts ON tblKartrisProductCategoryLink.PCAT_ProductID = vKartrisTypeProducts.P_ID 
		WHERE   (vKartrisTypeProducts.LANG_ID = @LANG_ID) AND (tblKartrisProductCategoryLink.PCAT_CategoryID = @CAT_ID)
		GROUP BY vKartrisTypeProducts.P_Name, vKartrisTypeProducts.P_Desc, vKartrisTypeProducts.P_StrapLine, vKartrisTypeProducts.P_ID,
					vKartrisTypeProducts.P_VersionDisplayType, vKartrisTypeProducts.P_DateCreated, vKartrisTypeProducts.P_LastModified, 
				tblKartrisProductCategoryLink.PCAT_OrderNo, vKartrisTypeProducts.P_Type, vKartrisTypeProducts.P_Live
		
	)

	SELECT *
	FROM ProductList
	WHERE Row BETWEEN @StartRowNumber AND @EndRowNumber
	ORDER BY Row ASC
END
--****************************************************************************************************************
-- END: Include Live field to display gray icon in the backend category menu
--****************************************************************************************************************
--****************************************************************************************************************
-- BEGIN: Changes to support basket decimal places
--****************************************************************************************************************
;DISABLE TRIGGER trigKartrisConfig_DML ON dbo.tblKartrisConfig;
INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CactuShopName_DEPRECATED], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) 
VALUES (N'frontend.basket.decimalplaces', NULL, N'2', N'n', N'n', N'1|2|3|4|5|n', N'control how many decimal places in the basket quantity', 1.3001, N'2', 0)
;ENABLE TRIGGER trigKartrisConfig_DML ON dbo.tblKartrisConfig;
GO
--****************************************************************************************************************
-- END: Changes to support basket decimal places
--****************************************************************************************************************
