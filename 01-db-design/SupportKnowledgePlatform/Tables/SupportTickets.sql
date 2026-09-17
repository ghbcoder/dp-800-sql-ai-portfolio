CREATE TABLE [dbo].[SupportTickets]
(
    [TicketID] INT IDENTITY(1,1) NOT NULL,
    [CustomerID] INT NOT NULL,
    [Title] NVARCHAR(300) NOT NULL,
    [Status] NVARCHAR(30) NOT NULL
        CONSTRAINT [DF_SupportTickets_Status]
        DEFAULT N'Open',
    [AIMetadata] NVARCHAR(MAX) NULL,
    [CreatedAt] DATETIME2 NOT NULL
        CONSTRAINT [DF_SupportTickets_CreatedAt]
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [PK_SupportTickets]
        PRIMARY KEY ([TicketID]),

    CONSTRAINT [FK_SupportTickets_Customers]
        FOREIGN KEY ([CustomerID])
        REFERENCES [dbo].[Customers] ([CustomerID]),

    CONSTRAINT [CK_SupportTickets_Status]
        CHECK ([Status] IN (N'Open', N'In Progress', N'Resolved', N'Closed')),

    CONSTRAINT [CK_SupportTickets_AIMetadata]
        CHECK (
            [AIMetadata] IS NULL OR
            ISJSON([AIMetadata]) = 1
            ),
);
GO

CREATE NONCLUSTERED INDEX [IX_SupportTickets_CustomerID_Status]
ON [dbo].[SupportTickets]
(
    [CustomerID],
    [Status]
)
INCLUDE
(
    [Title],
    [CreatedAt]
);