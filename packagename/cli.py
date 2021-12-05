"""Submodule containing the CLI command handlers."""

import os
import sys

import Ice

Ice.loadSlice(os.path.join(os.path.dirname(__file__), "iceflix.ice"))
import IceFlix  # pylint: disable=wrong-import-position



def main_service():
    """Handles the `mainservice` CLI command."""
    print("Main service")
    print(IceFlix.__name__)
    sys.exit(0)


def catalog_service():
    """Handles the `catalogservice` CLI command."""
    print("Catalog service")
    sys.exit(0)


def streaming_service():
    """Handles the `streamingservice` CLI command."""
    print("Streaming service")
    sys.exit(0)


def authentication_service():
    """Handles the `authenticationservice` CLI command."""
    print("Authentication service")
    sys.exit(0)
