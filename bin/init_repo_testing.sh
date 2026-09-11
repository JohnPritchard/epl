cd $HOME/src/git/epl
cd repos/testing
cd macports
mkdir -pv setup
[ ! -e setup/Portfile ] && \
    curl -Lo setup/Portfile \
        https://ftp.eso.org/pub/dfs/pipelines/repositories/testing/macports/setup/Portfile
[ ! -e ports.tar ] && curl -LO https://ftp.eso.org/pub/dfs/pipelines/repositories/testing/macports/ports.tar
[ -d ports ] && rm -fr ports
tar -xf ports.tar 
rm -fr ports/{PortIndex,devel,lang,python,x11}*
rm -fr ports/science/eso-*
rsync -a $(port dir cfitsio) ports/science/
cd ..
../../bin/isolate_esopipes --py 3.13
rsync --delete -aHAXtUN macports/ macports.isolate_esopipes/
rsync --delete -aHAXtUN macports.isolate_esopipes/ macports/
cd macports/ports
for F in */* ; do mv -v $F $(dirname $F)/epl-$(basename $F)-testing ; done
sed -i '' \
    -e 's@^\([[:space:]]*\)\(revision\)\([[:space:]][[:space:]]*\)\([^[:space:]]*\)@\1\2\3\4\n\1name   cfitsio\nset __prefix  ${prefix}\nset prefix    ${__prefix}/libexec/epl/testing@' \
    science/epl-cfitsio-testing/Portfile
sed -i '' \
    -e 's@^\([[:space:]]*\)\(name\)\([[:space:]][[:space:]]*\)\([^[:space:]]*\)@\1\2\3epl-\4-testing\n\1set __name \4@' \
    -e 's@/libexec/eso/@/libexec/epl/@' \
    -e 's@--with-cfitsio=${__prefix}@--with-cfitsio=${prefix}@' \
    -e 's@^\([[:space:]]*\)\(master_sites[[:space:]].*\)${name}@\1\2\${__name}@' \
    -e 's@port:cfitsio@port:epl-cfitsio-testing@g' \
    -e 's@port:cext@port:epl-cext-testing@g' \
    -e 's@port:cpl@port:epl-cpl-testing@g' \
    -e 's@port:adari@port:epl-adari-testing@g' \
    -e 's@port:edps@port:epl-edps-testing@g' \
    -e 's@port:\(eso[^[:space:]]+\)\( *\)@port:epl-\1-testing\2@g' \
    -e 's@port:molecfit_third_party@port:epl-molecfit_third_party-testing@g' \
    -e 's@port:telluriccorr@port:epl-telluriccorr-testing@g' \
    -e 's@${destroot}${__prefix}/bin/eso@${destroot}${__prefix}/bin/epl-eso@' \
    -e 's@\(dist_subdir[[:space:]]\)\(esopipe\)@\1epl-\2@' \
    */*/Portfile
sed -i '' \
    -e 's@--with-cfitsio=${prefix}@--with-cfitsio=${__prefix}@' \
    */epl-cpl-testing/Portfile
sed -i '' \
    -e 's@\(livecheck.regex.*\)kit@\1demo-reflex@' \
    */epl-esopipe-*-datademo-testing/Portfile
for F in */*/Portfile ; do
    ! grep ^\ \*distname $F >/dev/null \
    && sed -i '' \
        -e 's@^\([[:space:]]*\)\(master_sites\)\([[:space:]][[:space:]]*\)\([^[:space:]]*\)@\1\2\3\4\n\1distname\3${__name}-${version}@' \
        $F
done
cd ../..
for F in macports/ports/*/*-{datastatic,recipes,wkf}-testing/Portfile ; do
    if ! grep ^set\ \*pl_version $F >/dev/null ; then
        echo $F
        pl_version=$(grep ^version $F | awk '{print $2}' | sed -e 's@-.*@@')
        sudo sed -i '' \
            -e 's@^\(version\)@set pl_version '${pl_version}'\n&@' \
            -e 's@${instrument}-${version}@${instrument}-${pl_version}@g' \
            -e 's@${instrument}-calib-${version}@${instrument}-calib-${pl_version}@g' \
            $F
    fi
done
sudo sed -i '' \
    -e 's@^\(distfiles[[:space:]][[:space:]]*\).*@\1${__name}-${version}.tar@' \
    macports/ports/science/epl-molecfit_third_party-testing/Portfile
