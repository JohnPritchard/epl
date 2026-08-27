#! /usr/bin/env bash -f

################################################################################
## Definition of functions
usage() {
  printf "\
Usage: ${execName} [-h|Dvnq]

  -h|--help: help
  -D|--debug: debug
  -n|--dryRun: dry-run
  -q|--quiet: quiet
     -q Only Warnings and Errors are written out (to stderr)
     -q -q increases quietness, only Errors are written out (to stderr)
     -q -q -q increases quietness, NO output to stdout or stderr
  -v|--verbose: verbose

  --py) e.g. 3.13
"
  exit ${exstat:-0}
}

################################################################################
## Definition of variable who need default values
execName="`basename ${0}`"
quietLevel=0

################################################################################
## Generic utility functions
if [ -z "${EPL_FUNCTIONS_READLINK}" ]; then
  EPL_FUNCTIONS_READLINK="readlink"
  which greadlink > /dev/null 2>&1 && EPL_FUNCTIONS_READLINK="greadlink"
fi
[ -z "${EPL_FUNCTIONS}" ] && EPL_FUNCTIONS="$(dirname $(${EPL_FUNCTIONS_READLINK} -f ${0}))/epl.functions.sh"
if [ -e ${EPL_FUNCTIONS:-/opt/epl/bin/epl.functions.sh} ]; then
  . ${EPL_FUNCTIONS:-/opt/epl/bin/epl.functions.sh}
else
  echo "${execName}::Error:: ${EPL_FUNCTIONS:-/opt/epl/bin/epl.functions.sh} does NOT exist"
  exit 1
fi
