cd /Users/jpritcha/src/git/epl
cd repos/stable
cd macports
sudo chown -R jpritcha:users .
[ ! -e ports.tar ] && curl -LO https://ftp.eso.org/pub/dfs/pipelines/repositories/stable/macports/ports.tar
[ -d ports ] && sudo rm -fr ports
tar -xf ports.tar 
rm -fr ports/{PortIndex,devel,lang,python,x11}*
rm -fr ports/science/eso-*
rsync -a $(port dir cfitsio) ports/science/
cd ..
../../bin/isolate_esopipes --py 3.13
sudo rsync --delete -aHAXtUN macports/ macports.isolate_esopipes/
sudo rsync --delete -aHAXtUN macports.isolate_esopipes/ macports/
cd macports/ports
for F in */* ; do mv -v $F $(dirname $F)/epl-$(basename $F) ; done
sed -i '' \
    -e 's@^\([[:space:]]*\)\(revision\)\([[:space:]][[:space:]]*\)\([^[:space:]]*\)@\1\2\3\4\n\1name   cfitsio\nset __prefix  ${prefix}\nset prefix    ${__prefix}/libexec/epl/stable@' \
    science/epl-cfitsio/Portfile
sed -i '' \
    -e 's@^\([[:space:]]*\)\(name\)\([[:space:]][[:space:]]*\)\([^[:space:]]*\)@\1\2\3epl-\4\n\1set __name \4@' \
    -e 's@/libexec/eso/@/libexec/epl/@' \
    -e 's@--with-cfitsio=${__prefix}@--with-cfitsio=${prefix}@' \
    -e 's@^\([[:space:]]*\)\(master_sites[[:space:]].*\)${name}@\1\2\${__name}@' \
    -e 's@port:cfitsio@port:epl-cfitsio@g' \
    -e 's@port:cext@port:epl-cext@g' \
    -e 's@port:cpl@port:epl-cpl@g' \
    -e 's@port:adari@port:epl-adari@g' \
    -e 's@port:edps@port:epl-edps@g' \
    -e 's@port:eso@port:epl-eso@g' \
    -e 's@port:molecfit@port:epl-molecfit@g' \
    -e 's@port:telluricccor@port:epl-telluricccor@g' \
    -e 's@${destroot}${__prefix}/bin/eso@${destroot}${__prefix}/bin/epl-eso@' \
    -e 's@\(dist_subdir[[:space:]]\)\(esopipe\)@\1epl-\2@' \
    */*/Portfile
sed -i '' \
    -e 's@\(livecheck.regex.*\)kit@\1demo-reflex@' \
    */epl-esopipe-*-datademo/Portfile
for F in */*/Portfile ; do
    ! grep ^\ \*distname $F >/dev/null \
    && sed -i '' \
        -e 's@^\([[:space:]]*\)\(master_sites\)\([[:space:]][[:space:]]*\)\([^[:space:]]*\)@\1\2\3\4\n\1distname\3${__name}-${version}@' \
        $F
done
sudo chown -R macports:wheel .
cd ../..
sudo -u macports portindex macports/ports
for p in $( \
    grep -l mf_exp_ver macports/ports/science/*/Portfile \
) ; do
    P=$(basename $(dirname $p))
    sudo port clean $P
    sudo port bump $P +mf_exp_ver
    sudo port clean $P
done
bash ../../bin/chk_bump.sh
sudo -u macports portindex macports/ports
