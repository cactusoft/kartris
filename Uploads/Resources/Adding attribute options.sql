use kartris_github
go

/* Add the attribute options table. 
This is the table that records what options are attached to attributes with the 'c' (checkbox) (yes/no) display mode set. */
IF NOT (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'tblKartrisAttributeOptions'))
CREATE TABLE dbo.tblKartrisAttributeOptions (
		ATTRIBO_ID INT Primary Key IDENTITY,
		ATTRIBO_AttributeID INT FOREIGN KEY REFERENCES tblKartrisAttributes(ATTRIB_ID) ON DELETE CASCADE ON UPDATE CASCADE,
		ATTRIBO_OrderBYValue TINYINT)
GO

/* Add new language string to support the attribute options */
IF (SELECT COUNT(*) FROM tblKartrisLanguageElementTypes WHERE LET_ID=18) = 0 
	BEGIN
	INSERT INTO tblKartrisLanguageElementTypes(
								LET_ID, LET_Name)
							VALUES (18, 'tblKartrisAttributeOptions')
	END
GO

/* Add new language string to support the attribute options */
IF (SELECT COUNT(*) FROM tblKartrisLanguageElementTypeFields WHERE LET_ID = 18 AND LEFN_ID= 1) = 0
	BEGIN
	INSERT INTO tblKartrisLanguageElementTypeFields(LET_ID, LEFN_ID, LEFN_IsMandatory)
							VALUES (18,1,'true')
	END
GO

/* Create / update the stored procedure for adding an attribute option.
These are options attached to attributes with the 'c' (checkbox) (yes/no) display mode set. */
IF  OBJECT_ID('_spKartrisAttributeOption_Add','P') IS NOT NULL
	DROP PROCEDURE _spKartrisAttributeOption_Add
GO
CREATE PROCEDURE _spKartrisAttributeOption_Add
							(
							@AttributeId INTEGER,
							@OrderByValue TINYINT,
							@NewAttributeOption_ID INT OUT
							)
AS
BEGIN
INSERT INTO tblKartrisAttributeOptions (ATTRIBO_AttributeID, ATTRIBO_OrderBYValue)
						VALUES (@AttributeId, @OrderByValue)
					
SELECT @NewAttributeOption_ID = SCOPE_IDENTITY();
END
GO

/* Create / update the stored procedure for updating an attribute option. */
IF  OBJECT_ID('_spKartrisAttributeOption_Update','P') IS NOT NULL
	DROP PROCEDURE _spKartrisAttributeOption_Update
GO
CREATE PROCEDURE _spKartrisAttributeOption_Update
							(
							@AttributeOptionId INTEGER,
							@OrderByValue TINYINT
							)
AS
BEGIN

UPDATE tblKartrisAttributeOptions SET ATTRIBO_OrderBYValue = @OrderByValue
									WHERE ATTRIBO_ID = @AttributeOptionId		
END
GO

/* Create / update the stored procedure for deleting an attribute option. */
IF  OBJECT_ID('_spKartrisAttributeOption_Delete','P') IS NOT NULL
	DROP PROCEDURE _spKartrisAttributeOption_Delete
GO
CREATE PROCEDURE _spKartrisAttributeOption_Delete
							(
							@AttributeOptionId INTEGER
							)
AS
BEGIN
DELETE FROM tblKartrisAttributeOptions WHERE ATTRIBO_ID = @AttributeOptionId		
END
GO

/* Create / update the stored procedure for retrieving all attribute options for a given attribute */
IF  OBJECT_ID('spKartrisAttributeOptions_GetByAttributeId','P') IS NOT NULL
	DROP PROCEDURE spKartrisAttributeOptions_GetByAttributeId
GO
CREATE PROCEDURE spKartrisAttributeOptions_GetByAttributeId
							(
							@AttributeId INTEGER
							)
AS
BEGIN
SELECT kao.*, kle.LE_Value ATTRIBO_Name FROM tblKartrisAttributeOptions kao INNER JOIN dbo.tblKartrisLanguageElements kle
ON kle.LE_ParentID = kao.ATTRIBO_ID
WHERE ATTRIBO_AttributeID = @AttributeId AND (kle.LE_TypeID = 18) AND (kle.LE_FieldID = 1) AND 
					  (kle.LE_Value IS NOT NULL)
END
GO

/* Create / update the stored procedure for retrieving a single attribute option */
IF  OBJECT_ID('spKartrisAttributeOptions_Get','P') IS NOT NULL
	DROP PROCEDURE spKartrisAttributeOptions_Get
GO
CREATE PROCEDURE spKartrisAttributeOptions_Get
AS
BEGIN
SELECT * FROM tblKartrisAttributeOptions 
END
GO

