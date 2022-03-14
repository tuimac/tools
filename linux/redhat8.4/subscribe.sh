#!/bin/bash

sudo subscription-manager register
sudo subscription-manager list --available
sudo subscription-manager subscribe --pool=xxxxxxxxxx
