#!/bin/bash
if [ ! -z $VIRTUAL_ENV ]; then; 
    uwsgi --plugin python3 --virtualenv $VIRTUAL_ENV --socket 127.0.0.1:8888 --chdir $VIRTUAL_ENV --wsgi-file /tmp/alpino/alpino.wsgi --logto alpino.uwsgi.log --log-date --log-5xx --master --processes 2 --threads 2 --need-app
else 
    uwsgi --plugin python3 --socket 127.0.0.1:8888 --wsgi-file /tmp/alpino/alpino.wsgi --logto alpino.uwsgi.log --log-date --log-5xx --master --processes 2 --threads 2 --need-app
fi
