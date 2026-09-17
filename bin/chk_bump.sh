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
get_latest_fedora_release() {
    curl -1L https://ftp.eso.org/pub/dfs/pipelines/repositories/${release_channel}/fedora/ 2>/dev/null \
        | grep '\[DIR\]' \
        | sed -e 's@^.*href="@@' -e 's@/".*@@' \
        | tail -n 1
}
# -----------------------------------------------------------------------------------
get_srpm_pkg_list() {
    curl -qL https://ftp.eso.org/pub/dfs/pipelines/repositories/${release_channel}/fedora/${fc_latest_release}/src 2>/dev/null \
        | grep '\[DIR\]' \
        | sed -e 's@^.*href="@@' -e 's@/".*@@'
}
# -----------------------------------------------------------------------------------
get_pkg_srpm_list() {
    _pkg_srpm_list_exists=false
    mkdir -pv specs/${pkg_name}/
    [ -e specs/${pkg_name}/pkg_srpm_list ] && _pkg_srpm_list_exists=true
    [ -e /tmp/.$$.${pkg_name}.pkg_srpm_list ] && rm -f /tmp/.$$.${pkg_name}.pkg_srpm_list
    curl -qL https://ftp.eso.org/pub/dfs/pipelines/repositories/${release_channel}/fedora/${fc_latest_release}/src/${pkg_name}/ 2>/dev/null \
        | grep src.rpm \
        | sed -e 's@^.*href="@@' -e 's@".*@@' \
        > /tmp/.$$.${pkg_name}.pkg_srpm_list \
        || exit 1
    add_and_commit=false
    if ${_pkg_srpm_list_exists} ; then
        diff /tmp/.$$.${pkg_name}.pkg_srpm_list specs/${pkg_name}/pkg_srpm_list >/dev/null 2>&1 || add_and_commit=true
    else
        add_and_commit=true
    fi
    if $add_and_commit ; then
        mv /tmp/.$$.${pkg_name}.pkg_srpm_list specs/${pkg_name}/pkg_srpm_list
        git add \
            specs/${pkg_name}/pkg_srpm_list
        git commit \
            -m"${pkg_name}: Updated list of SRPMs" \
            specs/${pkg_name}/pkg_srpm_list
    else
        rm -f /tmp/.$$.${pkg_name}.pkg_srpm_list
    fi
}
# -----------------------------------------------------------------------------------
get_pkg_srpm_contents() {
    mkdir -pv specs/${pkg_name}/$SRPM
    [ -e /tmp/.$$.$SRPM ] && rm -f /tmp/.$$.$SRPM
    curl -qL https://ftp.eso.org/pub/dfs/pipelines/repositories/${release_channel}/fedora/${fc_latest_release}/src/${pkg_name}/${SRPM} 2>/dev/null \
        -o /tmp/.$$.$SRPM
    tar -tvf /tmp/.$$.$SRPM \
        > specs/${pkg_name}/$SRPM/contents
    tar -xf /tmp/.$$.$SRPM \
        -C specs/${pkg_name}/$SRPM \
        \*.spec
    git add \
        specs/${pkg_name}/$SRPM/contents \
        specs/${pkg_name}/$SRPM/*.spec
    git commit \
        -m"${SRPM}: Added contents and spec file" \
        specs/${pkg_name}/$SRPM/contents \
        specs/${pkg_name}/$SRPM/*.spec
    rm -f /tmp/.$$.$SRPM
}
# -----------------------------------------------------------------------------------
get_pkg_srpm_pl_version_from_spec() {
    grep ^\ \*Version: ${new_pkg_version}/*.spec \
        | awk '{print $2}'
}
# -----------------------------------------------------------------------------------
get_pkg_srpm_kit_version_from_spec() {
    grep urlhelper.\*-kit- ${new_pkg_version}/*.spec \
        | sed \
            -e 's@gzip.*$@@' \
            -e 's@.*\(%{version}.*\.tar\.gz\).*@\1@' \
            -e 's@\.tar\.gz@@' \
            -e "s@%{version}@${pl_version}@"
}
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

meye="-i"
something_to_push=false

if [ -z "${SUDO_AS_OWNER}"]; then
    owner=$(ls -ld . | awk '{print $3}')
    if [ "${owner}" != "${USER}" ]; then
        SUDO_AS_OWNER="sudo -u ${owner}"
    fi
fi

if [ -d macports ]; then
    __CWD__=$(pwd)
    release_channel=$(basename "$(pwd)")
    _rc_suffix=${release_channel/stable}
    rc_suffix=${_rc_suffix:+-${_rc_suffix}}
    fc_latest_release=$(get_latest_fedora_release)
    #pkg_list=($(get_srpm_pkg_list))
    #pkg_list=($(get_srpm_pkg_list | head -n 5))
    pkg_list=($(\
        get_srpm_pkg_list \
        | egrep adari_core\|cext\|cpl\|edps\|esopipe-\|esoreflex\|esorex\|hdrl\|molecfit\|pycpl\|pyesorex\|pyhdrl\|telluriccor \
    ))
    #pkg_list=($(\
    #    get_srpm_pkg_list \
    #    | egrep uves \
    #))
    unset new_pkg_versions_list
    if ${do_check:-true} ; then
        i=0
        for pkg_name in ${pkg_list[@]} ; do
            debugLog "Checking ${pkg_name}..."
            unset new_SRPM
            get_pkg_srpm_list
            for SRPM in $(cat specs/${pkg_name}/pkg_srpm_list) ; do
                if [ ! -e specs/${pkg_name}/${SRPM} ]; then
                    get_pkg_srpm_contents
                    new_SRPM=specs/${pkg_name}/${SRPM}
                fi
            done
            if [ ! -z "${new_SRPM}" ]; then
                new_pkg_versions_list[$i]="${new_SRPM}"
                (( i++ ))
            fi
        done
    fi

    if [ "${release_channel}" == "stable" ]; then
        curl -L \
            -o /tmp/mf_exp_ver_reflex_${release_channel}.txt \
            https://ftp.eso.org/pub/usg/molecfit/er/default/reflex_${release_channel}.txt \
            2>/dev/null
        mf_exp_ver_master_sites=$(
            dirname $(
                grep MOLECFIT /tmp/mf_exp_ver_reflex_${release_channel}.txt \
                | awk '{print $3}' \
            )
        )
    fi

    for new_pkg_version in ${new_pkg_versions_list[@]} ${force_pkg_name_list//,/ }; do

        pkg_name=$(basename $(dirname ${new_pkg_version}))
        epl_pkg_name=epl-${pkg_name}${rc_suffix}

        if [ ! -d macports/ports/science/${epl_pkg_name} ]; then
            verboseLog "*** IGNORING ${new_pkg_version} ***"
            continue
        fi

        pkg_name_list=$epl_pkg_name
        is_esoipipe_pkg=false
        if [[ "${pkg_name}" =~ "esopipe" ]]; then
            is_esoipipe_pkg=true
            if \
                [[ ! "${pkg_name}" =~ "datademo" ]] \
                && [[ ! "${pkg_name}" =~ "recipes" ]] \
            ; then
                verboseLog "*** IGNORING ${new_pkg_version} ***"
                continue
            fi
            if [[ "${pkg_name}" =~ "recipes" ]]; then
                pkg_name_list=$(\
                    ls -d1 macports/ports/science/epl-${pkg_name/-recipes}* \
                    | sed -e 's@macports/ports/science/@@' \
                    | grep -v datademo \
                )
            fi
        fi

        verboseLog "*** ${new_pkg_version} ***"
        SRPM=$(basename ${new_pkg_version})
        tar_gz_version=$(\
            grep tar.gz ${new_pkg_version}/contents \
                | sed -e 's@^.*-\([0-9a-z\.-]*\).tar.gz@\1@' \
        )
        pl_version=$(get_pkg_srpm_pl_version_from_spec)
        kit_version=$(get_pkg_srpm_kit_version_from_spec)
        verboseLog "          SRPM=${SRPM}"
        verboseLog "      pkg_name=${pkg_name}"
        verboseLog "tar_gz_version=${tar_gz_version}"
        verboseLog "    pl_version=${pl_version}"
        verboseLog "   kit_version=${kit_version}"

        for epl_pkg_name in $pkg_name_list ; do
            mf_exp_ver_variant=$(\
                port variants ${epl_pkg_name} \
                    | grep mf_exp_ver \
                    | sed \
                        -e 's@.*\[+\]mf_exp_ver.*@-mf_exp_ver@' \
                        -e 's@.*[[:space:]]mf_exp_ver.*@+mf_exp_ver@' \
            )
            variant=default
            variant=${mf_exp_ver_variant}
            #! first check the datademo packages
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
                verboseLog "${epl_pkg_name}"
                unset new_version
                cur_version=$(port -q info --version ${epl_pkg_name})
                #! use port_vercomp
                if [[ ${kit_version:-${pl_version}} != ${cur_version} ]]; then
                    new_version=${kit_version:-${pl_version}}
                fi
                if [ ! -z ${new_version} ]; then
                    for p in macports/ports/science/${epl_pkg_name} ; do
                        verboseLog "*** ${epl_pkg_name} ***"
                        verboseLog "p=${p} ; new_version=${new_version} ; pl_version=${kit_version:-${pl_version}} ; cur_version=${cur_version}"
                        [ ! -z ${debug}" ] && read -p "<Enter> " dummy
                        sudo port clean ${epl_pkg_name}
                        modified_package=true
                        if $is_mf_exp_ver ; then
                            if grep mf_exp_ver_version $p/Portfile >/dev/null 2>&1 ; then
                                sed -i '' \
                                    -e "s@^\([[:space:]]*mf_exp_ver_version[[:space:]][[:space:]]*\).*@\1${new_version}@" \
                                    -e "s@^\([[:space:]]*mf_exp_ver_master_sites[[:space:]][[:space:]]*\).*@\1${mf_exp_ver_master_sites}@" \
                                    $p/Portfile
                                git_commit_msg="${epl_pkg_name}: update to mf_exp_ver=${new_version}"
                            else
                            modified_package=false
                            fi
                        else
                            pl_version=$(echo ${new_version} | sed -e 's@-.*@@')
                            sed -i '' \
                                -e "s@^\(version[[:space:]][[:space:]]*\).*@\1${new_version}@" \
                                -e "s@^\(revision[[:space:]][[:space:]]*\).*@\10@" \
                                -e "s@^\(set[[:space:]][[:space:]]*pl_version[[:space:]][[:space:]]*\).*@\1${pl_version}@" \
                                $p/Portfile
                            git_commit_msg="${epl_pkg_name}: update to ${new_version}"
                        fi
                        if $modified_package ; then
                            sudo port bump ${epl_pkg_name} ${variant/default}
                            git add \
                                $p/Portfile
                            git commit \
                                -m"${git_commit_msg}" \
                                $p/Portfile
                            something_to_push=true                        
                        fi
                        sudo port clean ${epl_pkg_name}
                    done
                fi
            done
        done
    done
    if $do_git_push && $something_to_push ; then
        git push
    fi
else
    errorLog "no macports directory in current directory '$(pwd)'"
fi
exit ${exstat:-0}
