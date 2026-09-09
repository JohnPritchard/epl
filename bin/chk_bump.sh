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
################################################################################
## Local functions definitions
# -----------------------------------------------------------------------------------
get_kit_version() {
    _version=$(
      cat /tmp/reflex_${release_channel}.txt \
        | grep ${_inst}-kit- \
        | sed \
          -e 's@.*[[:space:]]\([^[:space:]]*-kit-[^[:space:]]*\).*@\1@' \
          -e 's@^.*/@@' \
          -e 's@.*-kit-\([0-9a-z\.-]*\).tar.gz@\1@' \
    )
    echo ${_version}
}
# -----------------------------------------------------------------------------------
get_demo_version() {
    _version=$(
      cat /tmp/reflex_${release_channel}.txt \
        | grep ${_inst}-demo- \
        | sed \
          -e 's@.*[[:space:]]\([^[:space:]]*-demo-[^[:space:]]*\).*@\1@' \
          -e 's@^.*/@@' \
          -e 's@.*-demo-reflex-\([0-9a-z\.-]*\).tar.gz@\1@' \
    )
    echo ${_version}
}
# -----------------------------------------------------------------------------------
get_dep_version_from_kit() {
    kit_URL=$(
        curl -L http://www.eso.org/sci/software/pipe_aem_table.html 2>/dev/null \
          | sed -e 's@</td>@\n@g' \
          | grep ${_inst}-kit- \
          | sed -e 's@^.*href="@@' -e 's@".*$@@'
    )
    kit_bn=$(basename "${kit_URL}")
    cmd="curl -qL '${kit_URL}' 2>/dev/null"
    if [ -e "/opt/local/var/macports/distfiles/epl-esopipe-${_inst}_${release_channel}/${kit_bn}" ]; then
        cmd="cat '/opt/local/var/macports/distfiles/epl-esopipe-${_inst}_${release_channel}/${kit_bn}'"
    fi
    _version=$(
        eval ${cmd} \
            | tar -ztvf - \
            | egrep $1 \
            | sed 's@^.*/@@' \
            | sed -e 's@'$1'-\([0-9a-z\.-]*\).tar.*@\1@' \
            | grep -v .tar.gz \
            | grep -v .tar \
    )
    echo ${_version}
}
# -----------------------------------------------------------------------------------
check_pl_and_cpl_versions() {
  release_channel=$1
  __hdr_done=false
  for _inst in $(
    cat /tmp/reflex_${release_channel}.txt \
      | sed \
        -e 's@.*[[:space:]]\([^[:space:]]*-kit-[^[:space:]]*\).*@\1@' \
        -e 's@.*/@@' \
        -e 's@-kit-.*@@' \
  )  ; do
    _kit_version=$(get_kit_version)
    _demo_version=$(get_demo_version)
    # Command to get the CPL version from a PL kit file...
    _cpl_version=$(get_cpl_version_from_kit)
    # cext is included in cpl tar.gz, not as a separate cext-....-.tar.gz file...
    #
    #! Command to get the PL .tar.gz version from a kit file...
    #! _pl_version correctly reported by livecheck on recipe packages...
    _pl_version=$(
      curl -qL $(
        cat /tmp/reflex_${release_channel}.txt \
          | sed \
            -e 's@.*[[:space:]]\([^[:space:]]*-kit-[^[:space:]]*\).*@\1@' \
          | grep ${_inst}-kit- \
      ) 2>/dev/null \
        | tar -ztvf - \
        | grep /${_inst}-\[0-9\] \
        | sed 's@^.*/@@' \
        | sed -e 's@'${_inst}'-\([0-9a-z\.-]*\).tar.gz@\1@' \
        | grep -v .tar.gz \
    )

    if ! ${__hdr_done:-false} ; then
      printf $"%15s  %10s  %10s  %10s  %10s\n" \
        "Instrument" \
        "kit_ver" \
        "demo_ver" \
        "pl_ver" \
        "cpl_ver"
      __hdr_done=true
    fi

    printf "%15s  %10s  %10s  %10s  %10s\n" \
      $_inst \
      $_kit_version \
      $_demo_version \
      $_pl_version \
      $_cpl_version
  done

}
# -----------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------

################################################################################
## Command line options
while [ ! -z "${1}" ]; do

  case $1 in
    -h|--help)    usage ; shift;;
    -D|--debug)   debug="-D"; quiet=""; vbose="-v";  quietLevel=0 ; shift;;
    -n|--dryRun)  dryRun="-n"; shift;;
    -q|--quiet)   quiet="${quiet} -q"; vbose=""; debug=""; (( quietLevel++ )) ; shift;;
    -v|--verbose) vbose="-v"; quiet="";  quietLevel=0 ; shift;;
    -a)           arg="${arg:+$arg }${2}"; shift; shift;;
    -o)           OBXs="${OBXs:+${OBXs} }${2}"; shift; shift;;
    --py)         ESOPIPE_PY_VER="${2}"; shift; shift;;
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

