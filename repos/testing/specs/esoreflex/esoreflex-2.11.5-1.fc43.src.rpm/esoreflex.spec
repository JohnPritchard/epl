Name: esoreflex
Version: 2.11.5
Release: 1%{?dist}
Summary: Reflex environment to execute ESO pipelines
Group: Applications/Scientific
License: GPLv2+ and ASL 1.1 and ASL 2.0 and ASL-like and BSD and BSD-style and CDDL and CPL and CC BY-NC-SA 3.0 and Custom and EPL and ICU and JDL and LGPLv2+ and MIT and Public Domain and WSDP-1.5
Vendor: European Southern Observatory
Packager: ESO <usd-help@eso.org>
URL: http://www.eso.org/sci/software/reflex

Source0: https://ftp.eso.org/pub/dfs/reflex/%{name}-%{version}.tar.gz
Source1: esoreflex_set_memory
Source2: esoreflex.rc

Requires: esorex >= 3.12
Requires: java-11-openjdk >= 11
Requires: python3 >= 2.6
Requires: xterm

%description
Reflex is an environment that provides an easy and flexible way to reduce
VLT/VLTI science data using the ESO pipelines.

# No sensible debuginfo can be generated since this is Java code, so disable.
%global debug_package %{nil}

%define worksrcpath %{_builddir}/%{name}-%{version}
%define targetname %{name}-%{version}

%prep
%setup -q -n %{name}-%{version}
cp %{SOURCE1} %{worksrcpath}/%{name}/bin

%build
# The following libraries are removed since they were causing some errors
rm %{worksrcpath}/common/lib/libproj.so
rm %{worksrcpath}/common/lib/libgarp.so
rm %{worksrcpath}/common/lib/libgdalactor.so
rm %{worksrcpath}/common/lib/libgisbuffer.so
rm %{worksrcpath}/common/lib/libgishull.so
rm %{worksrcpath}/common/lib/libgisraster.so
rm %{worksrcpath}/common/lib/libptmatlab.so
rm %{worksrcpath}/common/lib/libclib_jiio.so
rm %{worksrcpath}/common/lib/libgeos.so.2
rm %{worksrcpath}/common/lib64/libptmatlab.so
rm %{worksrcpath}/ptolemy/src/lib/libptmatlab.so
rm %{worksrcpath}/ptolemy/src/lib/libJNIFMU.so
rm %{worksrcpath}/r/lib/libjri.so
# The install path has to be changed because otherwise Reflex tries to change it
# and will fail because the file is owned by root.
echo '%{_datadir}/%{targetname}' > %{worksrcpath}/build-area/install-path.txt
# The following two commands uncomment the _alternateDefaultOpenDirectory property and set it to the worflow path under share/.
sed -i "s|<!--[[:space:]]*\(property[[:space:]][[:space:]]*name=\"_alternateDefaultOpenDirectory\"\).*|<\1 value=\"%{_datadir}/reflex/workflows\"|" \
    %{worksrcpath}/common/configs/ptolemy/configs/kepler/configuration.xml
sed -i "s|\(class[[:space:]]*=[[:space:]]*\"ptolemy[].]kernel[].]util[].]StringAttribute\"[[:space:]]*\)/[[:space:]]*-->|\1 />|" \
    %{worksrcpath}/common/configs/ptolemy/configs/kepler/configuration.xml