/* Add the attribute product options table. 
This is the table that links a product to the attribute options that have been selected for that product */
IF NOT (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'tblKartrisAttributeProductOptions'))
CREATE TABLE dbo.tblKartrisAttributeProductOptions (
		ATTRIBPO_ID INT Primary Key IDENTITY,
		ATTRIBPO_AttributeOptionID INT FOREIGN KEY REFERENCES tblKartrisAttributeOptions(ATTRIBO_ID) ON DELETE CASCADE ON UPDATE CASCADE,
		ATTRIBPO_ProductId INT FOREIGN KEY REFERENCES tblKartrisProducts(P_ID) ON DELETE CASCADE ON UPDATE CASCADE
		CONSTRAINT uc_UniqueProductAttributeOption UNIQUE(ATTRIBPO_AttributeOptionID, ATTRIBPO_ProductID)  )
GO

/* Create / update the stored procedure for adding a product attribute.
This ties together a single attribute option and a product to show that this 
attribute option has been selected / applied to a give product */
IF  OBJECT_ID('_spKartrisAttributeProductOption_Add','P') IS NOT NULL
	DROP PROCEDURE _spKartrisAttributeProductOption_Add
GO
CREATE PROCEDURE _spKartrisAttributeProductOption_Add
							(
							@AttributeOptionId INTEGER,
							@ProductId INTEGER,
							@AttributeProductId INTEGER OUTPUT
							)
AS
BEGIN
/* Add a new attribute product option. That is to say, add an attribute option to a product */ 
INSERT INTO tblKartrisAttributeProductOptions
				(ATTRIBPO_AttributeOptionID,
				ATTRIBPO_ProductId)
			VALUES
				(@AttributeOptionId,
				@ProductId)
SET @AttributeProductId = @@IDENTITY
SELECT @AttributeProductId
RETURN
END
GO

/* Create / update the stored procedure for deleting a product attribute. */
IF  OBJECT_ID('_spKartrisAttributeProductOption_Delete','P') IS NOT NULL
	DROP PROCEDURE _spKartrisAttributeProductOption_Delete
GO
CREATE PROCEDURE _spKartrisAttributeProductOption_Delete
							(
							@AttributeProductId INTEGER
							)
AS
BEGIN
DELETE FROM tblKartrisAttributeProductOptions
WHERE ATTRIBPO_ID = @AttributeProductId
END
GO
/* Create / update the stored procedure for retrieving all attribute options that have been applied to a given product */
IF  OBJECT_ID('_spKartrisAttributeProductOptions_GetByProductID','P') IS NOT NULL
	DROP PROCEDURE _spKartrisAttributeProductOptions_GetByProductID
GO
CREATE PROCEDURE _spKartrisAttributeProductOptions_GetByProductID
							(
							@ProductId INTEGER
							)
AS
BEGIN
SELECT * FROM tblKartrisAttributeProductOptions
WHERE ATTRIBPO_ProductId = @ProductId
END
GO

/* Create / update the stored procedure for deleting a single product attribute */
IF  OBJECT_ID('_spKartrisAttributeProductOptions_DeleteByAttributeIdAndProductId','P') IS NOT NULL
	DROP PROCEDURE _spKartrisAttributeProductOptions_DeleteByAttributeIdAndProductId
GO
CREATE PROCEDURE _spKartrisAttributeProductOptions_DeleteByAttributeIdAndProductId
							(
							@AttributeId INTEGER,
							@ProductId INTEGER
							)
AS
BEGIN
/* Delete all product attributes using the attribute ID as the key */
DELETE apo
FROM tblKartrisAttributeProductOptions apo INNER JOIN 
tblKartrisAttributeOptions ao
ON apo.ATTRIBPO_AttributeOptionID = ao.ATTRIBO_ID
WHERE ao.ATTRIBO_AttributeID = @AttributeId
AND apo.ATTRIBPO_ProductId = @ProductId
END 
GO

/* Get attributes by category ID. This is actually used by the Deadline PowerPack modification, but
	this is such an easier place to make the modification */
IF  OBJECT_ID('_spKartrisAttributes_GetByCategoryId','P') IS NOT NULL
	DROP PROCEDURE _spKartrisAttributes_GetByCategoryId
GO
CREATE PROCEDURE _spKartrisAttributes_GetByCategoryId
							(
							@CategoryId INT
							)
AS
BEGIN
/* Select all attributes by category ID.*/
SELECT a.*
FROM tblKartrisAttributes a INNER JOIN tblKartrisAttributeValues av
on a.ATTRIB_ID = av.ATTRIBV_AttributeID INNER JOIN tblKartrisProductCategoryLink pcl
on pcl.PCAT_ProductID = av.ATTRIBV_ProductID
WHERE pcl.PCAT_CategoryID = @CategoryId
END 
GO

/* Retrieve both written attributes and checkbox attributes if the attribute is marked as 'special'. 
	These attributes are used for Google services. */