meye="-i"

if [ -d macports ]; then
    D=$(pwd)
    release_channel=$(basename "$(pwd)")

    sudo chown -R macports:wheel .

    curl -L \
        -o /tmp/reflex_${release_channel}.txt \
        https://ftp.eso.org/pub/dfs/pipelines/repositories/${release_channel}/kit/reflex_cfg/reflex_${release_channel}.txt
    curl -L \
        -o /tmp/mf_exp_ver_reflex_${release_channel}.txt \
        https://ftp.eso.org/pub/usg/molecfit/er/default/reflex_${release_channel}.txt
    mf_exp_ver_master_sites=$(
        dirname $(
            grep MOLECFIT /tmp/mf_exp_ver_reflex_${release_channel}.txt \
            | awk '{print $3}' \
        )
    )
    #for _inst in $(
    #    cat /tmp/reflex_${release_channel}.txt \
    #    | sed \
    #        -e 's@.*[[:space:]]\([^[:space:]]*-kit-[^[:space:]]*\).*@\1@' \
    #        -e 's@.*/@@' \
    #        -e 's@-kit-.*@@' \
    #) ; do
    for _inst in $(
        curl -L http://www.eso.org/sci/software/pipe_aem_table.html 2>/dev/null \
            | sed -e 's@</td>@\n@g' \
            | grep href.\*-kit- \
            | sed \
                -e 's@^.*href="@@'\
                -e 's@".*$@@' \
                -e 's@.*/@@' \
                -e 's@-kit-.*@@' \
    )  ; do
        continue
    done
    for _inst in $(\
        ls -d macports/ports/science/epl-esopipe-*-recipes \
            | sed -e 's@^.*esopipe-@@' -e 's@-recipes@@' \
    ) ; do
        echo "*** ${_inst} ***"
        mf_exp_ver_variant=$(\
            port variants epl-esopipe-${_inst}-recipes \
                | grep mf_exp_ver \
                | sed \
                    -e 's@.*\[+\]mf_exp_ver.*@-mf_exp_ver@' \
                    -e 's@.*[[:space:]]mf_exp_ver.*@+mf_exp_ver@' \
        )
        variant=default
        variant=${mf_exp_ver_variant}
        #! first check the datademo packages
        for variant in default ; do
            sudo port clean epl-esopipe-${_inst}-datademo
            echo "epl-esopipe-${_inst}-datademo"
            new_version=$( \
                port livecheck epl-esopipe-${_inst}-datademo ${variant/default} 2>&1 \
                    | grep 'new version' \
                    | sed -e 's@^.* new version: @@' -e 's@).*$@@' \
            )
            if [ ! -z ${new_version} ]; then
                for p in $(ls -1d macports/ports/science/*esopipe-${_inst}* 2>/dev/null | grep datademo) ; do
                    echo "*** $(basename $p) ***"
                    modified_package=true
                    if $is_mf_exp_ver ; then
                        if grep mf_exp_ver_version $p/Portfile >/dev/null 2>&1 ; then
                            sudo -u macports sed -i '' \
                                -e "s@^\([[:space:]]*mf_exp_ver_version[[:space:]][[:space:]]*\).*@\1${new_version}@" \
                                -e "s@^\([[:space:]]*mf_exp_ver_master_sites[[:space:]][[:space:]]*\).*@\1${mf_exp_ver_master_sites}@" \
                                $p/Portfile
                            git_commit_msg="$(basename $p): update to mf_exp_ver=${new_version}"
                        else
                          modified_package=false
                        fi
                    else
                        pl_version=$(echo ${new_version} | sed -e 's@-.*@@')
                        sudo -u macports sed -i '' \
                            -e "s@^\(version[[:space:]][[:space:]]*\).*@\1${new_version}@" \
                            -e "s@^\(revision[[:space:]][[:space:]]*\).*@\10@" \
                            -e "s@^\(set[[:space:]][[:space:]]*pl_version[[:space:]][[:space:]]*\).*@\1${pl_version}@" \
                            $p/Portfile
                        git_commit_msg="$(basename $p): update to ${new_version}"
                    fi
                    if $modified_package ; then
                        sudo port bump $(basename $p) ${variant/default}
                        sudo -u macports \
                            git add \
                                $p/Portfile
                        sudo -u macports \
                            git commit \
                                -m"${git_commit_msg}" \
                                $p/Portfile
                    fi
                    sudo port clean $(basename $p)
                done
            fi
        done
        #! now all the others...
        for variant in default ${mf_exp_ver_variant} ; do
            is_mf_exp_ver=false
            if [ ! -z "${mf_exp_ver_variant}" ]; then
                if [ "${mf_exp_ver_variant:0:1}" == "+" ]; then
                    if [ "${variant}" != "default" ]; then
                        is_mf_exp_ver=true
                    fi
                else
                    if [ "${variant}" == "default" ]; then
                        is_mf_exp_ver=true
                    fi
                fi
            fi
            sudo port clean epl-esopipe-${_inst}-recipes
            echo "epl-esopipe-${_inst}-recipes"
            new_version=$( \
                port livecheck epl-esopipe-${_inst}-recipes ${variant/default} 2>&1 \
                    | grep 'new version' \
                    | sed -e 's@^.* new version: @@' -e 's@).*$@@' \
            )
            if [ ! -z ${new_version} ]; then
                for p in $(ls -1d macports/ports/science/*esopipe-${_inst}* 2>/dev/null | grep -v datademo) ; do
                    echo "*** $(basename $p) ***"
                    modified_package=true
                    if $is_mf_exp_ver ; then
                        if grep mf_exp_ver_version $p/Portfile >/dev/null 2>&1 ; then
                            sudo -u macports sed -i '' \
                                -e "s@^\([[:space:]]*mf_exp_ver_version[[:space:]][[:space:]]*\).*@\1${new_version}@" \
                                -e "s@^\([[:space:]]*mf_exp_ver_master_sites[[:space:]][[:space:]]*\).*@\1${mf_exp_ver_master_sites}@" \
                                $p/Portfile
                            git_commit_msg="$(basename $p): update to mf_exp_ver=${new_version}"
                        else
                          modified_package=false
                        fi
                    else
                        pl_version=$(echo ${new_version} | sed -e 's@-.*@@')
                        sudo -u macports sed -i '' \
                            -e "s@^\(version[[:space:]][[:space:]]*\).*@\1${new_version}@" \
                            -e "s@^\(revision[[:space:]][[:space:]]*\).*@\10@" \
                            -e "s@^\(set[[:space:]][[:space:]]*pl_version[[:space:]][[:space:]]*\).*@\1${pl_version}@" \
                            $p/Portfile
                        git_commit_msg="$(basename $p): update to ${new_version}"
                    fi
                    if $modified_package ; then
                        sudo port bump $(basename $p) ${variant/default}
                        sudo -u macports \
                            git add \
                                $p/Portfile
                        sudo -u macports \
                            git commit \
                                -m"${git_commit_msg}" \
                                $p/Portfile
                    fi
                    sudo port clean $(basename $p)
                done
                # So by now we should have downloaded the kit file, which we can use to check the CPL and esorex versions in...
                for _dep in \
                    cpl \
                    esorex \
                    telluriccorr \
                    molecfit_third_party \
                ; do
                    new_version=$(get_dep_version_from_kit $_dep)
                    if [ ! -z "${new_version}" ]; then
                        p=macports/ports/science/epl-${_dep}
                        if ! grep version[[:space:]][[:space:]]\*$new_version ${p}/Portfile >/dev/null 2>&1 ; then
                            sudo -u macports sed -i '' \
                                -e "s@^\(version[[:space:]][[:space:]]*\).*@\1${new_version}@" \
                                -e "s@^\(revision[[:space:]][[:space:]]*\).*@\10@" \
                                -e "s@^\(set[[:space:]][[:space:]]*pl_version[[:space:]][[:space:]]*\).*@\1${pl_version}@" \
                                $p/Portfile
                            git_commit_msg="$(basename $p): update to ${new_version}"
                            sudo port bump $(basename $p)
                            sudo -u macports \
                                git add \
                                    $p/Portfile
                            sudo -u macports \
                                git commit \
                                    -m"${git_commit_msg}" \
                                    $p/Portfile
                            sudo port clean $(basename $p)
                        fi
                    fi
                done
                for _dep in \
                    cext \
                ; do
                    new_version=$( \
                        port livecheck epl-${_dep} 2>&1 \
                            | grep 'new version' \
                            | sed -e 's@^.* new version: @@' -e 's@).*$@@' \
                    )
                    if [ ! -z "${new_version}" ]; then
                        p=macports/ports/science/epl-${_dep}
                        if ! grep version[[:space:]][[:space:]]\*$new_version ${p}/Portfile >/dev/null 2>&1 ; then
                            sudo -u macports sed -i '' \
                                -e "s@^\(version[[:space:]][[:space:]]*\).*@\1${new_version}@" \
                                -e "s@^\(revision[[:space:]][[:space:]]*\).*@\10@" \
                                -e "s@^\(set[[:space:]][[:space:]]*pl_version[[:space:]][[:space:]]*\).*@\1${pl_version}@" \
                                $p/Portfile
                            git_commit_msg="$(basename $p): update to ${new_version}"
                            sudo port bump $(basename $p)
                            sudo -u macports \
                                git add \
                                    $p/Portfile
                            sudo -u macports \
                                git commit \
                                    -m"${git_commit_msg}" \
                                    $p/Portfile
                            sudo port clean $(basename $p)
                        fi
                    fi
                done
            fi
        done
    done
    #sudo chown -R macports:wheel .
else
    errorLog "no macports directory in current directory '$(pwd)'"
fi
exit ${exstat:-0}
