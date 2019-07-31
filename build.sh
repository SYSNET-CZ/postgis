#!/usr/bin/env bash
docker build -t sysnetcz/postgis:manual-build .
docker build -t sysnetcz/postgis:11.0-2.5 .
docker build -t sysnetcz/postgis:9.6-2.5 .
