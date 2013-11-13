/****** Object:  Table [dbo].[tblKartrisLanguageStrings]    Script Date: 9/9/2013 3:29:00 PM ******/
INSERT [dbo].[tblKartrisLanguageStrings] ([LS_FrontBack], [LS_Name], [LS_Value], [LS_Description], [LS_VersionAdded], [LS_DefaultValue], [LS_VirtualPath], [LS_ClassName], [LS_LangID]) VALUES (N'f', N'ContentText_NoValidShipping', N'No shipping is available for this order to your selected destination.', '', 2.5007, N'No shipping is available for this order to your selected destination.', NULL, N'Shipping', 1)
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_Update]    Script Date: 10/30/2013 3:28:40 PM ******/
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
	@V_Price as real,
	@V_Tax as tinyint,
	@V_Weight as real,
	@V_DeliveryTime as tinyint,
	@V_Quantity as real,
	@V_QuantityWarnLevel as real,
	@V_Live as bit,
	@V_DownLoadInfo as nvarchar(255),
	@V_DownloadType as nvarchar(50),
	@V_RRP as real,
	@V_Type as char(1),
	@V_CustomerGroupID as smallint,
	@V_CustomizationType as char(1),
	@V_CustomizationDesc as nvarchar(255),
	@V_CustomizationCost as real,
	@V_Tax2 as tinyint,
	@V_TaxExtra as nvarchar(255)
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
		V_Tax2 = @V_Tax2, V_TaxExtra = @V_TaxExtra
	WHERE V_ID = @V_ID;
	
	IF @V_Type = 'b' BEGIN
		UPDATE tblKartrisVersions
		SET V_DownLoadInfo = @V_DownLoadInfo, V_DownloadType = @V_DownloadType
		WHERE V_ProductID = @V_ProductID AND V_Type = 'c';
	END

END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_UpdateCombinationsFromBasicInfo]    Script Date: 10/30/2013 3:28:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	Updates a specific combination version
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_UpdateCombinationsFromBasicInfo]
(
	@ProductID as int,
	@Price as real, 
	@Tax as tinyint,
	@Tax2 as tinyint,
	@TaxExtra as nvarchar(50),
	@Weight as real,
	@RRP as real
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DownloadInfo as nvarchar(255), @DownloadType as nvarchar(50);
	SELECT @DownloadInfo = [V_DownLoadInfo], @DownloadType = [V_DownloadType]
	FROM [dbo].[tblKartrisVersions]
	WHERE [V_ProductID] = @ProductID AND [V_Type] = 'b';
	
	UPDATE tblKartrisVersions
	SET V_Price = @Price, V_Tax = @Tax, V_Weight = @Weight, V_RRP = @RRP, V_Tax2 = @Tax2, V_TaxExtra = @TaxExtra,
		V_DownLoadInfo = @DownloadInfo, V_DownloadType = @DownloadType
	WHERE V_ProductID = @ProductID AND (V_Type = 'c' OR V_Type = 's');
	

	
END
GO
/****** Object:  StoredProcedure [dbo].[_spKartrisVersions_AddAsCombination]    Script Date: 10/30/2013 3:24:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[_spKartrisVersions_AddAsCombination]
(
	@V_CodeNumber as nvarchar(25),
	@V_ProductID as int,
	@V_Price as real,
	@V_Tax as tinyint,
	@V_Tax2 as tinyint,
	@V_TaxExtra as nvarchar(50),
	@V_Weight as real,
	@V_Quantity as real,
	@V_QuantityWarnLevel as real,
	@V_RRP as real,
	@V_Type as char(1),
	@V_NewID as bigint OUT
)
								
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @DownloadInfo as nvarchar(255), @DownloadType as nvarchar(50);
	SELECT @DownloadInfo = [V_DownLoadInfo], @DownloadType = [V_DownloadType]
	FROM [dbo].[tblKartrisVersions]
	WHERE [V_ProductID] = @V_ProductID AND [V_Type] = 'b';

	INSERT INTO tblKartrisVersions
	VALUES (@V_CodeNumber, @V_ProductID, @V_Price, @V_Tax, @V_Weight, 0, @V_Quantity, @V_QuantityWarnLevel, 
			1, @DownloadInfo, @DownloadType, 20, @V_RRP, @V_Type, NULL, 'n', NULL, 0, @V_Tax2, @V_TaxExtra);
			
	SELECT @V_NewID = SCOPE_IDENTITY();
	

END
GO
INSERT [dbo].[tblKartrisObjectConfig] ([OC_Name], [OC_ObjectType], [OC_DataType], [OC_DefaultValue], [OC_Description], [OC_MultilineValue], [OC_VersionAdded]) 
VALUES (N'K:product.showlargeimageinline', N'Product', N'b', N'0', N'Change products images to large view mode instead of being displayed in the image gallery.', 0, 2.5006);
GO
DECLARE @OC_ID as int;
SELECT @OC_ID = OC_ID FROM [dbo].[tblKartrisObjectConfig] WHERE [OC_Name] = N'K:product.showlargeimageinline';

INSERT INTO dbo.tblKartrisObjectConfigValue
SELECT @OC_ID, P_ID, 1
FROM dbo.vKartrisTypeProducts
WHERE P_Desc LIKE '%<overridelargeimagelinktype>';

GO
