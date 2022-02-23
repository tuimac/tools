#!/bin/bash

sudo pcs cluster auth primary secondary -u hacluster
sudo pcs cluster setup --name mycluster primary secondary
sudo pcs cluster start --all
sudo pcs cluster enable --all
