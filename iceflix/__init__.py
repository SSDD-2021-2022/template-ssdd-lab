"""iceflix package definition."""

try:
    import IceFlix

except ImportError:
    import os
    import Ice

    Ice.loadSlice(os.path.join(os.path.dirname(__file__), "iceflix.ice"))
