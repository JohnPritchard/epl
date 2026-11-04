%define instrument giraf
Name: esopipe-%{instrument}-recipes
Version: 2.18.4
Release: 3%{?dist}
Summary: ESO GIRAFFE instrument pipeline (recipe plugins)

Group: Applications/Scientific
License: GPLv2+
Vendor: European Southern Observatory
Packager: <usd-help@eso.org>
URL: http://www.eso.org/sci/software/pipelines
Source0: %{instrument}-%{version}.tar.gz

BuildRequires: cext-devel >= 1.2
BuildRequires: cfitsio-devel >= 3.350
BuildRequires: cpl-devel >= 7.0
BuildRequires: gcc
BuildRequires: pkgconfig >= 0.21


%description
ESO data reduction pipeline recipe plugins for the GIRAFFE instrument.
See www.eso.org/pipelines for a description of the ESO pipeline systems.
To execute these one needs to install a front-end such as esorex or Reflex.

%package -n esopipe-%{instrument}-wkf
Summary: ESO GIRAFFE instrument pipeline (workflows)
Requires: %{name} = %{version}-%{release}
Requires: adari >= 3.0.0
Requires: esoreflex >= 2.8
Requires: python3-astropy >= 1.0
Requires: python3-edps >= 1.3.3
Requires: python3-matplotlib-wx >= 1.2
Requires: python3-numpy >= 1.5
Requires: python3-wxpython4 >= 2.8.12
Requires: esopipe-detmon-recipes
Requires: esopipe-esotk-recipes
%description -n esopipe-%{instrument}-wkf
ESO data reduction pipeline workflows for the GIRAFFE instrument.
See www.eso.org/pipelines for a description of the ESO pipeline systems.

%prep
if ! test -f %{SOURCE0} ; then
    # Unpack the source tarball from the pipeline kit if it is not yet available.
    cd '%{_sourcedir}'
    %_urlhelper - 'https://ftp.eso.org/pub/dfs/pipelines/kit_devel/%{instrument}-kit-%{version}-4.tar.gz' | gzip -dc | tar -xf - '%{instrument}-kit-%{version}-4/%{instrument}-%{version}.tar.gz'
    mv '%{instrument}-kit-%{version}-4/%{instrument}-%{version}.tar.gz' ./
    rmdir '%{instrument}-kit-%{version}-4'
fi
%setup -q -n %{instrument}-%{version} -c -T
cd %{_builddir}
gzip -dc '%{SOURCE0}' | tar -xf -

%build
%configure
# http://fedoraproject.org/wiki/PackagingGuidelines#Beware_of_Rpath
sed -i 's|^hardcode_libdir_flag_spec=.*|hardcode_libdir_flag_spec=""|g' libtool
sed -i 's|^runpath_var=LD_RUN_PATH|runpath_var=DIE_RPATH_DIE|g' libtool
%make_build

%check
make %{?_smp_mflags} installcheck

%define ld_conf_file %{_sysconfdir}/ld.so.conf.d/%{instrument}-%{version}.conf

%install
rm -rf %{buildroot}
%make_install
install -m 755 -d %{buildroot}%{_sysconfdir}/ld.so.conf.d
echo '%{_libdir}/%{instrument}-%{version}' > %{buildroot}%{ld_conf_file}
find %{buildroot}%{_datadir}/reflex/workflows \
     %{buildroot}%{_datadir}/esopipes/*/reflex -name '*.xml' -print0 | \
while IFS= read -r -d '' N ; do
    sed -i "s|CALIB_DATA_PATH_TO_REPLACE|%{_datadir}/esopipes/datastatic|g" "$N"
    sed -i 's|ROOT_DATA_PATH_TO_REPLACE|$HOME/reflex_data|g' "$N"
    sed -i "s|\(<property name=\"RAW_DATA_DIR\" class=\"ptolemy\.data\.expr\.FileParameter\" value=\"\).*\">|\1%{_datadir}/esopipes/datademo/%{instrument}/\">|" "$N"
    # The following is for workflows that did not move to the new RAW_DATA_DIR standard.
    sed -i "s|\(<property name=\"RAWDATA_DIR\" class=\"ptolemy\.data\.expr\.FileParameter\" value=\"\).*\">|\1%{_datadir}/esopipes/datademo/%{instrument}/\">|" "$N"
done

%ldconfig_scriptlets

%files
%dir %{_docdir}/esopipes
%dir %{_docdir}/esopipes/*
%doc %{_docdir}/esopipes/*/*
%config %{ld_conf_file}
%{_libdir}/*
%exclude %{_libdir}/*/*.so
%exclude %{_libdir}/*/*.la
%exclude %{_libdir}/esopipes-plugins/*/*.la
%exclude %{_includedir}/*

%files -n esopipe-%{instrument}-wkf
%{_datadir}/reflex
%dir %{_datadir}/esopipes
%dir %{_datadir}/esopipes/*
%{_datadir}/esopipes/*/reflex
%{_datadir}/esopipes/reports/*
%{_datadir}/esopipes/workflows/*

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 2.18.4-3
- New version created.
