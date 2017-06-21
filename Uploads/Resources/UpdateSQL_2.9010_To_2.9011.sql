
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

INSERT INTO [tblKartrisConfig]
(CFG_Name,CFG_Value,CFG_DataType,CFG_DisplayType,CFG_DisplayInfo,CFG_Description,CFG_VersionAdded,CFG_DefaultValue,CFG_Important)
VALUES
('general.mailchimp.storeid', '', 's', 't',	'','MailChimp ECommerce Store ID.','2.9011', 'store', 0)

INSERT INTO [tblKartrisConfig]
(CFG_Name,CFG_Value,CFG_DataType,CFG_DisplayType,CFG_DisplayInfo,CFG_Description,CFG_VersionAdded,CFG_DefaultValue,CFG_Important)
VALUES
('general.mailchimp.listid', '', 's', 't',	'','MailChimp Subscribers List ID. This list is created in the MailChimp website. MailChimp>Lists>Select Your List>Settings>List name and defaults>ListID should appear in the screen','2.9011', '', 0)


/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.9011', CFG_VersionAdded=2.9010 WHERE CFG_Name='general.kartrisinfo.versionadded';