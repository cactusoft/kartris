/****** Object:  UserDefinedFunction [dbo].[fnKartrisBasket_GetItemWeight]    Script Date: 17/06/2016 19:40:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [dbo].[fnKartrisBasket_GetItemWeight]
(
	@BasketValueID as bigint,
	@VersionID as bigint,
	@ProductID as int
)
RETURNS real
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Weight as real;
	DECLARE @WeightBase as real;

	DECLARE @ProductType as char(1);
	
	SELECT @ProductType = P_Type
	FROM tblKartrisProducts 
	WHERE P_ID = @ProductID;
	
	IF @ProductType IN ('s','m') BEGIN
		SELECT @Weight = V_Weight
		FROM tblKartrisVersions
		WHERE V_ID = @VersionID;
	END ELSE BEGIN
		DECLARE @OptionsList as nvarchar(max);
		SELECT @OptionsList = COALESCE(@OptionsList + ',', '') + CAST(T.BSKTOPT_OptionID As nvarchar(10))
		FROM (SELECT BSKTOPT_OptionID FROM dbo.tblKartrisBasketOptionValues WHERE  BSKTOPT_BasketValueID = @BasketValueID) AS T;
		
		SELECT @Weight = SUM(P_OPT_WeightChange)
		FROM dbo.tblKartrisProductOptionLink
		WHERE P_OPT_ProductID = @ProductID AND P_OPT_OptionID IN (SELECT * FROM dbo.fnTbl_SplitNumbers(@OptionsList));
		
		-- If weight = 0, then no weight change for the options, we need to use the base version.
		IF @Weight = 0 BEGIN
			SELECT @Weight = V_Weight FROM tblKartrisVersions WHERE V_ID = @VersionID;
			END
		ELSE
			-- Get weight of options and weight of base version, add together
			BEGIN
				SELECT @WeightBase = V_Weight FROM tblKartrisVersions WHERE V_ID = @VersionID;
				SET @Weight = @Weight + @WeightBase;
			END
	END
	
	-- Return the result of the function
	RETURN @Weight;

END
GO
/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.9006', CFG_VersionAdded=2.9006 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO



















