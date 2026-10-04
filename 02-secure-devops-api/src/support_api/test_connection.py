from database import open_connection
from security_context import get_security_context

with open_connection() as connection:
    context = get_security_context(connection)

    print(f"Database: {context['database']}")
    print(f"Login identity: {context['login_identity']}")
    print(f"Database user: {context['database_user']}")
    print(f"Original login: {context['original_login']}")
