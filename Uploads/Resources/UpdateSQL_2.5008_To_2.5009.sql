-- =============================================
-- Author:		Paul
-- Create date: 2014/1/13
-- Description:	
-- Remarks: Adds indexes for support ticket tables to improve speed and performance
-- =============================================

/****** Object:  Index [STM_Various]    Script Date: 01/13/2014 14:29:02 ******/
CREATE NONCLUSTERED INDEX [STM_Various] ON [dbo].[tblKartrisSupportTicketMessages] 
(
	[STM_TicketID] ASC,
	[STM_LoginID] ASC,
	[STM_DateCreated] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [TIC_VariousFields]    Script Date: 01/13/2014 14:31:26 ******/
CREATE NONCLUSTERED INDEX [TIC_VariousFields] ON [dbo].[tblKartrisSupportTickets] 
(
	[TIC_UserID] ASC,
	[TIC_LoginID] ASC,
	[TIC_Status] ASC,
	[TIC_DateOpened] ASC,
	[TIC_DateClosed] ASC,
	[TIC_SupportTicketTypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [TIC_Subject]    Script Date: 01/13/2014 14:31:40 ******/
CREATE NONCLUSTERED INDEX [TIC_Subject] ON [dbo].[tblKartrisSupportTickets] 
(
	[TIC_Subject] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO





