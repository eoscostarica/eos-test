#!/usr/bin/env bash
services=$(docker ps | grep "issue/" | awk '{print $1}')

if [[ ! -z "$services" ]]; then
  docker stop $services
fi
