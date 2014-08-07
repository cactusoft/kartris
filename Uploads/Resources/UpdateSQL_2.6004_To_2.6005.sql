/****** UPDATE general.security.ssl config setting to include new 'always' option ******/
UPDATE tblKartrisConfig
SET CFG_DisplayType = 'l', CFG_DisplayInfo = 'y|n|a', CFG_Description = 'y = SSL on for essential pages, n = SSL off, a = SSL always on for all pages'
WHERE (CFG_Name = 'general.security.ssl')