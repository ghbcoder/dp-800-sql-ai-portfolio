from database import open_connection

with open_connection() as connection:
    cursor = connection.cursor()

    cursor.execute(
        """
        SELECT
            DB_NAME() AS DatabaseName,
            SUSER_SNAME() AS LoginIdentity,
            USER_NAME() AS DatabaseUser,
            ORIGINAL_LOGIN() AS OriginalLogin;
        """
    )

    row = cursor.fetchone()

    print(f"Database: {row.DatabaseName}")
    print(f"Login identity: {row.LoginIdentity}")
    print(f"Database user: {row.DatabaseUser}")
    print(f"Original login: {row.OriginalLogin}")