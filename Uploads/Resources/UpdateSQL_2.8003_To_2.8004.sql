/****** 
v2.8004 
Fixes spKartrisProducts_GetTopList, the LANG and P IDs were round the wrong way
In back end, sort shipping zones by OrderBy value

Sorted some option sorting issues by changing option sort fields
from tinyint to smallint

Remove remaining linnworks stuff from database
******/

/****** Object:  StoredProcedure [dbo].[spKartrisProducts_GetTopList]    Script Date: 7/21/2014 10:14:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Medz
-- Create date: 02/12/2008 13:52:43
-- Last Modified: Mohammad - July 2014
-- Description:	Replaces spKartris_Prod_TopList
-- Remarks:	Optimization (Medz) - 04-07-2010
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisProducts_GetTopList]
	(
	@Limit int,
	@LANG_ID tinyint,
	@StartDate datetime
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	WITH tblTopList AS
	(
		SELECT  tblKartrisInvoiceRows.IR_VersionCode AS IR_VersionCode, SUM(tblKartrisInvoiceRows.IR_Quantity) AS IR_Quantity
		FROM    tblKartrisInvoiceRows LEFT OUTER JOIN tblKartrisOrders ON tblKartrisInvoiceRows.IR_OrderNumberID = tblKartrisOrders.O_ID
		WHERE   (tblKartrisOrders.O_Paid = 1) AND (tblKartrisOrders.O_Date >= @StartDate)
		GROUP BY tblKartrisInvoiceRows.IR_VersionCode
	)
	SELECT TOP (@Limit) vKartrisCategoryProductsVersionsLink.P_ID, [dbo].[fnKartrisProducts_GetName](vKartrisCategoryProductsVersionsLink.P_ID, @LANG_ID) AS P_Name, 
				@LANG_ID as LANG_ID, SUM(tblTopList.IR_Quantity) as ProductHits
	FROM tblTopList INNER JOIN dbo.vKartrisCategoryProductsVersionsLink ON tblTopList.IR_VersionCode = dbo.vKartrisCategoryProductsVersionsLink.V_CodeNumber
	WHERE	vKartrisCategoryProductsVersionsLink.V_CustomerGroupID IS NULL 
		AND vKartrisCategoryProductsVersionsLink.P_CustomerGroupID IS NULL 
		AND vKartrisCategoryProductsVersionsLink.CAT_CustomerGroupID IS NULL
	GROUP BY vKartrisCategoryProductsVersionsLink.P_ID, [dbo].[fnKartrisProducts_GetName](vKartrisCategoryProductsVersionsLink.P_ID, @LANG_ID)
	ORDER BY ProductHits DESC
END
GO

/****** Object:  UserDefinedFunction [dbo].[fnKartrisProducts_GetName]    Script Date: 01/23/2013 21:59:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [dbo].[fnKartrisProducts_GetName] 
(
	-- Add the parameters for the function here
	@P_ID as int,
	@LANG_ID as tinyint
)
RETURNS nvarchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(MAX);

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = P_Name FROM vKartrisTypeProducts WHERE P_ID = @P_ID AND LANG_ID = @LANG_ID ;

	-- Return the result of the function
	RETURN @Result

END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisShippingZones_Get]    Script Date: 2015-03-26 14:49:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[_spKartrisShippingZones_Get]
(
	@LANG_ID tinyint
)
AS
	SET NOCOUNT ON;
SELECT        SZ_ID, LANG_ID, SZ_Name, SZ_Live, SZ_OrderByValue
FROM            vKartrisTypeShippingZones
WHERE        (LANG_ID = @LANG_ID)
ORDER BY SZ_OrderByValue
GO

/****** Allow turning off back end homepage graphs on big sites where this can cause timeouts ******/
BEGIN TRY
	INSERT [dbo].[tblKartrisConfig] ([CFG_Name], [CFG_Value], [CFG_DataType], [CFG_DisplayType], [CFG_DisplayInfo], [CFG_Description], [CFG_VersionAdded], [CFG_DefaultValue], [CFG_Important]) VALUES (N'backend.homepage.graphs', N'ON', N's', N'b', 'ON|OFF', N'Hides the data summary graphs on the back end home page, suggested on large sites where the queries may time out and put unnecessary load on site.', 2.8004, N'ON', 0)
END TRY
BEGIN CATCH
	/* chill, config setting is already there */
END CATCH
GO

/******
Below are various fixes for sprocs that deal with options, to ensure correct
sorting on front end displays
******/


