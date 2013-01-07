-- =============================================
-- KARTRIS UPDATE SCRIPT
-- From 1.3004 to 1.3006
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisPromotions_GetAllDetails](@LANG_ID as tinyint,@NowOffset as datetime)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT	tblKartrisPromotions.PROM_ID, tblKartrisPromotions.PROM_MaxQuantity, tblKartrisPromotions.PROM_StartDate, tblKartrisPromotions.PROM_EndDate, tblKartrisPromotionParts.PP_PartNo, 
			tblKartrisPromotionParts.PP_Type, tblKartrisPromotionParts.PP_Value, tblKartrisPromotionParts.PP_ItemType, tblKartrisPromotionParts.PP_ItemID, 
			PP_ItemName =	CASE tblKartrisPromotionParts.PP_ItemType
							WHEN 'v' THEN		dbo.fnKartrisVersions_GetProductName(PP_ItemID, @LANG_ID) 
											+ ' (' + dbo.fnKartrisVersions_GetName(PP_ItemID, @LANG_ID) + ')'
							WHEN 'p' THEN		dbo.fnKartrisProducts_GetName(PP_ItemID, @LANG_ID)
							WHEN 'c' THEN 	dbo.fnKartrisCategories_GetName(PP_ItemID, @LANG_ID)
							ELSE 'Name NOT Found .. !!'
						END
	FROM	tblKartrisPromotionParts INNER JOIN tblKartrisPromotions ON tblKartrisPromotionParts.PROM_ID = tblKartrisPromotions.PROM_ID 
	WHERE	tblKartrisPromotions.PROM_ID 
			IN 
			(
				SELECT DISTINCT vKartrisTypePromotions.PROM_ID
				FROM         tblKartrisPromotionParts INNER JOIN
									  vKartrisTypePromotions ON tblKartrisPromotionParts.PROM_ID = vKartrisTypePromotions.PROM_ID
				WHERE     (@NowOffset BETWEEN vKartrisTypePromotions.PROM_StartDate AND vKartrisTypePromotions.PROM_EndDate) AND (vKartrisTypePromotions.PROM_Live = 1) AND 
									  (vKartrisTypePromotions.LANG_ID = @LANG_ID)
						
			)
	ORDER BY PROM_ID, PP_PartNo ASC	
   
END


