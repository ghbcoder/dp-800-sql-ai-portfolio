CREATE TABLE [dbo].[TicketMessages]
(
    [MessageID] INT IDENTITY(1,1) NOT NULL,
    [TicketID] INT NOT NULL,
    [MessageText] NVARCHAR(MAX) NOT NULL,
    [CreatedAt] DATETIME2 NOT NULL
        CONSTRAINT [DF_TicketMessages_CreatedAt]
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [PK_TicketMessages]
        PRIMARY KEY ([MessageID]),

    CONSTRAINT [FK_TicketMessages_SupportTickets]
        FOREIGN KEY ([TicketID])
        REFERENCES [dbo].[SupportTickets] ([TicketID])
);