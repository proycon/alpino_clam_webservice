#!/usr/bin/env python3

import clam.clamservice
import alpino_webservice.alpino_webservice as service
application = clam.clamservice.run_wsgi(service)

