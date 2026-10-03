import os

from azure.identity import AzureCliCredential, ManagedIdentityCredential


def get_credential():
    mode = os.environ.get("AZURE_AUTH_MODE", "developer")

    if mode == "developer":
        return AzureCliCredential()

    if mode == "managed-identity":
        client_id = os.environ["AZURE_CLIENT_ID"]

        return ManagedIdentityCredential(
            client_id=client_id
        )

    raise ValueError(
        f"Unsupported AZURE_AUTH_MODE: {mode}"
    )