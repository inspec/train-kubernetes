#!/bin/bash
#
# This script runs a passed in command, but first setups up the bundler caching on the repo

set -ue

export USER="root"
export LANG=C.UTF-8 LANGUAGE=C.UTF-8

# Fetch tokens from vault ASAP so that long-running tests don't cause our vault token to expire
echo "--- installing vault"
export VAULT_VERSION=1.13.0
export VAULT_HOME=$HOME/vault
curl --create-dirs -sSLo $VAULT_HOME/vault.zip https://releases.hashicorp.com/vault/$VAULT_VERSION/vault_${VAULT_VERSION}_linux_amd64.zip
unzip -o $VAULT_HOME/vault.zip -d $VAULT_HOME

if [ -n "${CI_ENABLE_COVERAGE:-}" ]; then
  echo "--- fetching Sonar token from vault"
  export SONAR_TOKEN=$($VAULT_HOME/vault kv get -field token secret/inspec/train-kubernetes/sonar)

  if [ -n "${SONAR_TOKEN:-}" ]; then
    echo "  ++ SONAR_TOKEN set successfully"
  else
    echo "  !! SONAR_TOKEN not set - exiting "
    exit 1 # TODO: Remove this line if we wish not to exit
  fi
fi

echo "--- bundle install"
bundle config --local path vendor/bundle
bundle install --jobs=7 --retry=3

echo "+++ bundle exec task"
bundle exec $@
RAKE_EXIT=$?

#TODO: If coverage is enabled, then we need to pick up the coverage test report. Currently we don't have test for this repo.
if [ -n "${CI_ENABLE_COVERAGE:-}" ]; then
  echo "--- installing sonarscanner"
  export SONAR_SCANNER_VERSION=6.1.0.4477
  export SONAR_SCANNER_HOME=$HOME/.sonar/sonar-scanner-$SONAR_SCANNER_VERSION-linux-x64
  curl --create-dirs -sSLo $HOME/.sonar/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux-x64.zip
  unzip -o $HOME/.sonar/sonar-scanner.zip -d $HOME/.sonar/
  export PATH=$SONAR_SCANNER_HOME/bin:$PATH
  export SONAR_SCANNER_OPTS="-server"

  # Delete the vendor/ directory. I've tried to exclude it using sonar.exclusions,
  # but that appears to get ignored, and we end up analyzing the gemfile install
  # which blows our analysis.
  echo "--- deleting installed gems"
  rm -rf vendor/

  # See sonar-project.properties for additional settings
  echo "--- running sonarscanner"
  sonar-scanner \
  -Dsonar.sources=. \
  -Dsonar.host.url=https://sonar.progress.com
fi

exit $RAKE_EXIT