/****** Object:  UserDefinedFunction [dbo].[fnKartrisVersions_GetSortedOptionsByVersion]    Script Date: 11/02/2011 20:16:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnKartrisVersions_GetSortedOptionsByVersion]
(
	@VersionID as bigint
)
RETURNS nvarchar(max)
AS
BEGIN
	DECLARE @Options as nvarchar(max)
	SELECT @Options = COALESCE(@Options + ',', '') + CAST(T.V_OPT_OptionID as nvarchar(10))
	FROM (	SELECT DISTINCT Top(5000) V_OPT_OptionID
			FROM dbo.tblKartrisVersionOptionLink
			WHERE V_OPT_VersionID = @VersionID
			ORDER BY V_OPT_OptionID) AS T;

	RETURN @Options
END
GO


/****** Object:  View [dbo].[vKartrisCombinationPrices]    Script Date: 11/02/2011 20:19:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vKartrisCombinationPrices]
AS
SELECT     V_ProductID, V_ID, V_CodeNumber, V_Price, dbo.fnKartrisVersions_GetSortedOptionsByVersion(V_ID) AS V_OptionsIDs
FROM         dbo.tblKartrisVersions
WHERE     (V_Type = 'c')

GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[14] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tblKartrisVersions"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 203
               Right = 266
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 5130
         Alias = 2910
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisCombinationPrices'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vKartrisCombinationPrices'
GO


/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetCombinationPrice_s]    Script Date: 11/02/2011 14:51:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spKartrisVersions_GetCombinationVersionID_s]
(
	@ProductID as int,
	@OptionsList as nvarchar(1000),
	@Return_Value as bigint OUTPUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- need to sort the options' list to match the already sorted options
	--@OptionsList
	DECLARE @SortedOptions as nvarchar(max);
	SELECT @SortedOptions = COALESCE(@SortedOptions + ',', '') + CAST(T._ID as nvarchar(10))
	FROM (	SELECT DISTINCT Top(5000) _ID
			FROM dbo.fnTbl_SplitNumbers(@OptionsList)
			ORDER BY _ID) AS T;

    SELECT @Return_Value = V_ID
    FROM dbo.vKartrisCombinationPrices
    WHERE V_ProductID = @ProductID AND V_OptionsIDs = @SortedOptions;
    
    IF @Return_Value IS NULL BEGIN
		SELECT @Return_Value = V_ID
		FROM tblKartrisVersions
		WHERE V_ProductID = @ProductID AND V_Type = 'b';
	END
	
	IF @Return_Value IS NULL BEGIN
		SET @Return_Value = 0;
	END
END


/****** Object:  StoredProcedure [dbo].[spKartrisOrderPaymentsLink_Add]    Script Date: 11/07/2011 19:09:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Medz
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisOrderPaymentsLink_Add]
(
		   @OP_PaymentID int,
           @OP_OrderID int
)
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

Disable Trigger trigKartrisOrderPaymentLink_DML ON tblKartrisOrderPaymentLink;	
	INSERT INTO [tblKartrisOrderPaymentLink]
           ([OP_PaymentID]
           ,[OP_OrderID]
           ,[OP_OrderCanceled])
     VALUES
           (@OP_PaymentID,@OP_OrderID,0)

	SELECT @OP_PaymentID;
Enable Trigger trigKartrisOrderPaymentLink_DML ON tblKartrisOrderPaymentLink;	
END


/****** Object:  StoredProcedure [dbo].[spKartrisPromotions_GetAllDetails]    Script Date: 09/11/2011 14:18:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisPromotions_GetAllDetails](@LANG_ID as tinyint,@NowOffset as datetime)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT	tblKartrisPromotions.PROM_ID, tblKartrisPromotions.PROM_MaxQuantity, tblKartrisPromotions.PROM_StartDate, tblKartrisPromotions.PROM_EndDate, tblKartrisPromotionParts.PP_PartNo, 
			tblKartrisPromotionParts.PP_Type, tblKartrisPromotionParts.PP_Value, tblKartrisPromotionParts.PP_ItemType, tblKartrisPromotionParts.PP_ItemID, 
			PP_ItemName =	CASE tblKartrisPromotionParts.PP_ItemType
							WHEN 'v' THEN		dbo.fnKartrisVersions_GetProductName(PP_ItemID, @LANG_ID) 
											+ ' (' + dbo.fnKartrisVersions_GetName(PP_ItemID, @LANG_ID) + ')'
							WHEN 'p' THEN		dbo.fnKartrisProducts_GetName(PP_ItemID, @LANG_ID)
							WHEN 'c' THEN 	dbo.fnKartrisCategories_GetName(PP_ItemID, @LANG_ID)
							ELSE 'Name NOT Found .. !!'
						END
	FROM	tblKartrisPromotionParts INNER JOIN tblKartrisPromotions ON tblKartrisPromotionParts.PROM_ID = tblKartrisPromotions.PROM_ID 
	WHERE	tblKartrisPromotions.PROM_ID 
			IN 
			(
				SELECT DISTINCT vKartrisTypePromotions.PROM_ID
				FROM         tblKartrisPromotionParts INNER JOIN
									  vKartrisTypePromotions ON tblKartrisPromotionParts.PROM_ID = vKartrisTypePromotions.PROM_ID
				WHERE     (@NowOffset BETWEEN vKartrisTypePromotions.PROM_StartDate AND vKartrisTypePromotions.PROM_EndDate) AND (vKartrisTypePromotions.PROM_Live = 1) AND 
									  (vKartrisTypePromotions.LANG_ID = @LANG_ID)
						
			)
	ORDER BY PROM_ID, PP_PartNo ASC	
   
END


/****** Object:  UserDefinedFunction [dbo].[fnTbl_SplitStrings]    Script Date: 11/17/2011 15:33:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER FUNCTION [dbo].[fnTbl_SplitStrings]
(	
	@List varchar(max))
RETURNS @ParsedList 
table(_ID varchar(20)) AS BEGIN
    DECLARE @_ID varchar(20), @Pos int    
    SET @List = LTRIM(RTRIM(@List))+ ','    
    SET @Pos = CHARINDEX(',', @List, 1)    
    IF REPLACE(@List, ',', '') <> '' BEGIN        
		WHILE @Pos > 0 BEGIN                
			SET @_ID = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))                
			IF @_ID <> '' BEGIN                        
				INSERT INTO @ParsedList (_ID)                         
				VALUES (@_ID)              
			END                
			SET @List = RIGHT(@List, LEN(@List) - @Pos)                
			SET @Pos = CHARINDEX(',', @List, 1)        
		END    
	END     
	RETURN
END