# Set the installation path in various configuration files.
sed -i "s|^ESOREFLEX_BASE=.*$|ESOREFLEX_BASE=\"%{_datadir}/%{targetname}\"|g" %{worksrcpath}/esoreflex/bin/esoreflex
sed -i "s|^ESOREFLEX_WORKFLOW_PATH=.*$|ESOREFLEX_WORKFLOW_PATH=\"%{_datadir}/reflex/workflows\":~/KeplerData/workflows/MyWorkflows|g" %{worksrcpath}/esoreflex/bin/esoreflex
sed -i "s|^LOAD_ESOREX_CONFIG=.*$|LOAD_ESOREX_CONFIG=\"%{_sysconfdir}/esorex.rc\"|g" %{worksrcpath}/esoreflex/bin/esoreflex
sed -i "s|^LOAD_ESOREX_RECIPE_CONFIG=.*$|LOAD_ESOREX_RECIPE_CONFIG=\"%{_sysconfdir}/esoreflex_default_recipe_config.rc\"|g" %{worksrcpath}/esoreflex/bin/esoreflex
sed -i "s|^ESOREFLEX_SYSTEM_RC=.*$|ESOREFLEX_SYSTEM_RC=\"%{_sysconfdir}/esoreflex.rc\"|g" %{worksrcpath}/esoreflex/bin/esoreflex
sed -i "s|^ESOREFLEX_BASE=.*$|ESOREFLEX_BASE=\"%{_datadir}/%{targetname}\"|g" %{worksrcpath}/esoreflex/bin/esoreflex_set_memory

%install
rm -rf %{buildroot}
install -m 755 -d %{buildroot}%{_datadir}
# Copy the source tree preserving the timestamps in case Kepler tries to rebuild
# anything based on them. We do update the ownership of the files though.
cp -a %{worksrcpath} %{buildroot}%{_datadir}/%{targetname}
install -m 755 -d %{buildroot}%{_bindir}
ln -s %{_datadir}/%{targetname}/esoreflex/bin/esoreflex %{buildroot}%{_bindir}/esoreflex
ln -s %{_datadir}/%{targetname}/esoreflex/bin/esoreflex_set_memory %{buildroot}%{_bindir}/esoreflex_set_memory
install -m 755 -d %{buildroot}%{_sysconfdir}
install -m 644 %{SOURCE2} %{buildroot}%{_sysconfdir}
echo '# No default parameters should be specified for recipes under Reflex.' > %{buildroot}%{_sysconfdir}/esoreflex_default_recipe_config.rc
sed -i "s|@@JAVA@@|/usr/lib/jvm/jre-11-openjdk/bin/java|g" %{buildroot}%{_sysconfdir}/esoreflex.rc
sed -i "s|@@VERSION@@|%{version}|g" %{buildroot}%{_sysconfdir}/esoreflex.rc
sed -i "s|@@SYS_CONFIG_DIR@@|%{_sysconfdir}|g" %{buildroot}%{_sysconfdir}/esoreflex.rc
sed -i "s|@@SHARE_DIR@@|%{_datadir}|g" %{buildroot}%{_sysconfdir}/esoreflex.rc
sed -i "s|@@ESOREFLEX_BASE@@|%{_datadir}/%{targetname}|g" %{buildroot}%{_sysconfdir}/esoreflex.rc
sed -i "s|esoreflex\.python-command=.*|esoreflex.python-command=/usr/bin/python3|g" %{buildroot}%{_sysconfdir}/esoreflex.rc
install -m 755 -d %{buildroot}%{_datadir}/reflex/workflows
ln -s %{_datadir}/%{targetname}/esoreflex/eso-demo-workflows %{buildroot}%{_datadir}/reflex/workflows/%{targetname}-demos
install -m 755 -d %{buildroot}%{_datadir}/reflex/recipes
echo 'Should be replaced in post install (version = %{version}).' > %{buildroot}%{_sysconfdir}/esoreflex-esorex.rc

%define version_file %{buildroot}%{_datadir}/%{targetname}/esoreflex/version

%check
# Check that the version file exists and is compatible with the version tag set
# in the Specfile.
if [ ! -f '%{version_file}' ] ; then
    echo 'ERROR: Missing version file under %{version_file}.' 1>&2
    exit 1
fi
if ! grep '%{version}' '%{version_file}' > /dev/null ; then
    echo 'ERROR: File %{version_file} appears to have a different version than what is delcared in the Spec file.' 1>&2
    exit 1
