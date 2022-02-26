#!/bin/bash

sudo pcs host auth primary secondary -u hacluster
sudo pcs cluster setup test primary secondary
sudo pcs cluster enable --all
sudo pcs cluster start --all
sleep 3
sudo pcs status
