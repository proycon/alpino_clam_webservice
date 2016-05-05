Alpino webservice (CLAM-based)
===============================

This is a webservice for [Alpino](http://www.let.rug.nl/vannoord/alp/Alpino/),
a dependency parser for Dutch developed at the University of Groningen. The
webservice is powered by [CLAM](https://proycon.github.io/clam).

We host thus webservice on https://webservices-lst.science.ru.nl , register for
a free account there if you just want to use our installation.

If you want to deploy the webservice yourself, on your own server, then this
repository holds the CLAM service configuration and wrapper script. You will
need to install the dependencies CLAM, FoLiA-tools and PyNLPl (``pip install
clam folia-tools pynlpl``). If you use your
[LaMachine](https://proycon.github.io/LaMachine) distribution then there are
all included already. Edit the service configuration file ``alpino.py`` and add
a section for your server. Use the provided ``startserver_development.sh`` or
``startserver_production.sh`` script to start the server.

Consult the [CLAM](https://proycon.github.io/clam) manual for details regarding
configuration and deployment.





