"""Module for the service announcements listener and publisher.

You can reuse it in all your services.
"""

import logging
import os
import threading

import Ice

try:
    import IceFlix
except ImportError:
    Ice.loadSlice(os.path.join(os.path.dirname(__file__), "iceflix.ice"))
    import IceFlix


class ServiceAnnouncementsListener(IceFlix.ServiceAnnouncements):
    """Listener for the ServiceAnnouncements topic."""

    def __init__(self, own_servant, own_service_id, own_type):
        """Initialize a ServiceAnnouncements topic listener.

        The `own_servant` argument should be the service servant object, that is
        expected to have a `share_data_with` method. That method should receive
        the proxy of the new announced service and is expected that it invokes
        remotely the `updateDB` method with the appropriate values.

        The `own_service_id` argument should be a string with an unique
        identifier. It should be the same used to announce this service.

        The `own_type` argument should be a class reference for the type of the
        `own_servant`. For example, IceFlix.MainPrx.
        """
        self.servant = own_servant
        self.service_id = own_service_id
        self.own_type = own_type

        self.authenticators = {}
        self.catalogs = {}
        self.mains = {}
        self.known_ids = set()

    def newService(
        self, service, service_id, current
    ):  # pylint: disable=invalid-name,unused-argument
        """Receive the announcement of a new started service."""
        if service_id == self.service_id:
            logging.debug("Received own announcement. Ignoring")
            return

        proxy = self.own_type.checkedCast(service)

        if not proxy:
            logging.debug("New service isn't of my type. Ignoring")
            return

        self.servant.share_data_with(proxy)

    def announce(self, service, service_id, current):  # pylint: disable=unused-argument
        """Receive an announcement."""

        if service_id == self.service_id or service_id in self.known_ids:
            logging.debug("Received own announcement or already known. Ignoring")
            return

        if service.ice_isA("::IceFlix::Main"):
            self.mains[service_id] = IceFlix.MainPrx.uncheckedCast(service)

        elif service.ice_isA("::IceFlix::Authenticator"):
            self.authenticators[service_id] = IceFlix.AuthenticatorPrx.uncheckedCast(
                service
            )

        elif service.ice_isA("::IceFlix::MediaCatalog"):
            self.catalogs[service_id] = IceFlix.MediaCatalogPrx.uncheckedCast(service)

        else:
            logging.info(
                "Received annoucement from unknown service %s: %s",
                service_id,
                service.ice_ids(),
            )


class ServiceAnnouncementsSender:
    """The instances send the announcement events periodically to the topic."""

    def __init__(self, topic, service_id, servant_proxy):
        """Initialize a ServiceAnnoucentsSender.

        The `topic` argument should be a IceStorm.TopicPrx object.
        The `service_id` should be the unique identifier of the announced proxy
        The `servant_proxy` should be a object proxy to the servant.
        """
        self.publisher = IceFlix.ServiceAnnouncementsPrx.uncheckedCast(
            topic.getPublisher(),
        )
        self.service_id = service_id
        self.proxy = servant_proxy
        self.timer = None

    def start_service(self):
        """Start sending the initial announcement."""
        self.publisher.newService(self.proxy, self.service_id)
        self.timer = threading.Timer(3.0, self.announce)
        self.timer.start()

    def announce(self):
        """Start sending the announcements."""
        self.timer = None

        self.publisher.announce(self.proxy, self.service_id)
        self.timer = threading.Timer(10.0, self.announce)
        self.timer.start()

    def stop(self):
        """Stop sending the announcements."""
        if self.timer:
            self.timer.cancel()
            self.timer = None
