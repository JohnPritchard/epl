## "@(#) $Id: epl.functions.sh 5014 2025-02-01 17:05:13Z jpritcha $"

################################################################################
## Provides:

#  checkVarIsSet()
#  countdown() <secs>
#  datetime()
#  dbgCont()
#  debugLog()
#  errorLog()
#  execCmd()
#  execCmdDebug()
#  execCmdDryRun()
#  execCmdIgnoreDryRun()
#  execCmdExitOnError()
#  execCmdExitOnErrorIgnoreDryRun()
#  notQuietLog()
#  setDebug()
#  setDryRun()
#  setQuiet()
#  setVbose()
#  toUseTheseFunction()
#  verboseLog()
#  warningLog()

################################################################################
## To Use insert the contents of the following funtion in the script:

toUseTheseFunction() {
################################################################################
## Generic utility functions
if [ -z "${EPL_FUNCTIONS_READLINK}" ]; then
  EPL_FUNCTIONS_READLINK="readlink"
  which greadlink > /dev/null 2>&1 && EPL_FUNCTIONS_READLINK="greadlink"
  if ! ${EPL_FUNCTIONS_READLINK} -f ${0} >/dev/null 2>&1 ; then
    echo "${EPL_FUNCTIONS_READLINK} does not support -f command line option"
    exit 1
  fi
fi
[ -z "${EPL_FUNCTIONS}" ] && EPL_FUNCTIONS="$(ls $(dirname $(${EPL_FUNCTIONS_READLINK} -f \"${0}\"))/epl.functions.sh 2>/dev/null)"
if [ -e ${EPL_FUNCTIONS:-/opt/epl/bin/epl.functions.sh} ]; then
  . ${EPL_FUNCTIONS:-/opt/epl/bin/epl.functions.sh}
else
  echo "${execName}::Error:: ${EPL_FUNCTIONS:-/opt/epl/bin/epl.functions.sh} does NOT exist"
  exit 1
fi
# ------------------------------------------------------------------------------
}

################################################################################
## Make sure the relevant directory is in the PATH
if [ -z "${EPL_FUNCTIONS_READLINK}" ]; then
  EPL_FUNCTIONS_READLINK="readlink"
  which greadlink > /dev/null 2>&1 && EPL_FUNCTIONS_READLINK="greadlink"
fi
canonical_exec=$(${EPL_FUNCTIONS_READLINK} -f "${0}" 2>/dev/null)
if [ ! -z "${canonical_exec}" ]; then
  execPATH=$(dirname "${canonical_exec}")
  if [[ ! "${PATH}" =~ "${execPATH}" ]]; then
    export PATH=${execPATH}:${PATH}
  fi
fi

################################################################################
## Useful environment variables
if [ -z "${EPL_FUNCTIONS_DATE}" ]; then
  EPL_FUNCTIONS_DATE="date"
  which gdate > /dev/null 2>&1 && EPL_FUNCTIONS_DATE="gdate"
  export EPL_FUNCTIONS_DATE
fi
if [ -z "${EPL_FUNCTIONS_SED}" ]; then
  EPL_FUNCTIONS_SED="sed"
  which gsed > /dev/null 2>&1 && EPL_FUNCTIONS_SED="gsed"
  export EPL_FUNCTIONS_SED
fi
SED="sed"
which ssed > /dev/null 2>&1 && SED="ssed"

################################################################################
verboseLog() {
  if [ ! -z "${vbose}" ]
  then
    echo "${execName}:: $1" >> ${2:-/dev/stdout}
  fi
}

################################################################################
debugLog() {
  if [ ! -z "${debug}" ]
  then
    echo "${execName}::debug:: $1" >> ${2:-/dev/stdout}
  fi
}

################################################################################
notQuietLog() {
  if [ -z "${quiet}" ]
  then
    echo "${execName}:: $1" >> ${2:-/dev/stdout}
  fi
}

################################################################################
errorLog() {
  if [ ${quietLevel:-0} -lt 3 ]
  then
    echo "${execName}::Error:: $1" >> ${2:-/dev/stderr}
  fi
}

################################################################################
warningLog() {
  if [ ${quietLevel:-0} -lt 2 ]
  then
    echo "${execName}::Warning:: $1" >> ${2:-/dev/stderr}
  fi
}

