#!/bin/sh
#ufw allow 23002/tcp
ufw allow proto tcp from 150.69.0.0/16 to any port 23002
