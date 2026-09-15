CREATE TABLE dbo.Customers
(
    CustomerID INT IDENTITY(1,1) NOT NULL,
    FullName   NVARCHAR(200) NOT NULL,
    Email      NVARCHAR(320) NOT NULL,
    CreatedAt  DATETIME2 NOT NULL
        CONSTRAINT DF_Customers_CreatedAt
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Customers
        PRIMARY KEY (CustomerID),

    CONSTRAINT UQ_Customers_Email
        UNIQUE (Email)
);