/****** Object:  StoredProcedure [dbo].[spKartrisProductOptionGroupLink_Get]    Script Date: 2015-04-02 13:21:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spKartrisProductOptionGroupLink_Get]
AS
	SET NOCOUNT ON;
SELECT        tblKartrisProductOptionGroupLink.*
FROM            tblKartrisProductOptionGroupLink
ORDER BY P_OPTG_OrderByValue
GO

/****** Object:  StoredProcedure [dbo].[spKartrisProductOptionLink_Get]    Script Date: 2015-04-02 13:22:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spKartrisProductOptionLink_Get]
AS
	SET NOCOUNT ON;
SELECT        tblKartrisProductOptionLink.*
FROM            tblKartrisProductOptionLink

ORDER BY P_OPT_OrderByValue

GO

/****** Object:  StoredProcedure [dbo].[spKartrisOptions_Get]    Script Date: 2015-04-02 13:21:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spKartrisOptions_Get]
AS
	SET NOCOUNT ON;
SELECT        tblKartrisOptions.*
FROM            tblKartrisOptions
ORDER BY OPT_DefOrderByValue
GO

/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetOptions]    Script Date: 2015-04-02 14:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	replaces [spKartris_VER_GetVersionOptions]
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisVersions_GetOptions](@P_ID as int, @LANG_ID as tinyint)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT     vKartrisTypeOptionGroups.OPTG_ID, vKartrisTypeOptionGroups.OPTG_Name, vKartrisTypeOptionGroups.OPTG_Desc, 
					  vKartrisTypeOptionGroups.OPTG_OptionDisplayType, tblKartrisProductOptionGroupLink.P_OPTG_MustSelected
FROM         vKartrisTypeOptionGroups INNER JOIN
					  tblKartrisProductOptionGroupLink ON vKartrisTypeOptionGroups.OPTG_ID = tblKartrisProductOptionGroupLink.P_OPTG_OptionGroupID
WHERE     (vKartrisTypeOptionGroups.LANG_ID = @LANG_ID) AND (tblKartrisProductOptionGroupLink.P_OPTG_ProductID = @P_ID)
ORDER BY tblKartrisProductOptionGroupLink.P_OPTG_OrderByValue, vKartrisTypeOptionGroups.OPTG_DefOrderByValue
END
GO

/****** Object:  StoredProcedure [dbo].[spKartrisVersions_GetOptionValues]    Script Date: 2015-04-02 14:32:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	replaces [spKartris_VER_GetVersionOptionValues]
-- =============================================
ALTER PROCEDURE [dbo].[spKartrisVersions_GetOptionValues](@P_ID as int, @OPT_OptionGroupID as tinyint, @LANG_ID as tinyint)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT		vKartrisTypeOptions.OPT_ID, vKartrisTypeOptions.OPT_Name, vKartrisTypeOptions.OPT_CheckBoxValue, 
				tblKartrisProductOptionLink.P_OPT_PriceChange, tblKartrisProductOptionLink.P_OPT_Selected
	FROM         vKartrisTypeOptions INNER JOIN tblKartrisProductOptionLink 
				ON vKartrisTypeOptions.OPT_ID = tblKartrisProductOptionLink.P_OPT_OptionID
	WHERE      (vKartrisTypeOptions.LANG_ID = @LANG_ID) 
				AND (vKartrisTypeOptions.OPT_OptionGroupID = @OPT_OptionGroupID) 
				AND (tblKartrisProductOptionLink.P_OPT_ProductID = @P_ID)
	ORDER BY    tblKartrisProductOptionLink.P_OPT_OrderByValue, vKartrisTypeOptions.OPT_DefOrderByValue
END
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisOptions_GetByGroupID]    Script Date: 2015-04-02 14:57:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisOptions_GetByGroupID]
(
	@LANG_ID tinyint,
	@OptionGroupID smallint
)
AS
	SET NOCOUNT ON;
SELECT     vKartrisTypeOptions.OPT_ID, vKartrisTypeOptions.LANG_ID, vKartrisTypeOptions.OPT_Name, vKartrisTypeOptions.OPT_OptionGroupID, 
					  vKartrisTypeOptions.OPT_CheckBoxValue, vKartrisTypeOptions.OPT_DefPriceChange, vKartrisTypeOptions.OPT_DefWeightChange, 
					  vKartrisTypeOptions.OPT_DefOrderByValue, tblKartrisOptionGroups.OPTG_OptionDisplayType
FROM         vKartrisTypeOptions INNER JOIN
					  tblKartrisOptionGroups ON vKartrisTypeOptions.OPT_OptionGroupID = tblKartrisOptionGroups.OPTG_ID
WHERE     (vKartrisTypeOptions.LANG_ID = @LANG_ID) AND (vKartrisTypeOptions.OPT_OptionGroupID = @OptionGroupID)
ORDER BY vKartrisTypeOptions.OPT_DefOrderByValue, vKartrisTypeOptions.OPT_Name
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisProductOptionLink_Add]    Script Date: 01/23/2013 21:59:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisProductOptionLink_Add]
(
	@OptionID as int,
	@ProductID int,
	@OrderBy as smallint,
	@PriceChange as real,
	@WeightChange as real,
	@Selected as bit
)
AS
	SET NOCOUNT OFF;
	
	INSERT INTO [tblKartrisProductOptionLink] 
	VALUES (@OptionID, @ProductID, @OrderBy, @PriceChange, @WeightChange, @Selected);
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisOptionGroups_Update]    Script Date: 01/23/2013 21:59:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisOptionGroups_Update]
(
	@OPTG_BackendName nvarchar(50),
	@OPTG_OptionDisplayType char(1),
	@OPTG_DefOrderByValue smallint,
	@Original_OPTG_ID smallint
)
AS
	SET NOCOUNT OFF;

	UPDATE	[tblKartrisOptionGroups] 
	SET		[OPTG_BackendName] = @OPTG_BackendName, [OPTG_OptionDisplayType] = @OPTG_OptionDisplayType, 
			[OPTG_DefOrderByValue] = @OPTG_DefOrderByValue 
	WHERE	(([OPTG_ID] = @Original_OPTG_ID));
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisOptionGroups_Add]    Script Date: 01/23/2013 21:59:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisOptionGroups_Add]
(
	@OPTG_BackendName nvarchar(50),
	@OPTG_OptionDisplayType char(1),
	@OPTG_DefOrderByValue smallint,
	@NewID smallint OUT
)
AS
	SET NOCOUNT OFF;

	INSERT INTO [tblKartrisOptionGroups] ([OPTG_BackendName], [OPTG_OptionDisplayType], [OPTG_DefOrderByValue]) 
	VALUES (@OPTG_BackendName, @OPTG_OptionDisplayType, @OPTG_DefOrderByValue);
	SELECT @NewID = SCOPE_IDENTITY();
GO

/****** Object:  StoredProcedure [dbo].[_spKartrisProductOptionGroupLink_Add]    Script Date: 01/23/2013 21:59:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[_spKartrisProductOptionGroupLink_Add]
(
	@ProductID int,
	@GroupID as smallint,
	@OrderBy as smallint,
	@MustSelect as bit
)
AS
	SET NOCOUNT OFF;
	
	INSERT INTO [tblKartrisProductOptionGroupLink] 
	VALUES (@ProductID, @GroupID, @OrderBy, @MustSelect);
GO

/******
Update Options tables to change the sort-order fields
to smallint
******/
DROP INDEX [Indx_DefOrderByValue] ON [dbo].[tblKartrisOptionGroups]
GO
ALTER TABLE [dbo].[tblKartrisOptionGroups] ALTER COLUMN OPTG_DefOrderByValue [smallint] NOT NULL
GO
CREATE NONCLUSTERED INDEX [Indx_DefOrderByValue] ON [dbo].[tblKartrisOptionGroups]
(
	[OPTG_DefOrderByValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblKartrisProductOptionGroupLink] ALTER COLUMN P_OPTG_OrderByValue [smallint] NOT NULL
GO

ALTER TABLE [dbo].[tblKartrisProductOptionLink] ALTER COLUMN P_OPT_OrderByValue [smallint] NOT NULL
GO

/******
Remove linnworks stuff
******/

BEGIN TRY

	/****** Object:  Table [dbo].[tblKartrisLinnworksOrders]    Script Date: 2015-04-02 14:35:36 ******/
	DROP TABLE [dbo].[tblKartrisLinnworksOrders]

	/****** Object:  StoredProcedure [dbo].[_spKartrisLinnworksOrders_Add]    Script Date: 2015-04-02 14:36:47 ******/
	DROP PROCEDURE [dbo].[_spKartrisLinnworksOrders_Add]

	/****** Object:  StoredProcedure [dbo].[_spKartrisLinnworksOrders_Get]    Script Date: 2015-04-02 14:37:03 ******/
	DROP PROCEDURE [dbo].[_spKartrisLinnworksOrders_Get]

END TRY
BEGIN CATCH
	/* er... nothing here */
END CATCH

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.8004', CFG_VersionAdded=2.8004 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO
