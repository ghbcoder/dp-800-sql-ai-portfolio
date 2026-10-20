-- Add a drift probe column to the KnowledgeArticles table for post-deployment verification
ALTER TABLE dbo.KnowledgeArticles
ADD __DriftProbe bit NULL;
GO


-- Drop the drift probe column after post-deployment verification
ALTER TABLE dbo.KnowledgeArticles
DROP COLUMN __DriftProbe;
GO