################################################################################
execCmd() {
  if [ ! -z "${debug}" ] || [ ! -z "${dryRun}" ] || [ ! -z "${ECdebug}" ] || [ ! -z "${ECdryRun}" ] && [ -z "${quiet}" ]
  then
    echo "${execName}::execCmd:: $1"
  fi
  unset execCmd_PIPESTATUS
  if [ -z "${dryRun}"  ] && [ -z "${ECdryRun}" ] || ${ignoreDryRun:-false}
  then
    unsetIgnoreDryRun="${ignoreDryRun:-true}"
    unset ignoreDryRun
    local i=0 S
    if echo "${1}" | grep '&[[:space:]]*$' >/dev/null 2>&1 ; then
      echo eval "${1}"
      return 0
    else
      eval "${1} ; for S in \${PIPESTATUS[@]} ; do execCmd_PIPESTATUS[\$i]=\$S ; (( i++ )) ; done"
    fi
    ${unsetIgnoreDryRun:-false} && unset ignoreDryRun
    return ${execCmd_PIPESTATUS[((${#execCmd_PIPESTATUS[@]}-1))]}
  fi
  execCmd_PIPESTATUS=0
  return 0
}

################################################################################
execCmdDebug() {
  ECdebug="--debug"
  execCmd "${1}"
  retval=$?
  unset ECdebug
  return $retval
}

################################################################################
execCmdDryRun() {
  ECdryRun="--dryRun"
  execCmd "${1}"
  retval=$?
  unset ECdryRun
  return $retval
}

################################################################################
execCmdIgnoreDryRun() {
  unsetIgnoreDryRun="${ignoreDryRun:-true}"
  ignoreDryRun="true"
  execCmd "${1}"
  retval=$?
  ${unsetIgnoreDryRun:-false} && unset ignoreDryRun
  return $retval
}

################################################################################
execCmdExitOnErrorIgnoreDryRun() {
  unsetIgnoreDryRun="${ignoreDryRun:-true}"
  ignoreDryRun="true"
  execCmdExitOnError "${1}"
  retval=$?
  ${unsetIgnoreDryRun:-false} && unset ignoreDryRun
  return $retval
}
################################################################################
execCmdExitOnError() {
  execCmd "${1}"
  local i=1 j S estat=0
  for S in ${execCmd_PIPESTATUS[@]} ; do
    if [ $S -ne 0 ]; then
      if [ ${#execCmd_PIPESTATUS[@]} -gt 1 ]; then
        unset preDel postDel 
        (( j=i+1 ))
        (( k=i-1 ))
        [ $i -gt 1 ] && preDel=" -e 1,${k}d"
        [ $i -lt ${#execCmd_PIPESTATUS[@]} ] && postDel=" -e ${j},${#execCmd_PIPESTATUS[@]}d"
        errorLog "'$(echo ${1} | tr '|' '\n' | sed${preDel}${postDel} -e 's/^ *//' -e 's/ *$//')', exited with status $S"
      else
        errorLog "'${1}' failed, exited with status $S"
      fi
      estat=$S
      (( i++ ))
    fi
  done
  [ $estat -ne 0 ] && exit $estat
}

################################################################################
## Usage:
## checkVarIsSet <VAR-NAME> <level> [error-message] [exit-status]
##      <VAR-NAME>: name of variable to check for, no '$'
##         <level>: fatal|fatalNoExit|warn
## [error-message]: Optional Error/Warning message to print
##   [exit-status]: Optional exit status value
##
checkVarIsSet(){
  v1="$`echo $1`"
  v2="`eval echo $v1`"
  debugLog "Variable $1 is set to $v2"
  if [ -z "${v2}" ]
  then
    debugLog "Variable $1 is not set"
    case $2 in
      fatal)       errorLog   "${3:-Variable $1 not set}"; exstat=${4:-1} ; usage ;;
      fatalNoExit) errorLog   "${3:-Variable $1 not set}"; (( exstat=${exstat-0}+${4:-1} ));;
      warn)        warningLog "${3:-Variable $1 not set}";;
      *)           errorLog   "*** Coding error:: error-level not recognised"; exit 1
    esac
  else
    debugLog "Variable $1 is set to $v2"
  fi
}
################################################################################
setDebug() {
  debug="-D"
}
################################################################################
setVbose() {
  vbose="-v"
}
################################################################################
setQuiet() {
  quiet="-q"
}
################################################################################
setDryRun() {
  debug="-D"
  dryRun="-n"
}
################################################################################
countdown(){
   (( date1=$(${EPL_FUNCTIONS_DATE} +%s) + $1)); 
   while [[ $date1 -gt $(${EPL_FUNCTIONS_DATE} +%s) ]]; do 
     echo -ne "$(${EPL_FUNCTIONS_DATE} -u --date @$(($date1 - $(${EPL_FUNCTIONS_DATE} +%s))) +%H:%M:%S)\r";
     sleep 0.2
   done
}
################################################################################
elapsed_time() {
  python -c "import datetime ; print(datetime.timedelta(seconds=(${2}-${1})))"
}
################################################################################
dbgCont() {
  [ ! -z "${debug}" ] && read -p "Continue ? " dummy
}
################################################################################
datetime() {
  ${EPL_FUNCTIONS_DATE} +%Y-%m-%dT%H:%M:%S
}
################################################################################
