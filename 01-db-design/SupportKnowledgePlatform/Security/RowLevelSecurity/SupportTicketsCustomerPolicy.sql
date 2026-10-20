CREATE SECURITY POLICY [security].[SupportTicketsCustomerPolicy]
    ADD FILTER PREDICATE [security].[fn_SupportTicketRlsPredicate](CustomerID)
        ON dbo.SupportTickets
            WITH (STATE = ON);
GO