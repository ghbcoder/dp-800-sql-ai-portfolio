from database import open_connection

def create_support_ticket(customer_id: int, title: str) -> int:
    with open_connection() as connection:
        cursor = connection.cursor()

        row = cursor.execute(
            """
            DECLARE @TicketID INT;

            EXEC dbo.CreateSupportTicket
                @CustomerID = ?,
                @Title = ?,
                @TicketID = @TicketID OUTPUT;

            SELECT @TicketID AS TicketID;
            """,
            customer_id,
            title,
        ).fetchone()

        connection.commit()

        return row.TicketID


if __name__ == "__main__":
    ticket_id = create_support_ticket(
        customer_id=1,
        title="Python passwordless connectivity test",
    )

    print(f"Created support ticket: {ticket_id}")