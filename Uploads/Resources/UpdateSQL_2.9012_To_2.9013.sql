

/****** new GDPR functionality ******/
INSERT INTO [tblKartrisConfig]
(CFG_Name,CFG_Value,CFG_DataType,CFG_DisplayType,CFG_DisplayInfo,CFG_Description,CFG_VersionAdded,CFG_DefaultValue,CFG_Important)
VALUES
(N'general.gdpr.mailinglistbcc', N'', N's', N't', '', N'An email address to BCC mailing list confirmations to as proof of GDPR terms',2.9013, N'', 0);

GO

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.9013', CFG_VersionAdded=2.9013 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO
