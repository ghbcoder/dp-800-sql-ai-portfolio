import os
import struct

import pyodbc

from auth import get_credential


SQL_COPT_SS_ACCESS_TOKEN = 1256
AZURE_SQL_SCOPE = "https://database.windows.net/.default"


def open_connection():
    server = os.environ["AZURE_SQL_SERVER"]
    database = os.environ["AZURE_SQL_DATABASE"]

    credential = get_credential()
    token = credential.get_token(AZURE_SQL_SCOPE)

    token_bytes = token.token.encode("utf-16-le")
    token_struct = struct.pack(
        f"<I{len(token_bytes)}s",
        len(token_bytes),
        token_bytes,
    )

    connection_string = (
        "Driver={ODBC Driver 18 for SQL Server};"
        f"Server=tcp:{server},1433;"
        f"Database={database};"
        "Encrypt=yes;"
        "TrustServerCertificate=no;"
    )

    return pyodbc.connect(
        connection_string,
        attrs_before={
            SQL_COPT_SS_ACCESS_TOKEN: token_struct
        },
    )