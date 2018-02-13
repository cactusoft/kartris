
/*** Adding some fields to Users table for GDPR opt in recording  ***/
ALTER TABLE tblKartrisUsers
ADD U_GDPR_OptIn datetime, U_GDPR_SignupIP nvarchar(50); 
GO

/*** Increase some field sizes for IPs to support IPv6  ***/
ALTER TABLE tblKartrisUsers
ALTER COLUMN U_ML_SignupIP nvarchar(50); 

ALTER TABLE tblKartrisUsers
ALTER COLUMN U_ML_ConfirmationIP nvarchar(50); 

ALTER TABLE tblKartrisUsers
ALTER COLUMN U_ML_ConfirmationIP nvarchar(50); 

ALTER TABLE tblKartrisSessions
ALTER COLUMN SESS_IP nvarchar(50); 

ALTER TABLE tblKartrisAffiliateLog
ALTER COLUMN AFLG_IP nvarchar(50); 
GO




/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.9012', CFG_VersionAdded=2.9012 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO

