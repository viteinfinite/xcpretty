#!/bin/bash
source "$HOME/.rvm/scripts/rvm"
rvm use 2.0.0

gem build xcpretty.gemspec

gem uninstall xcpretty -v 0.1.6
gem install xcpretty-0.1.6.gem 

cd /Users/civetta/Works/Xebia/pab/code/
rm build/reports/*
./scripts/Jenkins-KIF.sh
open build/reports

cd /Users/civetta/Works/Personal/xcpretty/
