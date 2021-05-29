#!/bin/bash

sudo killall -HUP mDNSResponder
sudo mount -uw /
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.mDNSresponder.plist
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.mDNSresponder.plist
