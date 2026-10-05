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
    
    [ValidFrom] DATETIME2 GENERATED ALWAYS AS ROW START
        HIDDEN NOT NULL
        CONSTRAINT [DF_SupportTickets_ValidFrom]
        DEFAULT SYSUTCDATETIME(),
    
    [ValidTo] DATETIME2 GENERATED ALWAYS AS ROW END
        HIDDEN NOT NULL
        CONSTRAINT [DF_SupportTickets_ValidTo]
        DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),

    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo]),

    CONSTRAINT [PK_SupportTickets]
        PRIMARY KEY ([TicketID]),

    CONSTRAINT [FK_SupportTickets_Customers]
        FOREIGN KEY ([CustomerID])
        REFERENCES [dbo].[Customers] ([CustomerID]),

    CONSTRAINT [CK_SupportTickets_Status]
        CHECK (
            [Status] = N'Open'
            OR [Status] = N'In Progress'
            OR [Status] = N'Resolved'
            OR [Status] = N'Closed'
        ),

    CONSTRAINT [CK_SupportTickets_AIMetadata]
        CHECK (
            [AIMetadata] IS NULL OR
            ISJSON([AIMetadata]) = 1
            )
)
WITH
(
    SYSTEM_VERSIONING = ON
    (
        HISTORY_TABLE = [dbo].[SupportTicketsHistory],
        DATA_CONSISTENCY_CHECK = ON
    )
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
GO

CREATE NONCLUSTERED INDEX [IX_SupportTickets_CustomerID_CreatedAt]
    ON [dbo].[SupportTickets]
    (
        [CustomerID],
        [CreatedAt] DESC,
        [TicketID] DESC
    )
    INCLUDE
    (
        [Title],
        [Status]
    );
GO
