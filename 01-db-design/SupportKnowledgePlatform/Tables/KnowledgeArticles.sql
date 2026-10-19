CREATE TABLE [dbo].[KnowledgeArticles]
(
    [ArticleID] INT IDENTITY(1,1) NOT NULL,
    [Title] NVARCHAR(300) NOT NULL,
    [Content] NVARCHAR(MAX) NOT NULL,
    [Category] NVARCHAR(100) NULL,
    [CreatedAt] DATETIME2 NOT NULL
        CONSTRAINT [DF_KnowledgeArticles_CreatedAt]
        DEFAULT SYSUTCDATETIME(),
    [LastReviewedAt] DATETIME2 (0) NULL,

    CONSTRAINT [PK_KnowledgeArticles]
        PRIMARY KEY ([ArticleID])
);