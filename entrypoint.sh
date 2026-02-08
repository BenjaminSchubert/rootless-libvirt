#!/bin/bash

set -eux

sudo mkdir /run/dbus
sudo dbus-daemon --system --nofork &
sudo libvirtd &

exec "$@"
