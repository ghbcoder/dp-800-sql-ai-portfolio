CREATE TABLE [dbo].[SupportTickets]
(
    [TicketID] INT IDENTITY(1,1) NOT NULL,
    [CustomerID] INT NOT NULL,
    [Title] NVARCHAR(300) NOT NULL,
    [Status] NVARCHAR(30) NOT NULL,
    [CreatedAt] DATETIME2 NOT NULL
        CONSTRAINT [DF_SupportTickets_CreatedAt]
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [PK_SupportTickets]
        PRIMARY KEY ([TicketID]),

    CONSTRAINT [FK_SupportTickets_Customers]
        FOREIGN KEY ([CustomerID])
        REFERENCES [dbo].[Customers] ([CustomerID])
);