fi

%post
# Replace the temporary contents of the EsoReflex specific EsoRex config file
# with the active EsoRex configuration and update the recipe directory in the
# copied file.
if grep 'Should be replaced in post install (version = %{version}).' %{_sysconfdir}/esoreflex-esorex.rc > /dev/null ; then
  CONFIG_FILE=%{_sysconfdir}/esoreflex-esorex.rc
elif test -f %{_sysconfdir}/esoreflex-esorex.rc.rpmnew ; then
  if grep 'Should be replaced in post install (version = %{version}).' %{_sysconfdir}/esoreflex-esorex.rc.rpmnew > /dev/null ; then
    CONFIG_FILE=%{_sysconfdir}/esoreflex-esorex.rc.rpmnew
  fi
fi
if test -n "$CONFIG_FILE" ; then
  sed -e 's|\(esorex.caller.recipe-dir=.*\)|\1:%{_datadir}/reflex/recipes|' %{_sysconfdir}/esorex.rc > "$CONFIG_FILE"
fi

%files
%dir %{_datadir}/%{targetname}
%dir %{_datadir}/%{targetname}/esoreflex
%doc %{_datadir}/%{targetname}/esoreflex/COPYING
%doc %{_datadir}/%{targetname}/esoreflex/LICENSE
%doc %{_datadir}/%{targetname}/esoreflex/ReleaseNotes
%config(noreplace) %{_sysconfdir}/*
%{_bindir}/*
%{_datadir}/%{targetname}/esoreflex.jar
%{_datadir}/%{targetname}/esoreflex/version
%{_datadir}/%{targetname}/esoreflex/.project
%{_datadir}/%{targetname}/esoreflex/.classpath
%{_datadir}/%{targetname}/esoreflex/bin
%{_datadir}/%{targetname}/esoreflex/doc
%{_datadir}/%{targetname}/esoreflex/eso-demo-workflows
%{_datadir}/%{targetname}/esoreflex/lib
%{_datadir}/%{targetname}/esoreflex/python
%{_datadir}/%{targetname}/esoreflex/resources
%{_datadir}/%{targetname}/esoreflex/src
%{_datadir}/%{targetname}/esoreflex/target
%{_datadir}/%{targetname}/actors
%{_datadir}/%{targetname}/authentication
%{_datadir}/%{targetname}/authentication-gui
%{_datadir}/%{targetname}/build-area
%{_datadir}/%{targetname}/common
%{_datadir}/%{targetname}/component-library
%{_datadir}/%{targetname}/configuration-manager
%{_datadir}/%{targetname}/core
%{_datadir}/%{targetname}/data-handling
%{_datadir}/%{targetname}/dataone
%{_datadir}/%{targetname}/dataturbine
%{_datadir}/%{targetname}/directors
%{_datadir}/%{targetname}/display-redirect
%{_datadir}/%{targetname}/ecogrid
%{_datadir}/%{targetname}/event-state
%{_datadir}/%{targetname}/gui
%{_datadir}/%{targetname}/io
%{_datadir}/%{targetname}/job
%{_datadir}/%{targetname}/kepler
%{_datadir}/%{targetname}/kepler-tasks
%{_datadir}/%{targetname}/loader
%{_datadir}/%{targetname}/module-manager
%{_datadir}/%{targetname}/module-manager-gui
%{_datadir}/%{targetname}/opendap
%{_datadir}/%{targetname}/outreach
%{_datadir}/%{targetname}/ptolemy
%{_datadir}/%{targetname}/r
%{_datadir}/%{targetname}/repository
%{_datadir}/%{targetname}/sms
%{_datadir}/%{targetname}/ssh
%{_datadir}/%{targetname}/util
%dir %{_datadir}/reflex
%dir %{_datadir}/reflex/recipes
%dir %{_datadir}/reflex/workflows
%{_datadir}/reflex/workflows/*

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 2.11.5-1
- New version created.
