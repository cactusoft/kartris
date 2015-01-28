
/****** Object:  Index [U_EmailAddress]    Script Date: 2015-01-15 20:22:20 ******/
CREATE UNIQUE NONCLUSTERED INDEX [U_EmailAddress] ON [dbo].[tblKartrisUsers]
(
	[U_EmailAddress] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='2.8001', CFG_VersionAdded=2.8 WHERE CFG_Name='general.kartrisinfo.versionadded';