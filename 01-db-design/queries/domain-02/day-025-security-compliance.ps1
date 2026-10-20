# Show the audit policy for the specified SQL server.
az sql server audit-policy show `
    --resource-group rg-dp800-lab `
    --name sql-dp800-250354

# Show the audit policy for the specified SQL database.
az sql db audit-policy show `
    --resource-group rg-dp800-lab `
    --server sql-dp800-250354 `
    --name sqldb-dp800