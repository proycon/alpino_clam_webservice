Alpino webservice (CLAM-based)
===============================

*(Licensed under the GNU Public License v3)*

This is a webservice for [Alpino](http://www.let.rug.nl/vannoord/alp/Alpino/),
a dependency parser for Dutch developed at the University of Groningen. The
webservice is powered by [CLAM](https://proycon.github.io/clam).

We host this webservice on https://webservices-lst.science.ru.nl , register for
a free account there if you just want to use our installation. You can also
consult the [REST API specification](https://webservices-lst.science.ru.nl/alpino/info/) there.

If you want to deploy the webservice yourself, on your own server, then this
repository holds the CLAM service configuration and wrapper script. You will
need to install the dependencies CLAM, FoLiA-tools and PyNLPl (``pip install
clam folia-tools pynlpl``). itself. If you use your
[LaMachine](https://proycon.github.io/LaMachine) distribution then there are
all included already. 

You will obviously also need
[Alpino](http://www.let.rug.nl/vannoord/alp/Alpino/) itself, it is not included
here nor in LaMachine. Make sure it is properly set up with the
``$ALPINO_HOME`` environment variable pointing to the right path.

Edit the service configuration file ``alpino.py`` and add
a section for your server. Use the provided ``startserver_development.sh`` or
``startserver_production.sh`` script to start the server.

Consult the [CLAM](https://proycon.github.io/clam) manual for details regarding
configuration and deployment.





