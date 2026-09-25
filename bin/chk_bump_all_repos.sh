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
  --no_push: do not do a git push at the end of processing

  --force <pkg_name>: comma separated lits of packages to consider, e.g.
        specs/adari_core/adari_core-5.1.0-1.fc43.src.rpm,specs/edps/edps-1.8.1-1.fc43.src.rpm
  --skip_check: no check against SRPMs
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
################################################################################
## Local functions definitions

# -----------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------
do_git_push="true"
################################################################################
## Command line options
while [ ! -z "${1}" ]; do

  case $1 in
    -h|--help)    usage ; shift;;
    -D|--debug)   debug="-D"; quiet=""; vbose="-v";  quietLevel=0 ; shift;;
    -n|--dryRun)  dryRun="-n"; shift;;
    -q|--quiet)   quiet="${quiet} -q"; vbose=""; debug=""; (( quietLevel++ )) ; shift;;
    -v|--verbose) vbose="-v"; quiet="";  quietLevel=0 ; shift;;
    --no_push)    do_git_push="false"; shift;;
    --no_self_update) do_self_update="false"; shift;;
    --force)      force_pkg_name_list="${2}"; shift; shift;;
    --skip_check) do_check=false; shift;;
    *)            exstat=1; usage; shift;;
  esac
done

################################################################################
## Main loop starts...

exstat=0

# Call other template.bash based scripts with command line options:
## ${quiet:+ -q}${dryRun:+ -n}${debug:+ -D}${vbose:+ -v}
# or
##  ${quiet:+ -q}${dryRun:+ -n}${debug:+ -d}${vbose:+ -v}
# for older scripts with "-d" for debug rather than -D

## checkVarIsSet <VAR-NAME> <level> [error-message] [exit-status]
##      <VAR-NAME>: name of variable to check for, no '$'
##         <level>: fatal|fatalNoExit|warn
## [error-message]: Optional Error/Warning message to print
##   [exit-status]: Optional exit status value

cd /opt/epl || exit $?
sudo chown -R macports:macports . || exit $?
sudo chmod -R g+w . || exit $?
[ ${do_self_update:-true} ] && \
    sudo port selfupdate \
    || exit $?
sudo chown -R macports:macports . || exit $?
sudo chmod -R g+w . || exit $?
git pull || exit $?
cd repos/stable || exit $?
bash ../../bin/chk_bump.sh || exit $?
cd ../testing || exit $?
bash ../../bin/chk_bump.sh || exit $?
cd ../devel || exit $?
bash ../../bin/chk_bump.sh || exit $?
sudo port sync || exit $?
sudo chown -R macports:macports . || exit $?
sudo chmod -R g+w . || exit $?

exit ${exstat:-0}
