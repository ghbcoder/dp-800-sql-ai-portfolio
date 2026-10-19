CREATE ROLE [DatabaseDeploymentValidator];
GO

GRANT VIEW DEFINITION
    TO [DatabaseDeploymentValidator];

GO

GRANT ALTER
    ON OBJECT::dbo.KnowledgeArticles
    TO [DatabaseDeploymentValidator];
GO
