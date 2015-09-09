import sys
sys.path.append("/tmp/alpino")
import alpino
import clam.clamservice
application = clam.clamservice.run_wsgi(alpino)