

/****** Object:  Index [idxSESS_Code]    Script Date: 22/03/2017 14:08:03 ******/
DROP INDEX [idxSESS_Code] ON [dbo].[tblKartrisSessions] WITH ( ONLINE = OFF )
GO

 /****** ADD SUPPORT FOR EXTERNAL SSL OPTIONS ******/
 UPDATE tblKartrisConfig SET CFG_DisplayInfo = N'y|n|a|e', CFG_Description = N'y = SSL on for essential pages, n = SSL off, a = SSL always on for all pages, e = external SSL (such as Cloudflare)' WHERE CFG_Name = N'general.security.ssl'
 GO