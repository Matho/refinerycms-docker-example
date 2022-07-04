#!/bin/bash
set -x
set -e
set -o pipefail

./bin/run.symlinks.docker.sh

bundle exec rake db:migrate

service nginx start

bundle exec puma -C config/puma.rb