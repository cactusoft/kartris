
/* Improve stats table indexes, remove duplicates, make sure date and other
filter items are included */

/****** Object:  Index [PS_ID]    Script Date: 03/05/2021 10:37:10 ******/
DROP INDEX [idxST_ID] ON [dbo].[tblKartrisStatistics]
GO

DROP INDEX [PS_ID] ON [dbo].[tblKartrisStatistics]
GO

/****** Object:  Index [ST_Date]    Script Date: 03/05/2021 10:40:19 ******/
CREATE NONCLUSTERED INDEX [ST_Date] ON [dbo].[tblKartrisStatistics]
(
	[ST_Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [ST_Type]    Script Date: 03/05/2021 10:40:37 ******/
CREATE NONCLUSTERED INDEX [ST_Type] ON [dbo].[tblKartrisStatistics]
(
	[ST_Type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [ST_ItemID]    Script Date: 03/05/2021 10:40:53 ******/
CREATE NONCLUSTERED INDEX [ST_ItemID] ON [dbo].[tblKartrisStatistics]
(
	[ST_ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='3.1002', CFG_VersionAdded=3.1002 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO


