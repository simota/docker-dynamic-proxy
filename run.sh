#!/bin/sh

docker run -d -p 80:80 -p 6379  -t simota/dynamic-proxy /usr/bin/supervisord
