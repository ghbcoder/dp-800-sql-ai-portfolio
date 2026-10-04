def get_security_context(connection):
    cursor = connection.cursor()

    row = cursor.execute(
        """
        SELECT
            DB_NAME() AS DatabaseName,
            SUSER_SNAME() AS LoginIdentity,
            USER_NAME() AS DatabaseUser,
            ORIGINAL_LOGIN() AS OriginalLogin;
        """
    ).fetchone()

    return {
        "database": row.DatabaseName,
        "login_identity": row.LoginIdentity,
        "database_user": row.DatabaseUser,
        "original_login": row.OriginalLogin,
    }