
/****** Object:  Index [CO_ParentOrderID]    Script Date: 25/11/2021 20:18:48 ******/
CREATE UNIQUE NONCLUSTERED INDEX [CO_ParentOrderID] ON [dbo].[tblKartrisClonedOrders]
(
	[CO_ParentOrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

/* Change the OrderNo field in category-product link, smallint too small when have large number (32768+) products in a category */
ALTER TABLE tblKartrisProductCategoryLink ALTER COLUMN PCAT_OrderNo int

/****** Set this to tell Data tool which version of db we have ******/
UPDATE tblKartrisConfig SET CFG_Value='3.2002', CFG_VersionAdded=3.2002 WHERE CFG_Name='general.kartrisinfo.versionadded';
GO


