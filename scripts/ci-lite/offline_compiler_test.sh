#!/usr/bin/env bash
set -ex -o pipefail

# These ones can be `npm link`ed for fast development
LINKABLE_PKGS=(
  $(pwd)/dist/packages-dist/{common,core,compiler,compiler_cli,platform-{browser,server}}
  $(pwd)/dist/tools/@angular/tsc-wrapped
)
PKGS=(
  reflect-metadata
  typescript@next
  zone.js
  rxjs
  @types/{node,jasmine}
  jasmine
)

TMPDIR=${TMPDIR:-.}
readonly TMP=$TMPDIR/e2e_test.$(date +%s)
mkdir -p $TMP
cp -R -v modules/@angular/compiler_cli/integrationtest/* $TMP
# Try to use the same versions as angular, in particular, this will
# cause us to install the same rxjs version.
cp -v package.json $TMP

# run in subshell to avoid polluting cwd
(
  cd $TMP
  npm install ${PKGS[*]}
  # TODO(alexeagle): allow this to be npm link instead
  npm install ${LINKABLE_PKGS[*]}

  # Compile the compiler_cli integration tests
  ./node_modules/.bin/ngc

  ./node_modules/.bin/jasmine init
  # Run compiler_cli integration tests in node
  ./node_modules/.bin/jasmine test/*_spec.js
)