IF  OBJECT_ID('_spKartrisAttributes_GetSpecialByProductID','P') IS NOT NULL
	DROP PROCEDURE _spKartrisAttributes_GetSpecialByProductID
GO
CREATE PROCEDURE [dbo].[_spKartrisAttributes_GetSpecialByProductID]
	(
		@P_ID int,
		@LANG_ID tinyint
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT     vKartrisTypeAttributes.ATTRIB_Name, vKartrisTypeAttributeValues.ATTRIBV_Value, vKartrisTypeAttributes.ATTRIB_OrderByValue OrderValue
	FROM         vKartrisTypeAttributeValues INNER JOIN
						  vKartrisTypeAttributes ON vKartrisTypeAttributeValues.ATTRIBV_AttributeID = vKartrisTypeAttributes.ATTRIB_ID AND 
						  vKartrisTypeAttributeValues.LANG_ID = vKartrisTypeAttributes.LANG_ID
	WHERE     (vKartrisTypeAttributes.ATTRIB_Live = 1) AND (vKartrisTypeAttributeValues.ATTRIBV_ProductID = @P_ID) AND (vKartrisTypeAttributeValues.LANG_ID = @LANG_ID) 
						  AND (vKartrisTypeAttributes.ATTRIB_Special = 1)
	UNION ALL
	SELECT kta.ATTRIB_Name, kle.LE_Value, kao.ATTRIBO_OrderBYValue OrderValue
	FROM tblKartrisAttributeOptions kao INNER JOIN dbo.tblKartrisLanguageElements kle
ON kle.LE_ParentID = kao.ATTRIBO_ID INNER JOIN vKartrisTypeAttributes kta
ON kta.ATTRIB_ID = kao.ATTRIBO_AttributeID INNER JOIN tblKartrisAttributeProductOptions kapo
ON kapo.ATTRIBPO_AttributeOptionID = kao.ATTRIBO_ID AND kapo.ATTRIBPO_ProductId = @P_ID
WHERE  (kle.LE_TypeID = 18) AND (kle.LE_FieldID = 1) AND 
					  (kle.LE_Value IS NOT NULL)
	ORDER BY OrderValue
END
GO

/* Retrieve product summary for both written attributes and checkbox attributes. */ 
IF  OBJECT_ID('spKartrisAttributes_GetSummaryByProductID','P') IS NOT NULL
	DROP PROCEDURE spKartrisAttributes_GetSummaryByProductID
GO
CREATE PROCEDURE spKartrisAttributes_GetSummaryByProductID
	(
		@P_ID int,
		@LANG_ID tinyint
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 SELECT     vKartrisTypeAttributes.ATTRIB_ID, vKartrisTypeAttributes.ATTRIB_Name, vKartrisTypeAttributeValues.ATTRIBV_Value,
			vKartrisTypeAttributeValues.ATTRIBV_ProductID, vKartrisTypeAttributes.ATTRIB_Compare, 
			vKartrisTypeAttributes.ATTRIB_OrderByValue OrderValue
FROM         vKartrisTypeAttributeValues INNER JOIN
					  vKartrisTypeAttributes ON vKartrisTypeAttributeValues.ATTRIBV_AttributeID = vKartrisTypeAttributes.ATTRIB_ID AND 
					  vKartrisTypeAttributeValues.LANG_ID = vKartrisTypeAttributes.LANG_ID
WHERE     (vKartrisTypeAttributes.ATTRIB_Live = 1) AND (vKartrisTypeAttributes.ATTRIB_ShowFrontend = 1) AND (vKartrisTypeAttributeValues.ATTRIBV_ProductID = @P_ID) AND
					   (vKartrisTypeAttributeValues.LANG_ID = @LANG_ID)

UNION ALL
SELECT kta.ATTRIB_ID, kta.ATTRIB_Name, kle.LE_Value, kapo.ATTRIBPO_ProductId, kta.ATTRIB_Compare, kao.ATTRIBO_OrderBYValue OrderValue
	FROM tblKartrisAttributeOptions kao INNER JOIN dbo.tblKartrisLanguageElements kle
ON kle.LE_ParentID = kao.ATTRIBO_ID INNER JOIN vKartrisTypeAttributes kta
ON kta.ATTRIB_ID = kao.ATTRIBO_AttributeID INNER JOIN tblKartrisAttributeProductOptions kapo
ON kapo.ATTRIBPO_AttributeOptionID = kao.ATTRIBO_ID 
WHERE  (kle.LE_TypeID = 18) AND (kle.LE_FieldID = 1) AND 
					  (kle.LE_Value IS NOT NULL) AND kapo.ATTRIBPO_ProductId=@P_ID 
					  AND kle.LE_LanguageID=@Lang_ID
ORDER BY OrderValue
END
GO
