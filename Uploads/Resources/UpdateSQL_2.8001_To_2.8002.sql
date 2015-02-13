
/****** remove constraint, now set default value for this ******/
ALTER TABLE [dbo].[tblKartrisProducts] DROP CONSTRAINT [CK_Products_VersionsSortDirection]
GO

/****** set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.8002', CFG_VersionAdded=2.8 WHERE CFG_Name='general.kartrisinfo.versionadded';