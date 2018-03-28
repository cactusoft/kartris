

/****** new GDPR functionality ******/
INSERT INTO [tblKartrisConfig]
(CFG_Name,CFG_Value,CFG_DataType,CFG_DisplayType,CFG_DisplayInfo,CFG_Description,CFG_VersionAdded,CFG_DefaultValue,CFG_Important)
VALUES
(N'general.gdpr.mailinglistbcc', N'y', N's', N't',	'',N'An email address to BCC mailing list confirmations to as proof of GDPR terms',2.9013, N'y', 0);

GO
